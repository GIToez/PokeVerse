-- PokeVerse updater: reads a static manifest from GitHub Pages instead of posting to a PHP
-- script. Services.updater is the manifest folder; the client fetches <os>.json from it:
--
--   {
--     "version": "client-42",
--     "url": "https://<pages>/updater/files",          -- base for every file below
--     "files": { "/init.lua": "<crc32>", ... },
--     "sizes": { "/init.lua": 1234, ... },              -- bytes, for the progress (optional)
--     "urls": { "/data/things/data.spr": "https://github.com/.../releases/download/..." },
--     "binary": { "file": "/PokeVerse.exe", "checksum": "<crc32>", "size": 123 }
--   }
--
-- Checksums are lowercase hex CRC32 without leading zeros (g_resources.filesChecksums).
-- "urls" holds absolute URLs for files that cannot be on Pages (over its 100 MB limit).
--
-- Files download a few at a time and are written to disk in batches as they arrive, so an
-- interrupted update keeps what was written and the next start only fetches what is missing.
-- The executable and the files the updater itself runs on (CORE) come last and are written
-- together, so an interrupted update always restarts with the old updater intact.

Updater = {}

Updater.maxRetries = 5
Updater.parallel = 4
Updater.batchSize = 25

-- files the updater needs to start; never written half way, always after the rest
local CORE = { "^/init%.lua$", "^/modules/corelib/", "^/modules/updater/", "^/modules/client_locales/",
               "^/modules/client_styles/", "^/data/styles/" }
local RESTART = { "init.lua", "corelib", "updater", "otmod" }

local BACKGROUND_NONE, BACKGROUND_UPDATING = 0, 1

local updaterWindow
local loadModulesFunction
local scheduledEvent
local manifestOperation = 0
local operations = {}
local lastBackgroundUpdate = 0

local function onLog(level, message, time)
  if level == LogError then
    Updater.error(message)
    g_logger.setOnLog(nil)
  end
end

local function loadModules()
  if loadModulesFunction then
    local tmpLoadFunc = loadModulesFunction
    loadModulesFunction = nil
    tmpLoadFunc()
  end
end

local function encodePath(path)
  return (path:gsub("[^%w%-%._~/]", function(c) return string.format("%%%02X", string.byte(c)) end))
end

local function manifestUrl()
  local base = Services.updater
  if base:sub(-1) ~= "/" then base = base .. "/" end
  return base .. g_app.getOs() .. ".json"
end

local function fileUrl(data, file)
  if type(data.urls) == "table" and type(data.urls[file]) == "string" then
    return data.urls[file]
  end
  local base = data.url
  if base:sub(-1) == "/" then base = base:sub(1, -2) end
  if file:sub(1, 1) ~= "/" then file = "/" .. file end
  return base .. encodePath(file)
end

local function matchesAny(file, patterns, plain)
  for _, pattern in ipairs(patterns) do
    if file:find(pattern, 1, plain) then
      return true
    end
  end
  return false
end

local function formatMB(bytes)
  return string.format("%.1f MB", bytes / (1024 * 1024))
end

local function setBackgroundTask(kind, text, percent)
  if g_android and g_android.setBackgroundTask then
    g_android.setBackgroundTask(kind, text or "", percent or -1)
  end
end

local function writeFiles(files)
  if #files == 0 then return end
  g_resources.updateFiles(files)
  if g_http.forgetDownload then
    for _, file in ipairs(files) do
      g_http.forgetDownload(file)
    end
  end
end

