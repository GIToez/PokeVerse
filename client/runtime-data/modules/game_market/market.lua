local marketWindow, currentMarketPanel, currentTabButton
local marketOpcode = 64

local marketBuyPanel, marketSearchTextEdit, marketBuyComboBox, buyPanelTable, selectedBuyRow, buyOffersWindow, makeOfferWindow, buyNowWindow
local currentPage, maxPage, currentOder = 1, 1, 'timedesc'
local itemToSell, itemToSellCount, textEditSellPrice, checkBoxOnlyOffers, sellButton
local sellPanelTable, sellPanelTableData
local offerPanelTable1, offerPanelTable2, offerPanelTableData1, offerPanelTableData2, offerToMeWindow, myCurrentOfferWindow
local marketSellPanel, marketOfferPanel, marketHistoricPanel
local marketHistoricList

local comboBoxOptions = {
  "Todos", "Items", "Stones", "Poke Balls", "Diamonds", "Addons", "Outfits", "Pokemon", "Held Item", "Furnitures", "Berries", "Plates", "Dolls", "Foods", "Utilities", "Supplies",
}

local buyHeader = {
  [1] = {text = '#',          width = 30,  onClick = function(self) currentOder = currentOder == 'timedesc'   and 'timeasc'   or 'timedesc'   refreshBuyItems() end},
  [2] = {text = 'Item',       width = 50,  onClick = function(self) currentOder = currentOder == 'itemdesc'   and 'itemasc'   or 'itemdesc'   refreshBuyItems() end},
  [3] = {text = 'Nome',       width = 250, onClick = function(self) currentOder = currentOder == 'itemdesc'   and 'itemasc'   or 'itemdesc'   refreshBuyItems() end},
  [4] = {text = 'Vendedor',     width = 247, onClick = function(self) currentOder = currentOder == 'sellerdesc' and 'sellerasc' or 'sellerdesc' refreshBuyItems() end},
  [5] = {text = 'Quantidade',     width = 100,  onClick = function(self) currentOder = currentOder == 'amountdesc' and 'amountasc' or 'amountdesc' refreshBuyItems() end},
  [6] = {text = 'Preço Unitário', width = 125, onClick = function(self) currentOder = currentOder == 'pricedesc'  and 'priceasc'  or 'pricedesc'  refreshBuyItems() end},
}

local sellHeader = {
  [1] = {text = '#',          width = 30,  onClick = function(self) currentOder = currentOder == 'timedesc'   and 'timeasc'   or 'timedesc'   refreshSellItems() end},
  [2] = {text = 'Item',       width = 50,  onClick = function(self) currentOder = currentOder == 'itemdesc'   and 'itemasc'   or 'itemdesc'   refreshSellItems() end},
  [3] = {text = 'Nome',       width = 250, onClick = function(self) currentOder = currentOder == 'namedesc'   and 'nameasc'   or 'namedesc'   refreshSellItems() end},
  [4] = {text = 'Tempo',       width = 247, onClick = function(self) currentOder = currentOder == 'timedesc'   and 'timeasc'   or 'timedesc'   refreshSellItems() end},
  [5] = {text = 'Amount',     width = 100,  onClick = function(self) currentOder = currentOder == 'amountdesc' and 'amountasc' or 'amountdesc' refreshSellItems() end},
  [6] = {text = 'Preço Unitário', width = 125, onClick = function(self) currentOder = currentOder == 'pricedesc'  and 'priceasc'  or 'pricedesc'  refreshSellItems() end},
}

local offerHeader1 = {
  [1] = {text = '#',          width = 30,  onClick = function(self) currentOder = currentOder == 'timedesc'   and 'timeasc'   or 'timedesc'   refreshSellItems() end},
  [2] = {text = 'Item',       width = 50,  onClick = function(self) currentOder = currentOder == 'itemdesc'   and 'itemasc'   or 'itemdesc'   refreshSellItems() end},
  [3] = {text = 'Nome',       width = 250, onClick = function(self) currentOder = currentOder == 'namedesc'   and 'nameasc'   or 'namedesc'   refreshSellItems() end},
  [4] = {text = 'Ofertas',     width = 238, onClick = function(self) currentOder = currentOder == 'timedesc'   and 'timeasc'   or 'timedesc'   refreshSellItems() end},
  [5] = {text = 'Tempo',       width = 100, onClick = function(self) currentOder = currentOder == 'amountdesc' and 'amountasc' or 'amountdesc' refreshSellItems() end},
  [6] = {text = 'Açao',     width = 125, onClick = function(self) currentOder = currentOder == 'pricedesc'  and 'priceasc'  or 'pricedesc'  refreshSellItems() end},
}

local offerHeader2 = {
  [1] = {text = '#',          width = 30,  onClick = function(self) currentOder = currentOder == 'timedesc'   and 'timeasc'   or 'timedesc'   refreshSellItems() end},
  [2] = {text = 'Item',       width = 50,  onClick = function(self) currentOder = currentOder == 'itemdesc'   and 'itemasc'   or 'itemdesc'   refreshSellItems() end},
  [3] = {text = 'Nome',       width = 240, onClick = function(self) currentOder = currentOder == 'namedesc'   and 'nameasc'   or 'namedesc'   refreshSellItems() end},
  [4] = {text = 'Vendedor(a)',     width = 247, onClick = function(self) currentOder = currentOder == 'timedesc'   and 'timeasc'   or 'timedesc'   refreshSellItems() end},
  [5] = {text = 'Oferta',      width = 100, onClick = function(self) currentOder = currentOder == 'amountdesc' and 'amountasc' or 'amountdesc' refreshSellItems() end},
  [6] = {text = 'Açao',     width = 125, onClick = function(self) currentOder = currentOder == 'pricedesc'  and 'priceasc'  or 'pricedesc'  refreshSellItems() end},
}

