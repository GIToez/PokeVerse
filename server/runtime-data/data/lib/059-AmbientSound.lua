function sendSound(cid, sound, loop)
	if not loop then
		doSendPlayerExtendedOpcode(cid, 85,  sound.."|".."false")
	elseif loop == true then
		doSendPlayerExtendedOpcode(cid, 85,  sound.."|".."true")
	elseif loop == false then
		doSendPlayerExtendedOpcode(cid, 85,  sound.."|".."false")
	end
end

function pauseSound(cid)
	doSendPlayerExtendedOpcode(cid, 81, "")
end

function sendSoundForall(sound)
	for _, k in ipairs(getPlayersOnline()) do
		doSendPlayerExtendedOpcode(k, 85,  sound)
	end
end

function sendScreanSound(cid, sound)
	for _, v in ipairs(getSpectators(getThingPosition(cid), 7, 5, true)) do
		if(isPlayer(v))then
			doSendPlayerExtendedOpcode(v, 85,  sound)
		end
	end
end

function sendScreanPosSound(sound, pos)
	if getSpectators(pos, 7, 5, true) ~= nil then
		for _, v in ipairs(getSpectators(pos, 7, 5, true)) do
			if(isPlayer(v))then
				doSendPlayerExtendedOpcode(v, 85,  sound)
			end
		end
	end
end
