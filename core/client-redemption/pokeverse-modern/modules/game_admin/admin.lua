-- The Admin window for staff (server lib Admin, 074-admin.lua). The client says {action = "hello"} at login;
-- the server answers {type = "state", access, ...} only to staff (access 1 and up), so the top bar button
-- stays hidden for everyone else. The tabs and buttons follow the staff member's access: most buttons run a
-- staff command ({action = "command", text}) that the server runs as the talkaction itself, so the command's
-- access in talkactions.xml decides, and {type = "commands"} lists the commands this staff member can use.
-- Events: start {event, multiplier, minutes}, stop {event}, broadcast {text, target = both/game/discord, ping}.
-- Players: players {filter} -> {type = "players"}, ban {name, days, reason, comment}, bans -> {type = "bans"}.
-- Decorations: decorations, deco_add {set, item}, deco_remove {set}, deco_preview {set, minutes}, deco_auto {on},
-- deco_item_add / deco_item_remove {set, item} (a set's prop list; that set's deco_items comes back);
-- {type = "decorations"} answers each, and the first request (catalog = true) also gets one
-- {type = "deco_items", set, items} per set. {type = "result", ok, text} answers the rest.
local IMAGES = '/modules/game_admin/images/'
local OK_COLOR = '#7ee08f'
local BAD_COLOR = '#ff8a8a'
local MUTED_COLOR = '#96aacd'
local RUNNING_COLOR = '#ffd75a'
local TICK_MS = 1000
local DECO_REFRESH_SECONDS = 5
local PLAYERS_REFRESH_SECONDS = 5
local BAN_CONFIRM_MS = 4000

local TABS = { 'boosts', 'events', 'players', 'world', 'decorations', 'server', 'commands' }
local STAFF_NAMES = { 'Tutor', 'Senior Tutor', 'Gamemaster', 'Community Manager', 'God' }
local COMMAND_GROUPS = { 'Players', 'Moving', 'Staff', 'Events', 'World', 'Server', 'Other' }
local BAN_REASON_LABELS = { [4] = 'Offensive talk', [5] = 'Spamming', [6] = 'Advertising', [10] = 'Bug abuse',
                            [11] = 'Game weakness abuse', [12] = 'Bots or cheats', [14] = 'Multi-clienting',
                            [15] = 'Account trading', [19] = 'Destructive' }

-- the Players tab's buttons: each runs "<words> <the player's name>"
local PLAYER_ACTIONS = {
    { 'Go to', '/goto', 'Teleport to the player' },
    { 'Bring here', '/c', 'Bring the player to you' },
    { 'Kick', '/kick', 'Disconnect the player' },
    { 'Chat ban 1h', '/chatban', 'Mute the player in every chat channel for 60 minutes' },
    { 'Info', '/info', 'Character and account details' },
    { 'Notations', '/notations', 'Notations on the account' },
    { 'Ban info', '/baninfo', 'Why and until when the account is banned' },
    { 'Unban', '/unban', 'Lift the account ban, IP ban or namelock' },
    { 'Promote', '/promote', 'One staff group up' },
    { 'Demote', '/demote', 'One staff group down' },
}

-- the Server tab: { label, { { button, command, tooltip } } }
local SERVER_SECTIONS = {
    { 'Saves', { { 'Save now', '/save' }, { 'Clean map', '/clean' },
                         { 'Clean in 5 min', '/clean 5', 'Warn everyone, then remove the items on the map' } } },
    { 'Restart', { { 'In 5 min', '/restart 5' }, { 'In 15 min', '/restart 15' }, { 'In 30 min', '/restart 30' },
                   { 'In 60 min', '/restart 60' }, { 'Cancel', '/restart cancel' }, { 'Status', '/restart' },
                   { 'Announce', '/restart announce', 'Broadcast the time left' } } },
    { 'Access', { { 'Close server', '/closeserver', 'Only staff can log in' }, { 'Open server', '/openserver' },
                  { 'Who\'s online', '/online' }, { 'Same IP', '/mc' }, { 'Reports', '/reports' } } },
    { 'PvP', { { 'No PvP', '/mode nopvp' }, { 'PvP', '/mode pvp' }, { 'PvP enforced', '/mode pvpenforced' } } },
    { 'Me', { { 'Ghost', '/ghost', 'Turn invisible, or visible again' }, { 'Ignore PMs', '/squelch' },
              { 'Click teleport', '/cliport', 'Teleport where you click on the map' }, { 'Temple', '/t' } } },
    { 'Reload', {} },
    { 'Diagnostics', { { 'Server diag', '/serverdiag' }, { 'Calendar', '/calendar' }, { 'Weather', '/weather status' },
                       { 'Legendaries', '/legendary status' }, { 'Anniversary', '/anniversary status' } } },
    { 'Anniversary', { { 'Show entrance', '/anniversary show', 'Show the Union Room sign and teleport for 30 minutes, to test the cake town' },
                       { 'Hide entrance', '/anniversary hide' },
                       { 'Event on', '/anniversary on', 'Force the Anniversary on: bonuses, gifts and the cake town' },
                       { 'Event off', '/anniversary off', 'Force it off: the Union Room entrance hides and the town empties' },
                       { 'Event auto', '/anniversary auto', 'Back to its dates' },
                       { 'Start invasion', '/anniversary start' }, { 'Boss', '/anniversary boss', 'Bring out the Mad Big Cake' },
                       { 'Reset', '/anniversary reset', 'Clear the invasion' } } },
}
for _, name in ipairs({ 'talkactions', 'actions', 'creaturescripts', 'globalevents', 'movements', 'npcs', 'monsters',
                        'items', 'spells', 'raids', 'quests', 'outfits', 'vocations', 'stages', 'groups', 'chat',
                        'config', 'mods', 'all' }) do
    table.insert(SERVER_SECTIONS[6][2], { name, '/reload ' .. name })
