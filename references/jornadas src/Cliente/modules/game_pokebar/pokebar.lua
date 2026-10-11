-- Constants
pokemonBar = nil

local lastBarIcon = nil
local portraitLabels = {}
local currentPokemonPortraitLabel
local currentPokemonLife
local currentPokemonMP
local currentPokemonXP
local currentPokemonPortrait

local ORIENTATIONS = {}
ORIENTATIONS.HORIZONTAL = 0
ORIENTATIONS.VERTICAL = 1

local orientation = ORIENTATIONS.HORIZONTAL
local defaultWidth = 0
local defaultHeight = 0

local POKEBELT_ITEM_IMAGE = "images/none"
local POKEBELT_ITEM_USE_IMAGE = "images/none"

pokemonExperienceTooltip = 'Your Pokemon have %d%% to advance to level %d.'
manaTooltip = 'Your Pokemon energy is %d out of %d.'

local function resetCurrentPortrait()
    currentPokemonPortraitLabel = nil
    currentPokemonLife = nil
    currentPokemonMP = nil
    currentPokemonXP = nil
    currentPokemonPortrait = nil
end

local function getColorByHealthPercent(percent, serverId)
    if (percent >= 80) then
        return '#00851B'
    elseif (percent >= 40) then
        return '#8A8A00'
    end
    return '#850000'
end

