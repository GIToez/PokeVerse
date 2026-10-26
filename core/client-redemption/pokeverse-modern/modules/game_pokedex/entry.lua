-- The Details tab in sections: name and types, the description, the evolution chain, the order
-- abilities (each opens its Pokepedia guide page), breeding, egg moves, your Pokemon and its stats.
-- Built from the entry the server sends as JSON just before the Pokedex entry (getDexDetails in
-- 010-pokedex.lua). It scrolls inside the same screen as the old plain text, which stays for "???".
local entryInit = onInit
local entryTerminate = onTerminate

-- what each order ability needs, and its page in the Pokepedia guide (wiki_data.lua)
local ABILITIES = {
    ['Ride'] = { page = 'ride', how = 'Order on yourself to get on, and again to get off.' },
    ['Fly'] = { page = 'fly', premium = true, how = 'Order on yourself to take off; /up and /down change floors.' },
    ['Levitate'] = { page = 'fly', premium = true, how = 'Order on yourself, then /up and /down change floors.' },
    ['Surf'] = { page = 'surf', premium = true, how = 'Order on the edge of the water to surf, and on the shore to land.' },
    ['Dive'] = { page = 'dive', premium = true, how = 'Surf onto a whirlpool with an oxygen mask in the key item slot.' },
    ['Teleport'] = { page = 'teleport', premium = true, how = 'With it out, say /teleport and pick where to go.' },
    ['Dig'] = { page = 'dig', how = 'Order on a pile of small stones to open a hole.' },
    ['Cut'] = { page = 'cut', how = 'Order on a small bush to cut it.' },
    ['Rock Smash'] = { page = 'rocksmash', how = 'Order on a round stone to break it. It comes back after a minute.' },
    ['Headbutt'] = { page = 'headbutt', how = 'Order on a nest tree. Wait 10 seconds between headbutts.' },
    ['Flash'] = { page = 'flash', how = 'Order on your Pokemon to switch its light on or off.' },
    ['Find'] = { page = 'find', how = "Say /find and a trainer's name to learn which way they are." },
    ['Transform'] = { page = 'transform', how = 'Order on a Pokemon to copy it. 20 minutes between transforms.' },
    ['Strength'] = { page = 'strength', premium = true, how = 'Order on a heavy boulder to push it one tile.' },
    ['Waterfall'] = { page = 'waterfall', premium = true, how = 'While surfing, order on a waterfall next to you to ride it.' },
    ['Rock Climb'] = { page = 'rockclimb', premium = true, how = 'Order on a rock wall with handholds to climb it.' },
    ['Blink'] = { page = 'blink', how = 'Order on a tile your Pokemon can see to teleport it there.' },
}

local STAT_COLORS = { '#e86a6a', '#f0a050', '#f2c14e', '#6f9cf0', '#7ad08a', '#f07ab0' }
local RAISED, LOWERED = '#6fdc8c', '#ff7a7a'

local panel, scroll, plainText, plainScroll
local entries = {} -- dex number -> the last entry the server sent for it

-- the row is as tall as its name and the wrapped line under it
local function fitAbility(row)
    local function fit()
        if not row:isDestroyed() then
            row:setHeight(row.name:getMarginTop() + row.name:getHeight() + row.how:getMarginTop() + row.how:getHeight() + 5)
        end
    end
    -- the label wraps after its own geometry callback, so measure on the next frame
    row.how.onGeometryChange = function()
        addEvent(fit)
    end
    fit()
end

local function showPlain()
    if panel then
        panel:hide()
        scroll:hide()
    end
    if plainText then
        plainText:show()
        plainScroll:show()
    end
end

local function showEntry()
    plainText:hide()
    plainScroll:hide()
    panel:show()
    scroll:show()
end

local function add(style, text)
    local widget = g_ui.createWidget(style, panel)
    if text then
        widget:setText(text)
    end
    return widget
end

local function heading(text, hint)
    local widget = add('DexHeading', text)
    widget.hint:setText(hint or '')
    return widget
