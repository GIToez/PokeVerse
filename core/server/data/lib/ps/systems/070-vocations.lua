-- Vocations (docs/upcoming-features.md, section 6): from trainer level 20 a trainer picks one of
-- six vocations, once and for good. The client's vocation window (game_vocation) talks JSON on
-- EXTENDED_IDS.VOCATION:
--   server -> client  {type = "open", level, minLevel, chosen, vocations = {{key, name, tagline, perks}, ...}}
--                     {type = "chosen", key, name}
--                     {type = "result", ok, text}
--   client -> server  {action = "choose", key}
-- A choice is only accepted while the window that was opened by Vocations.open is up, so the
-- vocation quest line decides when a trainer may choose. The perks themselves are not in yet.

Vocations = {}

Vocations.MIN_LEVEL = 20

-- id is what the storage keeps, so ids never change or get reused
Vocations.LIST = {
    { id = 1, key = "ace", name = "Ace Trainer", tagline = "Battles and experience",
      perks = { "Battle EXP +2% to +10%", "Titles up to Ace Trainer", "Bonus grows with each rank" } },
    { id = 2, key = "catcher", name = "Catcher", tagline = "Catching",
      perks = { "Catch chance +2% to +10%", "Ball back after a failed throw", "Bonus grows with each rank" } },
    { id = 3, key = "breeder", name = "Breeder", tagline = "Eggs and the daycare",
      perks = { "Hatching up to 25% faster", "Chance of a second egg", "Better early egg chance" } },
    { id = 4, key = "ranger", name = "Ranger", tagline = "Tracking wild Pokemon",
      perks = { "Radar for nearby spawns", "Filter by type, see direction", "Rare finds at top ranks" } },
    { id = 5, key = "angler", name = "Angler", tagline = "Fishing",
      perks = { "Faster fishing skill", "See what bites at a spot", "Fishing map at rank 4" } },
    { id = 6, key = "medic", name = "Medic", tagline = "Healing and support",
      perks = { "Healing items +3% to +15%", "Heal other players' team", "Bonus grows with each rank" } },
}

local STORAGE = playersStorages.vocation
-- a storage, not a table: talkactions, NPCs and creature scripts each have their own Lua state
local WINDOW = playersStorages.vocationWindow

local byKey, byId = {}, {}
for _, vocation in ipairs(Vocations.LIST) do
    byKey[vocation.key] = vocation
    byId[vocation.id] = vocation
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.VOCATION, JSON.encode(data))
end

local function result(cid, ok, text)
    send(cid, { type = "result", ok = ok, text = __L(cid, text) })
    return ok
end

Vocations.get = function(cid)
    return byId[getPlayerStorageValue(cid, STORAGE)]
end

Vocations.open = function(cid)
    if (not isPlayer(cid)) then
        return false
    end
    if (not getPlayerUsingOtClient(cid)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
            __L(cid, "Choosing a vocation needs the PokeVerse client."))
        return false
    end
    local list = {}
    for _, vocation in ipairs(Vocations.LIST) do
        local perks = {}
        for _, perk in ipairs(vocation.perks) do
            perks[#perks + 1] = __L(cid, perk)
        end
        list[#list + 1] = { key = vocation.key, name = __L(cid, vocation.name), tagline = __L(cid, vocation.tagline),
                            perks = perks }
    end
    local chosen = Vocations.get(cid)
    setPlayerStorageValue(cid, WINDOW, chosen and -1 or 1)
    send(cid, { type = "open", level = getPlayerLevel(cid), minLevel = Vocations.MIN_LEVEL,
                chosen = chosen and chosen.key or nil, vocations = list })
    return true
end

Vocations.choose = function(cid, key)
    local vocation = byKey[tostring(key or "")]
    if (not vocation) then
        return false
    end
    if (Vocations.get(cid)) then
        return result(cid, false, "You already have a vocation.")
    end
    if (getPlayerStorageValue(cid, WINDOW) ~= 1) then
        return result(cid, false, "Talk to the vocation guide to choose a vocation.")
    end
    if (getPlayerLevel(cid) < Vocations.MIN_LEVEL) then
        return result(cid, false, string.format(__L(cid, "You need trainer level %d to choose a vocation."),
            Vocations.MIN_LEVEL))
    end
    setPlayerStorageValue(cid, WINDOW, -1)
    setPlayerStorageValue(cid, STORAGE, vocation.id)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_YELLOW)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
        string.format(__L(cid, "You are now a %s!"), __L(cid, vocation.name)))
    send(cid, { type = "chosen", key = vocation.key, name = __L(cid, vocation.name) })
    return true
end

Vocations.reset = function(cid)
    setPlayerStorageValue(cid, STORAGE, -1)
    setPlayerStorageValue(cid, WINDOW, -1)
end

Vocations.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or "")
    if (action == "choose") then
        Vocations.choose(cid, data.key)
    elseif (action == "close") then
        setPlayerStorageValue(cid, WINDOW, -1)
    end
end

Vocations.onLogout = function(cid)
    setPlayerStorageValue(cid, WINDOW, -1)
end
