-- Last Storages: 9312, 9712
if (NpcBattle == nil) then
    local NPC_BATTLE_TIMEOUT = 60 -- one minute
    local NPC_TIME_BETWEEN_BATTLES = 6 * 60 * 60
    local NPC_GYM_TIME_BETWEEN_BATTLES = 10 * 60 * 60 -- NPCs that give a badge
    local NPC_TIME_BETWEEN_BATTLES_FOREVER = -2
    local NPC_BATTLE_MAX_DISTANCE = 6 -- farther from the NPC than this and the battle is canceled
    local NPC_ARENA_MIN_DISTANCE = 3 -- a gym's arena must be at least this long to move the player across it
    local NPC_BATTLE_DURATION = 10 * 60
    local NPC_DIFFICULTY_DYNAMIC = 0 -- Depends on player level
    local NPC_POKEMON_EXPERIENCE_RATE = 2.0

    --local NPC_LEVEL_STORAGE_BASE = 9500 -- Just to remind
    local NPC_LEVEL_MAX = 100
    local NPC_GROW_PER_LEVEL = 3 -- How much the NPC Pokemon will grow with each NPC level

    --local LAST_BATTLE_TIME_STORAGE_BASE = 9100 -- Just to remind

    local STORAGE_BASE = 9000
    local NPC_STORAGES = {
        CURRENT_BATTLE_STATUS = STORAGE_BASE + 1,
        OPPONENT = STORAGE_BASE + 2,
        POKEMON1_STATUS = STORAGE_BASE + 3,
        POKEMON2_STATUS = STORAGE_BASE + 4,
        POKEMON3_STATUS = STORAGE_BASE + 5,
        POKEMON4_STATUS = STORAGE_BASE + 6,
        POKEMON5_STATUS = STORAGE_BASE + 7,
        POKEMON6_STATUS = STORAGE_BASE + 8,
        BATTLE_TIMEOUT = STORAGE_BASE + 9
    }

    local POKEMONNUMBER_TO_VAR = {
        [1] = NPC_STORAGES.POKEMON1_STATUS,
        [2] = NPC_STORAGES.POKEMON2_STATUS,
        [3] = NPC_STORAGES.POKEMON3_STATUS,
        [4] = NPC_STORAGES.POKEMON4_STATUS,
        [5] = NPC_STORAGES.POKEMON5_STATUS,
        [6] = NPC_STORAGES.POKEMON6_STATUS
    }

    local NPC_BATTLE_STATUS = {
        ISNT_BATTLEING = -1,
        IS_BATTLEING = 0
    }

    local NPC_POKEMON_STATUS = {
        CANNOT_USE = -1,
        CAN_USE = 0
    }

    local TALK_STATE = {
        ERASE = 0,
        ACCEPTING_BATTLE = 1
    }

    local BATTLE_END_MODES = {
        PLAYER_LOGOUT = 0,
        PLAYER_WIN = 1,
        PLAYER_LOSS = 2,
        PLAYER_AWAY = 3
    }

    local NPC_DIALOGS = {
        POKEMON_DOWN = {
            "Grr...",
            "I guess I underestimated you...",
            "So you aren't so weak.",
            "Let's see if you can beat this"
        },
        BATTLE_START = {
            "Alright, prepare yourself!",
            "Yep! Let's battle!",
            "Let's see if you can do."
        },
        PLAYER_WITHOUT_POKEMON = {
            "Where is your Pokemon?",
            "Where is your Pokemon? Afraid?",
            "First call your Pokemon!"
        },
        NPC_LOSS = {
            "Grr...",
            "You're very lucky...",
            "Congratulations!"
        },
        NPC_WIN = {
            "Haha! Where is the Pokemon trainer?",
            "Yes! I'm the best! No chance for you.",
            "More luck next time."
        }
    }
    --[[ // ]]
    local NpcsByName = {}
    NpcBattle = {
        name = "",
        uid = 0,
        pokemons = {},
        currentPokemons = {},
        rewardBaseExp = 0,
        rewardItems = {},
        rewardUniqueItems = {},
        rewardRespect = 0,
        rewardBadge = nil,
        lastBattleTimeStorage = 0,
        requiredRespect = 0,
        oneWin = false,
        difficulty = 10,
        required = nil,
        onWin = nil,
        cooldowns = {},
        levelStorage = 0,
        baseBet = 0,
        currentBet = 0,
        npcHandler = nil,
        requiredLevel = 0,
        changes = {}, -- new pokemon that the NPC will carry when the player win x times structure = changes{{level = 1, pokemon = "Pikachu"}, {level = 2, pokemon = Charmander}, ...}
        payRespect = 0,
        evolve = true,
        lastDefeatTimeStorage = nil,
        lastOrder = 0,
        pokemonMaxLevel = NPC_LEVEL_MAX,
        specialMove = nil, -- A move that all Pokemon from this NPC will use
        pokemonDefeatExperienced = false,
        onEnd = nil,
        onDefeatNpcPokemon = nil,
        requiredMessage = nil,
        pokemonMovesets = nil,
        currentPokemonId = -1,
        pokemonTeamEvolvable = true,
        extraStats = nil,
        lossSpeech = nil,
        winSpeech = nil,
        battleInterval = nil,
        defeatedPokemonCount = 0,
        linealOrder = false
    }

    -- local REGISTERED_STORAGES = {}

    function NpcBattle:new(name, lastBattleTimeStorage, levelStorage, npcHandler, lastDefeatTimeStorage)
        if (not npcHandler) then
            log(LOG_TYPES.ERROR, "NpcBattle:new missing npcHandler", name, lastBattleTimeStorage, levelStorage)
            return
        end

        if (not levelStorage) then
            log(LOG_TYPES.ERROR, "NpcBattle:new missing levelStorage", name, lastBattleTimeStorage)
            return
        end

        if (not lastBattleTimeStorage) then
            log(LOG_TYPES.ERROR, "NpcBattle:new missing lastBattleTimeStorage", name)
            return
        end

        if (not name or type(name) ~= "string") then
            log(LOG_TYPES.ERROR, "NpcBattle:new missing name")
            return
        end

        --[[if (table.find(REGISTERED_STORAGES, lastBattleTimeStorage)) then  This is buggy, cuz if we put more then one NPC at the map (same NPC) the warning will show up
                log(LOG_TYPES.ERROR, "NpcBattle:new duplicated last battle time storage", name, lastBattleTimeStorage)
            else
                REGISTERED_STORAGES[#REGISTERED_STORAGES + 1] = lastBattleTimeStorage
            end

            if (table.find(REGISTERED_STORAGES, levelStorage)) then
                log(LOG_TYPES.ERROR, "NpcBattle:new duplicated level storage", name, levelStorage)
            else
                REGISTERED_STORAGES[#REGISTERED_STORAGES + 1] = levelStorage
            end]]

        local obj = {}
        obj.name = name
        obj.lastBattleTimeStorage = lastBattleTimeStorage
        obj.levelStorage = levelStorage
        obj.npcHandler = npcHandler
        obj.lastDefeatTimeStorage = lastDefeatTimeStorage

        setmetatable(obj, self)
        self.__index = self

        NpcsByName[name] = obj
        if (getCreatureIcon(getNpcId()) == CREATURE_ICONS.NONE) then
            setCreatureIcon(getNpcId(), CREATURE_ICONS.BATTLE)
        end

        return obj
    end

    function NpcBattle:setBattleInterval(v)
        self.battleInterval = v
    end

    function NpcBattle:setCustomPokemonLevel(v)
        self.customPokemonLevel = v
    end

    function NpcBattle:setLossSpeech(v)
        self.lossSpeech = v
    end

    function NpcBattle:setWinSpeech(v)
        self.winSpeech = v
    end

    function NpcBattle:setPokemonMovesets(movesets)
        self.pokemonMovesets = movesets
    end

    function NpcBattle:setPokemons(pokemons)
        self.pokemons = pokemons
    end

    function NpcBattle:setRewardBaseExp(rewardBaseExp)
        self.rewardBaseExp = rewardBaseExp
    end

    function NpcBattle:setRewardItems(rewardItems)
        self.rewardItems = rewardItems
    end

    function NpcBattle:setRewardUniqueItems(rewardUniqueItems)
        self.rewardUniqueItems = rewardUniqueItems
    end

    function NpcBattle:setRewardRespect(rewardRespect)
        self.rewardRespect = rewardRespect
    end

    function NpcBattle:setRewardBadge(rewardBadge)
        self.rewardBadge = rewardBadge
    end

    function NpcBattle:setRequiredRespect(requiredRespect)
        self.requiredRespect = requiredRespect
    end

    function NpcBattle:setOneWin(oneWin)
        self.oneWin = oneWin
    end

    function NpcBattle:setDifficulty(difficulty)
        self.difficulty = difficulty
    end

    function NpcBattle:setRequired(required)
        self.required = required
    end

    -- msg: a string, or function(cid) returning one
    function NpcBattle:setRequiredMessage(msg)
        self.requiredMessage = msg
    end

    -- Gym leaders: every one of these trainers must be beaten first, and the leader says how many are left.
    function NpcBattle:setRequiredTrainers(names)
        local function remaining(cid)
            local left = {}
            for _, name in ipairs(names) do
                if (not getPlayerDefeatedNPC(cid, name)) then
                    left[#left + 1] = name
                end
            end
            return left
        end
        self.required = function(cid) return #remaining(cid) == 0 end
        self.requiredMessage = function(cid)
            local left = remaining(cid)
            if (#left == 1) then
                return string.format(__L(cid, "You must first defeat the GYM trainers. Only %s is left, then battle against me."), left[1])
            end
            return string.format(__L(cid, "You must first defeat the GYM trainers: %d of %d are left."), #left, #names)
        end
    end

    function NpcBattle:setOnWin(onWin)
        self.onWin = onWin
    end

    function NpcBattle:setOnEnd(v)
        self.onEnd = v
    end

    function NpcBattle:setOnDefeatNpcPokemon(v)
        self.onDefeatNpcPokemon = v
    end

    function NpcBattle:setBaseBet(baseBet)
        self.baseBet = baseBet
    end

    function NpcBattle:setRequiredLevel(requiredLevel)
        self.requiredLevel = requiredLevel
    end

    function NpcBattle:addChange(level, pokemon)
        table.insert(self.changes, { level = level, pokemon = pokemon })
    end

    function NpcBattle:setPayRespect(payRespect)
        self.payRespect = payRespect
    end

    function NpcBattle:setEvolve(evolve)
        self.evolve = evolve
    end

    function NpcBattle:setPokemonMaxLevel(v)
        self.pokemonMaxLevel = v
    end

    function NpcBattle:setSpecialMove(v)
        self.specialMove = v
    end

    function NpcBattle:setPokemonDefeatExperienced(v)
        self.pokemonDefeatExperienced = v
    end

    function NpcBattle:setRequiredStorage(v)
        self.requiredStorage = v
    end

    function NpcBattle:setPokemonTeamEvolvable(v)
        self.pokemonTeamEvolvable = v
    end

    function NpcBattle:setPokemonExtraStats(v)
        self.extraStats = v
    end

    function NpcBattle:setLinealOrder(v)
        self.linealOrder = v
    end

    --[[ // ]]
    -- IS
    function NpcBattle:isBattleing()
        return getCreatureStorage(self.uid, NPC_STORAGES.CURRENT_BATTLE_STATUS) == NPC_BATTLE_STATUS.IS_BATTLEING
    end

    function NpcBattle:isPokemonOnline()
        return #getCreatureSummons(self.uid) > 0
    end

    -- GET
    function NpcBattle:getPokemons()
        return self.pokemons
    end

    function NpcBattle:getPokemon()
        return getCreatureSummons(self.uid)[1]
    end

    function NpcBattle:getBattleTimeoutRemaing()
        return getCreatureStorage(self.uid, NPC_STORAGES.BATTLE_TIMEOUT)
    end

    function NpcBattle:getRequiredRespect()
        return self.requiredRespect
    end

    function NpcBattle:getMoveCooldown(move)
        return (self.cooldowns[move] and self.cooldowns[move] - getCurrentTimeInSeconds()) or 0
    end

    --[[ The NPC level is based on how many wins the player gets against him, many wins = npc stronger  ]]
    function NpcBattle:getLevel(pid)
        if (self.evolve) then
            local v = getCreatureStorage(pid, self.levelStorage)
            return (v and v > 0 and v <= self.pokemonMaxLevel) and v or 1
        end
        return 1
    end

    function NpcBattle:getPokemonMove(pokemonUid, targetUid)
        local moves = self.pokemonMovesets and self.pokemonMovesets[self.currentPokemonId] or getPokemonDefaultSkills(getPokemonReferenceName(pokemonUid))
        if (self.specialMove) then
            moves[#moves + 1] = self.specialMove
        end

        -- First try a random move, if cant use it, try from the strongest to down
        local move = table.random(moves)
        if (not self:canPokemonUseMove(move, pokemonUid, targetUid)) then
            move = nil
            for i = #moves, #moves, -1 do
                if (self:canPokemonUseMove(moves[i], pokemonUid, targetUid)) then
                    move = moves[i]
                    break
                end
            end
        end

        return move
    end

    -- SET
    function NpcBattle:setBattleStatus(status)
        doCreatureSetStorage(self.uid, NPC_STORAGES.CURRENT_BATTLE_STATUS, status)
    end

    function NpcBattle:setOpponent(opponent)
        doCreatureSetStorage(self.uid, NPC_STORAGES.OPPONENT, opponent)
        doNpcSetOpponent(self.uid, opponent) -- Source function
    end

    function NpcBattle:setPokemonStatus(pokemonNumber, status)
        doCreatureSetStorage(self.uid, POKEMONNUMBER_TO_VAR[pokemonNumber], status)
    end

    function NpcBattle:setBattleTimeout(battleTimeout)
        doCreatureSetStorage(self.uid, NPC_STORAGES.BATTLE_TIMEOUT, battleTimeout)
    end

    function NpcBattle:setPlayerLastBattleTimeWithNpc(pid, forever)
        if (isNumber(forever)) then
            doCreatureSetStorage(pid, self.lastBattleTimeStorage, forever)
        else
            doCreatureSetStorage(pid, self.lastBattleTimeStorage, (forever and NPC_TIME_BETWEEN_BATTLES_FOREVER or os.time()))
        end
    end

    function NpcBattle:setMoveCooldown(move, cooldown)
        if (not cooldown) then
            cooldown = getPokemonSkillCooldownTime(move)
        end
        self.cooldowns[move] = cooldown + getCurrentTimeInSeconds()
    end

    function NpcBattle:setLevel(pid, level)
        doCreatureSetStorage(pid, self.levelStorage, (level <= self.pokemonMaxLevel and level or
                self.pokemonMaxLevel))
    end

    -- CAN
    function NpcBattle:canPokemonUseMove(move, pokemonUid, targetUid)
        if (self:getMoveCooldown(move) > 0 or getPokemonSkillWildBlock(move) or
                getMonsterLevel(pokemonUid) < getPokemonSkillRequiredLevel(getCreatureName(pokemonUid), move) or
                (getPokemonSkillMakeHeal(move) and getCreatureHealth(pokemonUid) / getCreatureMaxHealth(pokemonUid) > 0.5)) then
            return false
        end

        if (getInstantSpellInfo(SKILL_FUNCTION_PREFIX .. move).needdirection == 1) then
            local pokemonPos, targetPos = getCreaturePosition(pokemonUid), getCreaturePosition(targetUid)
            if (pokemonPos.x ~= targetPos.x and pokemonPos.y ~= targetPos.y) then
                return false
            end
            doCreatureSetLookDirection(pokemonUid, getDirectionTo(pokemonPos, targetPos))
        end
        return true
    end

    function NpcBattle:canPlayerBattleWithNpc(pid)
        if (getPlayerDueling(pid)) then
            return __L(pid, "You can't battle against me while you're dueling.")
        end

        if (self.payRespect > 0 and getPlayerRespect(pid) < self.payRespect) then
            return string.format(__L(pid, "You need pay %s respect points to battle against me."), self.payRespect)
        end

        if (getPlayerLevel(pid) < self.requiredLevel) then
            return string.format(__L(pid, "You need at least level %s to battle against me."), self.requiredLevel)
        end

        self:doUpdateCurrentBet(pid)
        if (self.currentBet > 0 and getPlayerMoney(pid) < self.currentBet) then
            return string.format(__L(pid, "You need at least %s dollars to bet."), self.currentBet)
        end

        if (getPlayerRespect(pid) < self.requiredRespect) then
            return string.format(__L(pid, "Sorry kid, you need at least %s respect points to do a battle with me."), self.requiredRespect)
        end

        if (self.rewardBadge ~= nil) then
            if (getPlayerItemCount(pid, self.rewardBadge.newItemId) > 0) then
                return __L(pid, "You already have my badge, there is no reason to a new battle.")
            end
        end

        local lastBattleTime = getCreatureStorage(pid, self.lastBattleTimeStorage)
        if (lastBattleTime == NPC_TIME_BETWEEN_BATTLES_FOREVER) then
            return __L(pid, "You beat me before, there is no reason to a new battle.")

        elseif (lastBattleTime > -1) then
            local interval = self.battleInterval
            if (interval == nil) then
                interval = self.rewardBadge ~= nil and NPC_GYM_TIME_BETWEEN_BATTLES or NPC_TIME_BETWEEN_BATTLES
                -- With the default intervals, a server save also clears the wait
                if (lastBattleTime <= getGlobalStorageValue(GLOBAL_STORAGES.SERVER_START_TIME)) then
                    interval = 0
                end
            end

            local remaingTime = (lastBattleTime + interval) - os.time()
            if (remaingTime > 0) then
                return string.format(__L(pid, "Sorry, you must wait %s seconds to battle with me again."), table.concat(string.timediff(remaingTime, pid)))
            end
        end

        if ((self.requiredStorage and getCreatureStorage(pid, self.requiredStorage) < 0) or
                (self.required and not self.required(pid))) then
            if (type(self.requiredMessage) == "function") then
                return self.requiredMessage(pid)
            end
            return self.requiredMessage and self.requiredMessage or __L(pid, "You can't duel against me yet.")
        end

        if (not isSightClear(getCreaturePosition(pid), getCreaturePosition(self.uid), false)) then
            return __L(pid, "First get next to me.")
        end

        if (isPokemonOnline(pid)) then
            local pokemon = getPlayerPokemon(pid)
            if (isMonster(pokemon) and isPokemonUsingHealthPotion(pokemon) or isPokemonUsingEnergyPotion(pokemon)) then
                return __L(pid, "You can't battle against me while your Pokemon is using potions.")
            end
        end

        if (getTilePzInfo(getCreaturePosition(pid))) then
            return __L(pid, "You can't duel against me while you are in a protection zone.")
        end

        return true
    end

    -- DO
    function NpcBattle:doMovesCooldownReset()
        self.cooldowns = {}
    end

    function NpcBattle:doPlayerGiveBadge(pid, badge)
        doTransformItem(getPlayerItemById(pid, true, badge.oldItemId).uid, badge.newItemId)
    end

    function NpcBattle:doPokemonsStatusReset()
        for i = 1, #self.currentPokemons do
            self:setPokemonStatus(i, NPC_POKEMON_STATUS.CAN_USE)
        end
    end

    function NpcBattle:doBattleTimeoutReset()
        self:setBattleTimeout(NPC_BATTLE_TIMEOUT)
    end

    function NpcBattle:doCallPokemon(pokemonName, pid)
        self:doMovesCooldownReset()
        doAddExhaust(self.uid)

        local spawnPosition = getCreaturePosition(self.uid)
        local pokemon = doSummonCreature(pokemonName, spawnPosition, false)

        local pos = getPositionAdjacent(pokemon, spawnPosition)
        if (pos) then
            doTeleportThing(pokemon, pos)
        end

        doConvinceCreature(self.uid, pokemon)
        doSendMagicEffect(spawnPosition, balls["poke"].effects.use)
        registerCreatureEvent(pokemon, "npcPokemonDeath")
        doCreatureSay(self.uid, string.format(__L(pid, "Go, %s!"), pokemonName), TALKTYPE_MONSTER)

        addEvent(function()
            if (isCreature(pokemon)) then
                doSendCreatureEffect(pokemon, CREATURE_EFFECTS.RED_FADE_IN)
            end
        end, 10)

        local level = 0
        if (self.customPokemonLevel ~= nil) then
            level = self.customPokemonLevel(pid)
        elseif (self.difficulty ~= NPC_DIFFICULTY_DYNAMIC) then
            level = self.difficulty + ((self:getLevel(getNpcOpponent(self.uid)) - 1) * NPC_GROW_PER_LEVEL)
        else
            level = getPlayerLevel(getNpcOpponent(self.uid))
            level = level >= 10 and level or 10
            level = level <= 90 and level or 90
            level = getRandom(level - 20, level)
        end

        level = (level <= self.pokemonMaxLevel and level or self.pokemonMaxLevel)
        level = (level <= POKEMON_LEVEL_MAX and level or POKEMON_LEVEL_MAX)
        level = (level > 0 and level or 1)

        setMonsterExtraPoints(pokemon, level + 10)
        setMonsterLevel(pokemon, level)
        if (self.pokemonDefeatExperienced) then
            setCreatureSkillLoss(pokemon, true) -- Enable exp
            setMonsterExperienceRate(pokemon, NPC_POKEMON_EXPERIENCE_RATE)
        end

        if (self.extraStats) then
            setMonsterVarPokeStat(pokemon, MONSTER_POKE_STATS.MAXHEALTH, self.extraStats)
            setMonsterVarPokeStat(pokemon, MONSTER_POKE_STATS.ATTACK, self.extraStats)
            setMonsterVarPokeStat(pokemon, MONSTER_POKE_STATS.DEFENSE, self.extraStats)
            setMonsterVarPokeStat(pokemon, MONSTER_POKE_STATS.SPECIALATTACK, self.extraStats)
            setMonsterVarPokeStat(pokemon, MONSTER_POKE_STATS.SPECIALDEFENSE, self.extraStats)
            setMonsterVarPokeStat(pokemon, MONSTER_POKE_STATS.SPEED, self.extraStats)
        end
    end

    local function getElementMultiplerBetweenPokemons(pokemon1, pokemon2)
        if (not pokemon1 or not pokemon2) then
            return 0
        end

        local result = 0
        local pokemon1elements = getPokemonTypes(nil, pokemon1)
        local pokemon2elements = getPokemonTypes(nil, pokemon2)

        for i = 1, #pokemon1elements do
            for j = 1, #pokemon2elements do
                result = result + getElementMultipler(pokemon1elements[i], pokemon2elements[j])
            end
        end

        return result
    end

    local function findMaxInTable(inTable)
        if (#inTable < 1) then
            return nil
        end

        local resultKey, resultValue, tableKey, tableValue = -1, -1, nil, nil

        for tableKey = 1, #inTable do
            tableValue = inTable[tableKey]

            if (tableValue > -1 and tableValue > resultValue) then
                resultKey = tableKey
                resultValue = tableValue
            end
        end

        if (resultValue > -1) then
            return resultKey
        end

        return nil
    end

    function NpcBattle:doCallNextPokemon()
        local pid = getNpcOpponent(self.uid)
        self.defeatedPokemonCount = (self.currentPokemonId and (self.defeatedPokemonCount + 1) or 0)
        if (self.defeatedPokemonCount > 0 and self.onDefeatNpcPokemon) then
            self:onDefeatNpcPokemon(pid, self.defeatedPokemonCount)
        end

        if (self.linealOrder) then
            if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON1_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
                self:doCallPokemon(self.currentPokemons[1], pid)
                self:setPokemonStatus(1, NPC_POKEMON_STATUS.CANNOT_USE)
                self.currentPokemonId = 1
                return true
            end

            if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON2_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
                self:doCallPokemon(self.currentPokemons[2], pid)
                self:setPokemonStatus(2, NPC_POKEMON_STATUS.CANNOT_USE)
                self.currentPokemonId = 2
                return true
            end

            if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON3_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
                self:doCallPokemon(self.currentPokemons[3], pid)
                self:setPokemonStatus(3, NPC_POKEMON_STATUS.CANNOT_USE)
                self.currentPokemonId = 3
                return true
            end

            if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON4_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
                self:doCallPokemon(self.currentPokemons[4], pid)
                self:setPokemonStatus(4, NPC_POKEMON_STATUS.CANNOT_USE)
                self.currentPokemonId = 4
                return true
            end

            if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON5_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
                self:doCallPokemon(self.currentPokemons[5], pid)
                self:setPokemonStatus(5, NPC_POKEMON_STATUS.CANNOT_USE)
                self.currentPokemonId = 5
                return true
            end

            if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON6_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
                self:doCallPokemon(self.currentPokemons[6], pid)
                self:setPokemonStatus(6, NPC_POKEMON_STATUS.CANNOT_USE)
                self.currentPokemonId = 6
                return true
            end

            return false
        end

        local npcPokemonsMultiplers = {}
        local npcOpponentPokemonName = getPlayerPokemonName(pid)

        if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON1_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
            table.insert(npcPokemonsMultiplers, 1, getElementMultiplerBetweenPokemons(self.currentPokemons[1], npcOpponentPokemonName))
        else
            table.insert(npcPokemonsMultiplers, 1, -1)
        end

        if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON2_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
            table.insert(npcPokemonsMultiplers, 2, getElementMultiplerBetweenPokemons(self.currentPokemons[2], npcOpponentPokemonName))
        else
            table.insert(npcPokemonsMultiplers, 2, -1)
        end

        if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON3_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
            table.insert(npcPokemonsMultiplers, 3, getElementMultiplerBetweenPokemons(self.currentPokemons[3], npcOpponentPokemonName))
        else
            table.insert(npcPokemonsMultiplers, 3, -1)
        end

        if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON4_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
            table.insert(npcPokemonsMultiplers, 4, getElementMultiplerBetweenPokemons(self.currentPokemons[4], npcOpponentPokemonName))
        else
            table.insert(npcPokemonsMultiplers, 4, -1)
        end

        if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON5_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
            table.insert(npcPokemonsMultiplers, 5, getElementMultiplerBetweenPokemons(self.currentPokemons[5], npcOpponentPokemonName))
        else
            table.insert(npcPokemonsMultiplers, 5, -1)
        end

        if (getCreatureStorage(self.uid, NPC_STORAGES.POKEMON6_STATUS) == NPC_POKEMON_STATUS.CAN_USE) then
            table.insert(npcPokemonsMultiplers, 6, getElementMultiplerBetweenPokemons(self.currentPokemons[6], npcOpponentPokemonName))
        else
            table.insert(npcPokemonsMultiplers, 6, -1)
        end

        local bestPokemonToUseNow = findMaxInTable(npcPokemonsMultiplers)
        if (bestPokemonToUseNow) then
            self:doCallPokemon(self.currentPokemons[bestPokemonToUseNow], pid)
            self:setPokemonStatus(bestPokemonToUseNow, NPC_POKEMON_STATUS.CANNOT_USE)
            self.currentPokemonId = bestPokemonToUseNow
            return true
        end

        return false
    end

    function NpcBattle:doBattleEnd(pid, battleEndMode)
        if (battleEndMode == BATTLE_END_MODES.PLAYER_WIN) then
            if (self.lossSpeech) then
                doCreatureSay(self.uid, __L(pid, self.lossSpeech), TALKTYPE_SAY)
            else
                doCreatureSay(self.uid, __L(pid, table.random(NPC_DIALOGS.NPC_LOSS)), TALKTYPE_SAY)
            end

            if (self.rewardBaseExp > 0 or self.rewardBadge ~= nil or #self.rewardItems > 0 or
                    #self.rewardUniqueItems > 0 or self.currentBet > 0) then
                doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "You won %s and received your reward."), self.name))
            else
                doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "You won %s."), self.name))
            end

            -- Before the battle win count changes, so the client shows it instead of the plain win banner
            if (GymLeaders.get(self.name, self.rewardBadge)) then
                GymLeaders.send(pid, "victory", self.name, self.uid)
            end

            doPlayerAddBattleWin(pid)
            doPlayerAddRespect(pid, (self.rewardRespect * 2))
            doPlayerAddStatistic(pid, PLAYER_STATISTIC_IDS.DEFEAT_NPC, 1)

            local previousLevel = self:getLevel(pid)
            self:setLevel(pid, previousLevel + 1)

            if (self.rewardBaseExp > 0) then
                doPlayerAddExperience(pid, self.rewardBaseExp * previousLevel)
                doSendAnimatedText(getCreaturePosition(pid), "+EXP!", COLOR_LIGHTGREEN)
            end

            if (self.rewardBadge ~= nil) then
                self:doPlayerGiveBadge(pid, self.rewardBadge)
                doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "Congratulations! You received the %s from %s."), getItemNameById(self.rewardBadge.newItemId), self.name))
            end

            doPlayerAchievementCheck(pid, ACHIEVEMENT_IDS.KANTO_BADGES)

            for i = 1, #self.rewardItems, 2 do
                doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "You received: %s [%sx]."), getItemNameById(self.rewardItems[i]), self.rewardItems[i + 1]))
                doPlayerAddItem(pid, self.rewardItems[i], self.rewardItems[i + 1], true)
            end

            for i = 1, #self.rewardUniqueItems, 2 do
                local item = doCreateUniqueItemEx(pid, self.rewardUniqueItems[i], self.rewardUniqueItems[i + 1])
                if (item) then
                    if (doPlayerAddItemEx(pid, item, false) == RETURNVALUE_NOERROR) then
                        doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "You received: %s [%sx]."), getItemNameById(self.rewardUniqueItems[i]), self.rewardUniqueItems[i + 1]))
                    else
                        doPlayerAddDepotItem(pid, 0, item)
                        doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "You received: %s [%x] directly into your depot."), getItemNameById(self.rewardUniqueItems[i]), self.rewardUniqueItems[i + 1]))
                    end
                else
                    log(LOG_TYPES.ERROR, "NpcBattle:doBattleEnd - Can't create reward unique item.",
                        getCreatureName(pid), self.rewardUniqueItems[i], self.rewardUniqueItems[i + 1])
                end
            end

            if (self.currentBet > 0) then
                doPlayerAddMoney(pid, math.floor(self.currentBet * 2))
            end

            if (self.oneWin) then
                self:setPlayerLastBattleTimeWithNpc(pid, true)
            end

            if (self.lastDefeatTimeStorage) then
                doCreatureSetStorage(pid, self.lastDefeatTimeStorage, os.time())
            end

            if (self.onWin) then
                self.onWin(pid)
            end

        elseif (battleEndMode == BATTLE_END_MODES.PLAYER_LOSS) then
            if (self.winSpeech) then
                doCreatureSay(self.uid, __L(pid, self.winSpeech), TALKTYPE_SAY)
            else
                doCreatureSay(self.uid, __L(pid, table.random(NPC_DIALOGS.NPC_WIN)), TALKTYPE_SAY)
            end
            doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "You have been defeated by %s!"), self.name))
            doPlayerAddBattleLoss(pid)

        elseif (battleEndMode == BATTLE_END_MODES.PLAYER_AWAY) then
            doCreatureSay(self.uid, table.random(NPC_DIALOGS.NPC_WIN), TALKTYPE_SAY)
            doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, "You and your opponent were too far from each other and the battle was canceled.")
            doPlayerAddBattleLoss(pid)
        end

        if (self:isPokemonOnline()) then
            local npcPokemon = self:getPokemon()

            doCreatureSay(self.uid, string.format(__L(pid, "Back, %s!"), getCreatureName(npcPokemon)), TALKTYPE_SAY)
            doSendMagicEffect(getCreaturePosition(npcPokemon), balls["poke"].effects.use)
            doRemoveCreature(npcPokemon)
        end

        self:setBattleStatus(NPC_BATTLE_STATUS.ISNT_BATTLEING)
        self:doHoldConversation(false)
        self.battleMaxDistance = nil
        self.npcHandler:releaseFocus(pid)

        if (isPlayer(pid)) then
            setPlayerBattleing(pid, false)
            setPlayerDisconnectAtExit(pid, true)
            doCreatureSetNoMove(pid, false)

            if (self.onEnd) then
                self.onEnd(pid, battleEndMode == BATTLE_END_MODES.PLAYER_WIN, self.uid)
            end
        end
    end

    function NpcBattle:doBattleCheck(pid, battleTimeRemaing, decreaseTimeout, playerLastFreeCap, checkAlivePokemon)
        if (not isPlayer(pid)) then
            self:doBattleEnd(pid, BATTLE_END_MODES.PLAYER_LOGOUT)
            return
        end

        local playerCap = getPlayerFreeCap(pid)
        if (playerLastFreeCap and playerCap ~= playerLastFreeCap) then
            doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, "You modified your Pokemon team during battle! You're out!")
            self:doBattleEnd(pid, BATTLE_END_MODES.PLAYER_LOSS)
            return
        end

        if (battleTimeRemaing == 0) then
            doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, "Your time has ended.")
            self:doBattleEnd(pid, BATTLE_END_MODES.PLAYER_LOSS)
            return
        end

        local playerPosition = getCreaturePosition(pid)
        local npcPosition = getCreaturePosition(self.uid)
        if (not npcPosition) then
            return
        end

        if (getDistanceBetween(npcPosition, playerPosition) > (self.battleMaxDistance or NPC_BATTLE_MAX_DISTANCE) or playerPosition.z ~= npcPosition.z) then
            self:doBattleEnd(pid, BATTLE_END_MODES.PLAYER_AWAY)
            return
        end

        if (self:isPokemonOnline()) then
            local playerPokemon = getPlayerPokemon(pid)

            if (isCreature(playerPokemon)) then
                local npcPokemon = self:getPokemon()

                if (not hasTarget(npcPokemon)) then
                    doCreatureSetTarget(npcPokemon, playerPokemon)
                end

                if (not isExhaust(self.uid)) then
                    local move = self:getPokemonMove(npcPokemon, playerPokemon)
                    if (move) then
                        self:doPokemonUseMove(npcPokemon, move)
                    end
                end

                if (getRandom(0, 100) <= 25 or getDistanceBetween(getCreaturePosition(npcPokemon), getCreaturePosition(playerPokemon)) > 3) then
                    self:doOrderPokemon(npcPokemon, playerPokemon, pid)
                end

            elseif (getPlayerDuelPokemonRemaing(pid) <= 0) then
                self:doBattleEnd(pid, BATTLE_END_MODES.PLAYER_LOSS)
                return

            elseif (decreaseTimeout) then
                if (checkAlivePokemon) then
                    local tmpBalls = getPlayerAllBallsWithPokemon(pid)
                    local alives = #tmpBalls

                    if (alives < PLAYER_BALL_MAX) then -- Maybe this player hasnt six Pokemon, so the timeout is useless
                        for _, ball in pairs(tmpBalls) do
                            local ballName = ballsNames[ball.itemid]
                            if (not ballName or ball.itemid == balls[ballName].discharged) then
                                alives = alives - 1
                            end
                        end

                        if (alives <= 0) then
                            self:doBattleEnd(pid, BATTLE_END_MODES.PLAYER_LOSS)
                            return
                        end

                    else
                        checkAlivePokemon = nil -- Isnt need check if the player got six Pokemon, the timeout will work fine
                    end
                end

                local timeout = self:getBattleTimeoutRemaing()
                if (timeout <= 0) then
                    doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, "Your time has ended.")
                    self:doBattleEnd(pid, BATTLE_END_MODES.PLAYER_LOSS)
                    return

                else
                    doSendAnimatedText(playerPosition, timeout, TEXTCOLOR_RED)
                    self:setBattleTimeout(timeout - 1)
                    decreaseTimeout = false
                end
            else
                decreaseTimeout = true
            end
        else
            if (self:doCallNextPokemon()) then
                doCreatureSay(self.uid, __L(pid, table.random(NPC_DIALOGS.POKEMON_DOWN)), TALKTYPE_SAY)
            else
                self:doBattleEnd(pid, BATTLE_END_MODES.PLAYER_WIN)
                return
            end
        end
        addEvent(self.doBattleCheck, 500, self, pid, battleTimeRemaing - 0.5, decreaseTimeout, playerCap, checkAlivePokemon)
    end

    local ARENA_DIRECTIONS = { { x = 1, y = 0 }, { x = -1, y = 0 }, { x = 0, y = 1 }, { x = 0, y = -1 } }
    local ARENA_LINES_FROM, ARENA_LINES_TO = 13238, 13253 -- floor of the white lines of a gym's battle field
    local ARENA_SEARCH = 10

    local function isArenaLine(position)
        for stackpos = 0, 3 do
            position.stackpos = stackpos
            local thing = getThingFromPos(position, false)
            if (thing and thing.itemid and thing.itemid >= ARENA_LINES_FROM and thing.itemid <= ARENA_LINES_TO) then
                return true
            end
        end
        return false
    end

    -- The bounds of the battle field the NPC stands at, from the floor of its lines
    local function getArenaField(center)
        local field
        for dy = -ARENA_SEARCH, ARENA_SEARCH do
            for dx = -ARENA_SEARCH, ARENA_SEARCH do
                local x, y = center.x + dx, center.y + dy
                if (isArenaLine({ x = x, y = y, z = center.z })) then
                    if (not field) then
                        field = { minX = x, maxX = x, minY = y, maxY = y }
                    else
                        field.minX, field.maxX = math.min(field.minX, x), math.max(field.maxX, x)
                        field.minY, field.maxY = math.min(field.minY, y), math.max(field.maxY, y)
                    end
                end
            end
        end
        return field
    end

    -- Across the middle of the field; the NPC's row or column is kept when it stands in the middle of it
    local function mirror(value, low, high)
        local middle = (low + high) / 2
        if (math.abs(value - middle) <= 1) then
            return value
        end
        return math.floor(2 * middle - value + 0.5)
    end

    local function isArenaStandable(pid, position, playerPosition)
        if (getTilePzInfo(position)) then
            return false
        end
        return getSamePosition(position, playerPosition) or isWalkable(pid, position)
    end

    -- The longest straight run of free tiles from the NPC, on the side the player talked from
    local function getArenaRunEnd(pid, npcPosition, playerPosition)
        local best, bestScore
        for _, direction in ipairs(ARENA_DIRECTIONS) do
            local facing = (playerPosition.x - npcPosition.x) * direction.x + (playerPosition.y - npcPosition.y) * direction.y
            if (facing >= 0) then
                local run, free = 0, nil
                for i = 1, ARENA_SEARCH do
                    local position = { x = npcPosition.x + direction.x * i, y = npcPosition.y + direction.y * i, z = npcPosition.z }
                    local own = getSamePosition(position, playerPosition)
                    if ((not own and doTileQueryAdd(pid, position, 4, false) ~= 1) or getTilePzInfo(position)) then -- 4: FLAG_IGNOREBLOCKCREATURE
                        break
                    end
                    run = i
                    if (i <= NPC_BATTLE_MAX_DISTANCE and isArenaStandable(pid, position, playerPosition)) then
                        free = position
                    end
                end

                local score = run * 10 + facing
                if (run >= NPC_ARENA_MIN_DISTANCE and free and (not bestScore or score > bestScore)) then
                    best, bestScore = free, score
                end
            end
        end
        return best
    end

    -- Where the player stands for a gym duel: the NPC's mirror across the battle field, so they face
    -- each other from its two ends.
    function NpcBattle:getArenaPosition(pid)
        local npcPosition = getCreaturePosition(self.uid)
        local playerPosition = getCreaturePosition(pid)

        local field = getArenaField(npcPosition)
        if (field) then
            local target = { x = mirror(npcPosition.x, field.minX, field.maxX), y = mirror(npcPosition.y, field.minY, field.maxY), z = npcPosition.z }
            if (not getSamePosition(target, npcPosition)) then
                for radius = 0, 2 do
                    for dy = -radius, radius do
                        for dx = -radius, radius do
                            if (math.max(math.abs(dx), math.abs(dy)) == radius) then
                                local position = { x = target.x + dx, y = target.y + dy, z = target.z }
                                if (isArenaStandable(pid, position, playerPosition)) then
                                    return position
                                end
                            end
                        end
                    end
                end
            end
        end

        return getArenaRunEnd(pid, npcPosition, playerPosition)
    end

    function NpcBattle:doPlaceInArena(pid)
        local destination = self:getArenaPosition(pid)
        if (not destination) then
            return
        end

        local npcPosition = getCreaturePosition(self.uid)
        self.battleMaxDistance = math.max(NPC_BATTLE_MAX_DISTANCE, getDistanceBetween(npcPosition, destination) + 1)
        if (not getSamePosition(destination, getCreaturePosition(pid))) then
            doSendMagicEffect(getCreaturePosition(pid), CONST_ME_TELEPORT)
            doTeleportThing(pid, destination, false)
            doSendMagicEffect(destination, CONST_ME_TELEPORT)
        end
        doCreatureSetLookDirection(pid, getDirectionTo(destination, npcPosition))
        doCreatureSetLookDirection(self.uid, getDirectionTo(npcPosition, destination))

        -- The player's Pokemon stands one step ahead of its trainer
        local pokemon = getPlayerPokemon(pid)
        if (isCreature(pokemon)) then
            local dx, dy = npcPosition.x - destination.x, npcPosition.y - destination.y
            local step = math.abs(dx) >= math.abs(dy) and { x = (dx > 0 and 1 or -1), y = 0 } or { x = 0, y = (dy > 0 and 1 or -1) }
            local ahead = { x = destination.x + step.x, y = destination.y + step.y, z = destination.z }
            local position = isWalkable(pokemon, ahead) and ahead or getPositionAdjacent(pokemon, destination)
            if (position) then
                doTeleportThing(pokemon, position, false)
                doCreatureSetLookDirection(pokemon, getDirectionTo(position, npcPosition))
            end
        end
    end

    -- The conversation stays open while the battle lasts, wherever the player stands in it
    function NpcBattle:doHoldConversation(hold)
        local handler = self.npcHandler
        if (hold) then
            self.savedTalkRadius = self.savedTalkRadius or handler.talkRadius
            self.savedIdleTime = self.savedIdleTime or handler.idleTime
            handler.talkRadius = math.max(self.savedTalkRadius, self.battleMaxDistance or NPC_BATTLE_MAX_DISTANCE)
            handler.idleTime = math.max(self.savedIdleTime, NPC_BATTLE_DURATION)
        elseif (self.savedTalkRadius) then
            handler.talkRadius = self.savedTalkRadius
            handler.idleTime = self.savedIdleTime
            self.savedTalkRadius, self.savedIdleTime = nil, nil
        end
    end

    function NpcBattle:doBattleStart(pid)
        local gym = GymLeaders.get(self.name, self.rewardBadge)
        if (gym) then
            self:doPlaceInArena(pid)
            GymLeaders.send(pid, "intro", self.name, self.uid)
        end
        self:doHoldConversation(true)

        self:setBattleStatus(NPC_BATTLE_STATUS.IS_BATTLEING)
        self:setOpponent(pid)
        self:doUpdateCurrentPokemons(pid)
        self:doPokemonsStatusReset()
        self:doBattleTimeoutReset()
        self:doCallNextPokemon()
        self:setPlayerLastBattleTimeWithNpc(pid)
        if (self.currentBet > 0) then doPlayerRemoveMoney(pid, self.currentBet) end
        if (self.payRespect > 0) then doPlayerAddRespect(pid, -self.payRespect) end
        setPlayerDuelPokemonRemaing(pid, 6)
        setPlayerBattleing(pid, true)
        doAddCondition(pid, pokemonCallDelayCondition)
        doCreatureSay(self.uid, __L(pid, table.random(NPC_DIALOGS.BATTLE_START)), TALKTYPE_SAY)
        setPlayerDisconnectAtExit(pid, false)
        doCreatureSetNoMove(pid, true)
        self:doBattleCheck(pid, NPC_BATTLE_DURATION, true, nil, true)
    end

    function NpcBattle:doPokemonUseMove(pokemonUid, move)
        if (doPokemonUseSkill(pokemonUid, move)) then
            self:setMoveCooldown(move)
            doAddExhaust(self.uid)
        end
    end

    function NpcBattle:doUpdateCurrentPokemons(pid)
        local npcLevel = self:getLevel(pid)
        self.currentPokemons = table.copy(self.pokemons)

        -- Add all possibly pokemons to my team
        for i, change in ipairs(self.changes) do
            if (npcLevel >= change.level) then
                table.insert(self.currentPokemons, change.pokemon)
            end
        end

        -- If I get more then I can carry, remove random
        while (#self.currentPokemons > 6) do
            table.remove(self.currentPokemons, math.random(1, #self.currentPokemons))
        end

        -- What level my pokemons are now
        local level
        if (self.difficulty ~= NPC_DIFFICULTY_DYNAMIC) then
            level = self.difficulty + ((npcLevel - 1) * NPC_GROW_PER_LEVEL)
            level = (level <= POKEMON_LEVEL_MAX and level or POKEMON_LEVEL_MAX)
        else
            level = getPlayerLevel(pid)
            level = level >= 10 and level or 10
            level = level <= 90 and level or 90
            level = math.random(level - 5, level)
        end

        -- Evolve them, if possible
        if (self.pokemonTeamEvolvable) then
            for i = 1, #self.currentPokemons do
                local evolutions = getPokemonEvolutions(self.currentPokemons[i])
                while (evolutions and #evolutions > 0) do
                    local tmpEvolutions = evolutions
                    evolutions = nil

                    for k, v in ipairs(tmpEvolutions) do
                        if (level >= v.requiredLevel) then
                            self.currentPokemons[i] = v.name
                            evolutions = getPokemonEvolutions(self.currentPokemons[i])
                            break
                        end
                    end
                end
            end
        end
    end

    function NpcBattle:doUpdateCurrentBet(pid)
        self.currentBet = self.baseBet * self:getLevel(pid)
    end

    function NpcBattle:doOrderPokemon(pokemonUid, targetUid, pid)
        local pos = getPositionAdjacent(pokemonUid, getCreaturePosition(targetUid))
        if (pos) then
            if (not getPathToEx(pokemonUid, pos)) then
                doTeleportThing(pokemonUid, getCreaturePosition(targetUid))
                return
            end
            --doCreatureWalkToPosition(pokemonUid, pos)

            if ((os.time() - self.lastOrder) > 4) then
                doCreatureSay(self.uid, string.format(__L(pid, "%s, go there!"), getCreatureNickname(pokemonUid)), TALKTYPE_MONSTER)
                self.lastOrder = os.time()
            end
        end
    end

    -- Global functions
    function NpcBattle:doTalkStart(npcUid, pid)
        self.uid = npcUid
        if (self:isBattleing()) then
            selfSay("I'm battling at the moment, please wait.", pid)
            return TALK_STATE.ERASE

        else
            local result = self:canPlayerBattleWithNpc(pid)
            if (result == true) then
                selfSay(string.format(__L(pid, "Do you really want to battle with me?%s%s {Yes} or {No}"),
                    (self.currentBet > 0 and (string.format(__L(pid, " (You will bet %s dollars)"), self.currentBet)) or ""),
                    (self.payRespect > 0 and (string.format(__L(pid, " (You will pay %s respect points)"), self.payRespect)) or "")), pid)
                return TALK_STATE.ACCEPTING_BATTLE

            else
                selfSay(result, pid)
                return TALK_STATE.ERASE
            end
        end
    end

    function NpcBattle:doTalkEnd(npcUid, pid, talkState)
        self.uid = npcUid
        if (talkState == TALK_STATE.ACCEPTING_BATTLE) then
            if (self:isBattleing()) then
                selfSay("I'm battling at the moment, please wait.", pid)
                return TALK_STATE.ERASE

            elseif (not isPokemonOnline(pid) and #getCreatureSummons(pid) == 0) then
                selfSay(__L(pid, table.random(NPC_DIALOGS.PLAYER_WITHOUT_POKEMON)), pid)
                return TALK_STATE.ERASE

            else
                local result = self:canPlayerBattleWithNpc(pid)
                if (result == true) then
                    self:doBattleStart(pid)
                else
                    selfSay(result, pid)
                    return TALK_STATE.ERASE
                end
            end
        else
            selfSay("Huh?", pid)
        end
        return TALK_STATE.ERASE
    end

    function NpcBattle:doForceBattleStart(npcUid, pid)
        if (self:isBattleing()) then
            return false
        end

        self.uid = npcUid
        self:doBattleStart(pid)
        return true
    end

    function getNpcOpponent(nid)
        return getCreatureStorage(nid, NPC_STORAGES.OPPONENT)
    end

    function getNpcBattleByName(name)
        return NpcsByName[name]
    end

    function getPlayerDefeatedNPC(cid, npcName)
        local r = getCreatureStorage(cid,
            (type(npcName) == 'string' and getNpcBattleByName(npcName).levelStorage or npcName)) -- npcName can be the storage too, because I can normaly call this function only inside NPCs
        return r > 1
    end

    function getPlayerLastDefeatedNpc(cid, lastDefeatTimeStorage)
        return getCreatureStorage(cid, lastDefeatTimeStorage)
    end

    function doPlayerEraseDefeatedNpc(cid, npcName)
        if (type(npcName) ~= 'string') then
            log(LOG_TYPES.ERROR, "npcBattle:doPlayerEraseDefeatedNPC - npcName is not a string.", getCreatureName(cid), npcName)
            return
        end

        doCreatureSetStorage(cid, getNpcBattleByName(npcName).levelStorage, -1)
        doCreatureSetStorage(cid, getNpcBattleByName(npcName).lastBattleTimeStorage, -1)
    end
end