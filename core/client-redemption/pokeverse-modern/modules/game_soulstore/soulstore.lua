-- The Store: what Verse Orbs buy (Store in the server lib). The top bar's Store button opens it. The server talks
-- JSON on ExtendedIds.Store: {type = "store", balance, held, buyOrbs, coin, bag, points, premiumDays, sex, ball, guild,
-- categories, offers} fills the window, {type = "result", ok, text} answers a purchase, a withdraw or a deposit (a fresh
-- "store" comes first when it worked), {type = "history", list} fills the history and {type = "buy-link", url} is the
-- page for buying Verse Orbs with PayPal. The window sends {action = "open"}, {action = "buy", offer, count, text},
-- {action = "withdraw", amount}, {action = "deposit", amount}, {action = "history"} and {action = "buy-orbs"}.
-- held is how many of the balance's coins were bought in the last days and can't be withdrawn yet.
local ICONS = '/modules/game_vocation/images/perk_'
local CATEGORY_ICONS = { featured = 'star', premium = 'crown', addons = 'heart', outfits = 'outfit',
                         warpstyles = 'ball', services = 'guide', items = 'up', guild = 'ranks', referral = 'heart' }
local WARP_IMAGES = '/modules/game_warpfx/images/'
local WARP_PREVIEW_KEY = 'store-preview'
local SLOT_NOTES = { warp = 'Log in, log out and teleport', victory = 'Plays when you win a battle',
                     defeat = 'Plays when you lose a battle' }
local KIND_ICONS = { premium = 'crown', sex = 'outfit', nickname = 'title', unnickname = 'back', vitamins = 'up',
                     guild = 'ranks', rank = 'ranks', referral = 'heart' }
local MAX_COUNT = 100
local PREMIUM_PERKS = {
    'Fly, Levitate, Surf, Dive, Waterfall, Strength, Rock Climb and Teleport',
    'Houses, beds, the Day Care, masteries and outfit addons',
    'Berries, premium doors and the Hoenn boats',
    'Two hunting tasks at once',
}

local window
local dialog
local historyWindow
local state
local category = 'featured'
local selected -- offer id
local count = 1
local wantOpen = false
local stopWarpPreview

local function center(widget)
    local root = rootWidget:getSize()
    widget:setPosition({ x = math.floor((root.width - widget:getWidth()) / 2),
                         y = math.max(0, math.floor((root.height - widget:getHeight()) / 2)) })
end

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Store, data)
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
    return nil
end

local function inCategory(offer, id)
    if id == 'featured' then
        return offer.featured == true
    end
    return offer.category == id
end

local function searchText()
    return window and window.categoriesPanel.search:getText():lower():trim() or ''
end

