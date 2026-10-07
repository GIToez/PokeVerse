local marketWindow, currentMarketPanel, currentTabButton
local marketOpcode = 64

local marketBuyPanel, marketSearchTextEdit, marketBuyComboBox, buyPanelTable, buyPanelTableData, selectedBuyRow, buyOffersWindow, makeOfferWindow, buyNowWindow
local currentPage, maxPage, currentOder = 1, 1, 'timedesc'
local itemToSell, itemToSellCount, textEditSellPrice, checkBoxOnlyOffers, sellButton
local sellPanelTable, sellPanelTableData
local offerPanelTable1, offerPanelTable2, offerPanelTableData1, offerPanelTableData2, offerToMeWindow, myCurrentOfferWindow
local marketSellPanel, marketOfferPanel, marketHistoricPanel
local marketHistoricList
local sellSyncEvent, offerSyncEvent
local offerCountWindow

-- The server matches categories by these exact names; "Todos" means all categories.
local comboBoxOptions = {
  {"All", "Todos"}, {"Items", "Items"}, {"Stones", "Stones"}, {"Poke Balls", "Poke Balls"}, {"Diamonds", "Diamonds"},
  {"Addons", "Addons"}, {"Outfits", "Outfits"}, {"Pokemon", "Pokemon"}, {"Held Item", "Held Item"},
  {"Furnitures", "Furnitures"}, {"Berries", "Berries"}, {"Plates", "Plates"}, {"Dolls", "Dolls"},
  {"Foods", "Foods"}, {"Utilities", "Utilities"}, {"Supplies", "Supplies"},
}

local function toggleOrder(a, b)
  currentOder = currentOder == a and b or a
end

local buyHeader = {
  [1] = {text = '#',                width = 30,  onClick = function() toggleOrder('timedesc', 'timeasc') refreshBuyItems() end},
  [2] = {text = tr('Item'),         width = 50,  onClick = function() toggleOrder('itemdesc', 'itemasc') refreshBuyItems() end},
  [3] = {text = tr('Name'),         width = 250, onClick = function() toggleOrder('itemdesc', 'itemasc') refreshBuyItems() end},
  [4] = {text = tr('Seller'),       width = 247, onClick = function() toggleOrder('sellerdesc', 'sellerasc') refreshBuyItems() end},
  [5] = {text = tr('Amount'),       width = 100, onClick = function() toggleOrder('amountdesc', 'amountasc') refreshBuyItems() end},
  [6] = {text = tr('Unit price'),   width = 125, onClick = function() toggleOrder('pricedesc', 'priceasc') refreshBuyItems() end},
}

local sellHeader = {
  [1] = {text = '#',                width = 30,  onClick = function() refreshSellItems() end},
  [2] = {text = tr('Item'),         width = 50,  onClick = function() refreshSellItems() end},
  [3] = {text = tr('Name'),         width = 250, onClick = function() refreshSellItems() end},
  [4] = {text = tr('Time'),         width = 247, onClick = function() refreshSellItems() end},
  [5] = {text = tr('Amount'),       width = 100, onClick = function() refreshSellItems() end},
  [6] = {text = tr('Unit price'),   width = 125, onClick = function() refreshSellItems() end},
}

local offerHeader1 = {
  [1] = {text = '#',                width = 30},
  [2] = {text = tr('Item'),         width = 50},
  [3] = {text = tr('Name'),         width = 250},
  [4] = {text = tr('Offers'),       width = 238},
  [5] = {text = tr('Time'),         width = 100},
  [6] = {text = tr('Action'),       width = 125},
}

local offerHeader2 = {
  [1] = {text = '#',                width = 30},
  [2] = {text = tr('Item'),         width = 50},
  [3] = {text = tr('Name'),         width = 240},
  [4] = {text = tr('Seller'),       width = 247},
  [5] = {text = tr('Offer'),        width = 100},
  [6] = {text = tr('Action'),       width = 125},
}

local function formatRemaining(time)
  local remaining = time - os.time()
  if remaining < 0 then return tr('Expired') end
  return string.format("%02d:%02d:%02d", remaining / 3600, (remaining / 60) % 60, remaining % 60)
end

local function setPokeIcon(widget, poke_info)
  if poke_info and TABLE_POKEMON_INFO[poke_info.name] then
    widget:getChildById('poke'):setImageSource("/data/images/pokeicons/" .. poke_info.name)
    widget:getChildById('level'):setText("Lv." .. poke_info.level)
    widget:getChildById('sex'):setImageSource("/data/images/game/skulls/skull_" .. (poke_info.sex == 0 and "red" or (poke_info.sex == 1 and "black" or "yellow")))
    if string.find(poke_info.name, "Shiny", 1, true) then
      widget:getChildById('shiny'):setImageSource("/data/images/game/npcicons/icon_star")
    else
      widget:getChildById('shiny'):setImageSource("/images/ui/item")
    end
  else
    widget:getChildById('poke'):setImageSource("/images/ui/item")
    widget:getChildById('level'):setText("")
    widget:getChildById('sex'):setImageSource("/images/ui/item")
    widget:getChildById('shiny'):setImageSource("/images/ui/item")
  end
