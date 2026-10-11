--------- EXTRA XP RATE ---------
local function doExtraExpRateReset(pid)
	if (isPlayer(pid)) then
		setPlayerExtraExpRate(pid, 0)
		setPlayerExtraExpRateTime(pid, 0)
		setPlayerExtraExpRateValue(pid, 0)
		-- doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, "Your bonus experience has ended.")
		doSendMagicEffect(getCreaturePosition(pid), EFFECT_RED_BUFF)
	end
end

function doExtraExpRateCheck(pid) -- Called onLogin
	local remaingTime = getPlayerExtraExpRateTime(pid) - os.time()
	if (remaingTime > 0) then
		-- doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "Remaining %s minutes of bonus experience."), math.floor(remaingTime / 60)))
		setPlayerExtraExpRate(pid, getPlayerExtraExpRateValue(pid))
		addEvent(doExtraExpRateReset, remaingTime * 1000, pid)
	elseif (getPlayerExtraExpRateValue(pid) > 0) then
		doExtraExpRateReset(pid)
	end
end

function doExtraExpRateStart(pid, seconds, value)
	if (getPlayerExtraExpRate(pid) > 0) then
		return false
	end

	setPlayerExtraExpRate(pid, value)
	setPlayerExtraExpRateTime(pid, os.time() + seconds)
	setPlayerExtraExpRateValue(pid, value)
	-- doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(pid, "Your %s%% bonus experience has started. Duration: %s minutes."), math.round(value * 100), math.floor(seconds / 60)))
	doSendMagicEffect(getCreaturePosition(pid), EFFECT_RED_BUFF)
	addEvent(doExtraExpRateReset, seconds * 1000, pid)
	return true
end
--------- EXTRA XP RATE ---------
--------- EXTRA BANNER RATE ---------
local function doExtraBannerRateReset(pid)
	if (isPlayer(pid)) then
		setPlayerExtraBannerRate(pid, 0)
		setPlayerExtraBannerRateTime(pid, 0)
		setPlayerExtraBannerRateValue(pid, 0)
		doSendMagicEffect(getCreaturePosition(pid), EFFECT_RED_BUFF)
	end
end

function doExtraBannerRateCheck(pid) -- Called onLogin
	local remaingTime = getPlayerExtraBannerRateTime(pid) - os.time()
	if (remaingTime > 0) then
		doExtraBannerRateReset(pid)
	elseif (getPlayerExtraBannerRateValue(pid) > 0) then
		doExtraBannerRateReset(pid)
	end
end

function doExtraBannerRateStart(pid, seconds, value)
	if (getPlayerExtraBannerRate(pid) > 0) then
		return false
	end

	setPlayerExtraBannerRate(pid, value)
	setPlayerExtraBannerRateTime(pid, os.time() + seconds)
	setPlayerExtraBannerRateValue(pid, value)
	doSendMagicEffect(getCreaturePosition(pid), EFFECT_RED_BUFF)
	addEvent(doExtraBannerRateReset, seconds * 1000, pid)
	return true
end
--------- EXTRA BANNER RATE ---------