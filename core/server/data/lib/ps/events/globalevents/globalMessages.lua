local GLOBALMESSAGES = {
	{"Never share your account details with anyone. The PokeVerse staff will never ask for your password and never gives away items or Pokemon."},
	{"Think twice before using any kind of bot or hack on your character. It will not be tolerated and your character will be deleted. Play fair."},
	{"Do you need information about the game? Ask in the Help channel or search the Wiki Chat (Ctrl + O)."},
	{"Enjoying the game? Invite your friends to play! It is more fun together and it helps keep the project alive."},
	{"Have a message, comment or suggestion for the PokeVerse developers? Let the staff know in the Help channel."},
}

local MSGTYPES = {
	MESSAGE_STATUS_WARNING, --[[Red message in game window and in the console]]
	MESSAGE_EVENT_ADVANCE, --[[White message in game window and in the console]]
	MESSAGE_INFO_DESCR --[[Green message in game window and in the console]]
}

local LAST_MESSAGE_ID = 0
local LAST_TYPE_ID = 0

function onThink()
	local msgs = GLOBALMESSAGES[LAST_MESSAGE_ID + 1]
	if (msgs) then
		LAST_MESSAGE_ID = LAST_MESSAGE_ID + 1
	else
		msgs = GLOBALMESSAGES[1]
		LAST_MESSAGE_ID = 1
	end

	local msgtype = MSGTYPES[LAST_TYPE_ID + 1]
	if (msgtype) then
		LAST_TYPE_ID = LAST_TYPE_ID + 1
	else
		msgtype = MSGTYPES[1]
		LAST_TYPE_ID = 1
	end

	for i, msg in ipairs(msgs) do
		doBroadcastMessage(msg, msgtype)
	end
	return true
end
