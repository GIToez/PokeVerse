-- Sent by the client's PC window (PC, lib/ps/systems/067-pc.lua): "/pc <action> ...".
--   hello, close, box <n>, pokemon <id>, partymon <index> <name>, party, deposit <index> <box> <slot> <name>, withdraw <id>,
--   move <id> <box> [slot], rename <box> <name>, inbox, take <id>, takeall, tobox <id>, stash, bag,
--   stow <itemtype> <count>, stowall, unstow <itemtype> <count>, depot, opendepot, search <text>
-- Every action but hello and close needs the window opened at a locker; staff can "/pc open" anywhere.
function onSay(cid, words, param)
    local action, rest = (param or ""):match("^%s*(%a*)%s*(.-)%s*$")
    action = (action or ""):lower()
    local numbers = {}
    for n in rest:gmatch("%d+") do
        numbers[#numbers + 1] = tonumber(n)
    end
    local a, b, c = numbers[1], numbers[2], numbers[3]

    if (action == "hello") then
        PC.hello(cid)
        return true
    elseif (action == "close") then
        PC.close(cid)
        return true
    elseif (action == "open" and getPlayerAccess(cid) >= PC.STAFF_ACCESS) then
        PC.hello(cid)
        PC.open(cid, getThingPos(cid), true)
        return true
    elseif (not PC.isOpen(cid)) then
        return true
    end

    if (action == "box") then
        PC.sendBox(cid, a or 1)
    elseif (action == "pokemon" and a) then
        PC.sendPokemon(cid, a)
    elseif (action == "partymon" and a) then
        PC.sendPartyPokemon(cid, a, rest:match("^%d+%s+(.+)$") or "")
    elseif (action == "party") then
        PC.sendParty(cid)
    elseif (action == "deposit" and c) then
        PC.deposit(cid, a, b, c, rest:match("^%d+%s+%d+%s+%d+%s+(.+)$") or "")
    elseif (action == "withdraw" and a) then
        PC.withdraw(cid, a)
    elseif (action == "move" and b) then
        PC.move(cid, a, b, c)
    elseif (action == "rename" and a) then
        PC.rename(cid, a, rest:match("^%d+%s*(.*)$") or "")
    elseif (action == "inbox") then
        PC.sendInbox(cid)
    elseif (action == "take" and a) then
        PC.take(cid, a)
    elseif (action == "takeall") then
        PC.takeAll(cid)
    elseif (action == "tobox" and a) then
        PC.inboxToBox(cid, a)
    elseif (action == "stash") then
        PC.sendStash(cid)
    elseif (action == "bag") then
        PC.sendBag(cid)
    elseif (action == "stow" and b) then
        PC.stow(cid, a, b)
    elseif (action == "stowall") then
        PC.stowAll(cid)
    elseif (action == "unstow" and b) then
        PC.unstow(cid, a, b)
    elseif (action == "depot") then
        PC.sendDepot(cid)
    elseif (action == "opendepot") then
        PC.openDepot(cid)
    elseif (action == "search") then
        PC.search(cid, (rest:gsub("[^%w%s%.%-']", "")))
    end
    return true
end
