--[[
  SISTEMA DE DUNGEON / DIMENSIONAL ZONE
  
  USAR ESSA CHAMADA QUANDO JOGADOR MORRER
    doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "closeinformation"}))

]]

DzBeginner = 1
DzTalented = 2
DzIntermediary = 3
DzAdvanced = 4
DzExperient = 5

DzBronze = 1
DzSilver = 2
DzGold = 3
DzSpecial = 4

DzStateNone = 0
DzStateTeam = 1
DzStateSearching = 2
DzStateBattle = 3
DzStateReward = 4
DzStateDie = 5

DzPrepared = 0
DzPreparedNotInLobby = 1
DzPreparedNotHaveKey = 2
DzPreparedNotPlayer = 3

Dz = {}
Dz.Opcode = 41
Dz.PlayerStorage = 868689
Dz.GlobalStorage = 21
Dz.RankingStorage = {}
Dz.RankingStorage[DzBeginner] = 6500
Dz.RankingStorage[DzTalented] = Dz.RankingStorage[DzBeginner]+50
Dz.RankingStorage[DzIntermediary] = Dz.RankingStorage[DzTalented]+50
Dz.RankingStorage[DzAdvanced] = Dz.RankingStorage[DzIntermediary]+50
Dz.RankingStorage[DzExperient] = Dz.RankingStorage[DzAdvanced]+50

Dz.LobbyPosition = {from = {x = 4655, y = 118, z = 9},to = {x = 4673, y = 133, z = 9}, tp = {x = 4664, y = 128, z = 9}}
Dz.Keys = {
  [DzBronze]  = {id = 'bronze',  name = "Bronze",  itemId = 35577},
  [DzSilver]  = {id = 'silver',  name = "Silver",  itemId = 35578},
  [DzGold]    = {id = 'gold',    name = "Gold",    itemId = 35579},
  [DzSpecial] = {id = 'special', name = "Special", itemId = 35580},
}

Dz.Teams = {}
Dz.SearchingPlayers = {
  [DzBeginner] = {},
  [DzTalented] = {},
  [DzIntermediary] = {},
  [DzAdvanced] = {},
  [DzExperient] = {},
}
Dz.Diff = {
  [DzBeginner] = {},
  [DzTalented] = {},
  [DzIntermediary] = {},
  [DzAdvanced] = {},
  [DzExperient] = {},
}

Dz.Chest = {
  [DzBronze]  = {itemId = 33849},
  [DzSilver]  = {itemId = 33850},
  [DzGold]    = {itemId = 33852},
  [DzSpecial] = {itemId = 33851},
}

function Dz.sendMaps(cid, diff)
  if diff == 0 or diff > DzExperient then return end
  doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "first", diff = diff}))
  local buffer = {}
  for _, map in pairs (Dz.Diff[diff].Maps) do
    if map.active then
      buffer[#buffer+1] = {}
      buffer[#buffer].name = map.name
      buffer[#buffer].maxPlayers = map.maxPlayers
      buffer[#buffer].rarity = map.rarity
      buffer[#buffer].image = map.image
      buffer[#buffer].experience = map.experience
      buffer[#buffer].reward = map.reward
      local rooms = {occupied = 0, max = #map.rooms}
      for roomId, room in ipairs(map.rooms) do
        if room.inUse then rooms.occupied = rooms.occupied + 1 end
      end
      buffer[#buffer].rooms = rooms
      if #buffer == 10 then
        doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "maps", draw = false, maps = buffer}))
		stats = 1
        buffer = {}
      end
    end
  end
  doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "maps", draw = true, maps = buffer}))
  Dz.sendKeys(cid)
end

function Dz.sendKeys(cid)
  local keys = {}
  for rarity, info in ipairs(Dz.Keys) do
    keys[rarity] = getPlayerItemCount(cid, info.itemId)
  end
  doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "keys", keys = keys}))
end

