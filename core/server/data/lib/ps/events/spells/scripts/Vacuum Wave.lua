local SKILL_NAME = "Vacuum Wave"

function onTargetCreature_VacuumWave(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_VacuumWave")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