end

local function clearItemWidget(widget)
  widget:setItemId(0)
  widget:setTooltip('')
  setPokeIcon(widget, nil)
end

local function showItem(widget, spriteId, count, description, poke_info)
  widget:setItemId(spriteId)
  widget:setItemCount(count)
  widget:setTooltip(description or '')
  setPokeIcon(widget, poke_info)
end

-- Redemption's UITable only builds text cells; the market also needs item and button cells.
local function addMarketRow(tbl, data, height)
  local plain = {}
  for colId, column in ipairs(data) do
    plain[colId] = {text = column.text ~= nil and tostring(column.text) or nil, width = column.width}
  end
  local row = tbl:addRow(plain, height)
  if not row then return end
  for colId, column in ipairs(data) do
    local col = tbl.columns[row.rowId][colId]
    if column.tooltip then col:setTooltip(column.tooltip) end
    col:setTextAlign(column.align or AlignLeftCenter)
    if column.itemid then
      local itemCol = g_ui.createWidget("BuyTableUIItem", col)
      showItem(itemCol, column.itemid, column.count, column.tooltip, column.poke_info)
    end
    if column.button then
      local buttonColumn = g_ui.createWidget('MarketOffersButton', col)
      buttonColumn:setId(column.buttonId or ('button' .. colId))
      buttonColumn:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
      buttonColumn:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
      buttonColumn:setImageSource(column.bImage)
      buttonColumn:setTooltip(column.bText)
      buttonColumn.onClick = column.button
    end
  end
  return row
end

-- Redemption applies a table's *-style properties on a later event; set them before adding the header.
local function setupTable(tbl, tableData, header)
  tbl:setRowStyle('TableRow', true)
  tbl:setColumnStyle('PanelTableColumn', true)
  tbl:setHeaderRowStyle('PanelTableHeaderRow')
  tbl:setHeaderColumnStyle('PanelTableHeaderColumn')
  tbl:setTableData(tableData)
  tbl:addHeader(header)
  addEvent(function()
    for colId, col in ipairs(tbl.headerColumns or {}) do
      if header[colId] then col:setWidth(header[colId].width) end
    end
  end)
end

local function send(text)
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(marketOpcode, text)
  end
end

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
  connect(LocalPlayer, {
    onPositionChange = updatePosition
  })

  local rootPanel = modules.game_interface.getRootPanel()
  marketWindow = g_ui.createWidget('MarketWindow', rootPanel)

  marketBuyPanel      = g_ui.createWidget('BuyPanel', marketWindow)
  marketSellPanel     = g_ui.createWidget('SellPanel', marketWindow)
  marketOfferPanel    = g_ui.createWidget('OfferPanel', marketWindow)
  marketHistoricPanel = g_ui.createWidget('HistoricPanel', marketWindow)

  marketBuyComboBox = marketBuyPanel:getChildById('comboBox')
  marketSearchTextEdit = marketBuyPanel:getChildById('buySearchTextEdit')
  for _, option in ipairs(comboBoxOptions) do
    marketBuyComboBox:addOption(tr(option[1]), option[2])
  end
  marketBuyComboBox.onOptionChange = refreshBuyItems
  buyPanelTable = marketBuyPanel:getChildById('panelTable')
  buyPanelTableData = marketBuyPanel:getChildById('panelTableData')
  setupTable(buyPanelTable, buyPanelTableData, buyHeader)
  buyPanelTable.onSelectionChange = function(tbl, selectedRow)
    if not selectedRow then return end
    toggleBuyButtons(true)
    selectedBuyRow = selectedRow
    if selectedRow.price == 0 then
      marketBuyPanel:getChildById('makeOfferButton'):setImageSource("images/buttons/ofertar")
      marketBuyPanel:getChildById('buyNowButton'):setImageSource("images/buttons/comprar_off")
      marketBuyPanel:getChildById('buyNowButton'):setEnabled(false)
    else
      marketBuyPanel:getChildById('buyNowButton'):setImageSource("images/buttons/comprar")
      marketBuyPanel:getChildById('makeOfferButton'):setImageSource("images/buttons/ofertar")
    end
  end

  buyOffersWindow = g_ui.createWidget('BuyOffersWindow', rootPanel)
  buyNowWindow    = g_ui.createWidget('BuyNowWindow', rootPanel)
  makeOfferWindow = g_ui.createWidget('MakeOfferWindow', rootPanel)
  for _, slot in ipairs(makeOfferWindow:getChildById('offersList'):getChildren()) do
    slot.onDrop = onMakeOfferDrop
  end

  local panelToSell = marketSellPanel:getChildById('panelToSell')
  itemToSell         = panelToSell:getChildById('itemToSell')
  itemToSellCount    = panelToSell:getChildById('itemToSellCount')
  textEditSellPrice  = panelToSell:getChildById('textEditSellPrice')
  checkBoxOnlyOffers = panelToSell:getChildById('checkBoxOnlyOffers')
  sellButton         = panelToSell:getChildById('sellButton')
  sellPanelTable     = marketSellPanel:getChildById('panelTable')
  sellPanelTableData = marketSellPanel:getChildById('panelTableData')
  setupTable(sellPanelTable, sellPanelTableData, sellHeader)

  offerPanelTable1     = marketOfferPanel:getChildById('panelTable1')
  offerPanelTableData1 = marketOfferPanel:getChildById('panelTableData1')
  setupTable(offerPanelTable1, offerPanelTableData1, offerHeader1)

  offerPanelTable2     = marketOfferPanel:getChildById('panelTable2')
  offerPanelTableData2 = marketOfferPanel:getChildById('panelTableData2')
  setupTable(offerPanelTable2, offerPanelTableData2, offerHeader2)

  offerToMeWindow = g_ui.createWidget('OfferToMeWindow', rootPanel)
  myCurrentOfferWindow = g_ui.createWidget('MyCurrentOfferWindow', rootPanel)

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
  disconnect(LocalPlayer, {
    onPositionChange = updatePosition
  })
  ProtocolGame.unregisterExtendedOpcode(marketOpcode)
  removeEvent(sellSyncEvent)
  removeEvent(offerSyncEvent)
  destroyOfferCountWindow()
  marketWindow:destroy()
  buyOffersWindow:destroy()
  buyNowWindow:destroy()
  makeOfferWindow:destroy()
  offerToMeWindow:destroy()
  myCurrentOfferWindow:destroy()
