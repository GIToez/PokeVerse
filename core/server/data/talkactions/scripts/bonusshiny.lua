-- /bonusshiny <duration>               start a 2x shiny chance event, e.g. /bonusshiny 2h
-- /bonusshiny <multiplier>x <duration> start with another multiplier, e.g. /bonusshiny 3x 2h or 1.5x 30m
-- /bonusshiny off                      cancel the running event
-- /bonusshiny status                   show the running event
-- Durations: m (minutes), h (hours), d (days); 1 minute to 7 days. Starting a new event replaces the running one.
local USAGE = "Usage: /bonusshiny <duration> | <multiplier>x <duration> | off | status   (e.g. 2h, 3x 2h, 30m, 1d)"

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

function onSay(cid, words, param, channel)
	local command = param:match("^%s*(.-)%s*$"):lower()

	if (command == "") then
		reply(cid, USAGE)
		reply(cid, ShinyEvent.describe())
	elseif (command == "status") then
		reply(cid, ShinyEvent.describe())
	elseif (command == "off" or command == "stop" or command == "cancel") then
		if (ShinyEvent.stop()) then
			print("> Shiny event: cancelled by " .. getCreatureName(cid))
		else
			reply(cid, "No shiny event is running.")
		end
	else
		local multiplier, seconds = ServerExpEvent.parse(command)
		if (not multiplier) then
			reply(cid, seconds or USAGE)
			return true
		end
		ShinyEvent.start(multiplier, seconds)
		print(string.format("> Shiny event: %s started %s for %s", getCreatureName(cid),
			ServerExpEvent.formatMultiplier(multiplier), ServerExpEvent.formatDuration(seconds)))
	end
	return true
end
