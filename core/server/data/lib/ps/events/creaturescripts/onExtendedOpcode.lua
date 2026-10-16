-- Client extended opcodes (OTClient). The PC, the Pokepedia and the vocation window send JSON requests, not chat commands.
function onExtendedOpcode(cid, opcode, buffer)
    if (opcode == EXTENDED_IDS.PC) then
        PC.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.POKEPEDIA) then
        Pokepedia.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.VOCATION) then
        Vocations.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.RADAR) then
        Vocations.onRadarMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.FISHING) then
        Fishing.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.TRAINER_CARD) then
        TrainerCard.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.DAYCARE) then
        Daycare.onClientMessage(cid, buffer)
    end
    return true
end
