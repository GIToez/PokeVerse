-- Modern layout: open the legacy Pokedex window centred on the game window and above the
-- floating panels (the legacy code centres it on the whole display), with a button to the
-- species' Pokepedia entry (knowledge level, drops, spawn areas).
local legacyInit = onInit
local legacyTerminate = onTerminate
local shownNumber
local pokepediaButton

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
    end)
end

local function onInfo(pokemonId)
    shownNumber = tonumber(pokemonId)
    if pokepediaButton then
        pokepediaButton:setVisible(shownNumber ~= nil and modules.game_pokepedia ~= nil)
    end
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

function onInit()
    legacyInit()
    createPokepediaButton()
    connect(g_game, { onPokedexOpen = bringToFront, onPokedexInfo = onInfo })
end

function onTerminate()
    disconnect(g_game, { onPokedexOpen = bringToFront, onPokedexInfo = onInfo })
    if pokepediaButton then
        pokepediaButton:destroy()
        pokepediaButton = nil
    end
    legacyTerminate()
end
