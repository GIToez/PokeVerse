-- The Pokedex tab: every species with what the trainer knows about it. Defeats and catches raise
-- the knowledge level: seen (name and picture), 1 (base stats, abilities, moves), 2 (EV yield,
-- drops, how hard it is to catch), 3 (where it spawns). The server sends what the level allows.
DexTab = {}

local page
local entries = {} -- number -> { number, name, level, points, next, wild }
local order = {}
local incoming
local complete, wild = 0, 0
local selected
local detail
local searchEvent, redrawEvent

local FILTERS = {
    { id = 'all', name = 'All Pokemon' },
    { id = 'learning', name = 'Still learning' },
    { id = 'complete', name = 'Complete' },
    { id = 'unseen', name = 'Not seen yet' },
    { id = 'tracked', name = 'Tracked' },
}
local TIERS = { normal = 'Common', rare = 'Rare', legendary = 'Legendary' }
local LEVEL_TEXT = {
    [1] = 'base stats, abilities and moves',
    [2] = 'EV yield, drops and how hard it is to catch',
    [3] = 'where it spawns',
}

local function displayName(entry)
    return (entry.name ~= '' and entry.level >= 0) and entry.name or '???'
end

local function matches(entry)
    local side = page.side
    local text = side.search:getText():lower()
    if text ~= '' then
        local number = tonumber(text)
        if number then
            if entry.number ~= number then
                return false
            end
        elseif entry.name == '' or not entry.name:lower():find(text, 1, true) then
            return false
        end
    end
    local filter = (side.filter:getCurrentOption() or {}).data or 'all'
    if filter == 'learning' then
        return entry.level >= 0 and entry.level < 3
    elseif filter == 'complete' then
        return entry.level >= 3
    elseif filter == 'unseen' then
        return entry.level < 0
    elseif filter == 'tracked' then
        return entry.name ~= '' and Tracker.isTracked(entry.name)
    end
    return true
end

local function fillRow(row, entry)
    row.number:setText(string.format('#%03d', entry.number))
    row.name:setText(displayName(entry))
    row.name:setColor(entry.level < 0 and '#7d8db0' or (entry.level >= 3 and '#8fe08f' or '#dce6ff'))
    row.level:setText(entry.level >= 1 and ('L' .. entry.level) or (entry.level == 0 and tr('Seen') or ''))
    if entry.level >= 3 then
        row.points:setText(tr('Done'))
    elseif entry.next > 0 then
        row.points:setText(string.format('%d / %d', entry.points, entry.next))
    else
        row.points:setText('')
    end
end

local function drawList()
    if not page then
        return
    end
    local list = page.side.list
    list:destroyChildren()
    local focus
    for _, number in ipairs(order) do
        local entry = entries[number]
        if matches(entry) then
            local row = g_ui.createWidget('PpDexRow', list)
            row.entry = entry
            fillRow(row, entry)
            if number == selected then
                focus = row
            end
        end
    end
    page.side.complete:setText(tr('Complete: %d / %d', complete, wild))
    page.side.complete:setTooltip(tr('Know every wild Pokemon to level 3 for a Master Ball.'))
    if focus then
        list:focusChild(focus, KeyboardFocusReason)
        list:ensureChildVisible(focus)
    end
end

local function scheduleRedraw()
    removeEvent(redrawEvent)
    redrawEvent = scheduleEvent(function()
        redrawEvent = nil
        if page and page:isVisible() then
            drawList()
        end
    end, 300)
end

