-- /legendary status                 what is out, the warnings, the mode, the next spawn and the cooldowns
-- /legendary spawn <name> [here]    spawn one now (in its habitat, or at your feet); ignores the gap, the
--                                   cooldowns and the limits, but not a second of the same species or a
--                                   second mythical. Regis come asleep, Mew in disguise.
-- /legendary set <birds|beasts|regis|eon>  the whole set (a member already out is skipped)
-- /legendary end <name>             send one away without a cooldown
-- /legendary move <name>            move it on now, the way it moves (flyers take off, Lugia and Kyogre dive)
-- /legendary health <name> <percent>
-- /legendary signs <name>           show its signs and trail now, and tell you the spots
-- /legendary mew [here]             Mew disguised as a Pokemon of the spot
-- /legendary reveal                 Mew shows its true self
-- /legendary wake <name>            wake a sleeping Regi
-- /legendary warn [here]            Mewtwo's psychic disturbance, then Mewtwo
-- /legendary mode <auto|manual>     manual: no scheduled spawns, what is out stays
-- /legendary next <duration>        move the next scheduled spawn, e.g. /legendary next 5m
-- /legendary cooldowns clear [name]
-- /legendary flyover <name> [dive]   a fly-over (or Lugia's shape under the sea) only you see, nothing spawns
-- Durations: s, m, h, d.
local USAGE = "Usage: /legendary status | spawn <name> [here] | set <birds|beasts|regis|eon> | end <name> | move <name> | " ..
	"health <name> <percent> | signs <name> | mew [here] | reveal | wake <name> | warn [here] | mode <auto|manual> | " ..
	"next <duration> | cooldowns clear [name] | flyover <name> [dive]"

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

local function findOut(cid, name)
	local target = WildLegendaries.find(name)
	if (not target and WildLegendaries.findFlight(name)) then
		reply(cid, WildLegendaries.getSpecies(name).name .. " is in the air (or under the sea) right now; it lands in a few seconds.")
	elseif (not target) then
		reply(cid, (WildLegendaries.getSpecies(name) and WildLegendaries.getSpecies(name).name or tostring(name)) ..
			" is not out.")
	end
	return target
end

function onSay(cid, words, param, channel)
	local args = {}
	for word in param:gmatch("%S+") do
		table.insert(args, word)
	end
	local command = (args[1] or "status"):lower()
	local here = args[#args] and args[#args]:lower() == "here"

	if (command == "status") then
		for _, line in ipairs(WildLegendaries.describe(true)) do
			reply(cid, line)
		end

	elseif (command == "spawn" or command == "mew") then
		local name = command == "mew" and "Mew" or table.concat(args, " ", 2, here and (#args - 1) or #args)
		local species = WildLegendaries.getSpecies(name)
		if (not species) then
			reply(cid, "Unknown legendary: " .. name)
			return true
		end
		local pos = here and getCreaturePosition(cid) or nil
		local created, info = WildLegendaries.spawn(species, pos, pos and WildLegendaries.areaAt(pos) or nil, "staff")
		if (created and WildLegendaries.isDisguised(created)) then
			reply(cid, string.format("Mew is out, disguised as a wild %s near %s.", getCreatureName(created), tostring(info)))
		else
			reply(cid, created and string.format("%s is out near %s.", species.name, tostring(info)) or info)
		end

	elseif (command == "set") then
		local set = WildLegendaries.getSet(args[2])
		if (not set) then
			reply(cid, "Sets: birds, beasts, regis, eon.")
			return true
		end
		local spawned = WildLegendaries.spawnSet(set, "staff")
		reply(cid, #spawned > 0 and string.format("%s: %d out.", set.name, #spawned) or "Every member is out already.")

	elseif (command == "end") then
		local name = table.concat(args, " ", 2)
		local flight = WildLegendaries.findFlight(name)
		if (flight) then
			WildLegendaries.endFlight(flight, "staff")
		else
			local target = findOut(cid, name)
			if (target) then
				WildLegendaries.finish(target, "staff")
			end
		end

	elseif (command == "move") then
		local target = findOut(cid, table.concat(args, " ", 2))
		if (target) then
			if (WildLegendaries.isDisguised(target) or WildLegendaries.isAsleep(target)) then
				reply(cid, "It doesn't move while asleep or in disguise.")
			else
				WildLegendaries.requestMove(target)
				reply(cid, string.format("%s moves on within a second (/legendary status shows where).", getCreatureName(target)))
			end
		end

	elseif (command == "health") then
		local percent = tonumber(args[3])
		local target = percent and findOut(cid, args[2])
		if (not percent) then
			reply(cid, USAGE)
		elseif (target) then
			percent = math.max(1, math.min(100, percent))
			local wanted = math.floor(getCreatureMaxHealth(target) * percent / 100)
			doCreatureAddHealth(target, wanted - getCreatureHealth(target))
			reply(cid, string.format("%s at %d%% health.", args[2], WildLegendaries.healthPercent(target)))
		end

	elseif (command == "signs") then
		local target = findOut(cid, table.concat(args, " ", 2))
		if (target) then
			local _, entry = WildLegendaries.find(args[2])
			local species = WildLegendaries.getSpecies(entry.name)
			WildLegendaries.showSigns(target, species, true)
			local spots = {}
			for _, spot in ipairs(WildLegendaries.trailOf(target)) do
				table.insert(spots, string.format("%d,%d,%d (%ds ago)", spot.x, spot.y, spot.z, os.time() - spot.at))
			end
			local path = WildLegendaries.pathOf(target)
			reply(cid, string.format("%s: trail %s; zones %s; next %s.", species.name,
				#spots > 0 and table.concat(spots, ", ") or "none yet",
				#path > 0 and table.concat(path, " > ") or "?",
				tostring(getCreatureStorage(target, WildLegendaries.MON.NEXT_ZONE))))
		end

	elseif (command == "reveal") then
		local target = findOut(cid, "Mew")
		if (target) then
			local mew, why = WildLegendaries.reveal(target, getCreatureName(cid))
			reply(cid, mew and "Mew shows its true self." or why)
		end

	elseif (command == "wake") then
		local target = findOut(cid, table.concat(args, " ", 2))
		if (target) then
			local ok, why = WildLegendaries.wake(target, getCreatureName(cid))
			reply(cid, ok and "Awake." or why)
		end

	elseif (command == "warn") then
		local species = WildLegendaries.getSpecies("Mewtwo")
		local ok, info = WildLegendaries.warn(species, "staff", here and getCreaturePosition(cid) or nil)
		reply(cid, ok and string.format("The disturbance builds near %s; Mewtwo comes in %s.", info,
			ServerExpEvent.formatDuration(WildLegendaries.CONFIG.warningSeconds)) or info)

	elseif (command == "mode") then
		local mode = (args[2] or ""):lower()
		if (mode ~= "auto" and mode ~= "manual") then
			reply(cid, "Mode: " .. (WildLegendaries.isManual() and "manual" or "auto") .. ". /legendary mode <auto|manual>")
			return true
		end
		WildLegendaries.setManual(mode == "manual")
		if (mode == "auto") then
			WildLegendaries.scheduleNext(os.time(), true)
		end
		reply(cid, mode == "manual" and "Manual: only staff start wild legendaries now." or
			("Auto: next wild legendary in " .. ServerExpEvent.formatDuration(WildLegendaries.getNextSpawn() - os.time()) .. "."))

	elseif (command == "next") then
		local seconds = parseDuration(args[2])
		if (not seconds) then
			reply(cid, USAGE)
			return true
		end
		WildLegendaries.setNextSpawn(os.time() + seconds)
		reply(cid, "Next wild legendary in " .. ServerExpEvent.formatDuration(seconds) .. "." ..
			(WildLegendaries.isManual() and " (Manual mode: it waits until you switch to auto.)" or ""))

	elseif (command == "flyover") then
		local dive = args[#args] and args[#args]:lower() == "dive"
		local name = table.concat(args, " ", 2, dive and (#args - 1) or #args)
		if (WildLegendaries.flyover(cid, name, dive and "dive" or "fly")) then
			reply(cid, "A " .. (dive and "swim-by" or "fly-over") .. " of " .. WildLegendaries.getSpecies(name).name ..
				" crosses your screen now; only you see it.")
		else
			reply(cid, "Unknown legendary: " .. name)
		end

	elseif (command == "cooldowns" and (args[2] or ""):lower() == "clear") then
		local species = args[3] and WildLegendaries.getSpecies(table.concat(args, " ", 3))
		WildLegendaries.clearCooldowns(species and species.name or nil)
		reply(cid, "Cooldowns cleared" .. (species and (" for " .. species.name) or "") .. ".")

	else
		reply(cid, USAGE)
	end
	return true
end
