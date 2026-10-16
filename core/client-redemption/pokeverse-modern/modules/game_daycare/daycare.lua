-- The Day Care window. The Old Man and the Old Lady open it (Daycare.open in the server lib); the server talks
-- JSON on ExtendedIds.Daycare: {type = "daycare", slots, egg, candidates, plates, plate, events, rules} fills the
-- window and {type = "result", ok, text} answers an action. The window sends {action = "hello"} at login (so the
-- keepers know to open it instead of talking) and the actions: refresh, deposit, withdraw, cancel, collect, plate.
--
-- Two places hold any two Pokemon. A line runs from each down to the egg slot in the Pokemon's color: blue for
-- males, pink for females, lilac for a Ditto or a genderless Pokemon.
local IMAGES = '/modules/game_daycare/images/'
local PORTRAITS = '/images/staticPortraits/'
local ICONS = '/modules/game_vocation/images/'
local SEX_ICONS = {
    male = '/modules/game_trainercard/images/sex_male_big',
    female = '/modules/game_trainercard/images/sex_female_big'
}
local SMALL_SEX_ICONS = {
    male = '/modules/game_trainercard/images/sex_male',
    female = '/modules/game_trainercard/images/sex_female'
}
local GENDERLESS_ICON = '/modules/client_entergame/images/icon_gender'
local COLORS = { male = '#60aaff', female = '#ff78b4', neutral = '#baa0e6', empty = '#3a4c6e' }
local OK_COLOR = '#7ee08f'
local BAD_COLOR = '#ff8a8a'
local GOLD_COLOR = '#ffd75a'
local MUTED_COLOR = '#96aacd'

local window
local state -- the last {type = "daycare"} message
local minutes -- the training time picked for the next Pokemon

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Daycare, data)
    end
end

