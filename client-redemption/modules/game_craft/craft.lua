-- Profession crafting (ext opcode 103). Using a crafting table makes the server send the profession
-- ('work') and that rank's recipes ('items'); recipes, materials, timers and rewards stay on the
-- server, which answers every create, speed up and collect with 'refreshItem'.
local OPCODE = 103
local MAX_QUANTITY = 100
local RANK_ORDER = { E = 5, D = 4, C = 3, B = 2, A = 1, S = 0 }
-- The server names the professions in English; the artwork keeps the original file names.
local WORK_IMAGES = { stylist = 'stylist', adventurer = 'aventureiro', professor = 'professor', enginner = 'engenheiro',
  engineer = 'engenheiro' }

local mainWindow, createWindow, speedUpWindow, listPanel, rankPanel
local collectButton, speedUpButton
local workLevel, workName = 0, nil
local currentRank, selected
local openPosition

local function formatTime(seconds)
  seconds = math.max(0, math.floor(tonumber(seconds) or 0))
  local hours, minutes = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60)
  local text = ''
  if hours > 0 then text = text .. hours .. 'h ' end
  if minutes > 0 then text = text .. minutes .. 'm ' end
  return text .. (seconds % 60) .. 's'
end

local function stopEvent(widget)
  if widget.event then
    removeEvent(widget.event)
    widget.event = nil
  end
end

local function stopEvents()
  for _, child in ipairs(listPanel:getChildren()) do
    stopEvent(child)
  end
end

local function created(info)
  if info.storage_qnt <= 0 then return 0 end
  if info.storage_time <= 0 then return info.storage_qnt end
  return math.floor((info.storage_qnt * info.timeByUnit - info.storage_time) / info.timeByUnit)
end

local function updateActions()
  local info = selected and selected.INFO
  local collectable = info and info.collectable or 0
  collectButton:setVisible(collectable > 0)
  speedUpButton:setVisible(info ~= nil and info.storage_time > 0)
  speedUpButton:breakAnchors()
  speedUpButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
  speedUpButton:addAnchor(AnchorRight, collectable > 0 and 'craftItemCollect' or 'craftItemCreate', AnchorLeft)
end

local function drawProgress(widget)
  local info = widget.INFO
  local done = created(info)
  info.collectable = done - math.max(0, info.storage_collected)
  local progressBar, timedesc = widget:getChildById('progressBar'), widget:getChildById('timedesc')
  local progressIcon, progressWindow = widget:getChildById('progressIcon'), widget:getChildById('progressLabelwindow')
  if info.storage_qnt > 0 then
    local total = info.storage_qnt * info.timeByUnit
    local percent = total > 0 and math.floor((total - info.storage_time) * 100 / total) or 100
    progressBar:setPercent(math.max(0, math.min(100, percent)))
    progressBar:show()
    progressIcon:setImageSource(info.storage_time > 0 and '/modules/game_craft/images/progressIconAnimated' or
      '/modules/game_craft/images/progressIcon')
    progressIcon:show()
    timedesc:setText(info.storage_time > 0 and ('- ' .. formatTime(info.storage_time)) or '- 100%')
    timedesc:show()
    progressWindow:setTooltip(tr('Finished: %d', done) .. '\n' .. tr('Ready to collect: %d', info.collectable) .. '\n' ..
      tr('Total units: %d', info.storage_qnt))
    progressWindow:show()
  else
    progressBar:hide()
    progressIcon:hide()
    timedesc:hide()
    progressWindow:hide()
  end
  if widget == selected then updateActions() end
end

local function startTimer(widget)
  stopEvent(widget)
  if widget.INFO.storage_time <= 0 then return end
  widget.event = cycleEvent(function()
    local info = widget.INFO
    info.storage_time = math.max(0, info.storage_time - 1)
    drawProgress(widget)
    if info.storage_time <= 0 then stopEvent(widget) end
  end, 1000)
end

local function selectWidget(widget)
  if selected and not selected:isDestroyed() then
    selected:setImageSource('/modules/game_craft/images/interface/window_craft')
  end
  selected = widget
  if widget then
    widget:setImageSource('/modules/game_craft/images/interface/window_craftLight')
  end
  updateActions()
end

