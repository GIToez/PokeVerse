local OPCODE = 59
local SHOW_MS = 15000

local pokekillWindow
local hideEvents = {}
local lastKill

local function panelFor(windowName)
  if windowName == 'modulo' then
    return 'moduleKill', tr('Hunt the Pokemon')
  elseif windowName == 'npc' then
    return 'npcKill', tr('Hunting mission')
  end
end

local function hidePanel(id)
  removeEvent(hideEvents[id])
  hideEvents[id] = nil
  pokekillWindow:getChildById(id):hide()
  if not pokekillWindow:getChildById('moduleKill'):isVisible() and not pokekillWindow:getChildById('npcKill'):isVisible() then
    pokekillWindow:hide()
  end
end

local function onKill(protocol, opcode, buffer)
  local ok, data = pcall(json.decode, buffer)
  if not ok or type(data) ~= 'table' or type(data.PokeInfo) ~= 'table' then
    g_logger.error('[game_pokekill] invalid message: ' .. tostring(buffer))
    return
  end
  local id, title = panelFor(data.WindowName)
  if not id then return end
  local panel = pokekillWindow:getChildById(id)
  local name = CORRECT_NAME[data.PokeName] or tostring(data.PokeName)
  if POKE_SPRITE[data.PokeName] then
    panel:getChildById('pokeImage'):setOutfit({ type = POKE_SPRITE[data.PokeName] })
  end
  panel:getChildById('taskName'):setText(title)
  panel:getChildById('pokeName'):setText(name .. ' ' .. tostring(data.PokeInfo.KillCount))
  lastKill = { panel = id, name = name, count = tostring(data.PokeInfo.KillCount) }
  panel:show()
  pokekillWindow:show()
  pokekillWindow:raise()
  removeEvent(hideEvents[id])
  hideEvents[id] = scheduleEvent(function() hidePanel(id) end, SHOW_MS)
end

local function onGameEnd()
  hidePanel('moduleKill')
  hidePanel('npcKill')
  lastKill = nil
end

function init()
  pokekillWindow = g_ui.displayUI('pokekill', modules.game_interface.getRootPanel())
  pokekillWindow:hide()
  connect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.registerExtendedOpcode(OPCODE, onKill)
end

function terminate()
  disconnect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.unregisterExtendedOpcode(OPCODE)
  for _, event in pairs(hideEvents) do removeEvent(event) end
  hideEvents = {}
  pokekillWindow:destroy()
end

function getState()
  return {
    visible = pokekillWindow:isVisible(),
    last = lastKill
  }
end
