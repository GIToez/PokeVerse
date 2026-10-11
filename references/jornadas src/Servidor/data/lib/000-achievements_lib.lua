ACHIEVEMENT_NAMES = { -- ou faz referencia usando este index ou o index numerico da tabela TABLE_ACHIEVEMENTS
  ['skill_wc_1']         = 01,
  ['skill_wc_2']         = 02,
  ['skill_wc_3']         = 03,    
  ['skill_fishing_1']    = 04,
  ['skill_fishing_2']    = 05,
  ['skill_fishing_3']    = 06,    
  ['skill_cooking_1']    = 07,
  ['skill_cooking_2']    = 08,
  ['skill_cooking_3']    = 09,
  ['skill_doctor_1']     = 10,
  ['skill_doctor_2']     = 11,
  ['skill_doctor_3']     = 12,
  ['skill_woodwork_1']   = 13,
  ['skill_woodwork_2']   = 14,
  ['skill_woodwork_3']   = 15,
  ['skill_farming_1']    = 16,
  ['skill_farming_2']    = 17,
  ['skill_farming_3']    = 18,
  ['skill_mining_1']     = 19,
  ['skill_mining_2']     = 20,
  ['skill_mining_3']     = 21,    
  ['waking_pirates']     = 22,

  ['kill_ur_1st_player'] = 23,
  ['interior_decorator'] = 24,
  ['open_250_holes']     = 25,
  ['repair_boats']       = 26,
  ['travel_with_npc']    = 27,
  ['drink_potion']       = 28,
  ['kill_tashigi']       = 29,
  ['kill_nezumi']        = 30,
  
  ['quest_sabo']         = 51,  
  ['quest_dadan']        = 52,
  ['quest_jack_sparrow'] = 53,
  ['quest_thief_d']      = 54,
  ['quest_thief_r']      = 55,
  ['quest_thief_s']      = 56,    
  ['quest_taking_eggs']  = 57,
  ['quest_postman']      = 58,
  ['quest_buggy_bird']   = 59,
  
  ['kuro__']  = 206, -- arena do kuro
  
  ['route_1'] = 151,
  ['route_2'] = 152,
  ['route_3'] = 153,
  ['route_4'] = 154,
  ['route_5'] = 155,
  ['route_last'] = 199,
}

TABLE_ACHIEVEMENTS = { -- STORAGE = 28000 (definido na lib '_STORAGES.lua') + index  
 [001] = {name = "Novice Lumberjack",      value = 0010, reward = 1},
 [002] = {name = "Lumberjack",             value = 0100, reward = 2},
 [003] = {name = "Experient Lumberjack",   value = 1000, reward = 4},

 [004] = {name = "Novice Fisher",          value = 0010, reward = 1},
 [005] = {name = "Fisher",                 value = 0100, reward = 2},
 [006] = {name = "Experient Fisher",       value = 1000, reward = 4},

 [007] = {name = "Novice Cooker",          value = 0010, reward = 1},
 [008] = {name = "Cooker",                 value = 0100, reward = 2},
 [009] = {name = "Experient Cooker",       value = 1000, reward = 4},

 [010] = {name = "Novice Doctor",          value = 0010, reward = 1},
 [011] = {name = "Doctor",                 value = 0100, reward = 2},
 [012] = {name = "Experient Doctor",       value = 1000, reward = 4},

 [013] = {name = "Novice Constructor",     value = 0010, reward = 1},
 [014] = {name = "Constructor",            value = 0100, reward = 2},
 [015] = {name = "Experient Constructor",  value = 1000, reward = 4}, 

 [016] = {name = "Novice Farmer",          value = 0010, reward = 1},
 [017] = {name = "Farmer",                 value = 0100, reward = 2},
 [018] = {name = "Experient Farmer",       value = 1000, reward = 4}, 

 [019] = {name = "Novice Miner",           value = 0010, reward = 1},
 [020] = {name = "Miner",                  value = 0100, reward = 2},
 [021] = {name = "Experient Miner",        value = 1000, reward = 4}, 

 [022] = {name = "Waking Pirates",                 value =   100, reward = 1},

  [23] = {name = "Killing your first enemy",       value =     1, reward = 1},
  [24] = {name = "Interior Decorator",             value =   100, reward = 1}, 
  [25] = {name = "The Digger",                     value =   250, reward = 1},
  [26] = {name = "Reparing Boats",                 value =   250, reward = 3},
  [27] = {name = "Long Travels",                   value =   350, reward = 3},
  [28] = {name = "Potion Addict",                  value = 10000, reward = 3},
  [29] = {name = "Expert in Duels",                value =    50, reward = 3},
  [30] = {name = "Protecting the Nami's Treasure", value =     5, reward = 3},
      
 -- reservado para diversos
 
 
 -- Reservado para achievement defeats
 [040] = {name = "Defeating Big Rat",           value = 1, reward = 1},
 [041] = {name = "Defeating Enraged Crocodile", value = 1, reward = 1},
 [042] = {name = "Defeating Beetle King",       value = 1, reward = 1},
 [043] = {name = "Defeating Furious Boar",      value = 1, reward = 1},
 [044] = {name = "Defeating Mutated Lobster",   value = 1, reward = 1},
 [045] = {name = "Defeating Glowed Golem",      value = 1, reward = 1},    
 
 -- Quests 
 [051] = {name = "Sabo Friend",            value = 1, reward = 1},
 [052] = {name = "Helping Dadan",          value = 3, reward = 1},  
 [053] = {name = "Defeating Jack Sparrow", value = 1, reward = 1},
 
 [054] = {name = "Gaining the trust of the D block", value = 1, reward = 1},
 [055] = {name = "Gaining the trust of the R block", value = 1, reward = 1},
 [056] = {name = "Gaining the trust of the S block", value = 1, reward = 1},

 [057] = {name = "Stealing Eggs",                    value = 8, reward = 1},
 [058] = {name = "Postman Quest",                    value = 1, reward = 1},
 [059] = {name = "Saving Buggy from the Birds",      value = 1, reward = 1},
  
 -- Quest Unlocking Routes
 [151] = {name = "Unlocking Goa Kingdom Route", value = 1, reward = 1},
 [152] = {name = "Unlocking Shell Town Route",  value = 1, reward = 1},
 [153] = {name = "Unlocking Orange Town Route", value = 1, reward = 1},
 [154] = {name = "Unlocking Loguetown Route",   value = 1, reward = 1}, 
 -- reservado até o [200]
 
  -- Quest Saga
 [201] = {name = "Defeating Bluejam",                value = 1, reward = 1},
 [202] = {name = "Defeating Alvida",                 value = 1, reward = 1},
 [203] = {name = "Defeating Captain Morgan",         value = 1, reward = 1},
 [204] = {name = "Defeating Mohji",                  value = 1, reward = 1},
 [205] = {name = "Defeating Buggy and Cabaji",       value = 1, reward = 1}, 
 [206] = {name = "Defeating Kuro Pirates",           value = 1, reward = 1},
 
 -- [800] deve ser o limite  
}
local STORAGE_ACHIEVEMENT_POINTS = 28000 -- 28000 = achiev. points  (28001 - 28800) quantidade de ticks de cada achievs.
  -- Preencher os storages de cada um 
  for index, content in pairs(TABLE_ACHIEVEMENTS) do
    TABLE_ACHIEVEMENTS[index].storage = STORAGE_ACHIEVEMENT_POINTS + index  
  end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