local function updatePortraitLabel(portrait, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)
    local label = portraitLabels[portrait:getId()]
    if (text == tr("USE")) then
        currentPokemonPortraitLabel = label
        currentPokemonPortrait = portrait
        currentPokemonLife = portrait:getChildById('HPProgressBar')
        currentPokemonMP = portrait:getChildById('MPProgressBar')
        currentPokemonXP = portrait:getChildById('XPProgressBar')
        levelLabel = portrait:getChildById('levelLabel')
        portrait:setImageSource(POKEBELT_ITEM_USE_IMAGE)
		
		local ImageBackground = currentPokemonPortrait:getChildById('backgroundborderbig')
		local PokeType = currentPokemonPortrait:getChildById('type1')
		local iconsBars = currentPokemonPortrait:getChildById('iconsBars')
		local backgroundblack = currentPokemonPortrait:getChildById('backgroundblack')
		local setinha = currentPokemonPortrait:getChildById('hand')

		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/4")
			backgroundblack:setImageSource("images/animated/f4")
			PokeType:setMarginRight(104)
		end, 50)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/5")
			backgroundblack:setImageSource("images/animated/f5")
			PokeType:setMarginRight(95)
		end, 100)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/6")
			backgroundblack:setImageSource("images/animated/f6")
			PokeType:setMarginRight(86)
			setinha:setMarginRight(-20)
		end, 150)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/7")
			backgroundblack:setImageSource("images/animated/f7")
			PokeType:setMarginRight(77)
			local Pokelabel = portrait:getChildById('PokeName')
			local pokeShiny = portrait:getChildById('pokeShiny')
			local PokeGender = portrait:getChildById('pokeGender')
			g_effects.fadeIn(Pokelabel)
			g_effects.fadeIn(pokeShiny)
			g_effects.fadeIn(PokeGender)
		end, 200)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/8")
			backgroundblack:setImageSource("images/animated/f8")
			PokeType:setMarginRight(68)
		end, 250)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/9")
			backgroundblack:setImageSource("images/animated/f9")
			PokeType:setMarginRight(59)
		end, 300)
		scheduleEvent(function()
		ImageBackground:setImageSource("images/animated/10")
		backgroundblack:setImageSource("images/animated/f10")
		PokeType:setMarginRight(50)
		end, 350)
		scheduleEvent(function()
		ImageBackground:setImageSource("images/animated/11")
		backgroundblack:setImageSource("images/animated/f11")
		PokeType:setMarginRight(41)
		end, 400)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/12")
			backgroundblack:setImageSource("images/animated/f12")
			PokeType:setMarginRight(32)
		end, 450)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/13")
			backgroundblack:setImageSource("images/animated/f13")
			PokeType:setMarginRight(23)
			g_effects.fadeIn(iconsBars)
		end, 500)
		scheduleEvent(function()portrait:getChildById('baseCircleLight'):setImageSource("images/circle/light_green")end, 510)

		portrait:getChildById('HPProgressBar'):setOpacity(0)
		portrait:getChildById('MPProgressBar'):setOpacity(0)
		portrait:getChildById('XPProgressBar'):setOpacity(0)
		
		scheduleEvent(function()
		    currentPokemonLife:setMarginLeft(75)
		    currentPokemonMP:setMarginLeft(73)
			currentPokemonXP:setMarginLeft(73)
		    currentPokemonLife:setSize('131 15')
		    currentPokemonMP:setSize('123 5')
			currentPokemonXP:setSize('118 5')

			g_effects.fadeIn(currentPokemonLife)
			g_effects.fadeIn(currentPokemonMP)
			g_effects.fadeIn(currentPokemonXP)
			g_effects.fadeIn(currentPokemonPortraitLabel)
		end, 550)
		
        return
    elseif (portrait == currentPokemonPortrait) then -- diminui
		local ImageBackground = currentPokemonPortrait:getChildById('backgroundborderbig')
		local PokeType = currentPokemonPortrait:getChildById('type1')
		local iconsBars = currentPokemonPortrait:getChildById('iconsBars')
		local backgroundblack = currentPokemonPortrait:getChildById('backgroundblack')
		local setinha = currentPokemonPortrait:getChildById('hand')

		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/13")
			backgroundblack:setImageSource("images/animated/f13")
			PokeType:setMarginRight(23)
			local Pokelabel = portrait:getChildById('PokeName')
			local pokeShiny = portrait:getChildById('pokeShiny')
			local PokeGender = portrait:getChildById('pokeGender')
			g_effects.fadeOut(Pokelabel)
			g_effects.fadeOut(pokeShiny)
			g_effects.fadeOut(PokeGender)
		end, 50)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/12")
			backgroundblack:setImageSource("images/animated/f12")
			PokeType:setMarginRight(32)
		end, 100)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/11")
			backgroundblack:setImageSource("images/animated/f11")
			PokeType:setMarginRight(41)
		end, 150)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/10")
			backgroundblack:setImageSource("images/animated/f10")
			PokeType:setMarginRight(50)
		end, 200)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/9")
			backgroundblack:setImageSource("images/animated/f9")
			PokeType:setMarginRight(59)
		end, 250)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/8")
			backgroundblack:setImageSource("images/animated/f8")
			PokeType:setMarginRight(68)
		end, 300)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/7")
			backgroundblack:setImageSource("images/animated/f7")
			PokeType:setMarginRight(77)
			setinha:setMarginRight(70)
		end, 350)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/6")
			backgroundblack:setImageSource("images/animated/f6")
			PokeType:setMarginRight(86)
		end, 400)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/5")
			backgroundblack:setImageSource("images/animated/f5")
			PokeType:setMarginRight(95)
		end, 450)
		scheduleEvent(function()
			ImageBackground:setImageSource("images/animated/4")
			backgroundblack:setImageSource("images/animated/f4")
			PokeType:setMarginRight(104)
		end, 500)
		scheduleEvent(function()PokeType:setMarginRight(113)end, 550)
		
		iconsBars:setOpacity(0)
		label:setOpacity(0)
		portrait:getChildById('HPProgressBar'):setOpacity(0)
		portrait:getChildById('MPProgressBar'):setOpacity(0)
		portrait:getChildById('XPProgressBar'):setOpacity(0)
		
		scheduleEvent(function()
		    portrait:getChildById('HPProgressBar'):setMarginLeft(58)
		    portrait:getChildById('MPProgressBar'):setMarginLeft(55)
			portrait:getChildById('XPProgressBar'):setMarginLeft(49)
		    portrait:getChildById('HPProgressBar'):setSize('57 15')
		    portrait:getChildById('MPProgressBar'):setSize('51 5')
			portrait:getChildById('XPProgressBar'):setSize('52 5')

			g_effects.fadeIn(portrait:getChildById('HPProgressBar'))
			g_effects.fadeIn(portrait:getChildById('MPProgressBar'))
			g_effects.fadeIn(portrait:getChildById('XPProgressBar'))
		end, 600)
		
		scheduleEvent(function()portrait:getChildById('baseCircleLight'):setImageSource("images/circle/light_white")end, 520)
		resetCurrentPortrait()
    end

    if (textColor == 0) then
        portrait:getChildById('HPProgressBar'):setBackgroundColor("#00851B")
        portrait:getChildById('portrait'):setColor(TextColors.white)
    elseif (textColor == 1) then
        portrait:getChildById('HPProgressBar'):setBackgroundColor("#8A8A00")
        portrait:getChildById('portrait'):setColor(TextColors.white)
    elseif (textColor == 2) then
        portrait:getChildById('HPProgressBar'):setBackgroundColor("#850000")
        if (text == "FNT") then
            portrait:getChildById('portrait'):setColor('#00000099')
        end
    else
        portrait:getChildById('HPProgressBar'):setBackgroundColor("#FFFFFF")
        portrait:getChildById('portrait'):setColor(TextColors.white)
    end
	
    label:setText(text)
    portrait:getChildById('levelLabel'):setText("Lv."..pokeLevel)
    portrait:getChildById('MPProgressBar'):setValue(pokeMana, 0, pokeMaxMana)
    portrait:getChildById('MPProgressBar'):setTooltip(tr(manaTooltip, pokeMana, pokeMaxMana))
	
    portrait:getChildById('HPProgressBar'):setTooltip("Vida - "..text)
	
    portrait:getChildById('XPProgressBar'):setPercent(pokeExp)
    portrait:getChildById('XPProgressBar'):setTooltip(tr('Your Pokemon have %d%% to advance to level %d.', pokeExp, pokeLevel+1))
	
    portrait:getChildById('HPProgressBar'):setPercent(textColor)
	if text == "100%" then
		portrait:getChildById('HPProgressBar'):setPercent(string.sub(text, 0, 3))
	elseif text == "FNT" then
		portrait:getChildById('HPProgressBar'):setPercent(0)
	else
		portrait:getChildById('HPProgressBar'):setPercent(string.sub(text, 0, 2))
	end
