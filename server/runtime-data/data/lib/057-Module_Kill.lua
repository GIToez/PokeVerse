STORAGE_TASK = {  -- STORAGE_TASK.CONST.OFFSET.KILLED_BOSS
  VIEW               = 49996,
  RANK               = 49997,
  POINTS             = 49998,
  APPEAR_QUESTLOG    = 49999,
  ACTIVE_NAMES       = 50000, -- 50000 ~ 5009 :: São 10 storages pra salvar o nome dos bixos que estão com task ativa
  START              = 50010, -- Examples: 50011 = rat kills count; 50022 = finished snake task
  
  CONST = { -- Não são storages, apenas constantes relacionadas
    MAX_TASKS_TOGETHER = 1,
    OFFSET_COUNT = 10,
    OFFSET = {
      KILLS       = 1,
      FINISHED    = 2,
      KILLED_BOSS = 3,
      DELAY = 4,
    },
  }, 
}

TABLE_RANKS_OTC = {
   [-1] = {"E","D","C","B","A","S"},
   [0] = {"E","D","C","B","A","S"},
   [1] = {"E","D","C","B","A","S"},
   [2] = {"E","D","C","B","A","S"},
   [3] = {"E","D","C","B","A","S"},
   [4] = {"E","D","C","B","A","S"}
} 

TABLE_RANK_LEVEL = {
   ["E"] = {{1,19}, -1, points = 0},
   ["D"] = {{20,39}, -1, points = 0},
   ["C"] = {{40,69}, -1, points = 0},
   ["B"] = {{70,89}, -1, points = 0},
   ["A"] = {{90,100}, -1, points = 0},
   ["S"] = {{101,math.huge}, -1, points = 0}
}   
-- Business Around The World :: Comeca no npc Mack
STORAGE_BUSINESS_WORLD = {
    SHOW_IN_QUEST_LOG = 21030,
    HISTORY           = 21031,
    KILLS             = 21032, -- armazena os kills de varios bixos ao mesmo tempo com uma gambiarra
}

STORAGE_SAVING_BUGGY_BIRDS = {
    --SHOW_IN_QUEST_LOG = 21040,
    HISTORY           = 21041,
    KILLS             = 21042,
}   

TABLE_RANKS = {"E","D","C","B","A","S"}
TABLE_DELAY_SAMPLER = 60*60*24 -- 24 horas

