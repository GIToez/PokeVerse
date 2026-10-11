local MainWindow, MainShortcuts, MainPanel, BasePanel, IVEVPanel, FriendshipPanel
local Key = "Menu"
local Opcode = 63
local CurrentShortcutId = 'base'
local TotalValues = {base = 0, ivs = 0, evs = 0}

local friendshipItems = {
  ['mint']      = {name = "Mint",       value = 1},
  ['banana']    = {name = "Banana",     value = 10},
  ['apple']     = {name = "Apple",      value = 25},
  ['grape']     = {name = "Grape",      value = 50},
  ['cupNoodle'] = {name = "Cup Noodle", value = 100},
}

local friendshipBonus = {
  ['lootLucky']      = {name = "Loot Lucky", value = 0.1},
  ['shinyCharm']     = {name = "Shiny Charm", value = 0.1},
  ['criticalChance'] = {name = "Critical Chance", value = 0.1},
  ['energyRegen']    = {name = "Max Energy", value = 0.1},
}

local evs = {
  ['hp']         = {name = "HP"},
  ['atk']        = {name = "ATK"},
  ['def']        = {name = "DEF"},
  ['spatk']      = {name = "SP.ATK"},
  ['spdef']      = {name = "SP.DEF"},
  ['speed']      = {name = "SPEED"},
}

local base = {
  ['hp']         = {name = "HP"},
  ['atk']        = {name = "ATK"},
  ['def']        = {name = "DEF"},
  ['spatk']      = {name = "SP.ATK"},
  ['spdef']      = {name = "SP.DEF"},
  ['speed']      = {name = "SPEED"},
}

local stats = {
  ['hp']         = {name = "HP", image = "hp"},
  ['atk']        = {name = "ATK", image = "atk"},
  ['def']        = {name = "DEF", image = "def"},
  ['spatk']      = {name = "SP.ATK", image = "spatk"},
  ['spdef']      = {name = "SP.DEF", image = "spdef"},
  ['speed']      = {name = "SPEED", image = "speed"},
  ['ivhp']       = {name = "HP", image = "hp"},
  ['ivatk']      = {name = "ATK", image = "atk"},
  ['ivdef']      = {name = "DEF", image = "def"},
  ['ivspatk']    = {name = "SP.ATK", image = "spatk"},
  ['ivspdef']    = {name = "SP.DEF", image = "spdef"},
  ['ivspeed']    = {name = "SPEED", image = "speed"},
  ['ivTotal']    = {name = "IV", image = "iv"},
  ['baseTotal']  = {name = "BASE", image = "base"},
  ['perfection'] = {name = "PERFECTION", image = "perfection"},
  ['friendship'] = {name = "FRIENDSHIP", image = "friendship"},
}

local stones = {
  ['hpstone']         = {name = "HP"},
  ['atkstone']        = {name = "ATK"},
  ['defstone']        = {name = "DEF"},
  ['spatkstone']      = {name = "SP.ATK"},
  ['spdefstone']      = {name = "SP.DEF"},
  ['speedstone']      = {name = "SPEED"},
}

