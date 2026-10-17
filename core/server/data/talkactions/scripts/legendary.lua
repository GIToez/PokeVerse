-- /legendary status               what is out, the next spawn, the population row and the cooldowns
-- /legendary spawn <name> [here]  spawn one now (on a random point, or at your feet); ignores the gap,
--                                 the cooldowns and the limits, but not a second of the same species
-- /legendary end <name>           send one away without a cooldown
-- /legendary next <duration>      move the next scheduled spawn, e.g. /legendary next 5m
-- /legendary cooldowns clear [name]
-- Durations: s, m, h, d.
local USAGE = "Usage: /legendary status | spawn <name> [here] | end <name> | next <duration> | cooldowns clear [name]"

local UNITS = { s = 1, m = 60, h = 3600, d = 86400 }

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function parseDuration(text)
	local amount, unit = tostring(text or ""):match("^(%d+)%s*([smhd]?)$")
	if (not amount) then
		return nil
	end
	return tonumber(amount) * UNITS[unit ~= "" and unit or "m"]
end

function onSay(cid, words, param, channel)
	local args = {}
	for word in param:gmatch("%S+") do
		table.insert(args, word)
	end
	local command = (args[1] or "status"):lower()

	if (command == "status") then
		for _, line in ipairs(WildLegendaries.describe(true)) do
			reply(cid, line)
		end

	elseif (command == "spawn") then
		local here = args[#args] and args[#args]:lower() == "here"
		local name = table.concat(args, " ", 2, here and (#args - 1) or #args)
		local species = WildLegendaries.getSpecies(name)
		if (not species) then
			reply(cid, "Unknown legendary: " .. name)
			return true
		end
		local pos, area
		if (here) then
			pos = getCreaturePosition(cid)
			area = "your position"
		end
		local created, err = WildLegendaries.spawn(species, pos, area, "staff")
		reply(cid, created and (species.name .. " is out.") or err)

	elseif (command == "end") then
		local target = WildLegendaries.find(table.concat(args, " ", 2))
		if (not target) then
			reply(cid, "That legendary is not out.")
			return true
		end
		WildLegendaries.finish(target, "staff")

	elseif (command == "next") then
		local seconds = parseDuration(args[2])
		if (not seconds) then
			reply(cid, USAGE)
			return true
		end
		WildLegendaries.setNextSpawn(os.time() + seconds)
		reply(cid, "Next wild legendary in " .. ServerExpEvent.formatDuration(seconds) .. ".")

	elseif (command == "cooldowns" and (args[2] or ""):lower() == "clear") then
		local species = args[3] and WildLegendaries.getSpecies(table.concat(args, " ", 3))
		WildLegendaries.clearCooldowns(species and species.name or nil)
		reply(cid, "Cooldowns cleared" .. (species and (" for " .. species.name) or "") .. ".")

	else
		reply(cid, USAGE)
	end
	return true
end
