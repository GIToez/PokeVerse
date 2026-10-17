function onStatsChange(cid, attacker, type, combat, value)
    if (type == STATSCHANGE_HEALTHLOSS and value > 0) then
        WildLegendaries.onHit(cid, value)
    end
    return true
end
