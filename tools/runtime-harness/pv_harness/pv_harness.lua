-- PokeVerse runtime test driver. DEVELOPMENT ONLY.
-- Installed into the client's user directory by tools/runtime_test.sh and active only
-- when PV_HARNESS=1. After the character enters the game it drives each system the
-- way its UI button does, and logs ([PVH] lines) every extended-opcode payload,
-- client handler error, server text message and window that opened.

-- Server item ids (for /i). The client only sees client ids (CLIENT_ID, from items.otb).
local ITEM = {
  BALL_CHARGED = 12159, BALL_EMPTY = 12157, POKEDEX = 12281, MARKET_PC = 32137,
  DRAGON_FANG = 23516, ZINC = 23457, APPLE = 35547, MONEY_10K = 35573, EV_RESET = 35552,
}
local CLIENT_ID = {
  [12159] = 11120, [12157] = 11118, [12281] = 11242, [32137] = 31132,
  [23516] = 22173, [23457] = 22114, [35547] = 34542, [35573] = 34568, [35552] = 34547,
}
local OP = { DUNGEON = 41, PASS = 61, CALENDAR = 62, POKEMON_INFO = 63, MARKET = 64, CRAFT = 103 }
local SLOT_FEET = 8

local steps, stepIndex = {}, 0
local originalOnExtendedOpcode, originalSend
local stepFile = "harness_step.txt"

local function log(fmt, ...)
  g_logger.info("[PVH] " .. string.format(fmt, ...))
end

local function marker(text)
  local dir = g_resources.getWriteDir()
  if dir:sub(-1) ~= "/" then dir = dir .. "/" end
  local f = io.open(dir .. stepFile, "w")
  if f then f:write(text) f:close() end
end

local function short(s, n)
  s = tostring(s):gsub("[\r\n]", " ")
  n = n or 600
  return #s > n and (s:sub(1, n) .. "...(" .. #s .. " bytes)") or s
end

local function visibleWindows()
  local seen = {}
  local roots = { rootWidget }
  if modules.game_interface and modules.game_interface.getRootPanel then
    table.insert(roots, modules.game_interface.getRootPanel())
  end
  for _, root in ipairs(roots) do
    for _, child in ipairs(root:getChildren()) do
      if child:isVisible() and child:getId() then seen[child:getId()] = true end
    end
  end
  return seen
end

local function player() return g_game.getLocalPlayer() end

local function findItem(serverId)
  local id = CLIENT_ID[serverId] or serverId
  local p = player()
  for slot = 1, 10 do
    local it = p:getInventoryItem(slot)
    if it and it:getId() == id then return it end
  end
  for _, container in pairs(g_game.getContainers()) do
    for _, it in ipairs(container:getItems()) do
      if it:getId() == id then return it end
    end
  end
end

local function countItem(serverId)
  local id = CLIENT_ID[serverId] or serverId
  local n = 0
  for _, container in pairs(g_game.getContainers()) do
    for _, it in ipairs(container:getItems()) do
      if it:getId() == id then n = n + it:getCount() end
    end
  end
  return n
end

local function openBackpacks()
  local p = player()
  for slot = 1, 10 do
    local it = p:getInventoryItem(slot)
    if it and it:isContainer() then g_game.open(it) end
  end
end

local function feetBall() return player():getInventoryItem(SLOT_FEET) end

local function sendOp(op, payload) g_game.getProtocolGame():sendExtendedOpcode(op, payload) end

local function spectators()
  local list = {}
  for _, c in ipairs(g_map.getSpectators(player():getPosition(), false)) do
    if c ~= player() then table.insert(list, c) end
  end
  return list
end

local function creatureNamed(name)
  for _, c in ipairs(spectators()) do
    if c:getName():lower():find(name:lower(), 1, true) then return c end
  end
end

-- `wait` is the maximum time in ms; with `doneFn` the step ends as soon as it returns true.
local function step(name, wait, fn, doneFn)
  table.insert(steps, { name = name, wait = wait, fn = fn, doneFn = doneFn })
end

local function runNext()
  stepIndex = stepIndex + 1
  local s = steps[stepIndex]
  if not s then
    log("DONE")
    marker("DONE")
    g_game.safeLogout()
    scheduleEvent(function() g_app.exit() end, 3000)
    return
  end
  local before = visibleWindows()
  log("STEP %d %s", stepIndex, s.name)
  marker(string.format("%02d-%s", stepIndex, s.name))
  local ok, err = pcall(s.fn)
  if not ok then log("STEP-ERROR %s: %s", s.name, tostring(err)) end
  local function finish()
    local opened = {}
    for id in pairs(visibleWindows()) do
      if not before[id] then table.insert(opened, id) end
    end
    log("STEP-END %s opened=[%s]", s.name, table.concat(opened, ","))
    marker(string.format("%02d-%s-end", stepIndex, s.name))
    scheduleEvent(runNext, 1500)
  end
  if not s.doneFn then
    scheduleEvent(finish, s.wait)
    return
  end
  local waited = 0
  local function poll()
    local okDone, done = pcall(s.doneFn)
    if (okDone and done) or waited >= s.wait then return finish() end
    waited = waited + 1000
    scheduleEvent(poll, 1000)
  end
  scheduleEvent(poll, 1000)
