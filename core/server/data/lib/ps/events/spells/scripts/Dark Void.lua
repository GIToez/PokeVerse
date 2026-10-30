local SKILL_NAME = "Dark Void"

function onTargetCreature_DarkVoid(cid, target)
    doCreatureAddStatus(target, CREATURE_STATUS_SLEEP, nil, cid)
end

local combat = createCombatObject()
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature_DarkVoid")
setCombatParam(combat, COMBAT_PARAM_EFFECT, getPokemonSkillAreaEffect(SKILL_NAME))
setCombatArea(combat, createCombatArea(AREA_CIRCLE2X2))

function onCastSpell(cid, var)
	doCombat(cid, combat, var)
	return true
end
