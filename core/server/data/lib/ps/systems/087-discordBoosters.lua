-- Discord booster rewards: Verse Orbs for every 7 days of continuous server boosting, paid to
-- the game account linked to the booster (061-discordAccounts.lua). Switched by
-- discordBridgeBoosterRewards; needs discordBridgeAccountLinking too.
--
-- The bot only says which boost week of which streak is complete. The game owns the amounts
-- (config) and the ledger `discord_booster_rewards` (schemas/pokeverse-extensions.sql), so a
-- retry, a lost bot state file or a replayed old streak never pays twice. The ledger row and
-- the Verse Orbs are written together in C++ (doDiscordBoosterDeposit, src/discordbridge.cpp)
-- inside one transaction; never read-modify-write `soulcoins` here. On loyalty weeks the
-- community bonus adds +1 per discordBridgeBoosterCommunityEvery server boosts the bot reports,
-- capped at discordBridgeBoosterCommunityMax.

DiscordBoosters = {}

local WEEK = 7 * 24 * 60 * 60
local CLOCK_SKEW = 300
local MAX_WEEK = 5200
local MAX_SERVER_BOOSTS = 1000

local fail = DiscordBridge.fail
local queryRows = DiscordBridge.queryRows

local function info()
    return getDiscordBridgeInfo and getDiscordBridgeInfo() or {}
end

function DiscordBoosters.isEnabled()
    return info().boosterRewards == true
end

local function requireEnabled()
    if (not DiscordBoosters.isEnabled()) then
        fail("disabled", "booster rewards are disabled on this server")
    end
end

local function isInteger(value)
    return type(value) == "number" and value == math.floor(value)
end

local function validDiscordUserId(id)
    return type(id) == "string" and id:match("^%d+$") ~= nil and #id >= 17 and #id <= 20
end

local REWARD_FIELDS = {week = "number", weekly = "number", loyalty = "number", yearly = "number", community = "number",
    total = "number"}

local function storedWeek(discordUserId, boostSince, week)
    return queryRows(string.concat("SELECT `week`, IFNULL(`weekly`, 0) AS `weekly`, IFNULL(`loyalty`, 0) AS `loyalty`, ",
        "IFNULL(`yearly`, 0) AS `yearly`, IFNULL(`community`, 0) AS `community`, IFNULL(`total`, 0) AS `total` ",
        "FROM `discord_booster_rewards` ",
        "WHERE `discord_user_id` = ", db.escapeString(discordUserId), " AND `boost_since` = ", string.format("%d", boostSince),
        " AND `week` = ", week, " LIMIT 1;"), REWARD_FIELDS)[1]
end

-- A streak is stale when the user was already paid for a newer streak, or when it is not the
-- streak of the last payout but started before that payout (an old streak sent again).
local function isStaleStreak(discordUserId, boostSince)
    local escaped = db.escapeString(discordUserId)
    local since = string.format("%d", boostSince)
    local newer = DiscordBridge.queryNumber(string.concat("SELECT COUNT(*) AS `count` FROM `discord_booster_rewards` ",
        "WHERE `discord_user_id` = ", escaped, " AND `boost_since` > ", since, ";"), "count") or 0
    if (newer > 0) then
        return true
    end

    local last = queryRows(string.concat("SELECT `boost_since`, `created_at` FROM `discord_booster_rewards` ",
        "WHERE `discord_user_id` = ", escaped, " ORDER BY `created_at` DESC, `id` DESC LIMIT 1;"),
        {boost_since = "long", created_at = "long"})[1]
    return last ~= nil and last.boost_since ~= boostSince and boostSince < last.created_at
end

local function coinsText(amount)
    return amount == 1 and "1 Verse Orb was" or string.format("%d Verse Orbs were", amount)
end

local function notifyAccount(accountId, total)
    local message = string.concat("Thank you for boosting the PokeVerse Discord! ", coinsText(total),
        " added to your Verse Orb balance (spend ", total == 1 and "it" or "them", " in the Store).")
    for _, cid in ipairs(getPlayersOnline()) do
        if (getPlayerAccountId(cid) == accountId) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, message)
        end
    end
end

local function reply(reward, deposited)
    return {deposited = deposited, week = reward.week, weekly = reward.weekly, loyalty = reward.loyalty,
        yearly = reward.yearly, community = reward.community or 0, total = reward.total}
end

local function handleRules()
    requireEnabled()
    local rules = info().booster or {}
    local perks = JSON.array()
    if (DiscordBoostPerks and DiscordBoostPerks.isEnabled()) then
        for _, perk in ipairs(DiscordBoostPerks.list()) do
            perks[#perks + 1] = perk
        end
    end
    return {weekly = rules.weekly or 0, loyaltyEvery = rules.loyaltyEvery or 0, loyalty = rules.loyalty or 0,
        yearlyEvery = rules.yearlyEvery or 0, yearly = rules.yearly or 0, communityEvery = rules.communityEvery or 0,
        communityMax = rules.communityMax or 0, perks = perks}
end

local function handleWeek(params)
    requireEnabled()
    local discordUserId, boostSince, week = params.discordUserId, params.boostSince, params.week
    -- A bot from before the community bonus sends no count; that only loses the bonus.
    local serverBoosts = params.serverBoosts == nil and 0 or params.serverBoosts
    local now = os.time()
    if (not validDiscordUserId(discordUserId)) then
        fail("invalid_params", "invalid Discord user id")
    end
    if (not isInteger(boostSince) or boostSince <= 0 or boostSince > now) then
        fail("invalid_params", "boostSince must be a past unix time in seconds")
    end
    if (not isInteger(week) or week < 1 or week > MAX_WEEK) then
        fail("invalid_params", string.format("week must be an integer from 1 to %d", MAX_WEEK))
    end
    if (not isInteger(serverBoosts) or serverBoosts < 0 or serverBoosts > MAX_SERVER_BOOSTS) then
        fail("invalid_params", string.format("serverBoosts must be an integer from 0 to %d", MAX_SERVER_BOOSTS))
    end

    local link = DiscordAccounts.getLinkByDiscordUser(discordUserId)
    if (not link) then
        fail("not_linked", "this Discord user is not linked")
    end

    local completedAt = boostSince + week * WEEK
    if (completedAt > now + CLOCK_SKEW) then
        fail("not_due", "that boost week is not complete yet")
    end

    local stored = storedWeek(discordUserId, boostSince, week)
    if (stored) then
        return reply(stored, false)
    end

    if (completedAt < link.linked_at) then
        fail("before_link", "that boost week was completed before the account was linked")
    end
    if (isStaleStreak(discordUserId, boostSince)) then
        fail("stale_streak", "that boost streak was replaced by a newer one")
    end

    local reward, err = doDiscordBoosterDeposit(discordUserId, link.account_id, boostSince, week, serverBoosts)
    if (not reward) then
        fail(err or "internal", "the reward could not be deposited")
    end
    if (reward.deposited) then
        print(string.format("> Discord booster reward: week %d, %d Verse Orbs to account %d.", week, reward.total,
            link.account_id))
        if (reward.total > 0) then
            notifyAccount(link.account_id, reward.total)
        end
    end
    return reply(reward, reward.deposited)
end

DiscordBridge.registerHandler("booster.rules", handleRules)
DiscordBridge.registerHandler("booster.week", handleWeek)
