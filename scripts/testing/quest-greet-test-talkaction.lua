-- TEST ONLY - never part of the game data or any package.
-- scripts/test-server-linux.sh copies this file into a temporary server directory as "/questtest"
-- and scripts/quest-greet-test.py says it before greeting an NPC:
--
--   /questtest <level> <NPC name>
--
-- raises the trainer to that level (levels only go up, so the cases run from low to high) and puts
-- them next to the NPC, then answers "questtest: ready <level>".

function onSay(cid, words, param)
    local level, name = param:match("^(%d+)%s+(.+)$")
    level = tonumber(level)
    local npc = name and getCreatureByName(name)
    if (not level or not npc) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "questtest: error " .. param)
        return true
    end

    local need = getExperienceForLevel(level) - getPlayerExperience(cid)
    if (need > 0) then
        doPlayerAddExperience(cid, need)
    end

    local pos = getCreaturePosition(npc)
    doTeleportThing(cid, getClosestFreeTile(cid, pos, false, false), false)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "questtest: ready " .. getPlayerLevel(cid))
    return true
end
