local MainWindow, SearchPanel, DifficultyPanel, DungeonPanel, DungeonList, KeysPanel, TeamPanel
local InviteWindow, InformationWindow, RankingWindow
local Opcode = 41

local DzBeginner = 1
local DzTalented = 2
local DzIntermediary = 3
local DzAdvanced = 4
local DzExperient = 5

local DzBronze = 1
local DzSilver = 2
local DzGold = 3
local DzSpecial = 4

local Maps, Favorites, CurrentDiff = {}, nil, DzBeginner

local areas = {
	{
		from = {x = 4655, y = 118, z = 9}, 
		to = {x = 4673, y = 133, z = 9}, 
		priority = 0,
		name = ""
	},
}
local area = nil
local intervalo = 1
local duracao = 10
local retorno = 0
local eventAnimation = nil
local check = true

local Difficulty = {
  [DzBeginner] = {name = "Iniciante", level = "80-170"},
  [DzTalented] = {name = "Talentoso", level = "120-250"},
  [DzIntermediary] = {name = "Intermediário", level = "170-300"},
  [DzAdvanced] = {name = "Avançado", level = "250-430"},
  [DzExperient] = {name = "Experiente", level = "300+"},
}

local Keys = {
  [DzBronze]  = {name = "Bronze", image = 'images/keys/bronze'},
  [DzSilver]  = {name = "Silver", image = 'images/keys/silver'},
  [DzGold]    = {name = "Gold", image = 'images/keys/gold'},
  [DzSpecial] = {name = "Special", image = 'images/keys/special'},
}

function init()
  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
  })
  connect(g_game, { 
	onGameStart = updatePosition
  })
  connect(LocalPlayer, {
  	onPositionChange = updatePosition
  })

  TopButton = g_ui.loadUI("topbutton", modules.game_interface.getRootPanel())
  -- TopButton:setVisible(false)
  
  MainWindow = g_ui.loadUI("dungeon", modules.game_interface.getRootPanel())
  InviteWindow = g_ui.loadUI("invite", modules.game_interface.getRootPanel())
  InvitedWindow = g_ui.loadUI("invited", modules.game_interface.getRootPanel())
  InformationWindow = g_ui.loadUI("information", modules.game_interface.getRootPanel())
  SearchPanel = MainWindow:getChildById("searchPanel")
  DifficultyPanel = MainWindow:getChildById("difficultyPanel")
  DungeonPanel = MainWindow:getChildById("dungeonPanel")
  DungeonList = DungeonPanel:getChildById("dungeonList")
  KeysPanel = DungeonPanel:getChildById("keysPanel")
  TeamPanel = DungeonPanel:getChildById("teamPanel")
  RankingWindow = MainWindow:getChildById("rankingWindow")
  
  connect(DungeonList, {onChildFocusChange = function(self, focusedChild, unfocusedChild, reason)
    if focusedChild == nil then return end
	if focusedChild:getChildById('panel') == nil then 
		--print("not panel") 
		return 
	end
	onDungeonWidgetFocusChange(self, focusedChild, unfocusedChild, reason)
  end})
  
  for diff, info in ipairs(Difficulty) do
    local widget = DifficultyPanel:getChildById(diff)
    widget:getChildById('name'):setText(tr(info.name))
    widget:getChildById('level'):setText(info.level)
  end

  for rarity, info in pairs(Keys) do
    KeysPanel:getChildById(rarity):getChildById('image'):setImageSource(info.image)
    KeysPanel:getChildById(rarity):getChildById('count'):setText("x0")
  end
  MainWindow:hide()
  loadFavorites()
  ProtocolGame.registerExtendedOpcode(Opcode, parseDungeon)
end

function terminate()
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
  })
  
  ProtocolGame.unregisterExtendedOpcode(Opcode)

  MainWindow:destroy()
  MainWindow = nil
  saveFavorites()
end

function isInRange(pos, fromPos, toPos)
    return
        pos.x>=fromPos.x and
        pos.y>=fromPos.y and
        pos.z>=fromPos.z and
        pos.x<=toPos.x and
        pos.y<=toPos.y and
        pos.z<=toPos.z
end

function toggle()
  if MainWindow:isVisible() then
	hideMainWindow()
  else
    requestMaps(1)
  end
end

function online()
  offline()
end

function showMainWindow()
  MainWindow:show()
end

