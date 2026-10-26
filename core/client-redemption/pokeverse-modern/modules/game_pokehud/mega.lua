-- The Mega bar under the trainer's health and the round Mega button (docs/upcoming-features.md, Mega
-- Evolution; the look is docs/concepts/mega-gauge-hud.png). The server (097-megaEvolution.lua) sends the
-- state on ExtendedIds.Mega after the client's hello and on every change; the R key (Ctrl+R while typing)
-- and the button send "evolve" on ExtendedIds.MegaEvolve. Purple while charging, gold when full, green while
-- Mega Evolved; the button is lit only when the Pokemon out can Mega Evolve. The boosted moves glow on the
-- moves bar. The animation messages go on to game_megafx.
Mega = {}

local IMAGES = '/modules/game_pokehud/images/'
local KEYBIND_CATEGORY = 'Pokemon'
local ACTION = 'Mega Evolve'

local panel
local setBar
local state

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.MegaEvolve, data)
    end
end

local function evolve()
    if g_game.isOnline() and state and state.ring then
        send({ action = 'evolve' })
    end
end

local function setBoostedMoves(moves)
    local moduleMoves = modules.game_pokemoves
    if moduleMoves and moduleMoves.setBoostedMoves then
        moduleMoves.setBoostedMoves(moves)
    end
end

local function update()
    if not panel then
        return
    end
    local shown = state ~= nil and state.ring == true
    panel.megaIcon:setVisible(shown)
    panel.megaBar:setVisible(shown)
    panel.megaButton:setVisible(shown)
    if not shown then
        setBoostedMoves({})
        return
    end

    local max = math.max(1, state.max or 100)
    local gauge = math.max(0, math.min(state.gauge or 0, max))
    local button, lit, fill, text, tooltip
    if state.active then
        local left, duration = state.left or 0, math.max(1, state.duration or 60)
        local form = (state.form or tr('Mega')):gsub('^Shiny ', '')
        fill, text = 'fill-mega-active', string.format('%s %ds', form:upper(), left)
        tooltip = tr('%s for %d more seconds. It ends if your Pokemon is called back or faints.', form, left)
        button, lit = 'mega-button-active', true
        setBar(panel.megaBar, left * 100 / duration, fill, text, tooltip)
        -- "MEGA CHARIZARD X 27s" is too long for the bar: "CHARIZARD X 27s"
        if panel.megaBar.text:getTextSize().width > panel.megaBar:getWidth() - 8 then
            panel.megaBar.text:setText(string.format('%s %ds', form:gsub('^Mega ', ''):upper(), left))
        end
    else
        if gauge >= max then
            fill = 'fill-mega-full'
            text = state.ready and tr('MEGA READY') or string.format('MEGA %d / %d', gauge, max)
            tooltip = state.ready and tr('Press R or click the button to Mega Evolve.')
                or tr('The gauge is full. Your Pokemon out needs to hold its own Mega Stone.')
        else
            fill = 'fill-mega-charge'
            text = string.format('MEGA %d / %d', gauge, max)
            tooltip = tr('Mega gauge: fight with your Pokemon to charge it. Full, press R to Mega Evolve.')
        end
        button, lit = state.ready and 'mega-button-ready' or 'mega-button-off', state.ready == true
        setBar(panel.megaBar, gauge * 100 / max, fill, text, tooltip)
    end
    panel.megaButton:setImageSource(IMAGES .. button)
    panel.megaButton.key:setOn(lit)
    panel.megaButton:setTooltip(tooltip)
    setBoostedMoves(state.active and state.boosted or {})
end

local function updateKeyLabel()
    if panel then
        local label = Keybind.getShortLabel(KEYBIND_CATEGORY, ACTION)
        panel.megaButton.key:setText(label)
        panel.megaButton.key:setVisible(label ~= '')
    end
end

local function onMega(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        return
    end
    if data.type == 'fx' then
        local fx = modules.game_megafx
        if fx and fx.play then
            fx.play(data)
        end
    elseif data.type == 'state' then
        state = data
        update()
    end
end

local function onGameStart()
    state = nil
    update()
    send({ action = 'hello' })
end

local function onGameEnd()
    state = nil
    update()
end

function Mega.getState()
    return state
end

function Mega.init(mainPanel, setBarFunction)
    panel, setBar = mainPanel, setBarFunction
    panel.megaButton.onClick = evolve
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Mega, onMega)
    Keybind.new(KEYBIND_CATEGORY, ACTION, { [CHAT_MODE.ON] = 'Ctrl+R', [CHAT_MODE.OFF] = 'R' }, '')
    Keybind.bind(KEYBIND_CATEGORY, ACTION, { { type = KEY_DOWN, callback = evolve } })
    connect(Keybind, { onBind = updateKeyLabel })
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    updateKeyLabel()
    if g_game.isOnline() then
        onGameStart()
    end
end

function Mega.terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Mega)
    Keybind.delete(KEYBIND_CATEGORY, ACTION)
    disconnect(Keybind, { onBind = updateKeyLabel })
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    panel, setBar, state = nil, nil, nil
end
