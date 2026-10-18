-- The Pokemon Trade window. Ron and Joel Morris open it (PokemonShop.open in the server lib); the server talks
-- JSON on ExtendedIds.PokemonShop: {type = "shop", npc, town, greeting, money, party, boxes, box, list, rules}
-- fills the window, {type = "box", box, boxes, list} swaps the PC box shown, {type = "result", ok, text, total, rare}
-- answers a sale and {type = "close"} closes it. The window sends {action = "hello"} at login (so the NPCs know to
-- open it instead of talking), {action = "box", box} and {action = "sell", keys, confirm, box}.
--
-- The basket keeps Pokemon from the party and from any box; the server checks them all again when they are sold.
local PORTRAITS = '/images/staticPortraits/'
local OK_COLOR = '#7ee08f'
local BAD_COLOR = '#ff8a8a'
local GOLD_COLOR = '#ffd75a'
local CHEAP = 500
local SORTS = {
    { name = 'Price', less = function(a, b) return a.price > b.price end },
    { name = 'Level', less = function(a, b) return a.level > b.level end },
    { name = 'Name', less = function(a, b) return a.name < b.name end },
}

local window
local confirmWindow
local state -- the last {type = "shop"} message, with the box messages merged in
local tab = 'party'
local sortIndex = 1
local basket = {} -- the picked entries, in the order they were picked
local openPos -- where the trainer stood when the window opened

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.PokemonShop, data)
    end
end

