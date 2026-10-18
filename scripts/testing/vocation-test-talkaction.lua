-- TEST ONLY - never part of the game data or any package.
-- scripts/test-server-linux.sh copies this file into a temporary server directory as "/vocationtest"
-- and scripts/vocation-test.py says it. It drives the real vocation code paths for every vocation
-- and prints one "vocationtest: PASS|FAIL <name>" message per check, then
-- "vocationtest: done <passed> passed, <failed> failed". The catch and potion checks finish a few
-- seconds later (the ball throw has a delay).
--
--   /vocationtest <name of a second online trainer>   (the Medic heals that trainer's Pokemon)
--
-- The action and NPC scripts (incubator, health potions, daycare) are loaded into a sandbox so
-- their local functions run unchanged. Loading the potion script there logs "can only be used while
-- loading the script" for its conditions; the Medic checks only use the potion's first heal.

local SCRIPTS = "data/lib/ps/events/actions/"
local CRANE_ITEMID = 3977 -- CRANE1_ITEMID, local to systems/043-fishing.lua
local passed, failed = 0, 0
local tester

local sendText = doPlayerSendTextMessage

local function say(text)
    sendText(tester, MESSAGE_STATUS_CONSOLE_BLUE, "vocationtest: " .. text)
end

local function check(name, ok, detail)
    if (ok) then
        passed = passed + 1
        say("PASS " .. name)
    else
        failed = failed + 1
        say("FAIL " .. name .. (detail and (" (" .. tostring(detail):sub(1, 300) .. ")") or ""))
    end
end

local function sandbox(path, extra, libs)
    local env = setmetatable(extra or {}, { __index = _G })
    for _, file in ipairs(libs or {}) do
        local lib = assert(loadfile(file))
        setfenv(lib, env)
        lib()
    end
    local chunk = assert(loadfile(path))
    setfenv(chunk, env)
    chunk()
    return env
end

local function become(cid, key, rank)
    Vocations.reset(cid)
    if (key) then
        for _, vocation in ipairs(Vocations.LIST) do
            if (vocation.key == key) then
                setPlayerStorageValue(cid, playersStorages.vocation, vocation.id)
            end
        end
        Vocations.setRank(cid, rank or 1)
    end
end

-- Runs fn with Vocations.PERKS[key][perk] replaced by value at every rank
local function withPerk(key, perk, value, fn)
    local old = Vocations.PERKS[key][perk]
    Vocations.PERKS[key][perk] = { value, value, value, value, value }
    local ok, err = pcall(fn)
    Vocations.PERKS[key][perk] = old
    if (not ok) then
        check(key .. "." .. perk .. " ran without errors", false, err)
    end
end

-- Messages (and cancel messages) the code sends to the tester while fn runs
local function captureMessages(fn)
    local messages, original, originalCancel = {}, doPlayerSendTextMessage, doPlayerSendCancel
    doPlayerSendTextMessage = function(cid, kind, text)
        messages[#messages + 1] = text
        return original(cid, kind, text)
    end
    doPlayerSendCancel = function(cid, text)
        messages[#messages + 1] = text
        return originalCancel(cid, text)
    end
    local ok, err = pcall(fn)
    doPlayerSendTextMessage, doPlayerSendCancel = original, originalCancel
    if (not ok) then
        check("no errors while capturing messages", false, err)
    end
    return table.concat(messages, "\n")
end

local function isFree(cid, pos)
    local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = 0 })
    if (not ground or ground.itemid == 0) then
        return false
    end
    local info = getTileInfo(pos)
    return info and not info.protection and not info.house and doTileQueryAdd(cid, pos) == RETURNVALUE_NOERROR
end

-- A free non-protection tile with free tiles around it
local function findArena(cid)
    local origin = getCreaturePosition(cid)
    for radius = 1, 40 do
        for dx = -radius, radius do
            for dy = -radius, radius do
                local p = { x = origin.x + dx, y = origin.y + dy, z = origin.z }
                local all = isFree(cid, p)
                for _, d in ipairs({ { 1, 0 }, { 2, 0 }, { 0, 1 }, { -1, -1 } }) do
                    all = all and isFree(cid, { x = p.x + d[1], y = p.y + d[2], z = p.z })
                end
                if (all) then
                    return p
                end
            end
        end
    end
end

local function newBall(cid, pokemon, level, sex)
    local uid = doCreatePokemonBall(cid, "poke", pokemon, level, sex or POKEMON_SEX_FEMALE, nil, 0, nil, false, nil,
        getExperienceForLevel(level), nil, nil, nil, nil, nil, nil, false, nil, nil, true)
    return getThing(uid)
end

---------------------------------------------------------------------------------------------------

local function testRanks(cid)
    become(cid, nil)
    check("no vocation: rank 0, no perks", Vocations.getRank(cid) == 0 and Vocations.perk(cid, "ace", "battleExp") == nil)

    setPlayerStorageValue(cid, playersStorages.vocationWindow, -1)
    check("choosing needs the window", not Vocations.choose(cid, "catcher") and not Vocations.get(cid))
    local original, opened = doSendPlayerExtendedOpcode, nil
    doSendPlayerExtendedOpcode = function(target, opcode, buffer)
        if (opcode == EXTENDED_IDS.VOCATION) then
            opened = JSON.decode(buffer)
            return true
        end
        return original(target, opcode, buffer)
    end
    local ok, err = pcall(Vocations.onClientMessage, cid, '{"action":"open"}')
    doSendPlayerExtendedOpcode = original
    check("U opens the vocation window", ok and opened and opened.type == "open" and #(opened.vocations or {}) == 6 and
        getPlayerStorageValue(cid, playersStorages.vocationWindow) == 1, err)
    local level = getPlayerLevel(cid)
    if (level < Vocations.MIN_LEVEL) then
        check("below level 20 the window can't choose", not Vocations.choose(cid, "catcher") and not Vocations.get(cid))
        doPlayerAddLevel(cid, Vocations.MIN_LEVEL - level)
    end
    check("choosing works with the window open", Vocations.choose(cid, "catcher") and Vocations.is(cid, "catcher"))
    check("a new vocation starts at rank 1", Vocations.getRank(cid) == 1 and Vocations.getTitle(cid) == "Rookie Catcher")
    setPlayerStorageValue(cid, playersStorages.vocationWindow, 1)
    check("the vocation can't be changed", not Vocations.choose(cid, "medic") and Vocations.is(cid, "catcher"))
    check("look text shows the title",
        (getPlayerSpecialDescription(cid) or ""):find("Catcher, Rookie Catcher %(rank 1%)") ~= nil, getPlayerSpecialDescription(cid))
    check("other vocations' perks don't apply", Vocations.perk(cid, "medic", "healing") == nil)

    for _, vocation in ipairs(Vocations.LIST) do
        become(cid, vocation.key, 5)
        check(vocation.name .. " rank 5 title", Vocations.getTitle(cid) == vocation.titles[5])
    end
    become(cid, "ace", 1)
    check("Ace rank 1: +2% EXP", Vocations.perk(cid, "ace", "battleExp") == 0.02)
    become(cid, "ace", 5)
    check("Ace rank 5: +10% EXP", Vocations.perk(cid, "ace", "battleExp") == 0.10)
    become(cid, "ranger", 1)
    check("Ranger rank 1: no type filter yet", Vocations.perk(cid, "ranger", "typeFilterRank") == nil)
    become(cid, "ranger", 2)
    check("Ranger rank 2: type filter", Vocations.perk(cid, "ranger", "typeFilterRank") == true)

    become(cid, "angler", 5)
    check("no rank above 5", not Vocations.rankUp(cid) and Vocations.getRank(cid) == 5)
    Vocations.reset(cid)
    check("reset clears the vocation", not Vocations.get(cid) and (getPlayerSpecialDescription(cid) or "") == "")
end

-- The vocation messages the code sends while fn runs, decoded
local function captureVocation(fn)
    local sent, original = {}, doSendPlayerExtendedOpcode
    doSendPlayerExtendedOpcode = function(target, opcode, buffer)
        if (opcode == EXTENDED_IDS.VOCATION) then
            sent[#sent + 1] = JSON.decode(buffer)
            return true
        end
        return original(target, opcode, buffer)
    end
    local ok, err = pcall(fn)
    doSendPlayerExtendedOpcode = original
    if (not ok) then
        check("no errors while capturing vocation messages", false, err)
    end
    local last = {}
    for _, data in ipairs(sent) do
        last[data.type] = data
    end
    return last
end

local function goalsOf(trial)
    local list = {}
    for _, goal in ipairs(trial and trial.goals or {}) do
        list[#list + 1] = goal.have .. "/" .. goal.need .. " " .. goal.text
    end
    return table.concat(list, "; ")
end

local function testTrials(cid)
    become(cid, nil)
    local notice = captureVocation(function() Vocations.sendTrial(cid) end).trial
    check("top bar: \"!\" to choose a vocation from level 20", notice and notice.choose == true and
        notice.ready == (getPlayerLevel(cid) >= Vocations.MIN_LEVEL))
    -- a new character has fishing skill 0, and the skill checks below need a level to step back from
    for _ = 1, 20 do
        if (getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING) >= 1) then
            break
        end
        doPlayerAddSkillTry(cid, PLAYER_SKILL_FISHING, 1000, false)
    end
    become(cid, "angler", 1)
    if (getPlayerLevel(cid) < Vocations.RANK_LEVELS[2]) then
        doPlayerAddLevel(cid, Vocations.RANK_LEVELS[2] - getPlayerLevel(cid))
    end
    -- the skill goal at the tester's own fishing skill, so it is done and the other goals decide
    local skillGoal = Vocations.TRIALS.angler[3]
    local oldSkillGoals = skillGoal.goals
    local skill = getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING)
    skillGoal.goals = { math.max(1, skill), 30, 45, 60 }
    local ok, err = pcall(function()
        local trial = Vocations.getTrial(cid)
        local goals = trial and trial.goals or {}
        check("trial: Angler rank 1 has three goals", #goals == 3 and goals[1].text == "Hook 100 Pokemon while fishing" and
            goals[2].text == "Hook 4 different species" and goals[1].have == 0 and goals[2].have == 0 and
            goals[3].have == goals[3].need and trial.have == 1 and trial.need == 3, goalsOf(trial))
        local ok, why = Vocations.canRankUp(cid)
        check("trial: no rank up before the trial", not ok and (why or ""):find("Hook 100") ~= nil, why)
        check("trial: the Rank up action refuses", captureVocation(function()
            Vocations.onClientMessage(cid, '{"action":"rankup"}')
        end).result ~= nil and Vocations.getRank(cid) == 1)

        setPlayerStorageValue(cid, playersStorages.vocationTrial, 7)
        check("trial: the old single count is the first goal's", Vocations.getTrial(cid).goals[1].have == 7)
        Vocations.resetTrial(cid)

        Vocations.addTrial(cid, "ace", "defeat", "Rattata", 10)
        Vocations.addTrial(cid, "angler", "catch", "Magikarp")
        check("trial: other vocations' and other events don't count", Vocations.getTrial(cid).goals[1].have == 0 and
            Vocations.getTrial(cid).goals[2].have == 0)
        local sent = captureVocation(function() Vocations.addTrial(cid, "angler", "hook", "Magikarp", 98) end)
        trial = Vocations.getTrial(cid)
        check("trial: steps count, the species once, and are sent", trial.goals[1].have == 98 and trial.goals[2].have == 1 and
            sent.trial and sent.trial.goals and sent.trial.goals[1].have == 98 and sent.trial.ready == false, goalsOf(trial))
        Vocations.addTrial(cid, "angler", "hook", "Shiny Magikarp")
        Vocations.addTrial(cid, "angler", "hook", "Magikarp")
        trial = Vocations.getTrial(cid)
        check("trial: a species counts once, shiny forms too", trial.goals[2].have == 1 and trial.goals[1].have == 100,
            goalsOf(trial))
        local messages = captureMessages(function() Vocations.addTrial(cid, "angler", "hook", "Poliwag") end)
        check("trial: a finished goal stops counting", Vocations.getTrial(cid).goals[1].have == 100 and
            Vocations.getTrial(cid).goals[2].have == 2)
        check("trial: no goal message before a goal is done", not messages:find("goal done"), messages)
        Vocations.addTrial(cid, "angler", "hook", "Krabby")
        messages = captureMessages(function()
            sent = captureVocation(function() Vocations.addTrial(cid, "angler", "hook", "Shellder") end)
        end)
        trial = Vocations.getTrial(cid)
        check("trial: done once every goal is, ready", trial.have == 3 and trial.need == 3 and sent.trial and
            sent.trial.ready == true and messages:find("Rank%-up trial done") ~= nil, goalsOf(trial) .. " | " .. messages)
        local map = getPlayerStorageValue(cid, playersStorages.vocationTrialSpecies)
        check("trial: the species are kept as a hex bitmap", type(map) == "string" and map:match("^s%x+$") ~= nil and
            #map == 1 + math.ceil(math.max(getPokemonNumberByName("Magikarp"), getPokemonNumberByName("Shellder"),
                getPokemonNumberByName("Krabby"), getPokemonNumberByName("Poliwag")) / 4), tostring(map))

        local data = Vocations.progress(cid)
        local gains = {}
        for _, gain in ipairs(data.next.gains) do
            gains[gain.text] = gain.badge
        end
        check("progress: rank, titles, perks and the next rank", data.key == "angler" and data.rank == 1 and #data.titles == 5 and
            #data.ranks == 5 and #data.perks >= 2 and data.next.rank == 2 and data.next.ready == true and data.next.level == 30 and
            #data.next.trial.goals == 3)
        check("progress: next rank gains", gains["Fishing skill gain"] == "+20%" and gains["See what can bite"] == "New",
            JSON.encode(gains))

        sent = captureVocation(function() Vocations.onClientMessage(cid, '{"action":"rankup"}') end)
        trial = Vocations.getTrial(cid)
        check("trial: Rank up takes rank 2 and starts the next trial", Vocations.getRank(cid) == 2 and
            trial.goals[1].have == 0 and trial.goals[1].need == 300 and trial.goals[2].have == 0 and
            not tostring(getPlayerStorageValue(cid, playersStorages.vocationTrialSpecies)):find("1") and sent.progress and sent.progress.rank == 2,
            goalsOf(trial))

        skillGoal.goals = { 1, skill + 1, 45, 60 }
        messages = captureMessages(function() Vocations.addTrial(cid, "angler", "skill", nil, skill) end)
        check("trial: the skill goal counts the skill itself", Vocations.getTrial(cid).goals[3].have == skill and
            not messages:find("goal done"), messages)
        skillGoal.goals = { 1, skill, 45, 60 }
        messages = captureMessages(function() Vocations.addTrial(cid, "angler", "skill", nil, skill - 1) end)
        check("trial: reaching the skill finishes its goal", messages:find("Rank%-up goal done: Reach fishing skill") ~= nil,
            messages)
    end)
    skillGoal.goals = oldSkillGoals
    check("trial checks ran without errors", ok, err)

    become(cid, "catcher", 1)
    check("trial: Catcher rank 1 has no shiny goal", #Vocations.getTrial(cid).goals == 2, goalsOf(Vocations.getTrial(cid)))
    become(cid, "catcher", 3)
    Vocations.addTrial(cid, "catcher", "catch", "Rattata")
    local trial = Vocations.getTrial(cid)
    check("trial: only shinies count for the shiny goal", #trial.goals == 3 and trial.goals[3].have == 0 and
        trial.goals[1].have == 1, goalsOf(trial))
    Vocations.addTrial(cid, "catcher", "catch", "Shiny Rattata")
    trial = Vocations.getTrial(cid)
    check("trial: a shiny catch counts for all three", trial.goals[1].have == 2 and trial.goals[2].have == 1 and
        trial.goals[3].have == 1, goalsOf(trial))
    local last = getPokemonNameByNumber(POKEMON_NUMBER)
    Vocations.addTrial(cid, "catcher", "catch", last)
    check("trial: the last Pokedex number fits the bitmap", Vocations.getTrial(cid).goals[2].have == 2,
        tostring(last) .. " " .. tostring(getPlayerStorageValue(cid, playersStorages.vocationTrialSpecies)))

    become(cid, "angler", 2)
    local outfit = getCreatureOutfit(cid)
    outfit.lookType = getPlayerSex(cid) == PLAYERSEX_FEMALE and 611 or 612
    doCreatureChangeOutfit(cid, outfit)
    check("progress: not wearing the outfit", Vocations.progress(cid).wearing == false)
    local sent = captureVocation(function() Vocations.onClientMessage(cid, '{"action":"wear"}') end)
    check("wear: puts the vocation outfit on", sent.progress and sent.progress.wearing == true and
        getCreatureOutfit(cid).lookType == Vocations.LIST[5].looks[getPlayerSex(cid) == PLAYERSEX_FEMALE and 1 or 2])

    become(cid, "angler", 5)
    check("progress: no next rank at rank 5", Vocations.progress(cid).next == nil and Vocations.getTrial(cid) == nil)
    become(cid, nil)
end

local function testTrainerCard(cid, friend)
    local sent, original = {}, doSendPlayerExtendedOpcode
    local function capture(fn)
        sent = {}
        doSendPlayerExtendedOpcode = function(target, opcode, buffer)
            if (opcode == EXTENDED_IDS.TRAINER_CARD) then
                sent[#sent + 1] = buffer
                local data = JSON.decode(buffer)
                sent[data.type] = data
                return true
            end
            return original(target, opcode, buffer)
        end
        local ok, err = pcall(fn)
        doSendPlayerExtendedOpcode = original
        if (not ok) then
            check("Trainer Card ran without errors", false, err)
        end
    end
    for _, key in ipairs({ "cardTitle", "cardAbout", "cardFavorite", "cardTrophies", "cardPrivacy" }) do
        setPlayerStorageValue(cid, playersStorages[key], -1)
    end
    become(cid, "catcher", 3)

    capture(function() TrainerCard.onClientMessage(cid, '{"action":"open"}') end)
    local card = sent.card
    check("card: opens your own card", card and card.own == true and card.name == getCreatureName(cid) and card.level == getPlayerLevel(cid))
    check("card: vocation and title", card and card.vocation and card.vocation.key == "catcher" and card.vocation.rank == 3 and
        card.title == Vocations.LIST[2].titles[3], card and card.title)
    local regions, slots, real = {}, 0, 0
    for _, region in ipairs(card and card.badges or {}) do
        regions[#regions + 1] = region.region .. " " .. #region.list
        for _, badge in ipairs(region.list) do
            slots = slots + 1
            real = real + (badge.upcoming and 0 or 1)
        end
    end
    check("card: badges by region, Kanto first, 28 in all and 12 in the game",
        table.concat(regions, ", ") == "Kanto 8, Orange Islands 4, Johto 8, Hoenn 8" and slots == 28 and real == 12,
        table.concat(regions, ", "))
    check("card: the stats", card and card.stats and card.stats.dexTotal == POKEMON_NUMBER)
    check("card: hometown, outfit, play time", card and card.town and card.town.name == getTownName(getPlayerTown(cid)) and
        card.outfit.type == getCreatureOutfit(cid).lookType and card.playTime ~= nil)
    check("card: fits in one message", sent[1] and #sent[1] < 8192, sent[1] and #sent[1])

    local ballA = newBall(cid, "Scyther", 41, POKEMON_SEX_MALE)
    local ballB = newBall(cid, "Gengar", 52, POKEMON_SEX_FEMALE)
    capture(function() TrainerCard.onClientMessage(cid, '{"action":"candidates"}') end)
    local keys = {}
    for _, pokemon in ipairs(sent.candidates and sent.candidates.list or {}) do
        keys[pokemon.key] = pokemon
    end
    check("card: candidates list the party", keys["Scyther|41|1"] and keys["Gengar|52|0"] and keys["Scyther|41|1"].look ~= nil,
        sent[1])

    capture(function()
        TrainerCard.onClientMessage(cid, JSON.encode({ action = "save", favorite = "Scyther|41|1",
            trophies = { "Gengar|52|0", "Scyther|41|1" }, title = "v2", about = "Hello\n\n\n\nfive lines\r\n" .. string.rep("x", 300),
            privacy = 3 }))
    end)
    card = sent.card
    check("card: save keeps the favorite and the trophies", card and card.favorite and card.favorite.key == "Scyther|41|1" and
        #card.trophies == 2 and card.trophies[1].name == "Gengar" and card.trophies[1].sex == "female")
    check("card: an earned title", card and card.titleKey == "v2" and card.title == Vocations.LIST[2].titles[2], card and card.title)
    local about = card and card.about or ""
    check("card: About is cleaned (4 lines, 160 letters)", #about <= 160 and not about:find("\r") and
        select(2, about:gsub("\n", "")) <= 3, about)
    check("card: privacy saved", card and card.privacy == 3)
    check("card: saved message", sent.result and sent.result.ok == true)

    capture(function() TrainerCard.onClientMessage(cid, '{"action":"save","title":"v5"}') end)
    check("card: a title above the rank is refused", sent.result and sent.result.ok == false and
        getPlayerStorageValue(cid, playersStorages.cardTitle) == "v2")
    capture(function() TrainerCard.onClientMessage(cid, '{"action":"save","trophies":["Mew|100|2"]}') end)
    check("card: a Pokemon you don't have is refused", sent.result and sent.result.ok == false and
        #TrainerCard.data(cid, cid).trophies == 2)
    capture(function() TrainerCard.onClientMessage(cid, '{"action":"titles"}') end)
    check("card: titles list the vocation ranks", sent.titles and sent.titles.list[1] and sent.titles.list[1].key == "v3" and
        #sent.titles.list >= 3)

    doRemoveItem(ballB.uid)
    capture(function() TrainerCard.onClientMessage(cid, '{"action":"open"}') end)
    check("card: a trophy you don't have anymore drops off", sent.card and #sent.card.trophies == 1 and
        sent.card.trophies[1].name == "Scyther")

    if (isPlayer(friend)) then
        capture(function() TrainerCard.onClientMessage(friend, JSON.encode({ action = "open", name = getCreatureName(cid) })) end)
        local other = sent.card
        check("card: another trainer sees it, without your settings", other and other.own == false and other.privacy == nil and
            other.favorite and other.favorite.name == "Scyther")
        local hidden = {}
        for _, what in ipairs(other and other.hidden or {}) do
            hidden[what] = true
        end
        check("card: privacy hides play time and statistics", other and other.playTime == nil and other.stats == nil and
            hidden.playTime and hidden.stats and #other.trophies == 1)
        capture(function() TrainerCard.onClientMessage(friend, JSON.encode({ action = "achievements", name = getCreatureName(cid) })) end)
        check("card: achievements tab", sent.achievements and sent.achievements.total > 0)
    else
        check("card: second trainer online", false)
    end
    capture(function() TrainerCard.onClientMessage(cid, '{"action":"open","name":"Nobody Here At All"}') end)
    check("card: offline trainers", sent.result and sent.result.ok == false)

    doRemoveItem(ballA.uid)
    for _, key in ipairs({ "cardTitle", "cardAbout", "cardFavorite", "cardTrophies", "cardPrivacy" }) do
        setPlayerStorageValue(cid, playersStorages[key], -1)
    end
    become(cid, nil)
end

local function testAce(cid)
    local ball = newBall(cid, "Pidgey", 50)
    if (not isItem(ball)) then
        check("Ace: test ball", false, "no ball")
        return
    end
    local function gain()
        local before = getBallPokemonExp(ball.uid)
        doPlayerPokemonAddExperience(cid, nil, 200, true, ball)
        return getBallPokemonExp(ball.uid) - before
    end
    become(cid, nil)
    local base = gain()
    become(cid, "ace", 5)
    local ace = gain()
    become(cid, "ace", 1)
    local ace1 = gain()
    check("Ace rank 5 gets +10% battle EXP", base > 0 and ace == base + math.floor(base * 0.10), base .. " -> " .. ace)
    check("Ace rank 1 gets +2% battle EXP", ace1 == base + math.floor(base * 0.02), base .. " -> " .. ace1)
    become(cid, "ace", 5)
    local before = getBallPokemonExp(ball.uid)
    doPlayerPokemonAddExperience(cid, nil, 200, false, ball)
    check("Ace bonus is only for battle EXP", getBallPokemonExp(ball.uid) - before == 200)
    doRemoveItem(ball.uid)
end

local function testCatcherOdds(cid)
    local function rate(trials, chance)
        local hits = 0
        for _ = 1, trials do
            if (math.random() < chance or Vocations.catchSecondChance(cid, chance)) then
                hits = hits + 1
            end
        end
        return hits / trials
    end
    become(cid, nil)
    check("no second chance without the vocation", not Vocations.catchSecondChance(cid, 0.5))
    become(cid, "catcher", 5)
    local r = rate(200000, 0.2)
    check("Catcher rank 5: a 20% throw catches 22% of the time", r > 0.2155 and r < 0.2245, r)
    become(cid, "catcher", 1)
    r = rate(200000, 0.2)
    check("Catcher rank 1: a 20% throw catches 20.4% of the time", r > 0.1995 and r < 0.2085, r)
end

-- A real kill and throw; fresh trainers always miss (fewer than 25% of the needed tries)
local function throwAt(cid, pos, pokemon, after)
    local m = doCreateMonster(pokemon, pos, false)
    if (not isMonster(m)) then
        check("catch test: monster", false, pokemon)
        return
    end
    doTargetCombatHealth(cid, m, COMBAT_PHYSICALDAMAGE, -10000000, -10000000, CONST_ME_NONE)
    addEvent(function()
        -- its own body: other tests running at the same time leave bodies on these tiles too
        local corpse = getTileItemById(pos, getMonsterInfo(pokemon).lookCorpse)
        if (not isPlayer(cid) or not isItem(corpse)) then
            check("catch test: corpse", false)
            return
        end
        local itemid = balls["ultra"].empty
        local ball = doPlayerAddItem(cid, itemid, 1)
        local count = getPlayerItemCount(cid, itemid)
        emptyBall(cid, { uid = ball, itemid = itemid }, getThingPosition(ball), corpse, pos)
        addEvent(function()
            if (isPlayer(cid)) then
                after(count - getPlayerItemCount(cid, itemid))
            end
        end, 6000)
    end, 500)
end

local function countCaught(cid)
    local n = 0
    for _, b in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        if (getBallPokemonName(b.uid) == "Dragonite") then
            n = n + 1
        end
    end
    return n
end

local function testCatcherThrows(cid, arena)
    local east = { x = arena.x + 1, y = arena.y, z = arena.z }
    local south = { x = arena.x, y = arena.y + 1, z = arena.z }
    become(cid, "catcher", 5)
    Vocations.PERKS.catcher.ballBack = { 1, 1, 1, 1, 1 }
    Vocations.PERKS.catcher.catchChance = { 100, 100, 100, 100, 100 }
    throwAt(cid, east, "Dragonite", function(lost)
        check("Catcher: the failed ball comes back", lost == 0, lost)
        check("Catcher: no catch before 25% of the tries, even with the bonus", countCaught(cid) == 0)
        Vocations.PERKS.catcher.ballBack = { 0.02, 0.04, 0.06, 0.08, 0.10 }
        Vocations.PERKS.catcher.catchChance = { 0.02, 0.04, 0.06, 0.08, 0.10 }
        become(cid, nil)
        throwAt(cid, south, "Dragonite", function(lost2)
            check("regular trainer: the failed ball is lost", lost2 == 1, lost2)
        end)
    end)
end

local function testBreederIncubator(cid)
    local env = sandbox(SCRIPTS .. "eggIncubator/emptyIncubator.lua")
    local function hatchSeconds()
        local incubator = doPlayerAddItem(cid, 14048, 1)
        local egg = doPlayerAddItem(cid, getPokemonEggId("Pidgey"), 1)
        local now = getCurrentTimeInSeconds()
        env.onUse(cid, getThing(incubator), getThingPosition(incubator), getThing(egg), getThingPosition(egg))
        local seconds = (getItemAttribute(incubator, 1000) or 0) - now
        doRemoveItem(incubator)
        return seconds
    end
    become(cid, nil)
    local base = hatchSeconds()
    become(cid, "breeder", 5)
    local fast = hatchSeconds()
    become(cid, "breeder", 1)
    local fast1 = hatchSeconds()
    check("incubator: 60 minutes for everyone", math.abs(base - 3600) <= 1, base)
    check("Breeder rank 5 hatches in 45 minutes", math.abs(fast - 2700) <= 1, fast)
    check("Breeder rank 1 hatches in 57 minutes", math.abs(fast1 - 3420) <= 1, fast1)
end

local function testShinyEvent(cid)
    ShinyEvent.stop()
    check("shiny event: 1 in 8192 without an event", ShinyEvent.chance(8192) == 8192, ShinyEvent.chance(8192))
    ShinyEvent.start(2, 60)
    check("shiny event: /bonusshiny 2x sets the C++ multiplier", getShinyEventMultiplier() == 2, getShinyEventMultiplier())
    check("shiny event: 1 in 4096 at 2x", ShinyEvent.chance(8192) == 4096, ShinyEvent.chance(8192))
    check("shiny event: described", ShinyEvent.describe():find("2x shiny event") ~= nil, ShinyEvent.describe())
    check("shiny event: off cancels it", ShinyEvent.stop() and getShinyEventMultiplier() == 1 and not ShinyEvent.get())
end

local function testAdmin(cid)
    local sent, broadcasts = {}, {}
    local opcode, access, broadcast = doSendPlayerExtendedOpcode, getPlayerAccess, doBroadcastMessage
    local level, largest = 0, 0
    doSendPlayerExtendedOpcode = function(target, id, buffer)
        if (id == EXTENDED_IDS.ADMIN) then
            sent[#sent + 1] = JSON.decode(buffer)
            largest = math.max(largest, #buffer)
        end
        return true
    end
    getPlayerAccess = function(pid) return pid == cid and level or access(pid) end
    doBroadcastMessage = function(text) broadcasts[#broadcasts + 1] = text return true end
    local discord, onBroadcast = {}, DiscordBridge.onBroadcast
    DiscordBridge.onBroadcast = function(source, author, text) discord[#discord + 1] = source .. "|" .. author .. "|" .. text end
    local function contains(list, value)
        for _, v in ipairs(list or {}) do
            if (v == value) then
                return true
            end
        end
        return false
    end
    local function ask(data)
        sent = {}
        Admin.onClientMessage(cid, JSON.encode(data))
        return sent
    end
    local ok, err = pcall(function()
        ShinyEvent.stop()
        check("admin: players get nothing", #ask({ action = "hello" }) == 0 and not Admin.allowed(cid))
        ask({ action = "start", event = "shiny", multiplier = 2, minutes = 30 })
        check("admin: players can't start events", not ShinyEvent.get())

        level = 1
        local tutor = ask({ action = "hello" })[1]
        check("admin: a tutor gets the window without the world settings", tutor and tutor.type == "state" and tutor.access == 1
            and tutor.world == nil)
        ask({ action = "start", event = "shiny", multiplier = 2, minutes = 30 })
        check("admin: a tutor can't start events", not ShinyEvent.get() and sent[1] and sent[1].ok == false)
        local function commandWords()
            local words = {}
            for _, message in ipairs(ask({ action = "commands" })) do
                for _, entry in ipairs(message.commands or {}) do
                    words[entry.words] = entry
                end
            end
            return words
        end
        local words = commandWords()
        check("admin: a tutor's command list has /chatban but not /kick", words["/chatban"] ~= nil and words["/kick"] == nil)
        local talked = {}
        local execute = doCreatureExecuteTalkAction
        doCreatureExecuteTalkAction = function(pid, text) talked[#talked + 1] = text return true end
        ask({ action = "command", text = "/kick Vocation Friend" })
        check("admin: a tutor can't run /kick from the window", #talked == 0 and sent[1] and sent[1].ok == false
            and sent[1].text:find("access 3") ~= nil, sent[1] and sent[1].text)
        ask({ action = "ban", name = "Vocation Friend", days = 1, reason = 5 })
        check("admin: a tutor can't ban", sent[1] and sent[1].ok == false and sent[1].text:find("Bans need") ~= nil)
        local list = ask({ action = "players", filter = "vocation t" })[1]
        check("admin: the player search finds the tester", list and list.type == "players" and list.total == 1
            and list.players[1].name == getCreatureName(cid) and #(list.towns or {}) > 0, list and list.total)
        list = ask({ action = "players", filter = "zzzz" })[1]
        check("admin: the player search can find nobody", list and list.total == 0 and #list.players == 0)

        level = Admin.ACCESS
        words = commandWords()
        check("admin: God's command list has /kick with its usage", words["/kick"] and words["/kick"].group == "Players"
            and words["/kick"].usage == "/kick <player>" and words["/reload"] ~= nil)
        ask({ action = "command", text = "  /goto Vocation Friend " })
        check("admin: the window runs a command as typed", talked[#talked] == "/goto Vocation Friend" and sent[1].ok == true,
            talked[#talked])
        ask({ action = "command", text = "/nosuchcommand" })
        check("admin: an unknown command is refused", #talked == 1 and sent[1].ok == false)
        ask({ action = "save" })
        check("admin: Save server runs /save", talked[#talked] == "/save")
        doCreatureExecuteTalkAction = execute
        ask({ action = "command", text = "/online" })
        check("admin: a real command runs", sent[1] and sent[1].ok == true, sent[1] and sent[1].text)

        local banned, removed = {}, {}
        local addBan, isBanned, remove, logout = doAddAccountBanishment, isAccountBanished, doRemoveCreature, doSetDiscordLogoutReason
        doAddAccountBanishment = function(...) banned[#banned + 1] = { ... } return true end
        isAccountBanished = function() return false end
        doRemoveCreature = function(pid) removed[#removed + 1] = pid return true end
        doSetDiscordLogoutReason = function() return true end
        local banOk, banErr = pcall(function()
            local friend = getPlayerByName("Vocation Friend")
            ask({ action = "ban", name = "Vocation Friend", days = 7, reason = 5, comment = "  spam  " })
            local args = banned[1] or {}
            check("admin: Ban bans the account for 7 days", friend and args[1] == getPlayerAccountId(friend)
                and args[2] == getPlayerGUID(friend) and math.abs(args[3] - os.time() - 7 * 86400) <= 1 and args[4] == 5
                and args[5] == ACTION_BANISHMENT and args[6] == "spam" and args[7] == getPlayerGUID(cid), tostring(args[3]))
            check("admin: the banned player is disconnected", removed[1] == friend and sent[1] and sent[1].ok == true
                and sent[2] and sent[2].type == "bans")
            ask({ action = "ban", name = "Vocation Friend", days = 0, reason = 12 })
            check("admin: a ban for good is a deletion", banned[2] and banned[2][3] == -1 and banned[2][5] == ACTION_DELETION)
            ask({ action = "ban", name = "Vocation Friend", days = 2, reason = 5 })
            check("admin: odd ban lengths are refused", #banned == 2 and sent[1].ok == false)
            ask({ action = "ban", name = "Vocation Friend", days = 1, reason = 99 })
            check("admin: odd ban reasons are refused", #banned == 2 and sent[1].ok == false)
            ask({ action = "ban", name = getCreatureName(cid), days = 1, reason = 5 })
            check("admin: staff can't ban their own rank", #banned == 2 and sent[1].ok == false)
            ask({ action = "ban", name = "Nobody Called This", days = 1, reason = 5 })
            check("admin: banning an unknown name is refused", #banned == 2 and sent[1].ok == false)
        end)
        doAddAccountBanishment, isAccountBanished, doRemoveCreature, doSetDiscordLogoutReason = addBan, isBanned, remove, logout
        if (not banOk) then
            error(banErr)
        end
        local bans = ask({ action = "bans" })[1]
        check("admin: the window lists the banned accounts", bans and bans.type == "bans" and type(bans.bans) == "table")
        check("admin: every message fits in 8 KB", largest < 8000, largest)
        local state = ask({ action = "hello" })[1]
        check("admin: staff get the four events", state and state.type == "state" and #(state.events or {}) == 4)
        check("admin: God gets the world settings", state.world and #(state.world.kinds or {}) == 9
            and #(state.world.legendaries or {}) > 0 and #(state.world.holidays or {}) > 0)
        ask({ action = "start", event = "shiny", multiplier = 7, minutes = 30 })
        check("admin: odd multipliers are refused", not ShinyEvent.get() and sent[1] and sent[1].ok == false)
        ask({ action = "start", event = "shiny", multiplier = 2, minutes = 30 })
        local multiplier, endsAt = ShinyEvent.get()
        check("admin: Start runs the shiny event", multiplier == 2 and math.abs(endsAt - os.time() - 1800) <= 1, multiplier)
        check("admin: the window shows it running", sent[2] and sent[2].events[2].multiplier == 2)
        ask({ action = "stop", event = "shiny" })
        check("admin: Stop cancels it", not ShinyEvent.get() and getShinyEventMultiplier() == 1)
        check("admin: the window offers 10x and 7 days", contains(state.multipliers, 10) and contains(state.minutes, 10080))
        ask({ action = "start", event = "shiny", multiplier = 10, minutes = 10080 })
        multiplier, endsAt = ShinyEvent.get()
        check("admin: Start runs 10x for 7 days", multiplier == 10 and math.abs(endsAt - os.time() - 604800) <= 1, multiplier)
        ShinyEvent.stop()
        ask({ action = "broadcast", text = "  Hello trainers  " })
        check("admin: broadcast is sent with the staff name", broadcasts[#broadcasts] == getCreatureName(cid) .. ": Hello trainers",
            broadcasts[#broadcasts])
        check("admin: broadcast goes to Discord too by default", discord[#discord] == "gm|" .. getCreatureName(cid) .. "|Hello trainers",
            discord[#discord])
        local before, toDiscord = #broadcasts, #discord
        ask({ action = "broadcast", text = "Game only", target = "game" })
        check("admin: an in-game broadcast skips Discord", #broadcasts == before + 1 and #discord == toDiscord)
        ask({ action = "broadcast", text = "Discord only", target = "discord" })
        check("admin: a Discord broadcast skips the game", #broadcasts == before + 1 and discord[#discord] == "gm|" ..
            getCreatureName(cid) .. "|Discord only", discord[#discord])
        ask({ action = "broadcast", text = "Nowhere", target = "moon" })
        check("admin: an unknown broadcast target is refused", sent[1] and sent[1].ok == false and #broadcasts == before + 1
            and #discord == toDiscord + 1)
    end)
    doSendPlayerExtendedOpcode, getPlayerAccess, doBroadcastMessage = opcode, access, broadcast
    DiscordBridge.onBroadcast = onBroadcast
    ShinyEvent.stop()
    if (not ok) then
        error(err)
    end
end

local function testQuests(cid)
    local sent = {}
    local opcode = doSendPlayerExtendedOpcode
    doSendPlayerExtendedOpcode = function(target, id, buffer)
        if (id == EXTENDED_IDS.QUEST) then
            sent[#sent + 1] = buffer
        end
        return true
    end
    -- the fragments of each message joined back, as the client does
    local function messages()
        local list, pieces = {}, {}
        for _, buffer in ipairs(sent) do
            local id, index, count, piece = buffer:match("^#(%d+):(%d+):(%d+):(.*)$")
            if (id) then
                pieces[id] = pieces[id] or {}
                pieces[id][tonumber(index)] = piece
                if (#pieces[id] == tonumber(count)) then
                    list[#list + 1] = JSON.decode(table.concat(pieces[id]))
                end
            else
                list[#list + 1] = JSON.decode(buffer)
            end
        end
        sent = {}
        return list
    end
    local first = getNpcQuests("Assistant Guyli")[1]
    local defeat
    for _, quests in pairs(getAllNpcQuests()) do
        for _, quest in ipairs(quests) do
            if (not defeat and quest.questType == 3 and quest.counterStorage and quest.questRequest[2] >= 20) then
                defeat = quest
            end
        end
    end
    local saved = { [first.storage] = getCreatureStorage(cid, first.storage),
                    [defeat.storage] = getCreatureStorage(cid, defeat.storage),
                    [defeat.counterStorage] = getCreatureStorage(cid, defeat.counterStorage),
                    [playersStorages.questClient] = getCreatureStorage(cid, playersStorages.questClient) }
    local ok, err = pcall(function()
        local entry = Quests.getEntry(first.storage)
        check("quests: the catalog has the NPCs' quests", Quests.getEntry(defeat.storage) ~= nil and entry ~= nil)
        check("quests: names come from quests.xml", entry.name == "Kanto Main #01 - A new mystery!" and entry.step == "Part 1 of 5" and
            entry.category == "Main story", tostring(entry.name) .. " / " .. tostring(entry.step))
        check("quests: braces are left out", not tostring(entry.text):find("[{}]"), entry.text)
        check("quests: defeat objective", Quests.objective(defeat):find("^Defeat %d+ ") ~= nil, Quests.objective(defeat))

        doCreatureSetStorage(cid, first.storage, QUEST_STATUS.STARTED)
        check("quests: a started quest is active", Quests.stateOf(cid, first, first) == "active")
        doCreatureSetStorage(cid, first.storage, QUEST_STATUS.FINISHED)
        check("quests: a finished quest is done", Quests.stateOf(cid, first, nil) == "done")
        doCreatureSetStorage(cid, first.storage, QUEST_STATUS.UNSTARTED)
        check("quests: an offered quest is available", Quests.stateOf(cid, first, first) == "available" and
            getNpcCurrentQuest(cid, "Assistant Guyli") == first)

        Quests.onLogin(cid)
        check("quests: old clients keep the chat lines", not Quests.onProgress(cid, defeat, 1, 30) and #sent == 0)
        doCreatureSetStorage(cid, defeat.storage, QUEST_STATUS.STARTED)
        Quests.onClientMessage(cid, JSON.encode({ action = "hello" }))
        local hello = messages()
        local active = hello[1] and hello[1].type == "active" and hello[1].quests or {}
        check("quests: hello sends the active quests", #active >= 1 and active[#active].state == "active", #active)
        check("quests: hello sends the NPC marks", hello[2] and hello[2].type == "marks" and
            hello[2].npcs["Assistant Guyli"] == "available")

        local need, shown = defeat.questRequest[2], {}
        for count = 1, need do
            if (Quests.onProgress(cid, defeat, count, need)) then
                for _, message in ipairs(messages()) do
                    if (message.type == "notice") then
                        shown[#shown + 1] = message.kind == "ready" and "ready" or message.have
                    end
                end
            end
        end
        local step = need / 10
        local expected = {}
        for count = 1, need - 1 do
            if (count >= need - 3 or math.floor(count / step) > math.floor((count - 1) / step)) then
                expected[#expected + 1] = count
            end
        end
        expected[#expected + 1] = "ready"
        check("quests: progress at every tenth and the last three", table.concat(shown, ",") == table.concat(expected, ","),
            table.concat(shown, ","))

        Quests.onClientMessage(cid, JSON.encode({ action = "list" }))
        local list = messages()
        local rows = list[1] and list[1].type == "list" and list[1].quests or {}
        local found
        for _, row in ipairs(rows) do
            if (row.id == defeat.storage) then
                found = row
            end
        end
        check("quests: the list has the quest under way with its progress", found and found.state == "active" and
            found.need == need, found and found.state)
        check("quests: the list is split into fragments", #rows > 20 and list[2] and list[2].type == "marks", #rows)

        local hidden, story
        for _, row in ipairs(rows) do
            hidden = hidden or (row.hidden and row)
            story = story or (row.id == first.storage and row)
        end
        check("quests: the story always shows", story and not story.hidden and story.name ~= nil)
        check("quests: an unmet NPC's quest is ???", hidden and hidden.name == nil and hidden.npc == nil and
            hidden.rewards == nil and hidden.place and hidden.place.x == nil and hidden.category ~= "Main story",
            hidden and JSON.encode(hidden))
        if (hidden) then
            local npc = Quests.getEntry(hidden.id).npc
            saved[Quests.metKey(npc)] = getCreatureStorage(cid, Quests.metKey(npc))
            Quests.onMeet(cid, npc)
            local met = messages()
            check("quests: meeting the NPC tells the client", met[1] and met[1].type == "found" and met[1].npc == npc)
            Quests.onClientMessage(cid, JSON.encode({ action = "list" }))
            local again
            for _, row in ipairs((messages()[1] or {}).quests or {}) do
                again = again or (row.id == hidden.id and row)
            end
            check("quests: then its quests show in full", again and not again.hidden and again.npc == npc, again and JSON.encode(again))
            Quests.onMeet(cid, npc)
            check("quests: meeting again sends nothing", #messages() == 0)
        end
    end)
    doSendPlayerExtendedOpcode = opcode
    for storage, value in pairs(saved) do
        doCreatureSetStorage(cid, storage, value)
    end
    if (not ok) then
        error(err)
    end
end

local function testExpItems(cid)
    local LUCKY_EGG, EXP_SHARE = 30152, 30153
    local function gain(ball, amount)
        local before = getBallPokemonExp(ball.uid)
        doPlayerPokemonAddExperience(cid, nil, amount, true, ball)
        return getBallPokemonExp(ball.uid) - before
    end
    local created = {}
    local function holding(itemId)
        local ball = newBall(cid, "Pidgey", 30)
        created[#created + 1] = ball
        if (itemId) then
            PokemonHeldItem.give(cid, ball.uid, getThing(doPlayerAddItem(cid, itemId, 1)))
        end
        return ball
    end
    -- the test balls can't go to the depot: a full bag leaves no room for the next one
    local function drop(...)
        for _, ball in ipairs({ ... }) do
            doRemoveItem(ball.uid)
            for i, made in ipairs(created) do
                if (made == ball) then table.remove(created, i) break end
            end
        end
    end
    local function probe(amount)
        local ball = holding()
        local gained = gain(ball, amount)
        drop(ball)
        return gained
    end
    become(cid, nil)

    local plain, egg = holding(), holding(LUCKY_EGG)
    local base, lucky = gain(plain, 200), gain(egg, 200)
    check("Lucky Egg: +50% battle EXP", base > 0 and math.abs(lucky - base * 1.5) <= 1, base .. " -> " .. lucky)
    check("Lucky Egg: held item name and description", PokemonHeldItem.getHeldName(HELD_IDS.LUCKY_EGG) == "Lucky Egg" and
        PokemonHeldItem.getBallDescription(egg.uid) == "Lucky Egg (+50% experience from wild Pokemon)",
        PokemonHeldItem.getBallDescription(egg.uid))
    local before = getBallPokemonExp(egg.uid)
    doPlayerPokemonAddExperience(cid, nil, 200, false, egg)
    check("Lucky Egg: only battle EXP", getBallPokemonExp(egg.uid) - before == 200)
    drop(plain, egg)

    local half, full = probe(50), probe(100)
    local earner, a, b, fainted, other = holding(EXP_SHARE), holding(EXP_SHARE), holding(EXP_SHARE), holding(EXP_SHARE), holding()
    setBallPokemonLastHp(fainted.uid, 0)
    local belt = { earner, a, b, fainted, other }
    local exp = {}
    for _, ball in ipairs(belt) do
        exp[ball.uid] = getBallPokemonExp(ball.uid)
    end
    local realBelt, realItems = getPlayerBelt, getContainerItems
    getPlayerBelt = function() return 1 end
    getContainerItems = function() return belt end
    local ok, holders = pcall(PokemonHeldItem.shareExperience, cid, 200, earner.uid)
    local function gained(ball) return getBallPokemonExp(ball.uid) - exp[ball.uid] end
    check("Exp Share: two holders on the belt split the 50% pool", ok and holders == 2 and gained(a) == half and
        gained(b) == half and half > 0, tostring(holders) .. " " .. gained(a) .. "/" .. half)
    check("Exp Share: nothing for the earner, a fainted holder or a Pokemon without one",
        gained(earner) == 0 and gained(fainted) == 0 and gained(other) == 0)
    belt = { earner, a, other }
    exp[a.uid] = getBallPokemonExp(a.uid)
    ok, holders = pcall(PokemonHeldItem.shareExperience, cid, 200, earner.uid)
    check("Exp Share: a single holder gets the whole 50%", ok and holders == 1 and gained(a) == full, gained(a) .. "/" .. full)
    getPlayerBelt, getContainerItems = realBelt, realItems

    for _, ball in ipairs(created) do
        doRemoveItem(ball.uid)
    end
end

local function testHeldItems(cid)
    local CHARCOAL, DRAGON_FANG = 23515, 23516
    local ball = newBall(cid, "Pidgey", 30)
    local charcoal = getThing(doPlayerAddItem(cid, CHARCOAL, 1))
    local fang = getThing(doPlayerAddItem(cid, DRAGON_FANG, 1))
    local before = getPlayerItemCount(cid, CHARCOAL)

    local name = PokemonHeldItem.give(cid, ball.uid, charcoal)
    check("held: giving Charcoal", name == "Charcoal" and getBallHeld(ball.uid) == HELD_IDS.CHARCOAL and
        getPlayerItemCount(cid, CHARCOAL) == before - 1, name)
    name = PokemonHeldItem.give(cid, ball.uid, fang)
    check("held: giving Dragon Fang swaps the Charcoal back", name == "Dragon Fang" and
        getBallHeld(ball.uid) == HELD_IDS.DRAGON_FANG and getPlayerItemCount(cid, CHARCOAL) == before, name)
    local _, err = PokemonHeldItem.give(cid, ball.uid, getThing(doPlayerAddItem(cid, 2148, 1)))
    check("held: only held items can be given", err == "Only held items can be given to a Pokemon.", err)
    local fangs = getPlayerItemCount(cid, DRAGON_FANG)
    name = PokemonHeldItem.take(cid, ball.uid)
    check("held: taking it back", name == "Dragon Fang" and not getBallHeld(ball.uid) and
        getPlayerItemCount(cid, DRAGON_FANG) == fangs + 1, name)
    _, err = PokemonHeldItem.take(cid, ball.uid)
    check("held: nothing to take", err == "This Pokemon isn't holding an item.", err)

    local POLKADOT_BOW = 23525
    PokemonHeldItem.give(cid, ball.uid, getThing(doPlayerAddItem(cid, POLKADOT_BOW, 1)))
    local setModifier, setType = setPokemonHeldMovePowerModifier, setPokemonHeldMovePowerType
    local modifier, types = nil, {}
    setPokemonHeldMovePowerModifier = function(_, v) modifier = v end
    setPokemonHeldMovePowerType = function(_, v, slot) types[slot] = v end
    local applied = pcall(PokemonHeldItem.onPokemonCall, cid, ball)
    setPokemonHeldMovePowerModifier, setPokemonHeldMovePowerType = setModifier, setType
    check("held: Polkadot Bow boosts Normal moves by 10%", applied and modifier == 10 and types[1] == ELEMENT_NORMAL and
        types[2] == EMPTY_STORAGE, tostring(modifier))
    check("held: Polkadot Bow description", PokemonHeldItem.getBallDescription(ball.uid) == "Polkadot Bow: Normal moves +10%",
        PokemonHeldItem.getBallDescription(ball.uid))
    PokemonHeldItem.take(cid, ball.uid)
    doPlayerRemoveItem(cid, POLKADOT_BOW, 1)

    doPlayerRemoveItem(cid, CHARCOAL, 1)
    doPlayerRemoveItem(cid, DRAGON_FANG, 1)
    doPlayerRemoveItem(cid, 2148, 1)
    doRemoveItem(ball.uid)
    testExpItems(cid)
end

local function testDaycare(cid)
    local said = {}
    local callbacks = {}
    local handler = {
        setCallback = function(_, id, fn) callbacks[id] = fn end,
        addModule = function() end,
        isFocused = function() return true end,
        isInRange = function() return true end,
    }
    local env = sandbox("data/npc/scripts/daycareFemale.lua", {
        KeywordHandler = { new = function() return {} end },
        NpcHandler = { new = function() return handler end },
        NpcSystem = { parseParameters = function() end },
        FocusModule = { new = function() return {} end },
        selfSay = function(text) said[#said + 1] = text end,
        CALLBACK_GREET = 5,
        CALLBACK_MESSAGE_DEFAULT = 7,
    }, { "data/npc/lib/npc.lua" })
    local function talk(text)
        said = {}
        callbacks[env.CALLBACK_MESSAGE_DEFAULT](cid, TALKTYPE_SAY, text)
        return table.concat(said, " ")
    end
    local guid = getPlayerGUID(cid)
    setPlayerStorageValue(cid, playersStorages.daycareEgg, -1)
    setPlayerStorageValue(cid, playersStorages.daycareClient, -1)
    said = {}
    check("daycare: greeting runs for clients without the window",
        callbacks[env.CALLBACK_GREET] and callbacks[env.CALLBACK_GREET](cid) == true and #said == 0, table.concat(said, " "))
    local eggId = getPokemonEggId("Pidgey")
    -- the fee money left from earlier runs fills the bag, and an egg that doesn't fit drops on the floor
    doPlayerRemoveMoney(cid, getPlayerMoney(cid))
    db.executeQuery("DELETE FROM daycare_female WHERE player_id = " .. guid)
    db.executeQuery("DELETE FROM daycare_male WHERE player_id = " .. guid)
    db.executeQuery("INSERT INTO daycare_male (player_id, date, max_training_minutes, pokemon_name, pokemon_level) VALUES (" ..
        guid .. ", " .. (os.time() - 3 * 86400) .. ", 2880, 'Pidgey', 30)")

    -- One daycare visit: leave a female Pidgey, two days of training, then take it out
    local function visit(name, daysSinceEgg, statusCheck)
        db.executeQuery("UPDATE players SET lasteggtime = " .. (os.time() - daysSinceEgg * 86400 - 60) .. " WHERE id = " .. guid)
        local ball = newBall(cid, "Pidgey", 30, POKEMON_SEX_FEMALE)
        doPlayerAddMoney(cid, 100)
        talk("leave")
        talk("pidgey")
        talk("1440")
        local left = talk("yes")
        if (not left:find("will be fine here")) then
            check(name .. ": leave the Pokemon", false, left)
            return nil
        end
        db.executeQuery("UPDATE daycare_female SET date = date - 2 * 86400 WHERE player_id = " .. guid)
        if (statusCheck) then
            statusCheck(talk("status"))
        end
        doPlayerAddMoney(cid, 5000)
        local eggs = getPlayerItemCount(cid, eggId)
        talk("withdraw")
        local out = talk("yes")
        for _, b in ipairs(getPlayerAllBallsWithPokemon(cid)) do
            if (getBallPokemonName(b.uid) == "Pidgey") then
                doRemoveItem(b.uid)
            end
        end
        local got = getPlayerItemCount(cid, eggId) - eggs
        doPlayerRemoveItem(cid, eggId, got)
        if (not out:find("Thank you for using our services")) then
            check(name .. ": withdraw", false, out)
        end
        return got
    end

    doPlayerAddPremiumDays(cid, 30)
    become(cid, nil)
    check("daycare: no egg in the first 7 days", visit("day 3", 3, function(status)
        check("daycare: status explains the wait", status:find("on day 14 it is certain") ~= nil, status)
    end) == 0)
    check("daycare: the egg is certain on day 14", visit("day 14", 14) == 1)
    become(cid, "breeder", 3)
    withPerk("breeder", "earlyEgg", 1, function()
        withPerk("breeder", "secondEgg", 0, function()
            check("daycare: Breeder's early egg roll (forced to 100%) gives an egg on day 8", visit("day 8", 8, function(status)
                check("daycare: status shows the egg rolled on day 8", status:find("An {egg} is waiting") ~= nil, status)
            end) == 1)
        end)
        withPerk("breeder", "secondEgg", 1, function()
            check("daycare: Breeder's second egg (forced to 100%)", visit("second egg", 14) == 2)
        end)
    end)
    withPerk("breeder", "earlyEgg", 0, function()
        check("daycare: early rolls (forced to 0%) give no egg on day 10", visit("day 10", 10) == 0)
        check("daycare: rolls are remembered up to today",
            getPlayerStorageValue(cid, playersStorages.eggRollDay) == 10, getPlayerStorageValue(cid, playersStorages.eggRollDay))
    end)
    db.executeQuery("DELETE FROM daycare_male WHERE player_id = " .. guid)
    db.executeQuery("UPDATE players SET lasteggtime = 0 WHERE id = " .. guid)
    doPlayerRemoveMoney(cid, getPlayerMoney(cid))
end

-- Runs fn as if the tester played without the PokeVerse client (the radar answers in text there;
-- this test client counts as OTClient)
local function asTextClient(fn)
    local original = getPlayerUsingOtClient
    getPlayerUsingOtClient = function() return false end
    local ok, result = pcall(fn)
    getPlayerUsingOtClient = original
    if (not ok) then
        check("no errors in the text radar", false, result)
    end
    return result
end

-- The radar's eight directions, worked out independently of Vocations
local function compass(from, to)
    local dx, dy = to.x - from.x, to.y - from.y
    local ns = (dy < 0 and math.abs(dy) * 2.414 >= math.abs(dx)) and "north" or
        ((dy > 0 and math.abs(dy) * 2.414 >= math.abs(dx)) and "south" or "")
    local ew = (dx > 0 and math.abs(dx) * 2.414 >= math.abs(dy)) and "east" or
        ((dx < 0 and math.abs(dx) * 2.414 >= math.abs(dy)) and "west" or "")
    return (ns ~= "" and ew ~= "") and (ns .. "-" .. ew) or (ns .. ew)
end

local function testRanger(cid, arena)
    local made = {}
    local tried, free, results = 0, 0, {}
    -- On the first free tile within 6 tiles of the wanted offset (the checks use where it landed). The far
    -- offsets come first; the near ones are for test spots on small upper floors, where the far ones are void.
    local function spawnAt(name, dx, dy)
        for radius = 0, 6 do
            for ox = -radius, radius do
                for oy = -radius, radius do
                    local p = { x = arena.x + dx + ox, y = arena.y + dy + oy, z = arena.z }
                    local ring = (math.abs(ox) == radius or math.abs(oy) == radius) and (p.x ~= arena.x or p.y ~= arena.y)
                    if (ring) then tried = tried + 1 end
                    if (ring and isFree(cid, p)) then
                        free = free + 1
                        local m = doCreateMonster(name, p, false)
                        local r = tostring(m) .. (isCreature(m) and ":creature" or "")
                        results[r] = (results[r] or 0) + 1
                        if (isMonster(m)) then
                            -- the checks compare directions and distances, so the Pokemon stay put
                            doCreatureSetNoMove(m, true)
                            made[#made + 1] = m
                            return m
                        end
                    end
                end
            end
        end
    end
    local function spawn(name, ...)
        tried, free, results = 0, 0, {}
        local offsets = { ... }
        for i = 1, #offsets, 2 do
            local m = spawnAt(name, offsets[i], offsets[i + 1])
            if (m) then
                return m
            end
        end
        local seen = {}
        for r, n in pairs(results) do seen[#seen + 1] = r .. " x" .. n end
        check("radar test: room for " .. name, false, string.format("arena %d,%d,%d; %d tiles tried, %d free; results %s",
            arena.x, arena.y, arena.z, tried, free, table.concat(seen, " ", 1, math.min(#seen, 8))))
    end
    local function where(m)
        local from = getCreaturePosition(cid)
        local to = getCreaturePosition(m)
        local distance = getDistanceBetween(from, to)
        return compass(from, to), distance, distance <= 30 and "near" or (distance <= 100 and "far" or "very far")
    end
    become(cid, "ranger", 5)
    local before = Vocations.scan(cid, 30)
    local pidgey = spawn("Pidgey", 6, 0, -6, 0, 0, 6, 0, -6)
    local shiny = spawn("Shiny Rattata", 0, 8, 0, -8, 8, 0, -8, 0, 8, 8, -8, -8)
    local articuno = spawn("Articuno", -12, -12, 12, 12, -12, 12, 12, -12, 0, -16, 16, 0, 0, 16, -16, 0, 0, 10, 10, 0, -10, 0, 0, -10, 6, 6, -6, -6, 6, -6, -6, 6)
    if (not (pidgey and shiny and articuno)) then
        for _, m in ipairs(made) do
            if (isCreature(m)) then
                doRemoveCreature(m)
            end
        end
        return
    end
    local found = Vocations.scan(cid, 30)
    check("radar finds the regular Pokemon", #found.regular == #before.regular + 1, #found.regular)
    check("radar sorts shinies apart", #found.shiny == #before.shiny + 1)
    check("radar sorts legendaries apart", #found.legendary == #before.legendary + 1)
    local fire = Vocations.scan(cid, 30, ELEMENT_FIRE)
    check("radar type filter", #fire.regular <= #before.regular)
    local entry
    for _, e in ipairs(found.regular) do
        if (e.name == "Pidgey" and isCreature(pidgey) and e.distance == getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(pidgey))) then
            entry = e
        end
    end
    check("radar gives the direction", entry ~= nil and entry.direction == (where(pidgey)), entry and entry.direction)
    local near = Vocations.scan(cid, 3)
    check("radar range limit", #near.regular < #found.regular)

    become(cid, "ranger", 1)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    local text = captureMessages(function() asTextClient(function() return Vocations.radar(cid, "") end) end)
    check("rank 1 radar counts Pokemon", text:find("wild Pokemon within 30 tiles") ~= nil, text)
    check("rank 1 radar hides the shiny and the legendary", not text:find("shiny") and not text:find("Articuno"))
    check("radar cooldown", not asTextClient(function() return Vocations.radar(cid, "") end))
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    check("rank 1 can't filter by type", not asTextClient(function() return Vocations.radar(cid, "normal") end))

    become(cid, "ranger", 3)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    text = captureMessages(function() asTextClient(function() return Vocations.radar(cid, "") end) end)
    local pidgeyDirection, pidgeyDistance = where(pidgey)
    check("rank 3 radar names species and direction",
        -- a wild Pidgey nearby joins the test one's group ("Pidgey x2 (...)"); the nearest gives the direction
        text:find("Pidgey[ x%d]* %(" .. pidgeyDirection:gsub("%-", "%%-") .. ", " .. pidgeyDistance .. " tiles%)") ~= nil, text)
    check("rank 3 radar still hides the shiny", not text:find("shiny Rattata"))

    become(cid, "ranger", 4)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    text = captureMessages(function() asTextClient(function() return Vocations.radar(cid, "flying") end) end)
    check("radar type filter keeps Pidgey (Flying)", text:find("Pidgey") ~= nil, text)
    check("radar type filter drops the shiny Rattata (Normal)", not text:find("Rattata"), text)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    text = captureMessages(function() asTextClient(function() return Vocations.radar(cid, "") end) end)
    local shinyDirection, _, shinyBand = where(shiny)
    check("rank 4 radar finds the shiny", text:find("shiny Rattata, " .. shinyBand .. " to the " .. shinyDirection, 1, true) ~= nil, text)
    check("rank 4 radar hides the legendary", not text:find("Articuno"))

    become(cid, "ranger", 5)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    setPlayerStorageValue(cid, playersStorages.vocationLegendaryAt, 0)
    text = captureMessages(function() asTextClient(function() return Vocations.radar(cid, "") end) end)
    local legendDirection, _, legendBand = where(articuno)
    check("rank 5 radar finds the legendary",
        text:find("something rare, " .. legendBand .. " to the " .. legendDirection .. ": Articuno", 1, true) ~= nil, text)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    text = captureMessages(function() asTextClient(function() return Vocations.radar(cid, "") end) end)
    check("legendary scans have their own cooldown", not text:find("Articuno"), text)

    -- the popup's scan (the JSON for the PokeVerse client)
    local pikachu = spawn("Pikachu", -6, 0, 0, -6, 6, 6)
    local function blipOf(data, m)
        for _, b in ipairs(data.blips) do
            if (b.id == m) then
                return b
            end
        end
    end
    local function onGrid(b, center, grid)
        return b ~= nil and (b.x - center.x) % grid == 0 and (b.y - center.y) % grid == 0
    end
    become(cid, nil)
    check("popup: no radar for other trainers", Vocations.radarState(cid).enabled == false)
    become(cid, "ranger", 1)
    local state = Vocations.radarState(cid)
    check("popup: status for a Ranger", state.enabled and state.rank == 1 and state.range == 30 and
        state.unlocks.type == 2 and state.unlocks.species == 3 and state.unlocks.shiny == 4 and state.unlocks.legendary == 5)
    local data = Vocations.radarScan(cid)
    local b = blipOf(data, pidgey)
    check("popup rank 1: a blip without name, look or types", b and b.kind == "unknown" and not b.name and not b.look and
        not b.types and not b.exact, b and JSON.encode(b))
    check("popup rank 1: blips snapped to 5 tiles", onGrid(b, data.center, 5), b and JSON.encode(b))
    check("popup rank 1: no shiny or legendary", not blipOf(data, shiny) and not blipOf(data, articuno))
    become(cid, "ranger", 2)
    data = Vocations.radarScan(cid)
    b = blipOf(data, pidgey)
    check("popup rank 2: types, blips snapped to 3 tiles", b and b.types and table.concat(b.types, ","):find("flying") and
        not b.name and onGrid(b, data.center, 3), b and JSON.encode(b))
    become(cid, "ranger", 3)
    data = Vocations.radarScan(cid)
    b = blipOf(data, pidgey)
    local pidgeyPos = getCreaturePosition(pidgey)
    check("popup rank 3: exact Pidgey with its name and look", b and b.exact and b.name == "Pidgey" and
        b.x == pidgeyPos.x and b.y == pidgeyPos.y and b.look == getCreatureOutfit(pidgey).lookType, b and JSON.encode(b))
    check("popup rank 3: Pidgey is common", b and b.kind == "common", b and b.kind)
    local p = pikachu and blipOf(data, pikachu)
    check("popup rank 3: Pikachu is uncommon", p and p.kind == "uncommon", p and p.kind)
    check("popup rank 3: still no shiny", not blipOf(data, shiny))
    become(cid, "ranger", 4)
    data = Vocations.radarScan(cid)
    b = blipOf(data, shiny)
    check("popup rank 4: the shiny, only roughly", b and b.kind == "shiny" and not b.exact and b.band == shinyBand and
        b.direction == shinyDirection, b and JSON.encode(b))
    check("popup rank 4: no legendary", not blipOf(data, articuno))
    become(cid, "ranger", 5)
    setPlayerStorageValue(cid, playersStorages.vocationLegendaryAt, 0)
    data = Vocations.radarScan(cid)
    b = blipOf(data, articuno)
    check("popup rank 5: the legendary with its name", b and b.kind == "legendary" and b.name == "Articuno" and
        b.band == legendBand and b.direction == legendDirection, b and JSON.encode(b))
    data = Vocations.radarScan(cid)
    check("popup rank 5: legendaries keep their cooldown", not blipOf(data, articuno))
    check("popup scan counts every Pokemon found", tonumber(data.total) and data.total >= #data.blips and
        data.total >= 2, data.total)
    local encoded = JSON.encode(data)
    local ok, decoded = pcall(JSON.decode, encoded)
    check("popup scan encodes to JSON", ok and decoded.type == "scan" and decoded.center.x == data.center.x and
        #encoded < 8192, #encoded)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    local scanned = Vocations.radar(cid, "")
    check("popup: !radar scans in the PokeVerse client, then recharges", scanned and not Vocations.radarPopupScan(cid))

    -- the live view: rank 3 exact blips follow their Pokemon after the scan, rank 2 stays a snapshot
    local function captureRadar(fn)
        local original, got = doSendPlayerExtendedOpcode, {}
        doSendPlayerExtendedOpcode = function(target, opcode, buffer)
            if (opcode == EXTENDED_IDS.RADAR) then
                got[#got + 1] = JSON.decode(buffer)
                return true
            end
            return original(target, opcode, buffer)
        end
        local ok, err = pcall(fn)
        doSendPlayerExtendedOpcode = original
        if (not ok) then
            check("no errors in the live radar", false, err)
        end
        return got
    end
    -- other wild Pokemon around may move too, so the checks look for Pidgey
    local function pidgeyIn(got, field)
        for _, message in ipairs(got) do
            for _, entry in ipairs(message[field] or {}) do
                if ((type(entry) == "table" and entry.id or entry) == pidgey) then
                    return entry
                end
            end
        end
    end
    become(cid, "ranger", 2)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    local got = captureRadar(function() Vocations.radarPopupScan(cid) end)
    check("live radar: rank 2 stays a snapshot", got[1] and got[1].type == "scan" and not got[1].live and
        not Vocations.radarLiveUpdate(cid))
    become(cid, "ranger", 3)
    setPlayerStorageValue(cid, playersStorages.vocationRadarAt, 0)
    local keepAwake, awake = doMonsterKeepAwake, {}
    doMonsterKeepAwake = keepAwake and function(id, ms)
        awake[id] = ms
        return keepAwake(id, ms)
    end
    got = captureRadar(function() Vocations.radarPopupScan(cid) end)
    doMonsterKeepAwake = keepAwake
    check("live radar: rank 3 scans are live", got[1] and got[1].type == "scan" and got[1].live == true)
    check("live radar: the tracked Pokemon keep walking with no trainer in view",
        keepAwake and awake[pidgey] == Vocations.PERKS.ranger.liveSeconds * 1000 and keepAwake(pidgey, 1) and not keepAwake(cid, 1),
        keepAwake and tostring(awake[pidgey]) or "doMonsterKeepAwake missing: old server build")
    got = captureRadar(function() Vocations.radarLiveUpdate(cid) end)
    check("live radar: nothing sent for a Pokemon that stayed", not pidgeyIn(got, "blips"))
    local from = getCreaturePosition(pidgey)
    local to
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, { 1, 1 }, { -1, -1 } }) do
        local p = { x = from.x + d[1], y = from.y + d[2], z = from.z }
        if (not to and isFree(cid, p)) then
            to = p
        end
    end
    if (to) then
        doTeleportThing(pidgey, to, false)
        got = captureRadar(function() Vocations.radarLiveUpdate(cid) end)
        local moved = pidgeyIn(got, "blips")
        check("live radar: sends where Pidgey went", moved and moved.x == to.x and moved.y == to.y,
            got[1] and JSON.encode(got[1]))
    else
        check("live radar: room to move Pidgey", false)
    end
    Vocations.setRadarLive(cid, false)
    doTeleportThing(pidgey, from, false)
    got = captureRadar(function() Vocations.radarLiveUpdate(cid) end)
    check("live radar: paused while the popup is closed", #got == 0 and not pidgeyIn(got, "blips"))
    Vocations.setRadarLive(cid, true)
    doRemoveCreature(pidgey)
    got = captureRadar(function() Vocations.radarLiveUpdate(cid) end)
    check("live radar: a caught or defeated Pokemon is gone", pidgeyIn(got, "gone") ~= nil, got[1] and JSON.encode(got[1]))
    Vocations.setRadarLive(cid, false)

    for _, m in ipairs(made) do
        if (isCreature(m)) then
            doRemoveCreature(m)
        end
    end
end

-- Type matchups on the moves bar and the move cards (MoveInfo, EXTENDED_IDS.MOVE_INFO)
local function testMoveInfo(cid, arena)
    local made, spots = {}, {}
    for dx = -3, 3 do
        for dy = -3, 3 do
            local p = { x = arena.x + dx, y = arena.y + dy, z = arena.z }
            if ((dx ~= 0 or dy ~= 0) and isFree(cid, p)) then
                spots[#spots + 1] = p
            end
        end
    end
    local function make(name)
        local spot = table.remove(spots, 1)
        local m = spot and doCreateMonster(name, spot, false)
        if (m) then
            made[#made + 1] = m
        end
        return m
    end
    local geodude, charmander, bulbasaur, charizard, gastly, squirtle =
        make("Geodude"), make("Charmander"), make("Bulbasaur"), make("Charizard"), make("Gastly"), make("Squirtle")
    if (not (geodude and charmander and bulbasaur and charizard and gastly and squirtle)) then
        check("move info: room for the test Pokemon", false)
    else
        local m = function(target, move) return MoveInfo.getMultiplier(nil, target, move) end
        check("matchup: Water Gun vs Geodude is a double weakness, capped at 2.5x", m(geodude, "Water Gun") == 2.5, m(geodude, "Water Gun"))
        check("matchup: Water Gun vs Charmander is 2x", m(charmander, "Water Gun") == 2, m(charmander, "Water Gun"))
        check("matchup: Water Gun vs Bulbasaur is 0.5x", m(bulbasaur, "Water Gun") == 0.5, m(bulbasaur, "Water Gun"))
        check("matchup: Vine Whip vs Charizard is a double resistance (0.25x)", m(charizard, "Vine Whip") == 0.25, m(charizard, "Vine Whip"))
        check("matchup: Thunder Shock can't touch Geodude", m(geodude, "Thunder Shock") == 0, m(geodude, "Thunder Shock"))
        check("matchup: Tackle can't touch Gastly", m(gastly, "Tackle") == 0, m(gastly, "Tackle"))
        check("matchup: Tackle vs Charmander is plain", m(charmander, "Tackle") == 1, m(charmander, "Tackle"))
        check("matchup: no arrow for a status move", m(charmander, "Growl") == nil)
        check("damage uses the same multiplier", getSkillElementMultiplier(0, geodude, "Water Gun") == 2.5)

        setPokemonHeldMovePowerModifier(squirtle, 20)
        setPokemonHeldMovePowerType(squirtle, ELEMENT_WATER, 1)
        setPokemonHeldMovePowerType(squirtle, EMPTY_STORAGE, 2)
        local power, boosts = MoveInfo.getPower(cid, squirtle, "Water Gun")
        check("card: Water Gun on a Squirtle with Mystic Water is 40 x1.1 x1.2", power and math.floor(power + 0.5) == 53 and #boosts == 2,
            tostring(power) .. " " .. JSON.encode(boosts))
        local strong = MoveInfo.estimateDamage(squirtle, charmander, "Water Gun", 53, 2)
        local weak = MoveInfo.estimateDamage(squirtle, charmander, "Water Gun", 53, 0.5)
        check("card: the damage estimate grows with the matchup", strong and weak and strong > weak and weak >= 1,
            tostring(strong) .. " " .. tostring(weak))
        check("card: no damage estimate for an immunity", MoveInfo.estimateDamage(squirtle, gastly, "Tackle", 40, 0) == nil)
        power, boosts = MoveInfo.getPower(cid, squirtle, "Tackle")
        check("card: Tackle gets no boosts on a Squirtle", power == getPokemonSkillDamage("Tackle") and #boosts == 0, tostring(power))

        local original, sent = doSendPlayerExtendedOpcode, {}
        doSendPlayerExtendedOpcode = function(target, opcode, buffer)
            if (opcode == EXTENDED_IDS.MOVE_INFO) then
                sent[#sent + 1] = JSON.decode(buffer)
                return true
            end
            return original(target, opcode, buffer)
        end
        local ok, err = pcall(function()
            MoveInfo.onClientMessage(cid, JSON.encode({ action = "matchup", target = charmander,
                icons = { getPokemonSkillClientIconId("Water Gun"), getPokemonSkillClientIconId("Growl") } }))
            MoveInfo.onClientMessage(cid, JSON.encode({ action = "card", icon = getPokemonSkillClientIconId("Water Gun"), target = charmander }))
            MoveInfo.onClientMessage(cid, "not json")
        end)
        doSendPlayerExtendedOpcode = original
        check("move info: no errors", ok, err)
        local matchup, card = sent[1], sent[2]
        check("move info: the matchup reply", matchup and matchup.type == "matchup" and #matchup.moves == 2 and
            matchup.moves[1].multiplier == 2 and matchup.moves[1].power == 40 and matchup.moves[2].multiplier == nil,
            matchup and JSON.encode(matchup))
        check("move info: the card", card and card.type == "card" and card.name == "Water Gun" and card.final == 40 and
            card.target and card.target.multiplier == 2 and card.target.name == getCreatureName(charmander), card and JSON.encode(card))
        check("move info: bad messages are ignored", #sent == 2)
    end
    for _, m in ipairs(made) do
        if (isCreature(m)) then
            doRemoveCreature(m)
        end
    end
end

-- The JSON messages fn sends on EXTENDED_IDS.FISHING
local function captureFishing(fn)
    local original, sent = doSendPlayerExtendedOpcode, {}
    doSendPlayerExtendedOpcode = function(target, opcode, buffer)
        if (opcode == EXTENDED_IDS.FISHING) then
            sent[#sent + 1] = JSON.decode(buffer)
            return true
        end
        return original(target, opcode, buffer)
    end
    local ok, result = pcall(fn)
    doSendPlayerExtendedOpcode = original
    if (not ok) then
        check("no errors in the fishing guide", false, result)
    end
    return sent
end

local function testFishingGuide(cid)
    become(cid, nil)
    local status = Fishing.guideState(cid)
    check("fishing guide button hidden for non-Anglers", status.enabled == false)
    become(cid, "angler", 3)
    status = Fishing.guideState(cid)
    check("fishing guide button shown for Anglers", status.enabled == true and status.guideRank == 4, status.guideRank)
    local sent = captureFishing(function() Fishing.onClientMessage(cid, '{"action":"open"}') end)
    check("fishing guide refused below rank 4", #sent == 0)

    become(cid, "angler", 4)
    sent = captureFishing(function() Fishing.onClientMessage(cid, '{"action":"open"}') end)
    local guide = sent[1] or {}
    check("fishing guide sent at rank 4", guide.type == "guide" and guide.rank == 4 and #(guide.regions or {}) == 4,
        tostring(guide.type))
    local first = (guide.tiers or {})[1] or {}
    check("guide: Magikarp at skill 0 everywhere", first.skill == 0 and (first.pools or {}).kanto and
        first.pools.kanto[1] == "Magikarp", first.skill)
    local hoenn, numbered, missing = false, 0, {}
    for _, tier in ipairs(guide.tiers or {}) do
        for _, name in ipairs((tier.pools or {}).hoenn or {}) do
            hoenn = hoenn or name == "Surskit"
        end
    end
    for name, info in pairs(guide.pokemon or {}) do
        if ((tonumber(info.number) or 0) > 0) then
            numbered = numbered + 1
        else
            missing[#missing + 1] = name
        end
    end
    check("guide: Surskit in a Hoenn pool", hoenn)
    check("guide: every Pokemon has a portrait number", numbered > 0 and #missing == 0, table.concat(missing, ", "))
    local rods = {}
    for _, rod in ipairs(guide.rods or {}) do
        rods[rod.name] = rod
    end
    check("guide: rods with their skill", rods["Old Rod"] and rods["Old Rod"].skill == 0 and rods["Super Rod"] and
        rods["Super Rod"].skill == 50 and (rods["Old Rod"].client or 0) > 0)
    check("guide: cranes are for Angler masters", rods["Cranes"] and rods["Cranes"].anglerOnly == true and
        guide.cranesRank == 5)
    check("guide: player's region", guide.region == "kanto", guide.region)

    sent = captureFishing(function() Fishing.onClientMessage(cid, '{"action":"hello"}') end)
    check("fishing guide answers hello with the status", sent[1] and sent[1].type == "status" and sent[1].enabled == true)
    local text = captureMessages(function() asTextClient(function() return Fishing.openGuide(cid) end) end)
    check("fishing guide falls back to text without the client", text:find("Kanto: %*0: Magikarp") ~= nil, text)
end

local function testAngler(cid)
    become(cid, nil)
    local n, total = 20000, 0
    for _ = 1, n do total = total + Fishing.getSkillTries(cid) end
    check("regular trainer: 1 fishing try per hook", total == n)
    become(cid, "angler", 1)
    total = 0
    for _ = 1, n do total = total + Fishing.getSkillTries(cid) end
    check("Angler rank 1: +20% fishing tries", total / n > 1.18 and total / n < 1.22, total / n)
    become(cid, "angler", 5)
    total = 0
    for _ = 1, n do total = total + Fishing.getSkillTries(cid) end
    check("Angler rank 5: double fishing tries", total == 2 * n, total / n)

    become(cid, "angler", 3)
    check("fishing map needs rank 4", not Fishing.sendGuide(cid))
    become(cid, "angler", 4)
    local text = captureMessages(function() Fishing.sendGuide(cid) end)
    check("fishing map at rank 4", text:find("Kanto: %*0: Magikarp") ~= nil and text:find("Hoenn:") ~= nil, text)
    testFishingGuide(cid)
end

-- A water tile with a free, non-protection tile next to it
local function findWater(cid, origin)
    for radius = 1, 80 do
        for dx = -radius, radius do
            for dy = -radius, radius do
                if (math.abs(dx) == radius or math.abs(dy) == radius) then
                    local water = { x = origin.x + dx, y = origin.y + dy, z = origin.z, stackpos = 0 }
                    local ground = getTileThingByPos(water)
                    if (ground and isInArray(WATER_IDS, ground.itemid) and getTileInfo(water).things <= 1) then
                        for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
                            local stand = { x = water.x + d[1], y = water.y + d[2], z = water.z }
                            if (isFree(cid, stand)) then
                                return water, stand, ground
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Casts an Old Rod (or the rod given): returns the messages and the wait before the first bite the
-- fishing loop got
local function cast(cid, water, ground, rodId)
    local rod = doPlayerAddItem(cid, rodId or 12292, 1)
    local ticks
    local realAddEvent = addEvent
    addEvent = function(fn, delay, ...)
        local args = { ... }
        if (args[1] == cid and args[6] ~= nil) then
            ticks = args[6]
            return 0
        end
        return realAddEvent(fn, delay, ...)
    end
    local text = captureMessages(function()
        Fishing.onFishing(cid, getThing(rod), getThingPosition(rod), ground, water)
    end)
    addEvent = realAddEvent
    setFishingStatus(cid, false)
    doRemoveCondition(cid, CONDITION_OUTFIT, CONDITION_SUBID.OUTFITS.FISHING)
    local float = getTileItemById(water, 13181)
    if (isItem(float)) then
        doRemoveItem(float.uid)
    end
    doRemoveItem(rod)
    return text, ticks
end

local function testAnglerSpot(cid, arena)
    local water, stand, ground = findWater(cid, arena)
    for town = 1, 20 do
        if (water) then
            break
        end
        local temple = getTownTemplePosition(town)
        if (temple and temple.x and temple.x > 0) then
            water, stand, ground = findWater(cid, temple)
        end
    end
    if (not water) then
        check("Angler spot: water near the test spot", false)
        return
    end
    doTeleportThing(cid, stand, false)
    become(cid, nil)
    local text, base = cast(cid, water, ground)
    check("regular trainer fishes without the bite list", text:find("You are fishing now") ~= nil and not text:find("can bite here"), text)
    become(cid, "angler", 2)
    text = cast(cid, water, ground)
    check("Angler rank 2 sees what can bite", text:find("Angler: can bite here: Magikarp") ~= nil, text)
    become(cid, "angler", 3)
    local _, fast = cast(cid, water, ground)
    check("Angler rank 3 gets the first bite sooner", base and fast and fast < base, tostring(base) .. " -> " .. tostring(fast))

    local refused = "Only Anglers from rank " .. Vocations.PERKS.angler.cranesRank .. " can use cranes"
    become(cid, nil)
    text = cast(cid, water, ground, CRANE_ITEMID)
    check("regular trainers can't use cranes", text:find(refused, 1, true) ~= nil, text)
    become(cid, "angler", 4)
    text = cast(cid, water, ground, CRANE_ITEMID)
    check("Anglers below rank 5 can't use cranes", text:find(refused, 1, true) ~= nil, text)
    become(cid, "angler", 5)
    local skill = getPlayerSkill(cid, SKILL_FISHING)
    text = cast(cid, water, ground, CRANE_ITEMID)
    check("rank 5 Anglers get past the crane rule", not text:find(refused, 1, true) and
        (skill >= 60 or text:find("You need at least skill 60") ~= nil), text)
    become(cid, "ranger", 5)
    text = cast(cid, water, ground, CRANE_ITEMID)
    check("other vocations can't use cranes", text:find(refused, 1, true) ~= nil, text)
    doTeleportThing(cid, arena, false)
end

local function testMedic(cid, friend, arena)
    local env = sandbox(SCRIPTS .. "potions/healthPotions.lua")
    local pos = { x = arena.x + 2, y = arena.y, z = arena.z }
    doTeleportThing(friend, { x = arena.x, y = arena.y + 1, z = arena.z }, false)
    local m = doCreateMonster("Snorlax", pos, false)
    if (not isMonster(m)) then
        check("Medic: test Pokemon", false)
        return
    end
    doConvinceCreature(friend, m)
    local function heal()
        doRemoveCondition(m, CONDITION_REGENERATION, CONDITION_SUBID.REGENERATION.HEALTH_POTION)
        setIsPokemonUsingHealthPotion(m, false)
        doCreatureAddHealth(m, -(getCreatureHealth(m) - 1))
        local potion = doPlayerAddItem(cid, 12245, 1)
        local where = getCreaturePosition(m)
        env.onUse(cid, getThing(potion), getThingPosition(potion), { uid = m, itemid = 0 }, where)
        doPlayerRemoveItem(cid, 12245, getPlayerItemCount(cid, 12245))
        return getCreatureHealth(m) - 1
    end
    check("Medic test Pokemon belongs to the other trainer", getCreatureMaster(m) == friend)
    become(cid, nil)
    check("a regular trainer can't heal another trainer's Pokemon", heal() == 0)
    become(cid, "medic", 5)
    local base = math.floor(6000 / 12)
    local healed = heal()
    check("Medic heals another trainer's Pokemon, +15% at rank 5", healed == math.min(math.floor(base * 1.15), getCreatureMaxHealth(m) - 1),
        healed .. " of max " .. getCreatureMaxHealth(m))
    become(cid, "medic", 1)
    healed = heal()
    check("Medic rank 1 heals +3%", healed == math.min(math.floor(base * 1.03), getCreatureMaxHealth(m) - 1), healed)
    doRemoveCreature(m)
end

-- Runs fn without sending the game's messages and window updates: the outfit checks choose every
-- vocation in one go, and all of that in one packet overflows the network message
local function quietly(fn)
    local text, opcode, effect = doPlayerSendTextMessage, doSendPlayerExtendedOpcode, doSendMagicEffect
    doPlayerSendTextMessage = function() return true end
    doSendPlayerExtendedOpcode = function() return true end
    doSendMagicEffect = function() return true end
    local ok, err = pcall(fn)
    doPlayerSendTextMessage, doSendPlayerExtendedOpcode, doSendMagicEffect = text, opcode, effect
    if (not ok) then
        error(err, 0)
    end
end

local STARTER_OUTFITS, REPLACEMENT_OUTFITS = { 82 }, { 83, 84, 85 }

local function testOutfits(cid)
    local female = getPlayerSex(cid) == PLAYERSEX_FEMALE
    local trainer = female and 611 or 612
    local function wear(lookType)
        local outfit = getCreatureOutfit(cid)
        outfit.lookType, outfit.lookAddons = lookType, 0
        doCreatureChangeOutfit(cid, outfit)
    end
    local function forget()
        for _, vocation in ipairs(Vocations.LIST) do
            doPlayerRemoveOutfitId(cid, vocation.outfit, 255)
        end
        for _, id in ipairs(REPLACEMENT_OUTFITS) do
            doPlayerRemoveOutfitId(cid, id, 255)
        end
    end
    local function choose(key)
        become(cid, nil)
        setPlayerStorageValue(cid, playersStorages.vocationWindow, 1)
        return Vocations.choose(cid, key)
    end

    forget()
    become(cid, nil)
    for _, vocation in ipairs(Vocations.LIST) do
        check(vocation.name .. " outfit is locked without the vocation", not canPlayerWearOutfitId(cid, vocation.outfit, 0))
    end
    check("Rookie is a starter outfit", canPlayerWearOutfitId(cid, STARTER_OUTFITS[1], 0))

    for _, vocation in ipairs(Vocations.LIST) do
        choose(vocation.key)
        check(vocation.name .. " can wear their outfit after choosing", canPlayerWearOutfitId(cid, vocation.outfit, 0))
        check(vocation.name .. " puts their outfit on when choosing",
            getCreatureOutfit(cid).lookType == vocation.looks[female and 1 or 2], getCreatureOutfit(cid).lookType)
        wear(trainer)
        Vocations.updateOutfit(cid)
        check(vocation.name .. " can change back to Trainer", getCreatureOutfit(cid).lookType == trainer)
        for _, other in ipairs(Vocations.LIST) do
            if (other ~= vocation and canPlayerWearOutfitId(cid, other.outfit, 0)) then
                check(vocation.name .. " can't wear the " .. other.name .. " outfit", false)
            end
        end
        wear(vocation.looks[female and 1 or 2])
        Vocations.updateOutfit(cid)
        check(vocation.name .. " keeps wearing their outfit", getCreatureOutfit(cid).lookType == vocation.looks[female and 1 or 2])
        Vocations.reset(cid)
        check("without the vocation the " .. vocation.name .. " outfit comes off",
            getCreatureOutfit(cid).lookType == trainer, getCreatureOutfit(cid).lookType)
    end
    check("Angler gets the Fisher addons too", (function()
        choose("angler")
        doPlayerAddOutfitId(cid, 9, 1)
        return canPlayerWearOutfitId(cid, 9, 1)
    end)())
    become(cid, "ace")
    check("another vocation can't wear the Fisher addons", not canPlayerWearOutfitId(cid, 9, 1))

    local quests = sandbox(PS_LIB_CONFIG_DIR .. "003-quest.lua").QUESTS_CONFIG
    become(cid, nil)
    check("Julia's Fisher addon quests are for Anglers only",
        not quests["Julia"][1].canStart(cid) and not quests["Julia"][2].canStart(cid))
    become(cid, "angler")
    check("Anglers can start Julia's quests", quests["Julia"][1].canStart(cid) and quests["Julia"][2].canStart(cid))
    local function rewardLooks(npc)
        local looks = {}
        for _, quest in ipairs(quests[npc]) do
            for _, reward in ipairs(quest.rewardItems or {}) do
                if (reward.female) then
                    looks[reward.female.looktype] = true
                end
            end
        end
        return looks
    end
    check("Professor Oak gives the Voyager outfit", rewardLooks("Professor Oak")[2543] and not rewardLooks("Professor Oak")[1200])
    check("Justin Flowers gives the Wanderer outfit", rewardLooks("Justin Flowers")[2575] and not rewardLooks("Justin Flowers")[1202])

    -- a Catcher who had earned the Master Trainer (Oak) and Ranger (Justin Flowers) outfits
    forget()
    for _, earned in ipairs({ { "ace", 40 }, { "ranger", 49 }, { "catcher", 37 } }) do
        become(cid, earned[1])
        doPlayerAddOutfitId(cid, earned[2], 0)
    end
    become(cid, "catcher")
    setPlayerStorageValue(cid, playersStorages.vocationOutfits, -1)
    local text = captureMessages(function() Vocations.migrateOutfits(cid) end)
    check("migration: Voyager for the Master Trainer outfit", canPlayerWearOutfitId(cid, 83, 0), text)
    check("migration: Wanderer for the Ranger outfit", canPlayerWearOutfitId(cid, 84, 0), text)
    check("migration: no Duelist for a Catcher's own outfit", not canPlayerWearOutfitId(cid, 85, 0), text)
    check("migration: tells the trainer", text:find("The Ranger outfit now belongs to a vocation. You got the Wanderer outfit instead.", 1, true) ~= nil, text)
    check("migration: keeps the Catcher outfit", canPlayerWearOutfitId(cid, 37, 0))
    doPlayerRemoveOutfitId(cid, 83, 255)
    Vocations.migrateOutfits(cid)
    check("migration runs once", not canPlayerWearOutfitId(cid, 83, 0))
    forget()
    become(cid, nil)
    Vocations.updateOutfit(cid)
end

local function testCalendar(cid)
    local function date(time) return os.date("%Y-%m-%d %H:%M", time) end
    local function day(time) return os.date("%Y-%m-%d", time) end
    local function at(y, m, d, h) return os.time({ year = y, month = m, day = d, hour = h or 0, min = 0, sec = 0 }) end

    local e1, e2 = { EventCalendar.easter(2026) }, { EventCalendar.easter(2027) }
    check("Calendar: Easter Sunday", e1[1] == 4 and e1[2] == 5 and e2[1] == 3 and e2[2] == 28, table.concat(e1, "-") .. " " .. table.concat(e2, "-"))
    local l1, l2 = { EventCalendar.lunarNewYear(2026) }, { EventCalendar.lunarNewYear(2027) }
    check("Calendar: Lunar New Year", table.concat(l1, "-") == "2026-2-17" and table.concat(l2, "-") == "2027-2-6",
        table.concat(l1, "-") .. " " .. table.concat(l2, "-"))
    check("Calendar: Harvest Moon is the full moon nearest the September equinox",
        day(EventCalendar.harvestMoon(2026)) == "2026-09-26" and day(EventCalendar.harvestMoon(2027)) == "2027-09-15",
        day(EventCalendar.harvestMoon(2026)) .. " " .. day(EventCalendar.harvestMoon(2027)))

    local restartMinutes = ServerRestart.getDaily() or 0
    local restart = string.format("%02d:%02d", math.floor(restartMinutes / 60), restartMinutes % 60)
    local anniversary
    for _, event in ipairs(EventCalendar.getEvents(at(2027, 9, 1), at(2027, 11, 1))) do
        if (event.holiday and event.holiday.id == "anniversary") then
            anniversary = event
        end
    end
    check("Calendar: the anniversary runs Oct 3-5 from the " .. restart .. " restart",
        anniversary and date(anniversary.startsAt) == "2027-10-03 " .. restart and date(anniversary.endsAt) == "2027-10-06 " .. restart,
        anniversary and date(anniversary.startsAt) .. " - " .. date(anniversary.endsAt))
    local fullMoons, nights = 0, 0
    for _, phase in ipairs(EventCalendar.moonPhases(at(2027, 1, 1), at(2028, 1, 1) - 1)) do
        fullMoons = fullMoons + (phase.full and 1 or 0)
    end
    for _, event in ipairs(EventCalendar.getEvents(at(2027, 1, 1), at(2028, 1, 1) - 1)) do
        if (event.holiday and event.holiday.id == "clefairy") then
            nights = nights + 1
            check("Calendar: Clefairy Night runs 20:00-06:00", os.date("%H:%M", event.startsAt) == "20:00" and
                event.endsAt - event.startsAt == 10 * 3600, date(event.startsAt))
            if (nights >= 1) then break end
        end
    end
    check("Calendar: 12 or 13 full moons a year", fullMoons == 12 or fullMoons == 13, fullMoons)

    local bonuses = EventCalendar.parseBonuses("exp=2,shiny=1.5x")
    check("Calendar: bonuses parse", bonuses and bonuses.exp == 2 and bonuses.shiny == 1.5)
    check("Calendar: bad bonuses are refused", not EventCalendar.parseBonuses("exp=1") and not EventCalendar.parseBonuses("exp=11") and
        not EventCalendar.parseBonuses("gold=2") and not EventCalendar.parseBonuses("Big Weekend"))
    local once = EventCalendar.parseAdd("once 2026-11-06 18:00 2d exp=2 Double Friday")
    check("Calendar: /calendar add once", once and once.rule == "once" and date(once.startsAt) == "2026-11-06 18:00" and
        once.length == 2 * 86400 and once.name == "Double Friday" and once.bonusText == "exp=2")
    local last = EventCalendar.parseAdd("weekend last loot=2 Loot Weekend")
    check("Calendar: /calendar add weekend last", last and last.rule == "nthweekend" and last.nth == -1 and last.bonuses.loot == 2 and
        last.name == "Loot Weekend")
    check("Calendar: /calendar add refuses bad input", not EventCalendar.parseAdd("daily exp=2 X") and
        not EventCalendar.parseAdd("once 2026-11-06 18:00 40d exp=2 X") and not EventCalendar.parseAdd("weekend exp=2"))

    local now = os.time()
    local base = EventCalendar.multiplier("exp")
    EventCalendar.addStaffEvent({ rule = "once", startsAt = now - 60, length = 3600, nth = 0, bonusText = "exp=2", name = "VT Staff" }, "vt")
    local staff
    for _, event in ipairs(EventCalendar.getStaffEvents()) do
        if (event.name == "VT Staff") then staff = event end
    end
    check("Calendar: a running staff event multiplies EXP", staff and EventCalendar.multiplier("exp") == base * 2,
        base .. " -> " .. EventCalendar.multiplier("exp"))
    check("Calendar: removing a staff event", staff and EventCalendar.removeStaffEvent(staff.id) and EventCalendar.multiplier("exp") == base)
    EventCalendar.addStaffEvent({ rule = "weekend", startsAt = 0, length = 0, nth = 0, bonusText = "loot=1.5", name = "VT Weekend" }, "vt")
    local weekends, okWeekends = 0, true
    for _, event in ipairs(EventCalendar.getEvents(at(2026, 11, 1), at(2026, 12, 1))) do
        if (event.name == "VT Weekend") then
            weekends = weekends + 1
            okWeekends = okWeekends and os.date("%w %H:%M", event.startsAt) == "5 " .. restart and event.endsAt - event.startsAt == 3 * 86400
        end
    end
    check("Calendar: weekend events run Friday to Monday at the " .. restart .. " restart", weekends >= 4 and okWeekends, weekends)
    for _, event in ipairs(EventCalendar.getStaffEvents()) do
        if (event.name == "VT Weekend") then EventCalendar.removeStaffEvent(event.id) end
    end

    local forced = EventCalendar.getForced("harvestmoon")
    EventCalendar.setForced("harvestmoon", true)
    check("Calendar: forcing the Harvest Moon on", EventCalendar.isActive("harvestmoon") and EventCalendar.hasFlag("berries") and
        EventCalendar.berryMaxCount(3) == 8 and EventCalendar.berryStageInterval(600) == 300 and EventCalendar.seedCount(2) == 4)
    EventCalendar.setForced("harvestmoon", forced)
    check("Calendar: back to automatic", EventCalendar.isActive("harvestmoon") == nil and EventCalendar.berryMaxCount(3) == 3)
    local halloween = EventCalendar.getForced("halloween")
    EventCalendar.setForced("halloween", false)
    local listed = false
    for _, event in ipairs(EventCalendar.getEvents(at(2026, 10, 25), at(2026, 10, 30))) do
        listed = listed or (event.holiday and event.holiday.id == "halloween")
    end
    check("Calendar: forcing a holiday off hides it", not listed)
    EventCalendar.setForced("halloween", halloween)

    local status = EventCalendar.statusData()
    check("Calendar: status has the next event", status.type == "status" and status.next and status.next.startsAt > status.now,
        status.next and status.next.name)
    local range = EventCalendar.rangeData(at(2026, 9, 28), at(2026, 11, 9))
    check("Calendar: a month range lists events and moons", range and #range.events > 0 and #range.moons >= 2)
    check("Calendar: too long a range is refused", EventCalendar.rangeData(at(2026, 1, 1), at(2026, 6, 1)) == nil)
end

local function testSeasons(cid)
    local function at(y, m, d, h) return os.time({ year = y, month = m, day = d, hour = h or 12, min = 0, sec = 0 }) end
    local expected = { spring = { 3, 20, 22 }, summer = { 6, 21, 23 }, autumn = { 9, 22, 24 }, winter = { 12, 21, 23 } }
    local restart = ServerRestart.getDaily() or 0
    local spans, ok = EventCalendar.seasonSpans(at(2026, 1, 15), at(2026, 12, 31)), true
    for _, span in ipairs(spans) do
        local d, want = os.date("*t", span.startsAt), expected[span.season.id]
        if (d.year == 2026) then
            ok = ok and d.month == want[1] and d.day >= want[2] and d.day <= want[3] and d.hour * 60 + d.min == restart
        end
    end
    check("Seasons: each starts at the restart after its equinox or solstice", #spans == 5 and ok, #spans)
    check("Seasons: spans follow each other", spans[1] and spans[1].endsAt == spans[2].startsAt and spans[4].endsAt == spans[5].startsAt)
    local forced = EventCalendar.getForcedSeason()
    EventCalendar.setForcedSeason(nil)
    check("Seasons: by date", EventCalendar.seasonId(at(2026, 11, 1)) == "autumn" and EventCalendar.seasonId(at(2027, 1, 15)) == "winter" and
        EventCalendar.seasonId(at(2027, 4, 30)) == "spring" and EventCalendar.seasonId(at(2027, 7, 1)) == "summer")
    EventCalendar.setForcedSeason("winter")
    local current = EventCalendar.currentSeason(at(2027, 7, 1))
    check("Seasons: staff can force one", current.season.id == "winter" and current.forced and EventCalendar.seasonId() == "winter")
    EventCalendar.setForcedSeason(forced and forced.id or nil)
    check("Seasons: back to automatic", (EventCalendar.getForcedSeason() and EventCalendar.getForcedSeason().id) == (forced and forced.id))
    local status = EventCalendar.statusData()
    check("Seasons: the calendar status names the season", status.season and EventCalendar.getSeason(status.season.id) ~= nil and
        status.season.endsAt > status.now, status.season and status.season.id)
    local range = EventCalendar.rangeData(at(2026, 9, 1), at(2026, 10, 10))
    check("Seasons: a month range lists the seasons it crosses", range and range.seasons and #range.seasons == 2, range and range.seasons and #range.seasons)
end

local function testWeather(cid, arena)
    local W = Weather
    local saved = W.readOverrides()
    W.writeOverrides("m")
    local function zoneNamed(name)
        for _, zone in ipairs(W.getZones()) do
            if (zone.name == name) then return zone end
        end
    end
    local function at(y, m, d, h, mi) return os.time({ year = y, month = m, day = d, hour = h, min = mi or 0, sec = 0 }) end
    local viridian, desert, johto = zoneNamed("Viridian"), zoneNamed("Desert Island 92"), nil
    local orange
    for _, zone in ipairs(W.getZones()) do
        if (zone.region.id == "johto" and not johto) then johto = zone end
        if (zone.climate == "tropical" and not orange) then orange = zone end
    end
    check("Weather: zones for Kanto, the Orange Islands and the desert", viridian and orange and desert and viridian.region.id == "kanto" and
        desert.climate == "desert")
    if (not (viridian and orange and desert)) then
        W.writeOverrides(saved)
        return
    end
    check("Weather: a town's spot is in its own zone", W.zoneAt(viridian.pos) == viridian)
    for _, zone in ipairs(W.findZones(cid, "all")) do
        if (zone.none or not zone.region.live) then
            check("Weather: 'all' leaves out calm and closed zones", false, zone.name)
        end
    end
    if (johto) then
        check("Weather: Johto has none until it goes live", W.at(johto).source == "none")
    end

    local day = at(2026, 10, 20, 0)
    local changes, ok, last = 0, true, nil
    for t = day, day + 86400 - 1, 600 do
        local a, b = W.at(viridian, t), W.at(viridian, t)
        ok = ok and a.kind == b.kind and a.endsAt == b.endsAt and W.KINDS[a.kind] ~= nil and a.endsAt > t and
            (a.endsAt - a.startsAt) % (20 * 60) == 0
        if (a.kind ~= last) then changes, last = changes + 1, a.kind end
    end
    check("Weather: the same answer every time, in 20-minute steps", ok)
    check("Weather: it changes several times a day", changes >= 4 and changes <= 72, changes)
    local snowy, summerSnow, tropicalSnow, sand, desertTotal = 0, 0, 0, 0, 0
    for t = at(2026, 1, 1, 6), at(2026, 12, 20, 6), 3 * 3600 + 7 * 60 do
        local month = os.date("*t", t).month
        local kind = W.at(viridian, t).kind
        if (kind == "snow" and (month == 12 or month <= 2)) then snowy = snowy + 1 end
        if (kind == "snow" and month >= 7 and month <= 8) then summerSnow = summerSnow + 1 end
        local tropical = W.at(orange, t).kind
        if (tropical == "snow" or tropical == "hail") then tropicalSnow = tropicalSnow + 1 end
        local dry = W.at(desert, t).kind
        desertTotal = desertTotal + 1
        if (dry == "sandstorm") then sand = sand + 1 end
    end
    check("Weather: Kanto snows in winter, never in summer", snowy > 0 and summerSnow == 0, snowy .. " " .. summerSnow)
    check("Weather: no snow or hail in the tropics", tropicalSnow == 0, tropicalSnow)
    check("Weather: the desert has sandstorms", sand > desertTotal / 5, sand .. "/" .. desertTotal)
    local christmas, tropicalChristmas = W.at(viridian, at(2026, 12, 25, 12)), W.at(orange, at(2026, 12, 25, 12))
    check("Weather: snow on Christmas Day", christmas.kind == "snow" and christmas.source == "holiday")
    check("Weather: not in the tropics", tropicalChristmas.source ~= "holiday")
    local halloween, before = W.at(viridian, at(2026, 10, 31, 22)), W.at(viridian, at(2026, 10, 31, 19))
    check("Weather: fog on Halloween night", halloween.kind == "fog" and halloween.source == "holiday" and before.source ~= "holiday")

    W.setOverride({ viridian.id }, "rain", 5)
    local staff = W.at(viridian)
    check("Weather: staff weather wins", staff.kind == "rain" and staff.source == "staff" and math.abs(staff.endsAt - os.time() - 300) <= 2,
        staff.kind .. " " .. staff.source)
    W.setOverride({ viridian.id }, "sunny", 5)
    check("Weather: no harsh sunlight at night, even from staff", W.at(viridian).kind == (W.isNight() and "clear" or "sunny"))
    W.setOverride({ viridian.id }, nil)
    check("Weather: clearing staff weather", W.at(viridian).source ~= "staff")
    local allIds = {}
    for _, zone in ipairs(W.getZones()) do allIds[#allIds + 1] = zone.id end
    local pins = W.readOverrides()
    W.setOverride(allIds, "rain", 5)
    W.setOverride({ viridian.id }, "fog", 5)
    local stored, pinned = W.readOverrides(), 0
    for _, id in ipairs(allIds) do
        local entry = W.getOverrides()[id]
        if (entry and entry.kind == (id == viridian.id and "fog" or "rain")) then pinned = pinned + 1 end
    end
    check("Weather: staff weather on every zone fits the database and reads back", #stored <= 255 and pinned == #allIds,
        #stored .. " chars, " .. pinned .. "/" .. #allIds)
    W.writeOverrides(pins)

    -- CI starts on the Tutorial Island, which has no weather: test in Viridian then
    local arenaZone = W.zoneAt(arena)
    local center = (arenaZone and not arenaZone.none and arenaZone.region.live) and arena or viridian.pos
    local spots = {}
    for radius = 0, 12 do
        for dx = -radius, radius do
            for dy = -radius, radius do
                local p = { x = center.x + dx, y = center.y + dy, z = center.z }
                if ((math.abs(dx) == radius or math.abs(dy) == radius) and #spots < 2 and isFree(cid, p) and W.isOutdoors(p)) then
                    spots[#spots + 1] = p
                end
            end
        end
    end
    local spot = spots[1]
    local made = {}
    local function make(name)
        local p = table.remove(spots, 1)
        local m = p and doCreateMonster(name, p, false)
        if (m) then made[#made + 1] = m end
        return m
    end
    local squirtle, geodude = make("Squirtle"), make("Geodude")
    check("Weather: an open-sky spot near the arena", squirtle and geodude, spot and (spot.x .. "," .. spot.y .. "," .. spot.z))
    if (squirtle and geodude) then
        local zones = { W.zoneAt(getCreaturePosition(squirtle)).id, W.zoneAt(getCreaturePosition(geodude)).id }
        local function set(kind)
            W.setOverride(zones, kind, 5)
            W.forget(squirtle)
            W.forget(geodude)
        end
        set("rain")
        local value, kind = W.getMovePowerModifier(squirtle, ELEMENT_WATER)
        check("Weather: rain powers up Water moves", value == 1.2 and kind == "rain", value)
        check("Weather: and weakens Fire moves", W.getMovePowerModifier(squirtle, ELEMENT_FIRE) == 0.8)
        check("Weather: and leaves the rest alone", W.getMovePowerModifier(squirtle, ELEMENT_NORMAL) == 1)
        local power, boosts = MoveInfo.getPower(cid, squirtle, "Water Gun")
        local boosted = false
        for _, boost in ipairs(boosts or {}) do boosted = boosted or boost.weather == "rain" end
        check("Weather: the move card shows the rain boost", boosted and math.floor(power + 0.5) == 53, tostring(power))
        local data = W.data(cid)
        check("Weather: the client message", data.type == "weather" and data.kind and data.season == EventCalendar.seasonId())
        set("sandstorm")
        local health = getCreatureHealth(squirtle)
        local lost = W.chip(squirtle)
        check("Weather: a sandstorm wears Pokemon down", lost > 0 and getCreatureHealth(squirtle) == health - lost, lost)
        check("Weather: but not Rock types", W.chip(geodude) == 0)
        doCreatureAddHealth(squirtle, -(getCreatureHealth(squirtle) - 1))
        check("Weather: never below 1 health", W.chip(squirtle) == 0 and getCreatureHealth(squirtle) == 1)
        set("fog")
        local misses = 0
        for _ = 1, 400 do
            if (W.fogMiss(squirtle, geodude)) then misses = misses + 1 end
        end
        local distance = getDistanceBetween(getCreaturePosition(squirtle), getCreaturePosition(geodude))
        if (distance < 2) then
            check("Weather: fog never misses up close", misses == 0, misses)
        else
            check("Weather: fog makes about 1 in 10 long-range moves miss", misses >= 15 and misses <= 80, misses)
        end
        set("rain")
        W.CONFIG.battle = false
        check("Weather: the battle setting turns it off", W.getMovePowerModifier(squirtle, ELEMENT_WATER) == 1)
        W.CONFIG.battle = true
        W.setOverride(zones, nil)
    end
    for _, m in ipairs(made) do
        if (isCreature(m)) then doRemoveCreature(m) end
    end
    check("Weather: the light reaches players", doPlayerSetWeatherLight(cid, 80, -1) == true and doPlayerSetWeatherLight(0, 80, -1) == false)
    W.writeOverrides(saved)
    W.send(cid)
end

local function testDecorations(cid)
    local D = Decorations
    local holiday = D.holidayTheme()
    local season = D.SETS[EventCalendar.seasonId()] and EventCalendar.seasonId() or nil
    check("Decorations: the set follows the holidays, then the season", D.theme() == (holiday or season),
        tostring(D.theme()))
    local mapped, missing = {}, {}
    for _, entry in ipairs(D.HOLIDAYS) do
        mapped[entry[1]] = D.SETS[entry[2]] and #D.SETS[entry[2]].items > 0
    end
    for _, h in ipairs(EventCalendar.HOLIDAYS) do
        if (not mapped[h.id]) then missing[#missing + 1] = h.id end
    end
    check("Decorations: every calendar holiday has its own set", #missing == 0, table.concat(missing, ","))
    local viridian = Weather.getZone(1)
    local spots = viridian and D.spotsFor(viridian) or {}
    check("Decorations: spots around Viridian's temple", #spots >= 3, #spots)
    local apart, outdoors = true, true
    for i, a in ipairs(spots) do
        outdoors = outdoors and Weather.isOutdoors(a)
        for j = i + 1, #spots do
            apart = apart and math.max(math.abs(a.x - spots[j].x), math.abs(a.y - spots[j].y)) >= D.CONFIG.spacing
        end
    end
    check("Decorations: under the open sky, 3 tiles apart", apart and outdoors)
    local set, props = D.SETS[D.theme() or ""], {}
    if (set and viridian) then
        local ids = {}
        for _, id in ipairs(set.items) do ids[id] = true end
        if (set.first) then ids[set.first] = true end
        local r = D.CONFIG.maxDistance
        for x = viridian.pos.x - r, viridian.pos.x + r do
            for y = viridian.pos.y - r, viridian.pos.y + r do
                local pos = { x = x, y = y, z = viridian.pos.z }
                local ground = getTileThingByPos({ x = x, y = y, z = pos.z, stackpos = 0 })
                for id in pairs((ground and ground.itemid and ground.itemid > 0) and ids or {}) do
                    local item = getTileItemById(pos, id)
                    if (item and item.uid and item.uid > 0 and getItemAttribute(item.uid, "scriptprotected") == true) then
                        props[#props + 1] = pos
                    end
                end
            end
        end
        check("Decorations: the set is up in Viridian, script protected so players can't move it", #props >= 3, #props)
        check("Decorations: a tile with a prop is no longer a spot", props[1] and not D.isSpot(props[1]))
    end
end

local function testHandDecorations(cid)
    local D = Decorations
    local viridian = Weather.getZone(1)
    check("Decorations: sets by id or name", D.findSet("Valentine's") == "valentines" and D.findSet("pokemon day") == "pokemonday"
        and not D.findSet("nope"))
    local garland, why = D.findItem("christmas", "garland")
    check("Decorations: props by name or id", D.findItem("christmas", "wreath") == 6502 and D.findItem("christmas", "2105") == 2105
        and not D.findItem("christmas", "99999") and not garland and tostring(why):find("Which one"), why)

    -- a wall with a hook to stand by, and a clear tile, near Viridian's temple
    local wall, stand, dir, floor
    local steps = { { 0, 1, NORTH }, { 0, -1, SOUTH }, { 1, 0, WEST }, { -1, 0, EAST } }
    for dx = -16, 16 do
        for dy = -16, 16 do
            local pos = { x = viridian.pos.x + dx, y = viridian.pos.y + dy, z = viridian.pos.z }
            if (not wall and D.hasHook(pos) and D.checkSpot(pos, 6502)) then
                for _, step in ipairs(steps) do
                    local near = { x = pos.x + step[1], y = pos.y + step[2], z = pos.z }
                    if (not wall and not D.hasHook(near) and D.checkSpot(near, 2105)) then
                        wall, stand, dir = pos, near, step[3]
                    end
                end
            end
            local tile = getTileInfo(pos)
            if (not floor and math.abs(dx) > 3 and not D.hasHook(pos) and D.checkSpot(pos, 2105) and tile
                and tile.downItems == 0 and tile.creatures == 0) then
                floor = pos
            end
        end
    end
    check("Decorations: a hook wall and a clear tile near Viridian's temple", wall and floor)
    if (not wall or not floor) then
        return
    end
    check("Decorations: a tree doesn't go on a wall", not D.checkSpot(wall, 2105))

    local sent, level, largest = {}, Admin.ACCESS, 0
    local opcode, access = doSendPlayerExtendedOpcode, getPlayerAccess
    doSendPlayerExtendedOpcode = function(target, id, buffer)
        if (id == EXTENDED_IDS.ADMIN) then
            sent[#sent + 1] = JSON.decode(buffer)
            largest = math.max(largest, #buffer)
        end
        return true
    end
    getPlayerAccess = function() return level end
    local function ask(data)
        sent = {}
        Admin.onClientMessage(cid, JSON.encode(data))
        return sent
    end
    local back = getCreaturePosition(cid)
    local preview, viridianOff = D.getPreview(), D.getNoAuto()[viridian.id] == true
    local count = #D.getSpots()
    local ok, err = pcall(function()
        doTeleportThing(cid, stand, false)
        doCreatureSetLookDir(cid, dir)
        local answer = ask({ action = "deco_add", set = "christmas", item = 6502 })
        local state = answer[2]
        local saved = state and state.spots and state.spots[1]
        check("Decorations: the Admin window saves a wreath on the wall you face", answer[1] and answer[1].ok
            and #D.getSpots() == count + 1 and saved and saved.x == wall.x and saved.y == wall.y and saved.valid,
            answer[1] and answer[1].text)
        local catalog = ask({ action = "decorations", catalog = true })
        local christmas = catalog[1] and catalog[1].type == "deco_items" and catalog[1].set == "christmas" and catalog[1].items
        check("Decorations: the window gets every set and its props", #catalog == #D.setIds() + 1 and christmas
            and christmas[1].client > 0 and catalog[#catalog].type == "decorations" and #catalog[#catalog].sets == #D.setIds())
        check("Decorations: each message fits the 8 KB extended opcode limit", largest < 8000, largest)
        ask({ action = "deco_add", set = "christmas", item = 6503 })
        local spots = D.spotsNear(wall, 0)
        check("Decorations: a second prop for the set replaces the first", #D.getSpots() == count + 1 and spots[1]
            and spots[1].spot.itemid == 6503)
        level = 0
        ask({ action = "deco_add", set = "halloween", item = 5616 })
        check("Decorations: players below God can't save props", #D.getSpots() == count + 1)
        level = Admin.ACCESS
        check("Decorations: a tree for Christmas on a clear tile", D.addSpot("christmas", floor, 2105, "test")
            and #D.getSpots() == count + 2)
        ask({ action = "deco_preview", set = "christmas", minutes = 5 })
        check("Decorations: preview puts the set up", D.theme() == "christmas" and D.getPreview() == "christmas")
        doTeleportThing(cid, viridian.pos, false)
        ask({ action = "deco_auto", on = false })
        check("Decorations: Viridian's automatic props can be turned off", D.getNoAuto()[viridian.id] == true)
    end)
    doSendPlayerExtendedOpcode, getPlayerAccess = opcode, access
    doTeleportThing(cid, back, false)
    if (not ok) then
        error(err)
    end

    local function protectedAt(pos, itemid)
        local item = getTileItemById(pos, itemid)
        return item and item.uid and item.uid > 0 and getItemAttribute(item.uid, "scriptprotected") == true
    end
    -- the automatic props of the set up now around Viridian's temple (this script's spotsFor was worked
    -- out with the props already down, so it names other tiles)
    local function autoProps()
        local set, ids, n = D.SETS[D.theme() or ""], {}, 0
        for _, itemid in ipairs(set and set.items or {}) do ids[itemid] = true end
        if (set and set.first) then ids[set.first] = true end
        local r = D.CONFIG.maxDistance
        for x = viridian.pos.x - r, viridian.pos.x + r do
            for y = viridian.pos.y - r, viridian.pos.y + r do
                local pos = { x = x, y = y, z = viridian.pos.z }
                local ground = getTileThingByPos({ x = x, y = y, z = pos.z, stackpos = 0 })
                for itemid in pairs((ground and ground.itemid and ground.itemid > 0) and ids or {}) do
                    n = n + (protectedAt(pos, itemid) and not (x == floor.x and y == floor.y) and 1 or 0)
                end
            end
        end
        return n
    end
    addEvent(function()
        check("Decorations: the saved wreath and tree go up with the set", protectedAt(wall, 6503) and protectedAt(floor, 2105))
        check("Decorations: with automatic props off, only the saved ones are in Viridian", autoProps() == 0, autoProps())
        D.removeSpots(wall, "christmas")
        D.removeSpots(floor)
        D.setAuto(viridian.id, not viridianOff)
        if (not preview) then
            D.setPreview(nil)
        end
        check("Decorations: removing deletes the rows", #D.getSpots() == count, #D.getSpots() - count)
        addEvent(function()
            check("Decorations: removed props come down", not protectedAt(wall, 6503) and not protectedAt(floor, 2105))
            check("Decorations: the automatic props come back", autoProps() >= 3, autoProps())
        end, 4000)
    end, 3000)
end

local function testLegendaries(cid, friend, arena)
    local W = WildLegendaries
    local MON, KEY = W.MON, W.KEY
    local saved = {}
    for name, key in pairs(KEY) do
        saved[key] = getStorage(key)
    end
    for _, a in ipairs(W.getActive()) do
        if (isMonster(a.cid)) then
            W.finish(a.cid, "restart")
        end
    end
    W.clearCooldowns()

    local bad, total = {}, 0
    local function scan(points, label)
        local good = 0
        for _, p in ipairs(points) do
            total = total + 1
            if (W.isGoodPoint({ x = p[1], y = p[2], z = p[3] })) then
                good = good + 1
            elseif (#bad < 5) then
                bad[#bad + 1] = string.format("%s %d,%d,%d", label, p[1], p[2], p[3])
            end
        end
        return good
    end
    local roamGood = scan(LEGENDARY_ANCHORS.ROAM, "roam")
    check("Legendary: at least 95% of the Kanto points are good ground", roamGood >= #LEGENDARY_ANCHORS.ROAM * 0.95,
        roamGood .. "/" .. #LEGENDARY_ANCHORS.ROAM .. " " .. table.concat(bad, "; "))
    local homesOk, homeDetail = true, {}
    for _, species in ipairs(W.SPECIES) do
        local points = LEGENDARY_ANCHORS.HOMES[species.home]
        local good = points and scan(points, species.home) or 0
        if (good < 3) then
            homesOk = false
            homeDetail[#homeDetail + 1] = species.name .. " " .. good
        end
    end
    check("Legendary: every species has a home area with good points", homesOk, table.concat(homeDetail, ", "))
    check("Legendary: 21 species, 11 tier 1", #W.SPECIES == 21 and #(function()
        local t = {} for _, s in ipairs(W.SPECIES) do if (s.tier == 1) then t[#t + 1] = s end end return t end)() == 11)

    check("Legendary: population rows", W.getPopulation(0).gap[1] == 16 * 3600 and W.getPopulation(3).gap[2] == 8 * 3600 and
        W.getPopulation(20).cooldown[1] == 24 * 3600 and W.getPopulation(60).gap[1] == 2 * 3600)
    local now = os.time()
    local nextAt = W.scheduleNext(now, true)
    local row = W.getPopulation()
    check("Legendary: the next spawn falls in the population's gap", nextAt - now >= row.gap[1] and nextAt - now <= row.gap[2],
        nextAt - now)
    W.setNextSpawn(now + 100 * 3600)
    check("Legendary: a busier server brings the next spawn forward", W.scheduleNext(now, false) <= now + row.gap[2])

    local tier1 = 0
    for i = 1, 4000 do
        if (W.pickSpecies(W.SPECIES).tier == 1) then tier1 = tier1 + 1 end
    end
    check("Legendary: tier 1 is three times as likely", tier1 / 4000 > 0.73 and tier1 / 4000 < 0.80, tier1 / 4000)

    local broadcasts, cards, events = {}, {}, {}
    local broadcast, opcode, otc, emit = doBroadcastMessage, doSendPlayerExtendedOpcode, getPlayerUsingOtClient, DiscordBridge.emitLegendary
    local getScheduled = ServerRestart.getScheduled
    doBroadcastMessage = function(text) broadcasts[#broadcasts + 1] = text return true end
    doSendPlayerExtendedOpcode = function(target, id, buffer)
        if (id == EXTENDED_IDS.LEGENDARY and target == cid) then cards[#cards + 1] = JSON.decode(buffer) end
        return true
    end
    getPlayerUsingOtClient = function() return true end
    DiscordBridge.emitLegendary = function(event) events[#events + 1] = event end
    local spawned = {}
    local ok, err = pcall(function()
        local articuno = W.getSpecies("articuno")
        local mewtwo = W.getSpecies("Mewtwo")
        local a = W.spawn(articuno, nil, nil, "test")
        spawned[#spawned + 1] = a
        check("Legendary: spawns on a Kanto point", isMonster(a) and W.isEncounter(a), a)
        check("Legendary: spawn broadcast with the recommended level",
            (broadcasts[#broadcasts] or ""):find("A wild Articuno has appeared near .+ Recommended for trainers level 50%+") ~= nil,
            broadcasts[#broadcasts])
        check("Legendary: spawn card and Discord event", cards[#cards] and cards[#cards].type == "spawn" and
            cards[#cards].species == "Articuno" and events[#events] and events[#events].event == "spawn" and
            events[#events].encounterId == getCreatureStorage(a, MON.ENCOUNTER))
        local plain = doCreateMonster("Articuno", arena, false, false)
        check("Legendary: health raised 30x for the fight only", isMonster(plain) and
            getCreatureMaxHealth(a) == getCreatureMaxHealth(plain) * W.CONFIG.healthMultiplier[1],
            getCreatureMaxHealth(a) .. " vs " .. (isMonster(plain) and getCreatureMaxHealth(plain) or 0))
        if (isMonster(plain)) then doRemoveCreature(plain) end
        local again, why = W.spawn(articuno)
        check("Legendary: never two of the same species", not again and why ~= nil)

        local list = W.eligible()
        local hasArticuno = false
        for _, s in ipairs(list) do hasArticuno = hasArticuno or s.name == "Articuno" end
        check("Legendary: the one out is not eligible", #list == 20 and not hasArticuno, #list)
        -- north of the arena: the Catcher throws, running at the same time, use the tiles east and south
        local m = W.spawn(mewtwo, { x = arena.x, y = arena.y - 1, z = arena.z }, "the test arena", "test")
        spawned[#spawned + 1] = m
        check("Legendary: a second one can come", isMonster(m))
        check("Legendary: at most two alive", #W.eligible() == 0 and W.blocked(os.time()) ~= nil)
        W.finish(a, "staff")
        local tier2 = false
        for _, s in ipairs(W.eligible()) do tier2 = tier2 or s.tier == 2 end
        check("Legendary: never two tier 2", not tier2 and #W.eligible() > 0)
        check("Legendary: sent away by staff, no cooldown", not isMonster(a) and not W.getCooldowns()["Articuno"] and
            (broadcasts[#broadcasts] or ""):find("flew away") ~= nil)
        ServerRestart.getScheduled = function() return os.time() + 3600, 1 end
        check("Legendary: no spawns in the 2 hours before a restart", (W.blocked(os.time()) or ""):find("restart") ~= nil)
        ServerRestart.getScheduled = getScheduled

        -- roaming, flee, heal and time up on a fresh Articuno
        a = W.spawn(articuno, nil, nil, "test")
        spawned[#spawned + 1] = a
        local t = os.time()
        local from = getCreaturePosition(a)
        doCreatureSetStorage(a, MON.NEXT_MOVE, t - 1)
        doCreatureSetStorage(a, MON.LAST_HIT, t)
        W.upkeep(a, t)
        check("Legendary: stays put while being hit", getSamePosition(from, getCreaturePosition(a)) and
            getCreatureStorage(a, MON.NEXT_MOVE) == t + 30)
        doCreatureSetStorage(a, MON.NEXT_MOVE, t - 1)
        doCreatureSetStorage(a, MON.LAST_HIT, 0)
        from = getCreaturePosition(a)
        W.upkeep(a, t)
        check("Legendary: roams to another point", not getSamePosition(from, getCreaturePosition(a)) and
            getCreatureStorage(a, MON.NEXT_MOVE) >= t + 240 and events[#events].event == "sighting",
            events[#events] and events[#events].event)

        local max = getCreatureMaxHealth(a)
        local hit = getCreatureHealth(a) - math.floor(max * 0.45)
        W.onHit(a, hit)
        doCreatureAddHealth(a, -hit)
        check("Legendary: flees at 50% health", getCreatureStorage(a, MON.FLEE_PENDING) == 1 and getCreatureStorage(a, MON.FLEE_STAGE) == 1)
        from = getCreaturePosition(a)
        W.upkeep(a, t)
        check("Legendary: the flee moves it and keeps its health", not getSamePosition(from, getCreaturePosition(a)) and
            getCreatureHealth(a) == max - hit and (broadcasts[#broadcasts] or ""):find("fled") ~= nil, broadcasts[#broadcasts])
        W.onHit(a, 1)
        check("Legendary: tier 1 flees only once", getCreatureStorage(a, MON.FLEE_PENDING) == 0)

        doCreatureSetStorage(a, MON.LAST_HIT, t - 200)
        doCreatureSetStorage(a, MON.LAST_HEAL, 0)
        doCreatureSetStorage(a, MON.NEXT_MOVE, t + 600)
        local before = getCreatureHealth(a)
        W.upkeep(a, t)
        check("Legendary: heals back slowly when left alone", getCreatureHealth(a) - before == math.ceil(max * 0.05),
            getCreatureHealth(a) - before)

        doCreatureSetStorage(a, MON.ENDS_AT, t - 1)
        doCreatureSetStorage(a, MON.LAST_HIT, t - 30)
        W.upkeep(a, t)
        check("Legendary: doesn't fly off while hit in the last 2 minutes", isMonster(a))
        doCreatureSetStorage(a, MON.LAST_HIT, t - 200)
        W.upkeep(a, t)
        local cooldown = W.getCooldowns()["Articuno"]
        check("Legendary: flies off when time is up, with the cooldown", not isMonster(a) and cooldown and
            math.abs(cooldown - t - W.getPopulation().cooldown[1]) <= 2, cooldown and (cooldown - t))
        check("Legendary: Articuno is not eligible on cooldown", (function()
            for _, s in ipairs(W.eligible()) do if (s.name == "Articuno") then return false end end return true end)())

        local cardTypes = {}
        for _, c in ipairs(cards) do cardTypes[c.type] = true end
        check("Legendary: cards for spawn, sighting, flee and end", cardTypes.spawn and cardTypes.flee and cardTypes["end"])
    end)
    doBroadcastMessage, doSendPlayerExtendedOpcode, getPlayerUsingOtClient = broadcast, opcode, otc
    DiscordBridge.emitLegendary, ServerRestart.getScheduled = emit, getScheduled
    if (not ok) then
        check("Legendary: ran without errors", false, err)
    end

    -- A real defeat: the tester does almost all the damage, the friend 3%
    local m = spawned[2]
    if (isMonster(m)) then
        local candies, money = getPlayerItemCount(cid, W.CONFIG.rareCandyId), getPlayerMoney(cid)
        local friendMoney = isPlayer(friend) and getPlayerMoney(friend) or 0
        -- auto loot would add the body's loot money on top of the reward
        local autoLoot = getPlayerAutoLoot(cid)
        setPlayerAutoLoot(cid, false)
        local function defeats()
            local r = db.getResult(string.format("SELECT `kills` FROM `player_dex_kills` WHERE `player_id` = %d AND `species` = 'Mewtwo'",
                getPlayerGUID(cid)))
            if (r:getID() == -1) then return 0 end
            local kills = r:getDataInt("kills")
            r:free()
            return kills
        end
        local points = defeats()
        doCreatureSetNoMove(m, true)
        local pos = getCreaturePosition(m)
        -- reward shares only count damage from a trainer's Pokemon
        local pets = {}
        local function pet(master)
            local p = doCreateMonster("Snorlax", { x = arena.x + 1, y = arena.y + 1, z = arena.z }, false)
            if (isMonster(p)) then
                doConvinceCreature(master, p)
                pets[#pets + 1] = p
            end
            return p
        end
        if (isPlayer(friend)) then
            local fp = pet(friend)
            if (isMonster(fp)) then
                local share = -math.floor(getCreatureHealth(m) * 0.03)
                doTargetCombatHealth(fp, m, COMBAT_PHYSICALDAMAGE, share, share, CONST_ME_NONE)
            end
        end
        local tp = pet(cid)
        doTargetCombatHealth(isMonster(tp) and tp or cid, m, COMBAT_PHYSICALDAMAGE, -10000000, -10000000, CONST_ME_NONE)
        addEvent(function()
            for _, p in ipairs(pets) do
                if (isMonster(p)) then doRemoveCreature(p) end
            end
            if (not isPlayer(cid)) then return end
            setPlayerAutoLoot(cid, autoLoot)
            check("Legendary defeat: Rare Candies and money for 10% of the damage",
                getPlayerItemCount(cid, W.CONFIG.rareCandyId) - candies == 2 and getPlayerMoney(cid) - money == 10000,
                (getPlayerItemCount(cid, W.CONFIG.rareCandyId) - candies) .. " / " .. (getPlayerMoney(cid) - money))
            check("Legendary defeat: nothing below 10%", not isPlayer(friend) or getPlayerMoney(friend) == friendMoney)
            check("Legendary defeat: one Pokepedia defeat", defeats() == points + 1, defeats() - points)
            local cd = W.getCooldowns()["Mewtwo"]
            check("Legendary defeat: tier 2 cooldown", cd and math.abs(cd - os.time() - W.getPopulation().cooldown[2]) <= 3)
            check("Legendary defeat: the encounter is closed", #W.getActive() == 0, #W.getActive())
            local corpse, bodyPos
            for radius = 0, 4 do
                for dx = -radius, radius do
                    for dy = -radius, radius do
                        local at = { x = pos.x + dx, y = pos.y + dy, z = pos.z }
                        local found = not corpse and getTileItemById(at, 11538) -- fainted mewtwo
                        if (found and isItem(found)) then
                            corpse, bodyPos = found, at
                        end
                    end
                end
            end
            check("Legendary defeat: the body lasts 3 minutes and belongs to the top damage dealer", isItem(corpse) and
                (getItemAttribute(corpse.uid, "duration") or 0) > 150000 and getItemAttribute(corpse.uid, "corpseowner") == getPlayerGUID(cid),
                isItem(corpse) and tostring(getItemAttribute(corpse.uid, "duration")) or "no body")
            if (isItem(corpse)) then
                W.releaseBody(bodyPos, corpse.itemid, "Mewtwo")
                check("Legendary defeat: after the window anyone may throw", not getItemAttribute(corpse.uid, "corpseowner"))
                doRemoveItem(corpse.uid)
            end
            local said = {}
            local b = doBroadcastMessage
            doBroadcastMessage = function(text) said[#said + 1] = text return true end
            W.onCatch(cid, "Mewtwo")
            doBroadcastMessage = b
            check("Legendary defeat: a catch right after is announced", (said[1] or ""):find("caught the wild Mewtwo") ~= nil, said[1])
            for key, value in pairs(saved) do
                doSetStorage(key, value)
            end
        end, 3000)
    else
        check("Legendary defeat: Mewtwo out", false)
        for key, value in pairs(saved) do
            doSetStorage(key, value)
        end
    end
end

function onSay(cid, words, param, channel)
    tester, passed, failed = cid, 0, 0
    local friend = getPlayerByName(param ~= "" and param or "-")
    if (getPlayerLevel(cid) < 65) then
        doPlayerAddLevel(cid, 65 - getPlayerLevel(cid), false)
    end
    local arena = findArena(cid)
    if (not arena) then
        say("FAIL no free tiles")
        return true
    end
    doTeleportThing(cid, arena, false)
    -- clear skies everywhere, so rain or a sandstorm can't change the numbers the other tests expect
    local weather = Weather.readOverrides()
    Weather.writeOverrides("m")
    local everywhere = {}
    for _, zone in ipairs(Weather.getZones()) do
        everywhere[#everywhere + 1] = zone.id
    end
    Weather.setOverride(everywhere, "clear", 10)
    for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        doRemoveItem(ball.uid)
    end

    local tests = {
        { "ranks", testRanks }, { "trials", testTrials },
        { "trainer card", function() testTrainerCard(cid, friend) end }, { "outfits", function() quietly(function() testOutfits(cid) end) end }, { "ace", testAce }, { "catcher odds", testCatcherOdds },
        { "incubator", testBreederIncubator }, { "daycare", testDaycare }, { "held items", testHeldItems }, { "shiny event", testShinyEvent }, { "admin", testAdmin }, { "quests", testQuests }, { "calendar", testCalendar }, { "seasons", testSeasons }, { "weather", function() testWeather(cid, arena) end }, { "decorations", testDecorations }, { "hand decorations", testHandDecorations }, { "legendaries", function() testLegendaries(cid, friend, arena) end }, { "move info", function() testMoveInfo(cid, arena) end }, { "ranger", function() testRanger(cid, arena) end },
        { "angler", testAngler }, { "angler spot", function() testAnglerSpot(cid, arena) end },
        { "medic", function()
            if (isPlayer(friend)) then
                testMedic(cid, friend, arena)
            else
                check("Medic: second trainer online", false, param)
            end
        end },
    }
    for _, test in ipairs(tests) do
        local ok, err = pcall(test[2], cid)
        if (not ok) then
            check(test[1] .. " ran without errors", false, err)
        end
    end
    become(cid, nil)
    testCatcherThrows(cid, arena)
    addEvent(function()
        Weather.writeOverrides(weather)
        if (isPlayer(cid)) then
            become(cid, nil)
            say(string.format("done %d passed, %d failed", passed, failed))
        end
    end, 15000)
    return true
end
