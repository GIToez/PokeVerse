json = require('data/lib/json')

local market_items = {}
local OFFERUNDERCONSTRUCTION = 0
local OFFERPOSTED = 1
local OFFERDECLINED = 2
local OFFERACCEPTED = 3

local pokeballs = {12159,12160,12158,12163,12161,12162,12167,12168,12166,12171,12172,12170,12175,12176,12174,12179,12180,12178,12183,12184,12182,12187,12188,12186,13494,13495,13493,14389,14390,14391,14392,14393,14394,14395,14396,14397,14398,14399,14400,14401,14402,14403,14404,14405,14406,14407,14408,14409,14410,14411,14412,14443,14444,14445,14446,14447,14448,14451,14452,14453,14454,14455,14456,18130,18131,18129,18630,18631,18629,18725,18726,18727,18728,18729,18730,18731,18732,18733,18852,18853,18854,18855,18856,18857,18858,18859,18860,18861,18862,18863,18864,18865,18866,18886,18887,18888,18889,18890,18891,18892,18893,18894,18899,18900,18901,18902,18903,18904,18905,18906,18907,18933,18934,18935,18936,18937,18938,18939,18940,18941,19027,19028,19030,19031,19032,19034,19035,19036,19038,19039,19040,19042,19043,19044,19046,19047,19048,19050,19051,19052,19054,19055,19056,19058,19059,19060,19063,19074,19075,19076,19077,19078,19079,19080,19081,19082,24554,24555,24556,24557,24558,24559,24560,24561,24562,24566,24567,24569,24592,24593,24594,24595,24596,24597,24598,24599,24600,24601,24602,24603,24608,24609,24610,24611,24612,24613,24614,24615,24616,24617,24618,24619,24620,24621,24622,24623,24624,24625,24677,24678,24679,24680,24681,24682,24683,24684,24685,24686,24687,24688,24689,24690,24691,24692,24693,24694,24695,24696,24697,25161,25162,25163,25164,25165,25166,25167,25168,25169,25170,25171,25172,25173,25174,25175,25176,25177,25178,25276,25277,25279,25318,25319,25320,25321,25322,25323,25324,25325,25326,25327,25328,25329,25330,25331,25332,25333,25334,25335,25336,25337,25338,25339,25340,25341,25342,25343,25344,25345,25346,25347,25358,25359,25360,25361,25362,25363,25364,25365,25366,25367,25368,25369,25370,25371,25372,25373,25374,25375,25376,25377,25378,25379,25380,25381,25382,25383,25384,25385,25386,25387,25388,25389,25390,25391,25392,25393,27631,27632,27633,27634,27635,27636,27637,27638,27639,27640,27641,27642,27643,27644,27645,27646,27647,27648,27649,27650,27651,27652,27653,27654,27655,27656,27657,27658,27659,27660,27661,27662,27663,27664,27665,27666,27667,27668,27669,27670,27671,27672,27673,27674,27675,27676,27677,27678,27679,27680,27681,27682,27683,27684,27685,27686,27687,27688,27689,27690,27691,27692,27693,27694,27695,27696,27697,27698,27699,27700,27701,27702,27703,27704,27705,27706,27707,27708,27709,27710,27711,27712,27713,27714,27715,27716,27717,27718,27719,27720,27721,27722,27723,27724,27725,27726,27727,27728,27729,27775,27776,27777,27779,27780,27781,27783,27784,27785,27787,27788,27789,27791,27792,27793,27795,27796,27797,27799,27800,27801,27803,27804,27805,27807,27808,27809,27995,27996,27997,27999,28000,28001,28003,28004,28005,28007,28008,28009,28011,28012,28013,28015,28016,28017,28019,28020,28021,28023,28024,28025,28027,28028,28029,28031,28032,28033,28035,28036,28037,28090,28091,28092,28093,28094,28095,28096,28097,28098,28099,28100,28101,28102,28103,28104,28105,28106,28107,28108,28109,28110,28111,28112,28113,28114,28115,28116,28117,28118,28119,28120,28121,28122,28123,28124,28125,28126,28127,28128,28170,28171,28172,28174,28175,28176,28178,28179,28180,28182,28183,28184,28186,28187,28188,28190,28191,28192,28194,28195,28196,28198,28199,28200,28202,28203,28204,28206,28207,28208,28210,28211,28212,28214,28215,28216,28218,28219,28220,28222,28223,28224,28226,28227,28228,28230,28231,28232,28234,28235,28236,28238,28239,28240,28242,28243,28244,28246,28247,28248,28250,28251,28252,28254,28255,28256,28258,28259,28260,29873,29874,29875,29877,29878,29879,29881,29882,29883,29887,29888,29889,29891,29892,29893,29895,29896,29897,29899,29900,29901,29903,29904,29905,29907,29908,29909,12187,12188,12186}
local stones_items = {18083,18084,18085,18092,18091,18090,18089,18088,18087,18086,18093,18094,18096,18095,28892,28914,28893}
local pokebolas_items = {12157,12161,12165,12169,12173,12177,12181,12185,13492,18628,19029,19033,19037,19041,19045,19049,19053,19057,19061,24568,25279,25348,28070,12185}
local diamond_items = {34524,25498}
local addon_items = {}
local outfit_items = {}
local held_items = {}
local furniture_items = {}
local berry_items = {}
local plate_items = {13807,17814,18081,18082,23946}
local doll_items = {23463,25239,25240,25243,28262,28263,28264,2108,2110,3955,2322,5810,6512,6567,6579,7183,8982,8985,9019,11138,11201,11205,11250}
local food_items = {13820,14464,14470,23574,27936,29130,2673,2674,2675,2676,2677,2680,2682,2687,2688,2696,5097,6501,6569,6574,7372,7373,7374,7375,7376,7377,7966,8841,13305}
local utilities_items = {29769,29770,29771,29772,24209}
local suplies_items = {}

local block_items = {}

function isBlockItem(itemId) return isInArray(block_items, itemId) end
function isPokeball(itemId) return isInArray(pokeballs, itemId) end
function isStones(itemId) return isInArray(stones_items, itemId) end
function isPokebolas(itemId) return isInArray(pokebolas_items, itemId) end
function isDiamonds(itemId) return isInArray(diamond_items, itemId) end
function isAddons(itemId) return isInArray(addon_items, itemId) end
function isOutfits(itemId) return isInArray(outfit_items, itemId) end
function isHelds(itemId) return isInArray(held_items, itemId) end
function isFurnitures(itemId) return isInArray(furniture_items, itemId) end
function isBerrys(itemId) return isInArray(berry_items, itemId) end
function isPlates(itemId) return isInArray(plate_items, itemId) end
function isDolls(itemId) return isInArray(doll_items, itemId) end
function isFoods(itemId) return isInArray(food_items, itemId) end
function isUtilities(itemId) return isInArray(utilities_items, itemId) end
function isSuplies(itemId) return isInArray(suplies_items, itemId) end

function getMarketItemName(itemId, uid)
  if isPokeball(itemId) and getItemAttribute(uid, ballsAttributes.pokemonName) then
    return getItemAttribute(uid, ballsAttributes.pokemonName)
  end
  return getItemInfo(itemId).name
end

function getMarketPokeInfo(itemId, uid)
  local info = {name = getItemInfo(itemId).name, sex = 0, level = 0}
  if isPokeball(itemId) and getItemAttribute(uid, ballsAttributes.pokemonName) then
    info.name = getItemAttribute(uid, ballsAttributes.pokemonName)
    info.sex = getItemAttribute(uid, ballsAttributes.sex)
    info.level = getItemAttribute(uid, ballsAttributes.pokemonLevel)
  end
  return info
end

