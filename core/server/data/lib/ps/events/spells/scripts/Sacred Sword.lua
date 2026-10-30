local SKILL_NAME = "Sacred Sword"

function onTargetCreature_SacredSword(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_SacredSword")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
