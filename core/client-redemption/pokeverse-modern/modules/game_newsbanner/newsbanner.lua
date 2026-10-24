-- News banner (docs/upcoming-features.md, section 25). Server-wide announcements come as JSON on
-- ExtendedIds.Announcement (092-announcements.lua) just before the server's own text message:
--   {c = category, h = title, x = text, f = the text message as sent}
-- category is event, legendary, server, staff, milestone, tip or news. A Poke Ball drops in at the top of the
-- game window, turns sideways, opens along its seam, and the banner spreads out between the two halves; it
-- folds back in, the ball turns upright and sparkles away. One banner at a time, the rest queue. Hovering keeps
-- it open, clicking opens the Server Log, where the text is too.
-- takeScreenText (game_textmessage) hides the red text in the middle of the screen for what the banner shows;
-- with Options > Interface > Show news banner off nothing here draws and the red text is back.
-- Tips wait until the trainer has been out of a fight for a while, and are dropped after an hour; Show tips off
-- (or the banner's "Turn off tips") skips them.
local IMG = '/modules/game_newsbanner/images/'
local TICK = 30

local BALL = 46
local HALF = 23
local MIN_WIDTH, MAX_WIDTH, WIDTH_SHARE = 380, 620, 0.45
local MIN_HEIGHT, MAX_HEIGHT = 60, 82
local MAX_TEXT = 200
local GAP = 6 -- between the banner's ends and the ball halves

local DROP_MS, PULSE_MS, TURN_MS, SPLIT_MS, OPEN_MS, CLOSE_MS, GONE_MS = 450, 750, 300, 200, 500, 420, 400
local MIN_HOLD_MS, MAX_HOLD_MS = 5000, 9000
local NEXT_GAP_MS = 400
local EXPECT_MS = 4000 -- the text message follows the banner's message this soon
local START_DELAY_MS = 150 -- lets the event cards' own banner (wild legendaries) take the top first
local MAX_QUEUE = 8
local TIP_CALM_MS = 30000
local TIP_EXPIRE_MS = 60 * 60 * 1000

-- title: for a message that doesn't have its own
local CATEGORIES = {
    event = { label = 'EVENT', color = '#ffc42e', title = 'Event news' },
    legendary = { label = 'LEGENDARY', color = '#ba78ff', title = 'Legendary sighting' },
    server = { label = 'SERVER', color = '#ff5454', title = 'Heads up' },
    staff = { label = 'STAFF', color = '#54a8ff', title = 'PokeVerse staff' },
    milestone = { label = 'MILESTONE', color = '#60dc78', title = 'Congratulations!' },
    tip = { label = 'TIP', color = '#bec4d2', title = 'Did you know?' },
    news = { label = 'NEWS', color = '#78c8e6', title = 'News' },
}

local queue = {}
local expected = {}
local current
local banner
local tickEvent
local nextEvent
local lastFight = 0

local function option(key, default)
    local options = modules.client_options
    if not options or not options.getOption then
        return default
    end
    local value = options.getOption(key)
    if value == nil then
        return default
    end
    return value
end

local function enabled()
    return option('showNewsBanner', true) ~= false
end

local function tipsEnabled()
    return option('showTips', true) ~= false
end

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

local function easeOut(t) return 1 - (1 - t) ^ 3 end
local function easeIn(t) return t ^ 3 end

local function easeBack(t)
    local c = 1.6
    return 1 + (c + 1) * (t - 1) ^ 3 + c * (t - 1) ^ 2
end

local function bounce(t)
    local n, d = 7.5625, 2.75
    if t < 1 / d then
        return n * t * t
    elseif t < 2 / d then
        t = t - 1.5 / d
        return n * t * t + 0.75
    elseif t < 2.5 / d then
        t = t - 2.25 / d
        return n * t * t + 0.9375
    end
    t = t - 2.625 / d
    return n * t * t + 0.984375
end

local function trim(text)
    return (tostring(text or ''):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function inFight()
    local player = g_game.getLocalPlayer()
    if not player then
        return false
    end
    if g_game.isAttacking() then
        return true
    end
    local states = player:getStates()
    return Player.isStateActive(states, PlayerStates.Swords) or Player.isStateActive(states, PlayerStates.RedSwords)
end

local function otherBannerShowing()
    for _, name in ipairs({ 'game_eventcards', 'game_levelup', 'game_evolution' }) do
        local m = modules[name]
        if m and m.isShowing and m.isShowing() then
            return true
        end
    end
    return false
end

-- under the top bar, like the event cards' banner, and centred on the map rather than the whole window
local function place(widget)
    local root = modules.game_interface.getRootPanel()
    local map = modules.game_interface.getMapPanel()
    local top = math.max(0, map:getY() - root:getY()) + 12
    -- below the top bar and the trainer's HUD (name, health and party), which sit over the top of the map
    for _, id in ipairs({ 'environment', 'pokeHud' }) do
        local area = root:recursiveGetChildById(id)
        if area and area:isVisible() then
            top = math.max(top, area:getY() + area:getHeight() - root:getY() + 12)
        end
    end
    widget:setMarginTop(top)
    local rootRect, mapRect = root:getRect(), map:getRect()
    widget:setMarginLeft((mapRect.x + mapRect.width / 2) - (rootRect.x + rootRect.width / 2))
    return mapRect.width
end

local function destroyBanner()
    if tickEvent then
        removeEvent(tickEvent)
        tickEvent = nil
    end
    if banner then
        banner:destroy()
        banner = nil
    end
    current = nil
end

local showNext

local function scheduleNext(delay)
    if nextEvent then
        removeEvent(nextEvent)
    end
    nextEvent = scheduleEvent(function()
        nextEvent = nil
        showNext()
    end, delay)
end

local function openLog()
    local console = modules.game_console
    if not console or not console.getTab then
        return
    end
    local tab = console.getTab(tr('Server Log'))
    if tab and console.consoleTabBar then
        console.consoleTabBar:selectTab(tab)
    end
end

function turnOffTips()
    if modules.client_options and modules.client_options.setOption then
        modules.client_options.setOption('showTips', false)
    end
    if modules.game_textmessage and modules.game_textmessage.displayStatusMessage then
        modules.game_textmessage.displayStatusMessage(tr('Tips are off. Options > Interface > Show tips turns them back on.'))
    end
end

local function phases(hold)
    return {
        { 'drop', DROP_MS }, { 'pulse', PULSE_MS }, { 'turn', TURN_MS }, { 'split', SPLIT_MS }, { 'open', OPEN_MS },
        { 'hold', hold }, { 'close', CLOSE_MS }, { 'unturn', TURN_MS }, { 'gone', GONE_MS },
    }
end

local function holdFor(text)
    return clamp(MIN_HOLD_MS + math.max(0, #text - 70) * 40, MIN_HOLD_MS, MAX_HOLD_MS)
end

local function setHeight(widget, width, height)
    widget.body.inner:setSize({ width = width, height = height })
    widget.body:setHeight(height)
    widget.shadow:setSize({ width = widget.shadow:getWidth(), height = height + 16 })
    widget:setSize({ width = width + 2 * (HALF + GAP) + 8, height = height })
    widget.body.inner.text:setHeight(height - 40)
end

-- Wrapped text only knows its height once the banner is laid out. More than two lines is cut at a word, with
-- "..." (the Server Log has all of it).
local function fitHeight(widget, width, full)
    local label = widget.body.inner.text
    label:setText('Ag')
    local line = label:getTextSize().height
    label:setText(full)
    if line <= 0 then
        return false
    end
    local text = full
    while label:getTextSize().height > line * 2 + 2 do
        local cut = text:match('^(.*)%s+%S+$')
        if not cut or cut == '' then
            break
        end
        text = cut
        label:setText(text:gsub('[%s%p]+$', '') .. '...')
    end
    setHeight(widget, width, clamp(40 + label:getTextSize().height + 8, MIN_HEIGHT, MAX_HEIGHT))
    return true
end

local function build(item)
    local root = modules.game_interface.getRootPanel()
    local spec = CATEGORIES[item.category] or CATEGORIES.news
    local widget = g_ui.createWidget('NewsBanner', root)
    local mapWidth = place(widget)
    local width = math.floor(clamp(mapWidth * WIDTH_SHARE, MIN_WIDTH, MAX_WIDTH))

    local inner = widget.body.inner
    inner.edge:setImageColor(spec.color)
    inner.railLeft:setImageColor(spec.color)
    inner.railRight:setImageColor(spec.color)
    inner.badge:setImageColor(spec.color)
    inner.badge.icon:setImageSource(IMG .. 'icon_' .. (CATEGORIES[item.category] and item.category or 'news'))
    inner.category:setText(spec.label)
    inner.category:setColor(spec.color)
    inner.title:setText(item.title)

    local tipOff = inner.tipOff
    local reserved = 0
    if item.category == 'tip' then
        tipOff:setVisible(true)
        tipOff:setWidth(tipOff.label:getWidth() + 18)
        reserved = tipOff:getWidth() + 10
        tipOff.onClick = function()
            turnOffTips()
            if current then
                current.closeNow = true
            end
            return true
        end
        tipOff:setPhantom(false)
    end

    local textLeft = 24 + 38 + 12
    local text = inner.text
    text:setWidth(width - textLeft - 24)
    text:setHeight(MAX_HEIGHT - 40)
    text:setText(item.text)
    inner.title:setMaxWidth(width - textLeft - inner.category:getWidth() - 8 - 24 - reserved)
    setHeight(widget, width, MIN_HEIGHT)
    widget.glow:setImageColor(spec.color)
    widget.ring:setImageColor(spec.color)
    widget.top = widget:getMarginTop()

    widget.onClick = function()
        openLog()
        return true
    end
    return widget, width, spec.color
end

local function sparkles(widget, k, color)
    if not widget.sparkles then
        widget.sparkles = {}
        for i = 1, 8 do
            local s = g_ui.createWidget('NewsBannerSparkle', widget)
            s:setImageColor(i % 2 == 0 and '#ffffff' or color)
            widget.sparkles[i] = s
        end
    end
    for i, s in ipairs(widget.sparkles) do
        local a = (i / 8) * math.pi * 2 + 0.3
        local r = 8 + 34 * easeOut(k)
        s:setMarginLeft(math.floor(math.cos(a) * r))
        s:setMarginTop(math.floor(math.sin(a) * r))
        s:setOpacity(1 - k)
        local size = math.max(2, math.floor(14 * (1 - k) + 4))
        s:setSize({ width = size, height = size })
    end
end

local function setBall(widget, scale, rotation, dy)
    local ball = widget.ball
    local size = math.max(1, math.floor(BALL * scale + 0.5))
    ball:setVisible(true)
    ball:setSize({ width = size, height = size })
    ball:setRotation(rotation or 0)
    ball:setMarginTop(math.floor(dy or 0))
    widget.halfLeft:setVisible(false)
    widget.halfRight:setVisible(false)
    widget.body:setWidth(0)
    widget.shadow:setVisible(false)
end

local function setOpen(widget, w, gap, fullWidth)
    widget.ball:setVisible(false)
    widget.halfLeft:setVisible(true)
    widget.halfRight:setVisible(true)
    local offset = math.floor(w / 2 + gap + HALF / 2 - 6)
    widget.halfLeft:setMarginLeft(-offset)
    widget.halfRight:setMarginLeft(offset)
    local visible = math.floor(w)
    widget.body:setWidth(visible)
    widget.shadow:setVisible(visible > 4)
    widget.shadow:setWidth(visible + 16)
    widget.body.inner:setVisible(visible > 2)
end

local function frame()
    tickEvent = nil
    if not current or not banner or banner:isDestroyed() then
        destroyBanner()
        scheduleNext(NEXT_GAP_MS)
        return
    end
    local now = g_clock.millis()
    local c = current
    local elapsed = now - c.start

    -- hovering keeps it open, the tip button closes it at once
    if c.phase == 'hold' then
        if banner:isHovered() and not c.closeNow then
            c.start = c.start + (now - (c.last or now))
            elapsed = now - c.start
        elseif c.closeNow then
            c.start = c.start - math.max(0, c.holdEnd - elapsed)
            elapsed = now - c.start
            c.closeNow = false
        end
    end
    c.last = now
    if not c.fitted then
        c.fitted = fitHeight(banner, c.width, c.item.text) or elapsed > DROP_MS
    end

    local at = 0
    local phase, k
    for _, p in ipairs(c.phases) do
        if elapsed < at + p[2] then
            phase, k = p[1], (elapsed - at) / p[2]
            break
        end
        at = at + p[2]
    end
    if phase == 'hold' then
        c.holdEnd = at + c.hold
    end
    if not phase then
        destroyBanner()
        scheduleNext(NEXT_GAP_MS)
        return
    end
    if phase ~= c.phase then
        if phase == 'split' and modules.game_sounds and modules.game_sounds.play then
            modules.game_sounds.play('ball_open', 0.7)
        end
        c.phase = phase
    end

    local w, gap
    banner.glow:setOpacity(0)
    banner.ring:setOpacity(0)
    if phase == 'drop' then
        setBall(banner, 1, 0, -(banner.top + 40) * (1 - bounce(k)))
    elseif phase == 'pulse' then
        local beat = math.abs(math.sin(k * math.pi * 2))
        banner.glow:setOpacity(0.45 * beat)
        local ringT = (k * 2) % 1
        local ringSize = math.floor(BALL + 8 + 44 * ringT)
        banner.ring:setSize({ width = ringSize, height = ringSize })
        banner.ring:setOpacity(0.85 * (1 - ringT))
        setBall(banner, 1 + 0.12 * beat, 0, 0)
    elseif phase == 'turn' then
        setBall(banner, 1, -90 * easeBack(k), 0)
    elseif phase == 'split' then
        w, gap = 0, GAP * easeOut(k)
        banner.glow:setImageColor('#ffffff')
        banner.glow:setOpacity(0.8 * (1 - k))
    elseif phase == 'open' then
        w, gap = c.width * easeOut(k), GAP
    elseif phase == 'hold' then
        w, gap = c.width, GAP
        local shine = banner.body.inner.shine
        local t = (elapsed - at) % 2600 / 2600
        shine:setMarginLeft(math.floor(-60 + (c.width + 120) * t))
        shine:setOpacity(t < 0.6 and 1 or 0)
    elseif phase == 'close' then
        local e = easeIn(k)
        w, gap = c.width * (1 - e), GAP * (1 - e)
    elseif phase == 'unturn' then
        setBall(banner, 1, -90 * (1 - easeBack(k)), 0)
    else
        local e = easeIn(k)
        setBall(banner, math.max(0.02, 1 - e), 0, -10 * e)
        sparkles(banner, k, c.color)
    end
    if w then
        setOpen(banner, w, gap, c.width)
    end
    tickEvent = scheduleEvent(frame, TICK)
end

local function pickNext()
    local now = g_clock.millis()
    for i = #queue, 1, -1 do
        local item = queue[i]
        if item.category == 'tip' and (not tipsEnabled() or now - item.at > TIP_EXPIRE_MS) then
            table.remove(queue, i)
        end
    end
    for i, item in ipairs(queue) do
        if item.category ~= 'tip' then
            return table.remove(queue, i)
        end
    end
    if #queue > 0 and now - lastFight >= TIP_CALM_MS then
        return table.remove(queue, 1)
    end
    return nil
end

showNext = function()
    if current or not g_game.isOnline() or not enabled() then
        return
    end
    if inFight() then
        lastFight = g_clock.millis()
    end
    if #queue == 0 then
        return
    end
    if otherBannerShowing() then
        scheduleNext(500)
        return
    end
    local item = pickNext()
    if not item then
        scheduleNext(1000) -- a tip waiting for the fight to end
        return
    end
    local widget, width, color = build(item)
    banner = widget
    local hold = holdFor(item.text)
    current = { item = item, start = g_clock.millis(), width = width, color = color, hold = hold,
                phases = phases(hold) }
    frame()
end

-- game_textmessage: true hides the red text in the middle of the screen (the console keeps it)
function takeScreenText(mode, text)
    if not enabled() then
        return false
    end
    local now = g_clock.millis()
    text = trim(text)
    for i = #expected, 1, -1 do
        local entry = expected[i]
        if now - entry.at > EXPECT_MS then
            table.remove(expected, i)
        elseif entry.text == text then
            table.remove(expected, i)
            return true
        end
    end
    return false
end

function show(category, title, text, full)
    if not enabled() or not g_game.isOnline() then
        return false
    end
    category = CATEGORIES[category] and category or 'news'
    text = trim(text)
    if #text > MAX_TEXT then
        text = text:sub(1, MAX_TEXT - 3) .. '...'
    end
    if full then
        table.insert(expected, { text = trim(full), at = g_clock.millis() })
    end
    if category == 'tip' and not tipsEnabled() then
        return false
    end
    title = trim(title)
    if title == '' then
        title = CATEGORIES[category].title
    end
    table.insert(queue, { category = category, title = title, text = text, at = g_clock.millis() })
    while #queue > MAX_QUEUE do
        table.remove(queue, 1)
    end
    if not current then
        scheduleNext(START_DELAY_MS)
    end
    return true
end

function isShowing()
    return current ~= nil
end

local function onMessage(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('NewsBanner: invalid message')
        return
    end
    show(tostring(data.c or 'news'), data.h, data.x or data.f, data.f)
end

local function clearAll()
    if nextEvent then
        removeEvent(nextEvent)
        nextEvent = nil
    end
    destroyBanner()
    queue, expected = {}, {}
end

-- Options > Interface: Show news banner off takes it away, Show tips off drops the waiting tips
function refresh()
    if not enabled() then
        clearAll()
    elseif not tipsEnabled() then
        for i = #queue, 1, -1 do
            if queue[i].category == 'tip' then
                table.remove(queue, i)
            end
        end
    end
end

local function onStatesChange(player, states, oldStates)
    for _, value in ipairs({ states, oldStates }) do
        if Player.isStateActive(value, PlayerStates.Swords) or Player.isStateActive(value, PlayerStates.RedSwords) then
            lastFight = g_clock.millis()
            return
        end
    end
end

local function onGameEnd()
    clearAll()
    lastFight = 0
end

function init()
    g_ui.importStyle('newsbanner')
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Announcement, onMessage)
    connect(g_game, { onGameEnd = onGameEnd })
    connect(LocalPlayer, { onStatesChange = onStatesChange })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Announcement)
    disconnect(g_game, { onGameEnd = onGameEnd })
    disconnect(LocalPlayer, { onStatesChange = onStatesChange })
    clearAll()
end
