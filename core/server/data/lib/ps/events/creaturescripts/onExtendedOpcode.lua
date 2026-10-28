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
    elseif (opcode == EXTENDED_IDS.HELD_ITEM) then
        PokemonHeldItem.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.ADMIN) then
        Admin.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.QUEST) then
        Quests.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.MOVE_INFO) then
        MoveInfo.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.CALENDAR) then
        EventCalendar.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.WEATHER) then
        Weather.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.POKEMON_SHOP) then
        PokemonShop.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.HINTS) then
        Hints.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.REPORT) then
        Reports.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.STORE) then
        Store.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.EXP_BOOST) then
        ExpBoost.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.BANK) then
        Bank.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.EVENT_SHOP) then
        EventShop.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.ANALYSER) then
        Analyser.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.MEGA_EVOLVE) then
        MegaEvolution.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.BAG) then
        Bag.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.SOCIAL) then
        Social.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.POKEMON_OUTFIT) then
        PokemonAddon.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.WARP_STYLES) then
        WarpStyles.onClientMessage(cid, buffer)
    elseif (opcode == EXTENDED_IDS.AUTO_LOOT) then
        local enabled = buffer == "1"
        setPlayerAutoLoot(cid, enabled)
        setPlayerAutoLootSave(cid, enabled)
    elseif (opcode == EXTENDED_IDS.PING) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.PING, string.sub(buffer, 1, 16))
    end
    return true
end
