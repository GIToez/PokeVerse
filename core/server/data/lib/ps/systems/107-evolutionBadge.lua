-- Ready to evolve: a badge on the Poke bar socket of every Pokemon that can evolve (client game_pokebar),
-- and a chat line the moment one becomes ready. It is the evolve button's own check
-- (events/actions/evolve.lua), done for every ball the trainer carries:
--   "ready"  the level is reached and every required item is carried (at the right time of day)
--   "almost" the level is reached, but an item is missing or it is the wrong time of day (a faded badge)
-- JSON on EXTENDED_IDS.HELD_ITEM, the swap bar's channel:
--   { type = "evolve", items = { { number = <swap bar number>, state = "ready"|"almost", to = name, need = text } } }
-- It is sent at login, right after a level up, when a ball joins the bar, and when a 5 second check finds a
-- change (an evolution item picked up or used, day turning to night). Only changes are sent.

EvolutionBadge = {}

local CHECK = 5000
local sent = {}  -- cid -> the last JSON sent (each Lua state keeps its own; a repeat is harmless)
local loops = {} -- cid -> token of the running check
local loginAt = {} -- cid -> os.time() of the login: the bar is filled then, which is no news

local function timeText(cid, requiredTime)
    if (requiredTime == WORLD_LIGHT_STATE_NIGHT) then
        return __L(cid, "at night")
    elseif (requiredTime == WORLD_LIGHT_STATE_DAY) then
        return __L(cid, "during the day")
    end
    return nil
end

local function byItem(evolution)
    return evolution.requiredItems ~= nil and #evolution.requiredItems > 0
end

-- state, the evolution's name ("Silcoon or Cascoon" for random ones), what is still needed
EvolutionBadge.stateOf = function(cid, ballUid)
    local name = getBallPokemonName(ballUid)
    if (not name or not POKEMONS[name] or not havePokemonEvolution(name)) then
        return nil
    end
    local level = tonumber(getBallPokemonLevel(ballUid)) or 0
    local ready, almost = {}, {}
    for _, evolution in ipairs(getPokemonEvolutions(name) or {}) do
        if (not evolution.extraPokemon and level >= (evolution.requiredLevel or 0)) then
            local missing = {}
            for _, itemId in ipairs(evolution.requiredItems or {}) do
                if (getPlayerItemCount(cid, itemId) < 1) then
                    missing[#missing + 1] = getItemNameById(itemId) or "an item"
                end
            end
            local wrongTime = evolution.requiredTime and getWorldLightState() ~= evolution.requiredTime
            if (#missing == 0 and not wrongTime) then
                ready[#ready + 1] = evolution
            else
                local need = table.concat(missing, ", ")
                if (wrongTime) then
                    need = need ~= "" and (need .. " " .. timeText(cid, evolution.requiredTime)) or timeText(cid, evolution.requiredTime)
                end
                almost[#almost + 1] = { name = evolution.name, need = need }
            end
        end
    end
    if (#ready > 0) then
        -- the evolve button's choice: one by item beats one by level only (Kirlia with a Dawn Stone)
        local pick, names = nil, {}
        for _, evolution in ipairs(ready) do
            if (evolution.random) then
                names[#names + 1] = evolution.name
            elseif (not pick or (byItem(evolution) and not byItem(pick))) then
                pick = evolution
            end
        end
        local to = pick and pick.name or table.concat(names, " " .. __L(cid, "or") .. " ")
        return "ready", to
    end
    if (#almost > 0) then
        local lines = {}
        for i = 1, math.min(#almost, 4) do
            lines[#lines + 1] = string.format("%s: %s", almost[i].name, almost[i].need)
        end
        return "almost", almost[1].name, table.concat(lines, "\n")
    end
    return nil
end

-- Works out every carried ball's state, tells the trainer about the ones that just became ready, and sends
-- the bar the list when it changed. quiet: no chat line (a Lua state's first look after login).
EvolutionBadge.refresh = function(cid, quiet)
    if (not isPlayer(cid)) then
        sent[cid], loops[cid] = nil, nil
        return
    end
    if (quiet == nil) then
        quiet = loginAt[cid] ~= nil and os.time() - loginAt[cid] < 8
    end
    local items = {}
    for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
        local number = tonumber(getFastcallNumber(ball.uid))
        local state, to, need = EvolutionBadge.stateOf(cid, ball.uid)
        if (number and state) then
            items[#items + 1] = { number = number, state = state, to = to, need = need }
        end
        -- the chat line: once per evolution, kept on the ball so every Lua state and the next login agree
        local announced = getBallEvolveAnnounced(ball.uid)
        if (state == "ready") then
            if (announced ~= to) then
                setBallEvolveAnnounced(ball.uid, to)
                if (not quiet) then
                    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
                        __L(cid, "Your %s is ready to evolve into %s! Call it out and use the evolve button."),
                        getBallPokemonName(ball.uid), to))
                end
            end
        elseif (announced) then
            setBallEvolveAnnounced(ball.uid, nil)
        end
    end
    table.sort(items, function(a, b) return a.number < b.number end)
    local text = JSON.encode({ type = "evolve", items = items })
    if (sent[cid] ~= text) then
        sent[cid] = text
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.HELD_ITEM, text)
    end
end

-- soon, from wherever a Pokemon changed (a level up, a ball linked to the bar): after the change is saved
EvolutionBadge.soon = function(cid)
    addEvent(function()
        local ok, err = pcall(EvolutionBadge.refresh, cid)
        if (not ok) then
            log(LOG_TYPES.ERROR, "EvolutionBadge.refresh", err)
        end
    end, 200)
end

local function check(cid, token)
    if (loops[cid] ~= token) then
        return
    end
    if (not isPlayer(cid)) then
        sent[cid], loops[cid] = nil, nil
        return
    end
    local ok, err = pcall(EvolutionBadge.refresh, cid)
    if (not ok) then
        log(LOG_TYPES.ERROR, "EvolutionBadge.refresh", err)
    end
    addEvent(check, CHECK, cid, token)
end

EvolutionBadge.onLogin = function(cid)
    sent[cid] = nil
    loginAt[cid] = os.time()
    local token = {}
    loops[cid] = token
    -- after the bar is filled; whatever is ready at login gets its badge, not a chat line
    addEvent(function()
        if (loops[cid] == token and isPlayer(cid)) then
            pcall(EvolutionBadge.refresh, cid, true)
            addEvent(check, CHECK, cid, token)
        end
    end, 3000)
end
