-- Global Trade Station: trainers sell and buy items, and sell Pokemon, to each other. It opens
-- from the Pokemon Center computer (actions/computer.lua) and keeps working within a few tiles of
-- it; staff can open it anywhere with "/gts open".
--
-- The client's GTS window (game_gts) sends "/gts <action> ..." (talkactions/client/gts.lua) and
-- draws the EXTENDED_IDS.GTS JSON that comes back, one {type = ...} per message.
--
-- What an offer sells or pays with is held here until it is sold, cancelled or expires: items and
-- Pokemon leave the trainer's bag, money leaves the bank first and then the bag. Sellers are paid
-- into the bank, less the tax, even when offline; items bought by an offline trainer go to the
-- depot. Expired offers go back to their trainer at login or when the GTS opens.

GTS = {}

GTS.TAX = 0.01 -- of each sale, paid by the seller
GTS.DURATION = 7 * 24 * 60 * 60
GTS.MAX_OFFERS = 30 -- active offers per trainer, items and Pokemon together
GTS.MAX_AMOUNT = 1000
GTS.MAX_PRICE = 20000000 -- per piece
GTS.MAX_TOTAL = 1000000000 -- amount x price: the offline bank credit is 32-bit
GTS.RANGE = 4 -- tiles from the computer
GTS.STAFF_ACCESS = 5
GTS.LIST_LIMIT = 40
GTS.HISTORY_LIMIT = 30

local KIND_ITEM, KIND_POKEMON = 0, 1
local STATE_DONE, STATE_CANCELLED, STATE_EXPIRED = 1, 2, 3
-- long messages go in fragments (doSendPlayerLongExtendedOpcode); a list past this loses its last rows
local MESSAGE_LIMIT = 60000

