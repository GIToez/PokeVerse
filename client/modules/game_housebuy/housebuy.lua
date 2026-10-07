config = {
  OPCODE_HOUSE = {201},
}

function init()
  lookWindow = g_ui.displayUI('housebuy')
  lookWindow:hide()

  ProtocolGame.registerExtendedOpcode(config.OPCODE_HOUSE[1], function(protocol, opcode, buffer) house(protocol, opcode, buffer) end)

  connect(g_game, {
	onGameStart = nothing,
    onGameEnd = offline
  })

end

function house(protocol, opcode, buffer)
  if opcode == config.OPCODE_HOUSE[1] then
    house_data = buffer:explode("|")
    house_ = {}
    house_.mapname = house_data[2]
    house_.owner = house_data[3]
    house_.town = house_data[4]
    house_.size = house_data[5]
    house_.price = house_data[6]
    getHouseInformation()
  end
end


function getHouseInformation()
  lookWindow:show()
  lookWindow:raise()
  lookWindow:focus()

  if not g_game.isOnline() then
    protocol:disconnect()
    return
  end

  local house_information = lookWindow:getChildById('full_content'):getChildById('right_content'):getChildById('data_content'):getChildById('info_panel')
  lookWindow:getChildById('full_content'):getChildById('right_content'):getChildById('house_map_name'):setText(tr(house_.mapname))
  house_information:getChildById('house_owner'):setText(tr(""..house_.owner))
  house_information:getChildById('town_name'):setText(tr(""..house_.town))
  house_information:getChildById('house_size'):setText(tr(""..house_.size.." tiles"))
  house_information:getChildById('house_price'):setText(tr(""..house_.price.." dólares"))

  if house_data[3] == "Nobody" then
    lookWindow:getChildById('full_content'):getChildById('right_content'):getChildById('buyhousebutton'):setVisible(true)
    lookWindow:getChildById('windowbuyhouse'):setVisible(true)
    lookWindow:getChildById('ownerhouse'):setVisible(false)
  else
    lookWindow:getChildById('full_content'):getChildById('right_content'):getChildById('buyhousebutton'):setVisible(false)
    lookWindow:getChildById('ownerhouse'):setVisible(true)
    lookWindow:getChildById('windowbuyhouse'):setVisible(false)
  end
end

function terminate()
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline
  })
  lookWindow:hide()
  ProtocolGame.unregisterExtendedOpcode(config.OPCODE_HOUSE[1])
end

function offline()
  lookWindow:hide()
end

function toggle()
  if lookWindow:isVisible() then
    onCloseInformation()
  else
    getHouseInformation()
  end
end

function onCloseInformation()
  lookWindow:hide()

  if acceptWindow then
    acceptWindow:destroy()
	acceptWindow = nil
  end
end

function sendBuyHouse()
  g_game.talk("buyhouseewqnml")
  if lookWindow:isVisible() then
    onCloseInformation()
  end
end
function chutar()
  g_game.talk("chutarrrase")
  if lookWindow:isVisible() then
    onCloseInformation()
  end
end
function portas()
  g_game.talk("portassdawt")
end
function hospedes()
  g_game.talk("hospedeseeq")
end
function subdono()
  g_game.talk("subdonoeqwxv")
end

function abandonar()
  if acceptWindow then
    return true
  end

  local acceptFunc = function()
	g_game.talk("abandonarweqn")
	if lookWindow:isVisible() then
	onCloseInformation()
	end
	acceptWindow = nil
  end
  
  local cancelFunc = function() acceptWindow:destroy() acceptWindow = nil end

  acceptWindow = displayGeneralBox(tr('Confirmar'), tr("Você realmente quer abandonar esta casa ??"),
  { { text=tr('Sim'), callback=acceptFunc },
    { text=tr('Não'), callback=cancelFunc },
    anchor=AnchorHorizontalCenter }, acceptFunc, cancelFunc)
  return true
end