function init()
  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = refresh,
  })
  MainWindow      = g_ui.displayUI('pokemonInfo')
  MainShortcuts       = MainWindow:getChildById('mainShortcuts')
  MainPanel       = MainWindow:getChildById('mainPanel')
  BasePanel       = MainWindow:getChildById('base')
  IVEVPanel       = MainWindow:getChildById('ivev')
  FriendshipPanel = MainWindow:getChildById('friendship')
  
  for id, item in pairs(friendshipItems) do
    local widget = FriendshipPanel:getChildById(id)
    widget:getChildById('item'):setImageSource("images/friendship_icons/"..id)
    -- widget:getChildById('name'):setText(tr(item.name))
    -- widget:getChildById('friendshipLabel'):setText(tr("Amizade").."+"..item.value)
  end
  
  for id, bonus in pairs(friendshipBonus) do
    local widget = FriendshipPanel:getChildById(id)
    widget:getChildById('icon'):setImageSource("images/friendship_icons/"..id)
    widget:getChildById('name'):setText(tr(bonus.name))
    widget:getChildById('percent'):setText(bonus.value.."%")
  end
  
  for id, ev in pairs(evs) do
    local widget = IVEVPanel:getChildById(id)
    widget:getChildById('icon'):setImageSource("images/ivev_icons/"..id)
    widget:getChildById('name'):setText(ev.name..":")
  end
  
  for id, b in pairs(base) do
    local widget = BasePanel:getChildById(id)
    widget:getChildById('icon'):setImageSource("images/ivev_icons/"..id)
    widget:getChildById('name'):setText(b.name..":")
  end
  
  for id, stone in pairs(stones) do
    local widget = BasePanel:getChildById(id)
    widget:getChildById('icon'):setImageSource("images/stones/"..id)
    -- widget:setTooltip(stone.name)
  end
  
  for id, stat in pairs(stats) do
    local widget = MainPanel:getChildById(id)
    widget:getChildById('icon'):setImageSource("images/stat_icons/"..stat.image)
    widget:getChildById('name'):setText(stat.name..":")
    widget:getChildById('value'):setText(0)
    -- widget:getChildById('bonus'):setText("+0")
  end
  
  -- g_keyboard.bindKeyDown(Key, toggle)
  
  -- MainButton = modules.client_topmenu.addRightGameToggleButton('MainButton', tr('Pass') .. ' ('..Key..')', '/images/topbuttons/pass', toggle)
  -- MainButton:setOn(false)
  ProtocolGame.registerExtendedOpcode(Opcode, parsePokemonInfo)
  MainWindow:hide()
end

function terminate()
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = refresh,
  })
  
  -- g_keyboard.unbindKeyDown(Key)
  ProtocolGame.unregisterExtendedOpcode(Opcode)
  MainWindow:destroy()
  MainWindow = nil
  -- MainButton:destroy()
  -- MainButton = nil
end

function toggle()
  if MainWindow:isVisible() then
    hide()
  else
    show()
  end
  -- if MainButton:isOn() then
    -- hide()
  -- else
    -- show()
  -- end
end

function refresh()
  MainWindow:hide()
  -- MainButton:setOn(false)
end

function show()
  MainWindow:show()
  MainWindow:raise()
  MainWindow:focus()
  -- MainButton:setOn(true)
end

function hide()
  MainWindow:hide()
  -- MainButton:setOn(false)
end

function togglePanel(id)
  if CurrentShortcutId == id and MainWindow:getChildById(CurrentShortcutId):isVisible() then return end
  MainWindow:getChildById(CurrentShortcutId):hide()
  MainShortcuts:getChildById(CurrentShortcutId):setBorderColor('white')
  MainWindow:getChildById(id):show()
  MainShortcuts:getChildById(id):setBorderColor('#00FF56')
  CurrentShortcutId = id
end

function parsePokemonInfo(protocol, opcode, buffer)
  -- print(buffer)
  local pokemonInfo = json.decode(buffer)
  if pokemonInfo.protocol == "Close" then
    hide()
  elseif pokemonInfo.protocol == "Info" then
    resetInfo()
    drawPokemonInfo(pokemonInfo)
  end
end

function resetInfo()
    IVEVPanel:getChildById('evPointsPanel').spendingPoints = 0
    IVEVPanel:getChildById('evPointsPanel'):getChildById('spendingPoints'):setText("")
  for id, ev in pairs(evs) do
    local widget = IVEVPanel:getChildById(id)
    widget:getChildById('spendingPoints'):setText("")
    IVEVPanel:getChildById('ev_reset').onClick = function() doShowResetEv() end
  end
  
  for id, b in pairs(base) do
    local widget = BasePanel:getChildById(id)
    widget:getChildById('spendingPoints'):setText("")
    BasePanel:getChildById('attribute_reset').onClick = function() doShowResetBase() end
  end
  
  for id, stone in pairs(stones) do
    local widget = BasePanel:getChildById(id)
    widget:getChildById('count'):setText("")
  end
end

