-- The Admin window for staff (server lib Admin, 074-admin.lua). The client says {action = "hello"} at login;
-- the server answers {type = "state", access, online, events, multipliers, minutes} only to staff, so the top bar
-- button stays hidden for everyone else. Actions: refresh, start {event, multiplier, minutes}, stop {event},
-- broadcast {text}, save, clean; {type = "result", ok, text} answers them. The server checks the access again.
-- The Decorations tab: decorations, deco_add {set, item}, deco_remove {set}, deco_preview {set, minutes},
-- deco_auto {on}; {type = "decorations"} answers each with the sets, their props and the props saved nearby.
local IMAGES = '/modules/game_admin/images/'
local OK_COLOR = '#7ee08f'
local BAD_COLOR = '#ff8a8a'
local MUTED_COLOR = '#96aacd'
local RUNNING_COLOR = '#ffd75a'
local TICK_MS = 1000

-- staff commands that need a name, an id or a message after them; clicking one puts it in the chat line
local COMMANDS = {
    { '/goto ', 'Teleport to a player: /goto name' },
    { '/c ', 'Bring a player to you: /c name' },
    { '/town ', 'Teleport to a town: /town name' },
    { '/t', 'Teleport to your temple' },
    { '/i ', 'Create an item: /i id, count' },
    { '/m ', 'Summon a monster: /m name' },
    { '/r', 'Remove the thing in front of you' },
    { '/info ', 'Information about a player: /info name' },
    { '/kick ', 'Kick a player: /kick name' },
    { '/online', 'Players online' },
    { '/ghost', 'Turn invisible, or visible again' },
    { '/b ', 'Broadcast with your name: /b message' },
    { '/reload ', 'Reload scripts: /reload talkactions, actions, npcs...' },
    { '/closeserver', 'Close the server to players' },
    { '/openserver', 'Open the server to players again' },
}

local window
local button
local state -- the last {type = "state"} message
local receivedAt = 0
local picks = {} -- per event: { multiplier, minutes }
local tickEvent
local broadcasting = false -- the next result answers a broadcast
local tab = 'events'
local deco = { data = nil, set = nil, item = nil, askedAt = 0 }
local DECO_REFRESH_SECONDS = 5
local DECO_ROWS = 7

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Admin, data)
    end
end

