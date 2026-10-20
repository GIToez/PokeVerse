-- The Poke Mart window. It takes over every NPC shop from game_npctrade's legacy window (which stays hidden
-- while this module is loaded): onOpenNpcTrade fills it with what that NPC sells and buys, onPlayerGoods
-- keeps the money and the bag counts current and onCloseNpcTrade closes it.
--
-- Buy: click the tiles to fill a cart, then Buy; the money and the capacity are checked first.
-- Sell: every item this NPC buys is listed, the ones in the bag bright with an amount to type, the rest
-- grayed out at 0 (the "Only items I have" filter hides them). Sell sells the amounts entered; the small
-- Sell all does what the legacy window's did: sells everything this NPC buys from the bag (no NPC buys
-- anything a shop sells, so in practice that is the Pokemon drops).
-- The server takes at most 100 of an item per request and the sell amount is a byte, so every trade goes
-- in steps of 100, a little apart.
local STEP = 100
local STEP_MS = 120
local MAX_LINE = 1000
local LAST_INVENTORY = 10
local BAD_COLOR = '#ff8a8a'
local ONLY_OWNED_SETTING = 'martOnlyOwned'

local CATEGORIES = {
    { id = 'balls', name = 'Balls' }, { id = 'potions', name = 'Potions' }, { id = 'tools', name = 'Tools' },
    { id = 'mail', name = 'Mail' }, { id = 'food', name = 'Food' }, { id = 'berries', name = 'Berries' },
    { id = 'held', name = 'Held items' }, { id = 'backpacks', name = 'Backpacks' }, { id = 'safari', name = 'Safari' },
    { id = 'clothes', name = 'Clothes' }, { id = 'furniture', name = 'Furniture' }, { id = 'other', name = 'Other' },
}

local window
local tab = 'buy'
local category = 'all'
local buyList, sellList = {}, {}
local goods = {} -- client item id -> count in the bag
local money = 0
local carts = { buy = {}, sell = {} } -- { entry, count }, in the order they were added
local npcName
local lastNpc
local queue, queueEvent = {}, nil

local function thousands(n)
    local text = tostring(math.floor(tonumber(n) or 0))
    return (text:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', ''))
end

local function dollars(n)
    return '$' .. thousands(n)
end

local function failure(text)
    if modules.game_textmessage then
        modules.game_textmessage.displayFailureMessage(text)
    end
end

local function titleCase(name)
    return (name:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b end))
end

-- the tiles and the cart leave out the "Pokemon" and "Empty" every potion and ball name starts with
local function shortName(name)
    return (name:gsub('^Pokemon ', ''):gsub('^Empty ', ''):gsub('Poke Ball Backpack$', 'Ball Backpack'))
end

local function infoOf(id)
    return MART_ITEMS[id] or {}
end

-- one line for the tile; the tooltip has the whole description
local function shortInfo(entry)
    local desc = entry.desc or ''
    local rate = desc:match('catch rate of this ball is (%S+)%.?')
    if rate then
        return tr('Catch rate %s', rate:gsub('%.$', ''))
    end
    local power = desc:match('regeneration for 1 minute%. Power: (%d+)')
    if power then
        return desc:find('energy') and tr('Energy regen %s, 1 min', power) or tr('Health regen %s, 1 min', power)
    end
    if desc:find('recharge a ball') then
        return tr('Revives a Pokemon')
    end
    if #desc > 0 and #desc <= 22 then
        return desc:gsub('%.$', '')
    end
    for _, cat in ipairs(CATEGORIES) do
        if cat.id == entry.cat then
            return tr(cat.name)
        end
    end
    return ''
end

