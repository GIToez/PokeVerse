-- The NPC conversation window, docked at the bottom of the game screen above the console. It shows
-- what the NPC said with its blue {words} inline and as buttons, and a big Yes and No when the NPC
-- asks a {yes} question. Buttons send through the console's NPCs tab, the same as clicking a link
-- there, so the tab keeps the whole conversation; typed answers go in the NPCs tab as before.
local IMAGES = '/modules/game_npcdialog/images/'
local LEADERS = '/modules/game_gymbattle/images/leaders/'
local WIDTH = 660
local MIN_HEIGHT = 156
local TEXT_COLOR = '#e6ecf5'
local WORD_COLOR = '#6fb6ff'
-- talking range of the server's NPCs; farther away they stop listening
local RANGE = 4
local IDLE_MS = 120000
-- after Goodbye, the NPC's farewell doesn't open the window again
local FAREWELL_MS = 3000
local FAREWELLS = { bye = true, goodbye = true, farewell = true, cya = true }

local PORTRAITS = {
    ['Brock'] = LEADERS .. 'brock', ['Misty'] = LEADERS .. 'misty', ['Lt. Surge'] = LEADERS .. 'ltsurge',
    ['Erika'] = LEADERS .. 'erika', ['Koga'] = LEADERS .. 'koga', ['Sabrina'] = LEADERS .. 'sabrina',
    ['Blaine'] = LEADERS .. 'blaine', ['Giovanni'] = LEADERS .. 'giovanni',
    ['Professor Oak'] = '/images/portraits/professor_oak', ['Red'] = '/images/portraits/red',
}

local ROLES = {
    ['Brock'] = 'Gym Leader, Pewter City', ['Misty'] = 'Gym Leader, Cerulean City',
    ['Lt. Surge'] = 'Gym Leader, Vermilion City', ['Erika'] = 'Gym Leader, Celadon City',
    ['Koga'] = 'Gym Leader, Fuchsia City', ['Sabrina'] = 'Gym Leader, Saffron City',
    ['Blaine'] = 'Gym Leader, Cinnabar Island', ['Giovanni'] = 'Gym Leader, Viridian City',
    ['Professor Oak'] = 'Pokemon Professor, Pallet Town', ['Red'] = 'Trainer Guide',
}

local window
local npc -- { name, id }
local lines = {}
local reply
local replied = false
local replyAt = 0
-- a line said this recently is what a newly opened conversation answers (usually the "hi")
local RECENT_REPLY_MS = 5000
local lastHeard = 0
local quietName, quietUntil = nil, 0
local checkEvent, layoutEvent

local function trim(s)
    return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

