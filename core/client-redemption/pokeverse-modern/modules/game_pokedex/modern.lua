-- Modern layout: open the legacy Pokedex window centred on the game window and above the
-- floating panels (the legacy code centres it on the whole display).
local legacyInit = onInit
local legacyTerminate = onTerminate

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

function onInit()
    legacyInit()
    connect(g_game, { onPokedexOpen = bringToFront, onPokedexInfo = bringToFront })
end

function onTerminate()
    disconnect(g_game, { onPokedexOpen = bringToFront, onPokedexInfo = bringToFront })
    legacyTerminate()
end
