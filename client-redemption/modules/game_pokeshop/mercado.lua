function CityShow()
  g_effects.fadeIn(mercadoPanel:getChildById("voltarMercado"), 250)
  g_effects.fadeIn(mercadoPanel:getChildById("CityListPanel"), 250)
  scheduleEvent(function() mercadoPanel:getChildById("voltarMercado"):show() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("CityListPanel"):show() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("CityListScrollBar"):show() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("TitleCidade"):show() end, 251)

  g_effects.fadeOut(mercadoPanel:getChildById("TitleProdutos"), 250)
  g_effects.fadeOut(mercadoPanel:getChildById("TitleVip"), 250)
  g_effects.fadeOut(mercadoPanel:getChildById("VipListPanel"), 250)
  g_effects.fadeOut(mercadoPanel:getChildById("ItemListPanel"), 250)
  g_effects.fadeOut(mercadoPanel:getChildById("ItemListScrollBar"), 250)

  scheduleEvent(function() mercadoPanel:getChildById("TitleProdutos"):hide() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("TitleVip"):hide() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("VipListPanel"):hide() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("ItemListPanel"):hide() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("ItemListScrollBar"):hide() end, 251)
end
function CityClose()
  g_effects.fadeOut(mercadoPanel:getChildById("voltarMercado"), 250)
  g_effects.fadeOut(mercadoPanel:getChildById("CityListPanel"), 250)
  scheduleEvent(function() mercadoPanel:getChildById("voltarMercado"):hide() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("CityListPanel"):hide() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("CityListScrollBar"):hide() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("TitleCidade"):hide() end, 251)
  
  g_effects.fadeIn(mercadoPanel:getChildById("TitleProdutos"), 250)
  g_effects.fadeIn(mercadoPanel:getChildById("TitleVip"), 250)
  g_effects.fadeIn(mercadoPanel:getChildById("VipListPanel"), 250)
  g_effects.fadeIn(mercadoPanel:getChildById("ItemListPanel"), 250)
  g_effects.fadeIn(mercadoPanel:getChildById("ItemListScrollBar"), 250)

  scheduleEvent(function() mercadoPanel:getChildById("TitleProdutos"):show() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("TitleVip"):show() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("VipListPanel"):show() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("ItemListPanel"):show() end, 251)
  scheduleEvent(function() mercadoPanel:getChildById("ItemListScrollBar"):show() end, 251)
end


function Ditto()
---Config
local Item_Id = 1
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyDitto()
---Config
local Item_Id = 2
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Bless()
---Config
local Item_Id = 3
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function BlessPlus()
---Config
local Item_Id = 4
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function BlessUltra()
---Config
local Item_Id = 5
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function genero()
---Config
local Item_Id = 7
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function name()
---Config
local Item_Id = 8
local Sell_Name = marketOffers[Item_Id][1]
local Value_Diamond = marketOffers[Item_Id][2]
local Value_PokeCoin = marketOffers[Item_Id][3]

---Functions
local Diamond = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() 
  shopWindow:getChildById("WindowSelectedName"):show() 
  shopWindow:getChildById("WindowSelectedName"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) 
  shopWindow:getChildById("WindowSelectedName"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
  shopWindow:getChildById("WindowSelectedName"):getChildById("Enviar").onClick = function(self) onTextChangeDiamond(self:getParent():getChildById("search")) end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() 
  shopWindow:getChildById("WindowSelectedName"):show() 
  shopWindow:getChildById("WindowSelectedName"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) 
  shopWindow:getChildById("WindowSelectedName"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  
  shopWindow:getChildById("WindowSelectedName"):getChildById("Enviar").onClick = function(self) onTextChangePokecoin(self:getParent():getChildById("search")) end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Profission()
---Config
local Item_Id = 9
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Stamina()
---Config
local Item_Id = 11
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Vip30()
---Config
local Item_Id = 12
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Vip60()
---Config
local Item_Id = 13
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Vip90()
---Config
local Item_Id = 14
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Pallet()
---Config
local Item_Id = 15
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Viridian()
---Config
local Item_Id = 16
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Pewter()
---Config
local Item_Id = 17
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Cerulean()
---Config
local Item_Id = 18
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Vermilion()
---Config
local Item_Id = 19
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Lavender()
---Config
local Item_Id = 20
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Celadon()
---Config
local Item_Id = 21
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Fuchsia()
---Config
local Item_Id = 22
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Saffron()
---Config
local Item_Id = 23
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function Cinnabar()
---Config
local Item_Id = 24
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city') shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/item/city')  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end