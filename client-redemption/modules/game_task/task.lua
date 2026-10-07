-- Kill tasks (ext opcode 58). The server owns the task list, progress, rewards and rank unlocks;
-- this window only shows what it sends and talks /task, /taskrank and /taskbuyrank back.
local OPCODE = 58
local RANKS = { 'E', 'D', 'C', 'B', 'A', 'S' }
local BUTTON_ACTIONS = { doneButtonWidget = 'done', cancelButtonWidget = 'cancel', acceptButtonWidget = 'accept' }
local HUNTER_TOKEN = 33448

local window, taskList, mainButton, unlockWindow, delayWindow
local entries = {}
local currentRank = 'E'
local lastAlert

local ALERTS = {
  ['[TaskNaoCompleta]'] = 'You have not finished this task yet.',
  ['[MissaoAbandonada]'] = 'You cancelled a task. Try a task close to your level for a better chance of success.',
  ['[PegueiUmaMissao]'] = 'You took a task! Defeat the chosen Pokemon to receive your reward.',
  ['[CompleteiAMissao]'] = 'Congratulations! You completed your task. Keep going to climb the task ranks.',
}

local function displayName(id)
  return CORRECT_NAME[id] or id:gsub('(%a)([%w]*)', function(a, b) return a:upper() .. b end)
end

local function typeImage(typeName)
  if not typeName or typeName == '' then return '' end
  return '/modules/game_task/images/window_list/type/type_ball/' .. typeName
end

local function formatMinutes(minutes)
  local hours = math.floor(minutes / 60)
  if hours > 0 then
    return tr('%dh %dmin', hours, minutes % 60)
  end
  return tr('%d min', minutes)
end

function closePopups()
  if unlockWindow then
    unlockWindow:destroy()
    unlockWindow = nil
  end
  if delayWindow then
    delayWindow:destroy()
    delayWindow = nil
  end
end

function hideAlert()
  window:getChildById('WindowAlert'):hide()
  window:getChildById('BackgroundBlack'):hide()
end

local function showAlert(key)
  lastAlert = key
  local alert = window:getChildById('WindowAlert')
  alert:getChildById('desc'):setText(tr(ALERTS[key]))
  window:getChildById('BackgroundBlack'):show()
  alert:show()
  alert:raise()
end

local function clearEntries()
  for _, entry in pairs(entries) do
    entry:destroy()
  end
  entries = {}
end

local function setButtons(entry, doing)
  if entry.buttons and entry.doing == doing then return end
  if entry.buttons then entry.buttons:destroy() end
  entry.doing = doing
  entry.buttons = g_ui.createWidget(doing and 'TaskDoneCancel' or 'TaskAccept', entry)
  for buttonId, action in pairs(BUTTON_ACTIONS) do
    local button = entry.buttons:getChildById(buttonId)
    if button then
      button.onClick = function() g_game.talk('/task ' .. action .. ',' .. entry.taskId) end
    end
  end
end

local function updateEntry(info)
  if type(info) ~= 'table' or type(info.id) ~= 'string' then return end
  local entry = entries[info.id]
  if not entry then
    entry = g_ui.createWidget('TaskButton', taskList)
    entry:setId('task_' .. info.id)
    entry.taskId = info.id
    entries[info.id] = entry
    local outfit = g_ui.createWidget('TaskOutfit', entry:getChildById('SlotOutfit'))
    if POKE_SPRITE[info.id] then
      outfit:setOutfit({ type = POKE_SPRITE[info.id] })
    end
  end
  local data = TABLE_KILL[info.id] or {}
  if data.background then
    entry:setImageSource('/modules/game_task/images/window_list/type/' .. data.background)
  end
  entry:getChildById('BackgroudType'):setImageSource('/modules/game_task/images/window_list/' .. (info.doing and 'border_on' or 'border_off'))
  setButtons(entry, info.doing and true or false)

  local type1, type2 = entry:getChildById('type1'), entry:getChildById('type2')
  type1:setImageSource(typeImage(data.type1))
  type1:setTooltip(data.type1 and tr(data.type1) or '')
  type2:setImageSource(typeImage(data.type2))
  type2:setTooltip(data.type2 and data.type2 ~= '' and tr(data.type2) or '')

  entry.kills, entry.count = tonumber(info.kills) or 0, tonumber(info.count) or 0
  local name = displayName(info.id)
  entry:getChildById('NamePoke'):setText(name)
  entry:getChildById('labelKill'):setText(string.format('- %d/%d', entry.kills, entry.count))
  entry:getChildById('labelLevel'):setText(tr('Lv.') .. tostring(info.level))
  entry:getChildById('labelReward'):setText(tr('Experience: %s', tostring(info.reward)))
  entry:getChildById('labelPoint'):setText(tr('Hunt points: %s', tostring(info.point)))
  entry:getChildById('desc'):setText(tr('Defeat %d %s to complete this task.', entry.count, name))
  local token = entry:getChildById('itemSlot1')
  token:setItemId(HUNTER_TOKEN)
  token:setTooltip(tr('Hunter Token'))
