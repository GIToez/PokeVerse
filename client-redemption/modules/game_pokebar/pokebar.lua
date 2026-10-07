-- PokeVerse Pokemon bar. Behaviour reference: client/runtime-data/modules/game_pokebar (legacy client).
pokemonBar = nil

local IMAGES = '/modules/game_pokebar/images/'
local TYPE_IMAGES = '/images/types/type_ball/'

local ORIENTATIONS = { HORIZONTAL = 0, VERTICAL = 1 }
local orientation = ORIENTATIONS.HORIZONTAL
local defaultHeight = 0

local portraitLabels = {}
local current = {}

local pokemonExperienceTooltip = 'Your Pokemon has %d%% to advance to level %d.'
local manaTooltip = 'Your Pokemon energy is %d out of %d.'

local function resetCurrentPortrait()
    current = {}
end

local function getColorByHealthPercent(percent)
    if percent >= 80 then
        return '#00851B'
    elseif percent >= 40 then
        return '#8A8A00'
    end
    return '#850000'
end

local function pokemonInfo(name)
    return TABLE_POKEMON_INFO and TABLE_POKEMON_INFO[name]
end

-- Frames 4..13 of images/animated widen the portrait; the type icon slides 9px per frame.
local function animateFrames(portrait, frames, onFrame)
    local border = portrait:getChildById('backgroundborderbig')
    local black = portrait:getChildById('backgroundblack')
    local type1 = portrait:getChildById('type1')
    for step, frame in ipairs(frames) do
        scheduleEvent(function()
            if portrait:isDestroyed() then
                return
            end
            border:setImageSource(IMAGES .. 'animated/' .. frame)
            black:setImageSource(IMAGES .. 'animated/f' .. frame)
            type1:setMarginRight(104 - (frame - 4) * 9)
            if onFrame then
                onFrame(frame)
            end
        end, step * 50)
    end
end

local function setBars(portrait, hpMargin, mpMargin, xpMargin, hpSize, mpSize, xpSize)
    local hp = portrait:getChildById('HPProgressBar')
    local mp = portrait:getChildById('MPProgressBar')
    local xp = portrait:getChildById('XPProgressBar')
    hp:setMarginLeft(hpMargin)
    mp:setMarginLeft(mpMargin)
    xp:setMarginLeft(xpMargin)
    hp:setSize(hpSize)
    mp:setSize(mpSize)
    xp:setSize(xpSize)
    g_effects.fadeIn(hp)
    g_effects.fadeIn(mp)
    g_effects.fadeIn(xp)
end

local function hideBars(portrait)
    portrait:getChildById('HPProgressBar'):setOpacity(0)
    portrait:getChildById('MPProgressBar'):setOpacity(0)
    portrait:getChildById('XPProgressBar'):setOpacity(0)
end

local function expandPortrait(portrait, label)
    current = {
        label = label,
        portrait = portrait,
        life = portrait:getChildById('HPProgressBar'),
        mana = portrait:getChildById('MPProgressBar'),
        experience = portrait:getChildById('XPProgressBar'),
    }
    local hand = portrait:getChildById('hand')
    local iconsBars = portrait:getChildById('iconsBars')
    animateFrames(portrait, { 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 }, function(frame)
        if frame == 6 then
            hand:setMarginRight(-20)
        elseif frame == 7 then
            g_effects.fadeIn(portrait:getChildById('PokeName'))
            g_effects.fadeIn(portrait:getChildById('pokeShiny'))
            g_effects.fadeIn(portrait:getChildById('pokeGender'))
        elseif frame == 13 then
            g_effects.fadeIn(iconsBars)
        end
    end)
    scheduleEvent(function()
        if not portrait:isDestroyed() then
            portrait:getChildById('baseCircleLight'):setImageSource(IMAGES .. 'circle/light_green')
        end
    end, 510)
    hideBars(portrait)
    scheduleEvent(function()
        if not portrait:isDestroyed() then
            setBars(portrait, 75, 73, 73, '131 15', '123 5', '118 5')
            g_effects.fadeIn(label)
        end
    end, 550)
