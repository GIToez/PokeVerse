local SKILL_NAME = "Rock Wrecker"

function onTargetCreature_RockWrecker(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
    doCreatureAddStatus(cid, CREATURE_STATUS_RECHARGE, nil, cid)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_RockWrecker")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
