local guardians = {
    [27291] = "Entei",
}

function onUse(cid, item)

	if type(getPlayerStorageValue(cid, 9006)) == "string" or getPlayerStorageValue(cid, 9005) > 0 then
	return doPlayerSendCancel(cid, "Voce nao pode usar o card, com 1 guardado no fly")
	end
    
    if getPlayerCurrentGuardian(cid) then
        return doPlayerSendCancel(cid, "Voce pode usar apenas 1 Guardian") --fodase o ingles
    end

    local guardian =  guardians[item.itemid]
    if guardian then
		
	if exhaustion.get(cid, 305) then
       return doPlayerSendTextMessage(cid, 27, "Aguarde, ainda falta " .. math.ceil(exhaustion.get(cid, 305) / 60) .. " minutos para voce usar o guardian novamente.")
    end
    doPlayerPopupFYI(cid, "Suba no fly, ride ou relogue sua conta pra salvar o tempo do guardian.")
    doPlayerSummonGuardian(cid, guardian)
		
    doPlayerSetStorageValue(cid, 9005, exhaustion.get(getPlayerCurrentGuardian(cid), 11))
    doPlayerSetStorageValue(cid, 9006, guardian)
	doPlayerSave(cid)
		exhaustion.set(cid, 305, 600 * 60)
    end
    return true
end 
