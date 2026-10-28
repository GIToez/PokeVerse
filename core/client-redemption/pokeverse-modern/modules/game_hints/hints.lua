-- First-visit hints: a card with what a place is for, the first time the trainer walks into it. Most
-- places are noticed by their area name (game_environment); the server shows the rest (072-daycare.lua
-- shows the Day Care hint when its window first opens). The server (082-hints.lua) remembers which
-- hints each character has seen, so a hint shows once per character, on any computer.
--
-- ExtendedIds.Hints JSON:
--   client -> server  {action = "hello"} (at login), {action = "seen", key}, {action = "reset"}
--   server -> client  {type = "seen", seen = {key, ...}}, {type = "show", key}
--
-- The Settings switch "Show first-visit hints" (showHints) and the card's "Don't show hints" button turn
-- them off; the Wiki tab of the Pokepedia shows every hint again.

-- Keys and their order match Hints.KEYS on the server. Keep texts ASCII.
HINTS = {
    { key = 'center', title = 'Pokemon Center', portrait = 113,
      areas = { 'Pokemon Center' },
      lines = {
          "Say hi to Nurse Joy to heal you and your Pokemon for free.",
          "Use a locker to open your PC: Poke boxes, stash, inbox and depot.",
          "The computers open the GTS, where trainers buy and sell Pokemon and items.",
          "The teleporter takes you to the Union Room.",
      } },
    { key = 'mart', title = 'Poke Mart', portrait = 52,
      areas = { 'Pokemon Mart', 'Pokemon Market' },
      lines = {
          "Say hi to the clerk to buy Poke Balls, Potions, Revives, ropes and rods.",
          "Marts also buy a lot of the loot your Pokemon win.",
      } },
    { key = 'buyer', title = 'Pokemon Buyer', portrait = 53,
      areas = { 'Pokemon Buyer' },
      lines = {
          "Say hi to open the shop: it buys Pokemon from your party and straight from your PC boxes.",
          "Tick the Pokemon you want to sell and press Sell. Shiny Pokemon and ones with 5 perfect IVs ask you to type SELL first.",
      } },
    { key = 'daycare', title = 'Day Care', portrait = 175,
      areas = { 'Daycare' },
      lines = {
          "Leave up to two Pokemon here: they gain experience while you play without them.",
          "Pick a time when you leave one and pay when you take it back. Cancel takes it out early, without experience.",
          "A compatible pair may leave you an Egg. Ditto works with anything.",
      } },
    { key = 'union', title = 'Union Room', portrait = 137,
      areas = { 'Union Room' },
      lines = {
          "Joey runs the tournaments, Emmet Cash is the bank and Curt Raeburn manages TMs.",
          "Josh Pillberg sells EV and breeding items, and the mastery wing is here too. Soul Coins are spent in the Store on the top bar.",
      } },
    { key = 'gym', title = 'Gym', portrait = 68,
      areas = { 'Gym' },
      lines = {
          "Beat the gym's trainers first, then pay the leader's respect points to challenge them.",
          "A win gives the badge, experience, respect and a TM.",
      } },
    { key = 'safari', title = 'Safari Zone', portrait = 115,
      areas = { 'Safari', 'Saffari' },
      lines = {
          "Only Safari Balls work here. Leave your Pokemon and balls behind before you go in.",
          "Throw stones or cookies to raise your chance, then a Safari Ball when you are told you can.",
      } },
    { key = 'bank', title = 'Bank', portrait = 52,
      areas = { 'Bank' },
      lines = {
          "Say balance, deposit, withdraw, transfer or history to the banker.",
          "The GTS, house rent and Pokepedia purchases use your bank balance.",
      } },
}

local BY_KEY = {}
for _, hint in ipairs(HINTS) do
    BY_KEY[hint.key] = hint
end

local TOP_MARGIN = 130
local FADE_MS = 250

local seen = {}
local synced = false
local queue = {}
local card
local lastArea
local checkEvent

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Hints, data)
    end
end

function isEnabled()
    local options = modules.client_options
    return not (options and options.getOption and options.getOption('showHints') == false)
end

function getHints()
    return HINTS
end

function hasSeen(key)
    return seen[key] == true
end

local function hintForArea(name)
    if not name or name == '' then
        return nil
    end
    for _, hint in ipairs(HINTS) do
        for _, word in ipairs(hint.areas or {}) do
            if name:find(word, 1, true) then
                return hint
            end
        end
    end
end

local function closeCard()
    if card then
        card:destroy()
        card = nil
    end
end

local showNext