ACHIEVEMENT = {
  
   getPoints = function(cid)
     --return math.max(0, getPlayerStorageValue(cid, STORAGE_ACHIEVEMENT_POINTS) or 0)
     return getPlayerSkill(cid, SKILL_ACHIEVEMENT) 
   end,
   
   addPoints = function(cid, points)
     --setPlayerStorageValue(cid, STORAGE_ACHIEVEMENT_POINTS, ACHIEVEMENT.getPoints(cid) + points)
     --doPlayerAddSkill(cid, SKILL_ACHIEVEMENT, points)
     doPlayerAddSkillLevel(cid, SKILL_ACHIEVEMENT, points) 
   end,
   
   setValue = function(cid, index, value) -- index do achievement
     setPlayerStorageValue(cid, TABLE_ACHIEVEMENTS[index].storage, math.max(0, math.min(TABLE_ACHIEVEMENTS[index].value, value)) )
   end,
   
   getValue = function(cid, index) -- index do achievement     
     return math.max(0, getPlayerStorageValue(cid, TABLE_ACHIEVEMENTS[index].storage))
   end,
   
   add      = function(cid, index, value) -- adiciona ponto ate completar 
     if not ACHIEVEMENT.assert(cid, index, 'add(cid, index, value)') then
       return nil
     end
     index = TABLE_ACHIEVEMENTS[index] and index or ACHIEVEMENT_NAMES[index]
     --------- tratamento acabou
     if not ACHIEVEMENT.finished(cid, index) then
       ACHIEVEMENT.setValue(cid, index, ACHIEVEMENT.getValue(cid, index) + value)
       if ACHIEVEMENT.getValue(cid, index) >= TABLE_ACHIEVEMENTS[index].value then
         ACHIEVEMENT.doFinish(cid, index)
       end 
     end      
   end,
   
   finished = function(cid, index)
     if not ACHIEVEMENT.assert(cid, index, 'finished(cid, index)') then
       return nil                      
     end
     index = TABLE_ACHIEVEMENTS[index] and index or ACHIEVEMENT_NAMES[index]
     --------- tratamento acabou
     return ACHIEVEMENT.getValue(cid, index) >= TABLE_ACHIEVEMENTS[index].value 
   end,
   
   doFinish = function(cid, index)
     local points = TABLE_ACHIEVEMENTS[index].reward 
     -- ACHIEVEMENT.addPoints(cid, points)
     doPlayerSendTextMessage(cid, 22, "Contratulations, you just completed the achievement '" .. TABLE_ACHIEVEMENTS[index].name .. "' and earned " .. points .. " achievement point" .. (points > 1 and "s" or "") .. ".")
   end,
   
   assert = function(cid, index, str_from_function) -- meu proprio assert rs
     if not TABLE_ACHIEVEMENTS[index] and (not ACHIEVEMENT_NAMES[index] or not TABLE_ACHIEVEMENTS[ACHIEVEMENT_NAMES[index]]) then
       print("lib_achievements.lua -> " .. (str_from_function or ' - ') .. " :: Index " .. (index and ('`' .. index .. '`') or ' - ') .. " do not exist on table. (nick: `" .. (getPlayerName(cid) or "?") .. "`)")
       return false
     end  
     return true
   end,      
}        
--------------------------------------------------------------------------------