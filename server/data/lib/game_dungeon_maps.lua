
Dz.PrizeRooms = {
  [1] = {
    teleportPos =  {x = 37, y = 53, z = 6},
    inUse = false,
    corpse = {
      [1] = {x = 36, y = 23, z = 6},
      [2] = {x = 25, y = 33, z = 6},
      [3] = {x = 46, y = 33, z = 6},
    },
    chest = {
      [1] = {x = 32, y = 11, z = 6},
      [2] = {x = 36, y = 10, z = 6},
      [3] = {x = 40, y = 11, z = 6},
    },
  },
  [2] = {
    teleportPos =  {x = 37, y = 53, z = 6},
    inUse = false,
    corpse = {
      [1] = {x = 36, y = 23, z = 6},
      [2] = {x = 25, y = 33, z = 6},
      [3] = {x = 46, y = 33, z = 6},
    },
    chest = {
      [1] = {x = 32, y = 11, z = 6},
      [2] = {x = 36, y = 10, z = 6},
      [3] = {x = 40, y = 11, z = 6},
    },
  },
}

----------------------------------------------------------------------------------------------------
---------------------------------------------BEGINNER-----------------------------------------------
----------------------------------------------------------------------------------------------------

Dz.Diff[DzBeginner].Level = {min=10, max=50}
Dz.Diff[DzBeginner].Maps = {}
Dz.Diff[DzBeginner].Maps[1] = {name = "Toca dos Rattatas", rarity = DzBronze, maxPlayers = 1, image = "catinhorattata", active = true}
Dz.Diff[DzBeginner].Maps[1].experience = 1500000
Dz.Diff[DzBeginner].Maps[1].time = 60000 * 60
Dz.Diff[DzBeginner].Maps[1].potions = 20
Dz.Diff[DzBeginner].Maps[1].revives = 12
Dz.Diff[DzBeginner].Maps[1].corpses = {[1] = {"Shiny Rattata","Shiny Raticate"}, [2] = {"Rattata","Raticate","Zubat","Golbat"}}
Dz.Diff[DzBeginner].Maps[1].reward = {{id = 35542, qnt = {1,5}, chance = 50},{id = 35541, qnt = {1,5}, chance = 50},{id = 35540, qnt = {1,5}, chance = 50},{id = 35539, qnt = {1,5}, chance = 50},{id = 12165, qnt = {1,5}, chance = 50},{id = 34524, qnt = {1,5}, chance = 50},{id = 12129, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50}}
Dz.Diff[DzBeginner].Maps[1].rooms = {}
Dz.Diff[DzBeginner].Maps[1].rooms[1] = {
  pos = {player = {x = 4670, y = 429, z = 7}, from = {x = 4662, y = 389, z = 4}, to = {x = 4739, y = 469, z = 7}},
  inUse = false,
  variable = {pokemonCount = 0, time = nil, members = {}, pokemons = {}},
  pokemons = {
    {name = "Rattata", pos = {x = 4681, y = 443, z = 7}},
    {name = "Rattata", pos = {x = 4689, y = 452, z = 7}},
    {name = "Rattata", pos = {x = 4702, y = 451, z = 7}},
    {name = "Rattata", pos = {x = 4704, y = 435, z = 7}},
    {name = "Rattata", pos = {x = 4691, y = 423, z = 7}},
    {name = "Rattata", pos = {x = 4708, y = 422, z = 7}},
    {name = "Rattata", pos = {x = 4724, y = 418, z = 7}},
    {name = "Rattata", pos = {x = 4724, y = 403, z = 7}},
    {name = "Rattata", pos = {x = 4716, y = 407, z = 7}},
    {name = "Rattata", pos = {x = 4706, y = 410, z = 7}},
    {name = "Rattata", pos = {x = 4703, y = 404, z = 7}},
    {name = "Rattata", pos = {x = 4706, y = 403, z = 7}},
	
    {name = "Raticate", pos = {x = 4686, y = 402, z = 6}},
    {name = "Raticate", pos = {x = 4692, y = 416, z = 6}},
    {name = "Zubat", pos = {x = 4680, y = 406, z = 6}},
    {name = "Zubat", pos = {x = 4680, y = 413, z = 6}},
    {name = "Zubat", pos = {x = 4707, y = 413, z = 6}},
    {name = "Raticate", pos = {x = 4718, y = 399, z = 6}},
    {name = "Rattata", pos = {x = 4726, y = 409, z = 6}},
    {name = "Rattata", pos = {x = 4720, y = 422, z = 6}},
    {name = "Rattata", pos = {x = 4730, y = 419, z = 6}},
    {name = "Rattata", pos = {x = 4719, y = 435, z = 6}},
    {name = "Raticate", pos = {x = 4728, y = 436, z = 6}},
	
    {name = "Raticate", pos = {x = 4729, y = 429, z = 5}},
    {name = "Raticate", pos = {x = 4729, y = 436, z = 5}},
	
    {name = "Golbat", pos = {x = 4722, y = 445, z = 4}},
    {name = "Golbat", pos = {x = 4718, y = 432, z = 4}},
    {name = "Raticate", pos = {x = 4715, y = 425, z = 4}},
    {name = "Raticate", pos = {x = 4716, y = 419, z = 5}},
    {name = "Raticate", pos = {x = 4715, y = 416, z = 5}},
  },
  boss = {name = "Shiny Raticate", pos = {x = 4728, y = 400, z = 5}}
}

