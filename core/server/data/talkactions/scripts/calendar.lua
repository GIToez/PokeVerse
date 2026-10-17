-- /calendar                              what runs now and the next events (30 days)
-- /calendar list                         the events staff added, with their numbers
-- /calendar add once 2026-11-06 18:00 2d exp=2 Name      one time, server time, for 2 days
-- /calendar add weekend exp=1.5 Name                     every weekend (Friday's to Monday's restart)
-- /calendar add weekend 1 loot=2 Name                    the first (1-5, or last) weekend of every month
-- /calendar add yearly 11-06 18:00 1d exp=2,shiny=2 Name every year on that date
-- /calendar remove <number>
-- /calendar holiday <id> on | off | auto force a holiday on or off, or back to its dates
-- Bonuses: exp, shiny, loot, breeding, fishing (above 1x, up to 10x), joined with commas.
local USAGE = "Usage: /calendar | list | add <once|weekend|yearly> ... <bonuses> <name> | remove <number> | holiday <id> on|off|auto"

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function holidayIds()
	local ids = {}
	for _, holiday in ipairs(EventCalendar.HOLIDAYS) do
		ids[#ids + 1] = holiday.id
	end
	return table.concat(ids, ", ")
end

function onSay(cid, words, param, channel)
	local command, rest = param:match("^%s*(%S*)%s*(.-)%s*$")
	command = (command or ""):lower()
	local now = os.time()

	if (command == "") then
		for _, event in ipairs(EventCalendar.getEvents(now, now + 30 * 24 * 60 * 60)) do
			local running = event.startsAt <= now
			reply(cid, string.format("%s %s: %s to %s. %s", running and "[now]" or "-", event.name,
				os.date("%Y-%m-%d %H:%M", event.startsAt), os.date("%Y-%m-%d %H:%M", event.endsAt), event.description))
		end
		reply(cid, USAGE)
	elseif (command == "list") then
		local events = EventCalendar.getStaffEvents()
		if (#events == 0) then
			reply(cid, "No staff events. The holidays are: " .. holidayIds() .. ".")
		end
		for _, event in ipairs(events) do
			reply(cid, string.format("#%d %s: %s, %s.", event.id, event.name, EventCalendar.describeRule(event),
				EventCalendar.formatBonuses(event.bonuses)))
		end
	elseif (command == "add") then
		local event, err = EventCalendar.parseAdd(rest)
		if (not event) then
			reply(cid, err)
			return true
		end
		EventCalendar.addStaffEvent(event, getCreatureName(cid))
		reply(cid, string.format("Added %s: %s, %s. It takes effect within a minute.", event.name, EventCalendar.describeRule(event),
			EventCalendar.formatBonuses(event.bonuses)))
		print(string.format("> Event calendar: %s added %s (%s)", getCreatureName(cid), event.name, rest))
	elseif (command == "remove") then
		local id = tonumber(rest)
		if (not id or not EventCalendar.removeStaffEvent(id)) then
			reply(cid, "There is no staff event with that number. See /calendar list.")
			return true
		end
		reply(cid, "Removed event #" .. id .. ".")
		print(string.format("> Event calendar: %s removed event #%d", getCreatureName(cid), id))
	elseif (command == "holiday") then
		local id, mode = rest:lower():match("^(%S+)%s+(%S+)$")
		local values = { on = true, off = false, auto = nil }
		if (not id or not EventCalendar.getHoliday(id) or (mode ~= "on" and mode ~= "off" and mode ~= "auto")) then
			reply(cid, "Usage: /calendar holiday <id> on|off|auto. Holidays: " .. holidayIds() .. ".")
			return true
		end
		EventCalendar.setForced(id, values[mode])
		reply(cid, string.format("%s is now %s (in effect within a minute).", EventCalendar.getHoliday(id).name,
			mode == "auto" and "back to its dates" or ("forced " .. mode)))
		print(string.format("> Event calendar: %s set %s to %s", getCreatureName(cid), id, mode))
	else
		reply(cid, USAGE)
	end
	return true
end
