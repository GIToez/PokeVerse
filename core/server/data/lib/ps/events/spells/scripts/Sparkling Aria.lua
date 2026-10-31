local SKILL_NAME = "Sparkling Aria"
local SKILL_PROJECTILE = getPokemonSkillProjectile(SKILL_NAME)
local SKILL_EFFECT = getPokemonSkillEffect(SKILL_NAME)

function onTargetCreature_SparklingAria(cid, target)
    if (isFriend(cid, target)) then
        doCreatureRemoveStatus(target, CREATURE_STATUS_BURN)
    else
        doSkillDamage(cid, target, SKILL_NAME)
    end
end

function onTargetTile_SparklingAria(cid, position)
    if (math.random(0, 1) == 1) then
        local pos = getCreaturePosition(cid)
        addEvent(doSendDistanceShoot, getRandom(1, 300), pos, position, SKILL_PROJECTILE)
        addEvent(doSendMagicEffect, getRandom(300, 600), position, SKILL_EFFECT)
    end
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_SparklingAria")
setCombatCallback(combat, CALLBACK_PARAM_TARGETTILE, "onTargetTile_SparklingAria")
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))

function onCastSpell(cid, var)
    doCreatureRemoveStatus(cid, CREATURE_STATUS_BURN)
    return doCombat(cid, combat, var)
end