TABLE_TASKS = { 
  ["bulbasaur"] = {id = 0, level = 20, count = 005, exp = 2500, point = 10000, delay = (60*60*24)},
  ["ivysaur"]  = {id = 1, level = 40, count = 025, exp = 3000, point = 3, delay = (60*60*24)},
  ["venusaur"]   = {id = 2, level = 85, count = 230, exp = 25000, point = 5, delay = (60*60*24)},
 
  ["charmander"] = {id = 3, level = 20, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["charmeleon"]  = {id = 4, level = 40, count = 025, exp = 3000, point = 3, delay = (60*60*24)},
  ["charizard"]   = {id = 5, level = 85, count = 230, exp = 25000, point = 5, delay = (60*60*24)},
 
  ["squirtle"] = {id = 6, level = 20, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["wartortle"]  = {id = 7, level = 40, count = 025, exp = 3000, point = 3, delay = (60*60*24)},
  ["blastoise"]   = {id = 8, level = 85, count = 230, exp = 25000, point = 5, delay = (60*60*24)},
 
  ["caterpie"] = {id = 9, level = 1, count = 030, exp = 1500, point = 1, delay = (60*60*24)},
  ["metapod"]  = {id = 10, level = 10, count = 030, exp = 3000, point = 3, delay = (60*60*24)},
  ["butterfree"]   = {id = 11, level = 30, count = 50, exp = 5500, point = 4, delay = (60*60*24)},
 
  ["weedle"] = {id = 12, level = 1, count = 030, exp = 1500, point = 1, delay = (60*60*24)},
  ["kakuna"]  = {id = 13, level = 10, count = 030, exp = 3000, point = 3, delay = (60*60*24)},
  ["beedrill"]   = {id = 14, level = 30, count = 50, exp = 5500, point = 4, delay = (60*60*24)},
 
  ["pidgey"] = {id = 15, level = 5, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["pidgeotto"]  = {id = 16, level = 20, count = 050, exp = 3000, point = 3, delay = (60*60*24)},
  ["pidgeot"]   = {id = 17, level = 65, count = 230, exp = 25000, point = 5, delay = (60*60*24)},
 
  ["rattata"] = {id = 18, level = 1, count = 040, exp = 1500, point = 1, delay = (60*60*24)},
  ["raticate"]  = {id = 19, level = 20, count = 035, exp = 3500, point = 3, delay = (60*60*24)},
 
  ["spearow"] = {id = 20, level = 5, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["fearow"]  = {id = 21, level = 50, count = 050, exp = 3650, point = 3, delay = (60*60*24)},
 
  ["ekans"] = {id = 22, level = 12, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["arbok"]  = {id = 23, level = 35, count = 075, exp = 6000, point = 3, delay = (60*60*24)},
 
  ["pikachu"] = {id = 24, level = 20, count = 025, exp = 3500, point = 1, delay = (60*60*24)},
  ["raichu"]  = {id = 25, level = 50, count = 230, exp = 25000, point = 3, delay = (60*60*24)},
 
  ["sandshrew"] = {id = 26, level = 10, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["sandslash"]  = {id = 27, level = 55, count = 120, exp = 10000, point = 3, delay = (60*60*24)},
 
  ["nidorana"] = {id = 28, level = 10, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["nidorina"]  = {id = 29, level = 25, count = 065, exp = 3500, point = 3, delay = (60*60*24)},
  ["nidoqueen"]  = {id = 30, level = 65, count = 100, exp = 15320, point = 5, delay = (60*60*24)},

  ["nidorano"] = {id = 31, level = 10, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["nidorino"]  = {id = 32, level = 25, count = 065, exp = 3500, point = 3, delay = (60*60*24)},
  ["nidoking"]  = {id = 33, level = 65, count = 100, exp = 15320, point = 5, delay = (60*60*24)},

  ["clefairy"] = {id = 34, level = 10, count = 025, exp = 2500, point = 1, delay = (60*60*24)},
  ["clefable"]  = {id = 35, level = 35, count = 100, exp = 10500, point = 5, delay = (60*60*24)},

  ["vulpix"] = {id = 36, level = 20, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["ninetales"]  = {id = 37, level = 75, count = 110, exp = 10000, point = 5, delay = (60*60*24)},

  ["jigglypuff"] = {id = 38, level = 20, count = 025, exp = 3000, point = 2, delay = (60*60*24)},
  ["wigglytuff"]  = {id = 39, level = 52, count = 100, exp = 10000, point = 5, delay = (60*60*24)},

  ["zubat"] = {id = 40, level = 5, count = 035, exp = 1500, point = 1, delay = (60*60*24)},
  ["golbat"]  = {id = 41, level = 40, count = 025, exp = 3500, point = 3, delay = (60*60*24)},

  ["oddish"] = {id = 42, level = 5, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["gloom"]  = {id = 43, level = 28, count = 025, exp = 3000, point = 3, delay = (60*60*24)},
  ["vileplume"]  = {id = 44, level = 60, count = 100, exp = 17000, point = 5, delay = (60*60*24)},

  ["paras"] = {id = 45, level = 5, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["parasect"]  = {id = 46, level = 50, count = 075, exp = 7500, point = 3, delay = (60*60*24)},

  ["venonat"] = {id = 47, level = 18, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["venomoth"]  = {id = 48, level = 60, count = 100, exp = 11000, point = 3, delay = (60*60*24)},

  ["diglett"] = {id = 49, level = 5, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["dugtrio"]  = {id = 50, level = 35, count = 065, exp = 5500, point = 3, delay = (60*60*24)},

  ["meowth"] = {id = 51, level = 12, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["persian"]  = {id = 52, level = 25, count = 055, exp = 5000, point = 3, delay = (60*60*24)},

  ["psyduck"] = {id = 53, level = 12, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["golduck"]  = {id = 54, level = 55, count = 100, exp = 13500, point = 3, delay = (60*60*24)},

  ["mankey"] = {id = 55, level = 15, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["primeape"]  = {id = 56, level = 55, count = 065, exp = 7500, point = 3, delay = (60*60*24)},

  ["growlithe"] = {id = 57, level = 25, count = 025, exp = 3500, point = 2, delay = (60*60*24)},
  ["arcanine"]  = {id = 58, level = 80, count = 150, exp = 20000, point = 5, delay = (60*60*24)},

  ["poliwag"] = {id = 59, level = 5, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["poliwhirl"]  = {id = 60, level = 20, count = 065, exp = 4500, point = 3, delay = (60*60*24)},
  ["poliwrath"]  = {id = 61, level = 75, count = 100, exp = 12000, point = 5, delay = (60*60*24)},

  ["abra"] = {id = 62, level = 25, count = 030, exp = 3500, point = 1, delay = (60*60*24)},
  ["kadabra"]  = {id = 63, level = 55, count = 065, exp = 5500, point = 3, delay = (60*60*24)},
  ["alakazam"]  = {id = 64, level = 80, count = 120, exp = 16000, point = 5, delay = (60*60*24)},

  ["machop"] = {id = 65, level = 20, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["machoke"]  = {id = 66, level = 55, count = 065, exp = 5500, point = 3, delay = (60*60*24)},
  ["machamp"]  = {id = 67, level = 80, count = 120, exp = 16000, point = 5, delay = (60*60*24)},

  ["bellsprout"] = {id = 68, level = 5, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["weepinbell"]  = {id = 69, level = 35, count = 065, exp = 5500, point = 2, delay = (60*60*24)},
  ["victreebel"]  = {id = 70, level = 60, count = 085, exp = 3500, point = 3, delay = (60*60*24)},

  ["tentacool"] = {id = 71, level = 15, count = 040, exp = 35000, point = 1, delay = (60*60*24)},
  ["tentacruel"]  = {id = 72, level = 85, count = 120, exp = 20000, point = 5, delay = (60*60*24)},

  ["geodude"] = {id = 73, level = 15, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["graveler"]  = {id = 74, level = 40, count = 065, exp = 4500, point = 3, delay = (60*60*24)},
  ["golem"]  = {id = 75, level = 75, count = 120, exp = 20000, point = 5, delay = (60*60*24)},

  ["ponyta"] = {id = 76, level = 20, count = 040, exp = 2500, point = 1, delay = (60*60*24)},
  ["rapidash"]  = {id = 77, level = 65, count = 085, exp = 13000, point = 5, delay = (60*60*24)},

  ["slowpoke"] = {id = 78, level = 15, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["slowbro"]  = {id = 79, level = 55, count = 065, exp = 5350, point = 3, delay = (60*60*24)},

  ["magnemite"] = {id = 80, level = 15, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["magneton"]  = {id = 81, level = 40, count = 100, exp = 10000, point = 3, delay = (60*60*24)},

  ["farfetchd"] = {id = 82, level = 40, count = 080, exp = 12512, point = 3, delay = (60*60*24)},

  ["doduo"] = {id = 83, level = 25, count = 030, exp = 5350, point = 1, delay = (60*60*24)},
  ["dodrio"] = {id = 84, level = 55, count = 085, exp = 10000, point = 3, delay = (60*60*24)},

  ["seel"] = {id = 85, level = 20, count = 030, exp = 3500, point = 1, delay = (60*60*24)},
  ["dewgong"] = {id = 86, level = 75, count = 100, exp = 12000, point = 3, delay = (60*60*24)},

  ["grimer"] = {id = 87, level = 15, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["muk"] = {id = 88, level = 45, count = 120, exp = 20000, point = 5, delay = (60*60*24)},

  ["shellder"] = {id = 89, level = 5, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["cloyster"] = {id = 90, level = 65, count = 120, exp = 13500, point = 5, delay = (60*60*24)},

  ["gastly"] = {id = 91, level = 20, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["haunter"] = {id = 92, level = 45, count = 065, exp = 7500, point = 3, delay = (60*60*24)},
  ["gengar"] = {id = 93, level = 80, count = 130, exp = 20000, point = 5, delay = (60*60*24)},

  ["onix"] = {id = 94, level = 30, count = 130, exp = 20000, point = 5, delay = (60*60*24)},

  ["drowzee"] = {id = 95, level = 25, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["hypno"] = {id = 96, level = 50, count = 065, exp = 8500, point = 3, delay = (60*60*24)},

  ["krabby"] = {id = 97, level = 5, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["kingler"] = {id = 98, level = 45, count = 075, exp = 7500, point = 3, delay = (60*60*24)},

  ["voltorb"] = {id = 99, level = 12, count = 030, exp = 2500, point = 1, delay = (60*60*24)},
  ["electrode"] = {id = 100, level = 40, count = 100, exp = 13500, point = 3, delay = (60*60*24)},

  ["exeggcute"] = {id = 101, level = 8, count = 035, exp = 3500, point = 1, delay = (60*60*24)},
  ["exeggutor"] = {id = 102, level = 48, count = 125, exp = 20000, point = 5, delay = (60*60*24)},

  ["cubone"] = {id = 103, level = 20, count = 030, exp = 3500, point = 1, delay = (60*60*24)},
  ["marowak"] = {id = 104, level = 45, count = 075, exp = 7500, point = 3, delay = (60*60*24)},

  ["hitmonlee"] = {id = 105, level = 60, count = 150, exp = 25000, point = 5, delay = (60*60*24)},
  ["hitmonchan"] = {id = 106, level = 60, count = 150, exp = 25000, point = 5, delay = (60*60*24)},

  ["lickitung"] = {id = 107, level = 50, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["koffing"] = {id = 108, level = 15, count = 040, exp = 3500, point = 1, delay = (60*60*24)},
  ["weezing"] = {id = 109, level = 40, count = 075, exp = 13500, point = 3, delay = (60*60*24)},

  ["rhyhorn"] = {id = 110, level = 35, count = 055, exp = 5500, point = 3, delay = (60*60*24)},
  ["rhydon"] = {id = 111, level = 65, count = 080, exp = 13500, point = 5, delay = (60*60*24)},

  ["chansey"] = {id = 112, level = 60, count = 050, exp = 10000, point = 5, delay = (60*60*24)},

  ["tangela"] = {id = 113, level = 40, count = 060, exp = 7500, point = 3, delay = (60*60*24)},

  ["kangaskhan"] = {id = 114, level = 60, count = 130, exp = 25000, point = 5, delay = (60*60*24)},

  ["horsea"] = {id = 115, level = 5, count = 045, exp = 3500, point = 1, delay = (60*60*24)},
  ["seadra"] = {id = 116, level = 45, count = 075, exp = 9500, point = 3, delay = (60*60*24)},

  ["goldeen"] = {id = 117, level = 10, count = 045, exp = 3500, point = 1, delay = (60*60*24)},
  ["seaking"] = {id = 118, level = 25, count = 075, exp = 9500, point = 3, delay = (60*60*24)},

  ["staryu"] = {id = 119, level = 15, count = 045, exp = 3500, point = 1, delay = (60*60*24)},
  ["starmie"] = {id = 120, level = 45, count = 075, exp = 9500, point = 3, delay = (60*60*24)},

  ["mr. mime"] = {id = 121, level = 60, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["scyther"] = {id = 122, level = 50, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["jynx"] = {id = 123, level = 85, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["electabuzz"] = {id = 124, level = 80, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["magmar"] = {id = 125, level = 80, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["pinsir"] = {id = 126, level = 45, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["tauros"] = {id = 127, level = 45, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["magikarp"] = {id = 128, level = 1, count = 100, exp = 3500, point = 1, delay = (60*60*24)},
  ["gyarados"] = {id = 129, level = 80, count = 120, exp = 25000, point = 5, delay = (60*60*24)},

  ["lapras"] = {id = 130, level = 80, count = 100, exp = 25000, point = 5, delay = (60*60*24)},

  ["ditto"] = {id = 131, level = 50, count = 001, exp = 10000, point = 10, delay = (60*60*24)},

  ["eevee"] = {id = 132, level = 20, count = 050, exp = 10000, point = 3, delay = (60*60*24)},
  ["vaporeon"] = {id = 133, level = 60, count = 050, exp = 10000, point = 5, delay = (60*60*24)},
  ["jolteon"] = {id = 134, level = 55, count = 050, exp = 10000, point = 5, delay = (60*60*24)},
  ["flareon"] = {id = 135, level = 55, count = 050, exp = 10000, point = 5, delay = (60*60*24)},

  ["porygon"] = {id = 136, level = 40, count = 050, exp = 10000, point = 3, delay = (60*60*24)},

  ["omanyte"] = {id = 137, level = 20, count = 030, exp = 3500, point = 3, delay = (60*60*24)},
  ["omastar"] = {id = 138, level = 70, count = 075, exp = 10000, point = 5, delay = (60*60*24)},

  ["kabuto"] = {id = 139, level = 20, count = 030, exp = 3500, point = 3, delay = (60*60*24)},
  ["kabutops"] = {id = 140, level = 70, count = 075, exp = 10000, point = 5, delay = (60*60*24)},

  ["aerodactyl"] = {id = 141, level = 100, count = 100, exp = 100000, point = 10, delay = (60*60*24)},

  ["snorlax"] = {id = 142, level = 85, count = 100, exp = 100000, point = 10, delay = (60*60*24)},

  ["articuno"] = {id = 143, level = 100, count = 001, exp = 100000, point = 10, delay = (60*60*24)},
  ["zapdos"] = {id = 144, level = 100, count = 001, exp = 100000, point = 10, delay = (60*60*24)},
  ["moltres"] = {id = 145, level = 100, count = 001, exp = 100000, point = 10, delay = (60*60*24)},

  ["dratini"] = {id = 146, level = 10, count = 035, exp = 7500, point = 1, delay = (60*60*24)},
  ["dragonair"] = {id = 147, level = 45, count = 075, exp = 20000, point = 3, delay = (60*60*24)},
  ["dragonite"] = {id = 148, level = 100, count = 120, exp = 50000, point = 5, delay = (60*60*24)},

  ["mewtwo"] = {id = 149, level = 100, count = 001, exp = 100000, point = 10, delay = (60*60*24)},
  ["mew"] = {id = 150, level = 100, count = 001, exp = 100000, point = 10, delay = (60*60*24)},
}

TABLE_TASKS_MONSTERS = { -- NOME DOS BIXOS MINUSCULO !!!!!!!!!!!!!
  ["joker bee"]          = "joker bee/god wind",
}

TABLE_ACHIEVEMENT_BOSS = -- index do achievement do boss
{ -- index sempre minus culo
  ["ditto"] = 40,
  ["enraged crocodile"] = 41,
  ["beetle king"] = 42,
  ["furious boar"] = 43,
  ["mutated lobster"] = 44,
  ["glowed golem"] = 45,  
      
  ["bluejam"] = 201, 
  ["alvida"] = 202,
  ["morgan"] = 203,
  ["mohji"] = 204,
  ["buggy"] = 205,     
}

-- TABLE_TASK_BUSINESS_AROUND_THE_WORLD = {
  -- ['troll']           = {count = 30, storage_multiplier = 1000000},
  -- ['troll warrior']   = {count = 20, storage_multiplier = 10000},
  -- ['troll berserker'] = {count = 10, storage_multiplier = 100},
  -- ['troll commander'] = {count =  2, storage_multiplier = 1},
-- }
-- TOTAL_VALUE_FROM_TASK_BUSINESS_AROUND_THE_WORLD = table.foldr(TABLE_TASK_BUSINESS_AROUND_THE_WORLD, 0, function (acc, task) return acc + task.count * task.storage_multiplier end)

-- TABLE_TASK_SAVING_BUGGY_BIRDS = {
  -- ['baby bird']  = {count = 250, storage_multiplier = 1},
  -- ['big bird']   = {count =  80, storage_multiplier = 1000},
-- }
-- TOTAL_VALUE_FROM_TASK_SAVING_BUGGY_BIRDS = table.foldr(TABLE_TASK_SAVING_BUGGY_BIRDS, 0, function (acc, task) return acc + task.count * task.storage_multiplier end)
-------------------------------------------------------------------------------- 
task = {
  avaiable = function(cid, taskname)
    return true      
  end, 

  getStorage = function(index, offset)  
    return STORAGE_TASK.START + (index * STORAGE_TASK.CONST.OFFSET_COUNT) + offset
  end,

  finished = function(cid, taskname) -- se matou all e ja reportou no npc   
    return getPlayerStorageValue(cid, task.getStorage(TABLE_TASKS[taskname].id, STORAGE_TASK.CONST.OFFSET.FINISHED)) == 1
  end,      

  kills = function(cid, taskname) -- quantidade de vezes que ja matou determinado bixo
    return getPlayerStorageValue(cid, task.getStorage(TABLE_TASKS[taskname].id, STORAGE_TASK.CONST.OFFSET.KILLS))
  end,
  
  killedNeededCount = function(cid, taskname)
    return task.kills(cid, taskname) >= TABLE_TASKS[taskname].count
  end,
  
  slot = function(cid, number) -- tem no maximo "STORAGE_TASK.CONST.MAX_TASKS_TOGETHER" de slots
    if number > STORAGE_TASK.CONST.MAX_TASKS_TOGETHER then
      print("[ERROR] lib_Tasks.lua excedeu o limite de slots!!!!!!!!!!!!!!!!!!!!!!")
      -- doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, 'somente 1 por vez')
    end         
    return getPlayerStorageValue(cid, STORAGE_TASK.ACTIVE_NAMES + number) 
  end,                        
  
  doing = function(cid, taskname) -- ve se essa task ja nao esta sendo feita por mim
    for i = 1, STORAGE_TASK.CONST.MAX_TASKS_TOGETHER do
      if task.slot(cid, i) == taskname then
        return true
      end
    end
    return false -- nao esta fazendo esta task  
  end, 
  
  doEraseSlot = function(cid, taskname)
    for i = 1, STORAGE_TASK.CONST.MAX_TASKS_TOGETHER do
      if task.slot(cid, i) == taskname then
        setPlayerStorageValue(cid, STORAGE_TASK.ACTIVE_NAMES + i, "")
        break
      end
    end
  end,
  
  doSaveSlot = function(cid, taskname)
    if task.doing(cid, taskname) then -- ja esta fazendo essa task em algum slot 
      return false
    end
    for i = 1, STORAGE_TASK.CONST.MAX_TASKS_TOGETHER do
      if not TABLE_TASKS[ task.slot(cid, i) ]  then -- linha vazia   
        setPlayerStorageValue(cid, STORAGE_TASK.ACTIVE_NAMES + i, taskname)
         local __buffer = {}
         __buffer["[PegueiUmaMissao]"] = {}
         doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))
        return true  
      end   
    end
    return false
  end,
  
  doSetKills = function(cid, taskname, count) -- define a quantidade de monstros matados em determinado slot 
    setPlayerStorageValue(cid, task.getStorage(TABLE_TASKS[taskname].id, STORAGE_TASK.CONST.OFFSET.KILLS), count)  
    task.doParseTask(cid, taskname)
  end,  
  
  doSetBossKill = function(cid, taskname, count)
    setPlayerStorageValue(cid, task.getStorage(TABLE_TASKS[taskname].id, STORAGE_TASK.CONST.OFFSET.KILLED_BOSS), count)
  end,
  
  doSetFinished = function(cid, taskname, count) -- define se ja terminou (-1 = nunca tentou, 0 = n?o terminou, 1 = terminou)
    setPlayerStorageValue(cid, task.getStorage(TABLE_TASKS[taskname].id, STORAGE_TASK.CONST.OFFSET.FINISHED), count)
  end,
  
  doParseTask = function(cid, taskname)
     local __buffer = {}                 
     local rank = ((getPlayerStorageValue(cid,STORAGE_TASK.VIEW) == -1) and "E" or getPlayerStorageValue(cid,STORAGE_TASK.VIEW))
     local avaiableTasks = getAvaiableTasks(cid)
     for creature, taskInfo in pairs(avaiableTasks) do
        if TABLE_RANK_LEVEL[rank] then
           if getPlayerStorageValue(cid, STORAGE_TASK.RANK) >= TABLE_RANK_LEVEL[rank][2] then
              if getPlayerLevel(cid) >= TABLE_RANK_LEVEL[rank][1][1] and taskInfo.level >= TABLE_RANK_LEVEL[rank][1][1] and taskInfo.level <= TABLE_RANK_LEVEL[rank][1][2] then      
                 if creature == taskname then
                    __buffer[1] = {}    
                    __buffer[1].id = creature
                    __buffer[1].level = taskInfo.level
                    __buffer[1].reward = taskInfo.exp
                    __buffer[1].point = taskInfo.point
                    __buffer[1].doing = task.doing(cid, creature)
                    __buffer[1].kills = (task.kills(cid, creature) == -1) and 0 or task.kills(cid, creature)
                    __buffer[1].count = taskInfo.count 
                    break
                 end
              end
           end
        end
     end
     doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))
  end,
  
  doParseTasks = function(cid)   
     function compare(a,b)
        return a.level < b.level
     end
     local __buffer = {}  
     local __resetBuffer = {}              
     local rank = ((getPlayerStorageValue(cid,STORAGE_TASK.VIEW) == -1) and "E" or getPlayerStorageValue(cid,STORAGE_TASK.VIEW))
     local avaiableTasks = getAvaiableTasks(cid)
     for creature, taskInfo in pairs(avaiableTasks) do
        if TABLE_RANK_LEVEL[rank] then
           if getPlayerStorageValue(cid, STORAGE_TASK.RANK) >= TABLE_RANK_LEVEL[rank][2] then
              if getPlayerLevel(cid) >= TABLE_RANK_LEVEL[rank][1][1] and taskInfo.level >= TABLE_RANK_LEVEL[rank][1][1] and taskInfo.level <= TABLE_RANK_LEVEL[rank][1][2] then  
                 local bufferid = #__buffer + 1
                 __buffer[bufferid] = {}    
                 __buffer[bufferid].id = creature                               
                 __buffer[bufferid].level = taskInfo.level
                 __buffer[bufferid].reward = taskInfo.exp                       
                 __buffer[bufferid].point = taskInfo.point
                 __buffer[bufferid].doing = task.doing(cid, creature)
                 __buffer[bufferid].kills = (task.kills(cid, creature) == -1) and 0 or task.kills(cid, creature)
                 __buffer[bufferid].count = taskInfo.count 
				
                 table.sort(__buffer, compare)
              end
           end
        end                                                  
     end                             
     doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, "[resetList]")
     doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))
  end,
  
  doParsePlayer = function(cid)
     local ranks = TABLE_RANKS_OTC[getPlayerStorageValue(cid, STORAGE_TASK.RANK)]
     local __buffer = {}
     __buffer["[pointsHave]"] = getPlayerStorageValue(cid, STORAGE_TASK.POINTS)       
     if ranks then
        __buffer["[unlockedRanks]"] = ranks
     end                    
     doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))
  end,
  
  doCancel = function(cid, taskname) -- cancelar slot de task (ou por cancelar ou quando termina mesmo) 
     if task.doing(cid, taskname) then    
        task.doEraseSlot(cid, taskname)
        task.doSetBossKill(cid, taskname, 0)         
        task.doSetFinished(cid, taskname, 0)  
        task.doSetKills(cid, taskname, 0)  
        return true
     end
     return false     
  end,
  
  doStart = function(cid, taskname) -- se o storage == 0, entao ele ja comecou essa task alguma vez na vida 
    task.doSetFinished(cid, taskname, 0) 
    -- setPlayerStorageValue(cid, STORAGE_TASK.APPEAR_QUESTLOG, 0) -- aparecer na quest log    
    task.doSetKills(cid, taskname, 0)
  end,
  
  doComplete = function(cid, taskname)  
    if not TABLE_TASKS[taskname].delay then
       TABLE_TASKS[taskname].delay = TABLE_DELAY_SAMPLER
    end
    doPlayerAddExp(cid, TABLE_TASKS[taskname].exp)
    setPlayerStorageValue(cid, task.getStorage(TABLE_TASKS[taskname].id, STORAGE_TASK.CONST.OFFSET.DELAY), os.time() + TABLE_TASKS[taskname].delay)
    setPlayerStorageValue(cid, STORAGE_TASK.POINTS, TABLE_TASKS[taskname].point + getPlayerStorageValue(cid, STORAGE_TASK.POINTS))           
    task.doCancel(cid, taskname)     
    task.doSetFinished(cid, taskname, 1)
    task.doParsePlayer(cid)   
  end,
  
  getTaskTableByTarget = function(cid, targetname)
    if TABLE_TASKS[targetname] then
      return targetname, TABLE_TASKS[targetname] 
    elseif TABLE_TASKS_MONSTERS[targetname] then -- da mesma especie mas tem nome diferente Ex: dragon lord
      return TABLE_TASKS_MONSTERS[targetname], TABLE_TASKS[ TABLE_TASKS_MONSTERS[targetname] ]
    end
    return nil
  end,
  
}
--------------------------------------------------------------------------------

function getAvaiableTasks(cid)
  local retorno = {}
  for index, v in pairs(TABLE_TASKS) do
    if task.avaiable(cid, index) then -- index de string    
      retorno[index] = v
    end
  end
  return retorno
end 
              
function getDoingTasks(cid)
  local retorno = ""
  for indexName, v in pairs(TABLE_TASKS) do
    if task.doing(cid, indexName) then -- index de string 
      retorno = retorno .. "{" .. indexName .. "}, "
    end
  end
  return string.sub(retorno, 1, string.len(retorno)-2) -- pra retirar o ultimo caracter (virgula) da string
end
--------------------------------------------------------------------------------
local function doGenerateTaskQuestLog()  
  local questxml = '  <quest name="Tasks" startstorageid="' .. STORAGE_TASK.APPEAR_QUESTLOG .. '" startstoragevalue="0" endstoragevalue="1"> \n' 
  for name, task_line in pairs(TABLE_TASKS) do -- gerar cada quest log
    local storage = task.getStorage(task_line.id, STORAGE_TASK.CONST.OFFSET.FINISHED)
    questxml = questxml ..
               '      <mission name="' .. name .. '" storageid="' .. storage .. '" startvalue="0" endvalue="1"> \n' .. 
               '        <missionstate id="0" description="Kill ' .. task_line.count .. ' ' ..  name .. 's and report to take you prize."/> \n' .. 
               '      </mission> \n ' 
  end  
  questxml = questxml .. '  </quest>\n'
  local file = io.open("data\\XML\\quests.xml", "w")
  file:write(questxml)
  file:close()
end

--doGenerateTaskQuestLog()