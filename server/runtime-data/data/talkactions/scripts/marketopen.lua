-- Development only (GM): opens the market at the player's position and reloads listings from the database.
function onSay(cid, words, param)
  local p = getCreaturePosition(cid)
  doPlayerSetStorageValue(cid, playersStorages.marketPos, ",X:"..p.x..",Y:"..p.y..",Z:"..p.z..",S:0")
  getMarketItems()
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(Protocol_create("refreshall")))
  return true
end
