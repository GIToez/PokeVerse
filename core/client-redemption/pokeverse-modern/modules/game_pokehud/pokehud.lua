local IMAGES = '/modules/game_pokehud/images/'
local PARTY_SIZE = 6
local DOLLAR_ICON = 3035
local SOUL_COIN_ICON = 6499

local hud
local party = {}
local summon
local summonEvent

local function resizeFill(track)
    local width = math.floor((track:getWidth() * (track.percent or 0)) / 100)
    track.fill:setVisible(width > 0)
    track.fill:setWidth(math.max(width, 8))
end

local function setBar(track, percent, fillImage, text, tooltip)
    track.percent = math.max(0, math.min(100, percent))
    track.fill:setImageSource(IMAGES .. fillImage)
    track.text:setText(text or '')
    track:setTooltip(tooltip)
    resizeFill(track)
end

local function formatNumber(value)
    local text = tostring(math.floor(value))
    while true do
        local changed
        text, changed = text:gsub('^(-?%d+)(%d%d%d)', '%1,%2')
        if changed == 0 then
            return text
        end
    end
end

local function setCoin(widget, itemId, text)
    widget.icon:setItemId(itemId)
    widget.amount:setText(text)
    widget:setWidth(widget:getPaddingLeft() + widget.icon:getWidth() + widget.amount:getMarginLeft() +
                        widget.amount:getWidth() + widget:getPaddingRight())
end

local function onWalletChange(total)
    if not hud then
        return
    end
    setCoin(hud.coins.soulCoins, SOUL_COIN_ICON, formatNumber(total.soulCoins))
    setCoin(hud.coins.dollars, DOLLAR_ICON, '$' .. formatNumber(total.dollars))
end

local function onHealthChange(player, health, maxHealth)
    local percent = maxHealth > 0 and math.floor(health * 100 / maxHealth) or 0
    setBar(hud.mainPanel.health, percent, 'fill-health', percent .. '%',
           tr('Your character health is %d out of %d.', health, maxHealth))
end

local function onLevelChange(player, level, percent)
    hud.experiencePanel.level:setText(tr('Lv.') .. ' ' .. level)
    hud.experiencePanel.experienceText:setText(percent .. '% ' .. tr('XP'))
    setBar(hud.experiencePanel.experience, percent, 'fill-experience', nil,
           tr('You have %d%% to advance to level %d.', percent, level + 1))
end

local function onOutfitChange(creature, outfit)
    if creature:isLocalPlayer() then
        hud.portrait.creature:setOutfit(outfit)
    end
end

local function onStatesChange(player, now, old)
    local conditions = hud.conditions
    conditions:destroyChildren()
    Player.iterateChangedStates(now, 0, function(bit)
        local icon = Icons[bit]
        if icon then
            local widget = g_ui.createWidget('UIWidget', conditions)
            widget:setSize({ width = 12, height = 12 })
            widget:setImageSource('/images/game/states/player-state-flags')
            widget:setImageClip(((icon.clip - 1) * 9) .. ' 0 9 9')
            widget:setImageSize({ width = 9, height = 9 })
            widget:setTooltip(icon.tooltipBar or icon.tooltip)
        end
    end)
end

local function updateSummon()
    local panel = hud.mainPanel
    if summon and summon:getHealthPercent() > 0 then
        local percent = summon:getHealthPercent()
        panel.pokemonName:setText(summon:getName())
        panel.pokemonName:setColor('#e8ecec')
        panel.pokemonHealth:setVisible(true)
        setBar(panel.pokemonHealth, percent, 'fill-pokemon', percent .. '%',
               tr('%s health is %d%%.', summon:getName(), percent))
    else
        panel.pokemonName:setText(tr('No Pokemon out'))
        panel.pokemonName:setColor('#8a9696')
        panel.pokemonHealth:setVisible(false)
    end
end

local function onCreatureAppear(creature)
    if creature:isLocalPlayerSummon() then
        summon = creature
        updateSummon()
    end
end

local function onCreatureDisappear(creature)
    if summon and creature:getId() == summon:getId() then
        summon = nil
        updateSummon()
    end
end

local function onCreatureHealthPercentChange(creature)
    if summon and creature:getId() == summon:getId() then
        updateSummon()
    end
end

local function pokemonName(itemId)
    if type(getPokemonNameByIconItemId) == 'function' then
        return getPokemonNameByIconItemId(itemId)
    end
    return ''
end

