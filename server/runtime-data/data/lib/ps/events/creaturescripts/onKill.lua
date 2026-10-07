function onKill(cid, target, lastHit)
  local name = getCreatureName(target)
  if (not isSummon(target) and not getPokemonSummon(target)) then
    if isPlayer(cid) and (lastHit) then
      local value = Dz.getPlayerStorage(cid)
	  print(value.state, value.diff, value.mapId, value.roomId)
      if value.state == DzStateBattle then
        local Map = Dz.Diff[value.diff].Maps[value.mapId]
        local Room = Map.rooms[value.roomId]
		if getCreatureName(target) == Room.boss.name then
          Dz.teleportToPrize(value.diff, value.mapId, value.roomId)
		else
          Room.variable.pokemonCount = Room.variable.pokemonCount - 1
          if Room.variable.pokemonCount == 0 then
			table.insert(Room.variable.pokemons, doCreateMonster(Room.boss.name, Room.boss.pos))
          end
		  for _, name in pairs(Room.variable.members) do
		    local player = getPlayerByName(name)
			if isPlayer(player) then
		      doSendPlayerExtendedOpcode(player, Dz.Opcode, json.encode({protocol = "pokemoncount", count = Room.variable.pokemonCount}))
		    end
		  end
		end
      end
	end
    doQuestDefeat(cid, name)
    if (lastHit) then
      RangerClub.onPlayerKill(cid, name)
      --            HalloweenEvent.onPlayerKill(cid, target, lastHit)
      -- AnniversaryEvent.onPlayerKill(cid, target, lastHit)
      --EasterEvent.ThisIsEaster.onPlayerKill(cid, target, lastHit)
      --            ChristmasEvent.onPlayerKill(cid, target, lastHit)
    end
  end
  return true
end