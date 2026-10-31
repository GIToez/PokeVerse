local SKILL_NAME = "Dragon Hammer"

function onTargetCreature_DragonHammer(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_DragonHammer")
function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