end

local function pair(key, value)
    local row = add('DexPair')
    row.key:setText(key)
    row.value:setText(value)
    row.value.onGeometryChange = function()
        row:setHeight(math.max(16, row.value:getHeight()))
    end
    row:setHeight(16)
    return row
end

local function meter(label, value, max, note, color)
    local row = add('DexMeter')
    row.label:setText(label)
    row.note:setText(note or '')
    row.track.fill:setBackgroundColor(color or '#6fb4ff')
    local fraction = max > 0 and math.min(1, value / max) or 0
    row.track.onGeometryChange = function()
        row.track.fill:setWidth(math.floor(row.track:getWidth() * fraction))
    end
    row.track.fill:setWidth(0)
    return row
end

local function stripDot(text)
    return (tostring(text or ''):gsub('%.%s*$', ''))
end

-- what still has to be defeated or caught; the server leaves locked sections out of the entry
local function lockedText(entry, level)
    local knowledge = entry.knowledge
    if knowledge and math.max(0, knowledge.level or 0) == level - 1 then
        local more = math.max(1, (knowledge.next or 0) - (knowledge.points or 0))
        if level == 1 then
            return tr('??? Catch one, or defeat %d more, to learn it', more)
        end
        return tr('??? Defeat or catch %d more to learn it', more)
    end
    return tr('??? Learned at Pokedex knowledge level %d', level)
end

local function hiddenLine(entry, level)
    add('DexMuted', lockedText(entry, level))
end

local function joined(list)
    if not list or #list == 0 then
        return tr('None')
    end
    return table.concat(list, ', ')
end

local function drawHero(entry)
    local hero = add('DexHero')
    local name = g_ui.createWidget('DexHeroName', hero)
    name:setText(entry.name or '?')
    local number = g_ui.createWidget('DexHeroNumber', hero)
    number:setText(string.format('#%03d', tonumber(entry.number) or 0))
    for _, typeId in ipairs(entry.types or {}) do
        local badge = g_ui.createWidget('DexTypeBadge', hero)
        badge:setImageSource('/images/types/square/' .. typeId)
        badge:setTooltip(getTypeNameById(typeId))
    end

    local wild = entry.wild
    if wild then
        local level = wild.minLevel == wild.maxLevel and tostring(wild.minLevel) or
            string.format('%d - %d', wild.minLevel or 0, wild.maxLevel or 0)
        add('DexMuted', tr('Wild level %s  -  Caught %d', level, wild.caught or 0))
        if wild.wasted and wild.wasted ~= '' then
            add('DexMuted', wild.wasted .. ' ' .. tr('currently.'))
        end
    end
    if entry.description and entry.description ~= '' then
        add('DexQuote', entry.description)
    end
end