local function thousands(n)
    local text = tostring(math.floor(tonumber(n) or 0))
    return (text:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', ''))
end

local function dollars(n)
    return '$' .. thousands(n)
end

local function rules()
    return (state and state.rules) or {}
end

local function failure(text)
    if modules.game_textmessage then
        modules.game_textmessage.displayFailureMessage(text)
    end
end

-- the Pokemon bar's face, else the portrait with its empty border trimmed
local function setFace(face, entry)
    if entry.face then
        face.item:setItemId(entry.face)
        face.item:show()
        face.portrait:hide()
    else
        local inset = 14
        face.portrait:setImageSource(PORTRAITS .. (tonumber(entry.number) or 0))
        face.portrait:setImageClip({ x = inset, y = inset, width = 96 - 2 * inset, height = 96 - 2 * inset })
        face.portrait:show()
        face.item:hide()
    end
end

local function priceMath(entry)
    return tr('%s + %d x %s', dollars(entry.base), entry.level, dollars(rules().perLevel or 5))
end

local function tooltip(entry)
    local lines = { entry.nickname and string.format('%s (%s)', entry.nickname, entry.name) or entry.name,
                    tr('Level %d', entry.level) }
    if entry.nature then
        lines[#lines + 1] = tr('%s nature  |  IV %d/186  |  %d perfect', entry.nature, entry.ivs or 0, entry.perfect or 0)
    end
    lines[#lines + 1] = entry.held and tr('Holds %s (it goes back to your bag)', entry.held) or tr('No held item')
    lines[#lines + 1] = tr('Price: %s = %s', priceMath(entry), dollars(entry.price))
    if entry.blocked then
        lines[#lines + 1] = tr('Can\'t be sold: %s', entry.blocked)
    elseif entry.rare then
        lines[#lines + 1] = tr('Rare: you will be asked to type SELL')
    end
    return table.concat(lines, '\n')
end

-- Basket ------------------------------------------------------------------------------------------------

local function basketIndex(key)
    for index, entry in ipairs(basket) do
        if entry.key == key then
            return index
        end
    end
    return nil
end

local function partyInBasket()
    local count = 0
    for _, entry in ipairs(basket) do
        count = count + (entry.box and 0 or 1)
    end
    return count
end

local function basketTotal()
    local total = 0
    for _, entry in ipairs(basket) do
        total = total + entry.price
    end
    return total
end

-- why this entry can't go in the basket, or nil
local function addBlocker(entry)
    if entry.blocked then
        return tr('%s can\'t be sold: %s.', entry.name, entry.blocked:lower())
    elseif #basket >= (rules().max or 30) then
        return tr('You can sell up to %d Pokemon at a time.', rules().max or 30)
    elseif not entry.box and partyInBasket() + 1 >= #(state.party or {}) then
        return tr('Keep at least one Pokemon with you.')
    end
    return nil
end

local refresh

local function toggle(entry)
    local index = basketIndex(entry.key)
    if index then
        table.remove(basket, index)
    else
        local blocker = addBlocker(entry)
        if blocker then
            failure(blocker)
            return
        end
        basket[#basket + 1] = entry
    end
    refresh()
end

-- swaps the basket's entries for the fresh ones; Pokemon gone (or blocked now) leave it
local function prune()
    local fresh = {}
    for _, entry in ipairs(state.party or {}) do
        fresh[entry.key] = entry
    end
    for _, entry in ipairs(state.list or {}) do
        fresh[entry.key] = entry
    end
    local kept = {}
    for _, entry in ipairs(basket) do
        local now = fresh[entry.key]
        local elsewhere = entry.box and entry.box ~= state.box
        if now and not now.blocked then
            kept[#kept + 1] = now
        elseif not now and elsewhere then
            kept[#kept + 1] = entry
        end
    end
    basket = kept
end

local function fillBasket()
    local panel = window.basket
    panel.title:setText(tr('Selling (%d)', #basket))
    panel.clear:setEnabled(#basket > 0)
    panel.list:destroyChildren()
    for _, entry in ipairs(basket) do
        local row = g_ui.createWidget('ShopBasketRow', panel.list)
        setFace(row.face, entry)
        row.name:setText(entry.name)
        row.where:setText(tr('Lv %d', entry.level) .. '  \183  ' .. (entry.box and tr('Box %d', entry.box) or tr('Party')))
        row.math:setText(priceMath(entry))
        row.price:setText(dollars(entry.price))
        row.price:setColor(entry.rare and GOLD_COLOR or OK_COLOR)
        row:setTooltip(tooltip(entry))
        row.remove:setTooltip(tr('Take %s out', entry.name))
        row.remove.onClick = function() toggle(entry) end
    end
    panel.empty:setVisible(#basket == 0)
    local total = basketTotal()
    panel.total:setText(dollars(total))
    panel.note1.text:setText(tr('Held items go back to your bag.'))
    panel.note2.text:setText(tr('Prices: species price + %s per level.', dollars(rules().perLevel or 5)))
    panel.sell:setEnabled(#basket > 0)
    panel.sell:setText(#basket > 0 and tr('Sell %d for %s', #basket, dollars(total)) or tr('Pick Pokemon to sell'))
end

-- List --------------------------------------------------------------------------------------------------

local function shownEntries()
    local source = (tab == 'party' and state.party or state.list) or {}
    local query = window.search:getText():lower()
    local shown = {}
    for _, entry in ipairs(source) do
        if query == '' or entry.name:lower():find(query, 1, true) or
            (entry.nickname and entry.nickname:lower():find(query, 1, true)) then
            shown[#shown + 1] = entry
        end
    end
    table.sort(shown, SORTS[sortIndex].less)
    return shown
end

local function fillCard(card, entry)
    setFace(card.face, entry)
    card.name:setText(entry.name)
    local details = { tr('Lv %d', entry.level) }
    if (entry.perfect or 0) >= (rules().rareIvs or 5) then
        details[#details + 1] = tr('%d perfect IVs', entry.perfect)
    elseif entry.held then
        details[#details + 1] = entry.held
    end
    card.level:setText(table.concat(details, '  \183  '))
    local blocked = entry.blocked ~= nil
    card:setOn(blocked)
    card.price:setVisible(not blocked)
    card.price:setText(dollars(entry.price))
    card.price:setColor(entry.rare and GOLD_COLOR or OK_COLOR)
    card.lock:setVisible(blocked)
    card.reason:setVisible(blocked)
    card.reason:setText(entry.blocked or '')
    local picked = basketIndex(entry.key) ~= nil
    card:setChecked(picked)
    card.check:setVisible(picked)
    card:setTooltip(tooltip(entry))
    card.onClick = function() toggle(entry) end
end

local function currentBoxIndex()
    for index, box in ipairs(state.boxes or {}) do
        if box.box == state.box then
            return index
        end
    end
    return nil
end

local function fillBoxBar()
    local bar = window.boxBar
    local boxes = state.boxes or {}
    local index = currentBoxIndex()
    bar.prev:setVisible(tab == 'pc')
    bar.next:setVisible(tab == 'pc')
    if tab ~= 'pc' then
        bar.title:setText(tr('Your party'))
        bar.count:setText(tr('The Pokemon you carry. One always stays with you.'))
        return
    end
    local box = index and boxes[index]
    if box then
        local title = tr('Box %d', box.box)
        bar.title:setText(box.name ~= title and (title .. '  \183  ' .. box.name) or title)
        bar.count:setText(tr('%d Pokemon', box.count))
    else
        bar.title:setText(tr('PC Storage'))
        bar.count:setText('')
    end
    bar.prev:setEnabled(index ~= nil and index > 1)
    bar.next:setEnabled(index ~= nil and index < #boxes)
end

local function fillList()
    window.grid:destroyChildren()
    local shown = shownEntries()
    for _, entry in ipairs(shown) do
        fillCard(g_ui.createWidget('ShopCard', window.grid), entry)
    end
    window.none:setVisible(#shown == 0)
    if window.search:getText() ~= '' then
        window.none:setText(tr('No Pokemon here match your search.'))
    elseif tab == 'party' then
        window.none:setText(tr('You aren\'t carrying any Pokemon.'))
    else
        window.none:setText(tr('Your PC boxes are empty.'))
    end
end

local function fillTabs()
    local stored = 0
    for _, box in ipairs(state.boxes or {}) do
        stored = stored + (box.count or 0)
    end
    window.partyTab:setText(tr('Party (%d)', #(state.party or {})))
    window.pcTab:setText(tr('PC Storage (%d)', stored))
    window.partyTab:setOn(tab == 'party')
    window.pcTab:setOn(tab == 'pc')
    window.sort:setText(tr(SORTS[sortIndex].name) .. '  v')
    window.addCheap:setText(tr('Add everything under %s', dollars(CHEAP)))
    window.addCheapNote:setText(tr('Skips shinies, %d+ perfect IVs and protected Pokemon', rules().rareIvs or 5))
end

refresh = function()
    if not state then
        return
    end
    g_tooltip.hide() -- the hovered card may be rebuilt below
    fillTabs()
    fillBoxBar()
    fillList()
    fillBasket()
end

local function addCheap()
    local added = 0
    for _, entry in ipairs(shownEntries()) do
        if entry.price < CHEAP and not entry.rare and not basketIndex(entry.key) and not addBlocker(entry) then
            basket[#basket + 1] = entry
            added = added + 1
        end
    end
    if added == 0 then
        failure(tr('Nothing else here goes for less than %s.', dollars(CHEAP)))
    end
    refresh()
end

-- Selling -----------------------------------------------------------------------------------------------

function cancelConfirm()
    if confirmWindow then
        confirmWindow:destroy()
        confirmWindow = nil
        if window and window:isVisible() then
            window:focus()
        end
    end
end

local function sendSale(confirm)
    local keys = {}
    for _, entry in ipairs(basket) do
        keys[#keys + 1] = entry.key
    end
    if #keys > 0 then
        send({ action = 'sell', keys = keys, confirm = confirm, box = state.box })
    end
end

local function askConfirm(names)
    cancelConfirm()
    confirmWindow = g_ui.createWidget('PokemonShopConfirm', rootWidget)
    local list = #names == 1 and names[1] or tr('%s and %s', table.concat(names, ', ', 1, #names - 1), names[#names])
    confirmWindow.text:setText(tr('%s can\'t be bought back once sold. Type SELL to sell %d Pokemon for %s.', list,
        #basket, dollars(basketTotal())))
    local root = rootWidget:getSize()
    confirmWindow:setPosition({ x = math.floor((root.width - confirmWindow:getWidth()) / 2),
                                y = math.max(0, math.floor((root.height - confirmWindow:getHeight()) / 2)) })
    local function update()
        confirmWindow.confirm:setEnabled(confirmWindow.field:getText():upper() == 'SELL')
    end
    local function confirm()
        if confirmWindow and confirmWindow.confirm:isEnabled() then
            cancelConfirm()
            sendSale('SELL')
        end
    end
    confirmWindow.field.onTextChange = update
    confirmWindow.field.onEnter = confirm
    confirmWindow.confirm.onClick = confirm
    confirmWindow.onEnter = confirm
    update()
    confirmWindow:raise()
    confirmWindow:focus()
    confirmWindow:lock()
    confirmWindow.field:focus()
end

local function sell()
    local rare = {}
    for _, entry in ipairs(basket) do
        if entry.rare then
            rare[#rare + 1] = entry.name
        end
    end
    if #rare > 0 then
        askConfirm(rare)
    else
        sendSale(nil)
    end
end

-- Window ------------------------------------------------------------------------------------------------

function close()
    cancelConfirm()
    if window then
        window:hide()
    end
    openPos = nil
end

local function show()
    if not window:isVisible() then
        local root = rootWidget:getSize()
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                             y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
        local player = g_game.getLocalPlayer()
        openPos = player and player:getPosition()
        tab, basket = 'party', {}
        window.search:setText('')
    end
    window:show()
    window:raise()
    window:focus()
end

local function fillHeader()
    local parts = { state.npc }
    if state.town then
        parts[#parts + 1] = state.town
    end
    if state.greeting then
        parts[#parts + 1] = '"' .. state.greeting .. '"'
    end
    window.subtitle:setText(table.concat(parts, '  \183  '))
    window.moneyPanel.money:setText(dollars(state.money))
end

local function onShop(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Pokemon shop: invalid message')
        return
    end
    if data.type == 'shop' then
        local wasOpen = window:isVisible()
        state = data
        show()
        if wasOpen then
            prune()
        end
        fillHeader()
        refresh()
    elseif data.type == 'box' and state then
        state.box, state.boxes, state.list = data.box, data.boxes, data.list
        prune()
        refresh()
    elseif data.type == 'close' then
        close()
    elseif data.type == 'result' then
        if data.rare and #data.rare > 0 and window:isVisible() then
            askConfirm(data.rare)
            return
        end
        if data.ok then
            basket = {}
            refresh()
            if modules.game_textmessage then
                modules.game_textmessage.displayGameMessage(data.text)
            end
        elseif data.text then
            failure(data.text)
        end
    end
end

local function setTab(name)
    tab = name
    refresh()
end

local function changeBox(step)
    local index = currentBoxIndex()
    local box = index and (state.boxes or {})[index + step]
    if box then
        send({ action = 'box', box = box.box })
    end
end

local function onPositionChange(player, newPos)
    if not window or not window:isVisible() or not openPos or not newPos then
        return
    end
    local range = rules().range or 5
    if newPos.z ~= openPos.z or math.max(math.abs(newPos.x - openPos.x), math.abs(newPos.y - openPos.y)) > range then
        local npc = state and state.npc
        close()
        failure(npc and tr('You walked away from %s.', npc) or tr('You walked away from the shop.'))
    end
end

local function onGameStart()
    send({ action = 'hello' })
end

local function onGameEnd()
    close()
    state, basket = nil, {}
end

function init()
    g_ui.importStyle('pokemonshop')
    window = g_ui.createWidget('PokemonShopWindow', rootWidget)
    window:hide()

    window.partyTab.onClick = function() setTab('party') end
    window.pcTab.onClick = function() setTab('pc') end
    window.sort.onClick = function()
        sortIndex = sortIndex % #SORTS + 1
        refresh()
    end
    window.search.onTextChange = function() refresh() end
    window.boxBar.prev.onClick = function() changeBox(-1) end
    window.boxBar.next.onClick = function() changeBox(1) end
    window.addCheap.onClick = addCheap
    window.basket.clear.onClick = function()
        basket = {}
        refresh()
    end
    window.basket.sell.onClick = sell

    ProtocolGame.registerExtendedOpcode(ExtendedIds.PokemonShop, onShop)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    connect(LocalPlayer, { onPositionChange = onPositionChange })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.PokemonShop)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    disconnect(LocalPlayer, { onPositionChange = onPositionChange })
    cancelConfirm()
    if window then
        window:destroy()
    end
    window = nil
end
