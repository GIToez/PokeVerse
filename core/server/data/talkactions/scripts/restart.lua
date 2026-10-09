-- /restart                     show the scheduled restart and the daily restart time
-- /restart <minutes>           restart in that many minutes (players are warned)
-- /restart cancel              cancel the scheduled restart (a cancelled daily restart comes back tomorrow)
-- /restart announce [text]     broadcast the time left now, optionally followed by a message
-- /restart daily <HH:MM>       change the daily restart time (server time, kept across restarts)
-- /restart daily off|default   turn the daily restart off / go back to config.lua
local USAGE = "Usage: /restart [<minutes> | cancel | announce [text] | daily <HH:MM>|off|default]"
local MAX_MINUTES = 24 * 60

local function reply(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function showStatus(cid)
	for _, line in ipairs(ServerRestart.describe()) do
		reply(cid, line)
	end
end

function onSay(cid, words, param, channel)
	local command, rest = param:match("^%s*(%S*)%s*(.-)%s*$")
	command = command:lower()

	if (command == "" or command == "status") then
		showStatus(cid)
	elseif (command == "cancel" or command == "stop") then
		if (not ServerRestart.cancel()) then
			reply(cid, "No restart is scheduled.")
		end
	elseif (command == "announce") then
		local at, reason = ServerRestart.getScheduled()
		if (not at) then
			reply(cid, "No restart is scheduled.")
		else
			ServerRestart.announce(at - os.time(), reason)
			if (rest ~= "") then
				doBroadcastMessage(rest, MESSAGE_STATUS_WARNING)
			end
		end
	elseif (command == "daily") then
		local value = rest:lower()
		if (value == "off") then
			ServerRestart.disableDaily()
		elseif (value == "default") then
			ServerRestart.setDaily(nil)
		else
			local minutes = ServerRestart.parseTime(value)
			if (not minutes) then
				reply(cid, "Use a 24-hour time such as 06:00, or off / default.")
				return true
			end
			ServerRestart.setDaily(minutes)
		end
		local at, reason = ServerRestart.getScheduled()
		if (at and reason == ServerRestart.REASON_DAILY) then
			ServerRestart.cancel()
		end
		showStatus(cid)
	elseif (tonumber(command)) then
		local minutes = math.floor(tonumber(command))
		if (minutes < 1 or minutes > MAX_MINUTES) then
			reply(cid, "Minutes must be between 1 and " .. MAX_MINUTES .. ".")
			return true
		end
		ServerRestart.scheduleIn(minutes * 60)
		print("> Restart: " .. getCreatureName(cid) .. " scheduled a restart in " .. minutes .. " minute(s)")
		reply(cid, "Restart scheduled in " .. ServerRestart.formatDuration(minutes * 60) .. ". Players are warned automatically.")
	else
		reply(cid, USAGE)
	end
	return true
end
