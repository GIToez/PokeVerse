local SKILL_NAME = "Crush Grip"

function onTargetCreature_CrushGrip(cid, target)
    doSkillDamage(cid, target, SKILL_NAME, math.max(1, math.floor(120 * getCreatureHealth(target) / getCreatureMaxHealth(target))))
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_CrushGrip")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
