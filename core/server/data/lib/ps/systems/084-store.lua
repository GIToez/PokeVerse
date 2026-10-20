-- The Store: what Soul Coins buy, from the Store button on the top bar. It replaced the Soul Coin NPCs
-- (npc/scripts/soulTrade.lua, kept but no longer on the map) and Josh Pillberg's vitamin reset.
--
-- Soul Coins are an account balance (`accounts`.`soulcoins`, shared by the account's characters) and an item
-- (Store.COIN_ID). Withdraw turns balance into coins in the bag and Deposit puts them back. A purchase takes the
-- balance first and then coins from the bag, so nobody has to withdraw to shop.
--
-- The window talks JSON on EXTENDED_IDS.STORE:
--   client -> server  {action = "open"}, {action = "buy", offer, count, text}, {action = "withdraw", amount},
--                     {action = "deposit", amount}, {action = "history"}
--   server -> client  {type = "store", balance, bag, premiumDays, sex, ball, guild, categories, offers}
--                     {type = "result", ok, text}
--                     {type = "history", list}

Store = {}

Store.COIN_ID = 6500
Store.MAX_COUNT = 100 -- of a consumable in one purchase
Store.MAX_TRANSFER = 10000 -- coins in one withdraw or deposit
Store.HISTORY_ROWS = 50
Store.NICK_MIN, Store.NICK_MAX = 4, 20
Store.NAME_FORBIDDEN = { "shiny", "shini", "shyni", "shyny" }

-- The categories in the window's order. Featured holds offers with featured = true (discounts, limited
-- editions, the holiday outfits while their event runs).
Store.CATEGORIES = {
    { id = "featured", name = "Featured", icon = "featured" },
    { id = "premium", name = "Premium", icon = "premium" },
    { id = "addons", name = "Pokemon Addons", icon = "addons" },
    { id = "outfits", name = "Trainer Outfits", icon = "outfits" },
    { id = "services", name = "Services", icon = "services" },
    { id = "items", name = "Consumables", icon = "items" },
    { id = "guild", name = "Guild", icon = "guild" },
}

-- kind: "premium" (days), "item" (itemId), "outfit" (outfitId from XML/outfits.xml), "sex", "nickname",
-- "unnickname", "vitamins", "guild", "rank". look/looks are what the window draws: a Pokemon or one look per sex
-- (female, male). use is the datalog_coin_uses id the NPCs logged the same thing with.
Store.OFFERS = {
    { id = "premium30", category = "premium", kind = "premium", days = 30, price = 15, use = 1, name = "30 days Premium",
      description = "Premium for the whole account, shared by its 3 characters. Added to the days you have left." },
    { id = "premium90", category = "premium", kind = "premium", days = 90, price = 40, was = 45, use = 1,
      name = "90 days Premium", description = "Three months of Premium for the price of less than three." },

    { id = "addon_kabutops", category = "addons", kind = "item", itemId = 29826, price = 15, use = 12, look = 2496,
      name = "Fossilized Kabutops", pokemon = "Kabutops", description = "Gives Kabutops its fossil look, also while it surfs." },
    { id = "addon_aerodactyl", category = "addons", kind = "item", itemId = 29827, price = 15, use = 12, look = 2494,
      name = "Fossilized Aerodactyl", pokemon = "Aerodactyl", description = "Gives Aerodactyl its fossil look, also while it flies." },
    { id = "addon_armaldo", category = "addons", kind = "item", itemId = 29829, price = 15, use = 12, look = 2497,
      name = "Fossilized Armaldo", pokemon = "Armaldo", description = "Gives Armaldo its fossil look." },
    { id = "addon_omastar", category = "addons", kind = "item", itemId = 29830, price = 15, use = 12, look = 2478,
      name = "Fossilized Omastar", pokemon = "Omastar", description = "Gives Omastar its fossil look, also while it surfs." },
    { id = "addon_greybeard", category = "addons", kind = "item", itemId = 29855, price = 15, use = 12, look = 2380,
      name = "Greybeard Costume", pokemon = "Slowking", description = "Dresses Slowking as a bearded wizard." },

    { id = "outfit_business", category = "outfits", kind = "outfit", outfitId = 53, price = 15, looks = { 1380, 1381 },
      name = "Business", description = "A sharp suit for trainers who mean business." },
    { id = "outfit_rider", category = "outfits", kind = "outfit", outfitId = 55, price = 15, looks = { 1384, 1385 },
      name = "Rider", description = "Biker leathers for the open road." },
    { id = "outfit_shinymaniac", category = "outfits", kind = "outfit", outfitId = 50, price = 15, looks = { 1370, 1370 },
      name = "Shiny Poke Maniac", description = "The Poke Maniac costume in its rare shiny colours." },

    { id = "nickname", category = "services", kind = "nickname", price = 1, use = 5, name = "Pokemon Nickname",
      description = "Names the Pokemon in your ball slot. 4 to 20 letters and spaces; it can't be a Pokemon's name or contain \"shiny\"." },
    { id = "unnickname", category = "services", kind = "unnickname", price = 0, name = "Remove Nickname",
      description = "The Pokemon in your ball slot goes back to its species name." },
    { id = "vitamins", category = "services", kind = "vitamins", price = 1, use = 10, name = "Vitamin Reset",
      description = "Removes every vitamin from the Pokemon in your ball slot, so you can give it new ones." },
    { id = "sex", category = "services", kind = "sex", price = 3, use = 2, name = "Sex Change",
      description = "Changes your trainer from male to female, or back." },

    { id = "stamina", category = "items", kind = "item", itemId = 13971, price = 1, use = 6, stack = true,
      name = "Stamina Recover", description = "A drink that recovers 10 hours of stamina." },
    { id = "eggmove", category = "items", kind = "item", itemId = 28915, price = 1, use = 11, stack = true,
      name = "Egg Move Capsule", description = "Teaches a Pokemon one of its egg moves." },

    { id = "guild", category = "guild", kind = "guild", price = 5, use = 8, name = "Create a Guild",
      description = "Forms a new guild with you as its leader. Needs level %d and no guild." },
    { id = "rank", category = "guild", kind = "rank", price = 1, use = 9, name = "New Guild Rank",
      description = "Adds a rank to your guild. Leaders only; give it to a member with /setrank name, rank." },
}

