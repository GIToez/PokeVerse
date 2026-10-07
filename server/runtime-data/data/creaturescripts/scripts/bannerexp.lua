function onKill(cid, target)
	
	if not isMonster(target) then
		return true
	end

	if (getPlayerStorageValue(cid, storage_banner_id) <= -1) then
		return true
	end
	local banner_pos = {x=getPlayerStorageValue(cid, storage_banner_x), y=getPlayerStorageValue(cid, storage_banner_y), z=getPlayerStorageValue(cid, storage_banner_z)}

	if (getTileItemById(banner_pos, getPlayerStorageValue(cid, storage_banner_id)).uid >= 1) then
		if not (CheckPlayerInArea(cid, banner_pos)) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você saiu do alcance, seu Banner quebrou!")
			setPlayerStorageValue(cid, 78999788, -1)
            setPlayerExtraExpRate(cid, 0)
            setPlayerExtraExpRateTime(cid, 0)
            setPlayerExtraExpRateValue(cid, 0)
			
			if (isItem(getTileItemById(banner_pos, 34525))) then
				doRemoveItem(getTileItemById(banner_pos, 34525).uid)
		        doSendMagicEffect(banner_pos, effect_decay_banner)
			elseif (isItem(getTileItemById(banner_pos, 34526))) then
				doRemoveItem(getTileItemById(banner_pos, 34526).uid)
		        doSendMagicEffect(banner_pos, effect_decay_banner)
			elseif (isItem(getTileItemById(banner_pos, 34527))) then
				doRemoveItem(getTileItemById(banner_pos, 34527).uid)
			elseif (isItem(getTileItemById(banner_pos, 34528))) then
				doRemoveItem(getTileItemById(banner_pos, 34528).uid)
		        doSendMagicEffect(banner_pos, effect_decay_banner)
			elseif isItem(getTileItemById(banner_pos, 34529)) then
				doRemoveItem(getTileItemById(banner_pos, 34529).uid)
		        doSendMagicEffect(banner_pos, effect_decay_banner)
			end
		    setPlayerStorageValue(cid, player_use_banner, -1)
			
			-- isInArray(TerraTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid)
		end
	else
		-- doPlayerSetRate(cid, rate_level,1)
	end

	
	return true
end

function CheckPlayerInArea(cid, banner_pos)
	for x=banner_pos.x-banner_radius_x, banner_pos.x+banner_radius_x do
		for y=banner_pos.y-banner_radius_y, banner_pos.y+banner_radius_y do
			local banner_area = {x=x,y=y,z=banner_pos.z}
			local player = getTopCreature(banner_area).uid
			if (isPlayer(player)) then
				AddBonusExp(cid, banner_pos)
				return true
			end
		end
	end
end

function AddBonusExp(cid, banner_pos)
	doSendMagicEffect(banner_pos, effect_kill_banner)
end