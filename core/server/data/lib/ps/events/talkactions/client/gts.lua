-- Sent by the client's GTS window (GTS, lib/ps/systems/066-gts.lua): "/gts <action> ...".
--   close, category <id>, offers <item>, sell|buy <item> <amount> <price>, accept <offer> [amount],
--   cancel <offer>, mine, species [search], listings <name>, pokemon <offer>, mypokemon,
--   list <index> <price> <name> (the index-th Pokemon of mypokemon)
-- Every action but close needs the window opened at a Pokemon Center computer; staff can
-- "/gts open" anywhere.
function onSay(cid, words, param)
    local action, rest = (param or ""):match("^%s*(%a*)%s*(.-)%s*$")
    action = (action or ""):lower()
    local numbers = {}
    for n in rest:gmatch("%d+") do
        numbers[#numbers + 1] = tonumber(n)
    end
    local a, b, c = numbers[1], numbers[2], numbers[3]

    if (action == "close") then
        GTS.close(cid)
        return true
    elseif (action == "open" and getPlayerAccess(cid) >= GTS.STAFF_ACCESS) then
        GTS.open(cid, true)
        return true
    elseif (not GTS.isOpen(cid)) then
        return true
    end

    if (action == "category" and a) then
        GTS.sendCategory(cid, a)
    elseif (action == "offers" and a) then
        GTS.sendOffers(cid, a)
    elseif ((action == "sell" or action == "buy") and c) then
        GTS.createOffer(cid, action == "sell", a, b, c)
    elseif (action == "accept" and a) then
        GTS.accept(cid, a, b)
    elseif (action == "cancel" and a) then
        GTS.cancel(cid, a)
    elseif (action == "mine") then
        GTS.sendMine(cid)
    elseif (action == "species") then
        GTS.sendSpecies(cid, (rest:gsub("[^%w%s%.%-']", "")))
    elseif (action == "listings" and rest ~= "") then
        GTS.sendListings(cid, rest)
    elseif (action == "pokemon" and a) then
        GTS.sendPokemon(cid, a)
    elseif (action == "mypokemon") then
        GTS.sendMyPokemon(cid)
    elseif (action == "list" and b) then
        GTS.listPokemon(cid, a, b, rest:match("^%d+%s+%d+%s+(.+)$") or "")
    end
    return true
end
