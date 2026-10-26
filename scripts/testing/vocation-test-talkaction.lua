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
        local text = "FAIL " .. name .. (detail and (" (" .. tostring(detail):sub(1, 300) .. ")") or "")
        -- the client can miss some of the messages, the server log keeps every failure
        print("vocationtest: " .. text)
        say(text)
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

-- The calendar's own bonus events (the weekend Double Shiny) would change the shiny numbers
local function withoutCalendarBonuses(test)
    return function(cid)
        local multiplier, shiny = EventCalendar.multiplier, getShinyEventMultiplier()
        EventCalendar.multiplier = function() return 1 end
        setShinyEventMultiplier(1)
        local ok, err = pcall(test, cid)
        EventCalendar.multiplier = multiplier
        setShinyEventMultiplier(shiny)
        if (not ok) then
            error(err, 0)
        end
    end
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
        check("admin: the Legendaries section gets the species, the sets and the mode", state.world.legendary and
            #(state.world.legendary.species or {}) == 21 and #(state.world.legendary.sets or {}) == 4 and
            type(state.world.legendary.manual) == "boolean")
        local god = level
        level = Admin.WORLD_ACCESS
        local manager = ask({ action = "hello" })[1]
        level = Admin.WORLD_ACCESS - 1
        local gamemaster = ask({ action = "hello" })[1]
        level = god
        check("admin: a Community Manager gets the world settings and the Legendaries section", manager and manager.world
            and #(manager.world.kinds or {}) == 9 and manager.world.legendary and #(manager.world.legendary.species or {}) == 21)
        check("admin: below that, no world settings", gamemaster and gamemaster.type == "state" and gamemaster.world == nil)
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

        -- every quest needs its mission in XML/quests.xml, so the log shows its name and what to do.
        -- Daily and holiday or event quests (the Daily and Events categories) don't need one: the
        -- log shows their objective.
        local unnamed = {}
        for npcName, quests in pairs(getAllNpcQuests()) do
            for _, quest in ipairs(quests) do
                local logged = quest.storage and Quests.getEntry(quest.storage)
                if (quest.storage and not quest.daily and not (logged and logged.text)
                        and not (logged and (logged.category == "Events" or logged.category == "Daily"))) then
                    unnamed[#unnamed + 1] = npcName .. " " .. quest.storage
                end
            end
        end
        table.sort(unnamed)
        local pirate, sotashi = Quests.getEntry(8679), Quests.getEntry(8717)
        check("quests: holiday NPCs' quests are in Events", pirate and pirate.category == "Events"
            and sotashi and sotashi.category == "Events", tostring(pirate and pirate.category))
        check("quests: every new quest has its mission in quests.xml for the quest log", #unnamed == 0,
            table.concat(unnamed, ", "))
        local stolen, lessons, rock = Quests.getEntry(8659), Quests.getEntry(8753), Quests.getEntry(8019)
        check("quests: a line given by several NPCs takes the line's name", stolen and stolen.name == "The stolen Pokemon"
            and stolen.step == "Part 1 of 6", tostring(stolen and stolen.name) .. " / " .. tostring(stolen and stolen.step))
        check("quests: Professor Oak's tutorial is in Getting started", lessons and lessons.step == "Part 3 of 3"
            and lessons.category == "Getting started", tostring(lessons and lessons.category))
        check("quests: older quests show their own mission name", rock and rock.name == "Rock #02", tostring(rock and rock.name))
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

local function testPokemonShop(cid)
    local guid = getPlayerGUID(cid)
    local sent = {}
    local originalSend, originalNear = doSendPlayerExtendedOpcode, PokemonShop.nearNpc
    doSendPlayerExtendedOpcode = function(to, opcode, text)
        if (to == cid and opcode == EXTENDED_IDS.POKEMON_SHOP) then
            sent[#sent + 1] = JSON.decode(text)
        end
        return originalSend(to, opcode, text)
    end
    local near = "Ron"
    PokemonShop.nearNpc = function() return near, "Talk to Ron or Joel Morris to sell Pokemon." end
    local function last(kind)
        for i = #sent, 1, -1 do
            if (sent[i].type == kind) then
                return sent[i]
            end
        end
    end
    local function message(data)
        sent = {}
        PokemonShop.onClientMessage(cid, JSON.encode(data))
        return last("result"), last("shop")
    end
    local function find(list, name)
        for _, entry in ipairs(list or {}) do
            if (entry.name == name) then
                return entry
            end
        end
    end
    local function clear()
        for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
            doRemoveItem(ball.uid)
        end
        db.executeQuery("DELETE FROM `pc_boxes` WHERE `player_id` = " .. guid)
    end

    local ok, err = pcall(function()
        clear()
        check("shop: species price plus $5 a level", PokemonShop.priceOf("Pidgey", 10) == PokemonShop.basePrice("Pidgey") + 50 and
            PokemonShop.basePrice("Not a Pokemon") == 0, PokemonShop.priceOf("Pidgey", 10))

        PokemonShop.onLogin(cid)
        check("shop: clients without the window keep the conversation", PokemonShop.open(cid, "Ron") == false)
        message({ action = "hello" })
        newBall(cid, "Pidgey", 10)
        sent = {}
        check("shop: the greeting opens the window", PokemonShop.open(cid, "Ron") and last("shop") ~= nil)
        local only = find(last("shop").party, "Pidgey")
        check("shop: the last Pokemon carried can't be sold", only and only.blocked ~= nil and only.price == PokemonShop.priceOf("Pidgey", 10),
            only and only.blocked)

        newBall(cid, "Rattata", 6)
        newBall(cid, "Caterpie", 4)
        local tm = newBall(cid, "Zubat", 12)
        setBallTm(tm.uid, 1, 1, TM_IDS.MEGA_PUNCH)
        newBall(cid, "Shiny Pidgey", 10)
        for _, name in ipairs({ "Zubat", "Caterpie" }) do
            for index, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
                if (getBallPokemonName(ball.uid) == name) then
                    PC.deposit(cid, index, 1, nil, name)
                    break
                end
            end
        end
        local _, shop = message({ action = "refresh" })
        local caterpie, zubat = find(shop and shop.list, "Caterpie"), find(shop and shop.list, "Zubat")
        local rattata, shinyRow = find(shop and shop.party, "Rattata"), find(shop and shop.party, "Shiny Pidgey")
        check("shop: the PC box lists its Pokemon", shop and shop.box == 1 and caterpie and zubat and #shop.boxes == 1 and
            shop.boxes[1].count == 2, shop and JSON.encode(shop.boxes))
        local pcBox
        doSendPlayerExtendedOpcode = function(to, opcode, text)
            if (to == cid and opcode == EXTENDED_IDS.PC) then
                local data = JSON.decode(text)
                if (data and data.type == "box") then pcBox = data end
            end
            return true
        end
        PC.sendBox(cid, 3)
        doSendPlayerExtendedOpcode = originalSend
        check("PC: every box can be picked, not only the ones in use", pcBox and #pcBox.boxes == PC.BOXES and pcBox.box == 3 and
            pcBox.boxes[1].count == 2 and pcBox.boxes[2].count == 0, pcBox and (#pcBox.boxes .. " boxes, box " .. pcBox.box))
        doSendPlayerExtendedOpcode = function(to, opcode, text)
            if (to == cid and opcode == EXTENDED_IDS.POKEMON_SHOP) then
                sent[#sent + 1] = JSON.decode(text)
            end
            return originalSend(to, opcode, text)
        end
        check("shop: a Pokemon that knows a TM is locked", zubat and zubat.blocked ~= nil, zubat and zubat.blocked)
        check("shop: shinies are marked rare", shinyRow and shinyRow.rare == true and rattata and not rattata.rare)

        near = nil
        local result = message({ action = "sell", keys = { rattata.key } })
        check("shop: nothing is sold away from the NPC", result and not result.ok and last("close") and
            #getPlayerAllBallsWithPokemon(cid) == 3)
        near = "Ron"

        result = message({ action = "sell", keys = { zubat.key } })
        check("shop: a locked Pokemon is refused", result and not result.ok and (result.text or ""):find("Zubat") ~= nil,
            result and result.text)
        result = message({ action = "sell", keys = { rattata.key, shinyRow.key } })
        check("shop: rare Pokemon need SELL typed", result and not result.ok and result.rare and result.rare[1] == "Shiny Pidgey" and
            #getPlayerAllBallsWithPokemon(cid) == 3, result and result.text)
        local party = getPlayerAllBallsWithPokemon(cid)
        local all = {}
        for index, ball in ipairs(party) do
            all[#all + 1] = string.format("p|%d|%s|%d", index, getBallPokemonName(ball.uid), getBallPokemonLevel(ball.uid))
        end
        result = message({ action = "sell", keys = all, confirm = "SELL" })
        check("shop: one Pokemon always stays with the trainer", result and not result.ok and #getPlayerAllBallsWithPokemon(cid) == 3,
            result and result.text)

        local money = getPlayerMoney(cid)
        local expected = PokemonShop.priceOf("Rattata", 6) + PokemonShop.priceOf("Shiny Pidgey", 10) + PokemonShop.priceOf("Caterpie", 4)
        result, shop = message({ action = "sell", keys = { rattata.key, shinyRow.key, caterpie.key }, confirm = "SELL", box = 1 })
        local stored = db.getResult("SELECT COUNT(*) AS `n` FROM `pc_boxes` WHERE `player_id` = " .. guid)
        local left = stored:getID() ~= -1 and stored:getDataInt("n") or -1
        if (stored:getID() ~= -1) then
            stored:free()
        end
        check("shop: party and PC Pokemon sell together for their prices", result and result.ok and result.total == expected and
            getPlayerMoney(cid) - money == expected and #getPlayerAllBallsWithPokemon(cid) == 1 and left == 1,
            result and (result.text .. " / " .. tostring(getPlayerMoney(cid) - money) .. " of " .. expected .. ", " .. left .. " in the PC"))
        check("shop: the window gets the new lists", shop and #shop.party == 1 and #shop.list == 1)
        result = message({ action = "sell", keys = { caterpie.key } })
        check("shop: a Pokemon sold already is refused", result and not result.ok, result and result.text)
    end)
    doSendPlayerExtendedOpcode, PokemonShop.nearNpc = originalSend, originalNear
    check("shop checks ran without errors", ok, err)
    clear()
    PokemonShop.onLogin(cid)
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

    -- footprints: from printsRank the tracked blip's steps on soft ground are sent as prints
    local perks = Vocations.PERKS.ranger
    check("prints: the status says from which rank", Vocations.radarState(cid).unlocks.prints == perks.printsRank)
    become(cid, "ranger", perks.printsRank - 1)
    local tracked, why = Vocations.trackPrints(cid, pikachu)
    check("prints: not below their rank", not tracked and why == "rank" and Vocations.trackedPrints(cid) == nil, why)
    become(cid, "ranger", 5)
    tracked, why = Vocations.trackPrints(cid, shiny)
    check("prints: shinies stay vague", not tracked and why == "vague", why)
    if (articuno and isCreature(articuno)) then
        tracked, why = Vocations.trackPrints(cid, articuno)
        check("prints: legendaries stay vague", not tracked and why == "vague", why)
    end
    become(cid, "ranger", perks.printsRank)
    doMonsterKeepAwake, awake = keepAwake and function(id, ms)
        awake[id] = ms
        return keepAwake(id, ms)
    end, {}
    got = captureRadar(function() tracked = Vocations.trackPrints(cid, pikachu) end)
    doMonsterKeepAwake = keepAwake
    check("prints: tracking a blip", tracked and Vocations.trackedPrints(cid) == pikachu and got[1] and
        got[1].type == "track" and got[1].id == pikachu and got[1].seconds == perks.printsSeconds,
        got[1] and JSON.encode(got[1]))
    check("prints: the Pokemon keeps walking for the track", not keepAwake or awake[pikachu] == perks.printsSeconds * 1000)
    local trackers = Vocations.printTrackers(pikachu)
    check("prints: the Pokemon knows its tracker", #trackers == 1 and trackers[1] == cid)
    local at = getCreaturePosition(pikachu)
    got = captureRadar(function() Vocations.sendPrint(pikachu, at, "east") end)
    check("prints: a step is sent to the tracker", got[1] and got[1].type == "print" and got[1].id == pikachu and
        got[1].x == at.x and got[1].y == at.y and got[1].z == at.z and got[1].way == "east", got[1] and JSON.encode(got[1]))
    setPlayerStorageValue(cid, playersStorages.vocationTrack, "m" .. pikachu .. ":" .. (os.time() - 1))
    got = captureRadar(function() Vocations.sendPrint(pikachu, at, "east") end)
    check("prints: none once the track is over", #got == 0 and #Vocations.printTrackers(pikachu) == 0)
    Vocations.trackPrints(cid, pikachu)
    got = captureRadar(function() tracked = Vocations.trackPrints(cid) end)
    check("prints: stopping", tracked and Vocations.trackedPrints(cid) == nil and #Vocations.printTrackers(pikachu) == 0 and
        got[1] and got[1].type == "track" and got[1].id == nil, got[1] and JSON.encode(got[1]))
    got = captureRadar(function() Vocations.sendPrint(pikachu, at, "north") end)
    check("prints: nothing sent after stopping", #got == 0)

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

local function testDuelWilds(cid, arena)
    local allowed = 1 -- RET_NOERROR
    local pet = doCreateMonster("Snorlax", { x = arena.x + 1, y = arena.y, z = arena.z }, false)
    local wild = doCreateMonster("Snorlax", { x = arena.x + 2, y = arena.y, z = arena.z }, false)
    if (not isMonster(pet) or not isMonster(wild)) then
        check("Duel wilds: room for the test Pokemon", false)
        return
    end
    doConvinceCreature(cid, pet)
    local savedDuel, savedBattle = getPlayerDueling(cid), getPlayerBattleing(cid)
    local ok, err = pcall(function()
        check("Duel wilds: a pet and a wild", isPokemonOfPlayer(pet) and isPokemonWild(wild))

        local function hit(fromCid, toCid)
            local before = getCreatureHealth(toCid)
            doTargetCombatHealth(fromCid, toCid, COMBAT_PHYSICALDAMAGE, -200, -200, CONST_ME_NONE)
            return before - getCreatureHealth(toCid)
        end

        local lost = hit(pet, wild)
        check("Duel wilds: a pet can hit a wild", canDoCombat(pet, wild) == allowed and lost > 0, lost)

        setPlayerDueling(cid, true)
        local health = getCreatureHealth(wild)
        lost = hit(pet, wild)
        check("Duel wilds: a duel pet cannot hit a wild", canDoCombat(pet, wild) ~= allowed and lost == 0
            and getCreatureHealth(wild) == health, tostring(canDoCombat(pet, wild)) .. " " .. lost)
        check("Duel wilds: a wild cannot hit a duel pet", canDoCombat(wild, pet) ~= allowed)

        local targeting = sandbox("data/lib/ps/events/creaturescripts/onTarget.lua")
        local text = captureMessages(function()
            check("Duel wilds: click-targeting a wild is cancelled", targeting.onTarget(cid, wild) == false)
        end)
        check("Duel wilds: the cancel names the duel", text:find("wild Pokemon", 1, true) ~= nil, text)

        setPlayerDueling(cid, false)
        setPlayerBattleing(cid, true)
        health = getCreatureHealth(wild)
        lost = hit(pet, wild)
        check("Duel wilds: an NPC-battle pet cannot hit a wild", canDoCombat(pet, wild) ~= allowed and lost == 0
            and getCreatureHealth(wild) == health, tostring(canDoCombat(pet, wild)) .. " " .. lost)
        check("Duel wilds: a wild cannot hit an NPC-battle pet", canDoCombat(wild, pet) ~= allowed)
        text = captureMessages(function()
            check("Duel wilds: click-targeting a wild during an NPC battle is cancelled", targeting.onTarget(cid, wild) == false)
        end)
        check("Duel wilds: the battle cancel names the duel", text:find("wild Pokemon", 1, true) ~= nil, text)

        setPlayerBattleing(cid, false)
        lost = hit(pet, wild)
        check("Duel wilds: after the fight a pet can hit a wild again", canDoCombat(pet, wild) == allowed and lost > 0, lost)
    end)
    setPlayerDueling(cid, savedDuel)
    setPlayerBattleing(cid, savedBattle)
    if (isMonster(pet)) then
        doRemoveCreature(pet)
    end
    if (isMonster(wild)) then
        doRemoveCreature(wild)
    end
    if (not ok) then
        check("Duel wilds: ran without errors", false, err)
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
    local marks = {}
    local env = sandbox(SCRIPTS .. "potions/healthPotions.lua", {
        doSendPlayerExtendedOpcode = function(pid, opcode, payload)
            if (opcode == EXTENDED_IDS.HEAL_MARK) then
                marks[#marks + 1] = { to = pid, data = JSON.decode(payload) }
            end
            return doSendPlayerExtendedOpcode(pid, opcode, payload)
        end })
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
    local function markedFor(pid, from)
        for index = from or 1, #marks do
            if (marks[index].to == pid and marks[index].data.id == m) then
                return marks[index].data.s
            end
        end
        return nil
    end
    check("Heal mark: the healer and the owner see it on the Pokemon, for 60 seconds",
        markedFor(cid) == 60 and markedFor(friend) == 60, tostring(markedFor(cid)) .. " " .. tostring(markedFor(friend)))
    local sent = #marks
    healed = heal()
    check("Heal mark: a second potion sends it again", markedFor(cid, sent + 1) == 60, tostring(markedFor(cid, sent + 1)))
    sent = #marks
    addEvent(function()
        local left = markedFor(cid, sent + 1)
        check("Heal mark: sent again each tick, so trainers who come closer see it", left and left >= 50 and left <= 56, tostring(left))
        if (isCreature(m)) then
            doRemoveCreature(m)
        end
    end, 5500)
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

    local anniversary
    for _, event in ipairs(EventCalendar.getEvents(at(2027, 9, 1), at(2027, 11, 1))) do
        if (event.holiday and event.holiday.id == "anniversary") then
            anniversary = event
        end
    end
    check("Calendar: the anniversary runs Oct 3-5 from 06:00",
        anniversary and date(anniversary.startsAt) == "2027-10-03 06:00" and date(anniversary.endsAt) == "2027-10-06 06:00",
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
            okWeekends = okWeekends and os.date("%w %H:%M", event.startsAt) == "5 17:00" and os.date("%w %H:%M", event.endsAt) == "1 05:00"
        end
    end
    check("Calendar: weekend events run Friday 06:00 to Monday 06:00", weekends >= 4 and okWeekends, weekends)
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

local function testHalloween(cid)
    local function date(time) return os.date("%Y-%m-%d %H:%M", time) end
    local function read(path)
        local file = io.open(path, "r")
        if (not file) then return nil end
        local text = file:read("*a")
        file:close()
        return text
    end

    local halloween
    for _, event in ipairs(EventCalendar.getEvents(os.time({ year = 2026, month = 10, day = 1, hour = 0 }),
            os.time({ year = 2026, month = 11, day = 30, hour = 0 }))) do
        if (event.holiday and event.holiday.id == "halloween") then halloween = event end
    end
    check("Halloween: runs Oct 24 06:00 to Nov 2 06:00", halloween and date(halloween.startsAt) == "2026-10-24 06:00" and
        date(halloween.endsAt) == "2026-11-02 06:00", halloween and date(halloween.startsAt) .. " - " .. date(halloween.endsAt))

    local raids = read("data/raids/raids.xml") or ""
    -- the raids that come to the Kanto towns (the others have their own arenas)
    local townRaids = { ["Halloween"] = true, ["christmasStolenPresent"] = true, ["christmasRocketBots"] = true,
                        ["christmasRunawayStantler"] = true }
    local names = {}
    for _, id in ipairs({ "halloween", "christmas" }) do
        for _, name in ipairs(EventCalendar.RAIDS[id].names) do names[#names + 1] = name end
    end
    names[#names + 1] = "Anniversary"
    for _, name in ipairs(names) do
        local line = raids:match('<raid name="' .. name .. '"[^>]*>')
        check("Holiday raids: " .. name .. " is in raids.xml, off on its own", line and line:find('enabled="no"') ~= nil, line)
        -- reftype block would hold every raid up until its last ghost or cauldron is gone
        check("Holiday raids: " .. name .. " doesn't block the others", line and line:find('reftype="single"') ~= nil, line)
        local text = line and read("data/raids/" .. line:match('file="([^"]+)"'))
        check("Holiday raids: " .. name .. " has its file", text ~= nil, line)
        for cx, cy, cz, r, body in (text or ""):gmatch('<areaspawn[^>]-centerx="(%d+)" centery="(%d+)" centerz="(%d+)" radius="(%d+)">(.-)</areaspawn>') do
            local center, radius, amount = { x = tonumber(cx), y = tonumber(cy), z = tonumber(cz) }, tonumber(r), 0
            for count in body:gmatch('amount="(%d+)"') do amount = amount + tonumber(count) end
            local free = 0
            for dx = -radius, radius do
                for dy = -radius, radius do
                    local pos = { x = center.x + dx, y = center.y + dy, z = center.z }
                    local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = 0 })
                    local info = getTileInfo(pos)
                    if (ground and ground.itemid ~= 0 and info and not info.protection and not info.house and
                            doTileQueryAdd(cid, pos) == RETURNVALUE_NOERROR) then
                        free = free + 1
                    end
                end
            end
            local where = string.format("%d,%d,%d", center.x, center.y, center.z)
            check("Holiday raids: " .. name .. " spawn " .. where .. " has room for its " .. amount, free >= math.min(amount, (2 * radius + 1) ^ 2),
                free .. " free")
            if (townRaids[name]) then
                local zone = Weather.zoneAt(center)
                local distance = zone and math.max(math.abs(zone.pos.x - center.x), math.abs(zone.pos.y - center.y))
                check("Holiday raids: " .. name .. " spawn " .. where .. " is by a Kanto town", zone and zone.region.id == "kanto" and distance <= 150,
                    zone and (zone.name .. " " .. distance))
            end
        end
        local items, grounded = 0, 0
        for x, y, z in (text or ""):gmatch('<itemspawn[^>]-x="(%d+)" y="(%d+)" z="(%d+)"') do
            local ground = getTileThingByPos({ x = tonumber(x), y = tonumber(y), z = tonumber(z), stackpos = 0 })
            items = items + 1
            grounded = grounded + ((ground and ground.itemid ~= 0) and 1 or 0)
        end
        if (items > 0) then
            check("Holiday raids: every item of " .. name .. " is on the map", grounded == items, grounded .. "/" .. items)
        end
    end

    local spots, moved = {}, {}
    for _, spot in ipairs(HalloweenEvent.getNpcSpots()) do
        if (spot.moved) then
            moved[#moved + 1] = spot
        else
            spots[#spots + 1] = spot
        end
    end
    local named = {}
    for _, spot in ipairs(spots) do named[spot.name] = true end
    for _, name in ipairs(HalloweenEvent.NPCS) do
        check("Halloween: " .. name .. " has a spot on the map", named[name] == true)
    end
    local function present()
        local count = 0
        for _, spot in ipairs(spots) do
            count = count + (getNpcAtPosition(spot.pos, spot.name) and 1 or 0)
        end
        return count
    end
    local forced = EventCalendar.getForced("halloween")
    EventCalendar.setForced("halloween", true)
    HalloweenEvent.syncNpcs()
    check("Halloween: its NPCs are there during Halloween", present() == #spots, present() .. "/" .. #spots)
    -- moved spots include pirates shifted one tile onto a ship. getNpcAtPosition looks one tile
    -- around, so those still show from the old tile. Only the unreachable hall copies must be empty.
    local halls = 0
    for _, spot in ipairs(moved) do
        if (spot.name == "Trevor" or spot.name == "Peter Paul") then
            halls = halls + (getNpcAtPosition(spot.pos, spot.name) and 1 or 0)
        end
    end
    check("Halloween: Trevor and Peter Paul stand in the Union Room, not in the hall copies", #moved >= 2 and halls == 0 and
        getNpcAtPosition(HalloweenEvent.NPC_MOVED["Trevor"], "Trevor") and getNpcAtPosition(HalloweenEvent.NPC_MOVED["Peter Paul"], "Peter Paul"),
        halls)
    EventCalendar.setForced("halloween", false)
    HalloweenEvent.syncNpcs()
    local stayed = {}
    for _, spot in ipairs(spots) do
        if (getNpcAtPosition(spot.pos, spot.name)) then
            stayed[#stayed + 1] = string.format("%s at %d,%d,%d", spot.name, spot.pos.x, spot.pos.y, spot.pos.z)
        end
    end
    check("Halloween: its NPCs leave when it isn't Halloween", present() == 0, table.concat(stayed, "; "))
    EventCalendar.setForced("halloween", true)
    HalloweenEvent.syncNpcs()
    check("Halloween: its NPCs come back when it starts", present() == #spots, present() .. "/" .. #spots)
    EventCalendar.setForced("halloween", forced)
    HalloweenEvent.syncNpcs()

    for name, pos in pairs(HalloweenEvent.NPC_MOVED) do
        local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = 0 })
        check("Halloween: " .. name .. " stands on the map", ground and ground.itemid ~= 0, pos.x .. "," .. pos.y .. "," .. pos.z)
    end
    for _, ship in ipairs(HalloweenEvent.PIRATE_SHIPS) do
        local dest = getTileThingByPos({ x = ship.dest.x, y = ship.dest.y, z = ship.dest.z, stackpos = 0 })
        local shore = getTileThingByPos({ x = ship.shore.x, y = ship.shore.y, z = ship.shore.z, stackpos = 0 })
        check("Halloween: " .. ship.name .. " ship tile exists", dest and dest.itemid ~= 0)
        check("Halloween: " .. ship.name .. " shore tile exists", shore and shore.itemid ~= 0)
        check("Halloween: " .. ship.name .. " stands at the shore", HalloweenEvent.NPC_MOVED[ship.name] ~= nil)
    end
    local here = getCreaturePosition(cid)
    for _, ship in ipairs(HalloweenEvent.PIRATE_SHIPS) do
        doCreatureSetStorage(cid, ship.storage, QUEST_STATUS.UNSTARTED)
        local refused = not HalloweenEvent.tryEnterShip(cid, ship.storage, ship.dest)
        check("Halloween: " .. ship.name .. " refuses without the faction", refused and doComparePositions(getCreaturePosition(cid), here))
        doCreatureSetStorage(cid, ship.storage, QUEST_STATUS.STARTED)
        check("Halloween: " .. ship.name .. " takes a started player",
            HalloweenEvent.tryEnterShip(cid, ship.storage, ship.dest) and doComparePositions(getCreaturePosition(cid), ship.dest))
        if (ship.dest2) then
            check("Halloween: " .. ship.name .. " takes a started player to the other ship",
                HalloweenEvent.tryEnterShip(cid, ship.storage, ship.dest2) and doComparePositions(getCreaturePosition(cid), ship.dest2))
        end
        doTeleportThing(cid, here)
        doCreatureSetStorage(cid, ship.storage, QUEST_STATUS.UNSTARTED)
    end
    local quests = sandbox(PS_LIB_CONFIG_DIR .. "003-quest.lua").QUESTS_CONFIG
    for _, outfit in ipairs(HalloweenEvent.PIRATE_OUTFITS) do
        local found
        for _, quest in ipairs(quests[outfit.npc] or {}) do
            if (quest.storage == outfit.storage) then
                for _, reward in ipairs(quest.rewardItems or {}) do
                    if (reward.type == 3 and reward.female and reward.female.looktype == outfit.female
                            and reward.male and reward.male.looktype == outfit.male) then
                        found = true
                    end
                end
            end
        end
        check("Halloween: " .. outfit.npc .. " awards " .. outfit.name, found == true)
        check("Halloween: " .. outfit.npc .. " is placed during Halloween", HalloweenEvent.NPC_MOVED[outfit.npc] ~= nil)
    end

    local account = getPlayerAccountId(cid)
    local count, year = getAccountStorage(account, ACCOUNT_STORAGES.BOUGHT_RARE_CANDY), getAccountStorage(account, ACCOUNT_STORAGES.BOUGHT_RARE_CANDY_YEAR)
    setPlayerBoughtRareCandy(cid, 15)
    check("Halloween: the rare candy limit counts this Halloween's buys", getPlayerBoughtRareCandy(cid) == 15, getPlayerBoughtRareCandy(cid))
    setAccountStorage(account, ACCOUNT_STORAGES.BOUGHT_RARE_CANDY_YEAR, getAccountStorage(account, ACCOUNT_STORAGES.BOUGHT_RARE_CANDY_YEAR) - 1)
    check("Halloween: last Halloween's rare candies don't count", getPlayerBoughtRareCandy(cid) == 0, getPlayerBoughtRareCandy(cid))
    setAccountStorage(account, ACCOUNT_STORAGES.BOUGHT_RARE_CANDY, count)
    setAccountStorage(account, ACCOUNT_STORAGES.BOUGHT_RARE_CANDY_YEAR, year)
end

local function testPokedexObtained(cid)
    local function storage(name) return getPokemonDexStorage(name) end
    local saved = {}
    for _, name in ipairs({ "Tauros", "Bulbasaur", "Bulmander" }) do saved[name] = getCreatureStorage(cid, storage(name)) end

    local knowledge = Pokepedia.getKnowledge(cid, "Tauros")
    if (knowledge and knowledge.catches == 0) then
        doCreatureSetStorage(cid, storage("Tauros"), POKEDEXSTATUS_DEXED)
        doPokedexObtained(cid, "Tauros")
        knowledge = Pokepedia.getKnowledge(cid, "Tauros")
        check("Pokedex: an evolution or starter counts as caught", getCreatureStorage(cid, storage("Tauros")) == POKEDEXSTATUS_DEXED_CATCHED and
            knowledge.level >= 1, getCreatureStorage(cid, storage("Tauros")) .. " " .. knowledge.level)
    end

    doCreatureSetStorage(cid, storage("Bulbasaur"), POKEDEXSTATUS_DEXED_CATCHED)
    doCreatureSetStorage(cid, storage("Bulmander"), POKEDEXSTATUS_UNKNOWN)
    local sent, original = nil, doPlayerSendPokedexStatus
    doPlayerSendPokedexStatus = function(to, status) if (to == cid) then sent = status end return true end
    doPokedexStatusSend(cid)
    doPlayerSendPokedexStatus = original
    check("Pokedex: each number shows its own species, not a variant sharing it", sent and sent[1] == POKEDEXSTATUS_DEXED_CATCHED and
        #sent == POKEMON_NUMBER, sent and (tostring(sent[1]) .. " of " .. #sent))

    for name, value in pairs(saved) do doCreatureSetStorage(cid, storage(name), value) end
end

local function testSummerChests(cid)
    local saved = getCreatureStorage(cid, playersStorages.summerHunting)
    local year = tonumber(os.date("%Y"))
    doCreatureSetStorage(cid, playersStorages.summerHunting, string.format("y%d:%d:0", year, -3599000))
    JulyVacationEvent.onStaminaChange(cid, 0, -2000)
    local spent, received = JulyVacationEvent.getHunting(cid)
    check("Summer: the 1 hour chest after an hour of hunting", received == 1 and spent == -3601000, spent .. " " .. received)
    JulyVacationEvent.onStaminaChange(cid, 0, -1000)
    spent, received = JulyVacationEvent.getHunting(cid)
    check("Summer: the 1 hour chest only once", received == 1, received)
    check("Summer: kept on the character (a restart doesn't reset it)",
        tostring(getCreatureStorage(cid, playersStorages.summerHunting)) == string.format("y%d:%d:1", year, -3602000),
        tostring(getCreatureStorage(cid, playersStorages.summerHunting)))
    doCreatureSetStorage(cid, playersStorages.summerHunting, string.format("y%d:%d:7", year - 1, -99999999))
    spent, received = JulyVacationEvent.getHunting(cid)
    check("Summer: last year's hunting doesn't count", spent == 0 and received == 0, spent .. " " .. received)
    doCreatureSetStorage(cid, playersStorages.summerHunting, saved)
end

local function testAnniversaryBoss(cid)
    local cakePos, cakeId = AnniversaryEvent.STATIC_BIG_CAKE_POS, 24707
    local state, count = AnniversaryEvent.getEventState(), AnniversaryEvent.getMinionKillCount()
    AnniversaryEvent.setMinionKillCount(AnniversaryEvent.MINION_KILL_REQ_COUNT)
    AnniversaryEvent.doSummonBoss()
    local boss = getCreatureByName("Mad Big Cake")
    check("Anniversary: the boss comes after the minions", isMonster(boss) and
        AnniversaryEvent.getEventState() == AnniversaryEvent.EVENT_STATES.KILLING_BOSS, AnniversaryEvent.getEventState())
    if (isMonster(boss)) then
        doRemoveCreature(boss)
    end
    AnniversaryEvent.onBossKill(nil, nil)
    check("Anniversary: the boss kill resets the invasion", AnniversaryEvent.getMinionKillCount() == 0 and
        AnniversaryEvent.getEventState() == AnniversaryEvent.EVENT_STATES.UNSTARTED,
        AnniversaryEvent.getMinionKillCount() .. " " .. AnniversaryEvent.getEventState())
    check("Anniversary: the big cake is back", isItem(getTileItemById(cakePos, cakeId)))
    local before = #(getSpectators(cakePos, 30, 30) or {})
    AnniversaryEvent.onMinionKill(nil, nil)
    check("Anniversary: no more temple minions after the boss", #(getSpectators(cakePos, 30, 30) or {}) == before)
    AnniversaryEvent.setMinionKillCount(count)
    AnniversaryEvent.setEventState(state)
end

local function testAnniversaryNpcs()
    local spots = AnniversaryEvent.getNpcSpots()
    local named = {}
    for _, spot in ipairs(spots) do
        named[spot.name] = true
    end
    for _, name in ipairs(AnniversaryEvent.NPCS) do
        check("Anniversary: " .. name .. " has a spot in the Union Room", named[name] == true)
    end
    local function present()
        local count = 0
        for _, spot in ipairs(spots) do
            count = count + (getNpcAtPosition(spot.pos, spot.name) and 1 or 0)
        end
        return count
    end
    local forced = EventCalendar.getForced("anniversary")
    AnniversaryEvent.setPreview(nil)
    EventCalendar.setForced("anniversary", true)
    AnniversaryEvent.syncNpcs()
    check("Anniversary: its shop NPCs are there during the event", present() == #spots, present() .. "/" .. #spots)
    EventCalendar.setForced("anniversary", false)
    AnniversaryEvent.syncNpcs()
    check("Anniversary: its shop NPCs leave when it isn't the event", present() == 0, present() .. "/" .. #spots)
    EventCalendar.setForced("anniversary", true)
    AnniversaryEvent.syncNpcs()
    check("Anniversary: its shop NPCs come back when it starts", present() == #spots, present() .. "/" .. #spots)
    EventCalendar.setForced("anniversary", forced)
    AnniversaryEvent.syncNpcs()
    for name, pos in pairs(AnniversaryEvent.NPC_SPOTS) do
        local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = 0 })
        check("Anniversary: " .. name .. " stands on the map", ground and ground.itemid ~= 0, pos.x .. "," .. pos.y .. "," .. pos.z)
    end
end

local function testEventShop(cid)
    local halloween = EventShop.get("halloween_trevor")
    local letters = EventShop.get("anniversary_letters")
    local gifts = EventShop.get("anniversary_gifts")
    check("Event shop: Trevor, Timothy Kelvin and Murray Aaron have catalogs",
        halloween and letters and gifts and halloween.tokenId == 14461 and letters.mode == "sell" and gifts.tokenId == 27935)
    local chair = EventShop.findOffer("halloween_trevor", "pumpkin chair kit")
    check("Event shop: the pumpkin chair kit costs 100 HT", chair and chair.price == 100 and chair.itemId == 25148)
    check("Event shop: old clients still get a text list", EventShop.fyi("halloween_trevor"):find("pumpkin chair kit", 1, true) and
        EventShop.fyi("halloween_trevor"):find("HT", 1, true))
    check("Event shop: a client that never said hello does not get the window",
        EventShop.open(cid, "halloween_trevor", cid) == false)

    doPlayerSafeAddItem(cid, 14461, 100, false, true)
    local chairs = getPlayerItemCount(cid, 25148)
    local ok = EventShop.exchange(cid, "halloween_trevor", "pumpkin chair kit", 1)
    check("Event shop: 100 HT buy a pumpkin chair kit", ok and getPlayerItemCount(cid, 25148) == chairs + 1,
        tostring(ok) .. " " .. getPlayerItemCount(cid, 25148))

    local bought = getPlayerBoughtRareCandy(cid)
    setPlayerBoughtRareCandy(cid, 15)
    doPlayerSafeAddItem(cid, 14461, 100, false, true)
    local refused, err = EventShop.exchange(cid, "halloween_trevor", "rare candy", 1)
    check("Event shop: rare candy stays at the account cap", not refused and type(err) == "string" and err:find("15", 1, true), err)
    setPlayerBoughtRareCandy(cid, bought)

    doPlayerSafeAddItem(cid, 27819, 2, false, false)
    local tokens = getPlayerItemCount(cid, 27935)
    local sold = EventShop.exchange(cid, "anniversary_letters", "letter a", 2)
    check("Event shop: two letter A become 2 AT", sold and getPlayerItemCount(cid, 27935) >= tokens + 2)

    local locker, lockerText = EventShop.exchange(cid, "anniversary_gifts", "kangaskhan locker", 1)
    check("Event shop: a locker needs the PSoul letters", not locker, lockerText)

    local christmas = EventShop.get("christmas_santa")
    local grinch = EventShop.get("christmas_grinch")
    local easter = EventShop.get("easter_ralp")
    local july = EventShop.get("july_walter")
    check("Event shop: Santa, Ralp and Walter John have catalogs",
        christmas and grinch and easter and july
            and christmas.tokenId == 14632 and grinch.tokenId == 25270
            and easter.tokenId == 24549 and july.tokenId == 29132
            and christmas.uniqueToken and grinch.uniqueToken and not easter.uniqueToken and july.uniqueToken)
    local present = EventShop.findOffer("christmas_santa", "santa claus present")
    local grinchPresent = EventShop.findOffer("christmas_grinch", "santa claus present")
    check("Event shop: Old Santa's present is 30 CT and Grinch Santa's is 5 TB",
        present and present.price == 30 and grinchPresent and grinchPresent.price == 5)
    check("Event shop: Christmas FYI still lists CT", EventShop.fyi("christmas_santa"):find("christmas kit 1", 1, true)
        and EventShop.fyi("christmas_santa"):find("CT", 1, true))
    check("Event shop: Token Box FYI still lists TB", EventShop.fyi("christmas_grinch"):find("elfin clothes kit", 1, true)
        and EventShop.fyi("christmas_grinch"):find("TB", 1, true))
    check("Event shop: Easter FYI still lists GEE", EventShop.fyi("easter_ralp"):find("blue easter ticket", 1, true)
        and EventShop.fyi("easter_ralp"):find("GEE", 1, true))
    check("Event shop: July FYI still lists F", EventShop.fyi("july_walter"):find("common seal box", 1, true)
        and EventShop.fyi("july_walter"):find("F", 1, true))

    doPlayerSafeAddItem(cid, 14632, 50, false, true)
    local lamps = getPlayerItemCount(cid, 18052)
    local boughtLamp = EventShop.exchange(cid, "christmas_santa", "chinchou lamp", 1)
    check("Event shop: 50 CT buy a chinchou lamp", boughtLamp and getPlayerItemCount(cid, 18052) == lamps + 1,
        tostring(boughtLamp) .. " " .. getPlayerItemCount(cid, 18052))

    doPlayerSafeAddItem(cid, 25270, 5, false, true)
    local presents = getPlayerItemCount(cid, 14639)
    local boughtPresent = EventShop.exchange(cid, "christmas_grinch", "santa claus present", 1)
    check("Event shop: 5 TB buy a santa claus present", boughtPresent and getPlayerItemCount(cid, 14639) == presents + 1,
        tostring(boughtPresent) .. " " .. getPlayerItemCount(cid, 14639))

    doPlayerSafeAddItem(cid, 24549, 20, false, false)
    local tickets = getPlayerItemCount(cid, 24563)
    local boughtTicket = EventShop.exchange(cid, "easter_ralp", "blue easter ticket", 1)
    check("Event shop: 20 GEE buy a blue easter ticket", boughtTicket and getPlayerItemCount(cid, 24563) == tickets + 1,
        tostring(boughtTicket) .. " " .. getPlayerItemCount(cid, 24563))

    local easterBought = getPlayerBoughtRareCandy(cid)
    setPlayerBoughtRareCandy(cid, 15)
    doPlayerSafeAddItem(cid, 24549, 75, false, false)
    local easterRefused, easterErr = EventShop.exchange(cid, "easter_ralp", "rare candy", 1)
    check("Event shop: Easter rare candy stays at the account cap",
        not easterRefused and type(easterErr) == "string" and easterErr:find("15", 1, true), easterErr)
    setPlayerBoughtRareCandy(cid, easterBought)

    doPlayerSafeAddItem(cid, 29132, 1, false, true)
    local seals = getPlayerItemCount(cid, 29125)
    local boughtSeal = EventShop.exchange(cid, "july_walter", "common seal box", 1)
    check("Event shop: 1 fragment buys a common seal box", boughtSeal and getPlayerItemCount(cid, 29125) == seals + 1,
        tostring(boughtSeal) .. " " .. getPlayerItemCount(cid, 29125))
end

local function testServerRestart()
    local keys = {
        GLOBAL_STORAGES.SERVER_RESTART_AT, GLOBAL_STORAGES.SERVER_RESTART_REASON,
        GLOBAL_STORAGES.SERVER_RESTART_DAILY, GLOBAL_STORAGES.SERVER_RESTART_SKIP,
    }
    local saved = {}
    for i, key in ipairs(keys) do
        saved[i] = getStorage(key)
    end
    local function restore()
        for i, key in ipairs(keys) do
            doSetStorage(key, saved[i])
        end
    end

    local now = os.time()
    local staffAt = now + 600
    doSetStorage(GLOBAL_STORAGES.SERVER_RESTART_SKIP, 0)
    ServerRestart.schedule(staffAt, 2)
    local at, reason = ServerRestart.next(now)
    check("Restart: a staff restart is next", at == staffAt and reason == "staff", tostring(at) .. " " .. tostring(reason))

    doSetStorage(GLOBAL_STORAGES.SERVER_RESTART_AT, 0)
    doSetStorage(GLOBAL_STORAGES.SERVER_RESTART_SKIP, 0)
    ServerRestart.setDaily(5 * 60)
    local dailyAt = ServerRestart.nextDaily(5 * 60, now)
    at, reason = ServerRestart.next(now)
    check("Restart: the daily restart is next when nothing is scheduled", at == dailyAt and reason == "daily",
        tostring(at) .. " " .. tostring(reason))
    check("Restart: server.status names that daily restart",
        DiscordBridge.serverStatus().restart and DiscordBridge.serverStatus().restart.at == dailyAt
            and DiscordBridge.serverStatus().restart.reason == "daily")

    doSetStorage(GLOBAL_STORAGES.SERVER_RESTART_SKIP, dailyAt)
    at, reason = ServerRestart.next(now)
    local following = ServerRestart.nextDaily(5 * 60, dailyAt)
    check("Restart: a skipped daily comes back the next day", at == following and reason == "daily",
        tostring(at) .. " " .. tostring(following))

    ServerRestart.disableDaily()
    doSetStorage(GLOBAL_STORAGES.SERVER_RESTART_AT, 0)
    doSetStorage(GLOBAL_STORAGES.SERVER_RESTART_SKIP, 0)
    at, reason = ServerRestart.next(now)
    check("Restart: daily off and nothing scheduled has no field", at == nil and reason == nil
        and DiscordBridge.serverStatus().restart == nil, tostring(at))

    restore()
end

local function testDecorationItems(cid)
    local saved = getStorage(GLOBAL_STORAGES.DECORATIONS_ITEMS)
    local ok = Decorations.addCustomItem("halloween", 25130)
    local found = nil
    for _, item in ipairs(Decorations.catalog("halloween")) do
        found = item.id == 25130 and item or found
    end
    check("Decorations: an item id added to a set's list is offered with it", ok and found and found.custom == true)
    check("Decorations: the same item can't be added twice", not Decorations.addCustomItem("halloween", 25130))
    check("Decorations: an item that doesn't exist can't be added", not Decorations.addCustomItem("halloween", 65000))
    check("Decorations: a set's own props can't be taken off the list", not Decorations.removeCustomItem("halloween", 2097))
    check("Decorations: an added item comes off the list", Decorations.removeCustomItem("halloween", 25130))
    found = false
    for _, item in ipairs(Decorations.catalog("halloween")) do
        found = found or item.id == 25130
    end
    check("Decorations: and isn't offered any more", not found)
    doSetStorage(GLOBAL_STORAGES.DECORATIONS_ITEMS, saved)

    local fits, total = 0, 0
    for _, spot in ipairs(Decorations.DEFAULT_SPOTS.halloween) do
        total = total + 1
        local pos = { x = spot[1], y = spot[2], z = spot[3] }
        local saved = false
        for _, row in ipairs(Decorations.getSpots()) do
            saved = saved or (row.set == "halloween" and row.pos.x == pos.x and row.pos.y == pos.y and row.pos.z == pos.z)
        end
        if (saved and (Decorations.checkSpot(pos, spot[4]) or isItem(getTileItemById(pos, spot[4])))) then
            fits = fits + 1
        end
    end
    check("Decorations: the Union Room's Halloween props are saved and fit", fits == total, fits .. "/" .. total)
end

local function testSeasons(cid)
    local function at(y, m, d, h) return os.time({ year = y, month = m, day = d, hour = h or 12, min = 0, sec = 0 }) end
    local expected = { spring = { 3, 20, 22 }, summer = { 6, 21, 23 }, autumn = { 9, 22, 24 }, winter = { 12, 21, 23 } }
    local spans, ok = EventCalendar.seasonSpans(at(2026, 1, 15), at(2026, 12, 31)), true
    for _, span in ipairs(spans) do
        local d, want = os.date("*t", span.startsAt), expected[span.season.id]
        if (d.year == 2026) then
            ok = ok and d.month == want[1] and d.day >= want[2] and d.day <= want[3] and d.hour == 6 and d.min == 0
        end
    end
    check("Seasons: each starts at 06:00 after its equinox or solstice", #spans == 5 and ok, #spans)
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
        if (zone.none or not W.isRegionOn(zone.region)) then
            check("Weather: 'all' leaves out calm and closed zones", false, zone.name)
        end
    end
    check("Weather: Johto has zones and weather", johto and W.at(johto).source ~= "none")
    if (johto) then
        W.setRegionOn("johto", false)
        check("Weather: a region switched off has none", W.at(johto).source == "none" and not W.isRegionOn(johto.region))
        W.setRegionOn("johto", true)
        check("Weather: switched on again it has weather", W.at(johto).source ~= "none")
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
    local center = (arenaZone and not arenaZone.none and W.isRegionOn(arenaZone.region)) and arena or viridian.pos
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

local function testBallSlotUse(cid)
    if (isPokemonOnline(cid) or isItem(getPlayerSlotItem(cid, PLAYER_SLOT_BALL))) then
        check("Ball slot: free for the test", false)
        return
    end
    local ball = newBall(cid, "Pikachu", 10, POKEMON_SEX_MALE)
    doMovePlayerItem(cid, ball.uid, { y = PLAYER_SLOT_BALL, z = 0 })
    local slot = getPlayerSlotItem(cid, PLAYER_SLOT_BALL)
    check("Ball slot: the ball goes in", isItem(slot) and isBallWithPokemon(slot.uid), slot and slot.itemid)
    doRemoveConditions(cid, false)
    doPlayerUseBallOnSlot(cid)
    check("Ball slot: using it like quick call calls the Pokemon", isPokemonOnline(cid))
    check("Ball slot: the ball stays in the slot", isItem(getPlayerSlotItem(cid, PLAYER_SLOT_BALL)))
    doRemoveConditions(cid, false)
    doPlayerUseBallOnSlot(cid)
    check("Ball slot: using it again calls the Pokemon back", not isPokemonOnline(cid))
    doRemoveConditions(cid, false)
    slot = getPlayerSlotItem(cid, PLAYER_SLOT_BALL)
    if (isItem(slot)) then
        doRemoveItem(slot.uid)
    end
end

local function testPokemonHabitat(cid)
    check("Habitat: the empty stand is a habitat",
        getItemNameById(PokemonHabitat.EMPTY_ID):lower():find("habitat", 1, true) ~= nil)
    check("Habitat: an empty poke ball is not charged",
        not PokemonHabitat.isChargedBall({ uid = 0, itemid = balls["poke"].empty }))
    check("Habitat: no stand under the trainer", PokemonHabitat.standOn(getCreaturePosition(cid)) == nil)

    local houseId, tile, prev
    for _, id in pairs(getTownHouses()) do
        local info = getHouseInfo(id, false)
        if (info and not info.guildHall and info.owner == 0 and info.tiles <= 50) then
            houseId, prev = id, 0
            break
        end
    end
    if (houseId) then
        setHouseOwner(houseId, getPlayerGUID(cid), false)
        for _, pos in ipairs(getHouseTiles(houseId) or {}) do
            local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = 0 })
            local tileInfo = getTileInfo(pos)
            if (ground and ground.itemid ~= 0 and tileInfo and tileInfo.house and not tileInfo.bed) then
                tile = pos
                break
            end
        end
        if (not tile) then
            setHouseOwner(houseId, prev, false)
            houseId = nil
        end
    end
    check("Habitat: a vacant house tile", houseId and tile ~= nil, houseId)
    if (not houseId or not tile) then
        return
    end

    local back = getCreaturePosition(cid)
    local function cleanup()
        PokemonHabitat.recall(tile)
        local stand = getTileItemById(tile, PokemonHabitat.EMPTY_ID)
        if (isItem(stand)) then
            doRemoveItem(stand.uid)
        end
        local sitting = PokemonHabitat.ballOn(tile)
        if (sitting) then
            doRemoveItem(sitting.uid)
        end
        for _, b in ipairs(getPlayerAllBallsWithPokemon(cid)) do
            if (getBallPokemonNickname(b.uid) == "HabitatTest") then
                doRemoveItem(b.uid)
            end
        end
        setHouseOwner(houseId, prev, false)
        doTeleportThing(cid, back, false)
    end

    doTeleportThing(cid, tile, false)
    check("Habitat: the owner can use their house tile", PokemonHabitat.ownsHouseTile(cid, tile))

    doCreateItem(PokemonHabitat.EMPTY_ID, 1, tile)
    check("Habitat: the stand goes down in the house", isItem(getTileItemById(tile, PokemonHabitat.EMPTY_ID)))

    local ball = newBall(cid, "Pikachu", 10, POKEMON_SEX_MALE)
    if (ball and ball.uid) then
        setBallPokemonNickname(ball.uid, "HabitatTest", false)
    end
    check("Habitat: a charged poke ball looks like the inventory ball",
        PokemonHabitat.isChargedBall(ball) and ball.itemid == balls["poke"].charged, ball and ball.itemid)
    -- quick call and the swap bar use the slot ball through doPlayerUseItem, which passes the trainer's tile
    check("Habitat: a bag ball used while standing on the stand is not taken off it",
        ball and not PokemonHabitat.useBall(cid, ball, tile, { uid = 0, itemid = 0 }, tile)
            and not PokemonHabitat.ballOn(tile))

    PokemonHabitat.attach(cid, ball, getTileItemById(tile, PokemonHabitat.EMPTY_ID), tile)
    local sitting = PokemonHabitat.ballOn(tile)
    check("Habitat: the ball on the stand is still the poke ball", sitting and sitting.itemid == balls["poke"].charged,
        sitting and sitting.itemid)
    check("Habitat: the stand stays under it", isItem(getTileItemById(tile, PokemonHabitat.EMPTY_ID)))
    check("Habitat: the house remembers the walker", PokemonHabitat.hasRow(tile))

    local walker
    for _, spec in ipairs(getSpectators(tile, 10, 10, true) or {}) do
        if (isNpc(spec) and tostring(getCreatureNickname(spec) or ""):find("HabitatTest", 1, true)) then
            walker = spec
        end
    end
    check("Habitat: the Pokemon walks the house", walker and getHouseFromPos(getCreaturePosition(walker)) == houseId)

    PokemonHabitat.takeBack(cid, sitting or ball, tile)
    check("Habitat: taking the ball back recalls the Pokemon",
        not PokemonHabitat.hasRow(tile) and (not walker or not isCreature(walker)))
    check("Habitat: the stand stays after take-back", isItem(getTileItemById(tile, PokemonHabitat.EMPTY_ID)))

    local bagBall = newBall(cid, "Pikachu", 10, POKEMON_SEX_FEMALE)
    if (bagBall and bagBall.uid) then
        setBallPokemonNickname(bagBall.uid, "HabitatTest", false)
    end
    PokemonHabitat.useEmpty(cid, getTileItemById(tile, PokemonHabitat.EMPTY_ID), tile, bagBall,
        { x = CONTAINER_POSITION, y = 0, z = 0 })
    sitting = PokemonHabitat.ballOn(tile)
    check("Habitat: use-with the stand puts the bag ball on it",
        sitting and sitting.itemid == balls["poke"].charged and PokemonHabitat.hasRow(tile),
        sitting and sitting.itemid)
    PokemonHabitat.takeBack(cid, sitting or bagBall, tile)

    local usedBall = newBall(cid, "Pikachu", 10, POKEMON_SEX_MALE)
    if (usedBall and usedBall.uid) then
        setBallPokemonNickname(usedBall.uid, "HabitatTest", false)
    end
    PokemonHabitat.useBall(cid, usedBall, { x = CONTAINER_POSITION, y = 0, z = 0 },
        getTileItemById(tile, PokemonHabitat.EMPTY_ID), tile)
    sitting = PokemonHabitat.ballOn(tile)
    check("Habitat: use-with the ball on the stand attaches it",
        sitting and sitting.itemid == balls["poke"].charged and PokemonHabitat.hasRow(tile),
        sitting and sitting.itemid)
    PokemonHabitat.takeBack(cid, sitting or usedBall, tile)

    cleanup()
end

local function testMegaItems(cid)
    check("mega: 97 item ids in order", MEGA_ITEM_IDS.EMPTY_RING == 30175 and MEGA_FIRST_STONE_ID == 30178 and
        MEGA_LAST_STONE_ID == 30271 and #MEGA_STONES == 94, MEGA_LAST_STONE_ID)
    check("mega: every stone has an item type", getItemNameById(MEGA_LAST_STONE_ID):lower() == "blue orb" and
        getItemNameById(MEGA_ITEM_IDS.RING):lower() == "mega ring", getItemNameById(MEGA_LAST_STONE_ID))

    local BAG = { x = CONTAINER_POSITION, y = 64, z = 0 }
    local function craft(useRing)
        local ring = getThing(doPlayerAddItem(cid, MEGA_ITEM_IDS.EMPTY_RING, 1))
        local key = getThing(doPlayerAddItem(cid, MEGA_ITEM_IDS.KEY_STONE, 1))
        local used, target = key, ring
        if (useRing) then
            used, target = ring, key
        end
        local rings = getPlayerItemCount(cid, MEGA_ITEM_IDS.RING)
        local ok = MegaEvolution.onRingPartUse(cid, used, BAG, target, BAG)
        return ok and getPlayerItemCount(cid, MEGA_ITEM_IDS.RING) == rings + 1
            and getPlayerItemCount(cid, MEGA_ITEM_IDS.EMPTY_RING) == 0 and getPlayerItemCount(cid, MEGA_ITEM_IDS.KEY_STONE) == 0,
            string.format("%s on %s, rings %d", tostring(used.itemid), tostring(target.itemid),
                getPlayerItemCount(cid, MEGA_ITEM_IDS.RING))
    end
    check("mega: the Key Stone on the empty ring makes the Mega Ring", craft(false))
    check("mega: the empty ring on the Key Stone makes the Mega Ring", craft(true))
    doPlayerRemoveItem(cid, MEGA_ITEM_IDS.RING, 2)

    local ring = getThing(doPlayerAddItem(cid, MEGA_ITEM_IDS.EMPTY_RING, 1))
    local key = getThing(doPlayerAddItem(cid, MEGA_ITEM_IDS.KEY_STONE, 1))
    local floor = getCreaturePosition(cid)
    check("mega: both parts must be in the bag", not MegaEvolution.onRingPartUse(cid, key, floor, ring, BAG)
        and getPlayerItemCount(cid, MEGA_ITEM_IDS.KEY_STONE) == 1, getPlayerItemCount(cid, MEGA_ITEM_IDS.KEY_STONE))
    check("mega: the Key Stone only goes on the empty ring", not MegaEvolution.onRingPartUse(cid, key, BAG,
        getThing(doPlayerAddItem(cid, 2148, 1)), BAG))
    doPlayerRemoveItem(cid, MEGA_ITEM_IDS.EMPTY_RING, 1)
    doPlayerRemoveItem(cid, MEGA_ITEM_IDS.KEY_STONE, 1)
    doPlayerRemoveItem(cid, 2148, 1)

    local VENUSAURITE = MEGA_FIRST_STONE_ID
    local ball = newBall(cid, "Bulbasaur", 30)
    check("mega: Venusaurite is a held item", PokemonHeldItem.isHeldItem(VENUSAURITE))
    local name = PokemonHeldItem.give(cid, ball.uid, getThing(doPlayerAddItem(cid, VENUSAURITE, 1)))
    local stone = PokemonHeldItem.getMegaStone(ball.uid)
    check("mega: giving Venusaurite", name == "Venusaurite" and stone and stone.form == "Mega Venusaur" and
        getPlayerItemCount(cid, VENUSAURITE) == 0, name)
    check("mega: the stone's description", (PokemonHeldItem.getBallDescription(ball.uid) or ""):find("Venusaurite", 1, true),
        PokemonHeldItem.getBallDescription(ball.uid))
    check("mega: the GTS refuses a ball holding a Mega Stone", GTS.ballProblem(cid, ball) == "Take its Mega Stone off first.",
        GTS.ballProblem(cid, ball))
    local locked = MegaEvolution.isStoneLocked
    MegaEvolution.isStoneLocked = function() return true end
    local taken, why = PokemonHeldItem.take(cid, ball.uid)
    MegaEvolution.isStoneLocked = locked
    check("mega: a locked stone stays on", not taken and why and getBallHeld(ball.uid) ~= nil, why)
    name = PokemonHeldItem.take(cid, ball.uid)
    check("mega: taking the stone back", name == "Venusaurite" and getPlayerItemCount(cid, VENUSAURITE) == 1, name)
    check("mega: the GTS takes the ball again", GTS.ballProblem(cid, ball) == nil, GTS.ballProblem(cid, ball))
    doPlayerRemoveItem(cid, VENUSAURITE, 1)
    doRemoveItem(ball.uid)

    local stones = 0
    for _, category in ipairs(GTS.CATEGORIES) do
        if (category.name == "Mega Stones") then
            stones = #category.items
        end
    end
    check("mega: the GTS lists the stones", stones == 94, stones)

    local given = getPlayerItemCount(cid, MEGA_ITEM_IDS.EMPTY_RING)
    quietly(function() MegaEvolution.giveTestItems(cid) end)
    check("mega: /megaitems gives the ring parts and stones", getPlayerItemCount(cid, MEGA_ITEM_IDS.EMPTY_RING) == given + 1
        and getPlayerItemCount(cid, MEGA_ITEM_IDS.KEY_STONE) == 1 and getPlayerItemCount(cid, MEGA_LAST_STONE_ID) == 1,
        string.format("%d rings, %d key stones, %d blue orbs", getPlayerItemCount(cid, MEGA_ITEM_IDS.EMPTY_RING),
            getPlayerItemCount(cid, MEGA_ITEM_IDS.KEY_STONE), getPlayerItemCount(cid, MEGA_LAST_STONE_ID)))
    for id = MEGA_ITEM_IDS.EMPTY_RING, MEGA_LAST_STONE_ID do
        doPlayerRemoveItem(cid, id, getPlayerItemCount(cid, id))
    end
end

-- The Mega animation's wait before the burst is off, so the checks see the form at once
local function withoutMegaBurst(fn)
    return function(...)
        local burst = MegaEvolution.BURST_MS
        MegaEvolution.BURST_MS = 0
        local ok, err = pcall(fn, ...)
        MegaEvolution.BURST_MS = burst
        if (not ok) then
            error(err, 0)
        end
    end
end

local function testMegaForms(cid)
    local function hasTypes(pokemon, expected)
        local types = getPokemonTypes(pokemon)
        if (#types ~= #expected) then
            return false
        end
        for i, element in ipairs(expected) do
            if (types[i] ~= element) then
                return false
            end
        end
        return true
    end

    local looks = { ["Mega Venusaur"] = 2595, ["Mega Charizard X"] = 2596, ["Mega Charizard Y"] = 2597,
        ["Mega Blastoise"] = 2598, ["Shiny Mega Venusaur"] = 2630, ["Shiny Mega Charizard X"] = 2631,
        ["Shiny Mega Charizard Y"] = 2632, ["Shiny Mega Blastoise"] = 2633 }
    for form, look in pairs(looks) do
        local definition = getPokemonDefinition(form)
        local info = getMonsterInfo(form)
        check("mega forms: " .. form .. " has a config, a look and a portrait", MegaEvolution.hasForm(form) and
            info and info.outfit.lookType == look and definition.portrait ~= 0 and definition.fastcallPortrait ~= 0,
            info and info.outfit.lookType)
    end
    check("mega forms: the base Pokemon is not a form", not MegaEvolution.hasForm("Charizard"))

    local charizardX, charizardY = MEGA_STONES[2], MEGA_STONES[3]
    check("mega forms: the stones map to forms", MegaEvolution.formFor("Charizard", charizardX) == "Mega Charizard X"
        and MegaEvolution.formFor("Shiny Charizard", charizardY) == "Shiny Mega Charizard Y"
        and MegaEvolution.formFor("Blastoise", charizardX) == nil,
        tostring(MegaEvolution.formFor("Shiny Charizard", charizardY)))

    check("mega forms: Dragon Claw makes contact, Water Pulse is a pulse", getPokemonSkillMakeContact("Dragon Claw")
        and getPokemonSkillIsPulse("Water Pulse") and not getPokemonSkillIsPulse("Dragon Claw")
        and not getPokemonSkillMakeContact("Camouflage"))
    local ids, moveCheck = POKEMON_SPECIAL_ABILITY_IDS, getPokemonSpecialAbilityMoveCheck
    check("mega forms: Drought, Tough Claws and Mega Launcher pick their moves",
        moveCheck(ids.DROUGHT, "Flamethrower") and not moveCheck(ids.DROUGHT, "Water Pulse")
        and moveCheck(ids.TOUGH_CLAWS, "Dragon Claw") and not moveCheck(ids.TOUGH_CLAWS, "Flamethrower")
        and moveCheck(ids.MEGA_LAUNCHER, "Dragon Pulse") and not moveCheck(ids.MEGA_LAUNCHER, "Hydro Pump"))

    if (isPokemonOnline(cid) or isItem(getPlayerSlotItem(cid, PLAYER_SLOT_BALL))) then
        check("mega forms: ball slot free for the test", false)
        return
    end
    local function callOut(name)
        local ball = newBall(cid, name, 50, POKEMON_SEX_MALE)
        doMovePlayerItem(cid, ball.uid, { y = PLAYER_SLOT_BALL, z = 0 })
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        return getPlayerPokemon(cid)
    end
    local function callBack()
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        doRemoveConditions(cid, false)
        local slot = getPlayerSlotItem(cid, PLAYER_SLOT_BALL)
        if (isItem(slot)) then
            doRemoveItem(slot.uid)
        end
    end

    local pokemon = callOut("Charizard")
    if (not isCreature(pokemon)) then
        check("mega forms: Charizard comes out", false)
        callBack()
        return
    end
    local ability, look = getMonsterSpecialAbility(pokemon), getCreatureOutfit(pokemon).lookType
    local atk, spAtk = getPokemonAtk(pokemon, 50), getPokemonSpAtk(pokemon, 50)
    quietly(function() MegaEvolution.onStaffCommand(cid, "x") end)
    check("mega forms: /mega x makes Mega Charizard X", MegaEvolution.isMega(pokemon)
        and getPokemonReferenceName(pokemon) == "Mega Charizard X", getPokemonReferenceName(pokemon))
    check("mega forms: Mega Charizard X is Fire/Dragon", hasTypes(pokemon, { ELEMENT_FIRE, ELEMENT_DRAGON }))
    check("mega forms: Mega Charizard X hits harder", getPokemonAtk(pokemon, 50) > atk
        and getPokemonSpAtk(pokemon, 50) > spAtk, string.format("%.1f > %.1f", getPokemonAtk(pokemon, 50), atk))
    check("mega forms: Mega Charizard X has Tough Claws",
        getMonsterSpecialAbility(pokemon) == POKEMON_SPECIAL_ABILITY_IDS.TOUGH_CLAWS, getMonsterSpecialAbility(pokemon))
    check("mega forms: Mega Charizard X's look", getCreatureOutfit(pokemon).lookType == 2596,
        getCreatureOutfit(pokemon).lookType)
    local portrait = getPlayerSlotItem(cid, PLAYER_SLOT_PORTRAIT)
    check("mega forms: the Mega's portrait is worn in the portrait slot, not put in the bag",
        isItem(portrait) and portrait.itemid == getPokemonPortraitId("Mega Charizard X")
        and getPlayerItemCount(cid, getPokemonPortraitId("Mega Charizard X")) == 1,
        string.format("slot %s, %d carried", tostring(portrait and portrait.itemid),
            getPlayerItemCount(cid, getPokemonPortraitId("Mega Charizard X"))))
    local again
    quietly(function() again = MegaEvolution.onStaffCommand(cid, "y") end)
    check("mega forms: a second /mega is refused", not again and getPokemonReferenceName(pokemon) == "Mega Charizard X")

    quietly(function() MegaEvolution.onStaffCommand(cid, "off") end)
    check("mega forms: /mega off turns it back", not MegaEvolution.isMega(pokemon)
        and hasTypes(pokemon, { ELEMENT_FIRE, ELEMENT_FLYING }) and getMonsterSpecialAbility(pokemon) == ability
        and getCreatureOutfit(pokemon).lookType == look and math.abs(getPokemonAtk(pokemon, 50) - atk) < 0.01,
        string.format("%s, ability %s, look %d", getPokemonReferenceName(pokemon), tostring(getMonsterSpecialAbility(pokemon)),
            getCreatureOutfit(pokemon).lookType))

    quietly(function() MegaEvolution.onStaffCommand(cid, "y") end)
    check("mega forms: Mega Charizard Y keeps Fire/Flying and has Drought", getPokemonReferenceName(pokemon) == "Mega Charizard Y"
        and hasTypes(pokemon, { ELEMENT_FIRE, ELEMENT_FLYING })
        and getMonsterSpecialAbility(pokemon) == POKEMON_SPECIAL_ABILITY_IDS.DROUGHT
        and getCreatureOutfit(pokemon).lookType == 2597, getCreatureOutfit(pokemon).lookType)
    check("mega forms: Drought boosts its own Fire moves", doPokemonSpecialAbilityCheck(pokemon,
        POKEMON_SPECIAL_ABILITY_IDS.DROUGHT, nil, "Flamethrower"))
    callBack()

    pokemon = callOut("Shiny Charizard")
    if (isCreature(pokemon)) then
        quietly(function() MegaEvolution.onStaffCommand(cid, "x") end)
        check("mega forms: a Shiny Charizard becomes Shiny Mega Charizard X",
            getPokemonReferenceName(pokemon) == "Shiny Mega Charizard X" and getCreatureOutfit(pokemon).lookType == 2631,
            getPokemonReferenceName(pokemon))
    else
        check("mega forms: Shiny Charizard comes out", false)
    end
    callBack()

    pokemon = callOut("Blastoise")
    if (isCreature(pokemon)) then
        local ball = getPlayerBall(cid)
        PokemonHeldItem.give(cid, ball.uid, getThing(doPlayerAddItem(cid, MEGA_STONES[4].itemId, 1)))
        quietly(function() MegaEvolution.onStaffCommand(cid, "") end)
        check("mega forms: /mega uses the held Blastoisinite", getPokemonReferenceName(pokemon) == "Mega Blastoise"
            and getMonsterSpecialAbility(pokemon) == POKEMON_SPECIAL_ABILITY_IDS.MEGA_LAUNCHER,
            getPokemonReferenceName(pokemon))
    else
        check("mega forms: Blastoise comes out", false)
    end
    callBack()
    doPlayerRemoveItem(cid, MEGA_STONES[4].itemId, getPlayerItemCount(cid, MEGA_STONES[4].itemId))
end

-- The Megas after the starters, and Primal Groudon and Kyogre
local function testMoreMegas(cid)
    local E = function(...) return { ... } end
    local forms = {
        { "Mega Beedrill", 2607, 2634, E(ELEMENT_BUG, ELEMENT_POISON), "ADAPTABILITY" },
        { "Mega Pidgeot", 2608, 2635, E(ELEMENT_NORMAL, ELEMENT_FLYING), "NO_GUARD" },
        { "Mega Alakazam", 2599, 2636, E(ELEMENT_PSYCHIC), "TRACE" },
        { "Mega Slowbro", 2609, 2637, E(ELEMENT_WATER, ELEMENT_PSYCHIC), "SHELL_ARMOR" },
        { "Mega Gengar", 2600, 2638, E(ELEMENT_GHOST, ELEMENT_POISON), "SHADOW_TAG" },
        { "Mega Kangaskhan", 2601, 2639, E(ELEMENT_NORMAL), "PARENTAL_BOND" },
        { "Mega Gyarados", 2610, 2611, E(ELEMENT_WATER, ELEMENT_DARK), "MOLD_BREAKER" },
        { "Mega Aerodactyl", 2612, 2640, E(ELEMENT_ROCK, ELEMENT_FLYING), "TOUGH_CLAWS" },
        { "Mega Ampharos", 2602, 2603, E(ELEMENT_ELECTRIC, ELEMENT_DRAGON), "MOLD_BREAKER" },
        { "Mega Steelix", 2613, 2641, E(ELEMENT_STEEL, ELEMENT_GROUND), "SAND_FORCE" },
        { "Mega Scizor", 2614, 2642, E(ELEMENT_BUG, ELEMENT_STEEL), "TECHNICIAN" },
        { "Mega Tyranitar", 2604, 2643, E(ELEMENT_ROCK, ELEMENT_DARK), "SAND_STREAM" },
        { "Mega Sceptile", 2615, 2644, E(ELEMENT_GRASS, ELEMENT_DRAGON), "LIGHTNINGROD" },
        { "Mega Blaziken", 2605, 2645, E(ELEMENT_FIRE, ELEMENT_FIGHT), "SPEED_BOOST" },
        { "Mega Swampert", 2616, 2646, E(ELEMENT_WATER, ELEMENT_GROUND), "SWIFT_SWIM" },
        { "Mega Sableye", 2617, 2647, E(ELEMENT_DARK, ELEMENT_GHOST), "MAGIC_BOUNCE" },
        { "Mega Mawile", 2625, 2648, E(ELEMENT_STEEL, ELEMENT_FAIRY), "HUGE_POWER" },
        { "Mega Sharpedo", 2618, 2649, E(ELEMENT_WATER, ELEMENT_DARK), "STRONG_JAW" },
        { "Mega Camerupt", 2619, 2650, E(ELEMENT_FIRE, ELEMENT_GROUND), "SHEER_FORCE" },
        { "Mega Altaria", 2620, 2651, E(ELEMENT_DRAGON, ELEMENT_FAIRY), "PIXILATE" },
        { "Mega Absol", 2621, 2652, E(ELEMENT_DARK), "MAGIC_BOUNCE" },
        { "Mega Glalie", 2622, 2653, E(ELEMENT_ICE), "REFRIGERATE" },
        { "Mega Latias", 2626, nil, E(ELEMENT_DRAGON, ELEMENT_PSYCHIC), "LEVITATE" },
        { "Primal Kyogre", 2628, nil, E(ELEMENT_WATER), "PRIMORDIAL_SEA" },
        { "Primal Groudon", 2627, nil, E(ELEMENT_GROUND, ELEMENT_FIRE), "DESOLATE_LAND" },
    }
    local function sameTypes(types, expected)
        if (#types ~= #expected) then
            return false
        end
        for i, element in ipairs(expected) do
            if (types[i] ~= element) then
                return false
            end
        end
        return true
    end
    for _, f in ipairs(forms) do
        local name, look, shinyLook, types, ability = f[1], f[2], f[3], f[4], f[5]
        local definition, info = getPokemonDefinition(name), getMonsterInfo(name)
        local shiny, shinyInfo = getPokemonDefinition("Shiny " .. name), getMonsterInfo("Shiny " .. name)
        local problem = (not MegaEvolution.hasForm(name) and "no form")
                or ((not info or info.outfit.lookType ~= look) and "look " .. tostring(info and info.outfit.lookType))
                or ((definition.portrait == 0 or definition.fastcallPortrait == 0) and "no face")
                or (not sameTypes(definition.pTypes, types) and "types")
                or ((definition.specialAbilities[1] ~= POKEMON_SPECIAL_ABILITY_IDS[ability]) and "ability")
                or (shinyLook and (not shiny or shiny.portrait == 0 or not shinyInfo or shinyInfo.outfit.lookType ~= shinyLook)
                    and "shiny " .. tostring(shinyInfo and shinyInfo.outfit.lookType))
                or (not shinyLook and shiny and "a shiny that can't be caught")
        check("more megas: " .. name .. " has its look, face, types and ability", not problem, problem)
    end
    local inGame = 0
    for _, stone in ipairs(MEGA_STONES) do
        if (MegaEvolution.hasForm(stone.form)) then
            inGame = inGame + 1
        end
    end
    check("more megas: 29 stones and orbs work", inGame == 29, inGame)

    local ids, moveCheck = POKEMON_SPECIAL_ABILITY_IDS, getPokemonSpecialAbilityMoveCheck
    check("more megas: Strong Jaw, Sand Force and Sheer Force pick their moves",
        moveCheck(ids.STRONG_JAW, "Crunch") and moveCheck(ids.STRONG_JAW, "Fire Fang") and not moveCheck(ids.STRONG_JAW, "Tackle")
        and moveCheck(ids.SAND_FORCE, "Rock Slide") and not moveCheck(ids.SAND_FORCE, "Flamethrower")
        and moveCheck(ids.SHEER_FORCE, "Flamethrower") and not moveCheck(ids.SHEER_FORCE, "Earthquake")
        and not moveCheck(ids.SHEER_FORCE, "Tackle"))
    check("more megas: Desolate Land boosts Fire, Primordial Sea boosts Water",
        moveCheck(ids.DESOLATE_LAND, "Flamethrower") and not moveCheck(ids.DESOLATE_LAND, "Water Pulse")
        and moveCheck(ids.PRIMORDIAL_SEA, "Water Pulse") and not moveCheck(ids.PRIMORDIAL_SEA, "Flamethrower"))

    if (isPokemonOnline(cid) or isItem(getPlayerSlotItem(cid, PLAYER_SLOT_BALL))) then
        check("more megas: ball slot free for the test", false)
        return
    end
    local function callOut(name, level)
        local ball = newBall(cid, name, level or 50, POKEMON_SEX_MALE)
        doMovePlayerItem(cid, ball.uid, { y = PLAYER_SLOT_BALL, z = 0 })
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        return getPlayerPokemon(cid)
    end
    local function callBack()
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        doRemoveConditions(cid, false)
        local slot = getPlayerSlotItem(cid, PLAYER_SLOT_BALL)
        if (isItem(slot)) then
            doRemoveItem(slot.uid)
        end
    end

    local pokemon = callOut("Altaria")
    if (isCreature(pokemon)) then
        local before = getPokemonSkillDamageTypeOf(pokemon, "Tackle")
        quietly(function() MegaEvolution.onStaffCommand(cid, "") end)
        check("more megas: Mega Altaria's Pixilate makes Tackle a Fairy move", before == ELEMENT_NORMAL
            and getPokemonReferenceName(pokemon) == "Mega Altaria"
            and getPokemonSkillDamageTypeOf(pokemon, "Tackle") == ELEMENT_FAIRY
            and getPokemonSkillDamageTypeOf(pokemon, "Dragon Pulse") == ELEMENT_DRAGON, getPokemonReferenceName(pokemon))
    else
        check("more megas: Altaria comes out", false)
    end
    callBack()

    local stoneOf = {}
    for _, stone in ipairs(MEGA_STONES) do
        stoneOf[stone.form] = stone.itemId
    end
    pokemon = callOut("Groudon", 70)
    if (isCreature(pokemon)) then
        local orb = getThing(doPlayerAddItem(cid, stoneOf["Primal Groudon"], 1))
        PokemonHeldItem.give(cid, getPlayerBall(cid).uid, orb)
        quietly(function() MegaEvolution.onStaffCommand(cid, "") end)
        check("more megas: Groudon with the Red Orb becomes Primal Groudon, Ground/Fire with Desolate Land",
            getPokemonReferenceName(pokemon) == "Primal Groudon" and sameTypes(getPokemonTypes(pokemon), { ELEMENT_GROUND, ELEMENT_FIRE })
            and getMonsterSpecialAbility(pokemon) == ids.DESOLATE_LAND and getCreatureOutfit(pokemon).lookType == 2627,
            getPokemonReferenceName(pokemon))
        PokemonHeldItem.take(cid, getPlayerBall(cid).uid)
    else
        check("more megas: Groudon comes out", false)
    end
    callBack()
    doPlayerRemoveItem(cid, stoneOf["Primal Groudon"], getPlayerItemCount(cid, stoneOf["Primal Groudon"]))

    pokemon = callOut("Gyarados")
    local wild
    if (isCreature(pokemon)) then
        quietly(function() MegaEvolution.onStaffCommand(cid, "") end)
        local here = getCreaturePosition(cid)
        for dx = -2, 2 do
            for dy = -2, 2 do
                if (not isMonster(wild) and (dx ~= 0 or dy ~= 0)) then
                    wild = doCreateMonster("Rattata", { x = here.x + dx, y = here.y + dy, z = here.z }, false)
                end
            end
        end
    end
    if (isMonster(wild) and MegaEvolution.isMega(pokemon)) then
        doCreatureSetNoMove(wild, true)
        setMonsterSpecialAbility(wild, ids.LEVITATE)
        local alone = doPokemonSpecialAbilityCheck(wild, ids.LEVITATE, nil, "Earthquake")
        local broken = doWithMoldBreaker(pokemon, doPokemonSpecialAbilityCheck, wild, ids.LEVITATE, nil, "Earthquake")
        local plain = doWithMoldBreaker(wild, doPokemonSpecialAbilityCheck, wild, ids.LEVITATE, nil, "Earthquake")
        check("more megas: Mega Gyarados' Mold Breaker gets past Levitate, only while it attacks",
            alone and not broken and plain and doPokemonSpecialAbilityCheck(wild, ids.LEVITATE, nil, "Earthquake"))

        setMonsterSpecialAbility(wild, ids.MAGIC_BOUNCE)
        quietly(function() doCreatureAddStatus(wild, CREATURE_STATUS_CONFUSION, nil, pokemon) end)
        check("more megas: Magic Bounce sends a confusion back", getCreatureStatus(pokemon, CREATURE_STATUS_CONFUSION)
            and not getCreatureStatus(wild, CREATURE_STATUS_CONFUSION))
        doCreatureRemoveStatus(pokemon, CREATURE_STATUS_CONFUSION)

        setMonsterSpecialAbility(wild, ids.DESOLATE_LAND)
        local health = getCreatureHealth(wild)
        quietly(function() doSkillDamage(pokemon, wild, "Water Pulse") end)
        check("more megas: Water moves evaporate on Desolate Land", isCreature(wild)
            and health - getCreatureHealth(wild) <= 1, isCreature(wild) and health - getCreatureHealth(wild))
        local result
        quietly(function() result = { doWithMoldBreaker(pokemon, function() return 1, nil, 3 end) } end)
        check("more megas: a hit's results come back through the Mold Breaker wrapper", result[1] == 1
            and result[2] == nil and result[3] == 3)
        doRemoveCreature(wild)
    else
        check("more megas: Mega Gyarados and a wild Rattata for the ability checks", false)
    end
    callBack()
end

local function testMegaDrops(cid)
    local function names(drops)
        local out = {}
        for _, stone in ipairs(drops or {}) do
            out[#out + 1] = stone.name
        end
        table.sort(out)
        return table.concat(out, ",")
    end
    check("mega drops: 1 in 250,000 for stones and orbs", MegaEvolution.DROP_CHANCE == 250000
        and MegaEvolution.ORB_DROP_CHANCE == 250000)
    check("mega drops: the whole line drops the stone, shinies too", names(MegaEvolution.getDrops("Bulbasaur")) == "Venusaurite"
        and names(MegaEvolution.getDrops("Shiny Ivysaur")) == "Venusaurite" and names(MegaEvolution.getDrops("Venusaur")) == "Venusaurite",
        names(MegaEvolution.getDrops("Shiny Ivysaur")))
    check("mega drops: Charmander's line drops either Charizardite", names(MegaEvolution.getDrops("Charmander")) == "Charizardite X,Charizardite Y",
        names(MegaEvolution.getDrops("Charmander")))
    check("mega drops: Groudon and Kyogre drop their orbs", names(MegaEvolution.getDrops("Groudon")) == "Red Orb"
        and names(MegaEvolution.getDrops("Kyogre")) == "Blue Orb")
    check("mega drops: a Pokemon with no Mega line drops nothing", MegaEvolution.getDrops("Rattata") == nil
        and MegaEvolution.getDrops("Slowking") == nil and names(MegaEvolution.getDrops("Slowpoke")) == "Slowbronite")

    local text, original, knowledge = "", doSendPlayerExtendedOpcode, Pokepedia.getKnowledge
    Pokepedia.onClientMessage(cid, '{"action":"hello"}')
    Pokepedia.getKnowledge = function(player, name)
        local result = knowledge(player, name)
        if (result) then
            result.level = 3
        end
        return result
    end
    doSendPlayerExtendedOpcode = function(target, opcode, buffer)
        if (opcode == EXTENDED_IDS.POKEPEDIA) then
            text = text .. buffer:gsub("^#%d+:%d+:%d+:", "")
            return true
        end
        return original(target, opcode, buffer)
    end
    local sentOk, sentErr = pcall(Pokepedia.sendDex, cid, "Charmander")
    doSendPlayerExtendedOpcode, Pokepedia.getKnowledge = original, knowledge
    local decoded, dex = pcall(JSON.decode, text)
    local chances = {}
    for _, drop in ipairs(decoded and type(dex) == "table" and dex.drops or {}) do
        if (drop.name == "Charizardite X" or drop.name == "Charizardite Y") then
            chances[#chances + 1] = tonumber(drop.chance) or 0
        end
    end
    check("mega drops: Charmander's Pokepedia drops list both Charizardites, 1 in 500,000 each",
        sentOk and #chances == 2 and math.abs(chances[1] - 0.0002) < 1e-9 and math.abs(chances[2] - 0.0002) < 1e-9,
        tostring(sentErr) .. " " .. text:sub(1, 200))

    local x, y
    for _, stone in ipairs(MEGA_STONES) do
        x = stone.name == "Charizardite X" and stone.itemId or x
        y = stone.name == "Charizardite Y" and stone.itemId or y
    end
    local function stones()
        return getPlayerItemCount(cid, x) + getPlayerItemCount(cid, y)
    end
    local here = getCreaturePosition(cid)
    local wild
    for dx = -2, 2 do
        for dy = -2, 2 do
            if (not isMonster(wild) and (dx ~= 0 or dy ~= 0)) then
                wild = doCreateMonster("Charmander", { x = here.x + dx, y = here.y + dy, z = here.z }, false)
            end
        end
    end
    if (not isMonster(wild)) then
        check("mega drops: a wild Charmander", false)
        return
    end
    doCreatureSetNoMove(wild, true)
    local chance, before = MegaEvolution.DROP_CHANCE, stones()
    MegaEvolution.DROP_CHANCE = 1
    quietly(function() MegaEvolution.onKill(cid, wild) end)
    local dropped = stones() - before
    MegaEvolution.DROP_CHANCE = 1000000000
    quietly(function() MegaEvolution.onKill(cid, wild) end)
    MegaEvolution.DROP_CHANCE = chance
    check("mega drops: a defeated wild Charmander drops a Charizardite", dropped == 1, dropped)
    check("mega drops: the roll uses DROP_CHANCE", stones() - before == 1, stones() - before)
    doRemoveCreature(wild)
    doPlayerRemoveItem(cid, x, getPlayerItemCount(cid, x))
    doPlayerRemoveItem(cid, y, getPlayerItemCount(cid, y))
end

local function testMegaQuest(cid)
    local M = MegaEvolution
    local quests = {}
    for _, quest in ipairs(getNpcQuests("Professor Oak")) do
        quests[quest.storage] = quest
    end
    local research, keyStone = quests[M.RESEARCH_QUEST], quests[M.KEY_STONE_QUEST]
    check("mega quest: Professor Oak has the research and the Key Stone quests", research and keyStone
        and research.requiredLevel == 60 and keyStone.blockStart)
    if (not research or not keyStone) then
        return
    end
    local stoneOf = {}
    for _, stone in ipairs(MEGA_STONES) do
        stoneOf[stone.name] = stone.itemId
    end
    local function names(list)
        local out = {}
        for _, stone in ipairs(list) do
            out[#out + 1] = stone.name
        end
        table.sort(out)
        return table.concat(out, ",")
    end
    local storages = { M.RESEARCH_QUEST, M.KEY_STONE_QUEST, M.KEY_STONE_FOUND, M.STONE_CHOICE,
        playersStorages.megaResearch, playersStorages.megaStarter }
    local saved = {}
    for i, storage in ipairs(storages) do
        saved[i] = getPlayerStorageValue(cid, storage)
        setPlayerStorageValue(cid, storage, -1)
    end

    -- the starter's stone
    setPlayerStorageValue(cid, playersStorages.megaStarter, "Squirtle")
    local squirtle = names(M.starterStones(cid))
    setPlayerStorageValue(cid, playersStorages.megaStarter, "Charmander")
    local charmander = names(M.starterStones(cid))
    check("mega quest: the stones of the starter Oak wrote down", squirtle == "Blastoisinite"
        and charmander == "Charizardite X,Charizardite Y", squirtle .. " / " .. charmander)
    setPlayerStorageValue(cid, playersStorages.megaStarter, -1)
    local unknown = names(M.starterStones(cid))
    local ball = newBall(cid, "Ivysaur", 30, POKEMON_SEX_MALE)
    setBallOriginalTrainer(ball.uid, cid)
    local older = names(M.starterStones(cid))
    doRemoveItem(ball.uid)
    check("mega quest: an older trainer's starter is the Pokemon with their own trainer mark, even evolved",
        older == "Venusaurite" and (unknown == "Blastoisinite,Charizardite X,Charizardite Y,Venusaurite"
        or M.STARTER_LINES[getPlayerStorageValue(cid, playersStorages.megaStarter)] == nil), older .. " / " .. unknown)

    -- the research
    setPlayerStorageValue(cid, M.RESEARCH_QUEST, QUEST_STATUS.STARTED)
    quietly(function()
        for _ = 1, 60 do M.onResearchDefeat(cid, "Charmander") end
        for _ = 1, 50 do M.onResearchDefeat(cid, "Shiny Ivysaur") end
        for _ = 1, 5 do M.onResearchDefeat(cid, "Rattata") end
        M.onResearchDefeat(cid, "Groudon")
        for _ = 1, 49 do M.onResearchDefeat(cid, "Gastly") end
    end)
    local have, need = M.researchProgress(cid)
    local early = research.questRequest(cid)
    quietly(function() M.onResearchDefeat(cid, "Haunter") end)
    local done = research.questRequest(cid)
    check("mega quest: 50 defeats from each of three Mega Stone lines, shinies count, others don't",
        have == 149 and need == 150 and not early and done, have .. "/" .. need)
    local logHave, logNeed = Quests.progress(cid, research)
    check("mega quest: the quest log shows the research", logHave == 150 and logNeed == 150
        and Quests.objective(research):find("three Mega Stone") ~= nil)

    -- the crystal and its guardian
    local crystal = getTileItemById(M.CRYSTAL, M.CRYSTAL_ITEM)
    check("mega quest: the glowing crystal is in Cerulean Cave", isItem(crystal) and crystal.actionid == M.CRYSTAL_ACTION,
        isItem(crystal) and crystal.actionid)
    if (isItem(crystal)) then
        local idle, after
        quietly(function() idle = M.onCrystalUse(cid, crystal) end)
        setPlayerStorageValue(cid, M.KEY_STONE_QUEST, QUEST_STATUS.STARTED)
        local guardian
        quietly(function() guardian = M.onCrystalUse(cid, crystal) end)
        local second
        quietly(function() second = M.onCrystalUse(cid, crystal) end)
        check("mega quest: on the quest the crystal calls the Guardian Alakazam, once", idle == nil and isCreature(guardian)
            and getCreatureName(guardian) == "Guardian Alakazam" and second == nil)
        local keys = getPlayerItemCount(cid, MEGA_ITEM_IDS.KEY_STONE)
        if (isCreature(guardian)) then
            quietly(function() M.onGuardianDeath(guardian, { cid }) end)
        end
        quietly(function() after = M.onCrystalUse(cid, crystal) end)
        check("mega quest: defeating the guardian gives the Key Stone, once", not isCreature(guardian)
            and getPlayerItemCount(cid, MEGA_ITEM_IDS.KEY_STONE) == keys + 1
            and getPlayerStorageValue(cid, M.KEY_STONE_FOUND) == QUEST_STATUS.FINISHED
            and after == nil)
        doPlayerRemoveItem(cid, MEGA_ITEM_IDS.KEY_STONE, 1)
    end

    -- the Mega Ring and the stone
    local hadRing = M.ownsRing(cid)
    local ring = not hadRing and doPlayerAddItem(cid, MEGA_ITEM_IDS.RING, 1)
    check("mega quest: showing Oak the Mega Ring ends the Key Stone quest", keyStone.questRequest(cid))
    local said, say = {}, selfSay
    selfSay = function(text) said[#said + 1] = text end
    setPlayerStorageValue(cid, playersStorages.megaStarter, "Squirtle")
    local before = getPlayerItemCount(cid, stoneOf["Blastoisinite"])
    pcall(M.onKeyStoneQuestEnd, cid)
    check("mega quest: a Squirtle starter gets Blastoisinite at once", getPlayerItemCount(cid, stoneOf["Blastoisinite"]) == before + 1
        and getPlayerStorageValue(cid, M.STONE_CHOICE) == QUEST_STATUS.FINISHED)
    setPlayerStorageValue(cid, playersStorages.megaStarter, "Charmander")
    setPlayerStorageValue(cid, M.STONE_CHOICE, -1)
    local x, y = getPlayerItemCount(cid, stoneOf["Charizardite X"]), getPlayerItemCount(cid, stoneOf["Charizardite Y"])
    pcall(M.onKeyStoneQuestEnd, cid)
    local asked = getPlayerStorageValue(cid, M.STONE_CHOICE) == QUEST_STATUS.STARTED and (said[#said] or ""):find("Charizardite X") ~= nil
    local _, other = pcall(M.onStoneChoiceTalk, cid, "banana")
    local _, picked = pcall(M.onStoneChoiceTalk, cid, "y")
    selfSay = say
    check("mega quest: a Charmander starter picks Charizardite X or Y", asked and other and picked
        and getPlayerItemCount(cid, stoneOf["Charizardite Y"]) == y + 1 and getPlayerItemCount(cid, stoneOf["Charizardite X"]) == x
        and getPlayerStorageValue(cid, M.STONE_CHOICE) == QUEST_STATUS.FINISHED and not M.onStoneChoiceTalk(cid, "y"))

    doPlayerRemoveItem(cid, stoneOf["Blastoisinite"], 1)
    doPlayerRemoveItem(cid, stoneOf["Charizardite Y"], 1)
    if (ring) then
        doRemoveItem(ring)
    end
    check("mega quest: the test's ring is gone again", M.ownsRing(cid) == hadRing)
    for i, storage in ipairs(storages) do
        setPlayerStorageValue(cid, storage, saved[i])
    end
end

-- The whole way through the gauge, as a trainer plays it: a shiny, a Primal and a stone with no form yet
local function testMegaCheck(cid)
    if (isItem(getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM)) or isPokemonOnline(cid)
            or isItem(getPlayerSlotItem(cid, PLAYER_SLOT_BALL))) then
        check("mega check: key item and ball slots free for the test", false)
        return
    end
    local M, ids = MegaEvolution, POKEMON_SPECIAL_ABILITY_IDS
    local realPz = getTilePzInfo
    getTilePzInfo = function() return false end
    local stoneOf = {}
    for _, stone in ipairs(MEGA_STONES) do
        stoneOf[stone.name] = stone.itemId
    end
    local function sameTypes(types, expected)
        if (#types ~= #expected) then
            return false
        end
        for i = 1, #types do
            if (types[i] ~= expected[i]) then
                return false
            end
        end
        return true
    end
    local ring = getThing(doPlayerAddItem(cid, MEGA_ITEM_IDS.RING, 1))
    doMovePlayerItem(cid, ring.uid, { y = PLAYER_SLOT_KEY_ITEM, z = 0 })

    -- out with its stone, gauge full, R: the form; then the drain turns it back
    local function megaEvolve(name, level, stoneName)
        local ball = newBall(cid, name, level, POKEMON_SEX_MALE)
        PokemonHeldItem.give(cid, ball.uid, getThing(doPlayerAddItem(cid, stoneOf[stoneName], 1)))
        doMovePlayerItem(cid, ball.uid, { y = PLAYER_SLOT_BALL, z = 0 })
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        local pokemon = getPlayerPokemon(cid)
        local result = { pokemon = pokemon, out = isCreature(pokemon) }
        if (result.out) then
            result.baseSpAtk = getPokemonSpAtk(pokemon, level)
            setPlayerStorageValue(cid, playersStorages.megaGauge, M.MAX)
            quietly(function() result.pressed = M.onPress(cid) end)
            result.form = getPokemonReferenceName(pokemon)
            result.types = getPokemonTypes(pokemon)
            result.ability = getMonsterSpecialAbility(pokemon)
            result.spAtk = getPokemonSpAtk(pokemon, level)
            result.active = M.isActive(cid)
            quietly(function()
                for _ = 1, M.DURATION do M.step(cid) end
            end)
            result.after = getPokemonReferenceName(pokemon)
            result.over = not M.isActive(cid) and M.getGauge(cid) == 0
        end
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        doRemoveConditions(cid, false)
        local slot = getPlayerSlotItem(cid, PLAYER_SLOT_BALL)
        if (isItem(slot)) then
            PokemonHeldItem.take(cid, slot.uid)
            doRemoveItem(slot.uid)
        end
        doPlayerRemoveItem(cid, stoneOf[stoneName], getPlayerItemCount(cid, stoneOf[stoneName]))
        return result
    end

    local ok, err = pcall(function()
        local venusaur = megaEvolve("Shiny Venusaur", 50, "Venusaurite")
        check("mega check: a Shiny Venusaur with Venusaurite Mega Evolves through the gauge", venusaur.out and venusaur.pressed
            and venusaur.active and venusaur.form == "Shiny Mega Venusaur", venusaur.form)
        check("mega check: Shiny Mega Venusaur is Grass/Poison with Thick Fat and more Sp. Atk",
            venusaur.types and sameTypes(venusaur.types, { ELEMENT_GRASS, ELEMENT_POISON }) and venusaur.ability == ids.THICK_FAT
            and (venusaur.spAtk or 0) > (venusaur.baseSpAtk or 0), tostring(venusaur.spAtk) .. " / " .. tostring(venusaur.baseSpAtk))
        check("mega check: after 60 seconds it is a Shiny Venusaur again", venusaur.after == "Shiny Venusaur" and venusaur.over,
            venusaur.after)

        local kyogre = megaEvolve("Kyogre", 70, "Blue Orb")
        check("mega check: Kyogre with the Blue Orb undergoes Primal Reversion through the gauge", kyogre.out and kyogre.active
            and kyogre.form == "Primal Kyogre" and kyogre.ability == ids.PRIMORDIAL_SEA
            and sameTypes(kyogre.types, { ELEMENT_WATER }) and kyogre.after == "Kyogre", kyogre.form)

        local pinsir = megaEvolve("Pinsir", 50, "Pinsirite")
        check("mega check: Pinsirite has no form yet, so Pinsir doesn't Mega Evolve", pinsir.out and not pinsir.pressed
            and not pinsir.active and pinsir.form == "Pinsir" and M.formFor("Pinsir", MEGA_STONE_BY_ITEMID[stoneOf["Pinsirite"]]) == nil,
            pinsir.form)
    end)
    getTilePzInfo = realPz
    setPlayerStorageValue(cid, playersStorages.megaGauge, 0)
    local worn = getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM)
    if (isItem(worn) and worn.itemid == MEGA_ITEM_IDS.RING) then
        doRemoveItem(worn.uid)
    end
    if (not ok) then
        check("mega check: ran without errors", false, err)
    end
end

local function testMegaGauge(cid)
    if (isItem(getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM)) or isPokemonOnline(cid)
            or isItem(getPlayerSlotItem(cid, PLAYER_SLOT_BALL))) then
        check("mega gauge: key item and ball slots free for the test", false)
        return
    end
    local GAUGE = playersStorages.megaGauge
    local realTime, realPz, realDueling, realTournament = os.time, getTilePzInfo, isDueling, getPlayerTournamentReady
    local now = realTime()
    os.time = function(...) if (select("#", ...) > 0) then return realTime(...) end return now end
    getTilePzInfo = function() return false end
    local sent = {}
    local realSend = doSendPlayerExtendedOpcode
    doSendPlayerExtendedOpcode = function(to, opcode, buffer)
        if (opcode == EXTENDED_IDS.MEGA) then
            sent[#sent + 1] = buffer
            return true
        end
        return realSend(to, opcode, buffer)
    end
    local function restore()
        os.time, getTilePzInfo, isDueling, getPlayerTournamentReady = realTime, realPz, realDueling, realTournament
        doSendPlayerExtendedOpcode = realSend
    end
    local function gauge()
        return MegaEvolution.getGauge(cid)
    end
    local function setGauge(value)
        setPlayerStorageValue(cid, GAUGE, value)
    end
    local function why()
        return MegaEvolution.problem(cid) or ""
    end
    -- the stone back in the bag after a take, or a new one (the bag may be too full for one)
    local function stone(index)
        local found = getPlayerItemById(cid, true, MEGA_STONES[index].itemId)
        return isItem(found) and found or getThing(doPlayerAddItem(cid, MEGA_STONES[index].itemId, 1))
    end

    local ok, err = pcall(function()
        setGauge(0)
        setPlayerStorageValue(cid, playersStorages.megaCharges, -1)
        setPlayerStorageValue(cid, playersStorages.megaPvp, -1)
        MegaEvolution.onClientMessage(cid, '{"action":"hello"}')
        local hello = sent[#sent] and JSON.decode(sent[#sent])
        check("mega gauge: the client's hello gets the HUD state", hello and hello.type == "state" and hello.ring == false
            and hello.gauge == 0 and hello.active == false, sent[#sent])

        check("mega gauge: no ring, no Mega", why():find("Mega Ring", 1, true) ~= nil, why())
        local ring = getThing(doPlayerAddItem(cid, MEGA_ITEM_IDS.RING, 1))
        doMovePlayerItem(cid, ring.uid, { y = PLAYER_SLOT_KEY_ITEM, z = 0 })
        ring = getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM)
        check("mega gauge: the Mega Ring goes in the key item slot", MegaEvolution.hasRing(cid), ring.itemid)

        local ball = newBall(cid, "Charizard", 50, POKEMON_SEX_MALE)
        PokemonHeldItem.give(cid, ball.uid, stone(2))
        doMovePlayerItem(cid, ball.uid, { y = PLAYER_SLOT_BALL, z = 0 })
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        local pokemon = getPlayerPokemon(cid)
        ball = getPlayerBall(cid)
        if (not isCreature(pokemon)) then
            check("mega gauge: Charizard comes out", false)
            return
        end

        local pos = getCreaturePosition(cid)
        local rattata = doCreateMonster("Rattata", { x = pos.x + 2, y = pos.y, z = pos.z }, false)
        local oddish = doCreateMonster("Oddish", { x = pos.x - 2, y = pos.y, z = pos.z }, false)
        MegaEvolution.onHit(pokemon, rattata, "Ember")
        check("mega gauge: a damaging hit charges 2", gauge() == 2, gauge())
        MegaEvolution.onHit(pokemon, rattata, "Ember")
        check("mega gauge: one charged hit a second", gauge() == 2, gauge())
        now = now + 1
        MegaEvolution.onHit(pokemon, oddish, "Ember")
        check("mega gauge: a super-effective hit charges 3", gauge() == 5, gauge())
        MegaEvolution.onHit(oddish, pokemon, "Tackle")
        check("mega gauge: taking a hit charges 1", gauge() == 6, gauge())
        MegaEvolution.onHit(oddish, pokemon, "Tackle")
        check("mega gauge: hits taken charge at most every 2 seconds", gauge() == 6, gauge())
        MegaEvolution.onKill(cid, rattata)
        check("mega gauge: defeating a wild Pokemon charges 5", gauge() == 11, gauge())
        setGauge(0)
        for i = 1, MegaEvolution.SAME_TARGET + 2 do
            now = now + 1
            MegaEvolution.onHit(pokemon, rattata, "Ember")
        end
        check("mega gauge: hitting the same target again and again gives less", gauge() == MegaEvolution.SAME_TARGET * 2 + 2,
            gauge())
        local wildCount = #sent
        check("mega gauge: every charge updates the HUD", wildCount > 0 and JSON.decode(sent[#sent]).gauge == gauge(),
            sent[#sent])

        setGauge(98)
        now = now + 1
        MegaEvolution.onHit(pokemon, oddish, "Ember")
        check("mega gauge: it stops at 100", gauge() == 100, gauge())
        check("mega gauge: full, the button lights up", MegaEvolution.state(cid).ready == true)
        doRemoveCreature(rattata)
        doRemoveCreature(oddish)

        getTilePzInfo = function() return true end
        check("mega gauge: no Mega in a protection zone", why():find("protection zone", 1, true) ~= nil, why())
        getTilePzInfo = function() return false end
        getPlayerTournamentReady = function() return true end
        check("mega gauge: off in tournaments", why():find("tournament", 1, true) ~= nil, why())
        getPlayerTournamentReady = realTournament
        check("mega gauge: entering a tournament emptied the gauge", gauge() == 0, gauge())
        MegaEvolution.sync(cid)

        setGauge(100)
        PokemonHeldItem.take(cid, ball.uid)
        quietly(function() MegaEvolution.onPress(cid) end)
        check("mega gauge: no stone, no Mega", not MegaEvolution.isActive(cid) and gauge() == 100)
        PokemonHeldItem.give(cid, ball.uid, stone(4))
        quietly(function() MegaEvolution.onPress(cid) end)
        check("mega gauge: another Pokemon's stone, no Mega", not MegaEvolution.isActive(cid)
            and MegaEvolution.state(cid).ready == false)
        PokemonHeldItem.take(cid, ball.uid)
        local gave, gaveWhy = PokemonHeldItem.give(cid, ball.uid, stone(2))
        check("mega gauge: Charizard holds its Charizardite X again", gave ~= nil, gaveWhy)

        local pressed
        quietly(function() pressed = MegaEvolution.onPress(cid) end)
        check("mega gauge: R Mega Evolves Charizard into Mega Charizard X", pressed and MegaEvolution.isActive(cid)
            and getPokemonReferenceName(pokemon) == "Mega Charizard X" and getCreatureOutfit(pokemon).lookType == 2596,
            getPokemonReferenceName(pokemon))
        local state = MegaEvolution.state(cid)
        local contact = #(state.boosted or {}) > 0
        for _, move in ipairs(state.boosted or {}) do
            contact = contact and getPokemonSkillMakeContact(move)
        end
        check("mega gauge: the HUD gets the form and the boosted contact moves", state.active and state.form == "Mega Charizard X"
            and state.left == MegaEvolution.DURATION and contact, table.concat(state.boosted or {}, ", "))
        check("mega gauge: the stone is locked", MegaEvolution.isStoneLocked(cid, ball.uid)
            and not PokemonHeldItem.take(cid, ball.uid))
        check("mega gauge: the ring is locked", getItemAttribute(ring.uid, "scriptprotected") == true)
        check("mega gauge: no charging while Mega", not MegaEvolution.charge(cid, 5))
        quietly(function() pressed = MegaEvolution.onPress(cid) end)
        check("mega gauge: one Mega at a time", not pressed)

        for i = 1, MegaEvolution.DURATION / 2 do
            MegaEvolution.step(cid)
        end
        check("mega gauge: it drains over 60 seconds", MegaEvolution.isActive(cid) and gauge() == 50, gauge())
        for i = 1, MegaEvolution.DURATION / 2 do
            MegaEvolution.step(cid)
        end
        check("mega gauge: at zero it turns back", not MegaEvolution.isActive(cid) and gauge() == 0
            and getPokemonReferenceName(pokemon) == "Charizard" and getCreatureOutfit(pokemon).lookType ~= 2596,
            getPokemonReferenceName(pokemon))
        check("mega gauge: the ring and stone are free again", not MegaEvolution.isStoneLocked(cid, ball.uid)
            and getItemAttribute(ring.uid, "scriptprotected") ~= true)

        setGauge(100)
        quietly(function() MegaEvolution.onPress(cid) end)
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        check("mega gauge: calling the Pokemon back ends it and empties the gauge", not MegaEvolution.isActive(cid)
            and gauge() == 0 and not isPokemonOnline(cid), gauge())
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        pokemon = getPlayerPokemon(cid)
        check("mega gauge: called again it is Charizard", isCreature(pokemon) and not MegaEvolution.isMega(pokemon))

        setGauge(100)
        quietly(function() MegaEvolution.onPress(cid) end)
        isDueling = function() return true end
        MegaEvolution.sync(cid)
        check("mega gauge: a duel ends it and starts from 0", not MegaEvolution.isActive(cid) and gauge() == 0
            and not MegaEvolution.isMega(pokemon), gauge())
        isDueling = realDueling
        MegaEvolution.sync(cid)

        setGauge(100)
        quietly(function() MegaEvolution.onPress(cid) end)
        MegaEvolution.onLogout(cid)
        check("mega gauge: logging out ends it", not MegaEvolution.isActive(cid) and gauge() == 0
            and not MegaEvolution.isMega(pokemon), gauge())

        setGauge(80)
        setPlayerStorageValue(cid, playersStorages.megaActive, string.format("M1|%d|30", pokemon))
        setItemScriptProtected(ring.uid, true)
        MegaEvolution.onLogin(cid)
        check("mega gauge: a login after a crash mid-Mega empties the gauge and frees the ring", gauge() == 0
            and getItemAttribute(ring.uid, "scriptprotected") ~= true, gauge())
        setGauge(40)
        MegaEvolution.onLogin(cid)
        check("mega gauge: the charge is kept across logins", gauge() == 40, gauge())
        MegaEvolution.onClientMessage(cid, '{"action":"hello"}')

        MegaEvolution.BURST_MS = 1800
        setGauge(100)
        local before = #sent
        MegaEvolution.onPress(cid)
        local fx
        for i = before + 1, #sent do
            local message = JSON.decode(sent[i])
            if (message.type == "fx" and message.phase == "evolve") then
                fx = message
            end
        end
        check("mega gauge: nearby clients get the animation with the form and its look", fx ~= nil
            and fx.pokemon == pokemon and fx.trainer == cid and fx.form == "Mega Charizard X" and fx.look == 2596
            and fx.ms == 1800, sent[#sent])
        check("mega gauge: until the burst it is not the form yet", MegaEvolution.isActive(cid)
            and not MegaEvolution.isMega(pokemon) and MegaEvolution.state(cid).form == "Mega Charizard X"
            and MegaEvolution.isStoneLocked(cid, ball.uid))
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        check("mega gauge: called back before the burst, there is no Mega", not MegaEvolution.isActive(cid)
            and gauge() == 0 and not MegaEvolution.burst(cid))
        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        pokemon = getPlayerPokemon(cid)
        setGauge(100)
        quietly(function() MegaEvolution.onPress(cid) end)
        quietly(function() MegaEvolution.burst(cid) end)
        check("mega gauge: at the burst it becomes Mega Charizard X", MegaEvolution.isMega(pokemon)
            and getPokemonReferenceName(pokemon) == "Mega Charizard X")
        before = #sent
        MegaEvolution.finish(cid)
        local ended = false
        for i = before + 1, #sent do
            ended = ended or sent[i]:find('"phase":"end"', 1, true) ~= nil
        end
        check("mega gauge: the end goes out too", ended, sent[#sent])
        MegaEvolution.BURST_MS = 0

        setGauge(100)
        MegaEvolution.onClientMessage(cid, '{"action":"evolve"}')
        check("mega gauge: the client's evolve message Mega Evolves", MegaEvolution.isActive(cid))
        MegaEvolution.finish(cid)

        doRemoveConditions(cid, false)
        doPlayerUseBallOnSlot(cid)
        doRemoveConditions(cid, false)
        PokemonHeldItem.take(cid, ball.uid)
        doRemoveItem(ball.uid)
        doMovePlayerItem(cid, ring.uid, { y = PLAYER_SLOT_BACKPACK, z = 0 })
        setGauge(0)
        check("mega gauge: without the ring nothing charges", not MegaEvolution.charge(cid, 5) and gauge() == 0)
    end)
    restore()
    if (not ok) then
        error(err, 0)
    end
    for _, id in ipairs({ MEGA_ITEM_IDS.RING, MEGA_STONES[2].itemId, MEGA_STONES[4].itemId }) do
        doPlayerRemoveItem(cid, id, getPlayerItemCount(cid, id))
    end
    for _, key in ipairs({ "megaGauge", "megaClient", "megaCharges", "megaPvp", "megaActive" }) do
        setPlayerStorageValue(cid, playersStorages[key], -1)
    end
end

local function testRunningShoes(cid)
    local RUNNING_SHOES = 18754
    if (isItem(getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM)) or isPokemonOnline(cid)
            or isItem(getPlayerSlotItem(cid, PLAYER_SLOT_BALL))) then
        check("running shoes: key item and ball slots free for the test", false)
        return
    end
    local before = getCreatureSpeed(cid)
    local shoes = getThing(doPlayerAddItem(cid, RUNNING_SHOES, 1))
    doMovePlayerItem(cid, shoes.uid, { y = PLAYER_SLOT_KEY_ITEM, z = 0 })
    local worn = getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM)
    check("running shoes: they go in the key item slot", isItem(worn) and worn.itemid == RUNNING_SHOES, worn and worn.itemid)
    check("running shoes: +60 speed", getCreatureSpeed(cid) == before + 60, getCreatureSpeed(cid) - before)

    local ball = newBall(cid, "Pikachu", 10, POKEMON_SEX_MALE)
    doMovePlayerItem(cid, ball.uid, { y = PLAYER_SLOT_BALL, z = 0 })
    doRemoveConditions(cid, false)
    doPlayerUseBallOnSlot(cid)
    check("running shoes: a Pokemon can be called while wearing them", isPokemonOnline(cid))
    doRemoveConditions(cid, false)
    doPlayerUseBallOnSlot(cid)
    doRemoveConditions(cid, false)
    local slot = getPlayerSlotItem(cid, PLAYER_SLOT_BALL)
    if (isItem(slot)) then
        doRemoveItem(slot.uid)
    end

    doMovePlayerItem(cid, worn.uid, { y = PLAYER_SLOT_BACKPACK, z = 0 })
    check("running shoes: taking them off puts the speed back", getCreatureSpeed(cid) == before,
        getCreatureSpeed(cid) - before)
    doPlayerRemoveItem(cid, RUNNING_SHOES, 1)
end

local function testAnalyser(cid)
    local function near(a, b)
        return a and b and math.abs(a - b) < 0.0001
    end

    check("Analyser: a quarter of the tries or less can't catch", getCatchRollMaxFor(10, false, 2, 0) == nil)
    local max = getCatchRollMaxFor(200, false, 90, 12)
    check("Analyser: 90 tries of 200 with catching 12 rolls 1-199", max == 199, max)
    check("Analyser: an ultra ball against 1-199 is 3/199", near(Analyser.throwChance(3, max, 0, 1), 3 / 199))
    check("Analyser: the Catcher perk and the boost multiply the chance",
        near(Analyser.throwChance(3, max, 0.5, 1.5), 3 / 199 * 1.5 * 1.5))
    check("Analyser: a coloured ball rolls as 2", near(Analyser.throwChance(2.5, 100, 0, 1), 0.02))
    check("Analyser: species without the ball counter keep their chance", getCatchRollMaxFor(7.5, true, 0, 0) == 7.5)

    local first, expected, half, unlock = Analyser.simulate({ catchChance = 10, tries = 0, skill = 0, step = 1, rate = 1 })
    check("Analyser: a fresh 10-chance Pokemon needs two throws to open", first == 0 and unlock == 2, unlock)
    check("Analyser: it catches in the end", expected and expected > 2 and half and half > 2, expected)
    first, expected = Analyser.simulate({ catchChance = 10, tries = 0, skill = 0, step = 1, rate = 1, guaranteed = true })
    check("Analyser: a sure ball catches with the first throw", first == 1 and expected == 1, expected)

    check("Analyser: level 1 needs 100 EXP for level 2",
        Analyser.pokemonExpFor(0) == 0 and Analyser.pokemonExpFor(1) == 100 and Analyser.pokemonExpFor(2) == 200)
    check("Analyser: no Pokemon, no chances", Analyser.catchAudit(cid, "Nothing At All").name == nil)

    local wild = doCreateMonster("Caterpie", getThingPos(cid), true)
    check("Analyser: a wild Caterpie to defeat", isMonster(wild))
    if (isMonster(wild)) then
        Analyser.onKill(cid, wild)
        local name, level = Analyser.lastKill(cid)
        check("Analyser: the defeated Pokemon reads back from storage", name == "Caterpie" and level == (getMonsterLevel(wild) or 0),
            tostring(getPlayerStorageValue(cid, playersStorages.analyserLastKill)))
        doRemoveCreature(wild)
    end

    check("Discord: a common catch is not announced", not DiscordBridge.announcesCatch("Caterpie"))
    check("Discord: a shiny catch is announced", DiscordBridge.announcesCatch("Shiny Caterpie"))
    check("Discord: a legendary catch is announced", DiscordBridge.announcesCatch("Mewtwo"))

    local audit = Analyser.catchAudit(cid, "Pidgey", 5)
    local poke = audit.balls and audit.balls[1]
    check("Analyser: Pidgey lists the poke ball first", poke and poke.name == "poke" and poke.item == getItemInfo(balls["poke"].charged).clientId,
        poke and poke.name)
    local roll = getCatchRollMaxFor(getPlayerPokemonCatchChance(cid, "Pidgey"), getPokemonIgnoreBallCounter("Pidgey"),
        getPlayerCatchTries(cid, getPokemonNumberByName("Pidgey")) + 1, getPlayerSkillLevel(cid, PLAYER_SKILL_CATCHING))
    local wanted = Analyser.throwChance(1, roll, Vocations.perk(cid, "catcher", "catchChance") or 0,
        DiscordBoostPerks.catchMultiplier() or 1)
    check("Analyser: the poke ball's chance is the next throw's roll", poke and near(poke.chance, math.floor(wanted * 10000 + 0.5) / 10000),
        poke and poke.chance)

    local state = Analyser.pokemonState(cid, 12)
    check("Analyser: the Pokemon EXP state carries the gain", state.type == "pokemon" and state.amount == 12)
    if (state.level) then
        check("Analyser: the Pokemon's EXP sits between its levels", state.exp >= state.prev and state.next > state.prev,
            string.format("%s %s %s", state.prev, state.exp, state.next))
    end
end

local function testLegendaries(cid, friend, arena)
    local W = WildLegendaries
    local MON, KEY = W.MON, W.KEY
    local saved = {}
    for name, key in pairs(KEY) do
        saved[key] = getStorage(key)
    end
    local function clearOut(keep)
        for _, a in ipairs(W.getActive()) do
            if (isMonster(a.cid) and a.cid ~= keep) then
                W.finish(a.cid, "restart")
            end
        end
        for encounter in pairs(W.getFlights()) do
            W.endFlight(encounter, "restart")
        end
    end
    -- lands a flight now; returns the legendary back on the map and the flight
    local function landNow(name)
        local encounter, f = W.findFlight(name)
        if (not f) then
            return nil
        end
        f.start = os.time() - f.seconds - 60
        W.setFlight(encounter, f)
        W.runFlights(os.time())
        return W.find(name), f
    end
    clearOut()
    doSetStorage(KEY.PENDING, "m")
    doSetStorage(KEY.MODE, "auto")
    W.clearCooldowns()

    local points = W.getPoints()
    local good, bad, regions = 0, {}, {}
    for _, p in ipairs(points) do
        regions[p.region or "?"] = (regions[p.region or "?"] or 0) + 1
        if (W.isGoodPoint(p)) then
            good = good + 1
        elseif (#bad < 5) then
            bad[#bad + 1] = string.format("%d,%d,%d %s", p.x, p.y, p.z, p.area)
        end
    end
    check("Legendary: at least 90% of the points are good ground", good >= #points * 0.9,
        good .. "/" .. #points .. " " .. table.concat(bad, "; "))
    check("Legendary: points in all four regions", (regions.kanto or 0) > 500 and (regions.johto or 0) > 500 and
        (regions.orange or 0) > 500 and (regions.hoenn or 0) > 500, JSON.encode(regions))
    local thin, tiers = {}, { 0, 0, 0 }
    for _, s in ipairs(W.SPECIES) do
        tiers[s.tier] = tiers[s.tier] + 1
        local habitat = W.getHabitat(s)
        if (#habitat.all < 10 or (s.homes and #habitat.home == 0)) then
            thin[#thin + 1] = s.name .. " " .. #habitat.all .. "/" .. #habitat.home
        end
        local seen = {}
        for _, entry in ipairs(habitat.all) do
            seen[entry.point.region] = true
        end
        for _, region in ipairs(s.regions) do
            if (not seen[region]) then
                thin[#thin + 1] = s.name .. " none in " .. region
            end
        end
    end
    check("Legendary: every species has a habitat in each of its regions, with its homes", #thin == 0, table.concat(thin, ", "))
    check("Legendary: 21 species, 11 legendaries, 6 major, 4 mythicals", #W.SPECIES == 21 and tiers[1] == 11 and
        tiers[2] == 6 and tiers[3] == 4, table.concat(tiers, "/"))

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
    check("Legendary: legendaries 6, major 2, mythicals 1", tier1 / 4000 > 0.77 and tier1 / 4000 < 0.84, tier1 / 4000)
    check("Legendary: mythicals cool down longest", W.cooldownFor(W.getSpecies("Mew")) > W.cooldownFor(W.getSpecies("Lugia")))

    local broadcasts, cards, events, flights = {}, {}, {}, {}
    local broadcast, opcode, otc, emit = doBroadcastMessage, doSendPlayerExtendedOpcode, getPlayerUsingOtClient, DiscordBridge.emitLegendary
    local getScheduled = ServerRestart.getScheduled
    doBroadcastMessage = function(text) broadcasts[#broadcasts + 1] = text return true end
    doSendPlayerExtendedOpcode = function(target, id, buffer)
        if (id == EXTENDED_IDS.LEGENDARY and target == cid) then cards[#cards + 1] = JSON.decode(buffer) end
        if (id == EXTENDED_IDS.LEGENDARY_FLIGHT and target == cid) then flights[#flights + 1] = JSON.decode(buffer) end
        return true
    end
    getPlayerUsingOtClient = function() return true end
    DiscordBridge.emitLegendary = function(event) events[#events + 1] = event end
    local function last() return broadcasts[#broadcasts] or "" end
    local arenaMewtwo
    local weatherSaved = Weather.readOverrides()
    local ok, err = pcall(function()
        local articuno = W.getSpecies("articuno")
        local mewtwo = W.getSpecies("Mewtwo")
        local a = W.spawn(articuno, nil, nil, "test")
        local region = isMonster(a) and Weather.regionAt(getCreaturePosition(a)).id
        check("Legendary: spawns in its habitat", isMonster(a) and W.isEncounter(a) and
            (region == "kanto" or region == "orange" or region == "johto"), region)
        check("Legendary: spawn broadcast with the recommended level",
            last():find("A wild Articuno has appeared near .+ Recommended for trainers level 50%+") ~= nil, last())
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

        -- one mythical at a time, whoever starts it
        local celebi = W.spawn(W.getSpecies("Celebi"), nil, nil, "test")
        check("Legendary: a mythical's announcement names no area", isMonster(celebi) and not last():find(" near "), last())
        local jirachi, why2 = W.spawn(W.getSpecies("Jirachi"), nil, nil, "staff")
        check("Legendary: never two mythicals", not jirachi and tostring(why2):find("mythical") ~= nil, why2)
        if (isMonster(celebi)) then W.finish(celebi, "staff") end

        -- Mewtwo's warning, then Mewtwo where it was felt
        local warned, warnArea = W.warn(mewtwo, "test")
        check("Legendary: Mewtwo's warning comes first", warned and W.getPending()["Mewtwo"] ~= nil and
            last():find("psychic disturbance") ~= nil and not W.find("Mewtwo"), last())
        local mewtwoEligible = false
        for _, s in ipairs(W.eligible()) do mewtwoEligible = mewtwoEligible or s.name == "Mewtwo" end
        check("Legendary: a warned Mewtwo is not eligible", not mewtwoEligible)
        local pending = W.getPending()["Mewtwo"]
        doSetStorage(KEY.PENDING, string.format("m;Mewtwo=%d:%d:test", os.time() - 1, pending and pending.point or 1))
        W.runPending(os.time())
        local wm = W.find("Mewtwo")
        check("Legendary: after the warning Mewtwo appears there", wm and not W.getPending()["Mewtwo"] and
            getCreatureStorage(wm, MON.AREA) == warnArea, wm and tostring(getCreatureStorage(wm, MON.AREA)) .. " vs " .. tostring(warnArea))
        if (wm) then W.finish(wm, "staff") end
        W.warn(mewtwo, "test")
        -- north of the arena: the Catcher throws, running at the same time, use the tiles east and south
        arenaMewtwo = W.spawn(mewtwo, { x = arena.x, y = arena.y - 1, z = arena.z }, "the test arena", "test")
        check("Legendary: a staff spawn replaces the warning", isMonster(arenaMewtwo) and not W.getPending()["Mewtwo"])
        check("Legendary: at most two alive", #W.eligible() == 0 and W.blocked(os.time()) ~= nil)
        W.finish(a, "staff")
        check("Legendary: sent away by staff, no cooldown", not isMonster(a) and not W.getCooldowns()["Articuno"] and
            last():find("flew away") ~= nil, last())

        -- sets
        local birds = W.spawnSet(W.getSet("birds"), "test")
        check("Legendary: the birds come together, one announcement", #birds == 3 and
            last():find("The legendary birds have appeared together") ~= nil, last())
        local members, major = 0, false
        for _, e in ipairs(W.getActive()) do if (e.flags:find("s")) then members = members + 1 end end
        for _, s in ipairs(W.eligible()) do major = major or s.tier == 2 end
        check("Legendary: a set doesn't count against the limit", members == 3 and #W.eligible() > 0, #W.eligible())
        check("Legendary: never two major ones on the schedule", not major)
        check("Legendary: a set member already out is skipped", #W.spawnSet(W.getSet("birds"), "test") == 0)
        for _, b in ipairs(birds) do W.finish(b, "staff") end

        local chance = W.CONFIG.setChance
        W.CONFIG.setChance = 100
        W.setCooldown("Entei", os.time() + 3600)
        W.scheduledSpawn(W.getSpecies("Raikou"), "test")
        W.CONFIG.setChance = chance
        local raikou, entei, suicune = W.find("Raikou"), W.find("Entei"), W.find("Suicune")
        check("Legendary: the set roll brings the whole set, the one on cooldown too", raikou and entei and suicune)
        if (raikou) then
            local zone = getCreatureStorage(raikou, MON.ZONE)
            doCreatureSetStorage(raikou, MON.NEXT_MOVE, os.time() - 1)
            doCreatureSetStorage(raikou, MON.LAST_HIT, 0)
            local eventCount = #events
            W.upkeep(raikou, os.time())
            local newZone = getCreatureStorage(raikou, MON.ZONE)
            local allowed = { [zone] = true }
            for _, z in ipairs(LEGENDARY_ANCHORS.NEIGHBORS[zone] or {}) do allowed[z] = true end
            local here, trail = getCreaturePosition(raikou), W.trailOf(raikou)
            check("Legendary: a roamer walks to its zone or the next one", allowed[newZone] and #trail >= 1,
                tostring(zone) .. " -> " .. tostring(newZone))
            check("Legendary: its trail marks the way it came", #trail == 1 or
                getDistanceBetween(trail[1], here) <= W.CONFIG.routeSpacing + 1, #trail .. " marks")
            local seer, town = W.seenBy(here)
            check("Legendary: a move is reported only when a trainer or a town sees it",
                (#events > eventCount) == (seer ~= nil or town ~= nil), tostring(seer) .. "/" .. tostring(town))

            local marks = W.routeMarks({ x = 100, y = 100, z = 7 }, { x = 140, y = 100, z = 7 })
            check("Legendary: route marks on the last stretch, nearest the end first", #marks == 4 and marks[1].x == 132 and
                marks[4].x == 108 and #W.routeMarks({ x = 100, y = 100, z = 7 }, { x = 110, y = 100, z = 6 }) == 0, #marks)

            local me = getCreaturePosition(cid)
            -- the tester counts as 20 to 30 tiles from it for the area signs (not moved: the catch throws
            -- that follow use the tiles next to the tester)
            local there, spot = getCreaturePosition(raikou), nil
            -- the sign lands 3 to 5 tiles toward it, 2 either way, and only on a tile with ground
            local function groundToward(pos)
                local r = math.max(math.abs(there.x - pos.x), math.abs(there.y - pos.y))
                for along = 3, 5 do
                    local cx = math.floor(pos.x + (there.x - pos.x) * along / r + 0.5)
                    local cy = math.floor(pos.y + (there.y - pos.y) * along / r + 0.5)
                    for dx = -2, 2 do
                        for dy = -2, 2 do
                            local g = getTileThingByPos({ x = cx + dx, y = cy + dy, z = pos.z, stackpos = STACKPOS_GROUND })
                            if (not g or not g.itemid or g.itemid == 0) then
                                return false
                            end
                        end
                    end
                end
                return true
            end
            -- every tile of the square ring r tiles out (it spawns anywhere: some rings are mostly water)
            for r = 20, 30 do
                for i = -r, r do
                    for _, d in ipairs({ { i, -r }, { i, r }, { -r, i }, { r, i } }) do
                        local pos = { x = there.x + d[1], y = there.y + d[2], z = there.z }
                        if (not spot and W.isGoodPoint(pos) and groundToward(pos)) then spot = pos end
                    end
                end
                if (spot) then break end
            end
            check("Legendary: found a spot 20 to 30 tiles from it for the area signs", spot ~= nil)
            if (spot) then
                local shown, effect, position, online = {}, doSendMagicEffect, getCreaturePosition, getPlayersOnline
                doSendMagicEffect = function(pos) shown[#shown + 1] = pos return true end
                getCreaturePosition = function(c) return c == cid and spot or position(c) end
                getPlayersOnline = function() return { cid } end
                -- the sign goes on a random tile near the point toward it, and none when that tile has no ground
                local ok, err, s = true, nil, nil
                for try = 1, 10 do
                    if (s or not ok) then break end
                    ok, err = pcall(W.guideSigns, raikou, W.getSpecies("Raikou"), os.time() + 3600 * try)
                    for _, pos in ipairs(shown) do
                        if (getDistanceBetween(pos, spot) <= 7) then s = pos end
                    end
                end
                doSendMagicEffect, getCreaturePosition, getPlayersOnline = effect, position, online
                check("Legendary: guideSigns runs", ok, err)
                check("Legendary: a trainer in its area sees a sign a few tiles toward it", s and
                    getDistanceBetween(s, there) < getDistanceBetween(spot, there),
                    s and (s.x - spot.x .. "," .. s.y - spot.y) or (#shown .. " signs"))
            end

            doTeleportThing(raikou, { x = me.x + 3, y = me.y + 3, z = me.z }, false)
            check("Legendary: a trainer in sight sees it", W.seenBy(getCreaturePosition(raikou)) == getCreatureName(cid))
            local hint = {}
            for rank = 1, 5 do
                hint[rank] = table.concat(W.radarHints(cid, rank), " ")
            end
            check("Legendary radar: rank 1 feels something powerful, no name", hint[1]:find("Something powerful") ~= nil and
                not hint[1]:find("Raikou"), hint[1])
            check("Legendary radar: rank 2 names it from its signs", hint[2]:find("Raikou is stirring around") ~= nil, hint[2])
            check("Legendary radar: rank 3 the zones it may run to", hint[3]:find("may run to") ~= nil or
                hint[3]:find("stays on this island") ~= nil, hint[3])
            check("Legendary radar: rank 4 the direction and how fresh", hint[4]:find("south%-east of here, signs") ~= nil, hint[4])
            check("Legendary radar: rank 5 where it came from or is heading", hint[5]:find("heading for") ~= nil or
                hint[5]:find("came by") ~= nil, hint[5])
            check("Legendary radar: never the spot", not hint[5]:find("%d+, %d+"), hint[5])
        end
        if (entei) then
            W.finish(entei, "fled")
            local cd = W.getCooldowns()["Entei"]
            check("Legendary: a set member's cooldown is set again when it leaves", cd and
                math.abs(cd - os.time() - W.cooldownFor(W.getSpecies("Entei"))) <= 2)
        end
        clearOut(arenaMewtwo)

        -- the Regis sleep until found
        local regirock = W.spawn(W.getSpecies("Regirock"), nil, nil, "test")
        check("Legendary: a Regi comes asleep", W.isAsleep(regirock) and last():find("is sleeping somewhere near") ~= nil, last())
        local blocked = W.onHit(regirock, 100, cid)
        check("Legendary: the first hit wakes it instead of hurting it", blocked == false and
            getCreatureStorage(regirock, MON.WAKE_PENDING) == 1)
        W.upkeep(regirock, os.time())
        check("Legendary: awake, it stays an hour", isMonster(regirock) and not W.isAsleep(regirock) and
            math.abs(getCreatureStorage(regirock, MON.ENDS_AT) - os.time() - W.CONFIG.wakeLifetime) <= 2 and
            last():find(getCreatureName(cid) .. " woke Regirock up", 1, true) ~= nil, last())
        check("Legendary: awake, hits count", W.onHit(regirock, 1, cid) ~= false)
        if (isMonster(regirock)) then W.finish(regirock, "staff") end

        -- Mew in disguise
        local mew = W.spawn(W.getSpecies("Mew"), nil, nil, "test")
        local encounter = isMonster(mew) and getCreatureStorage(mew, MON.ENCOUNTER)
        check("Legendary: Mew comes disguised as a local Pokemon", isMonster(mew) and W.isDisguised(mew) and
            getCreatureName(mew) ~= "Mew" and W.find("Mew") == mew, isMonster(mew) and getCreatureName(mew))
        check("Legendary: the announcement doesn't say where", not last():find(" near "), last())
        check("Legendary: the disguise is hidden from the status",
            not (" " .. table.concat(W.describe(false), " ") .. " "):find("[^%w]Mew[^%w]"), table.concat(W.describe(false), " "))
        check("Legendary: hitting the disguise reveals it", isMonster(mew) and W.onHit(mew, 50, cid) == false)
        W.upkeep(mew, os.time())
        local real = W.find("Mew")
        check("Legendary: Mew shows its true self, same encounter", real and getCreatureName(real) == "Mew" and
            not isMonster(mew) and getCreatureStorage(real, MON.ENCOUNTER) == encounter and
            last():find("found Mew hiding as a wild") ~= nil, last())
        if (real) then W.finish(real, "staff") end
        local hidden = W.spawn(W.getSpecies("Mew"), nil, nil, "test")
        check("Legendary: a Ranger's radar asks for the reveal", hidden and W.requestReveal(hidden, "A Ranger") and
            getCreatureStorage(hidden, MON.REVEAL_PENDING) == 1)
        if (hidden and isMonster(hidden)) then W.finish(hidden, "staff") end

        -- Kyogre's rain (staff weather wins, so clear the test's clear skies first)
        Weather.writeOverrides("m")
        local kyogre = W.spawn(W.getSpecies("Kyogre"), nil, nil, "test")
        local home = isMonster(kyogre) and W.weatherZone(getCreatureStorage(kyogre, MON.HOME_ZONE))
        local rain = home and Weather.getOverrides()[home.id]
        check("Legendary: Kyogre brings rain to its zone", rain and rain.kind == "rain", home and home.name)
        if (isMonster(kyogre)) then
            doCreatureSetStorage(kyogre, MON.NEXT_MOVE, os.time() - 1)
            W.upkeep(kyogre, os.time())
            local _, dive = W.findFlight("Kyogre")
            check("Legendary: Kyogre dives to its next spot", not isMonster(kyogre) and dive and dive.kind == "w")
            kyogre = landNow("Kyogre")
            check("Legendary: a territory one stays in its zone", kyogre and home and
                getCreatureStorage(kyogre, MON.ZONE) == home.name,
                kyogre and tostring(getCreatureStorage(kyogre, MON.ZONE)))
            if (kyogre) then W.finish(kyogre, "staff") end
        end
        check("Legendary: the rain stops when it leaves", home and not Weather.getOverrides()[home.id])
        Weather.writeOverrides(weatherSaved)

        -- staff: move it on, end a flight, a fly-over only they see; Groudon shakes the screen
        local zapdos = W.spawn(W.getSpecies("Zapdos"), nil, nil, "test")
        check("Legendary: staff move asks the globalevent", zapdos and W.requestMove(zapdos) and
            getCreatureStorage(zapdos, MON.MOVE_PENDING) == 1)
        if (zapdos) then W.upkeep(zapdos, os.time()) end
        local zapdosEncounter, zapdosFlight = W.findFlight("Zapdos")
        local listed = false
        for _, e in ipairs(W.adminState().active) do
            listed = listed or (e.name == "Zapdos" and e.flying and e.landsIn > 0)
        end
        check("Legendary: the staff move makes it fly, listed as flying", zapdos and not isMonster(zapdos) and
            zapdosFlight ~= nil and listed and W.spawn(W.getSpecies("Zapdos")) == nil)
        check("Legendary: the status says it is in the air", table.concat(W.describe(true), " "):find("Zapdos") ~= nil,
            table.concat(W.describe(true), " "))
        check("Legendary: staff end a flight, no cooldown", zapdosEncounter and W.endFlight(zapdosEncounter, "staff") and
            not W.findFlight("Zapdos") and not W.getCooldowns()["Zapdos"] and last():find("The wild Zapdos") ~= nil, last())
        flights = {}
        check("Legendary: a fly-over only staff see", W.flyover(cid, "Lugia", "dive") and #flights == 1 and
            flights[1].kind == "dive" and flights[1].species == "Lugia" and next(W.getFlights()) == nil and not W.flyover(cid, "Nobody"))
        -- Route 27: sea from y 836 up to the shore, land past it
        local seaFrom, inland = { x = 2836, y = 836, z = 7 }, { x = 2836, y = 806, z = 7 }
        local shore = W.landfall(seaFrom, inland)
        check("Legendary: a dive comes up at the first shore on its way, not inland", shore and W.isGoodPoint(shore) and
            shore.y > inland.y + 2 and seaFrom.y - shore.y >= W.CONFIG.landfallMin and math.abs(shore.x - seaFrom.x) <= 3,
            shore and string.format("%d,%d", shore.x, shore.y))
        check("Legendary: no shore on a dive over land", W.landfall(inland, { x = inland.x, y = inland.y - 20, z = 7 }) == nil)
        flights = {}
        local groudon = W.spawn(W.getSpecies("Groudon"), { x = arena.x + 2, y = arena.y, z = arena.z }, "the test arena", "test")
        check("Legendary: Groudon shakes the screens near it", groudon and #flights > 0 and flights[1].type == "shake" and
            flights[1].strength >= 1, flights[1] and JSON.encode(flights[1]))
        if (groudon) then W.finish(groudon, "staff") end

        -- Jirachi's meteor shower, Deoxys's impact
        local spot = { x = arena.x + 2, y = arena.y, z = arena.z }
        flights = {}
        local jirachi = W.spawn(W.getSpecies("Jirachi"), spot, "the test arena", "test")
        local shower = W.getShower()
        local meteors = false
        for _, m in ipairs(flights) do meteors = meteors or (m.type == "meteors" and not m.big) end
        check("Legendary: Jirachi lands with a meteor shower", jirachi and shower and
            getDistanceBetween(shower.pos, getCreaturePosition(jirachi)) <= 1 and shower.untilTime > os.time() and meteors and
            last():find("meteor shower") ~= nil, last())
        if (shower) then W.runShower(shower.untilTime) end
        check("Legendary: the shower ends", not W.getShower())
        if (jirachi) then W.finish(jirachi, "staff") end
        flights = {}
        local deoxys = W.spawn(W.getSpecies("Deoxys"), spot, "the test arena", "test")
        local big, shaken = false, false
        for _, m in ipairs(flights) do
            big = big or (m.type == "meteors" and m.big)
            shaken = shaken or (m.type == "shake" and (m.delay or 0) > 0)
        end
        check("Legendary: Deoxys comes with a meteor impact", deoxys and big and shaken and last():find("meteor struck") ~= nil,
            last())
        if (deoxys) then W.finish(deoxys, "staff") end

        -- Groudon and Kyogre: a storm where they meet, and Rayquaza comes down to calm them
        Weather.writeOverrides("m")
        local g = W.spawn(W.getSpecies("Groudon"), nil, nil, "test")
        local k = W.spawn(W.getSpecies("Kyogre"), nil, nil, "test")
        local meetZone = k and W.weatherZone(getCreatureStorage(k, MON.ZONE))
        if (g and k and meetZone) then
            doCreatureSetStorage(g, MON.ZONE, getCreatureStorage(k, MON.ZONE))
            W.runClashes(os.time())
            local storm = Weather.getOverrides()[meetZone.id]
            check("Legendary: Groudon and Kyogre in one zone bring a great storm", storm and storm.kind == "thunderstorm" and
                last():find("Groudon and Kyogre meet near") ~= nil and #W.getClashes() == 1, last())
            check("Legendary: staff see the clash in the status", table.concat(W.adminState().events, " "):find("thunderstorm") ~= nil)
            local chance = W.CONFIG.rayquazaChance
            W.CONFIG.rayquazaChance = 100
            W.runRayquaza(os.time())
            W.CONFIG.rayquazaChance = chance
            check("Legendary: Rayquaza is called, comes a little later", not W.find("Rayquaza") and not W.findFlight("Rayquaza") and
                table.concat(W.describe(true), " "):find("Rayquaza comes down") ~= nil)
            W.runRayquaza(os.time() + W.CONFIG.rayquazaDelay + 1)
            check("Legendary: Rayquaza comes down to them", (W.findFlight("Rayquaza") or W.find("Rayquaza")) ~= nil and
                last():find("Rayquaza is coming down from the sky") ~= nil, last())
            local ray = W.find("Rayquaza") or landNow("Rayquaza")
            check("Legendary: Rayquaza lands next to Groudon", ray and getDistanceBetween(getCreaturePosition(ray),
                getCreaturePosition(g)) <= 10, ray and getDistanceBetween(getCreaturePosition(ray), getCreaturePosition(g)))
            W.runClashes(os.time())
            local after = Weather.getOverrides()[meetZone.id]
            check("Legendary: Rayquaza calms the storm, Kyogre's rain comes back", #W.getClashes() == 0 and
                (not after or after.kind == "rain"), after and after.kind)
            if (ray) then W.finish(ray, "staff") end
            W.runRayquaza(os.time() + 10 * W.CONFIG.rayquazaDelay)
            check("Legendary: Rayquaza is called once per Groudon and Kyogre", not W.find("Rayquaza") and
                not W.findFlight("Rayquaza"))
        else
            check("Legendary: Groudon and Kyogre spawn for the clash test", false)
        end
        clearOut(arenaMewtwo)
        W.runClashes(os.time())
        Weather.writeOverrides(weatherSaved)

        -- through a restart: back where it was, with its health and time left
        a = W.spawn(articuno, nil, nil, "test")
        local articunoEncounter = getCreatureStorage(a, MON.ENCOUNTER)
        doCreatureAddHealth(a, -math.floor(getCreatureMaxHealth(a) / 2))
        local where, left = getCreaturePosition(a), getCreatureStorage(a, MON.ENDS_AT) - os.time()
        local mewtwoWhere = getCreaturePosition(arenaMewtwo)
        W.save()
        check("Legendary: the ones out are saved", tostring(getStorage(KEY.SAVED)):find(articunoEncounter .. "=" ..
            articuno.index .. "|50|", 1, true) ~= nil, getStorage(KEY.SAVED))
        local said = #broadcasts
        doRemoveCreature(a)
        doRemoveCreature(arenaMewtwo)
        local back = W.restore()
        a, arenaMewtwo = W.find("Articuno"), W.find("Mewtwo")
        check("Legendary: after a restart it is back with its health and time", a and back[articunoEncounter] and
            getCreatureStorage(a, MON.ENCOUNTER) == articunoEncounter and math.abs(W.healthPercent(a) - 50) <= 1 and
            getSamePosition(getCreaturePosition(a), where) and
            math.abs(getCreatureStorage(a, MON.ENDS_AT) - os.time() - left) <= 60,
            a and (W.healthPercent(a) .. "% " .. (getCreatureStorage(a, MON.ENDS_AT) - os.time()) .. "s"))
        check("Legendary: restored quietly", #broadcasts == said and arenaMewtwo and
            getSamePosition(getCreaturePosition(arenaMewtwo), mewtwoWhere))

        -- flying, flee, heal and time up on Articuno
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
        local flyEncounter, f = W.findFlight("Articuno")
        check("Legendary: flies on far, off the map", not isMonster(a) and f and f.kind == "a" and
            flyEncounter == articunoEncounter and getDistanceBetween(from, f.to) >= 30 and
            f.seconds >= W.CONFIG.flightSeconds[1] and f.seconds <= W.CONFIG.flightSeconds[2],
            f and (getDistanceBetween(from, f.to) .. " tiles in " .. f.seconds .. "s"))
        check("Legendary: still out while flying", W.spawn(articuno) == nil)
        check("Legendary: a restart mid-flight brings it back where it was going", f and tostring(getStorage(KEY.SAVED)):find(
            string.format("%d=%d|%d|%d,%d,%d|", articunoEncounter, articuno.index, f.health, f.to.x, f.to.y, f.to.z), 1, true) ~= nil,
            getStorage(KEY.SAVED))
        if (f) then
            flights = {}
            f.from, f.start = getCreaturePosition(cid), os.time()
            W.setFlight(flyEncounter, f)
            W.runFlights(os.time())
            check("Legendary: the trainers under a flight are sent it once", #flights == 1 and flights[1].type == "flight" and
                flights[1].species == "Articuno" and flights[1].kind == "fly" and flights[1].circle > 0)
            W.runFlights(os.time())
            check("Legendary: not sent twice", #flights == 1, #flights)
        end
        local eventCount = #events
        a = landNow("Articuno")
        local seer, town
        if (a) then seer, town = W.seenBy(getCreaturePosition(a)) end
        check("Legendary: lands where it was going, same encounter", a and f and
            getCreatureStorage(a, MON.ENCOUNTER) == articunoEncounter and getDistanceBetween(getCreaturePosition(a), f.to) <= 3 and
            not W.findFlight("Articuno") and math.abs(W.healthPercent(a) - 50) <= 1,
            a and (W.healthPercent(a) .. "% " .. getDistanceBetween(getCreaturePosition(a), f.to) .. " tiles off"))
        check("Legendary: a landing is reported only when a trainer or a town sees it", (seer or town) and
            events[#events].event == "sighting" or (not seer and not town and #events == eventCount),
            tostring(seer) .. "/" .. tostring(town))

        local max = getCreatureMaxHealth(a)
        local hit = getCreatureHealth(a) - math.floor(max * 0.45)
        W.onHit(a, hit)
        doCreatureAddHealth(a, -hit)
        local hurt = W.healthPercent(a)
        check("Legendary: flees at 50% health", getCreatureStorage(a, MON.FLEE_PENDING) == 1 and getCreatureStorage(a, MON.FLEE_STAGE) == 1)
        W.upkeep(a, t)
        local _, fled = W.findFlight("Articuno")
        check("Legendary: the flee takes it to the sky with its health", not isMonster(a) and fled and fled.health == hurt and
            fled.stage == 1 and last():find("took to the sky") ~= nil, last())
        a = landNow("Articuno")
        check("Legendary: it comes down with its health", a and math.abs(W.healthPercent(a) - hurt) <= 1 and
            getCreatureStorage(a, MON.FLEE_STAGE) == 1 and last():find("came down near") ~= nil, last())
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

        W.setManual(true)
        check("Legendary: manual mode stops the schedule", (W.blocked(os.time()) or ""):find("manual") ~= nil)
        W.setManual(false)
        ServerRestart.getScheduled = function() return os.time() + 300, 1 end
        check("Legendary: no spawns in the 10 minutes before a restart", (W.blocked(os.time()) or ""):find("restart") ~= nil)
        ServerRestart.getScheduled = getScheduled

        local count = #broadcasts
        W.onCatch(cid, "Lugia")
        W.onCatch(cid, "Shiny Raikou")
        W.onCatch(cid, "Pidgey")
        check("Legendary: every legendary catch is announced", #broadcasts == count + 2 and
            (broadcasts[count + 1] or ""):find("caught a Lugia") ~= nil and (broadcasts[count + 2] or ""):find("caught a shiny Raikou") ~= nil,
            table.concat(broadcasts, " | ", count + 1))
        W.onReward(cid, "Celebi")
        check("Legendary: a quest reward is announced", last():find("received Celebi") ~= nil, last())

        local cardTypes = {}
        for _, c in ipairs(cards) do cardTypes[c.type] = true end
        check("Legendary: cards for spawn, sighting, flee and end", cardTypes.spawn and cardTypes.flee and cardTypes["end"])
    end)
    doBroadcastMessage, doSendPlayerExtendedOpcode, getPlayerUsingOtClient = broadcast, opcode, otc
    DiscordBridge.emitLegendary, ServerRestart.getScheduled = emit, getScheduled
    Weather.writeOverrides(weatherSaved)
    clearOut(arenaMewtwo)
    if (not ok) then
        check("Legendary: ran without errors", false, err)
    end

    -- A real defeat: the tester does almost all the damage, the friend 3%
    local m = arenaMewtwo
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

local function testHints(cid)
    local sent, original = {}, doSendPlayerExtendedOpcode
    local function capture(fn)
        sent = {}
        doSendPlayerExtendedOpcode = function(target, opcode, buffer)
            if (opcode == EXTENDED_IDS.HINTS) then
                local data = JSON.decode(buffer)
                sent[#sent + 1] = data
                sent[data.type] = data
                return true
            end
            return original(target, opcode, buffer)
        end
        local ok, err = pcall(fn)
        doSendPlayerExtendedOpcode = original
        if (not ok) then
            check("Hints ran without errors", false, err)
        end
    end
    local savedSeen = getPlayerStorageValue(cid, playersStorages.hintsSeen)
    local savedClient = getPlayerStorageValue(cid, playersStorages.hintsClient)

    check("Hints: opcode 38 on both sides", EXTENDED_IDS.HINTS == 38)
    check("Hints: storages are free", playersStorages.hintsSeen ~= nil and playersStorages.hintsClient ~= nil and
        playersStorages.hintsSeen ~= playersStorages.hintsClient)
    setPlayerStorageValue(cid, playersStorages.hintsSeen, -1)
    Hints.onLogin(cid)
    capture(function() Hints.show(cid, "daycare") end)
    check("Hints: nothing is sent before the client says hello", #sent == 0 and not Hints.enabled(cid))

    capture(function() Hints.onClientMessage(cid, '{"action":"hello"}') end)
    check("Hints: hello sends the seen list, empty at first", Hints.enabled(cid) and sent.seen ~= nil and
        #sent.seen.seen == 0, JSON.encode(sent))

    capture(function() Hints.show(cid, "daycare") end)
    check("Hints: an unseen hint is shown", sent.show ~= nil and sent.show.key == "daycare", JSON.encode(sent))
    capture(function() Hints.show(cid, "nope") end)
    check("Hints: unknown keys are ignored", #sent == 0)

    capture(function()
        Hints.onClientMessage(cid, '{"action":"seen","key":"daycare"}')
        Hints.onClientMessage(cid, '{"action":"seen","key":"center"}')
        Hints.onClientMessage(cid, '{"action":"seen","key":"center"}')
        Hints.onClientMessage(cid, '{"action":"seen","key":"nope"}')
        Hints.onClientMessage(cid, 'not json')
    end)
    check("Hints: seen keys are kept as bits", Hints.hasSeen(cid, "daycare") and Hints.hasSeen(cid, "center") and
        not Hints.hasSeen(cid, "mart") and Hints.mask(cid) == 1 + 8, tostring(Hints.mask(cid)))
    capture(function() Hints.show(cid, "daycare") end)
    check("Hints: a seen hint isn't shown again", #sent == 0)

    capture(function() Hints.onClientMessage(cid, '{"action":"hello"}') end)
    local list = sent.seen and table.concat(sent.seen.seen, ",") or ""
    check("Hints: hello after a relog sends what was seen", list == "center,daycare", list)

    Hints.onLogin(cid)
    capture(function() Hints.onClientMessage(cid, '{"action":"reset"}') end)
    check("Hints: reset clears every hint", Hints.mask(cid) == 0 and sent.seen ~= nil and #sent.seen.seen == 0)

    setPlayerStorageValue(cid, playersStorages.hintsSeen, savedSeen)
    setPlayerStorageValue(cid, playersStorages.hintsClient, savedClient)
end

local function testWorldBoss()
    check("World Boss: The A. Mesmer is Hypno, not the shared template",
        WorldBoss.get("The A. Mesmer") ~= nil and WorldBoss.get("Blastertoise") ~= nil)

    local seen, count = {}, 0
    WorldBoss.each(function(name, boss)
        count = count + 1
        check("World Boss: " .. name .. " has a Seek-it hint",
            type(boss.hint) == "string" and boss.hint:find("Seek it", 1, true), boss.hint)
        for _, line in ipairs(boss.messages) do
            check("World Boss: flavor is unique — " .. line:sub(1, 48), not seen[line],
                seen[line] and (seen[line] .. " and " .. name) or name)
            seen[line] = name
        end
    end)
    check("World Boss: twenty catalogs", count == 20, tostring(count))

    local mesmer = WorldBoss.get("The A. Mesmer")
    local flavor = mesmer.messages[1]
    local text = WorldBoss.announceText("The A. Mesmer", flavor)
    check("World Boss: Mesmer announce names Hill of Confusion",
        text:find("World Boss", 1, true) and text:find("Hill of Confusion", 1, true)
            and text:find("Lavender", 1, true) and text:find("Hypnosis", 1, true), text)
    check("World Boss: Mesmer announce has no coordinates",
        not text:find("4226", 1, true) and not text:find("272", 1, true), text)
    check("World Boss: Mesmer announce is not a generic HARD line",
        not text:find("sea was very choppy", 1, true) and not text:find("What's that in the sky", 1, true), text)

    local captured, original = {}, doBroadcastMessage
    doBroadcastMessage = function(msg, class, announcement)
        captured[#captured + 1] = { text = msg, announcement = announcement }
        captured.last = captured[#captured]
        return true
    end
    WorldBoss.announce("The A. Mesmer", false, flavor)
    check("World Boss: spawn goes to Discord",
        captured.last and captured.last.announcement and captured.last.announcement.discord ~= false
            and captured.last.announcement.title == "World Boss")
    WorldBoss.announce("The A. Mesmer", true, flavor)
    check("World Boss: 10-minute reminder stays in game",
        captured.last and captured.last.announcement and captured.last.announcement.discord == false)
    WorldBoss.defeated()
    check("World Boss: defeat goes to Discord",
        captured.last and captured.last.text:find("defeated", 1, true)
            and captured.last.announcement and captured.last.announcement.discord ~= false)
    doBroadcastMessage = original
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
        { "incubator", testBreederIncubator }, { "daycare", testDaycare }, { "pokemon shop", testPokemonShop }, { "held items", testHeldItems }, { "shiny event", withoutCalendarBonuses(testShinyEvent) }, { "admin", withoutCalendarBonuses(testAdmin) }, { "quests", testQuests }, { "calendar", testCalendar }, { "halloween", testHalloween }, { "world boss", testWorldBoss }, { "summer chests", testSummerChests }, { "anniversary boss", testAnniversaryBoss }, { "anniversary npcs", testAnniversaryNpcs }, { "event shop", testEventShop }, { "server restart", testServerRestart }, { "decoration items", testDecorationItems }, { "seasons", testSeasons }, { "hints", testHints }, { "weather", function() testWeather(cid, arena) end }, { "decorations", testDecorations }, { "hand decorations", testHandDecorations }, { "ball slot", testBallSlotUse }, { "habitat", testPokemonHabitat }, { "analyser", testAnalyser }, { "mega items", testMegaItems }, { "mega forms", withoutMegaBurst(testMegaForms) }, { "more megas", withoutMegaBurst(testMoreMegas) }, { "mega drops", testMegaDrops }, { "mega quest", testMegaQuest }, { "mega gauge", withoutMegaBurst(testMegaGauge) }, { "running shoes", testRunningShoes }, { "legendaries", function() testLegendaries(cid, friend, arena) end }, { "move info", function() testMoveInfo(cid, arena) end }, { "duel wilds", function() testDuelWilds(cid, arena) end }, { "ranger", function() testRanger(cid, arena) end },
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