function getPokeMarketDescription(itemId, uid, pokemonFRIENDSHIP, pokemonFRIENDSHIPLUCK, pokemonSex, pokemonName, pokemonNickname, pokemonLevel)
  local description = ""
  if isPokeball(itemId) and getItemAttribute(uid, ballsAttributes.pokemonName) then
  
    description = description..getItemAttribute(uid, ballsAttributes.pokemonName).." (Level "..getItemAttribute(uid, ballsAttributes.pokemonLevel)..") ".."[+"..getItemAttribute(uid, ballsAttributes.extraPoints).."]"
    description = description.."\nSex: "..getSexDescription(getItemAttribute(uid, ballsAttributes.sex))
    description = description.."\nIVs - EVs"

    description = description.."\nHp: "..getItemAttribute(uid, ballsAttributes.ivhp)
	if getItemAttribute(uid, ballsAttributes.evhp) then 
	    description = description.." (+"..getItemAttribute(uid, ballsAttributes.evhp)..")"
	else
	    description = description.." (+0)"
	end
    description = description.."\nAtk: "..getItemAttribute(uid, ballsAttributes.ivatq)
	if getItemAttribute(uid, ballsAttributes.evatq) then 
	    description = description.." (+"..getItemAttribute(uid, ballsAttributes.evatq)..")"
	else
	    description = description.." (+0)"
	end
    description = description.."\nDef: "..getItemAttribute(uid, ballsAttributes.ivdef)
	if getItemAttribute(uid, ballsAttributes.evdef) then 
	    description = description.." (+"..getItemAttribute(uid, ballsAttributes.evdef)..")"
	else
	    description = description.." (+0)"
	end
    description = description.."\nSp.Atk: "..getItemAttribute(uid, ballsAttributes.ivspatq)
	if getItemAttribute(uid, ballsAttributes.evspatq) then 
	    description = description.." (+"..getItemAttribute(uid, ballsAttributes.evspatq)..")"
	else
	    description = description.." (+0)"
	end
    description = description.."\nSp.Def: "..getItemAttribute(uid, ballsAttributes.ivspdef)
	if getItemAttribute(uid, ballsAttributes.evspdef) then 
	    description = description.." (+"..getItemAttribute(uid, ballsAttributes.evspdef)..")"
	else
	    description = description.." (+0)"
	end
    description = description.."\nSpeed: "..getItemAttribute(uid, ballsAttributes.ivspd)
	
	if getItemAttribute(uid, ballsAttributes.evspd) then 
	    description = description.." (+"..getItemAttribute(uid, ballsAttributes.evspd)..")"
	else
	    description = description.." (+0)"
	end	

	if getItemAttribute(uid, ballsAttributes.friendshipLevel) == nil then 
	    description = description.."\nFriendship: Lv.1 Bônus: 0.1%"
	else
	    description = description.."\nFriendship: Lv."..getItemAttribute(uid, ballsAttributes.friendshipLevel).." Bônus: "..tostring(getItemAttribute(uid, ballsAttributes.friendshipLootLucky)):sub(1,3).."%"
	end
	
	local IVTotal = getItemAttribute(uid, ballsAttributes.ivhp) + getItemAttribute(uid, ballsAttributes.ivatq) + getItemAttribute(uid, ballsAttributes.ivdef) + getItemAttribute(uid, ballsAttributes.ivspatq) + getItemAttribute(uid, ballsAttributes.ivspdef) + getItemAttribute(uid, ballsAttributes.ivspd)
	description = description.."\nPerfection: "..tostring(IVTotal * 100 / 186):sub(1,6).."%"

	local naturesMarket = {
	  ["1"] = {desc = "Adamant", Increase = "Attack", Decrease = "Sp.Atk"},
	  ["2"] = {desc = "Bashful", Increase = "Sp.Atk", Decrease = "Sp.Atk"},
	  ["3"] = {desc = "Bold", Increase = "Defense", Decrease = "Attack"},
	  ["4"] = {desc = "Brave", Increase = "Attack", Decrease = "Speed"},
	  ["5"] = {desc = "Calm", Increase = "Sp.Def", Decrease = "Attack"},
	  ["6"] = {desc = "Careful", Increase = "Sp.Def", Decrease = "Sp.Atk"},
	  ["7"] = {desc = "Docile", Increase = "Defense", Decrease = "Defense"},
	  ["8"] = {desc = "Gentle", Increase = "Sp.Def", Decrease = "Defense"},
	  ["9"] = {desc = "Hardy", Increase = "Attack", Decrease = "Attack"},
	  ["10"] = {desc = "Hasty", Increase = "Speed", Decrease = "Defense"},
	  ["11"] = {desc = "Impish", Increase = "Defense", Decrease = "Sp.Atk"},
	  ["12"] = {desc = "Jolly", Increase = "Speed", Decrease = "Sp.Atk"},
	  ["13"] = {desc = "Lax", Increase = "Defense", Decrease = "Sp.Def"},
	  ["14"] = {desc = "Lonely", Increase = "Attack", Decrease = "Defense"},
	  ["15"] = {desc = "Mild", Increase = "Sp.Atk", Decrease = "Defense"},
	  ["16"] = {desc = "Modest", Increase = "Sp.Atk", Decrease = "Attack"},
	  ["17"] = {desc = "Naive", Increase = "Speed", Decrease = "Sp.Def"},
	  ["18"] = {desc = "Naughty", Increase = "Attack", Decrease = "Sp.Def"},
	  ["19"] = {desc = "Quiet", Increase = "Sp.Atk", Decrease = "Speed"},
	  ["20"] = {desc = "Quirky", Increase = "Sp.Def", Decrease = "Sp.Def"},
	  ["21"] = {desc = "Rash", Increase = "Sp.Atk", Decrease = "Sp.Def"},
	  ["22"] = {desc = "Relaxed", Increase = "Defense", Decrease = "Speed"},
	  ["23"] = {desc = "Sassy", Increase = "Sp.Def", Decrease = "Speed"},
	  ["24"] = {desc = "Serious", Increase = "Speed", Decrease = "Speed"},
	  ["25"] = {desc = "Timid", Increase = "Speed", Decrease = "Attack"},
	}
	local NatureNumber = tostring(getItemAttribute(uid, ballsAttributes.nature))
	-- print(NatureNumber)
	if getItemAttribute(uid, ballsAttributes.nature)  == nil then 
		description = description.."\nNature: none"
	else
		description = description.."\nNature: "..naturesMarket[NatureNumber].desc.."( +"..naturesMarket[NatureNumber].Increase.." -"..naturesMarket[NatureNumber].Decrease.." )"
	end

    if (getBallPokemonSpecialAbility(uid) ~= POKEMON_SPECIAL_ABILITY_IDS.NONE) then
        description = description.."\nSpecial Ability: "..getPokemonSpecialAbilityName(getBallPokemonSpecialAbility(uid)).."."
    end
	
    if (getBallTm(uid, 1) ~= TM_IDS.NONE) then
        local defaultMoves = getPokemonDefaultSkills(getItemAttribute(uid, ballsAttributes.pokemonName))
		description = description.."\nTM-1: Replaced "..defaultMoves[getBallTmSlot(uid, 1)].." by "..getTmMove(getBallTm(uid, 1)).."."
    end
    if (getBallTm(uid, 2) ~= TM_IDS.NONE) then
        local defaultMoves = defaultMoves and defaultMoves or getPokemonDefaultSkills(getItemAttribute(uid, ballsAttributes.pokemonName))
		description = description.."\nTM-2: Replaced "..defaultMoves[getBallTmSlot(uid, 2)].." by "..getTmMove(getBallTm(uid, 2)).."."
    end

    if (getBallSeal(uid) ~= BALL_SEAL_IDS.NONE) then
       description = description.."\nSeal: "..getItemNameById(getBallSealItemid(getBallSeal(uid))).."."
    end

    if (getBallHeld(uid)) then
        description = description.."\nHeld Item: "..PokemonHeldItem.getHeldName(getBallHeld(uid), uid).." Lv."..getItemAttribute(uid, ballsAttributes.heldLevel)
    end

  else
    description = getItemInfo(itemId).description
  end
    return description
  end

