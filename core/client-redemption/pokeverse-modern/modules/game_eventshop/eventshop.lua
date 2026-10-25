-- Event Token Shop. Token NPCs open it (EventShop.open in the server lib). The server talks JSON on
-- ExtendedIds.EventShop: {type = "shop", npc, title, token, tokenName, tokenShort, balance, mode,
-- categories, offers} fills the window, {type = "result", ok, text} answers an exchange and
-- {type = "close"} closes it. The window sends {action = "hello"} at login, {action = "buy", offer,
-- count} and {action = "close"}.
local GOOD = '#7ee08f'
local MUTED = '#96aacd'

local window
local dialog
local state
local category = 'all'
local selected
local count = 1

local function center(widget)
    local root = rootWidget:getSize()
    widget:setPosition({ x = math.floor((root.width - widget:getWidth()) / 2),
                         y = math.max(0, math.floor((root.height - widget:getHeight()) / 2)) })
end

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.EventShop, data)
    end
end

local function thousands(n)
    local text = tostring(math.floor(tonumber(n) or 0))
    return (text:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', ''))
end

local function failure(text)
    if modules.game_textmessage then
        modules.game_textmessage.displayFailureMessage(text)
    end
end

local function offers()
    return (state and state.offers) or {}
end

local function findOffer(id)
    for _, offer in ipairs(offers()) do
        if offer.id == id then
            return offer
        end
    end
end

local function tokenShort()
    return (state and state.tokenShort) or ''
end

local function priceText(offer, price)
    price = price or offer.price or 0
    if offer.letters then
        return tr('Letters')
    end
    if (state and state.mode) == 'sell' then
        return string.format('+%s %s', thousands(price), tokenShort())
    end
    return string.format('%s %s', thousands(price), tokenShort())
end

local function searchText()
    return window and window.search:getText():lower():trim() or ''
end

local function shownOffers()
    local query = searchText()
    local list = {}
    for _, offer in ipairs(offers()) do
        local inCat = category == 'all' or offer.category == category
        local match = query == '' or offer.name:lower():find(query, 1, true)
            or (offer.note or ''):lower():find(query, 1, true)
        if inCat and match then
            list[#list + 1] = offer
        end
    end
    return list
end

local function categoryName(id)
    for _, entry in ipairs((state and state.categories) or {}) do
        if entry.id == id then
            return entry.name
        end
    end
    return id
end

local function canAfford(offer)
    if offer.locked then
        return false
    end
    if offer.letters then
        return true
    end
    if (state and state.mode) == 'sell' then
        return (offer.have or 0) >= count
    end
    return (offer.price or 0) <= (state.balance or 0)
end

local function totalPrice(offer)
    if (state and state.mode) == 'sell' then
        return (offer.price or 0) * count
    end
    return offer.price or 0
end

local function refreshDetail()
    local pane = window.detail
    local offer = selected and findOffer(selected)
    pane:setVisible(offer ~= nil)
    if not offer then
        return
    end
    pane.title:setText(offer.name)
    pane.subtitle:setText(offer.note or '')
    pane.preview.item:setItemId(offer.item or 0)
    local selling = (state and state.mode) == 'sell'
    if selling then
        pane.description:setText(tr('Each one pays %s %s.', offer.price or 0, tokenShort()))
        pane.info:setText(tr('You have %s.', offer.have or 0))
    elseif offer.letters then
        pane.description:setText(tr('Costs one of each P, S, O, U and L letter.'))
        pane.info:setText(offer.lockText or '')
    else
        pane.description:setText(tr('%sx for %s %s.', offer.count or 1, offer.price or 0, tokenShort()))
        pane.info:setText(offer.lockText or '')
    end
    pane.countBar:setVisible(selling)
    if selling then
        local max = math.max(1, math.min(100, offer.have or 1))
        count = math.max(1, math.min(count, max))
        pane.countBar.count:setText(tostring(count))
        pane.countBar.minus:setEnabled(count > 1)
        pane.countBar.plus:setEnabled(count < max)
    end
    local price = totalPrice(offer)
    if offer.locked then
        pane.buy:setText(tr('Cannot trade'))
        pane.buy:setEnabled(false)
        pane.buy:setTooltip(offer.lockText or '')
    elseif selling then
        pane.buy:setText(tr('Turn in — +%s %s', thousands(price), tokenShort()))
        pane.buy:setEnabled(canAfford(offer))
        pane.buy:setTooltip('')
    elseif offer.letters then
        pane.buy:setText(tr('Exchange'))
        pane.buy:setEnabled(canAfford(offer))
        pane.buy:setTooltip('')
    else
        pane.buy:setText(tr('Exchange — %s %s', thousands(price), tokenShort()))
        pane.buy:setEnabled(canAfford(offer))
        pane.buy:setTooltip(canAfford(offer) and '' or tr('You have %s %s.', thousands(state.balance or 0), tokenShort()))
    end
end

local function select(id)
    if selected ~= id then
        count = 1
    end
    selected = id
    for _, card in ipairs(window.offersPanel.list:getChildren()) do
        card:setChecked(card.offerId == id)
    end
    refreshDetail()
end

local function refreshOffers()
    local panel = window.offersPanel
    local list = shownOffers()
    local query = searchText()
    panel.title:setText(query ~= '' and tr('Search results') or categoryName(category))
    panel.count:setText(#list == 1 and tr('1 offer') or tr('%d offers', #list))
    panel.list:destroyChildren()
    local keep = false
    for _, offer in ipairs(list) do
        local card = g_ui.createWidget('EventShopCard', panel.list)
        card.offerId = offer.id
        card.name:setText(offer.name)
        card.note:setText(offer.note or '')
        card.frame.item:setItemId(offer.item or 0)
        card.price:setText(priceText(offer))
        local dim = offer.locked or ((state and state.mode) ~= 'sell' and not offer.letters and (offer.price or 0) > (state.balance or 0))
        card:setOn(dim)
        card.price:setColor(dim and MUTED or GOOD)
        card.onClick = function() select(offer.id) end
        keep = keep or offer.id == selected
    end
    panel.empty:setVisible(#list == 0)
    panel.empty:setText(query ~= '' and tr('Nothing matches "%s".', query) or tr('Nothing here.'))
    select(keep and selected or (list[1] and list[1].id or nil))
end

local function refreshChips()
    local box = window.chips
    box:destroyChildren()
    local searching = searchText() ~= ''
    for _, entry in ipairs((state and state.categories) or {}) do
        local chip = g_ui.createWidget('EventShopChip', box)
        chip:setText(entry.name)
        chip:setOn(not searching and entry.id == category)
        chip.onClick = function()
            category = entry.id
            window.search:setText('')
            refreshChips()
            refreshOffers()
        end
    end
end

local function refreshBank()
    window.bank.coin:setItemId(state.token or 0)
    window.bank.caption:setText(state.tokenName or '')
    window.bank.balance:setText(thousands(state.balance or 0))
end

local function refresh()
    if not window or not state then
        return
    end
    window.headerTitle:setText(state.npc or '')
    window.subtitle:setText(state.title or '')
    local selling = state.mode == 'sell'
    window.footer.note:setText(selling and tr('Turn letters in for %s.', state.tokenName or tokenShort())
        or tr('Prices are in %s. This is not the Poke Mart.', state.tokenName or tokenShort()))
    refreshBank()
    refreshChips()
    refreshOffers()
end

function closeDialog()
    if dialog then
        dialog:destroy()
        dialog = nil
    end
end

local function openDialog(title, text, label, onConfirm)
    closeDialog()
    dialog = g_ui.createWidget('EventShopDialog', rootWidget)
    dialog.title:setText(title)
    dialog.text:setText(text)
    dialog.confirm:setText(label)
    local function confirm()
        closeDialog()
        onConfirm()
    end
    dialog.confirm.onClick = confirm
    dialog.onEnter = confirm
    center(dialog)
    dialog:show()
    dialog:raise()
    dialog:focus()
end

local function buy()
    local offer = selected and findOffer(selected)
    if not offer or offer.locked or not canAfford(offer) then
        return
    end
    local request = { action = 'buy', offer = offer.id, count = (state.mode == 'sell') and count or 1 }
    if offer.letters then
        openDialog(tr('Confirm'), tr('Exchange the letters P, S, O, U and L for a %s?', offer.name),
            tr('Exchange'), function() send(request) end)
        return
    end
    if state.mode == 'sell' then
        local what = count > 1 and string.format('%dx %s', count, offer.name) or offer.name
        openDialog(tr('Confirm'), tr('Turn in %s for %s %s?', what, thousands(totalPrice(offer)), tokenShort()),
            tr('Turn in'), function() send(request) end)
        return
    end
    openDialog(tr('Confirm'), tr('Exchange %s %s for %s?', thousands(offer.price or 0), tokenShort(), offer.name),
        tr('Exchange'), function() send(request) end)
end

function close()
    closeDialog()
    if window and window:isVisible() then
        send({ action = 'close' })
        window:hide()
    end
end

local function show()
    if not window:isVisible() then
        center(window)
        window:show()
        window:raise()
        window:focus()
    end
end

local function onShop(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('EventShop: invalid message')
        return
    end
    if data.type == 'shop' then
        local same = state and state.shop == data.shop
        state = data
        if not same then
            category = 'all'
            selected = nil
            count = 1
            window.search:setText('')
        end
        show()
        refresh()
    elseif data.type == 'result' then
        if data.ok then
            if modules.game_textmessage then
                modules.game_textmessage.displayGameMessage(data.text)
            end
        elseif data.text then
            failure(data.text)
        end
    elseif data.type == 'close' then
        closeDialog()
        if window then
            window:hide()
        end
    end
end

local function onGameStart()
    send({ action = 'hello' })
end

local function onGameEnd()
    state = nil
    closeDialog()
    if window then
        window:hide()
    end
end

function init()
    g_ui.importStyle('eventshop')
    window = g_ui.createWidget('EventShopWindow', rootWidget)
    window:hide()
    window.search.onTextChange = function()
        refreshChips()
        refreshOffers()
    end
    window.detail.buy.onClick = buy
    window.detail.countBar.minus.onClick = function()
        count = math.max(1, count - 1)
        refreshDetail()
    end
    window.detail.countBar.plus.onClick = function()
        count = math.min(100, count + 1)
        refreshDetail()
    end
    ProtocolGame.registerExtendedOpcode(ExtendedIds.EventShop, onShop)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.EventShop)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    closeDialog()
    if window then
        window:destroy()
    end
    window = nil
end
