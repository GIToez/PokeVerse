return function(t)
  -- staff commands and their replies stay out of the footage
  local STAFF = { '^/', 'until cleared', 'game clock is now', ' zones', 'Reload', '%[Reports%]', 'gauge is full',
    'flew away', 'Usage:', 'back to the rolled', 'Halloween:', 'itch:', 'Legendary:', 'teleported', 'Weather', 'Halloween raid' }
  local function isStaff(text)
    text = tostring(text or '')
    for _, p in ipairs(STAFF) do
      if text:find(p) then return true end
    end
    return false
  end
  local console = modules.game_console
  if console and console.addTabText and not console.__itchWrapped then
    local raw = console.addTabText
    console.addTabText = function(text, ...) if not isStaff(text) then return raw(text, ...) end end
    console.__itchWrapped = true
  end
  local tm = modules.game_textmessage
  if tm and tm.displayMessage and not tm.__itchWrapped then
    local raw = tm.displayMessage
    tm.displayMessage = function(mode, text, ...) if not isStaff(text) then return raw(mode, text, ...) end end
    tm.__itchWrapped = true
  end
  connect(g_game, { onTextMessage = function(mode, text) t.mark('MSG ' .. tostring(text):sub(1, 160)) end })

  local H = { steps = {} }
  local steps = H.steps
  function H.add(delay, fn) steps[#steps + 1] = { delay, fn or function() end } end
  local add = H.add
  function H.wait(ms) add(ms) end
  function H.rec(name) add(600, function() t.clearPopups() t.clearChat() t.mark('REC ' .. name) end) end
  function H.stop() add(800, function() t.mark('STOP') end) end
  function H.shot(name) add(400, function() t.mark('SHOT ' .. name) end) end
  function H.say(text, delay) add(delay or 400, function() t.say(text) end) end
  function H.call(name, delay)
    add(1200, function() t.say('/itch back') t.say('/itch balls') end)
    add(delay or 2200, function() t.mark('call ' .. name .. '=' .. tostring(t.callPokemon(name))) end)
  end
  function H.go(pos, delay) add(delay or 3000, function() t.say('/goto ' .. pos) end) end
  function H.pos() local p = g_game.getLocalPlayer():getPosition() return p.x .. ',' .. p.y .. ',' .. p.z end
  function H.where(tag) add(100, function() t.mark('POS ' .. (tag or '') .. ' ' .. H.pos()) end) end
  -- one autoWalk to an offset; the camera follows
  function H.walk(dx, dy, delay)
    add(delay or 100, function()
      local p = g_game.getLocalPlayer():getPosition()
      local ok = g_game.getLocalPlayer():autoWalk({ x = p.x + dx, y = p.y + dy, z = p.z })
      t.mark('walk ' .. dx .. ',' .. dy .. '=' .. tostring(ok))
    end)
  end
  -- steps in one direction for ms milliseconds (flying and surfing make their tiles as they go)
  local DIRS = { n = North, s = South, e = East, w = West, ne = NorthEast, nw = NorthWest, se = SouthEast, sw = SouthWest }
  function H.steer(dir, ms)
    add(50, function()
      local deadline = g_clock.millis() + ms
      local function tick()
        if g_clock.millis() >= deadline then return end
        local player = g_game.getLocalPlayer()
        if not player:isWalking() then g_game.walk(DIRS[dir]) end
        scheduleEvent(tick, 40)
      end
      tick()
    end)
    add(ms)
  end
  function H.attackNearest(delay)
    add(delay or 300, function()
      local wild = t.nearestWild()
      t.mark('wild=' .. tostring(wild and wild:getName()))
      if wild then g_game.attack(wild) end
    end)
  end
  function H.attackName(name, delay)
    add(delay or 300, function()
      local player = g_game.getLocalPlayer()
      for _, c in ipairs(g_map.getSpectators(player:getPosition(), false)) do
        if c:isMonster() and not c:isLocalPlayerSummon() and c:getName():find(name) then g_game.attack(c) t.mark('attack ' .. c:getName()) return end
      end
      t.mark('attack none ' .. name)
    end)
  end
  function H.move(m, delay) add(delay or 900, function() t.say('/itch energy') t.say(m) end) end
  function H.moves(list, delay) for _, m in ipairs(list) do H.move(m, delay) end end
  -- the Order item (head slot) used on the tile at an offset: on your own tile it rides or flies,
  -- on a water edge it surfs
  function H.order(dx, dy, delay)
    add(delay or 300, function()
      local player = g_game.getLocalPlayer()
      local item = player:getInventoryItem(InventorySlotHead)
      local p = player:getPosition()
      local tile = g_map.getTile({ x = p.x + (dx or 0), y = p.y + (dy or 0), z = p.z })
      local thing = (dx or 0) == 0 and (dy or 0) == 0 and player or (tile and tile:getTopUseThing())
      t.mark('order ' .. tostring(dx) .. ',' .. tostring(dy) .. ' item=' .. tostring(item and item:getId()) .. ' thing=' .. tostring(thing ~= nil))
      if item and thing then g_game.useWith(item, thing) end
    end)
  end
  function H.stopFight(delay) add(delay or 300, function() g_game.cancelAttack() end) end
  -- talk to an NPC on the Default channel the way a trainer does
  function H.npc(words, delay)
    for i, w in ipairs(words) do
      local mode = i == 1 and MessageModes.Say or MessageModes.NpcTo
      add(delay or 1500, function() g_game.talkChannel(mode, 0, w) end)
    end
  end
  function H.npcClose(delay) add(delay or 300, function() pcall(function() modules.game_npcdialog.close() end) end) end
  function H.zoom(n, delay)
    add(delay or 200, function()
      local m = modules.game_interface.getMapPanel()
      for _ = 1, math.abs(n) do if n > 0 then m:zoomIn() else m:zoomOut() end end
    end)
  end
  -- fly across a region: take off, climb above every roof and cliff, then steer
  function H.flyover(name, pos, legend, legs)
    H.go(pos)
    H.say('/itch fly on', 1500)
    H.wait(2500)
    H.say('/up 5', 300)
    H.wait(1200)
    H.rec(name)
    if legend then H.say('/legendary flyover ' .. legend, 200) end
    for _, leg in ipairs(legs) do H.steer(leg[1], leg[2]) end
    H.stop()
    H.say('/down 5', 300)
    H.say('/itch fly off', 1500)
    H.wait(1500)
  end
  function H.lights(on, delay) add(delay or 100, function() modules.game_interface.getMapPanel():setDrawLights(on) end) end
  function H.closeAll()
    add(400, function()
      pcall(function() modules.game_pokepedia.hide() end)
      pcall(function() modules.game_quests.hide() end)
      pcall(function() modules.game_trainercard.close() end)
      pcall(function() modules.game_vocation.close() end)
    end)
  end
  function H.setup()
    add(2500, function() t.clearPopups() t.say('/reload talkactions') end)
    add(2500, function()
      t.say('/itch look') t.say('/itch team') t.say('/itch ring') t.say('/itch long') t.say('/itch balls')
      t.say('/weather all clear') t.say('/weather time day') t.say('/legendary mode manual')
      pcall(function() modules.client_options.setOption('showHints', false) end)
      pcall(function() modules.game_interface.getMapPanel():setShadowFloorIntensity(0) end)
    end)
    add(2500, function() pcall(function() modules.game_vocation.close() end) t.mark('slots: ' .. t.pokebarSlots()) end)
    add(100, function()
      for _, id in ipairs({ 'playtutorial', 'image' }) do
        local w = modules.game_interface.getRootPanel():getChildById(id)
        if w then w:setOpacity(0) end
      end
    end)
  end

  dofile('/scene.lua')(t, H)
  return steps
end