end

local function hide()
    pokemonBar:hide()
end

local function show()
    pokemonBar:show()
end

local function resize()
    if (orientation == ORIENTATIONS.HORIZONTAL) then
        local width = pokemonBar:getPaddingLeft() + pokemonBar:getPaddingRight()

        if (pokemonBar:getChildCount() == 0) then
            width = width + 227

        else
            for k, v in pairs(pokemonBar:getChildren()) do
                if (v:getStyleName() == 'BeltItem') then
                    width = width + v:getWidth() + 5
                end
            end
        end

        pokemonBar:resize(width, defaultHeight)

    else
        local height = pokemonBar:getPaddingTop() + pokemonBar:getPaddingBottom() + 5

        if (pokemonBar:getChildCount() == 0) then
            height = height + 227

        else
            for k, v in pairs(pokemonBar:getChildren()) do
                height = height + v:getHeight()
            end
        end

        pokemonBar:resize(227, height)
    end
end

local function reallocatePortraits()
    local last
    for k, v in pairs(pokemonBar:getChildren()) do
        if (v:getStyleName() == 'BeltItem') then
            v:breakAnchors()

            if (orientation == ORIENTATIONS.HORIZONTAL) then
                if (last) then
                    v:addAnchor(AnchorLeft, last:getId(), AnchorRight)
                else
                    v:addAnchor(AnchorLeft, 'parent', AnchorLeft)
                end
                v:addAnchor(AnchorTop, 'parent', AnchorTop)
                v:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)

                last = v

            else
                if (last) then
                    v:addAnchor(AnchorTop, last:getId(), AnchorBottom)
                else
                    v:addAnchor(AnchorTop, 'parent', AnchorTop)
                end
                v:addAnchor(AnchorLeft, 'parent', AnchorLeft)
                v:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
                last = v
            end
        end
    end
end

function switchOrientation()
    orientation = orientation == ORIENTATIONS.HORIZONTAL and ORIENTATIONS.VERTICAL or ORIENTATIONS.HORIZONTAL
    resize()
    reallocatePortraits()
end