local function place(widget)
    local map = modules.game_interface.getMapPanel()
    widget:addAnchor(AnchorTop, 'gameMapPanel', AnchorTop)
    widget:addAnchor(AnchorHorizontalCenter, 'gameMapPanel', AnchorHorizontalCenter)
    local top = map and math.min(TOP_MARGIN, math.floor(map:getHeight() / 5)) or TOP_MARGIN
    -- below the trainer's HUD, which sits over the top of the map, and the Pokegear loot list under it
    local root = modules.game_interface.getRootPanel()
    for _, id in ipairs({ 'pokeHud', 'pokegearLootFeed' }) do
        local area = map and root:recursiveGetChildById(id)
        if area and area:isVisible() then
            top = math.max(top, area:getY() + area:getHeight() - map:getY() + 12)
        end
    end
    widget:setMarginTop(top)
end

local function fit(widget)
    if widget:isDestroyed() then
        return
    end
    local lines, frame = widget:getChildById('lines'), widget:getChildById('frame')
    local content = math.max(lines:getY() + lines:getHeight(), frame:getY() + frame:getHeight()) - widget:getY()
    widget:setHeight(content + 12 + widget:getChildById('gotIt'):getHeight() + widget:getPaddingBottom())
end

local function display(hint)
    closeCard()
    card = g_ui.createWidget('HintCard', modules.game_interface.getRootPanel())
    place(card)
    card:getChildById('portrait'):setImageSource('/images/staticPortraits/' .. hint.portrait)
    card:getChildById('title'):setText(tr(hint.title))
    local lines = card:getChildById('lines')
    for _, line in ipairs(hint.lines) do
        local label = g_ui.createWidget('HintLine', lines)
        label:setText('- ' .. tr(line))
    end
    card:getChildById('gotIt').onClick = function()
        closeCard()
        scheduleEvent(showNext, FADE_MS)
    end
    card:getChildById('stop').onClick = function()
        queue = {}
        closeCard()
        local options = modules.client_options
        if options and options.setOption then
            options.setOption('showHints', false)
        end
        modules.game_textmessage.displayGameMessage(tr('Hints are off. Switch them back on in Settings > Interface.'))
    end
    card:raise()
    g_effects.fadeIn(card, FADE_MS)
    addEvent(function() fit(card) end)
    scheduleEvent(function() if card then fit(card) end end, 50)
end

showNext = function()
    if card or #queue == 0 then
        return
    end
    local entry = table.remove(queue, 1)
    if not entry.replay and (not isEnabled() or seen[entry.hint.key]) then
        return showNext()
    end
    if not entry.replay then
        seen[entry.hint.key] = true
        send({ action = 'seen', key = entry.hint.key })
    end
    display(entry.hint)
end

local function enqueue(hint, replay)
    for _, entry in ipairs(queue) do
        if entry.hint == hint then
            return
        end
    end
    table.insert(queue, { hint = hint, replay = replay })
    showNext()
end

function show(key)
    local hint = BY_KEY[key]
    if hint and synced and isEnabled() and not seen[key] and g_game.isOnline() then
        enqueue(hint, false)
        return true
    end
    return false
end

-- from the wiki: shows a hint again, seen or not and with hints off
function replay(key)
    local hint = BY_KEY[key]
    if hint and g_game.isOnline() then
        queue = {}
        closeCard()
        enqueue(hint, true)
    end
end

function resetSeen()
    send({ action = 'reset' })
end

local function checkArea()
    checkEvent = nil
    local environment = modules.game_environment
    local name = environment and environment.getAreaName and environment.getAreaName() or ''
    if name == lastArea then
        return
    end
    lastArea = name
    local hint = hintForArea(name)
    if hint then
        show(hint.key)
    end
end

local function onPositionChange()
    -- game_environment names the area in its own position handler; read it after that ran
    if not checkEvent then
        checkEvent = scheduleEvent(checkArea, 100)
    end
end

local function onHints(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Hints: invalid message')
        return
    end
    if data.type == 'seen' then
        seen = {}
        for _, key in ipairs(data.seen or {}) do
            seen[key] = true
        end
        synced = true
        lastArea = nil
        onPositionChange()
    elseif data.type == 'show' then
        show(data.key)
    end
end

local function onGameStart()
    seen, synced, queue, lastArea = {}, false, {}, nil
    send({ action = 'hello' })
end

local function onGameEnd()
    seen, synced, queue, lastArea = {}, false, {}, nil
    removeEvent(checkEvent)
    checkEvent = nil
    closeCard()
end

function init()
    g_ui.importStyle('hints')
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Hints, onHints)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    connect(LocalPlayer, { onPositionChange = onPositionChange })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Hints)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    disconnect(LocalPlayer, { onPositionChange = onPositionChange })
    removeEvent(checkEvent)
    checkEvent = nil
    closeCard()
end
