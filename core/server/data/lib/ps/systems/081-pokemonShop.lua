-- Pokemon shop window: Ron and Joel Morris buy Pokemon from the party and straight from the PC boxes. Greeting
-- one opens the window for modern clients (npc/scripts/shop_pokemonShop.lua); old clients keep the NPCs'
-- conversation, which uses the same price and rules.
--
-- The window talks JSON on EXTENDED_IDS.POKEMON_SHOP:
--   client -> server  {action = "hello"} (at login), {action = "box", box}, {action = "sell", keys, confirm}
--   server -> client  {type = "shop", npc, town, greeting, money, party, boxes, box, list, rules}
--                     {type = "box", box, boxes, list}
--                     {type = "result", ok, text, total, rare}
--                     {type = "close"}
-- A party Pokemon's key is "p|<index>|<name>|<level>" (uids only last one script run), a PC Pokemon's "b|<row id>".
-- Every action needs a shop NPC near the trainer; the NPC scripts and the extended opcodes run in different Lua
-- states, so nothing is kept between them but the trainer's position.

PokemonShop = {}

PokemonShop.PRICE_PER_LEVEL = 5
PokemonShop.RARE_PERFECT_IVS = 5 -- this many perfect IVs (or a shiny) make a sale ask for SELL typed
PokemonShop.NPC_RANGE = 5
PokemonShop.MAX_PER_SALE = 30
PokemonShop.NPCS = {
    ["Ron"] = { greeting = "Always a good price here, you can trust me." },
    ["Joel Morris"] = { greeting = "We buy all kinds of Pokemon. If you can't take care of them, we can help.",
                        allowed = function(cid) return getPlayerOrangeArchipelagoAccess(cid) >= 4 end },
}

local CLIENT = playersStorages.pokemonShopClient
local MESSAGE_LIMIT = 14000

local function send(cid, data, list)
    local text = JSON.encode(data)
    while (#text > MESSAGE_LIMIT and list and #list > 0) do
        table.remove(list)
        data.more = true
        text = JSON.encode(data)
    end
    doSendPlayerLongExtendedOpcode(cid, EXTENDED_IDS.POKEMON_SHOP, text)
end

local function result(cid, ok, text, ...)
    send(cid, { type = "result", ok = ok, text = string.format(__L(cid, text), ...) })
    return ok
end

-- Price and rules ------------------------------------------------------------------------------------------

-- The species' price (0 for a name the server doesn't know)
PokemonShop.basePrice = function(name)
    local ok, price = pcall(getPokemonPrice, name)
    return ok and tonumber(price) or 0
end

PokemonShop.priceOf = function(name, level)
    return PokemonShop.basePrice(name) + (tonumber(level) or 0) * PokemonShop.PRICE_PER_LEVEL
end

-- Why this ball's Pokemon can't be sold, or nil. party: it is one the trainer carries.
PokemonShop.blockReason = function(cid, uid, party)
    if (getItemUniqueOwner(uid) ~= ITEM_UNIQUE_OWNER_NONE) then
        return "Bound to you"
    elseif (getBallTm(uid, 1) ~= TM_IDS.NONE or getBallTm(uid, 2) ~= TM_IDS.NONE) then
        return "Knows a TM"
    elseif (party and uid == getPlayerSlotItem(cid, PLAYER_SLOT_BALL).uid
            and (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid))) then
        return "Out of its ball"
    end
    return nil
end

local function perfectIvs(uid)
    return GTS.summary(uid).perfect or 0
end

PokemonShop.isRare = function(name, uid)
    return isShinyName(name) ~= nil or perfectIvs(uid) >= PokemonShop.RARE_PERFECT_IVS
end

-- Listing --------------------------------------------------------------------------------------------------

local function partyKey(index, uid)
    return string.format("p|%d|%s|%d", index, getBallPokemonName(uid), getBallPokemonLevel(uid))
end

local function boxKey(id)
    return "b|" .. id
end

local function entry(cid, key, uid, name, level, party)
    local summary = GTS.summary(uid)
    local nickname = getBallPokemonNickname(uid)
    local held = getBallHeld(uid)
    local block = PokemonShop.blockReason(cid, uid, party)
    return { key = key, name = name, level = level, number = getPokemonNumberByName(name), face = GTS.faceOf(name),
             nickname = (nickname and nickname ~= "" and nickname ~= name) and nickname or nil,
             shiny = isShinyName(name) ~= nil or nil, base = PokemonShop.basePrice(name),
             price = PokemonShop.priceOf(name, level), perfect = summary.perfect, ivs = summary.ivs,
             nature = summary.nature, held = held and PokemonHeldItem.getHeldName(held, uid) or nil,
             rare = PokemonShop.isRare(name, uid) or nil, blocked = block and __L(cid, block) or nil }
end

