-- Customise Trainer and Pokemon Outfit, the outfit windows in Pokegear style.
-- Customise Trainer takes over the outfit window (the server's 0xC8, game_outfit in Classic) while the
-- Pokegear layout is on: outfits, addons and the four colours. Pokemon Outfit is in both layouts: the
-- server (systems/038-pokemonAddon.lua, ExtendedIds.PokemonOutfit) sends the outfits the Pokemon out
-- owns and the ones it could still get, and takes back only the chosen look type.
local COLOR_COUNT = 133 -- 19 columns of 7: the outfit colours the engine knows (getOutfitColor)
local PARTS = { 'head', 'body', 'legs', 'feet' }
local FULL_LIST_HEIGHT, COMPACT_LIST_HEIGHT = 166, 84

local trainer, pokemon
local hooked = false

OutfitWindow = {}

local function send(message)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.PokemonOutfit, message)
    end
end

local function dragByHeader(window)
    local header = window.header
    header.onDragEnter = function(widget, mousePos)
        local pos = window:getPosition()
        widget.dragOffset = { x = mousePos.x - pos.x, y = mousePos.y - pos.y }
        window:breakAnchors()
        return true
    end
    header.onDragMove = function(widget, mousePos)
        local root = g_ui.getRootWidget()
        window:setPosition({
            x = math.max(0, math.min(mousePos.x - widget.dragOffset.x, root:getWidth() - window:getWidth())),
            y = math.max(0, math.min(mousePos.y - widget.dragOffset.y, root:getHeight() - window:getHeight())) })
        return true
    end
    header.onDragLeave = function()
        return true
    end
end

local function makeWindow(style, close, save)
    local window = g_ui.createWidget(style, g_ui.getRootWidget())
    dragByHeader(window)
    window.header.close.onClick = close
    window.footer.cancel.onClick = close
    window.footer.save.onClick = save
    window.onKeyDown = function(_, keyCode)
        if keyCode == KeyEscape then
            close()
            return true
        elseif keyCode == KeyEnter or keyCode == KeyReturn then
            save()
            return true
        end
        return false
    end
    window:raise()
    window:focus()
    return window
end

local function turn(stage, step)
    local creature = stage.creature:getCreature()
    if creature then
        creature:setDirection((creature:getDirection() + step) % 4)
    end
end

local function setupStage(stage)
    stage.left.onClick = function() turn(stage, 1) end
    stage.right.onClick = function() turn(stage, -1) end
end

local function showOnStage(stage, outfit)
    local creature = stage.creature:getCreature()
    local direction = creature and creature:getDirection() or Directions.South
    stage.creature:setOutfit(outfit)
    creature = stage.creature:getCreature()
    if creature then
        creature:setDirection(direction)
    end
end

local function selectTile(list, tile)
    for _, child in ipairs(list:getChildren()) do
        child:setOn(child == tile)
    end
    if tile then
        list:ensureChildVisible(tile)
    end
end

-- Customise Trainer ---------------------------------------------------------------------------

local trainerState

local function closeTrainer()
    if trainer then
        trainer:destroy()
        trainer = nil
    end
    trainerState = nil
end

local function trainerOutfit(lookType)
    local o = trainerState.outfit
    return { type = lookType or o.type, head = o.head, body = o.body, legs = o.legs, feet = o.feet,
             addons = lookType and 0 or o.addons }
end

local function hasAddon(addons, which)
    return math.floor((addons or 0) / which) % 2 == 1
end

local function availableAddons()
    for _, entry in ipairs(trainerState.list) do
        if entry[1] == trainerState.outfit.type then
            return entry[3] or 0
        end
    end
    return 0
end

