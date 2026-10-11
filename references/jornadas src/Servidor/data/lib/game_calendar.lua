January   = 1
February  = 2
March     = 3
April     = 4
May       = 5
June      = 6
July      = 7
August    = 8
September = 9
October   = 10
November  = 11
December  = 12

Monday    = 0
Tuesday   = 1
Wednesday = 2
Thursday  = 3
Friday    = 4
Saturday  = 5
Sunday    = 6

REWARDS = {}
REWARDS[2021] = {}

REWARDS[2021][September] = {
  [1] =  {itemid = 29838, count = 10, points = 5},
  [2] =  {itemid = 2673, count = 10, points = 5},
  [3] =  {itemid = 14463, count = 10, points = 5},
  [4] =  {itemid = 34271, count = 10, points = 5},
  [5] =  {itemid = 25498, count = 10, points = 5},
  [6] =  {itemid = 26083, count = 10, points = 5},
  [7] =  {itemid = 29129, count = 10, points = 5},
  [8] =  {itemid = 14463, count = 10, points = 5},
  [9] =  {itemid = 26873, count = 10, points = 5},
  [10] = {itemid = 27291, count = 10, points = 5},
  [11] = {itemid = 29769, count = 10, points = 5},
  [12] = {itemid = 25482, count = 10, points = 5},
  [13] = {itemid = 34279, count = 10, points = 5},
  [14] = {itemid = 29129, count = 10, points = 5},
  [15] = {itemid = 14463, count = 10, points = 5},
  [16] = {itemid = 34272, count = 10, points = 5},
  [17] = {itemid = 23523, count = 10, points = 5},
  [18] = {itemid = 34857, count = 10, points = 5},
  [19] = {itemid = 34858, count = 10, points = 5},
  [20] = {itemid = 34862, count = 10, points = 5},
  [21] = {itemid = 29129, count = 10, points = 5},
  [22] = {itemid = 14463, count = 10, points = 5},
  [23] = {itemid = 34273, count = 10, points = 5},
  [24] = {itemid = 29770, count = 10, points = 5},
  [25] = {itemid = 34873, count = 10, points = 5},
  [26] = {itemid = 34806, count = 10, points = 5},
  [27] = {itemid = 34865, count = 10, points = 5},
  [28] = {itemid = 29129, count = 10, points = 5},
  [29] = {itemid = 14463, count = 10, points = 5},
  [30] = {itemid = 29771, count = 10, points = 5},
  [31] = {itemid = 29772, count = 10, points = 5},
}

-- SHOP DAILY REWARDS

DRShop = {
  [1] = {itemId = 6843, qnt = 5, price = 5},
  [2] = {itemId = 2001, qnt = 5, price = 500},
  [3] = {itemId = 2002, qnt = 5, price = 500},
  [4] = {itemId = 2003, qnt = 5, price = 500},
  [7] = {itemId = 2004, qnt = 5, price = 500},
  [8] = {itemId = 2005, qnt = 5, price = 500},
  [9] = {itemId = 2006, qnt = 5, price = 500},
  [10] = {itemId = 2007, qnt = 5, price = 500},
  [11] = {itemId = 2008, qnt = 5, price = 500},
  [12] = {itemId = 2009, qnt = 5, price = 500},
}

function getDRPoints(cid)
  local points = getPlayerStorageValue(cid, 3457753)
  return points == -1 and 0 or points
end

function sendDRShop(cid)
  local shop = {}
  for id, info in pairs(DRShop) do
    shop[id] = {itemId = getItemInfo(info.itemId).clientId, name = getItemNameById(info.itemId), qnt = info.qnt, price = info.price}
    if #shop == 10 then
      local protocol = Protocol_create("shop")
      Protocol_add(protocol, shop)
      doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DailyReward, table.tostring(protocol))
	  shop = {}
	end
  end
  if #shop == 0 then return end
  local protocol = Protocol_create("shop")
  Protocol_add(protocol, shop)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DailyReward, table.tostring(protocol))
end

function buyDRShopItem(cid, id)
  if not DRShop[id] then return end
  local info = DRShop[id]
  local drPoints = getDRPoints(cid)
  if info.price > drPoints then
    doPlayerPopupFYI(cid, "Pontos de recompensas insuficientes")
	return
  end
  if not isItemStackable(info.itemId) and info.qnt > 1 then
    for qnt = 1, info.qnt do
      doPlayerAddItem(cid, info.itemId, 1)
    end
  else
    doPlayerAddItem(cid, info.itemId, info.qnt)
  end
  setPlayerStorageValue(cid, 3457753, drPoints - info.price)
  local protocol = Protocol_create("points")
  Protocol_add(protocol, drPoints - info.price)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DailyReward, table.tostring(protocol))
end

-----------------------------------------------------------------------------------------

function getDailyRewards(cid, month, year)
  if not month or not year then return end
  month = tonumber(month)
  year = tonumber(year)
  if year < 1900 then return end
  if month == 0 or month > 12 then return end
  if not REWARDS[year] then sendRewards(cid, month, year, {}) return end
  if not REWARDS[year][month] then sendRewards(cid, month, year, {}) return end
  sendRewards(cid, month, year, REWARDS[year][month])
end

function sendRewards(cid, month, year, rewards)
  local tab = {}
  tab.month = month
  tab.year = year
  tab.currentDate = {
    day = (os.date('*t').day),
    month = (os.date('*t').month),
    year = (os.date('*t').year),
  }
  tab.points = getDRPoints(cid)
  tab.rewards = {}
  for day, item in ipairs(rewards) do
  -- if day == 16 then print(getMonthDailyStorage(day, month, year)) end
    tab.rewards[day] = {
	  itemid = getItemInfo(item.itemid).clientId,
	  count = item.count,
	  collected = getPlayerStorageValue(cid, getMonthDailyStorage(day, month, year)),
	}
  end
  local protocol = Protocol_create("rewards")
  Protocol_add(protocol, tab)
  doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DailyReward, table.tostring(protocol))
end

function collectDailyReward(cid)
  local day = os.date('*t').day
  local month = os.date('*t').month
  local year = os.date('*t').year
  if not REWARDS[year] then return end
  if not REWARDS[year][month] then return end
  if not REWARDS[year][month][day] then return end
  -- SE O TEMPO TAL FOR INFERIOR AO TEMPO TAL CONFIGURADO RETURN
  local reward = REWARDS[year][month][day]
  local storage = getMonthDailyStorage(day, month, year)
  if getPlayerStorageValue(cid, storage) == 1 then
	return
  end
  doPlayerAddItem(cid, reward.itemid, reward.count or 1)
  setPlayerStorageValue(cid, storage, 1)
  setPlayerStorageValue(cid, 3457753, getDRPoints(cid) + (reward.points or 1))
  sendRewards(cid, month, year, REWARDS[year][month])
end

function getMonthDailyStorage(day, month, year)
  return (getFirstMonthDay(month, year) - getWeekNumDays(month, year)) + day
end

function getFirstMonthDay(month, year)
  local dayCount = 0
  for i=1900, (year-1), 1 do
    dayCount = (dayCount + 365)
	if (isYearLeap(i)) then
	  dayCount = (dayCount + 1)
	end
  end
  for i=1, (month-1) do
    dayCount = (dayCount + getWeekNumDays(i, year))
  end
  return dayCount
end

function isYearLeap(year)
  return ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0)
end

function getWeekNumDays(month, year)
  if month == February then
    return isYearLeap(year) and 29 or 28
  elseif month == April or month == June or month == September or month == November then
    return 30
  else
    return 31
  end
end