local background
local clientVersionLabel
local logo
local bobEvent

local LOGO_RATIO = 640 / 261
local BOB_PERIOD = 3200 -- ms
local BOB_HEIGHT = 5 -- px

local function layoutLogo()
    if not logo then
        return
    end
    local height = math.max(110, math.min(261, math.floor(background:getHeight() * 0.17)))
    logo:setSize({ width = math.floor(height * LOGO_RATIO), height = height })
end

local function logoTop()
    return math.floor(background:getHeight() * 0.03)
end

local function bob()
    if not logo then
        return
    end
    local phase = (g_clock.millis() % BOB_PERIOD) / BOB_PERIOD
    logo:setMarginTop(logoTop() + math.floor(math.sin(phase * 2 * math.pi) * BOB_HEIGHT + 0.5))
end

local function startBob()
    if not bobEvent then
        bobEvent = cycleEvent(bob, 50)
    end
end

local function stopBob()
    if bobEvent then
        removeEvent(bobEvent)
        bobEvent = nil
    end
end

function init()
    background = g_ui.displayUI('background')
    background:lower()

    logo = background:getChildById('logo')
    clientVersionLabel = background:getChildById('clientVersionLabel')
    -- the NDK compiler string is a full toolchain URL, wider than a phone screen
    local compiler = g_platform.isMobile() and '' or g_app.getBuildCompiler() .. ' - '
    clientVersionLabel:setText(g_app.getName() .. ' ' .. g_app.getVersion() .. '\n' .. 'Rev  ' ..
                                   g_app.getBuildRevision() .. ' (' .. g_app.getBuildCommit() .. ')\n' .. 'Built on ' ..
                                   g_app.getBuildDate() .. '\n' .. compiler .. g_app.getBuildArch())

    connect(background, { onGeometryChange = layoutLogo })
    layoutLogo()

    if not g_game.isOnline() then
        addEvent(function()
            g_effects.fadeIn(clientVersionLabel, 1500)
            g_effects.fadeIn(logo, 1200)
        end)
        startBob()
    end

    connect(g_game, {
        onGameStart = hide,
        onGameEnd = show
    })
end

function terminate()
    disconnect(g_game, {
        onGameStart = hide,
        onGameEnd = show
    })
    stopBob()

    g_effects.cancelFade(clientVersionLabel)
    g_effects.cancelFade(logo)
    background:destroy()

    background = nil
    clientVersionLabel = nil
    logo = nil
end

function hide()
    background:hide()
    stopBob()
end

function show()
    background:show()
    startBob()
end

function hideVersionLabel()
    clientVersionLabel:hide()
end

function setVersionText(text)
    clientVersionLabel:setText(text)
end

function getBackground()
    return background
end
