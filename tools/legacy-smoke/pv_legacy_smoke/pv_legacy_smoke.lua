-- PokeVerse legacy client login smoke. TEST ONLY: tools/smoke_legacy_login.sh copies this module
-- into the client's user directory for one run and removes it afterwards; packages never contain it.
-- It logs in through the login and character list windows' own functions (the same code their
-- buttons run), records what the client shows in the game, and closes the client. Nothing here performs a
-- game action: the production build keeps bot protection on.
-- Environment: PV_ACCOUNT, PV_PASSWORD, PV_CHARACTER (default player/player/Trainer),
-- PV_IN_GAME_MS (time in the game before closing the client, default 15000), PV_WINDOW_SIZE.

local account = os.getenv('PV_ACCOUNT') or 'player'
local password = os.getenv('PV_PASSWORD') or 'player'
local character = os.getenv('PV_CHARACTER') or 'Trainer'
local inGameMs = tonumber(os.getenv('PV_IN_GAME_MS') or '') or 15000
local events = {}
local started = g_clock.millis()
local texts, talks = 0, 0

-- The feature each comparison row is about and the module that provides it in this client
-- (tools/redemption_smoke_rc.lua has the same keys with the Redemption module names).
local FEATURES = {
  { 'login', 'client_entergame' }, { 'map', 'game_interface' }, { 'minimap', 'game_minimap' },
  { 'pokebar', 'game_pokebar' }, { 'moves', 'game_pokemoves' }, { 'inventory', 'game_inventory' },
  { 'containers', 'game_containers' }, { 'pokedex', 'game_pokedex' }, { 'pokemon_info', 'game_pokemonInfo' },
  { 'npc_trade', 'game_npctrade' }, { 'shop', 'game_shop' }, { 'market', 'game_market' },
  { 'chat', 'game_chat' }, { 'battle_list', 'game_battle' }, { 'hotkeys', 'game_hotkeys' },
  { 'outfit', 'game_outfit' }, { 'questlog', 'game_questlog' }, { 'task', 'game_task' },
  { 'battle_pass', 'game_pass' }, { 'craft', 'game_craft' }, { 'tm_choose', 'game_tmchoose' },
  { 'statusbar', 'game_statusbar' }, { 'pokekill', 'game_pokekill' }, { 'effects', 'game_effects' },
}

local function log(fmt, ...)
  g_logger.info('[pv-smoke] ' .. string.format(fmt, ...))
end

local function later(ms, fn)
  table.insert(events, scheduleEvent(fn, ms))
end

-- PV_WINDOW_SIZE=WIDTHxHEIGHT gives both clients the same window for comparison screenshots.
local function applyWindowSize()
  local w, h = (os.getenv('PV_WINDOW_SIZE') or ''):match('^(%d+)x(%d+)$')
  if w then
    g_window.resize({ width = tonumber(w), height = tonumber(h) })
    g_window.move({ x = 0, y = 0 })
  end
end

local function finish(code)
  log('EXIT %d', code)
  later(500, function() g_app.exit() end)
end

local function find(id)
  return rootWidget:recursiveGetChildById(id)
end

local function visibleWindows()
  local ids = {}
  local roots = { rootWidget }
  if modules.game_interface and modules.game_interface.getRootPanel then
    table.insert(roots, modules.game_interface.getRootPanel())
  end
  for _, root in ipairs(roots) do
    for _, child in ipairs(root:getChildren()) do
      if child:isVisible() and child:getId() then table.insert(ids, child:getId()) end
    end
  end
  table.sort(ids)
  return table.concat(ids, ',')
end

local function selectCharacter(attempt)
  local list = find('characters')
  if not (list and CharacterList.isVisible()) then
    if attempt > 60 then log('FAIL no character list') return finish(1) end
    return later(500, function() selectCharacter(attempt + 1) end)
  end
  local names, chosen = {}, nil
  for _, widget in ipairs(list:getChildren()) do
    table.insert(names, tostring(widget.characterName))
    if widget.characterName == character then chosen = widget end
  end
  log('CHARLIST count=%d names=%s', #names, table.concat(names, ','))
  if not chosen then log('FAIL character %s not in the list', character) return finish(1) end
  log('CHARACTER name=%s', character)
  list:focusChild(chosen, KeyboardFocusReason)
  CharacterList.doLogin()
end

local function login(attempt)
  local accountEdit, passwordEdit = find('accountNameTextEdit'), find('accountPasswordTextEdit')
  -- The 854 SPR/DAT load when EnterGame.doLogin sets the client version.
  if not (accountEdit and passwordEdit and accountEdit:isVisible()) then
    if attempt > 120 then log('FAIL login window did not appear') return finish(1) end
    return later(500, function() login(attempt + 1) end)
  end
  log('LOGIN SCREEN ms=%d', g_clock.millis() - started)
  accountEdit:setText(account)
  passwordEdit:setText(password)
  EnterGame.doLogin()
  later(500, function() selectCharacter(0) end)
end

local function report()
  local player = g_game.getLocalPlayer()
  local pos = player and player:getPosition()
  local spectators = pos and #g_map.getSpectators(pos, false) or 0
  local tile = pos and g_map.getTile(pos)
  log('MAP pos=%s,%s,%s tile=%s creatures=%d', pos and pos.x or '?', pos and pos.y or '?', pos and pos.z or '?',
      tostring(tile ~= nil), spectators)
  local bar = modules.game_pokebar and modules.game_pokebar.pokemonBar
  log('MODULE game_pokebar loaded=%s visible=%s', tostring(modules.game_pokebar ~= nil),
      tostring(bar ~= nil and bar:isVisible()))
  for slot = 1, 10 do
    local item = player and player:getInventoryItem(slot)
    if item then log('INVENTORY slot=%d id=%d count=%d', slot, item:getId(), item:getCount()) end
  end
  for _, creature in ipairs(pos and g_map.getSpectators(pos, false) or {}) do
    log('LOOK name=%s lookType=%d', creature:getName(), creature:getOutfit().type or 0)
  end
  local features = {}
  for _, f in ipairs(FEATURES) do
    local module = g_modules.getModule(f[2])
    table.insert(features, string.format('%s=%s:%s', f[1], f[2], tostring(module ~= nil and module:isLoaded())))
  end
  log('FEATURES %s', table.concat(features, ' '))
  log('CHAT received texts=%d talks=%d', texts, talks)
  log('AUDIO engine=%s', g_sounds and 'OpenAL' or 'none')
  log('WINDOWS %s', visibleWindows())
  log('FPS foreground=%d background=%d', g_app.getForegroundPaneFps(), g_app.getBackgroundPaneFps())
  log('SCREENSHOT')
end

local function onGameStart()
  log('GAME START ms=%d', g_clock.millis() - started)
  later(5000, report)
  -- g_game.safeLogout is bot protected in this fork; closing the client logs out from C++, the
  -- same as a player closing the window.
  later(inGameMs, function()
    log('LOGOUT by closing the client')
    finish(0)
  end)
end

local function onGameEnd()
  log('GAME END')
end

local function onTextMessage() texts = texts + 1 end
local function onTalk() talks = talks + 1 end

function init()
  connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd, onTextMessage = onTextMessage, onTalk = onTalk })
  log('LOADED account=%s character=%s', account, character)
  applyWindowSize()
  later(1000, function() login(0) end)
  later(tonumber(os.getenv('PV_TIMEOUT_MS') or '') or 180000, function()
    log('FAIL timeout')
    finish(1)
  end)
end

function terminate()
  disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd, onTextMessage = onTextMessage, onTalk = onTalk })
  for _, event in ipairs(events) do removeEvent(event) end
end
