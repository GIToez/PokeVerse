-- Pokepedia: the client's encyclopedia window (game_pokepedia) with Map, Houses, Pokedex and Items
-- tabs, and its tracker panel. The client sends JSON requests over EXTENDED_IDS.POKEPEDIA, one
-- {action = ...} each, and draws the {type = ...} messages that come back.
--
--   Houses: the list, a house's details and tiles, buying from anywhere, leaving, the guest and
--     sub-owner lists, and transfers (the owner names a buyer and a price, the buyer confirms).
--     The /house commands keep working.
--   Items: every item the trainer could know, by category. Shop items are known from the start;
--     the rest is discovered by having one in the bag or depot, or by looking at one.
--   Pokedex knowledge: defeats and catches per species raise what a wild Pokemon's Pokedex entry
--     shows (doPokedexItemView), up to the spawn areas; completing species gives rewards.

Pokepedia = {}

Pokepedia.TRANSFER_TIME = 5 * 60
Pokepedia.MAX_PRICE = 100000000
Pokepedia.REQUESTS_PER_SECOND = 12

local MESSAGE_LIMIT = 200000
local COMPLETED = playersStorages.pokedexCompleted
local MIGRATED = playersStorages.pokepediaMigrated
local MASTER_BALL = 30136

local GUEST_LIST, SUBOWNER_LIST = 256, 257

local clients = {} -- cid -> true once the client said hello
local tracked = {} -- cid -> { [species] = true }
local discovered = {} -- guid -> { [itemid] = true }
local dex = {} -- guid -> { [species] = { kills, catches } }
local offers = {} -- house id -> { from, to, price, expires }
local requests = {} -- cid -> { second, count }

