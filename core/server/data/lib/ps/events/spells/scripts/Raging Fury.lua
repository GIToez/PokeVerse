local SKILL_NAME = "Raging Fury"

function onTargetCreature_RagingFury(cid, target)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_BIG_FLAMES)
    doSkillMultipleDamages(cid, SKILL_NAME, getRandom(2, 3))
    addEvent(doCreatureAddStatus, 3 * 500, cid, CREATURE_STATUS_CONFUSION, nil, cid)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_RagingFury")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