-- Downloads one step's files, Updater.parallel at a time. Finished files are written every
-- Updater.batchSize files and at the end, unless keepAll is set: then they stay in memory
-- for the caller to install.
local function downloadStep(step, keepAll, onDone)
  local files = step.files
  local nextIndex, active, done = 1, 0, 0
  local pending = {}
  local inFlight = {}
  local finished = false
  local lastFile = ""
  local speed, speedTime, speedBytes = 0, g_clock.millis(), step.doneBytes

  local function refresh(current)
    if not updaterWindow then return end
    if current then lastFile = current end
    local received = step.doneBytes
    for _, partial in pairs(inFlight) do
      received = received + partial
    end
    local bytesLeft = math.max(step.totalBytes - received, 0)

    local now = g_clock.millis()
    if now - speedTime >= 1000 then
      speed = (received - speedBytes) * 1000 / (now - speedTime)
      speedTime, speedBytes = now, received
    end

    local fileText = tr("File %i of %i", step.countFrom + math.min(done + active, #files), step.countOf)
    local lines = { fileText }
    if step.totalBytes > 0 then
      lines[1] = fileText .. "  -  " .. tr("%s left", formatMB(bytesLeft))
      updaterWindow.mainProgress:setPercent(math.floor(100 * (1 - bytesLeft / step.totalBytes)))
    else
      updaterWindow.mainProgress:setPercent(math.floor(100 * done / #files))
    end
    if speed >= 1024 * 1024 then
      table.insert(lines, string.format("%.1f MB/s", speed / (1024 * 1024)))
    elseif speed > 0 then
      table.insert(lines, string.format("%.0f kB/s", speed / 1024))
    end
    table.insert(lines, lastFile)
    updaterWindow.downloadStatus:setText(table.concat(lines, "\n"))

    if g_clock.millis() - lastBackgroundUpdate > 1000 then
      lastBackgroundUpdate = g_clock.millis()
      local percent = step.totalBytes > 0 and math.floor(100 * (1 - bytesLeft / step.totalBytes)) or -1
      setBackgroundTask(BACKGROUND_UPDATING, lines[1], percent)
    end
  end

  local function flush(force)
    if keepAll then return end
    if #pending >= Updater.batchSize or (force and #pending > 0) then
      writeFiles(pending)
      pending = {}
    end
  end

  local startNext
  local function fetch(entry, retries)
    local file, checksum, url, size = entry[1], entry[2], entry[3], entry[4]
    active = active + 1
    inFlight[file] = 0
    refresh(file)
    local id
    id = HTTP.download(url, file,
      function(path, gotChecksum, err)
        operations[id] = nil
        inFlight[file] = nil
        active = active - 1
        if not updaterWindow or finished then return end
        if not err and gotChecksum ~= checksum then
          err = "Invalid checksum of: " .. file .. ".\nShould be " .. checksum .. ", is: " .. gotChecksum
        end
        if err then
          if retries >= Updater.maxRetries then
            finished = true
            return Updater.error("Can't download file: " .. file .. ".\nError: " .. err)
          end
          active = active + 1 -- still owed; keeps the step from finishing while it waits
          scheduledEvent = scheduleEvent(function()
            active = active - 1
            if updaterWindow and not finished then fetch(entry, retries + 1) end
          end, 250 * (retries + 1))
          return
        end
        done = done + 1
        step.doneBytes = step.doneBytes + size
        table.insert(pending, file)
        flush(false)
        refresh()
        startNext()
      end,
      function(progress)
        inFlight[file] = size * (tonumber(progress) or 0) / 100
        refresh()
      end)
    operations[id] = true
  end

  startNext = function()
    if finished then return end
    while active < Updater.parallel and nextIndex <= #files do
      local entry = files[nextIndex]
      nextIndex = nextIndex + 1
      fetch(entry, 0)
    end
    if active == 0 and nextIndex > #files then
      finished = true
      flush(true)
      onDone()
    end
  end

  startNext()
end

local function finish(restart, reloadModules)
  setBackgroundTask(BACKGROUND_NONE)
  if restart and g_app.getOs() == "android" then
    -- Android apps cannot relaunch themselves; the files are in place for the next start
    local message = tr("Update installed. Reopen PokeVerse to finish.")
    updaterWindow.status:setText(message)
    local close = function() g_app.exit() end
    displayGeneralBox(tr("Updater"), message, {{text = tr("Close"), callback = close}}, close, close)
  elseif restart then
    g_app.restart()
  else
    if reloadModules then
      g_textures.clearCache()
      g_modules.reloadModules()
    end
    Updater.abort()
  end
end

local function updateFiles(data)
  if not updaterWindow then return end

  if type(data) ~= "table" then
    return Updater.error("Invalid data from the updater (not a table)")
  end

  if type(data.error) == 'string' and data.error:len() > 0 then
    return Updater.error(data.error)
  end

  if type(data.files) ~= "table" or type(data.url) ~= 'string' or data.url:len() < 4 then
    return Updater.error("Invalid data from the updater: " .. json.encode(data, 2))
  end

  local sizes = type(data.sizes) == "table" and data.sizes or {}
  local localFiles = g_resources.filesChecksums()

  local core = { files = {}, totalBytes = 0, doneBytes = 0 }
  local rest = { files = {}, totalBytes = 0, doneBytes = 0 }
  local restart, reloadModules = false, false
  for file, checksum in pairs(data.files) do
    if localFiles[file] ~= checksum then
      local size = tonumber(sizes[file]) or 0
      local step = matchesAny(file, CORE) and core or rest
      table.insert(step.files, { file, checksum, fileUrl(data, file), size })
      step.totalBytes = step.totalBytes + size
      if matchesAny(file, RESTART, true) then restart = true end
      if not file:find("data/things", 1, true) then reloadModules = true end
    end
  end
  -- big files first, so the count at the end moves quickly
  table.sort(rest.files, function(a, b) return a[4] > b[4] end)

  local binary = nil
  if type(data.binary) == "table" and type(data.binary.file) == "string" and data.binary.file:len() > 1 then
    local selfChecksum = g_resources.selfChecksum()
    if selfChecksum:len() > 0 and selfChecksum ~= data.binary.checksum then
      binary = data.binary.file
      local size = tonumber(data.binary.size) or 0
      table.insert(core.files, { binary, data.binary.checksum, fileUrl(data, binary), size })
      core.totalBytes = core.totalBytes + size
    end
  end

  if #core.files == 0 and #rest.files == 0 then
    updaterWindow.mainProgress:setPercent(100)
    scheduledEvent = scheduleEvent(Updater.abort, 20)
    return
  end

  updaterWindow.mainProgress:setPercent(0)
  updaterWindow.downloadStatus:show()

  -- one count and one "MB left" for the whole update; CORE is downloaded after the rest
  local totalFiles = #rest.files + #core.files
  local totalBytes = rest.totalBytes + core.totalBytes
  if totalBytes > 0 then
    updaterWindow.status:setText(tr("Downloading %i files (%s)", totalFiles, formatMB(totalBytes)))
  else
    updaterWindow.status:setText(tr("Downloading %i files", totalFiles))
  end

  local function installCore()
    updaterWindow.status:setText(tr("Updating client (may take few seconds)"))
    updaterWindow.mainProgress:setPercent(100)
    updaterWindow.downloadStatus:hide()
    scheduledEvent = scheduleEvent(function()
      local written = {}
      for _, entry in ipairs(core.files) do
        if entry[1] ~= binary then
          table.insert(written, entry[1])
        end
      end
      writeFiles(written)
      if binary then
        g_resources.updateExecutable(binary)
      end
      finish(binary or restart or (not loadModulesFunction and reloadModules), reloadModules)
    end, 100)
  end

  local restStep = { files = rest.files, totalBytes = totalBytes, doneBytes = 0,
                     countFrom = 0, countOf = totalFiles }
  local coreStep = { files = core.files, totalBytes = totalBytes, doneBytes = 0,
                     countFrom = #rest.files, countOf = totalFiles }

  local function runCore()
    if #core.files == 0 then return installCore() end
    coreStep.doneBytes = restStep.doneBytes
    downloadStep(coreStep, true, installCore)
  end

  if #rest.files == 0 then return runCore() end
  downloadStep(restStep, false, runCore)
end

-- public functions
function Updater.init(loadModulesFunc)
  g_logger.setOnLog(onLog)
  loadModulesFunction = loadModulesFunc
  Updater.check()
end

function Updater.terminate()
  loadModulesFunction = nil
  Updater.abort(true)
end

function Updater.abort(terminate)
  HTTP.cancel(manifestOperation)
  for id in pairs(operations) do
    HTTP.cancel(id)
  end
  operations = {}
  removeEvent(scheduledEvent)
  setBackgroundTask(BACKGROUND_NONE)
  if updaterWindow then
    updaterWindow:destroy()
    updaterWindow = nil
  end
  loadModules()
  if not terminate then
    signalcall(g_app.onUpdateFinished, g_app)
  end
end

function Updater.check()
  if updaterWindow then return end

  updaterWindow = g_ui.displayUI('updater')
  if not updaterWindow then
    return Updater.abort()
  end
  updaterWindow:show()
  updaterWindow:focus()
  updaterWindow:raise()

  local updateData = nil
  local function progressUpdater(value)
    removeEvent(scheduledEvent)
    if value == 100 then
      return Updater.error(tr("Timeout"))
    end
    if updateData then
      return updateFiles(updateData)
    end
    scheduledEvent = scheduleEvent(function() progressUpdater(value + 1) end, 100)
    updaterWindow.mainProgress:setPercent(value)
  end
  progressUpdater(0)

  manifestOperation = HTTP.getJSON(manifestUrl(), function(data, err)
    if err then
      return Updater.error(err)
    end
    updateData = data
  end)
end

function Updater.error(message)
  removeEvent(scheduledEvent)
  setBackgroundTask(BACKGROUND_NONE)
  if not updaterWindow then return end
  displayErrorBox(tr("Updater Error"), message).onOk = function()
    Updater.abort()
  end
end