local function refreshTrainer()
    local window, o = trainer, trainerState.outfit
    local available = availableAddons()
    o.addons = (hasAddon(o.addons, 1) and hasAddon(available, 1) and 1 or 0)
        + (hasAddon(o.addons, 2) and hasAddon(available, 2) and 2 or 0)
    showOnStage(window.stage, trainerOutfit())
    window.addons.addon1:setVisible(hasAddon(available, 1))
    window.addons.addon2:setVisible(hasAddon(available, 2))
    window.addons.addon1:setOn(hasAddon(o.addons, 1))
    window.addons.addon2:setOn(hasAddon(o.addons, 2))
    window.addons:setVisible(available ~= 0)
    window.noAddons:setVisible(available == 0)
    for _, part in ipairs(PARTS) do
        window.parts[part]:setOn(part == trainerState.part)
    end
    local chosen = o[trainerState.part]
    for _, swatch in ipairs(window.palette:getChildren()) do
        swatch:setOn(swatch.colorId == chosen)
    end
    for _, tile in ipairs(window.list:getChildren()) do
        tile.creature:setOutfit(trainerOutfit(tile.lookType))
        if tile.lookType == o.type then
            Pokegear.fitText(window.stage.name, tile.fullName)
        end
    end
end

local function chooseTrainerOutfit(tile)
    trainerState.outfit.type = tile.lookType
    selectTile(trainer.list, tile)
    refreshTrainer()
end

local function saveTrainer()
    if trainerState then
        g_game.changeOutfit(trainerOutfit())
    end
    closeTrainer()
end

