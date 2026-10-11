function doCheckOpenMarket(cid, toPosition)
  if not isCreature(cid) then return false end
  if getDistanceBetween(getCreaturePosition(cid), toPosition) > 1 then
	cancelMakeOfferOnLogout(cid)
    sendMarketClose(cid)
    return true
  end
  addEvent(doCheckOpenMarket, 1000, cid, toPosition)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
  local p = getThingPosition(item.uid)
  doPlayerSetStorageValue(cid, playersStorages.marketPos, ",X:"..p.x..",Y:"..p.y..",Z:"..p.z..",S:"..p.stackpos)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.Market, table.tostring(Protocol_create("refreshall")))
  doCheckOpenMarket(cid, toPosition)
  return true
end