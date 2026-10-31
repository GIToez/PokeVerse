local SKILL_NAME = "Ice Hammer"

function onTargetCreature_IceHammer(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_IceHammer")
function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