local function updateParty()
    local numbers = {}
    for number in pairs(party) do
        numbers[#numbers + 1] = number
    end
    table.sort(numbers)

    for i = 1, PARTY_SIZE do
        local ball = hud.party:getChildByIndex(i)
        local number = numbers[i]
        local pokemon = number and party[number]
        ball:setSize({ width = 14, height = 14 })
        if not pokemon then
            ball:setImageSource(IMAGES .. 'ball-empty')
            ball:setTooltip(nil)
        else
            local fainted = pokemon.text == 'FNT'
            ball:setImageSource(IMAGES .. (fainted and 'ball-fainted' or 'ball'))
            if pokemon.active then
                ball:setSize({ width = 16, height = 16 })
            end
            local name = pokemonName(pokemon.itemId)
            ball:setTooltip(pokemon.active and tr('%s (out)', name) or
                            (pokemon.text ~= '' and (name .. ' - ' .. pokemon.text) or name))
        end
    end
end

local function setPokemonText(pokemon, text)
    -- "USE" only marks the Pokemon that is out; it is not its health
    if text == tr('USE') then
        for _, other in pairs(party) do
            other.active = false
        end
        pokemon.active = true
    else
        pokemon.active = false
        pokemon.text = text
    end
end

local function onPokemonBarAdd(itemId, number, textColor, text)
    party[number] = { itemId = itemId, text = '' }
    setPokemonText(party[number], text)
    updateParty()
end

local function onPokemonBarRemove(number)
    party[number] = nil
    updateParty()
end

local function onPokemonBarUpdate(number, textColor, text)
    if party[number] then
        setPokemonText(party[number], text)
        updateParty()
    end
end

local function onPokemonBarClose()
    party = {}
    updateParty()
end

local function refresh()
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end
    hud.mainPanel.trainerName:setText(player:getName())
    hud.portrait.creature:setOutfit(player:getOutfit())
    onHealthChange(player, player:getHealth(), player:getMaxHealth())
    onLevelChange(player, player:getLevel(), player:getLevelPercent())
    onStatesChange(player, player:getStates(), 0)
    updateSummon()
    updateParty()
    onWalletChange(Wallet.get())
end

-- the server renames a Pokemon (its level) without the client seeing it appear again
local function findSummon()
    local player = g_game.getLocalPlayer()
    summon = nil
    if player then
        for _, creature in pairs(g_map.getSpectators(player:getPosition(), false)) do
            if creature:isLocalPlayerSummon() then
                summon = creature
                break
            end
        end
    end
    updateSummon()
end

local function onGameStart()
    party = {}
    summon = nil
    hud:show()
    refresh()
    removeEvent(summonEvent)
    summonEvent = cycleEvent(findSummon, 1000)
end

local function onGameEnd()
    removeEvent(summonEvent)
    summonEvent = nil
    hud:hide()
    party = {}
    summon = nil
end

function init()
    hud = g_ui.loadUI('pokehud', modules.game_interface.getRootPanel())
    hud:addAnchor(AnchorTop, 'gameMapPanel', AnchorTop)
    hud:addAnchor(AnchorHorizontalCenter, 'gameMapPanel', AnchorHorizontalCenter)
    hud:setMarginTop(4)
    for _, track in ipairs({ hud.experiencePanel.experience, hud.mainPanel.health, hud.mainPanel.pokemonHealth }) do
        track.onGeometryChange = resizeFill
    end
    for i = 1, PARTY_SIZE do
        local ball = g_ui.createWidget('HudBall', hud.party)
        if i == 1 then
            ball:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        else
            ball:addAnchor(AnchorLeft, 'prev', AnchorRight)
        end
        ball:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
    end

    connect(LocalPlayer, {
        onHealthChange = onHealthChange,
        onLevelChange = onLevelChange,
        onStatesChange = onStatesChange
    })
    connect(Creature, {
        onAppear = onCreatureAppear,
        onDisappear = onCreatureDisappear,
        onHealthPercentChange = onCreatureHealthPercentChange,
        onOutfitChange = onOutfitChange
    })
    connect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = onGameEnd,
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarClose = onPokemonBarClose
    })
    Wallet.init(onWalletChange)

    hud:hide()
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    disconnect(LocalPlayer, {
        onHealthChange = onHealthChange,
        onLevelChange = onLevelChange,
        onStatesChange = onStatesChange
    })
    disconnect(Creature, {
        onAppear = onCreatureAppear,
        onDisappear = onCreatureDisappear,
        onHealthPercentChange = onCreatureHealthPercentChange,
        onOutfitChange = onOutfitChange
    })
    disconnect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = onGameEnd,
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarClose = onPokemonBarClose
    })
    Wallet.terminate()
    removeEvent(summonEvent)
    hud:destroy()
    hud = nil
end
