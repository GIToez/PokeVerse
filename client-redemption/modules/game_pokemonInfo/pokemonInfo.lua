local MainWindow, MainShortcuts, MainPanel, BasePanel, IVEVPanel, FriendshipPanel, MainButton
local Opcode = 63
local CurrentShortcutId = 'base'
local TotalValues = {base = 0, ivs = 0, evs = 0}
local IMAGES = '/modules/game_pokemonInfo/images/'

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

local statIds = {'hp', 'atk', 'def', 'spatk', 'spdef', 'speed'}
local statNames = {hp = "HP", atk = "ATK", def = "DEF", spatk = "SP.ATK", spdef = "SP.DEF", speed = "SPEED"}

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

-- Reset codes sent by the server (lib/game_pokemonInfo.lua) and the alert each one shows.
local alerts = {
  Base          = {icon = 'base',     text = "You don't have enough Base recovery tickets to reset the Base Stats."},
  Iv            = {icon = 'ev',       text = "You don't have enough EV reset tickets to reset the Effort Values."},
  BaseReseted   = {icon = 'base',     text = "The Base Stats were reset. You received half of the upgrade stones back."},
  IvReseted     = {icon = 'ev',       text = "The Effort Values were reset."},
  SemStones     = {icon = 'stones',   text = "You don't have enough upgrade stones."},
  SemFoodFriend = {icon = 'fruits',   text = "You don't have enough food to raise friendship."},
  SemDinheiro   = {icon = 'money',    text = "You don't have enough gold to level up friendship."},
  SemDiamond    = {icon = 'diamond',  text = "You don't have enough diamonds. Make sure they are in your backpack."},
  SemExperience = {icon = 'exp',      text = "Not enough friendship experience. Make sure your Pokemon has been fed enough."},
}

function init()
  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = refresh,
  })
  MainWindow      = g_ui.displayUI('pokemonInfo')
  MainShortcuts   = MainWindow:getChildById('mainShortcuts')
  MainPanel       = MainWindow:getChildById('mainPanel')
  BasePanel       = MainWindow:getChildById('base')
  IVEVPanel       = MainWindow:getChildById('ivev')
  FriendshipPanel = MainWindow:getChildById('friendship')

  for id, item in pairs(friendshipItems) do
    local widget = FriendshipPanel:getChildById(id)
    widget:getChildById('item'):setImageSource(IMAGES .. "friendship_icons/" .. id)
    widget:getChildById('name'):setText(tr(item.name))
    widget:getChildById('friendshipLabel'):setText(tr("Friendship") .. " +" .. item.value)
  end

  for id, bonus in pairs(friendshipBonus) do
    local widget = FriendshipPanel:getChildById(id)
    widget:getChildById('icon'):setImageSource(IMAGES .. "friendship_icons/" .. id)
    widget:getChildById('name'):setText(tr(bonus.name))
    widget:getChildById('percent'):setText(bonus.value .. "%")
  end

  for _, id in ipairs(statIds) do
    for _, panel in ipairs({IVEVPanel, BasePanel}) do
      local widget = panel:getChildById(id)
      widget:getChildById('icon'):setImageSource(IMAGES .. "ivev_icons/" .. id)
      widget:getChildById('name'):setText(statNames[id] .. ":")
    end
    BasePanel:getChildById(id .. 'stone'):getChildById('icon'):setImageSource(IMAGES .. "stones/" .. id .. "stone")
  end

  for id, stat in pairs(stats) do
    local widget = MainPanel:getChildById(id)
    widget:getChildById('icon'):setImageSource(IMAGES .. "stat_icons/" .. stat.image)
    widget:getChildById('name'):setText(stat.name .. ":")
    widget:getChildById('value'):setText(0)
  end

  IVEVPanel:getChildById('ev_reset').onClick = doShowResetEv
  BasePanel:getChildById('attribute_reset').onClick = doShowResetBase

  MainButton = modules.game_mainpanel.addToggleButton('pokemonInfoButton', tr('Pokemon Info'),
    IMAGES .. 'button', toggle, false, 21)
  MainButton:setOn(false)

  ProtocolGame.registerExtendedOpcode(Opcode, parsePokemonInfo)
  MainWindow:hide()
end

function terminate()
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = refresh,
  })

  ProtocolGame.unregisterExtendedOpcode(Opcode)
  MainWindow:destroy()
  MainWindow = nil
  if MainButton then
    MainButton:destroy()
    MainButton = nil
  end
end

-- The server opens the window (Reset code OpenWindow) only while a Pokemon is summoned, so the button
-- asks for it instead of showing stale data.
function toggle()
  if MainWindow:isVisible() then
    hide()
  elseif g_game.isOnline() then
    g_game.talk('/pokemoninfo')
  end
