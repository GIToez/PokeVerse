-- Global Trade Station window, laid out like Redemption's market: items on one tab, Pokemon with
-- their portraits and stats on the other. The server (066-gts.lua) opens it from the Pokemon
-- Center computer and sends everything as ExtendedIds.Gts JSON, one {type = ...} per message;
-- the window only asks with "/gts <action> ...".
local window
local state = {}
local sideGroup
local searchEvent
local onEntryClick

local SEX_NAMES = { [0] = 'Female', [1] = 'Male', [2] = '-' }
local OK_COLOR, ERROR_COLOR = '#8fe08f', '#ff8a80'
local MUTED_COLOR = '#9fb6e0'
local FILTERS = { { id = 'all', name = 'All Pokemon' }, { id = 'shiny', name = 'Shiny Pokemon' } }

local ITEM_COLUMNS = {
    { id = 'holder', title = 'Trainer', width = 200 },
    { id = 'amount', title = 'Amount', width = 70, align = AlignRightCenter },
    { id = 'price', title = 'Price each', width = 110, align = AlignRightCenter },
    { id = 'total', title = 'Total', width = 130, align = AlignRightCenter },
    { id = 'expires', title = 'Ends', width = 130, align = AlignRightCenter },
}
local POKEMON_COLUMNS = {
    { id = 'holder', title = 'Trainer', width = 150 },
    { id = 'level', title = 'Level', width = 50, align = AlignRightCenter },
    { id = 'sex', title = 'Gender', width = 70, align = AlignCenter },
    { id = 'nature', title = 'Nature', width = 80 },
    { id = 'ivs', title = 'IVs', width = 110 },
    { id = 'boost', title = 'Boost', width = 50, align = AlignRightCenter },
    { id = 'price', title = 'Price', width = 110, align = AlignRightCenter },
    { id = 'expires', title = 'Ends', width = 100, align = AlignRightCenter },
}
local MINE_COLUMNS = {
    { id = 'kind', title = 'Offer', width = 70 },
    { id = 'name', title = 'Name', width = 200 },
    { id = 'amount', title = 'Amount', width = 60, align = AlignRightCenter },
    { id = 'price', title = 'Price each', width = 110, align = AlignRightCenter },
    { id = 'total', title = 'Total', width = 120, align = AlignRightCenter },
    { id = 'expires', title = 'Ends', width = 120, align = AlignRightCenter },
}
local HISTORY_COLUMNS = {
    { id = 'date', title = 'Date', width = 110 },
    { id = 'action', title = 'What', width = 90 },
    { id = 'name', title = 'Name', width = 200 },
    { id = 'amount', title = 'Amount', width = 60, align = AlignRightCenter },
    { id = 'price', title = 'Price each', width = 110, align = AlignRightCenter },
    { id = 'total', title = 'Total', width = 110, align = AlignRightCenter },
}
local STATE_NAMES = { [1] = { [1] = 'Sold', [0] = 'Bought' }, [2] = 'Cancelled', [3] = 'Expired' }

local function send(text)
    g_game.talk('/gts ' .. text)
end

local function formatMoney(amount)
    local text = tostring(math.floor(amount or 0))
    repeat
        local n
        text, n = text:gsub('^(%d+)(%d%d%d)', '%1,%2')
    until n == 0
    return '$' .. text
end

local function formatDate(time)
    return time and os.date('%b %d, %H:%M', time) or ''
end

local function readPrice(edit)
    local digits = edit:getText():gsub('[^%d]', '')
    return tonumber(digits) or 0
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

-- list icons use the Pokemon bar's face (shinies have their own), else the portrait shrunk
local function setFace(entry, pokemon)
    if pokemon.face then
        entry.item:setItemId(pokemon.face)
        entry.item:show()
        entry.portrait:hide()
    else
        entry.item:hide()
        setPortrait(entry.portrait, pokemon.number)
    end
end

local function setStatus(text, ok)
    window.status:setText(text or '')
    window.status:setColor(ok == false and ERROR_COLOR or OK_COLOR)
