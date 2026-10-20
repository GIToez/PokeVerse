-- The Poke Mart window. It takes over every NPC shop from game_npctrade's legacy window (which stays hidden
-- while this module is loaded): onOpenNpcTrade fills it, onPlayerGoods keeps the money and the bag counts
-- current and onCloseNpcTrade closes it.
--
-- Buy keeps a cart; Buy all checks the money and the capacity first and then buys line by line. Sell lists
-- what the NPC buys from the bag; Sell all sells everything not ticked Keep (remembered per NPC; anything a
-- shop sells starts kept, so only the Pokemon drops go by default) and clicking a row sells that item.
-- The server takes at most 100 of an item per request and the sell amount is a byte, so every trade goes
-- in steps of 100, a little apart.
local STEP = 100
local STEP_MS = 120
local MAX_LINE = 1000
local LAST_INVENTORY = 10
local KEEP_NODE = 'mart_keep'
local OK_COLOR = '#7ee08f'
local BAD_COLOR = '#ff8a8a'
local MUTED_COLOR = '#96aacd'

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
local cart = {} -- { entry, count }, in the order they were added
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

local function owned(entry)
    return math.max(0, (goods[entry.id] or 0) - equipped(entry.id))
end

local function freeCapacity()
    local player = g_game.getLocalPlayer()
    return player and player:getFreeCapacity() or 0
end

-- Keep --------------------------------------------------------------------------------------------------

local function keepTable()
    local all = g_settings.getNode(KEEP_NODE) or {}
    return all[npcName or ''] or {}
end

local function isKept(entry)
    local value = keepTable()[tostring(entry.id)]
    if value == nil then
        return infoOf(entry.id).c ~= nil
    end
    return value
end

local function setKept(entry, kept)
    local all = g_settings.getNode(KEEP_NODE) or {}
    local mine = all[npcName or ''] or {}
    mine[tostring(entry.id)] = kept
    all[npcName or ''] = mine
    g_settings.setNode(KEEP_NODE, all)
end

-- Cart --------------------------------------------------------------------------------------------------

local function cartLine(entry)
    for index, line in ipairs(cart) do
        if line.entry == entry then
            return line, index
        end
    end
    return nil
end

local function cartTotal()
    local total, weight = 0, 0
    for _, line in ipairs(cart) do
        total = total + line.entry.price * line.count
        weight = weight + line.entry.weight * line.count
    end
    return total, weight
end

