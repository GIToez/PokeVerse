-- /beachswarm                 a swarm of Surfing Pikachu on a sunny beach (any beach when none is sunny)
-- /beachswarm <beach>         on that beach, e.g. /beachswarm slateport
-- /beachswarm end             send the swarm away
-- /beachswarm status          the swarm, the rare ones out and which beaches are sunny
local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function names()
	local list = {}
	for _, beach in ipairs(BeachPikachu.BEACHES) do
		list[#list + 1] = beach.name
	end
	return table.concat(list, ", ")
end

function onSay(cid, words, param, channel)
	local command = param:match("^%s*(.-)%s*$"):lower()
	if (command == "end" or command == "stop" or command == "off") then
		if (not BeachPikachu.endSwarm()) then
			reply(cid, "No beach swarm is running.")
		end
	elseif (command == "status") then
		local swarm = BeachPikachu.getSwarm()
		local sunny = {}
		for _, index in ipairs(BeachPikachu.sunnyBeaches()) do
			sunny[#sunny + 1] = BeachPikachu.BEACHES[index].name
		end
		local out = 0
		for _, rareCid in pairs(BeachPikachu.getRare()) do
			out = out + (isCreature(rareCid) and 1 or 0)
		end
		reply(cid, string.format("Beach swarm: %s. Rare ones out: %d. Summer: %s. Sunny beaches: %s.",
			swarm and string.format("%s, %d min left", swarm.beach.name, math.ceil((swarm.endsAt - os.time()) / 60)) or "none",
			out, BeachPikachu.isSummer() and "yes" or "no", #sunny > 0 and table.concat(sunny, ", ") or "none"))
	else
		local beach = nil
		if (command ~= "") then
			beach = BeachPikachu.findBeach(command)
			if (not beach) then
				reply(cid, "Unknown beach. Beaches: " .. names())
				return true
			end
		end
		local ok, result = BeachPikachu.startSwarm(beach, true)
		if (not ok) then
			reply(cid, result)
		end
	end
	return true
end
