-- Modern layout: open the legacy Pokedex window centred on the game window and above the
-- floating panels (the legacy code centres it on the whole display), with a button to the
-- species' Pokepedia entry (knowledge level, drops, spawn areas).
local legacyInit = onInit
local legacyTerminate = onTerminate
local legacyStatus = onPokedexStatus
local legacyUpdate = onPokedexUpdate

-- The legacy grid shows a face only once a species is registered (/dex on it, which gives
-- experience); a species that was only caught kept the "?". It shows its face too, and the
-- ball badge plus the tooltip say it still can be registered.
local CAUGHT_ONLY = { [2] = true, [3] = true, [7] = true }

local function faceItemId(number)
    if number <= 151 then
        return 11873 + number
    elseif number <= 251 then
        return 15647 + number
    elseif number <= 386 then
        return 26857 + number
    end
    return 28819 + number
end

local function showCaughtFace(item, status)
    local number = tonumber(item:getId())
    if not number then
        return
    end
    if CAUGHT_ONLY[status] then
        item:setItemId(faceItemId(number))
        item:setTooltip(tr('Caught, not registered yet: use your Pokedex on one for experience.'))
    else
        item:setTooltip('')
    end
end

function onPokedexStatus(status)
    legacyStatus(status)
    for _, item in ipairs(panel:getChildren()) do
        local number = tonumber(item:getId())
        if number and status[number] then
            showCaughtFace(item, status[number])
        end
    end
end

function onPokedexUpdate(pokemonNumber, status)
    legacyUpdate(pokemonNumber, status)
    for _, item in ipairs(panel:getChildren()) do
        if tonumber(item:getId()) == pokemonNumber then
            showCaughtFace(item, status)
            break
        end
    end
end
local shownNumber
local pokepediaButton
local voiceCryButton

-- Blue RGB dot on /images/ui/dex.png (754x429), rightmost of the three painted buttons.
local CRY_BUTTON = { left = 55, top = 107, size = 22 }

local function bringToFront()
    addEvent(function()
        if not pokedexWindow or not pokedexWindow:isVisible() then
            return
        end
        local root = modules.game_interface.getRootPanel()
        if not pokedexWindow.placed then
            pokedexWindow:setPosition({
                x = root:getX() + math.max(0, math.floor((root:getWidth() - pokedexWindow:getWidth()) / 2)),
                y = root:getY() + math.max(0, math.floor((root:getHeight() - pokedexWindow:getHeight()) / 2))
            })
            pokedexWindow.placed = true
        end
        pokedexWindow:bindRectToParent()
        pokedexWindow:raise()
        if voiceCryButton then
            voiceCryButton:raise()
        end
    end)
end

local function setShown(number)
    shownNumber = tonumber(number)
    local known = shownNumber ~= nil
    if pokepediaButton then
        pokepediaButton:setVisible(known and modules.game_pokepedia ~= nil)
    end
    if voiceCryButton then
        voiceCryButton:setVisible(known)
    end
end

local function onInfo(pokemonId)
    setShown(pokemonId)
    bringToFront()
end

local function createPokepediaButton()
    local content = pokedexWindow and pokedexWindow:recursiveGetChildById('dexContent')
    if not content then
        return
    end
    pokepediaButton = g_ui.createWidget('Button', content)
    pokepediaButton:setId('pokepediaButton')
    pokepediaButton:setText(tr('Pokepedia'))
    pokepediaButton:setTooltip(tr('What you know about it: drops, how hard it is to catch and where it spawns'))
    pokepediaButton:setWidth(80)
    pokepediaButton:addAnchor(AnchorTop, 'parent', AnchorTop)
    pokepediaButton:addAnchor(AnchorRight, 'parent', AnchorRight)
    pokepediaButton:setMarginRight(6)
    pokepediaButton:hide()
    pokepediaButton.onClick = function()
        if shownNumber and modules.game_pokepedia then
            modules.game_pokepedia.DexTab.open(shownNumber)
        end
    end
end

local function createVoiceCryButton()
    if not pokedexWindow then
        return
    end
    voiceCryButton = g_ui.createWidget('UIWidget', pokedexWindow)
    voiceCryButton:setId('voiceCryButton')
    voiceCryButton:setSize({ width = CRY_BUTTON.size, height = CRY_BUTTON.size })
    voiceCryButton:addAnchor(AnchorTop, 'parent', AnchorTop)
    voiceCryButton:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    voiceCryButton:setMarginTop(CRY_BUTTON.top)
    voiceCryButton:setMarginLeft(CRY_BUTTON.left)
    voiceCryButton:setTooltip(tr('Play cry'))
    voiceCryButton:setFocusable(false)
    voiceCryButton:hide()
    voiceCryButton:raise()
    voiceCryButton.onClick = function()
        if shownNumber and modules.game_sounds and modules.game_sounds.playVoiceCry then
            modules.game_sounds.playVoiceCry(shownNumber)
        end
    end
end

function onInit()
    legacyInit()
    createPokepediaButton()
    createVoiceCryButton()
    local previousUnknown = onPokedexInfoUnknown
    function onPokedexInfoUnknown(...)
        setShown(nil)
        return previousUnknown(...)
    end
    connect(g_game, { onPokedexOpen = bringToFront, onPokedexInfo = onInfo })
end

function onTerminate()
    disconnect(g_game, { onPokedexOpen = bringToFront, onPokedexInfo = onInfo })
    if pokepediaButton then
        pokepediaButton:destroy()
        pokepediaButton = nil
    end
    if voiceCryButton then
        voiceCryButton:destroy()
        voiceCryButton = nil
    end
    legacyTerminate()
end
