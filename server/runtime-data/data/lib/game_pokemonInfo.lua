-- em data\lua\ps\config\pokemon.lua

function getPokemonPlayerIVHP(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonIVHP(ball.uid)
end

function getPokemonPlayerIVATQ(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonIVATQ(ball.uid)
end

function getPokemonPlayerIVDEF(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonIVDEF(ball.uid)
end

function getPokemonPlayerIVSPATQ(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonIVSPATQ(ball.uid)
end

function getPokemonPlayerIVSPDEF(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonIVSPDEF(ball.uid)
end

function getPokemonPlayerIVSPD(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonIVSPD(ball.uid)
end

function getPokemonPlayerEVHP(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonEVHP(ball.uid)
end

function getPokemonPlayerEVATQ(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonEVATQ(ball.uid)
end

function getPokemonPlayerEVDEF(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonEVDEF(ball.uid)
end

function getPokemonPlayerEVSPATQ(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonEVSPATQ(ball.uid)
end

function getPokemonPlayerEVSPDEF(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonEVSPDEF(ball.uid)
end

function getPokemonPlayerEVSPD(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return math.random(1, 31)
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonEVSPD(ball.uid)
end


-- return base stats ball
function getPokemonPlayerBASEHP(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return 0
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonBaseHP(ball.uid)
end

function getPokemonPlayerBASEATQ(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return 0
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonBaseATQ(ball.uid)
end

function getPokemonPlayerBASEDEF(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return 0
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonBaseDEF(ball.uid)
end

function getPokemonPlayerBASESPATQ(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return 0
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonBaseSPATQ(ball.uid)
end

function getPokemonPlayerBASESPDEF(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return 0
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonBaseSPDEF(ball.uid)
end

function getPokemonPlayerBASESPD(pokemonUid)
  if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
    return 0
  end

  local pokemonMaster = getCreatureMaster(pokemonUid)
  local ball = getPlayerBall(pokemonMaster)
  return getBallPokemonBaseSPD(ball.uid)
end



-- em data\lua\ps\config\balls.lua
function getBallPokemonIVHP(uid)
  local attr = getItemAttribute(uid, ballsAttributes.ivhp)
  return attr == nil and 0 or attr
end

function getBallPokemonIVATQ(uid)
  local attr = getItemAttribute(uid, ballsAttributes.ivatq)
  return attr == nil and 0 or attr
end

function getBallPokemonIVDEF(uid)
  local attr = getItemAttribute(uid, ballsAttributes.ivdef)
  return attr == nil and 0 or attr
end

function getBallPokemonIVSPATQ(uid)
  local attr = getItemAttribute(uid, ballsAttributes.ivspatq)
  return attr == nil and 0 or attr
end

function getBallPokemonIVSPDEF(uid)
  local attr = getItemAttribute(uid, ballsAttributes.ivspdef)
  return attr == nil and 0 or attr
end

function getBallPokemonIVSPD(uid)
  local attr = getItemAttribute(uid, ballsAttributes.ivspd)
  return attr == nil and 0 or attr
end

function getBallPokemonEVHP(uid)
  local attr = getItemAttribute(uid, ballsAttributes.evhp)
  return attr == nil and 0 or attr
end

function getBallPokemonEVATQ(uid)
  local attr = getItemAttribute(uid, ballsAttributes.evatq)
  return attr == nil and 0 or attr
end

function getBallPokemonEVDEF(uid)
  local attr = getItemAttribute(uid, ballsAttributes.evdef)
  return attr == nil and 0 or attr
end

function getBallPokemonEVSPATQ(uid)
  local attr = getItemAttribute(uid, ballsAttributes.evspatq)
  return attr == nil and 0 or attr
end

function getBallPokemonEVSPDEF(uid)
  local attr = getItemAttribute(uid, ballsAttributes.evspdef)
  return attr == nil and 0 or attr
end

function getBallPokemonEVSPD(uid)
  local attr = getItemAttribute(uid, ballsAttributes.evspd)
  return attr == nil and 0 or attr
end

function getBallPokemonEvPoints(uid)
  return (getBallPokemonLevel(uid) * 5) - getBallPokemonEVSpendingPoints(uid)
  -- return 100
end

function getBallPokemonEVSpendingPoints(uid)
  local attr = getItemAttribute(uid, ballsAttributes.evspendingPoints)
  return attr == nil and 0 or attr
end

function getBallPokemonBaseHP(uid)
  local attr = getItemAttribute(uid, ballsAttributes.basehp)
  return attr == nil and 0 or attr
end

function getBallPokemonBaseATQ(uid)
  local attr = getItemAttribute(uid, ballsAttributes.baseatq)
  return attr == nil and 0 or attr
end

function getBallPokemonBaseDEF(uid)
  local attr = getItemAttribute(uid, ballsAttributes.basedef)
  return attr == nil and 0 or attr
end

function getBallPokemonBaseSPATQ(uid)
  local attr = getItemAttribute(uid, ballsAttributes.basespatq)
  return attr == nil and 0 or attr
end

function getBallPokemonBaseSPDEF(uid)
  local attr = getItemAttribute(uid, ballsAttributes.basespdef)
  return attr == nil and 0 or attr
end

function getBallPokemonBaseSPD(uid)
  local attr = getItemAttribute(uid, ballsAttributes.basespd)
  return attr == nil and 0 or attr
end

NATURES = {
    -- 0 = IGUAL, 1 = AUMENTA, 2 = DIMINUI
    [1] = {name = "Adamant", atk = 1, def = 0, spAtk = 2, spDef = 0, speed = 0},
    [2] = {name = "Bashful", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0},
    [3] = {name = "Bold", atk = 2, def = 1, spAtk = 0, spDef = 0, speed = 0},
    [4] = {name = "Brave", atk = 1, def = 0, spAtk = 0, spDef = 0, speed = 2},
    [5] = {name = "Calm", atk = 2, def = 0, spAtk = 0, spDef = 1, speed = 0},
    [6] = {name = "Careful", atk = 0, def = 0, spAtk = 2, spDef = 1, speed = 0},
    [7] = {name = "Docile", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0},
    [8] = {name = "Gentle", atk = 0, def = 2, spAtk = 0, spDef = 1, speed = 0},
    [9] = {name = "Hardy", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0},
    [10] = {name = "Hasty", atk = 0, def = 2, spAtk = 0, spDef = 0, speed = 1},
    [11] = {name = "Impish", atk = 0, def = 1, spAtk = 2, spDef = 0, speed = 0},
    [12] = {name = "Jolly", atk = 0, def = 0, spAtk = 2, spDef = 0, speed = 1},
    [13] = {name = "Lax", atk = 0, def = 1, spAtk = 0, spDef = 2, speed = 0},
    [14] = {name = "Lonely", atk = 1, def = 2, spAtk = 0, spDef = 0, speed = 0},
    [15] = {name = "Mild", atk = 0, def = 2, spAtk = 1, spDef = 0, speed = 0},
    [16] = {name = "Modest", atk = 2, def = 0, spAtk = 1, spDef = 0, speed = 0},
    [17] = {name = "Naive", atk = 0, def = 0, spAtk = 0, spDef = 2, speed = 1},
    [18] = {name = "Naughty", atk = 1, def = 0, spAtk = 0, spDef = 2, speed = 0},
    [19] = {name = "Quiet", atk = 0, def = 0, spAtk = 1, spDef = 0, speed = 2},
    [20] = {name = "Quirky", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0},
    [21] = {name = "Rash", atk = 0, def = 0, spAtk = 1, spDef = 2, speed = 0},
    [22] = {name = "Relaxed", atk = 0, def = 1, spAtk = 0, spDef = 0, speed = 2},
    [23] = {name = "Sassy", atk = 0, def = 0, spAtk = 0, spDef = 1, speed = 2},
    [24] = {name = "Serious", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0},
    [25] = {name = "Timid", atk = 2, def = 0, spAtk = 0, spDef = 0, speed = 1}
}

function getNatureInfo(pokemonUid)
    if (not isSummon(pokemonUid) and not getPokemonSummon(pokemonUid)) then
        return {name = 0, atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0}
    end
    local pokemonMaster = getCreatureMaster(pokemonUid)
    local ball = getPlayerBall(pokemonMaster)
    return getBallPokemonNature(ball.uid)
end

function getBallPokemonNature(ballUid)
    local nature = getItemAttribute(ballUid, ballsAttributes.nature) 
    if not nature then return {name = "", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0} end
    return NATURES[nature] or {name = "", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0}
end
function getBallPokemonNatureMarket(ballUid)
    local nature = getItemAttribute(ballUid, ballsAttributes.nature) 
    if not nature then return {name = "", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0} end
    return NATURES[nature] or {name = "", atk = 0, def = 0, spAtk = 0, spDef = 0, speed = 0}
end

-- Amizade
function getBallPokemonFriendshipLevel(uid)
  local attr = getItemAttribute(uid, ballsAttributes.friendshipLevel)
  return attr == nil and 1 or math.max(1, attr)
end
function getBallPokemonFriendshipExp(uid)
  local attr = getItemAttribute(uid, ballsAttributes.friendshipExp)
  return attr == nil and 0 or attr
end
function getBallPokemonFriendshipLootLucky(uid)
  local attr = getItemAttribute(uid, ballsAttributes.friendshipLootLucky)
  return attr == nil and 0.1 or attr
end
function getBallPokemonFriendshipShinyCharm(uid)
  local attr = getItemAttribute(uid, ballsAttributes.friendshipShinyCharm)
  return attr == nil and 0.1 or attr
end
function getBallPokemonFriendshipCriticalChance(uid)
  local attr = getItemAttribute(uid, ballsAttributes.friendshipCriticalChance)
  return attr == nil and 0.1 or attr
end
function getBallPokemonFriendshipEnergyRegen(uid)
  local attr = getItemAttribute(uid, ballsAttributes.friendshipEnergyRegen)
  return attr == nil and 0.1 or attr
end

function getPokemonAtk(pokemon, pokemonLevel)
    local ivatk = getPokemonPlayerIVATQ(pokemon)
    local evatk = getPokemonPlayerEVATQ(pokemon)
    local baseatk = getPokemonPlayerBASEATQ(pokemon)
    if (ivatk == nil) then
        ivatk = math.random(1, 5)
    end
    local atk = ((((2 * getPokemonBaseAtk(pokemon) + ivatk + evatk + baseatk) * pokemonLevel) / 100) + 5)
    local nature = getNatureInfo(pokemon)
    atk = nature.atk == 0 and atk or (nature.atk == 1 and (atk * 1.1) or (atk - (atk / 100 * 10)))
    return math.max(1, atk)
end

function getPokemonAtkByBall(buid, pokemonName, pokemonLevel) ---- feito
    local ivatk = getBallPokemonIVATQ(buid)
    local evatk = getBallPokemonEVATQ(buid)
    local baseatk = getBallPokemonBaseATQ(buid)
    local atk = ((((2 * getPokemonBaseAtkByName(pokemonName) + ivatk + evatk + baseatk) * pokemonLevel) / 100) + 5)
    local nature = getBallPokemonNature(buid)
    atk = nature.atk == 0 and atk or (nature.atk == 1 and (atk * 1.1) or (atk - (atk / 100 * 10)))

    return math.max(1, atk)
end

function getPokemonDef(pokemon, pokemonLevel)
    local ivdef = getPokemonPlayerIVDEF(pokemon)
    local evdef = getPokemonPlayerEVDEF(pokemon)
    local basedef = getPokemonPlayerBASEDEF(pokemon)
    if (ivdef == nil) then
        ivdef = math.random(1, 5)
    end
    local def = ((((2 * getPokemonBaseDef(pokemon) + ivdef + evdef + basedef) * pokemonLevel) / 100) + 5)

    local nature = getNatureInfo(pokemon)
    def = nature.def == 0 and def or (nature.def == 1 and (def * 1.1) or (def - (def / 100 * 10)))

    return math.max(1, def)
end

function getPokemonDefByBall(buid, pokemonName, pokemonLevel) ---- feito
    local ivdef = getBallPokemonIVDEF(buid)
    local evdef = getBallPokemonEVDEF(buid)
    local basedef = getBallPokemonBaseDEF(buid)
    local def = ((((2 * getPokemonBaseDefByName(pokemonName) + ivdef + evdef + basedef) * pokemonLevel) / 100) + 5)
    local nature = getBallPokemonNature(buid)

    local nature = getBallPokemonNature(buid)
    def = nature.def == 0 and def or (nature.def == 1 and (def * 1.1) or (def - (def / 100 * 10)))

    return math.max(1, def)
end

function getPokemonSpAtk(pokemon, pokemonLevel)
    local ivspatk = getPokemonPlayerIVSPATQ(pokemon)
    local evspatk = getPokemonPlayerEVSPATQ(pokemon)
    local basespatk = getPokemonPlayerBASESPATQ(pokemon)
    if (ivspatk == nil) then
        ivspatk = math.random(1, 5)
    end
    local spatk = ((((2 * getPokemonBaseSpAtk(pokemon) + ivspatk + evspatk + basespatk) * pokemonLevel) / 100) + 5)

    local nature = getNatureInfo(pokemon)
    spatk = nature.spAtk == 0 and spatk or (nature.spAtk == 1 and (spatk * 1.1) or (spatk - (spatk / 100 * 10)))

    return math.max(1, spatk)
end

function getPokemonSpAtkByBall(buid, pokemonName, pokemonLevel) ---- feito
    local ivspatk = getBallPokemonIVSPATQ(buid)
    local evspatk = getBallPokemonEVSPATQ(buid)
    local basespatk = getBallPokemonBaseSPATQ(buid)
    local spatk = ((((2 * getPokemonBaseSpAtkByName(pokemonName) + ivspatk + evspatk + basespatk) * pokemonLevel) / 100) + 5)

    local nature = getBallPokemonNature(buid)
    spatk = nature.spAtk == 0 and spatk or (nature.spAtk == 1 and (spatk * 1.1) or (spatk - (spatk / 100 * 10)))

    return math.max(1, spatk)
end

function getPokemonSpDef(pokemon, pokemonLevel)
    local ivspdef = getPokemonPlayerIVSPDEF(pokemon)
    local evspdef = getPokemonPlayerEVSPDEF(pokemon)
    local basespdef = getPokemonPlayerBASESPDEF(pokemon)
    if (ivspdef == nil) then
        ivspdef = math.random(1, 5)
    end
    local spdef = ((((2 * getPokemonBaseSpDef(pokemon) + ivspdef + evspdef + basespdef) * pokemonLevel) / 100) + 5)

    local nature = getNatureInfo(pokemon)
    spdef = nature.spDef == 0 and spdef or (nature.spDef == 1 and (spdef * 1.1) or (spdef - (spdef / 100 * 10)))

    return math.max(1, spdef)
end

function getPokemonSpDefByBall(buid, pokemonName, pokemonLevel) ---- feito
    local ivspdef = getBallPokemonIVSPDEF(buid)
    local evspdef = getBallPokemonEVSPDEF(buid)
    local basespdef = getBallPokemonBaseSPDEF(buid)
    local spdef = ((((2 * getPokemonBaseSpDefByName(pokemonName) + ivspdef + evspdef + basespdef) * pokemonLevel) / 100) + 5)

    local nature = getBallPokemonNature(buid)
    spdef = nature.spDef == 0 and spdef or (nature.spDef == 1 and (spdef * 1.1) or (spdef - (spdef / 100 * 10)))

    return math.max(1, spdef)
end

function getPokemonSpeedByBall(buid, pokemonName, pokemonLevel) ---- feito
    local ivspd = getBallPokemonIVSPD(buid)
    local evspd = getBallPokemonEVSPD(buid)
    local basespd = getBallPokemonBaseSPD(buid)
    local spd = ((((2 * getPokemonBaseSpeedByName(pokemonName) + ivspd + evspd + basespd) * pokemonLevel) / 100) + 5)

    local nature = getBallPokemonNature(buid)
    spd = nature.speed == 0 and spd or (nature.speed == 1 and (spd * 1.1) or (spd - (spd / 100 * 10)))

    return math.max(1, spd)
end

function getPokemonSpeed(pokemon, pokemonLevel)
    local ivspd = getPokemonPlayerIVSPD(pokemon)
    local evspd = getPokemonPlayerEVSPD(pokemon)
    local basespd = getPokemonPlayerBASESPD(pokemon)
    if (ivspd == nil) then
        ivspd = math.random(1, 5)
    end
    local spd = ((((2 * getPokemonBaseSpeed(pokemon) + ivspd + evspd + basespd) * pokemonLevel) / 100) + 5)

    local nature = getNatureInfo(pokemon)
    spd = nature.speed == 0 and spd or (nature.speed == 1 and (spd * 1.1) or (spd - (spd / 100 * 10)))

    return math.max(1, spd)
end

function setBallPokemonIVHP(uid, ivhp)
    doItemSetAttribute(uid, ballsAttributes.ivhp, ivhp)
end

function setBallPokemonIVATQ(uid, ivatq)
    doItemSetAttribute(uid, ballsAttributes.ivatq, ivatq)
end

function setBallPokemonIVDEF(uid, ivdef)
    doItemSetAttribute(uid, ballsAttributes.ivdef, ivdef)
end

function setBallPokemonIVSPATQ(uid, ivspatq)
    doItemSetAttribute(uid, ballsAttributes.ivspatq, ivspatq)
end

function setBallPokemonIVSPDEF(uid, ivspdef)
    doItemSetAttribute(uid, ballsAttributes.ivspdef, ivspdef)
end

function setBallPokemonIVSPD(uid, ivspd)
    doItemSetAttribute(uid, ballsAttributes.ivspd, ivspd)
end

function setBallPokemonNature(uid, nature)
  doItemSetAttribute(uid, ballsAttributes.nature, nature)
end

function setBallPokemonBaseHP(uid, value)
  doItemSetAttribute(uid, ballsAttributes.basehp, value)
end

function setBallPokemonBaseATQ(uid, value)
  doItemSetAttribute(uid, ballsAttributes.baseatq, value)
end

function setBallPokemonBaseDEF(uid, value)
  doItemSetAttribute(uid, ballsAttributes.basedef, value)
end

function setBallPokemonBaseSPATK(uid, value)
  doItemSetAttribute(uid, ballsAttributes.basespatq, value)
end

function setBallPokemonBaseSPDEF(uid, value)
  doItemSetAttribute(uid, ballsAttributes.basespdef, value)
end

function setBallPokemonBaseSPEED(uid, value)
  doItemSetAttribute(uid, ballsAttributes.basespd, value)
end

local friendshipType = {
  ["mint"] = {itemId = 35545, exp = 1},
  ["banana"] = {itemId = 35546, exp = 10},
  ["apple"] = {itemId = 35547, exp = 25},
  ["grape"] = {itemId = 35548, exp = 50},
  ["cupNoodle"] = {itemId = 35549, exp = 10000000},
}

function giveFriendshipExp(cid, typeId)
  if not typeId or not friendshipType[typeId] then return end
  local ball = getPlayerBall(cid)
  if not isItem(ball) then return end
  local exp = friendshipType[typeId].exp
  local level = getBallPokemonFriendshipLevel(ball.uid)
  if level == 100 then return end
  local currLevelExp = getExpForFrindshipLevel(level)
  local nextLevelExp = getExpForFrindshipLevel(level + 1)
  if (currLevelExp >= nextLevelExp) then return end
  local experience = getBallPokemonFriendshipExp(ball.uid)
  if experience >= nextLevelExp then return end -- Caso a xp atual for maior que o requirido para o nivel
  experience = experience + exp
  if getPlayerItemCount(cid, friendshipType[typeId].itemId) < 1 then
		local info = {Reset = {code = "SemFoodFriend"}, protocol = "Info"}
		doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
    return
  end
  doPlayerRemoveItem(cid, friendshipType[typeId].itemId, 1)
  doItemSetAttribute(ball.uid, ballsAttributes.friendshipExp, experience)
  local info = {
    protocol = "Info",
    friendship = {
      level = getBallPokemonFriendshipLevel(ball.uid),
      exp = getBallPokemonFriendshipExp(ball.uid),
      lootLucky = getBallPokemonFriendshipLootLucky(ball.uid),
      shinyCharm = getBallPokemonFriendshipShinyCharm(ball.uid),
      criticalChance = getBallPokemonFriendshipCriticalChance(ball.uid),
      energyRegen = getBallPokemonFriendshipEnergyRegen(ball.uid),
    }
  }
  info.friendship.expToNext = getExpForFrindshipLevel(info.friendship.level+1)
  info.friendship.reqMoney = getFriendshipMoneyReq(info.friendship.level+1)
  info.friendship.reqDiamonds = getFriendshipDiamondsReq(info.friendship.level+1)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
end

function getExpForFrindshipLevel(level)
  level = level - 1
  return ((50 * level * level * level) - (150 * level * level) + (400 * level)) / 20
end

function getFriendshipMoneyReq(level)
  return level * 15000
end

function getFriendshipDiamondsReq(level)
  return level * 1
end

function upgradeFriendshipLevel(cid, useDiamonds)
  local ball = getPlayerBall(cid)
  if not isItem(ball) then return end
  local level = getBallPokemonFriendshipLevel(ball.uid)
  if level >= 100 then return end
  if getBallPokemonFriendshipExp(ball.uid) < getExpForFrindshipLevel(level + 1) then 
		local info = {Reset = {code = "SemExperience"}, protocol = "Info"}
		doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
	return 
  end
  if not useDiamonds then
    if getPlayerMoney(cid) < getFriendshipMoneyReq(level+1) then
		local info = {Reset = {code = "SemDinheiro"}, protocol = "Info"}
		doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
      return
    end
  else
    if getPlayerItemCount(cid, 34524) < getFriendshipDiamondsReq(level+1) then
		local info = {Reset = {code = "SemDiamond"}, protocol = "Info"}
		doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
      return
    end
  end
  if not useDiamonds then
    doPlayerRemoveMoney(cid, getFriendshipMoneyReq(level+1))
  else
    doPlayerRemoveItem(cid, 34524, getFriendshipDiamondsReq(level+1))
  end
  -- VERIFICAÇÃO DE GRANA E DIAMONDS
  doItemSetAttribute(ball.uid, ballsAttributes.friendshipCriticalChance, getBallPokemonFriendshipCriticalChance(ball.uid) + 0.1)
  doItemSetAttribute(ball.uid, ballsAttributes.friendshipLootLucky, getBallPokemonFriendshipLootLucky(ball.uid) + 0.1)
  doItemSetAttribute(ball.uid, ballsAttributes.friendshipEnergyRegen, getBallPokemonFriendshipEnergyRegen(ball.uid) + 0.1)
  doItemSetAttribute(ball.uid, ballsAttributes.friendshipShinyCharm, getBallPokemonFriendshipShinyCharm(ball.uid) + 0.1)
  doItemSetAttribute(ball.uid, ballsAttributes.friendshipLevel, level + 1)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Seu pokemon avançou em amizade do nivel "..level.." para o nivel "..(level+1).."")
  local info = {
    protocol = "Info",
    friendship = {
      level = getBallPokemonFriendshipLevel(ball.uid),
      exp = getBallPokemonFriendshipExp(ball.uid),
      lootLucky = getBallPokemonFriendshipLootLucky(ball.uid),
      shinyCharm = getBallPokemonFriendshipShinyCharm(ball.uid),
      criticalChance = getBallPokemonFriendshipCriticalChance(ball.uid),
      energyRegen = getBallPokemonFriendshipEnergyRegen(ball.uid),
    }
  }
  info.friendship.expToNext = getExpForFrindshipLevel(info.friendship.level+1)
  info.friendship.reqMoney = getFriendshipMoneyReq(info.friendship.level+1)
  info.friendship.reqDiamonds = getFriendshipDiamondsReq(info.friendship.level+1)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
  doBallUpdateDescription(ball.uid)
end

function generateIV()
    return math.random(1,31)
end
function generatePayIV()
    return math.random(10,31)
end

local BaseTypes = {
  ["hp"]    = {itemId = 35539},
  ["atk"]   = {itemId = 35540},
  ["def"]   = {itemId = 35542},
  ["spatk"] = {itemId = 35541},
  ["spdef"] = {itemId = 35543},
  ["speed"] = {itemId = 35544},
}

-- The upgrade list comes from the client: keep only known stats with positive integer amounts, merge
-- repeated stats, and drop a stat whose total would pass the cap.
local function sanitizeUpgradeTab(tab, current, cap)
  local merged, order = {}, {}
  if type(tab) ~= "table" then return {} end
  for _, entry in pairs(tab) do
    local value = type(entry) == "table" and tonumber(entry.value)
    if value and value > 0 and value == math.floor(value) and type(entry.id) == "string" and current[entry.id] then
      if not merged[entry.id] then order[#order + 1] = entry.id end
      merged[entry.id] = (merged[entry.id] or 0) + value
    end
  end
  local result = {}
  for _, id in ipairs(order) do
    if current[id] + merged[id] <= cap then
      result[#result + 1] = {id = id, value = merged[id]}
    end
  end
  return result
end

function upgradeBase(cid, tab)
  local ball = getPlayerBall(cid)
  if not isItem(ball) then return end
  local base = {
    hp = getBallPokemonBaseHP(ball.uid),
    atk = getBallPokemonBaseATQ(ball.uid), 
    def = getBallPokemonBaseDEF(ball.uid), 
    spatk = getBallPokemonBaseSPATQ(ball.uid),
    spdef = getBallPokemonBaseSPDEF(ball.uid),
    speed = getBallPokemonBaseSPD(ball.uid),
  }
  tab = sanitizeUpgradeTab(tab, base, 150)
  if #tab == 0 then return end
  for _, b in ipairs(tab) do
    if not BaseTypes[b.id] then return end
  end
  for _, b in pairs(tab) do
    if base[b.id] then
      local value = base[b.id]
      if (value + b.value <= 150) then
        if BaseTypes[b.id] then
          if getPlayerItemCount(cid, BaseTypes[b.id].itemId) < b.value then
				local info = {Reset = {code = "SemStones"}, protocol = "Info"}
				doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
            return
          end
        end
      end
    end
  end
  for _, b in pairs(tab) do
    if base[b.id] then
      local value = base[b.id]
      if (value + b.value <= 150) then
        base[b.id] = value + b.value
        doPlayerRemoveItem(cid, BaseTypes[b.id].itemId, b.value)
      end
    end
  end
  doItemSetAttribute(ball.uid, ballsAttributes.basehp, base.hp)
  doItemSetAttribute(ball.uid, ballsAttributes.baseatq, base.atk)
  doItemSetAttribute(ball.uid, ballsAttributes.basedef, base.def)
  doItemSetAttribute(ball.uid, ballsAttributes.basespatq, base.spatk)
  doItemSetAttribute(ball.uid, ballsAttributes.basespdef, base.spdef)
  doItemSetAttribute(ball.uid, ballsAttributes.basespd, base.speed)
  doBallUpdateDescription(ball.uid)
  sendPokemonInfo(cid)
end

function upgradeEv(cid, tab)
  local ball = getPlayerBall(cid)
  if not isItem(ball) then return end
  local points = getBallPokemonEvPoints(ball.uid)
  if points == 0 then return end
  local evs = {
    hp = getBallPokemonEVHP(ball.uid),
    atk = getBallPokemonEVATQ(ball.uid), 
    def = getBallPokemonEVDEF(ball.uid), 
    spatk = getBallPokemonEVSPATQ(ball.uid),
    spdef = getBallPokemonEVSPDEF(ball.uid),
    speed = getBallPokemonEVSPD(ball.uid),
  }
  tab = sanitizeUpgradeTab(tab, evs, 250)
  if #tab == 0 then return end
  local spendingReq = 0
  for _, ev in pairs(tab) do
    if evs[ev.id] then
      local value = evs[ev.id]
      if (value + ev.value <= 250) then
        spendingReq = spendingReq + ev.value
      end
    end
  end
  if spendingReq > points then return end
  if spendingReq + (evs.hp+evs.atk+evs.def+evs.spatk+evs.spdef+evs.speed) > 500 then return end
  local spendingPoints = getBallPokemonEVSpendingPoints(ball.uid)
  for _, ev in pairs(tab) do
    if evs[ev.id] then
      local value = evs[ev.id]
      if (value + ev.value <= 250) then
        evs[ev.id] = value + ev.value
        spendingPoints = spendingPoints + ev.value
      end
    end
  end
  doItemSetAttribute(ball.uid, ballsAttributes.evhp, evs.hp)
  doItemSetAttribute(ball.uid, ballsAttributes.evatq, evs.atk)
  doItemSetAttribute(ball.uid, ballsAttributes.evdef, evs.def)
  doItemSetAttribute(ball.uid, ballsAttributes.evspatq, evs.spatk)
  doItemSetAttribute(ball.uid, ballsAttributes.evspdef, evs.spdef)
  doItemSetAttribute(ball.uid, ballsAttributes.evspd, evs.speed)
  doItemSetAttribute(ball.uid, ballsAttributes.evspendingPoints, spendingPoints)
  doBallUpdateDescription(ball.uid)
  sendPokemonInfo(cid)
end

function doResetEvs(cid)
  local ball = getPlayerBall(cid)
  if not isItem(ball) then return end
  doItemSetAttribute(ball.uid, ballsAttributes.evhp, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.evatq, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.evdef, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.evspatq, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.evspdef, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.evspd, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.evspendingPoints, 0)
  doBallUpdateDescription(ball.uid)
  sendPokemonInfo(cid)
  
  local info = {Reset = {code = "IvReseted"}, protocol = "Info"}
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
end

function doResetBase(cid)
  local ball = getPlayerBall(cid)
  if not isItem(ball) then return end
  local base = {
    hp = getBallPokemonBaseHP(ball.uid),
    atk = getBallPokemonBaseATQ(ball.uid), 
    def = getBallPokemonBaseDEF(ball.uid), 
    spatk = getBallPokemonBaseSPATQ(ball.uid),
    spdef = getBallPokemonBaseSPDEF(ball.uid),
    speed = getBallPokemonBaseSPD(ball.uid),
  }
  if math.floor(getBallPokemonBaseHP(ball.uid) / 2) > 0 then 
    doPlayerAddItem(cid, BaseTypes["hp"].itemId, math.floor(getBallPokemonBaseHP(ball.uid) / 2))
  end  
  if math.floor(getBallPokemonBaseATQ(ball.uid) / 2) > 0 then 
    doPlayerAddItem(cid, BaseTypes["atk"].itemId, math.floor(getBallPokemonBaseATQ(ball.uid) / 2))
  end  
  if math.floor(getBallPokemonBaseDEF(ball.uid) / 2) > 0 then 
    doPlayerAddItem(cid, BaseTypes["def"].itemId, math.floor(getBallPokemonBaseDEF(ball.uid) / 2))
  end  
  if math.floor(getBallPokemonBaseSPATQ(ball.uid) / 2) > 0 then 
    doPlayerAddItem(cid, BaseTypes["spatk"].itemId, math.floor(getBallPokemonBaseSPATQ(ball.uid) / 2))
  end  
  if math.floor(getBallPokemonBaseSPDEF(ball.uid) / 2) > 0 then 
    doPlayerAddItem(cid, BaseTypes["spdef"].itemId, math.floor(getBallPokemonBaseSPDEF(ball.uid) / 2))
  end  
  if math.floor(getBallPokemonBaseSPD(ball.uid) / 2) > 0 then 
    doPlayerAddItem(cid, BaseTypes["speed"].itemId, math.floor(getBallPokemonBaseSPD(ball.uid) / 2))
  end
  doItemSetAttribute(ball.uid, ballsAttributes.basehp, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.baseatq, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.basedef, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.basespatq, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.basespdef, 0)
  doItemSetAttribute(ball.uid, ballsAttributes.basespd, 0)
  doBallUpdateDescription(ball.uid)
  sendPokemonInfo(cid)
  
  local info = {Reset = {code = "BaseReseted"}, protocol = "Info"}
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
end

function sendPokemonInfo(cid)
  local ball = getPlayerBall(cid)
  if not isItem(ball) then return end
  local summon = getPlayerPokemons(cid)[1]
  if not summon or not isCreature(summon) then return end
		
  local info = {}
  info.main = {
    health = getBallPokemonLastHp(ball.uid),
    level = getBallPokemonLevel(ball.uid),
    name = getBallPokemonName(ball.uid),
    nick = getBallPokemonNickname(ball.uid),
    gender = getBallPokemonSex(ball.uid),
    nature = getBallPokemonNature(ball.uid).name,
  }
  info.base = {
    hp = getBallPokemonBaseHP(ball.uid),
    atk = getBallPokemonBaseATQ(ball.uid),
    def = getBallPokemonBaseDEF(ball.uid),
    spatk = getBallPokemonBaseSPATQ(ball.uid),
    spdef = getBallPokemonBaseSPDEF(ball.uid),
    speed = getBallPokemonBaseSPD(ball.uid),
  }
  info.mainBase = {
    hp = getPokemonBaseHpByName(info.main.name), 
    atk = getPokemonBaseAtkByName(info.main.name), 
    def = getPokemonBaseDefByName(info.main.name),
    spatk = getPokemonBaseSpAtkByName(info.main.name), 
    spdef = getPokemonBaseSpDefByName(info.main.name), 
    speed = getPokemonBaseSpeedByName(info.main.name)
  }
  info.ivs = {
    hp = getBallPokemonIVHP(ball.uid),
    atk = getBallPokemonIVATQ(ball.uid), 
    def = getBallPokemonIVDEF(ball.uid), 
    spatk = getBallPokemonIVSPATQ(ball.uid),
    spdef = getBallPokemonIVSPDEF(ball.uid),
    speed = getBallPokemonIVSPD(ball.uid)
  }
  info.evs = {
    hp = getBallPokemonEVHP(ball.uid),
    atk = getBallPokemonEVATQ(ball.uid), 
    def = getBallPokemonEVDEF(ball.uid), 
    spatk = getBallPokemonEVSPATQ(ball.uid),
    spdef = getBallPokemonEVSPDEF(ball.uid),
    speed = getBallPokemonEVSPD(ball.uid),
    points = getBallPokemonEvPoints(ball.uid)
  }
  info.total = {
    hp = math.floor(getCreatureMaxHealth(summon)),
    atk = math.floor(getPokemonAtkByBall(ball.uid, info.main.name, info.main.level)),
    def = math.floor(getPokemonDefByBall(ball.uid, info.main.name, info.main.level)),
    spatk = math.floor(getPokemonSpAtkByBall(ball.uid, info.main.name, info.main.level)),
    spdef = math.floor(getPokemonSpDefByBall(ball.uid, info.main.name, info.main.level)),
    speed = math.floor(getPokemonSpeedByBall(ball.uid, info.main.name, info.main.level)),
  }
  info.friendship = {
    level = getBallPokemonFriendshipLevel(ball.uid),
    exp = getBallPokemonFriendshipExp(ball.uid),
    lootLucky = getBallPokemonFriendshipLootLucky(ball.uid),
    shinyCharm = getBallPokemonFriendshipShinyCharm(ball.uid),
    criticalChance = getBallPokemonFriendshipCriticalChance(ball.uid),
    energyRegen = getBallPokemonFriendshipEnergyRegen(ball.uid),
  }
  info.friendship.expToNext = getExpForFrindshipLevel(info.friendship.level+1)
  info.friendship.reqMoney = getFriendshipMoneyReq(info.friendship.level+1)
  info.friendship.reqDiamonds = getFriendshipDiamondsReq(info.friendship.level+1)
  info.tickets = {base = getPlayerItemCount(cid, 35553), evs = getPlayerItemCount(cid, 35552)}
  info.protocol = "Info"
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
end

function sendTickesCount(cid)
  local info = {tickets = {base = getPlayerItemCount(cid, 35553), evs = getPlayerItemCount(cid, 35552)}, protocol = "Info"}
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
end

function getPokeInfoMaxHealth(name, level, pokemonIVHP, uid)
  local hp = getMonsterInfo(name).health
  local hpRate = 1.0
  local cfgHpRate = 1.0
  local extraPoints = getBallPokemonExtraPoints(uid)
  
  local primeiroHP = ((((((hp + 50) * 0.5 + 100 + pokemonIVHP) * level) + 400)  * hpRate) * cfgHpRate)
  local calculo = 200 * (extraPoints * 0.05)
  
  if(calculo == 0) then
    hp = primeiroHP
  else
    hp = primeiroHP + (primeiroHP / calculo)
  end

  return math.floor(hp)
end