function onStatsChange(cid, attacker, type, combat, value)
    if (type == STATSCHANGE_HEALTHLOSS and value > 0) then
        return WildLegendaries.onHit(cid, value, attacker) ~= false
    end
    return true
end