end

local function showUnlock(info)
  closePopups()
  unlockWindow = g_ui.createWidget('TaskUnlockWindow', rootWidget)
  unlockWindow:getChildById('unlockRankLevel'):setText(tr('Level: %s', tostring(info.level)))
  unlockWindow:getChildById('unlockRankPoints'):setText(tr('Points: %s', tostring(info.points)))
  unlockWindow:getChildById('unlockRankRank'):setText(tr('Rank %s unlocked', tostring(info.rank)))
  unlockWindow:getChildById('unlockRankUnlock').onClick = function()
    for i, rank in ipairs(RANKS) do
      if rank == info.rank and RANKS[i + 1] then
        g_game.talk('/taskbuyrank ' .. RANKS[i + 1])
      end
    end
    closePopups()
  end
  unlockWindow:focus()
end

local function showDelay(minutes)
  closePopups()
  delayWindow = g_ui.createWidget('TaskDelayWindow', rootWidget)
  delayWindow:getChildById('minutesLabel'):setText(tr('You must wait %s to take this task again.', formatMinutes(tonumber(minutes) or 0)))
  delayWindow:focus()
end

local function onTaskOpcode(protocol, opcode, buffer)
  if not window then return end
  if buffer == '[resetList]' then
    clearEntries()
    return
  end
  local data = table.fromLiteral(buffer)
  if type(data) ~= 'table' then return end
  for key in pairs(ALERTS) do
    if data[key] then
      showAlert(key)
      return
    end
  end
  local playerData = false
  if data['[unlockRank]'] then
    showUnlock(data['[unlockRank]'])
    playerData = true
  end
  if data['[delayTask]'] then
    showDelay(data['[delayTask]'])
    playerData = true
  end
  if data['[pointsHave]'] then
    window:getChildById('labelPoints'):setText(math.max(0, tonumber(data['[pointsHave]']) or 0))
    playerData = true
  end
  if data['[unlockedRanks]'] then
    local unlocked = {}
    for _, rank in pairs(data['[unlockedRanks]']) do unlocked[rank] = true end
    for _, rank in ipairs(RANKS) do
      local button = window:recursiveGetChildById('Rank' .. rank)
      button:getChildById('RankButtonLock'):setImageSource(unlocked[rank] and '' or '/modules/game_task/images/locked')
      button:setOn(rank == currentRank)
    end
    playerData = true
  end
  if playerData then return end
  for _, info in pairs(data) do
    updateEntry(info)
  end
end

function parseRank(rank)
  currentRank = rank
  g_game.talk('/taskrank ' .. rank)
  g_game.talk('/taskstatus')
end

function show()
  if not g_game.isOnline() then return end
  parseRank(currentRank)
  window:show()
  window:raise()
  window:focus()
  if mainButton then mainButton:setOn(true) end
end

function hide()
  closePopups()
  hideAlert()
  window:hide()
  if mainButton then mainButton:setOn(false) end
end

function toggle()
  if window:isVisible() then hide() else show() end
end

function isVisible()
  return window and window:isVisible()
end

function getState()
  local tasks, doing = 0, nil
  for id, entry in pairs(entries) do
    tasks = tasks + 1
    if entry.doing then doing = { id = id, kills = entry.kills, count = entry.count } end
  end
  return { visible = window:isVisible(), tasks = tasks, doing = doing, points = window:getChildById('labelPoints'):getText(),
    alert = window:getChildById('WindowAlert'):isVisible() and lastAlert or nil, delay = delayWindow ~= nil,
    unlock = unlockWindow ~= nil }
end

function getEntry(id)
  return entries[id]
end

local function online()
  currentRank = 'E'
  clearEntries()
end

local function offline()
  closePopups()
  if window then hide() end
  clearEntries()
end

function init()
  window = g_ui.loadUI('task', modules.game_interface.getRootPanel())
  taskList = window:recursiveGetChildById('panelPTaskList')
  mainButton = modules.game_mainpanel.addToggleButton('taskButton', tr('Tasks'), '/modules/game_task/images/button', toggle,
    false, 23)
  ProtocolGame.registerExtendedOpcode(OPCODE, onTaskOpcode)
  connect(g_game, { onGameStart = online, onGameEnd = offline })
end

function terminate()
  disconnect(g_game, { onGameStart = online, onGameEnd = offline })
  ProtocolGame.unregisterExtendedOpcode(OPCODE)
  closePopups()
  clearEntries()
  if mainButton then
    mainButton:destroy()
    mainButton = nil
  end
  window:destroy()
  window = nil
end