function drawPokemonInfo(pokemonInfo)
  if pokemonInfo.Reset then
    if pokemonInfo.Reset.code == "Base" then
      doSemTicketBase()
    elseif pokemonInfo.Reset.code == "Iv" then
      doSemTicketIVEV()
    elseif pokemonInfo.Reset.code == "BaseReseted" then
      doResetedTicketBase()
    elseif pokemonInfo.Reset.code == "IvReseted" then
      doResetedTicketIVEV()
    elseif pokemonInfo.Reset.code == "SemStones" then
      doSemStone()
    elseif pokemonInfo.Reset.code == "SemFoodFriend" then
      doSemFood()
    elseif pokemonInfo.Reset.code == "SemDinheiro" then
      doSemDinheiro()
    elseif pokemonInfo.Reset.code == "SemDiamond" then
      doSemDiamond()
    elseif pokemonInfo.Reset.code == "SemExperience" then
      doSemExperience()
    elseif pokemonInfo.Reset.code == "OpenWindow" then
      toggle()
    end
  end
  if pokemonInfo.tickets then
    BasePanel:getChildById('baseTicketPanel'):getChildById('points'):setText(pokemonInfo.tickets.base)
    IVEVPanel:getChildById('evTicketPanel'):getChildById('points'):setText(pokemonInfo.tickets.evs)
  end
  if pokemonInfo.main then
    local PokeName = pokemonInfo.main.name
    MainPanel:getChildById('pokemonName'):setText(PokeName)
	
    MainPanel:getChildById('firstType'):setImageSource("/images/types/type_ball/"..TABLE_POKEMON_INFO[pokemonInfo.main.name].type1) 
    MainPanel:getChildById('firstType'):setTooltip(TABLE_POKEMON_INFO[pokemonInfo.main.name].type1) 
	
    MainPanel:getChildById('secondType'):setImageSource(TABLE_POKEMON_INFO[pokemonInfo.main.name].type2 == "" and "" or "/images/types/type_ball/"..TABLE_POKEMON_INFO[pokemonInfo.main.name].type2)
    MainPanel:getChildById('secondType'):setTooltip(TABLE_POKEMON_INFO[pokemonInfo.main.name].type2 == "" and "" or TABLE_POKEMON_INFO[pokemonInfo.main.name].type2)
	
    MainPanel:getChildById('pokedexId'):setText(TABLE_POKEMON_INFO[pokemonInfo.main.name].dexID)
    MainPanel:getChildById('pokemon'):setImageSource("/images/pokemon_image/"..pokemonInfo.main.name)
    if pokemonInfo.main.gender == 2 then
      MainPanel:getChildById('gender'):setText(pokemonInfo.main.gender == 2 and "Sexless")
      MainPanel:getChildById('genderIcon'):setImageSource(pokemonInfo.main.gender == 2 and "/images/game/skulls/skull_yellow")
    else
    MainPanel:getChildById('gender'):setText(pokemonInfo.main.gender == 0 and "Female" or "Male")
    MainPanel:getChildById('genderIcon'):setImageSource(pokemonInfo.main.gender == 0 and "/images/game/skulls/skull_red" or "/images/game/skulls/skull_black")
    end
    local Increase = NATURES_INFO[pokemonInfo.main.nature].Increase
    local Decrease = NATURES_INFO[pokemonInfo.main.nature].Decrease
    MainPanel:getChildById('nature'):setText(""..pokemonInfo.main.nature)
    MainPanel:getChildById('natureIcon'):setTooltip("+ "..Increase.."\n- "..Decrease)
  end
  if pokemonInfo.mainBase then
    MainPanel:getChildById('hp'):getChildById('value'):setText(pokemonInfo.mainBase.hp)
    MainPanel:getChildById('atk'):getChildById('value'):setText(pokemonInfo.mainBase.atk)
    MainPanel:getChildById('def'):getChildById('value'):setText(pokemonInfo.mainBase.def)
    MainPanel:getChildById('spatk'):getChildById('value'):setText(pokemonInfo.mainBase.spatk)
    MainPanel:getChildById('spdef'):getChildById('value'):setText(pokemonInfo.mainBase.spdef)
    MainPanel:getChildById('speed'):getChildById('value'):setText(pokemonInfo.mainBase.speed)
    TotalValues.mainBase = 0
    for id, value in pairs(pokemonInfo.mainBase) do
      TotalValues.mainBase = TotalValues.mainBase+value
    end
    MainPanel:getChildById('baseTotal'):getChildById('value'):setText(TotalValues.mainBase)
  end
  if pokemonInfo.total then
    -- print(pokemonInfo.total.hp, pokemonInfo.mainBase.hp)
    -- print(pokemonInfo.total.atk, pokemonInfo.mainBase.atk)
    MainPanel:getChildById('hp'):getChildById('bonus'):setText("(+"..(pokemonInfo.total.hp)..")")
    MainPanel:getChildById('atk'):getChildById('bonus'):setText("(+"..(pokemonInfo.total.atk)..")")
    MainPanel:getChildById('def'):getChildById('bonus'):setText("(+"..(pokemonInfo.total.def)..")")
    MainPanel:getChildById('spatk'):getChildById('bonus'):setText("(+"..(pokemonInfo.total.spatk)..")")
    MainPanel:getChildById('spdef'):getChildById('bonus'):setText("(+"..(pokemonInfo.total.spdef)..")")
    MainPanel:getChildById('speed'):getChildById('bonus'):setText("(+"..(pokemonInfo.total.speed)..")")
  end
  if pokemonInfo.base then
    TotalValues.base = 0
    for id, value in pairs(pokemonInfo.base) do
      drawBarInfo(BasePanel, id, value, 150)
      TotalValues.base = TotalValues.base+value
    end
    MainPanel:getChildById('baseTotal'):getChildById('bonus'):setText("(+"..TotalValues.base..")")
  end
  if pokemonInfo.ivs then
    MainPanel:getChildById('ivhp'):getChildById('value'):setText(pokemonInfo.ivs.hp)
    MainPanel:getChildById('ivatk'):getChildById('value'):setText(pokemonInfo.ivs.atk)
    MainPanel:getChildById('ivdef'):getChildById('value'):setText(pokemonInfo.ivs.def)
    MainPanel:getChildById('ivspatk'):getChildById('value'):setText(pokemonInfo.ivs.spatk)
    MainPanel:getChildById('ivspdef'):getChildById('value'):setText(pokemonInfo.ivs.spdef)
    MainPanel:getChildById('ivspeed'):getChildById('value'):setText(pokemonInfo.ivs.speed)
    TotalValues.ivs = 0
    for _, value in pairs(pokemonInfo.ivs) do
      TotalValues.ivs = TotalValues.ivs+value
    end
    MainPanel:getChildById('ivTotal'):getChildById('value'):setText(TotalValues.ivs)
    MainPanel:getChildById('perfection'):getChildById('value'):setText(tostring(TotalValues.ivs * 100 / 186):sub(1,6).."%")

    local valueColor = (TotalValues.ivs * 100 / 186)
    -- print(valueColor)
    if (valueColor > 0 and valueColor <= 20.000) then
      MainPanel:getChildById('perfection'):getChildById('value'):setColor("#ff0808")
    elseif (valueColor > 20.000 and valueColor <= 40.000) then
      MainPanel:getChildById('perfection'):getChildById('value'):setColor("#ff5608")
    elseif (valueColor > 40.000 and valueColor <= 60.000) then
      MainPanel:getChildById('perfection'):getChildById('value'):setColor("#ffa008")
    elseif (valueColor > 60.000 and valueColor <= 80.000) then
      MainPanel:getChildById('perfection'):getChildById('value'):setColor("#fbff08")
    elseif (valueColor > 80.000 and valueColor <= 99.000) then
      MainPanel:getChildById('perfection'):getChildById('value'):setColor("#0be000")
    elseif (valueColor == 100) then
      MainPanel:getChildById('perfection'):getChildById('value'):setColor("#0be000")
    end
  end
  if pokemonInfo.evs then
    IVEVPanel:getChildById('evPointsPanel'):getChildById('points'):setText(pokemonInfo.evs.points)
    MainPanel:getChildById('ivhp'):getChildById('bonus'):setText("(+"..pokemonInfo.evs.hp..")")
    MainPanel:getChildById('ivatk'):getChildById('bonus'):setText("(+"..pokemonInfo.evs.atk..")")
    MainPanel:getChildById('ivdef'):getChildById('bonus'):setText("(+"..pokemonInfo.evs.def..")")
    MainPanel:getChildById('ivspatk'):getChildById('bonus'):setText("(+"..pokemonInfo.evs.spatk..")")
    MainPanel:getChildById('ivspdef'):getChildById('bonus'):setText("(+"..pokemonInfo.evs.spdef..")")
    MainPanel:getChildById('ivspeed'):getChildById('bonus'):setText("(+"..pokemonInfo.evs.speed..")")
    TotalValues.evs = 0
    for id, value in pairs(pokemonInfo.evs) do
      if id ~= "points" then
        drawBarInfo(IVEVPanel, id, value, 250)
        TotalValues.evs = TotalValues.evs+value
      end
    end
    IVEVPanel:getChildById('progressBar'):setPercent(TotalValues.evs * 100 / 500)
    IVEVPanel:getChildById('progressBarValue'):setText(TotalValues.evs.." / 500")
    MainPanel:getChildById('ivTotal'):getChildById('bonus'):setText("(+"..TotalValues.evs..")")
  end
  if pokemonInfo.friendship then
    MainPanel:getChildById('friendship'):getChildById('value'):setText("Lv."..pokemonInfo.friendship.level)
    FriendshipPanel:getChildById('level'):setText(pokemonInfo.friendship.level)
    FriendshipPanel:getChildById('progressBar'):setPercent(pokemonInfo.friendship.exp * 100 / pokemonInfo.friendship.expToNext)
    FriendshipPanel:getChildById('progressBar'):setText(pokemonInfo.friendship.exp.." / "..pokemonInfo.friendship.expToNext)
    FriendshipPanel:getChildById('moneyLabel'):setText(tr('Gold required for level-up: ')..pokemonInfo.friendship.reqMoney)
    FriendshipPanel:getChildById('diamondValueLabel'):setText(pokemonInfo.friendship.reqDiamonds)
	drawFriendshipPercent(FriendshipPanel:getChildById('lootLucky'):getChildById('percent'), pokemonInfo.friendship.lootLucky)
	drawFriendshipPercent(FriendshipPanel:getChildById('shinyCharm'):getChildById('percent'), pokemonInfo.friendship.shinyCharm)
	drawFriendshipPercent(FriendshipPanel:getChildById('criticalChance'):getChildById('percent'), pokemonInfo.friendship.criticalChance)
	drawFriendshipPercent(FriendshipPanel:getChildById('energyRegen'):getChildById('percent'), pokemonInfo.friendship.energyRegen)
  end
