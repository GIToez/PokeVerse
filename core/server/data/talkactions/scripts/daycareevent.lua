-- /bonusdaycare  multiplies the training EXP Pokemon earn at the Day Care while it runs
-- /bonusbreeding makes the wait for a Day Care egg run that many times faster while it runs
-- Same arguments as /doubleexp:
--   /bonusdaycare <duration>               2x, e.g. /bonusdaycare 2h
--   /bonusdaycare <multiplier>x <duration> e.g. /bonusbreeding 3x 1d or 1.5x 30m
--   /bonusdaycare off | status
-- Durations: m (minutes), h (hours), d (days); 1 minute to 7 days. Starting a new event replaces the running one.
local KINDS = { ["/bonusdaycare"] = "daycare", ["/bonusbreeding"] = "breeding" }

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

function onSay(cid, words, param, channel)
	local kind = KINDS[words:lower()]
	if (not kind) then
		return false
	end
	local usage = string.format("Usage: %s <duration> | <multiplier>x <duration> | off | status   (e.g. 2h, 3x 2h, 30m, 1d)", words)
	local command = param:match("^%s*(.-)%s*$"):lower()

	if (command == "") then
		reply(cid, usage)
		reply(cid, Daycare.describeEvent(kind))
	elseif (command == "status") then
		reply(cid, Daycare.describeEvent(kind))
	elseif (command == "off" or command == "stop" or command == "cancel") then
		if (Daycare.stopEvent(kind)) then
			print(string.format("> %s event: cancelled by %s", Daycare.EVENTS[kind].label, getCreatureName(cid)))
		else
			reply(cid, Daycare.describeEvent(kind))
		end
	else
		local multiplier, seconds = ServerExpEvent.parse(command)
		if (not multiplier) then
			reply(cid, seconds or usage)
			return true
		end
		Daycare.startEvent(kind, multiplier, seconds)
		print(string.format("> %s event: %s started %s for %s", Daycare.EVENTS[kind].label, getCreatureName(cid),
			ServerExpEvent.formatMultiplier(multiplier), ServerExpEvent.formatDuration(seconds)))
	end
	return true
end