local function shownOffers()
    local query = searchText()
    local list = {}
    for _, offer in ipairs(offers()) do
        if query ~= '' then
            if offer.name:lower():find(query, 1, true) or (offer.pokemon or ''):lower():find(query, 1, true) then
                list[#list + 1] = offer
            end
        elseif inCategory(offer, category) then
            list[#list + 1] = offer
        end
    end
    return list
end

local function countIn(id)
    local n = 0
    for _, offer in ipairs(offers()) do
        n = n + (inCategory(offer, id) and 1 or 0)
    end
    return n
end

local function categoryName(id)
    for _, entry in ipairs((state and state.categories) or {}) do
        if entry.id == id then
            return entry.name
        end
    end
    return id
end

local function priceText(offer, price)
    price = price or offer.price
    if price <= 0 then
        return tr('Free')
    end
    return offer.points and tr('%s RP', thousands(price)) or thousands(price)
end

-- the look an outfit offer shows: the trainer's own sex, in the trainer's colours
local function outfitLook(offer)
    local looks = offer.looks or {}
    local look = { type = (state.sex == 0 and looks[1] or looks[2]) or looks[1] or 0 }
    local player = g_game.getLocalPlayer()
    if player then
        local own = player:getOutfit()
        look.head, look.body, look.legs, look.feet = own.head, own.body, own.legs, own.feet
    end
    return look
end

-- shows the offer's picture in a frame with item, creature and icon children
local function setPicture(frame, offer)
    frame.item:hide()
    frame.creature:hide()
    frame.icon:hide()
    if offer.item and offer.item > 0 then
        frame.item:setItemId(offer.item)
        frame.item:show()
    end
    if offer.look then
        frame.creature:setOutfit({ type = offer.look })
        frame.creature:show()
        frame.item:hide()
    elseif offer.looks then
        frame.creature:setOutfit(outfitLook(offer))
        frame.creature:show()
    elseif offer.image then
        frame.icon:setImageSource(WARP_IMAGES .. offer.image)
        frame.icon:show()
    elseif not (offer.item and offer.item > 0) then
        frame.icon:setImageSource(ICONS .. (KIND_ICONS[offer.kind] or CATEGORY_ICONS[offer.category] or 'star'))
        frame.icon:show()
    end
end

local function offerNote(offer)
    if offer.owned then
        return offer.kind == 'warpstyle' and tr('You have this Warp Style') or tr('You have this outfit')
    elseif offer.kind == 'warpstyle' then
        return tr(SLOT_NOTES[offer.slot] or 'Warp Style')
    elseif offer.kind == 'premium' then
        return tr('%d days for the whole account', offer.days or 0)
    elseif offer.pokemon then
        return tr('Addon for %s', offer.pokemon)
    elseif offer.kind == 'outfit' then
        return tr('Trainer outfit')
    elseif offer.points then
        return tr('Paid with referral points')
    elseif offer.stack then
        return tr('Buy up to %d at once', MAX_COUNT)
    end
    return categoryName(offer.category)
end

-- Detail pane ------------------------------------------------------------------------------------------

local function ballLine()
    local ball = state.ball
    if not ball then
        return tr('Put the Pokemon\'s ball in your ball slot first.')
    end
    local name = ball.nickname and string.format('%s (%s)', ball.nickname, ball.name) or ball.name
    return tr('In your ball slot: %s, level %d, %d vitamins.', name, ball.level or 0, ball.vitamins or 0)
end

local function infoFor(offer)
    if offer.kind == 'premium' then
        local lines = { (state.premiumDays or 0) > 0 and tr('You have %d days of Premium left.', state.premiumDays)
                        or tr('You don\'t have Premium.'), tr('Premium trainers get:') }
        for _, perk in ipairs(PREMIUM_PERKS) do
            lines[#lines + 1] = '- ' .. tr(perk)
        end
        return table.concat(lines, '\n')
    elseif offer.kind == 'nickname' or offer.kind == 'unnickname' or offer.kind == 'vitamins' then
        return ballLine()
    elseif offer.kind == 'guild' or offer.kind == 'rank' then
        local guild = state.guild
        if not guild then
            return tr('You aren\'t in a guild.')
        end
        return guild.leader and tr('You lead %s.', guild.name) or tr('You are in %s.', guild.name)
    elseif offer.kind == 'outfit' then
        return tr('Yours for good once bought: pick it in the outfit window.')
    elseif offer.kind == 'warpstyle' then
        return tr('Everyone around sees it. Yours for good once bought: put it on in Customise Trainer > Warp Styles.')
    elseif offer.points then
        return tr('You have %s referral points. A friend who reaches level 30 and buys Premium gives you 5.',
            thousands(state.points or 0))
    end
    return ''
end

local PLACEHOLDERS = { nickname = 'The new nickname', guild = 'The guild\'s name', rank = 'The rank\'s name' }

local function totalPrice(offer)
    return offer.price * (offer.stack and count or 1)
end

local function canAfford(offer, price)
    if offer.points then
        return price <= (state.points or 0)
    end
    return price <= (state.balance or 0) + (state.bag or 0)
end

local function stopPreview()
    if stopWarpPreview then
        stopWarpPreview()
        stopWarpPreview = nil
    end
end

-- a Warp Style offer loops on the trainer's own look in the preview (game_warpfx)
function showWarpPreview(offer)
    stopPreview()
    local preview = window.detail.preview
    local warpfx = modules.game_warpfx
    local warp = offer.kind == 'warpstyle' and warpfx and warpfx.loopStyle
    -- a taller frame with the trainer smaller and lower, so what plays over their head fits
    preview:setHeight(warp and 170 or 120)
    preview.creature:setSize(warp and { width = 76, height = 76 } or { width = 110, height = 110 })
    preview.creature:setMarginTop(warp and 56 or 0)
    if not warp then
        return
    end
    local player = g_game.getLocalPlayer()
    preview:setClipping(true)
    preview.icon:hide()
    preview.creature:setOutfit(player and player:getOutfit() or { type = 0 })
    preview.creature:show()
    local creature = preview.creature:getCreature()
    if creature then
        creature:setDirection(Directions.South)
    end
    stopWarpPreview = warpfx.loopStyle(preview, preview.creature, offer.slot, offer.style, WARP_PREVIEW_KEY)
end

local function refreshDetail()
    local pane = window.detail
    local offer = selected and findOffer(selected)
    if not offer then
        stopPreview()
    end
    pane:setVisible(offer ~= nil)
    if not offer then
        return
    end
    pane.title:setText(offer.name)
    pane.subtitle:setText(offerNote(offer))
    setPicture(pane.preview, offer)
    showWarpPreview(offer)
    pane.description:setText(offer.description or '')
    pane.info:setText(infoFor(offer))

    local placeholder = PLACEHOLDERS[offer.kind]
    pane.textField:setVisible(placeholder ~= nil)
    if placeholder then
        pane.textField:mergeStyle({ placeholder = tr(placeholder) })
    end
    pane.countBar:setVisible(offer.stack == true)
    pane.countBar.count:setText(tostring(count))
    pane.countBar.minus:setEnabled(count > 1)
    pane.countBar.plus:setEnabled(count < MAX_COUNT)

    local price = totalPrice(offer)
    if offer.owned then
        pane.buy:setText(tr('Owned'))
        pane.buy:setEnabled(false)
    elseif price == 0 then
        pane.buy:setText(tr('Use - Free'))
        pane.buy:setEnabled(true)
    elseif offer.points then
        pane.buy:setText(tr('Get - %s referral points', thousands(price)))
        pane.buy:setEnabled(canAfford(offer, price))
    else
        pane.buy:setText(price == 1 and tr('Buy - 1 Verse Orb') or tr('Buy - %s Verse Orbs', thousands(price)))
        pane.buy:setEnabled(canAfford(offer, price))
    end
    local short = not offer.owned and price > 0 and not canAfford(offer, price)
    pane.buy:setTooltip(short and (offer.points and tr('You have %s referral points.', thousands(state.points or 0))
        or tr('You have %s Verse Orbs.', thousands((state.balance or 0) + (state.bag or 0)))) or '')
end

-- Lists ------------------------------------------------------------------------------------------------

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
        local card = g_ui.createWidget('StoreOfferCard', panel.list)
        card.offerId = offer.id
        card.name:setText(offer.name)
        card.note:setText(offerNote(offer))
        setPicture(card.frame, offer)
        card.price:setText(offer.owned and tr('Owned') or priceText(offer))
        card.price:setColor(offer.owned and '#96aacd' or '#7ee08f')
        card.was:setText(offer.was and not offer.owned and thousands(offer.was) or '')
        card.onClick = function() select(offer.id) end
        keep = keep or offer.id == selected
    end
    panel.empty:setVisible(#list == 0)
    if query ~= '' then
        panel.empty:setText(tr('Nothing in the Store matches "%s".', query))
    elseif category == 'featured' then
        panel.empty:setText(tr('Nothing is featured right now.\nDeals, limited editions and the holiday outfits show up here during their events.'))
    else
        panel.empty:setText(tr('Nothing here yet.'))
    end
    select(keep and selected or (list[1] and list[1].id or nil))
end

local function refreshCategories()
    local box = window.categoriesPanel.categories
    box:destroyChildren()
    local searching = searchText() ~= ''
    for _, entry in ipairs((state and state.categories) or {}) do
        local button = g_ui.createWidget('StoreCategory', box)
        button.name:setText(entry.name)
        button.icon:setImageSource(ICONS .. (CATEGORY_ICONS[entry.icon] or 'star'))
        local n = countIn(entry.id)
        button.count:setText(n > 0 and tostring(n) or '')
        button:setOn(not searching and entry.id == category)
        button.onClick = function()
            category = entry.id
            window.categoriesPanel.search:setText('')
            refreshCategories()
            refreshOffers()
        end
    end
end

local function refreshBank()
    local bank = window.bank
    bank.coin:setItemId(state.coin or 0)
    bank.balance:setText(thousands(state.balance or 0))
    bank.bag:setText((state.bag or 0) > 0 and tr('+%s in your bag', thousands(state.bag)) or '')
    window.withdraw:setEnabled((state.balance or 0) - (state.held or 0) > 0)
    window.buyOrbs:setVisible(state.buyOrbs == true)
    window.deposit:setEnabled((state.bag or 0) > 0)
end

local function refresh()
    if not window or not state then
        return
    end
    refreshBank()
    refreshCategories()
    refreshOffers()
end

-- Dialogs ----------------------------------------------------------------------------------------------

function closeDialog()
    if dialog then
        dialog:destroy()
        dialog = nil
    end
end

-- title, text, confirm label, onConfirm(amount); max shows the amount field with an All button
local function openDialog(title, text, label, onConfirm, max)
    closeDialog()
    dialog = g_ui.createWidget('SoulStoreDialog', rootWidget)
    dialog.title:setText(title)
    dialog.text:setText(text)
    dialog.confirm:setText(label)
    dialog.field:setVisible(max ~= nil)
    dialog.all:setVisible(max ~= nil)
    if not max then
        dialog:setHeight(dialog:getHeight() - 44)
    end
    local function confirm()
        local amount = tonumber(dialog.field:getText())
        if max and (not amount or amount < 1 or amount > max) then
            failure(tr('Type an amount from 1 to %s.', thousands(max)))
            return
        end
        closeDialog()
        onConfirm(amount and math.floor(amount))
    end
    if max then
        dialog.field:setText(tostring(max))
        dialog.field:setCursorPos(-1)
        dialog.all.onClick = function() dialog.field:setText(tostring(max)) end
        dialog.field.onTextChange = function(field, value)
            local digits = value:gsub('%D', '')
            if digits ~= value then
                field:setText(digits)
            end
        end
    end
    dialog.confirm.onClick = confirm
    dialog.onEnter = confirm
    center(dialog)
    dialog:show()
    dialog:raise()
    dialog:focus()
    if max then
        dialog.field:focus()
    end
end

local function buy()
    local offer = selected and findOffer(selected)
    if not offer or offer.owned then
        return
    end
    local text = window.detail.textField:getText():trim()
    if PLACEHOLDERS[offer.kind] and text == '' then
        failure(tr('Type a name first.'))
        window.detail.textField:focus()
        return
    end
    local price = totalPrice(offer)
    local request = { action = 'buy', offer = offer.id, count = offer.stack and count or 1, text = text }
    if price == 0 then
        send(request)
        return
    end
    local what = offer.stack and count > 1 and string.format('%dx %s', count, offer.name) or offer.name
    if text ~= '' then
        what = string.format('%s "%s"', what, text)
    end
    if offer.points then
        openDialog(tr('Confirm'), tr('Get %s for %s referral points?', what, thousands(price)), tr('Get it'),
            function() send(request) end)
        return
    end
    local fromBag = math.max(0, price - (state.balance or 0))
    local text2 = price == 1 and tr('Buy %s for 1 Verse Orb?', what) or tr('Buy %s for %s Verse Orbs?', what, thousands(price))
    if fromBag > 0 then
        text2 = text2 .. '\n' .. tr('%s of them come from the orbs in your bag.', thousands(fromBag))
    end
    openDialog(tr('Confirm purchase'), text2, tr('Buy'), function() send(request) end)
end

local function withdraw()
    local max = state and ((state.balance or 0) - (state.held or 0)) or 0
    if max <= 0 then
        return
    end
    local text = tr('Verse Orbs from your balance go to your bag, to trade or carry.')
    if (state.held or 0) > 0 then
        text = text .. '\n' .. tr('%s bought in the last 7 days stay on the balance until then.', thousands(state.held))
    end
    openDialog(tr('Withdraw Verse Orbs'), text,
        tr('Withdraw'), function(amount) send({ action = 'withdraw', amount = amount }) end, max)
end

local function deposit()
    local max = state and state.bag or 0
    if max <= 0 then
        return
    end
    openDialog(tr('Deposit Verse Orbs'), tr('Verse Orbs from your bag go to your balance, shared by your account.'),
        tr('Deposit'), function(amount) send({ action = 'deposit', amount = amount }) end, max)
end

-- History ----------------------------------------------------------------------------------------------

function closeHistory()
    if historyWindow then
        historyWindow:destroy()
        historyWindow = nil
    end
end

local function showHistory(list)
    closeHistory()
    historyWindow = g_ui.createWidget('SoulStoreHistory', rootWidget)
    for _, entry in ipairs(list or {}) do
        local row = g_ui.createWidget('StoreHistoryRow', historyWindow.list)
        row.text:setText(entry.text or '')
        row.when:setText(string.format('%s  |  %s', os.date('%Y-%m-%d %H:%M', entry.date or 0), entry.player or ''))
        local amount = tonumber(entry.amount) or 0
        row.amount:setText(amount > 0 and ('+' .. thousands(amount)) or (amount < 0 and ('-' .. thousands(-amount)) or tr('Free')))
        row.amount:setColor(amount > 0 and '#7ee08f' or (amount < 0 and '#ffd75a' or '#96aacd'))
    end
    historyWindow.empty:setVisible(#(list or {}) == 0)
    center(historyWindow)
    historyWindow:show()
    historyWindow:raise()
    historyWindow:focus()
end

-- Window -----------------------------------------------------------------------------------------------

function close()
    closeDialog()
    closeHistory()
    stopPreview()
    wantOpen = false
    if window then
        window:hide()
    end
end

function open()
    wantOpen = true
    send({ action = 'open' })
end

function toggle()
    if window and window:isVisible() then
        close()
    else
        open()
    end
end

local function onStore(protocol, opcode, buffer)
    buffer = ProtocolGame.joinFragments(opcode, buffer)
    if not buffer then
        return
    end
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Store: invalid message')
        return
    end
    if data.type == 'store' then
        local first = state == nil
        state = data
        if first and category == 'featured' and countIn('featured') == 0 then
            category = 'premium'
        end
        if wantOpen and not window:isVisible() then
            center(window)
            window:show()
            window:raise()
            window:focus()
        end
        refresh()
    elseif data.type == 'result' then
        if data.ok then
            if window:isVisible() then
                window.detail.textField:setText('')
            end
            if modules.game_textmessage then
                modules.game_textmessage.displayGameMessage(data.text)
            end
        elseif data.text then
            failure(data.text)
        end
    elseif data.type == 'history' then
        showHistory(data.list)
    elseif data.type == 'buy-link' and type(data.url) == 'string' and data.url:match('^https?://') then
        g_platform.openUrl(data.url)
        if modules.game_textmessage then
            modules.game_textmessage.displayGameMessage(tr('The Verse Orbs page opened in your browser. The orbs arrive here as soon as PayPal confirms the payment.'))
        end
    end
end

local function onGameEnd()
    close()
    state = nil
end

function init()
    g_ui.importStyle('soulstore')
    window = g_ui.createWidget('SoulStoreWindow', rootWidget)
    window:hide()

    window.categoriesPanel.search.onTextChange = function()
        refreshCategories()
        refreshOffers()
    end
    window.detail.buy.onClick = buy
    window.detail.countBar.minus.onClick = function()
        count = math.max(1, count - (g_keyboard.isShiftPressed() and 10 or 1))
        refreshDetail()
    end
    window.detail.countBar.plus.onClick = function()
        count = math.min(MAX_COUNT, count + (g_keyboard.isShiftPressed() and 10 or 1))
        refreshDetail()
    end
    window.withdraw.onClick = withdraw
    window.deposit.onClick = deposit
    window.buyOrbs.onClick = function() send({ action = 'buy-orbs' }) end
    window.footer.history.onClick = function() send({ action = 'history' }) end

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Store, onStore)
    connect(g_game, { onGameEnd = onGameEnd })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Store)
    disconnect(g_game, { onGameEnd = onGameEnd })
    closeDialog()
    closeHistory()
    if window then
        window:destroy()
    end
    window = nil
end
