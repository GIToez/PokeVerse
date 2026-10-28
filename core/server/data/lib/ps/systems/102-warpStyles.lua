-- Warp Styles (docs/upcoming-features.md, section 28): the animation a trainer plays when logging in, logging out,
-- teleporting, winning or losing a duel, and fainting. Everyone in view sees it; the client draws it (game_warpfx).
--
-- Each trigger has a slot the trainer fills in the Warp Styles window (Customise Trainer). Warp Spin, Victory,
-- Defeat and Faint are everyone's defaults, Beam comes with Premium, staff (access 3 and up) have every style,
-- and any other style is owned by the character in `player_warp_styles`.
--
-- WarpStyles.play(cid, trigger[, fromPos[, toPos]]) sends EXTENDED_IDS.WARP_STYLES to the players around:
--   {type = "play", c = creature, s = style, h = "out" | "in" | "fx", p = {x, y, z}, o = outfit, d = direction}
-- "out" is sent while the trainer is still there (the client copies the look), "in" once they stand on the new
-- tile, "fx" plays on a trainer who stays. Clients that never said hello get the old magic effect instead.
-- The engine calls WarpStyles.fromEngine for teleport tiles and logouts (Game::playWarpStyle).

WarpStyles = {}

WarpStyles.RANGE_X, WarpStyles.RANGE_Y = 9, 7
WarpStyles.STAFF_ACCESS = 3

-- kind: the list a style belongs to; the Log in, Log out and Teleport slots take "warp" styles.
-- store: sold in the Store's Warp Styles category (Store.OFFERS)
WarpStyles.STYLES = {
    { id = "spin", name = "Warp Spin", kind = "warp", everyone = true },
    { id = "beam", name = "Beam", kind = "warp", premium = true },
    { id = "pokeball", name = "Poke Ball", kind = "warp", store = true },
    { id = "victory", name = "Victory", kind = "victory", everyone = true },
    { id = "fireworks", name = "Fireworks", kind = "victory", store = true },
    { id = "trophy", name = "Trophy", kind = "victory", store = true },
    { id = "defeat", name = "Defeat", kind = "defeat", everyone = true },
    { id = "sweatdrop", name = "Sweat Drop", kind = "defeat", store = true },
    { id = "ghost", name = "Ghost", kind = "defeat", store = true },
    { id = "faint", name = "Faint", kind = "faint", everyone = true },
}

WarpStyles.TRIGGERS = {
    { id = "login", name = "Log in", kind = "warp", default = "spin" },
    { id = "logout", name = "Log out", kind = "warp", default = "spin" },
    { id = "teleport", name = "Teleport", kind = "warp", default = "spin" },
    { id = "victory", name = "Victory", kind = "victory", default = "victory" },
    { id = "defeat", name = "Defeat", kind = "defeat", default = "defeat" },
    { id = "faint", name = "Faint", kind = "faint", default = "faint" },
}

-- what clients without the module see
local FALLBACK = { login = CONST_ME_TELEPORT, teleport = CONST_ME_TELEPORT, logout = CONST_ME_POFF }

local byId, triggerById = {}, {}
for _, style in ipairs(WarpStyles.STYLES) do
    byId[style.id] = style
end
for _, trigger in ipairs(WarpStyles.TRIGGERS) do
    triggerById[trigger.id] = trigger
end

local function isStaff(cid)
    return getPlayerAccess(cid) >= WarpStyles.STAFF_ACCESS
end

local function boughtStyles(cid)
    local owned = {}
    local r = db.getResult(string.format("SELECT `style` FROM `player_warp_styles` WHERE `player_id` = %d", getPlayerGUID(cid)))
    if (r:getID() ~= -1) then
        repeat
            owned[r:getDataString("style")] = true
        until not r:next()
        r:free()
    end
    return owned
end

WarpStyles.owns = function(cid, styleId, bought)
    local style = byId[styleId]
    if (not style) then
        return false
    end
    if (style.everyone or isStaff(cid)) then
        return true
    end
    if (style.premium and isPremium(cid)) then
        return true
    end
    return (bought or boughtStyles(cid))[styleId] == true
end

