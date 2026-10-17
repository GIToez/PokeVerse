-- /weather                                     the weather where you stand, and in every zone of your region
-- /weather status                              every live zone's weather
-- /weather <zone|region|all|here> <kind> [minutes]   set the weather (no minutes: until /weather ... auto)
-- /weather <zone|region|all|here> auto         back to the rolled weather
-- /weather off                                 clear every weather staff set
-- /weather time <day|night|dusk|HH:MM>         move the day and night cycle (to preview the light)
-- Zones are towns ("viridian", "desertisland92"); regions: kanto, hoenn, orange.
local USAGE = "Usage: /weather | status | <zone|region|all|here> <kind> [minutes] | <zone|region|all|here> auto | off | time <day|night|HH:MM>. Kinds: "
	.. table.concat(Weather.KIND_IDS, ", ") .. "."

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function describe(zone)
	local weather = Weather.at(zone)
	local until_ = weather.source == "staff" and (weather.endsAt == 0 and " (staff, until cleared)"
		or " (staff, until " .. os.date("%H:%M", weather.endsAt) .. ")")
		or (weather.source == "holiday" and " (" .. weather.holiday .. ")" or " until " .. os.date("%H:%M", weather.endsAt))
	return string.format("%s: %s%s", zone.name, Weather.KINDS[weather.kind].name, until_)
end

local function ids(zones)
	local list = {}
	for _, zone in ipairs(zones) do
		list[#list + 1] = zone.id
	end
	return list
end

local function sendAll()
	for _, pid in ipairs(getPlayersOnline()) do
		Weather.send(pid)
	end
end

function onSay(cid, words, param, channel)
	local target, kind, minutes = param:lower():match("^%s*(%S*)%s*(%S*)%s*(%S*)%s*$")
	local season = EventCalendar.currentSeason()

	if (target == "" or target == "status") then
		local here = Weather.zoneAt(getCreaturePosition(cid))
		local region = here and here.region
		reply(cid, string.format("Season: %s. You are in %s (%s), %s.", season.season.name, here and here.name or "no zone",
			region and region.name or "-", Weather.isOutdoors(getCreaturePosition(cid)) and "outdoors" or "under a roof"))
		for _, zone in ipairs(Weather.getZones()) do
			if (not zone.none and zone.region.live and (target == "status" or zone.region == region)) then
				reply(cid, describe(zone))
			end
		end
		if (target == "") then
			reply(cid, USAGE)
		end
		return true
	elseif (target == "time") then
		local presets = { day = 12 * 60, night = 0, dusk = 21 * 60 + 40, dawn = 7 * 60 + 5 }
		local hours, mins = kind:match("^(%d+):(%d+)$")
		local minutesOfDay = presets[kind] or (hours and tonumber(hours) * 60 + tonumber(mins))
		if (not minutesOfDay or not doSetWorldLightHour) then
			reply(cid, "Usage: /weather time <day|night|dawn|dusk|HH:MM>.")
			return true
		end
		doSetWorldLightHour(minutesOfDay)
		reply(cid, string.format("The game clock is now %02d:%02d.", math.floor(minutesOfDay / 60), minutesOfDay % 60))
		return true
	elseif (target == "off") then
		local all = {}
		for _, zone in ipairs(Weather.getZones()) do
			all[#all + 1] = zone.id
		end
		Weather.setOverride(all, nil)
		sendAll()
		reply(cid, "Cleared every weather staff set.")
		print(string.format("> Weather: %s cleared the staff weather", getCreatureName(cid)))
		return true
	end

	local zones = Weather.findZones(cid, target)
	if (#zones == 0) then
		reply(cid, "No live zone or region called '" .. target .. "'. " .. USAGE)
		return true
	elseif (kind ~= "auto" and not Weather.KINDS[kind]) then
		reply(cid, USAGE)
		return true
	end
	local time = tonumber(minutes)
	if (minutes ~= "" and (not time or time <= 0)) then
		reply(cid, "Minutes must be a number above 0.")
		return true
	end

	Weather.setOverride(ids(zones), kind ~= "auto" and kind or nil, time)
	sendAll()
	local names = #zones == 1 and zones[1].name or (#zones .. " zones")
	if (kind == "auto") then
		reply(cid, names .. " back to the rolled weather.")
	else
		reply(cid, string.format("%s: %s %s.", names, Weather.KINDS[kind].name, time and ("for " .. time .. " minutes") or "until cleared"))
	end
	print(string.format("> Weather: %s set %s to %s%s", getCreatureName(cid), target, kind, time and (" for " .. time .. " min") or ""))
	return true
end
