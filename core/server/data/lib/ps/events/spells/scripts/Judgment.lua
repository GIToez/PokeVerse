local SKILL_NAME = "Judgment"

function onTargetCreature_Judgment(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
end

function onTargetTile_Judgment(cid, position)
    if (math.random(0, 1) == 1) then
        doSendDistanceShoot(getSkyPosition(position), position, PROJECTILE_YELLOW_RAIN)
        addEvent(doSendMagicEffect, 150, position, EFFECT_BIG_YELLOW_SPARKS)
    end
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_Judgment")
setCombatCallback(combat, CALLBACK_PARAM_TARGETTILE, "onTargetTile_Judgment")
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))

function onCastSpell(cid, var)
	doCombat(cid, combat, var)
	return true
end