end

-- tables: a header and rows of fixed-width cells

local function buildHeader(header, columns)
    header:destroyChildren()
    for _, column in ipairs(columns) do
        local cell = g_ui.createWidget('GtsCell', header)
        cell:setWidth(column.width)
        cell:setText(tr(column.title))
        cell:setColor(MUTED_COLOR)
        cell:setTextAlign(column.align or AlignLeftCenter)
    end
end

local function addRow(list, columns, values, data)
    local row = g_ui.createWidget('GtsRow', list)
    for _, column in ipairs(columns) do
        local cell = g_ui.createWidget('GtsCell', row)
        cell:setId(column.id)
        cell:setWidth(column.width)
        cell:setTextAlign(column.align or AlignLeftCenter)
        cell:setText(values[column.id] ~= nil and tostring(values[column.id]) or '')
    end
    row.data = data
    return row
end

local function addEmpty(list, text)
    local label = g_ui.createWidget('GtsCell', list)
    label:setHeight(24)
    label:setText(text)
    label:setColor(MUTED_COLOR)
    label:setTextAlign(AlignCenter)
end

-- pages

local function showPage(id)
    for _, page in ipairs({ 'itemPage', 'pokemonPage', 'sellPokemonPage', 'minePage' }) do
        window.pages[page]:setVisible(page == id)
    end
    state.page = id
end

local function updateTabs()
    window.itemsTab:setOn(state.mode == 'items')
    window.pokemonTab:setOn(state.mode == 'pokemon')
    window.sellPokemonButton:setOn(state.page == 'sellPokemonPage')
    window.mineButton:setOn(state.page == 'minePage')
end

local function updateBalance()
    window.bank:setText(tr('Bank: %s', formatMoney(state.bank)))
    window.money:setText(tr('Bag: %s', formatMoney(state.money)))
end

-- items

local function updateAcceptBar(tableWidget, buying)
    local row = tableWidget.list:getFocusedChild()
    local offer = row and row.data
    local spin = tableWidget.amount
    if not offer then
        spin:setMaximum(1)
        spin:setValue(1)
        spin:setEnabled(false)
        tableWidget.total:setText('')
        tableWidget.accept:setEnabled(false)
        return
    end

    local maximum = offer.amount
    if not buying then
        maximum = math.min(maximum, state.item and state.item.count or 0)
    end
    spin:setEnabled(maximum > 1)
    spin:setMaximum(math.max(1, maximum))
    if spin:getValue() > maximum then
        spin:setValue(math.max(1, maximum))
    end
    tableWidget.total:setText(tr('Total: %s', formatMoney(spin:getValue() * offer.price)))
    tableWidget.accept:setEnabled(not offer.own and maximum > 0)
end

local function updateCreate()
    local create = window.pages.itemPage.create
    local item = state.item
    local selling = sideGroup:getSelectedWidget() == create.sellMode
    create:setEnabled(item ~= nil)
    if not item then
        create.title:setText(tr('Create Offer'))
        create.owned:setText(tr('Pick an item on the left.'))
        create.summary:setText('')
        return
    end

    create.item:setItemId(item.client)
    create.title:setText(tr('Create Offer: %s', item.name))
    create.owned:setText(tr('You have %d in your bag', item.count or 0))
    local amount, price = create.amount:getValue(), readPrice(create.price)
    local total = amount * price
    if selling then
        local tax = math.ceil(total * (state.tax or 0))
        create.summary:setText(tr('Total: %s\nTax on sale (%d%%): %s\nYou get: %s\nThe items are held by the GTS until sold.',
            formatMoney(total), math.floor((state.tax or 0) * 100 + 0.5), formatMoney(tax), formatMoney(total - tax)))
    else
        create.summary:setText(tr('Total: %s\nThe money is held by the GTS until someone sells to you.',
            formatMoney(total)))
    end
    create.createButton:setEnabled(price > 0 and amount > 0 and (not selling or amount <= (item.count or 0)))
end

