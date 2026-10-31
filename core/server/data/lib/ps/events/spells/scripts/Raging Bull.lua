local SKILL_NAME = "Raging Bull"

function onTargetCreature_RagingBull(cid, target)
    if (getCreatureStatus(target, CREATURE_STATUS_PROTECTION)) then
        doCreatureRemoveStatus(target, CREATURE_STATUS_PROTECTION)
        doSendMagicEffect(getCreaturePosition(target), EFFECT_BIG_SHIELD)
    end
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_RagingBull")
function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