local byId = {}
for _, offer in ipairs(Store.OFFERS) do
    byId[offer.id] = offer
end

Store.offer = function(id)
    return byId[tostring(id or "")]
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.STORE, JSON.encode(data))
end

local function result(cid, ok, text, ...)
    send(cid, { type = "result", ok = ok, text = string.format(__L(cid, text), ...) })
    return ok
end

-- Balance -----------------------------------------------------------------------------------------------

Store.getBalance = function(accountId)
    local r = db.getResult(string.format("SELECT `soulcoins` FROM `accounts` WHERE `id` = %d", accountId))
    if (r:getID() == -1) then
        return 0
    end
    local balance = r:getDataInt("soulcoins")
    r:free()
    return balance
end

local function changedRows()
    local r = db.getResult("SELECT ROW_COUNT() AS `n`")
    if (r:getID() == -1) then
        return 0
    end
    local n = r:getDataInt("n")
    r:free()
    return n
end

-- Takes amount from the balance in one statement that can't go below zero; false when it isn't there.
-- Nothing else (a second character, a payment landing) can change the balance between the check and the write.
Store.takeBalance = function(accountId, amount)
    if (amount <= 0) then
        return true
    end
    db.executeQuery(string.format("UPDATE `accounts` SET `soulcoins` = `soulcoins` - %d WHERE `id` = %d AND `soulcoins` >= %d",
        amount, accountId, amount))
    return changedRows() == 1
end

Store.addBalance = function(accountId, amount)
    if (amount <= 0) then
        return true
    end
    return db.executeQuery(string.format("UPDATE `accounts` SET `soulcoins` = `soulcoins` + %d WHERE `id` = %d", amount, accountId))
end

local function log(cid, text, amount)
    db.executeQuery(string.format("INSERT INTO `store_history` (`account_id`, `player_id`, `date`, `amount`, `description`)"
        .. " VALUES (%d, %d, %d, %d, %s)", getPlayerAccountId(cid), getPlayerGUID(cid), os.time(), amount,
        db.escapeString(text)))
end

