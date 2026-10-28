-- Nearby (docs/concepts/side-panel): the Battle List as a Pokegear window. The filters are the Battle
-- List's own checkboxes, so both layouts share them, and a click on a row does what a click on a
-- Battle List row does. Ctrl+B (the Battle List's key) opens and closes it.
Nearby = {}

local POSITION_SETTING = 'pokegearNearbyPosition'
local HIDDEN_SETTING = 'pokegearNearbyHidden'
local SORT_SETTING = 'pokegearNearbySort'
local MAX_ROWS = 8
local ROW_HEIGHT, ROW_SPACING = 38, 4
-- the portraits are 96x96 with the Pokemon in the middle
local PORTRAIT_INSET = 18
local CHROME_HEIGHT = 8 + 24 + 6 + 20 + 6 + 20 + 8 + 10

local FILTERS = {
    { id = 'hideMonsters', text = 'Wild', color = '#5fd36a' },
    { id = 'hidePlayers', text = 'Trainers', color = '#5aa0ff' },
    { id = 'hideNPCs', text = 'NPCs', color = '#42e0c4' },
    { id = 'hideParty', text = 'Party', color = '#ffcb05' },
}
-- the radar's colours (game_radar)
local TYPE_COLORS = {
    normal = '#a8a878', fight = '#c03028', flying = '#a890f0', poison = '#a040a0', ground = '#e0c068',
    rock = '#b8a038', bug = '#a8b820', ghost = '#705898', steel = '#b8b8d0', fire = '#f08030',
    water = '#6890f0', grass = '#78c850', electric = '#f8c830', psychic = '#f85888', ice = '#98d8d8',
    dragon = '#7038f8', dark = '#705848', fairy = '#ee99ac'
}
local SORTS = {
    { id = 'distance', text = 'Distance' },
    { id = 'health', text = 'HP' },
    { id = 'name', text = 'Name' },
    { id = 'level', text = 'Level' },
}

local window, rows, filterPills, sortPills = nil, {}, {}, {}
local refreshEvent, restorePosition
local shown = false
local battleWasVisible

local function battle()
    return modules.game_battle
end

local function battleWindow()
    local module = battle()
    return module and module.getBattleWindow and module.getBattleWindow()
end

local function filterBox(id)
    local panel = battleWindow()
    return panel and panel:recursiveGetChildById(id)
end

-- "Pidgey [12]" is a level 12 Pidgey; trainers and NPCs have no level
local function splitName(creature)
    local name = creature:getName()
    local base, level = name:match('^(.-) %[(%d+)%]$')
    if base then
        return base, tonumber(level)
    end
    return name, nil
end

local function portraitOf(name)
    local number = getPokemonNumberByName(name) or getPokemonNumberByName((name:gsub('^Shiny ', '')))
    return number and ('/images/staticPortraits/' .. number) or nil
end

local function initials(name)
    local letters = {}
    for word in name:gmatch('%S+') do
        letters[#letters + 1] = word:sub(1, 1):upper()
        if #letters == 2 then
            break
        end
    end
    if #letters == 1 then
        letters[2] = name:sub(2, 2):upper()
    end
    return table.concat(letters)
end

local function hpColor(percent)
    if percent > 50 then
        return '#5fd36a'
    elseif percent > 20 then
        return '#f2c84b'
    end
    return '#e5534b'
end

local function sortType()
    local saved = g_settings.getString(SORT_SETTING)
    for _, sort in ipairs(SORTS) do
        if sort.id == saved then
            return saved
        end
    end
    return 'distance'
end

local function distanceTo(creature, from)
    local pos = creature:getPosition()
    return math.max(math.abs(pos.x - from.x), math.abs(pos.y - from.y))
end

local function sortCreatures(list, from)
    local by = sortType()
    table.sort(list, function(a, b)
        local nameA, levelA = splitName(a)
        local nameB, levelB = splitName(b)
        if by == 'health' and a:getHealthPercent() ~= b:getHealthPercent() then
            return a:getHealthPercent() < b:getHealthPercent()
        elseif by == 'level' and (levelA or 0) ~= (levelB or 0) then
            return (levelA or 0) > (levelB or 0)
        elseif by == 'name' and nameA ~= nameB then
            return nameA < nameB
        end
        local distA, distB = distanceTo(a, from), distanceTo(b, from)
        if distA ~= distB then
            return distA < distB
        end
        return a:getId() < b:getId()
    end)
end

-- everyone the Battle List could show, and those its filters let through
local function collect()
    local player = g_game.getLocalPlayer()
    local from = player and player:getPosition()
    local module = battle()
    if not from or not module then
        return {}, 0
    end
    local total, list = 0, {}
    for _, creature in ipairs(getCreaturesAroundPlayer(false)) do
        if not creature:isLocalPlayer() and not creature:isDead() and not creature:isLocalPlayerSummon()
            and creature:getPosition() and creature:getPosition().z == from.z and module.canBeSeen(creature) then
            total = total + 1
            if module.doCreatureFitFilters(creature) then
                list[#list + 1] = creature
            end
        end
    end
    sortCreatures(list, from)
    return list, total
end

-- a dot per type after the level; the Pokepedia asks the server for a species' types once
local function fillTypes(row, name)
    local pokepedia = modules.game_pokepedia
    local types = name and pokepedia and pokepedia.getSpeciesTypes
        and pokepedia.getSpeciesTypes((name:gsub('^Shiny ', ''))) or {}
    local key = table.concat(types, ',')
    if row.typesKey == key then
        return
    end
    row.typesKey = key
    row.types:destroyChildren()
    for _, kind in ipairs(types) do
        local dot = g_ui.createWidget('PokegearTypeDot', row.types)
        dot:setImageColor(TYPE_COLORS[kind] or '#8899aa')
    end
    row.types:setWidth(#types > 0 and (#types * 11 - 3) or 0)
    row.types:setMarginLeft(#types > 0 and 6 or 0)
end

local function fillRow(row, creature)
    local name, level = splitName(creature)
    row.creature = creature
    row.isTarget = creature == g_game.getAttackingCreature()
    row:setOn(row.isTarget)
    row.name:setText(name)
    row.level:setText(level and (tr('Lv') .. ' ' .. level) or '')
    local tag = creature:isNpc() and tr('NPC') or (creature:isPlayer() and tr('TRAINER') or '')
    row.tag:setText(tag)
    row.tag:setVisible(tag ~= '')
    fillTypes(row, creature:isMonster() and name)
    local portrait = creature:isMonster() and portraitOf(name)
    row.face.portrait:setVisible(portrait ~= nil and portrait ~= false)
    if portrait then
        row.face.portrait:setImageSource(portrait)
        row.face.portrait:setImageClip({ x = PORTRAIT_INSET, y = PORTRAIT_INSET,
            width = 96 - 2 * PORTRAIT_INSET, height = 96 - 2 * PORTRAIT_INSET })
    end
    local outfit = not portrait and not creature:isMonster()
    row.face.outfit:setVisible(outfit)
    if outfit then
        row.face.outfit:setOutfit(creature:getOutfit())
    end
    row.face.initials:setText((portrait or outfit) and '' or initials(name))
    local percent = creature:getHealthPercent()
    row.bar.fill:setWidth(math.max(0, math.floor((row.bar:getWidth()) * percent / 100)))
    row.bar.fill:setVisible(percent > 0)
    row.bar.fill:setImageColor(hpColor(percent))
end

local function rowFor(index)
    local row = rows[index]
    if not row then
        row = g_ui.createWidget('PokegearNearbyRow', window.list)
        row.onMousePress = function(_, _, button)
            return button == MouseRightButton or button == MouseLeftButton
        end
        row.onMouseRelease = function(widget, mousePos, button)
            local module = battle()
            if widget.creature and module and module.onNearbyRowRelease then
                local handled = module.onNearbyRowRelease(widget, mousePos, button)
                scheduleEvent(function() if window then Nearby.refresh() end end, 50)
                return handled
            end
            return false
        end
        rows[index] = row
    end
    return row
end

local function refreshPills()
    for _, filter in ipairs(FILTERS) do
        local box = filterBox(filter.id)
        local on = not (box and box:isChecked())
        filterPills[filter.id]:setOn(on)
        -- the text centres across the whole pill, padding or not, and a state change resets the offset
        filterPills[filter.id]:setTextOffset({ x = 6, y = 2 })
        filterPills[filter.id].dot:setOpacity(on and 1 or 0.4)
    end
    local by = sortType()
    for _, sort in ipairs(SORTS) do
        sortPills[sort.id]:setOn(sort.id == by)
    end
    local key = Pokegear.boundKey({ 'Windows', 'Show/hide battle list' })
    window.header.keyChip:setText(key)
    window.header.keyChip:setVisible(key ~= '')
end

function Nearby.refresh()
    if not window or not window:isVisible() then
        return
    end
    local list, total = collect()
    local count = math.min(#list, MAX_ROWS)
    for i = 1, count do
        local row = rowFor(i)
        row:show()
        fillRow(row, list[i])
    end
    for i = count + 1, #rows do
        rows[i]:hide()
        rows[i].creature = nil
    end
    window.empty:setVisible(count == 0)
    window.header.count:setText(tr('%d of %d', #list, total))
    window.list:setHeight(count > 0 and (count * (ROW_HEIGHT + ROW_SPACING) - ROW_SPACING) or 18)
    window:setHeight(CHROME_HEIGHT + window.list:getHeight())
    refreshPills()
end

local function build()
    window = g_ui.createWidget('PokegearNearby', modules.game_interface.getRootPanel())
    window:hide()
    for _, filter in ipairs(FILTERS) do
        local pill = g_ui.createWidget('PokegearPill', window.filters)
        pill:setPaddingLeft(21)
        pill:setText(tr(filter.text))
        pill.dot = g_ui.createWidget('PokegearTypeDot', pill)
        pill.dot:setSize({ width = 7, height = 7 })
        pill.dot:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        pill.dot:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
        pill.dot:setMarginLeft(-12)
        pill.dot:setImageColor(filter.color)
        pill.onClick = function()
            local box = filterBox(filter.id)
            if box then
                battle().onFilterButtonClick(box)
            end
            Nearby.refresh()
        end
        filterPills[filter.id] = pill
    end
    for _, sort in ipairs(SORTS) do
        local pill = g_ui.createWidget('PokegearPill', window.sorts)
        pill:setText(tr(sort.text))
        pill.onClick = function()
            g_settings.set(SORT_SETTING, sort.id)
            Nearby.refresh()
        end
        sortPills[sort.id] = pill
    end
    restorePosition = Pokegear.makeMovable(window, window.header, POSITION_SETTING, function()
        -- centred under the ring
        window:addAnchor(AnchorTop, 'pokegearHub', AnchorBottom)
        window:addAnchor(AnchorRight, 'pokegearHub', AnchorRight)
        window:setMarginTop(2)
        window:setMarginRight(25)
    end)
end

local function onAttackingCreatureChange()
    Nearby.refresh()
end

local function openWindow()
    if not window then
        build()
    end
    restorePosition()
    window:show()
    window:raise()
    Nearby.refresh()
    if not refreshEvent then
        refreshEvent = cycleEvent(Nearby.refresh, 250)
    end
end

local function closeWindow()
    if refreshEvent then
        removeEvent(refreshEvent)
        refreshEvent = nil
    end
    if window then
        window:hide()
    end
end

-- the Battle List window waits hidden while Pokegear is on, and comes back as it was
local function hideBattleWindow(hide)
    local panel = battleWindow()
    if not panel then
        return
    end
    if hide then
        if battleWasVisible == nil then
            battleWasVisible = panel:isVisible()
        end
        panel:hide()
    elseif battleWasVisible ~= nil then
        panel:setVisible(battleWasVisible)
        battleWasVisible = nil
    end
end


function Nearby.apply(active)
    shown = active and g_game.isOnline()
    if shown then
        hideBattleWindow(true)
        connect(g_game, { onAttackingCreatureChange = onAttackingCreatureChange })
        if g_settings.getBoolean(HIDDEN_SETTING) then
            closeWindow()
        else
            openWindow()
        end
    else
        disconnect(g_game, { onAttackingCreatureChange = onAttackingCreatureChange })
        closeWindow()
        hideBattleWindow(false)
    end
end

function Nearby.toggle()
    if not shown then
        return
    end
    local open = window ~= nil and window:isVisible()
    g_settings.set(HIDDEN_SETTING, open)
    if open then
        closeWindow()
    else
        openWindow()
    end
    Pokegear.layoutColumn()
end

-- its own spot is under the ring, so it only counts while the ring is in its spot too
function Nearby.docked()
    return Hub.docked() and Pokegear.isDocked(window, POSITION_SETTING) and window or nil
end

function Nearby.terminate()
    Nearby.apply(false)
    if window then
        window:destroy()
        window = nil
    end
    rows, filterPills, sortPills = {}, {}, {}
end