local function addItem(info)
  local widget = g_ui.createWidget('CraftItemWidget', listPanel)
  widget:setId(tostring(info.id))
  widget.INFO = info
  widget:getChildById('item'):setItemId(info.itemid)
  widget:getChildById('name'):setText(info.name .. (info.qnt > 1 and (' (' .. info.qnt .. 'x)') or ''))
  widget:getChildById('desc'):setText(tr((tostring(info.desc or ''):gsub('%%', '%%%%'))))
  local levelWindow = widget:getChildById('levelWindow')
  levelWindow:setImageSource(workLevel < info.level and '/modules/game_craft/images/interface/levelblock_icon' or
    '/modules/game_craft/images/interface/level_icon')
  levelWindow:setTooltip(workLevel < info.level and tr('Your level is too low (required: %d)', info.level) or
    info.level == 0 and tr('No level required') or tr('Required level: %d', info.level))
  widget:getChildById('clockWindow'):setTooltip(tr('Crafting time per unit: %s', formatTime(info.timeByUnit)))
  for _, recipe in ipairs(info.recipe) do
    local recipeItem = g_ui.createWidget('CraftRecipeItem', widget:getChildById('recipe'))
    recipeItem:setItemId(recipe[1])
    recipeItem:setItemCount(recipe[2])
    recipeItem:setTooltip(recipe[3])
  end
  widget.onClick = selectWidget
  drawProgress(widget)
  startTimer(widget)
  return widget
end

local function setRank(rank, maxBoard)
  currentRank = rank
  for _, child in ipairs(rankPanel:getChildren()) do
    if maxBoard ~= nil then
      child:setEnabled(RANK_ORDER[child:getId()] >= RANK_ORDER[maxBoard])
    end
    child:setOn(child:getId() == rank)
  end
end

local function onCraft(protocol, opcode, buffer)
  local receive = table.fromLiteral(buffer)
  if type(receive) ~= 'table' then return end
  local kind = receive[3]
  if kind == 'work' then
    workName = Protocol_read(receive)
    workLevel = tonumber(Protocol_read(receive)) or 0
    local percent = tonumber(Protocol_read(receive)) or 0
    local openWindow = Protocol_read(receive)
    local image = WORK_IMAGES[string.lower(workName or '')]
    mainWindow:getChildById('workName'):setText(tr('%s Workshop', tr(workName or '')))
    mainWindow:getChildById('workImagem'):setImageSource(image and ('/modules/game_craft/images/works/' .. image) or '')
    mainWindow:getChildById('workNivel'):setText(tr('Lv. %d', workLevel))
    mainWindow:getChildById('expBar'):setPercent(percent)
    mainWindow:getChildById('workpercent'):setText(math.floor(percent) .. '%')
    if openWindow then
      local player = g_game.getLocalPlayer()
      openPosition = player and player:getPosition()
      show()
    end
  elseif kind == 'items' then
    local first = Protocol_read(receive)
    local rank = Protocol_read(receive)
    local maxBoard = Protocol_read(receive)
    local items = Protocol_read(receive)
    if first then
      stopEvents()
      selected = nil
      listPanel:destroyChildren()
      createWindow:hide()
      setRank(rank, maxBoard and rank or nil)
    end
    for _, info in ipairs(items or {}) do
      local widget = addItem(info)
      if not selected then selectWidget(widget) end
    end
  elseif kind == 'refreshItem' then
    local rank = Protocol_read(receive)
    local id = Protocol_read(receive)
    local info = Protocol_read(receive)
    createWindow:hide()
    local widget = rank == currentRank and listPanel:getChildById(tostring(id))
    if widget and type(info) == 'table' then
      widget.INFO.storage_qnt = info.storage_qnt
      widget.INFO.storage_collected = info.storage_collected
      widget.INFO.storage_time = info.storage_time
      drawProgress(widget)
      startTimer(widget)
    end
  end
end

local function send(message)
  local protocol = g_game.getProtocolGame()
  if protocol then protocol:sendExtendedOpcode(OPCODE, message) end
end

function getServerItems(rank)
  send('###RANK###' .. rank)
end

function showCreateWindow()
  if not selected then return end
  local info = selected.INFO
  createWindow:getChildById('item'):setItemId(info.itemid)
  createWindow:getChildById('name'):setText(info.name .. (info.qnt > 1 and (' (' .. info.qnt .. 'x)') or ''))
  local recipePanel = createWindow:getChildById('recipe')
  for slot = 1, 16 do
    local recipe = info.recipe[slot]
    local recipeItem = recipePanel:getChildById(tostring(slot))
    recipeItem:setItemId(recipe and recipe[1] or 0)
    recipeItem:setItemCount(recipe and recipe[2] or 0)
    recipeItem:setTooltip(recipe and recipe[3] or '')
  end
  local scrollBar = createWindow:getChildById('qntScrollBar')
  scrollBar:setValue(1)
  refreshCreateWindow()
  createWindow:show()
  createWindow:raise()
  createWindow:focus()
