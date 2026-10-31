local SKILL_NAME = "Hyper Drill"

function onTargetCreature_HyperDrill(cid, target)
    if (getCreatureStatus(target, CREATURE_STATUS_PROTECTION)) then
        doCreatureRemoveStatus(target, CREATURE_STATUS_PROTECTION)
        doSendMagicEffect(getCreaturePosition(target), EFFECT_BIG_SHIELD)
    end
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_HyperDrill")
function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
