-- Battle text for the modern client (game_battletext): trainers' call-outs and how good each hit was,
-- as JSON on EXTENDED_IDS.BATTLE_TEXT to the players who can see it. The chat line and the floating
-- text are still sent as before; the client draws those itself when its battle text is Classic.
--   {k = "call", c = trainer, n = nickname, m = move, t = type}  a trainer calls out a move
--   {k = "wild", c = pokemon}                                    a wild Pokemon used a move
--   {k = "hit", c = target, s = "crit"|"super"|"weak"|"immune"}  sent just before the hit's number
--   {k = "miss", c = attacker, t = target}                       sent just before "MISS!"
--   {k = "say", c = speaker, s = "summon"|"recall"|"order"|"throw", x = text, n = nickname, t = type}
--                                                                sent just before the speaker says x
BattleText = {}

BattleText.RANGE_X = 9
BattleText.RANGE_Y = 7

local pending = {} -- [target] = { multiplier, crit } from getFinalDamage until doSkillDamage hits

local function send(cid, data)
    if (not EXTENDED_IDS.BATTLE_TEXT or not isCreature(cid)) then
        return
    end
    local payload = JSON.encode(data)
    for _, spectator in ipairs(getSpectators(getCreaturePosition(cid), BattleText.RANGE_X, BattleText.RANGE_Y, false) or {}) do
        if (isPlayer(spectator)) then
            doSendPlayerExtendedOpcode(spectator, EXTENDED_IDS.BATTLE_TEXT, payload)
        end
    end
end

function BattleText.callout(trainer, pokemon, skillName)
    send(trainer, { k = "call", c = trainer, n = getCreatureNickname(pokemon), m = skillName,
                    t = ELEMENT_NAMES[getPokemonSkillDamageType(skillName)] or "Normal" })
end

local function typeName(pokemon, pokemonName)
    local types
    if (isCreature(pokemon)) then
        local ok, found = pcall(getPokemonTypes, pokemon)
        types = ok and found or nil
    elseif (pokemonName and POKEMONS[pokemonName]) then
        types = POKEMONS[pokemonName].pTypes
    end
    return types and ELEMENT_NAMES[types[1]] or "Normal"
end

-- Says text the way doCreatureSay did, after telling the modern clients around it what it is:
-- kind "summon", "recall", "order" or "throw". opts: pokemon (creature) or pokemonName, nick, talkType.
function BattleText.say(cid, kind, text, opts)
    opts = opts or {}
    local nick = opts.nick
    if (not nick and isCreature(opts.pokemon)) then
        nick = getCreatureNickname(opts.pokemon)
    end
    send(cid, { k = "say", c = cid, s = kind, x = text, n = nick or opts.pokemonName,
                t = (opts.pokemon or opts.pokemonName) and typeName(opts.pokemon, opts.pokemonName) or nil })
    if (opts.talkType) then
        doCreatureSay(cid, text, opts.talkType)
    else
        doCreatureSay(cid, text)
    end
end

function BattleText.wildMove(pokemon)
    send(pokemon, { k = "wild", c = pokemon })
end

function BattleText.onMultiplier(toCid, multiplier)
    pending[toCid] = { multiplier = multiplier }
end

function BattleText.onCritical(toCid)
    if (pending[toCid]) then
        pending[toCid].crit = true
    end
end

function BattleText.hit(toCid)
    local hit = pending[toCid]
    pending[toCid] = nil
    if (not hit) then
        return
    end
    local kind
    if (hit.multiplier == 0) then
        kind = "immune"
    elseif (hit.crit) then
        kind = "crit"
    elseif (hit.multiplier > 1) then
        kind = "super"
    elseif (hit.multiplier < 1) then
        kind = "weak"
    end
    if (kind) then
        send(toCid, { k = "hit", c = toCid, s = kind })
    end
end

function BattleText.miss(attacker, target)
    send(attacker, { k = "miss", c = attacker, t = isCreature(target) and target or 0 })
end

function BattleText.forget(toCid)
    pending[toCid] = nil
end
