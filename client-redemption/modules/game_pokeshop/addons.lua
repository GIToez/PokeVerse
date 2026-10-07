-- ACTION FUNCTIONS \/
function shinySelect()
	g_effects.fadeOut(addonsPanel:getChildById("TitleNormal"), 250)
	g_effects.fadeIn(addonsPanel:getChildById("TitleShiny"), 250)
    scheduleEvent(function() addonsPanel:getChildById("TitleShiny"):show() end, 0)
	addonsPanel:getChildById("Normal"):setImageSource('images/addons/buttons/normal')
	addonsPanel:getChildById("Shiny"):setImageSource('images/addons/buttons/shiny_selected')

    scheduleEvent(function() g_effects.fadeOut(addonsPanel:getChildById("NormalListPanel"), 250) end, 251)
    scheduleEvent(function() g_effects.fadeOut(addonsPanel:getChildById("NormalListScrollBar"), 250) end, 251)
    scheduleEvent(function() addonsPanel:getChildById("NormalListPanel"):hide() end, 251)
    scheduleEvent(function() addonsPanel:getChildById("NormalListScrollBar"):hide() end, 251)
	
    scheduleEvent(function() g_effects.fadeIn(addonsPanel:getChildById("ShinyListPanel"), 250) end, 251)
    scheduleEvent(function() g_effects.fadeIn(addonsPanel:getChildById("ShinyListScrollBar"), 250) end, 251)
    scheduleEvent(function() addonsPanel:getChildById("ShinyListPanel"):show() end, 251)
    scheduleEvent(function() addonsPanel:getChildById("ShinyListScrollBar"):show() end, 251)
end
function normalSelect()
	g_effects.fadeOut(addonsPanel:getChildById("TitleShiny"), 250)
	g_effects.fadeIn(addonsPanel:getChildById("TitleNormal"), 250)
	addonsPanel:getChildById("Normal"):setImageSource('images/addons/buttons/normal_selected')
	addonsPanel:getChildById("Shiny"):setImageSource('images/addons/buttons/shiny')

    scheduleEvent(function() g_effects.fadeOut(addonsPanel:getChildById("ShinyListPanel"), 250) end, 251)
    scheduleEvent(function() g_effects.fadeOut(addonsPanel:getChildById("ShinyListScrollBar"), 250) end, 251)
    scheduleEvent(function() addonsPanel:getChildById("ShinyListPanel"):hide() end, 251)
    scheduleEvent(function() addonsPanel:getChildById("ShinyListScrollBar"):hide() end, 251)
	
    scheduleEvent(function() g_effects.fadeIn(addonsPanel:getChildById("NormalListPanel"), 250) end, 251)
    scheduleEvent(function() g_effects.fadeIn(addonsPanel:getChildById("NormalListScrollBar"), 250) end, 251)
    scheduleEvent(function() addonsPanel:getChildById("NormalListPanel"):show() end, 251)
    scheduleEvent(function() addonsPanel:getChildById("NormalListScrollBar"):show() end, 251)
end
-- ACTION FUNCTIONS /\
-- BUY FUNCTIONS