-- Pays price from the balance first, then from coins in the bag: true, or false and why not
local function pay(cid, price)
    if (price <= 0) then
        return true
    end
    local account = getPlayerAccountId(cid)
    local fromBalance = math.min(Store.getBalance(account), price)
    local fromBag = price - fromBalance
    if (getPlayerItemCount(cid, Store.COIN_ID) < fromBag) then
        return false, "You need %d Soul Coins for this."
    elseif (not Store.takeBalance(account, fromBalance)) then
        return false, "Your Soul Coin balance changed. Try again."
    elseif (fromBag > 0 and not doPlayerRemoveItem(cid, Store.COIN_ID, fromBag)) then
        Store.addBalance(account, fromBalance)
        return false, "You need %d Soul Coins for this."
    end
    return true
end

local function refund(cid, price)
    Store.addBalance(getPlayerAccountId(cid), price)
end

-- State -------------------------------------------------------------------------------------------------

local function ballInfo(cid)
    local ball = getPlayerBall(cid)
    if (not isItem(ball) or not isBallWithPokemon(ball.uid)) then
        return nil
    end
    local name = getBallPokemonName(ball.uid)
    local nickname = getBallPokemonNickname(ball.uid)
    return { name = name, level = getBallPokemonLevel(ball.uid), number = getPokemonNumberByName(name),
             nickname = (nickname and nickname ~= "" and nickname ~= name) and nickname or nil,
             vitamins = getBallTotalVitamins(ball.uid) }
end

local function guildInfo(cid)
    local id = getPlayerGuildId(cid)
    if (id <= 0) then
        return nil
    end
    return { name = getPlayerGuildName(cid), leader = getPlayerGuildLevel(cid) == GUILDLEVEL_LEADER or nil }
end

local function hasOutfit(cid, offer)
    return canPlayerWearOutfitId(cid, offer.outfitId, 0)
end

