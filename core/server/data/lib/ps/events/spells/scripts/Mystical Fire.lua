local SKILL_NAME = "Mystical Fire"

function onTargetCreature_MysticalFire(cid, target)
    doSkillDamage(cid, target, SKILL_NAME)
    if (not isCreature(target)) then return end -- Defeated
    doCreatureAddStatus(target, CREATURE_STATUS_EXTRASPATK, CREATURE_STATUS_VAR_BAD, cid)
end

local combat = createCombatObject() setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_MysticalFire")
function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
