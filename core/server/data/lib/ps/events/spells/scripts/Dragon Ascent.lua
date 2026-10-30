local SKILL_NAME = "Dragon Ascent"

function onTargetCreature_DragonAscent(cid, target)
    local cidPos, pos = getCreaturePosition(cid), getPositionAdjacent(cid, getCreaturePosition(target), false)
    if (pos) then
        doSendDistanceShoot(cidPos, pos, PROJECTILE_BLUE_DRAGON)
        doSendMagicEffect(cidPos, EFFECT_TELEPORT_FRAME)
        doTeleportThing(cid, pos, false)
        doSendMagicEffect(pos, EFFECT_TELEPORT_FRAME)
    end
    doSkillDamage(cid, target, SKILL_NAME)
    if (not isCreature(cid)) then return end
    doCreatureAddStatus(cid, CREATURE_STATUS_EXTRASPDEF, CREATURE_STATUS_VAR_BAD, cid)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_DragonAscent")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
