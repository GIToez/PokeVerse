local SKILL_NAME = "Seed Flare"

function onTargetCreature_SeedFlare(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
    if (not isCreature(target)) then return end -- Defeated
    if (not doPokemonSpecialAbilityCheck(target, POKEMON_SPECIAL_ABILITY_IDS.SHIELD_DUST, nil) and getRandom(0, 100) <=
            (doPokemonSpecialAbilityCheck(cid, POKEMON_SPECIAL_ABILITY_IDS.SERENA_GRACE, nil) and 80 or 40)) then
        doCreatureAddStatus(target, CREATURE_STATUS_EXTRASPDEF, CREATURE_STATUS_VAR_BADMEDIUM, cid)
    end
end

function onTargetTile_SeedFlare(cid, position)
    addEvent(doSendMagicEffect, getRandom(1, 500), position, EFFECT_BIG_GREEN_LEAVES)
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_SeedFlare")
setCombatCallback(combat, CALLBACK_PARAM_TARGETTILE, "onTargetTile_SeedFlare")
setCombatArea(combat, createCombatArea(AREA_WAVE7))

function onCastSpell(cid, var)
	doCombat(cid, combat, var)
	return true
end