function hideMainWindow()
  RankingWindow:hide()
  InviteWindow:hide()
  InvitedWindow:hide()
  MainWindow:hide()
end

local function stopEvent(panel)
  if panel.event then
    removeEvent(panel.event)
    panel.event = nil
  end
end

function offline()
  TeamPanel:getChildById('members'):destroyChildren()
  TeamPanel:getChildById('invitePlayer'):hide()
  DungeonPanel:getChildById('leaveTeam'):hide()
  TeamPanel:getChildById('createTeam'):show()
  SearchPanel:hide()
  RankingWindow:hide()
  InviteWindow:hide()
  InvitedWindow:hide()
  InformationWindow:hide()
  stopEvent(SearchPanel)
  stopEvent(InformationWindow)
  MainWindow:hide()
end

function loadFavorites()
  local file = io.open("modules/game_dungeon/favorites.lua", "r")
  if file then
    Favorites = json.decode(file:read())
  else
    Favorites = {}
    for diff=DzBeginner, DzExperient do
      Favorites[diff] = {}
    end
    file = io.open("modules/game_dungeon/favorites.lua", "w")
    file:write(json.encode(Favorites))
  end
  file:close()
end

function saveFavorites()
  local file = io.open("modules/game_dungeon/favorites.lua", "w")
  file:write(json.encode(Favorites))
  file:close()
end

function onFavorite(self)
  local parent = self:getParent():getParent()
  local removed = 0
  for pos, mapId in pairs(Favorites[CurrentDiff]) do
    -- print(" FAV - Pos: "..pos.." id: "..mapId)
    if mapId == parent.map.mapId then
      removed = tonumber(pos)
  	break
    end
  end
  if removed > 0 then
    table.remove(Favorites[CurrentDiff], removed)
    -- print("removeu")
  else
    table.insert(Favorites[CurrentDiff], parent.map.mapId)
    -- print("inseriu")
  end
  for _, map in ipairs(Maps) do
    if map.mapId == parent.map.mapId then map.favorite = not map.favorite break end
  end
  drawMaps()
end

