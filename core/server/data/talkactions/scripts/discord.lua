-- !discord link | status | unlink | perks | help
-- Links the account of the speaking character to Discord (see 061-discordAccounts.lua).
-- Everything is sent only to the speaker; the command text is never shown to others.

local UNLINK_CONFIRM_SECONDS = 60
local pendingUnlink = {}

local function say(cid, text)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local CODE_ERRORS = {
    rate_limited = "You requested a code too recently. Please wait a moment and try again.",
    disabled = "Discord linking is disabled on this server.",
}

local function showHelp(cid, words)
    say(cid, string.concat("Discord account linking:\n",
        words, " link - get a one-time code, then use /link in the PokeVerse Discord server\n",
        words, " status - show whether this account is linked\n",
        words, " unlink - remove the link (asks for confirmation)\n",
        words, " perks - show the server boost perks everyone gets right now"))
end

local function requestCode(cid, accountId)
    if (DiscordAccounts.getLinkByAccount(accountId)) then
        say(cid, "This account is already linked to Discord. Use \"!discord unlink\" first to link another Discord user.")
        return
    end

    local code, err = doCreateDiscordLinkCode(accountId)
    if (not code) then
        say(cid, CODE_ERRORS[err] or "A code could not be created right now. Please try again later.")
        return
    end

    local text = string.concat("Your Discord link code is ", code, "\n\n",
        "In the PokeVerse Discord server, type: /link code:", code, "\n",
        "The code works once and expires in 10 minutes. Never share it with anyone.")
    say(cid, text)
    doPlayerPopupFYI(cid, text)
end

local function showStatus(cid, accountId)
    local link = DiscordAccounts.getLinkByAccount(accountId)
    if (not link) then
        say(cid, "This account is not linked to Discord. Type \"!discord link\" to get a code.")
        return
    end
    say(cid, string.concat("This account is linked to Discord since ", os.date("%Y-%m-%d", link.linked_at), "."))
end

local function unlink(cid, accountId, confirm)
    if (not DiscordAccounts.getLinkByAccount(accountId)) then
        doRevokeDiscordLinkCodes(accountId)
        pendingUnlink[accountId] = nil
        say(cid, "This account is not linked to Discord.")
        return
    end

    local requested = pendingUnlink[accountId]
    if (not confirm or not requested or os.time() - requested > UNLINK_CONFIRM_SECONDS) then
        pendingUnlink[accountId] = os.time()
        say(cid, string.concat("To remove the Discord link from this account, type \"!discord unlink confirm\" within ",
            UNLINK_CONFIRM_SECONDS, " seconds. Your characters are not affected."))
        return
    end

    pendingUnlink[accountId] = nil
    local link = DiscordAccounts.unlinkAccount(accountId)
    if (not link) then
        say(cid, "The link could not be removed. Please try again later.")
        return
    end

    DiscordBridge.emit({kind = "account_link", scope = "account", action = "unlinked", source = "game",
        discordUserId = link.discord_user_id})
    say(cid, "This account is no longer linked to Discord.")
end

local function showPerks(cid)
    if (not DiscordBoostPerks.isEnabled()) then
        say(cid, "Server boost perks are not available on this server.")
        return
    end
    say(cid, DiscordBoostPerks.describe() or
        "No server boost perks right now. Boosting the PokeVerse Discord to Level 1 unlocks perks for everyone.")
end

function onSay(cid, words, param, channel)
    if (string.lower(param or ""):match("^%s*perks%s*$")) then
        showPerks(cid)
        return true
    end
    if (not DiscordAccounts.isEnabled()) then
        say(cid, "Discord linking is not available on this server.")
        return true
    end

    local accountId = getPlayerAccountId(cid)
    local args = {}
    for word in string.gmatch(string.lower(param or ""), "%S+") do
        args[#args + 1] = word
    end
    local action = args[1] or ""
    words = string.sub(words, 1, 1) .. "discord"

    if (action == "link") then
        requestCode(cid, accountId)
    elseif (action == "status") then
        showStatus(cid, accountId)
    elseif (action == "unlink") then
        unlink(cid, accountId, args[2] == "confirm")
    else
        showHelp(cid, words)
    end
    return true
end
