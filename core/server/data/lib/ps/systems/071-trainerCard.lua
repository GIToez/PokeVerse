-- Trainer Card (docs/upcoming-features.md): a trainer's profile, opened from the top bar (your own),
-- by right-clicking a trainer, or by using the Pokedex on one. Only trainers who are online.
-- The owner picks a favorite Pokemon, up to six trophy Pokemon, the displayed title, an About text
-- and what other trainers don't see (TrainerCard.PRIVACY).
--
-- The client's Trainer Card window (game_trainercard) talks JSON on EXTENDED_IDS.TRAINER_CARD:
--   client -> server  {action = "hello"} (at login: the client has the window), {action = "open", name} (no name: your own card), {action = "titles"}, {action = "candidates"},
--                     {action = "save", favorite, trophies = {keys}, title, about, privacy},
--                     {action = "achievements", name}, {action = "duel", name}
--   server -> client  {type = "card", own, name, sex, level, town = {id, name}, guild, mastery, playTime, since, duels,
--                      respect, vocation = {key, name, rank, maxRank, title}, title, titleKey, outfit, favorite,
--                      trophies = {pokemon...}, badges = {{region, list = {{name, client, earned, upcoming}}}}, stats, about, privacy, hidden}
--                     {type = "titles", list = {{key, text, group, detail}}}
--                     {type = "candidates", list = {pokemon...}}
--                     {type = "achievements", name, earned, total, list = {{name, description}}}
--                     (the list messages have more = true when the list was cut to fit one message)
--                     {type = "result", ok, text}
-- A Pokemon is {key, name, level, sex, number, shiny, look, types}; key is "name|level|sex", what the
-- favorite and trophy storages keep (balls have no id of their own). A trophy or favorite the trainer
-- doesn't have anymore (belt, bag or PC boxes) drops off the card when the card is opened.

TrainerCard = {}

TrainerCard.MAX_TROPHIES = 6
TrainerCard.ABOUT_LENGTH = 160
TrainerCard.ABOUT_LINES = 4
TrainerCard.PRIVACY = { playTime = 1, stats = 2, trophies = 4 }
TrainerCard.DUEL_RANGE = 7
-- each list also has to fit in one message (JSON.MESSAGE_BUDGET)
TrainerCard.PC_CANDIDATES = 60 -- the highest-level Pokemon from the PC boxes offered as trophies
TrainerCard.ACHIEVEMENTS = 100 -- entries in the Achievements tab and the title list

local TITLE = playersStorages.cardTitle
local ABOUT = playersStorages.cardAbout
local FAVORITE = playersStorages.cardFavorite
local TROPHIES = playersStorages.cardTrophies
local PRIVACY = playersStorages.cardPrivacy
local SINCE = playersStorages.trainerSince
local CLIENT = playersStorages.cardClient

-- Every region's badges in gym order; "upcoming" ones are not in the game yet and show as locked slots
-- (the badge case window in game_badgecase keeps the same list)
local BADGE_REGIONS = {
    { name = "Kanto", badges = { "BOULDER", "CASCADE", "THUNDER", "RAINBOW", "SOUL", "MARSH", "VOLCANO", "EARTH" } },
    { name = "Orange Islands", badges = { "CORAL_EYE", "SEA_RUBY", "SPIKE_SHELL", "JADE_STAR" } },
    { name = "Johto", upcoming = { "Zephyr", "Hive", "Plain", "Fog", "Storm", "Mineral", "Glacier", "Rising" } },
    { name = "Hoenn", upcoming = { "Stone", "Knuckle", "Dynamo", "Heat", "Balance", "Feather", "Mind", "Rain" } },
}

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.TRAINER_CARD, JSON.encode(data))
end

-- A list message drops entries from the end until it fits in one message (more = true)
local function sendList(cid, data, list)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.TRAINER_CARD, JSON.encodeWithin(data, "list", list))
end

local function result(cid, ok, text, ...)
    send(cid, { type = "result", ok = ok, text = string.format(__L(cid, text), ...) })
    return ok
end

