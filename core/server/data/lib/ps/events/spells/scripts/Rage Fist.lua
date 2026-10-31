local SKILL_NAME = "Rage Fist"
local BASE_POWER = getPokemonSkillDamage(SKILL_NAME)

function onTargetCreature_RageFist(cid, target)
    local hurt = 1 - getCreatureHealth(cid) / getCreatureMaxHealth(cid)
    doSkillDamage(cid, target, SKILL_NAME, math.floor(BASE_POWER * (1 + hurt)))
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_RageFist")
function onCastSpell(cid, var)
    return doCombat(cid, combat, var)
end