function Handlers.dexlist(data)
    if data.part == 1 or not incoming then
        incoming = {}
    end
    for _, row in ipairs(data.list or {}) do
        incoming[#incoming + 1] = { number = row[1], name = tostring(row[2] or ''), level = row[3] or -1,
            points = row[4] or 0, next = row[5] or 0, wild = row[6] == 1 }
    end
    if data.part >= data.parts then
        entries, order = {}, {}
        for _, entry in ipairs(incoming) do
            entries[entry.number] = entry
            order[#order + 1] = entry.number
        end
        incoming = nil
        complete, wild = data.complete or 0, data.wild or 0
        drawList()
    end
end

-- details

local function setLocked(card, locked, text)
    card.locked:setVisible(locked)
    card.locked:setText(text or '')
end

local function lockText(data, level)
    local need = (data.thresholds or {})[level]
    if not need then
        return tr('Defeat or catch more to learn it.')
    end
    return tr('Defeat or catch %d more to learn its %s.', math.max(1, need - (data.points or 0)), tr(LEVEL_TEXT[level]))
end

local function drawDetail(data)
    detail = data
    local details = page.details
    details.empty:hide()
    local content = details.content
    content:show()
    local seen = data.level >= 0 and data.name ~= ''

    local portrait = content.icon.portrait
    portrait:setSize({ width = 64, height = 64 })
    portrait:setVisible(true)
    portrait:setImageSource(Pp.portrait(data.number))
    portrait:setImageColor(seen and '#ffffff' or '#000000')
    content.name:setText(seen and data.name or '???')
    content.tier:setText(string.format('#%03d  %s', data.number, tr(TIERS[data.tier] or 'Common')))
    if data.level >= 3 then
        content.level:setText(tr('Knowledge complete'))
        content.level:setColor('#8fe08f')
    elseif data.level >= 0 then
        content.level:setText(tr('Knowledge level %d of 3', data.level))
        content.level:setColor('#ffffff')
    else
        content.level:setText(tr('Not seen yet'))
        content.level:setColor('#96aacd')
    end
    local nextAt = data.next or 0
    Pp.setTrack(content.track, data.level >= 3 and 1 or (data.points or 0), data.level >= 3 and 1 or math.max(1, nextAt),
        data.level >= 3 and 'fill_green' or 'fill_blue')
    content.count:setText(data.level >= 3 and tr('%d', data.points or 0) or string.format('%d / %d', data.points or 0, nextAt))
    content.kills:setText(tr('Defeated %d, caught %d', data.kills or 0, data.catches or 0))

    local trackButton = content.trackButton
    local tracked = seen and Tracker.isTracked(data.name)
    trackButton:setEnabled(seen)
    trackButton:setText(tracked and tr('Untrack') or tr('Track'))
    trackButton:setTooltip(seen and tr('Follow its progress in the tracker panel') or tr('See it first'))
    -- the legacy Pokedex only shows species scanned with the Pokedex item
    content.open:setEnabled(seen and data.dexed == true)
    content.open:setTooltip(data.dexed and tr('Its types, matchups, moves and evolutions')
        or tr('Use your Pokedex on a %s to add it to the Pokedex first.', seen and data.name or tr('Pokemon')))

    local stats = content.stats
    stats.title:setText(tr('Base stats'))
    stats.values:destroyChildren()
    setLocked(stats, data.stats == nil, data.stats == nil and lockText(data, 1) or nil)
    if data.stats then
        for _, stat in ipairs({ { 'Attack', data.stats.attack }, { 'Defense', data.stats.defense },
            { 'Sp. Attack', data.stats.spAttack }, { 'Sp. Defense', data.stats.spDefense } }) do
            local label = g_ui.createWidget('TkText', stats.values)
            label:setText(string.format('%s: %s', tr(stat[1]), tostring(stat[2])))
        end
    end

    local catching = content.catching
    catching.title:setText(tr('Catching and drops'))
    catching.drops:destroyChildren()
    local hasCatch = data.catchHint ~= nil
    setLocked(catching, not hasCatch, not hasCatch and lockText(data, 2) or nil)
    catching.hint:setVisible(hasCatch)
    if hasCatch then
        catching.hint:setText(tr('How hard to catch: %s', data.catchHint))
        for _, drop in ipairs(data.drops or {}) do
            local item = g_ui.createWidget('PpDropItem', catching.drops)
            item:setItemId(drop.client)
            item:setTooltip(string.format('%s (%s%%)', drop.name, tostring(drop.chance)))
        end
        if #(data.drops or {}) == 0 then
            local none = g_ui.createWidget('TkMuted', catching.drops)
            none:setText(tr('It drops nothing.'))
        end
    end

    local spawns = content.spawns
    spawns.title:setText(tr('Where it lives'))
    spawns.list:destroyChildren()
    local hasSpawns = data.spawns ~= nil
    setLocked(spawns, not hasSpawns, not hasSpawns and lockText(data, 3) or nil)
    spawns.list:setVisible(hasSpawns)
    spawns.listScroll:setVisible(hasSpawns)
    if hasSpawns then
        for _, area in ipairs(data.spawns) do
            local where = area.town ~= '' and tr('Near %s', area.town) or tr('Wild area')
            local text = tr('%s: %s, floor %s (%d spawns)', data.name, where, Pp.floorName(area.z), area.points)
            local row = g_ui.createWidget('PpSpawnRow', spawns.list)
            row.name:setText(tr('%s, floor %s (%d)', where, Pp.floorName(area.z), area.points))
            row:setTooltip(Pp.formatPosition(area))
            row.show.onClick = function() MapTab.showPositions({ { x = area.x, y = area.y, z = area.z, text = text } }, text) end
            row.route.onClick = function() MapTab.routeTo({ x = area.x, y = area.y, z = area.z }, tr('%s (%s)', data.name, where)) end
        end
        if #data.spawns == 0 then
            local none = g_ui.createWidget('TkMuted', spawns.list)
            none:setText(tr('It doesn\'t spawn in the wild.'))
            none:setMarginLeft(6)
        end
    end

    local entry = entries[data.number]
    if entry then
        entry.level, entry.points, entry.next = data.level, data.points or 0, data.next or 0
        if seen then
            entry.name = data.name
        end
    end
end

local pendingName

function Handlers.dex(data)
    if pendingName and data.number then
        pendingName = nil
        selected = data.number
        drawDetail(data)
        drawList()
    elseif data.number == selected then
        drawDetail(data)
    end
end

local function select(number)
    selected = number
    Pp.send({ action = 'dex', number = number })
end

-- the tracker's progress updates also keep the list current
function DexTab.onProgress(row)
    local entry = entries[row.number]
    if not entry then
        return
    end
    local leveled = entry.level ~= row.level
    entry.level, entry.points, entry.next = row.level, row.points or 0, row.next or 0
    if row.name and row.name ~= '' and row.level >= 0 then
        entry.name = row.name
    end
    scheduleRedraw()
    if row.number == selected and page and page:isVisible() and (leveled or detail) then
        select(row.number)
    end
end

-- the answer to a request by name brings the number, which then becomes the selection
function DexTab.open(name)
    page.side.search:setText('', true)
    page.side.filter:setCurrentOptionByData('all', true)
    pendingName = name
    show('dex')
    if type(name) == 'number' then
        Pp.send({ action = 'dex', number = name })
    else
        Pp.send({ action = 'dex', name = name })
    end
end

function DexTab.setup(widget)
    page = widget
    local side = page.side
    for _, filter in ipairs(FILTERS) do
        side.filter:addOption(tr(filter.name), filter.id)
    end
    side.filter.onOptionChange = drawList
    side.search.onTextChange = function()
        removeEvent(searchEvent)
        searchEvent = scheduleEvent(drawList, 150)
    end
    side.list.onChildFocusChange = function(list, focused)
        if focused and focused.entry and focused.entry.number ~= (detail and detail.number) then
            select(focused.entry.number)
        end
    end
    local content = page.details.content
    content.trackButton.onClick = function()
        if not detail or detail.name == '' then
            return
        end
        if Tracker.isTracked(detail.name) then
            Tracker.untrack(detail.name)
        else
            Tracker.track(detail.name)
        end
        content.trackButton:setText(Tracker.isTracked(detail.name) and tr('Untrack') or tr('Track'))
    end
    content.open.onClick = function()
        if detail then
            g_game.talk('/dv ' .. detail.number)
        end
    end
end

function DexTab.onShow()
    Pp.send({ action = 'dexlist' })
    if selected and not pendingName then
        select(selected)
    end
end

function DexTab.onGameEnd()
    entries, order, incoming, selected, detail = {}, {}, nil, nil, nil
    complete, wild = 0, 0
    if page then
        page.side.list:destroyChildren()
        page.details.content:hide()
        page.details.empty:show()
    end
end

function DexTab.terminate()
    removeEvent(searchEvent)
    removeEvent(redrawEvent)
end

Pp.registerPage('dex', DexTab)
