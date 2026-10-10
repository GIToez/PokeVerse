-- Scripted client session for the parity tests. Shipped only in test builds
-- (assemble-*-client.sh --test). Runs on both the legacy and the Redemption engine.
--
-- The legacy engine cancels game actions that do not come from an input event (bot
-- protection), so everything after the game login goes through real keyboard and mouse
-- input: the module asks the harness (run-parity.sh) for it with log lines, the harness
-- replays it with xdotool.
--
--   SELFTEST SHOT <name>            take a screenshot
--   SELFTEST KEY <xdotool keys>     press keys, e.g. "ctrl+s" or "Right"
--   SELFTEST CLICK <x> <y> <button> [modifier]
--                                   click at window coordinates (1 left, 3 right),
--                                   optionally holding a key such as ctrl
--   SELFTEST TYPE <text>            type text
--   SELFTEST STEP <name> ok|FAIL <message>
--   SELFTEST DONE <passed> <failed>
--
-- config.lua (written by run-parity.sh) sets SELFTEST = { account, password, character }.
--
-- On the modern Redemption layout (Redemption's own modules) some windows open with other
-- shortcuts or buttons, and the minimap and inventory are part of the main panel instead
-- of windows (their steps only take the screenshot); the session is otherwise the same,
-- so the packets can be compared.

local SHOT_DELAY = 2500
local INPUT_DELAY = 1000
local steps = {}
local passed, failed = 0, 0
local current = 0
local currentDone -- finishes the running step; errors in its callbacks fail it

local function log(text)
  g_logger.info('SELFTEST ' .. text)
end

local function step(name, fn)
  table.insert(steps, { name = name, fn = fn })
end

local function protect(fn)
  return function()
    local ok, err = pcall(fn)
    if not ok and currentDone then currentDone(false, err) end
  end
end

local function after(delay, fn) scheduleEvent(protect(fn), delay) end

local function waitFor(cond, timeout, done)
  local start = g_clock.millis()
  local function poll()
    local ok, result = pcall(cond)
    if ok and result then return done(true) end
    if g_clock.millis() - start > timeout then return done(false) end
    after(100, poll)
  end
  after(0, poll)
end

local function shot(name, done)
  log('SHOT ' .. name)
  after(SHOT_DELAY, done)
end

local function key(keys, done)
  log('KEY ' .. keys)
  after(INPUT_DELAY, done)
end

local function typeText(text, done)
  log('TYPE ' .. text)
  after(INPUT_DELAY + 50 * #text, done)
end

local function clickAt(point, button, done, modifier)
  log(string.format('CLICK %d %d %d %s', point.x, point.y, button, modifier or ''))
  after(INPUT_DELAY, done)
end

local function center(widget)
  local rect = widget:getRect()
  return { x = rect.x + math.floor(rect.width / 2), y = rect.y + math.floor(rect.height / 2) }
end

local function rootChild(id)
  return rootWidget:recursiveGetChildById(id)
end

-- The first widget with this id that is shown (with all its parents). Some ids exist
-- twice, for example a hidden copy of a button in the other layout.
local function findVisible(id, widget)
  for _, child in ipairs((widget or rootWidget):getChildren()) do
    if child:isVisible() then
      if child:getId() == id then return child end
      local found = findVisible(id, child)
      if found then return found end
    end
  end
end

local function visible(id)
  return findVisible(id) ~= nil
end

local function findByText(widget, text)
  for _, child in ipairs(widget:getChildren()) do
    if child:isVisible() then
      if child.getText and child:getText() == text then return child end
      local found = findByText(child, text)
      if found then return found end
    end
  end
end

-- Window point of the centre of the tile at pos on the map widget.
local function tilePoint(map, pos)
  local rect = map:getRect()
  local sx, sy, n = 0, 0, 0
  for y = rect.y, rect.y + rect.height - 1, 4 do
    for x = rect.x, rect.x + rect.width - 1, 4 do
      local p = map:getPosition({ x = x, y = y })
      if p and p.x == pos.x and p.y == pos.y and p.z == pos.z then
        sx, sy, n = sx + x, sy + y, n + 1
      end
    end
  end
  if n == 0 then error('tile not on the map') end
  return { x = math.floor(sx / n), y = math.floor(sy / n) }
end

local function position()
  local player = g_game.getLocalPlayer()
  return player and player:getPosition()
end

local runNext

local function finish(name, ok, message)
  if ok then
    passed = passed + 1
    log('STEP ' .. name .. ' ok')
  else
    failed = failed + 1
    log('STEP ' .. name .. ' FAIL ' .. tostring(message))
  end
  after(500, runNext)
end

runNext = function()
  current = current + 1
  local s = steps[current]
  if not s then
    log('DONE ' .. passed .. ' ' .. failed)
    after(1000, function() g_app.exit() end)
    return
  end
  log('BEGIN ' .. s.name)
  local finished = false
  local function done(result, message)
    if finished then return end
    finished = true
    finish(s.name, result, message)
  end
  currentDone = done
  local ok, err = pcall(s.fn, done)
  if not ok then done(false, err) end
end

local function walkStep(name, keys, dx, dy)
  step('walk ' .. name, function(done)
    local from = position()
    key(keys, function()
      waitFor(function()
        local to = position()
        return to and to.x == from.x + dx and to.y == from.y + dy and not g_game.getLocalPlayer():isWalking()
      end, 3000, function(ok)
        local to = position() or {}
        done(ok, string.format('moved from %d,%d to %s,%s', from.x, from.y, tostring(to.x), tostring(to.y)))
      end)
    end)
  end)
end

-- Opens a window with open(done), waits until shown() is true, takes a screenshot and
-- closes it with close(done).
local function windowStep(name, shown, open, close)
  step('window ' .. name, function(done)
    open(function()
      waitFor(shown, 5000, function(ok)
        if not ok then return done(false, 'not shown') end
        shot('window-' .. name, function()
          close(function()
            waitFor(function() return not shown() end, 3000, function(closed)
              done(closed, 'still shown after closing')
            end)
          end)
        end)
      end)
    end)
  end)
end

-- Mini windows toggled by a key. Some start open, so it presses the key until the
-- window is shown, takes a screenshot and leaves it as it was.
local function keyWindow(name, id, keys)
  step('window ' .. name, function(done)
    local initially = visible(id)
    local function toggle(want, next)
      key(keys, function()
        waitFor(function() return visible(id) == want end, 3000, function(ok)
          if not ok then return done(false, id .. (want and ' not shown' or ' not hidden')) end
          next()
        end)
      end)
    end
    local function showAndShoot(next)
      shot('window-' .. name, next)
    end
    if initially then
      showAndShoot(function() toggle(false, function() toggle(true, function() done(true) end) end) end)
    else
      toggle(true, function() showAndShoot(function() toggle(false, function() done(true) end) end) end)
    end
  end)
end

local function clickButton(id, done)
  local button = findVisible(id)
  if not button then error('no visible widget ' .. id) end
  clickAt(center(button), 1, done)
end

function init()
  local cfg = SELFTEST or {}
  local modern = modules.game_mainpanel ~= nil

  step('login screen', function(done)
    waitFor(function() return visible('accountNameTextEdit') end, 15000, function(ok)
      if not ok then return done(false, 'enter game window not shown') end
      shot('login', function() done(true) end)
    end)
  end)

  step('account login', function(done)
    rootChild('accountNameTextEdit'):setText(cfg.account)
    rootChild('accountPasswordTextEdit'):setText(cfg.password)
    EnterGame.doLogin()
    -- New accounts get the message of the day first; Enter closes it.
    -- only top-level windows: Redemption's top bar has a button with the same text
    local function motd()
      for _, child in ipairs(rootWidget:getChildren()) do
        local title = type(child.title) == 'userdata' and child.title or child
        if child:isVisible() and title:getText() == tr('Message of the day') then return child end
      end
    end
    waitFor(function() return motd() or visible('characters') end, 15000, function(ok)
      if not ok then return done(false, 'character list not shown') end
      local function charlist()
        waitFor(function() return not motd() and visible('characters') end, 5000, function(shown)
          if not shown then return done(false, 'character list not shown') end
          after(500, function() shot('charlist', function() done(true) end) end)
        end)
      end
      if not motd() then return charlist() end
      after(1000, function() shot('motd', function() key('Return', charlist) end) end)
    end)
  end)

  step('game login', function(done)
    local list = findVisible('characters')
    local found = false
    for _, child in ipairs(list:getChildren()) do
      if child.characterName == cfg.character then
        list:focusChild(child, KeyboardFocusReason)
        found = true
      end
    end
    if not found then return done(false, 'character ' .. tostring(cfg.character) .. ' not listed') end
    CharacterList.doLogin()
    waitFor(function() return g_game.isOnline() and position() ~= nil end, 20000, function(ok)
      if not ok then return done(false, 'not online') end
      after(4000, function() shot('game', function() done(true) end) end)
    end)
  end)

  walkStep('east', 'Right', 1, 0)
  walkStep('east again', 'Right', 1, 0)
  walkStep('south', 'Down', 0, 1)
  walkStep('west', 'Left', -1, 0)
  walkStep('north', 'Up', 0, -1)
  step('after walking', function(done) shot('walk', function() done(true) end) end)

  step('say', function(done)
    typeText('selftest', function()
      key('Return', function()
        after(1000, function() shot('talk', function() done(true) end) end)
      end)
    end)
  end)

  local function chatShown() return visible('consoleTextEdit') end
  step('chat off', function(done)
    clickButton('toggleChat', function()
      waitFor(function() return not chatShown() end, 3000, function(ok)
        if not ok then return done(false, 'text box still shown') end
        shot('chat-off', function() done(true) end)
      end)
    end)
  end)
  walkStep('wasd east', 'd', 1, 0)
  walkStep('wasd west', 'a', -1, 0)
  step('temporary chat', function(done)
    key('Return', function()
      waitFor(chatShown, 3000, function(ok)
        if not ok then return done(false, 'Enter did not open the chat') end
        typeText('wasd', function()
          key('Return', function()
            waitFor(function() return not chatShown() end, 3000, function(back)
              if not back then return done(false, 'chat not closed after sending') end
              shot('chat-sent', function() done(true) end)
            end)
          end)
        end)
      end)
    end)
  end)
  step('chat on', function(done)
    clickButton('toggleChat', function()
      waitFor(chatShown, 3000, function(ok) done(ok, 'text box not shown') end)
    end)
  end)

  keyWindow('skills', 'skillWindow', modern and 'alt+s' or 'ctrl+s')
  keyWindow('battle', 'battleWindow', 'ctrl+b')
  keyWindow('viplist', 'vipWindow', 'ctrl+p')
  for _, name in ipairs({ 'minimap', 'inventory' }) do
    if modern then
      step('window ' .. name, function(done) shot('window-' .. name, function() done(true) end) end)
    else
      keyWindow(name, name .. 'Window', name == 'minimap' and 'ctrl+m' or 'ctrl+i')
    end
  end
  keyWindow('hotkeys', 'hotkeysWindow', 'ctrl+k')
  windowStep('options', function() return visible('optionsWindow') end,
    function(done)
      if modern and not findVisible('optionsButton') then
        modules.client_options.show()
        return after(INPUT_DELAY, done)
      end
      clickButton('optionsButton', done)
    end,
    function(done) key('Escape', done) end)
  local function questLogShown()
    if modern then
      local ui = modules.game_questlog.questLogController.ui
      return ui ~= nil and ui:isVisible()
    end
    return visible('questLogWindow')
  end
  windowStep('questlog', questLogShown,
    function(done) clickButton('questLogButton', done) end,
    function(done) key('Escape', done) end)
  local function outfitShown()
    if modern then return findByText(rootWidget, 'Customise Character') ~= nil end
    return modules.game_outfit.outfitWindow ~= nil
  end
  windowStep('outfit', outfitShown,
    function(done)
      local map = modules.game_interface.getMapPanel()
      -- classic controls (the default): Ctrl + right click opens the menu
      clickAt(tilePoint(map, position()), 3, function()
        local option = findByText(rootWidget, tr('Set Outfit'))
        if not option then error('no Set Outfit option in the menu') end
        shot('menu-player', function() clickAt(center(option), 1, done) end)
      end, 'ctrl')
    end,
    function(done) key('Escape', done) end)

  step('logout', function(done)
    key('ctrl+l', function()
      shot('logout-prompt', function()
        key('Return', function()
          waitFor(function() return not g_game.isOnline() end, 15000, function(ok)
            if not ok then return done(false, 'still online') end
            after(2000, function() shot('logout', function() done(true) end) end)
          end)
        end)
      end)
    end)
  end)

  connect(g_app, { onRun = function() after(3000, runNext) end })
end

function terminate()
end
