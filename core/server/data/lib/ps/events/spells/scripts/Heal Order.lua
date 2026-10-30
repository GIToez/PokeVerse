local SKILL_NAME = "Heal Order"

function onTargetCreature_HealOrder(cid, target)
    doCreatureAddHealth(cid, math.ceil((getCreatureMaxHealth(cid) / 2)))
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_HealOrder")
setCombatParam(combat, COMBAT_PARAM_EFFECT, getPokemonSkillEffect(SKILL_NAME))
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
