-- The Bank window, opened by the bank NPCs (npc/scripts/bank.lua). Their keywords still work for clients without
-- the window.
--
-- The client talks JSON on EXTENDED_IDS.BANK:
--   client -> server  {action = "hello"} at login; {action = "deposit"|"withdraw", amount} (amount "all" for all);
--                     {action = "check", name}; {action = "transfer", name, amount}; {action = "history"};
--                     {action = "close"}
--   server -> client  {type = "bank", npc, balance, money} opens or refreshes the window;
--                     {type = "check", name, found, own, self}; {type = "history", rows = {{kind, amount, other,
--                     date}, ...}}; {type = "result", ok, text}; {type = "close"}
--
-- Every action needs the trainer near the NPC that opened the window. Transfers have no cap and may go to the
-- trainer's other characters; the receiver gets a message (and a refreshed window) if online.

Bank = {}

Bank.RANGE = 4
Bank.HISTORY_ROWS = 20

local CLIENT = playersStorages.bankClient
local NPC = playersStorages.bankNpc
local ACTIONS = { DEPOSIT = 0, WITHDRAW = 1, TRANSFER = 2 }

local function formatNumber(amount)
    local text = tostring(math.floor(amount))
    local formatted
    repeat
        text, formatted = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until formatted == 0
    return text
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.BANK, JSON.encode(data))
end

local function result(cid, ok, text)
    send(cid, { type = "result", ok = ok, text = text })
end

-- NPC scripts have their own Lua state, so the NPC that opened the window is kept by name in a storage
local function npcNear(cid)
    local name = getPlayerStorageValue(cid, NPC)
    if (type(name) ~= "string") then
        return nil
    end
    for _, creature in ipairs(getSpectators(getCreaturePosition(cid), Bank.RANGE, Bank.RANGE, false) or {}) do
        if (isNpc(creature) and getCreatureName(creature) == name) then
            return creature
        end
    end
    return nil
end

local function guidByName(name)
    local guid = getPlayerGUIDByName(name)
    if (not guid or guid == 0) then
        return nil
    end
    return guid
end

local function accountOf(guid)
    local r = db.getResult("SELECT `account_id` FROM `players` WHERE `id` = " .. tonumber(guid) .. ";")
    if (r:getID() == -1) then
        return nil
    end
    local account = r:getDataInt("account_id")
    r:free()
    return account
end

-- the amount the client asked for: a whole number of dollars from 1 up to max, or max for "all"
local function amountOf(value, max)
    if (value == "all") then
        return max > 0 and max or nil
    end
    local amount = tonumber(value)
    if (not amount or amount ~= math.floor(amount) or amount < 1 or amount > max) then
        return nil
    end
    return amount
end

Bank.enabled = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1 and
        getBooleanFromString(getConfigInfo('bankSystem'))
end

Bank.sendState = function(cid)
    local npc = getPlayerStorageValue(cid, NPC)
    send(cid, { type = "bank", npc = type(npc) == "string" and npc or "",
                balance = getPlayerBalance(cid), money = getPlayerMoney(cid) })
end

Bank.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
    setPlayerStorageValue(cid, NPC, -1)
end

-- A bank NPC greeting the trainer: opens the window. False for clients without it.
Bank.open = function(cid, npc)
    if (not Bank.enabled(cid)) then
        return false
    end
    setPlayerStorageValue(cid, NPC, getCreatureName(npc))
    Bank.sendState(cid)
    return true
end

local function deposit(cid, value)
    local money = getPlayerMoney(cid)
    local amount = amountOf(value, money)
    if (not amount) then
        return result(cid, false, money > 0 and __L(cid, "You don't carry that much money.") or
            __L(cid, "You don't carry any money."))
    end
    if (not doPlayerDepositMoney(cid, amount)) then
        return result(cid, false, __L(cid, "The deposit could not be completed."))
    end
    doDatalogBankTransaction(ACTIONS.DEPOSIT, getPlayerGUID(cid), 0, amount, os.time())
    Bank.sendState(cid)
    result(cid, true, string.format(__L(cid, "You deposited $%s."), formatNumber(amount)))
end

