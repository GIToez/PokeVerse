-- Pokemon Center PC: one window with Poke boxes, stash, inbox and depot tabs and a search over all of
-- them. Click the depot locker at a Pokemon Center (standard Tibia containers); this module opens
-- the PC window and talks to the server over ExtendedIds.Pc JSON — no chat commands.
local window
local state = {}
local searchEvent, helloEvent
local drag
local lockerPos

-- server locker ids and the client ids OTClient uses for the same items
local LOCKER_IDS = {
    [2589] = true, [2590] = true, [2591] = true, [2592] = true, [13015] = true,
    [3497] = true, [3498] = true, [3499] = true, [3500] = true,
}

local SEX_NAMES = { [0] = 'Female', [1] = 'Male', [2] = '-' }
local OK_COLOR, ERROR_COLOR = '#8fe08f', '#ff8a80'
local MUTED_COLOR = '#9fb6e0'
local TABS = { boxes = 'boxesPage', stash = 'stashPage', inbox = 'inboxPage', depot = 'depotPage' }
local SORTS = { { id = 'name', name = 'Name' }, { id = 'count', name = 'Amount' }, { id = 'category', name = 'Category' } }
local WHERE_NAMES = { box = 'Poke boxes', stash = 'Stash', inbox = 'Inbox', depot = 'Depot' }

local function sendRequest(data)
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Pc, data)
    end
end