end

function drawFriendshipPercent(widget, value)
  if value == 0 then
    widget:setColor("white")
  else
    widget:setColor("green")
  end
  widget:setText(tostring(value):sub(1,3).."%")
end

function drawBarInfo(panel, typeId, value, maxValue)
  local widget = panel:getChildById(typeId)
  widget:getChildById('value'):setText(value.." / "..maxValue)
  widget.value = value
  widget.maxValue = maxValue
  widget:getChildById('progressBar'):setPercent(value * 100 / maxValue)
end

function addToUpgradeInfo(patternId, typeId, value)
  -- print(patternId, typeId, value)
  local panel = MainWindow:getChildById(patternId)
  if patternId == 'base' then
    local widget = BasePanel:getChildById(typeId)
    local spendingPoints = widget:getChildById('spendingPoints'):getText()
    if not tonumber(spendingPoints) then spendingPoints = 0 end
    if spendingPoints + value + widget.value > widget.maxValue then return end
    widget:getChildById('spendingPoints'):setText("+"..(spendingPoints+value))
    BasePanel:getChildById(typeId.."stone"):getChildById('count'):setText("-"..spendingPoints+value)
  elseif patternId == 'ivev' then
    local points = tonumber(IVEVPanel:getChildById('evPointsPanel'):getChildById('points'):getText())
    if not points or points == 0 or points < value then return end
    local widget = IVEVPanel:getChildById(typeId)
    local evTotal = tonumber(widget:getChildById('value'):getText()) or 0
    if ((evTotal + value) > 250) or ((TotalValues.evs + value) > 500) then return end
    local totalSpendingPoints = 0
    for id, ev in pairs(evs) do
      local subwidget = IVEVPanel:getChildById(id)
      local spendingPoints = subwidget:getChildById('spendingPoints'):getText()
      if tonumber(spendingPoints) then totalSpendingPoints = totalSpendingPoints + tonumber(spendingPoints) end
    end
	if totalSpendingPoints + TotalValues.evs +  value > 500 then return end
    local spendingPoints = widget:getChildById('spendingPoints'):getText()
    if not tonumber(spendingPoints) then spendingPoints = 0 end
    if spendingPoints + value + widget.value > widget.maxValue then return end
    widget:getChildById('spendingPoints'):setText("+"..(spendingPoints+value))
    IVEVPanel:getChildById('evPointsPanel').spendingPoints = IVEVPanel:getChildById('evPointsPanel').spendingPoints + value
    IVEVPanel:getChildById('evPointsPanel'):getChildById('spendingPoints'):setText("(-"..(IVEVPanel:getChildById('evPointsPanel').spendingPoints)..")")
  end
