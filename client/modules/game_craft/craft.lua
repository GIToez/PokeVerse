local opcode = 103
-- local KEY = "Shift+C"
local MainWindow, CreateWindow, SpeedUpWindow
local RankPanel, CraftListPanel
local CraftItemCollect, CraftItemCreate, SpeedUpCraft
local lastPlayerPosition = nil
local WorkNivel = 0

function init()
  connect(g_game, { 
  	onGameStart = offline,
  	onGameEnd = offline,
    onWalk = check,
    onAutoWalk = check
  })

  MainWindow = g_ui.loadUI('craft', modules.game_interface.getRootPanel())

  RankPanel = MainWindow:getChildById('rankPanel')
  CraftListPanel = MainWindow:getChildById('craftListPanel')
  connect(CraftListPanel, {onChildFocusChange = function(self, focusedChild, unfocusedChild, reason)
    if focusedChild == nil then return end
	updateCraftPanel(self, focusedChild, unfocusedChild, reason)
  end})
  
  CraftItemCollect = MainWindow:getChildById('craftItemCollect')
  CraftItemCreate = MainWindow:getChildById('craftItemCreate')
  SpeedUpCraft = MainWindow:getChildById('speedUpCraft')

  MainWindow:hide()
  
  CreateWindow = g_ui.createWidget('CreateWindow', modules.game_interface.getRootPanel())
  for slot=1, 16 do
    local recipeItem = g_ui.createWidget("ItemSlot", CreateWindow:getChildById('recipe'))
    recipeItem:setId(slot)
    recipeItem:setVirtual(true)
  end
  
  SpeedUpWindow = g_ui.createWidget('SpeedUpWindow', modules.game_interface.getRootPanel())
  
  CreateWindow:hide()
  SpeedUpWindow:hide()

  -- g_keyboard.bindKeyDown(KEY, toggle)
  ProtocolGame.registerExtendedOpcode(opcode, getCraft)
end

function terminate()
  disconnect(g_game, {
  	onGameStart = offline,
  	onGameEnd = offline,
    onWalk = check,
    onAutoWalk = check
  })
  -- g_keyboard.unbindKeyDown(KEY, toggle)
  ProtocolGame.unregisterExtendedOpcode(opcode)
  MainWindow:destroy()
  CreateWindow:destroy()
  SpeedUpWindow:destroy()
end

function offline()
  removeCraftEvents()
  CraftListPanel:destroyChildren()
  hide()
end

function toggle()
  if MainWindow:isVisible() then
    MainWindow:hide()
  else
    MainWindow:show()
  end
end

function hide()
  if MainWindow then
    MainWindow:setVisible(false)
  end
  CreateWindow:hide()
  SpeedUpWindow:hide()
end

function removeCraftEvents()
  for id, child in pairs(CraftListPanel:getChildren()) do
    removeEvent(child.event)
	child.event = nil
  end
end

function getServerItems(rank)
  g_game.getProtocolGame():sendExtendedOpcode(opcode, '###RANK###'..rank)
end

function showCreateWindow()
  if not CraftListPanel:getFocusedChild() then return end
  local INFO = CraftListPanel:getFocusedChild().INFO
  CreateWindow:getChildById('item'):setItemId(INFO.itemid)
  CreateWindow:getChildById('name'):setText(INFO.name..(INFO.qnt > 1 and " ("..INFO.qnt.."x)" or ""))
  CreateWindow:getChildById('qntScrollBar'):setValue(1)
  CreateWindow:getChildById('labelTotal'):setText(tr('Unidades totais')..': '..(INFO.qnt > 1 and "1 ("..INFO.qnt.."x)" or "1")..'\n\n'..tr('Tempo total de fabricação')..': '..INFO.timeByUnit..'s')
  for slot=1, 16 do
    local recipeItem = CreateWindow:getChildById('recipe'):getChildById(slot)
    recipeItem:setItemId(INFO.recipe[slot] and INFO.recipe[slot][1] or 0)
    recipeItem:setItemCount(INFO.recipe[slot] and INFO.recipe[slot][2] or 0)
	recipeItem:setTooltip(INFO.recipe[slot] and INFO.recipe[slot][3])
  end
  CreateWindow:show()
  CreateWindow:focus()
  CreateWindow:raise()
end

