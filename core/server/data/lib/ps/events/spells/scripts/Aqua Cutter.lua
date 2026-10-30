local SKILL_NAME = "Aqua Cutter"

function onTargetCreature_AquaCutter(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_AquaCutter")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