local function duration(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local days, hours, mins = math.floor(seconds / 86400), math.floor(seconds % 86400 / 3600), math.floor(seconds % 3600 / 60)
    if days > 0 then
        return hours > 0 and tr('%dd %dh', days, hours) or tr('%dd', days)
    elseif hours > 0 then
        return mins > 0 and tr('%dh %dm', hours, mins) or tr('%dh', hours)
    elseif mins > 0 then
        return tr('%dm', mins)
    end
    return tr('%ds', seconds % 60)
end

local function multiplier(m)
    return (string.format('%.2f', m):gsub('0+$', ''):gsub('%.$', '')) .. 'x'
end

local function setResult(ok, text)
    local label = tab == 'decorations' and window.decorations.result or window.tools.result
    label:setText(text)
    label:setColor(ok and OK_COLOR or BAD_COLOR)
end

local function askDecorations()
    deco.askedAt = g_clock.seconds()
    send({ action = 'decorations' })
end

local function setName(id)
    for _, set in ipairs(deco.data and deco.data.sets or {}) do
        if set.id == id then
            return set.name
        end
    end
    return id or ''
end

local function fillDecoItems()
    local panel, data = window.decorations, deco.data
    local items = data.items[deco.set] or {}
    local found = false
    for _, item in ipairs(items) do
        found = found or item.id == deco.item
    end
    if not found then
        deco.item = items[1] and items[1].id
    end
    panel.items:destroyChildren()
    for _, item in ipairs(items) do
        local widget = g_ui.createWidget('AdminDecoItem', panel.items)
        widget.item:setItemId(tonumber(item.client) or 0)
        widget.name:setText(item.wall and tr('%s (wall)', item.name) or item.name)
        widget:setTooltip(tr('%s, item %d', item.name, item.id))
        widget:setOn(item.id == deco.item)
        widget.onClick = function()
            deco.item = item.id
            fillDecoItems()
        end
    end
    panel.place:setEnabled(deco.item ~= nil)
end

local function fillDecorations(data)
    deco.data = data
    local panel = window.decorations
    if not deco.set or not data.items[deco.set] then
        deco.set = data.theme or (data.sets[1] and data.sets[1].id)
    end

    panel.sets:destroyChildren()
    for _, set in ipairs(data.sets or {}) do
        local widget = g_ui.createWidget('AdminTab', panel.sets)
        widget:setSize({ width = 94, height = 24 })
        widget:setText(set.name)
        widget:setOn(set.id == deco.set)
        if set.id == data.theme then
            widget.pin:setVisible(true)
            widget:setTooltip(tr('Up now'))
        end
        widget.onClick = function()
            deco.set = set.id
            fillDecorations(deco.data)
        end
    end
    fillDecoItems()

    local status = tr('Up now: %s', data.theme and setName(data.theme) or tr('none'))
    if data.preview then
        status = status .. ' ' .. tr('(preview, %s left)', duration(data.preview.left))
    end
    panel.status:setText(status)
    panel.status:setColor(data.preview and RUNNING_COLOR or '#dce6ff')
    panel.remove:setTooltip(tr('Delete the %s prop saved on the tile you face', setName(deco.set)))
    if data.preview then
        panel.preview:setText(tr('End preview'))
        panel.preview:setTooltip(tr('Back to the set the calendar puts up'))
    else
        panel.preview:setText(tr('Preview %s', setName(deco.set)))
        panel.preview:setTooltip(tr('Put this set up for everyone for %d minutes', tonumber(data.previewMinutes) or 30))
    end
    if data.town then
        panel.auto:setText(data.town.auto and tr('Auto props: on') or tr('Auto props: off'))
        panel.auto:setTooltip(tr('%s: the props the server puts around the temple. Off: only the props saved by hand.', data.town.name))
        panel.auto:setEnabled(true)
    else
        panel.auto:setText(tr('Auto props'))
        panel.auto:setEnabled(false)
    end

    panel.spotsTitle:setText(tr('Saved within %d tiles of you', tonumber(data.radius) or 0))
    panel.spots:destroyChildren()
    local spots = data.spots or {}
    for index, spot in ipairs(spots) do
        if index > DECO_ROWS then
            break
        end
        local row = g_ui.createWidget('AdminDecoRow', panel.spots)
        row.item:setItemId(tonumber(spot.client) or 0)
        row.text:setText(tr('%s: %s at %d, %d, %d', setName(spot.set), spot.name, spot.x, spot.y, spot.z))
        if spot.valid then
            row.note:setText(tr('by %s', spot.by ~= '' and spot.by or '?'))
            row.note:setColor(MUTED_COLOR)
        else
            row.note:setText(tr('doesn\'t fit: %s', spot.why or ''))
            row.note:setColor(BAD_COLOR)
        end
    end
    if #spots == 0 then
        local row = g_ui.createWidget('AdminMuted', panel.spots)
        row:setText(tr('None yet: pick a set and a prop, face a tile or a wall and press Place.'))
    elseif #spots > DECO_ROWS then
        local row = g_ui.createWidget('AdminMuted', panel.spots)
        row:setText(tr('and %d more (/deco list shows them all)', #spots - DECO_ROWS))
    end
end

function showTab(name)
    tab = name
    window.tabs.eventsTab:setOn(name == 'events')
    window.tabs.decorationsTab:setOn(name == 'decorations')
    for _, id in ipairs({ 'events', 'tools', 'commands' }) do
        window[id]:setVisible(name == 'events')
    end
    window.decorations:setVisible(name == 'decorations')
    if name == 'decorations' then
        askDecorations()
    end
end

local function updateStatus()
    if not state then
        return
    end
    local passed = g_clock.seconds() - receivedAt
    for _, row in ipairs(window.events.rows:getChildren()) do
        local event = row.event
        local left = event.multiplier and (tonumber(event.left) or 0) - passed
        if left and left > 0 then
            row.status:setText(tr('Running: %s for %s more', multiplier(event.multiplier), duration(left)))
            row.status:setColor(RUNNING_COLOR)
            row.stop:setEnabled(true)
            row.start:setText(tr('Replace'))
        else
            row.status:setText(tr('Not running'))
            row.status:setColor(MUTED_COLOR)
            row.stop:setEnabled(false)
            row.start:setText(tr('Start'))
        end
    end
end

local function refreshPicks(row)
    local pick = picks[row.event.key]
    for _, tab in ipairs(row.multipliers:getChildren()) do
        tab:setOn(tab.value == pick.multiplier)
    end
    for _, tab in ipairs(row.durations:getChildren()) do
        tab:setOn(tab.value == pick.minutes)
    end
    row.start:setTooltip(tr('Start %s for %s', multiplier(pick.multiplier), duration(pick.minutes * 60)))
end

local function addTabs(row, box, values, label, field)
    box:destroyChildren()
    for _, value in ipairs(values) do
        local tab = g_ui.createWidget('AdminTab', box)
        tab.value = value
        tab:setText(label(value))
        tab.onClick = function()
            picks[row.event.key][field] = value
            refreshPicks(row)
        end
    end
end

local function fill(data)
    state = data
    receivedAt = g_clock.seconds()
    window.online:setText(tr('Players online: %d', tonumber(data.online) or 0))

    local multipliers = data.multipliers or { 2 }
    local minutes = data.minutes or { 60 }
    local rows = window.events.rows
    rows:destroyChildren()
    for _, event in ipairs(data.events or {}) do
        picks[event.key] = picks[event.key] or { multiplier = 2, minutes = 60 }
        local pick = picks[event.key]
        if not table.find(multipliers, pick.multiplier) then
            pick.multiplier = multipliers[1]
        end
        if not table.find(minutes, pick.minutes) then
            pick.minutes = minutes[1]
        end

        local row = g_ui.createWidget('AdminEventRow', rows)
        row.event = event
        row.name:setText(tr(event.label))
        row.command:setText(event.command or '')
        addTabs(row, row.multipliers, multipliers, multiplier, 'multiplier')
        addTabs(row, row.durations, minutes, function(m) return duration(m * 60) end, 'minutes')
        row.start.onClick = function()
            send({ action = 'start', event = event.key, multiplier = pick.multiplier, minutes = pick.minutes })
        end
        row.stop.onClick = function()
            send({ action = 'stop', event = event.key })
        end
        refreshPicks(row)
    end
    updateStatus()
end

local function tick()
    tickEvent = nil
    if window and window:isVisible() then
        updateStatus()
        if tab == 'decorations' and g_clock.seconds() - deco.askedAt >= DECO_REFRESH_SECONDS then
            askDecorations()
        end
        tickEvent = scheduleEvent(tick, TICK_MS)
    end
end

function show()
    if not window or not state then
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
    if button then
        button:setOn(true)
    end
    send({ action = 'refresh' })
    if tab == 'decorations' then
        askDecorations()
    end
    removeEvent(tickEvent)
    tickEvent = scheduleEvent(tick, TICK_MS)
end

function hide()
    if window then
        window:hide()
    end
    if button then
        button:setOn(false)
    end
    removeEvent(tickEvent)
    tickEvent = nil
end

function toggle()
    if window and window:isVisible() then
        hide()
    else
        show()
    end
end

local function onAdmin(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Admin: invalid message')
        return
    end
    if data.type == 'state' then
        fill(data)
        button:setVisible(true)
    elseif data.type == 'decorations' then
        fillDecorations(data)
    elseif data.type == 'result' and data.text then
        setResult(data.ok, data.text)
        if data.ok and broadcasting then
            window.tools.broadcastText:setText('')
        end
        broadcasting = false
    end
end

local function onGameStart()
    send({ action = 'hello' })
end

local function onGameEnd()
    state = nil
    hide()
    button:setVisible(false)
    window.tools.result:setText('')
    window.decorations.result:setText('')
    deco.data = nil
end

local function fillCommands()
    local list = window.commands.list
    for _, command in ipairs(COMMANDS) do
        local widget = g_ui.createWidget('AdminCommand', list)
        widget:setText((command[1]:gsub('%s+$', '')))
        widget:setTooltip(tr(command[2]))
        widget.onClick = function()
            local console = modules.game_console
            if console and console.setTextEditText then
                if console.isChatEnabled and console.toggleChat and not console.isChatEnabled() then
                    console.toggleChat()
                end
                console.setTextEditText(command[1])
                if console.consoleTextEdit then
                    console.consoleTextEdit:focus()
                end
            end
        end
    end
end

function init()
    g_ui.importStyle('admin')
    window = g_ui.createWidget('AdminWindow', rootWidget)
    window:hide()
    fillCommands()

    local tools = window.tools
    tools.broadcast.onClick = function()
        broadcasting = true
        send({ action = 'broadcast', text = tools.broadcastText:getText() })
    end
    tools.broadcastText.onKeyPress = function(self, keyCode)
        if keyCode == KeyEnter or keyCode == KeyReturn then
            tools.broadcast.onClick()
            return true
        end
        return false
    end
    tools.save.onClick = function() send({ action = 'save' }) end
    tools.clean.onClick = function() send({ action = 'clean' }) end

    local decorations = window.decorations
    decorations.place.onClick = function()
        send({ action = 'deco_add', set = deco.set, item = deco.item })
    end
    decorations.remove.onClick = function()
        send({ action = 'deco_remove', set = deco.set })
    end
    decorations.preview.onClick = function()
        if deco.data and deco.data.preview then
            send({ action = 'deco_preview' })
        else
            send({ action = 'deco_preview', set = deco.set, minutes = deco.data and deco.data.previewMinutes })
        end
    end
    decorations.auto.onClick = function()
        if deco.data and deco.data.town then
            send({ action = 'deco_auto', on = not deco.data.town.auto })
        end
    end
    decorations.refresh.onClick = askDecorations
    showTab('events')

    button = modules.client_topmenu.addRightGameToggleButton('adminButton', tr('Admin'), IMAGES .. 'button_admin', toggle)
    button:setVisible(false)

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Admin, onAdmin)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Admin)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    removeEvent(tickEvent)
    for _, widget in ipairs({ button, window }) do
        if widget then
            widget:destroy()
        end
    end
    button, window, state = nil, nil, nil
end