end

function refreshCreateWindow()
  if not selected then return end
  local info = selected.INFO
  local quantity = createWindow:getChildById('qntScrollBar'):getValue()
  createWindow:getChildById('labelTotal'):setText(tr('Total units: %d', info.qnt * quantity) .. '\n' ..
    tr('Total crafting time: %s', formatTime(quantity * info.timeByUnit)))
  local recipePanel = createWindow:getChildById('recipe')
  for slot, recipe in ipairs(info.recipe) do
    recipePanel:getChildById(tostring(slot)):setItemCount(quantity * recipe[2])
  end
end

function createItem(quantity)
  if not selected or not currentRank then return end
  send('###CRAFT###,RANK' .. currentRank .. ',ID' .. selected.INFO.id .. ',QNT' .. quantity)
end

function doCreateItem()
  createItem(math.max(1, math.min(MAX_QUANTITY, createWindow:getChildById('qntScrollBar'):getValue())))
end

function showSpeedUp()
  if not selected then return end
  local info = selected.INFO
  local dustCost = math.ceil(info.storage_time / (5 * 60))
  speedUpWindow:getChildById('text'):setText(tr('This will cost %d diamond dust. Do you want to speed up crafting %s?',
    dustCost, info.name))
  speedUpWindow:show()
  speedUpWindow:raise()
  speedUpWindow:focus()
end

function speedUpItem()
  if selected and currentRank then
    send(currentRank .. '###SPEEDUP###' .. selected.INFO.id)
  end
  speedUpWindow:hide()
end

function collectItemCraft()
  if selected and currentRank then
    send(currentRank .. '###COLLECT###' .. selected.INFO.id)
  end
end

function selectItem(id)
  local widget = listPanel:getChildById(tostring(id))
  if widget then selectWidget(widget) end
  return widget ~= nil
end

function getState()
  local info = selected and selected.INFO
  return { visible = mainWindow:isVisible(), work = workName, level = workLevel, rank = currentRank,
    items = listPanel:getChildCount(), selected = info and info.id, queued = info and info.storage_qnt or 0,
    collected = info and math.max(0, info.storage_collected) or 0, timeLeft = info and info.storage_time or 0,
    collectable = info and info.collectable or 0, recipe = info and info.recipe, itemid = info and info.itemid }
end

function show()
  mainWindow:show()
  mainWindow:raise()
  mainWindow:focus()
end

function hide()
  mainWindow:hide()
  createWindow:hide()
  speedUpWindow:hide()
end

function toggle()
  if mainWindow:isVisible() then hide() else show() end
end

local function onPositionChange()
  local player = g_game.getLocalPlayer()
  if openPosition and player and mainWindow:isVisible() and not Position.equals(player:getPosition(), openPosition) then
    hide()
  end
end

local function offline()
  stopEvents()
  selected = nil
  listPanel:destroyChildren()
  openPosition = nil
  hide()
end

function init()
  local root = modules.game_interface.getRootPanel()
  mainWindow = g_ui.loadUI('craft', root)
  listPanel = mainWindow:getChildById('craftListPanel')
  rankPanel = mainWindow:getChildById('rankPanel')
  collectButton = mainWindow:getChildById('craftItemCollect')
  speedUpButton = mainWindow:getChildById('speedUpCraft')
  createWindow = g_ui.createWidget('CraftCreateWindow', root)
  local recipePanel = createWindow:getChildById('recipe')
  for slot = 1, 16 do
    g_ui.createWidget('CraftSlot', recipePanel):setId(tostring(slot))
  end
  speedUpWindow = g_ui.createWidget('CraftSpeedUpWindow', root)
  createWindow:hide()
  speedUpWindow:hide()
  connect(g_game, { onGameStart = offline, onGameEnd = offline })
  connect(LocalPlayer, { onPositionChange = onPositionChange })
  ProtocolGame.registerExtendedOpcode(OPCODE, onCraft)
end

function terminate()
  disconnect(g_game, { onGameStart = offline, onGameEnd = offline })
  disconnect(LocalPlayer, { onPositionChange = onPositionChange })
  ProtocolGame.unregisterExtendedOpcode(OPCODE)
  stopEvents()
  mainWindow:destroy()
  createWindow:destroy()
  speedUpWindow:destroy()
end