end

function doUpgradeInfo(patternId)
  local panel = MainWindow:getChildById(patternId)
  local statsToUpgrade = {}
  if patternId == 'base' then
    for id, b in pairs(base) do
      local value = tonumber(BasePanel:getChildById(id):getChildById('spendingPoints'):getText())
      if value and value > 0 then
        statsToUpgrade[#statsToUpgrade+1] = {id = id, value = value}
        -- print(id, value)
      end
    end
  elseif patternId == 'ivev' then
    local points = tonumber(IVEVPanel:getChildById('evPointsPanel'):getChildById('points'):getText())
    if not points or points == 0 then return end
    for id, ev in pairs(evs) do
      local value = tonumber(IVEVPanel:getChildById(id):getChildById('spendingPoints'):getText())
      if value and value > 0 then
        statsToUpgrade[#statsToUpgrade+1] = {id = id, value = value}
        -- print(id, value)
      end
    end
  end
  if #statsToUpgrade > 0 then
    g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "upgrade", patternId = patternId, tab = statsToUpgrade}))
  end
end

function doAddFriendshipXp(id)
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "friendship", type = "exp", id = id}))
end

function upgradeFriendshipLevel()
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "friendship", type = "level", useDiamonds = FriendshipPanel:getChildById('diamondCheckBox'):isChecked()}))
end

