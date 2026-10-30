if (ChristmasEvent) then
    return
end

ChristmasEvent = {}

local SPECIAL_POKEMON = {
    ["Pikachu"] = "Christmas Pikachu",
    ["Squirtle"] = "Christmas Squirtle",
    ["Charmander"] = "Christmas Charmander",
    ["Bulbasaur"] = "Christmas Bulbasaur",
    ["Abra"] = "Christmas Abra",
    ["Caterpie"] = "Christmas Caterpie",
    ["Diglett"] = "Christmas Diglett",
    ["Ekans"] = "Christmas Ekans",
    ["Gastly"] = "Christmas Gastly",
    ["Geodude"] = "Christmas Geodude",
    ["Grimer"] = "Christmas Grimer",
    ["Machop"] = "Christmas Machop",
    ["Meowth"] = "Christmas Meowth",
    ["Pidgey"] = "Christmas Pidgey",
    ["Rattata"] = "Christmas Rattata",
    ["Sandshrew"] = "Christmas Sandshrew",
    ["Spearow"] = "Christmas Spearow",
    ["Weedle"] = "Christmas Weedle",
    ["Aipom"] = "Christmas Aipom",
    ["Chikorita"] = "Christmas Chikorita",
    ["Clefairy"] = "Christmas Clefairy",
    ["Cubone"] = "Christmas Cubone",
    ["Ditto"] = "Christmas Ditto",
    ["Eevee"] = "Christmas Eevee",
    ["Elekid"] = "Christmas Elekid",
    ["Golbat"] = "Christmas Golbat",
    ["Hitmontop"] = "Christmas Hitmontop",
    ["Jigglypuff"] = "Christmas Jigglypuff",
    ["Jynx"] = "Christmas Jynx",
    ["Ledyba"] = "Christmas Ledyba",
    ["Mantine"] = "Christmas Mantine",
    ["Psyduck"] = "Christmas Psyduck",
    ["Seel"] = "Christmas Seel",
    ["Teddiursa"] = "Christmas Teddiursa",
    ["Togepi"] = "Christmas Togepi",
    ["Totodile"] = "Christmas Totodile",
    ["Wooper"] = "Christmas Wooper",
    ["Blissey"] = "Santa Blissey",
    ["Snorlax"] = { "Christmas Snorlax", "Santa Snorlax" },
}
local SPECIAL_POKEMON_CHANCE = 10

ChristmasEvent.DAMAGE_MINIMUM_RATIO = 0.5
ChristmasEvent.DROP_CHANCE = 20000 -- 20%
ChristmasEvent.PRESENT_ITEMIDS = {14639, 14640}

ChristmasEvent.onSpawn = function(cid)
    local special = SPECIAL_POKEMON[getCreatureName(cid)]
    if (special and getRandom(1, SPECIAL_POKEMON_CHANCE) <= 1) then
        if (type(special) == "table") then
            special = special[getRandom(1, #special)]
        end
        local r = doCreateMonster(special, getCreaturePosition(cid), false)
        if (not isBoolean(r)) then
            addEvent(doRemoveCreature, 1000, cid)
            setMonsterSpecialAbility(r, getPokemonRandomSpecialAbility(getCreatureName(r)))
            doSendMagicEffect(getCreaturePosition(r), EFFECT_TELEPORT_DOWN)
            return true
        end
    end

    return false
end

ChristmasEvent.onPlayerKill = function(cid, target, lastHit)
    if (not isPokemonName(getCreatureName(target)) or
            getCreatureDamageRatioByMaster(target, cid) < ChristmasEvent.DAMAGE_MINIMUM_RATIO) then
        return
    end

    if (getRandom(RANDOM_CHANCE_MIN, RANDOM_CHANCE_MAX) <= ChristmasEvent.DROP_CHANCE * (getMonsterLevel(target) / 100)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have found a christmas present.")
        doPlayerSafeAddItem(cid, table.random(ChristmasEvent.PRESENT_ITEMIDS), 1, true, true)
    end
end