end

local function collapsePortrait(portrait, label)
    local hand = portrait:getChildById('hand')
    local type1 = portrait:getChildById('type1')
    animateFrames(portrait, { 13, 12, 11, 10, 9, 8, 7, 6, 5, 4 }, function(frame)
        if frame == 13 then
            g_effects.fadeOut(portrait:getChildById('PokeName'))
            g_effects.fadeOut(portrait:getChildById('pokeShiny'))
            g_effects.fadeOut(portrait:getChildById('pokeGender'))
        elseif frame == 7 then
            hand:setMarginRight(70)
        end
    end)
    scheduleEvent(function()
        if not portrait:isDestroyed() then
            type1:setMarginRight(113)
        end
    end, 550)
    portrait:getChildById('iconsBars'):setOpacity(0)
    label:setOpacity(0)
    hideBars(portrait)
    scheduleEvent(function()
        if not portrait:isDestroyed() then
            portrait:getChildById('baseCircleLight'):setImageSource(IMAGES .. 'circle/light_white')
        end
    end, 520)
    scheduleEvent(function()
        if not portrait:isDestroyed() then
            setBars(portrait, 58, 55, 49, '57 15', '51 5', '52 5')
        end
    end, 600)
    resetCurrentPortrait()
end

-- text is the server's health label: "USE" for the summoned Pokemon, "FNT" when fainted, otherwise "NN%".
local function updatePortrait(portrait, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)
    local label = portraitLabels[portrait:getId()]
    if text == tr('USE') then
        expandPortrait(portrait, label)
        return
    elseif portrait == current.portrait then
        collapsePortrait(portrait, label)
    end

    local hp = portrait:getChildById('HPProgressBar')
    local icon = portrait:getChildById('portrait')
    if textColor == 0 then
        hp:setBackgroundColor('#00851B')
        icon:setColor(TextColors.white)
    elseif textColor == 1 then
        hp:setBackgroundColor('#8A8A00')
        icon:setColor(TextColors.white)
    elseif textColor == 2 then
        hp:setBackgroundColor('#850000')
        if text == 'FNT' then
            icon:setColor('#00000099')
        end
    else
        hp:setBackgroundColor('#FFFFFF')
        icon:setColor(TextColors.white)
    end

    label:setText(text)
    portrait:getChildById('levelLabel'):setText('Lv.' .. pokeLevel)
    local mp = portrait:getChildById('MPProgressBar')
    mp:setValue(pokeMana, 0, pokeMaxMana)
    mp:setTooltip(tr(manaTooltip, pokeMana, pokeMaxMana))
    hp:setTooltip(tr('Health') .. ' - ' .. text)
    local xp = portrait:getChildById('XPProgressBar')
    xp:setPercent(pokeExp)
    xp:setTooltip(tr(pokemonExperienceTooltip, pokeExp, pokeLevel + 1))

    if text == 'FNT' then
        hp:setPercent(0)
    else
        hp:setPercent(tonumber(text:match('^(%d+)')) or 0)
    end
end

local function hide()
    pokemonBar:hide()
end

local function show()
    pokemonBar:show()
end

local function beltItems()
    local items = {}
    for _, child in pairs(pokemonBar:getChildren()) do
        if child:getStyleName() == 'BeltItem' then
            table.insert(items, child)
        end
    end
    return items
end

local function resize()
    local items = beltItems()
    if orientation == ORIENTATIONS.HORIZONTAL then
        local width = pokemonBar:getPaddingLeft() + pokemonBar:getPaddingRight()
        if #items == 0 then
            width = width + 227
        end
        for _, item in ipairs(items) do
            width = width + item:getWidth() + 5
        end
        pokemonBar:resize(width, defaultHeight)
    else
        local height = pokemonBar:getPaddingTop() + pokemonBar:getPaddingBottom() + 5
        if #items == 0 then
            height = height + 227
        end
        for _, item in ipairs(items) do
            height = height + item:getHeight()
        end
        pokemonBar:resize(227, height)
    end
end