local function duration(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local days, hours, mins = math.floor(seconds / 86400), math.floor(seconds % 86400 / 3600), math.floor(seconds % 3600 / 60)
    if days > 0 then
        return hours > 0 and tr('%dd %dh', days, hours) or tr('%dd', days)
    elseif hours > 0 then
        return mins > 0 and tr('%dh %dm', hours, mins) or tr('%dh', hours)
    end
    return tr('%dm', mins)
end

local function thousands(n)
    local text = tostring(math.floor(tonumber(n) or 0))
    return (text:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', ''))
end

local function multiplier(m)
    return (string.format('%.2f', m):gsub('0+$', ''):gsub('%.$', '')) .. 'x'
end

-- the portraits are 96x96 with the Pokemon in the middle; inset trims the empty border
local function setPortrait(widget, number, inset)
    widget:setImageSource(PORTRAITS .. (tonumber(number) or 0))
    widget:setImageClip({ x = inset, y = inset, width = 96 - 2 * inset, height = 96 - 2 * inset })
end

local function colorKey(info)
    if not info or info.empty then
        return 'empty'
    end
    return (not info.ditto and info.sex) or 'neutral'
end

local function setSexIcon(widget, info, icons)
    if info.sex and not info.ditto then
        widget:setImageSource(icons[info.sex])
        widget:setImageColor('#ffffff')
    else
        widget:setImageSource(GENDERLESS_ICON)
        widget:setImageColor(COLORS.neutral)
    end
    widget:setTooltip(info.ditto and tr('Ditto: makes eggs with any Pokemon that can breed') or
        (info.sex == 'male' and tr('Male')) or (info.sex == 'female' and tr('Female')) or tr('Genderless'))
end

-- Slots -------------------------------------------------------------------------------------------------

local CARD_ONLY = { 'frame', 'portrait', 'name', 'sex', 'level', 'stats', 'heldItem', 'heldName', 'training', 'track',
                    'exp', 'withdraw', 'cancel' }

local function fillSlot(card, info)
    local empty = info.empty == true
    for _, id in ipairs(CARD_ONLY) do
        card[id]:setVisible(not empty)
    end
    card.emptyTitle:setVisible(empty)
    card.emptyText:setVisible(empty)
    card:setImageSource(IMAGES .. 'card_' .. colorKey(info))
    if empty then
        return
    end

    setPortrait(card.portrait, info.number, 14)
    card.name:setText(info.nickname or info.name)
    card.name:setTooltip(info.nickname and info.name or '')
    setSexIcon(card.sex, info, SEX_ICONS)
    if info.levelNow and info.levelNow > info.level then
        card.level:setText(tr('Lv %d  ->  %d', info.level, info.levelNow))
    else
        card.level:setText(tr('Lv %d', info.level))
    end
    if info.ivs then
        card.stats:setText(tr('%s  |  IV %d/%d', info.nature or '?', info.ivs.total, info.ivs.max))
    else
        card.stats:setText(tr('Nature and IVs not checked yet'))
    end

    if info.held then
        card.heldItem:setItemId(tonumber(info.held.client) or 0)
        card.heldItem:setVisible(true)
        card.heldName:setText(info.held.name)
        card.heldName:setColor('#dce6ff')
        card.heldName:setTooltip(info.held.text or '')
        card.heldItem:setTooltip(info.held.text or '')
    else
        card.heldItem:setItemId(0)
        card.heldName:setText(tr('No held item'))
        card.heldName:setColor(MUTED_COLOR)
        card.heldName:setTooltip('')
    end

    local trained, max = tonumber(info.trained) or 0, math.max(1, tonumber(info.max) or 1)
    card.training.icon:setImageSource(ICONS .. 'perk_clock')
    card.training.text:setText(info.done and tr('Training done: %s', duration(max * 60)) or
        tr('Trained %s of %s  (%s left)', duration(trained * 60), duration(max * 60), duration((max - trained) * 60)))
    card.training.text:setColor(info.done and OK_COLOR or '#dce6ff')
    local width = math.floor(card.track:getWidth() * math.min(1, trained / max))
    card.track.fill:setWidth(width)
    card.track.fill:setVisible(width >= 6)

    card.exp.icon:setImageSource(ICONS .. 'perk_exp')
    card.exp.text:setText(tr('+%s EXP  |  fee %s dollars', thousands(info.exp), thousands(info.fee)))

    card.withdraw:setEnabled(info.done == true)
    card.withdraw:setTooltip(info.done and tr('Take %s back with its training (%s dollars).', info.name, thousands(info.fee)) or
        tr('Available when the training is done.'))
    card.cancel:setVisible(not info.done)
    card.withdraw:setVisible(true)
    card.withdraw:breakAnchors()
    card.withdraw:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    card.withdraw:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    if info.done then
        card.withdraw:addAnchor(AnchorRight, 'parent', AnchorRight)
        card.withdraw:setMarginRight(0)
    else
        card.withdraw:addAnchor(AnchorRight, 'parent', AnchorHorizontalCenter)
        card.withdraw:setMarginRight(4)
    end
    card.cancel:setTooltip(tr('Take %s back now, without the training EXP (%s dollars).', info.name, thousands(info.fee)))
end

local function colorLines(slot, info)
    local color = COLORS[colorKey(info)]
    for _, part in ipairs({ 'Down', 'Across', 'In' }) do
        window['line' .. slot .. part]:setBackgroundColor(color)
    end
end

-- Egg -------------------------------------------------------------------------------------------------

local COMPATIBILITY = {
    empty = { bad = false, text = 'Leave two Pokemon here to see if they can make an egg together.' },
    twoDitto = { bad = true, text = 'Two Ditto can\'t make an egg together.' },
    genderless = { bad = true, text = 'A genderless Pokemon only makes eggs with a Ditto.' },
    sameGender = { bad = true, text = 'Two Pokemon of the same gender can\'t make an egg. It takes a female and a male, or one of them with a Ditto.' },
    incompatible = { bad = true, text = 'These two don\'t share an egg group, so they won\'t make an egg.' },
}

local function compatibilityText(egg, slots)
    local entry = COMPATIBILITY[egg.status]
    if entry then
        return tr(entry.text), entry.bad
    elseif egg.status == 'noEggs' then
        return tr('%s can\'t make eggs.', egg.blocked or '?'), true
    end
    local a, b = slots[1], slots[2]
    local parents = tr('%s and %s', a.name, b.name)
    return tr('%s get along very well! Their eggs hatch into %s.', parents, egg.species or '?'), false
end

local function fillEgg(egg, slots)
    local text, bad = compatibilityText(egg, slots)
    local panel = window.compatibility
    panel.title.icon:setImageSource(ICONS .. 'perk_heart')
    panel.title.text:setText(tr('Compatibility'))
    panel.text:setText(text)
    panel.text:setColor(bad and BAD_COLOR or (egg.status == 'empty' and MUTED_COLOR or OK_COLOR))

    local slot = window.egg
    local ready = egg.status == 'ready'
    local hasEgg = (tonumber(egg.client) or 0) > 0
    slot:setImageSource(IMAGES .. (ready and 'egg_slot_ready' or 'egg_slot'))
    slot.item:setItemId(hasEgg and tonumber(egg.client) or 0)
    slot.item:setVisible(hasEgg)
    slot.item:setOpacity(ready and 1 or 0.3)
    slot.unknown:setVisible(not hasEgg)
    slot.count:setText((ready and (egg.count or 1) > 1) and 'x2' or '')
    slot:setTooltip(egg.species and tr('%s egg', egg.species) or '')

    local status = window.eggStatus
    local panelEgg = window.eggPanel
    panelEgg.title.icon:setImageSource(ICONS .. (ready and 'perk_eggs' or 'perk_egg'))
    panelEgg.title.text:setText(tr('Egg'))
    panelEgg.collect:setVisible(ready)
    local lines = {}
    local chance = tr('Chance each day from day %d: %s%%', egg.fromDay or 7, tostring(egg.chance or 0))
    if ready then
        status:setText(tr('Egg ready!'))
        status:setColor(GOLD_COLOR)
        lines[#lines + 1] = (egg.count or 1) > 1 and tr('Two %s eggs are waiting for you!', egg.species) or
            tr('A %s egg is waiting for you!', egg.species)
        if egg.ivs then
            lines[#lines + 1] = tr('%s  |  IV %d/%d', egg.nature or '?', egg.ivs.total, egg.ivs.max)
        end
    elseif egg.status == 'together' then
        status:setText(tr('Getting to know each other'))
        status:setColor(MUTED_COLOR)
        lines[#lines + 1] = tr('Both need to train for 24 hours before they can make an egg: %s more.', duration(egg.left))
        lines[#lines + 1] = chance
    elseif egg.status == 'waiting' then
        status:setText(tr('Day %d of the wait', egg.day or 0))
        status:setColor(MUTED_COLOR)
        lines[#lines + 1] = tr('Eggs can come from day %d of the wait for one: in %s.', egg.fromDay or 7, duration(egg.left))
        lines[#lines + 1] = chance
    elseif egg.status == 'chance' then
        status:setText(tr('Day %d of the wait', egg.day or 0))
        status:setColor(OK_COLOR)
        lines[#lines + 1] = chance
        lines[#lines + 1] = tr('On day %d the egg is certain: in %s.', egg.certainDay or 14, duration(egg.left))
    else
        status:setText(egg.status == 'empty' and tr('Waiting for two Pokemon') or tr('No egg'))
        status:setColor(egg.status == 'empty' and MUTED_COLOR or BAD_COLOR)
        lines[#lines + 1] = tr('From day %d of the wait each day has a chance of an egg; on day %d it is certain.',
            egg.fromDay or 7, egg.certainDay or 14)
    end
    if state.plate then
        lines[#lines + 1] = tr('Your %s guides its move.', state.plate.name)
    end
    panelEgg.text:setText(table.concat(lines, '\n'))
end

-- Leaving a Pokemon -------------------------------------------------------------------------------------

local function depositBlocker()
    local rules = state.rules or {}
    if (rules.level or 0) < (rules.minLevel or 20) then
        return tr('The Day Care is for trainers from level %d.', rules.minLevel or 20)
    elseif not rules.premium then
        return tr('The Day Care is for premium accounts.')
    elseif rules.otherCharacter then
        return tr('Another character of your account is using the Day Care.')
    elseif not state.slots[1].empty and not state.slots[2].empty then
        return tr('Both places are taken.')
    elseif (rules.money or 0) < (rules.fee or 100) then
        return tr('You need %d dollars to leave a Pokemon here.', rules.fee or 100)
    end
    return nil
end

local function refreshTimes()
    local times = window.deposit.times
    for _, child in ipairs(times:getChildren()) do
        child:setOn(child.minutes == minutes)
    end
end

local function fillDeposit()
    local panel = window.deposit
    local rules = state.rules or {}
    panel.title.icon:setImageSource(ICONS .. 'perk_ball')
    panel.title.text:setText(tr('Leave a Pokemon'))
    panel.rules:setText(tr('%d dollars to enter, then 1, 2 or 4 dollars a minute by level. You have %s dollars.',
        rules.fee or 100, thousands(rules.money)))

    local options = rules.options or { 1440, 2880 }
    if not minutes or not table.find(options, minutes) then
        minutes = options[1]
    end
    panel.times:destroyChildren()
    for _, option in ipairs(options) do
        local tab = g_ui.createWidget('DaycareTab', panel.times)
        tab.minutes = option
        tab:setText(tr('%d hours', option / 60))
        tab:setWidth(84)
        tab.onClick = function()
            minutes = option
            refreshTimes()
        end
    end
    refreshTimes()

    local blocker = depositBlocker()
    panel.list:destroyChildren()
    local candidates = state.candidates or {}
    for _, entry in ipairs(candidates) do
        local row = g_ui.createWidget('DaycareCandidate', panel.list)
        setPortrait(row.portrait, entry.number, 14)
        row.name:setText(entry.name)
        setSexIcon(row.sex, { sex = entry.sex, ditto = entry.name == 'Ditto' or entry.name == 'Shiny Ditto' }, SMALL_SEX_ICONS)
        row.details:setText(tr('Lv %d', entry.level) .. '  |  ' .. (entry.held and tr('Holds %s', entry.held) or tr('No held item')))
        row.leave:setEnabled(blocker == nil)
        row.leave:setTooltip(blocker or tr('Leave %s here to train for %d hours.', entry.name, minutes / 60))
        row.leave.onClick = function()
            send({ action = 'deposit', key = entry.key, minutes = minutes })
        end
    end
    panel.none:setVisible(#candidates == 0 or blocker ~= nil)
    panel.list:setVisible(#candidates > 0 and blocker == nil)
    panel.listScroll:setVisible(#candidates > 0 and blocker == nil)
    panel.none:setText(blocker or tr('Carry the Pokemon you want to leave here in your bag.'))
end

local function fillPlates()
    local panel = window.plates
    panel.title.icon:setImageSource(ICONS .. 'perk_star')
    panel.title.text:setText(tr('Plate'))
    panel.list:destroyChildren()
    local plate = state.plate
    panel.current:setVisible(plate ~= nil)
    panel.currentName:setVisible(plate ~= nil)
    panel.takePlate:setVisible(plate ~= nil)
    panel.list:setVisible(plate == nil)
    if plate then
        panel.text:setText(tr('The next egg learns a move of the plate\'s type.'))
        panel.current:setItemId(tonumber(plate.client) or 0)
        panel.currentName:setText(plate.name)
        panel.takePlate.onClick = function() send({ action = 'plate' }) end
        return
    end
    local plates = state.plates or {}
    panel.text:setText(#plates > 0 and tr('Leave a plate here: the next egg learns a move of its type.') or
        tr('Plates in your bag show here. One left here guides the next egg\'s move.'))
    for _, entry in ipairs(plates) do
        local button = g_ui.createWidget('DaycarePlate', panel.list)
        button.item:setItemId(tonumber(entry.client) or 0)
        button:setTooltip(tr('Leave the %s here', entry.name))
        button.onClick = function() send({ action = 'plate', item = entry.item }) end
    end
end

local function fillEvents()
    local box = window.events
    box:destroyChildren()
    local labels = { daycare = 'Training EXP', breeding = 'Egg chance' }
    for _, kind in ipairs({ 'daycare', 'breeding' }) do
        local event = (state.events or {})[kind]
        if event then
            local pill = g_ui.createWidget('DaycareEventPill', box)
            pill:setText(tr('%s %s  |  %s left', multiplier(event.multiplier), tr(labels[kind]), duration(event.left)))
        end
    end
end

-- Window ------------------------------------------------------------------------------------------------

function hide()
    if window then
        window:hide()
    end
end

local function show()
    local root = rootWidget:getSize()
    if not window:isVisible() then
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                             y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
    end
    window:show()
    window:raise()
    window:focus()
end

local function fill(data)
    state = data
    g_tooltip.hide() -- the hovered button may be rebuilt below
    local slots = data.slots or {}
    for slot = 1, 2 do
        slots[slot] = slots[slot] or { empty = true }
    end
    local rules = data.rules or {}
    window.subtitle:setText(tr('The Old Man and the Old Lady train two Pokemon at a time and look after their eggs.') ..
        (rules.premium and '' or ('  ' .. tr('(premium)'))))
    for slot = 1, 2 do
        local card = window['slot' .. slot]
        fillSlot(card, slots[slot])
        colorLines(slot, slots[slot])
        card.withdraw.onClick = function() send({ action = 'withdraw', slot = slot }) end
        card.cancel.onClick = function()
            local info = slots[slot]
            local box
            local function close() if box then box:destroy() box = nil end end
            box = displayGeneralBox(tr('Stop training'),
                tr('Take %s back now? It keeps none of the training EXP and the fee is still %s dollars.', info.name, thousands(info.fee)),
                { { text = tr('Stop training'), callback = function() close() send({ action = 'cancel', slot = slot }) end },
                  { text = tr('Keep training'), callback = close }, anchor = AnchorHorizontalCenter }, close, close)
        end
    end
    fillEgg(data.egg or { status = 'empty' }, slots)
    window.eggPanel.collect.onClick = function() send({ action = 'collect' }) end
    fillDeposit()
    fillPlates()
    fillEvents()
end

local function onDaycare(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Day Care: invalid message')
        return
    end
    if data.type == 'daycare' then
        fill(data)
        show()
    elseif data.type == 'result' and data.text then
        if data.ok then
            modules.game_textmessage.displayGameMessage(data.text)
        else
            modules.game_textmessage.displayFailureMessage(data.text)
        end
    end
end

local function onGameStart()
    send({ action = 'hello' })
end

local function onGameEnd()
    state, minutes = nil, nil
    hide()
end

function init()
    g_ui.importStyle('daycare')
    window = g_ui.createWidget('DaycareWindow', rootWidget)
    window:hide()

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Daycare, onDaycare)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Daycare)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if window then
        window:destroy()
    end
    window = nil
end
