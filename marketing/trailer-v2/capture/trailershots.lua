local function child(id) return rootWidget:recursiveGetChildById(id) end
local function mark(text) g_logger.info('ITCH ' .. text) end
local function say(text) g_game.talkChannel(MessageModes.Say, 0, text) end

local function clearPopups()
  if modules.client_locales and modules.client_locales.selectFirstLocale then
    pcall(modules.client_locales.selectFirstLocale, 'en')
  end
  for _, c in ipairs(rootWidget:getChildren()) do
    if c:isVisible() and c:getId() ~= 'gameRootPanel' and c.recursiveGetChildById and (c:recursiveGetChildById('copyReport') or c:recursiveGetChildById('claim')) then
      c:hide()
    end
  end
  local daily = modules.game_dailylogin
  if daily and daily.hide then pcall(daily.hide) end
end

local function clearChat()
  local console = modules.game_console
  local bar = console and console.consoleTabBar
  if not bar then return end
  for _, tab in ipairs(bar.tabs or {}) do
    local buffer = tab.tabPanel and tab.tabPanel:getChildById('consoleBuffer')
    if buffer then buffer:destroyChildren() end
  end
end

local clearChatRaw = clearChat
clearChat = function() pcall(clearChatRaw) end

local function pokebarSlots()
  local bar = modules.game_pokebar.pokemonBar
  local out = {}
  for _, slot in ipairs(bar and bar:getChildren() or {}) do
    if slot.number then out[#out + 1] = slot.number .. '=' .. tostring(slot.baseTooltip):match('^[^\n]*') end
  end
  return table.concat(out, ', ')
end

local function callPokemon(name)
  local bar = modules.game_pokebar.pokemonBar
  for _, slot in ipairs(bar and bar:getChildren() or {}) do
    if slot.number and tostring(slot.baseTooltip):match('^' .. name) then
      say('/cp ' .. slot.number)
      return true
    end
  end
  return false
end

local function recall()
  local player = g_game.getLocalPlayer()
  for _, c in ipairs(g_map.getSpectators(player:getPosition(), false)) do
    if c:isLocalPlayerSummon() then
      local ball = player:getInventoryItem(InventorySlotFeet)
      if ball then g_game.use(ball) end
      return true
    end
  end
  return false
end

local function nearestWild()
  local player = g_game.getLocalPlayer()
  local best, bestD
  for _, c in ipairs(g_map.getSpectators(player:getPosition(), false)) do
    if c:isMonster() and not c:isLocalPlayerSummon() and not c:getName():find('%[100%]') then
      local a, b = player:getPosition(), c:getPosition()
      local d = math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
      if not bestD or d < bestD then best, bestD = c, d end
    end
  end
  return best
end

local steps = dofile('/trailerscenes.lua')({ child = child, mark = mark, say = say, clearPopups = clearPopups, clearChat = clearChat,
  pokebarSlots = pokebarSlots, callPokemon = callPokemon, recall = recall, nearestWild = nearestWild })

local function run(i)
  local step = steps[i]
  if not step then mark('DONE') scheduleEvent(function() g_app.exit() end, 1500) return end
  local ok, err = pcall(step[2])
  if not ok then mark('ERR step ' .. i .. ': ' .. tostring(err)) end
  scheduleEvent(function() run(i + 1) end, step[1])
end

local itchSize = g_window.getDisplaySize()
g_window.resize({ width = itchSize.width, height = itchSize.height })
g_window.move({ x = 0, y = 0 })
child('accountNameTextEdit'):setText('admin')
child('accountPasswordTextEdit'):setText('admin')
EnterGame.doLogin()
local function tryChar(n)
  if g_game.isOnline() then
    scheduleEvent(function() run(1) end, 3000)
    return
  end
  local list = child('characters')
  if list and list:isVisible() then
    for _, c in ipairs(list:getChildren()) do
      if c.characterName == 'Red' then list:focusChild(c, KeyboardFocusReason) end
    end
    CharacterList.doLogin()
  end
  for _, c in ipairs(rootWidget:getChildren()) do
    local t = type(c.title) == 'userdata' and c.title or c
    if c:isVisible() and t.getText and t:getText() == tr('Message of the day') then c:destroy() end
  end
  if n > 0 then scheduleEvent(function() tryChar(n - 1) end, 1000) end
end
scheduleEvent(function() tryChar(40) end, 1500)