local function drawEvolution(entry)
    heading(tr('Evolution'))
    local steps = entry.evolutions or {}
    if #steps == 0 then
        add('DexMuted', tr("It doesn't evolve."))
        return
    end
    -- one chain when every species has at most one evolution (Gastly, Haunter, Gengar)
    local nextOf, linear, first = {}, true, steps[1].from
    local hasPrior = {}
    for _, step in ipairs(steps) do
        if nextOf[step.from] then
            linear = false
        end
        nextOf[step.from] = step
        hasPrior[step.to] = true
    end
    for _, step in ipairs(steps) do
        if not hasPrior[step.from] then
            first = step.from
        end
    end
    local function condition(step)
        local parts = { tr('Lv %d', step.level or 0) }
        if step.time then
            parts[#parts + 1] = step.time
        end
        for _, item in ipairs(step.items or {}) do
            parts[#parts + 1] = item
        end
        return table.concat(parts, ', ')
    end
    local function chip(parent, name)
        local widget = g_ui.createWidget(name == entry.name and 'DexChipCurrent' or 'DexChip', parent)
        widget:setText(name)
        return widget
    end

    if linear and #steps <= 3 then
        local chain = add('DexChain')
        local name, guard = first, 0
        chip(chain, name)
        while nextOf[name] and guard < 5 do
            local step = nextOf[name]
            local arrow = g_ui.createWidget('DexChainStep', chain)
            arrow:setText(condition(step) .. ' >')
            chip(chain, step.to)
            name, guard = step.to, guard + 1
        end
        -- an item or a time of day makes the chain too long for one line
        local width = 0
        for _, child in ipairs(chain:getChildren()) do
            width = width + child:getWidth() + 4
        end
        if width <= panel:getPaddingRect().width then
            return
        end
        chain:destroy()
    end
    for _, step in ipairs(steps) do
        local row = add('DexChain')
        chip(row, step.from)
        g_ui.createWidget('DexChainStep', row):setText('>')
        chip(row, step.to)
        g_ui.createWidget('DexChainStep', row):setText(condition(step))
    end
end

-- the family's Mega and Primal forms (no entry of their own): which stone, typing, ability and stats
local function drawMegas(entry)
    local megas = entry.megas or {}
    if #megas == 0 then
        return
    end
    local allPrimal = true
    for _, mega in ipairs(megas) do
        allPrimal = allPrimal and mega.primal == true
    end
    heading(allPrimal and tr('Primal Reversion') or tr('Mega Evolution'), tr('needs the Mega Ring'))
    local STATS = { { 'atk', tr('Attack') }, { 'def', tr('Defense') }, { 'spAtk', tr('Sp. Atk') }, { 'spDef', tr('Sp. Def') } }
    for _, mega in ipairs(megas) do
        local row = add('DexChain')
        local from = g_ui.createWidget(mega.from == entry.name and 'DexChipCurrent' or 'DexChip', row)
        from:setText(mega.from)
        g_ui.createWidget('DexChainStep', row):setText(tr('holding %s >', mega.stone))
        g_ui.createWidget('DexChipCurrent', row):setText(mega.to)
        for _, typeId in ipairs(mega.types or {}) do
            local badge = g_ui.createWidget('DexTypeBadge', row)
            badge:setMarginTop(2)
            badge:setImageSource('/images/types/square/' .. typeId)
            badge:setTooltip(getTypeNameById(typeId))
        end

        local changes = {}
        for _, stat in ipairs(STATS) do
            local value = mega.stats and tonumber(mega.stats[stat[1]]) or 0
            local before = mega.baseStats and tonumber(mega.baseStats[stat[1]]) or value
            changes[#changes + 1] = value ~= before and string.format('%s %d (%+d)', stat[2], value, value - before)
                or string.format('%s %d', stat[2], value)
        end
        add('DexMuted', (mega.ability and (tr('Ability: %s', mega.ability) .. '  -  ') or '') .. table.concat(changes, ', '))
    end
end

local function drawAbilities(entry)
    heading(tr('Order abilities'), entry.abilities and #entry.abilities > 0 and tr('click to open the Pokepedia') or nil)
    if not entry.abilities then
        hiddenLine(entry, 1)
        return
    end
    if #entry.abilities == 0 then
        add('DexMuted', tr('None'))
        return
    end
    for _, name in ipairs(entry.abilities) do
        local info = ABILITIES[name] or {}
        local row = add('DexAbility')
        row.name:setText(tr(name))
        row.premium:setVisible(info.premium == true)
        row.how:setText(tr(info.how or 'Give it an order to use it.'))
        row.open:setText('')
        fitAbility(row)
        if info.page and modules.game_pokepedia then
            row:setTooltip(tr('Open %s in the Pokepedia', tr(name)))
            row.onHoverChange = function(widget, hovered)
                widget.open:setText(hovered and tr('Pokepedia >') or '')
            end
            row.onClick = function()
                modules.game_pokepedia.openWiki(info.page)
            end
        end
    end
end

local function drawBreeding(entry)
    heading(tr('Breeding'))
    if not entry.eggGroups then
        hiddenLine(entry, 1)
        heading(tr('Egg moves'))
        hiddenLine(entry, 1)
        return
    end
    pair(tr('Egg groups'), joined(entry.eggGroups))
    if entry.specialAbility then
        pair(tr('Special ability'), (tostring(entry.specialAbility):gsub('\n', ' ')))
    else
        pair(tr('Special abilities'), joined(entry.specialAbilities))
    end
    pair(tr('EV yield'), entry.evYield or lockedText(entry, 2))

    heading(tr('Egg moves'))
    if not entry.eggMoves or #entry.eggMoves == 0 then
        add('DexMuted', tr('None'))
        return
    end
    local grid = add('DexMoveGrid')
    for _, move in ipairs(entry.eggMoves) do
        local cell = g_ui.createWidget('DexMove', grid)
        cell.type:setImageSource('/images/types/square/' .. tostring(move.type))
        cell.name:setText(move.name)
        cell:setTooltip(getMoveDescriptionByName(move.name))
    end
end

local function drawOwn(entry)
    local own, sheet = entry.own, entry.sheet
    if not own and not sheet and not entry.vitamins then
        return
    end
    heading(sheet and tr('Your %s', sheet.name or entry.name) or tr('Your Pokemon'))
    if own then
        pair(tr('Level'), tostring(own.level))
    end
    if own and own.maxHealth then
        meter(tr('Health'), own.health or 0, own.maxHealth or 0, string.format('%d / %d', own.health or 0,
            own.maxHealth or 0), '#6fdc8c')
        meter(tr('Energy'), own.energy or 0, own.maxEnergy or 0, string.format('%d / %d', own.energy or 0,
            own.maxEnergy or 0), '#6fb4ff')
        pair(tr('To next level'), tr('%d experience', own.toNextLevel or 0))
    end
    if sheet then
        local nature = sheet.nature or {}
        local names = sheet.statNames or {}
        local natureText = nature.name or '?'
        if nature.up and nature.down and nature.up ~= nature.down and nature.up > 0 then
            natureText = string.format('%s  (+%s, -%s)', natureText, names[nature.up] or '?', names[nature.down] or '?')
        end
        pair(tr('Nature'), natureText)
    end
    if entry.held then
        pair(tr('Held item'), stripDot(entry.held))
    end
    if entry.vitamins then
        pair(tr('Vitamins'), stripDot(entry.vitamins))
    end
    if entry.transformMemory then
        pair(tr('Transform memory'), stripDot(entry.transformMemory))
    end
    if not sheet then
        return
    end
    local ivMax = (sheet.ivMax or 31) * 6
    meter(tr('IVs %d / %d', sheet.ivTotal or 0, ivMax), sheet.ivTotal or 0, ivMax,
        tr('%d perfect', sheet.perfectIvs or 0), '#6fb4ff')
    meter(tr('EVs %d / %d', sheet.evTotal or 0, sheet.evTotalMax or 510), sheet.evTotal or 0,
        sheet.evTotalMax or 510, (sheet.evTotal or 0) == 0 and tr('untrained') or '', '#f2c14e')

    heading(tr('Stats'))
    local head = add('DexStatHead')
    head.name:setText(tr('Stat'))
    head.value:setText(tr('Value'))
    head.iv:setText(tr('IV'))
    head.ev:setText(tr('EV'))
    head.effect:setText(tr('Effect'))
    for _, cell in ipairs({ head.name, head.value, head.iv, head.ev, head.effect }) do
        cell:setColor('#6f7a93')
    end
    head.track:hide()
    local highest = 1
    for stat = 1, 6 do
        highest = math.max(highest, (sheet.actual or {})[stat] or 0)
    end
    for stat = 1, 6 do
        local row = add('DexStatRow')
        local actual = (sheet.actual or {})[stat] or 0
        local effect = (sheet.effect or {})[stat] or 0
        row.name:setText((sheet.statNames or {})[stat] or '')
        row.value:setText(tostring(actual))
        row.iv:setText(tostring((sheet.ivs or {})[stat] or 0))
        row.ev:setText(tostring((sheet.evs or {})[stat] or 0))
        row.effect:setText(string.format('%s%d%%', effect >= 0 and '+' or '', effect))
        row.effect:setColor(effect > 0 and RAISED or effect < 0 and LOWERED or '#aeb7cc')
        row.track.fill:setBackgroundColor(STAT_COLORS[stat])
        local fraction = actual / (highest * 1.1)
        row.track.onGeometryChange = function()
            row.track.fill:setWidth(math.floor(row.track:getWidth() * fraction))
        end
        row.track.fill:setWidth(0)
    end
end

local function drawKnowledge(entry)
    local knowledge = entry.knowledge
    if not knowledge then
        return
    end
    heading(tr('Pokedex knowledge'))
    local level = math.max(0, knowledge.level or 0)
    if level >= 3 then
        meter(tr('Complete'), 1, 1, tr('%d defeats and catches', knowledge.points or 0), '#f2c14e')
    else
        meter(tr('Level %d of 3', level), knowledge.points or 0, math.max(1, knowledge.next or 1),
            tr('%d / %d to the next', knowledge.points or 0, knowledge.next or 0), '#f2c14e')
    end
end

local function draw(entry)
    panel:destroyChildren()
    drawHero(entry)
    drawEvolution(entry)
    drawMegas(entry)
    drawAbilities(entry)
    drawBreeding(entry)
    drawOwn(entry)
    drawKnowledge(entry)
    scroll:setValue(0)
    showEntry()
end

local shownNumber

-- the extended opcode with the JSON is handled after the Pokedex entry packet, so whichever of the
-- two comes second draws (an older entry for the species is shown until the new one lands)
local function onInfo(pokemonId)
    shownNumber = tonumber(pokemonId)
    local entry = entries[shownNumber]
    if entry and panel then
        draw(entry)
    else
        showPlain()
    end
end

local function onDetails(protocol, opcode, buffer)
    local ok, entry = pcall(json.decode, buffer)
    if not ok or type(entry) ~= 'table' or not tonumber(entry.number) then
        g_logger.warning('Pokedex: invalid Details entry')
        return
    end
    local number = tonumber(entry.number)
    entries[number] = entry
    if number == shownNumber and panel and pokedexWindow and pokedexWindow:isVisible() then
        draw(entry)
    end
end

local function createPanel()
    plainText = pokedexWindow and pokedexWindow:recursiveGetChildById('aaaText')
    if not plainText then
        return
    end
    plainScroll = plainText:getParent():getChildById('aaaTextScroll')
    local parent = plainText:getParent()
    scroll = g_ui.createWidget('DexDetailsScroll', parent)
    scroll:setId('dexEntryScroll')
    scroll:addAnchor(AnchorTop, 'parent', AnchorTop)
    scroll:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    scroll:addAnchor(AnchorRight, 'parent', AnchorRight)
    panel = g_ui.createWidget('DexDetailsPanel', parent)
    panel:setId('dexEntry')
    panel:addAnchor(AnchorTop, 'parent', AnchorTop)
    panel:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    panel:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    panel:addAnchor(AnchorRight, 'dexEntryScroll', AnchorLeft)
    panel:setVerticalScrollBar(scroll)
    showPlain()
end

local legacyUnknown = onPokedexInfoUnknown

function onPokedexInfoUnknown()
    legacyUnknown()
    shownNumber = nil
    showPlain()
end

local function clear()
    entries = {}
    shownNumber = nil
end

function onInit()
    entryInit()
    g_ui.importStyle('entry')
    createPanel()
    connect(g_game, { onPokedexInfo = onInfo, onGameEnd = clear })
    ProtocolGame.registerExtendedOpcode(ExtendedIds.PokedexDetails, onDetails)
end

function onTerminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.PokedexDetails)
    disconnect(g_game, { onPokedexInfo = onInfo, onGameEnd = clear })
    if panel then
        panel:destroy()
        scroll:destroy()
        panel, scroll = nil, nil
    end
    plainText, plainScroll = nil, nil
    entries = {}
    entryTerminate()
end
