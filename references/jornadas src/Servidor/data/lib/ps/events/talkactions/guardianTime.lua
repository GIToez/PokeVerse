function onSay(cid, words)
  if getPlayerCurrentGuardian(getCreatureMaster(cid)) then                         
    doPlayerSendTextMessage(getCreatureMaster(cid), 27, "Seu Guardian Possui (" .. math.ceil(exhaustion.get(getPlayerCurrentGuardian(getCreatureMaster(cid)), 11) / 60) .. ") Minutos Restantes.")
else
	doPlayerSendCancel(getCreatureMaster(cid), "Voce nao possui nenhum GUARDIAN ativo no momento.") 
end
	return true

end




