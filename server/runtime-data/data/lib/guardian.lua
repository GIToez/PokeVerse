
local GUARDIAN_CONFIGS = {
    exhaustion_minutes = 600,
    guardian_life_minutes = 60,
    guardians = {
	
        ["Charizard"] = {offense = 1500, specialattack = 5000, storage = 305, minutos = 60},
        ["Mewtwo"] = {offense = 1500, specialattack = 5000, storage = 305, minutos = 60},
        ["Mew"] = {offense = 1500, specialattack = 5000, storage = 305, minutos = 60},
        ["Articuno"] = {offense = 1500, specialattack = 5000, storage = 305, minutos = 60},
        ["Zapdos"] = {offense = 1500, specialattack = 5000, storage = 305, minutos = 60},
        ["Entei"] = {offense = 1500, specialattack = 5000, storage = 305, minutos = 60},
    
	}
}

function getPlayerCurrentGuardian(cid)
    if isPlayer(cid) and #getCreatureSummons(cid) > 0 then
        for i = 1, #getCreatureSummons(cid) do
            if isCreature(getCreatureSummons(cid)[i]) and getCreatureStorage(getCreatureSummons(cid)[i], 10) == "guardian" then
                return getCreatureSummons(cid)[i]
            end
        end
    end
    return false
end

function doPlayerSummonGuardian(cid, guardian_name)

 --[[ if isInHouse(cid) then
  doPlayerSendCancel(cid, "Seu Guardian não Foi Sumonado, por você estar dentro de uma house.")
  return true
  end]]--
  
    -- if getPlayerStorageValue(cid, 17000) > 0 or getPlayerStorageValue(cid, 17001) > 0 then
  -- doPlayerSendCancel(cid, "Seu Guardian não Foi Sumonado, por você em fly.")
  -- return true
  -- end

if isCreature(getPlayerCurrentGuardian(cid)) then
return false
end

    local guardian =  GUARDIAN_CONFIGS.guardians[guardian_name]
    if guardian then
        doSummonMonster(cid, guardian_name)
		
	local pokezinho = getCreatureSummons(cid)[#getCreatureSummons(cid)]
        doCreatureSetStorage(pokezinho, 10, "guardian")
        setPlayerStorageValue(pokezinho, 1001,  guardian.offense)
        setPlayerStorageValue(pokezinho, 1005,  guardian.specialattack)
		
		
        exhaustion.set(getCreatureSummons(cid)[#getCreatureSummons(cid)], 11, guardian.minutos * 60) ---- SETA O TEMPO DO GUARDIAN
	
        if getPlayerStorageValue(cid, 9005) > 0 then
            exhaustion.set(getPlayerCurrentGuardian(cid), 11, getPlayerStorageValue(cid, 9005))
        end
		addEvent(doRemoveGuardian, exhaustion.get(getPlayerCurrentGuardian(cid), 11) * 1000, getPlayerCurrentGuardian(cid))  ---- SETA O TEMPO PRA REMOVER GUARDIAN
    end
end

function doRemoveGuardian(cid)
    if isCreature(cid) and isPlayer(getCreatureMaster(cid)) then
        doPlayerSetStorageValue(getCreatureMaster(cid), 9005, 0)
        doPlayerSetStorageValue(getCreatureMaster(cid), 9006, 0)
        doPlayerSendTextMessage(getCreatureMaster(cid), 27, "Seu guardiao foi removido.")
		doRemoveCreature(cid, true)
    end
    return true
end