local function storageText(cid, key)
    local value = getPlayerStorageValue(cid, key)
    if (value == -1 or value == nil) then
        return ""
    end
    return tostring(value)
end

local function sexName(sex)
    if (sex == POKEMON_SEX_FEMALE) then
        return "female"
    elseif (sex == POKEMON_SEX_MALE) then
        return "male"
    end
    return nil
end

local function keyOf(name, level, sex)
    return string.format("%s|%d|%d", name, level, sex or POKEMON_SEX_UNKNOWN)
end

local function parseKey(key)
    local name, level, sex = tostring(key or ""):match("^([^|;]+)|(%d+)|(%d+)$")
    if (not name) then
        return nil
    end
    return name, tonumber(level), tonumber(sex)
end

local function types(name)
    local list = {}
    for _, id in ipairs(getPokemonTypes(nil, name) or {}) do
        if (ELEMENT_NAMES[id]) then
            list[#list + 1] = ELEMENT_NAMES[id]
        end
    end
    return JSON.array(list)
end

TrainerCard.pokemon = function(name, level, sex)
    local monster = getMonsterInfo(name, false)
    return { key = keyOf(name, level, sex), name = name, level = level, sex = sexName(sex),
             number = getPokemonNumberByName(name), shiny = isShinyName(name) ~= nil or nil,
             look = monster and monster.outfit and monster.outfit.lookType or nil, types = types(name) }
end

-- Everything the trainer owns, for the edit mode: belt and bag first, then the PC boxes by level
local function candidates(cid, limit)
    local list, seen = {}, {}
    local function add(name, level, sex, where)
        local key = keyOf(name, level, sex)
        if (not seen[key]) then
            seen[key] = true
            local monster = getMonsterInfo(name, false)
            list[#list + 1] = { key = key, name = name, level = level, sex = sexName(sex),
                                number = getPokemonNumberByName(name), shiny = isShinyName(name) ~= nil or nil, where = where,
                                look = monster and monster.outfit and monster.outfit.lookType or nil }
        end
    end
    for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        add(getBallPokemonName(ball.uid), getBallPokemonLevel(ball.uid), getBallPokemonSex(ball.uid), "party")
    end
    local r = db.getResult(string.format("SELECT `ball_id`, `pokemon_name`, `pokemon_level`, `attributes`,"
        .. " LENGTH(`attributes`) AS `attrlen` FROM `pc_boxes` WHERE `player_id` = %d AND `box` > 0"
        .. " ORDER BY `pokemon_level` DESC LIMIT %d", getPlayerGUID(cid), limit or TrainerCard.PC_CANDIDATES))
    if (r:getID() ~= -1) then
        repeat
            local sex = POKEMON_SEX_UNKNOWN
            local uid = doCreateItemEx(r:getDataInt("ball_id"))
            if (uid and r:getDataInt("attrlen") > 0) then
                doItemLoadAttributes(uid, "attributes", r:getID())
                if (isBallWithPokemon(uid)) then
                    sex = getBallPokemonSex(uid)
                end
            end
            add(r:getDataString("pokemon_name"), r:getDataInt("pokemon_level"), sex, "pc")
        until not r:next()
        r:free()
    end
    return list
end

-- Whether the trainer still has this Pokemon: the exact ball with them, or the name and level in the PC
local function owns(cid, key)
    local name, level, sex = parseKey(key)
    if (not name) then
        return false
    end
    for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        if (keyOf(getBallPokemonName(ball.uid), getBallPokemonLevel(ball.uid), getBallPokemonSex(ball.uid)) == key) then
            return true
        end
    end
    local r = db.getResult(string.format("SELECT 1 FROM `pc_boxes` WHERE `player_id` = %d AND `box` > 0"
        .. " AND `pokemon_name` = %s AND `pokemon_level` = %d LIMIT 1", getPlayerGUID(cid), db.escapeString(name), level))
    if (r:getID() ~= -1) then
        r:free()
        return true
    end
    return false
end

local function getTrophyKeys(cid)
    local keys = {}
    for key in storageText(cid, TROPHIES):gmatch("[^;]+") do
        if (#keys < TrainerCard.MAX_TROPHIES) then
            keys[#keys + 1] = key
        end
    end
    return keys
end

-- Drops the favorite and trophies the trainer doesn't have anymore
TrainerCard.prune = function(cid)
    local favorite = storageText(cid, FAVORITE)
    if (favorite ~= "" and not owns(cid, favorite)) then
        setPlayerStorageValue(cid, FAVORITE, -1)
    end
    local kept, changed = {}, false
    for _, key in ipairs(getTrophyKeys(cid)) do
        if (owns(cid, key)) then
            kept[#kept + 1] = key
        else
            changed = true
        end
    end
    if (changed) then
        setPlayerStorageValue(cid, TROPHIES, #kept > 0 and table.concat(kept, ";") or -1)
    end
end

local function privacy(cid)
    return math.max(0, tonumber(getPlayerStorageValue(cid, PRIVACY)) or 0)
end

local function hides(cid, what)
    local flag = TrainerCard.PRIVACY[what]
    return math.floor(privacy(cid) / flag) % 2 == 1
end

-- The titles the trainer can display: their vocation's titles up to their rank, then their achievements
TrainerCard.titles = function(cid)
    local list = {}
    local vocation = Vocations.get(cid)
    if (vocation) then
        for r = Vocations.getRank(cid), 1, -1 do
            list[#list + 1] = { key = "v" .. r, text = __L(cid, vocation.titles[r]), group = "vocation",
                                detail = string.format(__L(cid, "%s, rank %d"), __L(cid, vocation.name), r) }
        end
    end
    local r = db.getResult(string.format("SELECT `key` FROM `player_achievements` WHERE `player_id` = %d ORDER BY `key` DESC",
        getPlayerGUID(cid)))
    if (r:getID() ~= -1) then
        repeat
            local id = r:getDataInt("key")
            local name = getAchievementBaseName(id)
            if (name and #list < TrainerCard.ACHIEVEMENTS) then
                list[#list + 1] = { key = "a" .. id, text = __L(cid, name), group = "achievement",
                                    detail = __L(cid, getAchievementDescription(id) or "") }
            end
        until not r:next()
        r:free()
    end
    return list
end

-- The displayed title's text, nil when the key isn't one the trainer has earned
TrainerCard.titleText = function(cid, key)
    key = tostring(key or "")
    local rank = tonumber(key:match("^v(%d+)$"))
    if (rank) then
        local vocation = Vocations.get(cid)
        if (vocation and rank >= 1 and rank <= Vocations.getRank(cid)) then
            return __L(cid, vocation.titles[rank])
        end
        return nil
    end
    local id = tonumber(key:match("^a(%d+)$"))
    if (id and getAchievementBaseName(id) and getPlayerAchievement(cid, id)) then
        return __L(cid, getAchievementBaseName(id))
    end
    return nil
end

local function statistic(cid, key)
    local r = db.getResult(string.format("SELECT `value` FROM `player_statistics` WHERE `player_id` = %d AND `key` = %d LIMIT 1",
        getPlayerGUID(cid), key))
    if (r:getID() == -1) then
        return 0
    end
    local value = r:getDataInt("value")
    r:free()
    return value
end

local function achievementCount(cid)
    local r = db.getResult(string.format("SELECT COUNT(*) AS `total` FROM `player_achievements` WHERE `player_id` = %d",
        getPlayerGUID(cid)))
    if (r:getID() == -1) then
        return 0
    end
    local total = r:getDataInt("total")
    r:free()
    return total
end

local achievementTotal
local function achievementsTotal()
    if (not achievementTotal) then
        achievementTotal = 0
        for _ in pairs(ACHIEVEMENT_IDS) do
            achievementTotal = achievementTotal + 1
        end
    end
    return achievementTotal
end

local function playTime(cid)
    local total = math.max(0, tonumber(getPlayerStorageValue(cid, playersStorages.playTime)) or 0)
    local start = tonumber(getPlayerStorageValue(cid, playersStorages.playSessionStart)) or 0
    if (start > 0) then
        total = total + math.max(0, os.time() - start)
    end
    return total
end

local function mastery(cid)
    if (not getPlayerMastery(cid)) then
        return nil
    end
    local name = getVocationInfo(getPlayerVocation(cid)).name or ""
    return (name:gsub("^(%S+) ", "%1 \194\183 "))
end

local function badges(cid)
    local regions = {}
    for _, region in ipairs(BADGE_REGIONS) do
        local list = {}
        for _, id in ipairs(region.badges or {}) do
            local badge = BADGES[id]
            local earned = getPlayerItemCount(cid, badge.newItemId) > 0
            local info = getItemInfo(earned and badge.newItemId or badge.oldItemId)
            list[#list + 1] = { name = badge.name, client = info and info.clientId or 0, earned = earned }
        end
        for _, name in ipairs(region.upcoming or {}) do
            list[#list + 1] = { name = name, upcoming = true }
        end
        regions[#regions + 1] = { region = region.name, list = list }
    end
    return regions
end

local function favoriteOf(cid)
    local name, level, sex = parseKey(storageText(cid, FAVORITE))
    if (name) then
        return TrainerCard.pokemon(name, level, sex)
    end
    local ball = getPlayerAllBallsWithPokemon(cid)[1]
    if (ball) then
        local data = TrainerCard.pokemon(getBallPokemonName(ball.uid), getBallPokemonLevel(ball.uid), getBallPokemonSex(ball.uid))
        data.default = true
        return data
    end
    return nil
end

-- What the card shows; own adds the owner's settings, and the privacy settings only hide for others
TrainerCard.data = function(cid, target)
    local own = cid == target
    local vocation = Vocations.get(target)
    local outfit = getCreatureOutfit(target)
    local titleKey = storageText(target, TITLE)
    local title = TrainerCard.titleText(target, titleKey)
    if (not title) then
        titleKey = ""
        title = vocation and __L(target, Vocations.getTitle(target)) or __L(target, "Pokemon Trainer")
    end
    local guild = getPlayerGuildName(target)
    local town = getPlayerTown(target)
    local data = {
        type = "card", own = own, name = getCreatureName(target),
        sex = getPlayerSex(target) == PLAYERSEX_FEMALE and "female" or "male",
        level = getPlayerLevel(target), town = { id = town, name = getTownName(town) or "" },
        guild = (guild and guild ~= "") and guild or nil,
        guildRank = (guild and guild ~= "") and getPlayerGuildRank(target) or nil,
        mastery = mastery(target),
        since = math.max(0, tonumber(getPlayerStorageValue(target, SINCE)) or 0),
        duels = { won = math.max(0, getPlayerSkillLevel(target, PLAYER_SKILL_DUEL_WIN)),
                  lost = math.max(0, getPlayerSkillLevel(target, PLAYER_SKILL_DUEL_LOSS)) },
        respect = getPlayerRespect(target),
        title = title, titleKey = titleKey,
        outfit = { type = outfit.lookType, head = outfit.lookHead, body = outfit.lookBody, legs = outfit.lookLegs,
                   feet = outfit.lookFeet, addons = outfit.lookAddons },
        favorite = favoriteOf(target),
        badges = badges(target),
        about = storageText(target, ABOUT),
        privacy = own and privacy(target) or nil,
    }
    if (vocation) then
        data.vocation = { key = vocation.key, name = __L(cid, vocation.name), rank = Vocations.getRank(target),
                          maxRank = Vocations.MAX_RANK, title = __L(cid, Vocations.getTitle(target)) }
    end
    local hidden = {}
    if (own or not hides(target, "playTime")) then
        data.playTime = playTime(target)
    else
        hidden[#hidden + 1] = "playTime"
    end
    if (own or not hides(target, "stats")) then
        data.stats = { caught = getPlayerCaughts(target), dex = getPlayerTotalDexedPokemons(target), dexTotal = POKEMON_NUMBER,
                       unique = math.max(0, tonumber(getPlayerStorageValue(target, playersStorages.individualCaughts)) or 0),
                       shinies = statistic(target, PLAYER_STATISTIC_IDS.CATCH_SHINY_POKEMON),
                       tournaments = statistic(target, PLAYER_STATISTIC_IDS.WIN_TOURNAMENT),
                       achievements = achievementCount(target), achievementsTotal = achievementsTotal(),
                       trainers = statistic(target, PLAYER_STATISTIC_IDS.DEFEAT_NPC) }
    else
        hidden[#hidden + 1] = "stats"
    end
    local trophies = {}
    if (own or not hides(target, "trophies")) then
        for _, key in ipairs(getTrophyKeys(target)) do
            local name, level, sex = parseKey(key)
            if (name) then
                trophies[#trophies + 1] = TrainerCard.pokemon(name, level, sex)
            end
        end
    else
        hidden[#hidden + 1] = "trophies"
    end
    data.trophies = JSON.array(trophies)
    data.hidden = JSON.array(hidden)
    return data
end

-- The card for the Discord bot's /trainer (DiscordBridge trainer.lookup), also for trainers who are
-- offline: everything comes from the storages and tables, cid is set when the trainer is online.
-- What the trainer's privacy settings hide stays out and is listed in hidden.
TrainerCard.lookup = function(guid, cid)
    local online = cid ~= nil and isPlayer(cid)
    local function text(key)
        if (online) then
            return storageText(cid, key)
        end
        local r = db.getResult(string.format("SELECT `value` FROM `player_storage` WHERE `player_id` = %d AND `key` = %d LIMIT 1",
            guid, key))
        if (r:getID() == -1) then
            return ""
        end
        local value = r:getDataString("value")
        r:free()
        return value == "-1" and "" or value
    end
    local function number(key)
        return math.max(0, tonumber(text(key)) or 0)
    end
    local function hasAchievement(id)
        local r = db.getResult(string.format("SELECT 1 FROM `player_achievements` WHERE `player_id` = %d AND `key` = %d LIMIT 1",
            guid, id))
        if (r:getID() == -1) then
            return false
        end
        r:free()
        return true
    end

    local vocation
    for _, v in ipairs(Vocations.LIST) do
        if (v.id == tonumber(text(playersStorages.vocation))) then
            vocation = v
        end
    end
    local rank = vocation and math.max(1, math.min(Vocations.MAX_RANK, number(playersStorages.vocationRank))) or 0

    local titleKey = text(TITLE)
    local title
    local titleRank = tonumber(titleKey:match("^v(%d+)$"))
    local achievement = tonumber(titleKey:match("^a(%d+)$"))
    if (vocation and titleRank and titleRank >= 1 and titleRank <= rank) then
        title = vocation.titles[titleRank]
    elseif (achievement and getAchievementBaseName(achievement) and hasAchievement(achievement)) then
        title = getAchievementBaseName(achievement)
    end
    title = title or (vocation and vocation.titles[rank]) or "Pokemon Trainer"

    local flags = number(PRIVACY)
    local function hidden(what)
        return math.floor(flags / TrainerCard.PRIVACY[what]) % 2 == 1
    end

    local card = { title = title, about = text(ABOUT), since = number(SINCE), hidden = JSON.array() }
    if (vocation) then
        card.vocation = { key = vocation.key, name = vocation.name, rank = rank, maxRank = Vocations.MAX_RANK,
                          title = vocation.titles[rank] }
    end

    local name, level, sex = parseKey(text(FAVORITE))
    if (name) then
        card.favorite = TrainerCard.pokemon(name, level, sex)
    elseif (online) then
        card.favorite = favoriteOf(cid)
    end

    if (hidden("playTime")) then
        card.hidden[#card.hidden + 1] = "playTime"
    else
        card.playTime = online and playTime(cid) or number(playersStorages.playTime)
    end
    if (hidden("stats")) then
        card.hidden[#card.hidden + 1] = "stats"
    else
        card.dex = { seen = number(playersStorages.pokemonsDexeds), total = POKEMON_NUMBER }
    end
    local trophies = JSON.array()
    if (hidden("trophies")) then
        card.hidden[#card.hidden + 1] = "trophies"
    else
        for key in text(TROPHIES):gmatch("[^;]+") do
            local trophyName, trophyLevel, trophySex = parseKey(key)
            if (trophyName and #trophies < TrainerCard.MAX_TROPHIES) then
                trophies[#trophies + 1] = TrainerCard.pokemon(trophyName, trophyLevel, trophySex)
            end
        end
    end
    card.trophies = trophies

    -- badges are items: online anywhere on the trainer, offline the saved inventory (not the depot)
    local owned = {}
    if (not online) then
        local ids = {}
        for _, badge in pairs(BADGES) do
            ids[#ids + 1] = badge.newItemId
        end
        local r = db.getResult(string.format("SELECT DISTINCT `itemtype` FROM `player_items` WHERE `player_id` = %d AND `itemtype` IN (%s)",
            guid, table.concat(ids, ",")))
        if (r:getID() ~= -1) then
            repeat
                owned[r:getDataInt("itemtype")] = true
            until not r:next()
            r:free()
        end
    end
    local regions = JSON.array()
    for _, region in ipairs(BADGE_REGIONS) do
        if (region.badges) then
            local earned = JSON.array()
            for _, id in ipairs(region.badges) do
                local badge = BADGES[id]
                if ((online and getPlayerItemCount(cid, badge.newItemId) > 0) or owned[badge.newItemId]) then
                    earned[#earned + 1] = badge.name
                end
            end
            regions[#regions + 1] = { region = region.name, earned = earned, total = #region.badges }
        end
    end
    card.badges = regions
    return card
end

local function findTarget(cid, name)
    if (name == nil or name == "") then
        return cid
    end
    local target = getPlayerByName(tostring(name))
    if (not isPlayer(target) or (target ~= cid and isPlayerGhost(target))) then
        return nil
    end
    return target
end

TrainerCard.open = function(cid, name)
    if (not isPlayer(cid)) then
        return false
    end
    local target = findTarget(cid, name)
    if (not target) then
        return result(cid, false, "%s is not online.", tostring(name))
    end
    TrainerCard.prune(target)
    send(cid, TrainerCard.data(cid, target))
    return true
end

local function cleanAbout(text)
    text = tostring(text or ""):gsub("\r", ""):gsub("[%z\1-\9\11-\31\127]", "")
    local lines = {}
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if (#lines < TrainerCard.ABOUT_LINES) then
            lines[#lines + 1] = line
        end
    end
    text = table.concat(lines, "\n"):gsub("\n+$", "")
    if (#text > TrainerCard.ABOUT_LENGTH) then
        text = text:sub(1, TrainerCard.ABOUT_LENGTH)
        -- don't leave half a UTF-8 character
        text = text:gsub("[\192-\255][\128-\191]*$", "")
    end
    return text
end

TrainerCard.cleanAbout = cleanAbout

TrainerCard.save = function(cid, data)
    if (data.about ~= nil) then
        local about = cleanAbout(data.about)
        setPlayerStorageValue(cid, ABOUT, about ~= "" and about or -1)
    end
    if (data.title ~= nil) then
        local key = tostring(data.title)
        if (key ~= "" and not TrainerCard.titleText(cid, key)) then
            return result(cid, false, "You haven't earned that title.")
        end
        setPlayerStorageValue(cid, TITLE, key ~= "" and key or -1)
    end
    if (data.privacy ~= nil) then
        local flags = math.floor(tonumber(data.privacy) or 0)
        setPlayerStorageValue(cid, PRIVACY, math.max(0, math.min(7, flags)))
    end
    if (data.favorite ~= nil or data.trophies ~= nil) then
        local favorite = data.favorite ~= nil and tostring(data.favorite) or nil
        if (favorite and favorite ~= "" and not owns(cid, favorite)) then
            return result(cid, false, "You don't have that Pokemon anymore.")
        end
        local trophies
        if (type(data.trophies) == "table") then
            trophies = {}
            local seen = {}
            for _, key in ipairs(data.trophies) do
                key = tostring(key)
                if (#trophies >= TrainerCard.MAX_TROPHIES or seen[key]) then
                    break
                end
                if (not owns(cid, key)) then
                    return result(cid, false, "You don't have that Pokemon anymore.")
                end
                seen[key] = true
                trophies[#trophies + 1] = key
            end
        end
        if (favorite) then
            setPlayerStorageValue(cid, FAVORITE, favorite ~= "" and favorite or -1)
        end
        if (trophies) then
            setPlayerStorageValue(cid, TROPHIES, #trophies > 0 and table.concat(trophies, ";") or -1)
        end
    end
    send(cid, TrainerCard.data(cid, cid))
    return result(cid, true, "Your Trainer Card is saved.")
end

TrainerCard.sendAchievements = function(cid, name)
    local target = findTarget(cid, name)
    if (not target) then
        return result(cid, false, "%s is not online.", tostring(name))
    end
    local list = {}
    local earned = 0
    local r = db.getResult(string.format("SELECT `key` FROM `player_achievements` WHERE `player_id` = %d ORDER BY `key` DESC",
        getPlayerGUID(target)))
    if (r:getID() ~= -1) then
        repeat
            local id = r:getDataInt("key")
            earned = earned + 1
            local name = getAchievementBaseName(id)
            if (name and #list < TrainerCard.ACHIEVEMENTS and (target == cid or not getAchievementSecret(id))) then
                list[#list + 1] = { name = __L(cid, name), description = __L(cid, getAchievementDescription(id) or "") }
            end
        until not r:next()
        r:free()
    end
    sendList(cid, { type = "achievements", name = getCreatureName(target), earned = earned, total = achievementsTotal() }, list)
    return true
end

-- The card's Duel button: the same checks as using the duel item on the trainer
TrainerCard.duel = function(cid, name)
    local target = findTarget(cid, name)
    if (not target or target == cid) then
        return result(cid, false, "You must select a player.")
    end
    local from, to = getCreaturePosition(cid), getCreaturePosition(target)
    if (from.z ~= to.z or getDistanceBetween(from, to) > TrainerCard.DUEL_RANGE) then
        return result(cid, false, "Get closer to %s to ask for a duel.", getCreatureName(target))
    elseif (isPokemonOnline(cid)) then
        return result(cid, false, "You can't start or join a duel if you're using a Pokemon.")
    elseif (getPlayerDueling(cid)) then
        return result(cid, false, "You're already dueling.")
    elseif (getTilePzInfo(from)) then
        return result(cid, false, "You can't duel while you're on a protection zone.")
    elseif (getPlayerFrontierIsland(cid)) then
        return result(cid, false, "You can't duel while you're inside the Frontier Island.")
    elseif (getPlayerDueling(target)) then
        return result(cid, false, "This player is already dueling.")
    end
    if (getPlayerPartyDuel(cid)) then
        doPartyDuelInvite(cid, target)
    elseif (getPlayerPartyDuel(target)) then
        doPartyDuelJoin(target, cid)
    else
        setPlayerLastOpponent(cid, target)
        doPlayerSendChannelsDialog(cid, { CHANNEL_1_POKEMON, CHANNEL_2_POKEMON, CHANNEL_3_POKEMON,
                                          CHANNEL_4_POKEMON, CHANNEL_5_POKEMON, CHANNEL_6_POKEMON })
    end
    return true
end

TrainerCard.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or "")
    if (action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
    elseif (action == "open") then
        TrainerCard.open(cid, data.name)
    elseif (action == "titles") then
        sendList(cid, { type = "titles" }, TrainerCard.titles(cid))
    elseif (action == "candidates") then
        sendList(cid, { type = "candidates" }, candidates(cid))
    elseif (action == "save") then
        TrainerCard.save(cid, data)
    elseif (action == "achievements") then
        TrainerCard.sendAchievements(cid, data.name)
    elseif (action == "duel") then
        TrainerCard.duel(cid, data.name)
    end
end

TrainerCard.enabled = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1
end

TrainerCard.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
    if ((tonumber(getPlayerStorageValue(cid, SINCE)) or 0) <= 0) then
        setPlayerStorageValue(cid, SINCE, os.time())
    end
end