function requestMaps(diff)
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode{protocol = "Maps", diff = diff})
end
function showRewards(self)
  local parent = self:getParent():getParent()
  parent:getChildById('panel'):hide() 
  parent:getChildById('rewards'):getChildById('experience'):setText("+")
  parent:getChildById('rewards'):getChildById('experience2'):setText(getFormattedMoney2(parent.map.experience))
  parent:getChildById('rewards'):getChildById('experience3'):setText("XP")
  parent:getChildById('rewards'):getChildById('back').onClick = function()
    parent:getChildById('rewards'):hide()
    parent:getChildById('panel'):show()
  end
  parent:getChildById('rewards'):getChildById('items'):destroyChildren()
  parent:getChildById('rewards'):getChildById('items2'):destroyChildren()
  local itemSize, maxColumn = 28, 10
  local line, column = 0, 0
  for _, reward in ipairs(parent.map.reward) do
    local item = g_ui.createWidget('RewardsDg', parent:getChildById('rewards'):getChildById('items'..(line > 0 and 2 or '')))
	item:setSize(itemSize.." "..itemSize)
    item:setItemId(reward.clientId)
    item:setTooltip(reward.name)
    item:setVirtual(true)
    item:addAnchor(AnchorTop, 'parent', AnchorTop)
    item:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    item:setMarginLeft(column * itemSize)
    item:setSize('28 28')
    if column == (maxColumn-1) then line = line+1 column = 0 else column = column+1 end
  end
  parent:getChildById('rewards'):getChildById('items'):setSize(itemSize * #parent:getChildById('rewards'):getChildById('items'):getChildren().." "..itemSize)
  parent:getChildById('rewards'):getChildById('items2'):setSize(itemSize * #parent:getChildById('rewards'):getChildById('items2'):getChildren().." "..itemSize)
  parent:getChildById('rewards'):show()
end

function getRanking(self)
  local parent = self:getParent():getParent()
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode{protocol = "Ranking", diff = CurrentDiff, mapId = parent.map.mapId})
end

function SearchingTime()
    SearchPanel:getChildById('timer'):setText("Procurando time.")
    SearchPanel.p = 1
    SearchPanel:getChildById('timerCount'):setText(convertTime2(0))
    seconds = 0
    local function update()
      SearchPanel.p = SearchPanel.p == 3 and 1 or (SearchPanel.p+1)
      local txt = ""
      seconds = seconds + 1
      for p=1, SearchPanel.p do txt = txt.."." end
      SearchPanel:getChildById('timer'):setText("Procurando time"..txt)
      SearchPanel:getChildById('timerCount'):setText(convertTime2(seconds))
      SearchPanel.event = scheduleEvent(update, 1000)
    end
    SearchPanel.event = scheduleEvent(update, 1000)
end

function parseDungeon(protocol, opcode, buffer)
  -- print(buffer)
  local receive = json.decode(buffer)
  if receive.protocol == "close" then
    TeamPanel:getChildById('members'):destroyChildren()
    TeamPanel:getChildById('invitePlayer'):hide()
    DungeonPanel:getChildById('leaveTeam'):hide()
    TeamPanel:getChildById('createTeam'):show()
    SearchPanel:hide()
    RankingWindow:hide()
    InviteWindow:hide()
    InvitedWindow:hide()
    InformationWindow:hide()
    stopEvent(SearchPanel)
    stopEvent(InformationWindow)
  elseif receive.protocol == "first" then
    if CurrentDiff then
	  DifficultyPanel:getChildById(CurrentDiff):getChildById('separator'):hide()
	  DifficultyPanel:getChildById(CurrentDiff):setOpacity(0.5)
	end
    CurrentDiff = receive.diff
	DifficultyPanel:getChildById(CurrentDiff):getChildById('separator'):show()
	DifficultyPanel:getChildById(CurrentDiff):setOpacity(1)
    Maps = {}
  elseif receive.protocol == "maps" then
    for mapId, map in ipairs(receive.maps) do
	  for pos, fav_mapId in pairs(Favorites[CurrentDiff]) do
	    if mapId == tonumber(fav_mapId) then map.favorite = true break end
	  end
      map.mapId = mapId
      Maps[#Maps+1] = map
    end
	if receive.draw then drawMaps() end
  elseif receive.protocol == "keys" then
    for rarity, count in pairs(receive.keys) do
      KeysPanel:getChildById(rarity):getChildById('count'):setText("x"..count)
    end
  elseif receive.protocol == "team" then
    TeamPanel:getChildById('members'):destroyChildren()
    if receive.members then
      TeamPanel:getChildById('createTeam'):hide()
      TeamPanel:getChildById('invitePlayer'):show()
      DungeonPanel:getChildById('leaveTeam'):show()
	  table.sort(receive.members, function(a,b) return a.name == receive.leader end)
      for _, member in ipairs(receive.members) do
        local widget = g_ui.createWidget("MemberWidget", TeamPanel:getChildById('members'))
        widget:getChildById('name'):setText(member.name)
		widget:getChildById('level'):setText("Nivel: "..member.level)
		widget:getChildById('claName'):setText(getMasteryNameById(member.clan))
		widget:getChildById('clan'):setImageSource('/images/trainerCards/clans/' ..getMasteryNameById(member.clan))
	    local outfit = {type = member.outfit.lookType, head = member.outfit.lookHead, body = member.outfit.lookBody, legs = member.outfit.lookLegs, feet = member.outfit.lookFeet}
	    widget:getChildById('outfit'):setOutfit(outfit)
		if member.name == receive.leader then 
			widget:getChildById('leader'):show()
			widget:getChildById('leader'):setImageSource('images/leader')
			widget:getChildById('leader'):setImageColor("#bf7e00")
			widget:getChildById('leader'):setTooltip("Lider do grupo")
		else
			widget:getChildById('leader'):show()
			widget:getChildById('leader'):setImageSource('images/member')
			widget:getChildById('leader'):setImageColor("#6797fb")
			widget:getChildById('leader'):setTooltip("Membro do grupo")
		end
      end
    else
      TeamPanel:getChildById('invitePlayer'):hide()
      DungeonPanel:getChildById('leaveTeam'):hide()
      TeamPanel:getChildById('createTeam'):show()
    end
  elseif receive.protocol == "searching" then
    SearchPanel:getChildById('name'):setText(receive.name)
    SearchPanel:getChildById('experience'):setText("+")
    SearchPanel:getChildById('experience2'):setText(getFormattedMoney2(receive.experience))
    SearchPanel:getChildById('experience3'):setText("Experiência")
	SearchPanel:getChildById('playersIcon'):destroyChildren()
    for icon=1, receive.max do
      local widget = g_ui.createWidget('PlayerIcon', SearchPanel:getChildById('playersIcon'))
      widget:setSize('35 39')
      if icon > #receive.members then widget:setOpacity('0.5') end
    end
    SearchPanel:getChildById('playersIcon'):setWidth(35*receive.max)
	SearchPanel:getChildById('items'):destroyChildren()
	SearchPanel:getChildById('items2'):destroyChildren()
    local itemSize, maxColumn = 32, 10
    local line, column = 0, 0
    for _, reward in ipairs(receive.reward) do
      local item = g_ui.createWidget('RewardsDg', SearchPanel:getChildById('items'..(line > 0 and 2 or '')))
	  item:setSize(itemSize.." "..itemSize)
      item:setItemId(reward.clientId)
      item:setTooltip(reward.name)
      item:setVirtual(true)
      item:addAnchor(AnchorTop, 'parent', AnchorTop)
      item:addAnchor(AnchorLeft, 'parent', AnchorLeft)
      item:setMarginLeft(column * itemSize)
      if column == (maxColumn-1) then line = line+1 column = 0 else column = column+1 end
    end
    SearchPanel:getChildById('items'):setSize(itemSize * #SearchPanel:getChildById('items'):getChildren().." "..itemSize)
    SearchPanel:getChildById('items2'):setSize(itemSize * #SearchPanel:getChildById('items2'):getChildren().." "..itemSize)
	SearchPanel:getChildById('playersOutfit'):destroyChildren()
	for _, member in ipairs(receive.members) do
      local widget = g_ui.createWidget('UICreature', SearchPanel:getChildById('playersOutfit'))
      widget:setSize('46 46')
	  local outfit = {type = member.outfit.lookType, head = member.outfit.lookHead, body = member.outfit.lookBody, legs = member.outfit.lookLegs, feet = member.outfit.lookFeet}
	  widget:setOutfit(outfit)
	  widget:setTooltip(member.name.." [Lv:"..member.level.."]")
    end
    SearchPanel:getChildById('playersOutfit'):setWidth(64*#receive.members)

	SearchPanel:show()
  elseif receive.protocol == "invite" then
    -- Mostra janela de invite
    showInvitePlayer({name = receive.leader})
  elseif receive.protocol == "start" then
    -- Abre a janela de começo.
    InformationWindow:getChildById('timer'):setText(convertTime2(receive.time/ 1000))
    InformationWindow.time = receive.time / 1000
    local function updateTimer()
      if InformationWindow.time <= 0 then return end
      InformationWindow.time = InformationWindow.time - 1
      InformationWindow:getChildById('timer'):setText(convertTime2(InformationWindow.time))
	  InformationWindow.event = scheduleEvent(updateTimer, 1000)
    end
    InformationWindow.event = scheduleEvent(updateTimer, 1000)
    InformationWindow:getChildById('potion'):getChildById('label'):setText(receive.potions)
    InformationWindow:getChildById('revive'):getChildById('label'):setText(receive.revives)
    InformationWindow:getChildById('pokemon'):getChildById('label'):setText(receive.pokemons)
    InformationWindow:getChildById('PokeImageInfo'):setImageSource("images/dz_rush/def_dg")
    InformationWindow:getChildById('PokeImageInfo'):setTooltip("Derrote todos os Pokémons")
    TeamPanel:getChildById('members'):destroyChildren()
    TeamPanel:getChildById('invitePlayer'):hide()
    DungeonPanel:getChildById('leaveTeam'):hide()
    TeamPanel:getChildById('createTeam'):show()
    stopEvent(SearchPanel)
    SearchPanel:hide()
    RankingWindow:hide()
    InviteWindow:hide()
    InvitedWindow:hide()
    MainWindow:hide()
	InformationWindow:show()
  elseif receive.protocol == "medicament" then
    InformationWindow:getChildById(receive.potion and 'potion' or 'revive'):getChildById('label'):setText(receive.potion and receive.potion or receive.revive)
  elseif receive.protocol == "pokemoncount" then
    InformationWindow:getChildById('pokemon'):getChildById('label'):setText(math.max(0, receive.count))
		if receive.count == 0 then
			InformationWindow:getChildById('PokeImageInfo'):setImageSource("images/dz_rush/attack_dg")
			InformationWindow:getChildById('PokeImageInfo'):setTooltip("Derrote o Pokémon chefe")
    InformationWindow:getChildById('pokemon'):getChildById('label'):setText("Derrote o Pokémon chefe")
		end
  elseif receive.protocol == "closeinformation" then
    InformationWindow:hide()
    if InformationWindow.event then
      removeEvent(InformationWindow.event)
      InformationWindow.event = nil
    end
  elseif receive.protocol == "ranking" then
    RankingWindow:getChildById('DgImage'):setImageSource('images/background/circle/'..receive.image)
    RankingWindow:getChildById('map'):setText(receive.map)
    RankingWindow:getChildById('diff'):setText(Difficulty[receive.diff].name.." "..Difficulty[receive.diff].level)
    RankingWindow:getChildById('panel'):destroyChildren()
    for pos, rank in ipairs(receive.ranking) do
	  local widget = g_ui.createWidget("RankingWidget", RankingWindow:getChildById('panel'))
      widget:getChildById('name'):setText(rank.name)
      widget:getChildById('level'):setText(rank.level)
      widget:getChildById('time'):setText(convertTime2(rank.time))
      widget:getChildById('claName'):setText(getMasteryNameById(rank.clan))
      widget:getChildById('clan'):setImageSource('/images/trainerCards/clans/' ..getMasteryNameById(rank.clan))
      local outfit = {type = rank.outfit.lookType, head = rank.outfit.lookHead, body = rank.outfit.lookBody, legs = rank.outfit.lookLegs, feet = rank.outfit.lookFeet}
      widget:getChildById('outfit'):setOutfit(outfit)
	  if pos > 4 then 
		RankingWindow:getChildById('scrollbar'):show()
	  end
	  if pos <= 10 then
	    widget:getChildById('star'):show()
		if pos == 1 then widget:getChildById('star'):setImageSource('images/ranking/1') end
		if pos == 2 then widget:getChildById('star'):setImageSource('images/ranking/2') end
		if pos == 3 then widget:getChildById('star'):setImageSource('images/ranking/3') end
		if pos == 4 then widget:getChildById('star'):setImageSource('images/ranking/4') end
		if pos == 5 then widget:getChildById('star'):setImageSource('images/ranking/5') end
		if pos == 6 then widget:getChildById('star'):setImageSource('images/ranking/6') end
		if pos == 7 then widget:getChildById('star'):setImageSource('images/ranking/7') end
		if pos == 8 then widget:getChildById('star'):setImageSource('images/ranking/8') end
		if pos == 9 then widget:getChildById('star'):setImageSource('images/ranking/9') end
		if pos == 10 then widget:getChildById('star'):setImageSource('images/ranking/10') end
	  end
	end
	RankingWindow:show()
	RankingWindow:raise()
	RankingWindow:focus()
  end
end

function drawMaps()
  DungeonList:destroyChildren()
  table.sort(Maps, function(a,b) return a.favorite and not b.favorite end)
  local firstWidget = nil
  for _, map in ipairs(Maps) do
    local widget = g_ui.createWidget('DungeonWidget', DungeonList)
    local pictures = widget:getChildById('panel'):getChildById('PictureDG')
	widget:getChildById('border'):setImageSource('images/borders/border_'..map.rarity)
	widget:setId('map'..map.mapId)
    widget:setImageSource("images/background/"..map.image)
    pictures:setImageSource("images/background/pictures/"..map.image)
    widget:getChildById('panel'):getChildById('name'):setText(map.name)
    for icon=1, map.maxPlayers do
      g_ui.createWidget('PlayerIconDZS', widget:getChildById('panel'):getChildById('playersIcon'))
    end
    widget:getChildById('panel'):getChildById('favoritesButton'):setImageClip((map.favorite and '0 0' or '18 0')..' 18 18')
    widget:getChildById('panel'):getChildById('playersIcon'):setWidth(17*map.maxPlayers) 
    widget:getChildById('panel'):getChildById('playersText'):setText(map.maxPlayers..tr(" "..getPlayersCountDG(map.maxPlayers)))
    widget:getChildById('panel'):getChildById('roomsText'):setText(map.rooms.occupied.."/"..map.rooms.max..tr(" Salas em uso"))
    widget:getChildById('panel'):getChildById('roomsProgressBar'):setValue(map.rooms.occupied, 0, map.rooms.max)
    widget.map = map
	if not firstWidget then firstWidget = widget end
  end
  if firstWidget then firstWidget:focus() end
  MainWindow:show()
end

function onDungeonWidgetFocusChange(self, focusedChild, unfocusedChild, reason)

  if unfocusedChild then
	unfocusedChild:getChildById('panel'):getChildById('name'):setColor("#ffffff")
	unfocusedChild:getChildById('lighthover'):setImageSource('images/none')
  end
  if focusedChild then
	focusedChild:getChildById('panel'):getChildById('name'):setColor("#6797fb")
	focusedChild:getChildById('lighthover'):setImageSource('images/light_hover')
	focusedChild:getChildById('lighthover'):setImageColor(getRankLightColor(focusedChild.map.rarity))
  end
end

function createTeam()
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode{protocol = "CreateTeam"})
end

function leaveTeam()
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode{protocol = "LeaveTeam"})
end

function showInvitePlayer(params)
  if params.invite then
    InviteWindow:getChildById('edit'):show()
    InviteWindow:getChildById('label'):hide()
    InviteWindow:getChildById('confirm').onClick = function()
      g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode{protocol = "InviteToTeam", name = InviteWindow:getChildById('edit'):getText()})
	  InviteWindow:getChildById('edit'):setText("")
	  InviteWindow:hide()
    end
  InviteWindow:show()
  InviteWindow:focus()
  InviteWindow:raise()
  else
    InvitedWindow:getChildById('label_Name'):setText(params.name)
    InvitedWindow:getChildById('confirm').onClick = function()
      g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode{protocol = "AcceptInvite", name = params.name})
      InvitedWindow:hide()
    end
  InvitedWindow:show()
  InvitedWindow:focus()
  InvitedWindow:raise()
  end
end

function play()
  local dz = DungeonList:getFocusedChild()
  if not dz then return end
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode{protocol = "Play", diff = CurrentDiff, mapId = dz.map.mapId})
end

