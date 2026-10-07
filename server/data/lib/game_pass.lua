json = require('data/lib/json')

PassVip = 1
PassPremium = 2
PassFirst = PassVip

Pass = {}
Pass.opcode = GameServerOpcodes.PokePass
Pass.version = 1
Pass.endDate = {year=2021, month=11, day=4, hour=22, sec=00}
Pass.strgs = {}-- Antes ou igual o nivel 50 usara a storage first
Pass.strgs[PassVip] = {first = PokePassStorages.PassVip1, second = PokePassStorages.PassVip2}
Pass.strgs[PassPremium] = {first = PokePassStorages.PassPremium1, second = PokePassStorages.PassPremium2}
PassLevelStorage = PokePassStorages.PassLevelStorage
PassStarsStorage = PokePassStorages.PassStarsStorage
PassPremiumStorage = PokePassStorages.PassPremiumStorage
local NoneItem = {image = "", name = "", desc = "", item = {id = 1, count = 1}}

Pass.items = {}
Pass.items[1] = {}
Pass.items[1][PassVip] = NoneItem
Pass.items[1][PassPremium] = {
	image = "gyarados", 
	name = "Gyarados Cosplay", 
	desc = "Com este Gyarados Copslay você consegue mostrar para todos que a força do dragão é maior do que qualquer determinação.",
	item = {id = 35575, count = 1}
}

Pass.items[2] = {}
Pass.items[2][PassVip] = {image = "charizard", name = "", desc = "", item = {id = 29127, count = 1}} -- Ticket box ok
Pass.items[2][PassPremium] = {image = "charizard", name = "", desc = "", item = {id = 18896, count = 1}} -- Ticket Legendary ball ok

Pass.items[3] = {}
Pass.items[3][PassVip] = {image = "venusaur", name = "", desc = "", item = {id = 12161, count = 100}} -- 100GB ok
Pass.items[3][PassPremium] = {image = "charizard", name = "", desc = "", item = {id = 12165, count = 100}} -- 100UB ok

Pass.items[4] = {}
Pass.items[4][PassVip] = {image = "charizard", name = "", desc = "", item = {id = 35547, count = 5}} -- 5 maça ok
Pass.items[4][PassPremium] = {image = "charizard", name = "", desc = "", item = {id = 35574, count = 1}} -- Stats box ( pedras de status ) ok
 
Pass.items[5] = {}
Pass.items[5][PassVip] = NoneItem
Pass.items[5][PassPremium] = {image = "", name = "", desc = "", premiumPoints = 5} -- 5 PokeCoin ok

Pass.items[6] = {}
Pass.items[6][PassVip] = {image = "", name = "", desc = "", item = {id = 12244, count = 50}} -- 50 pokemon health potion ok 
Pass.items[6][PassPremium] = {image = "", name = "", desc = "", item = {id = 12246, count = 50}} -- 50 pokemon ultra health potion ok

Pass.items[7] = {}
Pass.items[7][PassVip] = {image = "", name = "", desc = "", item = {id = 29127, count = 1}} -- Ticket box ok
Pass.items[7][PassPremium] = {image = "", name = "", desc = "", item = {id = 18896, count = 1}} -- Ticket Legendary ball ok

Pass.items[8] = {}
Pass.items[8][PassVip] = NoneItem
Pass.items[8][PassPremium] = {image = "", name = "", desc = "", item = {id = 12248, count = 50}} -- 50 Revives ok

Pass.items[9] = {}
Pass.items[9][PassVip] = {image = "", name = "", desc = "", item = {id = 35548, count = 5}} -- 5 uvas ok
Pass.items[9][PassPremium] = {image = "", name = "", desc = "", item = {id = 35574, count = 1}} -- Stats box ( pedras de status ) ok

Pass.items[10] = {}
Pass.items[10][PassVip] = NoneItem
Pass.items[10][PassPremium] = {image = "", name = "", desc = "", item = {id = 34988, count = 1}} -- Gyarados Locker ok

