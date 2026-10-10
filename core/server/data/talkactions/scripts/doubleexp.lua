-- /doubleexp <duration>               start a 2x kill experience event, e.g. /doubleexp 2h
-- /doubleexp <multiplier>x <duration> start with another multiplier, e.g. /doubleexp 3x 2h or 1.5x 30m
-- /doubleexp off                      cancel the running event
-- /doubleexp status                   show the running event
-- Durations: m (minutes), h (hours), d (days); 1 minute to 7 days. Starting a new event replaces the running one.
local USAGE = "Usage: /doubleexp <duration> | <multiplier>x <duration> | off | status   (e.g. 2h, 3x 2h, 30m, 1d)"

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

function onSay(cid, words, param, channel)
	local command = param:match("^%s*(.-)%s*$"):lower()

	if (command == "") then
		reply(cid, USAGE)
		reply(cid, ServerExpEvent.describe())
	elseif (command == "status") then
		reply(cid, ServerExpEvent.describe())
	elseif (command == "off" or command == "stop" or command == "cancel") then
		if (ServerExpEvent.stop()) then
			print("> Experience event: cancelled by " .. getCreatureName(cid))
		else
			reply(cid, "No experience event is running.")
		end
	else
		local multiplier, seconds = ServerExpEvent.parse(command)
		if (not multiplier) then
			reply(cid, seconds or USAGE)
			return true
		end
		ServerExpEvent.start(multiplier, seconds)
		print(string.format("> Experience event: %s started %s for %s", getCreatureName(cid),
			ServerExpEvent.formatMultiplier(multiplier), ServerExpEvent.formatDuration(seconds)))
	end
	return true
end
