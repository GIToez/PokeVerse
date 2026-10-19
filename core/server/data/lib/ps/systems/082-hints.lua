-- First-visit hints: a short card the first time a trainer walks into a Pokemon Center, a Mart, the Day Care
-- and other places. The client (game_hints) has the texts and notices most places by their area name; the
-- server remembers which hints each trainer has seen and shows the ones a place name can't tell, such as the
-- Day Care window opening.
--
-- The client talks JSON on EXTENDED_IDS.HINTS:
--   client -> server  {action = "hello"} (at login), {action = "seen", key}, {action = "reset"}
--   server -> client  {type = "seen", seen = {key, ...}}
--                     {type = "show", key}

Hints = {}

-- A hint's bit is its index here: only add keys at the end.
Hints.KEYS = { "center", "mart", "buyer", "daycare", "union", "gym", "safari", "bank" }

local STORAGE = playersStorages.hintsSeen
local CLIENT = playersStorages.hintsClient
local INDEX = {}
for i, key in ipairs(Hints.KEYS) do
    INDEX[key] = i
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.HINTS, JSON.encode(data))
end

Hints.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
end

Hints.enabled = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1
end

Hints.mask = function(cid)
    return math.max(0, tonumber(getPlayerStorageValue(cid, STORAGE)) or 0)
end

Hints.hasSeen = function(cid, key)
    local index = INDEX[key]
    return index ~= nil and math.floor(Hints.mask(cid) / 2 ^ (index - 1)) % 2 == 1
end

-- Returns true when the hint was new
Hints.markSeen = function(cid, key)
    local index = INDEX[key]
    if (not index or Hints.hasSeen(cid, key)) then
        return false
    end
    setPlayerStorageValue(cid, STORAGE, Hints.mask(cid) + 2 ^ (index - 1))
    return true
end

Hints.reset = function(cid)
    setPlayerStorageValue(cid, STORAGE, 0)
end

Hints.seenList = function(cid)
    local list = {}
    for _, key in ipairs(Hints.KEYS) do
        if (Hints.hasSeen(cid, key)) then
            list[#list + 1] = key
        end
    end
    return list
end

Hints.sendSeen = function(cid)
    send(cid, { type = "seen", seen = Hints.seenList(cid) })
end

-- Shows a hint the trainer hasn't seen yet; the client says "seen" once it is on screen.
Hints.show = function(cid, key)
    if (not INDEX[key] or not Hints.enabled(cid) or Hints.hasSeen(cid, key)) then
        return false
    end
    send(cid, { type = "show", key = key })
    return true
end

Hints.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
        Hints.sendSeen(cid)
    elseif (data.action == "seen") then
        Hints.markSeen(cid, tostring(data.key or ""))
    elseif (data.action == "reset") then
        Hints.reset(cid)
        Hints.sendSeen(cid)
    end
end
