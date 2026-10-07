local missions = { -- Use missionStorage to link the monsters to each mission. It is set up this way so multiple missions can have the same monsters.
    [1] = {name = "Oddish", amount = 50, missionStorage = 63000, storage = 41000},
    [2] = {name = "Bellsprout", amount = 50, missionStorage = 63000, storage = 41001},
    [3] = {name = "Paras", amount = 50, missionStorage = 63000, storage = 41002},
    [4] = {name = "Beedrill", amount = 120, missionStorage = 605490, storage = 41003},
    [5] = {name = "Snorlax", amount = 30, missionStorage = 605489, storage = 41004},
    [6] = {name = "Diglett", amount = 30, missionStorage = 605493, storage = 41005},
    [7] = {name = "Sandshrew", amount = 30, missionStorage = 605493, storage = 41006},
    [8] = {name = "Cubone", amount = 30, missionStorage = 605493, storage = 41007},
    [9] = {name = "Golem", amount = 60, missionStorage = 605495, storage = 41008},
    [10] = {name = "Rhydon", amount = 60, missionStorage = 605495, storage = 41009},
    [11] = {name = "Marowak", amount = 60, missionStorage = 605495, storage = 41010},
    [12] = {name = "Sandslash", amount = 60, missionStorage = 605495, storage = 41011},
}

function onKill(creature, target)
    local cid = creature
    
    if isPlayer(creature) and isMonster(target) then
        for i = 1, #missions do
            if getCreatureName(target) == missions[i].name then
                if getCreatureStorage(cid, missions[i].missionStorage) == 1 then
                    if getCreatureStorage(cid, missions[i].storage) < missions[i].amount then
                        doCreatureSetStorage(cid, missions[i].storage, getCreatureStorage(cid, missions[i].storage) + 1)
                        
                        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você matou "..getCreatureStorage(cid, missions[i].storage).." de "..missions[i].amount.." "..missions[i].name.."s")
                    end
                end
            end
        end
    end
    return true
end