function Dz.sendTeam(cid)
  if Dz.getState(cid) == DzStateTeam then
    local leader = Dz.getTeam(cid)
    local DzTeam = Dz.Teams[leader]
    if DzTeam then
	  local members = {}
      for pos, name in pairs(DzTeam.members) do
        local player = getPlayerByName(name)
        if isPlayer(player) then
		  members[#members+1] = {name = name, level = getPlayerLevel(player), outfit = getCreatureOutfit(player), clan = getPlayerMastery(player)}
		end
	  end
	  local buffer = json.encode({protocol = "team", leader = leader, members = members})
      for _, member in pairs(members) do
        doSendPlayerExtendedOpcode(getPlayerByName(member.name), Dz.Opcode, buffer)
      end
    end
  end
end

function Dz.sendClose(cid)
  doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "close"}))
end

function Dz.sendRanking(cid, diff, mapId)
  if diff == 0 or diff > DzExperient then return end
  local Map = Dz.Diff[diff].Maps[mapId]
  if not Map then return end
  doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "ranking", diff = diff, map = Map.name, image = Map.image, ranking = Dz.getRanking(diff, mapId)}))
end

function Dz.createTeam(cid)
  if Dz.getState(cid) > DzStateNone then return end
  Dz.Teams[getCreatureName(cid)] = {
    guestList = {},
    members = {getCreatureName(cid)},
  }
  Dz.setState(cid, DzStateTeam)
  Dz.setTeam(cid, getCreatureName(cid))
  Dz.sendTeam(cid)
end

function Dz.inviteToTeam(cid, name)
  if Dz.getState(cid) ~= DzStateTeam then return end
  local DzTeam = Dz.Teams[getCreatureName(cid)]
  if not DzTeam then return end
  local pid = getPlayerByName(name)
  if not pid or not isPlayer(pid) then
    doPlayerPopupFYI(cid, "Jogador inválido.")
    return
  end
  if pid == cid then
    doPlayerPopupFYI(cid, "Você não pode se convidar.")
	return
  end
  if Dz.getState(pid) > DzStateNone then
    doPlayerPopupFYI(cid, "Não é possível convidar esse jogador no momento.")
    return
  end
  if isInArray(DzTeam.guestList, name) then
    doPlayerPopupFYI(cid, "Este jogador ja foi convidado.")
    return
  end
  if isInArray(DzTeam.members, name) then
    doPlayerPopupFYI(cid, "Este jogador ja está no time.")
    return
  end
  table.insert(DzTeam.guestList, name)
  doPlayerPopupFYI(cid, "O jogador "..name.." foi convidado!")
  doSendPlayerExtendedOpcode(pid, Dz.Opcode, json.encode({protocol = "invite", leader = getCreatureName(cid)}))
end

function Dz.leaveTeam(cid)
  if Dz.getState(cid) ~= DzStateTeam then return end
  local leader = Dz.getTeam(cid)
  if leader ~= -1 then
    local DzTeam = Dz.Teams[leader]
    if not DzTeam then
      Dz.resetStorage(cid)
      doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "team"}))
      return
    end
    if getCreatureName(cid) == leader then
      for pos, name in pairs(DzTeam.members) do
        local player = getPlayerByName(name)
        if isPlayer(player) then
          if name ~= leader then doPlayerPopupFYI(player, leader.." desfez o time.") end
          Dz.resetStorage(player)
          doSendPlayerExtendedOpcode(player, Dz.Opcode, json.encode({protocol = "team"}))
        end
      end
      Dz.Teams[leader] = nil
      return
    else
      for pos, name in pairs(DzTeam.members) do
        if name == getCreatureName(cid) then
          table.remove(DzTeam.members, pos)
          break
        end
      end
      for pos, name in pairs(DzTeam.members) do
        local player = getPlayerByName(name)
        if isPlayer(player) then Dz.sendTeam(player) end
      end
    end
    Dz.resetStorage(cid)
    doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "team"}))
  end