-- Bought or given to the character (not counting Premium or staff access)
WarpStyles.bought = function(cid, styleId)
    return boughtStyles(cid)[styleId] == true
end

WarpStyles.give = function(cid, styleId)
    if (not byId[styleId]) then
        return false
    end
    return db.executeQuery(string.format("INSERT IGNORE INTO `player_warp_styles` (`player_id`, `style`, `obtained_at`) VALUES (%d, %s, %d)",
        getPlayerGUID(cid), db.escapeString(styleId), os.time()))
end

-- The equipped slots, "login=spin;logout=beam;...": only what differs from the defaults is kept
local function readSlots(cid)
    local slots = {}
    local saved = getCreatureStorage(cid, playersStorages.warpStyles)
    if (type(saved) == "string") then
        for trigger, style in saved:gmatch("(%a+)=(%a+)") do
            if (triggerById[trigger] and byId[style]) then
                slots[trigger] = style
            end
        end
    end
    return slots
end

local function writeSlots(cid, slots)
    local parts = {}
    for _, trigger in ipairs(WarpStyles.TRIGGERS) do
        local style = slots[trigger.id]
        if (style and style ~= trigger.default) then
            parts[#parts + 1] = trigger.id .. "=" .. style
        end
    end
    doCreatureSetStorage(cid, playersStorages.warpStyles, #parts > 0 and table.concat(parts, ";") or -1)
end

-- The style a trigger plays: the equipped one while the trainer still has it (Premium can run out)
WarpStyles.equipped = function(cid, triggerId)
    local trigger = triggerById[triggerId]
    if (not trigger) then
        return nil
    end
    local style = readSlots(cid)[triggerId]
    if (style and byId[style].kind == trigger.kind and WarpStyles.owns(cid, style)) then
        return style
    end
    return trigger.default
end

WarpStyles.equip = function(cid, triggerId, styleId)
    local trigger, style = triggerById[triggerId], byId[styleId]
    if (not trigger or not style or style.kind ~= trigger.kind or not WarpStyles.owns(cid, styleId)) then
        return false
    end
    local slots = readSlots(cid)
    slots[triggerId] = styleId
    writeSlots(cid, slots)
    return true
end

local function hasClient(cid)
    return getCreatureStorage(cid, playersStorages.warpStylesClient) == 1
end

local function outfitOf(cid)
    local o = getCreatureOutfit(cid)
    return { type = o.lookType, head = o.lookHead, body = o.lookBody, legs = o.lookLegs, feet = o.lookFeet, addons = o.lookAddons }
end

-- Sends one half to the players who can see pos; skip: a player who must not get it (the trainer leaving by teleport)
local function send(cid, triggerId, style, half, pos, skip)
    local payload = JSON.encode({ type = "play", c = cid, s = style, h = half, t = triggerId,
        p = { x = pos.x, y = pos.y, z = pos.z }, o = outfitOf(cid), d = getCreatureLookDirection(cid) })
    local fallback = (half ~= "fx") and FALLBACK[triggerId] or nil
    for _, spectator in ipairs(getSpectators(pos, WarpStyles.RANGE_X, WarpStyles.RANGE_Y, false) or {}) do
        if (isPlayer(spectator) and spectator ~= skip) then
            if (hasClient(spectator)) then
                doSendPlayerExtendedOpcode(spectator, EXTENDED_IDS.WARP_STYLES, payload)
            elseif (fallback) then
                doSendMagicEffect(pos, fallback, spectator)
            end
        end
    end
end

-- Plays a trigger on a trainer. Ghosts (hidden staff) play nothing.
WarpStyles.play = function(cid, triggerId, fromPos, toPos)
    if (not isPlayer(cid) or isPlayerGhost(cid, true) or not triggerById[triggerId]) then
        return false
    end
    local style = WarpStyles.equipped(cid, triggerId)
    local here = getCreaturePosition(cid)
    if (triggerId == "login") then
        send(cid, triggerId, style, "in", here)
    elseif (triggerId == "logout" or triggerId == "faint") then
        send(cid, triggerId, style, "out", here)
    elseif (triggerId == "teleport") then
        -- the trainer's own client only shows the arrival, unless both halves play on one spot (/warpstyle)
        local from = fromPos or here
        local skip = not (toPos and getSamePosition(from, toPos)) and cid or nil
        send(cid, triggerId, style, "out", from, skip)
        if (toPos) then
            send(cid, triggerId, style, "in", toPos)
        end
    else
        send(cid, triggerId, style, "fx", here)
    end
    return true
end

-- Teleports a trainer with their Teleport style (travel NPCs, boats, NPC battle arenas)
WarpStyles.teleport = function(cid, destination, pushMove)
    local from = getCreaturePosition(cid)
    if (not isPlayer(cid) or isPlayerGhost(cid, true)) then
        doTeleportThing(cid, destination, pushMove)
        return
    end
    send(cid, "teleport", WarpStyles.equipped(cid, "teleport"), "out", from, cid)
    doTeleportThing(cid, destination, pushMove)
    send(cid, "teleport", WarpStyles.equipped(cid, "teleport"), "in", getCreaturePosition(cid))
end

-- From the engine: "out" before a teleport tile moves the trainer, "in" after it, "logout" before they leave.
-- Returning false makes the engine play its old magic effect.
WarpStyles.fromEngine = function(cid, half, pos)
    if (not isPlayer(cid) or isPlayerGhost(cid, true)) then
        return true
    end
    if (half == "logout") then
        send(cid, "logout", WarpStyles.equipped(cid, "logout"), "out", pos)
    elseif (half == "out") then
        send(cid, "teleport", WarpStyles.equipped(cid, "teleport"), "out", pos, cid)
    elseif (half == "in") then
        send(cid, "teleport", WarpStyles.equipped(cid, "teleport"), "in", pos)
    else
        return false
    end
    return true
end

-- Duel and battle wins and losses (onAdvance: the duel and battle skills go up by one at each)
WarpStyles.onDuelSkill = function(cid, skill)
    if (skill == PLAYER_SKILL_DUEL_WIN or skill == PLAYER_SKILL_BATTLE_WIN) then
        WarpStyles.play(cid, "victory")
    elseif (skill == PLAYER_SKILL_DUEL_LOSS or skill == PLAYER_SKILL_BATTLE_LOSS) then
        WarpStyles.play(cid, "defeat")
    end
end

WarpStyles.sendState = function(cid, open)
    local bought = boughtStyles(cid)
    local styles, triggers = {}, {}
    for _, style in ipairs(WarpStyles.STYLES) do
        local owned = WarpStyles.owns(cid, style.id, bought)
        local how = style.everyone and "Everyone has it" or (style.premium and "Premium")
            or (style.store and (bought[style.id] and "Bought in the Store" or "In the Store")) or "Not owned yet"
        styles[#styles + 1] = { id = style.id, name = style.name, kind = style.kind, owned = owned,
            how = (owned and not style.everyone and isStaff(cid) and not bought[style.id]) and "Staff" or how }
    end
    for _, trigger in ipairs(WarpStyles.TRIGGERS) do
        triggers[#triggers + 1] = { id = trigger.id, name = trigger.name, kind = trigger.kind, default = trigger.default,
            style = WarpStyles.equipped(cid, trigger.id) }
    end
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.WARP_STYLES, JSON.encode({ type = "state", open = open or nil,
        styles = styles, triggers = triggers }))
end

-- From the client: {action = "hello", fx} at login and when the option changes, {action = "open"}, {action = "equip", trigger, style}
WarpStyles.onClientMessage = function(cid, buffer)
    local ok, message = pcall(JSON.decode, buffer)
    if (not ok or type(message) ~= "table") then
        return
    end
    if (message.action == "hello") then
        -- fx = false: the trainer turned Warp Styles off (Options) and gets the plain effects
        doCreatureSetStorage(cid, playersStorages.warpStylesClient, message.fx == false and 0 or 1)
        WarpStyles.sendState(cid)
    elseif (message.action == "open") then
        WarpStyles.sendState(cid, true)
    elseif (message.action == "equip") then
        if (not WarpStyles.equip(cid, tostring(message.trigger), tostring(message.style))) then
            doPlayerSendCancel(cid, __L(cid, "You can't use that style there."))
        end
        WarpStyles.sendState(cid)
    end
end
