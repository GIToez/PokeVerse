-- Event Token Shop: holiday catalogs (Halloween Tokens, Anniversary Tokens / letters). The NPCs open
-- the window for clients that have it; their name+yes/no talk still works for old clients.
--
-- The client talks JSON on EXTENDED_IDS.EVENT_SHOP:
--   client -> server  {action = "hello"} at login; {action = "buy", offer, count}; {action = "close"}
--   server -> client  {type = "shop", shop, npc, title, token, tokenName, tokenShort, balance, mode,
--                     categories, offers} opens or refreshes the window;
--                     {type = "result", ok, text}; {type = "close"}

if (EventShop) then
    return
end

EventShop = {}
EventShop.RANGE = 4
EventShop.MAX_COUNT = 100

local CLIENT = playersStorages.eventShopClient
local NPC = playersStorages.eventShopNpc
local SHOP = playersStorages.eventShopId

local TOKEN = {
    HALLOWEEN = 14461,
    ANNIVERSARY = 27935,
}
local LETTERS_PSOUL = { 14438, 14439, 14440, 14441, 14442 }

local CATEGORY_NAMES = {
    all = "All",
    kits = "Kits",
    decorations = "Decorations",
    dolls = "Dolls",
    consumables = "Consumables",
    tms = "TMs",
    outfits = "Outfits",
    addons = "Addons",
    tickets = "Tickets",
    letters = "Letters",
    psoul = "PSoul",
    lockers = "Lockers",
}

local function inferCategory(offer)
    if (offer.category) then
        return offer.category
    end
    local n, d = string.lower(offer.name), string.lower(offer.description or "")
    if (offer.costItems) then
        return "lockers"
    end
    if (n:find("psoul", 1, true)) then
        return "psoul"
    end
    if (n:find("letter", 1, true)) then
        return "letters"
    end
    if (n:find("tm ", 1, true) == 1) then
        return "tms"
    end
    if (d == "outfit") then
        return "outfits"
    end
    if (d:find("addon", 1, true)) then
        return "addons"
    end
    if (n:find("locker", 1, true)) then
        return "lockers"
    end
    if (n:find("kit", 1, true)) then
        return "kits"
    end
    if (n:find("doll", 1, true)) then
        return "dolls"
    end
    if (n:find("candy", 1, true) or n:find("ball", 1, true) or n:find("wand", 1, true) or n:find("staff", 1, true)) then
        return "consumables"
    end
    if (n:find("ticket", 1, true)) then
        return "tickets"
    end
    return "decorations"
end

local function indexOffers(shop)
    shop.byId = {}
    for _, offer in ipairs(shop.offers) do
        offer.id = offer.id or string.lower(offer.name)
        offer.category = inferCategory(offer)
        offer.count = offer.count or 1
        offer.price = offer.price or offer.tokens or offer.halloweenTokens or 0
        shop.byId[offer.id] = offer
    end
end

