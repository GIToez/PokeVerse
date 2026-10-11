function onLook(cid, thing, position, lookDistance)
local house = getHouseFromPos(getCreaturePosition(cid))
-- local houseId = 

if(house) then -- dentro da casa 
local owner = getHouseInfo(house).owner

	if(getHouseInfo(house).owner ~= getPlayerGUID(cid) and (getHouseInfo(house).owner ~= getPlayerGuildId(cid) or getPlayerGuildLevel(cid) ~= GUILDLEVEL_LEADER)) then 

    if getHouseFromPos(position) and getItemNameById(thing.itemid):find("door") then
       if getHouseOwner(getHouseFromPos(position)) ~= 0 then house_owner = getPlayerNameByGUID(getHouseOwner(getHouseFromPos(position))) else house_owner = "Nobody" end
    
       house_name = getHouseName(getHouseFromPos(position))
       house_town = getTownName(getHouseTown(getHouseFromPos(position)))
       house_size = getHouseTilesCount(getHouseFromPos(position))
       house_price = getHousePrice(getHouseFromPos(position))
       
       local house_information = string.format("house_data|%s|%s|%s|%u|%u", house_name, house_owner, house_town, house_size, house_price)
       return doSendPlayerExtendedOpcode(cid, 202, house_information) and false
    end
    elseif getHouseFromPos(position) and getItemNameById(thing.itemid):find("door") then
       if getHouseOwner(getHouseFromPos(position)) ~= 0 then house_owner = getPlayerNameByGUID(getHouseOwner(getHouseFromPos(position))) else house_owner = "Nobody" end
    
       house_name = getHouseName(getHouseFromPos(position))
       house_town = getTownName(getHouseTown(getHouseFromPos(position)))
       house_size = getHouseTilesCount(getHouseFromPos(position))
       house_price = getHousePrice(getHouseFromPos(position))
       
       local house_information = string.format("house_data|%s|%s|%s|%u|%u", house_name, house_owner, house_town, house_size, house_price)
       return doSendPlayerExtendedOpcode(cid, 199, house_information) and false
    end

	return true
end
local house = getHouseFromPos(getCreaturePosition(cid))
if(not house) then

 local houseId = getHouseFromPos(position)
 if houseId and getItemNameById(thing.itemid):find("door") then
    if getHouseOwner(houseId) ~= 0 then house_owner = getPlayerNameByGUID(getHouseOwner(houseId)) else house_owner = "Nobody" end
 
    house_name = getHouseName(houseId)
    house_town = getTownName(getHouseTown(houseId))
    house_size = getHouseTilesCount(houseId)
    house_price = getHousePrice(houseId)
    
    local house_information = string.format("house_data|%s|%s|%s|%u|%u", house_name, house_owner, house_town, house_size, house_price)
    return doSendPlayerExtendedOpcode(cid, 201, house_information) and false
 end

	return true
end

if isPlayer(thing.uid) then     --player
   doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, getPlayerDesc(cid, thing.uid, false))  
return false
end

	return true
end