local function openTrainer(creature, outfitList)
    closeTrainer()
    local current = creature:getOutfit()
    trainerState = { outfit = table.copy(current), list = outfitList or {}, part = 'head' }
    trainer = makeWindow('PokegearTrainerOutfit', closeTrainer, saveTrainer)
    local window = trainer
    window.header.title:setText(tr('Customise Trainer'))
    setupStage(window.stage)
    window.outfitsLabel:setText(tr('Outfits (%d)', #trainerState.list))
    if modules.game_warpfx and modules.game_warpfx.openWindow then
        local warp = g_ui.createWidget('PokegearSocialAction', window.footer)
        warp:setText(tr('Warp Styles'))
        warp:setTooltip(tr('How you appear, vanish, win, lose and faint'))
        warp:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        warp:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
        warp.onClick = function()
            closeTrainer()
            modules.game_warpfx.openWindow()
        end
    end
    if Pokegear.isCompact() then
        window.list:setHeight(COMPACT_LIST_HEIGHT)
        window:setHeight(window:getHeight() - (FULL_LIST_HEIGHT - COMPACT_LIST_HEIGHT))
    end

    local selected
    for _, entry in ipairs(trainerState.list) do
        local tile = g_ui.createWidget('PokegearOutfitTile', window.list)
        tile.lookType = entry[1]
        tile.fullName = entry[2] ~= '' and entry[2] or tr('Outfit')
        Pokegear.fitText(tile.name, tile.fullName)
        tile:setTooltip(tile.fullName)
        tile.creature:setCreatureSize(52)
        tile.creature:setCenter(true)
        tile.onClick = chooseTrainerOutfit
        if entry[1] == current.type then
            selected = tile
        end
    end

    for id = 0, COLOR_COUNT - 1 do
        local swatch = g_ui.createWidget('PokegearOutfitSwatch', window.palette)
        swatch.colorId = id
        swatch:setBackgroundColor(getOutfitColor(id))
        swatch.onClick = function()
            trainerState.outfit[trainerState.part] = id
            refreshTrainer()
        end
    end
    for _, part in ipairs(PARTS) do
        window.parts[part].onClick = function()
            trainerState.part = part
            refreshTrainer()
        end
    end
    for bitValue, id in ipairs({ 'addon1', 'addon2' }) do
        window.addons[id].onClick = function()
            local addons = trainerState.outfit.addons or 0
            trainerState.outfit.addons = hasAddon(addons, bitValue) and addons - bitValue or addons + bitValue
            refreshTrainer()
        end
    end
    window.random.onClick = function()
        for _, part in ipairs(PARTS) do
            trainerState.outfit[part] = math.random(0, COLOR_COUNT - 1)
        end
        refreshTrainer()
    end

    if selected then
        selectTile(window.list, selected)
    end
    refreshTrainer()
end

local function onOpenOutfitWindow(creature, outfitList)
    openTrainer(creature, outfitList)
end

-- the stock window comes back with the Classic layout
function OutfitWindow.apply(on)
    if on == hooked then
        return
    end
    local stock = modules.game_outfit
    if on then
        if stock and stock.create then
            disconnect(g_game, { onOpenOutfitWindow = stock.create })
            if stock.destroy then
                stock.destroy()
            end
        end
        connect(g_game, { onOpenOutfitWindow = onOpenOutfitWindow })
    else
        disconnect(g_game, { onOpenOutfitWindow = onOpenOutfitWindow })
        if stock and stock.create then
            connect(g_game, { onOpenOutfitWindow = stock.create })
        end
        closeTrainer()
    end
    hooked = on
end

-- Pokemon Outfit ------------------------------------------------------------------------------

local pokemonState

local function closePokemon()
    if pokemon then
        pokemon:destroy()
        pokemon = nil
    end
    pokemonState = nil
end

local function choosePokemonOutfit(tile)
    if tile.locked then
        return
    end
    pokemonState.chosen = tile.lookType
    selectTile(pokemon.list, tile)
    showOnStage(pokemon.stage, { type = tile.lookType })
    Pokegear.fitText(pokemon.stage.name, tile.fullName)
end

local function savePokemon()
    if pokemonState and pokemonState.chosen ~= pokemonState.current then
        send({ action = 'choose', lookType = pokemonState.chosen })
    end
    closePokemon()
end

local function addPokemonTile(entry, locked)
    local lookType = tonumber(entry.lookType)
    if not lookType then
        return nil
    end
    local tile = g_ui.createWidget('PokegearOutfitTile', pokemon.list)
    tile.lookType = lookType
    tile.locked = locked
    tile.fullName = tostring(entry.name or '')
    tile.creature:setCreatureSize(52)
    tile.creature:setCenter(true)
    tile.creature:setOutfit({ type = lookType })
    Pokegear.fitText(tile.name, tile.fullName)
    tile.onClick = choosePokemonOutfit
    if locked then
        tile.lock:show()
        tile:setOpacity(0.45)
        tile:setTooltip(tr('%s: not owned yet', tile.fullName))
    else
        tile:setTooltip(tile.fullName)
    end
    return tile
end

local function openPokemon(message)
    closePokemon()
    local current = tonumber(message.current)
    pokemonState = { current = current, chosen = current }
    pokemon = makeWindow('PokegearPokemonOutfit', closePokemon, savePokemon)
    local name = tostring(message.name or '')
    pokemon.header.title:setText(name ~= '' and tr("%s's Outfit", name) or tr('Pokemon Outfit'))
    setupStage(pokemon.stage)

    local selected, owned, locked = nil, 0, 0
    for _, entry in ipairs(type(message.outfits) == 'table' and message.outfits or {}) do
        local tile = addPokemonTile(entry, false)
        if tile then
            owned = owned + 1
            if tile.lookType == current or not selected then
                selected = tile
            end
        end
    end
    for _, entry in ipairs(type(message.locked) == 'table' and message.locked or {}) do
        if addPokemonTile(entry, true) then
            locked = locked + 1
        end
    end
    pokemon.outfitsLabel:setText(locked > 0 and tr('Outfits (%d of %d)', owned, owned + locked)
        or tr('Outfits (%d)', owned))
    if selected then
        choosePokemonOutfit(selected)
    end
end

local function onPokemonOutfitMessage(protocol, opcode, buffer)
    local ok, message = pcall(json.decode, buffer)
    if not ok or type(message) ~= 'table' then
        return
    end
    if message.type == 'window' then
        openPokemon(message)
    end
end

-- The Pokemon out's outfits (the "Set Outfit" option on it, and /addon)
function OutfitWindow.openPokemon()
    send({ action = 'open' })
end

local function onGameStart()
    send({ action = 'hello' })
end

local function onGameEnd()
    closeTrainer()
    closePokemon()
end

function OutfitWindow.init()
    g_ui.importStyle('outfit')
    ProtocolGame.registerExtendedOpcode(ExtendedIds.PokemonOutfit, onPokemonOutfitMessage)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function OutfitWindow.terminate()
    OutfitWindow.apply(false)
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.PokemonOutfit)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    onGameEnd()
end