Pass.items[11] = {}
Pass.items[11][PassVip] = {image = "", name = "", desc = "", item = {id = 29125, count = 1}} -- common seal box ok
Pass.items[11][PassPremium] = {image = "", name = "", desc = "", item = {id = 29126, count = 1}} -- rare seal box ok

Pass.items[12] = {}
Pass.items[12][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[12][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[13] = {}
Pass.items[13][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[13][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[14] = {}
Pass.items[14][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[14][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[15] = {}
Pass.items[15][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[15][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[16] = {}
Pass.items[16][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[16][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[17] = {}
Pass.items[17][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[17][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[18] = {}
Pass.items[18][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[18][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[19] = {}
Pass.items[19][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[19][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[20] = {}
Pass.items[20][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[20][PassPremium] = {image = "", name = "", desc = "", premiumPoints = 5}

Pass.items[21] = {}
Pass.items[21][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[21][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[22] = {}
Pass.items[22][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[22][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[23] = {}
Pass.items[23][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[23][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[24] = {}
Pass.items[24][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[24][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[25] = {}
Pass.items[25][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[25][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[26] = {}
Pass.items[26][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[26][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[27] = {}
Pass.items[27][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[27][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[28] = {}
Pass.items[28][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[28][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[29] = {}
Pass.items[29][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[29][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[30] = {}
Pass.items[30][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[30][PassPremium] = {image = "", name = "", desc = "", premiumPoints = 5}

Pass.items[31] = {}
Pass.items[31][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[31][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[32] = {}
Pass.items[32][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[32][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[33] = {}
Pass.items[33][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[33][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[34] = {}
Pass.items[34][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[34][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[35] = {}
Pass.items[35][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[35][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[36] = {}
Pass.items[36][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[36][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[37] = {}
Pass.items[37][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[37][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[38] = {}
Pass.items[38][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[38][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[39] = {}
Pass.items[39][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[39][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[40] = {}
Pass.items[40][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[40][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[41] = {}
Pass.items[41][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[41][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[42] = {}
Pass.items[42][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[42][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[43] = {}
Pass.items[43][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[43][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[44] = {}
Pass.items[44][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[44][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[45] = {}
Pass.items[45][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[45][PassPremium] = {image = "", name = "", desc = "", premiumPoints = 5}

Pass.items[46] = {}
Pass.items[46][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[46][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[46] = {}
Pass.items[46][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[46][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[47] = {}
Pass.items[47][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[47][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[48] = {}
Pass.items[48][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[48][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[49] = {}
Pass.items[49][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[49][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

Pass.items[50] = {}
Pass.items[50][PassVip] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}
Pass.items[50][PassPremium] = {image = "", name = "", desc = "", item = {id = 2160, count = 4}}

for level, reward in ipairs(Pass.items) do
  for v=PassFirst, PassPremium do
    if reward[v].skin then
	  reward[v].style = "UIPassSkin"
	elseif reward[v].item then
	  reward[v].style = "UIPassItem"
      reward[v].item.clientId = getItemInfo(reward[v].item.id).clientId
	elseif reward[v].premiumPoints then
	  reward[v].style = "UIPassPremiumPoints"
	elseif reward[v].experience then
	  reward[v].style = "UIPassExperience"
	end
  end
end

local MissionsStr = PokePassStorages.MissionsStr
Pass.missions = {}
Pass.missions[1] = {stars = 10, max = 300, desc = "Derrote 300 Gyarados", image = "gyarados"}
Pass.missions[2] = {stars = 5, max = 35, desc = "Capture 35 Magikarps", image = "magikarp"}
Pass.missions[3] = {stars = 7, max = 10, desc = "Encontre 10 Dittos", image = "ditto"}
Pass.missions[4] = {stars = 10, max = 75, desc = "Aprimore 75 atributos de seu Pokémon", image = "stones"}
Pass.missions[5] = {stars = 6, max = 50, desc = "Venda 50 Pokémons", image = "sell_poke"}
Pass.missions[6] = {stars = 8, max = 300, desc = "Pesque 300 Magikarps", image = "pesque"}
Pass.missions[7] = {stars = 4, max = 30, desc = "Derrote o GM", image = "charizard"}
Pass.missions[8] = {stars = 4, max = 30, desc = "Derrote o Tutor", image = "charizard"}
Pass.missions[9] = {stars = 4, max = 30, desc = "Derrote o Player", image = "charizard"}
Pass.missions[10] = {stars = 2, max = 30, desc = "Derrote o Npc", image = "charizard"}
Pass.missions[11] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[12] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[13] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[14] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[15] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[16] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[17] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[18] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[19] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[20] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[21] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[22] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[23] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[24] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[25] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[26] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}
Pass.missions[27] = {stars = 1, max = 30, desc = "Derrote o Rockets", image = "charizard"}

-- for v=5, 50 do
 -- Pass.items[v] = Pass.items[1]
-- end

function sendPassInfo(cid)
-- for s=PokePassStorages.PassVip1, PokePassStorages.MissionsStr do
  -- setPlayerStorageValue(cid, s, -1)
-- end 
  local tempo = getPassTimer()

  local protocol = Protocol_create('Pass')
  Protocol_add(protocol, hasPassPremium(cid))
  Protocol_add(protocol, getPassLevel(cid))
  Protocol_add(protocol, #Pass.items)
  Protocol_add(protocol, getPassStars(cid))
  Protocol_add(protocol, getPassDaysLeft())
  Protocol_add(protocol, tempo)
  -- doSendPlayerExtendedOpcode(cid, Pass.opcode, json.encode(protocol))
  doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
end

function sendPass(cid)
  sendPassInfo(cid)
  local items = {}
  local first = true
  local collecteds = {
    [PassVip] = {},
    [PassPremium] = {},
  }
  for level, reward in ipairs(Pass.items) do
    items[#items+1] = {}
    for passType=PassFirst, PassPremium do
      items[#items][passType] = reward[passType]
      items[#items][passType].collected = hasCollected(cid, level, passType)
	  if hasCollected(cid, level, passType) then
	    table.insert(collecteds[passType], level)
	  end
	  -- print("Lv: "..level.." type: "..passType.." / "..(hasCollected(cid, level, passType) and 1 or 0))
	end
    items[#items][PassPremium+1] = level
	if level % 20 == 0 then
	  sendPassItems(cid, first, items, collecteds)
	  items = {}
	  first = false
	end
  end
  sendPassItems(cid, first, items, collecteds)
  sendPassMissions(cid)
end

function sendPassItems(cid, first, items, collecteds)
  if #items == 0 then return end
  local protocol = Protocol_create('Items')
  Protocol_add(protocol, first)
  Protocol_add(protocol, items)
  Protocol_add(protocol, collecteds)
  -- doSendPlayerExtendedOpcode(cid, Pass.opcode, json.encode(protocol))
  doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
end

function sendPassMissions(cid)
  local missions = {}
  local first = true
  for num, mission in ipairs(Pass.missions) do
    missions[#missions+1] = mission
	missions[#missions].progress = math.max(0, getPlayerStorageValue(cid, MissionsStr+num))
	if num % 20 == 0 then
      local protocol = Protocol_create('Missions')
      Protocol_add(protocol, first)
      Protocol_add(protocol, missions)
      doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
	  missions = {}
	  first = false
	end
  end
  if #Pass.missions % 20 == 0 then return end
  local protocol = Protocol_create('Missions')
  Protocol_add(protocol, first)
  Protocol_add(protocol, missions)
  doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
  -- doSendPlayerExtendedOpcode(cid, Pass.opcode, json.encode(protocol))
end

function hasPassPremium(cid)
  local strg = getPlayerStorageValue(cid, PassPremiumStorage)
  return strg == -1 and false or (strg == 1 and true or false)
end

function checkPassVersion(cid)
  if math.max(1, getPlayerStorageValue(cid, Pass.PassVersion)) == Pass.version then return end
  setPlayerStorageValue(cid, Pass.PassVersion, Pass.version)
  setPlayerStorageValue(cid, PassLevelStorage, 0)
  setPlayerStorageValue(cid, PassStarsStorage, 0)
  for passType = PassFirst, PassPremium do
    setPlayerStorageValue(cid, Pass.strgs[passType].first, -1)
    setPlayerStorageValue(cid, Pass.strgs[passType].second, -1)
  end
end

function getPassLevel(cid)
  return math.max(0, getPlayerStorageValue(cid, PassLevelStorage))
end

function getPassStars(cid)
  return math.max(0, getPlayerStorageValue(cid, PassStarsStorage))
end

function getPassTimer()
  local hometimerH = os.date("%H") * 60 * 60
  local hometimerM = os.date("%M") * 60
  local hometimerS = os.date("%S")
  local hometimer = hometimerH + hometimerM + hometimerS
 
  return 86400-hometimer
end

function getPassDaysLeft()
  local cdt = os.date('*t')
  local currentDateValue = os.time{year=cdt.year, month=cdt.month, day=cdt.day, hour=cdt.hour}
  local endDateValue = os.time{year=Pass.endDate.year, month=Pass.endDate.month, day=Pass.endDate.day, hour=Pass.endDate.hour}
  if currentDateValue >= endDateValue then return 0 end
  return math.floor(convertOsTime(endDateValue-currentDateValue).hours / 24)
end

function updatePassMission(cid, num, progress)
  local mission = Pass.missions[num]
  if not mission then return end
  local current = math.max(0, getPlayerStorageValue(cid, MissionsStr+num))
  if current >= mission.max then return end
  current = current + progress
  setPlayerStorageValue(cid, MissionsStr+num, current)
  if current >= mission.max then
    addPassStars(cid, mission.stars)
  else
    sendPassMissions(cid)
  end
end

function addPassStars(cid, stars)
  checkPassVersion(cid)
  local cdt = os.date('*t')
  if os.time{year=cdt.year, month=cdt.month, day=cdt.day, hour=cdt.hour} > os.time{year=Pass.endDate.year, month=Pass.endDate.month, day=Pass.endDate.day, hour=Pass.endDate.hour} then print("Notime") return false end
  local passLevel = getPassLevel(cid)
  local oldLevel = passLevel
  if passLevel >= #Pass.items then
    -- print("Nivel maximo já alcançado")
	return false
  end
  -- print("PassLevel: "..passLevel.." star: "..stars.." current: "..getPassStars(cid))
  local currentStars = getPassStars(cid)+stars
  while (currentStars >= 10) do
	currentStars = currentStars - 10
    passLevel = passLevel+1
  end
  if passLevel >= #Pass.items then
    currentStars = 10
	passLevel = #Pass.items
	-- print("Máximizou o passe")
	sendPass(cid)
  end
  -- print("SET PassLevel: "..passLevel.." star: "..stars.." current: "..getPassStars(cid))
  setPlayerStorageValue(cid, PassLevelStorage, passLevel)
  setPlayerStorageValue(cid, PassStarsStorage, currentStars)
  if oldLevel < passLevel then
    sendPassInfo(cid)
    sendPassMissions(cid)
  else
    sendPass(cid)
  end
  return true
end

function hasCollected(cid, level, passType)
  local hc = getPlayerStorageValue(cid, level <= 50 and Pass.strgs[passType].first or Pass.strgs[passType].second)
  if hc == -1 then return false end
  -- print(hc)
  return isInArray(json.decode(hc), level)
end

function buyPassLevel(cid) -- ADD LVL TO PASS

if getPlayerItemCount(cid, 34524) >= 3 then
  if not addPassStars(cid, 10) then return end
  doSendMagicEffect(getCreaturePosition(cid), 1145)
  sendPass(cid)
  doPlayerRemoveItem(cid, 34524, 3)
elseif getPlayerItemCount(cid, 34524) < 3 then
  local protocol = Protocol_create('NoDiamonds')
  doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
  return
end

end

function buyPass35(cid)
if hasPassPremium(cid) then return end
if getPlayerItemCount(cid, 34524) >= 35 then
   setPlayerStorageValue(cid, PassPremiumStorage, 1) -- adiciona o pass

   local sps = getThingPosWithDebug(cid)
   sps.x = sps.x+1
   sps.y = sps.y+1
   doSendMagicEffect(sps, 896)
   doSendMagicEffect(getCreaturePosition(cid), 1144)

   doPlayerRemoveItem(cid, 34524, 35)

   local protocol = Protocol_create('Pass35Buyed')
   doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
   sendPass(cid)
elseif getPlayerItemCount(cid, 34524) < 35 then
   local protocol = Protocol_create('NoDiamondsBuyPass')
   doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
   sendPass(cid)
		return
	end
end

function buyPass50(cid)
if hasPassPremium(cid) then return end
if getPlayerItemCount(cid, 34524) >= 50 then
   local PokeCoin = getPlayerStorageValue(cid, 414141)
   setPlayerStorageValue(cid, PassPremiumStorage, 1) -- adiciona o pass
   if not addPassStars(cid, 50) then return end -- adicionar 5 leveis
   setPlayerStorageValue(cid, 414141, PokeCoin+20)  -- adicionar 20 PokeCoins

   local sps = getThingPosWithDebug(cid)
   sps.x = sps.x+1
   sps.y = sps.y+1
   doSendMagicEffect(sps, 896)
   doSendMagicEffect(getCreaturePosition(cid), 1144)

   doPlayerRemoveItem(cid, 34524, 50)

   local protocol = Protocol_create('Pass50Buyed')
   doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
   sendPass(cid)
elseif getPlayerItemCount(cid, 34524) < 50 then
   local protocol = Protocol_create('NoDiamondsBuyPass')
   doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
   sendPass(cid)
		return
	end
end

function collectPassReward(cid, level, passType)
  if level <= 0 or level > #Pass.items then return end
  if passType < PassFirst or passType > PassPremium then return end
  checkPassVersion(cid)
  if level > getPassLevel(cid) then return end
  local reward = Pass.items[level]
  if not reward then return end
  if passType == PassVip then
    if not isPremium(cid) then
	  local protocol = Protocol_create('NoVipCollect')
      doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
	  return
	end
    if not hasCollected(cid, level, PassVip) then
      addPassReward(cid, level, passType, reward[PassVip])
    end
  elseif passType == PassPremium then
    if not hasPassPremium(cid) then
	  local protocol = Protocol_create('NoPass')
      doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
	  return
	end
    if not hasCollected(cid, level, PassPremium) then
      addPassReward(cid, level, passType, reward[PassPremium])
    end
  end
end

function addPassReward(cid, level, passType, reward)
  local message = ""
  if reward.item then
    doPlayerAddItem(cid, reward.item.id, reward.item.count)
	message = message.."Você ganhou "..reward.item.count.."x"..getItemNameById(reward.item.id)
  elseif reward.experience then
    doPlayerAddExperience(cid, reward.experience)
	message = message.."Você ganhou "..reward.experience.."pontos de experiência"
  elseif reward.skin then
    setPlayerStorageValue(cid, reward.skin.strg, 1)
	message = message.."Você ganhou a roupa "..reward.skin.name
  elseif reward.premiumPoints then
    -- doPlayerAddVipPoints(cid, reward.premiumPoints)
       doPlayerAddPremiumDays(cid, reward.premiumPoints)
	-- VERIFIQUE QUAL SUA FUNÇÃO DE ADD PONTOS DE VIP, CASO FOR USAR NO PASSE
	message = message.."Você ganhou "..reward.premiumPoints.." dias de premium"
  end
  local hc = getPlayerStorageValue(cid, level <= 50 and Pass.strgs[passType].first or Pass.strgs[passType].second)
  if hc == -1 then hc = {} else hc = json.decode(hc) end
  table.insert(hc, level)
  setPlayerStorageValue(cid, level <= 50 and Pass.strgs[passType].first or Pass.strgs[passType].second, json.encode(hc))
  doPlayerSendTextMessage(cid, 19, message)
  local protocol = Protocol_create('UpdateReward')
  Protocol_add(protocol, level)
  Protocol_add(protocol, passType)
  doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
end