MARKET_LOG_FILE = "market.log"
MARKET_MAX_PRICE = 99999999
MARKET_MAX_COUNT = 100000

function isMarketCode(code)
  return type(code) == "string" and code:match("^Mkt%d+$") ~= nil
end

function isMarketInteger(value, min, max)
  return type(value) == "number" and value == math.floor(value) and value >= min and value <= max
end

function marketLog(cid, action, detail)
  doWriteLogFile((LOGS_DIR or "logs/") .. MARKET_LOG_FILE, string.format("%s (guid %d) %s %s", getCreatureName(cid), getPlayerGUID(cid), action, detail))
end

function nearOnMarket(cid)
  local lastMarketPosition = getPlayerStorageValue(cid, playersStorages.marketPos)
  local pos = {x = 0,y = 0,z = 0,stackpos = 0}
  local explode = string.explode(lastMarketPosition, ',')
  for s=1, #explode do
    if string.find(explode[s], 'X:') then
	  pos.x = tonumber(string.explode(explode[s], 'X:')[1])
	end
    if string.find(explode[s], 'Y:') then
	  pos.y = tonumber(string.explode(explode[s], 'Y:')[1])
	end
    if string.find(explode[s], 'Z:') then
	  pos.z = tonumber(string.explode(explode[s], 'Z:')[1])
	end
    if string.find(explode[s], 'S:') then
	  pos.stackpos = tonumber(string.explode(explode[s], 'S:')[1])
	end
  end
  -- print("getDistanceBetween: "..getDistanceBetween(getCreaturePosition(cid), pos))
  if getDistanceBetween(getCreaturePosition(cid), pos) > 5 then return false end
  return true
end

function sendMarketClose(cid)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(Protocol_create('close')))
end

function refreshMarketOnClient(cid)
  doRefreshMarketItems()
  sendMarketBuyItems(cid, "Todos", 1, 0)
  sendMarketSellItems(cid)
  sendMarketOffers(cid)
  sendMarketHistoric(cid)
end

function doRefreshMarketItems()
  local refresh = false
  for item_code, market_item in pairs(market_items) do
    if market_item.time-os.time() < 0 then
      for playeroffer_id, offers in pairs(market_item.offers) do
	    local checkHistoric = false
        for num, offer_item in ipairs(offers) do
		  if offer_item.state == OFFERUNDERCONSTRUCTION or offer_item.state == OFFERPOSTED then
            local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..item_code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
            local mysql = db.getResult(query)
            if mysql:getID() == -1 then
              print("[Market] missing offer row for " .. item_code)
              return false
            end
            local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
            doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
            doItemSetCount(offerItem, offer_item.count)
            if addItem(getPlayerNameByGUID(offer_item.playeroffer_id), offer_item.itemid, offerItem) then
              db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..item_code.."' AND `item_index` = "..offer_item.item_index.." AND `playeroffer_id` = "..offer_item.playeroffer_id)
            end
            if not checkHistoric and offer_item.state == OFFERPOSTED then 
			  setMarketHistoric(offer_item.playeroffer_id, "Your offer was declined for "..market_item.item_name..".")
			  checkHistoric = true
			end
		  end
	  	  refresh = true
        end
      end
	end
  end
  if refresh then getMarketItems() end
end