end

function Dz.acceptInvite(cid, leader)
  if Dz.getState(cid) > DzStateNone then return end
  local DzTeam = Dz.Teams[leader]
  if not DzTeam then doPlayerPopupFYI(cid, "O time não existe") return end
  if not isInArray(DzTeam.guestList, getCreatureName(cid)) then doPlayerPopupFYI(cid, "O time não existe") return end
  if isInArray(DzTeam.members, getCreatureName(cid)) then
    doPlayerPopupFYI(cid, "Você já esta no time")
    Dz.sendTeam(cid)
    return
  end
  for pos, name in pairs(DzTeam.guestList) do
    if name:lower() == getCreatureName(cid):lower() then table.remove(DzTeam.guestList, pos) break end
  end
  if #DzTeam.members == 5 then
    doPlayerPopupFYI(cid, "Time está lotado")
    return
  end
  table.insert(DzTeam.members, getCreatureName(cid))
  Dz.setState(cid, DzStateTeam)
  Dz.setTeam(cid, leader)
  Dz.sendTeam(cid)
end

function Dz.play(cid, diff, mapId)
  if diff == 0 or diff > DzExperient then return end
  local Map = Dz.Diff[diff].Maps[mapId]
  if not Map then return end
  local state = Dz.getState(cid) 
  if state >= DzStateSearching then return end
  if getPlayerItemCount(cid, Dz.Keys[Map.rarity].itemId) == 0 then
    doPlayerPopupFYI(cid, "Você não possui chave")
	return
  end
  if state == DzStateTeam then
    local leader = Dz.getTeam(cid)
    local DzTeam = Dz.Teams[leader]
    if not DzTeam then
      Dz.resetStorage(cid)
      doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "team"}))
      return
    end
    if leader == -1 or leader ~= getCreatureName(cid) then
      doPlayerPopupFYI(cid, "Somente "..leader.." pode iniciar a dungeon.")
      return
    end
    local roomId = Dz.getAvailableRoom(Map)
    if not roomId then
      doPlayerPopupFYI(cid, "Nenhuma sala disponivel no momento")
      return
    end
    if #DzTeam.members < Map.maxPlayers then
      doPlayerPopupFYI(cid, "Quantidade de jogadores insuficientes para esse mapa ("..#DzTeam.members.."/"..Map.maxPlayers..")")
      return
    end
    if #DzTeam.members > Map.maxPlayers then
      doPlayerPopupFYI(cid, "Somente "..Map.maxPlayers.." jogadores para esse mapa.")
      return
    end
    local ret = Dz.AreMembersPrepared(Map, DzTeam.members)
    if ret.msg == DzPrepared then
      Dz.startMap(DzTeam.members, diff, mapId, roomId)
	  DzTeam = nil
    elseif ret.msg == DzPreparedNotInLobby then
	  local player = getPlayerByName(ret.name)
      return doPlayerPopupFYI(cid, (isPlayer(player) and getCreatureName(player) or "Um jogador").." não está na sala de espera.")
    elseif ret.msg == DzPreparedNotHaveKey then
      return doPlayerPopupFYI(cid, (isPlayer(player) and getCreatureName(player) or "Um jogador").." não possui chave")
    end
  else
    if not isInRange(getThingPos(cid), Dz.LobbyPosition.from, Dz.LobbyPosition.to) then
      doPlayerPopupFYI(cid, "Você não está na sala de espera.")
	  Dz.sendClose(cid)
	  return
    end
    local roomId = Dz.getAvailableRoom(Map)
	if not roomId then
      doPlayerPopupFYI(cid, "Nenhuma sala disponivel no momento")
      return
	end
    local SearchingPlayers = Dz.SearchingPlayers[diff][mapId]
    table.insert(SearchingPlayers, getCreatureName(cid))
    if #SearchingPlayers == Map.maxPlayers then
      local ret = Dz.AreMembersPrepared(Map, SearchingPlayers, true)
	  if ret.msg == DzPrepared then
        Dz.startMap(SearchingPlayers, diff, mapId, roomId)
		Dz.SearchingPlayers[diff][mapId] = {}
		return
	  end
	  Dz.setState(cid, DzStateSearching)
	  local excluded = getPlayerByName(ret.name)
	  for pos, name in pairs(Dz.SearchingPlayers[diff][mapId]) do
	    if name == ret.name then table.remove(pos, name) break end
	  end
	  if isPlayer(excluded) then
	    Dz.setState(excluded, DzStateNone)
        Dz.sendClose(excluded)
	  end
	  Dz.sendSearchingPlayers(SearchingPlayers, Map)
    else
	  Dz.setState(cid, DzStateSearching)
      Dz.sendSearchingPlayers(SearchingPlayers, Map)
    end
  end
end

function Dz.sendSearchingPlayers(SearchingPlayers, Map)
  local members = {}
  for pos, name in pairs(SearchingPlayers) do
    local player = getPlayerByName(name)
    if isPlayer(player) then
      members[#members+1] = {name = name, outfit = getCreatureOutfit(player), level = getPlayerLevel(player)}
    end
  end
  local buffer = json.encode({protocol = "searching", members = members, name = Map.name, experience = Map.experience, reward = Map.reward, max = Map.maxPlayers})
  for _, member in pairs(members) do
    doSendPlayerExtendedOpcode(getPlayerByName(member.name), Dz.Opcode, buffer)
  end
end

function Dz.cancelQueue(cid)
  local value = Dz.getPlayerStorage(cid)
  if value.state ~= DzStateSearching then return end
  value.state = DzStateNone
  setPlayerStorageValue(cid, Dz.PlayerStorage, json.encode(value))
  for diff, maps in ipairs(Dz.SearchingPlayers) do
	for mapId, players in ipairs(maps) do
      for pos, name in pairs(players) do
        if isPlayer(getPlayerByName(name)) and getCreatureName(cid) == name then
		  table.remove(players, pos)
          Dz.sendSearchingPlayers(players, Dz.Diff[diff].Maps[mapId])
		  return
		end
      end
	end
  end
end

function Dz.startMap(members, diff, mapId, roomId)
  local Map = Dz.Diff[diff].Maps[mapId]
  local Room = Map.rooms[roomId]
  local player = getPlayerByName(name)
  -- print("startMap: ", diff, mapId)
  Room.variable.members = {}
  Room.variable.time = os.time()
  Room.variable.pokemonCount = #Room.pokemons
  local eventId = addEvent(Dz.closeMap, Map.time, Room.variable.time, diff, mapId, roomId)
  local buffer = json.encode({protocol = "start", time = Map.time, potions = Map.potions, revives = Map.revives, pokemons = #Room.pokemons})

  for pos, name in pairs(members) do
    local player = getPlayerByName(name)
	doPlayerRemoveItem(player, Dz.Keys[Map.rarity].itemId, 1)
    doTeleportThing(player, Room.pos.player)

    --- HEAL
    if (isPokemonOnline(player)) then -- Try to call Pokemon back
        doPlayerUseBallOnSlot(player)
    end
    doCreatureAddHealth(player, (getCreatureMaxHealth(player) - getCreatureHealth(player)))
    doSendMagicEffect(getCreaturePosition(player), EFFECT_GREEN_BUFF)

    local balls = getPlayerAllBallsWithPokemon(player)
    for i, ball in ipairs(balls) do
        doBallHeal(player, ball)
    end

    --- HEAL

    Dz.setPlayerStorage(player, {state = DzStateBattle, diff = diff, mapId = mapId, roomId = roomId, eventId = eventId, potions = Map.potions, revives = Map.revives})
    table.insert(Room.variable.members, name)
	doSendPlayerExtendedOpcode(player, Dz.Opcode, buffer)
	Dz.sendKeys(player)
  end
  for _, pokemon in ipairs(Room.pokemons) do
    local pid = doCreateMonster(pokemon.name, pokemon.pos, false)
    if isCreature(pid) then table.insert(Room.variable.pokemons, pid) end
  end
  Room.inUse = true
end

function Dz.closeMap(oldTime, diff, mapId, roomId)
  local Room = Dz.Diff[diff].Maps[mapId].rooms[roomId]
  if Room.variable.time ~= oldTime then return end
  for _, name in pairs(Room.variable.members) do
    local player = getPlayerByName(name)
    if isPlayer(player) and (Dz.getState(player) == DzStateBattle) then
      doTeleportThing(player, Dz.LobbyPosition.tp)
      Dz.resetStorage(player)
      doPlayerPopupFYI(player, "O tempo acabou.")
	  doSendPlayerExtendedOpcode(player, Dz.Opcode, json.encode({protocol = "closeinformation"}))
    end
  end
  Dz.clearMap(diff, mapId, roomId)
end

function Dz.clearMap(diff, mapId, roomId)
  local Room = Dz.Diff[diff].Maps[mapId].rooms[roomId]
  for _, pid in ipairs(Room.variable.pokemons) do
    if isCreature(pid) then doRemoveCreature(pid) end
  end
  Room.variable.members = {}
  Room.variable.time = nil
  Room.inUse = false
end

function Dz.doPlayerLeave(cid)
  local value = Dz.getPlayerStorage(cid)
  if value.state == DzStateNone then return true end
  if value.state == DzStateTeam then
    Dz.leaveTeam(cid)
  elseif value.state == DzStateSearching then
    Dz.cancelQueue(cid)
  elseif value.state == DzStateBattle then
    local Map = Dz.Diff[value.diff].Maps[value.mapId]
    local Room = Map.rooms[value.roomId]
    doTeleportThing(cid, Dz.LobbyPosition.tp)
	if #Room.variable.members > 1 then
	  for pos, name in pairs(Room.variable.members) do
	    if name == getCreatureName(cid) then table.remove(Room.variable.members, pos) break end
	  end
	else
      Dz.clearMap(value.diff, value.mapId, value.roomId)
	end
	Dz.resetStorage(cid)
	doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "closeinformation"}))
  elseif value.state == DzStateReward then
    doTeleportThing(cid, Dz.LobbyPosition.tp)
    Dz.removePrizeRoom(value.prizeRoomId)
    Dz.resetStorage(cid)
  end
end

function Dz.AreMembersPrepared(Map, members, remove)
  for pos, name in pairs(members) do
    local player = getPlayerByName(name)
    if not isPlayer(player) then return {name = name, msg = DzPreparedNotPlayer} end
	if not isInRange(getThingPos(player), Dz.LobbyPosition.from, Dz.LobbyPosition.to) then return {name = name, msg = DzPreparedNotInLobby} end
	if getPlayerItemCount(player, Dz.Keys[Map.rarity].itemId) == 0 then return {name = name, msg = DzPreparedNotHaveKey} end
  end
  return {msg = DzPrepared}
end

function Dz.getAvailableRoom(Map)
  for roomId, room in ipairs(Map.rooms) do
    if not room.inUse then return roomId end
  end
  return nil
end

function Dz.getAvailablePrizeRoom()
  local rooms = Dz.getPrizeRoom()
  for roomId, room in ipairs(Dz.PrizeRooms) do
    if not isInArray(rooms, roomId) then return roomId end
    -- if not room.inUse then return roomId end
  end
  return nil
end

function Dz.getPrizeRoom()
  local rooms = getStorage(Dz.GlobalStorage)
  return rooms == -1 and {} or json.decode(rooms)
end

function Dz.addPrizeRoom(id)
  local rooms = Dz.getPrizeRoom()
  table.insert(rooms, id)
  doSetStorage(Dz.GlobalStorage, json.encode(rooms))
end

function Dz.removePrizeRoom(id)
  local rooms = Dz.getPrizeRoom()
  for pos, roomId in pairs(rooms) do
    if roomId == id then table.remove(rooms, pos) break end
  end
  doSetStorage(Dz.GlobalStorage, json.encode(rooms))
end

-------------------------
-------- Dentro de cada action que use potion ou revive, usar essa verificação, sendo que dentro da tabela, vai variar revive/potion
-------- if not Dz.onUseMedicament(cid, {potions = true}) then return false end

function Dz.onUseMedicament(cid, params)
  local value = Dz.getPlayerStorage(cid)
  if value.state ~= DzStateBattle then return true end
  local Map = Dz.Diff[value.diff].Maps[value.mapId]
  if params.potion then
    if value.potions == 0 then
	  doPlayerPopupFYI(cid, "Você já utilizou todas as poções disponiveis")
	  return false
	end
	value.potions = value.potions - 1
    doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "medicament", potion = value.potions}))
  elseif params.revives then
    if value.revives == 0 then
	  doPlayerPopupFYI(cid, "Você já utilizou todas os revives disponiveis")
	  return false
	end
	value.revives = value.revives - 1
    doSendPlayerExtendedOpcode(cid, Dz.Opcode, json.encode({protocol = "medicament", revive = value.revives}))
  end
  setPlayerStorageValue(cid, Dz.PlayerStorage, json.encode(value))
  return true
