-- Client extended opcodes (OTClient). The PC and the Pokepedia send JSON requests, not chat commands.
function onExtendedOpcode(cid, opcode, buffer)
    if (opcode == EXTENDED_IDS.PC) then
        PC.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.POKEPEDIA) then
        Pokepedia.onClientMessage(cid, buffer)
    end
    return true
end
