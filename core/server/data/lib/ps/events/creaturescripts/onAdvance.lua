local MASTERY_NAMES = { [PLAYER_SKILL_FISHING] = "Fishing", [PLAYER_SKILL_HEADBUTTING] = "Headbutt" }

local function sendSkillMastery(cid, skill, level)
    local levels = level - PLAYER_SKILL_MASTERY_LEVEL
    if (levels > 0) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
            __L(cid, "%s mastery: shiny chance x%.2f, %d%% chance of an extra Pokemon."), __L(cid, MASTERY_NAMES[skill]),
            getSkillMasteryShinyMultiplier(levels), math.floor(levels * PLAYER_SKILL_MASTERY_EXTRA_PER_LEVEL * 100 + 0.5)))
    end
end

function onAdvance(cid, skill, oldLevel, newLevel)
	if (skill == SKILL__LEVEL) then
        doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.LEVEL_100, newLevel)
        doSendMagicEffect(getCreaturePosition(cid), EFFECT_LEVEL_UP)
        if (newLevel > oldLevel) then
            LevelUpBanner.sendTrainer(cid, oldLevel, newLevel)
            doPlayerAddActivity(cid, "levelup", string.format(__L(cid, "You reached trainer level %d."), newLevel))
            Vocations.sendTrial(cid)
            Quests.onLevelUp(cid)
        end

    elseif (skill == PLAYER_SKILL_FISHING) then
        Vocations.addTrial(cid, "angler", "skill", nil, oldLevel)
        sendSkillMastery(cid, skill, newLevel)

    elseif (skill == PLAYER_SKILL_HEADBUTTING) then
        sendSkillMastery(cid, skill, newLevel)

    elseif (skill >= PLAYER_SKILL_DUEL_WIN and skill <= PLAYER_SKILL_BATTLE_LOSS) then
        onPlayerEndDuel(cid)
        WarpStyles.onDuelSkill(cid, skill)
    end
	return true
end
