function onMonsterSpawn(cid)
    if (EventCalendar.isActive("easter") and EasterEvent.OnSpawn(cid)) then
        return
    end
    AnniversaryEvent.onSpawn(cid)
    if (EventCalendar.isActive("christmas") and ChristmasEvent.onSpawn(cid)) then
        return
    end
    if (EventCalendar.isActive("halloween") and HalloweenEvent.onSpawn(cid)) then
        return
    end

    setMonsterSpecialAbility(cid, getPokemonRandomSpecialAbility(getCreatureName(cid)))
    setWildPokemonEvolvable(cid, getRandom(0, 3) == 1)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_TELEPORT_DOWN)
    DiscordBridge.onSpawn(cid, "spawn")
end