end

function getOfferCountWindow()
  return offerCountWindow
end

function destroyOfferCountWindow()
  if offerCountWindow and not offerCountWindow:isDestroyed() then
    offerCountWindow:destroy()
  end
  offerCountWindow = nil
end

function resetBuyingPanel()
  marketSearchTextEdit:setText("")
  buyPanelTable:clearData()
  selectedBuyRow = nil
end

function resetSellingPanel()
  itemToSell:setImageSource("/images/ui/item")
  clearItemWidget(itemToSell)
  itemToSell.itemid = 0
  itemToSell.spriteId = 0
  itemToSell.item_code = ''
  local panelToSell = marketSellPanel:getChildById('panelToSell')
  panelToSell:getChildById('name'):setText("")
  panelToSell:getChildById('totalValue'):setText("")
  panelToSell:getChildById('feeValue'):setText("")
  panelToSell:getChildById('totalAndFeeValue'):setText("")
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
  resetOffersPanels(1)
  resetOffersPanels(2)
  marketHistoricList:destroyChildren()
  hide()
end

local function hideDialogs()
  buyOffersWindow:hide()
  buyNowWindow:hide()
  makeOfferWindow:hide()
  offerToMeWindow:hide()
  myCurrentOfferWindow:hide()
  destroyOfferCountWindow()
end

function hide()
  marketWindow:hide()
  hideDialogs()
end

function show()
  hideDialogs()
  marketWindow:show()
  marketWindow:raise()
end

function isVisible()
  return marketWindow and marketWindow:isVisible()
end

function toggleBuyButtons(enabled)
  marketBuyPanel:getChildById('buyNowButton'):setEnabled(enabled)
  marketBuyPanel:getChildById('makeOfferButton'):setEnabled(enabled)
  marketBuyPanel:getChildById('buyNowButton'):setImageSource("images/buttons/comprar_off")
  marketBuyPanel:getChildById('makeOfferButton'):setImageSource("images/buttons/ofertar_off")
end

function getMakeOfferWindow()
  return makeOfferWindow
end

function showMakeOfferWindow()
  if not selectedBuyRow then return end
  marketWindow:hide()
  for _, child in ipairs(makeOfferWindow:getChildById('offersList'):getChildren()) do
    clearItemWidget(child)
  end
  showItem(makeOfferWindow:getChildById('offerItem'), selectedBuyRow.spriteId, selectedBuyRow.count, selectedBuyRow.description, selectedBuyRow.poke_info)
  makeOfferWindow:getChildById('offerItemName'):setText(selectedBuyRow.name)
  makeOfferWindow:show()
  makeOfferWindow:raise()
end

function marketAcceptOffer()
  if not offerToMeWindow.selectedOffer then return end
  send("###MARKETACCEPTOFFER###,ItemCode:" .. offerToMeWindow.selectedOffer.item_code .. ",PlayerOfferId:" .. offerToMeWindow.selectedOffer.playeroffer_id)
  show()