local function addToCart(entry, amount)
    local line = cartLine(entry)
    if not line then
        line = { entry = entry, count = 0 }
        cart[#cart + 1] = line
    end
    line.count = math.max(0, math.min(MAX_LINE, line.count + amount))
    if line.count == 0 then
        local _, index = cartLine(entry)
        table.remove(cart, index)
    end
    refresh()
end

local function clickAmount()
    if g_keyboard.isCtrlPressed() then
        return 100
    elseif g_keyboard.isShiftPressed() then
        return 10
    end
    return 1
end

local function buyAll()
    if busy() or #cart == 0 then
        return
    end
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
    for _, line in ipairs(cart) do
        local ptr, left = line.entry.ptr, line.count
        while left > 0 do
            local amount = math.min(STEP, left)
            push(function() g_game.buyItem(ptr, amount, false, false) end)
            left = left - amount
        end
    end
    cart = {}
    refresh()
end

-- Selling -----------------------------------------------------------------------------------------------

local function sellEntry(entry, amount)
    local ptr = entry.ptr
    while amount > 0 do
        local step = math.min(STEP, amount)
        push(function() g_game.sellItem(ptr, step, true) end)
        amount = amount - step
    end
end

local function sellOne(entry)
    if busy() then
        return
    end
    local amount = owned(entry)
    if amount > 0 then
        sellEntry(entry, amount)
        refresh()
    end
end

local function sellSummary()
    local count, kinds, keptKinds, value = 0, 0, 0, 0
    for _, entry in ipairs(sellList) do
        local amount = owned(entry)
        if amount > 0 then
            if isKept(entry) then
                keptKinds = keptKinds + 1
            else
                count, kinds, value = count + amount, kinds + 1, value + amount * entry.price
            end
        end
    end
    return count, kinds, keptKinds, value
end

local function sellAll()
    if busy() then
        return
    end
    local any = false
    for _, entry in ipairs(sellList) do
        local amount = owned(entry)
        if amount > 0 and not isKept(entry) then
            sellEntry(entry, amount)
            any = true
        end
    end
    if not any then
        failure(tr('Nothing to sell: everything here is kept.'))
    end
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

local function fillChips()
    window.chips:destroyChildren()
    local counts, all = {}, 0
    for _, entry in ipairs(buyList) do
        counts[entry.cat] = (counts[entry.cat] or 0) + 1
        all = all + 1
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
    chip('all', 'All', all)
    for _, cat in ipairs(CATEGORIES) do
        if counts[cat.id] then
            chip(cat.id, cat.name, counts[cat.id])
        end
    end
end

local function fillGrid()
    window.grid:destroyChildren()
    local shown = 0
    for _, entry in ipairs(buyList) do
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
    window.none:setText(#buyList == 0 and tr('%s doesn\'t sell anything. Try the Sell tab.', npcName or tr('This shop'))
        or tr('Nothing here matches your search.'))
end

local function fillCart()
    local panel = window.cart
    panel.title:setText(tr('Cart (%d)', #cart))
    panel.clear:setEnabled(#cart > 0)
    panel.list:destroyChildren()
    for _, line in ipairs(cart) do
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
        row:setTooltip(tooltip(entry, tr('%s each', dollars(entry.price))))
    end
    panel.empty:setVisible(#cart == 0)
    local total = cartTotal()
    panel.total.caption:setText(tr('Total'))
    panel.total.value:setText(dollars(total))
    panel.after.caption:setText(tr('Money after'))
    panel.after.value:setText(total > money and tr('%s short', dollars(total - money)) or dollars(money - total))
    panel.after.value:setColor(total > money and BAD_COLOR or '#ffffff')
    panel.buy:setEnabled(#cart > 0 and not busy())
    panel.buy:setText(busy() and tr('Buying...') or tr('Buy all'))
    panel.hint:setText(tr('Click a tile to add 1. Shift+click adds 10, Ctrl+click adds 100.'))
end

local function fillSellList()
    window.sellList:destroyChildren()
    local shown = {}
    for _, entry in ipairs(sellList) do
        if owned(entry) > 0 and matches(entry) then
            shown[#shown + 1] = entry
        end
    end
    table.sort(shown, function(a, b)
        local ka, kb = isKept(a), isKept(b)
        if ka ~= kb then
            return kb
        end
        return owned(a) * a.price > owned(b) * b.price
    end)
    for _, entry in ipairs(shown) do
        local row = g_ui.createWidget('MartSellRow', window.sellList)
        local amount, kept = owned(entry), isKept(entry)
        row.face.item:setItemId(entry.id)
        row.name:setText(entry.name)
        row.owned:setText(tr('In your bag: %d', amount))
        row.each:setText(tr('%s each', dollars(entry.price)))
        row.total:setText(kept and tr('kept') or dollars(amount * entry.price))
        row.total:setColor(kept and MUTED_COLOR or OK_COLOR)
        row:setOn(kept)
        row.keep:setChecked(kept)
        row.keep.onCheckChange = function(widget, checked)
            if checked ~= isKept(entry) then
                setKept(entry, checked)
                addEvent(refresh) -- this row is rebuilt
            end
        end
        row:setTooltip(tooltip(entry, tr('Click to sell all %d for %s.', amount, dollars(amount * entry.price))))
        row.onClick = function() sellOne(entry) end
        row.onMouseRelease = onItemMouseRelease(entry)
    end
    window.none:setVisible(#shown == 0)
    window.none:setText(window.search:getText() ~= '' and tr('Nothing here matches your search.')
        or tr('You have nothing %s buys.', npcName or tr('this shop')))
end

local function fillSellPanel()
    local panel = window.sellPanel
    local count, kinds, keptKinds, value = sellSummary()
    panel.text:setText(tr('Sells every item in your bag that %s buys, except the ones you keep.',
        npcName or tr('this shop')))
    panel.text2:setText(tr('Kept items stay kept here next time. Things the shops sell start kept, so Sell all ' ..
        'only takes what your Pokemon find.'))
    panel.items.caption:setText(tr('Items'))
    panel.items.value:setText(thousands(count))
    panel.kept.caption:setText(tr('Kept'))
    panel.kept.value:setText(keptKinds == 1 and tr('1 kind') or tr('%d kinds', keptKinds))
    panel.get.caption:setText(tr('You get'))
    panel.get.value:setText(dollars(value))
    panel.sellAll:setEnabled(count > 0 and not busy())
    panel.sellAll:setText(busy() and tr('Selling...') or tr('Sell all (%s)', thousands(count)))
end

local function sellableKinds()
    local kinds = 0
    for _, entry in ipairs(sellList) do
        if owned(entry) > 0 then
            kinds = kinds + 1
        end
    end
    return kinds
end

refresh = function()
    if not window or not window:isVisible() then
        return
    end
    g_tooltip.hide()
    window.moneyPanel.money:setText(dollars(money))
    window.buyTab:setText(tr('Buy (%d)', #buyList))
    window.sellTab:setText(tr('Sell (%d)', sellableKinds()))
    window.buyTab:setOn(tab == 'buy')
    window.sellTab:setOn(tab == 'sell')
    window.buyTab:setEnabled(#buyList > 0)
    window.sellTab:setEnabled(#sellList > 0)
    local buying = tab == 'buy'
    window.chips:setVisible(buying)
    window.grid:setVisible(buying)
    window.gridScroll:setVisible(buying)
    window.cart:setVisible(buying)
    window.sellList:setVisible(not buying)
    window.sellScroll:setVisible(not buying)
    window.sellPanel:setVisible(not buying)
    window.none:addAnchor(AnchorTop, buying and 'chips' or 'buyTab', AnchorBottom)
    if buying then
        fillChips()
        fillGrid()
        fillCart()
    else
        fillSellList()
        fillSellPanel()
    end
end

-- Window ------------------------------------------------------------------------------------------------

local function stop()
    if queueEvent then
        removeEvent(queueEvent)
    end
    queue, queueEvent = {}, nil
end

local function hideWindow()
    stop()
    if window then
        window:hide()
    end
    cart = {}
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
        cart, category = {}, 'all'
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
    for index = #cart, 1, -1 do
        if cart[index].count <= 0 then
            table.remove(cart, index)
        end
    end
    refresh()
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
        tab = name
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
        cart = {}
        refresh()
    end
    window.cart.buy.onClick = buyAll
    window.sellPanel.sellAll.onClick = sellAll

    connect(g_game, {
        onOpenNpcTrade = onOpenNpcTrade,
        onPlayerGoods = onPlayerGoods,
        onCloseNpcTrade = hideWindow,
        onNpcChatWindowClose = hideWindow,
        onTalk = onTalk,
        onGameEnd = onGameEnd,
    })
    connect(LocalPlayer, { onFreeCapacityChange = refresh, onInventoryChange = refresh })
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
    disconnect(LocalPlayer, { onFreeCapacityChange = refresh, onInventoryChange = refresh })
    stop()
    if window then
        window:destroy()
    end
    window = nil
end
