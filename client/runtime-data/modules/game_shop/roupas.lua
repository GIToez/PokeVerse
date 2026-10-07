function VoltarSelection()
  g_effects.fadeOut(roupasPanel:getChildById("MaleListPanel"), 250)
  g_effects.fadeOut(roupasPanel:getChildById("FemaleListPanel"), 250)
  g_effects.fadeOut(roupasPanel:getChildById("DuploListPanel"), 250)
  scheduleEvent(function() roupasPanel:getChildById("MaleListPanel"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("FemaleListPanel"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("DuploListPanel"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleMasculina"):hide() end, 251)    
  scheduleEvent(function() roupasPanel:getChildById("TitleFeminina"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleDuplo"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleGenero"):show() end, 252)

  scheduleEvent(function() roupasPanel:getChildById("MaleListScrollBar"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("FemaleListScrollBar"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("DuploListScrollBar"):hide() end, 251)

  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("SelectMale"), 250) end, 251)
  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("SelectGirl"), 250) end, 251)
  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("SelectDoble"), 250) end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectMale"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectGirl"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectDoble"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("VoltarSelection"):hide() end, 251)
end
function MaleShow()
  g_effects.fadeOut(roupasPanel:getChildById("SelectMale"), 250)
  g_effects.fadeOut(roupasPanel:getChildById("SelectGirl"), 250)
  g_effects.fadeOut(roupasPanel:getChildById("SelectDoble"), 250)
  scheduleEvent(function() roupasPanel:getChildById("SelectMale"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectGirl"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectDoble"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleGenero"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleMasculina"):show() end, 251)

  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("MaleListPanel"), 250) end, 251)
  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("MaleListScrollBar"), 250) end, 251)
  
  scheduleEvent(function() roupasPanel:getChildById("MaleListPanel"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("MaleListScrollBar"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("VoltarSelection"):show() end, 251)
end
function FemaleShow()
  g_effects.fadeOut(roupasPanel:getChildById("SelectMale"), 250)
  g_effects.fadeOut(roupasPanel:getChildById("SelectGirl"), 250)
  g_effects.fadeOut(roupasPanel:getChildById("SelectDoble"), 250)
  scheduleEvent(function() roupasPanel:getChildById("SelectMale"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectGirl"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectDoble"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleGenero"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleFeminina"):show() end, 251)

  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("FemaleListPanel"), 250) end, 251)
  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("FemaleListScrollBar"), 250) end, 251)
  scheduleEvent(function() roupasPanel:getChildById("FemaleListPanel"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("FemaleListScrollBar"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("VoltarSelection"):show() end, 251)
end
function DuploShow()
  g_effects.fadeOut(roupasPanel:getChildById("SelectMale"), 250)
  g_effects.fadeOut(roupasPanel:getChildById("SelectGirl"), 250)
  g_effects.fadeOut(roupasPanel:getChildById("SelectDoble"), 250)
  scheduleEvent(function() roupasPanel:getChildById("SelectMale"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectGirl"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("SelectDoble"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleGenero"):hide() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("TitleDuplo"):show() end, 251)

  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("DuploListPanel"), 250) end, 251)
  scheduleEvent(function() g_effects.fadeIn(roupasPanel:getChildById("DuploListScrollBar"), 250) end, 251)
  scheduleEvent(function() roupasPanel:getChildById("DuploListPanel"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("DuploListScrollBar"):show() end, 251)
  scheduleEvent(function() roupasPanel:getChildById("VoltarSelection"):show() end, 251)
end



function ashketchum()
---Config
local Item_Id = 25
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function brock()
---Config
local Item_Id = 26
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function stevenstone()
---Config
local Item_Id = 27
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ritchie()
---Config
local Item_Id = 28
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function traceysketchit()
---Config
local Item_Id = 29
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function bruno()
---Config
local Item_Id = 30
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function james()
---Config
local Item_Id = 31
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function butch()
---Config
local Item_Id = 32
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function lycanroccosplay()
---Config
local Item_Id = 33
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function jolteoncosplay()
---Config
local Item_Id = 34
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function vaporeoncosplay()
---Config
local Item_Id = 35
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function umbreoncosplay()
---Config
local Item_Id = 36
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function luxraycosplay()
---Config
local Item_Id = 37
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function venusaurcosplay()
---Config
local Item_Id = 38
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function blastoisecosplay()
---Config
local Item_Id = 39
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function charizardcosplay()
---Config
local Item_Id = 40
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function gengarcosplay()
---Config
local Item_Id = 41
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function exterminadordedemonios()
---Config
local Item_Id = 42
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function blueexorcist()
---Config
local Item_Id = 43
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function homemdeferro()
---Config
local Item_Id = 44
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function tonystark()
---Config
local Item_Id = 45
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function reidonorte()
---Config
local Item_Id = 47
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function coringa()
---Config
local Item_Id = 48
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function deadpool()
---Config
local Item_Id = 49
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function aforma()
---Config
local Item_Id = 50
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function bruxo()
---Config
local Item_Id = 51
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cirurgiaodamorte()
---Config
local Item_Id = 52
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cozinheiro()
---Config
local Item_Id = 53
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function donquixotedoflamingo()
---Config
local Item_Id = 54
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function fantasym()
---Config
local Item_Id = 55
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function chefjacquin()
---Config
local Item_Id = 56
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function debonairjacquin()
---Config
local Item_Id = 57
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function gangsterjacquin()
---Config
local Item_Id = 58
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function doutor()
---Config
local Item_Id = 59
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function guitarrista()
---Config
local Item_Id = 60
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function inquilino()
---Config
local Item_Id = 61
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function halloween()
---Config
local Item_Id = 62
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function jigsaw()
---Config
local Item_Id = 63
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ladoescuro()
---Config
local Item_Id = 64
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function palhaco()
---Config
local Item_Id = 65
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function panico()
---Config
local Item_Id = 66
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ninjamascarado()
---Config
local Item_Id = 67
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function tutankhamoak()
---Config
local Item_Id = 68
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ordemlugiaaprendizm()
---Config
local Item_Id = 69
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ordemlugiaguardiao()
---Config
local Item_Id = 70
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treinadorcampeao1()
---Config
local Item_Id = 71
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treinadorcampeao2()
---Config
local Item_Id = 72
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function modelom()
---Config
local Item_Id = 73
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function motociclista1()
---Config
local Item_Id = 74
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function motociclista2()
---Config
local Item_Id = 75
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function motociclista3()
---Config
local Item_Id = 76
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function motociclista4()
---Config
local Item_Id = 77
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function padre()
---Config
local Item_Id = 78
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function aventureiro()
---Config
local Item_Id = 79
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function barman()
---Config
local Item_Id = 80
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function chefe()
---Config
local Item_Id = 81
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function fraternidadem()
---Config
local Item_Id = 82
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function hacker()
---Config
local Item_Id = 83
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function hippie()
---Config
local Item_Id = 84
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function mestredekarate()
---Config
local Item_Id = 85
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function karate()
---Config
local Item_Id = 86
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function lutadorderua()
---Config
local Item_Id = 87
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function mecanico()
---Config
local Item_Id = 88
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pascoadeourom()
---Config
local Item_Id = 89
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pokemasterm()
---Config
local Item_Id = 90
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treinador()
---Config
local Item_Id = 91
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treinadorespecial()
---Config
local Item_Id = 92
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treinadorfitness()
---Config
local Item_Id = 93
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function vampiro()
---Config
local Item_Id = 94
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function viajantem()
---Config
local Item_Id = 95
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function vinganca()
---Config
local Item_Id = 96
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function misty()
---Config
local Item_Id = 97
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function oficialjenny()
---Config
local Item_Id = 98
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function jessie()
---Config
local Item_Id = 99
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cassidy()
---Config
local Item_Id = 100
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function harleyquinn()
---Config
local Item_Id = 101
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pikachucosplay()
---Config
local Item_Id = 102
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function azumarillcosplay()
---Config
local Item_Id = 103
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function flareoncosplay()
---Config
local Item_Id = 104
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function glaceoncosplay()
---Config
local Item_Id = 105
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function meowthcosplay()
---Config
local Item_Id = 106
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function persiancosplay()
---Config
local Item_Id = 107
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ninetalescosplay()
---Config
local Item_Id = 108
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function princesadasfadas()
---Config
local Item_Id = 109
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function rainhadasfadas()
---Config
local Item_Id = 110
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function sylveoncosplay()
---Config
local Item_Id = 111
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function melody()
---Config
local Item_Id = 112
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function oninezuko()
---Config
local Item_Id = 113
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function raposadenovecaldas()
---Config
local Item_Id = 114
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function adolescente()
---Config
local Item_Id = 115
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cleopatra()
---Config
local Item_Id = 116
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function cynthia()
---Config
local Item_Id = 117
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ensolarado()
---Config
local Item_Id = 118
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function fantasyf()
---Config
local Item_Id = 119
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function lutadoraoriental()
---Config
local Item_Id = 120
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function bruxa()
---Config
local Item_Id = 121
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function capetinha()
---Config
local Item_Id = 122
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function fantasma()
---Config
local Item_Id = 123
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function garotasupervila()
---Config
local Item_Id = 124
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function maedosdragoes()
---Config
local Item_Id = 125
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function ordemlugiaaprendizf()
---Config
local Item_Id = 126
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function assassina()
---Config
local Item_Id = 127
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function atriz()
---Config
local Item_Id = 128
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function bellaflorida()
---Config
local Item_Id = 129
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function coelhinha()
---Config
local Item_Id = 130
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function exploradora()
---Config
local Item_Id = 131
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function fraternidadef()
---Config
local Item_Id = 132
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function garotapossuida()
---Config
local Item_Id = 133
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function longcape()
---Config
local Item_Id = 134
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function mecanica()
---Config
local Item_Id = 135
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function modelo()
---Config
local Item_Id = 136
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function morceguinha()
---Config
local Item_Id = 137
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pascoadeourof()
---Config
local Item_Id = 138
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function princesa()
---Config
local Item_Id = 139
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function meninadaescola()
---Config
local Item_Id = 140
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function motociclista()
---Config
local Item_Id = 141
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function playmate()
---Config
local Item_Id = 142
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function pokemasterf()
---Config
local Item_Id = 143
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function popstar()
---Config
local Item_Id = 144
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function topdebiquini()
---Config
local Item_Id = 145
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treinadora()
---Config
local Item_Id = 146
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treinadoraespecial()
---Config
local Item_Id = 147
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function treinadorafitness()
---Config
local Item_Id = 148
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function vaqueira()
---Config
local Item_Id = 149
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function viajantef()
---Config
local Item_Id = 150
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function senhorapirata()
---Config
local Item_Id = 151
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function rua()
---Config
local Item_Id = 152
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end
function hotdog()
---Config
local Item_Id = 153
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
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local PokeCoin = function()
  shopWindow:getChildById("WindowSelectBuy"):hide() shopWindow:getChildById("WindowSelected"):show() shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_pokecoin/'..Sell_Name) shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyPokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
local Price = function()
  shopWindow:getChildById("WindowSelectBuy"):show() shopWindow:getChildById("WindowSelectBuy"):getChildById("Text"):setImageSource('images/buywindow/text_price/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/roupas/all/'..Sell_Name)  shopWindow:getChildById("WindowSelectBuy"):getChildById("Diamond"):setImageSource('images/count/diamond/'..Value_Diamond) shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..Value_PokeCoin)  shopWindow:getChildById("WindowSelectBuy"):getChildById("DiamondButton").onClick = function() Diamond() end  shopWindow:getChildById("WindowSelectBuy"):getChildById("PokeCoinButton").onClick = function() PokeCoin() end
  shopWindow:getChildById("BackgroundBlack"):show()
end
  Price()
  return true
end