local function send(cid, data, list)
    local text = JSON.encode(data)
    while (#text > MESSAGE_LIMIT and list and #list > 0) do
        table.remove(list)
        data.more = true
        text = JSON.encode(data)
    end
    doSendPlayerLongExtendedOpcode(cid, EXTENDED_IDS.POKEPEDIA, text)
end

local function result(cid, ok, text, ...)
    send(cid, { type = "result", ok = ok, text = string.format(__L(cid, text), ...) })
    return ok
end

local function each(query, fn)
    local r = db.getResult(query)
    if (r:getID() == -1) then
        return
    end
    repeat
        fn(r)
    until not r:next()
    r:free()
end

local function formatMoney(amount)
    local text = tostring(amount)
    repeat
        local n
        text, n = text:gsub('^(%d+)(%d%d%d)', '%1,%2')
    until n == 0
    return "$" .. text
end

local function getFunds(cid)
    return getPlayerBalance(cid) + getPlayerMoney(cid)
end

-- the bank first, then the bag (as the GTS)
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

Pokepedia.isClient = function(cid)
    return clients[cid] == true
end

-- towns

local towns -- { { id, name, pos } }

local function getTowns()
    if (not towns) then
        towns = {}
        for id = 1, 200 do
            local name = getTownName(id)
            if (name and name ~= "") then
                towns[#towns + 1] = { id = id, name = name, pos = getTownTemplePosition(id) }
            end
        end
    end
    return towns
end

local function nearestTown(x, y)
    local best, bestDistance
    for _, town in ipairs(getTowns()) do
        local pos = town.pos
        if (pos and pos.x and pos.x > 0) then
            local distance = math.max(math.abs(pos.x - x), math.abs(pos.y - y))
            if (not bestDistance or distance < bestDistance) then
                best, bestDistance = town.name, distance
            end
        end
    end
    return best or ""
end

---------------------------------------------------------------------------------------------------
-- Houses
---------------------------------------------------------------------------------------------------

local houses -- id -> static info, built on first use (the houses load after the scripts)
local houseIds

local function getHouses()
    if (not houses) then
        houses, houseIds = {}, {}
        for _, id in pairs(getTownHouses()) do
            local info = getHouseInfo(id, false)
            if (info) then
                houses[id] = { id = id, name = info.name, town = info.town, townName = getTownName(info.town) or "",
                    size = info.size, beds = info.beds, doors = info.doors, price = info.price, rent = info.rent,
                    guild = info.guildHall, entry = info.entry }
                houseIds[#houseIds + 1] = id
            end
        end
        table.sort(houseIds, function(a, b)
            local ha, hb = houses[a], houses[b]
            if (ha.townName ~= hb.townName) then
                return ha.townName < hb.townName
            end
            return ha.name < hb.name
        end)
    end
    return houses, houseIds
end

local guildNames = {}

local function guildName(id)
    if (not guildNames[id]) then
        local name = ""
        each("SELECT `name` FROM `guilds` WHERE `id` = " .. id, function(r)
            name = r:getDataString("name")
        end)
        guildNames[id] = name
    end
    return guildNames[id]
end

local function ownerName(house, owner)
    if (owner == 0) then
        return ""
    end
    if (house.guild) then
        return guildName(owner)
    end
    return getPlayerNameByGUID(owner) or ""
end

-- the player's own house (or the guild's hall for the guild leader)
local function ownsHouse(cid, id)
    local info = getHouseInfo(id, false)
    if (not info or info.owner == 0) then
        return false
    end
    if (info.guildHall) then
        return info.owner == getPlayerGuildId(cid) and getPlayerGuildLevel(cid) == GUILDLEVEL_LEADER
    end
    return info.owner == getPlayerGUID(cid)
end

local function inList(text, name)
    name = name:lower()
    for line in (text or ""):gmatch("[^\n]+") do
        if (line:lower():gsub("^%s+", ""):gsub("%s+$", "") == name) then
            return true
        end
    end
    return false
end

local function accountHouses(accountId)
    local guids = {}
    for _, guid in ipairs(getAllPlayersByAccountId(accountId)) do
        guids[guid] = true
    end
    local count = 0
    local all = getHouses()
    for id, house in pairs(all) do
        if (not house.guild) then
            local info = getHouseInfo(id, false)
            if (info and guids[info.owner]) then
                count = count + 1
            end
        end
    end
    return count
end

-- the rules of /house buy (TalkAction::houseBuy), without standing at the door
local function canOwn(cid, house)
    if (not getBooleanFromString(getConfigValue('buyableAndSellableHouses'))) then
        return false, "Houses can't be bought right now."
    end
    if (house.guild) then
        if (getPlayerGuildId(cid) == 0 or getPlayerGuildLevel(cid) ~= GUILDLEVEL_LEADER) then
            return false, "Only a guild leader can buy a guild hall."
        end
        if (getHouseByGuildId(getPlayerGuildId(cid))) then
            return false, "Your guild already has a hall."
        end
        return true
    end
    if (getHouseByPlayerGUID(getPlayerGUID(cid))) then
        return false, "You already have a house."
    end
    local perAccount = tonumber(getConfigValue('housesPerAccount')) or 0
    if (perAccount > 0 and accountHouses(getPlayerAccountId(cid)) >= perAccount) then
        return false, perAccount == 1 and "Your account already has a house." or "Your account has all the houses it may have."
    end
    if (getBooleanFromString(getConfigValue('houseNeedPremium')) and not isPremium(cid)) then
        return false, "You need a premium account to own a house."
    end
    local level = tonumber(getConfigValue('levelToBuyHouse')) or 0
    if (getPlayerLevel(cid) < level) then
        return false, string.format(__L(cid, "You need to be level %d to own a house."), level)
    end
    return true
end

Pokepedia.sendHouses = function(cid)
    local all, ids = getHouses()
    local rows, mine = {}, getHouseByPlayerGUID(getPlayerGUID(cid)) or 0
    for _, id in ipairs(ids) do
        local house = all[id]
        local info = getHouseInfo(id, false)
        local owner = info and info.owner or 0
        local entry = house.entry or {}
        rows[#rows + 1] = { id, house.name, house.townName, house.size, house.beds, house.price,
            ownerName(house, owner), house.guild and 1 or 0, entry.x or 0, entry.y or 0 }
    end
    send(cid, { type = "houses", part = 1, parts = 1, mine = mine, list = JSON.array(rows) }, rows)
end

Pokepedia.sendHouse = function(cid, id)
    local house = getHouses()[id]
    local info = house and getHouseInfo(id, false)
    if (not info) then
        return result(cid, false, "That house doesn't exist.")
    end
    local entry = house.entry
    local tiles = {}
    for _, pos in ipairs(getHouseTiles(id) or {}) do
        tiles[#tiles + 1] = { pos.x - entry.x, pos.y - entry.y, pos.z }
    end
    local owner, name = info.owner, getCreatureName(cid)
    local mine = ownsHouse(cid, id)
    local guests = getHouseAccessList(id, GUEST_LIST) or ""
    local subowners = getHouseAccessList(id, SUBOWNER_LIST) or ""
    local subowner = owner ~= 0 and inList(subowners, name)
    local canBuy, reason = false, nil
    if (owner == 0) then
        canBuy, reason = canOwn(cid, house)
    end
    local offer = offers[id]
    if (offer and offer.expires < os.time()) then
        offers[id], offer = nil, nil
    end
    send(cid, { type = "house", id = id, name = house.name, town = house.townName, size = house.size,
        beds = house.beds, doors = house.doors, price = house.price, rent = info.rent, guild = house.guild,
        owner = ownerName(house, owner), paidUntil = info.paidUntil, entry = entry, mine = mine,
        canBuy = canBuy, reason = reason and __L(cid, reason) or "", funds = getFunds(cid),
        guests = (mine or subowner) and guests or "", subowners = mine and subowners or "",
        editGuests = mine or subowner, editSubowners = mine and not house.guild,
        transfer = (mine and offer) and { name = getPlayerNameByGUID(offer.to) or "", price = offer.price } or false,
        tiles = JSON.array(tiles) }, tiles)
end

Pokepedia.buyHouse = function(cid, id)
    local house = getHouses()[id]
    local info = house and getHouseInfo(id, false)
    if (not info) then
        return result(cid, false, "That house doesn't exist.")
    end
    if (info.owner ~= 0) then
        return result(cid, false, "Someone already owns this house.")
    end
    local ok, reason = canOwn(cid, house)
    if (not ok) then
        return result(cid, false, reason)
    end
    if (not takeFunds(cid, house.price)) then
        return result(cid, false, "You need %s in your bank or bag to buy this house.", formatMoney(house.price))
    end
    if (not setHouseOwner(id, getPlayerGUID(cid))) then
        payTo(getPlayerGUID(cid), house.price)
        return result(cid, false, "The house could not be bought. Your money was returned to your bank.")
    end
    doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.HOUSE)
    result(cid, true, "You bought %s for %s. The rent of %s a week is paid from your bank.", house.name,
        formatMoney(house.price), formatMoney(info.rent))
    Pokepedia.sendHouse(cid, id)
    return true
end

Pokepedia.leaveHouse = function(cid, id)
    local house = getHouses()[id]
    if (not house or not ownsHouse(cid, id)) then
        return result(cid, false, "You don't own this house.")
    end
    offers[id] = nil
    setHouseOwner(id, 0)
    result(cid, true, "You left %s. What was inside went to your depot.", house.name)
    Pokepedia.sendHouse(cid, id)
    return true
end

local function cleanList(text)
    local names = {}
    for line in (text or ""):gmatch("[^\n,;]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if (line ~= "" and #names < 100) then
            names[#names + 1] = line:sub(1, 40)
        end
    end
    return table.concat(names, "\n")
end

Pokepedia.setAccess = function(cid, id, list, text)
    local info = getHouses()[id] and getHouseInfo(id, false)
    if (not info or info.owner == 0) then
        return result(cid, false, "That house has no owner.")
    end
    local mine = ownsHouse(cid, id)
    if (list == "guests") then
        if (not mine and not inList(getHouseAccessList(id, SUBOWNER_LIST), getCreatureName(cid))) then
            return result(cid, false, "Only the owner and sub-owners can change the guests.")
        end
        setHouseAccessList(id, GUEST_LIST, cleanList(text))
    elseif (list == "subowners") then
        if (not mine or info.guildHall) then
            return result(cid, false, "Only the owner can change the sub-owners.")
        end
        setHouseAccessList(id, SUBOWNER_LIST, cleanList(text))
    else
        return false
    end
    result(cid, true, "The list was saved.")
    Pokepedia.sendHouse(cid, id)
    return true
end

Pokepedia.offerHouse = function(cid, id, name, price)
    local house = getHouses()[id]
    if (not house or not ownsHouse(cid, id)) then
        return result(cid, false, "You don't own this house.")
    end
    if (house.guild) then
        return result(cid, false, "Guild halls can't be transferred.")
    end
    price = math.floor(tonumber(price) or -1)
    if (price < 0 or price > Pokepedia.MAX_PRICE) then
        return result(cid, false, "Enter a price from 0 to %s.", formatMoney(Pokepedia.MAX_PRICE))
    end
    local buyer = getPlayerByName(name or "")
    if (not buyer or not isPlayer(buyer)) then
        return result(cid, false, "%s is not online.", name or "")
    end
    if (buyer == cid) then
        return result(cid, false, "You already own this house.")
    end
    local ok, reason = canOwn(buyer, house)
    if (not ok) then
        return result(cid, false, "%s can't take this house: %s", getCreatureName(buyer), __L(cid, reason))
    end
    if (not clients[buyer]) then
        return result(cid, false, "%s needs the new client to accept a house transfer.", getCreatureName(buyer))
    end
    offers[id] = { from = getPlayerGUID(cid), to = getPlayerGUID(buyer), price = price,
        expires = os.time() + Pokepedia.TRANSFER_TIME }
    send(buyer, { type = "transferOffer", id = id, name = house.name, town = house.townName, size = house.size,
        rent = house.rent, price = price, from = getCreatureName(cid) })
    result(cid, true, "%s was asked to take %s for %s.", getCreatureName(buyer), house.name, formatMoney(price))
    Pokepedia.sendHouse(cid, id)
    return true
end

Pokepedia.cancelOffer = function(cid, id)
    if (offers[id] and ownsHouse(cid, id)) then
        offers[id] = nil
        result(cid, true, "The transfer was cancelled.")
        Pokepedia.sendHouse(cid, id)
    end
end

Pokepedia.answerOffer = function(cid, id, accept)
    local offer, house = offers[id], getHouses()[id]
    if (not offer or not house or offer.to ~= getPlayerGUID(cid) or offer.expires < os.time()) then
        return result(cid, false, "That offer is no longer open.")
    end
    offers[id] = nil
    local seller = getPlayerByGUID(offer.from)
    if (not accept) then
        if (seller) then
            doPlayerSendTextMessage(seller, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(seller,
                "%s turned down %s."), getCreatureName(cid), house.name))
        end
        return result(cid, true, "You turned the offer down.")
    end
    local info = getHouseInfo(id, false)
    if (not info or info.owner ~= offer.from) then
        return result(cid, false, "The house changed hands in the meantime.")
    end
    local ok, reason = canOwn(cid, house)
    if (not ok) then
        return result(cid, false, reason)
    end
    if (not takeFunds(cid, offer.price)) then
        return result(cid, false, "You need %s in your bank or bag.", formatMoney(offer.price))
    end
    if (not setHouseOwner(id, getPlayerGUID(cid))) then
        payTo(getPlayerGUID(cid), offer.price)
        return result(cid, false, "The house could not be transferred. Your money was returned to your bank.")
    end
    payTo(offer.from, offer.price)
    doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.HOUSE)
    if (seller) then
        doPlayerSendTextMessage(seller, MESSAGE_EVENT_ADVANCE, string.format(__L(seller,
            "%s took %s. %s went to your bank and what was inside to your depot."), getCreatureName(cid),
            house.name, formatMoney(offer.price)))
    end
    result(cid, true, "%s is yours.", house.name)
    Pokepedia.sendHouse(cid, id)
    return true
end

---------------------------------------------------------------------------------------------------
-- Items
---------------------------------------------------------------------------------------------------

local catalog, categories -- itemid -> { category, clientId, name, shop }, { { name, items } }
local shopItems = {}
for _, id in ipairs(POKEPEDIA_SHOP_ITEMS) do
    shopItems[id] = true
end

local function getCatalog()
    if (catalog) then
        return catalog, categories
    end
    catalog, categories = {}, {}
    local function add(name, ids)
        local category = { name = name, items = {} }
        for _, id in ipairs(ids) do
            local info = getItemInfo(id)
            if (info and info.name ~= "" and not catalog[id]) then
                catalog[id] = { category = #categories + 1, clientId = info.clientId,
                    name = string.capitalise(info.name), shop = shopItems[id] == true }
                category.items[#category.items + 1] = id
            end
        end
        if (#category.items > 0) then
            categories[#categories + 1] = category
        end
    end
    -- the hand-made categories; its own lists below stand in for the generated ones
    for _, category in ipairs(ItemCategories.LIST) do
        if (category.name ~= "Other" and not category.generated) then
            add(category.name, category.items)
        end
    end
    add("Shop Items", POKEPEDIA_SHOP_ITEMS)
    add("Quest Rewards", POKEPEDIA_QUEST_ITEMS)
    local drops, seen = {}, {}
    for _, name in ipairs(pokemonNamesWithoutShiny) do
        local monster = getMonsterInfo(name)
        for _, loot in ipairs(monster and monster.loot or {}) do
            if (loot.id and not seen[loot.id]) then
                seen[loot.id] = true
                drops[#drops + 1] = loot.id
            end
        end
    end
    table.sort(drops)
    add("Drops", drops)
    for _, category in ipairs(categories) do
        table.sort(category.items, function(a, b)
            return catalog[a].name < catalog[b].name
        end)
    end
    return catalog, categories
end

local function known(guid, id)
    local entry = getCatalog()[id]
    return entry and (entry.shop or (discovered[guid] and discovered[guid][id])) or false
end

local function loadDiscoveries(guid)
    local list = {}
    each("SELECT `itemtype` FROM `player_item_discoveries` WHERE `player_id` = " .. guid, function(r)
        list[r:getDataInt("itemtype")] = true
    end)
    discovered[guid] = list
    return list
end

Pokepedia.discover = function(cid, id, quiet)
    local entry = getCatalog()[id]
    if (not entry or entry.shop or not isPlayer(cid)) then
        return false
    end
    local guid = getPlayerGUID(cid)
    local list = discovered[guid] or loadDiscoveries(guid)
    if (list[id]) then
        return false
    end
    list[id] = true
    db.executeQuery(string.format("INSERT IGNORE INTO `player_item_discoveries` (`player_id`, `itemtype`) VALUES (%d, %d)",
        guid, id))
    if (not quiet) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid,
            "New item in your Pokepedia: %s (%s)."), entry.name, __L(cid, categories[entry.category].name)))
        if (clients[cid]) then
            send(cid, { type = "discovered", id = id, client = entry.clientId, name = entry.name,
                category = entry.category })
        end
    end
    return true
end

Pokepedia.discoverThing = function(cid, item, quiet)
    if (not isItem(item)) then
        return
    end
    Pokepedia.discover(cid, item.itemid, quiet)
    if (isContainer(item.uid)) then
        for _, child in ipairs(getContainerItems(item.uid, true)) do
            Pokepedia.discover(cid, child.itemid, quiet)
        end
    end
end

-- what the trainer already has: the bag and the other slots, the depot, the PC stash and inbox
local function scanBelongings(cid)
    if (not isPlayer(cid)) then
        return
    end
    local guid = getPlayerGUID(cid)
    for slot = CONST_SLOT_FIRST, CONST_SLOT_LAST do
        Pokepedia.discoverThing(cid, getPlayerSlotItem(cid, slot), true)
    end
    local depot = getPlayerDepot(cid, 0)
    if (depot) then
        for _, item in ipairs(getContainerItems(depot, true)) do
            Pokepedia.discover(cid, item.itemid, true)
        end
    end
    for _, tbl in ipairs({ "pc_stash", "pc_inbox" }) do
        each(string.format("SELECT DISTINCT `itemtype` FROM `%s` WHERE `player_id` = %d", tbl, guid), function(r)
            Pokepedia.discover(cid, r:getDataInt("itemtype"), true)
        end)
    end
end

Pokepedia.sendItems = function(cid)
    local all, list = getCatalog()
    local guid = getPlayerGUID(cid)
    if (not discovered[guid]) then
        loadDiscoveries(guid)
    end
    local rows = {}
    for index, category in ipairs(list) do
        local count = 0
        for _, id in ipairs(category.items) do
            if (known(guid, id)) then
                count = count + 1
            end
        end
        rows[#rows + 1] = { name = category.name, known = count, total = #category.items }
    end
    send(cid, { type = "items", categories = JSON.array(rows) })
end

-- a category's items in parts; unknown ones are 0 so the client can draw them as "???"
Pokepedia.sendCategory = function(cid, index)
    local all, list = getCatalog()
    local category = list[index]
    if (not category) then
        return
    end
    local guid = getPlayerGUID(cid)
    local rows = {}
    for _, id in ipairs(category.items) do
        if (known(guid, id)) then
            rows[#rows + 1] = { id, all[id].clientId, all[id].name, all[id].shop and 1 or 0 }
        else
            rows[#rows + 1] = 0
        end
    end
    send(cid, { type = "category", index = index, name = category.name, part = 1, parts = 1,
        items = JSON.array(rows) }, rows)
end

---------------------------------------------------------------------------------------------------
-- Pokedex knowledge
---------------------------------------------------------------------------------------------------

-- rare spawns that aren't legendary: about half the defeats
local RARE = {}
for _, name in ipairs({ "Nidoqueen", "Nidoking", "Farfetchd", "Hitmonlee", "Hitmonchan", "Lickitung",
    "Kangaskhan", "Scyther", "Pinsir", "Tauros", "Lapras", "Ditto", "Eevee", "Vaporeon", "Jolteon", "Flareon",
    "Porygon", "Omanyte", "Omastar", "Kabuto", "Kabutops", "Aerodactyl", "Snorlax", "Chansey", "Dratini",
    "Dragonair", "Dragonite", "Pichu", "Togepi", "Togetic", "Espeon", "Umbreon", "Slowking", "Wobbuffet",
    "Steelix", "Scizor", "Delibird", "Porygon2", "Stantler", "Smeargle", "Tyrogue", "Hitmontop", "Elekid",
    "Magby", "Miltank", "Blissey", "Larvitar", "Pupitar", "Tyranitar", "Ninjask", "Shedinja", "Nosepass",
    "Sableye", "Mawile", "Wailmer", "Wailord", "Feebas", "Milotic", "Chimecho", "Absol", "Wynaut", "Bagon",
    "Shelgon", "Salamence", "Beldum", "Metang", "Metagross", "Lileep", "Cradily", "Anorith", "Armaldo",
    "Relicanth", "Cranidos", "Rampardos", "Shieldon", "Bastiodon", "Gible", "Gabite", "Garchomp", "Riolu", "Lucario", "Spiritomb", "Rotom", "Happiny", "Munchlax", "Mantyke", "Togekiss", "Leafeon", "Glaceon", "Porygon-Z", "Magnezone", "Electivire", "Magmortar", "Rhyperior" }) do
    RARE[name] = true
end

Pokepedia.THRESHOLDS = {
    normal = { 25, 100, 500 },
    rare = { 10, 50, 250 },
    legendary = { 1, 5, 15 },
}
Pokepedia.REWARD_MONEY = { normal = 2000, rare = 5000, legendary = 15000 }
Pokepedia.REWARD_EXPERIENCE = 500 -- times the species' experience

local BASE = {} -- base species names
for number = 1, POKEMON_NUMBER do
    local name = getPokemonNameByNumber(number)
    if (name) then
        BASE[name] = number
    end
end

-- the species the complete Pokedex counts: the ones that spawn in the wild
local WILD = {}
for name in pairs(BASE) do
    if (POKEPEDIA_SPAWNS[name]) then
        WILD[#WILD + 1] = name
    end
end
table.sort(WILD)
Pokepedia.WILD = WILD

local function speciesOf(name)
    if (not name) then
        return nil
    end
    local number = getPokemonNumberByName(name)
    return number and getPokemonNameByNumber(number) or nil
end

local function tierOf(species)
    if (DiscordBridge.isLegendary(species)) then
        return "legendary"
    end
    return RARE[species] and "rare" or "normal"
end

Pokepedia.tier = tierOf

local function loadDex(guid)
    local list = {}
    each("SELECT `species`, `kills`, `catches` FROM `player_dex_kills` WHERE `player_id` = " .. guid, function(r)
        list[r:getDataString("species")] = { r:getDataInt("kills"), r:getDataInt("catches") }
    end)
    dex[guid] = list
    return list
end

local function entryOf(guid, species)
    local list = dex[guid] or loadDex(guid)
    return list[species] or { 0, 0 }
end

-- level -1: never seen, 0: seen, 1-3: what the defeats and catches unlocked
Pokepedia.getKnowledge = function(cid, species)
    species = speciesOf(species)
    if (not species or not BASE[species]) then
        return nil
    end
    local entry = entryOf(getPlayerGUID(cid), species)
    local kills, catches = entry[1], entry[2]
    local tier = tierOf(species)
    local thresholds = Pokepedia.THRESHOLDS[tier]
    local points = kills + catches
    local level = -1
    if (catches > 0 or hasPlayerDexedPokemon(cid, species)) then
        level = 0
    end
    if (catches > 0) then
        level = 1
    end
    for i = 3, 1, -1 do
        if (points >= thresholds[i]) then
            level = math.max(level, i)
            break
        end
    end
    return { species = species, number = BASE[species], kills = kills, catches = catches, points = points,
        level = level, tier = tier, thresholds = thresholds, next = thresholds[math.max(1, level + 1)] }
end

Pokepedia.getDexLevel = function(cid, name)
    local knowledge = Pokepedia.getKnowledge(cid, name)
    return knowledge and knowledge.level or 3
end

local function progressRow(knowledge)
    return { name = knowledge.species, number = knowledge.number, level = knowledge.level,
        points = knowledge.points, next = knowledge.level < 3 and knowledge.next or false }
end

local function catchHint(species)
    local chance = getPokemonCatchChance(species) or 0
    if (chance <= 40) then
        return "Very easy"
    elseif (chance <= 150) then
        return "Easy"
    elseif (chance <= 500) then
        return "Medium"
    elseif (chance <= 1000) then
        return "Hard"
    elseif (chance <= 5000) then
        return "Very hard"
    end
    return "Legendary"
end

Pokepedia.sendDex = function(cid, name)
    if (not clients[cid]) then
        return
    end
    local knowledge = Pokepedia.getKnowledge(cid, name)
    if (not knowledge) then
        return result(cid, false, "There is no Pokemon called %s.", tostring(name))
    end
    local data = progressRow(knowledge)
    data.type = "dex"
    if (knowledge.level < 0) then
        data.name = ""
        data.kills, data.catches, data.tier, data.thresholds = knowledge.kills, knowledge.catches, knowledge.tier,
            knowledge.thresholds
        data.tracked = tracked[cid] and tracked[cid][knowledge.species] or false
        return send(cid, data)
    end
    data.kills, data.catches, data.tier = knowledge.kills, knowledge.catches, knowledge.tier
    data.thresholds = knowledge.thresholds
    data.tracked = tracked[cid] and tracked[cid][knowledge.species] or false
    data.dexed = hasPlayerDexedPokemon(cid, knowledge.species) and true or false
    local definition = getPokemonDefinition(knowledge.species)
    if (knowledge.level >= 1 and definition) then
        data.stats = { attack = definition.atk or 0, defense = definition.def or 0, spAttack = definition.spAtk or 0,
            spDefense = definition.spDef or 0 }
    end
    if (knowledge.level >= 2) then
        data.catchHint = __L(cid, catchHint(knowledge.species))
        local drops = {}
        local monster = getMonsterInfo(knowledge.species)
        for _, loot in ipairs(monster and monster.loot or {}) do
            local info = loot.id and getItemInfo(loot.id)
            if (info and #drops < 12) then
                drops[#drops + 1] = { client = info.clientId, name = string.capitalise(info.name),
                    chance = math.max(0.01, math.floor((loot.chance or 0) / 1000 + 0.5) / 100) }
            end
        end
        local stones = MegaEvolution.getDrops(knowledge.species) or {}
        for _, stone in ipairs(stones) do
            local info = getItemInfo(stone.itemId)
            local rate = stone.form:find("^Primal") and MegaEvolution.ORB_DROP_CHANCE or MegaEvolution.DROP_CHANCE
            if (info) then
                drops[#drops + 1] = { client = info.clientId, name = stone.name, chance = 100 / rate / #stones }
            end
        end
        data.drops = JSON.array(drops)
    end
    if (knowledge.level >= 3) then
        local spawns = {}
        for _, area in ipairs(POKEPEDIA_SPAWNS[knowledge.species] or {}) do
            spawns[#spawns + 1] = { x = area[1], y = area[2], z = area[3], points = area[4],
                town = nearestTown(area[1], area[2]) }
        end
        data.spawns = JSON.array(spawns)
    end
    send(cid, data)
end

-- every base species with what the trainer knows: [[number, name, level, points, next, wild]]
Pokepedia.sendDexList = function(cid)
    local rows = {}
    for number = 1, POKEMON_NUMBER do
        local name = getPokemonNameByNumber(number)
        local knowledge = name and BASE[name] and Pokepedia.getKnowledge(cid, name)
        if (knowledge) then
            rows[#rows + 1] = { number, knowledge.level >= 0 and name or "", knowledge.level, knowledge.points,
                knowledge.level < 3 and knowledge.next or 0, POKEPEDIA_SPAWNS[name] and 1 or 0 }
        end
    end
    local complete = 0
    for _, species in ipairs(WILD) do
        if (Pokepedia.getDexLevel(cid, species) >= 3) then
            complete = complete + 1
        end
    end
    send(cid, { type = "dexlist", part = 1, parts = 1, complete = complete, wild = #WILD,
        list = JSON.array(rows) }, rows)
end

local function sendProgress(cid, species)
    if (clients[cid] and tracked[cid] and tracked[cid][species]) then
        local knowledge = Pokepedia.getKnowledge(cid, species)
        if (knowledge) then
            local data = progressRow(knowledge)
            data.type = "progress"
            send(cid, data)
        end
    end
end

local function checkComplete(cid)
    if (getCreatureStorage(cid, COMPLETED) == 1) then
        return
    end
    for _, species in ipairs(WILD) do
        if (Pokepedia.getDexLevel(cid, species) < 3) then
            return
        end
    end
    doCreatureSetStorage(cid, COMPLETED, 1)
    doPlayerAddItem(cid, MASTER_BALL, 1, true)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, __L(cid,
        "Your Pokedex is complete! You know every wild Pokemon. Here is a Master Ball."))
    doBroadcastMessage(string.format("%s completed the Pokedex!", getCreatureName(cid)), MESSAGE_STATUS_CONSOLE_BLUE)
end

local LEVEL_TEXT = {
    [1] = "base stats, abilities and moves",
    [2] = "EV yield, drops and how hard it is to catch",
    [3] = "where it spawns",
}

local function addPoints(cid, species, kills, catches)
    local guid = getPlayerGUID(cid)
    local before = Pokepedia.getDexLevel(cid, species)
    local list = dex[guid] or loadDex(guid)
    local entry = list[species] or { 0, 0 }
    entry[1], entry[2] = entry[1] + kills, entry[2] + catches
    list[species] = entry
    db.executeQuery(string.format("INSERT INTO `player_dex_kills` (`player_id`, `species`, `kills`, `catches`) " ..
        "VALUES (%d, %s, %d, %d) ON DUPLICATE KEY UPDATE `kills` = `kills` + %d, `catches` = `catches` + %d",
        guid, db.escapeString(species), kills, catches, kills, catches))
    local after = Pokepedia.getDexLevel(cid, species)
    if (after > before and after >= 1) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid,
            "Pokedex: you know %s better (level %d of 3). Its entry now shows %s."), species, after,
            __L(cid, LEVEL_TEXT[after])))
        if (after == 3) then
            local tier = tierOf(species)
            local money = Pokepedia.REWARD_MONEY[tier]
            local monster = getMonsterInfo(species)
            local experience = (monster and monster.experience or 0) * Pokepedia.REWARD_EXPERIENCE
            doPlayerAddMoney(cid, money)
            if (experience > 0) then
                doPlayerAddExperience(cid, experience)
            end
            doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(__L(cid,
                "Pokedex: %s complete! You earned %s and %d experience."), species, formatMoney(money), experience))
            checkComplete(cid)
        end
    end
    sendProgress(cid, species)
end

Pokepedia.onDefeated = function(cid, target)
    if (not isPlayer(cid) or not isCreature(target) or not PokemonStats.isWildPokemon(target)) then
        return
    end
    -- wild legendaries count only for trainers with 10% of the damage (WildLegendaries.onDeath)
    if (WildLegendaries and WildLegendaries.isEncounter(target)) then
        return
    end
    local name = getCreatureName(target):gsub("^Shiny ", "")
    -- event forms ("Easter Bulbasaur") only count when caught
    if (BASE[name]) then
        addPoints(cid, name, 1, 0)
    end
end

Pokepedia.onLegendaryDefeated = function(cid, name)
    if (isPlayer(cid) and BASE[name]) then
        addPoints(cid, name, 1, 0)
    end
end

Pokepedia.onCaught = function(cid, name)
    local species = speciesOf(name)
    if (isPlayer(cid) and species and BASE[species]) then
        addPoints(cid, species, 0, 1)
    end
end

-- what the Pokedex entry of a wild Pokemon leaves out below each level (doPokedexItemView)
Pokepedia.describeLevel = function(cid, name)
    local knowledge = Pokepedia.getKnowledge(cid, name)
    if (not knowledge) then
        return ""
    end
    if (knowledge.level >= 3) then
        return string.format(__L(cid, "\n\nPokedex knowledge: complete (%d defeats and catches)."), knowledge.points)
    end
    return string.format(__L(cid, "\n\nPokedex knowledge: level %d of 3 (%d / %d defeats and catches to the next)."),
        math.max(0, knowledge.level), knowledge.points, knowledge.next)
end

Pokepedia.setTracked = function(cid, names)
    local list = {}
    local rows = {}
    for _, name in ipairs(type(names) == "table" and names or {}) do
        local knowledge = type(name) == "string" and Pokepedia.getKnowledge(cid, name)
        if (knowledge and #rows < 20) then
            list[knowledge.species] = true
            rows[#rows + 1] = progressRow(knowledge)
        end
    end
    tracked[cid] = list
    send(cid, { type = "tracked", list = JSON.array(rows) })
end

-- trainers who played before the knowledge levels start with what they caught
local function migrate(cid)
    if (getCreatureStorage(cid, MIGRATED) == 1) then
        return
    end
    local guid = getPlayerGUID(cid)
    for name in pairs(BASE) do
        local catches = getPlayerPokemonCaughts(cid, name)
        if (getPokemonDefinition("Shiny " .. name)) then
            catches = catches + getPlayerPokemonCaughts(cid, "Shiny " .. name)
        end
        if (catches > 0) then
            db.executeQuery(string.format("INSERT IGNORE INTO `player_dex_kills` (`player_id`, `species`, `kills`, " ..
                "`catches`) VALUES (%d, %s, 0, %d)", guid, db.escapeString(name), catches))
        end
    end
    doCreatureSetStorage(cid, MIGRATED, 1)
    dex[guid] = nil
end

---------------------------------------------------------------------------------------------------
-- Session
---------------------------------------------------------------------------------------------------

Pokepedia.onLogin = function(cid)
    clients[cid], tracked[cid] = nil, nil
    local guid = getPlayerGUID(cid)
    discovered[guid], dex[guid] = nil, nil
    local ok, err = pcall(migrate, cid)
    if (not ok) then
        log(LOG_TYPES.ERROR, "Pokepedia - migration failed: " .. tostring(err), getCreatureName(cid))
    end
    addEvent(function()
        local ok, err = pcall(scanBelongings, cid)
        if (not ok) then
            log(LOG_TYPES.ERROR, "Pokepedia - scan failed: " .. tostring(err))
        end
    end, 2000)
end

Pokepedia.onLogout = function(cid)
    local guid = getPlayerGUID(cid)
    clients[cid], tracked[cid], requests[cid] = nil, nil, nil
    discovered[guid], dex[guid] = nil, nil
end

-- the types of the species Nearby lists; a Pokemon's types are no secret once it's on screen
Pokepedia.sendTypes = function(cid, names)
    if (type(names) ~= "table") then
        return
    end
    local types = {}
    for i = 1, math.min(#names, 30) do
        local name = tostring(names[i])
        local species = speciesOf(name)
        if (species) then
            local list = {}
            for _, id in ipairs(getPokemonTypes(nil, species) or {}) do
                if (ELEMENT_NAMES[id]) then
                    list[#list + 1] = ELEMENT_NAMES[id]:lower()
                end
            end
            types[name] = JSON.array(list)
        end
    end
    send(cid, { type = "types", types = types })
end

Pokepedia.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or ""):lower()
    if (action == "hello") then
        clients[cid] = true
        return
    end
    clients[cid] = true
    local now = os.time()
    local rate = requests[cid]
    if (not rate or rate.second ~= now) then
        rate = { second = now, count = 0 }
        requests[cid] = rate
    end
    rate.count = rate.count + 1
    if (rate.count > Pokepedia.REQUESTS_PER_SECOND) then
        return
    end
    local id = tonumber(data.id)
    if (action == "houses") then
        Pokepedia.sendHouses(cid)
    elseif (action == "house" and id) then
        Pokepedia.sendHouse(cid, id)
    elseif (action == "buy" and id) then
        Pokepedia.buyHouse(cid, id)
    elseif (action == "leave" and id) then
        Pokepedia.leaveHouse(cid, id)
    elseif (action == "access" and id) then
        Pokepedia.setAccess(cid, id, data.list, tostring(data.text or ""))
    elseif (action == "transfer" and id) then
        Pokepedia.offerHouse(cid, id, tostring(data.name or ""), data.price)
    elseif (action == "canceltransfer" and id) then
        Pokepedia.cancelOffer(cid, id)
    elseif (action == "answer" and id) then
        Pokepedia.answerOffer(cid, id, data.accept == true)
    elseif (action == "items") then
        Pokepedia.sendItems(cid)
    elseif (action == "category" and id) then
        Pokepedia.sendCategory(cid, id)
    elseif (action == "dexlist") then
        Pokepedia.sendDexList(cid)
    elseif (action == "dex" and (data.name or data.number)) then
        Pokepedia.sendDex(cid, data.name and tostring(data.name) or getPokemonNameByNumber(tonumber(data.number) or 0))
    elseif (action == "track") then
        Pokepedia.setTracked(cid, data.list)
    elseif (action == "types") then
        Pokepedia.sendTypes(cid, data.names)
    elseif (action == "pokedex") then
        doPokedexStatusSend(cid)
        doPlayerSendPokedexOpen(cid)
    end
end
