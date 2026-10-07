local Calendar, MonthPanel, ShopPanel, ShopScrollBar
-- local bankButton = nil
local currentMonth, currentYear
local Key = "Ctrl+J"
local OPCODE = 62

function init()

  --  = modules.client_topmenu.addLeftGameToggleButton('bankButton', 
    -- tr('Premio Diario') .. ' (Ctrl+J)', '/images/topbuttons/calendar', toggle)
  -- bankButton:setOn(false)
  
  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = refresh,
  })
  Calendar = g_ui.loadUI('calendar', modules.game_interface.getRootPanel())
  MonthPanel = Calendar:getChildById("monthPanel")
  ShopPanel = Calendar:getChildById("shopPanel")
  ShopScrollBar = Calendar:getChildById('shopScrollBar')
 
  Calendar:hide()
  
  -- g_keyboard.bindKeyDown(Key, toggle)

  ProtocolGame.registerExtendedOpcode(OPCODE, parseDailyReward)
end

function terminate()
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = refresh,
  })
  
  -- g_keyboard.unbindKeyDown(Key, toggle)

  ProtocolGame.unregisterExtendedOpcode(OPCODE)
  Calendar:destroy()
  -- closeChests()
end

function refresh()
  Calendar:hide()
  ShopPanel:destroyChildren()
  closeChests()
end

function toggle()
  if Calendar:isVisible() then
    Calendar:hide()
	closeChests()
  else
    Calendar:show()
	closeChests()
  end
end

function showCalendar()
  ShopPanel:hide()
  ShopScrollBar:hide()
  MonthPanel:show()
  closeChests()
end

function showShop()
  MonthPanel:hide()
  ShopPanel:show()
  ShopScrollBar:show()
end

function buyShopItem(id)
  g_game.getProtocolGame():sendExtendedOpcode(OPCODE, '###BUYITEM###'..id)
end

function requestCalendar(value)
  currentMonth = currentMonth + value
  if currentMonth == 13 then
    currentYear = currentYear + 1
	currentMonth = 1
  elseif currentMonth == 0 then
    currentYear = currentYear - 1
	currentMonth = 12
  end
  g_game.getProtocolGame():sendExtendedOpcode(OPCODE, currentMonth..'REQUEST'..currentYear)
end

