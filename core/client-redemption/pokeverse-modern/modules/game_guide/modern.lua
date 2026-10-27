-- Modern layout: the map panel runs under the side column and the chat, so the guide's corners of
-- the map panel are hidden. Professor Oak's balloon sits on top of the chat and the guide picture
-- left of the side column, above the Pokemon moves bar, both drawn over the map.
local legacyInit = onInit
local legacyTerminate = onTerminate
local legacyImage = onGameplayTutorialImage

local POKEBAR_WIDTH = 70
local MOVES_BAR_SPACE = 100
local CHAT_MOVES_BAR_SPACE = 48
-- Red at 1.7x the legacy 137x142; the art is 502x552, so it stays sharp
local RED_SIZE = { width = 233, height = 256 }
local BALLOON_OVERLAP = 24
-- Red and the picture are drawn at full size on a 1920x1080 window and shrink with it, down to MIN_SCALE
local REFERENCE = { width = 1920, height = 1080 }
local MIN_SCALE = 0.5
-- the picture never takes more than this share of the map panel's width or height
local PICTURE_MAX_SHARE = 0.3

local balloon, picture

local function scale()
    local s = math.min(rootWidget:getWidth() / REFERENCE.width, rootWidget:getHeight() / REFERENCE.height)
    return math.max(MIN_SCALE, math.min(1, s))
end

local function fitBalloon()
    local s = scale()
    local red = { width = math.floor(RED_SIZE.width * s), height = math.floor(RED_SIZE.height * s) }
    local bubble = balloon:getChildById('balloon')
    balloon:getChildById('character'):setSize(red)
    balloon:setSize({ width = red.width + bubble:getWidth() - BALLOON_OVERLAP,
        height = math.max(red.height + 8, bubble:getHeight()) })
end

local function fitPicture()
    local width, height = picture:getImageTextureWidth(), picture:getImageTextureHeight()
    if width == 0 or height == 0 then
        return
    end
    local map = modules.game_interface.getMapPanel()
    local s = math.min(scale(), map:getWidth() * PICTURE_MAX_SHARE / width,
        map:getHeight() * PICTURE_MAX_SHARE / height)
    picture:setSize({ width = math.floor(width * s), height = math.floor(height * s) })

    -- on a narrow window the chat reaches under the picture, so it moves up above the chat and the moves bar
    local side = modules.game_interface.getRootPanel():recursiveGetChildById('gameMainRightPanel')
    local chat = modules.game_interface.getBottomPanel()
    local left = (side and side:getX() or map:getX() + map:getWidth()) - 4 - picture:getWidth()
    local overChat = chat and chat:isVisible() and chat:getX() + chat:getWidth() > left
    picture:removeAnchor(AnchorBottom)
    if overChat then
        picture:addAnchor(AnchorBottom, 'gameBottomPanel', AnchorTop)
        picture:setMarginBottom(CHAT_MOVES_BAR_SPACE)
    else
        picture:addAnchor(AnchorBottom, 'gameMapPanel', AnchorBottom)
        picture:setMarginBottom(MOVES_BAR_SPACE)
    end
end

local function fit()
    if balloon then
        fitBalloon()
    end
    if picture then
        fitPicture()
    end
end

local function onImage(protocol, opcode, buffer)
    legacyImage(protocol, opcode, buffer)
    if picture then
        fitPicture()
    end
end

function onInit()
    legacyInit()

    local mapPanel = modules.game_interface.getMapPanel()
    local root = modules.game_interface.getRootPanel()
    balloon = mapPanel:getChildById('playtutorial')
    picture = mapPanel:getChildById('image')

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
        picture:setMarginRight(4)
        picture:setPhantom(true)
        picture:setImageAutoResize(false)

        -- the picture stays click-through; only the button takes the click. Closed, it stays hidden until
        -- the server sends a different picture
        local close = g_ui.createWidget('PVCloseButton', picture)
        close:addAnchor(AnchorTop, 'parent', AnchorTop)
        close:addAnchor(AnchorRight, 'parent', AnchorRight)
        close:setMargin(4)
        close.onClick = function()
            picture:setVisible(false)
        end

        ProtocolGame.unregisterExtendedOpcode(ExtendedIds.GameplayTutorialImage)
        ProtocolGame.registerExtendedOpcode(ExtendedIds.GameplayTutorialImage, onImage)
    end

    fit()
    connect(rootWidget, { onGeometryChange = fit })
    connect(modules.game_interface.getBottomPanel(), { onGeometryChange = fit })
end

function onTerminate()
    disconnect(rootWidget, { onGeometryChange = fit })
    disconnect(modules.game_interface.getBottomPanel(), { onGeometryChange = fit })
    legacyTerminate()
end