end

function refresh()
  hide()
end

function show()
  MainWindow:show()
  MainWindow:raise()
  MainWindow:focus()
  if MainButton then MainButton:setOn(true) end
end

function hide()
  MainWindow:hide()
  if MainButton then MainButton:setOn(false) end
end

function isVisible()
  return MainWindow and MainWindow:isVisible()
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
  local ok, pokemonInfo = pcall(json.decode, buffer)
  if not ok or type(pokemonInfo) ~= 'table' then
    g_logger.warning('[game_pokemonInfo] invalid payload: ' .. tostring(buffer))
    return
  end
  if pokemonInfo.protocol == "Close" then
    hide()
  elseif pokemonInfo.protocol == "Info" then
    -- The server splits one update over several messages (data, ticket counts, OpenWindow).
    LastInfo = LastInfo or {}
    for key, value in pairs(pokemonInfo) do
      LastInfo[key] = value
    end
    resetInfo()
    drawPokemonInfo(pokemonInfo)
  end
end

function resetInfo()
  local pointsPanel = IVEVPanel:getChildById('evPointsPanel')
  pointsPanel.spendingPoints = 0
  pointsPanel:getChildById('spendingPoints'):setText("")
  for _, id in ipairs(statIds) do
    IVEVPanel:getChildById(id):getChildById('spendingPoints'):setText("")
    BasePanel:getChildById(id):getChildById('spendingPoints'):setText("")
    BasePanel:getChildById(id .. 'stone'):getChildById('count'):setText("")
  end
end

local function setStatValues(prefix, values, field)
  for _, id in ipairs(statIds) do
    local text = values[id] or 0
    if field == 'bonus' then text = "(+" .. text .. ")" end
    MainPanel:getChildById(prefix .. id):getChildById(field):setText(text)
  end
end

local function drawMain(main)
  MainPanel:getChildById('pokemonName'):setText(main.name)

  local data = TABLE_POKEMON_INFO and TABLE_POKEMON_INFO[main.name]
  local firstType, secondType = MainPanel:getChildById('firstType'), MainPanel:getChildById('secondType')
  if data then
    firstType:setImageSource("/images/types/type_ball/" .. data.type1)
    firstType:setTooltip(data.type1)
    secondType:setImageSource(data.type2 == "" and "" or "/images/types/type_ball/" .. data.type2)
    secondType:setTooltip(data.type2 == "" and "" or data.type2)
    MainPanel:getChildById('pokedexId'):setText(data.dexID)
  else
    firstType:setImageSource("")
    secondType:setImageSource("")
    MainPanel:getChildById('pokedexId'):setText("")
  end
  MainPanel:getChildById('pokemon'):setImageSource("/images/pokemon_image/" .. main.name)

  local gender, genderIcon
  if main.gender == 2 then
    gender, genderIcon = "Sexless", "skull_yellow"
  elseif main.gender == 0 then
    gender, genderIcon = "Female", "skull_red"
  else
    gender, genderIcon = "Male", "skull_black"
  end
  MainPanel:getChildById('gender'):setText(tr(gender))
  MainPanel:getChildById('genderIcon'):setImageSource("/images/game/skulls/" .. genderIcon)

  MainPanel:getChildById('nature'):setText(tostring(main.nature or ""))
  local nature = NATURES_INFO and NATURES_INFO[main.nature]
  MainPanel:getChildById('natureIcon'):setTooltip(nature and ("+ " .. nature.Increase .. "\n- " .. nature.Decrease) or "")
end

local function drawExtra(extra)
  local boost = MainPanel:getChildById('boost')
  boost:setText("[+" .. (extra.boost or 0) .. "]")
  boost:setTooltip(tr('Boost') .. " +" .. (extra.boost or 0))

  local held = MainPanel:getChildById('heldItem')
  local heldText = tr('Held') .. ": "
  if extra.heldItem and extra.heldItem ~= "" then
    heldText = heldText .. extra.heldItem
    if extra.heldLevel and extra.heldLevel > 0 then
      heldText = heldText .. " (" .. tr('Tier') .. " " .. extra.heldLevel .. ")"
    end
  else
    heldText = heldText .. tr('None')
  end
  held:setText(heldText)
  held:setTooltip(heldText)

  local ability = MainPanel:getChildById('ability')
  local abilityText = tr('Ability') .. ": " .. ((extra.ability and extra.ability ~= "") and extra.ability or tr('None'))
  ability:setText(abilityText)
  ability:setTooltip(abilityText)
end