end

function marketRefuseOffer()
  if not offerToMeWindow.selectedOffer then return end
  send("###MARKETREFUSEOFFER###,ItemCode:" .. offerToMeWindow.selectedOffer.item_code .. ",PlayerOfferId:" .. offerToMeWindow.selectedOffer.playeroffer_id)
  show()
end

function showBuyNowWindow()
  if not selectedBuyRow or selectedBuyRow.price == 0 then return end
  marketWindow:hide()
  local rowItem = buyNowWindow:getChildById('item')
  showItem(rowItem, selectedBuyRow.spriteId, selectedBuyRow.count, selectedBuyRow.description, selectedBuyRow.poke_info)
  local rowScrollbar = buyNowWindow:getChildById('countScrollBar')
  rowScrollbar:setMinimum(1)
  rowScrollbar:setMaximum(selectedBuyRow.count)
  rowScrollbar:setValue(selectedBuyRow.count)

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

  rowScrollbar.onValueChange = function(self, value)
    rowItem:setItemCount(value)
    rowPrice:setText(getFormattedMoney2(value * selectedBuyRow.price))
    rowSpinBox.onValueChange = nil
    rowSpinBox:setValue(value)
    rowSpinBox.onValueChange = onSpinBoxValueChange
  end

  local buyFunc = function()
    buyItem(rowScrollbar:getValue())
    show()
  end
  local cancelFunc = function()
    show()
  end
  buyNowWindow.onEnter = buyFunc
  buyNowWindow.onEscape = cancelFunc
  buyNowWindow:getChildById('buttonOk').onClick = buyFunc
  buyNowWindow:getChildById('buttonCancel').onClick = cancelFunc
  buyNowWindow:show()
  buyNowWindow:raise()
end

function doPostOffer()
  if not selectedBuyRow then return show() end
  send("###MARKETBUYPOSTOFFER###,ItemCode:" .. selectedBuyRow.item_code)
  show()
end

function doCancelMakeOffer()
  if not selectedBuyRow then return show() end
  send("###MARKETBUYCANCELMAKEOFFER###,ItemCode:" .. selectedBuyRow.item_code)
  show()
end

function marketMakeOffer(x, y, z, count)
  if not selectedBuyRow then return end
  send("###MARKETBUYMAKEOFFER###,ItemCode:" .. selectedBuyRow.item_code .. ",Count:" .. count .. ",X:" .. x .. ",Y:" .. y .. ",Z:" .. z)
end

local function askOfferCount(item, pos)
  destroyOfferCountWindow()
  local count = item:getCount()
  offerCountWindow = g_ui.createWidget('CountWindow', rootWidget)
  local itembox = offerCountWindow:getChildById('item')
  local scrollbar = offerCountWindow:getChildById('countScrollBar')
  itembox:setItemId(item:getId())
  itembox:setItemCount(count)
  scrollbar:setMinimum(1)
  scrollbar:setMaximum(count)
  scrollbar:setValue(count)
  scrollbar.onValueChange = function(self, value)
    itembox:setItemCount(value)
  end
  local confirm = function()
    local amount = scrollbar:getValue()
    destroyOfferCountWindow()
    marketMakeOffer(pos.x, pos.y, pos.z, amount)
  end
  offerCountWindow.onEnter = confirm
  offerCountWindow.onEscape = destroyOfferCountWindow
  offerCountWindow:getChildById('buttonOk').onClick = confirm
  offerCountWindow:getChildById('buttonCancel').onClick = destroyOfferCountWindow
end

function onMakeOfferDrop(self, widget, mousePos)
  local item = widget and widget.currentDragThing
  if not item or not item:isItem() then return false end
  local pos = item:getPosition()
  if not pos or pos.x ~= 65535 then return false end
  if item:getCount() <= 1 or g_keyboard.isCtrlPressed() then
    marketMakeOffer(pos.x, pos.y, pos.z, item:getCount())
  elseif g_keyboard.isShiftPressed() then
    marketMakeOffer(pos.x, pos.y, pos.z, 1)
  else
    askOfferCount(item, pos)
  end
  return true
end

function buyItem(count)
  if not selectedBuyRow then return end
  send("###MARKETBUYITEM###,ItemCode:" .. selectedBuyRow.item_code .. ",Count:" .. count)
end