local function withdraw(cid, value)
    local balance = getPlayerBalance(cid)
    local amount = amountOf(value, balance)
    if (not amount) then
        return result(cid, false, balance > 0 and __L(cid, "You don't have that much in the bank.") or
            __L(cid, "Your bank account is empty."))
    end
    if (not doPlayerWithdrawMoney(cid, amount)) then
        return result(cid, false, __L(cid, "You can't carry that much. Make room in your bag and try again."))
    end
    doDatalogBankTransaction(ACTIONS.WITHDRAW, 0, getPlayerGUID(cid), amount, os.time())
    Bank.sendState(cid)
    result(cid, true, string.format(__L(cid, "You withdrew $%s."), formatNumber(amount)))
end

local function check(cid, name)
    name = type(name) == "string" and name:gsub("^%s+", ""):gsub("%s+$", "") or ""
    local guid = name ~= "" and guidByName(name) or nil
    if (not guid) then
        return send(cid, { type = "check", name = name, found = false })
    end
    send(cid, { type = "check", name = getPlayerNameByGUID(guid), found = true, self = guid == getPlayerGUID(cid),
                own = accountOf(guid) == getPlayerAccountId(cid) })
end

local function transfer(cid, name, value)
    name = type(name) == "string" and name:gsub("^%s+", ""):gsub("%s+$", "") or ""
    local guid = name ~= "" and guidByName(name) or nil
    if (not guid) then
        return result(cid, false, __L(cid, "There is no trainer with that name."))
    end
    if (guid == getPlayerGUID(cid)) then
        return result(cid, false, __L(cid, "You can't send money to yourself."))
    end
    local balance = getPlayerBalance(cid)
    local amount = amountOf(value, balance)
    if (not amount) then
        return result(cid, false, balance > 0 and __L(cid, "You don't have that much in the bank.") or
            __L(cid, "Your bank account is empty."))
    end
    local target = getPlayerNameByGUID(guid)
    if (not doPlayerTransferMoneyTo(cid, target, amount)) then
        return result(cid, false, __L(cid, "The transfer could not be completed."))
    end
    doDatalogBankTransaction(ACTIONS.TRANSFER, getPlayerGUID(cid), guid, amount, os.time())
    Bank.sendState(cid)
    result(cid, true, string.format(__L(cid, "You sent $%s to %s."), formatNumber(amount), target))

    local receiver = getPlayerByName(target)
    if (receiver and isPlayer(receiver)) then
        doPlayerSendTextMessage(receiver, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
            __L(receiver, "%s sent $%s to your bank account."), getCreatureName(cid), formatNumber(amount)))
        if (npcNear(receiver)) then
            Bank.sendState(receiver)
        end
    end
end

local function history(cid)
    local guid = getPlayerGUID(cid)
    local rows = JSON.array()
    local r = db.getResult("SELECT `action_id`, `sender`, `receiver`, `amount`, `date` FROM `datalog_bank_transactions`" ..
        " WHERE `sender` = " .. guid .. " OR `receiver` = " .. guid .. " ORDER BY `date` DESC, `id` DESC LIMIT " ..
        Bank.HISTORY_ROWS .. ";")
    if (r:getID() ~= -1) then
        repeat
            local action, sender, receiver = r:getDataInt("action_id"), r:getDataInt("sender"), r:getDataInt("receiver")
            local row = { amount = r:getDataLong("amount"), date = r:getDataInt("date") }
            if (action == ACTIONS.DEPOSIT) then
                row.kind = "deposit"
            elseif (action == ACTIONS.WITHDRAW) then
                row.kind = "withdraw"
            elseif (sender == guid) then
                row.kind, row.other = "sent", getPlayerNameByGUID(receiver) or "?"
            else
                row.kind, row.other = "received", getPlayerNameByGUID(sender) or "?"
            end
            rows[#rows + 1] = row
        until not r:next()
        r:free()
    end
    send(cid, { type = "history", rows = rows })
end

Bank.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
        return
    end
    if (data.action == "close") then
        setPlayerStorageValue(cid, NPC, -1)
        return
    end
    if (not npcNear(cid)) then
        setPlayerStorageValue(cid, NPC, -1)
        send(cid, { type = "close" })
        return result(cid, false, __L(cid, "You walked away from the bank."))
    end

    if (data.action == "deposit") then
        deposit(cid, data.amount)
    elseif (data.action == "withdraw") then
        withdraw(cid, data.amount)
    elseif (data.action == "check") then
        check(cid, data.name)
    elseif (data.action == "transfer") then
        transfer(cid, data.name, data.amount)
    elseif (data.action == "history") then
        history(cid)
    end
end
