--<action itemid="2589-2592" event="script" value="locker_action.lua"/>

function onUse(cid, item, itemEx)
	if depotLocker.isLocked(cid) then
			local response = {argument = "NoRelease",}
			doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DepotLock, json.encode(response))
		if not depotLocker.config.useBoard then
			local response = {argument = "NoRelease",}
			doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DepotLock, json.encode(response))
		end
		return true
	end
	return false
end