local function reallocatePortraits()
    local last
    for _, item in ipairs(beltItems()) do
        item:breakAnchors()
        if orientation == ORIENTATIONS.HORIZONTAL then
            if last then
                item:addAnchor(AnchorLeft, last:getId(), AnchorRight)
            else
                item:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            end
            item:addAnchor(AnchorTop, 'parent', AnchorTop)
            item:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
        else
            if last then
                item:addAnchor(AnchorTop, last:getId(), AnchorBottom)
            else
                item:addAnchor(AnchorTop, 'parent', AnchorTop)
            end
            item:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            item:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
        end
        last = item
    end
end

function switchOrientation()
    orientation = orientation == ORIENTATIONS.HORIZONTAL and ORIENTATIONS.VERTICAL or ORIENTATIONS.HORIZONTAL
    resize()
    reallocatePortraits()
end

local function removePortrait(portrait)
    local id = portrait:getId()
    if portrait == current.portrait then
        resetCurrentPortrait()
    end
    portraitLabels[id] = nil
    portrait:destroy()
end

local function reset()
    pokemonBar:destroyChildren()
    portraitLabels = {}
    resetCurrentPortrait()
end

local function findPortrait(fastcallNumber)
    local id = 'poke' .. fastcallNumber
    for _, item in ipairs(beltItems()) do
        if item:getId() == id then
            return item
        end
    end
end

function onPokemonBarAdd(itemId, fastcallNumber, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)
    local old = findPortrait(fastcallNumber)
    if old then
        removePortrait(old)
    end

    local item = g_ui.createWidget('BeltItem', pokemonBar)
    local name = getPokemonNameByIconItemId(itemId)
    local info = pokemonInfo(name)
    if not info then
        g_logger.warning(string.format('[PokeVerse] pokebar: no Pokemon for icon item %d (fastcall %d)', itemId, fastcallNumber))
    end

    item:setId('poke' .. fastcallNumber)
    if name ~= '' then
        item:getChildById('pokeImage'):setImageSource('/images/pokeicons/' .. name)
    end
    item.onMouseRelease = function(self, mousePosition, mouseButton)
        if mouseButton == MouseLeftButton and g_keyboard.isShiftPressed() then
            g_game.talkChannel(MessageModes.Say, 0, '/pd ' .. fastcallNumber)
            return true
        end
        g_game.talkChannel(MessageModes.Say, 0, '/cp ' .. fastcallNumber)
        return true
    end
    item:setTooltip(name)
    item:getChildById('pokeImage'):setTooltip(name)

    local type1 = item:getChildById('type1')
    local type2 = item:getChildById('type2')
    if info then
        type1:setImageSource(TYPE_IMAGES .. info.type1)
        type1:setTooltip(info.type1)
        if info.type2 ~= '' then
            type2:setImageSource(TYPE_IMAGES .. info.type2)
            type2:setTooltip(info.type2)
        end
        item:getChildById('PokeID'):setText(info.dexID)
    end

    local pokeName = item:getChildById('PokeName')
    local pokeShiny = item:getChildById('pokeShiny')
    local pokeGenderIcon = item:getChildById('pokeGender')
    if name:find('^Shiny ') then
        pokeName:setText(name:sub(7))
        pokeName:setColor('#e6960b')
        pokeShiny:show()
        pokeShiny:setTooltip(tr('Shiny Pokemon'))
    else
        pokeName:setText(name)
        pokeShiny:hide()
        pokeGenderIcon:setMarginLeft(-12)
    end

    if pokeGender == 2 then
        pokeGenderIcon:setImageSource('/images/game/skulls/skull_yellow')
        pokeGenderIcon:setTooltip(tr('Genderless'))
    elseif pokeGender == 1 then
        pokeGenderIcon:setImageSource('/images/game/skulls/skull_black')
        pokeGenderIcon:setTooltip(tr('Male'))
    elseif pokeGender == 0 then
        pokeGenderIcon:setImageSource('/images/game/skulls/skull_red')
        pokeGenderIcon:setTooltip(tr('Female'))
    end

    local label = item:getChildById('health')
    label:setId(item:getId() .. 'label')
    item:getChildById('levelLabel'):setText('Lv.' .. pokeLevel)

    portraitLabels[item:getId()] = label
    updatePortrait(item, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)

    resize()
    reallocatePortraits()
    show()
