function onKill(cid, target, lastHit)
    local name = getCreatureName(target)
    if (not isSummon(target) and not getPokemonSummon(target)) then
        doQuestDefeat(cid, name)
        if (lastHit) then
            Sounds.onFaint(getCreaturePosition(target))
            Analyser.onKill(cid, target)
            MegaEvolution.onKill(cid, target)
            RangerClub.onPlayerKill(cid, name)
            EventCalendar.onPlayerKill(cid, target)
            if (EventCalendar.isActive("halloween")) then
                HalloweenEvent.onPlayerKill(cid, target, lastHit)
            end
            if (EventCalendar.isActive("anniversary")) then
                AnniversaryEvent.onPlayerKill(cid, target, lastHit)
            end
            if (EventCalendar.isActive("easter")) then
                EasterEvent.ThisIsEaster.onPlayerKill(cid, target, lastHit)
            end
            if (EventCalendar.isActive("christmas")) then
                ChristmasEvent.onPlayerKill(cid, target, lastHit)
            end
        end
    end
	return true
end
