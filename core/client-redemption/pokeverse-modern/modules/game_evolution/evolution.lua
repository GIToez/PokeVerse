-- The server sends {state = "start", from, to, fromLook, toLook, duration} when an evolution
-- begins and {state = "done"} when the new Pokemon is out (doPokemonEvolve).
local SILHOUETTE_SHADER = 'Outfit - Evolution Silhouette'
local INTRO_MS = 1200      -- the Pokemon as it is, before the light starts
local REVEAL_BEFORE_MS = 1300 -- the new form shows this long before the server is done
local SWAP_FIRST_MS = 520  -- the two silhouettes swap slowly at first...
local SWAP_LAST_MS = 60    -- ...and as fast as this right before the reveal
local LINGER_MS = 2600     -- the result stays up this long after "done"
local FADE_STEP_MS = 30

local scene
local events = {}
local fromLook, toLook

local function schedule(fn, delay)
    local event
    event = scheduleEvent(function()
        table.removevalue(events, event)
        fn()
    end, delay)
    table.insert(events, event)
end

local function cancelEvents()
    for _, event in ipairs(events) do
        removeEvent(event)
    end
    events = {}
end

local function fade(widget, from, to, ms, onDone)
    local steps = math.max(1, math.floor(ms / FADE_STEP_MS))
    for step = 1, steps do
        schedule(function()
            if widget and not widget:isDestroyed() then
                widget:setOpacity(from + (to - from) * step / steps)
            end
            if step == steps and onDone then
                onDone()
            end
        end, step * FADE_STEP_MS)
    end
    widget:setOpacity(from)
end

local function showForm(look, silhouette)
    if not scene then
        return
    end
    scene.pokemon:setOutfit({ type = look })
    local creature = scene.pokemon:getCreature()
    if creature then
        creature:setShader(silhouette and SILHOUETTE_SHADER or '')
    end
end

local music

local function sounds()
    return modules.game_sounds
end

local function playMusic()
    if sounds() then
        sounds().play('evolution_start')
        music = sounds().play('evolution')
    end
end

-- finished: the "evolved" jingle plays over the music's fade
local function stopMusic(finished)
    if not sounds() then
        return
    end
    if music then
        sounds().fadeOut(music, finished and 1 or 0.3)
        music = nil
        if finished then
            sounds().play('evolution_done')
        end
    end
end

local function closeScene()
    cancelEvents()
    stopMusic(false)
    if scene then
        scene:destroy()
        scene = nil
    end
end

local function fadeOut()
    if not scene then
        return
    end
    local widget = scene
    fade(widget, 1, 0, 400, closeScene)
end

local function reveal(from, to)
    if not scene then
        return
    end
    scene.flash:setOpacity(1)
    showForm(toLook, false)
    fade(scene.flash, 1, 0, 700)
    fade(scene.glow, 0, 0.9, 700)
    scene.title:setText(tr('Congratulations! Your %s evolved into %s!', from, to))
    scene.hint:setText('')
end

local function startSwaps(swapUntil)
    local elapsed, showingTo = 0, false
    while elapsed < swapUntil do
        local progress = elapsed / swapUntil
        local interval = SWAP_FIRST_MS + (SWAP_LAST_MS - SWAP_FIRST_MS) * progress * progress
        elapsed = elapsed + interval
        showingTo = not showingTo
        local look = showingTo and toLook or fromLook
        schedule(function() showForm(look, true) end, INTRO_MS + elapsed)
    end
end

local function onStart(data)
    closeScene()
    fromLook, toLook = tonumber(data.fromLook), tonumber(data.toLook)
    if not fromLook or not toLook then
        return
    end

    scene = g_ui.createWidget('EvolutionScene', modules.game_interface.getRootPanel())
    scene.title:setText(tr('What? %s is evolving!', data.from or ''))
    scene.hint:setText(tr('Your Pokemon is surrounded by light...'))
    showForm(fromLook, false)
    fade(scene, 0, 1, 300)

    local duration = tonumber(data.duration) or 9500
    local revealAt = math.max(INTRO_MS + 1000, duration - REVEAL_BEFORE_MS)
    schedule(function()
        if scene then
            showForm(fromLook, true)
            fade(scene.glow, 0, 0.5, 600)
        end
    end, INTRO_MS)
    startSwaps(revealAt - INTRO_MS - SWAP_LAST_MS)
    schedule(function() reveal(data.from or '', data.to or '') end, revealAt)
    -- in case "done" never arrives (the trainer logged out, the Pokemon was recalled)
    schedule(fadeOut, duration + LINGER_MS + 2000)
end

local function onEvolution(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Evolution: invalid message')
        return
    end
    if data.state == 'start' then
        onStart(data)
        playMusic()
    elseif data.state == 'done' then
        stopMusic(true)
        if scene then
            schedule(fadeOut, LINGER_MS)
        end
    end
end

function isShowing()
    return scene ~= nil
end

function init()
    g_ui.importStyle('evolution')
    g_shaders.createFragmentShader(SILHOUETTE_SHADER, '/modules/game_evolution/silhouette', false)
    g_shaders.setupOutfitShader(SILHOUETTE_SHADER)
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Evolution, onEvolution)
    connect(g_game, { onGameEnd = closeScene })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Evolution)
    disconnect(g_game, { onGameEnd = closeScene })
    closeScene()
end