local function perfectionColor(percent)
  if percent <= 20 then return "#ff0808"
  elseif percent <= 40 then return "#ff5608"
  elseif percent <= 60 then return "#ffa008"
  elseif percent <= 80 then return "#fbff08" end
  return "#0be000"
end

function drawPokemonInfo(pokemonInfo)
  if pokemonInfo.Reset then
    local code = pokemonInfo.Reset.code
    if code == "OpenWindow" then
      show()
    elseif alerts[code] then
      showAlert(alerts[code].icon, alerts[code].text)
    end
  end
  if pokemonInfo.tickets then
    BasePanel:getChildById('baseTicketPanel'):getChildById('points'):setText(pokemonInfo.tickets.base)
    IVEVPanel:getChildById('evTicketPanel'):getChildById('points'):setText(pokemonInfo.tickets.evs)
  end
  if pokemonInfo.main then
    drawMain(pokemonInfo.main)
  end
  if pokemonInfo.extra then
    drawExtra(pokemonInfo.extra)
  end
  if pokemonInfo.mainBase then
    setStatValues('', pokemonInfo.mainBase, 'value')
    TotalValues.mainBase = 0
    for _, value in pairs(pokemonInfo.mainBase) do
      TotalValues.mainBase = TotalValues.mainBase + value
    end
    MainPanel:getChildById('baseTotal'):getChildById('value'):setText(TotalValues.mainBase)
  end
  if pokemonInfo.total then
    setStatValues('', pokemonInfo.total, 'bonus')
  end
  if pokemonInfo.base then
    TotalValues.base = 0
    for id, value in pairs(pokemonInfo.base) do
      drawBarInfo(BasePanel, id, value, 150)
      TotalValues.base = TotalValues.base + value
    end
    MainPanel:getChildById('baseTotal'):getChildById('bonus'):setText("(+" .. TotalValues.base .. ")")
  end
  if pokemonInfo.ivs then
    setStatValues('iv', pokemonInfo.ivs, 'value')
    TotalValues.ivs = 0
    for _, value in pairs(pokemonInfo.ivs) do
      TotalValues.ivs = TotalValues.ivs + value
    end
    MainPanel:getChildById('ivTotal'):getChildById('value'):setText(TotalValues.ivs)
    local percent = TotalValues.ivs * 100 / 186
    local perfection = MainPanel:getChildById('perfection'):getChildById('value')
    perfection:setText(tostring(percent):sub(1, 6) .. "%")
    perfection:setColor(perfectionColor(percent))
  end
  if pokemonInfo.evs then
    IVEVPanel:getChildById('evPointsPanel'):getChildById('points'):setText(pokemonInfo.evs.points)
    setStatValues('iv', pokemonInfo.evs, 'bonus')
    TotalValues.evs = 0
    for id, value in pairs(pokemonInfo.evs) do
      if id ~= "points" then
        drawBarInfo(IVEVPanel, id, value, 250)
        TotalValues.evs = TotalValues.evs + value
      end
    end
    IVEVPanel:getChildById('progressBar'):setPercent(TotalValues.evs * 100 / 500)
    IVEVPanel:getChildById('progressBarValue'):setText(TotalValues.evs .. " / 500")
    MainPanel:getChildById('ivTotal'):getChildById('bonus'):setText("(+" .. TotalValues.evs .. ")")
  end
  if pokemonInfo.friendship then
    local friendship = pokemonInfo.friendship
    MainPanel:getChildById('friendship'):getChildById('value'):setText("Lv." .. friendship.level)
    FriendshipPanel:getChildById('level'):setText(friendship.level)
    local expToNext = (friendship.expToNext and friendship.expToNext > 0) and friendship.expToNext or 1
    FriendshipPanel:getChildById('progressBar'):setPercent(math.min(100, friendship.exp * 100 / expToNext))
    FriendshipPanel:getChildById('progressBar'):setText(friendship.exp .. " / " .. (friendship.expToNext or 0))
    FriendshipPanel:getChildById('moneyLabel'):setText(tr('Gold required for level-up:') .. " " .. (friendship.reqMoney or 0))
    FriendshipPanel:getChildById('diamondValueLabel'):setText(friendship.reqDiamonds or 0)
    for id, _ in pairs(friendshipBonus) do
      drawFriendshipPercent(FriendshipPanel:getChildById(id):getChildById('percent'), friendship[id] or 0)
    end
  end
end

function drawFriendshipPercent(widget, value)
  widget:setColor(value == 0 and "white" or "green")
  widget:setText(tostring(value):sub(1, 3) .. "%")
end

function drawBarInfo(panel, typeId, value, maxValue)
  local widget = panel:getChildById(typeId)
  if not widget then return end
  widget:getChildById('value'):setText(value .. " / " .. maxValue)
  widget.value = value
  widget.maxValue = maxValue
  widget:getChildById('progressBar'):setPercent(value * 100 / maxValue)