local function drawOffers(data)
    local page = window.pages.itemPage
    state.offers = data
    if state.item and state.item.id == data.item then
        state.item.count = data.count
    end

    for _, side in ipairs({ { page.sell, data.sell, tr('Sell Offers') }, { page.buy, data.buy, tr('Buy Offers') } }) do
        local tableWidget, offers, title = side[1], side[2] or {}, side[3]
        tableWidget.title:setText(string.format('%s (%d)', title, #offers))
        tableWidget.list:destroyChildren()
        for _, offer in ipairs(offers) do
            local row = addRow(tableWidget.list, ITEM_COLUMNS, {
                holder = offer.own and tr('%s (you)', offer.holder or '') or offer.holder,
                amount = offer.amount, price = formatMoney(offer.price),
                total = formatMoney(offer.amount * offer.price), expires = formatDate(offer.expires)
            }, offer)
            if offer.own then
                for _, cell in ipairs(row:getChildren()) do
                    cell:setColor(MUTED_COLOR)
                end
            end
        end
        if #offers == 0 then
            addEmpty(tableWidget.list, tr('No offers yet.'))
        end
        updateAcceptBar(tableWidget, tableWidget == page.sell)
    end
    updateCreate()
end

local function selectItem(item)
    state.item = item
    local page = window.pages.itemPage
    for _, tableWidget in ipairs({ page.sell, page.buy }) do
        tableWidget.list:destroyChildren()
        updateAcceptBar(tableWidget, tableWidget == page.sell)
    end
    updateCreate()
    if item then
        send('offers ' .. item.id)
    end
end

local function drawItems()
    local entries = window.entries
    entries:destroyChildren()
    local filter = window.search:getText():lower()
    local first
    for _, item in ipairs(state.items or {}) do
        if filter == '' or item.name:lower():find(filter, 1, true) then
            local entry = g_ui.createWidget('GtsEntry', entries)
            entry.item:setItemId(item.client)
            entry.name:setText(item.name)
            entry.info:setText(item.count > 0 and tr('You have %d', item.count) or '')
            entry.data = item
            entry.onClick = onEntryClick
            first = first or entry
        end
    end
    if first then
        entries:focusChild(first, OtherFocusReason)
    else
        selectItem(nil)
    end
end

local function drawCategories()
    local list = window.categories
    list:destroyChildren()
    local source = state.mode == 'pokemon' and FILTERS or state.categories or {}
    local selected
    for _, category in ipairs(source) do
        local row = addRow(list, { { id = 'name', width = 194 } }, { name = tr(category.name) }, category)
        if (state.mode == 'pokemon' and category.id == state.filter) or (state.mode ~= 'pokemon' and category.id == state.category) then
            selected = row
        end
    end
    if selected then
        list:focusChild(selected, OtherFocusReason)
    end
end

-- Pokemon

local function pokemonLabel(entry)
    return string.format('%s Lv. %d', entry.name or '?', entry.level or 0)
end

local function ivText(entry)
    if not entry.ivs then
        return '?'
    end
    return entry.perfect and entry.perfect > 0 and string.format('%d/186 (%dx31)', entry.ivs, entry.perfect)
        or string.format('%d/186', entry.ivs)
end

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
    local detail = window.pages.pokemonPage.detail
    detail.content:hide()
    detail.empty:show()
    state.detail = nil
end

local function drawStats(sheet)
    local stats = window.pages.pokemonPage.detail.content.stats
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
    local detail = window.pages.pokemonPage.detail
    local content = detail.content
    state.detail = data
    detail.empty:hide()
    content:show()

    setPortrait(content.portraitFrame.portrait, data.number)
    if data.name and data.name:find('^Shiny ') then
        startSparkles(content.portraitFrame)
    else
        stopSparkles()
    end
    content.name:setText(pokemonLabel(data))
    if data.ball then
        content.ball:setItemId(data.ball)
    end
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

    content.sellerLabel:setText(tr('Sold by %s, ends %s', data.holder or '?', formatDate(data.expires)))
    content.buyPrice:setText(formatMoney(data.price))
    content.buyButton:setEnabled(not data.own)
    content.buyButton:setText(data.own and tr('Yours') or tr('Buy'))
end

local function drawListings(data)
    local page = window.pages.pokemonPage
    state.listings = data
    page.title:setText(tr('%s for sale (%d)', data.name or '', #(data.list or {})))
    page.list:destroyChildren()
    clearDetail()
    local first
    for _, entry in ipairs(data.list or {}) do
        local row = addRow(page.list, POKEMON_COLUMNS, {
            holder = entry.own and tr('%s (you)', entry.holder or '') or entry.holder,
            level = entry.level, sex = tr(SEX_NAMES[entry.sex] or '-'), nature = entry.nature or '?',
            ivs = ivText(entry), boost = '+' .. (entry.boost or 0), price = formatMoney(entry.price),
            expires = formatDate(entry.expires)
        }, entry)
        first = first or row
    end
    if first then
        page.list:focusChild(first, OtherFocusReason)
    else
        addEmpty(page.list, tr('Nobody is selling this Pokemon right now.'))
    end
end

local function drawSpecies(data)
    if state.mode ~= 'pokemon' then
        return
    end
    local entries = window.entries
    entries:destroyChildren()
    local first, keep
    for _, species in ipairs(data.list or {}) do
        local entry = g_ui.createWidget('GtsEntry', entries)
        setFace(entry, species)
        entry.name:setText(species.name)
        entry.info:setText(tr('%d for sale, from %s', species.count, formatMoney(species.cheapest)))
        entry.data = species
        entry.onClick = onEntryClick
        first = first or entry
        if state.species == species.name then
            keep = entry
        end
    end
    if keep or first then
        entries:focusChild(keep or first, OtherFocusReason)
    else
        local page = window.pages.pokemonPage
        page.title:setText(tr('No Pokemon for sale'))
        page.list:destroyChildren()
        addEmpty(page.list, data.search ~= '' and tr('No Pokemon match your search.')
            or tr('Nobody is selling a Pokemon right now. Be the first!'))
        clearDetail()
    end
end

local function requestSpecies()
    local text = window.search:getText():gsub('[^%w%s%.%-\']', '')
    if state.filter == 'shiny' then
        text = 'Shiny ' .. text
    end
    send('species ' .. text)
end

local function drawMyPokemon(data)
    local page = window.pages.sellPokemonPage
    page.list:destroyChildren()
    state.selectedBall = nil
    local first
    for _, ball in ipairs(data.list or {}) do
        local entry = g_ui.createWidget('GtsEntry', page.list)
        setFace(entry, ball)
        entry.name:setText(pokemonLabel(ball))
        if ball.problem then
            entry.info:setText(ball.problem)
            entry.info:setColor(ERROR_COLOR)
        else
            entry.info:setText(tr(SEX_NAMES[ball.sex] or '-'))
        end
        entry.data = ball
        first = first or entry
    end
    if first then
        page.list:focusChild(first, OtherFocusReason)
    else
        addEmpty(page.list, tr('You have no Pokemon with you.'))
    end
end

local function updateSellPokemon()
    local page = window.pages.sellPokemonPage
    local ball = state.selectedBall
    local price = readPrice(page.price)
    local tax = math.ceil(price * (state.tax or 0))
    page.summary:setText(price > 0 and tr('You get %s after the %d%% tax', formatMoney(price - tax),
        math.floor((state.tax or 0) * 100 + 0.5)) or '')
    page.listButton:setEnabled(ball ~= nil and not ball.problem and price > 0)
end

local function drawMine(data)
    local page = window.pages.minePage
    page.offers:destroyChildren()
    for _, offer in ipairs(data.offers or {}) do
        local kind = offer.kind == 1 and tr('Pokemon') or (offer.sale == 1 and tr('Sell') or tr('Buy'))
        local name = offer.kind == 1 and pokemonLabel(offer) or offer.name
        addRow(page.offers, MINE_COLUMNS, {
            kind = kind, name = name, amount = offer.amount, price = formatMoney(offer.price),
            total = formatMoney(offer.amount * offer.price), expires = formatDate(offer.expires)
        }, offer)
    end
    if #(data.offers or {}) == 0 then
        addEmpty(page.offers, tr('You have no offers on the GTS.'))
    end
    page.cancelButton:setEnabled(false)

    page.history:destroyChildren()
    for _, entry in ipairs(data.history or {}) do
        local action = STATE_NAMES[entry.state]
        if type(action) == 'table' then
            action = action[entry.sale] or ''
        end
        addRow(page.history, HISTORY_COLUMNS, {
            date = formatDate(entry.date), action = tr(action or ''),
            name = entry.kind == 1 and pokemonLabel(entry) or entry.name, amount = entry.amount,
            price = formatMoney(entry.price), total = formatMoney(entry.amount * entry.price)
        }, entry)
    end
    if #(data.history or {}) == 0 then
        addEmpty(page.history, tr('Nothing traded yet.'))
    end
end

-- modes

local function setMode(mode)
    state.mode = mode
    window.search:setText('', true)
    if mode == 'pokemon' then
        window.categoriesTitle:setText(tr('Show'))
        window.entriesTitle:setText(tr('Pokemon for sale'))
        state.filter = state.filter or 'all'
        showPage('pokemonPage')
        drawCategories()
        requestSpecies()
    else
        window.categoriesTitle:setText(tr('Categories'))
        window.entriesTitle:setText(tr('Items'))
        showPage('itemPage')
        drawCategories()
        if state.items then
            drawItems()
        end
    end
    updateTabs()
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

local function acceptOffer(tableWidget, buying)
    local row = tableWidget.list:getFocusedChild()
    local offer = row and row.data
    if not offer or not state.item then
        return
    end
    local amount = tableWidget.amount:getValue()
    local total = formatMoney(amount * offer.price)
    local text = buying and tr('Buy %dx %s from %s for %s?', amount, state.item.name, offer.holder or '?', total)
        or tr('Sell %dx %s to %s for %s?', amount, state.item.name, offer.holder or '?', total)
    confirm(tr('Global Trade Station'), text, function()
        send(string.format('accept %d %d', offer.id, amount))
    end)
end

-- messages

local handlers = {}

function handlers.open(data)
    state = { categories = data.categories or {}, bank = data.bank, money = data.money, tax = data.tax or 0,
        maxPrice = data.maxPrice, maxAmount = data.maxAmount, days = data.days, filter = 'all' }
    state.category = state.categories[1] and state.categories[1].id
    window.pages.itemPage.create.amount:setMaximum(state.maxAmount or 1000)
    updateBalance()
    setStatus(tr('Offers last %d days. Sellers pay a %d%% tax when something sells.', data.days or 7,
        math.floor(state.tax * 100 + 0.5)), true)
    local root = rootWidget
    window:setSize({ width = math.min(1000, root:getWidth() - 20), height = math.min(620, root:getHeight() - 20) })
    window:show()
    window:raise()
    window:focus()
    setMode('items')
end

function handlers.close()
    if window:isVisible() then
        window:hide()
    end
end

function handlers.category(data)
    if data.id ~= state.category then
        return
    end
    state.items = data.items or {}
    if state.mode == 'items' then
        drawItems()
    end
end

function handlers.offers(data)
    if state.item and state.item.id == data.item then
        drawOffers(data)
        for _, entry in ipairs(window.entries:getChildren()) do
            if entry.data == state.item then
                entry.info:setText(state.item.count > 0 and tr('You have %d', state.item.count) or '')
            end
        end
    end
end

function handlers.balance(data)
    state.bank, state.money = data.bank, data.money
    updateBalance()
end

function handlers.result(data)
    setStatus(data.text, data.ok)
end

function handlers.species(data)
    drawSpecies(data)
end

function handlers.listings(data)
    if state.mode == 'pokemon' and state.species == data.name then
        drawListings(data)
        -- a bought Pokemon may have been the last one
        if #(data.list or {}) == 0 then
            requestSpecies()
        end
    end
end

function handlers.pokemon(data)
    local row = window.pages.pokemonPage.list:getFocusedChild()
    if row and row.data and row.data.id == data.id then
        drawDetail(data)
    end
end

function handlers.myPokemon(data)
    drawMyPokemon(data)
end

function handlers.mine(data)
    drawMine(data)
end

local function onGts(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or not handlers[data.type] then
        g_logger.warning('GTS: invalid message')
        return
    end
    handlers[data.type](data)
end

-- widgets

local function onCategoryFocus(list, focused)
    if not focused or not focused.data then
        return
    end
    if state.mode == 'pokemon' then
        if state.filter ~= focused.data.id then
            state.filter = focused.data.id
            requestSpecies()
        end
        return
    end
    if state.category ~= focused.data.id or not state.items then
        state.category = focused.data.id
        state.items = nil
        window.entries:destroyChildren()
        selectItem(nil)
        send('category ' .. state.category)
    end
end

local function modePage()
    return state.mode == 'pokemon' and 'pokemonPage' or 'itemPage'
end

-- a click or arrow key opens the entry; lists redrawn while another page is up only keep it selected
local function openEntry(entry, reason)
    if not entry or not entry.data then
        return
    end
    if reason == OtherFocusReason and state.page ~= modePage() then
        return
    end
    if state.mode == 'pokemon' then
        state.species = entry.data.name
        showPage('pokemonPage')
        updateTabs()
        send('listings ' .. entry.data.name)
    else
        showPage('itemPage')
        updateTabs()
        selectItem(entry.data)
    end
end

function onEntryClick(entry)
    if state.page ~= modePage() then
        openEntry(entry)
    end
end

local function onSearchChange()
    if searchEvent then
        removeEvent(searchEvent)
        searchEvent = nil
    end
    if state.mode == 'pokemon' then
        searchEvent = scheduleEvent(function()
            searchEvent = nil
            requestSpecies()
        end, 400)
    else
        drawItems()
    end
end

local function cleanPrice(edit)
    local digits = edit:getText():gsub('[^%d]', '')
    local value = tonumber(digits)
    if value and state.maxPrice and value > state.maxPrice then
        digits = tostring(state.maxPrice)
    end
    if digits ~= edit:getText() then
        edit:setText(digits, true)
    end
end

local function setupItemPage()
    local page = window.pages.itemPage
    for _, side in ipairs({ { page.sell, true }, { page.buy, false } }) do
        local tableWidget, buying = side[1], side[2]
        buildHeader(tableWidget.header, ITEM_COLUMNS)
        tableWidget.list.onChildFocusChange = function() updateAcceptBar(tableWidget, buying) end
        tableWidget.amount.onValueChange = function() updateAcceptBar(tableWidget, buying) end
        tableWidget.accept.onClick = function() acceptOffer(tableWidget, buying) end
    end

    local create = page.create
    sideGroup = UIRadioGroup.create()
    sideGroup:addWidget(create.sellMode)
    sideGroup:addWidget(create.buyMode)
    sideGroup:selectWidget(create.sellMode)
    sideGroup.onSelectionChange = updateCreate
    create.amount.onValueChange = updateCreate
    create.price.onTextChange = function(edit)
        cleanPrice(edit)
        updateCreate()
    end
    create.createButton.onClick = function()
        local item = state.item
        if not item then
            return
        end
        local selling = sideGroup:getSelectedWidget() == create.sellMode
        local amount, price = create.amount:getValue(), readPrice(create.price)
        local text = selling and tr('Put %dx %s up for sale at %s each?', amount, item.name, formatMoney(price))
            or tr('Offer to buy %dx %s at %s each? %s will be held until someone sells to you.', amount, item.name,
                formatMoney(price), formatMoney(amount * price))
        confirm(tr('Global Trade Station'), text, function()
            send(string.format('%s %d %d %d', selling and 'sell' or 'buy', item.id, amount, price))
        end)
    end
end

local function setupPokemonPages()
    local page = window.pages.pokemonPage
    buildHeader(page.header, POKEMON_COLUMNS)
    page.list.onChildFocusChange = function(list, focused)
        if focused and focused.data then
            send('pokemon ' .. focused.data.id)
        end
    end
    page.detail.content.buyButton.onClick = function()
        local data = state.detail
        if not data or data.own then
            return
        end
        confirm(tr('Global Trade Station'), tr('Buy %s from %s for %s?', pokemonLabel(data), data.holder or '?',
            formatMoney(data.price)), function()
            send('accept ' .. data.id)
        end)
    end

    local sellPage = window.pages.sellPokemonPage
    sellPage.hint:setText(tr('Pick one of the Pokemon with you. It leaves your bag until it sells or you cancel.'))
    sellPage.list.onChildFocusChange = function(list, focused)
        state.selectedBall = focused and focused.data
        updateSellPokemon()
    end
    sellPage.price.onTextChange = function(edit)
        cleanPrice(edit)
        updateSellPokemon()
    end
    sellPage.listButton.onClick = function()
        local ball = state.selectedBall
        local price = readPrice(sellPage.price)
        if not ball or price <= 0 then
            return
        end
        confirm(tr('Global Trade Station'), tr('Put your %s up for sale for %s?', pokemonLabel(ball), formatMoney(price)),
            function() send(string.format('list %d %d %s', ball.index, price, ball.name)) end)
    end
end

local function setupMinePage()
    local page = window.pages.minePage
    buildHeader(page.offersHeader, MINE_COLUMNS)
    buildHeader(page.historyHeader, HISTORY_COLUMNS)
    page.offers.onChildFocusChange = function(list, focused)
        page.cancelButton:setEnabled(focused ~= nil and focused.data ~= nil)
    end
    page.cancelButton.onClick = function()
        local row = page.offers:getFocusedChild()
        local offer = row and row.data
        if not offer then
            return
        end
        local name = offer.kind == 1 and pokemonLabel(offer) or offer.name
        confirm(tr('Global Trade Station'), tr('Cancel your offer for %s? What it holds comes back to you.', name or '?'),
            function() send('cancel ' .. offer.id) end)
    end
end

function close()
    if window and window:isVisible() then
        window:hide()
        if g_game.isOnline() then
            send('close')
        end
    end
end

local function onGameEnd()
    if window then
        window:hide()
    end
    state = {}
end

function init()
    g_ui.importStyle('gts')
    window = g_ui.createWidget('GtsWindow', rootWidget)
    window:hide()
    window.onVisibilityChange = function(widget, visible)
        if not visible then
            stopSparkles()
        end
    end

    window.itemsTab.onClick = function() setMode('items') end
    window.pokemonTab.onClick = function() setMode('pokemon') end
    window.sellPokemonButton.onClick = function()
        if state.page == 'sellPokemonPage' then
            setMode(state.mode or 'items')
            return
        end
        showPage('sellPokemonPage')
        updateTabs()
        updateSellPokemon()
        send('mypokemon')
    end
    window.mineButton.onClick = function()
        if state.page == 'minePage' then
            setMode(state.mode or 'items')
            return
        end
        showPage('minePage')
        updateTabs()
        send('mine')
    end
    window.categories.onChildFocusChange = onCategoryFocus
    window.entries.onChildFocusChange = function(list, focused, unfocused, reason) openEntry(focused, reason) end
    window.search.onTextChange = onSearchChange

    setupItemPage()
    setupPokemonPages()
    setupMinePage()

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Gts, onGts)
    connect(g_game, { onGameEnd = onGameEnd })
end

function terminate()
    stopSparkles()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Gts)
    disconnect(g_game, { onGameEnd = onGameEnd })
    if searchEvent then
        removeEvent(searchEvent)
        searchEvent = nil
    end
    if sideGroup then
        sideGroup:destroy()
        sideGroup = nil
    end
    window:destroy()
    window = nil
    state = {}
end
