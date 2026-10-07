function onSay(cid, words, param)
    if hasPassPremium(cid) then
      local protocol = Protocol_create('HassMission')
      doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
	  sendPass(cid)
	elseif isPremium(cid) then
      local protocol = Protocol_create('HassMission')
      doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
	  sendPass(cid)
	elseif not hasPassPremium(cid) then
      local protocol = Protocol_create('NoMission')
      doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
	  sendPass(cid)
	elseif not isPremium(cid) then
      local protocol = Protocol_create('NoMission')
      doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
	  sendPass(cid)
	  return
	end
	return true
end