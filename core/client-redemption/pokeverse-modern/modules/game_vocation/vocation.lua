-- The vocation window. The server (Vocations in the server lib) opens it with JSON on
-- ExtendedIds.Vocation: {type = "open", level, minLevel, chosen, rank, title, vocations = {{key, name, tagline, perks}, ...}},
-- then answers a choice with {type = "chosen", key, name, rank, title} or {type = "result", ok, text}.
-- A card's Select turns into Confirm and Back; Confirm sends {action = "choose", key}.
-- The U key opens the trainer's vocation tool (the Ranger radar, the Angler fishing guide): those
-- modules call registerTool(id, {enabled = fn, toggle = fn}).
local IMAGES = '/modules/game_vocation/images/'
local ERROR_COLOR = '#ff8a80'
local MUTED_COLOR = '#96aacd'
local MESSAGE_MS = 4000

local window
local cards = {}
local state = {}
local selected
local messageEvent
local tools = {}
local TOOL_ACTION = 'Show/hide your vocation tool'

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Vocation, data)
    end
end

local function canChoose()
    return not state.chosen and (state.level or 0) >= (state.minLevel or 0)
end

local function updateSubtitle()
    removeEvent(messageEvent)
    messageEvent = nil
    local text
    if state.chosen then
        local vocation = cards[state.chosen]
        local name = vocation and vocation.data.name or state.chosen
        local title = state.title or name
        text = tr('You are %s', (title:match('^[AEIOUaeiou]') and 'an ' or 'a ') .. title)
        if state.title then
            text = text .. ' ' .. tr('(%s, rank %d of 5)', name, state.rank or 1)
        end
    elseif canChoose() then
        text = tr('Unlocks at Trainer Level %d', state.minLevel) .. '  \183  ' .. tr('Permanent choice')
    else
        text = tr('Reach Trainer Level %d to choose. You are level %d.', state.minLevel or 0, state.level or 0)
    end
    window.subtitle:setColor(MUTED_COLOR)
    window.subtitle:setText(text)
end

local function showMessage(text)
    updateSubtitle()
    window.subtitle:setColor(ERROR_COLOR)
    window.subtitle:setText(text)
    messageEvent = scheduleEvent(updateSubtitle, MESSAGE_MS)
end

local function refreshCard(key)
    local card = cards[key].widget
    local isSelected = selected == key
    local isChosen = state.chosen == key
    card:setChecked(isSelected or isChosen)
    card.select:setVisible(not state.chosen and not isSelected)
    card.select:setEnabled(canChoose())
    card.confirm:setVisible(isSelected)
    card.back:setVisible(isSelected)
    card.note:setVisible(isSelected)
    card.chosen:setVisible(isChosen)
end

local function refreshCards()
    for key in pairs(cards) do
        refreshCard(key)
    end
end

local function pick(key)
    if not canChoose() then
        return
    end
    selected = key
    refreshCards()
end

local function build(vocations)
    window.grid:destroyChildren()
    cards = {}
    selected = nil
    for _, data in ipairs(vocations) do
        local card = g_ui.createWidget('VocationCard', window.grid)
        card:setId(data.key)
        card.banner:setImageSource(IMAGES .. 'banner_' .. data.key)
        card.icon:setImageSource(IMAGES .. 'icon_' .. data.key)
        card.name:setText(data.name or '')
        card.tagline:setText(data.tagline or '')
        for _, perk in ipairs(data.perks or {}) do
            g_ui.createWidget('VocationPerk', card.perks):setText(perk)
        end
        card.select:setText(tr('Select %s', data.name or ''))
        card.select.onClick = function() pick(data.key) end
        card.back.onClick = function()
            selected = nil
            refreshCards()
        end
        card.confirm.onClick = function()
            send({ action = 'choose', key = data.key })
        end
        cards[data.key] = { widget = card, data = data }
    end
    refreshCards()
end

local function show()
    local root = rootWidget:getSize()
    window:show()
    window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                         y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
    window:raise()
    window:focus()
end

function registerTool(id, tool)
    tools[id] = tool
end

function unregisterTool(id)
    tools[id] = nil
end

local function typing()
    local widget = rootWidget
    while widget:getFocusedChild() do
        widget = widget:getFocusedChild()
    end
    return widget:getClassName() == 'UITextEdit' and widget:isEnabled() and widget:isVisible()
end

local function onToolKey()
    if typing() then
        return
    end
    for _, tool in pairs(tools) do
        if tool.enabled() then
            tool.toggle()
            return
        end
    end
end

function close()
    if window and window:isVisible() then
        window:hide()
        send({ action = 'close' })
    end
    selected = nil
end

local function onVocation(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Vocation: invalid message')
        return
    end
    if data.type == 'open' and type(data.vocations) == 'table' then
        state = { level = tonumber(data.level) or 0, minLevel = tonumber(data.minLevel) or 0, chosen = data.chosen,
                  rank = tonumber(data.rank), title = data.title }
        build(data.vocations)
        updateSubtitle()
        show()
    elseif data.type == 'chosen' then
        state.chosen = data.key
        state.rank = tonumber(data.rank)
        state.title = data.title
        selected = nil
        refreshCards()
        updateSubtitle()
    elseif data.type == 'result' and data.text and window:isVisible() then
        showMessage(data.text)
    end
end

local function onGameEnd()
    removeEvent(messageEvent)
    messageEvent = nil
    selected = nil
    state = {}
    if window then
        window:hide()
    end
end

function init()
    g_ui.importStyle('vocation')
    window = g_ui.createWidget('VocationWindow', rootWidget)
    window:hide()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Vocation, onVocation)
    connect(g_game, { onGameEnd = onGameEnd })
    Keybind.new('Windows', TOOL_ACTION, { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'U' }, '')
    Keybind.bind('Windows', TOOL_ACTION, { { type = KEY_DOWN, callback = onToolKey } })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Vocation)
    disconnect(g_game, { onGameEnd = onGameEnd })
    Keybind.delete('Windows', TOOL_ACTION)
    removeEvent(messageEvent)
    if window then
        window:destroy()
        window = nil
    end
end