function refreshCreateWindow()
  if not CraftListPanel:getFocusedChild() then return end
  local INFO = CraftListPanel:getFocusedChild().INFO
  local qntValue = CreateWindow:getChildById('qntScrollBar'):getValue()
  -- CreateWindow:getChildById('labelTotal'):setText(tr('Total units')..': '..(INFO.qnt > 1 and qntValue.." ("..INFO.qnt.."x)" or qntValue)..'\n'..tr('Total time')..': '..convertSecondsToString((qntValue * INFO.timeByUnit)))
  CreateWindow:getChildById('labelTotal'):setText(tr('Unidades totais')..': '..(INFO.qnt * qntValue)..'\n\n'..tr('Tempo total de fabricação')..': '..convertSecondsToString((qntValue * INFO.timeByUnit)))
  for _, recipe in ipairs(INFO.recipe) do
    local recipeItem = CreateWindow:getChildById('recipe'):getChildById(_)
    recipeItem:setItemCount(qntValue * recipe[2])
	recipeItem:setTooltip(recipe[3])
  end
end

function doCreateItem()
  g_game.getProtocolGame():sendExtendedOpcode(opcode, '###CRAFT###,RANK'..RankPanel:getFocusedChild():getId()..',ID'..tonumber(CraftListPanel:getFocusedChild():getId())..',QNT'..tonumber(CreateWindow:getChildById('qntScrollBar'):getValue()))
end

function showSpeedUp()
  local focusedChild = CraftListPanel:getFocusedChild()
  if not focusedChild then return end
  if not focusedChild.INFO then return end
  local dustCost =  math.ceil(focusedChild.INFO.storage_time/(5*60))
  SpeedUpWindow:getChildById('text'):setText(tr('Isso irá custar ')..dustCost..(dustCost > 1 and ' diamond dusts' or ' diamond dust')..', você tem certeza que deseja acelerar o craft do ` '..focusedChild.INFO.name..' ´?')
  SpeedUpWindow:show()
  SpeedUpWindow:focus()
  SpeedUpWindow:raise()
end

function speedUpItem()
  g_game.getProtocolGame():sendExtendedOpcode(opcode, RankPanel:getFocusedChild():getId()..'###SPEEDUP###'..tonumber(CraftListPanel:getFocusedChild():getId()))
  SpeedUpWindow:hide()
end

function collectItemCraft()
  g_game.getProtocolGame():sendExtendedOpcode(opcode, RankPanel:getFocusedChild():getId()..'###COLLECT###'..tonumber(CraftListPanel:getFocusedChild():getId()))
end

function updateCraftPanel(self, focusedChild, unfocusedChild, reason)
  local focusedId = tonumber(focusedChild:getId())
  focusedChild:setImageSource('images/interface/window_craft')
  if focusedId then focusedChild:setImageSource('images/interface/'..(focusedId % 2 == 0 and "window_craftLight" or "window_craftLight")) end
  if unfocusedChild then
    local unfocusedId = tonumber(unfocusedChild:getId())
    if unfocusedId then unfocusedChild:setImageSource('images/interface/'..(unfocusedId % 2 == 0 and "window_craft" or "window_craft")) end
  end
  if focusedChild.INFO then
    if focusedChild.INFO.collectable > 0 then
      CraftItemCollect:show()
	  SpeedUpCraft:addAnchor(AnchorRight, 'craftItemCollect', AnchorLeft)
    else
      CraftItemCollect:hide()
	  SpeedUpCraft:addAnchor(AnchorRight, 'craftItemCreate', AnchorLeft)
    end
	if focusedChild.INFO.storage_time > 0 then
	  SpeedUpCraft:show()
	else
	  SpeedUpCraft:hide()
	end
  end
end

function check()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local currentPosition = player:getPosition()
  
  if lastPlayerPosition then
    if currentPosition ~= lastPlayerPosition then
	  hide()
	end
  end
end

local RANKS = {["F"] = 5, ["E"] = 5, ["D"] = 4, ["C"] = 3, ["B"] = 2, ["A"] = 1, ["S"] = 0}