-- {word} and {word, other} both name the word before the comma, as in the console
local function wordsOf(text)
    local words, seen = {}, {}
    for content in text:gmatch('{([^}]*)}') do
        local word = trim(content:match('^([^,]*)') or content)
        local key = word:lower()
        if word ~= '' and not seen[key] then
            seen[key] = true
            words[#words + 1] = word
        end
    end
    return words
end

local function coloredText(text)
    local parts = {}
    local last = 1
    for from, content, to in text:gmatch('()%{([^}]*)%}()') do
        if from > last then
            parts[#parts + 1] = string.format('{%s, %s}', text:sub(last, from - 1), TEXT_COLOR)
        end
        local word = trim(content:match('^([^,]*)') or content)
        parts[#parts + 1] = string.format('{%s, %s}', word, WORD_COLOR)
        last = to
    end
    if last <= #text then
        parts[#parts + 1] = string.format('{%s, %s}', text:sub(last), TEXT_COLOR)
    end
    return table.concat(parts)
end

local function npcCreature()
    return npc and npc.id and g_map.getCreatureById(npc.id) or nil
end

local function findNpc(name, pos)
    if not pos then
        return nil
    end
    local tile = g_map.getTile(pos)
    for _, creature in ipairs(tile and tile:getCreatures() or {}) do
        if creature:getName() == name then
            return creature
        end
    end
    for _, creature in ipairs(g_map.getSpectators(pos, false)) do
        if creature:getName() == name and creature:isNpc() then
            return creature
        end
    end
    return nil
end

local function place()
    if not window then
        return
    end
    local root = modules.game_interface.getRootPanel()
    local map = modules.game_interface.getMapPanel()
    local rootRect, mapRect = root:getRect(), map:getRect()
    local width = math.min(WIDTH, mapRect.width - 16)
    window:setWidth(width)
    window:setMarginLeft(mapRect.x - rootRect.x + math.floor((mapRect.width - width) / 2))
    -- the console can sit over the bottom of the map
    local bottom = mapRect.y + mapRect.height
    local console = modules.game_interface.getBottomPanel()
    if console and console:isVisible() then
        bottom = math.min(bottom, console:getRect().y)
    end
    window:setMarginTop(math.max(0, bottom - rootRect.y - window:getHeight() - 6))
end

local function say(text)
    local console = modules.game_console
    local tab = console and console.consoleTabBar and console.consoleTabBar:getTab('NPCs')
    if tab then
        console.sendMessage(text, tab)
    else
        g_game.talk(text)
        onPlayerSay(text)
    end
end

local function addButton(style, word, label)
    local button = g_ui.createWidget(style, window.words)
    button:setText(label or (word:sub(1, 1):upper() .. word:sub(2)))
    if style == 'NpcWordButton' then
        button:setWidth(button:getTextSize().width + 26)
    end
    button.onClick = function() say(word) end
    return button
end

-- the buttons flow left to right and wrap to a new row when the row is full
local function layoutButtons()
    local width = window.words:getWidth()
    local x, y, rowHeight = 0, 0, 0
    for _, button in ipairs(window.words:getChildren()) do
        local w, h = button:getWidth(), button:getHeight()
        if x > 0 and x + w > width then
            x, y, rowHeight = 0, y + rowHeight + 6, 0
        end
        button:addAnchor(AnchorTop, 'parent', AnchorTop)
        button:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        button:setMarginTop(y)
        button:setMarginLeft(x)
        x = x + w + 6
        rowHeight = math.max(rowHeight, h)
    end
    return window.words:getChildCount() > 0 and (y + rowHeight) or 0
end

local function layout()
    layoutEvent = nil
    if not window then
        return
    end
    local message = window.message
    local textTop = 7
    if message.reply:isVisible() then
        textTop = 7 + message.reply:getHeight() + 2
    end
    message.text:setMarginTop(textTop)
    local messageHeight = textTop + message.text:getHeight() + 8
    message:setHeight(messageHeight)
    local wordsHeight = layoutButtons()
    window.words:setHeight(math.max(wordsHeight, 22))
    local top = window.name:getMarginTop() + window.name:getHeight() + 5
    window:setHeight(math.max(MIN_HEIGHT, top + messageHeight + 8 + math.max(wordsHeight, 22) + 12))
    place()
end

local function scheduleLayout()
    if layoutEvent then
        removeEvent(layoutEvent)
    end
    -- the wrapped text has its height once the window is laid out at its width
    layoutEvent = addEvent(function() addEvent(layout) end)
end

local function showPortrait(creature)
    local picture = window.portrait.picture
    local path = PORTRAITS[npc.name]
    if path then
        picture:setImageSource(path)
        picture:show()
        window.portrait.creature:hide()
    else
        picture:hide()
        window.portrait.creature:show()
        if creature then
            window.portrait.creature:setOutfit(creature:getOutfit())
            local shown = window.portrait.creature:getCreature()
            if shown then
                shown:setDirection(Directions.South)
            end
        end
    end
end

local function refresh()
    local text = table.concat(lines, '\n')
    window.message.text:setColoredText(coloredText(text))
    if reply and reply ~= '' then
        window.message.reply:setText(tr('You: %s', reply))
        window.message.reply:show()
    else
        window.message.reply:hide()
    end

    window.words:destroyChildren()
    local words = wordsOf(text)
    local hasYes = false
    for _, word in ipairs(words) do
        if word:lower() == 'yes' then
            hasYes = true
        end
    end
    if hasYes then
        local yes, no = 'yes', 'no'
        for _, word in ipairs(words) do
            if word:lower() == 'yes' then yes = word elseif word:lower() == 'no' then no = word end
        end
        addButton('NpcYesButton', yes, tr('Yes'))
        addButton('NpcNoButton', no, tr('No'))
    end
    for _, word in ipairs(words) do
        local key = word:lower()
        if not (hasYes and (key == 'yes' or key == 'no')) then
            addButton('NpcWordButton', word)
        end
    end
    scheduleLayout()
end

local function stopChecking()
    if checkEvent then
        removeEvent(checkEvent)
        checkEvent = nil
    end
end

function hide()
    stopChecking()
    if layoutEvent then
        removeEvent(layoutEvent)
        layoutEvent = nil
    end
    if window then
        window:destroy()
        window = nil
    end
    npc, lines, reply, replied, replyAt = nil, {}, nil, false, 0
end

-- the conversation ends when the player walks out of range, the NPC leaves the screen or goes quiet
local function check()
    local player = g_game.getLocalPlayer()
    local creature = npcCreature()
    if not player or not creature or g_clock.millis() - lastHeard > IDLE_MS then
        hide()
        return
    end
    local a, b = player:getPosition(), creature:getPosition()
    if not a or not b or a.z ~= b.z or math.max(math.abs(a.x - b.x), math.abs(a.y - b.y)) > RANGE + 2 then
        hide()
    end
end

local function open(name, creature)
    if not window then
        window = g_ui.createWidget('NpcDialog', modules.game_interface.getRootPanel())
    end
    npc = { name = name, id = creature and creature:getId() or nil }
    window.name:setText(name)
    window.role:setText(ROLES[name] and tr(ROLES[name]) or '')
    showPortrait(creature)
    stopChecking()
    if npc.id then
        checkEvent = cycleEvent(check, 500)
    end
end

function goodbye()
    if npc then
        quietName, quietUntil = npc.name, g_clock.millis() + FAREWELL_MS
    end
    say('bye')
    hide()
end

-- every line the player says to the NPC, typed in the NPCs tab or sent by a button
function onPlayerSay(text)
    text = trim(text or '')
    if text == '' then
        return
    end
    if FAREWELLS[text:lower()] then
        if npc then
            quietName, quietUntil = npc.name, g_clock.millis() + FAREWELL_MS
        end
        hide()
        return
    end
    reply, replied, replyAt = text, true, g_clock.millis()
end

local function onTalk(name, level, mode, text, channelId, creaturePos)
    if mode == MessageModes.Say and name == g_game.getCharacterName() then
        onPlayerSay(text)
        return
    end
    if mode ~= MessageModes.NpcFrom and mode ~= MessageModes.NpcFromStartBlock then
        return
    end
    if name == quietName and g_clock.millis() < quietUntil then
        return
    end
    local creature = findNpc(name, creaturePos)
    if not npc or npc.name ~= name then
        lines = {}
        if g_clock.millis() - replyAt > RECENT_REPLY_MS then
            reply, replied = nil, false
        end
    end
    -- every NPC line comes as NpcFromStartBlock, so the player's reply is what starts a new page
    if replied then
        lines, replied = {}, false
    end
    open(name, creature or npcCreature())
    lines[#lines + 1] = text
    lastHeard = g_clock.millis()
    refresh()
end

local function onGeometryChange()
    if window then
        place()
    end
end

function init()
    g_ui.importStyle('npcdialog')
    connect(g_game, { onTalk = onTalk, onGameEnd = hide })
    for _, panel in ipairs({ modules.game_interface.getMapPanel(), modules.game_interface.getBottomPanel() }) do
        connect(panel, { onGeometryChange = onGeometryChange })
    end
end

function terminate()
    disconnect(g_game, { onTalk = onTalk, onGameEnd = hide })
    for _, panel in ipairs({ modules.game_interface.getMapPanel(), modules.game_interface.getBottomPanel() }) do
        disconnect(panel, { onGeometryChange = onGeometryChange })
    end
    hide()
end
