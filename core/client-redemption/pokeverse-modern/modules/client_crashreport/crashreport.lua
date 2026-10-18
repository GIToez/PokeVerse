-- When the Windows client crashes it saves crashreport.log in the client's folder (win32crashhandler.cpp),
-- with the backtrace and the last log lines, and a minidump crashreport.dmp; every start keeps the last session's log as
-- pokeverse-previous.log. On the next start this offers to copy the report. A session that ended without
-- terminate() running (a crash the handler didn't catch, a freeze that was killed) is spotted by the marker
-- it leaves behind, and then the end of the previous log is offered instead. Not on mobile, where the system
-- kills the app all the time.
local REPORT = '/crashreport.log'
local SHOWN = '/crashreport-previous.log'
local DUMP = '/crashreport.dmp'
local MARKER = '/session.running'
local LOG_LINES = 200

local box
local showEvent

local function closeBox()
    if box then
        box:destroy()
        box = nil
    end
end

local function previousLogTail()
    local path = g_resources.getUserDir() .. g_app.getCompactName() .. '-previous.log'
    local ok, file = pcall(io.open, path, 'r')
    if not ok or not file then
        return nil
    end
    local lines = {}
    for line in file:lines() do
        lines[#lines + 1] = line
        if #lines > LOG_LINES then
            table.remove(lines, 1)
        end
    end
    file:close()
    return table.concat(lines, '\n')
end

-- Explorer opens Documents instead of a path with forward slashes
local function openFolder(dir)
    if g_app.getOs() == 'windows' then
        dir = dir:gsub('/', '\\')
    end
    g_platform.openDir(dir)
end

local function offer(title, message, text, folder)
    closeBox()
    local function copy()
        g_window.setClipboardText(text)
        closeBox()
        displayInfoBox(tr('Crash report'), tr('Copied. Paste it wherever you report bugs.'))
    end
    local buttons = { { text = tr('Copy report'), callback = copy } }
    if not g_platform.isMobile() then
        buttons[#buttons + 1] = { text = tr('Open folder'), callback = function()
            openFolder(folder)
        end }
    end
    buttons[#buttons + 1] = { text = tr('Close'), callback = closeBox }
    box = displayGeneralBox(title, message, buttons, copy, closeBox)
end

local function check(unclean)
    if g_resources.fileExists(REPORT) then
        local report = g_resources.readFileContents(REPORT)
        g_resources.writeFileContents(SHOWN, report)
        g_resources.deleteFile(REPORT)
        local message = tr('PokeVerse crashed last time and saved a crash report.\nCopy it and post it so the crash can be fixed.')
        if g_resources.fileExists(DUMP) then
            message = message .. '\n\n' .. tr('Please also post the file crashreport.dmp from its folder (Open folder).')
        end
        offer(tr('PokeVerse crashed'), message, report, g_resources.getWriteDir())
        return
    end

    -- the dump of a crash that was already offered
    if g_resources.fileExists(DUMP) then
        g_resources.deleteFile(DUMP)
    end

    if unclean and not g_platform.isMobile() then
        local log = previousLogTail()
        if log and log ~= '' then
            offer(tr('PokeVerse closed unexpectedly'),
                tr('PokeVerse did not close properly last time.\nIf it crashed or froze, copy the end of its log and post it.'),
                log, g_resources.getUserDir())
        end
    end
end

function init()
    local unclean = g_resources.fileExists(MARKER)
    g_resources.writeFileContents(MARKER, os.date('%Y-%m-%d %H:%M:%S'))
    -- after the login screen is up, so the box lands on top of it
    showEvent = scheduleEvent(function()
        showEvent = nil
        check(unclean)
    end, 1500)
end

function terminate()
    if showEvent then
        removeEvent(showEvent)
        showEvent = nil
    end
    closeBox()
    g_resources.deleteFile(MARKER)
end
