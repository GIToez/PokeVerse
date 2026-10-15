-- The daily login calendar. The server (065-dailyLogin.lua) sends the whole state as
-- ExtendedIds.DailyLogin JSON at login, after a claim and at midnight; the window only asks with
-- "/tasks login claim" and draws what comes back. It opens by itself at login while today's
-- reward is unclaimed.
local window, button, badge
local state, receivedAt
local openAtLogin = false

-- space kept free around the window, so it never touches the screen edges
local SCREEN_MARGIN = 10

local function formatMoney(amount)
    local text = tostring(amount)
    repeat
        local n
        text, n = text:gsub('^(%d+)(%d%d%d)', '%1,%2')
    until n == 0
    return '$' .. text
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    return tr('%dh %02dm', hours, minutes)
end

-- as many days in a row as fit on the screen, more rows below
local function layoutWindow()
    if not window then
        return
    end
    local days = window.days
    local layout = days:getLayout()
    local cell = layout:getCellSize()
    local spacing = layout:getCellSpacing()
    local count = math.max(1, days:getChildCount())
    local root = g_ui.getRootWidget()

    window:updateLayout()
    local chromeWidth = window:getPaddingLeft() + window:getPaddingRight()
    local chromeHeight = window:getHeight() - days:getHeight()
    local roomWidth = root:getWidth() - 2 * SCREEN_MARGIN - chromeWidth
    local columns = math.max(1, math.min(count, math.floor((roomWidth + spacing) / (cell.width + spacing))))
    local rows = math.ceil(count / columns)
    local width = columns * (cell.width + spacing) - spacing
    days:setWidth(width)
    window:setSize({ width = math.max(width, 200) + chromeWidth,
                     height = rows * (cell.height + spacing) - spacing + chromeHeight })
end

local function drawDay(widget, info, status)
    local reward = info.reward
    local item = reward.items and reward.items[1]
    widget.item:setVisible(item ~= nil)
    widget.money:setVisible(item == nil)
    if item then
        widget.item:setItemId(item.id)
        widget.item:setItemCount(item.count)
        widget:setTooltip(string.format('%d %s', item.count, item.name or ''))
    else
        widget.money:setText(formatMoney(reward.money or 0))
        widget:setTooltip(formatMoney(reward.money or 0))
    end
    widget.name:setText(info.label or '')

    local titles = { claimed = tr('Day %d', info.day), today = tr('Today'), tomorrow = tr('Next'),
                     later = tr('Day %d', info.day) }
    widget.title:setText(titles[status])
    widget.check:setVisible(status == 'claimed')
    widget:setOn(status == 'today')
    local opacity = status == 'claimed' and 0.4 or (status == 'today' and 1 or 0.8)
    for _, child in ipairs({ widget.title, widget.item, widget.money, widget.name }) do
        child:setOpacity(opacity)
    end
end

local function draw()
    if not window or not state then
        return
    end
    window.days:destroyChildren()
    for _, info in ipairs(state.days) do
        local status = 'later'
        if info.day <= state.done then
            status = 'claimed'
        elseif info.day == state.done + 1 then
            status = state.claimedToday and 'tomorrow' or 'today'
        end
        drawDay(g_ui.createWidget('LoginDay', window.days), info, status)
    end

    local total = #state.days
    local text
    if not state.claimedToday then
        text = state.missed and tr('You missed a day, so the calendar started over. Claim day 1!')
            or tr('Claim your day %d reward! Come back every day: day %d has the best reward.', state.done + 1, total)
    elseif state.done >= total then
        text = tr('All %d days collected! The calendar starts over tomorrow.', total)
    else
        local left = math.max(0, state.resetsIn - math.floor((g_clock.millis() - receivedAt) / 1000))
        text = tr('Come back tomorrow for day %d (in %s). Missing a day starts the calendar over.',
            state.done + 1, formatTime(left))
    end
    window.info:setText(text)
    window.claim:setEnabled(not state.claimedToday)
    layoutWindow()

    if button then
        button:setTooltip(state.claimedToday and tr('Daily login reward') or tr('Daily login reward (ready to claim)'))
    end
    if badge then
        badge:setVisible(not state.claimedToday)
    end
end

local function show()
    window:show()
    window:raise()
    window:focus()
end

function toggle()
    if window:isVisible() then
        window:hide()
        return
    end
    g_game.talk('/tasks login')
    show()
end

local function onDailyLogin(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or type(data.days) ~= 'table' then
        g_logger.warning('Daily login: invalid message')
        return
    end
    state, receivedAt = data, g_clock.millis()
    draw()
    if openAtLogin then
        openAtLogin = false
        if not state.claimedToday then
            show()
        end
    end
end

local function onGameStart()
    openAtLogin = true
end

local function onGameEnd()
    state = nil
    openAtLogin = false
    if badge then
        badge:hide()
    end
    if window then
        window:hide()
    end
end

function init()
    g_ui.importStyle('dailylogin')
    window = g_ui.createWidget('DailyLoginWindow', rootWidget)
    window:hide()
    window.claim.onClick = function() g_game.talk('/tasks login claim') end

    button = modules.client_topmenu.addRightGameToggleButton('dailyLoginButton', tr('Daily login reward'),
        '/images/options/rewardwall', toggle)
    if button then
        badge = g_ui.createWidget('UIWidget', button)
        badge:setId('badge')
        badge:setImageSource('/images/options/badge_dot')
        badge:setSize({ width = 8, height = 8 })
        badge:addAnchor(AnchorTop, 'parent', AnchorTop)
        badge:addAnchor(AnchorRight, 'parent', AnchorRight)
        badge:setPhantom(true)
        badge:hide()
    end

    ProtocolGame.registerExtendedOpcode(ExtendedIds.DailyLogin, onDailyLogin)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    connect(rootWidget, { onGeometryChange = layoutWindow })
    if g_game.isOnline() then
        g_game.talk('/tasks login')
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.DailyLogin)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    disconnect(rootWidget, { onGeometryChange = layoutWindow })
    if button then
        button:destroy()
    end
    window:destroy()
    window, button, badge, state = nil, nil, nil, nil
end
