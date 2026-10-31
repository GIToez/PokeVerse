local SKILL_NAME = "Whirlwind"
local SKILL_PROJECTILE = getPokemonSkillProjectile(SKILL_NAME)
local PUSH = 2

function onTargetCreature_Whirlwind(cid, target)
    if (not isMonster(target) or isFriend(cid, target)) then
        return
    end
    local from, pos = getCreaturePosition(cid), getCreaturePosition(target)
    local dx = pos.x == from.x and 0 or (pos.x > from.x and 1 or -1)
    local dy = pos.y == from.y and 0 or (pos.y > from.y and 1 or -1)
    local to = nil
    for i = 1, PUSH do
        local step = {x = pos.x + dx * i, y = pos.y + dy * i, z = pos.z}
        if (not isWalkable(target, step)) then
            break
        end
        to = step
    end
    if (to) then
        doTeleportThing(target, to, true)
        doSendMagicEffect(to, EFFECT_SCARY_FACE)
    end
end

function onTargetTile_Whirlwind(cid, position)
    if (math.random(0, 1) == 1) then
        local pos = getCreaturePosition(cid)
        doSendDistanceShoot(pos, {x = position.x + math.random(-1, 1), y = position.y + math.random(-1, 1), z = position.z}, SKILL_PROJECTILE)
        addEvent(doSendDistanceShoot, 250, pos, {x = position.x + math.random(-1, 1), y = position.y + math.random(-1, 1), z = position.z}, SKILL_PROJECTILE)
    end
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_Whirlwind")
setCombatCallback(combat, CALLBACK_PARAM_TARGETTILE, "onTargetTile_Whirlwind")
setCombatArea(combat, createCombatArea(AREA_WAVE7))

function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