-- the shared categories (065-itemCategories.lua), without the ones that can't be traded or are empty
GTS.CATEGORIES = {}
for _, category in ipairs(ItemCategories.LIST) do
    if (category.trade and #category.items > 0) then
        GTS.CATEGORIES[#GTS.CATEGORIES + 1] = category
    end
end

local CATALOG = {}
for index, category in ipairs(GTS.CATEGORIES) do
    for _, id in ipairs(category.items) do
        local info = getItemInfo(id)
        CATALOG[id] = { category = index, stackable = info.stackable, clientId = info.clientId,
            name = string.capitalise(info.name) }
    end
end

local function send(cid, data, list)
    local text = JSON.encode(data)
    -- long lists lose their last rows rather than the whole message
    while (#text > MESSAGE_LIMIT and list and #list > 0) do
        table.remove(list)
        data.more = true
        text = JSON.encode(data)
    end
    doSendPlayerLongExtendedOpcode(cid, EXTENDED_IDS.GTS, text)
end

local function result(cid, ok, text)
    send(cid, { type = "result", ok = ok, text = __L(cid, text) })
    return ok
end

local function notify(guid, text)
    local cid = getPlayerByGUID(guid)
    if (cid) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "GTS: " .. __L(cid, text))
    end
end

-- the face item the Pokemon bar shows (shinies have their own)
local function faceOf(name)
    local pokemon = getPokemonDefinition(name)
    return pokemon and pokemon.fastcallPortrait or nil
end

local function escape(text)
    return db.escapeString(text)
end

-- money

local function getFunds(cid)
    return getPlayerBalance(cid) + getPlayerMoney(cid)
end

local function takeFunds(cid, amount)
    if (getFunds(cid) < amount) then
        return false
    end

    local balance = getPlayerBalance(cid)
    local fromBank = math.min(balance, amount)
    doPlayerSetBalance(cid, balance - fromBank)
    if (amount > fromBank and not doPlayerRemoveMoney(cid, amount - fromBank)) then
        doPlayerSetBalance(cid, balance)
        return false
    end
    return true
end

local function payTo(guid, amount)
    if (amount <= 0) then
        return true
    end

    local cid = getPlayerByGUID(guid)
    if (cid) then
        doPlayerSetBalance(cid, getPlayerBalance(cid) + amount)
        return true
    end
    return doPlayerAddBalanceByName(getPlayerNameByGUID(guid), amount)
end

local function profitOf(total)
    return math.floor(total * (1 - GTS.TAX))
end

-- items: only the trainer's own, not unique ones (quest rewards stay with their trainer)

local function tradeableItems(cid, itemid)
    local ret = {}
    local backpack = getPlayerSlotItem(cid, PLAYER_SLOT_BACKPACK)
    if (isItem(backpack)) then
        for _, item in ipairs(getContainerItems(backpack.uid, true)) do
            if (item.itemid == itemid and getItemUniqueOwner(item.uid) == ITEM_UNIQUE_OWNER_NONE) then
                ret[#ret + 1] = item
            end
        end
    end
    return ret
end

local function countTradeable(cid, itemid)
    local count = 0
    for _, item in ipairs(tradeableItems(cid, itemid)) do
        count = count + math.max(1, getItemCount(item.uid))
    end
    return count
end

local function removeTradeable(cid, itemid, count)
    if (countTradeable(cid, itemid) < count) then
        return false
    end

    for _, item in ipairs(tradeableItems(cid, itemid)) do
        if (count <= 0) then
            break
        end

        local here = math.max(1, getItemCount(item.uid))
        if (here > count) then
            doRemoveItem(item.uid, count)
            count = 0
        else
            doRemoveItem(item.uid)
            count = count - here
        end
    end
    return true
end

local function stacksOf(itemid, count)
    local info = CATALOG[itemid] or getItemInfo(itemid)
    local size = info and info.stackable and 100 or 1
    local stacks = {}
    while (count > 0) do
        stacks[#stacks + 1] = math.min(size, count)
        count = count - stacks[#stacks]
    end
    return stacks
end

-- to the bag, or the depot when it is full; to the depot when the trainer is offline
local function giveItems(guid, itemid, count)
    local cid = getPlayerByGUID(guid)
    local name = not cid and getPlayerNameByGUID(guid)
    for _, n in ipairs(stacksOf(itemid, count)) do
        if (cid) then
            doPlayerSafeAddItem(cid, itemid, n, false, false, true)
        else
            local item = doCreateItemEx(itemid, n)
            if (not item or not doPlayerAddDepotItemByName(name, item)) then
                log(LOG_TYPES.ERROR, "GTS:giveItems - Can't deliver.", guid, itemid, n)
                return false
            end
        end
    end
    return true
end

-- Pokemon

local function ballProblem(cid, ball)
    if (getItemUniqueOwner(ball.uid) ~= ITEM_UNIQUE_OWNER_NONE) then
        return "Unique Pokemon can't be traded."
    elseif (getBallSeal(ball.uid) ~= BALL_SEAL_IDS.NONE) then
        return "Pokemon with a seal can't be traded."
    elseif (getBallTm(ball.uid, 1) ~= TM_IDS.NONE or getBallTm(ball.uid, 2) ~= TM_IDS.NONE) then
        return "Pokemon with TMs can't be traded."
    elseif (PokemonHeldItem.getMegaStone(ball.uid)) then
        return "Take its Mega Stone off first."
    elseif (ball.uid == getPlayerSlotItem(cid, PLAYER_SLOT_BALL).uid
            and (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid))) then
        return "Put your Pokemon back in its ball first."
    end
    return nil
end

local function giveBall(cid, offer)
    return doCreatePokemonBall(cid, offer:getDataInt('itemtype'), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, true, { column = 'attributes', result = offer:getID() })
end

local function loadBall(offer)
    local uid = doCreateItemEx(offer:getDataInt('itemtype'))
    if (not uid) then
        return nil
    end
    doItemLoadAttributes(uid, 'attributes', offer:getID())
    return isBallWithPokemon(uid) and uid or nil
end

local function pokemonSummary(uid)
    local summary = {}
    local ivs, _, natureId = PokemonStats.readBall(uid)
    if (ivs) then
        summary.nature = PokemonStats.getNatureName(natureId)
        summary.ivs = PokemonStats.getTotal(ivs)
        summary.perfect = 0
        for stat = 1, PokemonStats.STAT_COUNT do
            if (ivs[stat] == PokemonStats.IV_MAX) then
                summary.perfect = summary.perfect + 1
            end
        end
    end
    summary.sex = getBallPokemonSex(uid)
    summary.boost = getBallPokemonExtraPoints(uid)
    return summary
end

-- what the detail panels show (the PC's Poke boxes too)
GTS.describe = function(data, uid, name, level)
    for key, value in pairs(pokemonSummary(uid)) do
        data[key] = value
    end
    data.ability = getPokemonSpecialAbilityName(getBallPokemonSpecialAbility(uid))
    data.eggMove = getBallEggMove(uid)
    local held = getBallHeld(uid)
    data.held = held and PokemonHeldItem.getHeldName(held, uid) or nil
    data.sheet = PokemonStats.getStatSheet(uid, name, level)
    return data
end

GTS.summary = pokemonSummary
GTS.ballProblem = ballProblem
GTS.faceOf = faceOf

-- database

local SELECT = "SELECT o.`id`, o.`player_id`, o.`kind`, o.`sale`, o.`itemtype`, o.`amount`, o.`price`, o.`created`,"
        .. " o.`expires`, o.`pokemon_name`, o.`pokemon_level`, o.`attributes`, p.`name` AS `holder` FROM `gts_offers` o"
        .. " LEFT JOIN `players` p ON p.`id` = o.`player_id` "

local function query(where)
    local r = db.getResult(SELECT .. where)
    if (r:getID() == -1) then
        return nil
    end
    return r
end

local function rows(where, fn)
    local r = query(where)
    if (not r) then
        return
    end
    repeat
        fn(r)
    until not r:next()
    r:free()
end

local function getOffer(id)
    return query(string.format("WHERE o.`id` = %d LIMIT 1", id))
end

local function countOffers(guid)
    local r = db.getResult(string.format("SELECT COUNT(*) AS `total` FROM `gts_offers` WHERE `player_id` = %d", guid))
    if (r:getID() == -1) then
        return 0
    end
    local total = r:getDataInt('total')
    r:free()
    return total
end

local function addHistory(guid, offer, amount, state, sale)
    db.executeQuery(string.format("INSERT INTO `gts_history` (`player_id`, `kind`, `sale`, `itemtype`, `pokemon_name`,"
            .. " `pokemon_level`, `amount`, `price`, `state`, `date`) VALUES (%d, %d, %d, %d, %s, %d, %d, %d, %d, %d)",
        guid, offer:getDataInt('kind'), sale and 1 or 0, offer:getDataInt('itemtype'),
        escape(offer:getDataString('pokemon_name')), offer:getDataInt('pokemon_level'), amount,
        offer:getDataLong('price'), state, os.time()))
end

local function takeAmount(offer, amount)
    local left = offer:getDataInt('amount') - amount
    if (left <= 0) then
        return db.executeQuery(string.format("DELETE FROM `gts_offers` WHERE `id` = %d", offer:getDataInt('id')))
    end
    return db.executeQuery(string.format("UPDATE `gts_offers` SET `amount` = %d WHERE `id` = %d AND `amount` = %d",
        left, offer:getDataInt('id'), offer:getDataInt('amount')))
end

local function offerRow(r, guid)
    return {
        id = r:getDataInt('id'),
        holder = r:getDataString('holder'),
        amount = r:getDataInt('amount'),
        price = r:getDataLong('price'),
        expires = r:getDataLong('expires'),
        own = r:getDataInt('player_id') == guid or nil
    }
end

-- what an offer holds goes back to its trainer (online)
local function returnOffer(cid, offer, state)
    local kind, guid = offer:getDataInt('kind'), getPlayerGUID(cid)
    local amount, price = offer:getDataInt('amount'), offer:getDataLong('price')
    if (kind == KIND_POKEMON) then
        if (not giveBall(cid, offer)) then
            return false
        end
    elseif (offer:getDataInt('sale') == 1) then
        giveItems(guid, offer:getDataInt('itemtype'), amount)
    else
        payTo(guid, amount * price)
    end
    db.executeQuery(string.format("DELETE FROM `gts_offers` WHERE `id` = %d", offer:getDataInt('id')))
    addHistory(guid, offer, amount, state, offer:getDataInt('sale') == 1)
    return true
end

-- session

local SESSION = playersStorages.gtsSession

local function sendBalance(cid)
    send(cid, { type = "balance", bank = getPlayerBalance(cid), money = getPlayerMoney(cid) })
end

-- Global

GTS.returnExpired = function(cid)
    local guid, returned = getPlayerGUID(cid), 0
    -- item offers the GTS doesn't trade (moved over from the old market) go back too
    rows(string.format("WHERE o.`player_id` = %d", guid), function(offer)
        local untraded = offer:getDataInt('kind') ~= KIND_POKEMON and not CATALOG[offer:getDataInt('itemtype')]
        if ((untraded or offer:getDataLong('expires') <= os.time()) and returnOffer(cid, offer, STATE_EXPIRED)) then
            returned = returned + 1
        end
    end)
    if (returned > 0) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid,
            "GTS: %d of your offers expired and came back to you."), returned))
    end
end

GTS.onLogin = function(cid)
    if (isPlayer(cid)) then
        WindowSession.close(cid, SESSION)
        GTS.returnExpired(cid)
    end
end

-- terminal: where the computer stands, so the client can close the window when the player walks off
GTS.open = function(cid, anywhere, terminal)
    if (not getPlayerUsingOtClient(cid)) then
        return false
    end

    WindowSession.open(cid, SESSION, anywhere)
    GTS.returnExpired(cid)

    local categories = {}
    for index, category in ipairs(GTS.CATEGORIES) do
        categories[#categories + 1] = { id = index, name = category.name }
    end
    send(cid, { type = "open", categories = categories, bank = getPlayerBalance(cid), money = getPlayerMoney(cid),
        tax = GTS.TAX, days = GTS.DURATION / 86400, maxPrice = GTS.MAX_PRICE, maxAmount = GTS.MAX_AMOUNT,
        terminal = not anywhere and terminal and { x = terminal.x, y = terminal.y, z = terminal.z } or nil })
    return true
end

GTS.close = function(cid)
    WindowSession.close(cid, SESSION)
end

GTS.isOpen = function(cid)
    local ok, open = WindowSession.inRange(cid, SESSION, GTS.RANGE)
    if (ok) then
        return true
    end
    if (open) then
        WindowSession.close(cid, SESSION)
        send(cid, { type = "close" })
        doPlayerSendCancel(cid, __L(cid, "You moved away from the computer."))
    end
    return false
end

GTS.sendCategory = function(cid, index)
    local category = GTS.CATEGORIES[index]
    if (not category) then
        return
    end

    local items = {}
    for _, id in ipairs(category.items) do
        local info = CATALOG[id]
        items[#items + 1] = { id = id, client = info.clientId, name = info.name, count = countTradeable(cid, id) }
    end
    send(cid, { type = "category", id = index, items = items }, items)
end

GTS.sendOffers = function(cid, itemid)
    if (not CATALOG[itemid]) then
        return
    end

    local guid, now = getPlayerGUID(cid), os.time()
    local sell, buy = {}, {}
    rows(string.format("WHERE o.`kind` = %d AND o.`itemtype` = %d AND o.`sale` = 1 AND o.`expires` > %d"
            .. " ORDER BY o.`price` ASC, o.`created` ASC LIMIT %d", KIND_ITEM, itemid, now, GTS.LIST_LIMIT),
        function(r) sell[#sell + 1] = offerRow(r, guid) end)
    rows(string.format("WHERE o.`kind` = %d AND o.`itemtype` = %d AND o.`sale` = 0 AND o.`expires` > %d"
            .. " ORDER BY o.`price` DESC, o.`created` ASC LIMIT %d", KIND_ITEM, itemid, now, GTS.LIST_LIMIT),
        function(r) buy[#buy + 1] = offerRow(r, guid) end)
    send(cid, { type = "offers", item = itemid, count = countTradeable(cid, itemid), sell = sell, buy = buy }, buy)
end

local function checkPrice(cid, amount, price)
    if (amount < 1 or amount > GTS.MAX_AMOUNT) then
        return result(cid, false, string.format("The amount must be between 1 and %d.", GTS.MAX_AMOUNT))
    elseif (price < 1 or price > GTS.MAX_PRICE) then
        return result(cid, false, string.format("The price must be between $1 and $%d.", GTS.MAX_PRICE))
    elseif (amount * price > GTS.MAX_TOTAL) then
        return result(cid, false, string.format("An offer can't be worth more than $%d.", GTS.MAX_TOTAL))
    elseif (countOffers(getPlayerGUID(cid)) >= GTS.MAX_OFFERS) then
        return result(cid, false, string.format("You can have at most %d offers.", GTS.MAX_OFFERS))
    end
    return true
end

local function insertOffer(cid, kind, sale, itemtype, amount, price, pokemonName, level, attributes)
    local now = os.time()
    return db.executeQuery(string.format("INSERT INTO `gts_offers` (`player_id`, `kind`, `sale`, `itemtype`, `amount`,"
            .. " `price`, `created`, `expires`, `pokemon_name`, `pokemon_level`, `attributes`) VALUES"
            .. " (%d, %d, %d, %d, %d, %d, %d, %d, %s, %d, %s)", getPlayerGUID(cid), kind, sale, itemtype, amount, price,
        now, now + GTS.DURATION, escape(pokemonName or ""), level or 0, attributes or "NULL"))
end

GTS.createOffer = function(cid, sale, itemid, amount, price)
    if (not CATALOG[itemid]) then
        return result(cid, false, "This item can't be traded on the GTS.")
    elseif (not checkPrice(cid, amount, price)) then
        return false
    end

    if (sale) then
        if (not removeTradeable(cid, itemid, amount)) then
            return result(cid, false, "You don't have that many to sell.")
        end
        if (not insertOffer(cid, KIND_ITEM, 1, itemid, amount, price)) then
            giveItems(getPlayerGUID(cid), itemid, amount)
            return result(cid, false, "Not possible, please try again later.")
        end
    else
        if (not takeFunds(cid, amount * price)) then
            return result(cid, false, "You don't have enough money.")
        end
        if (not insertOffer(cid, KIND_ITEM, 0, itemid, amount, price)) then
            payTo(getPlayerGUID(cid), amount * price)
            return result(cid, false, "Not possible, please try again later.")
        end
    end

    doPlayerSave(cid)
    sendBalance(cid)
    GTS.sendOffers(cid, itemid)
    return result(cid, true, sale and "Your items are now for sale." or "Your buy offer is now up.")
end

local function acceptItem(cid, offer, amount)
    local guid, holder = getPlayerGUID(cid), offer:getDataInt('player_id')
    local itemid, price = offer:getDataInt('itemtype'), offer:getDataLong('price')
    amount = math.max(1, math.min(amount, offer:getDataInt('amount')))
    local total = amount * price

    if (offer:getDataInt('sale') == 1) then
        if (not takeFunds(cid, total)) then
            return result(cid, false, "You don't have enough money.")
        end
        if (not takeAmount(offer, amount)) then
            payTo(guid, total)
            return result(cid, false, "This offer is no longer available.")
        end
        giveItems(guid, itemid, amount)
        payTo(holder, profitOf(total))
        addHistory(holder, offer, amount, STATE_DONE, true)
        addHistory(guid, offer, amount, STATE_DONE, false)
        notify(holder, string.format("You sold %dx %s for $%d.", amount, CATALOG[itemid].name, profitOf(total)))
    else
        if (not removeTradeable(cid, itemid, amount)) then
            return result(cid, false, "You don't have that many to sell.")
        end
        if (not takeAmount(offer, amount)) then
            giveItems(guid, itemid, amount)
            return result(cid, false, "This offer is no longer available.")
        end
        giveItems(holder, itemid, amount)
        payTo(guid, profitOf(total))
        addHistory(guid, offer, amount, STATE_DONE, true)
        addHistory(holder, offer, amount, STATE_DONE, false)
        notify(holder, string.format("You bought %dx %s for $%d.", amount, CATALOG[itemid].name, total))
    end

    doPlayerSave(cid)
    sendBalance(cid)
    GTS.sendOffers(cid, itemid)
    return result(cid, true, offer:getDataInt('sale') == 1 and "Bought!" or "Sold! The money is in your bank.")
end

local function acceptPokemon(cid, offer)
    local guid, holder = getPlayerGUID(cid), offer:getDataInt('player_id')
    local price, name = offer:getDataLong('price'), offer:getDataString('pokemon_name')
    if (not takeFunds(cid, price)) then
        return result(cid, false, "You don't have enough money.")
    end
    if (not db.executeQuery(string.format("DELETE FROM `gts_offers` WHERE `id` = %d", offer:getDataInt('id')))) then
        payTo(guid, price)
        return result(cid, false, "This offer is no longer available.")
    end
    if (not giveBall(cid, offer)) then
        log(LOG_TYPES.ERROR, "GTS:acceptPokemon - Can't create ball.", getCreatureName(cid), offer:getDataInt('id'))
        payTo(guid, price)
        return result(cid, false, "Not possible, please try again later.")
    end

    payTo(holder, profitOf(price))
    addHistory(holder, offer, 1, STATE_DONE, true)
    addHistory(guid, offer, 1, STATE_DONE, false)
    notify(holder, string.format("You sold your %s for $%d.", name, profitOf(price)))
    doPlayerSave(cid)
    sendBalance(cid)
    GTS.sendSpecies(cid)
    GTS.sendListings(cid, name)
    return result(cid, true, string.format("%s is yours!", name))
end

GTS.accept = function(cid, id, amount)
    local offer = getOffer(id)
    if (not offer or offer:getDataLong('expires') <= os.time()) then
        if (offer) then offer:free() end
        return result(cid, false, "This offer is no longer available.")
    end

    local ret
    if (offer:getDataInt('player_id') == getPlayerGUID(cid)) then
        ret = result(cid, false, "This is your own offer. You can cancel it in My Offers.")
    elseif (offer:getDataInt('kind') == KIND_POKEMON) then
        ret = acceptPokemon(cid, offer)
    else
        ret = acceptItem(cid, offer, amount or 1)
    end
    offer:free()
    return ret
end

GTS.cancel = function(cid, id)
    local offer = getOffer(id)
    if (not offer) then
        return result(cid, false, "This offer is no longer available.")
    end

    local ret
    if (offer:getDataInt('player_id') ~= getPlayerGUID(cid)) then
        ret = result(cid, false, "This is not your offer.")
    elseif (returnOffer(cid, offer, STATE_CANCELLED)) then
        doPlayerSave(cid)
        sendBalance(cid)
        GTS.sendMine(cid)
        ret = result(cid, true, "Offer cancelled. What it held is back with you.")
    else
        ret = result(cid, false, "Not possible, please try again later.")
    end
    offer:free()
    return ret
end

GTS.sendMine = function(cid)
    local guid = getPlayerGUID(cid)
    local offers, history = {}, {}
    rows(string.format("WHERE o.`player_id` = %d ORDER BY o.`created` DESC", guid), function(r)
        local row = offerRow(r, guid)
        row.kind, row.sale = r:getDataInt('kind'), r:getDataInt('sale')
        local itemid = r:getDataInt('itemtype')
        if (row.kind == KIND_POKEMON) then
            row.name = r:getDataString('pokemon_name')
            row.number = getPokemonNumberByName(row.name)
            row.level = r:getDataInt('pokemon_level')
        elseif (CATALOG[itemid]) then
            row.name, row.client = CATALOG[itemid].name, CATALOG[itemid].clientId
        end
        offers[#offers + 1] = row
    end)

    local r = db.getResult(string.format("SELECT * FROM `gts_history` WHERE `player_id` = %d ORDER BY `date` DESC LIMIT %d",
        guid, GTS.HISTORY_LIMIT))
    if (r:getID() ~= -1) then
        repeat
            local itemid = r:getDataInt('itemtype')
            local row = { kind = r:getDataInt('kind'), sale = r:getDataInt('sale'), amount = r:getDataInt('amount'),
                price = r:getDataLong('price'), state = r:getDataInt('state'), date = r:getDataLong('date') }
            if (row.kind == KIND_POKEMON) then
                row.name, row.level = r:getDataString('pokemon_name'), r:getDataInt('pokemon_level')
                row.number = getPokemonNumberByName(row.name)
            elseif (CATALOG[itemid]) then
                row.name, row.client = CATALOG[itemid].name, CATALOG[itemid].clientId
            end
            history[#history + 1] = row
        until not r:next()
        r:free()
    end
    send(cid, { type = "mine", offers = offers, history = history }, history)
end

-- Pokemon offers

GTS.sendSpecies = function(cid, search)
    local where = ""
    if (search and search ~= "") then
        where = string.format(" AND `pokemon_name` LIKE %s", escape("%" .. search .. "%"))
    end

    local list = {}
    local r = db.getResult(string.format("SELECT `pokemon_name`, COUNT(*) AS `total`, MIN(`price`) AS `cheapest`"
            .. " FROM `gts_offers` WHERE `kind` = %d AND `expires` > %d%s GROUP BY `pokemon_name` ORDER BY `pokemon_name`",
        KIND_POKEMON, os.time(), where))
    if (r:getID() ~= -1) then
        repeat
            local name = r:getDataString('pokemon_name')
            list[#list + 1] = { name = name, number = getPokemonNumberByName(name), face = faceOf(name),
                count = r:getDataInt('total'), cheapest = r:getDataLong('cheapest') }
        until not r:next()
        r:free()
    end
    send(cid, { type = "species", search = search or "", list = list }, list)
end

GTS.sendListings = function(cid, name)
    local guid, list = getPlayerGUID(cid), {}
    rows(string.format("WHERE o.`kind` = %d AND o.`pokemon_name` = %s AND o.`expires` > %d ORDER BY o.`price` ASC LIMIT %d",
        KIND_POKEMON, escape(name), os.time(), GTS.LIST_LIMIT), function(r)
        local row = offerRow(r, guid)
        row.level = r:getDataInt('pokemon_level')
        local uid = loadBall(r)
        if (uid) then
            for key, value in pairs(pokemonSummary(uid)) do
                row[key] = value
            end
        end
        list[#list + 1] = row
    end)
    send(cid, { type = "listings", name = name, number = getPokemonNumberByName(name), list = list }, list)
end

GTS.sendPokemon = function(cid, id)
    local offer = getOffer(id)
    if (not offer or offer:getDataInt('kind') ~= KIND_POKEMON) then
        if (offer) then offer:free() end
        return result(cid, false, "This offer is no longer available.")
    end

    local uid = loadBall(offer)
    local name, level = offer:getDataString('pokemon_name'), offer:getDataInt('pokemon_level')
    local data = offerRow(offer, getPlayerGUID(cid))
    data.type, data.name, data.level, data.number = "pokemon", name, level, getPokemonNumberByName(name)
    data.ball = getItemInfo(offer:getDataInt('itemtype')).clientId
    if (uid) then
        GTS.describe(data, uid, name, level)
    end
    offer:free()
    send(cid, data)
end

GTS.sendMyPokemon = function(cid)
    local list = {}
    for index, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        local name = getBallPokemonName(ball.uid)
        local row = { index = index, name = name, number = getPokemonNumberByName(name), face = faceOf(name),
            level = getBallPokemonLevel(ball.uid), sex = getBallPokemonSex(ball.uid), problem = ballProblem(cid, ball) }
        if (row.problem) then
            row.problem = __L(cid, row.problem)
        end
        list[#list + 1] = row
    end
    send(cid, { type = "myPokemon", list = list }, list)
end

-- uids only last one script run: the ball is the index-th of sendMyPokemon's list, if it still holds that Pokemon
GTS.listPokemon = function(cid, index, price, name)
    local ball = getPlayerAllBallsWithPokemon(cid)[index]
    if (not ball or getBallPokemonName(ball.uid) ~= name) then
        return result(cid, false, "This Pokemon is not with you anymore.")
    end

    local problem = ballProblem(cid, ball)
    if (problem) then
        return result(cid, false, problem)
    elseif (not checkPrice(cid, 1, price)) then
        return false
    end

    PokemonStats.ensureBall(ball.uid)
    local level = getBallPokemonLevel(ball.uid)
    local attributes = getItemAttributesBlob(ball.uid)
    if (not attributes or not insertOffer(cid, KIND_POKEMON, 1, ball.itemid, 1, price, name, level, attributes)) then
        return result(cid, false, "Not possible, please try again later.")
    end

    doRemoveItem(ball.uid)
    doPlayerSave(cid) -- no copy of the ball may stay behind
    GTS.sendMyPokemon(cid)
    GTS.sendSpecies(cid)
    return result(cid, true, string.format("Your %s is now for sale.", name))
end
