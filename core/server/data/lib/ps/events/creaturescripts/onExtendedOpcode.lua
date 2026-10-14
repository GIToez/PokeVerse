-- Client extended opcodes (OTClient). PC uses EXTENDED_IDS.PC JSON requests, not chat commands.
function onExtendedOpcode(cid, opcode, buffer)
    if (opcode == EXTENDED_IDS.PC) then
        PC.onClientMessage(cid, buffer)
    end
    return true
end