function getCraft(protocol, opcode, buffer)
  local player = g_game.getLocalPlayer()
  if not player then return end
  local receive = loadstring("return ".. buffer)()
  if receive[3] == 'work' then
    local workName = Protocol_read(receive)
    WorkNivel = tonumber(Protocol_read(receive))
    local percent = Protocol_read(receive)
    local open_window = Protocol_read(receive)
	MainWindow:getChildById('workName'):setImageSource('images/topName/'..string.lower(workName))
	MainWindow:getChildById('workImagem'):setImageSource('images/works/'..string.lower(workName))
	MainWindow:getChildById('WorkImagempress'):setImageSource('images/works_press/'..string.lower(workName))
	MainWindow:getChildById('workNivel'):setText("Lv. "..WorkNivel)
	MainWindow:getChildById('expBar'):setPercent(percent)
	MainWindow:getChildById('workpercent'):setText(percent.."%")
	if open_window then 
	  lastPlayerPosition = player:getPosition()
	  MainWindow:show()
	  MainWindow:focus()
	  MainWindow:raise()
	end
  elseif receive[3] == 'refreshItem' then
    local rank = Protocol_read(receive)
	local id = Protocol_read(receive)
	local INFO = Protocol_read(receive)
	CreateWindow:hide()
	if (RankPanel:getFocusedChild():getId() == rank) and (tonumber(CraftListPanel:getFocusedChild():getId()) == id) then
	  local craftItemWidget = CraftListPanel:getChildById(id)
      removeEvent(craftItemWidget.event)
	  craftItemWidget.event = nil
	  craftItemWidget.INFO.storage_qnt = INFO.storage_qnt
	  craftItemWidget.INFO.storage_collected = INFO.storage_collected
	  craftItemWidget.INFO.storage_time = INFO.storage_time
	  DrawItemInList(craftItemWidget, id, craftItemWidget.INFO, true)
	end
  elseif receive[3] == 'items' then
    local first = Protocol_read(receive)
    local rank = Protocol_read(receive)
    local max_board = Protocol_read(receive)
	local items = Protocol_read(receive)
	if first then
	  removeCraftEvents()
	  CraftListPanel:destroyChildren()
	  CreateWindow:hide()
	  if max_board then
        local currentRank = RANKS[rank]
        for id, child in pairs(RankPanel:getChildren()) do
          if RANKS[child:getId()] < currentRank then
            child:disable()
          else
            child:enable()
          end
        end
	  end
	  RankPanel:getChildById(rank):focus()
	end
	for id, INFO in ipairs(items) do
	  DrawItemInList(g_ui.createWidget("CraftItemWidget", CraftListPanel), INFO.id, INFO)
	end
  end
end

