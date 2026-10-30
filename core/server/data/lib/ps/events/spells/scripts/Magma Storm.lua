local SKILL_NAME = "Magma Storm"

function onTargetCreature_MagmaStorm(cid, target)
    doSkillDamage(cid, target, SKILL_NAME, 30)
    if (not isCreature(target)) then return end -- Defeated
    if (not doPokemonSpecialAbilityCheck(target, POKEMON_SPECIAL_ABILITY_IDS.SHIELD_DUST, nil) and getRandom(0, 100) <=
            (doPokemonSpecialAbilityCheck(cid, POKEMON_SPECIAL_ABILITY_IDS.SERENA_GRACE, nil) and 20 or 10)) then
        doCreatureAddStatus(target, CREATURE_STATUS_BURN, getMonsterLevel(cid), cid)
    end
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_MagmaStorm")
setCombatParam(combat, COMBAT_PARAM_EFFECT, getPokemonSkillAreaEffect(SKILL_NAME))
setCombatArea(combat, createCombatArea(AREA_CIRCLE2X2))

local function doSpell(cid, var)
	if (isCreature(cid)) then
		doCombat(cid, combat, var)
	end
end

function onCastSpell(cid, var)
	for i = 1, 4 do
		addEvent(doSpell, 1000 * (i - 1) + 1, cid, var)
	end
	return true
end