end

-- Client-side checks mirror the server limits (lib/game_pokemonInfo.lua): Base 150 per stat; EVs 250 per
-- stat, 500 in total and no more than the available points. The server re-checks every upgrade.
function addToUpgradeInfo(patternId, typeId, value)
  if patternId == 'base' then
    local widget = BasePanel:getChildById(typeId)
    local spendingPoints = tonumber(widget:getChildById('spendingPoints'):getText()) or 0
    if not widget.value or spendingPoints + value + widget.value > widget.maxValue then return end
    widget:getChildById('spendingPoints'):setText("+" .. (spendingPoints + value))
    BasePanel:getChildById(typeId .. "stone"):getChildById('count'):setText("-" .. (spendingPoints + value))
  elseif patternId == 'ivev' then
    local pointsPanel = IVEVPanel:getChildById('evPointsPanel')
    local points = tonumber(pointsPanel:getChildById('points'):getText())
    if not points or points < pointsPanel.spendingPoints + value then return end
    local widget = IVEVPanel:getChildById(typeId)
    local totalSpendingPoints = 0
    for _, id in ipairs(statIds) do
      totalSpendingPoints = totalSpendingPoints + (tonumber(IVEVPanel:getChildById(id):getChildById('spendingPoints'):getText()) or 0)
    end
    if totalSpendingPoints + TotalValues.evs + value > 500 then return end
    local spendingPoints = tonumber(widget:getChildById('spendingPoints'):getText()) or 0
    if not widget.value or spendingPoints + value + widget.value > widget.maxValue then return end
    widget:getChildById('spendingPoints'):setText("+" .. (spendingPoints + value))
    pointsPanel.spendingPoints = pointsPanel.spendingPoints + value
    pointsPanel:getChildById('spendingPoints'):setText("(-" .. pointsPanel.spendingPoints .. ")")
  end
end

function doUpgradeInfo(patternId)
  local panel = patternId == 'base' and BasePanel or IVEVPanel
  if patternId == 'ivev' then
    local points = tonumber(IVEVPanel:getChildById('evPointsPanel'):getChildById('points'):getText())
    if not points or points == 0 then return end
  end
  local statsToUpgrade = {}
  for _, id in ipairs(statIds) do
    local value = tonumber(panel:getChildById(id):getChildById('spendingPoints'):getText())
    if value and value > 0 then
      statsToUpgrade[#statsToUpgrade + 1] = {id = id, value = value}
    end
  end
  if #statsToUpgrade > 0 then
    sendUpgrade(patternId, statsToUpgrade)
  end
end

function sendUpgrade(patternId, statsToUpgrade)
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "upgrade", patternId = patternId, tab = statsToUpgrade}))
end

function doAddFriendshipXp(id)
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "friendship", type = "exp", id = id}))
end

function upgradeFriendshipLevel()
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "friendship", type = "level", useDiamonds = FriendshipPanel:getChildById('diamondCheckBox'):isChecked()}))
end

function sendReset(resetType)
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode({protocol = "reset", type = resetType}))
end

function doHideAlertWindow()
  MainWindow:getChildById('resetWindow'):hide()
  MainWindow:getChildById('blackWindow'):hide()
end

function doHideMessageWindow()
  MainWindow:getChildById('alertWindow'):hide()
  MainWindow:getChildById('blackWindow'):hide()
end

local function showConfirm(icon, text, resetType)
  local resetwindow = MainWindow:getChildById('resetWindow')
  resetwindow:show()
  resetwindow:raise()
  MainWindow:getChildById('blackWindow'):show()
  resetwindow:getChildById('SlotItem'):setImageSource(IMAGES .. "AlertWindow/icon/" .. icon)
  resetwindow:getChildById('text'):setText(tr(text))
  resetwindow:getChildById('reiniciar').onClick = function()
    doHideAlertWindow()
    sendReset(resetType)
  end
end

function showAlert(icon, text)
  local alertwindow = MainWindow:getChildById('alertWindow')
  alertwindow:show()
  alertwindow:raise()
  MainWindow:getChildById('blackWindow'):show()
  alertwindow:getChildById('SlotItem'):setImageSource(IMAGES .. "AlertWindow/icon/" .. icon)
  alertwindow:getChildById('text'):setText(tr(text))
end

function doShowResetBase()
  showConfirm('base', "You are about to reset this Pokemon's Base Stats. Are you sure?", 'base')
end

function doShowResetEv()
  showConfirm('ev', "You are about to reset this Pokemon's Effort Values. Are you sure?", 'ivev')
end