local function removePortrait(portrait)
    local id = portrait:getId()
    if (portraitLabels[id] == currentPokemonPortraitLabel) then
        currentPokemonPortraitLabel = nil
		currentPokemonLife = nil
		currentPokemonMP = nil
		currentPokemonXP = nil
        currentPokemonPortrait = nil
    end

    portraitLabels[id]:destroy()
    portraitLabels[id] = nil
    portrait:destroy()
end

local function reset()
    pokemonBar:destroyChildren()
    resetCurrentPortrait()
end

function onPokemonBarAdd(itemId, fastcallNumber, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)
    local item = g_ui.createWidget('BeltItem', pokemonBar)
    local pokeImage = item:getChildById('pokeImage')
    local portrait = item:getChildById('portrait')
    local label = item:getChildById('health')
    local Pokelabel = item:getChildById('PokeName')
    local PokeID = item:getChildById('PokeID')
    local PokeGender = item:getChildById('pokeGender')
    local hand = item:getChildById('hand')
    local pokeShiny = item:getChildById('pokeShiny')
    local type1 = item:getChildById('type1')
    local ProgressBar = item:getChildById('ProgressBar')
    local type2 = item:getChildById('type2')
    local levelLabel = item:getChildById('levelLabel')

    item:setId('poke' .. fastcallNumber)
    pokeImage:setImageSource('/images/pokeicons/'..getPokemonNameByIconItemId(itemId))
	
    item.onMouseRelease = function(self, mousePosition, mouseButton)
        if mouseButton == MouseLeftButton and g_keyboard.isShiftPressed() then
            g_game.talkChannel(MessageModes.Say, 0 , '/pd ' .. fastcallNumber)
            return true
        end
        g_game.talkChannel(MessageModes.Say, 0 , '/cp ' .. fastcallNumber)
        return true
    end
    item:setTooltip(getPokemonNameByIconItemId(itemId))
    pokeImage:setTooltip(getPokemonNameByIconItemId(itemId))

    type1:setImageSource("/images/types/type_ball/"..TABLE_POKEMON_INFO[getPokemonNameByIconItemId(itemId)].type1) 
    type2:setImageSource(TABLE_POKEMON_INFO[getPokemonNameByIconItemId(itemId)].type2 == "" and "" or "/images/types/type_ball/"..TABLE_POKEMON_INFO[getPokemonNameByIconItemId(itemId)].type2)
    
    type1:setTooltip(TABLE_POKEMON_INFO[getPokemonNameByIconItemId(itemId)].type1) 
    type2:setTooltip(TABLE_POKEMON_INFO[getPokemonNameByIconItemId(itemId)].type2 == "" and "" or TABLE_POKEMON_INFO[getPokemonNameByIconItemId(itemId)].type2)

	
	PokeID:setText(TABLE_POKEMON_INFO[getPokemonNameByIconItemId(itemId)].dexID)

	if(string.find(getPokemonNameByIconItemId(itemId), 'Shiny')) then
		Pokelabel:setText(string.sub(getPokemonNameByIconItemId(itemId), 7, 99))
		Pokelabel:setColor("#e6960b")
		pokeShiny:show()
		pokeShiny:setTooltip("Pokémon Shiny")
	else
		Pokelabel:setText(getPokemonNameByIconItemId(itemId))
		pokeShiny:hide()
		PokeGender:setMarginLeft(-12)
	end

    if pokeGender == 2 then
      PokeGender:setImageSource(pokeGender == 2 and "/images/game/skulls/skull_yellow")
      PokeGender:setTooltip("Sexless")
    elseif pokeGender == 1 then
      PokeGender:setImageSource("/images/game/skulls/skull_black")
      PokeGender:setTooltip("Male")
    elseif pokeGender == 0 then
      PokeGender:setImageSource("/images/game/skulls/skull_red")
      PokeGender:setTooltip("Female")
    end

    label:setId(item:getId() .. 'label')
    levelLabel:setText("Lv."..pokeLevel)

    lastBarIcon = item
    portraitLabels[item:getId()] = label
    updatePortraitLabel(item, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)

    resize()
    reallocatePortraits()
    show()
end

function onPokemonBarRemove(fastcallNumber)
    local id = 'poke' .. fastcallNumber
    for k, v in pairs(pokemonBar:getChildren()) do
        if (v:getStyleName() == 'BeltItem' and v:getId() == id) then
            removePortrait(v)
        end
    end

    resize()
    reallocatePortraits()
    show()
