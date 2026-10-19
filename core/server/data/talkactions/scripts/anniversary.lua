-- /anniversary                 whether the Anniversary runs, the Union Room entrance and the cake invasion
-- /anniversary show [minutes]  show the entrance sign and teleport for a while (default 30, 0: until hidden)
--                              without the holiday, to test the cake town
-- /anniversary hide            end the preview (players in the town are sent back to the Union Room)
-- /anniversary on | off        force the whole holiday on or off (bonuses, gifts, the invasion and the town)
-- /anniversary auto            the holiday back to its dates (EventCalendar)
-- /anniversary start           start the cake invasion now (the holiday must be on)
-- /anniversary boss            skip the minions and bring out the Mad Big Cake (the holiday must be on)
-- /anniversary reset           clear the invasion and put the town back as it was
local USAGE = "Usage: /anniversary | show [minutes] | hide | on | off | auto | start | boss | reset."
local STATES = { [0] = "not started", [1] = "killing minions", [2] = "killing the boss" }

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function status(cid)
	local forced = EventCalendar.getForced("anniversary")
	local preview = AnniversaryEvent.getPreview()
	reply(cid, string.format("Anniversary: %s%s. Union Room entrance: %s%s. Invasion: %s (%d/%d minions).",
		EventCalendar.isActive("anniversary") and "running" or "off",
		forced == true and " (forced on)" or (forced == false and " (forced off)" or " (by its dates)"),
		AnniversaryEvent.isEntranceOpen() and "shown" or "hidden",
		preview and (preview == 0 and " (preview until hidden)" or " (preview until " .. os.date("%H:%M", preview) .. ")") or "",
		STATES[AnniversaryEvent.getEventState()] or "?", AnniversaryEvent.getMinionKillCount(),
		AnniversaryEvent.MINION_KILL_REQ_COUNT))
end

local function apply(cid)
	local mode, sent = AnniversaryEvent.sync(true)
	if (sent and sent > 0) then
		reply(cid, string.format("Sent %d player(s) out of the cake town.", sent))
	end
end

local function needsHoliday(cid)
	if (EventCalendar.isActive("anniversary")) then
		return false
	end
	reply(cid, "The Anniversary isn't running. Use /anniversary on first.")
	return true
end

function onSay(cid, words, param, channel)
	local command, rest = param:lower():match("^%s*(%S*)%s*(.-)%s*$")
	local name = getCreatureName(cid)

	if (command == "" or command == "status") then
		status(cid)
		if (command == "") then
			reply(cid, USAGE)
		end
		return true
	elseif (command == "show") then
		local minutes = rest == "" and AnniversaryEvent.PREVIEW_MINUTES or tonumber(rest)
		if (not minutes or minutes < 0 or minutes > AnniversaryEvent.PREVIEW_MAX_MINUTES) then
			reply(cid, string.format("Usage: /anniversary show [minutes], up to %d (0: until /anniversary hide).",
				AnniversaryEvent.PREVIEW_MAX_MINUTES))
			return true
		end
		AnniversaryEvent.setPreview(math.floor(minutes))
		apply(cid)
		print(string.format("> Anniversary: %s showed the entrance for %s", name, minutes == 0 and "until hidden" or minutes .. " min"))
	elseif (command == "hide") then
		AnniversaryEvent.setPreview(nil)
		apply(cid)
		if (EventCalendar.isActive("anniversary")) then
			reply(cid, "The Anniversary is running, so the entrance stays. Use /anniversary off to close it.")
		end
		print(string.format("> Anniversary: %s hid the entrance", name))
	elseif (command == "on" or command == "off" or command == "auto") then
		local values = { on = true, off = false }
		EventCalendar.setForced("anniversary", values[command])
		apply(cid)
		print(string.format("> Anniversary: %s set it to %s", name, command))
	elseif (command == "start") then
		if (needsHoliday(cid)) then
			return true
		end
		AnniversaryEvent.doStartEvent()
		print(string.format("> Anniversary: %s started the cake invasion", name))
	elseif (command == "boss") then
		if (needsHoliday(cid)) then
			return true
		end
		if (isMonster(getCreatureByName("Mad Big Cake"))) then
			reply(cid, "The Mad Big Cake is already out.")
			return true
		end
		AnniversaryEvent.doStartEvent()
		AnniversaryEvent.setMinionKillCount(AnniversaryEvent.MINION_KILL_REQ_COUNT)
		AnniversaryEvent.setEventState(AnniversaryEvent.EVENT_STATES.KILLING_BOSS)
		AnniversaryEvent.doSummonBoss()
		print(string.format("> Anniversary: %s brought out the boss", name))
	elseif (command == "reset") then
		AnniversaryEvent.close(true)
		print(string.format("> Anniversary: %s reset the cake town", name))
	else
		reply(cid, USAGE)
		return true
	end
	status(cid)
	return true
end