function cancelQueue()
  g_game.getProtocolGame():sendExtendedOpcode(Opcode, json.encode{protocol = "CancelQueue"})
  stopEvent(SearchPanel)
  SearchPanel:hide()
end

function convertTime(seconds)
  local hours = 0
  local minutes = 0
  repeat
    if seconds >= 60000 then
	  minutes = minutes + 1; seconds = seconds - 60000
	elseif minutes >= 60 then
	  hours = hours + 1; minutes = minutes - 60
	end
  until seconds < 60000 and minutes < 60
  local hours = string.sub(hours < 10 and "0"..hours or hours, 1, 2)
  local minutes = string.sub(minutes < 10 and "0"..minutes or minutes, 1, 2)
  local seconds = string.sub(seconds < 10000 and "0"..seconds or seconds, 1, 2)
  return hours..":"..minutes..":"..seconds
end

function convertTime2(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
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
  return valueText
end

--SHOW BUTTONS

function updatePosition()
	local player = g_game.getLocalPlayer()
	if not player then
		return 
	end
	local pos = player:getPosition()
	if not pos then return end
	check = false
	local prioridade = nil
	for i = 1, #areas do
		if isInRange(pos, areas[i].from, areas[i].to) then
			if prioridade == nil then
				prioridade = areas[i].priority
				Table = areas[i]
			end
			
			if areas[i].priority > prioridade then
				Table = areas[i]
				prioridade = areas[i].priority
			end
			check = true
		end
	end
	if check == true then
		if Table.name == area then
			return false
		else
			reset()
			area = Table.name
			retorno = 1
			TopButton:setVisible(true) 
			eventAnimation = cycleEvent(function() showDGButtons(retorno) end, 200)
			check = true
		end
	else
		reset()	
	end
end

function reset()
	area = nil
	removeEvent(eventAnimation)
	removeEvent(TopButton.fadeEvent)
	g_effects.fadeOut(TopButton, 0)
	TopButton:hide()
	-- TopButton:setVisible(false)	
    hideMainWindow()
end
function showDGButtons()
	if retorno == 1 then
		g_effects.fadeIn(TopButton, 1100)
		retorno = 2
		removeEvent(eventAnimation)
		-- eventAnimation = cycleEvent(function() showDGButtons(retorno) end, 2500)
		return
	elseif retorno == 2 then
		-- g_effects.fadeOut(TopButton, 1100)
		retorno = 0
		removeEvent(eventAnimation)
	end
end