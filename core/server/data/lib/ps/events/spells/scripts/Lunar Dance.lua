local SKILL_NAME = "Lunar Dance"
local SKILL_EFFECT = getPokemonSkillEffect(SKILL_NAME)
local CURED = {CREATURE_STATUS_BURN, CREATURE_STATUS_FREEZE, CREATURE_STATUS_PARALYSIS, CREATURE_STATUS_POISON,
    CREATURE_STATUS_BADPOISON, CREATURE_STATUS_SLEEP, CREATURE_STATUS_CONFUSION}

function onTargetCreature_LunarDance(cid, target)
    if (target ~= cid and isFriend(cid, target)) then
        doSendMagicEffect(getCreaturePosition(target), SKILL_EFFECT)
        doCreatureAddHealth(target, getCreatureMaxHealth(target))
        for _, status in ipairs(CURED) do
            doCreatureRemoveStatus(target, status)
        end
    end
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_LunarDance")
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

function onTargetTile_LunarDance(cid, position)
    addEvent(doSendMagicEffect, getRandom(1, 400), {x = position.x + math.random(-1, 1), y = position.y + math.random(-1, 1), z = position.z}, EFFECT_LOVE_HEARTS_TWO)
end
local combatEffect = createCombatObject()
setCombatCallback(combatEffect, CALLBACK_PARAM_TARGETTILE, "onTargetTile_LunarDance")
setCombatArea(combatEffect, createCombatArea(AREA_CROSS4X4))
setCombatParam(combatEffect, COMBAT_PARAM_AGGRESSIVE, false)

function onCastSpell(cid, var)
    doCombat(cid, combatEffect, var)
    addEvent(function(cid)
        if (isCreature(cid)) then
            doCombat(cid, combat, var)
            local heal = -(getCreatureHealth(cid) - 1)
            doCreatureAddHealth(cid, heal)
            doSendAnimatedText(getCreaturePosition(cid), heal, COLOR_RED)
        end
    end, 400, cid)
    return true
end
