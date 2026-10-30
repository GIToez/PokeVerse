local SKILL_NAME = "Roar of Time"

function onTargetCreature_RoarofTime(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

function onTargetTile_RoarofTime(cid, position)
    addEvent(doSendMagicEffect, getRandom(1, 600), position, EFFECT_BIG_BLUE_SPHERE)
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_RoarofTime")
setCombatCallback(combat, CALLBACK_PARAM_TARGETTILE, "onTargetTile_RoarofTime")
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))

function onCastSpell(cid, var)
	doCombat(cid, combat, var)
	doCreatureAddStatus(cid, CREATURE_STATUS_RECHARGE, nil, cid)
	return true
end
