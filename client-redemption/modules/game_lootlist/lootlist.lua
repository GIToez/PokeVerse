local SHOW_MS = 5000

local lootList
local defaultWidth, defaultHeight = 0, 0
local events = {}
local lastLoot

local function relayout()
  local last
  local width = lootList:getPaddingLeft() + lootList:getPaddingRight()
  for _, icon in ipairs(lootList:getChildren()) do
    icon:breakAnchors()
    if last then
      icon:addAnchor(AnchorLeft, last:getId(), AnchorRight)
    else
      icon:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    end
    width = width + icon:getWidth()
    last = icon
  end
  lootList:resize(lootList:getChildCount() == 0 and defaultWidth or width, defaultHeight)
end

local function addLoot(itemId, count)
  local icon = g_ui.createWidget('LootItem', lootList)
  icon:setItemId(itemId)
  local label = g_ui.createWidget('LootCountLabel', icon)
  label:setText(count)
  label:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
  label:addAnchor(AnchorTop, 'parent', AnchorBottom)
  relayout()
  g_effects.fadeOut(icon, SHOW_MS)
  local event
  event = scheduleEvent(function()
    events[event] = nil
    if not icon:isDestroyed() then
      icon:destroy()
      relayout()
    end
  end, SHOW_MS + 10)
  events[event] = true
end

local function reset()
  for event in pairs(events) do removeEvent(event) end
  events = {}
  lootList:destroyChildren()
  relayout()
end

local function onLootList(list)
  lastLoot = {}
  for itemId, count in pairs(list) do
    addLoot(itemId, count)
    lastLoot[itemId] = count
  end
end

local function onGameStart()
  reset()
  lootList:show()
end

local function onGameEnd()
  lootList:hide()
  reset()
  lastLoot = nil
end

function init()
  lootList = g_ui.loadUI('lootlist', modules.game_interface.getRootPanel())
  defaultWidth, defaultHeight = lootList:getWidth(), lootList:getHeight()
  connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd, onLootList = onLootList })
  if g_game.isOnline() then
    onGameStart()
  else
    lootList:hide()
  end
end

function terminate()
  disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd, onLootList = onLootList })
  reset()
  lootList:destroy()
end

function getState()
  return { visible = lootList:isVisible(), icons = lootList:getChildCount(), last = lastLoot }
end