end

function Dz.teleportToPrize(diff, mapId, roomId)
  local Map = Dz.Diff[diff].Maps[mapId]
  local Room = Map.rooms[roomId]
  for _, name in pairs(Room.variable.members) do
    local player = getPlayerByName(name)
    Dz.addToRanking(diff, mapId, {name = name, outfit = getCreatureOutfit(player), level = getPlayerLevel(player), clan = getPlayerMastery(player), time = os.time()-Room.variable.time})
    doSendPlayerExtendedOpcode(player, Dz.Opcode, json.encode({protocol = "closeinformation"}))
    local prizeRoomId = Dz.getAvailablePrizeRoom()
    if not prizeRoomId then
      doTeleportThing(player, Dz.LobbyPosition.tp)
      for _, reward in pairs(Map.reward) do
        if math.random(1,100) < reward.chance then
          doPlayerAddItem(player, reward.id, math.random(reward.qnt[1], reward.qnt[2]))
        end
      end
      doPlayerAddExperience(player, Map.experience)
      Dz.resetStorage(player)
    else
      local PrizeRoom = Dz.PrizeRooms[prizeRoomId]
      doTeleportThing(player, PrizeRoom.teleportPos)
      Dz.setPlayerStorage(player, {state = DzStateReward, prizeRoomId = prizeRoomId})
      for id, pos in ipairs(PrizeRoom.corpse) do
        for stackpos=1, 10 do
          local cPos = {x=pos.x,y=pos.y,z=pos.z,stackpos = stackpos}
          local tileThing = getTileThingByPos(cPos)
          if tileThing.itemid ~= 0 and isCorpse(tileThing.uid) then doRemoveItem(tileThing.uid) end
        end
        if math.random(1, id == 1 and 50 or 70) < 50 then
          local index = id == 3 and 2 or id
          local choose = math.random(1, #Map.corpses[index])
          local pokemon = Map.corpses[index][choose]
          local corpse = doCreateItem(getMonsterInfo(pokemon).lookCorpse, 1, pos)
          doItemSetAttribute(corpse, "corpseowner", getPlayerGUID(player))
          doItemSetAttribute(corpse, "pokemon", pokemon)
          doItemSetAttribute(corpse, "sex", math.random(0,1))
          doItemSetAttribute(corpse, "level", 1)
        end
      end
      for id, pos in ipairs(PrizeRoom.chest) do
        for rarity, chest in pairs(Dz.Chest) do
          local item = getTileItemById(pos, chest.itemId)
          if item.uid > 0 then doRemoveItem(item.uid) end
        end
        doCreateItem(Dz.Chest[Map.rarity].itemId, pos)
      end
      Dz.addPrizeRoom(prizeRoomId)
    end
  end
  Dz.clearMap(diff, mapId, roomId)
end

function Dz.getRanking(diff, mapId)
  local mysql = db.getResult("SELECT `ranking` FROM `dungeon_ranking` WHERE `diff` = "..diff.." AND `mapId` = "..mapId)
  local ranking = mysql:getID() ~= -1 and json.decode(mysql:getDataString("ranking")) or {}
  if #ranking > 0 then mysql:free() end
  return ranking
end

function Dz.addToRanking(diff, mapId, info)
  local ranking = Dz.getRanking(diff, mapId)
  table.insert(ranking, info)
  table.sort(ranking, function(a,b) return a.time < b.time end)
  local newRanking = {}
  for _, rank in ipairs(ranking) do
    if #newRanking >= 10 then break end
    newRanking[#newRanking+1] = rank
  end
  if #newRanking == 1 then
    db.executeQuery("INSERT INTO `dungeon_ranking` (`ranking`, `diff`, `mapId`) VALUES ('"..json.encode(newRanking).."', "..diff..", "..mapId..")")
  else
    db.executeQuery("UPDATE `dungeon_ranking` set `ranking` = '"..json.encode(newRanking).."' WHERE `diff` = "..diff.." AND `mapId` = "..mapId)
  end
end

-- Player Management

function Dz.getPlayerStorage(cid)
  local value = getPlayerStorageValue(cid, Dz.PlayerStorage)
  if value == -1 then 
    value = {state = DzStateNone, team = "", diff = 0, mapId = 0, roomId = 0, eventId = 0, prizeRoomId = 0, potions = 0, revives = 0}
    setPlayerStorageValue(cid, Dz.PlayerStorage, json.encode(value))
    return value
  end
  return json.decode(value)
end

function Dz.setPlayerStorage(cid, params)
  local value = Dz.getPlayerStorage(cid)
  if params.state then value.state = params.state end
  if params.team then value.team = params.team end
  if params.diff then value.diff = params.diff end
  if params.mapId then value.mapId = params.mapId end
  if params.roomId then value.roomId = params.roomId end
  if params.eventId then value.eventId = params.eventId end
  if params.prizeRoomId then value.prizeRoomId = params.prizeRoomId end
  if params.potions then value.potions = params.potions end
  if params.revives then value.revives = params.revives end
  setPlayerStorageValue(cid, Dz.PlayerStorage, json.encode(value))
end

function Dz.getState(cid)
  return Dz.getPlayerStorage(cid).state
end

function Dz.setState(cid, state)
  Dz.setPlayerStorage(cid, {state = state})
end

function Dz.getTeam(cid)
  return Dz.getPlayerStorage(cid).team
end

function Dz.setTeam(cid, team)
  Dz.setPlayerStorage(cid, {team = team})
end

function Dz.getEventId(cid)
  return Dz.getPlayerStorage(cid).eventId
end

function Dz.setEventId(cid, eventId)
  Dz.setPlayerStorage(cid, {eventId = eventId})
end

function Dz.resetStorage(cid)
  setPlayerStorageValue(cid, Dz.PlayerStorage, json.encode({state = DzStateNone, team = "", diff = 0, mapId = 0, roomId = 0, eventId = 0, prizeRoomId = 0, potions = 0, revives = 0}))
end

---

function isInRange(pos, fromPos, toPos)
  return
  pos.x>=fromPos.x and pos.y>=fromPos.y and pos.z>=fromPos.z and
  pos.x<=toPos.x and pos.y<=toPos.y and pos.z<=toPos.z
end