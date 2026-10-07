
function LycanrocDepot()
---Config
local Item_Id = 255
local ImageIcon = "Lycanroc"
local Sell_Name = "LycanrocDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function AlolanVulpixDepot()
---Config
local Item_Id = 256
local ImageIcon = "AlolanVulpix"
local Sell_Name = "AlolanVulpixDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function SlurpuffDepot()
---Config
local Item_Id = 257
local ImageIcon = "Slurpuff"
local Sell_Name = "SlurpuffDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ComfeyDepot()
---Config
local Item_Id = 258
local ImageIcon = "Comfey"
local Sell_Name = "ComfeyDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function GliscorDepot()
---Config
local Item_Id = 259
local ImageIcon = "Gliscor"
local Sell_Name = "GliscorDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function LaprasDepot()
---Config
local Item_Id = 260
local ImageIcon = "Lapras"
local Sell_Name = "LaprasDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function GauntletDepot()
---Config
local Item_Id = 261
local ImageIcon = "Gauntlet"
local Sell_Name = "GauntletDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function HoHoDepot()
---Config
local Item_Id = 262
local ImageIcon = "HoHo"
local Sell_Name = "HoHoDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function PrimarinaDepot()
---Config
local Item_Id = 263
local ImageIcon = "Primarina"
local Sell_Name = "PrimarinaDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function IncineroarDepot()
---Config
local Item_Id = 264
local ImageIcon = "Incineroar"
local Sell_Name = "IncineroarDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function LucarioDepot()
---Config
local Item_Id = 265
local ImageIcon = "Lucario"
local Sell_Name = "LucarioDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function LugiaDepot()
---Config
local Item_Id = 266
local ImageIcon = "Lugia"
local Sell_Name = "LugiaDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function LunalaDepot()
---Config
local Item_Id = 267
local ImageIcon = "Lunala"
local Sell_Name = "LunalaDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function StarDepot()
---Config
local Item_Id = 268
local ImageIcon = "Star"
local Sell_Name = "StarDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function SolgaleoDepot()
---Config
local Item_Id = 269
local ImageIcon = "Solgaleo"
local Sell_Name = "SolgaleoDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function VespiquenDepot()
---Config
local Item_Id = 270
local ImageIcon = "Vespiquen"
local Sell_Name = "VespiquenDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MimikyuDepot()
---Config
local Item_Id = 271
local ImageIcon = "Mimikyu"
local Sell_Name = "MimikyuDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MismagiusDepot()
---Config
local Item_Id = 272
local ImageIcon = "Mismagius"
local Sell_Name = "MismagiusDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MoltresDepot()
---Config
local Item_Id = 273
local ImageIcon = "Moltres"
local Sell_Name = "MoltresDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ZapdosDepot()
---Config
local Item_Id = 274
local ImageIcon = "Zapdos"
local Sell_Name = "ZapdosDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ArticunoDepot()
---Config
local Item_Id = 275
local ImageIcon = "Articuno"
local Sell_Name = "ArticunoDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function RaikoDepot()
---Config
local Item_Id = 276
local ImageIcon = "Raiko"
local Sell_Name = "RaikoDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function SuicuneDepot()
---Config
local Item_Id = 277
local ImageIcon = "Suicune"
local Sell_Name = "SuicuneDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function EnteiDepot()
---Config
local Item_Id = 278
local ImageIcon = "Entei"
local Sell_Name = "EnteiDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MewDepot()
---Config
local Item_Id = 279
local ImageIcon = "Mew"
local Sell_Name = "MewDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MewthoDepot()
---Config
local Item_Id = 280
local ImageIcon = "Mewtho"
local Sell_Name = "MewthoDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function UmbreonDepot()
---Config
local Item_Id = 281
local ImageIcon = "Umbreon"
local Sell_Name = "UmbreonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function FlareonDepot()
---Config
local Item_Id = 282
local ImageIcon = "Flareon"
local Sell_Name = "FlareonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function VaporeonDepot()
---Config
local Item_Id = 283
local ImageIcon = "Vaporeon"
local Sell_Name = "VaporeonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function JolteonDepot()
---Config
local Item_Id = 284
local ImageIcon = "Jolteon"
local Sell_Name = "JolteonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyUmbreonDepot()
---Config
local Item_Id = 285
local ImageIcon = "ShinyUmbreon"
local Sell_Name = "ShinyUmbreonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ChandelureDepot()
---Config
local Item_Id = 286
local ImageIcon = "Chandelure"
local Sell_Name = "ChandelureDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MegaBanneteDepot()
---Config
local Item_Id = 287
local ImageIcon = "MegaBannete"
local Sell_Name = "MegaBanneteDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function HypnoDepot()
---Config
local Item_Id = 288
local ImageIcon = "Hypno"
local Sell_Name = "HypnoDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function NinetalesDepot()
---Config
local Item_Id = 289
local ImageIcon = "Ninetales"
local Sell_Name = "NinetalesDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MegaBlastoiseDepot()
---Config
local Item_Id = 290
local ImageIcon = "MegaBlastoise"
local Sell_Name = "MegaBlastoiseDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyCharizardDepot()
---Config
local Item_Id = 291
local ImageIcon = "ShinyCharizard"
local Sell_Name = "ShinyCharizardDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MegaCharizardXDepot()
---Config
local Item_Id = 292
local ImageIcon = "MegaCharizardX"
local Sell_Name = "MegaCharizardXDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MegaCharizardYDepot()
---Config
local Item_Id = 293
local ImageIcon = "MegaCharizardY"
local Sell_Name = "MegaCharizardYDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MegaVenusaurDepot()
---Config
local Item_Id = 294
local ImageIcon = "MegaVenusaur"
local Sell_Name = "MegaVenusaurDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function GyaradosDepot()
---Config
local Item_Id = 295
local ImageIcon = "Gyarados"
local Sell_Name = "GyaradosDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyGyaradosDepot()
---Config
local Item_Id = 296
local ImageIcon = "ShinyGyarados"
local Sell_Name = "ShinyGyaradosDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MegaGyaradosDepot()
---Config
local Item_Id = 297
local ImageIcon = "MegaGyarados"
local Sell_Name = "MegaGyaradosDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MetagrossDepot()
---Config
local Item_Id = 298
local ImageIcon = "Metagross"
local Sell_Name = "MetagrossDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyMegaMetagrossDepot()
---Config
local Item_Id = 299
local ImageIcon = "ShinyMegaMetagross"
local Sell_Name = "ShinyMegaMetagrossDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function RoseradeDepot()
---Config
local Item_Id = 300
local ImageIcon = "Roserade"
local Sell_Name = "RoseradeDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function BudewDepot()
---Config
local Item_Id = 301
local ImageIcon = "Budew"
local Sell_Name = "BudewDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyMegaGardevoirDepot()
---Config
local Item_Id = 302
local ImageIcon = "ShinyMegaGardevoir"
local Sell_Name = "ShinyMegaGardevoirDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyMegaGalladeDepot()
---Config
local Item_Id = 303
local ImageIcon = "ShinyMegaGallade"
local Sell_Name = "ShinyMegaGalladeDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function RayquazaDepot()
---Config
local Item_Id = 304
local ImageIcon = "Rayquaza"
local Sell_Name = "RayquazaDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function GroudonDepot()
---Config
local Item_Id = 305
local ImageIcon = "Groudon"
local Sell_Name = "GroudonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function KyogreDepot()
---Config
local Item_Id = 306
local ImageIcon = "Kyogre"
local Sell_Name = "KyogreDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function DetetivePikachuDepot()
---Config
local Item_Id = 307
local ImageIcon = "DetetivePikachu"
local Sell_Name = "DetetivePikachuDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function PrimeapeDepot()
---Config
local Item_Id = 308
local ImageIcon = "Primeape"
local Sell_Name = "PrimeapeDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ArcanineDepot()
---Config
local Item_Id = 309
local ImageIcon = "Arcanine"
local Sell_Name = "ArcanineDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function AerodactylDepot()
---Config
local Item_Id = 310
local ImageIcon = "Aerodactyl"
local Sell_Name = "AerodactylDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function BlastoiseDepot()
---Config
local Item_Id = 311
local ImageIcon = "Blastoise"
local Sell_Name = "BlastoiseDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyBlastoiseDepot()
---Config
local Item_Id = 312
local ImageIcon = "ShinyBlastoise"
local Sell_Name = "ShinyBlastoiseDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function VenusaurDepot()
---Config
local Item_Id = 313
local ImageIcon = "Venusaur"
local Sell_Name = "VenusaurDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ShinyVenusaurDepot()
---Config
local Item_Id = 314
local ImageIcon = "ShinyVenusaur"
local Sell_Name = "ShinyVenusaurDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function kecleonDepot()
---Config
local Item_Id = 315
local ImageIcon = "kecleon"
local Sell_Name = "kecleonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function MarshadowDepot()
---Config
local Item_Id = 316
local ImageIcon = "Marshadow"
local Sell_Name = "MarshadowDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ZoroarkDepot()
---Config
local Item_Id = 317
local ImageIcon = "Zoroark"
local Sell_Name = "ZoroarkDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function SylveonDepot()
---Config
local Item_Id = 318
local ImageIcon = "Sylveon"
local Sell_Name = "SylveonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function AbsolDepot()
---Config
local Item_Id = 319
local ImageIcon = "Absol"
local Sell_Name = "AbsolDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function AggronDepot()
---Config
local Item_Id = 320
local ImageIcon = "Aggron"
local Sell_Name = "AggronDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function CelebiDepot()
---Config
local Item_Id = 321
local ImageIcon = "Celebi"
local Sell_Name = "CelebiDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ElectivireDepot()
---Config
local Item_Id = 322
local ImageIcon = "Electivire"
local Sell_Name = "ElectivireDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function GardevoirDepot()
---Config
local Item_Id = 323
local ImageIcon = "Gardevoir"
local Sell_Name = "GardevoirDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function GengarDepot()
---Config
local Item_Id = 324
local ImageIcon = "Gengar"
local Sell_Name = "GengarDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function InfernapeDepot()
---Config
local Item_Id = 325
local ImageIcon = "Infernape"
local Sell_Name = "InfernapeDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function WitchJinxDepot()
---Config
local Item_Id = 326
local ImageIcon = "WitchJinx"
local Sell_Name = "WitchJinxDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function KangaskhanDepot()
---Config
local Item_Id = 327
local ImageIcon = "Kangaskhan"
local Sell_Name = "KangaskhanDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function RhydonDepot()
---Config
local Item_Id = 328
local ImageIcon = "Rhydon"
local Sell_Name = "RhydonDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function SceptileDepot()
---Config
local Item_Id = 329
local ImageIcon = "Sceptile"
local Sell_Name = "SceptileDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function DragonairDepot()
---Config
local Item_Id = 330
local ImageIcon = "Dragonair"
local Sell_Name = "DragonairDepot"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function lumineonaquarium()
---Config
local Item_Id = 331
local ImageIcon = "lumineonaquarium"
local Sell_Name = "lumineonaquarium"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function luvdiscaquarium()
---Config
local Item_Id = 332
local ImageIcon = "luvdiscaquarium"
local Sell_Name = "luvdiscaquarium"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function shinyluvdiscaquarium()
---Config
local Item_Id = 333
local ImageIcon = "shinyluvdiscaquarium"
local Sell_Name = "shinyluvdiscaquarium"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function vaporeonaquarium()
---Config
local Item_Id = 334
local ImageIcon = "vaporeonaquarium"
local Sell_Name = "vaporeonaquarium"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function luvdiscaquarium2()
---Config
local Item_Id = 335
local ImageIcon = "luvdiscaquarium2"
local Sell_Name = "luvdiscaquarium2"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function goldeenaquarium()
---Config
local Item_Id = 336
local ImageIcon = "goldeenaquarium"
local Sell_Name = "goldeenaquarium"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function magikarpaquarium()
---Config
local Item_Id = 337
local ImageIcon = "magikarpaquarium"
local Sell_Name = "magikarpaquarium"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function magictable()
---Config
local Item_Id = 338
local ImageIcon = "magictable"
local Sell_Name = "magictable"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function tentaclechair()
---Config
local Item_Id = 339
local ImageIcon = "tentaclechair"
local Sell_Name = "tentaclechair"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function videogametable1()
---Config
local Item_Id = 341
local ImageIcon = "videogametable1"
local Sell_Name = "videogametable1"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function videogametable2()
---Config
local Item_Id = 342
local ImageIcon = "videogametable2"
local Sell_Name = "videogametable2"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function videogametable3()
---Config
local Item_Id = 343
local ImageIcon = "videogametable3"
local Sell_Name = "videogametable3"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function videogametable4()
---Config
local Item_Id = 344
local ImageIcon = "videogametable4"
local Sell_Name = "videogametable4"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function electrabuzzsculpture()
---Config
local Item_Id = 345
local ImageIcon = "electrabuzzsculpture"
local Sell_Name = "electrabuzzsculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function charizardsculpture()
---Config
local Item_Id = 346
local ImageIcon = "charizardsculpture"
local Sell_Name = "charizardsculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function laprassculpture()
---Config
local Item_Id = 347
local ImageIcon = "laprassculpture"
local Sell_Name = "laprassculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function gyaradossculpture()
---Config
local Item_Id = 348
local ImageIcon = "gyaradossculpture"
local Sell_Name = "gyaradossculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function venusaursculpture()
---Config
local Item_Id = 349
local ImageIcon = "venusaursculpture"
local Sell_Name = "venusaursculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function steelixsculpture()
---Config
local Item_Id = 350
local ImageIcon = "steelixsculpture"
local Sell_Name = "steelixsculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function gastlysculpture()
---Config
local Item_Id = 351
local ImageIcon = "gastlysculpture"
local Sell_Name = "gastlysculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function hauntersculpture()
---Config
local Item_Id = 352
local ImageIcon = "hauntersculpture"
local Sell_Name = "hauntersculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function primeapesculpture()
---Config
local Item_Id = 353
local ImageIcon = "primeapesculpture"
local Sell_Name = "primeapesculpture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function curtainofhearts()
---Config
local Item_Id = 354
local ImageIcon = "curtainofhearts"
local Sell_Name = "curtainofhearts"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function curtainofmewtwo()
---Config
local Item_Id = 355
local ImageIcon = "curtainofmewtwo"
local Sell_Name = "curtainofmewtwo"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function curtainofblastoise()
---Config
local Item_Id = 356
local ImageIcon = "curtainofblastoise"
local Sell_Name = "curtainofblastoise"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function curtainofvenusaur()
---Config
local Item_Id = 357
local ImageIcon = "curtainofvenusaur"
local Sell_Name = "curtainofvenusaur"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function curtainofcharizard()
---Config
local Item_Id = 358
local ImageIcon = "curtainofcharizard"
local Sell_Name = "curtainofcharizard"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function curtainofmisdreavus()
---Config
local Item_Id = 359
local ImageIcon = "curtainofmisdreavus"
local Sell_Name = "curtainofmisdreavus"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function curtainofgolem()
---Config
local Item_Id = 360
local ImageIcon = "curtainofgolem"
local Sell_Name = "curtainofgolem"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function curtainofdragonite()
---Config
local Item_Id = 361
local ImageIcon = "curtainofdragonite"
local Sell_Name = "curtainofdragonite"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function scarypicture()
---Config
local Item_Id = 362
local ImageIcon = "scarypicture"
local Sell_Name = "scarypicture"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function greenaltar()
---Config
local Item_Id = 363
local ImageIcon = "greenaltar"
local Sell_Name = "greenaltar"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pinkaltar()
---Config
local Item_Id = 364
local ImageIcon = "pinkaltar"
local Sell_Name = "pinkaltar"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function yellowaltar()
---Config
local Item_Id = 365
local ImageIcon = "yellowaltar"
local Sell_Name = "yellowaltar"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pinkaltar2()
---Config
local Item_Id = 366
local ImageIcon = "pinkaltar2"
local Sell_Name = "pinkaltar2"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function plant1()
---Config
local Item_Id = 367
local ImageIcon = "plant1"
local Sell_Name = "plant1"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function plant2()
---Config
local Item_Id = 368
local ImageIcon = "plant2"
local Sell_Name = "plant2"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pinkrose()
---Config
local Item_Id = 369
local ImageIcon = "pinkrose"
local Sell_Name = "pinkrose"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function redrose()
---Config
local Item_Id = 370
local ImageIcon = "redrose"
local Sell_Name = "redrose"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treesprout()
---Config
local Item_Id = 371
local ImageIcon = "treesprout"
local Sell_Name = "treesprout"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function plant3()
---Config
local Item_Id = 372
local ImageIcon = "plant3"
local Sell_Name = "plant3"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function computergamer()
---Config
local Item_Id = 373
local ImageIcon = "computergamer"
local Sell_Name = "computergamer"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function guitar()
---Config
local Item_Id = 374
local ImageIcon = "guitar"
local Sell_Name = "guitar"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function coachsgauntlet()
---Config
local Item_Id = 375
local ImageIcon = "coachsgauntlet"
local Sell_Name = "coachsgauntlet"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function premieraltar()
---Config
local Item_Id = 376
local ImageIcon = "premieraltar"
local Sell_Name = "premieraltar"
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/decoracoes/icon/'..ImageIcon)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end