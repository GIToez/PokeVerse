-- The event calendar. The server (077-eventCalendar.lua) sends ExtendedIds.Calendar JSON: "status"
-- (the running events and the next one) at login and whenever that changes, and "range" (every event
-- and moon of a span) when the window asks for a month. The banner beside the clock shows the
-- running event, or how long until the next one; clicking it opens the month.
local banner, window
local status -- the last "status" message
local range -- the last "range" message
local offset = 0 -- server clock - local clock, in seconds
local viewYear, viewMonth
local selectedDay -- the start of the clicked day, or nil for the whole month
local tickEvent, placeEvent
local askedAt = 0

local DAY = 86400
local LUNATION = 29.530588861 * DAY
local MAX_STRIPS = 3

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Calendar, data)
    end
end

local function now()
    return os.time() + offset
end

local function formatLeft(seconds)
    seconds = math.max(0, seconds)
    local days, hours = math.floor(seconds / DAY), math.floor(seconds % DAY / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    if days > 0 then
        return hours > 0 and tr('%dd %dh', days, hours) or tr('%dd', days)
    elseif hours > 0 then
        return tr('%dh %02dm', hours, minutes)
    end
    return tr('%dm', math.max(1, minutes))
end

local function formatWhen(event)
    if event.forced then
        return tr('On now, until staff end it')
    end
    local starts, ends = os.date('*t', event.startsAt), os.date('*t', event.endsAt - 1)
    local from = os.date('%a %d %b %H:%M', event.startsAt)
    if starts.year == ends.year and starts.yday == ends.yday then
        return from .. ' - ' .. os.date('%H:%M', event.endsAt)
    end
    return from .. ' - ' .. os.date('%d %b %H:%M', event.endsAt)
end

local function zoneName()
    local t = os.time()
    local diff = os.difftime(t, os.time(os.date('!*t', t)))
    if os.date('*t', t).isdst then
        diff = diff + 3600
    end
    local hours, minutes = math.floor(math.abs(diff) / 3600), math.floor(math.abs(diff) % 3600 / 60)
    local text = 'UTC' .. (diff < 0 and '-' or '+') .. hours
    return minutes > 0 and string.format('%s:%02d', text, minutes) or text
end

local function eventTooltip(event)
    return table.concat({ event.name, event.description or '', formatWhen(event) }, '\n')
end

-- banner

local function placeBanner()
    if not banner then
        return
    end
    local clock = rootWidget:recursiveGetChildById('timeWindow')
    banner:breakAnchors()
    if clock and clock:getParent() then
        banner:setParent(clock:getParent())
        -- the weather badge (game_weather) sits between the clock and the banner
        local weather = modules.game_weather and modules.game_weather.getBadge and modules.game_weather.getBadge()
        local after = (weather and weather:isVisible() and weather:getParent() == clock:getParent()) and 'weatherBadge' or 'timeWindow'
        local topMenu = modules.client_topmenu and modules.client_topmenu.getTopMenu and modules.client_topmenu.getTopMenu()
        if topMenu and clock:getParent() == topMenu then
            banner:addAnchor(AnchorLeft, after, AnchorRight)
            banner:addAnchor(AnchorVerticalCenter, 'timeWindow', AnchorVerticalCenter)
            banner:setMarginLeft(14)
            banner:setMarginTop(0)
        else
            banner:addAnchor(AnchorTop, after, AnchorBottom)
            banner:addAnchor(AnchorHorizontalCenter, 'timeWindow', AnchorHorizontalCenter)
            banner:setMarginLeft(0)
            banner:setMarginTop(2)
        end
    else
        banner:setParent(modules.game_interface.getRootPanel())
        banner:addAnchor(AnchorTop, 'parent', AnchorTop)
        banner:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
        banner:setMarginTop(4)
    end
    banner:setVisible(g_game.isOnline() and status ~= nil)
end

function relayout()
    placeBanner()
end

local function seasonLine()
    local season = status and status.season
    if not season then
        return nil
    end
    return tr('Season: %s', season.name)
end

local function withSeason(text)
    local line = seasonLine()
    return line and (text .. '\n\n' .. line) or text
end

local function updateBanner()
    if not banner or not status then
        return
    end
    local t = now()
    local active = {}
    for _, event in ipairs(status.active or {}) do
        if event.forced or event.endsAt > t then
            active[#active + 1] = event
        end
    end
    local label = banner:getChildById('label')
    local refresh = false
    if #active > 0 then
        local first = active[1]
        local text = first.forced and first.name or tr('%s: %s left', first.name, formatLeft(first.endsAt - t))
        if #active > 1 then
            text = text .. '  ' .. tr('+%d more', #active - 1)
        end
        label:setText(text)
        label:setColor(first.color or '#ffffff')
        local tips = {}
        for _, event in ipairs(active) do
            tips[#tips + 1] = eventTooltip(event)
        end
        banner:setTooltip(withSeason(table.concat(tips, '\n\n')) .. '\n\n' .. tr('Click or press C to open the calendar.'))
        refresh = #active < #(status.active or {})
    elseif status.next then
        label:setText(tr('Next: %s in %s', status.next.name, formatLeft(status.next.startsAt - t)))
        label:setColor('#96aacd')
        banner:setTooltip(withSeason(tr('No event is running.') .. '\n\n' .. eventTooltip(status.next)) .. '\n\n' ..
            tr('Click or press C to open the calendar.'))
    else
        label:setText(tr('Event calendar'))
        label:setColor('#96aacd')
        banner:setTooltip(withSeason(tr('Event calendar')) .. '\n\n' .. tr('Click or press C to open the calendar.'))
    end
    refresh = refresh or (#active == 0 and status.next and status.next.startsAt <= t)
    banner:setWidth(banner:getChildById('icon'):getWidth() + label:getMarginLeft() + label:getWidth() + 2)
    -- an event ended or started on this side: ask again (the server pushes it too, this covers a missed push)
    if refresh and g_clock.seconds() - askedAt > 30 then
        askedAt = g_clock.seconds()
        send({ action = 'status' })
    end
end

-- window

local function monthStart(year, month)
    return os.time({ year = year, month = month, day = 1, hour = 0, min = 0, sec = 0 })
end

local function gridStart(year, month)
    local first = os.date('*t', monthStart(year, month))
    local back = (first.wday + 5) % 7 -- days since Monday
    return os.time({ year = year, month = month, day = 1 - back, hour = 0, min = 0, sec = 0 })
end

local function dayStart(time)
    local d = os.date('*t', time)
    return os.time({ year = d.year, month = d.month, day = d.day, hour = 0, min = 0, sec = 0 })
end

local function nextDay(time)
    local d = os.date('*t', time)
    return os.time({ year = d.year, month = d.month, day = d.day + 1, hour = 0, min = 0, sec = 0 })
end

-- the moon phase (0 new .. 4 full .. 7) at a time, from the new and full moons the server sent,
-- and the new or full moon that falls inside [from, to) if there is one
local function moonAt(time, from, to)
    local newMoon, exact
    for _, phase in ipairs(range and range.moons or {}) do
        local start = phase.full and phase.time - LUNATION / 2 or phase.time
        if start <= time and (not newMoon or start > newMoon) then
            newMoon = start
        end
        if phase.time >= from and phase.time < to then
            exact = phase
        end
    end
    if not newMoon then
        return nil
    end
    if exact then
        return exact.full and 4 or 0, exact
    end
    return math.floor((time - newMoon) / LUNATION * 8 + 0.5) % 8
end

-- an event shows on the day it starts and the days it covers for more than a few hours (holidays end
-- at the morning restart); a night only on the evening it starts
local function onDay(event, from, to)
    if event.startsAt >= from and event.startsAt < to then
        return true
    elseif event.night then
        return false
    end
    return math.min(event.endsAt, to) - math.max(event.startsAt, from) > 6 * 3600
end

local function drawList()
    local list = window:recursiveGetChildById('events')
    list:destroyChildren()
    local from, to
    if selectedDay then
        from, to = selectedDay, nextDay(selectedDay)
        window:recursiveGetChildById('sideTitle'):setText(os.date('%A %d %B', selectedDay))
    else
        from, to = monthStart(viewYear, viewMonth), monthStart(viewYear, viewMonth + 1)
        window:recursiveGetChildById('sideTitle'):setText(tr('This month'))
    end
    local count = 0
    for _, event in ipairs(range and range.events or {}) do
        if onDay(event, from, to) then
            count = count + 1
            local row = g_ui.createWidget('CalendarEvent', list)
            row:getChildById('dot'):setBackgroundColor(event.color or '#ffffff')
            row:getChildById('name'):setText(event.name)
            row:getChildById('name'):setColor(event.color or '#ffffff')
            row:getChildById('when'):setText(formatWhen(event))
            local description = row:getChildById('description')
            description:setText(event.description or '')
            row:setHeight(row:getPaddingTop() + 16 + 3 + 14 + 3 + description:getHeight() + row:getPaddingBottom())
        end
    end
    local empty = window:recursiveGetChildById('empty')
    empty:setVisible(count == 0)
    empty:setText(range and (selectedDay and tr('No events on this day.') or tr('No events this month.'))
        or tr('Loading...'))
    window:recursiveGetChildById('zone'):setText(tr('Times are in your time zone (%s).', zoneName()))
end

local function drawGrid()
    if not window then
        return
    end
    window:recursiveGetChildById('month'):setText(os.date('%B %Y', monthStart(viewYear, viewMonth)))
    local season = status and status.season
    window:recursiveGetChildById('seasonIcon'):setVisible(season ~= nil)
    window:recursiveGetChildById('seasonLabel'):setVisible(season ~= nil)
    if season then
        window:recursiveGetChildById('seasonIcon'):setImageSource('/modules/game_weather/images/season_' .. season.id)
        local label = window:recursiveGetChildById('seasonLabel')
        label:setText(season.forced and tr('%s (set by staff)', season.name) or season.name)
        label:setColor(season.color or '#dce6ff')
    end
    local grid = window:recursiveGetChildById('grid')
    grid:destroyChildren()
    local today = dayStart(now())
    local day = gridStart(viewYear, viewMonth)
    for _ = 1, 42 do
        local from, to = day, nextDay(day)
        local d = os.date('*t', from)
        local cell = g_ui.createWidget('CalendarDay', grid)
        cell:getChildById('number'):setText(d.day)
        cell:getChildById('number'):setColor(from == today and '#ffd75a' or '#ffffff')
        cell:setOpacity(d.month == viewMonth and 1 or 0.45)
        cell:setChecked(selectedDay == from)
        if from == today then
            cell:setImageColor('#ffd75a')
        end
        local phase, exact = moonAt(from + DAY / 2, from, to)
        local moon = cell:getChildById('moon')
        if phase then
            moon:setImageSource('/modules/game_calendar/images/moon_' .. phase)
            moon:setTooltip(exact and tr('%s at %s', exact.full and tr('Full moon') or tr('New moon'),
                os.date('%H:%M', exact.time)) or nil)
        else
            moon:hide()
        end
        local strips, shown, more = cell:getChildById('strips'), 0, 0
        local tips = {}
        for _, event in ipairs(range and range.events or {}) do
            if onDay(event, from, to) then
                if shown < MAX_STRIPS then
                    shown = shown + 1
                    local strip = g_ui.createWidget('CalendarStrip', strips)
                    strip:setText(event.name)
                    strip:setBackgroundColor((event.color or '#80b0ff') .. '90')
                else
                    more = more + 1
                end
                tips[#tips + 1] = event.name .. ' (' .. formatWhen(event) .. ')'
            end
        end
        if more > 0 then
            local strips2 = strips:getChildByIndex(MAX_STRIPS)
            strips2:setText(tr('+%d more', more + 1))
            strips2:setBackgroundColor('#34507a')
        end
        for _, span in ipairs(range and range.seasons or {}) do
            if span.startsAt < to and span.endsAt > from then
                cell:getChildById('seasonBand'):setBackgroundColor(span.color or '#ffffff')
            end
            if span.startsAt >= from and span.startsAt < to then
                local icon = cell:getChildById('season')
                icon:setImageSource('/modules/game_weather/images/season_' .. span.id)
                icon:show()
                local begins = tr('%s begins (%s)', span.name, os.date('%H:%M', span.startsAt))
                icon:setTooltip(begins)
                table.insert(tips, 1, begins)
            end
        end
        cell:setTooltip(#tips > 0 and table.concat(tips, '\n') or nil)
        local start = from
        cell.onClick = function()
            selectedDay = selectedDay ~= start and start or nil
            drawGrid()
        end
        day = to
    end
    drawList()
end

local function askRange()
    range = nil
    local from = gridStart(viewYear, viewMonth)
    local to = from
    for _ = 1, 42 do
        to = nextDay(to)
    end
    send({ action = 'range', from = from, to = to })
end

function changeMonth(step)
    viewMonth = viewMonth + step
    if viewMonth < 1 then
        viewYear, viewMonth = viewYear - 1, 12
    elseif viewMonth > 12 then
        viewYear, viewMonth = viewYear + 1, 1
    end
    selectedDay = nil
    askRange()
    drawGrid()
end

function showToday()
    local d = os.date('*t', now())
    viewYear, viewMonth, selectedDay = d.year, d.month, nil
    askRange()
    drawGrid()
end

function show()
    if not window or not g_game.isOnline() then
        return
    end
    if not window:isVisible() then
        local root = rootWidget:getSize()
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
            y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
    end
    window:show()
    window:raise()
    window:focus()
    showToday()
end

function hide()
    if window then
        window:hide()
    end
end

function toggle()
    if window and window:isVisible() then
        hide()
    else
        show()
    end
end

local function onCalendar(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Event calendar: invalid message')
        return
    end
    if data.now then
        offset = data.now - os.time()
    end
    if data.type == 'status' then
        status = data
        placeBanner()
        updateBanner()
    elseif data.type == 'range' and window then
        local from = gridStart(viewYear, viewMonth)
        if data.from == from then
            range = data
            drawGrid()
        end
    end
end

local function onGameStart()
    status, range = nil, nil
    placeBanner()
    send({ action = 'status' })
    -- the clock moves to the top bar or under the HUD right after the game starts
    removeEvent(placeEvent)
    placeEvent = scheduleEvent(placeBanner, 400)
end

local function onGameEnd()
    status, range = nil, nil
    removeEvent(placeEvent)
    placeEvent = nil
    if banner then
        banner:hide()
    end
    hide()
end

local function onTopMenuVisibility()
    if g_game.isOnline() then
        removeEvent(placeEvent)
        placeEvent = scheduleEvent(placeBanner, 50)
    end
end

function init()
    g_ui.importStyle('/modules/game_dailytasks/tasks')
    g_ui.importStyle('/modules/game_fishing/fishing')
    g_ui.importStyle('/modules/game_gts/gts')
    g_ui.importStyle('calendar')
    banner = g_ui.createWidget('CalendarBanner', modules.game_interface.getRootPanel())
    banner:setId('calendarBanner')
    banner.onClick = toggle
    banner:hide()
    window = g_ui.createWidget('CalendarWindow', rootWidget)
    window:hide()
    local weekdays = window:recursiveGetChildById('weekdays')
    for _, name in ipairs({ tr('Mon'), tr('Tue'), tr('Wed'), tr('Thu'), tr('Fri'), tr('Sat'), tr('Sun') }) do
        g_ui.createWidget('CalendarWeekday', weekdays):setText(name)
    end
    local d = os.date('*t')
    viewYear, viewMonth = d.year, d.month

    local topMenu = modules.client_topmenu and modules.client_topmenu.getTopMenu and modules.client_topmenu.getTopMenu()
    if topMenu then
        connect(topMenu, { onVisibilityChange = onTopMenuVisibility })
    end
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Calendar, onCalendar)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    tickEvent = cycleEvent(updateBanner, 1000)
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    local topMenu = modules.client_topmenu and modules.client_topmenu.getTopMenu and modules.client_topmenu.getTopMenu()
    if topMenu then
        disconnect(topMenu, { onVisibilityChange = onTopMenuVisibility })
    end
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Calendar)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    removeEvent(tickEvent)
    removeEvent(placeEvent)
    tickEvent, placeEvent = nil, nil
    if banner then
        banner:destroy()
    end
    if window then
        window:destroy()
    end
    banner, window, status, range = nil, nil, nil, nil
end
