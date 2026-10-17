-- /deco                              the set up now, this town's automatic props and the props saved near you
-- /deco sets                         every decoration set
-- /deco items <set>                  the props offered for a set (any item id works too)
-- /deco add <set> <prop name or id>  save a prop on the tile you face; it goes up whenever the set is up
-- /deco remove [set]                 delete the prop saved on the tile you face (no set: the set up now)
-- /deco list                         the props saved near you
-- /deco preview <set> [minutes]      put a set up for a while, to see it; /deco preview off ends it
-- /deco auto <on|off>                this town's automatic props around the temple
-- Wall props (wreaths, garlands, tapestries) hang on the wall you face. See Decorations in
-- lib/ps/systems/080-decorations.lua.
local USAGE = "Usage: /deco | sets | items <set> | add <set> <prop> | remove [set] | list | preview <set> [minutes] | preview off | auto <on|off>."

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function setName(id)
	return Decorations.SETS[id] and Decorations.SETS[id].name or tostring(id)
end

local function posText(pos)
	return string.format("%d, %d, %d", pos.x, pos.y, pos.z)
end

local function front(cid)
	local pos = getCreatureLookPosition(cid)
	return { x = pos.x, y = pos.y, z = pos.z }
end

local function showList(cid)
	local list = Decorations.spotsNear(getCreaturePosition(cid), Decorations.NEARBY)
	if (#list == 0) then
		reply(cid, string.format("No props are saved within %d tiles.", Decorations.NEARBY))
		return
	end
	reply(cid, string.format("Props saved within %d tiles:", Decorations.NEARBY))
	for _, entry in ipairs(list) do
		local spot = entry.spot
		reply(cid, string.format("  %s: %s at %s (by %s)%s", setName(spot.set), Decorations.itemName(spot.itemid),
			posText(spot.pos), spot.by ~= "" and spot.by or "?", entry.valid and "" or " - doesn't fit any more: " .. entry.why))
	end
end

local function showStatus(cid)
	local theme = Decorations.theme()
	local preview, endsAt = Decorations.getPreview()
	reply(cid, "Decorations up now: " .. (theme and setName(theme) or "none") ..
		(preview and string.format(" (preview until %s)", os.date("%H:%M", endsAt)) or ""))
	local zone = Weather.zoneAt(getCreaturePosition(cid))
	if (zone) then
		reply(cid, string.format("%s's automatic props: %s.", zone.name, Decorations.getNoAuto()[zone.id] and "off" or "on"))
	end
	showList(cid)
	reply(cid, USAGE)
end

function onSay(cid, words, param)
	param = param:gsub("^%s+", ""):gsub("%s+$", "")
	local command, rest = param:match("^(%S+)%s*(.*)$")
	command = (command or ""):lower()

	if (command == "") then
		showStatus(cid)
	elseif (command == "sets") then
		local list = {}
		for _, id in ipairs(Decorations.setIds()) do
			list[#list + 1] = id .. " (" .. setName(id) .. ")"
		end
		reply(cid, "Decoration sets: " .. table.concat(list, ", ") .. ".")
	elseif (command == "items") then
		local setId = Decorations.findSet(rest)
		if (not setId) then
			reply(cid, "Which set? /deco sets lists them.")
			return true
		end
		local list = {}
		for _, item in ipairs(Decorations.catalog(setId)) do
			list[#list + 1] = string.format("%s (%d%s)", item.name, item.id, item.wall and ", wall" or "")
		end
		reply(cid, setName(setId) .. " props: " .. table.concat(list, ", ") .. ".")
	elseif (command == "add") then
		local setText, itemText = rest:match("^(%S+)%s*(.*)$")
		local setId = Decorations.findSet(setText)
		if (not setId) then
			reply(cid, "Usage: /deco add <set> <prop name or id>. /deco sets lists the sets.")
			return true
		end
		local itemid, why = Decorations.findItem(setId, itemText)
		if (not itemid) then
			reply(cid, why)
			return true
		end
		local pos = front(cid)
		local ok, result = Decorations.addSpot(setId, pos, itemid, getCreatureName(cid))
		if (not ok) then
			reply(cid, result)
			return true
		end
		print(string.format("> Decorations: %s saved %s for %s at %s", getCreatureName(cid), Decorations.itemName(itemid),
			setName(setId), posText(pos)))
		reply(cid, string.format("Saved %s for %s at %s%s. %s", Decorations.itemName(itemid), setName(setId), posText(pos),
			result and " (it replaces the prop saved there)" or "",
			Decorations.theme() == setId and "It goes up in a second." or "It goes up with the set; /deco preview " .. setId .. " to see it now."))
	elseif (command == "remove") then
		local pos = front(cid)
		local setId = rest ~= "" and Decorations.findSet(rest) or Decorations.theme()
		if (rest ~= "" and not setId) then
			reply(cid, "Which set? /deco sets lists them.")
			return true
		end
		local removed = setId and Decorations.removeSpots(pos, setId) or {}
		if (#removed == 0) then
			local others = {}
			for _, spot in ipairs(Decorations.getSpots()) do
				if (spot.pos.x == pos.x and spot.pos.y == pos.y and spot.pos.z == pos.z) then
					others[#others + 1] = spot.set
				end
			end
			reply(cid, #others > 0 and "Saved on that tile for: " .. table.concat(others, ", ") .. ". Use /deco remove <set>."
				or "No prop is saved on the tile you face.")
			return true
		end
		print(string.format("> Decorations: %s removed %s's prop at %s", getCreatureName(cid), setName(setId), posText(pos)))
		reply(cid, string.format("Removed %s's %s at %s.", setName(setId), Decorations.itemName(removed[1].itemid), posText(pos)))
	elseif (command == "list") then
		showList(cid)
	elseif (command == "preview") then
		local setText, minutes = rest:match("^(%S*)%s*(%d*)$")
		if (setText and setText:lower() == "off") then
			if (not Decorations.getPreview()) then
				reply(cid, "No set is being previewed.")
				return true
			end
			Decorations.setPreview(nil)
			reply(cid, "Preview ended; the decorations go back to the calendar's.")
			return true
		end
		local setId = setText and Decorations.findSet(setText)
		minutes = tonumber(minutes) or Decorations.PREVIEW_MINUTES
		if (not setId) then
			reply(cid, "Usage: /deco preview <set> [minutes] or /deco preview off.")
			return true
		elseif (minutes < 1 or minutes > Decorations.PREVIEW_MAX_MINUTES) then
			reply(cid, "Minutes must be between 1 and " .. Decorations.PREVIEW_MAX_MINUTES .. ".")
			return true
		end
		Decorations.setPreview(setId, minutes)
		print(string.format("> Decorations: %s previews %s for %d minutes", getCreatureName(cid), setName(setId), minutes))
		reply(cid, string.format("%s is up for everyone for %d minutes (/deco preview off ends it).", setName(setId), minutes))
	elseif (command == "auto") then
		local value = rest:lower()
		local zone = Weather.zoneAt(getCreaturePosition(cid))
		if (value ~= "on" and value ~= "off") then
			reply(cid, "Usage: /deco auto <on|off>.")
		elseif (not zone) then
			reply(cid, "You are not in a town.")
		else
			Decorations.setAuto(zone.id, value == "on")
			print(string.format("> Decorations: %s turned %s's automatic props %s", getCreatureName(cid), zone.name, value))
			reply(cid, string.format("%s's automatic props are %s%s.", zone.name, value,
				value == "off" and "; only the props saved by hand go up there" or ""))
		end
	else
		reply(cid, USAGE)
	end
	return true
end