function doResetPokemonInfo(id)
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "reset", id = "base"}))
end


--Alert Functions
function doHideAlertWindow()
  local resetwindow = MainWindow:getChildById('resetWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:hide()
  blackwindow:hide()
end
function doHideMessageWindow()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:hide()
  blackwindow:hide()
end
function doShowResetBase()
  local resetwindow = MainWindow:getChildById('resetWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/base")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/reset_base")
  resetwindow:getChildById('reiniciar').onClick = function() doHideAlertWindow() g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "reset", type = "base"})) end
end
function doShowResetEv()
  local resetwindow = MainWindow:getChildById('resetWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/ev")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/reset_ev")
  resetwindow:getChildById('reiniciar').onClick = function() doHideAlertWindow() g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "reset", type = "ivev"})) end
end
function doSemTicketBase()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/base")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/sem_baseticket")
end
function doSemTicketIVEV()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/ev")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/sem_evticket")
end
function doResetedTicketBase()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/base")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/reseted_base")
end
function doResetedTicketIVEV()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/ev")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/reseted_ivev")
end
function doSemStone()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/stones")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/sem_stone")
end
function doSemFood()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/fruits")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/sem_food")
end
function doSemDinheiro()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/money")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/sem_dinheiro")
end
function doSemDiamond()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/diamond")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/sem_diamond")
end
function doSemExperience()
  local resetwindow = MainWindow:getChildById('alertWindow')
  local blackwindow = MainWindow:getChildById('blackWindow')
  resetwindow:show()
  blackwindow:show()
  resetwindow:getChildById('SlotItem'):setImageSource("images/AlertWindow/icon/exp")
  resetwindow:getChildById('text'):setImageSource("images/AlertWindow/text/sem_xp")
end
--Alert Functions