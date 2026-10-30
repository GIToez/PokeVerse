local SKILL_NAME = "Shadow Force"

local function doStrike(cid, target)
    if (not isCreature(cid)) then return end
    if (getCreatureStatus(cid, CREATURE_STATUS_PROTECTION)) then
        doCreatureRemoveStatus(cid, CREATURE_STATUS_PROTECTION)
    end
    if (not isCreature(target)) then return end
    if (getCreatureStatus(target, CREATURE_STATUS_PROTECTION)) then
        doCreatureRemoveStatus(target, CREATURE_STATUS_PROTECTION)
    end
    local pos = getPositionAdjacent(cid, getCreaturePosition(target), false)
    if (pos) then
        doTeleportThing(cid, pos, false)
        doSendMagicEffect(pos, EFFECT_SHADOW_VORTEX)
    end
    doSkillDamage(cid, target, SKILL_NAME)
end

function onTargetCreature_ShadowForce(cid, target)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_SHADOW_VORTEX)
    doCreatureAddStatus(cid, CREATURE_STATUS_PROTECTION, nil, cid)
    addEvent(doStrike, 1000, cid, target)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_ShadowForce")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
