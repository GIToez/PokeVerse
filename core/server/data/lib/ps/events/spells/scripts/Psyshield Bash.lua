local SKILL_NAME = "Psyshield Bash"

function onTargetCreature_PsyshieldBash(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
    if (isCreature(cid)) then
        doCreatureAddStatus(cid, CREATURE_STATUS_EXTRASPDEF, CREATURE_STATUS_VAR_LOW, cid)
    end
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_PsyshieldBash")
function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
