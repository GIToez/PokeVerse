function onUse(cid, item, fromPosition, itemEx, toPosition)
  local value = Dz.getPlayerStorage(cid)
  if value.state < DzStateBattle then return false end
  local Map = Dz.Diff[value.diff].Maps[value.mapId]
  local PrizeRoom = Dz.PrizeRooms[value.prizeRoomId]
  Dz.removePrizeRoom(value.prizeRoomId)
  doTeleportThing(cid, Dz.LobbyPosition.tp)
  for _, reward in pairs(Map.reward) do
    if math.random(1,100) < reward.chance then
      doPlayerAddItem(cid, reward.id, math.random(reward.qnt[1], reward.qnt[2]))
    end
  end
  doPlayerAddExperience(cid, Map.experience)
  Dz.resetStorage(cid)
  return true
end