function DrawItemInList(craftItemWidget, id, INFO, refresh)
  INFO.collectable = 0
  if not refresh then 
    craftItemWidget:setId(id)
    craftItemWidget:getChildById('item'):setItemId(INFO.itemid)
    -- craftItemWidget:getChildById('item'):setItemCount(INFO.qnt)
    craftItemWidget:getChildById('name'):setText(INFO.name..(INFO.qnt > 1 and " ("..INFO.qnt.."x)" or ""))
    craftItemWidget:getChildById('desc'):setText(INFO.desc)
    craftItemWidget:getChildById('levelWindow'):setTooltip(WorkNivel < INFO.level and "Você não tem nível suficiente" or INFO.level == 0 and "Não requer nível" or "Nível requerido: "..INFO.level.." ")
	-- walox
    craftItemWidget:getChildById('clockWindow'):setTooltip("Tempo para construir:\n "..convertSecondsToString(INFO.timeByUnit))
    craftItemWidget:setImageSource('images/interface/'..(id == 1 and "window_craftLight" or (id % 2 == 0 and "window_craft" or "window_craft")))
    
	for _, recipe in ipairs(INFO.recipe) do
      local recipeItem = g_ui.createWidget("ItemProfission", craftItemWidget:getChildById('recipe'))
      recipeItem:setItemId(recipe[1])
      recipeItem:setItemCount(recipe[2])
      recipeItem:setVirtual(true)
	  recipeItem:setTooltip(recipe[3])
    end
	
  end
  
  -- MainWindow:getChildById('workName'):setImageSource('images/topName/'..string.lower(workName))
  craftItemWidget:getChildById('levelWindow'):setImageSource(WorkNivel < INFO.level and 'images/interface/levelblock_icon' or 'images/interface/level_icon')
  local V1 = (INFO.storage_qnt * INFO.timeByUnit) -- VALOR TOTAL
  local progressLabel = craftItemWidget:getChildById('progressLabelwindow')
  local progressLabelwindow = craftItemWidget:getChildById('progressLabelwindow')
  local progressBar = craftItemWidget:getChildById('progressBar')
  local timedesc = craftItemWidget:getChildById('timedesc')
  local progressIcon = craftItemWidget:getChildById('progressIcon')
  if INFO.storage_qnt > 0 then
    local created = tonumber(INFO.storage_time == 0 and (INFO.storage_qnt > 0 and INFO.storage_qnt or "") or math.floor((V1 - INFO.storage_time) / INFO.timeByUnit))
    INFO.collectable = created - (INFO.storage_collected == -1 and 0 or INFO.storage_collected)
    progressLabel:setTooltip("Concluídos: "..created.."\nColetáveis: "..INFO.collectable.."".."\nUnidades Totais: "..INFO.storage_qnt.."")
    progressLabelwindow:show()
    if INFO.storage_time <= 0 then
      progressBar:setValue(100, 0, 100)
	  timedesc:setText("- 100%")
	  progressIcon:setImageSource("images/progressIcon")
      progressIcon:show()
    end
    progressBar:show()
	progressIcon:show()
	timedesc:show()
  else
	progressBar:hide()
	progressIcon:hide()
	timedesc:hide()
	progressLabelwindow:hide()
  end
  if CraftListPanel:getFocusedChild() == craftItemWidget then
    if INFO.collectable > 0 then
      CraftItemCollect:show()
	  SpeedUpCraft:addAnchor(AnchorRight, 'craftItemCollect', AnchorLeft)
    else
      CraftItemCollect:hide()
	  SpeedUpCraft:addAnchor(AnchorRight, 'craftItemCreate', AnchorLeft)
    end
	if INFO.storage_time > 0 then
	  SpeedUpCraft:show()
	else
	  SpeedUpCraft:hide()
	end
  end
  if INFO.storage_time > 0 then
    local function reloadPercent()
      INFO.storage_time = INFO.storage_time - 1
      local V2 = INFO.storage_time -- VALOR NOVO OU ATUAL
      local percent = -math.floor(((V2 - V1) / V1) * 100)
      progressBar:setValue(percent, 0, 100)
      timedesc:setText("- "..convertSecondsToStrings(INFO.storage_time))
      local created = tonumber(INFO.storage_time == 0 and (INFO.storage_qnt > 0 and INFO.storage_qnt or "") or math.floor((V1 - INFO.storage_time) / INFO.timeByUnit))
      INFO.collectable = created - (INFO.storage_collected == -1 and 0 or INFO.storage_collected)
      progressLabel:setTooltip("Concluídos: "..created.."\nColetáveis: "..INFO.collectable.."".."\nUnidades Totais: "..INFO.storage_qnt.."")
      if INFO.storage_time <= 0 then
	    timedesc:setText("- 100%")
		progressIcon:setImageSource("images/progressIcon")
        progressIcon:show()
        removeEvent(craftItemWidget.event)
        craftItemWidget.event = nil
      end
	  if CraftListPanel:getFocusedChild() == craftItemWidget then
        if INFO.collectable > 0 then
          CraftItemCollect:show()
		  SpeedUpCraft:addAnchor(AnchorRight, 'craftItemCollect', AnchorLeft)
        else
          CraftItemCollect:hide()
		  SpeedUpCraft:addAnchor(AnchorRight, 'craftItemCreate', AnchorLeft)
        end
	    if INFO.storage_time > 0 then
	      SpeedUpCraft:show()
	    else
	      SpeedUpCraft:hide()
	    end
	  end
	  craftItemWidget.INFO = INFO
    end
    local V2 = INFO.storage_time -- VALOR ATUAL
    local V1 = (INFO.storage_qnt * INFO.timeByUnit) -- VALOR TOTAL
    local percent = -math.floor(((V2 - V1) / V1) * 100)
    progressBar:setValue(percent, 0, 100)
    timedesc:setText("- "..convertSecondsToStrings(INFO.storage_time))
	progressIcon:setImageSource("images/progressIconAnimated")
    craftItemWidget.event = cycleEvent(reloadPercent, 1000)
  else
    removeEvent(craftItemWidget.event)
	craftItemWidget.event = nil
  end
  craftItemWidget.INFO = INFO
end

function convertSeconds(seconds)
  local hours = 0
  local minutes = 0
  repeat
    if seconds >= 60 then
	  minutes = minutes + 1; seconds = seconds - 60
	elseif minutes >= 60 then
	  hours = hours + 1; minutes = minutes - 60
	end
  until seconds < 60 and minutes < 60
  return {hours = hours, seconds = seconds, minutes = minutes}
end

function convertSecondsToString(seconds)
  local time = convertSeconds(tonumber(seconds))
  return (time.hours == 1 and time.hours.." Hora" or "" and time.hours > 0 and time.hours.." Horas " or "") .. (time.minutes == 1 and time.minutes.." Minuto" or "" and time.minutes > 0 and time.minutes.." Minutos " or "") .. (time.seconds == 1 and time.seconds.." Segundo" or "" and time.seconds > 0 and time.seconds.." Segundos " or "")
end
function convertSecondsToStrings(seconds)
  local time = convertSeconds(tonumber(seconds))
  return (time.hours > 0 and time.hours.."h " or "") .. (time.minutes > 0 and time.minutes.."m " or "") .. time.seconds.."s"
end