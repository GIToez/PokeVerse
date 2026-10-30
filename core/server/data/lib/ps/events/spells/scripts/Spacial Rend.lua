local SKILL_NAME = "Spacial Rend"

function onTargetCreature_SpacialRend(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

function onTargetTile_SpacialRend(cid, position)
    addEvent(doSendMagicEffect, getRandom(1, 400), position, EFFECT_PURPLE_CRYSTAL_BROKE)
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_SpacialRend")
setCombatCallback(combat, CALLBACK_PARAM_TARGETTILE, "onTargetTile_SpacialRend")
setCombatArea(combat, createCombatArea(AREA_WAVE7))

function onCastSpell(cid, var)
	doCombat(cid, combat, var)
	return true
end
