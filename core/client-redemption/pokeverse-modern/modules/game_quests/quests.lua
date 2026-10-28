-- The quest log (server lib Quests, 075-quests.lua). The client says {action = "hello"} after login and
-- the server answers with the quests under way ({type = "active"}) for the tracker, and the marks over the
-- NPCs ({type = "marks"}, icons.lua). Opening the window asks for {action = "list"}: every quest the
-- trainer has started, can start now or later, and has done. Quest notices ({type = "notice"}) are drawn
-- by notices.lua and keep the rows here up to date. The tracked quests and the folded categories are kept
-- per character in g_settings ('QuestLog').
IMAGES = '/modules/game_quests/images/'

local CATEGORIES = { 'Main story', 'Gyms', 'Getting started', 'Side quests', 'Daily', 'Addons', 'Events' }
local TABS = { 'active', 'available', 'done' }
local TAB_NAMES = { active = 'Active', available = 'Available', done = 'Completed' }
local HELLO_DELAY = 1600
local LATER_COLOR = '#7f8ba3'

local window
local button
local helloEvent
local quests = {} -- id -> row
local order = {} -- ids in the server's order
local updates = {} -- id -> true: news since the log was last opened
local tab = 'active'
local selected -- id
local tracked = {} -- id -> true
local collapsed = {} -- "<tab>:<category>" -> true, the categories folded away in that tab
local loaded = false -- the full list came at least once

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Quest, data)
    end
end

-- per character settings

local function settingsKey()
    return ((g_game.getCharacterName() or ''):gsub('[^%w]', '_'))
end

local function loadTracked()
    tracked, collapsed = {}, {}
    local node = g_settings.getNode('QuestLog') or {}
    local mine = node[settingsKey()]
    if type(mine) == 'table' and type(mine.tracked) == 'table' then
        for _, id in pairs(mine.tracked) do
            if tonumber(id) then
                tracked[tonumber(id)] = true
            end
        end
    end
    if type(mine) == 'table' and type(mine.collapsed) == 'table' then
        for _, key in pairs(mine.collapsed) do
            collapsed[tostring(key)] = true
        end
    end
end