EventShop.SHOPS = {
    halloween_trevor = {
        npc = "Trevor",
        title = "Halloween Tokens",
        tokenId = TOKEN.HALLOWEEN,
        tokenShort = "HT",
        tokenName = "Halloween Token",
        uniqueToken = true,
        mode = "buy",
        thanks = "Heereee is... thaaanksss!",
        notEnough = "You do not have enough halloween tokens for it.",
        offers = {
            { name = "toy spider", itemId = 9006, price = 20 },
            { name = "vampire doll", itemId = 9019, price = 30 },
            { name = "mummy doll", itemId = 11201, price = 20 },
            { name = "bat decoration", itemId = 6492, price = 15 },
            { name = "skull tapestry", itemId = 5616, price = 8 },
            { name = "skeleton decoration", itemId = 6526, price = 15 },
            { name = "pumpkin amulet", itemId = 14462, price = 20 },
            { name = "skull backpack", itemId = 5926, price = 30 },
            { name = "skull bag", itemId = 5927, price = 18 },
            { name = "enchanted staff", itemId = 14457, price = 2, count = 10 },
            { name = "light wand", itemId = 14458, price = 1, count = 10 },
            { name = "pumpkin ball", itemId = 14459, price = 40 },
            { name = "skull ball", itemId = 14460, price = 40 },
            {
                name = "rare candy",
                itemId = 14463,
                price = 100,
                unique = true,
                onBuy = function(cid)
                    doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.BUY_RARE_CANDY)
                    setPlayerBoughtRareCandy(cid, getPlayerBoughtRareCandy(cid) + 1)
                end,
                canBuy = function(cid) return getPlayerBoughtRareCandy(cid) < 15 end,
                onBuyError = "You can only buy 15 Rare Candys during this event, your account already bought all!",
            },
            { name = "halloween kit 1", itemId = 18719, price = 50, description = "skull / frankenstein" },
            { name = "halloween kit 2", itemId = 18720, price = 100, description = "witch / mummy" },
            { name = "halloween kit 3", itemId = 18721, price = 150, description = "naughty devil / skeleton" },
            { name = "halloween kit 4", itemId = 18722, price = 200, description = "dark witch / vampire" },
            { name = "gastly lamp", itemId = 18056, price = 50 },
            { name = "cubone lamp", itemId = 18058, price = 50 },
            { name = "black pikachu doll", itemId = 19086, price = 100 },
            { name = "blue pikachu doll", itemId = 19087, price = 100 },
            { name = "bulbasaur doll", itemId = 19088, price = 100 },
            { name = "charmander doll", itemId = 19089, price = 100 },
            { name = "squirtle doll", itemId = 19090, price = 100 },
            { name = "halloween kit 6", itemId = 25157, price = 200, description = "panico" },
            { name = "halloween kit 7", itemId = 25158, price = 200, description = "clown" },
            { name = "zubat statue kit", itemId = 25143, price = 100 },
            { name = "golbat statue kit", itemId = 25144, price = 100 },
            { name = "crobat statue kit", itemId = 25145, price = 100 },
            { name = "skull chair kit", itemId = 25146, price = 100 },
            { name = "blue skull chair kit", itemId = 25147, price = 100 },
            { name = "pumpkin chair kit", itemId = 25148, price = 100 },
            { name = "pumpkin freezer kit", itemId = 25149, price = 100 },
            { name = "halloween table kit", itemId = 25150, price = 100 },
            { name = "golbat computer kit", itemId = 25151, price = 100 },
            { name = "halloween stand #1 kit", itemId = 25152, price = 100 },
            { name = "halloween stand #2 kit", itemId = 25153, price = 100 },
            { name = "halloween stand #3 kit", itemId = 25154, price = 100 },
            { name = "halloween stand #4 kit", itemId = 25155, price = 100 },
            { name = "pumpkin tree kit", itemId = 25156, price = 100 },
            { name = "green misdreavus curtain kit", itemId = 25187, price = 30 },
            { name = "purple misdreavus curtain kit", itemId = 25188, price = 30 },
            { name = "pumpkin curtain kit", itemId = 25189, price = 30 },
            { name = "pumpkinhead", itemId = 25094, price = 50 },
            { name = "pumpkin flower kit", itemId = 25190, price = 50 },
            { name = "elder god statue kit", itemId = 28159, price = 50 },
            { name = "imperial boat decoration kit", itemId = 28156, price = 50 },
            { name = "kraken boat decoration kit", itemId = 28157, price = 50 },
            { name = "pirate boat decoration kit", itemId = 28158, price = 50 },
        },
    },
    anniversary_letters = {
        npc = "Timothy Kelvin",
        title = "Anniversary Letters",
        tokenId = TOKEN.ANNIVERSARY,
        tokenShort = "AT",
        tokenName = "Anniversary Token",
        uniqueToken = true,
        mode = "sell",
        thanks = "Oh, thanks!",
        notEnough = "You do not have enough items for it.",
        offers = {
            { name = "letter A", itemId = 27819, price = 1 },
            { name = "letter B", itemId = 27820, price = 1 },
            { name = "letter C", itemId = 27821, price = 1 },
            { name = "letter D", itemId = 27822, price = 1 },
            { name = "letter E", itemId = 27823, price = 1 },
            { name = "letter F", itemId = 27825, price = 1 },
            { name = "letter G", itemId = 27826, price = 1 },
            { name = "letter H", itemId = 27827, price = 1 },
            { name = "letter I", itemId = 27828, price = 1 },
            { name = "letter J", itemId = 27830, price = 1 },
            { name = "letter K", itemId = 27831, price = 1 },
            { name = "letter L", itemId = 14438, price = 1 },
            { name = "letter M", itemId = 27832, price = 1 },
            { name = "letter N", itemId = 27833, price = 1 },
            { name = "letter O", itemId = 14439, price = 1 },
            { name = "letter P", itemId = 14440, price = 1 },
            { name = "letter Q", itemId = 27834, price = 1 },
            { name = "letter R", itemId = 27835, price = 1 },
            { name = "letter S", itemId = 14441, price = 1 },
            { name = "letter T", itemId = 27836, price = 1 },
            { name = "letter U", itemId = 14442, price = 1 },
            { name = "letter V", itemId = 27837, price = 1 },
            { name = "letter W", itemId = 27838, price = 1 },
            { name = "letter X", itemId = 27839, price = 1 },
            { name = "letter Y", itemId = 27840, price = 1 },
            { name = "letter Z", itemId = 27841, price = 1 },
            { name = "letter ?", itemId = 27829, price = 2 },
            { name = "letter !", itemId = 27824, price = 2 },
            { name = "PSoul letter P", itemId = 27844, price = 3 },
            { name = "PSoul letter S", itemId = 27845, price = 3 },
            { name = "PSoul letter O", itemId = 27843, price = 3 },
            { name = "PSoul letter U", itemId = 27846, price = 3 },
            { name = "PSoul letter L", itemId = 27842, price = 3 },
        },
    },
    anniversary_gifts = {
        npc = "Murray Aaron",
        title = "Anniversary Gifts",
        tokenId = TOKEN.ANNIVERSARY,
        tokenShort = "AT",
        tokenName = "Anniversary Token",
        uniqueToken = false,
        mode = "buy",
        thanks = "Oh, thanks!",
        notEnough = "You do not have enough token(s) for it.",
        offers = {
            { name = "tm energy ball", itemId = 24720, price = 80 },
            { name = "tm poison jab", itemId = 24722, price = 80 },
            { name = "tm rock tomb", itemId = 24717, price = 80 },
            { name = "tm drain punch", itemId = 24721, price = 80 },
            { name = "god crespi doll", itemId = 27816, price = 40 },
            { name = "god loki doll", itemId = 27817, price = 40 },
            { name = "god slowmotion doll", itemId = 27818, price = 40 },
            { name = "azurill/blastoise costume", itemId = 29885, price = 50, description = "Outfit" },
            { name = "pikachu/charizard costume", itemId = 29886, price = 50, description = "Outfit" },
            { name = "skarmory battle armor", itemId = 29848, price = 70, description = "Pokemon Addon" },
            { name = "kingdra battle armor", itemId = 29849, price = 70, description = "Pokemon Addon" },
            { name = "charizard battle armor", itemId = 29857, price = 70, description = "Pokemon Addon" },
            { name = "battle armor", itemId = 29850, price = 70, description = "Pokemon Addon" },
            { name = "royal armor", itemId = 29818, price = 70, description = "Pokemon Addon" },
            { name = "boo costume", itemId = 29819, price = 70, description = "Pokemon Addon" },
            { name = "firestone paint ticket", itemId = 29890, price = 25 },
            { name = "sunstone paint ticket", itemId = 29898, price = 25 },
            { name = "waterstone paint ticket", itemId = 29910, price = 25 },
            { name = "golem paint ticket", itemId = 29894, price = 25 },
            { name = "tentacruel paint ticket", itemId = 29902, price = 25 },
            { name = "vanish paint ticket", itemId = 29906, price = 25 },
            { name = "ruby tapestry", itemId = 29985, price = 3 },
            { name = "citrine tapestry", itemId = 29988, price = 3 },
            { name = "topaz tapestry", itemId = 29991, price = 3 },
            { name = "sapphire tapestry", itemId = 29994, price = 3 },
            { name = "lapis lazuli tapestry", itemId = 29997, price = 3 },
            { name = "charoite tapestry", itemId = 30000, price = 3 },
            { name = "pearl tapestry", itemId = 30102, price = 3 },
            { name = "diamond tapestry", itemId = 30105, price = 3 },
            { name = "morganite tapestry", itemId = 30135, price = 3 },
            { name = "red wooden bed", itemId = 30124, price = 15 },
            { name = "orange wooden bed", itemId = 30125, price = 15 },
            { name = "yellow wooden bed", itemId = 30126, price = 15 },
            { name = "green wooden bed", itemId = 30127, price = 15 },
            { name = "blue wooden bed", itemId = 30128, price = 15 },
            { name = "purple wooden bed", itemId = 30129, price = 15 },
            { name = "pink wooden bed", itemId = 30130, price = 15 },
            { name = "black wooden bed", itemId = 30131, price = 15 },
            { name = "white wooden bed", itemId = 30132, price = 15 },
            { name = "kangaskhan locker", itemId = 26182, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "aggron locker", itemId = 26183, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "absol locker", itemId = 26184, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "sceptile locker", itemId = 26185, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "rhydon locker", itemId = 26186, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "gardevoir locker", itemId = 26187, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "electivire locker", itemId = 26188, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "feraligatr locker", itemId = 26189, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "infernape locker", itemId = 26190, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
            { name = "dragonair locker", itemId = 26191, price = 0, costItems = LETTERS_PSOUL, description = "P, S, O, U and L letters" },
        },
    },
}

