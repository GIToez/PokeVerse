-- Modern layout: the map panel runs under the side column and the chat, so the guide's corners of
-- the map panel are hidden. Professor Oak's balloon sits on top of the chat and the guide picture
-- left of the side column, above the Pokemon moves bar, both drawn over the map.
local legacyInit = onInit

local POKEBAR_WIDTH = 70
local MOVES_BAR_SPACE = 100

function onInit()
    legacyInit()

    local mapPanel = modules.game_interface.getMapPanel()
    local root = modules.game_interface.getRootPanel()
    local balloon = mapPanel:getChildById('playtutorial')
    local picture = mapPanel:getChildById('image')

    if balloon then
        balloon:setParent(root)
        balloon:breakAnchors()
        balloon:addAnchor(AnchorLeft, 'gameMapPanel', AnchorLeft)
        balloon:addAnchor(AnchorBottom, 'gameBottomPanel', AnchorTop)
        balloon:setMarginLeft(POKEBAR_WIDTH)
        balloon:setMarginBottom(4)
        balloon:setPhantom(true)
    end

    if picture then
        picture:setParent(root)
        picture:breakAnchors()
        picture:addAnchor(AnchorRight, 'gameMainRightPanel', AnchorLeft)
        picture:addAnchor(AnchorBottom, 'gameMapPanel', AnchorBottom)
        picture:setMarginRight(4)
        picture:setMarginBottom(MOVES_BAR_SPACE)
        picture:setPhantom(true)
    end
end