local function saveTracked()
    local list, folded = {}, {}
    for id in pairs(tracked) do
        list[#list + 1] = id
    end
    table.sort(list)
    for key in pairs(collapsed) do
        folded[#folded + 1] = key
    end
    table.sort(folded)
    local node = g_settings.getNode('QuestLog') or {}
    node[settingsKey()] = { tracked = list, collapsed = folded }
    g_settings.setNode('QuestLog', node)
    g_settings.save()
end

local function refreshTracker()
    local pokepedia = modules.game_pokepedia
    if pokepedia and pokepedia.Tracker then
        pokepedia.Tracker.refresh()
    end
end

-- helpers

function setTrack(track, value, max, fill)
    track.fill:setImageSource('/modules/game_dailytasks/images/' .. (fill or 'fill_blue'))
    local function resize()
        local ratio = math.min(1, (value or 0) / math.max(1, max or 1))
        local width = math.floor(track:getWidth() * ratio)
        track.fill:setWidth(width)
        track.fill:setVisible(width >= 6)
    end
    track.onGeometryChange = resize
    resize()
end

function isReady(row)
    return row.state == 'active' and row.need and row.have and row.have >= row.need
end

function questTitle(row)
    return row.step and (row.name .. '  -  ' .. row.step) or row.name
end

local function placeText(row)
    local place = row.place
    if place and place.town and place.town ~= '' then
        return tr('%s, near %s', row.npc, place.town)
    end
    return row.npc or ''
end

local function shorten(text, max)
    text = tostring(text or '')
    return #text > max and text:sub(1, max - 3) .. '...' or text
end

local function rewardText(reward)
    if reward.kind == 'item' then
        return (reward.count or 1) > 1 and tr('%d %s', reward.count, reward.name or '') or (reward.name or '')
    elseif reward.kind == 'pokemon' then
        return reward.level and tr('%s, level %d', reward.name or '', reward.level) or (reward.name or '')
    end
    return tr(reward.name or 'New outfit')
end

function rewardsSummary(row)
    local parts = {}
    if (tonumber(row.exp) or 0) > 0 then
        parts[#parts + 1] = tr('%s exp', tostring(row.exp))
    end
    for _, reward in ipairs(row.rewards or {}) do
        parts[#parts + 1] = rewardText(reward)
    end
    return table.concat(parts, ', ')
end

local function inTab(row, name)
    if name == 'available' then
        return row.state == 'available' or row.state == 'later'
    end
    return row.state == name
end

local function matches(row, filter)
    if filter == '' then
        return true
    end
    for _, text in ipairs({ row.name, row.group, row.npc, row.objective, row.place and row.place.town }) do
        if text and tostring(text):lower():find(filter, 1, true) then
            return true
        end
    end
    return false
end

-- the window

local function hintText(row)
    local town = row.place and row.place.town
    if town and town ~= '' then
        return tr('Someone around %s has a quest for you.', town)
    end
    return tr('Someone out there has a quest for you.')
end

-- a quest from an NPC the trainer hasn't met yet: only where to look, and the level
local function drawHiddenDetails(details, row)
    details.name:setText('???')
    details.step:setText(tr(row.category or 'Side quests'))
    details.portrait:setVisible(true)
    details.portrait:setImageSource(IMAGES .. 'icon_quests')
    details.creature:setVisible(false)
    details.giver:setText(hintText(row))
    details.actions:hide()
    details.objective.text:setText(tr('Undiscovered quest'))
    details.objective.description:setText(tr('Explore and talk to the people you meet. Once you find who gives this quest, it shows here with its story and rewards.'))
    details.objective.track:hide()
    details.objective.count:hide()
    details.objective:setHeight(104)
    details.rewards:hide()
    local notes = {}
    if row.state == 'later' then
        notes[#notes + 1] = tr('Offered from trainer level %d.', row.level or 0)
    elseif (tonumber(row.level) or 0) > 1 then
        notes[#notes + 1] = tr('Requires trainer level %d.', row.level)
    end
    if row.daily then
        notes[#notes + 1] = tr('Daily: it can be done again after the server restart.')
    end
    details.footer:setText(table.concat(notes, '\n'))
end

local function drawDetails()
    local details = window.details
    local row = selected and quests[selected]
    for _, child in ipairs(details:getChildren()) do
        child:setVisible(row ~= nil and child:getId() ~= 'none')
    end
    details.none:setVisible(row == nil)
    if not row then
        return
    end
    if row.hidden then
        drawHiddenDetails(details, row)
        return
    end
    details.actions:show()

    details.name:setText(shorten(row.name, 40))
    details.step:setText(row.step or row.group or row.category or '')
    local portrait = modules.game_npcdialog and modules.game_npcdialog.getPortrait and
        modules.game_npcdialog.getPortrait(row.npc)
    local look = row.place and row.place.look
    details.portrait:setVisible(portrait ~= nil)
    details.creature:setVisible(portrait == nil and look ~= nil and look.type ~= nil)
    if portrait then
        details.portrait:setImageSource(portrait)
    elseif look and look.type then
        details.creature:setOutfit({ type = look.type, head = look.head or 0, body = look.body or 0,
            legs = look.legs or 0, feet = look.feet or 0 })
    end
    details.giver:setText(tr('Given by %s', placeText(row)))

    local canGo = row.place ~= nil and row.state ~= 'done'
    details.actions.goThere:setEnabled(canGo)
    details.actions.goThere:setTooltip(canGo and tr('Walk to %s', row.npc) or tr('Nowhere to go for this one.'))
    details.actions.goThere.onClick = function()
        local pokepedia = modules.game_pokepedia
        if pokepedia and pokepedia.Navigation and row.place then
            pokepedia.Navigation.goTo({ x = row.place.x, y = row.place.y, z = row.place.z }, row.npc)
            hide()
        end
    end
    local pokepedia = modules.game_pokepedia
    local canMap = canGo and pokepedia and pokepedia.MapTab and pokepedia.MapTab.showPosition ~= nil
    details.actions.viewMap:setEnabled(canMap and true or false)
    details.actions.viewMap:setTooltip(canMap and tr('Show where %s is on the world map', row.npc) or
        tr('Nowhere to go for this one.'))
    details.actions.viewMap.onClick = function()
        if canMap then
            pokepedia.MapTab.showPosition({ x = row.place.x, y = row.place.y, z = row.place.z }, row.npc, true)
            hide()
        end
    end
    local track = details.actions.track
    track:setVisible(row.state == 'active')
    track:setText(tracked[row.id] and tr('Untrack') or tr('Track'))
    track.onClick = function()
        tracked[row.id] = (not tracked[row.id]) or nil
        saveTracked()
        drawDetails()
        refreshTracker()
        local pokepedia = modules.game_pokepedia
        if tracked[row.id] and pokepedia and pokepedia.Tracker and pokepedia.Tracker.open then
            pokepedia.Tracker.open()
        end
    end

    local objective = details.objective
    objective.text:setText(row.objective or tr('Talk to %s.', row.npc))
    local text = row.text and row.text ~= row.objective and row.text or ''
    objective.description:setText(shorten(text, 220))
    local hasCount = row.state == 'active' and row.need ~= nil
    objective.track:setVisible(hasCount)
    objective.count:setVisible(hasCount)
    if hasCount then
        setTrack(objective.track, row.have, row.need, isReady(row) and 'fill_green' or 'fill_blue')
        objective.count:setText(string.format('%d / %d', row.have or 0, row.need))
    end
    objective:setHeight(row.text and row.text ~= row.objective and 104 or 70)

    local rewards = details.rewards
    rewards.list:destroyChildren()
    for _, reward in ipairs(row.rewards or {}) do
        if #rewards.list:getChildren() >= 6 then
            break
        end
        local widget = g_ui.createWidget('QuestReward', rewards.list)
        widget:setTooltip(rewardText(reward))
        if reward.kind == 'item' and (tonumber(reward.client) or 0) > 0 then
            widget.item:setItemId(reward.client)
            widget.item:show()
            widget.count:setText((reward.count or 1) > 1 and tostring(reward.count) or '')
        else
            widget.picture:setImageSource(reward.kind == 'pokemon' and (reward.number and
                '/images/staticPortraits/' .. reward.number or '/modules/game_pokehud/images/ball') or
                '/modules/game_trainercard/images/icon_outfit')
            widget.picture:show()
            widget.count:setText(reward.level and tostring(reward.level) or '')
        end
    end
    local exp = tonumber(row.exp) or 0
    rewards.exp:setText(exp > 0 and tr('+%s EXP', tostring(exp)) or '')
    rewards:setVisible(exp > 0 or #(row.rewards or {}) > 0)

    local notes = {}
    if row.state == 'later' then
        notes[#notes + 1] = tr('%s offers this from trainer level %d.', row.npc, row.level or 0)
    elseif (tonumber(row.level) or 0) > 1 then
        notes[#notes + 1] = tr('Requires trainer level %d.', row.level)
    end
    if row.daily then
        notes[#notes + 1] = tr('Daily: it can be done again after the server restart.')
    end
    if row.state == 'available' then
        notes[#notes + 1] = tr('Talk to %s to start it.', row.npc)
    elseif isReady(row) then
        notes[#notes + 1] = tr('Done! Go back to %s.', row.npc)
    end
    details.footer:setText(table.concat(notes, '\n'))
end

local function addRow(list, row)
    local widget = g_ui.createWidget('QuestRow', list)
    widget.questId = row.id
    widget.name:setText(row.hidden and '???' or shorten(row.name, 36))
    widget:setChecked(row.id == selected)
    widget.icon:setImageSource(row.state == 'active' and (isReady(row) and IMAGES .. 'npc_quest_ready' or
        IMAGES .. 'npc_quest_active') or (row.state == 'done' and IMAGES .. 'icon_quests_small' or
        IMAGES .. 'npc_quest_available'))
    if row.state == 'active' or row.state == 'available' then
        widget.icon:setSize({ width = 18, height = 18 })
    end
    local sub = row.step and (row.step .. '  -  ' .. (row.npc or '')) or (row.npc or '')
    if row.state == 'later' then
        sub = tr('Level %d  -  %s', row.level or 0, row.npc or '')
        widget.name:setColor(LATER_COLOR)
        widget.icon:setOpacity(0.5)
    end
    if row.hidden then
        local town = row.place and row.place.town
        sub = (town and town ~= '') and tr('Somewhere around %s', town) or tr('Somewhere out there')
        if row.state == 'later' then
            sub = tr('Level %d  -  %s', row.level or 0, sub)
        end
        widget.name:setColor(LATER_COLOR)
        widget.icon:setOpacity(0.5)
    end
    widget.sub:setText(sub)
    if row.state == 'active' and row.need then
        widget.track:show()
        setTrack(widget.track, row.have, row.need, isReady(row) and 'fill_green' or 'fill_blue')
    end
    widget:setTooltip(row.hidden and tr('Undiscovered quest') or (row.objective or row.name))
    widget.onClick = function()
        selected = row.id
        for _, child in ipairs(list:getChildren()) do
            if child.questId then
                child:setChecked(child.questId == selected)
            end
        end
        drawDetails()
    end
    return widget
end

local function counts()
    local result = { active = 0, available = 0, done = 0 }
    for _, id in ipairs(order) do
        local row = quests[id]
        for _, name in ipairs(TABS) do
            if inTab(row, name) then
                result[name] = result[name] + 1
            end
        end
    end
    return result
end

local function drawList()
    if not window then
        return
    end
    local count = counts()
    for _, name in ipairs(TABS) do
        local widget = window.tabs[name]
        widget:setOn(name == tab)
        widget:setText(tr('%s (%d)', tr(TAB_NAMES[name]), count[name]))
    end

    local filter = window.search:getText():lower()
    local groups = {}
    for _, id in ipairs(order) do
        local row = quests[id]
        if inTab(row, tab) and matches(row, filter) then
            local category = row.category or 'Side quests'
            groups[category] = groups[category] or {}
            table.insert(groups[category], row)
        end
    end

    local list = window.list
    list:destroyChildren()
    local first, keep
    for _, category in ipairs(CATEGORIES) do
        local rows = groups[category]
        if rows then
            -- in the Available tab the ones to start now go first
            table.sort(rows, function(a, b)
                if (a.state == 'later') ~= (b.state == 'later') then
                    return b.state == 'later'
                end
                if a.state == 'later' and (a.level or 0) ~= (b.level or 0) then
                    return (a.level or 0) < (b.level or 0)
                end
                return false
            end)
            local key = tab .. ':' .. category
            -- a search shows every match, folded or not
            local folded = collapsed[key] and filter == ''
            local header = g_ui.createWidget('QuestGroup', list)
            header.title:setText(tr(category))
            local found = 0
            for _, row in ipairs(rows) do
                found = found + (row.hidden and 0 or 1)
            end
            header.count:setText(found < #rows and tr('(%d of %d found)', found, #rows) or string.format('(%d)', #rows))
            header.arrow:setOn(folded)
            header:setTooltip(folded and tr('Click to show these quests') or tr('Click to hide these quests'))
            header.onClick = function()
                collapsed[key] = not collapsed[key] or nil
                saveTracked()
                local scroll = window.listScroll and window.listScroll:getValue()
                drawList()
                if scroll then
                    window.list:getLayout():update()
                    window.listScroll:setValue(scroll)
                end
            end
            for _, row in ipairs(rows) do
                first = first or row.id
                keep = keep or (row.id == selected and row.id)
                if not folded then
                    addRow(list, row)
                end
            end
        end
    end
    if not keep then
        selected = first
        for _, child in ipairs(list:getChildren()) do
            if child.questId then
                child:setChecked(child.questId == selected)
            end
        end
    end
    local empty = #list:getChildren() == 0
    window.empty:setVisible(empty)
    if empty then
        window.empty:setText(not loaded and tr('Loading your quests...') or (filter ~= '' and
            tr('No quest matches "%s".', filter) or (tab == 'active' and
            tr('No quest under way. The Available tab lists what the NPCs offer you.') or
            (tab == 'available' and tr('No NPC has a quest for you right now. More open up as you level.') or
                tr('You have not finished a quest yet.')))))
    end
    drawDetails()
end

local function selectTab(name)
    tab = name
    drawList()
end

function show(questId)
    if not window or not g_game.isOnline() then
        return
    end
    if not window:isVisible() then
        local root = rootWidget:getSize()
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
            y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
    end
    if questId and quests[questId] then
        selected = questId
        tab = quests[questId].state == 'done' and 'done' or
            ((quests[questId].state == 'available' or quests[questId].state == 'later') and 'available' or 'active')
    end
    window:show()
    window:raise()
    window:focus()
    if button then
        button:setOn(true)
    end
    updates = {}
    drawList()
    send({ action = 'list' })
end

-- the quests with news (started, progress, done) since the log was last opened: the Pokegear ring's badge
function getUpdateCount()
    local count = 0
    for _ in pairs(updates) do
        count = count + 1
    end
    return count
end

function hide()
    if window then
        window:hide()
    end
    if button then
        button:setOn(false)
    end
end

function toggle()
    if window and window:isVisible() then
        hide()
    else
        show()
    end
end

function isVisible()
    return window ~= nil and window:isVisible()
end

-- for the screenshots in tests
function openTab(name)
    show()
    if window and window.tabs[name] then
        selectTab(name)
    end
end

-- the data

local function setRows(rows, full)
    if full then
        quests, order = {}, {}
    end
    for _, row in ipairs(rows or {}) do
        if type(row) == 'table' and tonumber(row.id) then
            row.id = tonumber(row.id)
            if not quests[row.id] then
                order[#order + 1] = row.id
            end
            quests[row.id] = row
        end
    end
    -- a tracked quest that is no longer under way leaves the tracker
    if full then
        for id in pairs(tracked) do
            if not quests[id] or quests[id].state ~= 'active' then
                tracked[id] = nil
            end
        end
        saveTracked()
    end
end

-- a notice changes one row: progress, a new quest or one done
function onNotice(data)
    local id = tonumber(data.id)
    if not id then
        return
    end
    local row = quests[id]
    if not row then
        row = { id = id, name = data.name, step = data.step, npc = data.npc, objective = data.objective,
                category = 'Side quests' }
        quests[id] = row
        order[#order + 1] = id
    end
    if data.kind == 'complete' then
        row.state = 'done'
        tracked[id] = nil
        saveTracked()
        if modules.game_sounds then
            modules.game_sounds.play('quest_complete')
        end
    else
        row.state = 'active'
        row.have, row.need = data.have, data.need
        if data.kind == 'started' then
            tracked[id] = true
            saveTracked()
        end
    end
    if isVisible() then
        drawList()
    else
        updates[id] = true
    end
    refreshTracker()
end

-- the tracker's lines (game_pokepedia/tracker.lua)
function getTrackerLines()
    local lines = {}
    for _, id in ipairs(order) do
        local row = quests[id]
        if tracked[id] and row and row.state == 'active' then
            local ready = isReady(row)
            local key = 'quest_' .. id
            lines[#lines + 1] = { key = key, icon = IMAGES .. (ready and 'npc_quest_ready' or 'npc_quest_active'),
                name = row.name:match(' %- (.+)$') or row.name,
                count = row.need and string.format('%d / %d', math.min(row.have or 0, row.need), row.need) or '',
                value = row.need and (row.have or 0) or 0, max = row.need or 1, done = ready,
                claim = ready and tr('Go') or nil,
                onClaim = function()
                    local pokepedia = modules.game_pokepedia
                    if pokepedia and pokepedia.Navigation and row.place then
                        pokepedia.Navigation.goTo({ x = row.place.x, y = row.place.y, z = row.place.z }, row.npc)
                    else
                        show(id)
                    end
                end,
                tooltip = (row.objective or row.name) .. (ready and ('\n' .. tr('Done! Go back to %s.', row.npc)) or ''),
                onClick = function() show(id) end,
                onRemove = function()
                    tracked[id] = nil
                    saveTracked()
                    refreshTracker()
                end }
        end
    end
    return lines
end

-- messages over 8 KB arrive as "#id:index:count:" fragments, possibly out of order
local fragments, fragmentIds = {}, {}

local function join(buffer)
    if buffer:sub(1, 1) ~= '#' then
        return buffer
    end
    local id, index, count, piece = buffer:match('^#(%d+):(%d+):(%d+):(.*)$')
    if not id then
        return nil
    end
    index, count = tonumber(index), tonumber(count)
    local entry = fragments[id]
    if not entry then
        entry = { count = count, got = 0, pieces = {} }
        fragments[id] = entry
        table.insert(fragmentIds, id)
        if #fragmentIds > 8 then
            fragments[table.remove(fragmentIds, 1)] = nil
        end
    end
    if not entry.pieces[index] then
        entry.pieces[index] = piece
        entry.got = entry.got + 1
    end
    if entry.got < entry.count then
        return nil
    end
    fragments[id] = nil
    table.removevalue(fragmentIds, id)
    return table.concat(entry.pieces)
end

local function onQuest(protocol, opcode, buffer)
    buffer = join(buffer)
    if not buffer then
        return
    end
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Quests: invalid message')
        return
    end
    if data.type == 'list' then
        loaded = true
        setRows(data.quests, true)
        if isVisible() then
            drawList()
        end
        refreshTracker()
    elseif data.type == 'active' then
        setRows(data.quests, false)
        refreshTracker()
    elseif data.type == 'notice' then
        onNotice(data)
        showNotice(data)
    elseif data.type == 'marks' then
        setMarks(data.npcs or {})
    elseif data.type == 'found' and isVisible() then
        send({ action = 'list' })
    end
end

-- L is a plain letter: it shouldn't fire while the trainer types in a text field
local function typing()
    local widget = rootWidget
    while widget:getFocusedChild() do
        widget = widget:getFocusedChild()
    end
    return widget:getClassName() == 'UITextEdit' and widget:isEnabled() and widget:isVisible()
end

local function onToggleKey()
    if not typing() then
        toggle()
    end
end

local function onGameStart()
    quests, order, selected, loaded, updates = {}, {}, nil, false, {}
    loadTracked()
    removeEvent(helloEvent)
    helloEvent = scheduleEvent(function()
        helloEvent = nil
        send({ action = 'hello' })
    end, HELLO_DELAY)
end

local function onGameEnd()
    removeEvent(helloEvent)
    helloEvent = nil
    hide()
    quests, order, selected, loaded, updates = {}, {}, nil, false, {}
    fragments, fragmentIds = {}, {}
    resetNotices()
    resetIcons()
end

function init()
    g_ui.importStyle('/modules/game_dailytasks/tasks')
    g_ui.importStyle('/modules/game_fishing/fishing')
    g_ui.importStyle('/modules/game_gts/gts')
    g_ui.importStyle('quests')
    window = g_ui.createWidget('QuestLogWindow', rootWidget)
    window:hide()
    for _, name in ipairs(TABS) do
        window.tabs[name].onClick = function() selectTab(name) end
    end
    window.search.onTextChange = function() drawList() end

    button = modules.client_topmenu.addRightGameToggleButton('questLogButton', tr('Quest Log (L)'),
        '/images/options/button_questlog', toggle)
    Keybind.new('Windows', 'Show/hide the Quest Log', { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'L' }, '')
    Keybind.bind('Windows', 'Show/hide the Quest Log', { { type = KEY_DOWN, callback = onToggleKey } })

    initIcons()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Quest, onQuest)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    Keybind.delete('Windows', 'Show/hide the Quest Log')
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Quest)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    removeEvent(helloEvent)
    helloEvent = nil
    resetNotices()
    terminateIcons()
    for _, widget in ipairs({ button, window }) do
        if widget then
            widget:destroy()
        end
    end
    button, window = nil, nil
end