end

-- Steps -----------------------------------------------------------------------------

step("setup", 4000, function()
  openBackpacks()
  -- /cb looks the name up case-sensitively in POKEMONS after a case-insensitive check.
  -- Level 15: the level 8 GM may call Pokemon up to MAX_LEVEL_DIFF_BETWEEN_PLAYER_POKEMON above.
  g_game.talk("/cb Charmander,15,10")
end)

step("summon", 5000, function()
  local ball = feetBall()
  if not ball then
    ball = findItem(ITEM.BALL_CHARGED)
    if not ball then error("no charged ball found") end
    g_game.move(ball, { x = 65535, y = SLOT_FEET, z = 0 }, 1)
  end
  scheduleEvent(function()
    local b = feetBall()
    log("feet slot item=%s", b and b:getId() or "none")
    if b then g_game.use(b) end
  end, 1500)
end)

step("summon-check", 2000, function()
  local names = {}
  for _, c in ipairs(spectators()) do table.insert(names, c:getName()) end
  log("spectators: %s", table.concat(names, ", "))
end)

step("pokemon-info", 4000, function()
  g_game.talk("/pokeivev")
  modules.game_pokemonInfo.show()
end)

step("ball-look-before", 3000, function() g_game.look(feetBall()) end)

step("ev-spend", 4000, function()
  sendOp(OP.POKEMON_INFO, json.encode({ protocol = "upgrade", patternId = "ivev",
    tab = { { id = "hp", value = 10 }, { id = "spdef", value = 5 } } }))
end)

step("ball-look-after-ev-spend", 3000, function() g_game.look(feetBall()) end)

step("ev-reset", 5000, function()
  g_game.talk("/i " .. ITEM.EV_RESET .. ",1")
  scheduleEvent(function()
    sendOp(OP.POKEMON_INFO, json.encode({ protocol = "reset", type = "ivev" }))
  end, 1500)
end)

step("friendship-feed", 4000, function()
  g_game.talk("/i " .. ITEM.APPLE .. ",2")
  scheduleEvent(function()
    sendOp(OP.POKEMON_INFO, json.encode({ protocol = "friendship", type = "exp", id = "apple" }))
  end, 1500)
end)

step("friendship-level-nomoney", 3000, function()
  log("money items before=%d", countItem(ITEM.MONEY_10K))
  sendOp(OP.POKEMON_INFO, json.encode({ protocol = "friendship", type = "level", useDiamonds = false }))
end)

step("friendship-level-money", 6000, function()
  g_game.talk("/i " .. ITEM.MONEY_10K .. ",5")
  scheduleEvent(function()
    log("money items before=%d", countItem(ITEM.MONEY_10K))
    sendOp(OP.POKEMON_INFO, json.encode({ protocol = "friendship", type = "level", useDiamonds = false }))
    scheduleEvent(function() log("money items after=%d", countItem(ITEM.MONEY_10K)) end, 2000)
  end, 1500)
end)

-- Held items and vitamins are refused while the Pokemon is out of its ball.
step("recall", 3000, function() g_game.use(feetBall()) end)

step("held-dragon-fang", 5000, function()
  g_game.talk("/i " .. ITEM.DRAGON_FANG .. ",1")
  scheduleEvent(function()
    local fang = findItem(ITEM.DRAGON_FANG)
    if not fang then log("dragon fang not found") return end
    g_game.useWith(fang, feetBall())
  end, 1500)
end)

step("vitamin-zinc", 5000, function()
  g_game.talk("/i " .. ITEM.ZINC .. ",1")
  scheduleEvent(function()
    local zinc = findItem(ITEM.ZINC)
    if not zinc then log("zinc not found") return end
    g_game.useWith(zinc, feetBall())
  end, 1500)
end)

step("ball-look-after", 3000, function() g_game.look(feetBall()) end)

step("resummon", 4000, function() g_game.use(feetBall()) end)

step("pokemon-info-after", 4000, function() g_game.talk("/pokeivev") end)

step("pokedex-on-own-pokemon", 4000, function()
  local dex = findItem(ITEM.POKEDEX)
  local mon = creatureNamed("charmander")
  log("pokedex=%s target=%s", tostring(dex and dex:getId()), tostring(mon and mon:getName()))
  if dex and mon then g_game.useWith(dex, mon) end
end)