function ancient()
---Config
local Item_Id = 154
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function armorcore()
---Config
local Item_Id = 155
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function battlearmor()
---Config
local Item_Id = 156
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function bearcostume()
---Config
local Item_Id = 157
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function blackadamcostume()
---Config
local Item_Id = 158
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function blueflamesmage()
---Config
local Item_Id = 159
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cowboycostume()
---Config
local Item_Id = 160
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cyborgarmor1()
---Config
local Item_Id = 161
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cyborgarmor2()
---Config
local Item_Id = 162
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cyborgarmor3()
---Config
local Item_Id = 163
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cyborgarmor4()
---Config
local Item_Id = 164
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cyborgarmor5()
---Config
local Item_Id = 165
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cyborgarmor6()
---Config
local Item_Id = 166
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function deathunicorn()
---Config
local Item_Id = 167
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function death()
---Config
local Item_Id = 168
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function definitelynotmagikarp()
---Config
local Item_Id = 169
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function djcostume()
---Config
local Item_Id = 170
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function firemage()
---Config
local Item_Id = 171
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function flinstone()
---Config
local Item_Id = 172
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function genius()
---Config
local Item_Id = 173
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function guard()
---Config
local Item_Id = 174
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function guardianarmor()
---Config
local Item_Id = 175
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function icebearcostume()
---Config
local Item_Id = 176
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function lancesclothes()
---Config
local Item_Id = 177
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function leonciocostume()
---Config
local Item_Id = 178
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function malevolacostume()
---Config
local Item_Id = 179
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function mariocostume()
---Config
local Item_Id = 180
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function metalarmor()
---Config
local Item_Id = 181
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function peakyblinderscostume1()
---Config
local Item_Id = 182
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function peakyblinderscostume2()
---Config
local Item_Id = 183
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pegasuscostume()
---Config
local Item_Id = 184
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function robotunicorn()
---Config
local Item_Id = 185
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function rockstar()
---Config
local Item_Id = 186
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function serpentarmor()
---Config
local Item_Id = 187
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shazamcostume()
---Config
local Item_Id = 188
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function thorcostume()
---Config
local Item_Id = 189
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function tropicalcostume()
---Config
local Item_Id = 190
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function wordchampionrobe()
---Config
local Item_Id = 191
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function yakuzacostume()
---Config
local Item_Id = 192
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function adventurouspirate()
---Config
local Item_Id = 193
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function wonderwoman()
---Config
local Item_Id = 194
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ryujincostume()
---Config
local Item_Id = 195
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function girlpower()
---Config
local Item_Id = 196
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pufferfishcostume()
---Config
local Item_Id = 197
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function happyoctopuscostume()
---Config
local Item_Id = 198
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function octopuscostume()
---Config
local Item_Id = 199
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function flashcostume()
---Config
local Item_Id = 200
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cyborgarmor7()
---Config
local Item_Id = 201
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/normal/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function millenniuminspiration()
---Config
local Item_Id = 202
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function supremedeity()
---Config
local Item_Id = 203
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function blackraven()
---Config
local Item_Id = 204
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function diamondfury()
---Config
local Item_Id = 205
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function aldebarancostume()
---Config
local Item_Id = 206
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function babykurama()
---Config
local Item_Id = 207
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinycyborgarmor1()
---Config
local Item_Id = 208
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinycyborgarmor2()
---Config
local Item_Id = 209
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinycyborgarmor3()
---Config
local Item_Id = 210
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinycyborgarmor4()
---Config
local Item_Id = 211
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinycyborgarmor5()
---Config
local Item_Id = 212
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinycyborgarmor6()
---Config
local Item_Id = 213
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function deathcostume()
---Config
local Item_Id = 214
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function demoncostume()
---Config
local Item_Id = 215
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function angelcostume()
---Config
local Item_Id = 216
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function jigsawcostume()
---Config
local Item_Id = 217
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function jokercostume()
---Config
local Item_Id = 218
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function thornarmor()
---Config
local Item_Id = 219
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinymetalarmor1()
---Config
local Item_Id = 220
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinymetalarmor2()
---Config
local Item_Id = 221
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinymetalarmor3()
---Config
local Item_Id = 222
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinymetalarmor4()
---Config
local Item_Id = 223
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinymetalarmor5()
---Config
local Item_Id = 224
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function terminator()
---Config
local Item_Id = 225
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function reggaecostume()
---Config
local Item_Id = 226
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function matlachines()
---Config
local Item_Id = 227
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function vampirecostume1()
---Config
local Item_Id = 228
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function vampirecostume2()
---Config
local Item_Id = 229
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function witchcostume1()
---Config
local Item_Id = 230
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function paniccostume()
---Config
local Item_Id = 231
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function werewolfcostume()
---Config
local Item_Id = 232
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function zombiecostume()
---Config
local Item_Id = 233
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function deathskull()
---Config
local Item_Id = 234
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function alphawerewolfcostume()
---Config
local Item_Id = 235
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function jasoncostume()
---Config
local Item_Id = 236
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function batmancostume()
---Config
local Item_Id = 237
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinycowboycostume()
---Config
local Item_Id = 238
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function bonearmor()
---Config
local Item_Id = 239
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function anbumask()
---Config
local Item_Id = 240
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function witchcostume2()
---Config
local Item_Id = 241
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function bridecostume()
---Config
local Item_Id = 242
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function bearcoat()
---Config
local Item_Id = 243
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function enjoyingsummer1()
---Config
local Item_Id = 244
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function enjoyingsummer2()
---Config
local Item_Id = 245
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function moonfairy()
---Config
local Item_Id = 246
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function kyubimoncostume()
---Config
local Item_Id = 247
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ahriatari()
---Config
local Item_Id = 248
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function kuramaasura()
---Config
local Item_Id = 249
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function greymoncostume()
---Config
local Item_Id = 250
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cavegladiator()
---Config
local Item_Id = 251
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function gabumoncostume()
---Config
local Item_Id = 252
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function dreggmancostume()
---Config
local Item_Id = 253
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function killercloak()
---Config
local Item_Id = 254
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local BuyDiamond = function()
  g_game.talk('/shopdiamond '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local BuyPokeCoin = function()
  g_game.talk('/shoppokecoin '..marketOffers[Item_Id][1])
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  cleartab()
end
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/addons/outfit/shiny/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end