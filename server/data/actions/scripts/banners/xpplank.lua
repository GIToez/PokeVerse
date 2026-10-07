function onUse(cid, item, frompos, itemEx, topos)

	if (getPlayerStorageValue(cid, player_use_banner) >= 1) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você já está usando um XP Banner!.")
		return true
	end
	
	if (config_banner[item.itemid]) then
		local banner = config_banner[item.itemid]
		if (remove_banner_item == true or remove_banner_item == TRUE) then
			doPlayerRemoveItem(cid, item.itemid, 1)
		end
		CreateBanner(cid, banner, itemEx)
		TimeBannerCheck(cid, banner, getThingPos(itemEx.uid))
		-- EffectBanner(getThingPos(itemEx.uid))
	end

end

function CreateBanner(cid, banner, itemEx)
    local bannerze = doCreateItem(banner.banner_id, getThingPos(itemEx.uid))
    doItemSetAttribute(bannerze, "name", ""..banner.banner_name..". Pertence a: "..getCreatureName(cid))
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você usou um "..banner.banner_name..", que te dará "..banner.banner_percent.."% de exp a mais, tem duração de "..banner.time_left.." minuto(s).")
	setPlayerStorageValue(cid, storage_banner_x, getThingPos(itemEx.uid).x)
	setPlayerStorageValue(cid, storage_banner_y, getThingPos(itemEx.uid).y)
	setPlayerStorageValue(cid, storage_banner_z, getThingPos(itemEx.uid).z)
	setPlayerStorageValue(cid, storage_banner_id, banner.banner_id)
	-- doExtraBannerRateStart(cid, banner.time_left, banner.exp_bonus)
	if (doExtraExpRateStart(cid, banner.time_xp, banner.exp_bonus)) then
		doSendMagicEffect(getThingPos(itemEx.uid), effect_invoke_banner)
    else
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
    end
	setPlayerStorageValue(cid, player_use_banner, 1)
	setPlayerStorageValue(cid, time_banner, os.time() + (banner.time_left * time_in_minutes))
end

function TimeBannerCheck(cid, banner, banner_pos)
	if not isCreature(cid) then
		if (isItem(getTileItemById(banner_pos, 34525))) then
			doRemoveItem(getTileItemById(banner_pos, 34525).uid)
			
		elseif (isItem(getTileItemById(banner_pos, 34526))) then
			doRemoveItem(getTileItemById(banner_pos, 34526).uid)
			
		elseif (isItem(getTileItemById(banner_pos, 34527))) then
			doRemoveItem(getTileItemById(banner_pos, 34527).uid)
			
		elseif (isItem(getTileItemById(banner_pos, 34528))) then
			doRemoveItem(getTileItemById(banner_pos, 34528).uid)
			
		elseif isItem(getTileItemById(banner_pos, 34529)) then
			doRemoveItem(getTileItemById(banner_pos, 34529).uid)
		end
		doSendMagicEffect(banner_pos, effect_decay_banner)
		return true
	end

	if (getPlayerStorageValue(cid, time_banner) == os.time()) then			
		if (isItem(getTileItemById(banner_pos, 34525))) then
			doRemoveItem(getTileItemById(banner_pos, 34525).uid)
			doSendMagicEffect(banner_pos, effect_decay_banner)
			
		elseif (isItem(getTileItemById(banner_pos, 34526))) then
			doRemoveItem(getTileItemById(banner_pos, 34526).uid)
			doSendMagicEffect(banner_pos, effect_decay_banner)
			
		elseif (isItem(getTileItemById(banner_pos, 34527))) then
			doRemoveItem(getTileItemById(banner_pos, 34527).uid)
			doSendMagicEffect(banner_pos, effect_decay_banner)
			
		elseif (isItem(getTileItemById(banner_pos, 34528))) then
			doRemoveItem(getTileItemById(banner_pos, 34528).uid)
			doSendMagicEffect(banner_pos, effect_decay_banner)
			
		elseif isItem(getTileItemById(banner_pos, 34529)) then
			doRemoveItem(getTileItemById(banner_pos, 34529).uid)
			doSendMagicEffect(banner_pos, effect_decay_banner)
		end
		setPlayerStorageValue(cid, player_use_banner, -1)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Seu "..banner.banner_name.." quebrou.")
		return true
	end

	addEvent(function()
		TimeBannerCheck(cid, banner, banner_pos)
	end, 1000)
end