function setMarketHistoric(guid, negotiation, cid)
  negotiation = os.date('*t').day.."/"..os.date('*t').month.."/"..os.date('*t').year.." - "..negotiation
  local historic = getMarketHistoric(guid)
  historic[#historic+1] = {time = os.time(), negotiation = negotiation}
  if #historic >= 2 then table.sort(historic, function(a,b) return a.time > b.time end) end
  if historic[31] then historic[31] = nil end
  db.executeQuery("UPDATE `market_historic` set `historic` = '"..json.encode(historic).."' WHERE `player_id` = "..guid)
  if cid then sendMarketHistoric(cid) end
end

function getMarketHistoric(guid)
  local historic = {}
  local query = ("SELECT `historic` FROM `market_historic` WHERE `player_id` = "..guid)
  local mysql = db.getResult(query)
  if mysql:getID() ~= -1 then
    historic = json.decode(mysql:getDataString('historic'))
  else
    db.executeQuery("INSERT INTO `market_historic` (`player_id`, `historic`) VALUES ("..guid..", '"..json.encode(historic).."')")
  end
  if #historic >= 2 then table.sort(historic, function(a,b) return a.time < b.time end) end
  return historic
end

function sendMarketHistoric(cid)
  local protocol = Protocol_create('market_historic')
  Protocol_add(protocol, getMarketHistoric(getPlayerGUID(cid)))
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
end

function sendMarketOffers(cid)
  local myitems_withoffers, myOffers = {}, {}
  for item_code, market_item in pairs(market_items) do
    if market_item.playerseller_id == getPlayerGUID(cid) then
	  for playeroffer_id, offers in pairs(market_item.offers) do
	    if offers[1].state == OFFERPOSTED then
		  if not myitems_withoffers[item_code] then
            myitems_withoffers[item_code] = {
		      spriteId          = market_item.spriteId,
		      count             = market_item.count,
		      item_name         = market_item.item_name,
			  poke_info         = market_item.poke_info,
		      time              = market_item.time,
			  description       = market_item.description,
		      offers = {[1] = offers}
		    }
		  else
		    myitems_withoffers[item_code].offers[#myitems_withoffers[item_code].offers+1] = offers
		  end
		end
	  end
	end
	if market_item.offers[getPlayerGUID(cid)] then
	  for num, offer_item in ipairs(market_item.offers[getPlayerGUID(cid)]) do
        if offer_item.state == OFFERPOSTED and offer_item.state <= OFFERACCEPTED then
		  if not myOffers[item_code] then
            myOffers[item_code] = {
		      spriteId          = market_item.spriteId,
			  count             = market_item.count,
		      item_name         = market_item.item_name,
		      poke_info         = market_item.poke_info,
		      playerseller_name = market_item.playerseller_name,
			  description       = market_item.description,
		      offers            = market_item.offers[getPlayerGUID(cid)]
		    }
		  else
		    myOffers[item_code].offers = market_item.offers[getPlayerGUID(cid)]
		  end
        end
	  end
	end
  end
  local count = 1
  local first = true
  local new_myitems_withoffers, new_myOffers = {}, {}
  for item_code, market_item in pairs(myitems_withoffers) do
    new_myitems_withoffers[item_code] = market_item
    if count == 5 then
      local protocol = Protocol_create("market_myitems_withoffers")
      Protocol_add(protocol, first)
      Protocol_add(protocol, new_myitems_withoffers)
      doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
	  first = false
	  count = 1
	  new_myitems_withoffers = {}
	end
	count = count+1
  end
  local protocol = Protocol_create("market_myitems_withoffers")
  Protocol_add(protocol, first)
  Protocol_add(protocol, new_myitems_withoffers)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
  count = 1
  first = true
  for item_code, market_item in pairs(myOffers) do
    new_myOffers[item_code] = market_item
    if count == 5 then
      local protocol = Protocol_create("market_myOffers")
      Protocol_add(protocol, first)
      Protocol_add(protocol, new_myOffers)
      doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
	  first = false
	  count = 1
	  new_myOffers = {}
	end
	count = count+1
  end
  local protocol = Protocol_create("market_myOffers")
  Protocol_add(protocol, first)
  Protocol_add(protocol, new_myOffers)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
end

function sendMarketSellItems(cid)
  local send_market_items = {}
  for item_code, market_item in pairs(market_items) do
    if getPlayerGUID(cid) == market_item.playerseller_id then
	  send_market_items[#send_market_items+1] = market_item
	end
  end
  if #send_market_items == 0 then
	local protocol = Protocol_create("marketsellitems")
	Protocol_add(protocol, true)
	Protocol_add(protocol, {})
	doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
	return true
  end 
  local count = 1
  local first = true
  local new_send_market_items = {}
  for i=1, #send_market_items, 1 do
    new_send_market_items[i] = send_market_items[i]
    if count == 5 or i == #send_market_items then
      local protocol = Protocol_create("marketsellitems")
      Protocol_add(protocol, first)
      Protocol_add(protocol, new_send_market_items)
      doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
	  first = false
	  count = 1
	  new_send_market_items = {}
	end
	count = count+1
  end
end

function sendMarketOffersByItemCode(cid, code)
  local send_offers = {}
  if market_items[code] then
    for playeroffer_id, offers in pairs(market_items[code].offers) do
      for num, offer_item in ipairs(offers) do
        if offer_item.state == OFFERPOSTED then
          send_offers[#send_offers+1] = offer_item
        end
      end
    end
  end
  local protocol = Protocol_create("marketbuyitemsoffers")
  Protocol_add(protocol, send_offers)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
end

function sendMarketBuyItems(cid, category, page, focus, order, searchstring)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  if not order then order = "timeasc" end
  page = math.max(1, math.floor(tonumber(page) or 1))
  local send_market_items = {}
  local qnt_per_page = 15
  for item_code, itemInfo in pairs(market_items) do
    if itemInfo.time - os.time() > 0 then
      if (category == "Todos" or getItemCategory(itemInfo.itemid) == category) then
        if not searchstring or (string.find(string.lower(itemInfo.item_name), string.lower(searchstring), 1, true) or string.find(string.lower(itemInfo.playerseller_name), string.lower(searchstring), 1, true)) then
          local market_item = {
            item_code         = itemInfo.item_code,
            playerseller_name = itemInfo.playerseller_name,
            onlyoffer         = itemInfo.onlyoffer,
            itemid            = itemInfo.itemid,
            spriteId          = itemInfo.spriteId,
            count             = itemInfo.count,
            price             = itemInfo.price,
            time              = itemInfo.time,
      	    item_name         = itemInfo.item_name,
      	    poke_info         = itemInfo.poke_info,
			description       = itemInfo.description,
          }
      	  send_market_items[#send_market_items+1] = market_item
        end
      end
	end
  end
  local maxPage = math.ceil(#send_market_items / qnt_per_page)
  if string.find(order, 'itemdesc') then 
    table.sort(send_market_items, function(a,b) return a.item_name < b.item_name end)
  elseif string.find(order, 'itemasc') then
    table.sort(send_market_items, function(a,b) return a.item_name > b.item_name end)
  elseif string.find(order, 'sellerdesc') then
    table.sort(send_market_items, function(a,b) return a.playerseller_name < b.playerseller_name end)
  elseif string.find(order, 'sellerasc') then
    table.sort(send_market_items, function(a,b) return a.playerseller_name > b.playerseller_name end)
  elseif string.find(order, 'amountdesc') then
    table.sort(send_market_items, function(a,b) return a.count < b.count end)
  elseif string.find(order, 'amountasc') then
    table.sort(send_market_items, function(a,b) return a.count > b.count end)
  elseif string.find(order, 'pricedesc') then
    table.sort(send_market_items, function(a,b) return a.price < b.price end)
  elseif string.find(order, 'priceasc') then
    table.sort(send_market_items, function(a,b) return a.price > b.price end)
  end
  local max_send = 0
  local resend_page = page
  if page > 1 then
    if #send_market_items < page*qnt_per_page then
	  max_send = page*qnt_per_page - (page*qnt_per_page - #send_market_items)
	else
	  max_send = page*qnt_per_page
	end
	page = (page-1)*qnt_per_page+1
  else
    if #send_market_items < qnt_per_page then
      max_send = #send_market_items
    else
	  max_send = qnt_per_page
    end	
  end
  local new_send_market_items = {}
  for _=page, max_send, 1 do
    new_send_market_items[#new_send_market_items+1] = send_market_items[_]
  end
  local protocol = Protocol_create("marketbuyitems")
  Protocol_add(protocol, category)
  Protocol_add(protocol, resend_page)
  Protocol_add(protocol, maxPage)
  Protocol_add(protocol, focus)
  Protocol_add(protocol, searchstring or '')
  Protocol_add(protocol, new_send_market_items)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
end

function checkMarketCanSellItem(cid, container_index, slot_index)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  local item = {itemid = 0}
  if container_index >= CONST_SLOT_FIRST and container_index <= CONST_SLOT_LAST then
    item = getPlayerSlotItem(cid, container_index) or item
  elseif container_index >= 64 and container_index <= 80 then
    item = getContainerItemByIndex(cid, container_index - 64, slot_index) or item
  end
  if item.itemid == 0 then
    return doPlayerPopupFYI(cid, __L(cid, "Item not found."))
  elseif isBlockItem(item.itemid) then -- block item
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  elseif isContainer(item.uid) and getContainerSize(item.uid) > 0 then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  elseif getItemInfo(item.itemid).worth > 0 then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  elseif not getItemInfo(item.itemid).movable then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  end
  local itemInfo = {item_code = "", itemid = item.itemid, count = item.type, spriteId = getItemInfo(item.itemid).clientId}
  if not isItemStackable(item.itemid) then
    itemInfo.item_code = generateCode()
    doItemSetAttribute(item.uid, playersStorages.marketBase, itemInfo.item_code)
  end
  itemInfo.description = getPokeMarketDescription(item.itemid, item.uid)
  itemInfo.poke_info = getMarketPokeInfo(item.itemid, item.uid)
  local protocol = Protocol_create("marketsellitemschecked")
  Protocol_add(protocol, itemInfo)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
end

function getMarketItems()
  market_items = {}
  local query = "SELECT `market_items`.*, `players`.`name` FROM `market_items` INNER JOIN `players` ON `market_items`.`playerseller_id` = `players`.`id`"
  local mysql = db.getResult(query)
  if mysql:getID() ~= -1 then
    while(true) do
	  local market_item = {
        item_code         = mysql:getDataString('item_code'),
        playerseller_id   = mysql:getDataInt('playerseller_id'),
        playerseller_name = mysql:getDataString('name'),
        onlyoffer         = mysql:getDataInt('onlyoffer'),
        itemid            = mysql:getDataInt('itemid'),
        count             = mysql:getDataInt('count'),
        price             = mysql:getDataInt('price'),
        time              = mysql:getDataInt('time'),
      }
      local item = doCreateItemEx(market_item.itemid, market_item.count)
      doItemLoadAttributes(item, 'attributes', mysql:getID())
      doItemSetCount(item, market_item.count)
	  market_item.item_name = getMarketItemName(market_item.itemid, item)
	  market_item.poke_info = getMarketPokeInfo(market_item.itemid, item)
	  market_item.spriteId = getItemInfo(market_item.itemid).clientId
	  market_item.offers = getMarketItemOffers(market_item.item_code)
	  market_item.description = getPokeMarketDescription(market_item.itemid, item)
	  market_items[market_item.item_code] = market_item
      if not(mysql:next())then
        break
      end
    end
    mysql:free()
  end
end

function getMarketItemOffers(item_code)
  local offers = {}
  local mysql = db.getResult("SELECT * FROM `market_offers` WHERE `item_code` = '"..item_code.."'")
  if mysql:getID() ~= -1 then
    while(true) do
	  local offer_item = {
	    item_code         = mysql:getDataString('item_code'),
        itemid            = mysql:getDataInt('itemid'),
        count             = mysql:getDataInt('count'),
        item_index        = mysql:getDataInt('item_index'),
        playeroffer_id    = mysql:getDataInt('playeroffer_id'),
        playeroffer_name  = mysql:getDataString('playeroffer_name'),
        state  = mysql:getDataInt('state'),
	  }
      local item = doCreateItemEx(offer_item.itemid, offer_item.count)
      doItemLoadAttributes(item, 'attributes', mysql:getID())
      doItemSetCount(item, offer_item.count)
	  offer_item.item_name = getMarketItemName(offer_item.itemid, item)
	  offer_item.poke_info = getMarketPokeInfo(offer_item.itemid, item)
	  offer_item.spriteId = getItemInfo(offer_item.itemid).clientId
	  offer_item.description = getPokeMarketDescription(offer_item.itemid, item)
	  if not offers[offer_item.playeroffer_id] then offers[offer_item.playeroffer_id] = {} end
	  offers[offer_item.playeroffer_id][#offers[offer_item.playeroffer_id]+1] = offer_item
      if not(mysql:next())then
        break
      end
	end
	mysql:free()
  end
  return offers
end

function doMarketAcceptOffer(cid, code, playeroffer_id)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  local market_item = market_items[code]
  if not market_item then return end
  if market_item.playerseller_id ~= getPlayerGUID(cid) then
    return doPlayerPopupFYI(cid, __L(cid, "This does not belong to you."))
  end
  local offers = market_item.offers[playeroffer_id]
  if not offers then
    return doPlayerPopupFYI(cid, __L(cid, "This offer does not exist."))
  end
  local playeroffer_name
  for num, offer_item in ipairs(offers) do
    if offer_item.state == OFFERPOSTED then
      local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
      local mysql = db.getResult(query)
      if mysql:getID() == -1 then
        doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
        return false
      end
      local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
      doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
	  doItemSetCount(offerItem, offer_item.count)
      if addItem(getCreatureName(cid), offer_item.itemid, offerItem) then
		playeroffer_name = getPlayerNameByGUID(offer_item.playeroffer_id)
		offer_item.state = OFFERACCEPTED
      end
    end
  end
  if not playeroffer_name then return end
  local query = ("SELECT `attributes` FROM `market_items` WHERE `item_code` = '"..code.."' AND `playerseller_id`  = "..market_item.playerseller_id)
  local mysql = db.getResult(query)
  if mysql:getID() == -1 then
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  end
  local item = doCreateItemEx(market_item.itemid, market_item.count)
  doItemLoadAttributes(item, 'attributes', mysql:getID())
  doItemSetCount(item, market_item.count)
  if addItem(playeroffer_name, market_item.itemid, item) then
	db.executeQuery("DELETE FROM `market_items` WHERE `item_code` = '"..code.."'")
  end
  marketLog(cid, "accept", string.format("code=%s from_guid=%d", code, playeroffer_id))
  setMarketHistoric(getPlayerGUID(cid), "You accepted an offer for "..market_item.item_name..".", cid)
  setMarketHistoric(playeroffer_id, "Your offer was accepted for "..market_item.item_name..".")
  for _playeroffer_id, _offers in pairs(market_item.offers) do
    local checkHistoric = false
    for num, offer_item in ipairs(_offers) do
      if offer_item.state == OFFERPOSTED or offer_item.state == OFFERUNDERCONSTRUCTION then
        local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
        local mysql = db.getResult(query)
        if mysql:getID() == -1 then
          doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
          return false
        end
        local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
        doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
        doItemSetCount(offerItem, offer_item.count)
		if addItem(getPlayerNameByGUID(offer_item.playeroffer_id), offer_item.itemid, offerItem) then
		  db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..offer_item.item_code.."' AND `item_index` = "..offer_item.item_index.." AND `playeroffer_id` = "..offer_item.playeroffer_id)
          if not checkHistoric and offer_item.state == OFFERPOSTED then 
			setMarketHistoric(_playeroffer_id, "Your offer was declined for "..market_item.item_name..".")
		  end
		  checkHistoric = true
		end
      else
	    db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..offer_item.item_code.."' AND `item_index` = "..offer_item.item_index.." AND `playeroffer_id` = "..offer_item.playeroffer_id)
      end
	end
  end
  getMarketItems()
  refreshMarketOnClient(cid)
end

function doMarketRefuseOffer(cid, code, playeroffer_id)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  local market_item = market_items[code]
  if not market_item then return end
  if market_item.playerseller_id ~= getPlayerGUID(cid) then
    return doPlayerPopupFYI(cid, __L(cid, "This does not belong to you."))
  end
  local offers = market_item.offers[playeroffer_id]
  if not offers then
    return doPlayerPopupFYI(cid, __L(cid, "This offer does not exist."))
  end
  local checkHistoric = false
  for num, offer_item in ipairs(offers) do
    if offer_item.state == OFFERPOSTED then
      local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
      local mysql = db.getResult(query)
      if mysql:getID() == -1 then
        doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
        return false
      end
      local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
      doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
	  doItemSetCount(offerItem, offer_item.count)
      if addItem(getPlayerNameByGUID(playeroffer_id), offer_item.itemid, offerItem) then
        db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..offer_item.item_code.."' AND `item_index` = "..offer_item.item_index.." AND  `playeroffer_id` = "..offer_item.playeroffer_id)
        if not checkHistoric then 
          setMarketHistoric(playeroffer_id, "Your offer was declined for "..market_item.item_name..".")
          checkHistoric = true
	    end
	  end
    end
  end
  market_item.offers = getMarketItemOffers(market_item.item_code)
  sendMarketOffers(cid)
  doPlayerSave(cid)
end

function doMarketRemoveOffer(cid, code)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  local market_item = market_items[code]
  if not market_item then return end
  local offers = market_item.offers[getPlayerGUID(cid)]
  if not offers then
    return doPlayerPopupFYI(cid, __L(cid, "This offer does not exist."))
  end
  for num, offer_item in ipairs(offers) do
    if offer_item.state == OFFERPOSTED then
      local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
      local mysql = db.getResult(query)
      if mysql:getID() == -1 then
        doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
        return false
      end
      local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
      doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
      doItemSetCount(offerItem, offer_item.count)
      if addItem(getCreatureName(cid), offer_item.itemid, offerItem) then
        db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..offer_item.item_code.."' AND `item_index` = "..offer_item.item_index.." AND  `playeroffer_id` = "..offer_item.playeroffer_id)
      end
    end
  end
  market_item.offers = getMarketItemOffers(market_item.item_code)
  sendMarketOffers(cid)
  doPlayerSave(cid)
end

function getMarketFee(price)
  return math.max(1, math.floor(price / 1000))
end

function doMarketSellItem(cid, code, itemId, count, onlyoffer, price)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  if not isMarketInteger(itemId, 1, 0xFFFF) then return doPlayerPopupFYI(cid, __L(cid, "Item not found.")) end
  if not isMarketInteger(price, 0, MARKET_MAX_PRICE) then return doPlayerPopupFYI(cid, __L(cid, "Invalid price.")) end
  if onlyoffer ~= 1 then onlyoffer = 0 end
  local stackable = isItemStackable(itemId)
  if not isMarketInteger(count, 1, stackable and MARKET_MAX_COUNT or 1) then
    return doPlayerPopupFYI(cid, __L(cid, "You do not have that many items."))
  end
  local item
  if stackable then
    code = generateCode()
    item = getPlayerItemByIdInMarket(cid, itemId)
  elseif isMarketCode(code) then
    item = getPlayerItemByCode(cid, code)
  end
  if not item or item.itemid ~= itemId then return doPlayerPopupFYI(cid, __L(cid, "Item not found.")) end
  if market_items[code] then return doPlayerPopupFYI(cid, __L(cid, "This item is already listed.")) end
  if isItemUnique(item.uid, cid) then return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this unique item.")) end
  if isBlockItem(item.itemid) then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  elseif isContainer(item.uid) and getContainerSize(item.uid) > 0 then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  elseif getItemInfo(item.itemid).worth > 0 then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  elseif not getItemInfo(item.itemid).movable then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  end
  if onlyoffer == 0 and price == 0 then
    return doPlayerPopupFYI(cid, __L(cid, "Set a price greater than zero."))
  end
  price = onlyoffer == 1 and 0 or price
  if getPlayerItemCount(cid, item.itemid) < count then
    return doPlayerPopupFYI(cid, __L(cid, "You do not have that many items."))
  end
  local fee = getMarketFee(price * count)
  if getPlayerMoney(cid) < fee or not doPlayerRemoveMoney(cid, fee) then
    return doPlayerPopupFYI(cid, __L(cid, "You do not have enough money for the market fee."))
  end
  local market_item = {
    item_code = code, playerseller_id = getPlayerGUID(cid), playerseller_name = getCreatureName(cid), 
    onlyoffer = onlyoffer, spriteId = getItemInfo(item.itemid).clientId, itemid = item.itemid, count = count, price = price,
    time = (os.time() + (60 * 60 * 60)), attributes = getItemAttributesBlob(item.uid), offers = {}
  }
  
  market_item.description = getPokeMarketDescription(market_item.itemid, item.uid)
  market_item.item_name = getMarketItemName(market_item.itemid, item.uid)
  market_item.poke_info = getMarketPokeInfo(market_item.itemid, item.uid)
  local values = db.escapeString(code)..", "..market_item.playerseller_id..", "..db.escapeString(market_item.playerseller_name)..", "..onlyoffer..", "..item.itemid..", "..count..", "..price..", "..market_item.attributes..", "..market_item.time..")"
  if not db.executeQuery("INSERT INTO `market_items` (`item_code`, `playerseller_id`, `playerseller_name`, `onlyoffer`, `itemid`, `count`, `price`, `attributes`, `time`) VALUES ( "..values) then
    doPlayerAddMoney(cid, fee)
    marketLog(cid, "list-failed", string.format("code=%s itemid=%d count=%d reason=insert", code, item.itemid, count))
    return doPlayerPopupFYI(cid, __L(cid, "The item could not be listed. Your fee was refunded."))
  end
  local removed
  if stackable then
    removed = doPlayerRemoveItem(cid, item.itemid, count)
  else
    removed = doRemoveItem(item.uid, 1)
  end
  if not removed then
    db.executeQuery("DELETE FROM `market_items` WHERE `item_code` = "..db.escapeString(code))
    doPlayerAddMoney(cid, fee)
    marketLog(cid, "list-failed", string.format("code=%s itemid=%d count=%d reason=remove", code, item.itemid, count))
    return doPlayerPopupFYI(cid, __L(cid, "The item could not be listed. Your fee was refunded."))
  end
  market_items[code] = market_item
  marketLog(cid, "list", string.format("code=%s itemid=%d count=%d price=%d onlyoffer=%d fee=%d", code, item.itemid, count, price, onlyoffer, fee))
  sendMarketBuyItems(cid, "Todos", 1, 0)
  sendMarketSellItems(cid)
  doPlayerSave(cid)
end

function doMarketBuyItem(cid, code, buy_count)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  buy_count = buy_count or 1
  if not isMarketInteger(buy_count, 1, MARKET_MAX_COUNT) then
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  end
  if getPlayerFreeSlots(cid) < 0 then
    doPlayerSendCancel(cid, __L(cid, "Your backpack is full."))
    return false
  end
  local market_item = market_items[code]
  if not market_item then
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  end
  if market_item.onlyoffer == 1 then
    doPlayerPopupFYI(cid, __L(cid, "This item only accepts offers."))
	return false
  end
  if getPlayerFreeCap(cid) < getItemInfo(market_item.itemid).weight then
    doPlayerPopupFYI(cid, __L(cid, "You do not have enough capacity."))
    return false
  elseif market_item.playerseller_id == getPlayerGUID(cid) then
    doPlayerPopupFYI(cid, __L(cid, "You cannot buy your own item."))
    return false
  elseif buy_count > market_item.count then
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  elseif market_item.time - os.time() < 1 then
    doPlayerPopupFYI(cid, __L(cid, "This listing has expired."))
    return false
  elseif market_item.count < 1 then
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  elseif getPlayerMoney(cid) < (market_item.price * buy_count) then
    doPlayerPopupFYI(cid, __L(cid, "You do not have enough money."))
    return false
  end
  local query = ("SELECT `attributes` FROM `market_items` WHERE `item_code` = '"..code.."' AND `playerseller_id`  = "..market_item.playerseller_id)
  local mysql = db.getResult(query)
  if mysql:getID() == -1 then
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  end
  local item = doCreateItemEx(market_item.itemid, market_item.count)
  doItemLoadAttributes(item, 'attributes', mysql:getID())
  doItemSetCount(item, buy_count)
  local total = market_item.price * buy_count
  if not doPlayerRemoveMoney(cid, total) then
    doPlayerPopupFYI(cid, __L(cid, "You do not have enough money."))
    return false
  end
  if addItem(getCreatureName(cid), market_item.itemid, item) then
	addMoney(market_item.playerseller_name, total)
	marketLog(cid, "buy", string.format("code=%s itemid=%d count=%d total=%d seller_guid=%d", code, market_item.itemid, buy_count, total, market_item.playerseller_id))
	if buy_count == market_item.count then
	  db.executeQuery("DELETE FROM `market_items` WHERE `item_code` = '"..code.."'")
      for playeroffer_id, offers in pairs(market_item.offers) do
        local checkHistoric = false
        for num, offer_item in ipairs(offers) do
          local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
          local mysql = db.getResult(query)
          if mysql:getID() == -1 then
            doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
            return false
          end
		  local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
          doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
          doItemSetCount(offerItem, offer_item.count)
          if offer_item.state == OFFERPOSTED then
            if addItem(getPlayerNameByGUID(offer_item.playeroffer_id), offer_item.itemid, offerItem) then
              -- db.executeQuery("UPDATE `market_offers` set `state` = "..OFFERDECLINED.." WHERE `item_code` = '"..offer_item.item_code.."' AND `item_index` = "..offer_item.item_index)
              if not checkHistoric then 
      	        setMarketHistoric(playeroffer_id, "Your offer was declined for "..market_item.item_name..".")
      	      end
      	      checkHistoric = true
      	    end
          elseif offer_item.state == OFFERUNDERCONSTRUCTION then
            if addItem(getPlayerNameByGUID(offer_item.playeroffer_id), offer_item.itemid, offerItem) then
              db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..offer_item.item_code.."' AND `item_index` = "..offer_item.item_index.." AND `playeroffer_id` = "..offer_item.playeroffer_id)
            end
          end
        end
      end
	  getMarketItems()
	else
	  db.executeQuery("UPDATE `market_items` SET `count` = `count` - ".. buy_count .." WHERE `item_code` = '"..code.."'")
	  market_item.count = market_item.count - buy_count
	end
	setMarketHistoric(getPlayerGUID(cid), "You bought "..buy_count.." "..market_item.item_name..".", cid)
	setMarketHistoric(market_item.playerseller_id, "You sold "..buy_count.." "..market_item.item_name..".")
	sendMarketBuyItems(cid, "Todos", 1, 0)
  else
    doPlayerAddMoney(cid, total)
    marketLog(cid, "buy-failed", string.format("code=%s count=%d total=%d reason=delivery", code, buy_count, total))
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  end
  return true
end

function doMarketRemoveItem(cid, code)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  if getPlayerFreeSlots(cid) < 0 then
    doPlayerSendCancel(cid, __L(cid, "Your backpack is full."))
    return false
  end
  local market_item = market_items[code]
  if not market_item then
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  end
  if market_item.playerseller_id ~= getPlayerGUID(cid) then
    doPlayerPopupFYI(cid, __L(cid, "This does not belong to you."))
    return false
  elseif getPlayerFreeCap(cid) < getItemInfo(market_item.itemid).weight then
    doPlayerSendCancel(cid, __L(cid, "You do not have enough capacity."))
    return false
  end
  local query = ("SELECT `attributes` FROM `market_items` WHERE `item_code` = '"..code.."' AND `playerseller_id`  = "..market_item.playerseller_id)
  local mysql = db.getResult(query)
  if mysql:getID() == -1 then
    doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
    return false
  end
  local item = doCreateItemEx(market_item.itemid, market_item.count)
  doItemLoadAttributes(item, 'attributes', mysql:getID())
  doItemSetCount(item, market_item.count)
  if addItem(getCreatureName(cid), market_item.itemid, item) then
	db.executeQuery("DELETE FROM `market_items` WHERE `item_code` = '"..code.."'")
	for playeroffer_id, offers in pairs(market_item.offers) do
	  local checkHistoric = false
	  for num, offer_item in ipairs(offers) do
        local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
        local mysql = db.getResult(query)
        if mysql:getID() == -1 then
          doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
          return false
        end
        local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
        doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
        doItemSetCount(offerItem, offer_item.count)
		if offer_item.state == OFFERUNDERCONSTRUCTION then
          if addItem(getPlayerNameByGUID(offer_item.playeroffer_id), offer_item.itemid, offerItem) then
            db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..code.."' AND `item_index` = "..offer_item.item_index.." AND `playeroffer_id` = "..offer_item.playeroffer_id)
          end
		elseif offer_item.state == OFFERPOSTED then
          if addItem(getPlayerNameByGUID(offer_item.playeroffer_id), offer_item.itemid, offerItem) then
            -- db.executeQuery("UPDATE `market_offers` set `state` = "..OFFERDECLINED.." WHERE `item_code` = '"..code.."' AND `item_index` = "..offer_item.item_index)
            if not checkHistoric then 
      	      setMarketHistoric(playeroffer_id, "Your offer was declined for "..market_item.item_name..".")
      	    end
      	    checkHistoric = true
		  end
		end
	  end
	end
	getMarketItems()
	sendMarketBuyItems(cid, "Todos", 1, 0)
	sendMarketSellItems(cid)
  end
  return true
end

function doMarketPostOffer(cid, code)
  if not nearOnMarket(cid) then return sendMarketClose(cid) end
  local market_item, playeroffer_id = market_items[code], getPlayerGUID(cid)
  if not market_item or not market_item.offers[playeroffer_id] then return end
  for num, offer_item in pairs(market_item.offers[playeroffer_id]) do
    if offer_item.state ~= OFFERUNDERCONSTRUCTION then return end
    offer_item.state = OFFERPOSTED
	db.executeQuery("UPDATE `market_offers` set `state` = "..OFFERPOSTED.." WHERE `item_code` = '"..code.."' AND `item_index` = "..offer_item.item_index)
  end
  doPlayerPopupFYI(cid, __L(cid, "Your offer was sent. Wait for the seller to review it."))
  sendMarketBuyItems(cid, "Todos", 1, 0)
  sendMarketOffers(cid)
end

function doMarketCancelMakeOffer(cid, code)
  local market_item, playeroffer_id = market_items[code], getPlayerGUID(cid)
  if not market_item then return end
  local offers = market_item.offers[playeroffer_id]
  if not offers then return end
  for num, offer_item in pairs(offers) do
    if offer_item.item_code == code and offer_item.state == OFFERUNDERCONSTRUCTION then
      local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
      local mysql = db.getResult(query)
      if mysql:getID() == -1 then
        doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
        return false
      end
      local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
      doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
      doItemSetCount(offerItem, offer_item.count)
	  if addItem(getCreatureName(cid), offer_item.itemid, offerItem) then
		db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..code.."' AND `item_index` = "..offer_item.item_index.." AND `playeroffer_id` = "..offer_item.playeroffer_id)
	  end
    end
  end
  market_item.offers = getMarketItemOffers(market_item.item_code)
  sendMarketBuyItems(cid, "Todos", 1, 0)
end

function doMarketMakeOffer(cid, code, container_index, slot_index, count)
  if not nearOnMarket(cid) then return doMarketCancelMakeOffer(cid, code) end
  local item = {itemid = 0}
  if container_index >= 64 and container_index <= 80 then
    item = getContainerItemByIndex(cid, container_index - 64, slot_index) or item
  else
    return doPlayerPopupFYI(cid, __L(cid, "Only items inside your backpack can be offered."))
  end
  if item.itemid == 0 then
    return doPlayerPopupFYI(cid, __L(cid, "Item not found."))
  elseif isContainer(item.uid) and getContainerSize(item.uid) > 0 then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  elseif not getItemInfo(item.itemid).movable then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot sell this item."))
  end
  if isItemUnique(item.uid, cid) then return doPlayerPopupFYI(cid, __L(cid, "You cannot offer this unique item.")) end
  local maxCount = isItemStackable(item.itemid) and math.max(1, item.type) or 1
  if not isMarketInteger(count, 1, maxCount) then
    return doPlayerPopupFYI(cid, __L(cid, "You do not have the selected amount of items."))
  end
  local current_market_item = market_items[code]
  if not current_market_item then 
    return doPlayerPopupFYI(cid, __L(cid, "Item not found."))
  end
  if current_market_item.playerseller_id == getPlayerGUID(cid) then
    return doPlayerPopupFYI(cid, __L(cid, "You cannot make an offer on your own item."))
  end
  local current_offers = current_market_item.offers[getPlayerGUID(cid)]
  if current_offers and current_offers[1].state ~= OFFERUNDERCONSTRUCTION then
    return doPlayerPopupFYI(cid, __L(cid, "You already made an offer for this item."))
  end
  if current_offers and #current_offers >= 8 then
    return doPlayerPopupFYI(cid, __L(cid, "You reached the maximum number of items you can offer."))
  end
  local offer_item = {
    item_code         = code,
    itemid            = item.itemid,
	spriteId          = getItemInfo(item.itemid).clientId,
    count             = count,
    item_index        = current_offers and #current_offers+1 or 1,
    attributes        = getItemAttributesBlob(item.uid),
    playeroffer_id    = getPlayerGUID(cid),
    playeroffer_name  = getCreatureName(cid),
    state             = OFFERUNDERCONSTRUCTION,
  }
  offer_item.description = getPokeMarketDescription(offer_item.itemid, item.uid)
  offer_item.poke_info = getMarketPokeInfo(item.itemid, item.uid)
  local values = "'"..offer_item.item_code.."', "..offer_item.itemid..", "..offer_item.count..", "..offer_item.item_index..", "..offer_item.playeroffer_id..", "..db.escapeString(offer_item.playeroffer_name)..", "..offer_item.attributes..")"
  if not db.executeQuery("INSERT INTO `market_offers` (`item_code`, `itemid`, `count`, `item_index`, `playeroffer_id`, `playeroffer_name`, `attributes`) VALUES ( "..values) then
    return doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
  end
  if not doRemoveItem(item.uid, count) then
    db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = "..db.escapeString(code).." AND `item_index` = "..offer_item.item_index.." AND `playeroffer_id` = "..offer_item.playeroffer_id)
    return doPlayerPopupFYI(cid, __L(cid, "Item not found."))
  end
  marketLog(cid, "offer", string.format("code=%s itemid=%d count=%d", code, offer_item.itemid, count))
  if not current_market_item.offers[offer_item.playeroffer_id] then current_market_item.offers[offer_item.playeroffer_id] = {} end
  current_market_item.offers[offer_item.playeroffer_id][#current_market_item.offers[offer_item.playeroffer_id]+1] = offer_item
  local protocol = Protocol_create("marketbuymakeoffer")
  Protocol_add(protocol, {count = count, spriteId = offer_item.spriteId, description = offer_item.description, poke_info = offer_item.poke_info})
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(protocol))
  doPlayerSave(cid)
end

function cancelMakeOfferOnLogout(cid)
  local code = nil
  local mysql = db.getResult("SELECT * FROM `market_offers` WHERE `playeroffer_id` = "..getPlayerGUID(cid).." AND `state` = "..OFFERUNDERCONSTRUCTION)
  if mysql:getID() ~= -1 then
    while(true) do
	  local offer_item = {
	    item_code         = mysql:getDataString('item_code'),
        itemid            = mysql:getDataInt('itemid'),
        count             = mysql:getDataInt('count'),
	  }
      local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
      doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
      doItemSetCount(offerItem, offer_item.count)
	  code = offer_item.item_code
      if not(mysql:next())then
        break
      end
	end
	mysql:free()
  end
  if code then
    local market_item, playeroffer_id = market_items[code], getPlayerGUID(cid)
    if not market_item then return end
    local offers = market_item.offers[playeroffer_id]
    if not offers then return end
    for num, offer_item in pairs(offers) do
      if offer_item.item_code == code and offer_item.state == OFFERUNDERCONSTRUCTION then
        local query = ("SELECT `attributes` FROM `market_offers` WHERE `item_code` = '"..code.."' AND `playeroffer_id`  = "..offer_item.playeroffer_id.." AND `item_index` = "..offer_item.item_index)
        local mysql = db.getResult(query)
        if mysql:getID() == -1 then
          doPlayerPopupFYI(cid, __L(cid, "Invalid market item."))
          return false
        end
        local offerItem = doCreateItemEx(offer_item.itemid, offer_item.count)
        doItemLoadAttributes(offerItem, 'attributes', mysql:getID())
        doItemSetCount(offerItem, offer_item.count)
	    if addItem(getCreatureName(cid), offer_item.itemid, offerItem) then
          -- print("doMarketCancelMakeOffer: delete")
	  	db.executeQuery("DELETE FROM `market_offers` WHERE `item_code` = '"..code.."' AND `item_index` = "..offer_item.item_index.." AND `playeroffer_id` = "..offer_item.playeroffer_id)
	    end
      end
    end
    -- print("doMarketCancelMakeOffer: refresh")
    market_item.offers = getMarketItemOffers(market_item.item_code)
  end
end

getMarketItems()

------------------------- SUPPORT FUNCTIONS ----------------------------------------

function addMoney(name, money)
  local money_table = {
     [1] = {first = 10000, second = 35573},
	 [2] = {first = 1, second = 2152},
  }
  local tmp = 0
  for a, b in pairs(money_table) do
    tmp = money / b.first
    if math.floor(tmp) > 0 then
      local _tmp = tmp
      if math.floor(math.floor(tmp) / 10000) > 0 then 
        for _y = 1, math.floor(math.floor(tmp) / 10000) do
          local item = doCreateItemEx(b.second, 10000)
          doPlayerSendMailByName(name, item, 40)
          _tmp = math.floor(_tmp) - 10000
        end
      end
      if _tmp > 0 and _tmp < 10000 then
        local item = doCreateItemEx(b.second, math.floor(_tmp))
        doPlayerSendMailByName(name, item, 40)
      end
      money = money - (b.first * math.floor(tmp))
    end
  end
end

function addItem(name, itemId, item)
  return doPlayerSendMarketMailByName(name, item, 40) == true
end

function getItemCategory(itemid)
  local item = getItemInfo(itemid)
  if isStones(itemid) or (itemid >= 34731 and itemid <= 34770) then
	return "Stones"
  elseif isPokebolas(itemid) then
	return "Poke Balls"
  elseif isDiamonds(itemid) then
	return "Diamonds"
  elseif isAddons(itemid) or (itemid >= 34771 and itemid <= 34874) or (itemid >= 29561 and itemid <= 29768) or (itemid >= 29773 and itemid <= 29862) then
	return "Addons"
  elseif isOutfits(itemid) or (itemid >= 34601 and itemid <= 34730) then
	return "Outfits"
  elseif isPokeball(itemid) then
	return "Pokemon"
  elseif isHelds(itemid) or (itemid >= 23513 and itemid <= 23531) then
	return "Held Item"
  elseif isFurnitures(itemid) or (itemid >= 34875 and itemid <= 35099) then
	return "Furnitures"
  elseif isBerrys(itemid) or (itemid >= 14766 and itemid <= 14770) then
	return "Berries"
  elseif isPlates(itemid) or (itemid >= 12229 and itemid <= 12243) then
	return "Plates"
  elseif isDolls(itemid) or (itemid >= 17820 and itemid <= 18049) or (itemid >= 19760 and itemid <= 19768) or (itemid >= 19086 and itemid <= 19090) or (itemid >= 25412 and itemid <= 25416) or (itemid >= 27811 and itemid <= 27818) or (itemid >= 28076 and itemid <= 28089) or (itemid >= 28976 and itemid <= 29113)or (itemid >= 9693 and itemid <= 9699) then
	return "Dolls"
  elseif isFoods(itemid) or (itemid >= 25417 and itemid <= 25424) or (itemid >= 12202 and itemid <= 12212) then
	return "Foods"
  elseif isUtilities(itemid) or (itemid >= 35550 and itemid <= 35555) or (itemid >= 27357 and itemid <= 27376) then
	return "Utilities"
  elseif isSuplies(itemid) or (itemid >= 35539 and itemid <= 35549) then
	return "Supplies"
  else
	return "Items"
  end
end

function generateCode()
  local code = "Mkt"
  for num=1, 20 do
    code = code..math.random(0,9)
  end
  return code
end

function freeSlotsdeepSearch(_item)
  local freeSlot = 0
  for slot = 1, getContainerCap(_item) do
    local item = getContainerItem(_item, slot)
    if item.uid == 0 then
      freeSlot = freeSlot + 1
    elseif item.uid ~= 0 then
      if isContainer(item.uid) then
        freeSlot = freeSlot + freeSlotsdeepSearch(item.uid)
      end
    end
  end
  return freeSlot
end

function getPlayerFreeSlots(cid)
  local freeSlot = 0
  local item  = getPlayerSlotItem(cid, PLAYER_SLOT_BACKPACK)
  if item.uid ~= 0 then
    if isContainer(item.uid) then
      freeSlot = freeSlot + freeSlotsdeepSearch(item.uid)
    end
  end
  return math.max(0, (freeSlot - 1))
end

function getPlayerItemByCode(cid, item_code)
  local function getItemInContainerByCode(container, item_code)
    if isContainer(container) and getContainerSize(container) > 0 then
	  for slot = 0, (getContainerSize(container)-1) do
	    local item = getContainerItem(container, slot)
	    if isContainer(item.uid) and getContainerItem(item.uid, 0).uid ~= 0 then
		  local item = getItemInContainerByCode(item.uid, item_code)
		  if item then return item end
		else
		  if getItemAttribute(item.uid, playersStorages.marketBase) and getItemAttribute(item.uid, playersStorages.marketBase) == item_code then
		    return item
		  end
		end
	  end
	end
	return false
  end
  return getItemInContainerByCode(getPlayerSlotItem(cid, PLAYER_SLOT_BACKPACK).uid, item_code) 
end

function isItemUnique(uid, cid)
  if getItemAttribute(uid, ballsAttributes.uniqueFromTm) and getItemAttribute(uid, ballsAttributes.uniqueFromTm) == 1 then return true end 
  if getItemAttribute(uid, ballsAttributes.uniqueFromTmSlot1) and getItemAttribute(uid, ballsAttributes.uniqueFromTmSlot1) == 1 then return true end 
  if getItemAttribute(uid, ballsAttributes.uniqueFromTmSlot2) and getItemAttribute(uid, ballsAttributes.uniqueFromTmSlot2) == 1 then return true end 
  if (getItemUniqueOwner(uid) ~= ITEM_UNIQUE_OWNER_NONE and getItemUniqueOwner(uid) ~= getPlayerGUID(cid)) then return true end
  return false
end

function getPlayerItemByIdInMarket(cid, itemId)
  local function getItemInContainerById(container, itemId)
    if isContainer(container) and getContainerSize(container) > 0 then
	  for slot = 0, (getContainerSize(container)-1) do
	    local item = getContainerItem(container, slot)
	    if isContainer(item.uid) and getContainerItem(item.uid, 0).uid ~= 0 then
		  local item = getItemInContainerById(item.uid, itemId)
		  if item then return item end
		else
		  if item.itemid == itemId then
		    return item
		  end
		end
	  end
	end
	return false
  end
  return getItemInContainerById(getPlayerSlotItem(cid, PLAYER_SLOT_BACKPACK).uid, itemId) 
end