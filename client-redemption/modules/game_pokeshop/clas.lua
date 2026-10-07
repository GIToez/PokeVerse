function doCleanSelecteds()
    BackgroundCla:setImageSource("images/clas/clean")
    TitleBig:setImageSource("images/clas/clean")
    Descricao:setImageSource("images/clas/clean")

    ClaIcon5:setImageSource("images/clas/clean")
    ClaName5:setImageSource("images/clas/clean")
    ClaIcon1:setImageSource("images/clas/clean")
    ClaName1:setImageSource("images/clas/clean")

    TypeSolo:setImageSource("images/clas/clean")
    TypeSolo:setTooltip("")
    TypeSolo:hide()
    TypeFirst:setImageSource("images/clas/clean")
    TypeFirst:setTooltip("")
    TypeFirst:hide()
    TypeSecond:setImageSource("images/clas/clean")
    TypeSecond:setTooltip("")
    TypeSecond:hide()
end
function doReturnSelection()
    PanelSelectedClas:hide()
    ClasListScrollBar:show()
    ClasListPanel:show()
    TitleCla:show()
	
	doCleanSelecteds()
end

function doShowGaia()
	local ClaName = "gaia"
	local Type_First = "Grass"
	local Type_Second = "Bug"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuyGaia5() end
    BuyButton1.onClick = function() doBuyGaia1() end
end
function doShowAvalanche()
	local ClaName = "avalanche"
	local Type_First = "Water"
	local Type_Second = "Ice"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuyAvalanche5() end
    BuyButton1.onClick = function() doBuyAvalanche1() end
end
function doShowSpectrum()
	local ClaName = "spectrum"
	local Type_First = "Ghost"
	local Type_Second = "Poison"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuySpectrum5() end
    BuyButton1.onClick = function() doBuySpectrum1() end
end
function doShowHeremit()
	local ClaName = "heremit"
	local Type_First = "Rock"
	local Type_Second = "Ground"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuyHeremit5() end
    BuyButton1.onClick = function() doBuyHeremit1() end
end
function doShowZen()
	local ClaName = "zen"
	local Type_First = "Psychic"
	local Type_Second = "Dark"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuyZen5() end
    BuyButton1.onClick = function() doBuyZen1() end
end
function doShowVoltagic()
	local ClaName = "voltagic"
	local Type_First = "Electric"
	local Type_Second = "Steel"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuyVoltagic5() end
    BuyButton1.onClick = function() doBuyVoltagic1() end
end
function doShowBlaze()
	local ClaName = "blaze"
	local Type_First = "Fire"
	local Type_Second = "vazio"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuyBlaze5() end
    BuyButton1.onClick = function() doBuyBlaze1() end
end
function doShowHurricane()
	local ClaName = "hurricane"
	local Type_First = "Fly"
	local Type_Second = "Dragon"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuyHurricane5() end
    BuyButton1.onClick = function() doBuyHurricane1() end
end
function doShowVital()
	local ClaName = "vital"
	local Type_First = "Fighting"
	local Type_Second = "Normal"

    doCleanSelecteds()
    ClasListScrollBar:hide()
    ClasListPanel:hide()
    TitleCla:hide()
    PanelSelectedClas:show()
    BackgroundCla:setImageSource("images/clas/background/selected/"..ClaName)
    TitleBig:setImageSource("images/clas/background/title/"..ClaName)
    Descricao:setImageSource("images/clas/texts/"..ClaName)
	
    ClaIcon5:setImageSource("images/clas/icons/"..ClaName)
    ClaName5:setImageSource("images/clas/texts/rank_5/"..ClaName)
    ClaIcon1:setImageSource("images/clas/icons/"..ClaName)
    ClaName1:setImageSource("images/clas/texts/rank_1/"..ClaName)
	if Type_Second == "vazio" then
		TypeSolo:setImageSource("images/clas/types/"..Type_First)
		TypeSolo:setTooltip(Type_First)
		TypeSolo:show()
	else
		TypeFirst:setImageSource("images/clas/types/"..Type_First)
		TypeFirst:setTooltip(Type_First)
		TypeFirst:show()
		TypeSecond:setImageSource("images/clas/types/"..Type_Second)
		TypeSecond:setTooltip(Type_Second)
		TypeSecond:show()
	end
    BuyButton5.onClick = function() doBuyVital5() end
    BuyButton1.onClick = function() doBuyVital1() end
end


-- BUY FUNCTIONS \/

function doBuyGaia5()
  ---Config
  local Sell_Name = "gaia5"
  local ImageIcon = "gaia"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyAvalanche5()
  ---Config
  local Sell_Name = "avalanche5"
  local ImageIcon = "avalanche"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuySpectrum5()
  ---Config
  local Sell_Name = "spectrum5"
  local ImageIcon = "spectrum"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyHeremit5()
  ---Config
  local Sell_Name = "heremit5"
  local ImageIcon = "heremit"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyZen5()
  ---Config
  local Sell_Name = "zen5"
  local ImageIcon = "zen"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyVoltagic5()
  ---Config
  local Sell_Name = "voltagic5"
  local ImageIcon = "voltagic"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyBlaze5()
  ---Config
  local Sell_Name = "blaze5"
  local ImageIcon = "blaze"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyHurricane5()
  ---Config
  local Sell_Name = "hurricane5"
  local ImageIcon = "hurricane"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyVital5()
  ---Config
  local Sell_Name = "vital5"
  local ImageIcon = "vital"
  local Value_Diamond = 80
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end




function doBuyGaia1()
  ---Config
  local Sell_Name = "gaia1"
  local ImageIcon = "gaia"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyAvalanche1()
  ---Config
  local Sell_Name = "avalanche1"
  local ImageIcon = "avalanche"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuySpectrum1()
  ---Config
  local Sell_Name = "spectrum1"
  local ImageIcon = "spectrum"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyHeremit1()
  ---Config
  local Sell_Name = "heremit1"
  local ImageIcon = "heremit"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyZen1()
  ---Config
  local Sell_Name = "zen1"
  local ImageIcon = "zen"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyVoltagic1()
  ---Config
  local Sell_Name = "voltagic1"
  local ImageIcon = "voltagic"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyBlaze1()
  ---Config
  local Sell_Name = "blaze1"
  local ImageIcon = "blaze"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyHurricane1()
  ---Config
  local Sell_Name = "hurricane1"
  local ImageIcon = "hurricane"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end
function doBuyVital1()
  ---Config
  local Sell_Name = "vital1"
  local ImageIcon = "vital"
  local Value_Diamond = 60
  
  ---Functions
  local BuyDiamond = function()
    g_game.talk('/BuyMasteryRank '..Sell_Name)
    shopWindow:getChildById("WindowSelected"):hide()
    shopWindow:getChildById("BackgroundBlack"):hide()
    cleartab()
  end
  local Diamond = function()
    shopWindow:getChildById("WindowSelectBuy"):hide() 
	shopWindow:getChildById("WindowSelected"):show() 
	shopWindow:getChildById("WindowSelected"):getChildById("Text"):setImageSource('images/buywindow/text_diamond/'..Sell_Name) 
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/clas/icons/buy/'..ImageIcon) 
	shopWindow:getChildById("WindowSelected"):getChildById("price"):setImageSource('images/count/diamond/'..Value_Diamond)  
	shopWindow:getChildById("WindowSelected"):getChildById("Comprar").onClick = function() BuyDiamond() end
    
	shopWindow:getChildById("BackgroundBlack"):show()
  end
  Diamond()
  return true
end