function parseDailyReward(protocol, opcode, buffer)
  local player = g_game.getLocalPlayer()
  if not player then return end
  local receive = table.fromLiteral(buffer)
  if receive[3] == "rewards" then
    local tab = Protocol_read(receive)
	-- Calendar:getChildById("points"):setText(tab.points) -- Quantidade de Pontos
    currentMonth = tab.month
    currentYear = tab.year
	drawMonth(currentMonth, currentYear, tab.rewards, tab.currentDate)
	
	if tab.points == 5 or tab.points <= 9 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 10 or tab.points <= 14 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 15 or tab.points <= 19 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 20 or tab.points <= 24 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 25 or tab.points <= 29 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 30 or tab.points <= 34 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 35 or tab.points <= 39 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 40 or tab.points <= 44 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 45 or tab.points <= 49 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):hide()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):show()
	elseif tab.points == 50 then
		Calendar:getChildById("rewardWidge"):getChildById("bar5"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar10"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar15"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar20"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar25"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar30"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar35"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar40"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar45"):show()
		Calendar:getChildById("rewardWidge"):getChildById("bar50"):show()
		
		Calendar:getChildById("rewardWidge"):getChildById("normalChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("silverChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("goldChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("diamondChest"):show()
		Calendar:getChildById("rewardWidge"):getChildById("emeraldChest"):show()
		
		Calendar:getChildById("rewardWidge"):getChildById("closednormalChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedsilverChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedgoldChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closeddiamondChest"):hide()
		Calendar:getChildById("rewardWidge"):getChildById("closedemeraldChest"):hide()
	end
	
  elseif receive[3] == "points" then
    local points = Protocol_read(receive)
    Calendar:getChildById("points"):setText(points)
  elseif receive[3] == "shop" then
    local shop = Protocol_read(receive)
	for id, info in pairs(shop) do
	  local widget = g_ui.createWidget("DRShopWidget", ShopPanel)
	  widget:setId("shop"..id)
	  widget:getChildById("item"):setItemId(info.itemId)
	  widget:getChildById("item"):setItemCount(info.qnt)
	  widget:getChildById("name"):setText(info.name.."("..info.qnt..")")
	  widget:getChildById("price"):setText(tr("Price")..": "..info.price)
	  widget:getChildById("buy").onClick = function()
	    buyShopItem(id)
	  end
	end
  end

end

--- FUNÇÕES DE SUPORTE

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

months = {
  [January]   =  {name = "Janeiro"  },
  [February]  =  {name = "Fevereiro"},
  [March]     =  {name = "Março"   },
  [April]     =  {name = "Abril"   },
  [May]       =  {name = "Maio"    },
  [June]      =  {name = "Junho"   },
  [July]      =  {name = "Julho"   },
  [August]    =  {name = "Agosto"  },
  [September] =  {name = "Setembro"},
  [October]   =  {name = "Outubro" },
  [November]  =  {name = "Novembro"},
  [December]  =  {name = "Dezembro"},
}

function drawMonth(month, year, rewards, currentDate)
  MonthPanel:getChildById("month"):setText(months[month].name.." "..year.."")
  MonthPanel:getChildById("days"):destroyChildren()
  local weekChar = {"Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"}
  local line = 1
  local column = 1
  local maxColumn = 7
  local maxLine = 5
  for w=1, 7 do
    local widget = g_ui.createWidget("WeekWidget", MonthPanel:getChildById("days"))
	widget:setId(weekChar[w])
	widget:setText(weekChar[w])
    widget:setMarginTop((1 + widget:getHeight()) * (line - 1))
    widget:setMarginLeft((7 + widget:getWidth()) * (column - 1))
    if (column < maxColumn) then
      column = column+1
    else
      line = line+1
      column = 1
    end
  end
  -------------------------------------------------
  local weekDay = getFirstMonthDay(month, year)
  local monthDays = getWeekNumDays(month, year)
  
  for day=(1-weekDay), monthDays do
    local widget = g_ui.createWidget("DayWidget", MonthPanel:getChildById("days"))
	widget:setId(tostring(day))
	
    widget:setMarginTop(((1 + (line == 1 and 20 or widget:getHeight())) * (line - 1)) - (line > 1 and 20 or 0))
    widget:setMarginLeft((7 + widget:getWidth()) * (column - 1))
    if (column < maxColumn) then
      column = column+1
    else
      line = line+1
      column = 1
    end
	if day > 0 then
	  widget:getChildById("name"):setText(day)
	  if rewards[day] then
	    widget:getChildById("item"):setItemId(rewards[day].itemid)
	    widget:getChildById("item"):setItemCount(rewards[day].count)
		if day <= currentDate.day and month <= currentDate.month and year <= currentDate.year then
		  widget:getChildById("mask"):setImageSource(rewards[day].collected == 1 and "images/collected" or "images/lost")
		  widget:getChildById("mask"):setVisible(true)
		end
	  end
	  if day == currentDate.day and (rewards[day] and rewards[day].collected <= 0) then
	    widget:setTooltip("Coletar recompensa")
		widget:getChildById("mask"):setImageSource("images/collect") -- imagem antes de coletar
	    widget.onClick = function()
		  g_game.getProtocolGame():sendExtendedOpcode(OPCODE, 'COLLECT')
		end
	  end
	end
  end
  for c = column, maxColumn do
    local widget = g_ui.createWidget("DayWidget", MonthPanel:getChildById("days"))
	widget:setId("extra"..c)
    widget:setMarginTop(((1 + (line == 2 and 20 or widget:getHeight())) * (line - 1)) - (line > 2 and 20 or 0))
    widget:setMarginLeft((7 + widget:getWidth()) * (column - 1))
    if (column < maxColumn) then
      column = column+1
    else
      line = line+1
      column = 1
    end
  end
end

function getFirstMonthDay(month, year)
  local weekDay = Tuesday
  for i=1900, (year-1), 1 do
    weekDay = (weekDay + 365) % 7
	if (isYearLeap(i)) then
	  weekDay = (weekDay + 1) % 7
	end
  end
  for i=1, (month-1) do
    weekDay = (weekDay + getWeekNumDays(i, year)) % 7
  end
  return weekDay
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

function NormalChestOpen()
local Chest = Calendar:getChildById("rewardWidge"):getChildById("normalChest")

  scheduleEvent(function() Chest:setImageSource("images/baus/normal/1") end, 100)
  scheduleEvent(function() Chest:setImageSource("images/baus/normal/2") end, 200)
  scheduleEvent(function() Chest:setImageSource("images/baus/normal/3") end, 300)
  scheduleEvent(function() Chest:setImageSource("images/baus/normal/4") end, 400)
  scheduleEvent(function() Chest:setImageSource("images/baus/normal/5") end, 500)
  scheduleEvent(function() Chest:setImageSource("images/baus/normal/6") end, 600)
  scheduleEvent(function() Chest:setImageSource("images/baus/normal/7") end, 700)
  scheduleEvent(function() Chest:setImageSource("images/baus/normal/8") end, 800)
end
function SilverChestOpen()
local Chest = Calendar:getChildById("rewardWidge"):getChildById("silverChest")

  scheduleEvent(function() Chest:setImageSource("images/baus/silver/1") end, 100)
  scheduleEvent(function() Chest:setImageSource("images/baus/silver/2") end, 200)
  scheduleEvent(function() Chest:setImageSource("images/baus/silver/3") end, 300)
  scheduleEvent(function() Chest:setImageSource("images/baus/silver/4") end, 400)
  scheduleEvent(function() Chest:setImageSource("images/baus/silver/5") end, 500)
  scheduleEvent(function() Chest:setImageSource("images/baus/silver/6") end, 600)
  scheduleEvent(function() Chest:setImageSource("images/baus/silver/7") end, 700)
end
function GoldChestOpen()
local Chest = Calendar:getChildById("rewardWidge"):getChildById("goldChest")

  scheduleEvent(function() Chest:setImageSource("images/baus/gold/1") end, 100)
  scheduleEvent(function() Chest:setImageSource("images/baus/gold/2") end, 200)
  scheduleEvent(function() Chest:setImageSource("images/baus/gold/3") end, 300)
  scheduleEvent(function() Chest:setImageSource("images/baus/gold/4") end, 400)
  scheduleEvent(function() Chest:setImageSource("images/baus/gold/5") end, 500)
  scheduleEvent(function() Chest:setImageSource("images/baus/gold/6") end, 600)
  scheduleEvent(function() Chest:setImageSource("images/baus/gold/7") end, 700)
  scheduleEvent(function() Chest:setImageSource("images/baus/gold/8") end, 800)
end
function DiamondChestOpen()
local Chest = Calendar:getChildById("rewardWidge"):getChildById("diamondChest")

  scheduleEvent(function() Chest:setImageSource("images/baus/diamond/1") end, 100)
  scheduleEvent(function() Chest:setImageSource("images/baus/diamond/2") end, 200)
  scheduleEvent(function() Chest:setImageSource("images/baus/diamond/3") end, 300)
  scheduleEvent(function() Chest:setImageSource("images/baus/diamond/4") end, 400)
  scheduleEvent(function() Chest:setImageSource("images/baus/diamond/5") end, 500)
  scheduleEvent(function() Chest:setImageSource("images/baus/diamond/6") end, 600)
  scheduleEvent(function() Chest:setImageSource("images/baus/diamond/7") end, 700)
  scheduleEvent(function() Chest:setImageSource("images/baus/diamond/8") end, 800)
end
function EmeraldChestOpen()
local Chest = Calendar:getChildById("rewardWidge"):getChildById("emeraldChest")

  scheduleEvent(function() Chest:setImageSource("images/baus/emerald/1") end, 100)
  scheduleEvent(function() Chest:setImageSource("images/baus/emerald/2") end, 200)
  scheduleEvent(function() Chest:setImageSource("images/baus/emerald/3") end, 300)
  scheduleEvent(function() Chest:setImageSource("images/baus/emerald/4") end, 400)
  scheduleEvent(function() Chest:setImageSource("images/baus/emerald/5") end, 500)
  scheduleEvent(function() Chest:setImageSource("images/baus/emerald/6") end, 600)
  scheduleEvent(function() Chest:setImageSource("images/baus/emerald/7") end, 700)
  scheduleEvent(function() Chest:setImageSource("images/baus/emerald/8") end, 800)
end

function closeChests()
local Panel = Calendar:getChildById("rewardWidge")
	Panel:getChildById("bar5"):hide()
	Panel:getChildById("bar10"):hide()
	Panel:getChildById("bar15"):hide()
	Panel:getChildById("bar20"):hide()
	Panel:getChildById("bar25"):hide()
	Panel:getChildById("bar30"):hide()
	Panel:getChildById("bar35"):hide()
	Panel:getChildById("bar40"):hide()
	Panel:getChildById("bar45"):hide()
	Panel:getChildById("bar50"):hide()
	Panel:getChildById("normalChest"):setImageSource("images/baus/normal/1")
	Panel:getChildById("silverChest"):setImageSource("images/baus/silver/1")
	Panel:getChildById("goldChest"):setImageSource("images/baus/gold/1")
	Panel:getChildById("diamondChest"):setImageSource("images/baus/diamond/1")
	Panel:getChildById("emeraldChest"):setImageSource("images/baus/emerald/1")
end