local function partyList(cid)
    local list = JSON.array()
    local balls = getPlayerAllBallsWithPokemon(cid)
    for index, ball in ipairs(balls) do
        local name, level = getBallPokemonName(ball.uid), getBallPokemonLevel(ball.uid)
        local row = entry(cid, partyKey(index, ball.uid), ball.uid, name, level, true)
        if (not row.blocked and #balls == 1) then
            row.blocked = __L(cid, "Your last Pokemon")
        end
        list[#list + 1] = row
    end
    return list
end

local function getBoxRow(guid, id)
    local r = db.getResult(string.format("SELECT `id`, `box`, `ball_id`, `pokemon_name`, `pokemon_level`, `attributes`,"
        .. " LENGTH(`attributes`) AS `attrlen` FROM `pc_boxes` WHERE `id` = %d AND `player_id` = %d", id, guid))
    if (r:getID() == -1) then
        return nil
    end
    return r
end

-- A ball rebuilt from a box row, to read it (it is never put anywhere, so it goes when the script ends)
local function loadBall(r)
    local uid = doCreateItemEx(r:getDataInt("ball_id"))
    if (not uid) then
        return nil
    end
    if (r:getDataInt("attrlen") > 0) then
        doItemLoadAttributes(uid, "attributes", r:getID())
    end
    return isBallWithPokemon(uid) and uid or nil
end

-- The boxes that hold Pokemon, each { box, name, count }
local function boxList(cid)
    local guid = getPlayerGUID(cid)
    local counts, names = PC.boxCounts(guid), PC.boxNames(guid)
    local boxes = JSON.array()
    for box = 1, PC.BOXES do
        if ((counts[box] or 0) > 0) then
            boxes[#boxes + 1] = { box = box, name = names[box] or string.format(__L(cid, "Box %d"), box), count = counts[box] }
        end
    end
    return boxes
end

local function boxPokemon(cid, box)
    local list = JSON.array()
    local r = db.getResult(string.format("SELECT `id`, `ball_id`, `pokemon_name`, `pokemon_level`, `attributes`,"
        .. " LENGTH(`attributes`) AS `attrlen` FROM `pc_boxes` WHERE `player_id` = %d AND `box` = %d ORDER BY `slot`",
        getPlayerGUID(cid), box))
    if (r:getID() == -1) then
        return list
    end
    repeat
        local uid = loadBall(r)
        if (uid) then
            local row = entry(cid, boxKey(r:getDataInt("id")), uid, r:getDataString("pokemon_name"),
                r:getDataInt("pokemon_level"), false)
            row.box = box
            list[#list + 1] = row
        end
    until not r:next()
    r:free()
    return list
end

-- The box asked for, or the first one with Pokemon (0 when there is none)
local function pickBox(boxes, box)
    for _, shown in ipairs(boxes) do
        if (shown.box == box) then
            return box
        end
    end
    return boxes[1] and boxes[1].box or 0
end

-- Session --------------------------------------------------------------------------------------------------

PokemonShop.enabled = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1
end

PokemonShop.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
end

-- The shop NPC near the trainer that trades with them: its name, or nil and why not
PokemonShop.nearNpc = function(cid)
    local denied
    for _, creature in ipairs(getSpectators(getCreaturePosition(cid), PokemonShop.NPC_RANGE, PokemonShop.NPC_RANGE, false) or {}) do
        local name = isNpc(creature) and getCreatureName(creature)
        local npc = name and PokemonShop.NPCS[name]
        if (npc) then
            if (not npc.allowed or npc.allowed(cid)) then
                return name
            end
            denied = "You do not have enough access to trade here!"
        end
    end
    return nil, denied or "Talk to Ron or Joel Morris to sell Pokemon."
end

local function rules()
    return { perLevel = PokemonShop.PRICE_PER_LEVEL, rareIvs = PokemonShop.RARE_PERFECT_IVS, max = PokemonShop.MAX_PER_SALE,
             range = PokemonShop.NPC_RANGE }
end

PokemonShop.sendState = function(cid, npcName, box)
    local boxes = boxList(cid)
    box = pickBox(boxes, tonumber(box))
    local npc = PokemonShop.NPCS[npcName] or {}
    local zone = Weather and Weather.zoneAt and Weather.zoneAt(getCreaturePosition(cid))
    local list = box > 0 and boxPokemon(cid, box) or JSON.array()
    send(cid, { type = "shop", npc = npcName, town = zone and zone.name or nil,
                greeting = npc.greeting and __L(cid, npc.greeting) or nil, money = getPlayerMoney(cid),
                party = partyList(cid), boxes = boxes, box = box, list = list, rules = rules() }, list)
end

PokemonShop.sendBox = function(cid, box)
    local boxes = boxList(cid)
    box = pickBox(boxes, tonumber(box))
    local list = box > 0 and boxPokemon(cid, box) or JSON.array()
    send(cid, { type = "box", box = box, boxes = boxes, list = list }, list)
end

-- Opens the window (true), or false for clients without it
PokemonShop.open = function(cid, npcName)
    if (not PokemonShop.enabled(cid)) then
        return false
    end
    PokemonShop.sendState(cid, npcName, nil)
    return true
end

PokemonShop.close = function(cid)
    if (PokemonShop.enabled(cid)) then
        send(cid, { type = "close" })
    end
end

-- Selling --------------------------------------------------------------------------------------------------

-- What a key stands for now: { key, name, level, uid, party, ball or row id }, or nil
local function resolve(cid, key, balls)
    local index, name, level = tostring(key):match("^p|(%d+)|(.+)|(%d+)$")
    if (index) then
        local ball = balls[tonumber(index)]
        if (ball and getBallPokemonName(ball.uid) == name and getBallPokemonLevel(ball.uid) == tonumber(level)) then
            return { key = key, name = name, level = tonumber(level), uid = ball.uid, party = true }
        end
        return nil
    end
    local id = tonumber(tostring(key):match("^b|(%d+)$"))
    local r = id and getBoxRow(getPlayerGUID(cid), id)
    if (not r) then
        return nil
    end
    local uid = loadBall(r)
    local found = uid and { key = key, name = r:getDataString("pokemon_name"), level = r:getDataInt("pokemon_level"),
                            uid = uid, id = id, box = r:getDataInt("box") }
    r:free()
    return found
end

local function nameList(cid, names)
    if (#names == 1) then
        return names[1]
    end
    return table.concat(names, ", ", 1, #names - 1) .. " " .. __L(cid, "and") .. " " .. names[#names]
end

PokemonShop.sell = function(cid, keys, confirm, box)
    local npcName, why = PokemonShop.nearNpc(cid)
    if (not npcName) then
        return result(cid, false, why)
    elseif (type(keys) ~= "table" or #keys == 0) then
        return result(cid, false, "Pick the Pokemon you want to sell.")
    elseif (isEvolving(cid)) then
        return result(cid, false, "Wait until your Pokemon has evolved.")
    elseif (#keys > PokemonShop.MAX_PER_SALE) then
        return result(cid, false, "You can sell up to %d Pokemon at a time.", PokemonShop.MAX_PER_SALE)
    end

    local balls = getPlayerAllBallsWithPokemon(cid)
    local picked, seen, partySold, rare = {}, {}, 0, {}
    for _, key in ipairs(keys) do
        key = tostring(key)
        if (not seen[key]) then
            seen[key] = true
            local pokemon = resolve(cid, key, balls)
            if (not pokemon) then
                PokemonShop.sendState(cid, npcName, box)
                return result(cid, false, "Some of these Pokemon aren't yours to sell anymore. The list is up to date now.")
            end
            local block = PokemonShop.blockReason(cid, pokemon.uid, pokemon.party)
            if (block) then
                return result(cid, false, "%s can't be sold: %s.", pokemon.name, __L(cid, block):lower())
            end
            if (PokemonShop.isRare(pokemon.name, pokemon.uid)) then
                rare[#rare + 1] = pokemon.name
            end
            partySold = partySold + (pokemon.party and 1 or 0)
            picked[#picked + 1] = pokemon
        end
    end
    if (partySold > 0 and partySold >= #balls) then
        return result(cid, false, "Keep at least one Pokemon with you.")
    elseif (#rare > 0 and tostring(confirm or "") ~= "SELL") then
        send(cid, { type = "result", ok = false, rare = rare,
                    text = string.format(__L(cid, "%s can't be bought back. Type SELL to confirm."), nameList(cid, rare)) })
        return false
    end

    local total, names = 0, {}
    for _, pokemon in ipairs(picked) do
        if (pokemon.id) then
            db.executeQuery(string.format("DELETE FROM `pc_boxes` WHERE `id` = %d AND `player_id` = %d", pokemon.id,
                getPlayerGUID(cid)))
        end
        if (getBallHeld(pokemon.uid)) then
            PokemonHeldItem.take(cid, pokemon.uid)
        end
        if (pokemon.party) then
            doRemoveItem(pokemon.uid)
        end
        total = total + PokemonShop.priceOf(pokemon.name, pokemon.level)
        names[#names + 1] = string.format("%s (%d)", pokemon.name, pokemon.level)
        doPlayerAddStatistic(cid, PLAYER_STATISTIC_IDS.SELL_POKEMON, 1)
    end
    if (total > 0) then
        doPlayerAddMoney(cid, total)
    end
    doPlayerSave(cid) -- no clone balls
    print(string.format("> Pokemon shop: %s sold %s to %s for %d dollars", getCreatureName(cid), table.concat(names, ", "),
        npcName, total))

    PokemonShop.sendState(cid, npcName, box)
    send(cid, { type = "result", ok = true, total = total,
                text = string.format(__L(cid, #picked == 1 and "You sold %s for %d dollars." or "You sold %d Pokemon for %d dollars."),
                    #picked == 1 and picked[1].name or #picked, total) })
    return true
end

PokemonShop.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or "")
    if (action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
        return
    end
    local npcName, why = PokemonShop.nearNpc(cid)
    if (not npcName) then
        send(cid, { type = "close" })
        result(cid, false, why)
        return
    end
    if (action == "box") then
        PokemonShop.sendBox(cid, data.box)
    elseif (action == "refresh") then
        PokemonShop.sendState(cid, npcName, data.box)
    elseif (action == "sell") then
        PokemonShop.sell(cid, data.keys, data.confirm, data.box)
    end
end
