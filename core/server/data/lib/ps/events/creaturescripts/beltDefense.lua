-- Defense mode (BeltSwitches): something hurting the trainer calls their Pokemon out
function onStatsChange(cid, attacker, type, combat, value)
    if (type == STATSCHANGE_HEALTHLOSS and isCreature(attacker) and attacker ~= cid and getCreatureMaster(attacker) ~= cid) then
        BeltSwitches.onThreat(cid)
    end
    return true
end