end

function onPokemonBarRemove(fastcallNumber)
    local portrait = findPortrait(fastcallNumber)
    if portrait then
        removePortrait(portrait)
    end
    resize()
    reallocatePortraits()
    show()
end

function onPokemonBarUpdate(fastcallNumber, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)
    local portrait = findPortrait(fastcallNumber)
    if portrait then
        updatePortrait(portrait, textColor, text, pokeLevel, pokeMaxMana, pokeMana, pokeGender, pokeExp)
    end
end

function toggle()
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

local function onOnline()
    hide()
    reset()
    resize()
end

local function onOffline()
    hide()
    reset()
end

local function onManaChange(localPlayer, mana, maxMana)
    if current.mana then
        current.mana:setValue(mana, 0, maxMana)
        current.mana:setTooltip(tr(manaTooltip, mana, maxMana))
    end
end

-- PokeVerse reports the active Pokemon's level and experience through the magic level fields.
local function onPokemonLevelChange(localPlayer, value, percent)
    if current.experience then
        current.experience:setTooltip(tr(pokemonExperienceTooltip, percent, value + 1))
        current.experience:setPercent(percent)
    end
end

local function onCreatureHealthPercentChange(creature, health)
    if creature:isLocalPlayerSummon() and current.label and current.life then
        local percent = creature:getHealthPercent()
        current.label:setText(percent .. '%')
        current.life:setPercent(percent)
        current.life:setBackgroundColor(getColorByHealthPercent(percent))
    end
end

function onPortraitHoverChange(widget)
    local hand = widget:getChildById('hand')
    if g_mouse.isPressed(MouseLeftButton) then
        return
    end
    if widget:isHovered() then
        addEvent(function() g_effects.fadeIn(hand, 250) end)
    else
        addEvent(function() g_effects.fadeOut(hand, 250) end)
    end
end

function init()
    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarOpen = onPokemonBarOpen,
        onPokemonBarClose = onPokemonBarClose
    })
    connect(LocalPlayer, {
        onManaChange = onManaChange,
        onMagicLevelChange = onPokemonLevelChange
    })
    connect(Creature, {
        onHealthPercentChange = onCreatureHealthPercentChange
    })

    pokemonBar = g_ui.loadUI('pokebar', modules.game_interface.getRootPanel())
    scheduleEvent(function()
        local p = g_settings.getPoint('pokebar-pos')
        if p and p.x > 0 and p.y > 0 then
            pokemonBar:breakAnchors()
            pokemonBar:setPosition(p)
        end
    end, 100)
    orientation = g_settings.getInteger('pokebar-orientation', ORIENTATIONS.HORIZONTAL)
    pokemonBar:hide()

    pokemonBar.onMouseRelease = function(self, mousePosition, mouseButton)
        if mouseButton == MouseRightButton then
            local menu = g_ui.createWidget('PopupMenu')
            menu:addOption(tr('Switch Orientation'), switchOrientation)
            menu:display(mousePosition)
            return true
        end
        return false
    end

    defaultHeight = pokemonBar:getHeight()

    if g_game.isOnline() then
        onOnline()
        local localPlayer = g_game.getLocalPlayer()
        onManaChange(localPlayer, localPlayer:getMana(), localPlayer:getMaxMana())
    end
end

function terminate()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarOpen = onPokemonBarOpen,
        onPokemonBarClose = onPokemonBarClose
    })
    disconnect(LocalPlayer, {
        onManaChange = onManaChange,
        onMagicLevelChange = onPokemonLevelChange
    })
    disconnect(Creature, {
        onHealthPercentChange = onCreatureHealthPercentChange
    })

    g_settings.set('pokebar-pos', pokemonBar:getPosition())
    g_settings.set('pokebar-orientation', orientation)

    pokemonBar:destroy()
    pokemonBar = nil
end