function init()
  g_ui.importStyle('market')
  g_ui.importStyle('market_buy_panel')
  g_ui.importStyle('market_sell_panel')
  g_ui.importStyle('market_offer_panel')
  g_ui.importStyle('market_historic_panel')
  connect(g_game, { 
  	onGameStart = offline,
  	onGameEnd = offline
  })
  connect(g_game, { 
	onGameStart = updatePosition
  })
  connect(LocalPlayer, {
  	onPositionChange = updatePosition
  })
  
  marketWindow = g_ui.createWidget('MarketWindow', modules.game_interface.getRootPanel())
 
  marketBuyPanel       = g_ui.createWidget('BuyPanel', marketWindow)
  marketSellPanel      = g_ui.createWidget('SellPanel', marketWindow)
  marketOfferPanel     = g_ui.createWidget('OfferPanel', marketWindow)
  marketHistoricPanel  = g_ui.createWidget('HistoricPanel', marketWindow)
  
  -- BUY PANEL 
  marketBuyComboBox = marketBuyPanel:getChildById('comboBox')
  marketSearchTextEdit = marketBuyPanel:getChildById('buySearchTextEdit')
  
  for _, option in pairs(comboBoxOptions) do
    marketBuyComboBox:addOption(option)
  end
  marketBuyComboBox.onOptionChange = refreshBuyItems
  buyPanelTable = marketBuyPanel:getChildById('panelTable')
  buyPanelTableData = marketBuyPanel:getChildById('panelTableData')
  buyPanelTable:setTableData(buyPanelTableData)
  buyPanelTable:addHeader(buyHeader)
  buyPanelTable.onSelectionChange = function(table, selectedRow, previosSelectedRow)
    toggleBuyButtons(true)
	selectedBuyRow = selectedRow
	local rowPrice = selectedBuyRow.price
    if rowPrice == 0 then
	  marketBuyPanel:getChildById('makeOfferButton'):setImageSource("images/buttons/ofertar")
	  marketBuyPanel:getChildById('buyNowButton'):setImageSource("images/buttons/comprar_off")
      marketBuyPanel:getChildById('buyNowButton'):setEnabled(bool)
	elseif rowPrice >= 1 then
	  marketBuyPanel:getChildById('buyNowButton'):setImageSource("images/buttons/comprar")
	  marketBuyPanel:getChildById('makeOfferButton'):setImageSource("images/buttons/ofertar")
    end
  end
  
  buyOffersWindow  = g_ui.createWidget('BuyOffersWindow', modules.game_interface.getRootPanel())
  buyNowWindow     = g_ui.createWidget('BuyNowWindow', modules.game_interface.getRootPanel())
  makeOfferWindow  = g_ui.createWidget('MakeOfferWindow', modules.game_interface.getRootPanel())
  -- SELL PANEL
  itemToSell         = marketSellPanel:getChildById('panelToSell'):getChildById('itemToSell')
  itemToSellCount    = marketSellPanel:getChildById('panelToSell'):getChildById('itemToSellCount')
  textEditSellPrice  = marketSellPanel:getChildById('panelToSell'):getChildById('textEditSellPrice')
  checkBoxOnlyOffers = marketSellPanel:getChildById('panelToSell'):getChildById('checkBoxOnlyOffers')
  sellButton         = marketSellPanel:getChildById('panelToSell'):getChildById('sellButton')
  sellPanelTable     = marketSellPanel:getChildById('panelTable')
  sellPanelTableData = marketSellPanel:getChildById('panelTableData')
  sellPanelTable:setTableData(sellPanelTableData)
  sellPanelTable:addHeader(sellHeader)
  
  -- OFFER PANEL
  offerPanelTable1     = marketOfferPanel:getChildById('panelTable1')
  offerPanelTableData1 = marketOfferPanel:getChildById('panelTableData1')
  offerPanelTable1:setTableData(offerPanelTableData1)
  offerPanelTable1:addHeader(offerHeader1)
  
  offerPanelTable2     = marketOfferPanel:getChildById('panelTable2')
  offerPanelTableData2 = marketOfferPanel:getChildById('panelTableData2')
  offerPanelTable2:setTableData(offerPanelTableData2)
  offerPanelTable2:addHeader(offerHeader2)

  offerToMeWindow = g_ui.createWidget('OfferToMeWindow', modules.game_interface.getRootPanel())
  myCurrentOfferWindow = g_ui.createWidget('MyCurrentOfferWindow', modules.game_interface.getRootPanel())
  
  -- HISTORIC PANEL
  marketHistoricList = marketHistoricPanel:getChildById('historicList')
  marketWindow:hide()
  
  currentMarketPanel = marketBuyPanel
  currentTabButton = marketWindow:getChildById('buyTabButton')
  currentTabButton:setImageColor('white')
  
  ProtocolGame.registerExtendedOpcode(marketOpcode, onMarketMessage)
end

function terminate()
  disconnect(g_game, { 
  	onGameStart = offline,
  	onGameEnd = offline
  })
  
  ProtocolGame.unregisterExtendedOpcode(marketOpcode)
  marketWindow:destroy()
  buyOffersWindow:destroy()
  buyNowWindow:destroy()
  makeOfferWindow:destroy()
  offerToMeWindow:destroy()
  myCurrentOfferWindow:destroy()
end

function resetBuyingPanel()
  marketSearchTextEdit:setText("")
  buyPanelTable:clearData()
end

function resetSellingPanel()
  itemToSell:setImageSource("")
  itemToSell:setItemId(0)
  itemToSell:setTooltip("")
  itemToSell.itemid = 0
  itemToSell.spriteId = 0
  itemToSell.item_code = 0
  itemToSell:getChildById('poke'):setImageSource("/images/ui/item")
  itemToSell:getChildById('level'):setText("")
  itemToSell:getChildById('sex'):setImageSource("/images/ui/item")
  itemToSell:getChildById('shiny'):setImageSource("/images/ui/item")
  marketSellPanel:getChildById('panelToSell'):getChildById('name'):setText("")
  marketSellPanel:getChildById('panelToSell'):getChildById('totalValue'):setText("")
  marketSellPanel:getChildById('panelToSell'):getChildById('feeValue'):setText("")
  marketSellPanel:getChildById('panelToSell'):getChildById('totalAndFeeValue'):setText("")
  checkBoxOnlyOffers:setChecked(false)
  sellButton:setEnabled(false)
  textEditSellPrice:setText('')
  sellPanelTable:clearData()
  syncMarketSellItems()
end

function resetOffersPanels(pnl)
  if pnl == 1 then offerPanelTable1:clearData() syncMarketOfferItems() end
  if pnl == 2 then offerPanelTable2:clearData() end
end

function changeMarketPanel(panel, button)
  if currentMarketPanel == panel then return end
  currentMarketPanel:hide()
  currentMarketPanel = panel
  panel:show()
  if currentTabButton == button then return end
  currentTabButton:setImageColor('#5b5b5b')
  button:setImageColor('white')
  currentTabButton = button
end

function offline()
  resetBuyingPanel()
  resetSellingPanel()
  resetOffersPanels()
  hide()
end

function hide()
  marketWindow:hide()
  buyOffersWindow:hide()
  buyNowWindow:hide()
  makeOfferWindow:hide()
  offerToMeWindow:hide()
  myCurrentOfferWindow:hide()
  modules.game_interface.destroyCountWindow()
end

function show()
  buyOffersWindow:hide()
  buyNowWindow:hide()
  makeOfferWindow:hide()
  offerToMeWindow:hide()
  myCurrentOfferWindow:hide()
  modules.game_interface.destroyCountWindow()
  marketWindow:show()