local function tooltip(entry, action)
    local lines = { entry.name }
    if entry.desc then
        lines[#lines + 1] = entry.desc
    end
    if entry.weight > 0 then
        lines[#lines + 1] = tr('Weight: %.2f oz', entry.weight)
    end
    lines[#lines + 1] = action
    return table.concat(lines, '\n')
end

-- Steps -------------------------------------------------------------------------------------------------

local refresh

local function busy()
    return queueEvent ~= nil
end

-- the server answers every step with the goods and the inventory changes; rebuilding the list (a shop can
-- buy 250 items) for each of those slows the steps down, so those wait until the steps are done
local refreshEvent
local function requestRefresh()
    if refreshEvent or busy() then
        return
    end
    refreshEvent = scheduleEvent(function()
        refreshEvent = nil
        refresh()
    end, 50)
end

local function pump()
    local step = table.remove(queue, 1)
    if not step or not g_game.isOnline() or not window:isVisible() then
        queue, queueEvent = {}, nil
        refresh()
        return
    end
    step()
    queueEvent = scheduleEvent(pump, STEP_MS)
end

local function push(step)
    queue[#queue + 1] = step
    if not queueEvent then
        queueEvent = scheduleEvent(pump, 1)
    end
end

-- Goods -------------------------------------------------------------------------------------------------

local function equipped(id)
    local player = g_game.getLocalPlayer()
    local count = 0
    for slot = 1, LAST_INVENTORY do
        local item = player and player:getInventoryItem(slot)
        if item and item:getId() == id then
            count = count + item:getCount()
        end
    end
    return count
end

-- what can be sold: equipped items stay on, as in the legacy window
local function owned(entry)
    return math.max(0, (goods[entry.id] or 0) - equipped(entry.id))
end

local function freeCapacity()
    local player = g_game.getLocalPlayer()
    return player and player:getFreeCapacity() or 0
end

-- Cart --------------------------------------------------------------------------------------------------

local function cart()
    return carts[tab]
end

local function cartLine(entry, list)
    for index, line in ipairs(list or cart()) do
        if line.entry == entry then
            return line, index
        end
    end
    return nil
end

local function cartTotal()
    local total, weight = 0, 0
    for _, line in ipairs(cart()) do
        total = total + line.entry.price * line.count
        weight = weight + line.entry.weight * line.count
    end
    return total, weight
end

local function lineMax(entry)
    return tab == 'sell' and owned(entry) or MAX_LINE
end

local function addToCart(entry, amount)
    local list = cart()
    local line, index = cartLine(entry)
    if not line then
        line = { entry = entry, count = 0 }
        list[#list + 1] = line
        index = #list
    end
    local most = lineMax(entry)
    if amount > 0 and line.count >= most and tab == 'sell' then
        failure(tr('You only have %d %s.', most, entry.name))
    end
    line.count = math.max(0, math.min(most, line.count + amount))
    if line.count == 0 then
        table.remove(list, index)
    end
    refresh()
end

-- the sell cart can't hold more than the bag does, after a sale or a trade elsewhere
local function pruneSellCart()
    local list = carts.sell
    for index = #list, 1, -1 do
        local line = list[index]
        line.count = math.min(line.count, owned(line.entry))
        if line.count <= 0 then
            table.remove(list, index)
        end
    end
end

local function clickAmount()
    if g_keyboard.isCtrlPressed() then
        return 100
    elseif g_keyboard.isShiftPressed() then
        return 10
    end
    return 1
end

local function sendSteps(entry, amount, selling)
    local ptr = entry.ptr
    while amount > 0 do
        local step = math.min(STEP, amount)
        if selling then
            push(function() g_game.sellItem(ptr, step, true) end)
        else
            push(function() g_game.buyItem(ptr, step, false, false) end)
        end
        amount = amount - step
    end
end

local function buyCart()
    local total, weight = cartTotal()
    if total > money then
        failure(tr('You need %s more for this cart.', dollars(total - money)))
        return
    end
    local cap = freeCapacity()
    if weight > 0 and weight > cap then
        failure(tr('This cart weighs %.2f oz and you can carry %.2f oz more.', weight, cap))
        return
    end
    for _, line in ipairs(carts.buy) do
        sendSteps(line.entry, line.count, false)
    end
    carts.buy = {}
end

local function sellCart()
    pruneSellCart()
    for _, line in ipairs(carts.sell) do
        sendSteps(line.entry, line.count, true)
    end
    carts.sell = {}
end

local function confirmCart()
    if busy() or #cart() == 0 then
        return
    end
    if tab == 'sell' then
        sellCart()
    else
        buyCart()
    end
    refresh()
end

-- everything this NPC buys out of the bag, like the legacy window's Sell all
local function sellAllList()
    local list, count, total = {}, 0, 0
    for _, entry in ipairs(sellList) do
        local amount = owned(entry)
        if amount > 0 then
            list[#list + 1] = { entry = entry, count = amount }
            count, total = count + amount, total + amount * entry.price
        end
    end
    return list, count, total
end

local function sellAll()
    if busy() then
        return
    end
    local list = sellAllList()
    for _, line in ipairs(list) do
        sendSteps(line.entry, line.count, true)
    end
    carts.sell = {}
    refresh()
end

-- Filling -----------------------------------------------------------------------------------------------

local function matches(entry)
    local query = window.search:getText():lower()
    return query == '' or entry.name:lower():find(query, 1, true) ~= nil
end

local function onItemMouseRelease(entry)
    return function(widget, mousePos, button)
        if button == MouseRightButton then
            local menu = g_ui.createWidget('PopupMenu')
            menu:setGameMenu(true)
            menu:addOption(tr('Look'), function() g_game.inspectNpcTrade(entry.ptr) end)
            menu:display(mousePos)
            return true
        end
        return false
    end
end

local function sellable()
    local list = {}
    for _, entry in ipairs(sellList) do
        if owned(entry) > 0 then
            list[#list + 1] = entry
        end
    end
    table.sort(list, function(a, b) return owned(a) * a.price > owned(b) * b.price end)
    return list
end

local function fillChips(list)
    window.chips:destroyChildren()
    local counts = {}
    for _, entry in ipairs(list) do
        counts[entry.cat] = (counts[entry.cat] or 0) + 1
    end
    local function chip(id, name, count)
        local widget = g_ui.createWidget('MartChip', window.chips)
        widget:setText(tr(name) .. '  ' .. count)
        widget:setOn(category == id)
        widget.onClick = function()
            category = id
            refresh()
        end
    end
    chip('all', 'All', #list)
    for _, cat in ipairs(CATEGORIES) do
        if counts[cat.id] then
            chip(cat.id, cat.name, counts[cat.id])
        end
    end
end

local function fillSellFilters(mine)
    window.chips:destroyChildren()
    local all = g_ui.createWidget('MartChip', window.chips)
    local onlyOwned = g_settings.getBoolean(ONLY_OWNED_SETTING)
    all:setText(tr('All items') .. '  ' .. #sellList)
    all:setOn(not onlyOwned)
    all:setTooltip(tr('Everything %s buys', npcName or tr('this shop')))
    all.onClick = function()
        g_settings.set(ONLY_OWNED_SETTING, false)
        refresh()
    end
    local owned = g_ui.createWidget('MartChip', window.chips)
    owned:setText(tr('Only items I have') .. '  ' .. #mine)
    owned:setOn(onlyOwned)
    owned.onClick = function()
        g_settings.set(ONLY_OWNED_SETTING, true)
        refresh()
    end
end

local function fillGrid(list)
    window.grid:destroyChildren()
    local shown = 0
    for _, entry in ipairs(list) do
        if (category == 'all' or entry.cat == category) and matches(entry) then
            local tile = g_ui.createWidget('MartTile', window.grid)
            tile.face.item:setItemId(entry.id)
            tile.name:setText(shortName(entry.name))
            tile.price:setText(dollars(entry.price))
            tile.info:setText(shortInfo(entry))
            local line = cartLine(entry)
            tile:setChecked(line ~= nil)
            tile.badge:setVisible(line ~= nil)
            tile.badge:setText(line and ('x' .. line.count) or '')
            tile:setOn(entry.price > money)
            tile:setTooltip(tooltip(entry, tr('Click adds 1, Shift+click 10, Ctrl+click 100. Right-click to look.')))
            tile.onClick = function() addToCart(entry, clickAmount()) end
            tile.onMouseRelease = onItemMouseRelease(entry)
            shown = shown + 1
        end
    end
    window.none:setVisible(shown == 0)
    window.none:setText(#list == 0 and tr('%s doesn\'t sell anything. Try the Sell tab.', npcName or tr('This shop'))
        or tr('Nothing here matches your search.'))
end

local fillCart

-- the amount typed in a Sell row goes straight in the cart; the list isn't rebuilt so the field keeps focus
local function setSellAmount(entry, amount, row)
    local list = carts.sell
    local line, index = cartLine(entry, list)
    amount = math.max(0, math.min(owned(entry), amount))
    if amount > 0 and not line then
        list[#list + 1] = { entry = entry, count = amount }
    elseif line and amount == 0 then
        table.remove(list, index)
    elseif line then
        line.count = amount
    end
    if row then
        row:setChecked(amount > 0)
        row.total:setText(amount > 0 and dollars(amount * entry.price) or '')
    end
    fillCart()
end

local function fillSellList()
    window.sellList:destroyChildren()
    local mine, others = {}, {}
    local onlyOwned = g_settings.getBoolean(ONLY_OWNED_SETTING)
    for _, entry in ipairs(sellList) do
        local have = owned(entry) > 0
        if matches(entry) and (have or not onlyOwned) then
            local into = have and mine or others
            into[#into + 1] = entry
        end
    end
    table.sort(mine, function(a, b) return owned(a) * a.price > owned(b) * b.price end)
    table.sort(others, function(a, b) return a.name < b.name end)
    for _, group in ipairs({ mine, others }) do
        for _, entry in ipairs(group) do
            local row = g_ui.createWidget('MartSellRow', window.sellList)
            local have = owned(entry)
            local line = cartLine(entry, carts.sell)
            local amount = line and line.count or 0
            row.face.item:setItemId(entry.id)
            row.name:setText(entry.name)
            row.owned:setText(tr('In your bag: %d  \183  %s each', have, dollars(entry.price)))
            row.total:setText(amount > 0 and dollars(amount * entry.price) or '')
            row:setOn(have == 0)
            row:setChecked(amount > 0)
            row.amount:setText(tostring(amount))
            for _, control in ipairs({ row.amount, row.minus, row.plus, row.max }) do
                control:setEnabled(have > 0)
            end
            row.amount.onTextChange = function(widget, text)
                local digits = text:gsub('%D', '')
                if digits ~= text then
                    widget:setText(digits)
                    return
                end
                local value = tonumber(digits) or 0
                if value > owned(entry) then
                    widget:setText(tostring(owned(entry)))
                    return
                end
                setSellAmount(entry, value, row)
            end
            local function step(by)
                local now = tonumber(row.amount:getText()) or 0
                row.amount:setText(tostring(math.max(0, math.min(owned(entry), now + by))))
            end
            row.minus.onClick = function() step(g_keyboard.isShiftPressed() and -10 or -1) end
            row.plus.onClick = function() step(g_keyboard.isShiftPressed() and 10 or 1) end
            row.max.onClick = function() row.amount:setText(tostring(owned(entry))) end
            row:setTooltip(tooltip(entry, have > 0 and tr('You have %d. Type how many to sell, or use - + and Max.', have)
                or tr('You have none of these.')))
            row.onMouseRelease = onItemMouseRelease(entry)
        end
    end
    window.none:setVisible(#mine + #others == 0)
    if #sellList == 0 then
        window.none:setText(tr('%s doesn\'t buy anything.', npcName or tr('This shop')))
    elseif window.search:getText() ~= '' then
        window.none:setText(tr('Nothing here matches your search.'))
    else
        window.none:setText(tr('You have nothing %s buys.', npcName or tr('this shop')))
    end
end

fillCart = function()
    local panel = window.cart
    local selling = tab == 'sell'
    local list = cart()
    panel.title:setText(selling and tr('Selling (%d)', #list) or tr('Cart (%d)', #list))
    panel.clear:setEnabled(#list > 0)
    panel.list:destroyChildren()
    for _, line in ipairs(list) do
        local row = g_ui.createWidget('MartCartRow', panel.list)
        local entry = line.entry
        row.face.item:setItemId(entry.id)
        row.name:setText(shortName(entry.name))
        row.count:setText(tostring(line.count))
        row.price:setText(dollars(entry.price * line.count))
        row.minus.onClick = function() addToCart(entry, -1) end
        row.plus.onClick = function() addToCart(entry, 1) end
        row.add10.onClick = function() addToCart(entry, 10) end
        row.add100.onClick = function() addToCart(entry, 100) end
        row.remove.onClick = function() addToCart(entry, -line.count) end
        row:setTooltip(tooltip(entry, selling and tr('%s each, you have %d', dollars(entry.price), owned(entry))
            or tr('%s each', dollars(entry.price))))
    end
    panel.empty:setVisible(#list == 0)
    panel.empty:setText(selling and tr('Enter how many of each item to sell on the left.')
        or tr('Click an item on the left to put it in your cart.'))

    local total = cartTotal()
    panel.total.caption:setText(selling and tr('You get') or tr('Total'))
    panel.total.value:setText(dollars(total))
    panel.after.caption:setText(tr('Money after'))
    if selling then
        panel.after.value:setText(dollars(money + total))
        panel.after.value:setColor('#ffffff')
    else
        panel.after.value:setText(total > money and tr('%s short', dollars(total - money)) or dollars(money - total))
        panel.after.value:setColor(total > money and BAD_COLOR or '#ffffff')
    end

    panel.confirm:setEnabled(#list > 0 and not busy())
    if busy() then
        panel.confirm:setText(selling and tr('Selling...') or tr('Buying...'))
    else
        panel.confirm:setText(selling and tr('Sell') or tr('Buy'))
    end
    panel.confirm:addAnchor(AnchorBottom, selling and 'sellAll' or 'hint', AnchorTop)
    panel.hint:setText(selling and tr('Sell all sells everything %s buys from your bag.', npcName or tr('this shop'))
        or tr('Click a tile to add 1. Shift+click adds 10, Ctrl+click adds 100.'))

    panel.sellAll:setVisible(selling)
    if selling then
        local all, count, value = sellAllList()
        panel.sellAll:setEnabled(count > 0 and not busy())
        panel.sellAll:setText(tr('Sell all (%s)', thousands(count)))
        local lines = { tr('Sells everything %s buys from your bag:', npcName or tr('this shop')) }
        for _, line in ipairs(all) do
            lines[#lines + 1] = tr('%d %s (%s)', line.count, line.entry.name, dollars(line.count * line.entry.price))
        end
        lines[#lines + 1] = tr('Total: %s', dollars(value))
        panel.sellAll:setTooltip(count > 0 and table.concat(lines, '\n') or nil)
    end
end

refresh = function()
    if not window or not window:isVisible() then
        return
    end
    g_tooltip.hide()
    pruneSellCart()
    local selling = tab == 'sell'
    local mine = sellable()
    window.moneyPanel.money:setText(dollars(money))
    window.buyTab:setText(tr('Buy (%d)', #buyList))
    window.sellTab:setText(tr('Sell (%d)', #mine))
    window.buyTab:setOn(not selling)
    window.sellTab:setOn(selling)
    window.buyTab:setEnabled(#buyList > 0)
    window.sellTab:setEnabled(#sellList > 0)
    window.grid:setVisible(not selling)
    window.gridScroll:setVisible(not selling)
    window.sellList:setVisible(selling)
    window.sellScroll:setVisible(selling)
    if selling then
        fillSellFilters(mine)
        fillSellList()
    else
        fillChips(buyList)
        fillGrid(buyList)
    end
    fillCart()
end

-- Window ------------------------------------------------------------------------------------------------

local function stop()
    if queueEvent then
        removeEvent(queueEvent)
    end
    if refreshEvent then
        removeEvent(refreshEvent)
        refreshEvent = nil
    end
    queue, queueEvent = {}, nil
end

local function hideWindow()
    stop()
    if window then
        window:hide()
    end
    carts = { buy = {}, sell = {} }
end

function close()
    if window and window:isVisible() then
        g_game.closeNpcTrade()
    end
    hideWindow()
end

local function hideDialog()
    if modules.game_npcdialog and modules.game_npcdialog.hide then
        modules.game_npcdialog.hide()
    end
end

local function entryOf(item, price)
    local ptr = item[1]
    local id = ptr:getId()
    local info = infoOf(id)
    return { ptr = ptr, id = id, name = titleCase(item[2]), weight = (item[3] or 0) / 100, price = price,
             cat = info.c or 'other', desc = info.d }
end

local function onOpenNpcTrade(items)
    buyList, sellList = {}, {}
    for _, item in ipairs(items) do
        if item[4] > 0 then
            buyList[#buyList + 1] = entryOf(item, item[4])
        end
        if item[5] > 0 then
            sellList[#sellList + 1] = entryOf(item, item[5])
        end
    end
    local wasOpen = window:isVisible()
    if not wasOpen or npcName ~= lastNpc then
        carts, category = { buy = {}, sell = {} }, 'all'
        tab = #buyList > 0 and 'buy' or 'sell'
        window.search:setText('')
        local root = rootWidget:getSize()
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                             y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
    end
    npcName = lastNpc
    window.subtitle:setText(npcName and tr('%s  \183  Buy supplies, sell what your Pokemon find', npcName)
        or tr('Buy supplies, sell what your Pokemon find'))
    window:show()
    window:raise()
    window:focus()
    hideDialog()
    refresh()
end

local function onPlayerGoods(playerMoney, items)
    money = playerMoney or 0
    goods = {}
    for _, item in ipairs(items or {}) do
        local id = item[1]:getId()
        goods[id] = (goods[id] or 0) + item[2]
    end
    requestRefresh()
end

local function onTalk(name, level, mode)
    if mode ~= MessageModes.NpcFrom and mode ~= MessageModes.NpcFromStartBlock then
        return
    end
    if window and window:isVisible() and name == npcName then
        -- the NPC's "here are my offers" comes after the window opens
        scheduleEvent(hideDialog, 50)
        return
    end
    lastNpc = name
end

local function setTab(name)
    if tab ~= name then
        tab, category = name, 'all'
        window.search:setText('')
        refresh()
    end
end

local function onGameEnd()
    hideWindow()
    buyList, sellList, goods, money, npcName, lastNpc = {}, {}, {}, 0, nil, nil
end

function isOpen()
    return window ~= nil and window:isVisible()
end

function init()
    g_ui.importStyle('mart')
    window = g_ui.createWidget('MartWindow', rootWidget)
    window:hide()
    window.buyTab.onClick = function() setTab('buy') end
    window.sellTab.onClick = function() setTab('sell') end
    window.search.onTextChange = function() refresh() end
    window.cart.clear.onClick = function()
        carts[tab] = {}
        refresh()
    end
    window.cart.confirm.onClick = confirmCart
    window.cart.sellAll.onClick = sellAll

    connect(g_game, {
        onOpenNpcTrade = onOpenNpcTrade,
        onPlayerGoods = onPlayerGoods,
        onCloseNpcTrade = hideWindow,
        onNpcChatWindowClose = hideWindow,
        onTalk = onTalk,
        onGameEnd = onGameEnd,
    })
    connect(LocalPlayer, { onFreeCapacityChange = requestRefresh, onInventoryChange = requestRefresh })
end

function terminate()
    disconnect(g_game, {
        onOpenNpcTrade = onOpenNpcTrade,
        onPlayerGoods = onPlayerGoods,
        onCloseNpcTrade = hideWindow,
        onNpcChatWindowClose = hideWindow,
        onTalk = onTalk,
        onGameEnd = onGameEnd,
    })
    disconnect(LocalPlayer, { onFreeCapacityChange = requestRefresh, onInventoryChange = requestRefresh })
    stop()
    if window then
        window:destroy()
    end
    window = nil
end