Dz.Diff[DzTalented].Level = {min=10, max=50}
Dz.Diff[DzTalented].Maps = {}
Dz.Diff[DzBeginner].Maps[2] = {name = "Vilarejo dos Primeapes", rarity = DzSilver, maxPlayers = 4, image = "vilamankey", active = true}
Dz.Diff[DzBeginner].Maps[2].experience = 64000
Dz.Diff[DzBeginner].Maps[2].time = 60000 * 2
Dz.Diff[DzBeginner].Maps[2].potions = 20
Dz.Diff[DzBeginner].Maps[2].revives = 12
Dz.Diff[DzBeginner].Maps[2].corpses = {[1] = {"Rattata","Pidgey"}, [2] = {"Wartortle","Charizard"}}
Dz.Diff[DzBeginner].Maps[2].reward = {{id = 35542, qnt = {1,5}, chance = 50},{id = 35541, qnt = {1,5}, chance = 50},{id = 35540, qnt = {1,5}, chance = 50},{id = 35539, qnt = {1,5}, chance = 50},{id = 12165, qnt = {1,5}, chance = 50},{id = 34524, qnt = {1,5}, chance = 50},{id = 12129, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50}}
Dz.Diff[DzBeginner].Maps[2].rooms = {}
Dz.Diff[DzBeginner].Maps[2].rooms[1] = {
  pos = {player = {x = 4426, y = 580, z = 7}, from = {x = 4389, y = 564, z = 7}, to = {x = 4464, y = 642, z = 7}},
  inUse = false,
  variable = {pokemonCount = 0, time = nil, members = {}, pokemons = {}},
  pokemons = {
    {name = "Mankey", pos = {x = 4400, y = 592, z = 7}},
    {name = "Mankey", pos = {x = 4410, y = 601, z = 7}},
  },
  boss = {name = "Primeape", pos = {x = 4400, y = 592, z = 7}}
}