local function offerList(cid)
    local list = JSON.array()
    for _, offer in ipairs(Store.OFFERS) do
        local entry = { id = offer.id, category = offer.category, featured = offer.featured or nil, kind = offer.kind,
                        name = __L(cid, offer.name), price = offer.price, was = offer.was, look = offer.look,
                        looks = offer.looks, pokemon = offer.pokemon, stack = offer.stack or nil, days = offer.days }
        entry.description = __L(cid, offer.description)
        if (offer.kind == "guild") then
            entry.description = string.format(entry.description, getConfigValue("levelToFormGuild"))
        end
        if (offer.itemId) then
            entry.item = getItemClientId(offer.itemId) or 0
        end
        if (offer.kind == "outfit" and hasOutfit(cid, offer)) then
            entry.owned = true
        end
        list[#list + 1] = entry
    end
    return list
end

local function categoryList(cid)
    local list = JSON.array()
    for _, category in ipairs(Store.CATEGORIES) do
        list[#list + 1] = { id = category.id, name = __L(cid, category.name), icon = category.icon }
    end
    return list
end

Store.sendState = function(cid)
    send(cid, { type = "store", balance = Store.getBalance(getPlayerAccountId(cid)),
                bag = getPlayerItemCount(cid, Store.COIN_ID), premiumDays = getPlayerPremiumDays(cid),
                sex = getPlayerSex(cid), ball = ballInfo(cid), guild = guildInfo(cid),
                categories = categoryList(cid), offers = offerList(cid),
                nick = { min = Store.NICK_MIN, max = Store.NICK_MAX } })
end

Store.sendHistory = function(cid)
    local list = JSON.array()
    local r = db.getResult(string.format("SELECT h.`date`, h.`amount`, h.`description`, p.`name` FROM `store_history` h"
        .. " LEFT JOIN `players` p ON p.`id` = h.`player_id` WHERE h.`account_id` = %d ORDER BY h.`id` DESC LIMIT %d",
        getPlayerAccountId(cid), Store.HISTORY_ROWS))
    if (r:getID() ~= -1) then
        repeat
            list[#list + 1] = { date = r:getDataInt("date"), amount = r:getDataInt("amount"),
                                text = r:getDataString("description"), player = r:getDataString("name") }
        until not r:next()
        r:free()
    end
    send(cid, { type = "history", list = list })
end

-- Checks ------------------------------------------------------------------------------------------------

-- A nickname or guild name the NPCs accepted: letters and spaces, no Pokemon's name, no "shiny"
Store.nameAcceptable = function(name)
    name = tostring(name or "")
    if (#name < Store.NICK_MIN or #name > Store.NICK_MAX or not name:match("^[A-Za-z ]+$") or name:match("^ ")
            or name:match(" $") or name:match("  ")) then
        return false
    end
    local lower = name:lower()
    for _, word in ipairs(Store.NAME_FORBIDDEN) do
        if (lower:find(word, 1, true)) then
            return false
        end
    end
    return not isPokemonName(name)
end

local function ballBusy(cid)
    return isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid)
end

-- Why this purchase can't happen, or nil. text is the name the offer asks for.
local function blocker(cid, offer, text)
    local kind = offer.kind
    if (kind == "outfit" and hasOutfit(cid, offer)) then
        return "You already have this outfit."
    elseif (kind == "nickname" or kind == "unnickname" or kind == "vitamins") then
        local ball = getPlayerBall(cid)
        if (not isItem(ball) or not isBallWithPokemon(ball.uid)) then
            return "Put a ball in your ball slot first."
        elseif (ballBusy(cid)) then
            return "Call your Pokemon back into its ball first."
        elseif (kind == "nickname" and not Store.nameAcceptable(text)) then
            return "A nickname is 4 to 20 letters and spaces, and can't be a Pokemon's name or contain \"shiny\"."
        elseif (kind == "unnickname" and not ballInfo(cid).nickname) then
            return "This Pokemon has no nickname."
        elseif (kind == "vitamins" and getBallTotalVitamins(ball.uid) == 0) then
            return "This Pokemon has no vitamins."
        end
    elseif (kind == "guild") then
        if (getPlayerGuildId(cid) > 0) then
            return "You are already in a guild."
        elseif (getPlayerLevel(cid) < getConfigValue("levelToFormGuild")) then
            return string.format(__L(cid, "You need at least level %d to form a guild."), getConfigValue("levelToFormGuild"))
        elseif (getPlayerPremiumDays(cid) < getConfigValue("premiumDaysToFormGuild")) then
            return string.format(__L(cid, "You need at least %d premium days to form a guild."), getConfigValue("premiumDaysToFormGuild"))
        elseif (not Store.nameAcceptable(text)) then
            return "A guild name is 4 to 20 letters and spaces, and can't be a Pokemon's name or contain \"shiny\"."
        elseif (getGuildId(text)) then
            return "There is already a guild with that name."
        end
    elseif (kind == "rank") then
        if (getPlayerGuildId(cid) <= 0) then
            return "You aren't in a guild."
        elseif (getPlayerGuildLevel(cid) ~= GUILDLEVEL_LEADER) then
            return "Only the leader of your guild can add ranks."
        elseif (not Store.nameAcceptable(text)) then
            return "A rank name is 4 to 20 letters and spaces, and can't be a Pokemon's name or contain \"shiny\"."
        end
    end
    return nil
end

-- Gives what was bought: true, or false when it couldn't be given (the coins go back)
local function deliver(cid, offer, count, text)
    local kind = offer.kind
    if (kind == "premium") then
        doPlayerAddPremiumDays(cid, offer.days)
        Referral.onPlayerAcquirePremium(cid)
    elseif (kind == "item") then
        return doPlayerSafeAddItem(cid, offer.itemId, count, false) ~= false
    elseif (kind == "outfit") then
        doPlayerAddOutfitId(cid, offer.outfitId, 0)
    elseif (kind == "sex") then
        doPlayerSetSex(cid, getPlayerSex(cid) == PLAYERSEX_FEMALE and PLAYERSEX_MALE or PLAYERSEX_FEMALE)
    elseif (kind == "nickname" or kind == "unnickname") then
        local ball = getPlayerBall(cid)
        local oldNick = getBallPokemonNickname(ball.uid) or ""
        if (kind == "nickname") then
            setPlayerPokemonNickname(cid, text, false)
            doDatalogPokeNickChange(cid, oldNick, text, os.time())
            doPlayerAddStatistic(cid, PLAYER_STATISTIC_IDS.CHANGE_POKEMON_NICKNAME, 1)
        else
            setPlayerPokemonNickname(cid, (getBallPokemonName(ball.uid):gsub("^Shiny ", "")), true)
            doDatalogPokeNickChange(cid, oldNick, "", os.time())
        end
    elseif (kind == "vitamins") then
        Vitamin.doResetBall(getPlayerBall(cid))
    elseif (kind == "guild") then
        return doCreateGuild(cid, text) and true or false
    elseif (kind == "rank") then
        return doGuildCreateRank(getPlayerGuildId(cid), text) and true or false
    end
    return true
end

local DONE = {
    premium = "%d days of Premium were added to your account.",
    item = "You got %s. It is in your bag, or in your depot if the bag was full.",
    outfit = "The %s outfit is yours. Pick it in the outfit window.",
    sex = "Your trainer's sex has been changed.",
    nickname = "Your Pokemon is now called %s.",
    unnickname = "Your Pokemon's nickname was removed.",
    vitamins = "Your Pokemon's vitamins were reset.",
    guild = "Your guild %s has been formed!",
    rank = "The rank %s was added to your guild.",
}

Store.buy = function(cid, id, count, text)
    local offer = Store.offer(id)
    if (not offer) then
        return result(cid, false, "That offer isn't in the Store anymore.")
    end
    count = offer.stack and math.max(1, math.min(Store.MAX_COUNT, math.floor(tonumber(count) or 1))) or 1
    text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local why = blocker(cid, offer, text)
    if (why) then
        return result(cid, false, why)
    end
    local price = offer.price * count
    local ok, payWhy = pay(cid, price)
    if (not ok) then
        return result(cid, false, payWhy, price)
    end
    if (not deliver(cid, offer, count, text)) then
        refund(cid, price)
        Store.sendState(cid)
        return result(cid, false, "That didn't work, and your Soul Coins went back to your balance.")
    end
    if (offer.use and price > 0) then
        doDatalogCoinUse(os.time(), getPlayerGUID(cid), offer.use, price)
    end
    local label = (offer.stack and count > 1) and string.format("%dx %s", count, offer.name) or offer.name
    if (offer.kind == "nickname" or offer.kind == "guild" or offer.kind == "rank") then
        label = string.format("%s: %s", offer.name, text)
    end
    log(cid, label, -price)
    doPlayerSave(cid)
    print(string.format("> Store: %s bought %s for %d Soul Coins", getCreatureName(cid), label, price))

    local done = DONE[offer.kind]
    local arg = offer.kind == "premium" and offer.days or (offer.kind == "item" and label) or
        (offer.kind == "outfit" and offer.name) or text
    Store.sendState(cid)
    return result(cid, true, done, arg)
end

Store.withdraw = function(cid, amount)
    amount = math.floor(tonumber(amount) or 0)
    if (amount <= 0 or amount > Store.MAX_TRANSFER) then
        return result(cid, false, "Withdraw between 1 and %d Soul Coins.", Store.MAX_TRANSFER)
    end
    local account = getPlayerAccountId(cid)
    if (not Store.takeBalance(account, amount)) then
        return result(cid, false, "Your balance doesn't have %d Soul Coins.", amount)
    end
    local given = 0
    while (given < amount) do
        local stack = math.min(100, amount - given)
        if (not doPlayerSafeAddItem(cid, Store.COIN_ID, stack, false)) then
            break
        end
        given = given + stack
    end
    if (given < amount) then
        Store.addBalance(account, amount - given)
        if (given == 0) then
            return result(cid, false, "There is no room for the coins. Nothing was withdrawn.")
        end
        amount = given
    end
    log(cid, "Withdrew to the bag", -amount)
    doPlayerSave(cid)
    Store.sendState(cid)
    return result(cid, true, "%d Soul Coins are in your bag now (or your depot, where the bag was full).", amount)
end

Store.deposit = function(cid, amount)
    amount = math.floor(tonumber(amount) or 0)
    if (amount <= 0 or amount > Store.MAX_TRANSFER) then
        return result(cid, false, "Deposit between 1 and %d Soul Coins.", Store.MAX_TRANSFER)
    elseif (getPlayerItemCount(cid, Store.COIN_ID) < amount or not doPlayerRemoveItem(cid, Store.COIN_ID, amount)) then
        return result(cid, false, "You don't carry %d Soul Coins.", amount)
    end
    Store.addBalance(getPlayerAccountId(cid), amount)
    log(cid, "Deposited from the bag", amount)
    doPlayerSave(cid)
    Store.sendState(cid)
    return result(cid, true, "%d Soul Coins were added to your balance.", amount)
end

Store.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or "")
    if (action == "open") then
        Store.sendState(cid)
    elseif (action == "buy") then
        Store.buy(cid, data.offer, data.count, data.text)
    elseif (action == "withdraw") then
        Store.withdraw(cid, data.amount)
    elseif (action == "deposit") then
        Store.deposit(cid, data.amount)
    elseif (action == "history") then
        Store.sendHistory(cid)
    end
end