end

function onPokemonBarUpdate(fastcallNumber, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)
    local id = 'poke' .. fastcallNumber
    for k, v in pairs(pokemonBar:getChildren()) do
        if (v:getStyleName() == 'BeltItem' and v:getId() == id) then
            updatePortraitLabel(v, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)
        end
    end
end

function ButtonClick()
	if pokemonBar:isVisible() then
		hide()
	else
		show()
	end
end
function onPokemonBarOpen()
	show()
end

function onPokemonBarClose()
    hide()
    reset()
end

function onOnline()
    hide()
    reset()
    resize()
end

function onOffline()
    hide()
    reset()
end

function onManaChange(localPlayer, mana, maxMana)
  local localPlayer = g_game.getLocalPlayer()
    if currentPokemonMP and localPlayer then
		currentPokemonMP:setValue(mana, 0, maxMana)
		currentPokemonMP:setTooltip(tr('Your Pokemon energy is %d out of %d.', mana, maxMana))
    end
end

function onPokemonLevelChange(localPlayer, value, percent)
  local localPlayer = g_game.getLocalPlayer()
    if currentPokemonXP and localPlayer then
		currentPokemonXP:setTooltip(tr(pokemonExperienceTooltip, percent, value+1))
		currentPokemonXP:setPercent(percent)
    end
end

function onCreatureHealthPercentChange(creature, health)
    if (creature:isLocalPlayerSummon() and currentPokemonPortraitLabel and currentPokemonLife) then
        local p = creature:getHealthPercent()
        currentPokemonPortraitLabel:setText(p.."%")
		currentPokemonLife:setPercent(p)
		currentPokemonLife:setBackgroundColor(getColorByHealthPercent(p))
    end
end

function onInit()
    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarOpen = onPokemonBarOpen,
        onPokemonBarClose = onPokemonBarClose})
		
	connect(LocalPlayer, {
		onManaChange = onManaChange,
		onMagicLevelChange = onPokemonLevelChange
	})

    connect(Creature, {
        onHealthPercentChange = onCreatureHealthPercentChange,
    })

    pokemonBar = g_ui.loadUI('pokebar', modules.game_interface.getRootPanel())
    scheduleEvent(function()
        local p = g_settings.getPoint('pokebar-pos')
        if (p and p.x > 0 and p.y > 0) then
            pokemonBar:breakAnchors()
            pokemonBar:setPosition(p)
        end
    end, 100)
    orientation = g_settings.getInteger('pokebar-orientation', ORIENTATIONS.HORIZONTAL)
    pokemonBar:hide()

    pokemonBar.onMouseRelease = function(self, mousePosition, mouseButton)
        if (mouseButton == MouseRightButton) then
            local menu = g_ui.createWidget('PopupMenu')
            menu:addOption(tr('Switch Orientation'), switchOrientation)
            menu:display(mousePosition)
            return true
        end
        return false
    end

    defaultWidth = pokemonBar:getWidth()
    defaultHeight = pokemonBar:getHeight()

    if (g_game.isOnline()) then
        onOnline()
		local localPlayer = g_game.getLocalPlayer()
        onManaChange(localPlayer, localPlayer:getMana(), localPlayer:getMaxMana())
    end
end

function onTerminate()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarOpen = onPokemonBarOpen,
        onPokemonBarClose = onPokemonBarClose})
		
	disconnect(LocalPlayer, {
		onManaChange = onManaChange,
		onMagicLevelChange = onPokemonLevelChange
	})

    disconnect(Creature, {
        onHealthPercentChange = onCreatureHealthPercentChange,
    })

    g_settings.set('pokebar-pos', pokemonBar:getPosition())
    g_settings.set('pokebar-orientation', orientation)

    pokemonBar:destroy()
end

function onMoveBottomPanelHoverChange(widget)
  if widget:isHovered() and not g_mouse.isPressed(MouseLeftButton) then
    addEvent(function() g_effects.fadeIn(widget:getChildById('hand'), 250) end)
  elseif not widget:isHovered() and not g_mouse.isPressed(MouseLeftButton) then
    addEvent(function() g_effects.fadeOut(widget:getChildById('hand'), 250) end)
  end
end