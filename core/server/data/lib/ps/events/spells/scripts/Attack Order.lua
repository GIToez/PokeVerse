local SKILL_NAME = "Attack Order"

function onTargetCreature_AttackOrder(cid, target)
    local pos = getCreaturePosition(target)
    for i = 1, 4 do
        addEvent(doSendDistanceShoot, 120 * i, getPositionRandomAdjacent(pos, 3), pos, PROJECTILE_NEEDLE)
    end
    doSkillDamage(cid, target, SKILL_NAME)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_AttackOrder")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