end

function toggleBuyButtons(bool)
  marketBuyPanel:getChildById('buyNowButton'):setEnabled(bool)
  marketBuyPanel:getChildById('makeOfferButton'):setEnabled(bool)
  marketBuyPanel:getChildById('buyNowButton'):setImageSource("images/buttons/comprar_off")
  marketBuyPanel:getChildById('makeOfferButton'):setImageSource("images/buttons/ofertar_off")
end

function getMakeOfferWindow()
  return makeOfferWindow
end

function showMakeOfferWindow()
  marketWindow:hide()
  local offerChildren = makeOfferWindow:getChildById('offersList'):getChildren()
  for _, child in pairs(offerChildren) do
    child:setItemId(0)
    child:setTooltip('')
    child:getChildById('poke'):setImageSource("/images/ui/item")
    child:getChildById('level'):setText("")
    child:getChildById('sex'):setImageSource("/images/ui/item")
    child:getChildById('shiny'):setImageSource("/images/ui/item")
  end
  makeOfferWindow:getChildById('offerItem'):setItemId(selectedBuyRow.spriteId)
  makeOfferWindow:getChildById('offerItem'):setTooltip(selectedBuyRow.description)
  makeOfferWindow:getChildById('offerItem'):setItemCount(selectedBuyRow.count)
  makeOfferWindow:getChildById('offerItemName'):setText(selectedBuyRow.name)
  if selectedBuyRow.poke_info and TABLE_POKEMON_INFO[selectedBuyRow.poke_info.name] then
    makeOfferWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/data/images/pokeicons/"..selectedBuyRow.poke_info.name)
    makeOfferWindow:getChildById('offerItem'):getChildById('level'):setText("Lv."..selectedBuyRow.poke_info.level)
    makeOfferWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (selectedBuyRow.poke_info.sex == 0 and "red" or (selectedBuyRow.poke_info.sex == 1 and "black" or "yellow")))
    if string.find(selectedBuyRow.poke_info.name, "Shiny") then makeOfferWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
  else
    makeOfferWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/images/ui/item")
    makeOfferWindow:getChildById('offerItem'):getChildById('level'):setText("")
    makeOfferWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/images/ui/item")
    makeOfferWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/images/ui/item")
  end
  makeOfferWindow:show()
end

function marketAcceptOffer()
  if not offerToMeWindow.selectedOffer then return end
  local protocoltext = "###MARKETACCEPTOFFER###"
  protocoltext = protocoltext..',ItemCode:'..offerToMeWindow.selectedOffer.item_code
  protocoltext = protocoltext..',PlayerOfferId:'..offerToMeWindow.selectedOffer.playeroffer_id
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, protocoltext)
  show()
end

function marketRefuseOffer()
  if not offerToMeWindow.selectedOffer then return end
  local protocoltext = "###MARKETREFUSEOFFER###"
  protocoltext = protocoltext..',ItemCode:'..offerToMeWindow.selectedOffer.item_code
  protocoltext = protocoltext..',PlayerOfferId:'..offerToMeWindow.selectedOffer.playeroffer_id
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, protocoltext)
  show()
end

function showBuyNowWindow()
  marketWindow:hide()
  local rowItem = buyNowWindow:getChildById('item')
  rowItem:setItemId(selectedBuyRow.spriteId)
  rowItem:setTooltip(selectedBuyRow.description)
  rowItem:setItemCount(selectedBuyRow.count)
  local rowScrollbar = buyNowWindow:getChildById('countScrollBar')
  rowScrollbar:setMinimum(1)
  rowScrollbar:setMaximum(selectedBuyRow.count)
  rowScrollbar:setValue(selectedBuyRow.count)

  if selectedBuyRow.poke_info and TABLE_POKEMON_INFO[selectedBuyRow.poke_info.name] then
    rowItem:getChildById('poke'):setImageSource("/data/images/pokeicons/"..selectedBuyRow.poke_info.name)
    rowItem:getChildById('level'):setText("Lv."..selectedBuyRow.poke_info.level)
    rowItem:getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (selectedBuyRow.poke_info.sex == 0 and "red" or (selectedBuyRow.poke_info.sex == 1 and "black" or "yellow")))
    if string.find(selectedBuyRow.poke_info.name, "Shiny") then rowItem:getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
  else
    rowItem:getChildById('poke'):setImageSource("/images/ui/item")
    rowItem:getChildById('level'):setText("")
    rowItem:getChildById('sex'):setImageSource("/images/ui/item")
    rowItem:getChildById('shiny'):setImageSource("/images/ui/item")
  end
  
  local rowPrice = buyNowWindow:getChildById('price')
  rowPrice:setText(getFormattedMoney2(selectedBuyRow.price * selectedBuyRow.count))

  local rowSpinBox = buyNowWindow:getChildById('spinBox')
  rowSpinBox:setMinimum(0)
  rowSpinBox:setMaximum(selectedBuyRow.count)
  rowSpinBox:setValue(0)
  rowSpinBox:hideButtons()
  rowSpinBox:focus()
  rowSpinBox.firstEdit = true
  local onSpinBoxValueChange = function(self, value)
    rowSpinBox.firstEdit = false
	rowScrollbar:setValue(value)
  end

  rowSpinBox.onValueChange = onSpinBoxValueChange

  local refresh = function()
    if rowSpinBox.firstEdit then
      rowSpinBox:setValue(rowSpinBox:getMaximum())
      rowSpinBox.firstEdit = false
    end
  end
  
  g_keyboard.bindKeyPress("Up", function() refresh() rowSpinBox:up() end, rowSpinBox)
  g_keyboard.bindKeyPress("Down", function() refresh() rowSpinBox:down() end, rowSpinBox)
  g_keyboard.bindKeyPress("Right", function() refresh() rowSpinBox:up() end, rowSpinBox)
  g_keyboard.bindKeyPress("Left", function() refresh() rowSpinBox:down() end, rowSpinBox)
  g_keyboard.bindKeyPress("PageUp", function() refresh() rowSpinBox:setValue(rowSpinBox:getValue()+1) end, rowSpinBox)
  g_keyboard.bindKeyPress("PageDown", function() refresh() rowSpinBox:setValue(rowSpinBox:getValue()-1) end, rowSpinBox)

  rowScrollbar.onValueChange = function(self, value)
    rowItem:setItemCount(value)
	rowPrice:setText(getFormattedMoney2(value * selectedBuyRow.price))
    rowSpinBox.onValueChange = nil
    rowSpinBox:setValue(value)
    rowSpinBox.onValueChange = onSpinBoxValueChange
  end

  local okButton = buyNowWindow:getChildById('buttonOk')
  local buyFunc = function()
    buyItem(rowItem:getItemCount())
    show()
  end
  local cancelButton = buyNowWindow:getChildById('buttonCancel')
  local cancelFunc = function()
    show()
  end

  buyNowWindow.onEnter = buyFunc
  buyNowWindow.onEscape = cancelFunc

  okButton.onClick = buyFunc
  cancelButton.onClick = cancelFunc

  buyNowWindow:show()
