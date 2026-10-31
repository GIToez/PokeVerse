local SKILL_NAME = "Belly Drum"
local SKILL_EFFECT = getPokemonSkillEffect(SKILL_NAME)

function onCastSpell(cid, var)
    local cost = math.floor(getCreatureMaxHealth(cid) / 2)
    if (getCreatureHealth(cid) <= cost) then
        doSendAnimatedText(getCreaturePosition(cid), "FAIL!", COLOR_WHITE)
        return false
    end
    doCreatureAddHealth(cid, -cost)
    doSendAnimatedText(getCreaturePosition(cid), -cost, COLOR_RED)
    doCreatureAddStatus(cid, CREATURE_STATUS_EXTRASPATK, CREATURE_STATUS_VAR_HIGH, cid)
    doSendMagicEffect(getCreaturePosition(cid), SKILL_EFFECT)
    return true
end
