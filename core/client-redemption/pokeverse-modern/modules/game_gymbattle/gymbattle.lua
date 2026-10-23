-- Gym leader duel banners. The server sends JSON on ExtendedIds.Gym (GymLeaders in the server lib):
-- {type = "intro" or "victory", key, name, gym, title, element, badge, quote, look}. key names the
-- leader's portrait and band in images/, and the badge icon below.
local IMAGES = '/modules/game_gymbattle/images/'
local SLIDE_MS = 320
local SLIDE_FROM = -520
local FADE_OUT_MS = 500
local VS_DELAY_MS = 260
local HOLD_MS = { intro = 3600, victory = 6000 }
local GAP_MS = 200
local DUEL_MESSAGE_SUPPRESS_MS = 3000

-- Client ids of the earned badges
local BADGE_ITEMS = {
    brock = 11174, misty = 11176, ltsurge = 11178, erika = 11180,
    koga = 11182, sabrina = 11184, blaine = 11186, giovanni = 11188,
}

local ELEMENTS = { [0] = 'Normal', 'Fight', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug', 'Ghost', 'Steel',
    'Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Ice', 'Dragon', 'Dark', 'Fairy' }

local queue = {}
local banner
local events = {}

local function schedule(fn, delay)
    local event
    event = scheduleEvent(function()
        table.removevalue(events, event)
        fn()
    end, delay)
    table.insert(events, event)
end

local function clearBanner()
    if banner then
        g_effects.cancelFade(banner)
        banner:destroy()
        banner = nil
    end
end

local function reset()
    for _, event in ipairs(events) do
        removeEvent(event)
    end
    events = {}
    clearBanner()
    queue = {}
end

local function placeOverMap(widget)
    local root = modules.game_interface.getRootPanel()
    local map = modules.game_interface.getMapPanel()
    local rootRect, mapRect = root:getRect(), map:getRect()
    local top = mapRect.y - rootRect.y + math.floor(mapRect.height * 0.32) - math.floor(widget:getHeight() / 2)
    widget:setMarginTop(math.max(top, 0))
end

local function slideIn(widget, elapsed)
    if widget:isDestroyed() then
        return
    end
    local t = math.min(elapsed / SLIDE_MS, 1)
    local eased = 1 - (1 - t) ^ 3
    widget:setMarginLeft(math.floor(SLIDE_FROM * (1 - eased) + 0.5))
    if t < 1 then
        schedule(function() slideIn(widget, elapsed + 16) end, 16)
    end
end

local function fill(widget, data)
    widget.band:setImageSource(IMAGES .. 'band_' .. (data.type == 'victory' and 'victory' or data.key))
    widget.portrait:setImageSource(IMAGES .. 'leaders/' .. data.key)
    if data.element and ELEMENTS[data.element] then
        widget.element:setImageSource('/images/types/' .. data.element)
    else
        widget.element:setWidth(0)
    end

    if data.type == 'victory' then
        widget.heading:setText(tr('You defeated %s', data.name or ''):upper())
        widget.name:setText(tr('%s Badge!', data.badge or ''))
        widget.title:setText(tr('%s Leader', data.gym or ''))
        widget.vs:hide()
        widget.player:hide()
        widget.playerName:hide()
        widget.rays:show()
        if BADGE_ITEMS[data.key] then
            widget.badge:setItemId(BADGE_ITEMS[data.key])
            widget.badge:show()
        end
    else
        widget.heading:setText(tr('%s Leader', data.gym or ''):upper())
        widget.name:setText(data.name or '')
        widget.title:setText(data.title or '')
        local player = g_game.getLocalPlayer()
        if player then
            widget.player:setOutfit(player:getOutfit())
            local creature = widget.player:getCreature()
            if creature then
                creature:setDirection(Directions.West)
            end
            widget.playerName:setText(player:getName())
        end
    end
    widget.quote:setText(data.quote and ('"' .. data.quote .. '"') or '')
end

local showNext

local function display(data)
    local root = modules.game_interface.getRootPanel()
    banner = g_ui.createWidget('GymBanner', root)
    fill(banner, data)
    placeOverMap(banner)
    banner:setMarginLeft(SLIDE_FROM)
    g_effects.fadeIn(banner, SLIDE_MS)
    slideIn(banner, 0)

    local current = banner
    schedule(function()
        if current == banner and banner.vs:isVisible() then
            g_effects.fadeIn(banner.vs, 300)
        end
    end, SLIDE_MS + VS_DELAY_MS)

    schedule(function()
        if current ~= banner then
            return
        end
        g_effects.fadeOut(banner, FADE_OUT_MS)
        schedule(function()
            clearBanner()
            schedule(showNext, GAP_MS)
        end, FADE_OUT_MS)
    end, SLIDE_MS + (HOLD_MS[data.type] or HOLD_MS.intro))
end

showNext = function()
    if banner or #queue == 0 then
        return
    end
    display(table.remove(queue, 1))
end

local function onGym(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or (data.type ~= 'intro' and data.type ~= 'victory') or not data.key then
        g_logger.warning('GymBattle: invalid message')
        return
    end
    if data.type == 'victory' and modules.game_duelmessage and modules.game_duelmessage.suppress then
        modules.game_duelmessage.suppress(DUEL_MESSAGE_SUPPRESS_MS)
    end
    if data.type == 'victory' and modules.game_sounds then
        modules.game_sounds.play('badge_get')
    end
    table.insert(queue, data)
    showNext()
end

function init()
    g_ui.importStyle('gymbattle')
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Gym, onGym)
    connect(g_game, { onGameEnd = reset })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Gym)
    disconnect(g_game, { onGameEnd = reset })
    reset()
end