end

function doPostOffer()
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETBUYPOSTOFFER###,ItemCode:"..selectedBuyRow.item_code)
  show()
end

function doCancelMakeOffer()
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETBUYCANCELMAKEOFFER###,ItemCode:"..selectedBuyRow.item_code)
  show()
end

function marketMakeOffer(x, y, z, count)
  local protocoltext = "###MARKETBUYMAKEOFFER###"
  protocoltext = protocoltext..',ItemCode:'..selectedBuyRow.item_code
  protocoltext = protocoltext..',Count:'..count
  protocoltext = protocoltext..',X:'..x..',Y:'..y..',Z:'..z
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, protocoltext)
end

function buyItem(count)
  -- print(selectedBuyRow.item_code)
  -- print(selectedBuyRow.count)
  -- print(selectedBuyRow.price)
  -- print(selectedBuyRow:getId())
  local protocoltext = "###MARKETBUYITEM###"
  protocoltext = protocoltext..',ItemCode:'..selectedBuyRow.item_code
  protocoltext = protocoltext..',Count:'..count
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, protocoltext)
end

function refreshBuyItems()
  local protocoltext = "###MARKETBUYITEMS###"
  protocoltext = protocoltext..(#marketSearchTextEdit:getText() >= 3 and ',Search:'..marketSearchTextEdit:getText() or 'NotSearch')
  protocoltext = protocoltext..',Category:'..marketBuyComboBox:getText()
  protocoltext = protocoltext..',Page:'..currentPage
  protocoltext = protocoltext..',Order:'..currentOder
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, protocoltext)
end

function refreshOffersItems()
  local protocoltext = "###MARKETOFFERSITEMS###"
  protocoltext = protocoltext..',Order:'..currentOder
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, protocoltext)
end

function doPlaceItemForSale()
  local itemId = itemToSell.itemid
  -- if itemId <= 0 then print("nope") return end
  local count = itemToSellCount:getValue()
  if count < 1 then count = 1 end
  local protocoltext = "###MARKETSELLITEM###"..",ItemCode:"..itemToSell.item_code
  protocoltext = protocoltext..",ItemId:"..itemId..",Count:"..count..",Price:"..textEditSellPrice:getText()..",OnlyOffer:"..(checkBoxOnlyOffers:isChecked() and 0 or 1)
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, protocoltext)
end

function ResetValueItemSell()
  textEditSellPrice:setText('')
  marketSellPanel:getChildById('panelToSell'):getChildById('totalValue'):setText("Preço: $0")
  marketSellPanel:getChildById('panelToSell'):getChildById('feeValue'):setText("Taxa: $0")
  marketSellPanel:getChildById('panelToSell'):getChildById('totalAndFeeValue'):setText("Total: $0")
end

function refreshSellItems()
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, '###MARKETSELLITEMS###"')
end

function refreshAllMarket()
  g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, '###MARKETALL###"')
end

function selectItemToSell()
  local gameInterface = modules.game_interface
  local mouseGrabberWidget = gameInterface.getMouseGrabberWidget()
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
  
  mouseGrabberWidget.onMouseRelease = function(self, mousePosition, mouseButton)
    if mouseButton == MouseLeftButton then
	  local clickedWidget = gameInterface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
	  if clickedWidget and clickedWidget:getClassName() == 'UIItem' then
	    local item = clickedWidget:getItem()
		local pos = item:getPosition()
		g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, '###CHECKCANSELL###,X:'..pos.x..',Y:'..pos.y..',Z:'..pos.z)
	  end
	end
	while(g_mouse.isCursorChanged()) do
	  g_mouse.popCursor('target')
	end
	self:ungrabMouse()
	mouseGrabberWidget.onMouseRelease = nil
	mouseGrabberWidget.onMouseRelease = gameInterface.onMouseGrabberRelease
    ResetValueItemSell()
  end
end

function syncMarketSellItems()
  for w=1, sellPanelTableData:getChildCount() do
    local row = sellPanelTableData:getChildByIndex(w)
	if row then
	  local _time = row.time-os.time()
	  row:getChildByIndex(4):setText(_time < 0 and "Expired" or string.format("%02d:%02d:%02d", _time/(60*60), (_time/60)%60, _time%60))
	end
  end
  scheduleEvent(syncMarketSellItems, 1000)
end

function syncMarketOfferItems()
  for w=1, offerPanelTableData1:getChildCount() do
    local row = offerPanelTableData1:getChildByIndex(w)
	if row then
	  local _time = row.time-os.time()
	  row:getChildByIndex(5):setText(_time < 0 and "Expired" or string.format("%02d:%02d:%02d", _time/(60*60), (_time/60)%60, _time%60))
	end
  end
  scheduleEvent(syncMarketOfferItems, 1000)
end

function toPage(num, next, max)
  local oldPage = currentPage
  currentPage = num and num or (max and maxPage or (next and (currentPage+1 >= maxPage and maxPage or currentPage+1) or (currentPage-1 <= 0 and 1 or currentPage-1)))
  if currentPage == oldPage then return end 
  refreshBuyItems()
end

function onSellPriceTextChange()
  local value = math.max(1, itemToSellCount:getValue())
  local priceNumber = tonumber(textEditSellPrice:getText())
  if priceNumber then
    marketSellPanel:getChildById('panelToSell'):getChildById('totalValue'):setText("Preço: "..getFormattedMoney2((priceNumber*value)))
    marketSellPanel:getChildById('panelToSell'):getChildById('feeValue'):setText("Taxa: "..getFormattedMoney2(getMarketFee(priceNumber*value)))
    marketSellPanel:getChildById('panelToSell'):getChildById('totalAndFeeValue'):setText("Total: "..getFormattedMoney2((priceNumber*value)-getMarketFee(priceNumber*value)))
  end
end

