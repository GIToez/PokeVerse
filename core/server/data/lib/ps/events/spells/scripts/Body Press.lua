local SKILL_NAME = "Body Press"

function onTargetCreature_BodyPress(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_BodyPress")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