end

local WEATHER_MINUTES = { 30, 60, 180, 360, 1440, 0 }
local CLOCK = { { 'Dawn', 'dawn' }, { 'Day', 'day' }, { 'Dusk', 'dusk' }, { 'Night', 'night' } }

local window
local button
local state -- the last {type = "state"} message
local receivedAt = 0
local picks = {} -- per event: { multiplier, minutes }
local tickEvent
local broadcasting = false -- the next result answers a broadcast
local broadcastTarget = 'both' -- 'both', 'game' or 'discord'
local broadcastPing = '' -- '' (none) or one of state.pings' ids
local tab
local deco = { data = nil, items = {}, set = nil, item = nil, askedAt = 0 }
local commands = { byWords = nil, list = {}, parts = {} } -- what this staff member may run
local commandButtons = {} -- { widget, words }
local players = { list = {}, towns = {}, askedAt = 0, searchEvent = nil }
local banPick = { days = 7, reason = nil, confirmEvent = nil }
local world = { built = false, target = 'here', kind = 'rain', minutes = 60, holiday = nil }
local legendary = { built = false, pick = nil }

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Admin, data)
    end
end

local function trim(text)
    return ((text or ''):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function access()
    return state and tonumber(state.access) or 0
end

-- the logged-in staff member's access (0: not staff, or not logged in); client_terminal uses it
function getAccess()
    return access()
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
    local label = tab == 'decorations' and window.decorations.result or window.result
    label:setText(text)
    label:setColor(ok and OK_COLOR or BAD_COLOR)
end

-- commands ----------------------------------------------------------------------------------------

local function allowed(words)
    return commands.byWords ~= nil and commands.byWords[words:lower()] ~= nil
end

local function run(text)
    text = trim(text)
    if text == '' then
        return setResult(false, tr('Type a command.'))
    end
    send({ action = 'command', text = text })
end

local function refreshCommandButtons()
    local alive = {}
    for _, entry in ipairs(commandButtons) do
        if not entry.widget:isDestroyed() then
            entry.widget:setEnabled(allowed(entry.words))
            table.insert(alive, entry)
        end
    end
    commandButtons = alive
end

-- a button that runs a command; build() returns the command, or nil and why not
local function commandButton(parent, style, text, words, build, tooltip)
    local widget = g_ui.createWidget(style, parent)
    widget:setText(tr(text))
    widget.onClick = function()
        local command, why = build()
        if command then
            run(command)
        else
            setResult(false, why)
        end
    end
    if tooltip then
        widget:setTooltip(tr(tooltip))
    end
    table.insert(commandButtons, { widget = widget, words = words })
    widget:setEnabled(allowed(words))
    return widget
end

local function fixedCommand(command)
    return function() return command end
end

local function fillCommandList()
    local panel = window.commands.panel
    local list = panel.list
    list:destroyChildren()
    local filter = (trim(panel.text:getText()):match('^(%S*)') or ''):lower()
    local shown = 0
    for _, group in ipairs(COMMAND_GROUPS) do
        local heading
        for _, entry in ipairs(commands.list) do
            if (entry.group or 'Other') == group and entry.words:lower():find(filter, 1, true) == 1 then
                if not heading then
                    heading = g_ui.createWidget('AdminCommandHeading', list)
                    heading:setText(tr(group))
                end
                local row = g_ui.createWidget('AdminCommandRow', list)
                row.words:setText(entry.words)
                local words = entry.words:gsub('%p', '%%%0')
                row.usage:setText((entry.usage:gsub('^' .. words .. '%s*', '')))
                row.help:setText(tr(entry.help or ''))
                row.access:setText(STAFF_NAMES[tonumber(entry.access)] or '')
                row.onClick = function()
                    local takesParams = entry.usage ~= entry.words
                    panel.text:setText(entry.words .. (takesParams and ' ' or ''))
                    panel.text:setCursorPos(-1)
                    panel.text:focus()
                end
                shown = shown + 1
            end
        end
    end
    if shown == 0 then
        local label = g_ui.createWidget('AdminMuted', list)
        label:setText(commands.byWords and tr('No staff command starts with %s.', filter) or tr('Loading...'))
    end
end

local function onCommands(data)
    if tonumber(data.part) == 1 then
        commands.parts = {}
    end
    commands.parts[tonumber(data.part) or 1] = data.commands or {}
    local parts = tonumber(data.parts) or 1
    for part = 1, parts do
        if not commands.parts[part] then
            return
        end
    end
    commands.list, commands.byWords = {}, {}
    for part = 1, parts do
        for _, entry in ipairs(commands.parts[part]) do
            table.insert(commands.list, entry)
            commands.byWords[entry.words:lower()] = entry
        end
    end
    refreshCommandButtons()
    fillCommandList()
end

-- events ------------------------------------------------------------------------------------------

local function updateStatus()
    if not state then
        return
    end
    local passed = g_clock.seconds() - receivedAt
    local canRun = access() >= (tonumber(state.eventsAccess) or 5)
    for _, row in ipairs(window.boosts.eventsPanel.rows:getChildren()) do
        local event = row.event
        local left = event.multiplier and (tonumber(event.left) or 0) - passed
        if left and left > 0 then
            row.status:setText(tr('Running: %s for %s more', multiplier(event.multiplier), duration(left)))
            row.status:setColor(RUNNING_COLOR)
            row.stop:setEnabled(canRun)
            row.start:setText(tr('Replace'))
        else
            row.status:setText(tr('Not running'))
            row.status:setColor(MUTED_COLOR)
            row.stop:setEnabled(false)
            row.start:setText(tr('Start'))
        end
        row.start:setEnabled(canRun)
    end
end

local function refreshPicks(row)
    local pick = picks[row.event.key]
    for _, widget in ipairs(row.multipliers:getChildren()) do
        widget:setOn(widget.value == pick.multiplier)
    end
    for _, widget in ipairs(row.durations:getChildren()) do
        widget:setOn(widget.value == pick.minutes)
    end
    row.start:setTooltip(tr('Start %s for %s', multiplier(pick.multiplier), duration(pick.minutes * 60)))
end

local function addTabs(row, box, values, label, field)
    box:destroyChildren()
    for _, value in ipairs(values) do
        local widget = g_ui.createWidget('AdminTab', box)
        widget.value = value
        widget:setText(label(value))
        widget.onClick = function()
            picks[row.event.key][field] = value
            refreshPicks(row)
        end
    end
end

local function fillEvents(data)
    local multipliers = data.multipliers or { 2 }
    local minutes = data.minutes or { 60 }
    local rows = window.boosts.eventsPanel.rows
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

-- one-pick rows of AdminTabs: options = { { value, text[, tooltip] } }
local function pickRow(box, options, current, onPick, width)
    box:destroyChildren()
    for _, option in ipairs(options) do
        local widget = g_ui.createWidget('AdminTab', box)
        widget:setText(tr(option[2]))
        if width then
            widget:setWidth(width)
        end
        if option[3] then
            widget:setTooltip(tr(option[3]))
        end
        widget.value = option[1]
        widget:setOn(option[1] == current)
        widget.onClick = function()
            for _, other in ipairs(box:getChildren()) do
                other:setOn(other == widget)
            end
            onPick(option[1])
        end
    end
end

local function fillCalendar(info)
    local panel = window.boosts.calendar
    panel.seasons:destroyChildren()
    for _, season in ipairs(info.seasons or {}) do
        local widget = commandButton(panel.seasons, 'AdminTab', season.name, '/calendar',
            fixedCommand('/calendar season ' .. season.id), 'Make it ' .. season.name .. ' everywhere until you put it back')
        widget:setWidth(96)
    end
    commandButton(panel.seasons, 'AdminTab', 'By date', '/calendar', fixedCommand('/calendar season auto'),
        'Back to the season of the date'):setWidth(96)

    local holidays = {}
    for _, holiday in ipairs(info.holidays or {}) do
        table.insert(holidays, { holiday.id, holiday.name })
    end
    world.holiday = world.holiday or (holidays[1] and holidays[1][1])
    pickRow(panel.holidays, holidays, world.holiday, function(id) world.holiday = id end)
    panel.holidayButtons:destroyChildren()
    for _, entry in ipairs({ { 'On', 'on', 'Run the holiday now' }, { 'Off', 'off', 'Stop it, even on its dates' },
                             { 'By date', 'auto', 'Back to its dates' } }) do
        commandButton(panel.holidayButtons, 'AdminTab', entry[1], '/calendar', function()
            return world.holiday and ('/calendar holiday ' .. world.holiday .. ' ' .. entry[2]), tr('Pick a holiday.')
        end, entry[3]):setWidth(96)
    end
    commandButton(panel.holidayButtons, 'AdminTab', 'Show calendar', '/calendar', fixedCommand('/calendar'),
        'What runs now and next'):setWidth(110)
end

-- players -----------------------------------------------------------------------------------------

local function askPlayers()
    players.askedAt = g_clock.seconds()
    send({ action = 'players', filter = trim(window.players.online.search:getText()) })
end

local function askBans()
    if access() >= (tonumber(state and state.banAccess) or 3) then
        send({ action = 'bans' })
    end
end

local function selectedName()
    local name = trim(window.players.player.name:getText())
    if name == '' then
        return nil, tr('Type or pick a player first.')
    end
    return name
end

local function updatePlayerInfo()
    local panel = window.players.player
    local name = trim(panel.name:getText()):lower()
    local found
    for _, entry in ipairs(players.list) do
        if entry.name:lower() == name then
            found = entry
        end
    end
    if found then
        panel.info:setText(tr('Online, level %d%s, at %d, %d, %d%s', found.level,
            found.place and (' ' .. tr('in %s', found.place)) or '', found.x, found.y, found.z,
            tonumber(found.access) > 0 and (' - ' .. (STAFF_NAMES[tonumber(found.access)] or '')) or ''))
    elseif name ~= '' then
        panel.info:setText(tr('Not online: bans, unbans, notations and ban info still work.'))
    else
        panel.info:setText('')
    end
    for _, row in ipairs(window.players.online.list:getChildren()) do
        if row.playerName then
            row:setOn(row.playerName:lower() == name)
        end
    end
end

local function fillPlayers(data)
    players.list = data.players or {}
    local panel = window.players.online
    panel.list:destroyChildren()
    for _, entry in ipairs(players.list) do
        local row = g_ui.createWidget('AdminPlayerRow', panel.list)
        row.playerName = entry.name
        row:setText(entry.name)
        local staff = STAFF_NAMES[tonumber(entry.access)]
        row.level:setText(staff and tr('%s, Lv %d', staff, entry.level) or tr('Lv %d', entry.level))
        row.onClick = function()
            window.players.player.name:setText(entry.name)
            updatePlayerInfo()
        end
    end
    local total = tonumber(data.total) or #players.list
    if total > #players.list then
        panel.count:setText(tr('Showing %d of %d: search to find the rest', #players.list, total))
    else
        panel.count:setText(tr('%d player(s)', total))
    end

    local towns = data.towns or {}
    if #towns ~= #players.towns then
        players.towns = towns
        local box = window.players.player.towns
        box:destroyChildren()
        for _, town in ipairs(towns) do
            commandButton(box, 'AdminTab', town.name, '/town', function()
                local name, why = selectedName()
                return name and string.format('/town %d,%s', town.id, name), why
            end, 'Send the player to ' .. town.name .. '\'s temple')
        end
    end
    updatePlayerInfo()
end

local function fillBans(data)
    local list = window.players.bans.list
    list:destroyChildren()
    for _, ban in ipairs(data.bans or {}) do
        local row = g_ui.createWidget('AdminBanRow', list)
        local names = ban.names or {}
        row.names:setText(#names > 0 and table.concat(names, ', ') or tr('Account %d', ban.account))
        local left = tonumber(ban.left) or -1
        row.detail:setText(tr('%s, %s%s', ban.reason or '', left < 0 and tr('for good') or tr('%s left', duration(left)),
            (ban.by or '') ~= '' and (', ' .. tr('by %s', ban.by)) or ''))
        row:setTooltip(ban.comment ~= '' and ban.comment or nil)
        row.unban:setEnabled(names[1] ~= nil and allowed('/unban'))
        row.unban.onClick = function()
            run('/unban ' .. names[1])
            scheduleEvent(askBans, 600)
        end
    end
    if #(data.bans or {}) == 0 then
        g_ui.createWidget('AdminMuted', list):setText(tr('No account is banned.'))
    end
end

local function fillBanPicks()
    local panel = window.players.player
    local days = {}
    for _, value in ipairs(state.banDays or {}) do
        table.insert(days, { value, value == 0 and 'For good' or (value .. 'd') })
    end
    if not table.find(state.banDays or {}, banPick.days) then
        banPick.days = days[1] and days[1][1]
    end
    pickRow(panel.banDays, days, banPick.days, function(value) banPick.days = value end, 80)
    local reasons = {}
    for _, reason in ipairs(state.banReasons or {}) do
        table.insert(reasons, { reason.id, BAN_REASON_LABELS[reason.id] or reason.name, reason.name })
    end
    pickRow(panel.banReasons, reasons, banPick.reason, function(value) banPick.reason = value end)
end

local function resetBanButton()
    removeEvent(banPick.confirmEvent)
    banPick.confirmEvent = nil
    window.players.player.ban:setText(tr('Ban'))
end

local function onBan()
    local name, why = selectedName()
    if not name then
        return setResult(false, why)
    elseif not banPick.reason then
        return setResult(false, tr('Pick why.'))
    end
    if not banPick.confirmEvent then
        window.players.player.ban:setText(tr('Confirm'))
        banPick.confirmEvent = scheduleEvent(resetBanButton, BAN_CONFIRM_MS)
        return setResult(true, tr('Press Confirm to ban %s\'s account %s.', name,
            banPick.days == 0 and tr('for good') or tr('for %d day(s)', banPick.days)))
    end
    resetBanButton()
    send({ action = 'ban', name = name, days = banPick.days, reason = banPick.reason,
           comment = window.players.player.banComment:getText() })
    window.players.player.banComment:setText('')
    scheduleEvent(askPlayers, 600)
end

-- world -------------------------------------------------------------------------------------------

local function weatherCommand(rest)
    return '/weather ' .. world.target .. ' ' .. rest
end

-- one switch per region (maintenance): weather and decorations on or off; the state comes back
-- with every refresh
local function fillRegions(info)
    local row = window.world.weather.regions
    row:destroyChildren()
    for _, region in ipairs(info.regions or {}) do
        local on = region.on ~= false
        commandButton(row, on and 'PVGreenButton' or 'PVRedButton', tr(on and '%s: on' or '%s: off', region.name), '/weather',
            function()
                scheduleEvent(function() send({ action = 'refresh' }) end, 500)
                return string.format('/weather region %s %s', region.id, on and 'off' or 'on')
            end, on and 'Switch off its weather and decorations, for maintenance' or 'Switch its weather and decorations back on'):setWidth(140)
    end
end

local function fillWorld(info)
    local panel = window.world
    local weather = panel.weather
    local targets = { { 'here', 'Here', 'The zone you stand in' } }
    for _, region in ipairs(info.regions or {}) do
        table.insert(targets, { region.id, region.name })
    end
    table.insert(targets, { 'all', 'Everywhere' })
    pickRow(weather.targets, targets, world.target, function(value) world.target = value end, 96)

    local kinds = {}
    for _, kind in ipairs(info.kinds or {}) do
        table.insert(kinds, { kind.id, kind.name })
    end
    pickRow(weather.kinds, kinds, world.kind, function(value) world.kind = value end)

    local minutes = {}
    for _, value in ipairs(WEATHER_MINUTES) do
        table.insert(minutes, { value, value == 0 and 'Until auto' or duration(value * 60) })
    end
    pickRow(weather.durations, minutes, world.minutes, function(value) world.minutes = value end, 80)

    weather.buttons:destroyChildren()
    commandButton(weather.buttons, 'PVGreenButton', 'Set weather', '/weather', function()
        return weatherCommand(world.kind .. (world.minutes > 0 and (' ' .. world.minutes) or ''))
    end):setWidth(130)
    commandButton(weather.buttons, 'PVBlueButton', 'Back to auto', '/weather', function()
        return weatherCommand('auto')
    end, 'Back to the rolled weather there'):setWidth(130)
    commandButton(weather.buttons, 'PVBlueButton', 'Clear all staff weather', '/weather', fixedCommand('/weather off'),
        'Every zone back to the rolled weather'):setWidth(190)
    commandButton(weather.buttons, 'PVBlueButton', 'Status', '/weather', fixedCommand('/weather status'),
        'Every live zone\'s weather'):setWidth(100)
    for _, button in ipairs(weather.buttons:getChildren()) do
        button:setHeight(30)
    end

    weather.clock:destroyChildren()
    for _, entry in ipairs(CLOCK) do
        commandButton(weather.clock, 'AdminTab', entry[1], '/weather', fixedCommand('/weather time ' .. entry[2]),
            'Move the day and night cycle'):setWidth(80)
    end

    fillCalendar(info)
    world.built = true
end

-- events: the wild legendaries ------------------------------------------------------------------

local function askState()
    send({ action = 'refresh' })
end

-- a /legendary button; the status comes back a moment after it runs
local function legendaryButton(parent, style, text, build, tooltip)
    return commandButton(parent, style, text, '/legendary', function()
        local command, why = build()
        if command then
            scheduleEvent(askState, 800)
        end
        return command, why
    end, tooltip)
end

local function withPick(format)
    return function()
        return legendary.pick and string.format(format, legendary.pick), tr('Pick a legendary.')
    end
end

local TIER_NAMES = { 'Legendary', 'Major legendary', 'Mythical' }

local function fillLegendaryStatus(info)
    local panel = window.events.legendaries
    for _, widget in ipairs(panel.mode:getChildren()) do
        widget:setOn((widget.manual == true) == (info.manual == true))
    end
    local status = panel.status
    status:destroyChildren()
    local function line(text, color)
        local label = g_ui.createWidget('AdminText', status)
        label:setText(text)
        label:setTextAutoResize(true)
        if color then
            label:setColor(color)
        end
    end
    for _, a in ipairs(info.active or {}) do
        if a.flying then
            line(tr('%s %s over %s: %d%%, lands in %s, leaves in %s%s', a.name, a.area or tr('in the air'), a.zone or '?',
                tonumber(a.health) or 0, duration(a.landsIn), duration(a.left), a.set and tr(', set') or ''), RUNNING_COLOR)
        else
            local state = a.disguised and tr(' (disguised as %s)', a.disguised) or (a.asleep and tr(' (asleep)') or '')
            line(tr('%s%s near %s: %d%%, leaves in %s, at %d, %d, %d%s', a.name, state, a.area or '?', tonumber(a.health) or 0,
                duration(a.left), a.x, a.y, a.z, a.set and tr(', set') or ''), RUNNING_COLOR)
        end
    end
    for _, p in ipairs(info.pending or {}) do
        line(tr('%s: warning, appears in %s', p.name, duration(p.left)), RUNNING_COLOR)
    end
    for _, text in ipairs(info.events or {}) do
        line(text, RUNNING_COLOR)
    end
    if #(info.active or {}) == 0 and #(info.pending or {}) == 0 then
        line(tr('None out right now.'), MUTED_COLOR)
    end
    line(tr('Mythical slot: %s', info.mythical or tr('free')))
    if info.manual then
        line(tr('Manual: no scheduled spawns.'), MUTED_COLOR)
    else
        line(info.nextIn and tr('Next scheduled spawn in %s%s', duration(info.nextIn),
            info.blocked and (' (' .. info.blocked .. ')') or '') or tr('No spawn scheduled yet.'))
    end
    local cooling = {}
    for _, c in ipairs(info.cooldowns or {}) do
        table.insert(cooling, c.name .. ' ' .. duration(c.left))
    end
    line(tr('Cooldowns: %s', #cooling > 0 and table.concat(cooling, ', ') or tr('none')), MUTED_COLOR)
end

local function fillLegendaries(info)
    local panel = window.events.legendaries
    if not legendary.built then
        panel.mode:destroyChildren()
        for _, entry in ipairs({ { 'Auto', false, 'Spawn on the schedule' },
                                 { 'Manual', true, 'Only staff start them; what is out stays' } }) do
            local widget = legendaryButton(panel.mode, 'AdminTab', entry[1],
                fixedCommand('/legendary mode ' .. (entry[2] and 'manual' or 'auto')), entry[3])
            widget.manual = entry[2]
            widget:setWidth(80)
        end
        panel.sets:destroyChildren()
        for _, set in ipairs(info.sets or {}) do
            legendaryButton(panel.sets, 'AdminTab', set.name, fixedCommand('/legendary set ' .. set.id),
                'Spawn them together; one already out is skipped'):setWidth(140)
        end

        local species = {}
        for _, s in ipairs(info.species or {}) do
            table.insert(species, { s.name, s.name, tr('%s, moves: %s', tr(TIER_NAMES[tonumber(s.tier)] or ''), s.style or '') })
        end
        legendary.pick = legendary.pick or (species[1] and species[1][1])
        pickRow(panel.species, species, legendary.pick, function(value) legendary.pick = value end)

        local buttons = panel.buttons
        buttons:destroyChildren()
        legendaryButton(buttons, 'PVGreenButton', 'Spawn in its habitat', withPick('/legendary spawn %s'),
            'Regis come asleep, Mew in disguise')
        legendaryButton(buttons, 'PVGreenButton', 'Spawn at my feet', withPick('/legendary spawn %s here'))
        legendaryButton(buttons, 'PVRedButton', 'Send away', withPick('/legendary end %s'), 'Without a cooldown')
        legendaryButton(buttons, 'PVBlueButton', 'Move it now', withPick('/legendary move %s'), 'The way it moves')
        legendaryButton(buttons, 'PVBlueButton', 'Health 50%%', withPick('/legendary health %s 50'))
        legendaryButton(buttons, 'PVBlueButton', 'Health 100%%', withPick('/legendary health %s 100'))
        legendaryButton(buttons, 'PVBlueButton', 'Clear its cooldown', withPick('/legendary cooldowns clear %s'))
        legendaryButton(buttons, 'PVBlueButton', 'Show its signs', withPick('/legendary signs %s'),
            'Its signs and trail now, and the spots in the chat')
        legendaryButton(buttons, 'PVBlueButton', 'Fly-over (me only)', withPick('/legendary flyover %s'),
            'It crosses your screen; nobody else sees it and nothing spawns')
        legendaryButton(buttons, 'PVBlueButton', 'Dive-over (me only)', withPick('/legendary flyover %s dive'),
            'The dark shape under the water, for Lugia and Kyogre')

        local special = panel.special
        special:destroyChildren()
        legendaryButton(special, 'PVGreenButton', 'Mew disguised here', fixedCommand('/legendary mew here'),
            'Mew as a Pokemon of this spot')
        legendaryButton(special, 'PVBlueButton', 'Reveal Mew', fixedCommand('/legendary reveal'))
        legendaryButton(special, 'PVBlueButton', 'Wake the Regi', withPick('/legendary wake %s'), 'Pick a sleeping Regi first')
        legendaryButton(special, 'PVGreenButton', 'Mewtwo warning', fixedCommand('/legendary warn'),
            'The psychic disturbance, then Mewtwo in its habitat')
        legendaryButton(special, 'PVGreenButton', 'Mewtwo warning here', fixedCommand('/legendary warn here'))
        legendaryButton(special, 'PVGreenButton', "Rayquaza's event", fixedCommand('/legendary rayquaza'),
            'Groudon and Kyogre out (if they are not), then Rayquaza comes down to them')
        legendaryButton(special, 'PVBlueButton', 'Meteor shower here', fixedCommand('/legendary meteors'),
            "Jirachi's shower at your feet, nothing spawns")
        legendaryButton(special, 'PVBlueButton', 'Meteor impact here', fixedCommand('/legendary impact'),
            "Deoxys's impact at your feet, nothing spawns")
        legendaryButton(special, 'PVBlueButton', 'Next spawn in 5 min', fixedCommand('/legendary next 5m'))
        legendaryButton(special, 'PVBlueButton', 'Clear all cooldowns', fixedCommand('/legendary cooldowns clear'))
        legendaryButton(special, 'PVBlueButton', 'Status in chat', fixedCommand('/legendary status'))
        panel.refresh.onClick = askState
        legendary.built = true
    end
    fillLegendaryStatus(info)
end

-- server ------------------------------------------------------------------------------------------

local function buildServer()
    local box = window.server.panel.sections
    box:destroyChildren()
    for _, section in ipairs(SERVER_SECTIONS) do
        local row = g_ui.createWidget('AdminSection', box)
        row.label:setText(tr(section[1]))
        local perRow = 5
        local lines = math.ceil(#section[2] / perRow)
        row:setHeight(lines * 26 + (lines - 1) * 6)
        for _, entry in ipairs(section[2]) do
            local widget = commandButton(row.buttons, 'AdminSectionButton', entry[1], entry[2]:match('^(%S+)'),
                fixedCommand(entry[2]), (entry[3] and (entry[3] .. ': ') or '') .. entry[2])
            if entry[2] == '/reports' and modules.game_reports then
                widget:setTooltip(tr('Open the Reports window: every bug and player report, with their status'))
                widget.onClick = function() modules.game_reports.openStaff() end
            end
        end
    end
end

-- decorations -------------------------------------------------------------------------------------

local function askDecorations()
    deco.askedAt = g_clock.seconds()
    send({ action = 'decorations', catalog = next(deco.items) == nil })
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
    local panel = window.decorations
    local items = deco.items[deco.set] or {}
    local selected = nil
    for _, item in ipairs(items) do
        selected = item.id == deco.item and item or selected
    end
    if not selected then
        selected = items[1]
        deco.item = selected and selected.id
    end
    panel.items:destroyChildren()
    for _, item in ipairs(items) do
        local widget = g_ui.createWidget('AdminDecoItem', panel.items)
        widget.item:setItemId(tonumber(item.client) or 0)
        widget.name:setText(item.wall and tr('%s (wall)', item.name) or item.name)
        widget:setTooltip(item.custom and tr('%s, item %d (added to the list)', item.name, item.id) or tr('%s, item %d', item.name, item.id))
        widget:setOn(item.id == deco.item)
        widget.onClick = function()
            deco.item = item.id
            fillDecoItems()
        end
    end
    panel.place:setEnabled(deco.item ~= nil)
    panel.itemRemove:setEnabled(selected ~= nil and selected.custom == true)
    panel.itemRemove:setTooltip(selected and selected.custom and tr('Take %s off %s\'s list', selected.name, setName(deco.set))
        or tr('Only the props added to the list can be taken off it'))
    panel.itemAdd:setTooltip(tr('Add the item id to %s\'s list', setName(deco.set)))
end

local function fillDecorations(data)
    deco.data = data
    local panel = window.decorations
    if not deco.set or not deco.items[deco.set] then
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
    local spots, total = data.spots or {}, tonumber(data.total) or 0
    for _, spot in ipairs(spots) do
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
    elseif total > #spots then
        local row = g_ui.createWidget('AdminMuted', panel.spots)
        row:setText(tr('and %d more (/deco list shows them all)', total - #spots))
    end
end

-- tabs and state ----------------------------------------------------------------------------------

local function tabAccess(name)
    local events = tonumber(state and state.eventsAccess) or 5
    local needs = { boosts = tonumber(state and state.broadcastAccess) or 3, events = events, players = 1, world = events,
                    decorations = events, server = 3, commands = 1 }
    return needs[name] or 5
end

function showTab(name)
    if access() < tabAccess(name) then
        name = 'commands'
        for _, id in ipairs(TABS) do
            if access() >= tabAccess(id) then
                name = id
                break
            end
        end
    end
    tab = name
    for _, id in ipairs(TABS) do
        window.tabs[id .. 'Tab']:setOn(id == name)
        window[id]:setVisible(id == name)
    end
    window.result:setText('')
    if name == 'decorations' then
        askDecorations()
    elseif name == 'players' then
        askPlayers()
        askBans()
    end
end

local function refreshAccess()
    for _, id in ipairs(TABS) do
        window.tabs[id .. 'Tab']:setVisible(access() >= tabAccess(id))
    end
    local canBroadcast = access() >= (tonumber(state.broadcastAccess) or 3)
    window.boosts.tools.broadcast:setEnabled(canBroadcast)
    window.boosts.tools.broadcastText:setEnabled(canBroadcast)
    window.boosts.tools.ping:setEnabled(canBroadcast and broadcastTarget ~= 'game')
    local canBan = access() >= (tonumber(state.banAccess) or 3)
    window.players.player.ban:setEnabled(canBan)
    window.players.bans:setVisible(canBan)
end

-- The Discord pings the server lets this staff member pick; the pick stays while it's still offered.
local function fillPings(pings)
    local combo = window.boosts.tools.ping
    combo.onOptionChange = nil
    combo:clearOptions()
    combo:addOption(tr('No Discord ping'), '')
    local kept = false
    for _, ping in ipairs(type(pings) == 'table' and pings or {}) do
        combo:addOption(tostring(ping.label or ping.id), tostring(ping.id))
        kept = kept or tostring(ping.id) == broadcastPing
    end
    if not kept then
        broadcastPing = ''
    end
    combo:setCurrentOptionByData(broadcastPing, true)
    combo.onOptionChange = function(_, _, id) broadcastPing = id or '' end
end

local function fill(data)
    state = data
    receivedAt = g_clock.seconds()
    window.online:setText(tr('Players online: %d', tonumber(data.online) or 0))
    fillEvents(data)
    fillPings(data.pings)
    fillBanPicks()
    if data.world and not world.built then
        fillWorld(data.world)
    end
    if data.world then
        fillRegions(data.world)
        if data.world.legendary then
            fillLegendaries(data.world.legendary)
        elseif not legendary.built then
            local status = window.events.legendaries.status
            status:destroyChildren()
            local label = g_ui.createWidget('AdminText', status)
            label:setText(tr('The server sent no legendary controls: it is older than this client. Deploy the server to get them.'))
            label:setTextAutoResize(true)
            label:setColor(MUTED_COLOR)
        end
    end
    refreshAccess()
    if not commands.byWords then
        send({ action = 'commands' })
    end
    if not tab or access() < tabAccess(tab) then
        showTab(tab or 'boosts')
    end
end

local function tick()
    tickEvent = nil
    if window and window:isVisible() then
        updateStatus()
        local now = g_clock.seconds()
        if tab == 'decorations' and now - deco.askedAt >= DECO_REFRESH_SECONDS then
            askDecorations()
        elseif tab == 'players' and now - players.askedAt >= PLAYERS_REFRESH_SECONDS then
            askPlayers()
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
    showTab(tab or 'boosts')
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
    elseif data.type == 'commands' then
        onCommands(data)
    elseif data.type == 'players' then
        fillPlayers(data)
    elseif data.type == 'bans' then
        fillBans(data)
    elseif data.type == 'deco_items' and data.set then
        deco.items[data.set] = data.items or {}
    elseif data.type == 'decorations' then
        fillDecorations(data)
    elseif data.type == 'result' and data.text then
        setResult(data.ok, data.text)
        if data.ok and broadcasting then
            window.boosts.tools.broadcastText:setText('')
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
    window.result:setText('')
    window.decorations.result:setText('')
    deco.data = nil
    deco.items = {}
    commands.byWords, commands.list, commands.parts = nil, {}, {}
    players.list, players.towns = {}, {}
    world.built = false
    legendary.built = false
    tab = nil
    resetBanButton()
    refreshCommandButtons()
end

function init()
    g_ui.importStyle('admin')
    window = g_ui.createWidget('AdminWindow', rootWidget)
    window:hide()

    local tools = window.boosts.tools
    local function pickTarget(target)
        broadcastTarget = target
        for _, widget in ipairs(tools.targets:getChildren()) do
            widget:setOn(widget:getId() == target)
        end
    end
    for _, widget in ipairs(tools.targets:getChildren()) do
        widget.onClick = function()
            pickTarget(widget:getId())
            tools.ping:setEnabled(broadcastTarget ~= 'game')
        end
    end
    pickTarget(broadcastTarget)
    tools.broadcast.onClick = function()
        broadcasting = true
        send({ action = 'broadcast', text = tools.broadcastText:getText(), target = broadcastTarget,
               ping = broadcastTarget ~= 'game' and broadcastPing ~= '' and broadcastPing or nil })
    end
    tools.broadcastText.onKeyPress = function(self, keyCode)
        if keyCode == KeyEnter or keyCode == KeyReturn then
            tools.broadcast.onClick()
            return true
        end
        return false
    end

    local online = window.players.online
    online.refresh.onClick = function()
        askPlayers()
        askBans()
    end
    online.search.onTextChange = function()
        removeEvent(players.searchEvent)
        players.searchEvent = scheduleEvent(askPlayers, 300)
    end
    local player = window.players.player
    player.name.onTextChange = updatePlayerInfo
    for _, entry in ipairs(PLAYER_ACTIONS) do
        commandButton(player.actions, 'AdminSectionButton', entry[1], entry[2], function()
            local name, why = selectedName()
            if name and (entry[2] == '/kick' or entry[2] == '/unban') then
                scheduleEvent(function()
                    askPlayers()
                    askBans()
                end, 600)
            end
            return name and (entry[2] .. ' ' .. name), why
        end, entry[3])
    end
    player.ban.onClick = onBan

    local lookCount
    local function pickedLook()
        local look = tonumber(player.look:getText())
        lookCount = lookCount or #g_things.getThingTypes(ThingCategoryCreature)
        if not look or look < 2 or look >= lookCount then
            return nil
        end
        return look
    end
    player.look.onTextChange = function()
        local look = pickedLook()
        player.lookPreview:setVisible(look ~= nil)
        if look then
            player.lookPreview:setOutfit({ type = look })
            player.lookName:setText(tr('Look %d', look))
        else
            player.lookName:setText(trim(player.look:getText()) ~= '' and tr('No such look') or '')
        end
    end
    player.look.onTextChange()
    local function forced(target)
        return function()
            local look = pickedLook()
            if not look then
                return nil, tr('Type a look number first.')
            end
            if target == 'me' then
                return '/forceoutfit ' .. look
            end
            local name, why = selectedName()
            return name and string.format('/forceoutfit %d, %s', look, name), why
        end
    end
    commandButton(player.lookButtons, 'AdminSectionButton', 'On the player', '/forceoutfit', forced('player'),
        'Until they relog or choose an outfit; it is not added to their outfits'):setWidth(110)
    commandButton(player.lookButtons, 'AdminSectionButton', 'On me', '/forceoutfit', forced('me')):setWidth(80)
    commandButton(player.lookButtons, 'AdminSectionButton', 'Give theirs back', '/forceoutfit', function()
        local name, why = selectedName()
        return name and ('/forceoutfit off, ' .. name), why
    end, 'Put the player\'s own outfit back now'):setWidth(130)

    buildServer()

    local commandPanel = window.commands.panel
    commandPanel.run.onClick = function() run(commandPanel.text:getText()) end
    commandPanel.text.onTextChange = fillCommandList
    commandPanel.text.onKeyPress = function(self, keyCode)
        if keyCode == KeyEnter or keyCode == KeyReturn then
            commandPanel.run.onClick()
            return true
        end
        return false
    end
    fillCommandList()

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
    decorations.itemAdd.onClick = function()
        local id = tonumber(trim(decorations.itemId:getText()))
        if not id then
            setResult(false, tr('Enter an item id.'))
            return
        end
        deco.item = id
        send({ action = 'deco_item_add', set = deco.set, item = id })
        decorations.itemId:setText('')
    end
    decorations.itemRemove.onClick = function()
        send({ action = 'deco_item_remove', set = deco.set, item = deco.item })
    end
    decorations.itemId.onKeyPress = function(self, keyCode)
        if keyCode == KeyEnter or keyCode == KeyReturn then
            decorations.itemAdd.onClick()
            return true
        end
        return false
    end

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
    removeEvent(players.searchEvent)
    removeEvent(banPick.confirmEvent)
    for _, widget in ipairs({ button, window }) do
        if widget then
            widget:destroy()
        end
    end
    button, window, state = nil, nil, nil
    commandButtons = {}
end
