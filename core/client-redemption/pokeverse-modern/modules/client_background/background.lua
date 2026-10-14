local background
local clientVersionLabel

function init()
    background = g_ui.displayUI('background')
    background:lower()

    clientVersionLabel = background:getChildById('clientVersionLabel')
    -- the NDK compiler string is a full toolchain URL, wider than a phone screen
    local compiler = g_platform.isMobile() and '' or g_app.getBuildCompiler() .. ' - '
    clientVersionLabel:setText(g_app.getName() .. ' ' .. g_app.getVersion() .. '\n' .. 'Rev  ' ..
                                   g_app.getBuildRevision() .. ' (' .. g_app.getBuildCommit() .. ')\n' .. 'Built on ' ..
                                   g_app.getBuildDate() .. '\n' .. compiler .. g_app.getBuildArch())

    if not g_game.isOnline() then
        addEvent(function()
            g_effects.fadeIn(clientVersionLabel, 1500)
        end)
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

    g_effects.cancelFade(clientVersionLabel)
    background:destroy()

    background = nil
    clientVersionLabel = nil
end

function hide()
    background:hide()
end

function show()
    background:show()
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
