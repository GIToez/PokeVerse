-- Pokemon experience from kills: the Pokemon's level picks the rate.
-- Trainer experience stages are in data/XML/stages.xml.
POKEMON_EXP_STAGES = {
    { maxLevel = 10, rate = 15 },
    { maxLevel = 20, rate = 12 },
    { maxLevel = 30, rate = 8 },
    { maxLevel = 40, rate = 5 },
    { maxLevel = 50, rate = 3 },
    { maxLevel = 60, rate = 2 },
    { maxLevel = 70, rate = 1.5 },
    { rate = 1 }
}

-- Applied to every Pokemon kill on top of the stage (was 1.25)
POKEMON_EXP_RATE = 1.0

function getPokemonExpStageRate(level)
    for _, stage in ipairs(POKEMON_EXP_STAGES) do
        if (not stage.maxLevel or level <= stage.maxLevel) then
            return stage.rate
        end
    end
    return 1
end