local function send(text)
    local action, rest = text:match('^(%S+)%s*(.*)$')
    if not action then
        return
    end
    action = action:lower()
    local numbers = {}
    for n in rest:gmatch('%d+') do
        numbers[#numbers + 1] = tonumber(n)
    end
    local a, b, c = numbers[1], numbers[2], numbers[3]
    local data = { action = action }
    if action == 'box' then
        data.a = a or 1
    elseif action == 'pokemon' or action == 'withdraw' or action == 'take' or action == 'tobox' then
        data.a = a
    elseif action == 'partymon' then
        data.a = a
        data.name = rest:match('^%d+%s+(.+)$') or ''
    elseif action == 'deposit' then
        data.a, data.b, data.c = a, b, c
        data.name = rest:match('^%d+%s+%d+%s+%d+%s+(.+)$') or ''
    elseif action == 'move' then
        data.a, data.b, data.c = a, b, c
    elseif action == 'rename' then
        data.a = a
        data.name = rest:match('^%d+%s*(.*)$') or ''
    elseif action == 'stow' or action == 'unstow' then
        data.a, data.b = a, b
    elseif action == 'search' then
        data.text = rest
    end
    sendRequest(data)
end

local function isPokemonCenter()
    local loc = modules.game_time and modules.game_time.getLocation and modules.game_time.getLocation() or ''
    return loc:find('Pokemon Center', 1, true) ~= nil
end

local function closeLockerContainers()
    for _, container in pairs(g_game.getContainers()) do
        local item = container:getContainerItem()
        if item and LOCKER_IDS[item:getId()] then
            g_game.close(container)
        end
    end
end

-- the opened container carries no map position; the locker is one of the tiles next to the player
local function findLocker()
    local player = g_game.getLocalPlayer()
    local pos = player and player:getPosition()
    if not pos then
        return nil
    end
    for dx = -1, 1 do
        for dy = -1, 1 do
            local tile = g_map.getTile({ x = pos.x + dx, y = pos.y + dy, z = pos.z })
            if tile then
                for _, thing in ipairs(tile:getItems()) do
                    if LOCKER_IDS[thing:getId()] then
                        return tile:getPosition()
                    end
                end
            end
        end
    end
    return nil
end

local function onContainerOpen(container, previousContainer)
    if previousContainer then
        return
    end
    local item = container:getContainerItem()
    if not item or not LOCKER_IDS[item:getId()] then
        return
    end
    if not isPokemonCenter() then
        return
    end
    lockerPos = findLocker()
    scheduleEvent(function()
        sendRequest({ action = 'open' })
    end, 100)
end

local function formatCount(n)
    n = math.floor(n or 0)
    if n >= 100000 then
        return string.format('%dk', math.floor(n / 1000))
    elseif n >= 10000 then
        return (string.format('%.1fk', n / 1000):gsub('%.0k', 'k'))
    end
    return n > 1 and tostring(n) or ''
end

local function formatDate(time)
    return time and os.date('%b %d, %H:%M', time) or ''
end

local function setStatus(text, ok)
    window.status:setText(text or '')
    window.status:setColor(ok == false and ERROR_COLOR or OK_COLOR)
end

local function pokemonLabel(entry)
    return string.format('%s Lv. %d', entry.name or '?', entry.level or 0)
end

local function setPortrait(widget, number)
    if number then
        widget:setImageSource('/images/staticPortraits/' .. number)
        widget:setImageSmooth(true)
        widget:show()
    else
        widget:hide()
    end
end

-- the Pokemon bar's face (shinies have their own), else the portrait shrunk
local function setFace(face, portrait, pokemon)
    if pokemon.face then
        face:setItemId(pokemon.face)
        face:show()
        portrait:hide()
    else
        face:hide()
        setPortrait(portrait, pokemon.number)
    end
end

local function addEmpty(list, text)
    local label = g_ui.createWidget('GtsCell', list)
    label:setHeight(24)
    label:setText(text)
    label:setColor(MUTED_COLOR)
    label:setTextAlign(AlignCenter)
end

local function addEntry(list, data)
    local entry = g_ui.createWidget('GtsEntry', list)
    if data.number or data.face then
        setFace(entry.item, entry.portrait, data)
    else
        entry.item:setItemId(data.client or 0)
    end
    entry.data = data
    return entry
end

local function confirm(title, text, yes)
    local box
    local function close()
        if box then
            box:destroy()
            box = nil
        end
    end
    box = displayGeneralBox(title, text, {
        { text = tr('Yes'), callback = function() close(); yes() end },
        { text = tr('No'), callback = close },
        anchor = AnchorHorizontalCenter
    }, function() close(); yes() end, close)
end

-- tabs

local function showPage(id)
    for _, page in ipairs({ 'boxesPage', 'stashPage', 'inboxPage', 'depotPage', 'searchPage' }) do
        window.pages[page]:setVisible(page == id)
    end
end

local function setTab(tab)
    state.tab = tab
    window.boxesTab:setOn(tab == 'boxes')
    window.stashTab:setOn(tab == 'stash')
    window.inboxTab:setOn(tab == 'inbox')
    window.depotTab:setOn(tab == 'depot')
    showPage(TABS[tab])
    if tab == 'boxes' then
        send('box ' .. (state.box or 1))
        send('party')
    elseif tab == 'stash' then
        send('stash')
        send('bag')
    elseif tab == 'inbox' then
        send('inbox')
    elseif tab == 'depot' then
        send('depot')
    end
end

local function updateCounts()
    local counts = state.counts or {}
    window.boxesTab:setText(tr('Poke Boxes') .. (counts.pokemon and counts.pokemon > 0 and string.format(' (%d)', counts.pokemon) or ''))
    window.stashTab:setText(tr('Stash') .. (counts.stash and counts.stash > 0 and string.format(' (%d)', counts.stash) or ''))
    window.inboxTab:setText(tr('Inbox'))
    if counts.inbox and counts.inbox > 0 then
        window.inboxBadge:setText(counts.inbox > 99 and '99+' or tostring(counts.inbox))
        window.inboxBadge:setWidth(counts.inbox > 99 and 26 or 18)
        window.inboxBadge:show()
    else
        window.inboxBadge:hide()
    end
    window.summary:setText(tr('%d Pokemon in %d boxes of %d', counts.pokemon or 0, state.boxes or 0, state.boxSize or 0))
end

-- Pokemon detail

local SPARKLE_COUNT = 5
local SPARKLE_TICK = 50
local SPARKLE_SIZE = 22
local sparkleEvent
local sparkles = {}

local function placeSparkle(sparkle, frame)
    local room = frame:getWidth() - SPARKLE_SIZE
    sparkle.x = math.random(0, room)
    sparkle.y = math.random(0, room)
    sparkle.length = math.random(18, 30)
end

local function stopSparkles()
    if sparkleEvent then
        removeEvent(sparkleEvent)
        sparkleEvent = nil
    end
    for _, sparkle in ipairs(sparkles) do
        sparkle:destroy()
    end
    sparkles = {}
end

local function tickSparkles()
    for _, sparkle in ipairs(sparkles) do
        sparkle.step = sparkle.step + 1
        if sparkle.step >= sparkle.length then
            sparkle.step = 0
            placeSparkle(sparkle, sparkle:getParent())
        end
        local glow = math.sin(math.pi * sparkle.step / sparkle.length)
        local size = math.max(1, math.floor(SPARKLE_SIZE * (0.3 + 0.7 * glow)))
        local offset = math.floor((SPARKLE_SIZE - size) / 2)
        sparkle:setSize({ width = size, height = size })
        sparkle:setMarginLeft(sparkle.x + offset)
        sparkle:setMarginTop(sparkle.y + offset)
        sparkle:setOpacity(glow)
    end
end

-- the same sparkles as on the GTS portraits
local function startSparkles(frame)
    stopSparkles()
    for i = 1, SPARKLE_COUNT do
        local sparkle = g_ui.createWidget('UIWidget', frame)
        sparkle:setImageSource('/modules/game_gts/images/sparkle')
        sparkle:setImageSmooth(true)
        sparkle:setPhantom(true)
        sparkle:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        sparkle:addAnchor(AnchorTop, 'parent', AnchorTop)
        placeSparkle(sparkle, frame)
        sparkle.step = math.floor(sparkle.length * (i - 1) / SPARKLE_COUNT)
        table.insert(sparkles, sparkle)
    end
    tickSparkles()
    sparkleEvent = cycleEvent(tickSparkles, SPARKLE_TICK)
end

local function clearDetail()
    stopSparkles()
    local detail = window.pages.boxesPage.detail
    detail.content:hide()
    detail.empty:show()
    state.detail = nil
end

local function drawStats(sheet)
    local stats = window.pages.boxesPage.detail.content.stats
    stats:destroyChildren()
    if not sheet then
        local label = g_ui.createWidget('GtsLabel', stats)
        label:setText(tr('Its stats have not been checked yet.'))
        label:setColor(MUTED_COLOR)
        return
    end

    local nature = sheet.nature or {}
    local ivMax, evMax = sheet.ivMax or 31, sheet.evMax or 252
    for stat, name in ipairs(sheet.statNames or {}) do
        local row = g_ui.createWidget('GtsStatRow', stats)
        row.name:setText(name)
        row.actual:setText(tostring(sheet.actual and sheet.actual[stat] or 0))
        if nature.up ~= nature.down then
            if stat == nature.up then
                row.name:setColor('#ff7a70')
            elseif stat == nature.down then
                row.name:setColor('#7ab0ff')
            end
        end
        local iv, ev = sheet.ivs[stat] or 0, sheet.evs[stat] or 0
        row.iv:setText(tostring(iv))
        row.ev:setText(tostring(ev))
        row.ivTrack.fill:setWidth(math.floor((row.ivTrack:getWidth() - 2) * math.min(1, iv / ivMax)))
        row.evTrack.fill:setWidth(math.floor((row.evTrack:getWidth() - 2) * math.min(1, ev / evMax)))
        if iv == ivMax then
            row.iv:setColor('#5aa0e6')
        end
        if ev == evMax then
            row.ev:setColor('#e6c34a')
        end
    end
end

local function drawDetail(data)
    local detail = window.pages.boxesPage.detail
    local content = detail.content
    state.detail = data
    detail.empty:hide()
    content:show()

    setPortrait(content.portraitFrame.portrait, data.number)
    if data.shiny then
        startSparkles(content.portraitFrame)
    else
        stopSparkles()
    end
    content.name:setText(pokemonLabel(data) .. (data.nickname and data.nickname ~= '' and ('  "' .. data.nickname .. '"') or ''))
    content.ball:setItemId(data.ball or 0)
    content.line1:setText(tr('Gender: %s     Boost: +%d', tr(SEX_NAMES[data.sex] or '-'), data.boost or 0))
    content.line2:setText(tr('Ability: %s', data.ability or tr('None')))
    content.line3:setText(tr('Egg move: %s', (data.eggMove and data.eggMove ~= '') and data.eggMove or tr('None')))
    content.line4:setText(tr('Held item: %s', data.held or tr('None')))

    local sheet = data.sheet
    if sheet then
        local nature = sheet.nature or {}
        content.nature:setText(tr('%s Nature', nature.name or '?'))
        content.totals:setText(tr('IVs %d/%d (%d perfect)    EVs %d/%d', sheet.ivTotal or 0, (sheet.ivMax or 31) * 6,
            sheet.perfectIvs or 0, sheet.evTotal or 0, sheet.evTotalMax or 510))
    else
        content.nature:setText('')
        content.totals:setText('')
    end
    drawStats(sheet)

    local inBox = data.index == nil
    content.actionButton:setText(inBox and tr('Take to party') or tr('Put in a box'))
    content.actionButton:setEnabled(inBox and not state.partyFull or (not inBox and not data.problem))
    content.moveLabel:setVisible(inBox)
    content.moveCombo:setVisible(inBox)
    content.moveButton:setVisible(inBox)
end

-- Poke boxes

local function slotOf(row)
    return state.slots and state.slots[row]
end

local function selectPokemon(kind, data)
    state.selected = data and { kind = kind, data = data } or nil
    for _, slot in ipairs(window.pages.boxesPage.grid:getChildren()) do
        slot:setOn(kind == 'box' and data ~= nil and slot.data == data)
    end
    for _, slot in ipairs(window.pages.boxesPage.party:getChildren()) do
        slot:setOn(kind == 'party' and data ~= nil and slot.data == data)
    end
    if not data then
        clearDetail()
    elseif kind == 'box' then
        send('pokemon ' .. data.id)
    else
        send(string.format('partymon %d %s', data.index, data.name))
    end
end

local function deposit(ball, box, slot)
    send(string.format('deposit %d %d %d %s', ball.index, box or 0, slot or 0, ball.name))
end

local function withdraw(pokemon)
    send('withdraw ' .. pokemon.id)
end

-- dragging a Pokemon: a face follows the mouse and the slot under it on release gets it
local function stopDrag()
    if drag then
        drag.ghost:destroy()
        drag = nil
    end
end

local function dropTarget(mousePos)
    local widget = rootWidget:recursiveGetChildByPos(mousePos, false)
    while widget do
        if widget.pcSlot then
            return widget
        end
        widget = widget:getParent()
    end
    return nil
end

local function onDrop(source, target)
    if not target or target == source then
        return
    end
    local from, to = source.pcSlot, target.pcSlot
    if from.kind == 'box' and to.kind == 'box' then
        send(string.format('move %d %d %d', source.data.id, state.box, to.slot))
    elseif from.kind == 'box' and to.kind == 'party' then
        withdraw(source.data)
    elseif from.kind == 'party' and to.kind == 'box' then
        deposit(source.data, state.box, to.data == nil and to.slot or nil)
    end
end

local function setupSlot(slot, kind, index)
    slot.pcSlot = { kind = kind, slot = index }
    slot.onClick = function(self)
        -- the second click of a double click comes after the double click already moved it
        if self.data and not (state.selected and state.selected.data == self.data) then
            selectPokemon(kind, self.data)
        end
    end
    slot.onDoubleClick = function(self)
        if not self.data then
            return
        end
        if kind == 'box' then
            withdraw(self.data)
        else
            deposit(self.data)
        end
    end
    slot.onDragEnter = function(self, mousePos)
        if not self.data then
            return false
        end
        stopDrag()
        local ghost = g_ui.createWidget('UIItem', rootWidget)
        ghost:setVirtual(true)
        ghost:setPhantom(true)
        ghost:setSize({ width = 40, height = 40 })
        ghost:setItemId(self.face:getItemId())
        ghost:setOpacity(0.8)
        ghost:setPosition({ x = mousePos.x - 20, y = mousePos.y - 20 })
        drag = { ghost = ghost }
        return true
    end
    slot.onDragMove = function(self, mousePos)
        if drag then
            drag.ghost:setPosition({ x = mousePos.x - 20, y = mousePos.y - 20 })
        end
        return true
    end
    slot.onDragLeave = function(self, droppedWidget, mousePos)
        if not drag then
            return false
        end
        stopDrag()
        onDrop(self, dropTarget(mousePos))
        return true
    end
end

local function fillSlot(slot, data)
    slot.data = data
    slot:setOn(false)
    if not data then
        slot.face:hide()
        slot.portrait:hide()
        slot.level:setText('')
        slot.shiny:hide()
        slot:setTooltip('')
        return
    end
    setFace(slot.face, slot.portrait, data)
    slot.level:setText(tostring(data.level or ''))
    slot.shiny:setVisible(data.shiny == true)
    local tooltip = pokemonLabel(data)
    if data.nature then
        tooltip = tooltip .. '\n' .. tr('%s, IVs %d/186', data.nature, data.ivs or 0)
    end
    if data.problem then
        tooltip = tooltip .. '\n' .. data.problem
    end
    slot:setTooltip(tooltip)
end

local function drawBox(data)
    local page = window.pages.boxesPage
    state.box = data.box
    state.boxList = data.boxes or {}

    state.fillingBoxes = true
    for _, combo in ipairs({ page.boxCombo, page.detail.content.moveCombo }) do
        combo:clearOptions()
        for _, box in ipairs(state.boxList) do
            combo:addOption(string.format('%s (%d/%d)', box.name, box.count, state.boxSize or 30), box.box)
        end
    end
    page.boxCombo:setCurrentOptionByData(state.box, true)
    page.detail.content.moveCombo:setCurrentOptionByData(state.box, true)
    state.fillingBoxes = nil
    local current = state.boxList[state.box] or {}
    page.boxName:setText(current.name or '', true)
    page.boxCount:setText(tr('%d of %d', current.count or 0, state.boxSize or 30))
    page.prevBox:setEnabled(state.box > 1)
    page.nextBox:setEnabled(state.box < #state.boxList)

    local bySlot = {}
    for _, row in ipairs(data.list or {}) do
        bySlot[row.slot] = row
    end
    local keep = state.selected and state.selected.kind == 'box' and state.selected.data.id
    local kept
    for index, slot in ipairs(page.grid:getChildren()) do
        fillSlot(slot, bySlot[index])
        if keep and bySlot[index] and bySlot[index].id == keep then
            kept = bySlot[index]
        end
    end
    if keep then
        if kept then
            selectPokemon('box', kept)
        else
            selectPokemon(nil, nil)
        end
    end
end

local function drawParty(data)
    local page = window.pages.boxesPage
    state.party = data.list or {}
    state.partyFull = data.full == true
    local keep = state.selected and state.selected.kind == 'party' and state.selected.data
    local kept
    for index, slot in ipairs(page.party:getChildren()) do
        local ball = state.party[index]
        fillSlot(slot, ball)
        if ball and keep and ball.index == keep.index and ball.name == keep.name then
            kept = ball
        end
    end
    page.partyTitle:setText(tr('With you (%d)', #state.party))
    if keep then
        if kept then
            selectPokemon('party', kept)
        else
            selectPokemon(nil, nil)
        end
    end
end

-- Stash

local function stashCategories()
    local seen, list = {}, { 'All' }
    for _, entry in ipairs(state.stash or {}) do
        if not seen[entry.category] then
            seen[entry.category] = true
            table.insert(list, entry.category)
        end
    end
    table.sort(list, function(a, b)
        if a == 'All' or b == 'All' then
            return a == 'All'
        end
        return a < b
    end)
    return list
end

local function sortEntries(list)
    local sort = state.sort or 'name'
    table.sort(list, function(a, b)
        if sort == 'count' and a.count ~= b.count then
            return a.count > b.count
        elseif sort == 'category' and a.category ~= b.category then
            return a.category < b.category
        end
        return a.name < b.name
    end)
end

local function updateItemBar(bar, entry, actionText)
    bar:setEnabled(entry ~= nil)
    bar.action:setText(actionText)
    if not entry then
        bar.item:setItemId(0)
        bar.name:setText(tr('Pick an item'))
        bar.info:setText('')
        bar.amount:setMaximum(1)
        bar.amount:setValue(1)
        return
    end
    bar.item:setItemId(entry.client)
    bar.name:setText(entry.name)
    bar.info:setText(tr('%d stored', entry.count))
    bar.amount:setMaximum(math.max(1, entry.count))
    if bar.amount:getValue() > entry.count then
        bar.amount:setValue(entry.count)
    end
end

local function drawItemGrid(grid, list, picked, onPick)
    grid:destroyChildren()
    for _, entry in ipairs(list) do
        local cell = g_ui.createWidget('PcItemCell', grid)
        cell.item:setItemId(entry.client)
        cell.count:setText(formatCount(entry.count))
        cell:setTooltip(string.format('%s\n%s', entry.name, tr('%d stored', entry.count)))
        cell:setOn(picked == entry.itemtype)
        cell.data = entry
        cell.onClick = function(self)
            for _, other in ipairs(grid:getChildren()) do
                other:setOn(other == self)
            end
            onPick(self.data)
        end
    end
end

local drawStash, drawBag

local function pickStash(entry)
    state.stashPick = entry and entry.itemtype
    local bar = window.pages.stashPage.take
    updateItemBar(bar, entry, tr('Withdraw'))
    if entry then
        bar.info:setText(tr('%d in your stash', entry.count))
    end
end

local function pickBag(entry)
    state.bagPick = entry and entry.itemtype
    local bar = window.pages.stashPage.stow
    updateItemBar(bar, entry, tr('Stow'))
    if entry then
        bar.info:setText(tr('%d with you', entry.count))
    end
end

function drawStash()
    local page = window.pages.stashPage
    local filter = window.search:getText():lower()
    local list, picked = {}, nil
    for _, entry in ipairs(state.stash or {}) do
        if (state.category == 'All' or entry.category == state.category) then
            table.insert(list, entry)
            if entry.itemtype == state.stashPick then
                picked = entry
            end
        end
    end
    sortEntries(list)
    page.stashTitle:setText(tr('Stash: %s (%d)', tr(state.category or 'All'), #list))
    drawItemGrid(page.stash, list, picked and picked.itemtype, pickStash)
    if #list == 0 then
        local label = g_ui.createWidget('GtsLabel', page.stash)
        label:setText(tr('Nothing here yet. Stow items from your bag.'))
        label:setColor(MUTED_COLOR)
    end
    pickStash(picked)

    local categories = stashCategories()
    page.categories:destroyChildren()
    for _, name in ipairs(categories) do
        local count = 0
        for _, entry in ipairs(state.stash or {}) do
            if name == 'All' or entry.category == name then
                count = count + 1
            end
        end
        local row = g_ui.createWidget('GtsRow', page.categories)
        local cell = g_ui.createWidget('GtsCell', row)
        cell:setWidth(166)
        cell:setText(string.format('%s (%d)', tr(name), count))
        row.data = name
        if name == state.category then
            page.categories:focusChild(row, OtherFocusReason)
        end
    end
end

function drawBag()
    local page = window.pages.stashPage
    local picked
    for _, entry in ipairs(state.bag or {}) do
        if entry.itemtype == state.bagPick then
            picked = entry
        end
    end
    page.bagTitle:setText(tr('In your bag (%d)', #(state.bag or {})))
    drawItemGrid(page.bag, state.bag or {}, picked and picked.itemtype, pickBag)
    pickBag(picked)
    page.stowAll:setEnabled(#(state.bag or {}) > 0)
end

-- Inbox

local function drawInbox(data)
    local page = window.pages.inboxPage
    state.inbox = data.list or {}
    page.title:setText(tr('Inbox (%d)', #state.inbox) .. (data.more and ' +' or ''))
    page.list:destroyChildren()
    local hasPokemon = false
    for _, row in ipairs(state.inbox) do
        local entry = addEntry(page.list, row)
        entry.name:setText(row.pokemon and pokemonLabel(row) or (row.count > 1 and string.format('%dx %s', row.count, row.name) or row.name))
        entry.info:setText(string.format('%s, %s', row.source or '', formatDate(row.created)))
        hasPokemon = hasPokemon or row.pokemon == true
    end
    if #state.inbox == 0 then
        addEmpty(page.list, tr('Your inbox is empty.'))
    end
    page.takeAllButton:setEnabled(#state.inbox > 0)
    local function update()
        local focused = page.list:getFocusedChild()
        local row = focused and focused.data
        page.takeButton:setEnabled(row ~= nil)
        page.toBoxButton:setEnabled(row ~= nil and row.pokemon == true)
    end
    page.list.onChildFocusChange = update
    update()
end

-- Depot

local function drawDepot(data)
    local page = window.pages.depotPage
    local list = data.list or {}
    page.title:setText(tr('Depot (%d)', #list) .. (data.more and ' +' or ''))
    page.list:destroyChildren()
    for _, row in ipairs(list) do
        local entry = addEntry(page.list, row)
        entry.name:setText(row.count > 1 and string.format('%dx %s', row.count, row.name) or row.name)
        entry.info:setText(row.inside and tr('in %s', row.inside) or tr('in the depot chest'))
    end
    if #list == 0 then
        addEmpty(page.list, tr('Your depot is empty.'))
    end
end

-- Search

local function openResult(row)
    window.search:setText('', true)
    if row.where == 'box' then
        state.box = row.box
        state.selected = { kind = 'box', data = { id = row.id } }
        setTab('boxes')
    elseif row.where == 'stash' then
        state.category, state.stashPick = 'All', row.itemtype
        setTab('stash')
    else
        setTab(row.where)
    end
end

local function drawSearch(data)
    if window.search:getText():lower():gsub('[^%w%s%.%-\']', '') ~= data.text then
        return
    end
    local page = window.pages.searchPage
    page.title:setText(tr('Found %d for "%s"', #(data.list or {}), data.text))
    page.list:destroyChildren()
    for _, row in ipairs(data.list or {}) do
        local entry = addEntry(page.list, row)
        local name = row.number and pokemonLabel(row) or ((row.count or 1) > 1 and string.format('%dx %s', row.count, row.name) or row.name)
        entry.name:setText(name)
        local where = tr(WHERE_NAMES[row.where] or '')
        if row.where == 'box' then
            where = tr('Box %d', row.box)
        elseif row.inside then
            where = tr('Depot, in %s', row.inside)
        end
        entry.info:setText(where)
        entry.onDoubleClick = function() openResult(row) end
    end
    if #(data.list or {}) == 0 then
        addEmpty(page.list, tr('Nothing matches your search.'))
    else
        local hint = g_ui.createWidget('GtsCell', page.list)
        hint:setHeight(22)
        hint:setText(tr('Double click a result to go to it.'))
        hint:setColor(MUTED_COLOR)
        hint:setTextAlign(AlignCenter)
    end
end

local function onSearchChange()
    if searchEvent then
        removeEvent(searchEvent)
        searchEvent = nil
    end
    local text = window.search:getText():gsub('[^%w%s%.%-\']', '')
    if #text < 2 then
        showPage(TABS[state.tab or 'boxes'])
        return
    end
    showPage('searchPage')
    window.pages.searchPage.title:setText(tr('Searching...'))
    searchEvent = scheduleEvent(function()
        searchEvent = nil
        send('search ' .. text)
    end, 400)
end

-- messages

local handlers = {}

function handlers.open(data)
    state = { locker = not data.anywhere and (lockerPos or data.locker) or nil, anywhere = data.anywhere,
        boxes = data.boxes, boxSize = data.boxSize, box = 1, tab = 'boxes', category = 'All', sort = state.sort or 'name' }
    lockerPos = nil
    clearDetail()
    window.search:setText('', true)
    setStatus(tr('Drag Pokemon between your party and the boxes, or double click to move them.'), true)
    local root = rootWidget
    window:setSize({ width = math.min(1000, root:getWidth() - 20), height = math.min(620, root:getHeight() - 20) })
    closeLockerContainers()
    window:show()
    window:raise()
    window:focus()
    window.boxesTab:setOn(true)
    window.stashTab:setOn(false)
    window.inboxTab:setOn(false)
    window.depotTab:setOn(false)
    showPage('boxesPage')
end

function handlers.close()
    stopDrag()
    stopSparkles()
    if window:isVisible() then
        window:hide()
    end
end

function handlers.counts(data)
    state.counts = data
    updateCounts()
end

function handlers.box(data)
    drawBox(data)
end

function handlers.party(data)
    drawParty(data)
end

function handlers.pokemon(data)
    local selected = state.selected
    if not selected then
        return
    end
    if (selected.kind == 'box' and data.id == selected.data.id)
            or (selected.kind == 'party' and data.index == selected.data.index) then
        if selected.kind == 'party' then
            data.problem = selected.data.problem
        end
        drawDetail(data)
    end
end

function handlers.stash(data)
    state.stash = data.list or {}
    drawStash()
end

function handlers.bag(data)
    state.bag = data.list or {}
    drawBag()
end

function handlers.inbox(data)
    drawInbox(data)
end

function handlers.depot(data)
    drawDepot(data)
end

function handlers.search(data)
    drawSearch(data)
end

function handlers.result(data)
    setStatus(data.text, data.ok)
end

-- something was delivered while the window is open
function handlers.changed()
    if window:isVisible() and state.tab then
        setTab(state.tab)
    end
end

-- "Open depot": the server lets the next use of the locker open it as a container
function handlers.useLocker()
    handlers.close()
    local pos = state.locker
    local tile = pos and g_map.getTile(pos)
    local thing = tile and tile:getTopUseThing()
    if thing then
        g_game.use(thing)
    end
end

local function onPc(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or not handlers[data.type] then
        g_logger.warning('PC: invalid message')
        return
    end
    handlers[data.type](data)
end

-- widgets

local function setupBoxesPage()
    local page = window.pages.boxesPage
    for index = 1, 30 do
        setupSlot(g_ui.createWidget('PcSlot', page.grid), 'box', index)
    end
    for index = 1, 6 do
        setupSlot(g_ui.createWidget('PcSlot', page.party), 'party', index)
    end
    page.hint:setText(tr('Double click a Pokemon to take it or put it away, or drag it. Dropping one on a taken slot swaps them.'))
    page.prevBox.onClick = function() send('box ' .. math.max(1, (state.box or 1) - 1)) end
    page.nextBox.onClick = function() send('box ' .. ((state.box or 1) + 1)) end
    page.boxCombo.onOptionChange = function(combo, text, box)
        if box and box ~= state.box and not state.fillingBoxes then
            send('box ' .. box)
        end
    end
    page.renameButton.onClick = function()
        send(string.format('rename %d %s', state.box or 1, page.boxName:getText()))
    end
    page.boxName.onKeyPress = function(self, keyCode)
        if keyCode == KeyEnter or keyCode == KeyReturn then
            page.renameButton.onClick()
            return true
        end
        return false
    end

    local content = page.detail.content
    content.actionButton.onClick = function()
        local selected = state.selected
        if not selected then
            return
        end
        if selected.kind == 'box' then
            withdraw(selected.data)
        else
            deposit(selected.data)
        end
    end
    content.moveButton.onClick = function()
        local selected = state.selected
        local option = content.moveCombo:getCurrentOption()
        if selected and selected.kind == 'box' and option and option.data ~= state.box then
            send(string.format('move %d %d', selected.data.id, option.data))
        end
    end
end

local function setupStashPage()
    local page = window.pages.stashPage
    for _, sort in ipairs(SORTS) do
        page.sort:addOption(tr(sort.name), sort.id)
    end
    page.sort.onOptionChange = function(combo, text, id)
        state.sort = id
        if state.stash then
            drawStash()
        end
    end
    page.categories.onChildFocusChange = function(list, focused)
        if focused and focused.data and focused.data ~= state.category then
            state.category = focused.data
            drawStash()
        end
    end

    local take, stow = page.take, page.stow
    take.max.onClick = function() take.amount:setValue(take.amount:getMaximum()) end
    stow.max.onClick = function() stow.amount:setValue(stow.amount:getMaximum()) end
    take.action.onClick = function()
        if state.stashPick then
            send(string.format('unstow %d %d', state.stashPick, take.amount:getValue()))
        end
    end
    stow.action.onClick = function()
        if state.bagPick then
            send(string.format('stow %d %d', state.bagPick, stow.amount:getValue()))
        end
    end
    page.stowAll.onClick = function()
        confirm(tr('Pokemon Center PC'), tr('Put every stackable item and held item from your bag in the stash?'),
            function() send('stowall') end)
    end
    pickStash(nil)
    pickBag(nil)
end

local function setupInboxPage()
    local page = window.pages.inboxPage
    local function focused()
        local row = page.list:getFocusedChild()
        return row and row.data
    end
    page.takeButton.onClick = function()
        local row = focused()
        if row then
            send('take ' .. row.id)
        end
    end
    page.toBoxButton.onClick = function()
        local row = focused()
        if row and row.pokemon then
            send('tobox ' .. row.id)
        end
    end
    page.takeAllButton.onClick = function() send('takeall') end
end

local function setupDepotPage()
    window.pages.depotPage.openButton.onClick = function() send('opendepot') end
end

function close()
    stopDrag()
    stopSparkles()
    if window and window:isVisible() then
        window:hide()
        if g_game.isOnline() then
            send('close')
        end
    end
end

local function sayHello()
    if helloEvent then
        removeEvent(helloEvent)
    end
    helloEvent = scheduleEvent(function()
        helloEvent = nil
        if g_game.isOnline() then
            sendRequest({ action = 'hello' })
        end
    end, 1500)
end

-- like a Tibia container, the window closes once the player is no longer next to the locker
local function onPositionChange(player, newPos)
    local locker = state.locker
    if not window or not window:isVisible() or state.anywhere or not locker or not newPos then
        return
    end
    if newPos.z ~= locker.z or math.max(math.abs(newPos.x - locker.x), math.abs(newPos.y - locker.y)) > 1 then
        close()
        if modules.game_textmessage then
            modules.game_textmessage.displayFailureMessage(tr('You moved away from the PC.'))
        end
    end
end

local function onGameEnd()
    stopDrag()
    stopSparkles()
    if window then
        window:hide()
    end
    state = {}
end

function init()
    g_ui.importStyle('/modules/game_gts/gts')
    g_ui.importStyle('pc')
    window = g_ui.createWidget('PcWindow', rootWidget)
    window:hide()

    window.boxesTab.onClick = function() window.search:setText('', true); setTab('boxes') end
    window.stashTab.onClick = function() window.search:setText('', true); setTab('stash') end
    window.inboxTab.onClick = function() window.search:setText('', true); setTab('inbox') end
    window.depotTab.onClick = function() window.search:setText('', true); setTab('depot') end
    window.search.onTextChange = onSearchChange

    setupBoxesPage()
    setupStashPage()
    setupInboxPage()
    setupDepotPage()

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Pc, onPc)
    connect(g_game, { onGameStart = sayHello, onGameEnd = onGameEnd })
    connect(Container, { onOpen = onContainerOpen })
    connect(LocalPlayer, { onPositionChange = onPositionChange })
    if g_game.isOnline() then
        sayHello()
    end
end

function terminate()
    stopDrag()
    stopSparkles()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Pc)
    disconnect(g_game, { onGameStart = sayHello, onGameEnd = onGameEnd })
    disconnect(Container, { onOpen = onContainerOpen })
    disconnect(LocalPlayer, { onPositionChange = onPositionChange })
    for _, event in ipairs({ searchEvent, helloEvent }) do
        removeEvent(event)
    end
    searchEvent, helloEvent = nil, nil
    window:destroy()
    window = nil
    state = {}
end