for _, shop in pairs(EventShop.SHOPS) do
    indexOffers(shop)
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.EVENT_SHOP, JSON.encode(data))
end

local function result(cid, ok, text)
    send(cid, { type = "result", ok = ok, text = text })
    return ok, text
end

local function tokenCount(cid, shop)
    if (shop.uniqueToken) then
        return getPlayerItemCountByUnique(cid, shop.tokenId)
    end
    return getPlayerItemCount(cid, shop.tokenId)
end

local function takeTokens(cid, shop, amount)
    if (amount <= 0) then
        return true
    end
    if (shop.uniqueToken) then
        return doPlayerRemoveItemByUnique(cid, shop.tokenId, amount)
    end
    return doPlayerRemoveItem(cid, shop.tokenId, amount)
end

local function categoriesOf(shop)
    local seen, order = {}, { "all" }
    for _, offer in ipairs(shop.offers) do
        if (not seen[offer.category]) then
            seen[offer.category] = true
            order[#order + 1] = offer.category
        end
    end
    local list = JSON.array()
    for _, id in ipairs(order) do
        list[#list + 1] = { id = id, name = CATEGORY_NAMES[id] or id }
    end
    return list
end

local function offerNote(offer)
    if (offer.costItems) then
        return offer.description or "P, S, O, U and L letters"
    end
    return offer.description
end

local function offerLocked(cid, shop, offer)
    if (offer.canBuy and not offer.canBuy(cid)) then
        return true, offer.onBuyError
    end
    if (shop.mode == "sell") then
        local have = getPlayerItemCount(cid, offer.itemId)
        if (have < 1) then
            return true, shop.notEnough
        end
        return false, nil, have
    end
    if (offer.costItems) then
        for _, itemId in ipairs(offer.costItems) do
            if (getPlayerItemCount(cid, itemId) < 1) then
                return true, "You do not have enough letters for it."
            end
        end
    end
    return false
end

local function offerList(cid, shop)
    local list = JSON.array()
    for _, offer in ipairs(shop.offers) do
        local locked, lockText, have = offerLocked(cid, shop, offer)
        list[#list + 1] = {
            id = offer.id,
            name = offer.name,
            note = offerNote(offer),
            item = getItemClientId(offer.itemId) or 0,
            price = offer.price,
            count = offer.count,
            category = offer.category,
            locked = locked or nil,
            lockText = lockText,
            have = have,
            letters = offer.costItems and true or nil,
        }
    end
    return list
end

EventShop.get = function(shopId)
    return EventShop.SHOPS[shopId]
end

EventShop.findOffer = function(shopId, name)
    local shop = EventShop.SHOPS[shopId]
    return shop and shop.byId[string.lower(name or "")]
end

EventShop.fyi = function(shopId)
    local shop = EventShop.SHOPS[shopId]
    if (not shop) then
        return ""
    end
    local message = {}
    for _, offer in ipairs(shop.offers) do
        message[#message + 1] = offer.name
        if (offer.description) then
            message[#message + 1] = " ("
            message[#message + 1] = offer.description
            message[#message + 1] = ")"
        end
        message[#message + 1] = " ["
        if (shop.mode == "sell") then
            message[#message + 1] = "1x]["
            message[#message + 1] = offer.price
            message[#message + 1] = "x "
            message[#message + 1] = shop.tokenShort
            message[#message + 1] = "]\n"
        elseif (offer.costItems) then
            message[#message + 1] = offer.count
            message[#message + 1] = "x]\n"
        else
            message[#message + 1] = offer.count
            message[#message + 1] = "x]["
            message[#message + 1] = offer.price
            message[#message + 1] = "x "
            message[#message + 1] = shop.tokenShort
            message[#message + 1] = "]\n"
        end
    end
    message[#message + 1] = "\n"
    message[#message + 1] = shop.tokenShort
    message[#message + 1] = " = "
    message[#message + 1] = shop.tokenName
    return table.concat(message)
end

EventShop.enabled = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1
end

EventShop.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
    setPlayerStorageValue(cid, NPC, -1)
    setPlayerStorageValue(cid, SHOP, -1)
end

local function npcNear(cid)
    local name = getPlayerStorageValue(cid, NPC)
    if (type(name) ~= "string") then
        return nil
    end
    for _, creature in ipairs(getSpectators(getCreaturePosition(cid), EventShop.RANGE, EventShop.RANGE, false) or {}) do
        if (isNpc(creature) and getCreatureName(creature) == name) then
            return creature
        end
    end
    return nil
end

EventShop.sendState = function(cid)
    local shopId = getPlayerStorageValue(cid, SHOP)
    local shop = type(shopId) == "string" and EventShop.SHOPS[shopId]
    if (not shop) then
        return
    end
    local npc = getPlayerStorageValue(cid, NPC)
    send(cid, {
        type = "shop",
        shop = shopId,
        npc = type(npc) == "string" and npc or shop.npc,
        title = shop.title,
        token = getItemClientId(shop.tokenId) or 0,
        tokenName = shop.tokenName,
        tokenShort = shop.tokenShort,
        balance = tokenCount(cid, shop),
        mode = shop.mode,
        categories = categoriesOf(shop),
        offers = offerList(cid, shop),
    })
end

-- A token NPC talking to the trainer: opens the window. False for clients without it.
EventShop.open = function(cid, shopId, npc)
    local shop = EventShop.SHOPS[shopId]
    if (not shop or not EventShop.enabled(cid)) then
        return false
    end
    setPlayerStorageValue(cid, NPC, getCreatureName(npc))
    setPlayerStorageValue(cid, SHOP, shopId)
    EventShop.sendState(cid)
    return true
end

local function giveReward(cid, offer, amount)
    local count = (offer.count or 1) * (amount or 1)
    return doPlayerSafeAddItem(cid, offer.itemId, count, true, offer.unique)
end

-- Buy with tokens, turn letters into tokens, or spend the PSoul letters on a locker.
EventShop.exchange = function(cid, shopId, offerId, amount)
    local shop = EventShop.SHOPS[shopId]
    local offer = shop and shop.byId[string.lower(offerId or "")]
    if (not shop or not offer) then
        return false, "Whaat?"
    end
    amount = math.floor(tonumber(amount) or 1)
    if (amount < 1 or amount > EventShop.MAX_COUNT) then
        return false, "Whaat?"
    end
    if (shop.mode ~= "sell") then
        amount = 1
    end
    if (offer.canBuy and not offer.canBuy(cid)) then
        return false, offer.onBuyError
    end

    if (shop.mode == "sell") then
        if (getPlayerItemCount(cid, offer.itemId) < amount or not doPlayerRemoveItem(cid, offer.itemId, amount)) then
            return false, shop.notEnough
        end
        doPlayerSafeAddItem(cid, shop.tokenId, amount * offer.price, true, true)
        if (offer.onBuy) then
            offer.onBuy(cid)
        end
        return true, shop.thanks
    end

    if (offer.costItems) then
        for _, itemId in ipairs(offer.costItems) do
            if (getPlayerItemCount(cid, itemId) < 1) then
                return false, "You do not have enough letters for it."
            end
        end
        for _, itemId in ipairs(offer.costItems) do
            doPlayerRemoveItem(cid, itemId, 1)
        end
        giveReward(cid, offer, 1)
        if (offer.onBuy) then
            offer.onBuy(cid)
        end
        return true, shop.thanks
    end

    local cost = offer.price
    if (tokenCount(cid, shop) < cost or not takeTokens(cid, shop, cost)) then
        return false, shop.notEnough
    end
    giveReward(cid, offer, 1)
    if (offer.onBuy) then
        offer.onBuy(cid)
    end
    return true, shop.thanks
end

EventShop.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
        return
    end
    if (data.action == "close") then
        setPlayerStorageValue(cid, NPC, -1)
        setPlayerStorageValue(cid, SHOP, -1)
        return
    end
    if (not npcNear(cid)) then
        setPlayerStorageValue(cid, NPC, -1)
        setPlayerStorageValue(cid, SHOP, -1)
        send(cid, { type = "close" })
        return result(cid, false, __L(cid, "You walked away."))
    end
    if (data.action == "buy") then
        local shopId = getPlayerStorageValue(cid, SHOP)
        local exchanged, text = EventShop.exchange(cid, shopId, data.offer, data.count)
        if (exchanged) then
            EventShop.sendState(cid)
        end
        result(cid, exchanged, text)
    end
end
