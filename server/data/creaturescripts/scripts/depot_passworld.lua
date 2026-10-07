--<event type="textedit" name="lockerTextEdit" event="script" value="locker_creature.lua"/>
--<event type="look" name="lockerBlockLook" event="script" value="locker_creature.lua"/>
--<event type="login" name="lockerLogin" event="script" value="locker_creature.lua"/>
--<event type="logout" name="lockerLogout" event="script" value="locker_creature.lua"/>
function onLook(cid, thing, position, lookDistance)
	if isInArray(depotLocker.config.boardIDs, thing.itemid) and thing.actionid == depotLocker.config.actionIDs.board then
		return false
	end
	return true
end

function onLogin(cid)
	registerCreatureEvent(cid, "lockerTextEdit")
	registerCreatureEvent(cid, "lockerBlockLook")
	return true
end

function onLogout(cid)
	if not depotLocker.isLocked(cid) then
		setPlayerStorageValue(cid, depotLocker.storages.lockState, 0)
	end
	return true
end