function refreshBuyItems()
  local search = marketSearchTextEdit:getText()
  local option = marketBuyComboBox:getCurrentOption()
  local protocoltext = "###MARKETBUYITEMS###"
  protocoltext = protocoltext .. (#search >= 3 and ',Search:' .. search or 'NotSearch')
  protocoltext = protocoltext .. ',Category:' .. (option and option.data or 'Todos')
  protocoltext = protocoltext .. ',Page:' .. currentPage
  protocoltext = protocoltext .. ',Order:' .. currentOder
  send(protocoltext)
end

function refreshOffersItems()
  send("###MARKETOFFERSITEMS###,Order:" .. currentOder)
end

function doPlaceItemForSale()
  if not itemToSell.itemid or itemToSell.itemid <= 0 then return end
  local count = math.max(1, itemToSellCount:getValue())
  local protocoltext = "###MARKETSELLITEM###,ItemCode:" .. tostring(itemToSell.item_code or '')
  protocoltext = protocoltext .. ",ItemId:" .. itemToSell.itemid .. ",Count:" .. count .. ",Price:" .. textEditSellPrice:getText() .. ",OnlyOffer:" .. (checkBoxOnlyOffers:isChecked() and 0 or 1)
  send(protocoltext)
end

local function setSellTotals(price, fee, total)
  local panelToSell = marketSellPanel:getChildById('panelToSell')
  panelToSell:getChildById('totalValue'):setText(tr('Price') .. ": " .. price)
  panelToSell:getChildById('feeValue'):setText(tr('Fee') .. ": " .. fee)
  panelToSell:getChildById('totalAndFeeValue'):setText(tr('Total') .. ": " .. total)
end

function ResetValueItemSell()
  textEditSellPrice:setText('')
  setSellTotals("$0", "$0", "$0")
end

function refreshSellItems()
  send('###MARKETSELLITEMS###')
end

function refreshAllMarket()
  send('###MARKETALL###')
end

function checkCanSell(pos)
  send('###CHECKCANSELL###,X:' .. pos.x .. ',Y:' .. pos.y .. ',Z:' .. pos.z)
end

function selectItemToSell()
  local gameInterface = modules.game_interface
  local mouseGrabberWidget = gameInterface.mouseGrabberWidget
  if not mouseGrabberWidget then return end
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')

  mouseGrabberWidget.onMouseRelease = function(self, mousePosition, mouseButton)
    if mouseButton == MouseLeftButton then
      local clickedWidget = gameInterface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
      if clickedWidget and clickedWidget:getClassName() == 'UIItem' and clickedWidget:getItem() then
        checkCanSell(clickedWidget:getItem():getPosition())
      end
    end
    g_mouse.popCursor('target')
    self:ungrabMouse()
    mouseGrabberWidget.onMouseRelease = gameInterface.onMouseGrabberRelease
    ResetValueItemSell()
  end
end

function syncMarketSellItems()
  removeEvent(sellSyncEvent)
  for w = 1, sellPanelTableData:getChildCount() do
    local row = sellPanelTableData:getChildByIndex(w)
    if row and row.time then
      row:getChildByIndex(4):setText(formatRemaining(row.time))
    end
  end
  sellSyncEvent = scheduleEvent(syncMarketSellItems, 1000)
end

function syncMarketOfferItems()
  removeEvent(offerSyncEvent)
  for w = 1, offerPanelTableData1:getChildCount() do
    local row = offerPanelTableData1:getChildByIndex(w)
    if row and row.time then
      row:getChildByIndex(5):setText(formatRemaining(row.time))
    end
  end
  offerSyncEvent = scheduleEvent(syncMarketOfferItems, 1000)
end

function toPage(num, next, max)
  local oldPage = currentPage
  currentPage = num and num or (max and maxPage or (next and (currentPage + 1 >= maxPage and maxPage or currentPage + 1) or (currentPage - 1 <= 0 and 1 or currentPage - 1)))
  if currentPage == oldPage then return end
  refreshBuyItems()
end

local function updateSellTotals()
  local value = math.max(1, itemToSellCount:getValue())
  local priceNumber = tonumber(textEditSellPrice:getText())
  if priceNumber then
    setSellTotals(getFormattedMoney2(priceNumber * value), getFormattedMoney2(getMarketFee(priceNumber * value)), getFormattedMoney2(priceNumber * value - getMarketFee(priceNumber * value)))
  end
end

function onSellPriceTextChange()
  updateSellTotals()
end

local function showOffersToMe(market_item)
  local offerItem = offerToMeWindow:getChildById('offerItem')
  showItem(offerItem, market_item.spriteId, market_item.count, market_item.description, market_item.poke_info)
  offerToMeWindow:getChildById('offerItemName'):setText(market_item.item_name)
  local offersList = offerToMeWindow:getChildById('offersList')
  offersList:destroyChildren()
  offerToMeWindow.selectedOffer = nil
  for _, offers in ipairs(market_item.offers) do
    for _, offer_item in ipairs(offers) do
      local offerWidget = offersList:getChildById('offer' .. offer_item.playeroffer_id)
      if not offerWidget then
        offerWidget = g_ui.createWidget('OfferWidget', offersList)
        offerWidget:setId('offer' .. offer_item.playeroffer_id)
        offerWidget:setText(offer_item.playeroffer_name)
        offerWidget.item_count = 1
        offerWidget.item_code = offer_item.item_code
        offerWidget.playeroffer_id = offer_item.playeroffer_id
        offerWidget.onClick = function()
          if offerToMeWindow.selectedOffer and offerToMeWindow.selectedOffer ~= offerWidget then
            offerToMeWindow.selectedOffer:setImageColor('#171718')
          end
          offerToMeWindow.selectedOffer = offerWidget
          offerWidget:setImageColor('#172c41')
        end
      end
      local itemOfferWidget = offerWidget:getChildById('offerList'):getChildById('item' .. offerWidget.item_count)
      if itemOfferWidget then
        showItem(itemOfferWidget, offer_item.spriteId, offer_item.count, offer_item.description, offer_item.poke_info)
      end
      offerWidget.item_count = offerWidget.item_count + 1
    end
  end
  marketWindow:hide()
  offerToMeWindow:show()
  offerToMeWindow:raise()
end

local function showMyOffer(market_item)
  showItem(myCurrentOfferWindow:getChildById('offerItem'), market_item.spriteId, market_item.count, market_item.description, market_item.poke_info)
  myCurrentOfferWindow:getChildById('offerItemName'):setText(market_item.item_name)
  for slot = 1, 8 do
    clearItemWidget(myCurrentOfferWindow:getChildById('offersList'):getChildById('item' .. slot))
  end
  for slot, offer_item in ipairs(market_item.offers) do
    local item = myCurrentOfferWindow:getChildById('offersList'):getChildById('item' .. slot)
    if item then
      showItem(item, offer_item.spriteId, offer_item.count, offer_item.description, offer_item.poke_info)
    end
  end
  marketWindow:hide()
  myCurrentOfferWindow:show()
  myCurrentOfferWindow:raise()
end

local function showBuyOffers(itemInfo)
  marketWindow:hide()
  local offerItem = buyOffersWindow:getChildById('offerItem')
  showItem(offerItem, itemInfo.spriteId, itemInfo.count, itemInfo.description, itemInfo.poke_info)
  buyOffersWindow:getChildById('offersList'):destroyChildren()
  buyOffersWindow:getChildById('offerItemName'):setText(itemInfo.item_name)
  send("###MARKETBUYITEMSOFFERSBYITEMCODE###,ItemCode:" .. itemInfo.item_code)
  buyOffersWindow:show()
  buyOffersWindow:raise()
end

local lastState = {buy = {}, sell = {}, withOffers = {}, myOffers = {}, historic = {}, offersByCode = {}}

function onMarketMessage(protocol, opcode, buffer)
  local player = g_game.getLocalPlayer()
  if not player then return end
  local receive = table.fromLiteral(buffer)
  if not receive then return end
  if receive[3] == "refreshall" then
    refreshAllMarket()
  elseif receive[3] == "close" then
    hide()
  elseif receive[3] == "market_historic" then
    marketHistoricList:destroyChildren()
    local historic = Protocol_read(receive) or {}
    table.sort(historic, function(a, b) return a.time > b.time end)
    lastState.historic = {}
    for _, negotiation in ipairs(historic) do
      local text = g_ui.createWidget('HistoricLabel', marketHistoricList)
      text:setText(" " .. negotiation.negotiation)
      table.insert(lastState.historic, negotiation.negotiation)
    end
  elseif receive[3] == "marketbuyitems" then
    resetBuyingPanel()
    local category = Protocol_read(receive)
    marketBuyComboBox:setCurrentOptionByData(category, true)
    currentPage = Protocol_read(receive)
    maxPage = Protocol_read(receive)
    local focus = Protocol_read(receive)
    local searchstring = Protocol_read(receive)
    local buyItems = Protocol_read(receive) or {}
    marketSearchTextEdit:setText(searchstring or '')
    lastState.buy = {}
    for number, itemInfo in pairs(buyItems) do
      local data = {
        {text = number},
        {itemid = itemInfo.spriteId, count = itemInfo.count, tooltip = itemInfo.description, poke_info = itemInfo.poke_info},
        {text = itemInfo.item_name},
        {text = itemInfo.playerseller_name, align = AlignCenter},
        {text = itemInfo.count, align = AlignCenter},
        {text = getFormattedMoney(itemInfo.price) .. ' ', align = AlignRightCenter},
      }
      local row = addMarketRow(buyPanelTable, data, 34)
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
          menu:addOption(tr('Display offers'), function() showBuyOffers(itemInfo) end)
          menu:addOption(tr('Send message to %s', itemInfo.playerseller_name), function() g_game.openPrivateChannel(itemInfo.playerseller_name) end)
          menu:display(mousePos)
          self:focus()
        end
      end
      table.insert(lastState.buy, {item_code = itemInfo.item_code, itemid = itemInfo.itemid, spriteId = itemInfo.spriteId, name = itemInfo.item_name, seller = itemInfo.playerseller_name, count = itemInfo.count, price = itemInfo.price, onlyoffer = itemInfo.onlyoffer})
    end
    marketBuyPanel:getChildById('buyListPages'):getChildById('labelPages'):setText(tr('Page: %d / %d', currentPage or 1, maxPage or 1))
    if focus == 1 then changeMarketPanel(marketBuyPanel, marketWindow:getChildById('buyTabButton')) end
    toggleBuyButtons(false)
    marketWindow:show()
    marketWindow:raise()
  elseif receive[3] == "marketbuymakeoffer" then
    local itemInfo = Protocol_read(receive)
    for i = 1, 8 do
      local item = makeOfferWindow:getChildById('offersList'):getChildById('item' .. i)
      if item:getItemId() == 0 then
        showItem(item, itemInfo.spriteId, itemInfo.count, itemInfo.description, itemInfo.poke_info)
        break
      end
    end
  elseif receive[3] == "marketbuyitemsoffers" then
    local offersList = buyOffersWindow:getChildById('offersList')
    offersList:destroyChildren()
    local offers = Protocol_read(receive) or {}
    lastState.offersByCode = {}
    for _, offer_item in pairs(offers) do
      local offerWidget = offersList:getChildById('offer' .. offer_item.playeroffer_id)
      if not offerWidget then
        offerWidget = g_ui.createWidget('OfferWidget', offersList)
        offerWidget:setId('offer' .. offer_item.playeroffer_id)
        offerWidget:setText(offer_item.playeroffer_name)
        offerWidget.item_count = 1
      end
      local itemOfferWidget = offerWidget:getChildById('offerList'):getChildById('item' .. offerWidget.item_count)
      if itemOfferWidget then
        showItem(itemOfferWidget, offer_item.spriteId, offer_item.count, offer_item.description, offer_item.poke_info)
      end
      offerWidget.item_count = offerWidget.item_count + 1
      table.insert(lastState.offersByCode, {from = offer_item.playeroffer_name, count = offer_item.count, itemid = offer_item.itemid})
    end
    marketWindow:hide()
    buyOffersWindow:show()
  elseif receive[3] == "marketsellitems" then
    local first = Protocol_read(receive)
    if first then
      resetSellingPanel()
      lastState.sell = {}
    end
    local sellItems = Protocol_read(receive) or {}
    for number, itemInfo in pairs(sellItems) do
      local data = {
        {text = number},
        {itemid = itemInfo.spriteId, count = itemInfo.count, tooltip = itemInfo.description, poke_info = itemInfo.poke_info},
        {text = itemInfo.item_name},
        {text = formatRemaining(itemInfo.time), align = AlignCenter},
        {text = itemInfo.count, align = AlignCenter},
        {text = getFormattedMoney(itemInfo.price) .. ' ', align = AlignRightCenter},
      }
      local row = addMarketRow(sellPanelTable, data, 34)
      row.item_code = itemInfo.item_code
      row.price = itemInfo.price
      row.count = itemInfo.count
      row.time = itemInfo.time
      row.description = itemInfo.description
      row.onMouseRelease = function(self, mousePos, mouseButton)
        if mouseButton == MouseRightButton then
          local menu = g_ui.createWidget('PopupMenu')
          menu:addOption(tr('Cancel'), function() cancelSellItem(itemInfo.item_code) end)
          menu:display(mousePos)
          self:focus()
        end
      end
      table.insert(lastState.sell, {item_code = itemInfo.item_code, itemid = itemInfo.itemid, name = itemInfo.item_name, count = itemInfo.count, price = itemInfo.price, onlyoffer = itemInfo.onlyoffer})
    end
  elseif receive[3] == "marketsellitemschecked" then
    local itemInfo = Protocol_read(receive)
    showItem(itemToSell, itemInfo.spriteId, itemInfo.count, itemInfo.description, itemInfo.poke_info)
    itemToSell.itemid = itemInfo.itemid
    itemToSell.spriteId = itemInfo.spriteId
    itemToSell.item_code = itemInfo.item_code
    itemToSellCount:setEnabled(true)
    itemToSellCount:setMinimum(1)
    itemToSellCount:setMaximum(math.max(1, itemInfo.count or 1))
    itemToSellCount:setValue(1)
    itemToSellCount.onValueChange = function(self)
      local value = math.max(1, itemToSellCount:getValue())
      itemToSell:setItemCount(value)
      updateSellTotals()
    end
    marketSellPanel:getChildById('panelToSell'):getChildById('name'):setText(itemInfo.poke_info and itemInfo.poke_info.name or '')
    setSellTotals("$0", "$0", "$0")
    textEditSellPrice.itemInfo = itemInfo
    sellButton:setEnabled(true)
    lastState.checked = {itemid = itemInfo.itemid, item_code = itemInfo.item_code, count = itemInfo.count}
  elseif receive[3] == "market_myitems_withoffers" then
    local first = Protocol_read(receive)
    if first then
      resetOffersPanels(1)
      lastState.withOffers = {}
    end
    local myitems_withoffers = Protocol_read(receive) or {}
    local number = offerPanelTableData1:getChildCount() + 1
    for item_code, market_item in pairs(myitems_withoffers) do
      local data = {
        {text = number},
        {itemid = market_item.spriteId, count = market_item.count, tooltip = market_item.description, poke_info = market_item.poke_info},
        {text = market_item.item_name},
        {text = #market_item.offers, align = AlignCenter},
        {text = formatRemaining(market_item.time), align = AlignCenter},
        {button = function() showOffersToMe(market_item) end, buttonId = 'see', bText = tr("See"), bImage = "images/ver"},
      }
      local row = addMarketRow(offerPanelTable1, data, 34)
      row.offers = market_item.offers
      row.time = market_item.time
      row.item_code = item_code
      number = number + 1
      table.insert(lastState.withOffers, {item_code = item_code, offers = #market_item.offers})
    end
  elseif receive[3] == "market_myOffers" then
    local first = Protocol_read(receive)
    if first then
      resetOffersPanels(2)
      lastState.myOffers = {}
    end
    local myOffers = Protocol_read(receive) or {}
    local number = offerPanelTableData2:getChildCount() + 1
    for item_code, market_item in pairs(myOffers) do
      local data = {
        {text = number},
        {itemid = market_item.spriteId, count = market_item.count, tooltip = market_item.description, poke_info = market_item.poke_info},
        {text = market_item.item_name},
        {text = market_item.playerseller_name, align = AlignCenter},
        {button = function() showMyOffer(market_item) end, buttonId = 'see', bText = tr("See"), bImage = "images/ver"},
        {button = function() cancelMyOffer(item_code) end, buttonId = 'cancel', bText = tr("Cancel"), bImage = "images/cancelar"},
      }
      local row = addMarketRow(offerPanelTable2, data, 34)
      row.offers = market_item.offers
      row.item_code = item_code
      number = number + 1
      table.insert(lastState.myOffers, {item_code = item_code, seller = market_item.playerseller_name, items = #market_item.offers})
    end
  end
end

function cancelSellItem(item_code)
  send("###MARKETREMOVESELLITEM###,ItemCode:" .. item_code)
end

function cancelMyOffer(item_code)
  send("###MARKETCANCELOFFER###,ItemCode:" .. item_code)
end

function selectBuyRowByCode(item_code)
  for _, row in ipairs(buyPanelTableData:getChildren()) do
    if row.item_code == item_code then
      buyPanelTable:selectRow(row)
      return row
    end
  end
end

function getState()
  return {
    visible = isVisible(),
    buyVisible = buyNowWindow:isVisible(),
    makeOfferVisible = makeOfferWindow:isVisible(),
    offersToMeVisible = offerToMeWindow:isVisible(),
    selected = selectedBuyRow and selectedBuyRow.item_code or nil,
    page = currentPage,
    maxPage = maxPage,
    buy = lastState.buy,
    sell = lastState.sell,
    withOffers = lastState.withOffers,
    myOffers = lastState.myOffers,
    historic = lastState.historic,
    offersByCode = lastState.offersByCode,
    checked = lastState.checked,
    makeOfferSlots = (function()
      local n = 0
      for _, slot in ipairs(makeOfferWindow:getChildById('offersList'):getChildren()) do
        if slot:getItemId() ~= 0 then n = n + 1 end
      end
      return n
    end)(),
  }
end

function getFormattedMoney(value)
  value = tonumber(value) or 0
  if value == 0 then return "-" end
  if value < 1000 then return tostring(value) end
  local text = tostring(value)
  local len = text:len()
  if value < 1000000 then
    return string.sub(text, 1, len - 3) .. (value % 1000 == 0 and "" or "." .. string.sub(text, len - 2, len)) .. "K"
  end
  return string.sub(text, 1, len - 6) .. (value % 1000 == 0 and "" or "." .. string.sub(text, 2, 3)) .. "KK"
end

function getFormattedMoney2(value)
  value = math.floor(tonumber(value) or 0)
  if value == 0 then return "-" end
  if value > 100000000 then return tr("invalid") end
  local text = tostring(value)
  local formatted = text:reverse():gsub("(%d%d%d)", "%1."):reverse()
  return "$" .. formatted:gsub("^%.", "")
end

function getMarketFee(price)
  return math.max(1, math.floor(price / 1000))
end

function updatePosition()
  if isVisible() then
    offline()
  end
end