local function closeWindows()
  for _, m in ipairs({ "game_pass", "game_calendar", "game_dungeon", "game_craft", "game_shop", "game_market", "game_pokemonInfo" }) do
    if modules[m] and modules[m].hide then pcall(modules[m].hide) end
  end
end

step("catch-summon-wild", 4000, function()
  closeWindows()
  g_game.talk("/m rattata")
end)

local wildPos
local attackPolls = 0
step("catch-attack", 150000, function()
  local wild = creatureNamed("rattata")
  log("wild=%s", tostring(wild and wild:getName()))
  if wild then g_game.attack(wild) end
end, function()
  local wild = creatureNamed("rattata")
  if wild then
    wildPos = wild:getPosition()
    attackPolls = attackPolls + 1
    if not g_game.isAttacking() then g_game.attack(wild) end
    if attackPolls % 10 == 0 then
      log("wild hp=%d%% at %s attacking=%s", wild:getHealthPercent(), postostring(wildPos), tostring(g_game.isAttacking()))
    end
  end
  return wild == nil
end)

step("catch-throw", 8000, function()
  log("wild dead=%s at %s", tostring(creatureNamed("rattata") == nil), wildPos and postostring(wildPos) or "?")
  g_game.talk("/i " .. ITEM.BALL_EMPTY .. ",3")
  scheduleEvent(function()
    local ballItem = findItem(ITEM.BALL_EMPTY)
    local tile = wildPos and g_map.getTile(wildPos)
    local corpse = tile and tile:getTopUseThing()
    log("empty ball=%s corpse=%s", tostring(ballItem and ballItem:getId()), tostring(corpse and corpse:getId()))
    if ballItem and corpse then g_game.useWith(ballItem, corpse) end
  end, 1500)
end)

step("battle-pass", 4000, function()
  g_game.talk("/passopen")
  modules.game_pass.toggle()
end)

step("calendar", 4000, function()
  g_game.talk("/dailysigninopen")
  modules.game_calendar.toggle()
end)

step("dungeon", 4000, function() modules.game_dungeon.toggle() end)

step("craft", 4000, function()
  modules.game_craft.toggle()
  modules.game_craft.getServerItems("E")
end)

step("task", 4000, function() modules.game_task.toggle() end)

step("shop", 4000, function() g_game.talk("/ShopOpen") end)

step("market", 6000, function()
  -- The PC is not pickupable: create it on the tile in front of the character.
  g_game.talk("/i " .. ITEM.MARKET_PC .. ",1,true,true")
  scheduleEvent(function()
    local pos = player():getPosition()
    local d = player():getDirection()
    local front = { x = pos.x + (d == East and 1 or d == West and -1 or 0),
                    y = pos.y + (d == South and 1 or d == North and -1 or 0), z = pos.z }
    local tile = g_map.getTile(front)
    local top = tile and tile:getTopUseThing()
    log("market pc on ground=%s", tostring(top and top:getId()))
    if top then g_game.use(top) end
  end, 1500)
end)

step("close-windows", 2000, closeWindows)

-- Hooks ------------------------------------------------------------------------------

local function onTextMessage(mode, text) log("TEXT mode=%s %s", tostring(mode), short(text, 400)) end

local function onGameStart()
  stepIndex = 0
  scheduleEvent(runNext, 4000)
end

function init()
  if os.getenv("PV_HARNESS") ~= "1" then return end
  log("harness loaded")
  originalOnExtendedOpcode = ProtocolGame.onExtendedOpcode
  ProtocolGame.onExtendedOpcode = function(self, opcode, buffer)
    log("RECV op=%d %s", opcode, short(buffer))
    local ok, err = pcall(originalOnExtendedOpcode, self, opcode, buffer)
    if not ok then log("HANDLER-ERROR op=%d %s", opcode, tostring(err)) end
  end
  originalSend = ProtocolGame.sendExtendedOpcode
  ProtocolGame.sendExtendedOpcode = function(self, opcode, buffer, ...)
    log("SEND op=%d %s", opcode, short(buffer, 200))
    return originalSend(self, opcode, buffer, ...)
  end
  connect(g_game, { onGameStart = onGameStart, onTextMessage = onTextMessage })
  if g_game.isOnline() then onGameStart() end
end

function terminate()
  if originalOnExtendedOpcode then
    ProtocolGame.onExtendedOpcode = originalOnExtendedOpcode
    ProtocolGame.sendExtendedOpcode = originalSend
    disconnect(g_game, { onGameStart = onGameStart, onTextMessage = onTextMessage })
  end
end