Dz.Diff[DzIntermediary].Level = {min=10, max=50}
Dz.Diff[DzIntermediary].Maps = {}
Dz.Diff[DzBeginner].Maps[3] = {name = "Vale Lavafort", rarity = DzGold, maxPlayers = 2, image = "vulcaoanciao", active = true}
Dz.Diff[DzBeginner].Maps[3].experience = 64000
Dz.Diff[DzBeginner].Maps[3].time = 60000 * 2
Dz.Diff[DzBeginner].Maps[3].potions = 20
Dz.Diff[DzBeginner].Maps[3].revives = 12
Dz.Diff[DzBeginner].Maps[3].corpses = {[1] = {"Rattata","Pidgey"}, [2] = {"Wartortle","Charizard"}}
Dz.Diff[DzBeginner].Maps[3].reward = {{id = 35542, qnt = {1,5}, chance = 50},{id = 35541, qnt = {1,5}, chance = 50},{id = 35540, qnt = {1,5}, chance = 50},{id = 35539, qnt = {1,5}, chance = 50},{id = 12165, qnt = {1,5}, chance = 50},{id = 34524, qnt = {1,5}, chance = 50},{id = 12129, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50}}
Dz.Diff[DzBeginner].Maps[3].rooms = {}
Dz.Diff[DzBeginner].Maps[3].rooms[1] = {
  pos = {player = {x = 4426, y = 580, z = 7}, from = {x = 4389, y = 564, z = 7}, to = {x = 4464, y = 642, z = 7}},
  inUse = false,
  variable = {pokemonCount = 0, time = nil, members = {}, pokemons = {}},
  pokemons = {
    {name = "Mankey", pos = {x = 4400, y = 592, z = 7}},
    {name = "Mankey", pos = {x = 4410, y = 601, z = 7}},
  },
  boss = {name = "Primeape", pos = {x = 4400, y = 592, z = 7}}
}

Dz.Diff[DzAdvanced].Level = {min=10, max=50}
Dz.Diff[DzAdvanced].Maps = {}
Dz.Diff[DzBeginner].Maps[4] = {name = "Aquamarines", rarity = DzSpecial, maxPlayers = 2, image = "aquamarines", active = true}
Dz.Diff[DzBeginner].Maps[4].experience = 64000
Dz.Diff[DzBeginner].Maps[4].time = 60000 * 2
Dz.Diff[DzBeginner].Maps[4].potions = 20
Dz.Diff[DzBeginner].Maps[4].revives = 12
Dz.Diff[DzBeginner].Maps[4].corpses = {[1] = {"Rattata","Pidgey"}, [2] = {"Wartortle","Charizard"}}
Dz.Diff[DzBeginner].Maps[4].reward = {{id = 35542, qnt = {1,5}, chance = 50},{id = 35541, qnt = {1,5}, chance = 50},{id = 35540, qnt = {1,5}, chance = 50},{id = 35539, qnt = {1,5}, chance = 50},{id = 12165, qnt = {1,5}, chance = 50},{id = 34524, qnt = {1,5}, chance = 50},{id = 12129, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50},{id = 12292, qnt = {1,5}, chance = 50}}
Dz.Diff[DzBeginner].Maps[4].rooms = {}
Dz.Diff[DzBeginner].Maps[4].rooms[1] = {
  pos = {player = {x = 4758, y = 569, z = 4}, from = {x = 4389, y = 564, z = 7}, to = {x = 4464, y = 642, z = 7}},
  inUse = false,
  variable = {pokemonCount = 0, time = nil, members = {}, pokemons = {}},
  pokemons = {
    {name = "Mankey", pos = {x = 4400, y = 592, z = 7}},
    {name = "Mankey", pos = {x = 4410, y = 601, z = 7}},
  },
  boss = {name = "Primeape", pos = {x = 4400, y = 592, z = 7}}
}

Dz.Diff[DzExperient].Maps = {}

for diff=DzBeginner, DzExperient do
  for mapId, map in pairs (Dz.Diff[diff].Maps) do
    if map.active then
      for rewardId, reward in pairs(map.reward) do
        reward.name = getItemInfo(reward.id).name
        reward.clientId = getItemInfo(reward.id).clientId
      end
      Dz.SearchingPlayers[diff][mapId] = {}
    end
  end
end