function onMarketMessage(protocol, opcode, buffer)
  -- print("recebeu")
  local player = g_game.getLocalPlayer()
  if not player then return end
  local receive = loadstring("return ".. buffer)()
  local protocolGame = g_game.getProtocolGame()
  if receive[3] == "refreshall" then
    -- print("recebeu: refreshall")
    refreshAllMarket()
  elseif receive[3] == "close" then
    -- print("recebeu: close")
    hide()
  elseif receive[3] == "market_historic" then
    -- print("recebeu: market_historic")
    marketHistoricList:destroyChildren()
    local historic = Protocol_read(receive)
	table.sort(historic, function(a,b) return a.time > b.time end)
    for num, negotiation in ipairs(historic) do
	  local text = g_ui.createWidget('HistoricLabel', marketHistoricList)
	  text:setText(" "..negotiation.negotiation)
	end
  elseif receive[3] == "marketbuyitems" then
    -- print("recebeu: marketbuyitems")
    resetBuyingPanel()
    local category = Protocol_read(receive)
	marketBuyComboBox:setCurrentOption(category)
    currentPage = Protocol_read(receive)
    maxPage = Protocol_read(receive)
    local focus = Protocol_read(receive)
	local searchstring = Protocol_read(receive)
    local buyItems = Protocol_read(receive)
	marketSearchTextEdit:setText(searchstring)
	for number, itemInfo in pairs(buyItems) do
	  local data = {
        {text = number},
		{itemid = itemInfo.spriteId, count = itemInfo.count, tooltip = itemInfo.description, poke_info = itemInfo.poke_info,
	      mouseRelease = function(self, mousePos, mouseButton)
            if itemInfo.description:len() == 0 then return end
            local menu = g_ui.createWidget('PopupMenu')
            -- menu:setGameMenu(true)
            -- menu:addOption(tr('Info'), function() g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETPOKEMONINFO###,ItemCode:"..itemInfo.item_code) end)
            -- menu:display(mousePosition)
          end
		},
		{text = itemInfo.item_name},
		{text = itemInfo.playerseller_name, align = AlignCenter},
		{text = itemInfo.count, align = AlignCenter},
		{text = getFormattedMoney(itemInfo.price)..' ', align = AlignRightCenter},
		-- {poke_info = itemInfo.poke_info},
	  }
	  local row = buyPanelTable:addRow(data, 34)
	  row.item_code = itemInfo.item_code
	  row.itemid = itemInfo.itemid
	  row.spriteId = itemInfo.spriteId
	  row.price = itemInfo.price
	  row.count = itemInfo.count
	  row.name = itemInfo.item_name
	  row.description = itemInfo.description
	  row.poke_info = itemInfo.poke_info
	  row.onMouseRelease = function(self, mousePos, mouseButton)
	    if mouseButton == MouseRightButton then
		  local menu = g_ui.createWidget('PopupMenu')
		  menu:addOption(tr('Display offers'), function() 
		    marketWindow:hide()
		    buyOffersWindow:getChildById('offerItem'):setTooltip('')
	        buyOffersWindow:getChildById('offerItem'):setItemId(0)
            buyOffersWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/images/ui/item")
            buyOffersWindow:getChildById('offerItem'):getChildById('level'):setText("")
            buyOffersWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/images/ui/item")
            buyOffersWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/images/ui/item")
			buyOffersWindow:getChildById('offersList'):destroyChildren()
			buyOffersWindow:getChildById('offerItem'):setItemId(itemInfo.spriteId)
			buyOffersWindow:getChildById('offerItem'):setTooltip(itemInfo.description)
			buyOffersWindow:getChildById('offerItem'):setItemCount(itemInfo.count)
            if itemInfo.poke_info and TABLE_POKEMON_INFO[itemInfo.poke_info.name] then
              buyOffersWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/data/images/pokeicons/"..itemInfo.poke_info.name)
              buyOffersWindow:getChildById('offerItem'):getChildById('level'):setText("Lv."..itemInfo.poke_info.level)
              buyOffersWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (itemInfo.poke_info.sex == 0 and "red" or (itemInfo.poke_info.sex == 1 and "black" or "yellow")))
              if string.find(itemInfo.poke_info.name, "Shiny") then buyOffersWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
            else
              buyOffersWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/images/ui/item")
              buyOffersWindow:getChildById('offerItem'):getChildById('level'):setText("")
              buyOffersWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/images/ui/item")
              buyOffersWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/images/ui/item")
			end
			buyOffersWindow:getChildById('offerItemName'):setText(itemInfo.item_name)
            g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETBUYITEMSOFFERSBYITEMCODE###"..",ItemCode:"..itemInfo.item_code)
			buyOffersWindow:show()
		  end)
		  menu:addOption(tr('Send message to ')..itemInfo.playerseller_name, function() g_game.openPrivateChannel(itemInfo.playerseller_name) end)
		  menu:display(mousePos)
		  self:focus()
		end
	  end
	end
	marketBuyPanel:getChildById('buyListPages'):getChildById('labelPages'):setText('Página: '..currentPage..' / '..maxPage)
	if focus == 1 then changeMarketPanel(marketBuyPanel, marketWindow:getChildById('buyTabButton')) end
	toggleBuyButtons(false)
	marketWindow:show()
  elseif receive[3] == "marketbuymakeoffer" then
    local itemInfo = Protocol_read(receive)
	for i=1, 8 do
	  local item =  makeOfferWindow:getChildById('offersList'):getChildById('item'..i)
	  if item:getItemId() == 0 then
	    item:setItemId(itemInfo.spriteId)
	    item:setTooltip(itemInfo.description)
	    item:setItemCount(itemInfo.count)
        if itemInfo.poke_info and TABLE_POKEMON_INFO[itemInfo.poke_info.name] then
          item:getChildById('poke'):setImageSource("/data/images/pokeicons/"..itemInfo.poke_info.name)
	      item:getChildById('level'):setText("Lv."..itemInfo.poke_info.level)
	      item:getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (itemInfo.poke_info.sex == 0 and "red" or (itemInfo.poke_info.sex == 1 and "black" or "yellow")))
	      if string.find(itemInfo.poke_info.name, "Shiny") then item:getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
        else
          item:getChildById('poke'):setImageSource("/images/ui/item")
	      item:getChildById('level'):setText("")
	      item:getChildById('sex'):setImageSource("/images/ui/item")
	      item:getChildById('shiny'):setImageSource("/images/ui/item")
		end
		break
	  end
	end
  elseif receive[3] == "marketbuyitemsoffers" then
    buyOffersWindow:getChildById('offersList'):destroyChildren()
	local offers = Protocol_read(receive)
	for num, offer_item in pairs(offers) do
	  local offerWidget = buyOffersWindow:getChildById('offersList'):getChildById(offer_item.playeroffer_id)
	  if not offerWidget then
	    offerWidget = g_ui.createWidget('OfferWidget', buyOffersWindow:getChildById('offersList'))
	    offerWidget:setId(offer_item.playeroffer_id)
		offerWidget:setText(offer_item.playeroffer_name)
		offerWidget.item_count = 1
	  end
	  local itemOfferWidget = offerWidget:getChildById('offerList'):getChildById('item'..offerWidget.item_count)
	  itemOfferWidget:setItemId(offer_item.spriteId)
	  itemOfferWidget:setTooltip(offer_item.description)
	  itemOfferWidget:setItemCount(offer_item.count)
      if offer_item.poke_info and TABLE_POKEMON_INFO[offer_item.poke_info.name] then
        itemOfferWidget:getChildById('poke'):setImageSource("/data/images/pokeicons/"..offer_item.poke_info.name)
	    itemOfferWidget:getChildById('level'):setText("Lv."..offer_item.poke_info.level)
	    itemOfferWidget:getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (offer_item.poke_info.sex == 0 and "red" or (offer_item.poke_info.sex == 1 and "black" or "yellow")))
	    if string.find(offer_item.poke_info.name, "Shiny") then itemOfferWidget:getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
      else
        itemOfferWidget:getChildById('poke'):setImageSource("/images/ui/item")
	    itemOfferWidget:getChildById('level'):setText("")
	    itemOfferWidget:getChildById('sex'):setImageSource("/images/ui/item")
	    itemOfferWidget:getChildById('shiny'):setImageSource("/images/ui/item")
	  end
	  itemOfferWidget.mouseRelease = function(self, mousePos, mouseButton)
        if offer_item.description:len() == 0 then return end
        local menu = g_ui.createWidget('PopupMenu')
        -- menu:setGameMenu(true)
        -- menu:addOption(tr('Info'), function() g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETPOKEMONINFO###,ItemCode:"..offer_item.item_code) end)
        -- menu:display(mousePosition)
      end
	  offerWidget.item_count = offerWidget.item_count+1
      offerWidget.onClick = function()
        if offerToMeWindow.selectedOffer and offerToMeWindow.selectedOffer ~= offerWidget then
          offerToMeWindow.selectedOffer:setImageColor('#5b5b5b')
        end
        offerToMeWindow.selectedOffer = offerWidget
        offerToMeWindow.selectedOffer:setImageColor('#172c41')
      end
	end
	marketWindow:hide()
	buyOffersWindow:show()
  elseif receive[3] == "marketsellitems" then
    local first = Protocol_read(receive)
	if first then resetSellingPanel() end
    local sellItems = Protocol_read(receive)
	for number, itemInfo in pairs(sellItems) do
	  local _time = itemInfo.time-os.time() < 0 and "Expired" or string.format("%02d:%02d:%02d", itemInfo.time/(60*60), (itemInfo.time/60)%60, itemInfo.time%60)
	  local data = {
        {text = number},
		{itemid = itemInfo.spriteId, count = itemInfo.count, tooltip = itemInfo.description, poke_info = itemInfo.poke_info,
		  mouseRelease = function(self, mousePos, mouseButton)
		    if itemInfo.description:len() == 0 then return end
            local menu = g_ui.createWidget('PopupMenu')
            -- menu:setGameMenu(true)
            -- menu:addOption(tr('Info'), function() g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETPOKEMONINFO###,ItemCode:"..itemInfo.item_code) end)
            -- menu:display(mousePosition)
		  end
		},
		{text = itemInfo.item_name},
		{text = _time, align = AlignCenter},
		{text = itemInfo.count, align = AlignCenter},
		{text = getFormattedMoney(itemInfo.price)..' ', align = AlignRightCenter},
	  }
	  local row = sellPanelTable:addRow(data, 34)
	  row.item_code = itemInfo.item_code
	  row.price = itemInfo.price
	  row.count = itemInfo.count
	  row.time = itemInfo.time
	  row.description = itemInfo.description
	  row.onMouseRelease = function(self, mousePos, mouseButton)
	    if mouseButton == MouseRightButton then
		  local menu = g_ui.createWidget('PopupMenu')
		  menu:addOption(tr('Cancel'), function() 
            g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETREMOVESELLITEM###,ItemCode:"..itemInfo.item_code)
		  end)
		  menu:display(mousePos)
		  self:focus()
		end
	  end
	end
  elseif receive[3] == "marketsellitemschecked" then
    local itemInfo = Protocol_read(receive)
	-- if itemInfo.poke_info and isInArray(allPokemons, itemInfo.poke_info) then
	  -- itemToSell:setImageSource("/images/pokedex/icons/"..itemInfo.poke_info)
	-- else
	itemToSell:setItemId(itemInfo.spriteId)
	-- end
	itemToSell:setTooltip(itemInfo.description)
	itemToSell.itemid = itemInfo.itemid
	itemToSell.spriteId = itemInfo.spriteId
	itemToSell.item_code = itemInfo.item_code
    if itemInfo.poke_info and TABLE_POKEMON_INFO[itemInfo.poke_info.name] then
      itemToSell:getChildById('poke'):setImageSource("/data/images/pokeicons/"..itemInfo.poke_info.name)
      itemToSell:getChildById('level'):setText("Lv."..itemInfo.poke_info.level)
      itemToSell:getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (itemInfo.poke_info.sex == 0 and "red" or (itemInfo.poke_info.sex == 1 and "black" or "yellow")))
      if string.find(itemInfo.poke_info.name, "Shiny") then itemToSell:getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
    else
      itemToSell:getChildById('poke'):setImageSource("/images/ui/item")
      itemToSell:getChildById('level'):setText("")
      itemToSell:getChildById('sex'):setImageSource("/images/ui/item")
      itemToSell:getChildById('shiny'):setImageSource("/images/ui/item")
	end
	itemToSellCount:setEnabled(true)
	itemToSellCount:setValue(1)
	itemToSellCount:setMinimum(1)
	itemToSellCount:setMaximum(itemInfo.count)
	itemToSellCount.onValueChange = nil
	itemToSellCount.onValueChange = function(self)
      local value = math.max(1, itemToSellCount:getValue())
	  itemToSell:setItemCount(value)
	  itemToSellCount:setText(value)
	  local priceNumber = tonumber(textEditSellPrice:getText())
	  if priceNumber then
	    marketSellPanel:getChildById('panelToSell'):getChildById('totalValue'):setText("Preço: "..getFormattedMoney2((priceNumber*value)))
	    marketSellPanel:getChildById('panelToSell'):getChildById('feeValue'):setText("Taxa: "..getFormattedMoney2(getMarketFee(priceNumber*value)))
	    marketSellPanel:getChildById('panelToSell'):getChildById('totalAndFeeValue'):setText("Total: "..getFormattedMoney2((priceNumber*value)-getMarketFee(priceNumber*value)))
	  end
	end
	itemToSellCount:setText(1)
	marketSellPanel:getChildById('panelToSell'):getChildById('name'):setText(itemInfo.poke_info.name)
	marketSellPanel:getChildById('panelToSell'):getChildById('totalValue'):setText("Preço: $0")
	marketSellPanel:getChildById('panelToSell'):getChildById('feeValue'):setText("Taxa: $0")
	marketSellPanel:getChildById('panelToSell'):getChildById('totalAndFeeValue'):setText("Total: $0")
	textEditSellPrice.itemInfo = itemInfo
	sellButton:setEnabled(true)
  elseif receive[3] == "market_myitems_withoffers" then
    local first = Protocol_read(receive)
	if first then resetOffersPanels(1) end
    local myitems_withoffers = Protocol_read(receive)
	local number = 1
	for item_code, market_item in pairs(myitems_withoffers) do
	  local _time = market_item.time-os.time() < 0 and "Expired" or string.format("%02d:%02d:%02d", market_item.time/(60*60), (market_item.time/60)%60, market_item.time%60)
	  local data = {
        {text = number},
        {itemid = market_item.spriteId, count = market_item.count, tooltip = market_item.description, poke_info = market_item.poke_info,
		  mouseRelease = function(self, mousePos, mouseButton)
		    if market_item.description:len() == 0 then return end
            local menu = g_ui.createWidget('PopupMenu')
            -- menu:addOption(tr('Info'), function() g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETPOKEMONINFO###,ItemCode:"..item_code) end)
            -- menu:display(mousePosition)
		  end
		},
        {text = market_item.item_name},
        {text = #market_item.offers, align = AlignCenter},
        {text = _time, align = AlignCenter},
		-- {poke_info = market_item.poke_info},
        {button = function()
		  offerToMeWindow:getChildById('offerItem'):setTooltip('')
	      offerToMeWindow:getChildById('offerItem'):setItemId(0)
          offerToMeWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/images/ui/item")
          offerToMeWindow:getChildById('offerItem'):getChildById('level'):setText("")
          offerToMeWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/images/ui/item")
          offerToMeWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/images/ui/item")
		  offerToMeWindow:getChildById('offersList'):destroyChildren()
		  offerToMeWindow:getChildById('offerItem'):setItemId(market_item.spriteId)
		  offerToMeWindow:getChildById('offerItem'):setTooltip(market_item.description)
		  offerToMeWindow:getChildById('offerItem'):setItemCount(market_item.count)
		  if market_item.poke_info and TABLE_POKEMON_INFO[market_item.poke_info.name] then
            offerToMeWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/data/images/pokeicons/"..market_item.poke_info.name)
            offerToMeWindow:getChildById('offerItem'):getChildById('level'):setText("Lv."..market_item.poke_info.level)
            offerToMeWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (market_item.poke_info.sex == 0 and "red" or (market_item.poke_info.sex == 1 and "black" or "yellow")))
            if string.find(market_item.poke_info.name, "Shiny") then offerToMeWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
          else
            offerToMeWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/images/ui/item")
            offerToMeWindow:getChildById('offerItem'):getChildById('level'):setText("")
            offerToMeWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/images/ui/item")
            offerToMeWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/images/ui/item")
          end
		  offerToMeWindow:getChildById('offerItem').onMouseRelease = function(self, mousePos, mouseButton)
		    if market_item.description:len() == 0 then return end
            local menu = g_ui.createWidget('PopupMenu')
            -- menu:setGameMenu(true)
            -- menu:addOption(tr('Info'), function() g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETPOKEMONINFO###,ItemCode:"..item_code) end)
            -- menu:display(mousePosition)
		  end
		  offerToMeWindow:getChildById('offerItemName'):setText(market_item.item_name)
		  offerToMeWindow:getChildById('offersList'):destroyChildren()
		  for num, offers in ipairs(market_item.offers) do
			for _num, offer_item in ipairs(offers) do
			  local offerWidget = offerToMeWindow:getChildById('offersList'):getChildById(offer_item.playeroffer_id)
			  if not offerWidget then
	            offerWidget = g_ui.createWidget('OfferWidget', offerToMeWindow:getChildById('offersList'))
	            offerWidget:setId(offer_item.playeroffer_id)
	        	offerWidget:setText(offer_item.playeroffer_name)
	        	offerWidget.item_count = 1
				offerWidget.item_code = offer_item.item_code
		        offerWidget.playeroffer_id = offer_item.playeroffer_id
	          end
			  offerWidget.onClick = function()
				if offerToMeWindow.selectedOffer and offerToMeWindow.selectedOffer ~= offerWidget then
				  offerToMeWindow.selectedOffer:setBackgroundColor('alpha')
				end
				offerToMeWindow.selectedOffer = offerWidget
				offerToMeWindow.selectedOffer:setBackgroundColor('#172c41')
			  end
	          local itemOfferWidget = offerWidget:getChildById('offerList'):getChildById('item'..offerWidget.item_count)
	          itemOfferWidget:setItemId(offer_item.spriteId)
	          itemOfferWidget:setTooltip(offer_item.description)
	          itemOfferWidget:setItemCount(offer_item.count)
              if offer_item.poke_info and TABLE_POKEMON_INFO[offer_item.poke_info.name] then
                itemOfferWidget:getChildById('poke'):setImageSource("/data/images/pokeicons/"..offer_item.poke_info.name)
	            itemOfferWidget:getChildById('level'):setText("Lv."..offer_item.poke_info.level)
	            itemOfferWidget:getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (offer_item.poke_info.sex == 0 and "red" or (offer_item.poke_info.sex == 1 and "black" or "yellow")))
	            if string.find(offer_item.poke_info.name, "Shiny") then itemOfferWidget:getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
              else
                itemOfferWidget:getChildById('poke'):setImageSource("/images/ui/item")
	            itemOfferWidget:getChildById('level'):setText("")
	            itemOfferWidget:getChildById('sex'):setImageSource("/images/ui/item")
	            itemOfferWidget:getChildById('shiny'):setImageSource("/images/ui/item")
			  end
		      itemOfferWidget.onMouseRelease = function(self, mousePos, mouseButton)
		        if market_item.description:len() == 0 then return end
                local menu = g_ui.createWidget('PopupMenu')
                -- menu:addOption(tr('Info'), function() g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETPOKEMONINFO###,ItemCode:"..offer_item.item_code) end)
                -- menu:display(mousePosition)
		      end
	          offerWidget.item_count = offerWidget.item_count+1
			end
			marketWindow:hide()
	        offerToMeWindow:show()
		  end
		  offerToMeWindow:show()
		end, bText = tr("See"), bImage = tr("/images/ui/ver")},
	  }
	  local row = offerPanelTable1:addRow(data, 34)
	  row.offers = market_item.offers
	  row.time = market_item.time
      number = number+1
	end
  elseif receive[3] == "market_myOffers" then
    local first = Protocol_read(receive)
	if first then resetOffersPanels(2) end
	local myOffers = Protocol_read(receive)
	local number = 1
	for item_code, market_item in pairs(myOffers) do
	  local data = {
        {text = number},
        {itemid = market_item.spriteId, count = market_item.count, tooltip = market_item.description, poke_info = market_item.poke_info,
		  mouseRelease = function(self, mousePos, mouseButton)
		    if market_item.description:len() == 0 then return end
            local menu = g_ui.createWidget('PopupMenu')
            -- menu:setGameMenu(true)
            -- menu:addOption(tr('Info'), function() g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETPOKEMONINFO###,ItemCode:"..item_code) end)
            -- menu:display(mousePosition)
		  end
		},
        {text = market_item.item_name},
        {text = market_item.playerseller_name, align = AlignCenter},
		-- {poke_info = market_item.poke_info},
        {button = function()
		  myCurrentOfferWindow:getChildById('offerItem'):setTooltip('')
	      myCurrentOfferWindow:getChildById('offerItem'):setItemId(0)
          myCurrentOfferWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/images/ui/item")
          myCurrentOfferWindow:getChildById('offerItem'):getChildById('level'):setText("")
          myCurrentOfferWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/images/ui/item")
          myCurrentOfferWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/images/ui/item")
	      for slot=1, 8 do
		    local item =  myCurrentOfferWindow:getChildById('offersList'):getChildById('item'..slot)
			item:setTooltip('')
	        item:setItemId(0)
            item:getChildById('poke'):setImageSource("/images/ui/item")
            item:getChildById('level'):setText("")
            item:getChildById('sex'):setImageSource("/images/ui/item")
            item:getChildById('shiny'):setImageSource("/images/ui/item")
		  end
          myCurrentOfferWindow:getChildById('offerItem'):setItemId(market_item.spriteId)
          myCurrentOfferWindow:getChildById('offerItem'):setTooltip(market_item.description)
          myCurrentOfferWindow:getChildById('offerItem'):setItemCount(market_item.count)
		  if market_item.poke_info and TABLE_POKEMON_INFO[market_item.poke_info.name] then
            myCurrentOfferWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/data/images/pokeicons/"..market_item.poke_info.name)
            myCurrentOfferWindow:getChildById('offerItem'):getChildById('level'):setText("Lv."..market_item.poke_info.level)
            myCurrentOfferWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (market_item.poke_info.sex == 0 and "red" or (market_item.poke_info.sex == 1 and "black" or "yellow")))
            if string.find(market_item.poke_info.name, "Shiny") then myCurrentOfferWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
          else
            myCurrentOfferWindow:getChildById('offerItem'):getChildById('poke'):setImageSource("/images/ui/item")
            myCurrentOfferWindow:getChildById('offerItem'):getChildById('level'):setText("")
            myCurrentOfferWindow:getChildById('offerItem'):getChildById('sex'):setImageSource("/images/ui/item")
            myCurrentOfferWindow:getChildById('offerItem'):getChildById('shiny'):setImageSource("/images/ui/item")
          end
          myCurrentOfferWindow:getChildById('offerItemName'):setText(market_item.item_name)
	      for slot, offer_item in ipairs(market_item.offers) do
	        local item =  myCurrentOfferWindow:getChildById('offersList'):getChildById('item'..slot)
	        if item:getItemId() == 0 then
	          item:setItemId(offer_item.spriteId)
	          item:setTooltip(offer_item.description)
	          item:setItemCount(offer_item.count)
	          item:setTooltip(offer_item.description)
              if offer_item.poke_info and TABLE_POKEMON_INFO[offer_item.poke_info.name] then
                item:getChildById('poke'):setImageSource("/data/images/pokeicons/"..offer_item.poke_info.name)
	            item:getChildById('level'):setText("Lv."..offer_item.poke_info.level)
	            item:getChildById('sex'):setImageSource("/data/images/game/skulls/skull_".. (offer_item.poke_info.sex == 0 and "red" or (offer_item.poke_info.sex == 1 and "black" or "yellow")))
	            if string.find(offer_item.poke_info.name, "Shiny") then item:getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star") end
              else
                item:getChildById('poke'):setImageSource("/images/ui/item")
	            item:getChildById('level'):setText("")
	            item:getChildById('sex'):setImageSource("/images/ui/item")
	            item:getChildById('shiny'):setImageSource("/images/ui/item")
			  end
	        end
	      end
		  marketWindow:hide()
		  myCurrentOfferWindow:show()
		end, bText = tr("See"), bImage = tr("/images/ui/ver")},
        {button = function()
          g_game.getProtocolGame():sendExtendedOpcode(marketOpcode, "###MARKETCANCELOFFER###,ItemCode:"..item_code)
		end, bText = tr("Cancel"), bImage = tr("/images/ui/cancelar")},
	  }
	  local row = offerPanelTable2:addRow(data, 34)
	  row.offers = market_item.offers
	  number = number+1
	end
  end
  
end

function getFormattedMoney(value)
  value = tonumber(value)
  local valueLen = tostring(value):len()
  local valueText = ""
  if value == 0 then
    valueText = "-"
  elseif value < 1000 then
    valueText = valueText..value
  else
    if value < 1000000 then
      valueText = string.sub(value, 0, valueLen - 3)..(value % 1000 == 0 and "" or "."..string.sub(value, valueLen - 2, valueLen)).."K"
    else
  	  valueText = string.sub(value, 0, valueLen - 6)..(value % 1000 == 0 and "" or "."..string.sub(value, 2, 3)).."KK"
    end
  end
  return valueText
end

function getFormattedMoney2(value)
  local valueText = ""
  if value == 0 then
    valueText = "-"
  elseif value < 1000 then
    valueText = valueText..value
  else
    if value < 10000 then
	  valueText = valueText..string.sub(value, 0, 1).."."..valueText..string.sub(value, 2, 4)
	elseif value < 100000 then
	  valueText = valueText..string.sub(value, 0, 2).."."..valueText..string.sub(value, 3, 5)
	elseif value < 1000000 then
	  valueText = valueText..string.sub(value, 0, 3).."."..valueText..string.sub(value, 4, 6)
	elseif value < 10000000 then
	  valueText = valueText..string.sub(value, 0, 1).."."..valueText..string.sub(value, 2, 4).."."..valueText..string.sub(value, 5, 8)
	elseif value <= 100000000 then
	  valueText = valueText..string.sub(value, 0, 2).."."..valueText..string.sub(value, 3, 5).."."..valueText..string.sub(value, 6, 9)
	else
	  valueText = " invalido."
	end
  end
  return "$"..valueText
end

function getMarketFee(price)
  return math.max(1, price / 1000)
end

--CLOSE IN MOVE
function updatePosition()
	local player = g_game.getLocalPlayer()
	if not player then
		return 
	end
	local pos = player:getPosition()
	if not pos then return end
	reset()	
end
function reset()
    offline()
end