-- The Reports window (server lib Reports, 083-reports.lua): a bug report or a player report goes to the staff
-- and to the Discord forums; "My reports" shows what became of the trainer's own, and staff answer all of them
-- in "All reports". The client says {action = "hello"} after login and the server answers with the kinds,
-- their categories and statuses ({type = "config"}), and whether the character is staff.
IMAGES = '/modules/game_reports/images/'

local HELLO_DELAY = 1800
local FORM_TABS = { bug = true, player = true }
local TABS = { 'bug', 'player', 'mine', 'staff' }

-- badge colours by status
local STATUS_COLORS = {
    open = '#5d6f93', confirmed = '#3d6fb8', investigating = '#3d6fb8', planned = '#7a55c8',
    in_progress = '#b8860b', fixed = '#2f9a5a', action_taken = '#2f9a5a', wont_fix = '#b0404f',
    no_action = '#b0404f', duplicate = '#5a6170',
}

local window
local button
local helloEvent
local searchEvent
local sendTimeout
local config -- {kinds = {key = {name, categories, statuses}}, order, staff, canEdit, limits}
local tab = 'bug'
local statement -- the chat line a player report was opened from
local sending = false
local rows = {} -- the list on show
local selected -- id
local staffQuery = { kind = 'all', status = 'active', query = '', offset = 0 }
local staffTotal, staffPage = 0, 30
local current -- the report open in the staff details

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Report, data)
    end
end

local function kindInfo(kind)
    return config and config.kinds[kind]
end

local function lookup(list, key)
    for _, entry in ipairs(list or {}) do
        if entry.key == key then
            return entry
        end
    end
end

local function statusName(kind, status)
    local info = kindInfo(kind)
    local entry = info and lookup(info.statuses, status)
    return entry and entry.name or status
end

local function categoryName(kind, category)
    local info = kindInfo(kind)
    local entry = info and lookup(info.categories, category)
    return entry and entry.name or category
end

local function setBadge(badge, kind, status)
    badge:setText(statusName(kind, status))
    badge:setImageColor(STATUS_COLORS[status] or '#5d6f93')
end

local function dateText(time)
    return time and time > 0 and os.date('%d %b %Y, %H:%M', time) or ''
end

local function shorten(text, max)
    text = tostring(text or '')
    return #text > max and text:sub(1, max - 3) .. '...' or text
end

function isVisible()
    return window ~= nil and window:isVisible()
end

-- what goes with a report ---------------------------------------------------------------------------------

local function clientInfo()
    local size = g_window.getSize()
    local info = {
        os = g_app.getOs and g_app.getOs() or nil,
        version = g_app.getVersion and g_app.getVersion() or nil,
        build = g_app.getBuildCommit and shorten(g_app.getBuildCommit(), 10) or nil,
        renderer = g_graphics.getRenderer and shorten(g_graphics.getRenderer(), 50) or nil,
        window = size and string.format('%dx%d', size.width, size.height) or nil,
        fps = g_app.getFps and g_app.getFps() or nil,
        ping = g_game.getPing and g_game.getPing() or nil,
    }
    if g_window.getPlatformType then
        info.os = string.format('%s (%s)', info.os or '?', g_window.getPlatformType())
    end
    return info
end

local function infoLine(key, value)
    local line = g_ui.createWidget('ReportInfoLine', window.form.info.lines)
    line.key:setText(key)
    line.value:setText(value)
    return line
end

local function drawInfo()
    local lines = window.form.info.lines
    lines:destroyChildren()
    local player = g_game.getLocalPlayer()
    local pos = player and player:getPosition()
    if pos then
        infoLine(tr('Where you stand'), string.format('%d, %d, %d', pos.x, pos.y, pos.z))
    end
    infoLine(tr('Your trainer and Pokemon'), tr('%s, level %d, and the Pokemon out', g_game.getCharacterName(),
        player and player:getLevel() or 0))
    local client = clientInfo()
    infoLine(tr('Client'), shorten(string.format('%s, version %s', client.os or '?', client.version or '?'), 60))
    infoLine(tr('Graphics'), shorten(string.format('%s, %s, %s fps', client.renderer or '?', client.window or '?',
        tostring(client.fps or '?')), 60))
    local tip = window.form.info.tip
    if tab == 'player' then
        tip:setText(tr('Player reports are only seen by staff. Say what the player did and when; if it happened in the chat, right-click the message and pick "Report player" to send the message along.'))
    else
        tip:setText(tr('Stand where the bug happens before you send it: your position goes with the report. Say what you did, what you expected and what happened instead.'))
    end
end

local function onPositionChange()
    if isVisible() and FORM_TABS[tab] then
        drawInfo()
    end
end

-- the form ------------------------------------------------------------------------------------------------

local function updateCounter()
    local fields = window.form.fields
    local length = #fields.description:getText()
    local limits = config and config.limits or { textMin = 15, textMax = 1500 }
    fields.counter:setText(string.format('%d / %d', length, limits.textMax))
    fields.counter:setColor(length < limits.textMin and '#96aacd' or '#dce6ff')
end

local function setFeedback(text, good)
    local feedback = window.form.fields.feedback
    feedback:setText(text or '')
    feedback:setColor(good and '#7ee0a3' or '#ffb4b4')
end

local function fillCategories(kind)
    local combo = window.form.fields.category
    combo:clearOptions()
    local info = kindInfo(kind)
    for _, category in ipairs(info and info.categories or {}) do
        combo:addOption(tr(category.name), category.key)
    end
end

local function drawForm()
    local fields = window.form.fields
    local isPlayer = tab == 'player'
    fillCategories(tab)
    fields.categoryLabel:setText(isPlayer and tr('What did the player do?') or tr('What is it about?'))
    fields.targetLabel:setVisible(isPlayer)
    fields.target:setVisible(isPlayer)
    fields.statement:setVisible(isPlayer and statement ~= nil)
    fields.statement:setText(statement and tr('The message you report: "%s"', statement) or '')
    fields.title:setPlaceholder(isPlayer and tr('In a few words, for example: Uses a bot in Viridian Forest')
        or tr('In a few words, for example: Stuck on a rock east of Pewter'))
    fields.description:setPlaceholder(isPlayer
        and tr('What happened, when and where. Include what was said if it was in the chat.')
        or tr('What did you do, what did you expect, and what happened instead? Can you make it happen again?'))
    fields.send:setEnabled(not sending)
    updateCounter()
    drawInfo()
end

function clearForm()
    local fields = window.form.fields
    fields.title:clearText()
    fields.description:clearText()
    fields.target:clearText()
    statement = nil
    setFeedback('')
    drawForm()
end

function submit()
    if sending or not config then
        return
    end
    local fields = window.form.fields
    local option = fields.category:getCurrentOption()
    sending = true
    fields.send:setEnabled(false)
    setFeedback(tr('Sending...'), true)
    removeEvent(sendTimeout)
    sendTimeout = scheduleEvent(function()
        sendTimeout = nil
        if sending and window then
            sending = false
            window.form.fields.send:setEnabled(true)
            setFeedback(tr('No answer from the server. Try again in a moment.'))
        end
    end, 10000)
    send({
        action = 'submit',
        kind = tab,
        category = option and option.data or 'other',
        title = fields.title:getText(),
        description = fields.description:getText(),
        target = tab == 'player' and fields.target:getText() or nil,
        statement = tab == 'player' and statement or nil,
        client = clientInfo(),
    })
end

-- the lists -----------------------------------------------------------------------------------------------

local function clearDetails(text)
    local details = window.browser.details
    details.body:destroyChildren()
    for _, id in ipairs({ 'kindIcon', 'name', 'badge', 'meta', 'body', 'bodyScroll' }) do
        details[id]:setVisible(false)
    end
    details.staffBar:setVisible(false)
    details.hint:setText(text or '')
    details.hint:setVisible(true)
    current = nil
end

local function section(title)
    local label = g_ui.createWidget('ReportSectionTitle', window.browser.details.body)
    label:setText(title)
end

local function bodyText(text, style)
    local label = g_ui.createWidget(style or 'ReportBody', window.browser.details.body)
    label:setText(text)
    return label
end

local function showDetails(report, full)
    local details = window.browser.details
    details.hint:setVisible(false)
    for _, id in ipairs({ 'kindIcon', 'name', 'badge', 'meta', 'body', 'bodyScroll' }) do
        details[id]:setVisible(true)
    end
    details.kindIcon:setImageSource(IMAGES .. 'kind_' .. (report.kind == 'player' and 'player' or 'bug'))
    details.name:setText(report.title)
    setBadge(details.badge, report.kind, report.status)
    details.meta:setText(string.format('#%d  -  %s  -  %s', report.id, tr(categoryName(report.kind, report.category)),
        dateText(report.created)))
    details.body:destroyChildren()

    if report.target then
        section(tr('Reported player'))
        bodyText(full and report.targetOnline ~= nil
            and tr('%s (%s)', report.target, report.targetOnline and tr('online') or tr('offline')) or report.target)
    end
    if full then
        section(tr('From'))
        bodyText(tr('%s, level %d (%s)', report.reporter, report.level or 0,
            report.online and tr('online') or tr('offline')))
        section(tr('Description'))
        bodyText(report.description)
        if report.statement then
            section(tr('Reported message'))
            bodyText('"' .. report.statement .. '"')
        end
        section(tr('Where'))
        local pos = report.position or {}
        bodyText(string.format('%d, %d, %d%s', pos.x or 0, pos.y or 0, pos.z or 0,
            report.area and ('  -  ' .. report.area) or ''))
        if report.pokemon then
            section(tr('Pokemon out'))
            bodyText(report.pokemon)
        end
        if report.context and report.context.vocation then
            section(tr('Vocation'))
            bodyText(report.context.vocation)
        end
        if report.client then
            section(tr('Client'))
            bodyText(report.client, 'ReportEvent')
        end
        if report.events and #report.events > 0 then
            section(tr('History'))
            for _, event in ipairs(report.events) do
                local line = dateText(event.at) .. '  ' .. event.author
                if event.source == 'discord' then
                    line = line .. ' ' .. tr('on Discord')
                end
                if event.status ~= '' then
                    line = line .. ': ' .. tr(statusName(report.kind, event.status))
                end
                if event.note ~= '' then
                    line = line .. '  "' .. event.note .. '"'
                end
                bodyText(line, 'ReportEvent')
            end
        end
    else
        if report.note then
            section(tr('Answer from the team'))
            bodyText(report.note)
        elseif report.kind == 'player' and report.closed then
            section(tr('Answer from the team'))
            bodyText(tr('The team looked into it. Thank you for helping keep PokeVerse fair.'))
        elseif not report.closed then
            section(tr('Answer from the team'))
            bodyText(tr('No answer yet. You get a message here and on Discord when it changes.'), 'ReportEvent')
        end
        section(tr('Last change'))
        bodyText(dateText(report.updated))
    end

    local staffBar = details.staffBar
    staffBar:setVisible(full and config and config.canEdit or false)
    if full and config and config.canEdit then
        current = report
        local combo = staffBar.statusEdit
        combo:clearOptions()
        local info = kindInfo(report.kind)
        for _, status in ipairs(info and info.statuses or {}) do
            combo:addOption(tr(status.name), status.key)
        end
        combo:setCurrentOptionByData(report.status, true)
        staffBar.note:clearText()
        staffBar.staffInfo:setText(report.handledBy and tr('Last answered by %s', report.handledBy) or '')
    end
end

local function selectRow(id)
    selected = id
    for _, row in ipairs(window.browser.list:getChildren()) do
        row:setChecked(row.reportId == id)
    end
    if tab == 'staff' then
        clearDetails(tr('Loading...'))
        send({ action = 'get', id = id })
    else
        for _, report in ipairs(rows) do
            if report.id == id then
                showDetails(report, false)
            end
        end
    end
end

local function drawList()
    local browser = window.browser
    local list = browser.list
    list:destroyChildren()
    browser.filters:setVisible(tab == 'staff')
    browser.pager:setVisible(tab == 'staff')
    for _, report in ipairs(rows) do
        local row = g_ui.createWidget('ReportRow', list)
        row.reportId = report.id
        row.icon:setImageSource(IMAGES .. 'kind_' .. (report.kind == 'player' and 'player' or 'bug'))
        row.name:setText(report.title)
        local sub = string.format('#%d  -  %s', report.id, dateText(report.created))
        if tab == 'staff' then
            sub = string.format('#%d  -  %s%s', report.id, report.reporter,
                report.target and (' > ' .. report.target) or '')
        elseif report.target then
            sub = sub .. '  -  ' .. report.target
        end
        row.sub:setText(sub)
        setBadge(row.badge, report.kind, report.status)
        row.dot:setVisible(report.unseen == true)
        row.onClick = function() selectRow(report.id) end
    end
    browser.empty:setVisible(#rows == 0)
    browser.empty:setText(tab == 'staff' and tr('No reports match.')
        or tr('You have not sent any reports yet. Thank you for every one you send!'))
    if tab == 'staff' then
        local first = staffQuery.offset + 1
        local last = math.min(staffTotal, staffQuery.offset + #rows)
        browser.pager.pageLabel:setText(staffTotal > 0 and tr('%d-%d of %d', first, last, staffTotal) or '')
        browser.pager.prev:setEnabled(staffQuery.offset > 0)
        browser.pager.next:setEnabled(last < staffTotal)
    end
    local found = false
    for _, report in ipairs(rows) do
        found = found or report.id == selected
    end
    if found then
        selectRow(selected)
    elseif rows[1] and tab == 'mine' then
        selectRow(rows[1].id)
    else
        selected = nil
        clearDetails(tab == 'staff' and tr('Pick a report to read it.') or tr('Pick a report to see what became of it.'))
    end
end

local function requestStaffList()
    send({ action = 'list', kind = staffQuery.kind ~= 'all' and staffQuery.kind or nil, status = staffQuery.status,
           query = staffQuery.query, offset = staffQuery.offset })
end

function page(direction)
    staffQuery.offset = math.max(0, staffQuery.offset + direction * staffPage)
    requestStaffList()
end

local function fillFilters()
    local filters = window.browser.filters
    local kinds = filters.kindFilter
    kinds.onOptionChange = nil
    kinds:clearOptions()
    kinds:addOption(tr('All kinds'), 'all')
    for _, key in ipairs(config.order) do
        kinds:addOption(tr(config.kinds[key].name), key)
    end
    kinds:setCurrentOptionByData(staffQuery.kind, true)
    kinds.onOptionChange = function(_, _, data)
        staffQuery.kind, staffQuery.offset = data, 0
        fillStatusFilter()
        requestStaffList()
    end
    fillStatusFilter()
end

function fillStatusFilter()
    local combo = window.browser.filters.statusFilter
    combo.onOptionChange = nil
    combo:clearOptions()
    combo:addOption(tr('Not closed'), 'active')
    combo:addOption(tr('Closed'), 'closed')
    combo:addOption(tr('All'), 'all')
    local seen = {}
    for _, key in ipairs(config.order) do
        if staffQuery.kind == 'all' or staffQuery.kind == key then
            for _, status in ipairs(config.kinds[key].statuses) do
                if not seen[status.key] then
                    seen[status.key] = true
                    combo:addOption(tr(status.name), status.key)
                end
            end
        end
    end
    if not seen[staffQuery.status] and staffQuery.status ~= 'closed' and staffQuery.status ~= 'all' then
        staffQuery.status = 'active'
    end
    combo:setCurrentOptionByData(staffQuery.status, true)
    combo.onOptionChange = function(_, _, data)
        staffQuery.status, staffQuery.offset = data, 0
        requestStaffList()
    end
end

function saveStatus()
    if not current then
        return
    end
    local staffBar = window.browser.details.staffBar
    local option = staffBar.statusEdit:getCurrentOption()
    send({ action = 'status', id = current.id, status = option and option.data or current.status,
           note = staffBar.note:getText() })
end

function goThere()
    if current then
        send({ action = 'goto', id = current.id })
    end
end

-- tabs ----------------------------------------------------------------------------------------------------

function selectTab(name)
    if name == 'staff' and not (config and config.staff) then
        name = 'bug'
    end
    tab = name
    for _, key in ipairs(TABS) do
        window.tabs[key]:setOn(key == name)
    end
    window.form:setVisible(FORM_TABS[name] == true)
    window.browser:setVisible(not FORM_TABS[name])
    if FORM_TABS[name] then
        drawForm()
        window.form.fields.title:focus()
    else
        rows, selected = {}, nil
        drawList()
        if name == 'mine' then
            send({ action = 'mine' })
        else
            fillFilters()
            requestStaffList()
        end
    end
end

function show(name)
    if not window or not g_game.isOnline() then
        return
    end
    if not config then
        send({ action = 'hello' })
    end
    window:show()
    window:raise()
    window:focus()
    selectTab(name or (FORM_TABS[tab] and tab) or 'bug')
    if button then
        button:setOn(true)
    end
end

function hide()
    if window then
        window:hide()
    end
    if button then
        button:setOn(false)
    end
end

function toggle()
    if isVisible() then
        hide()
    else
        show()
    end
end

-- for the other modules: the console and the creature menus, the Admin window
function openBug()
    show('bug')
end

function openPlayer(name, message)
    show('player')
    statement = message and shorten(message, 255) or nil
    window.form.fields.target:setText(name or '')
    drawForm()
    window.form.fields.title:focus()
end

function openStaff()
    show('staff')
end

function isStaff()
    return config ~= nil and config.staff == true
end

-- server messages -----------------------------------------------------------------------------------------

local function onConfig(data)
    config = { kinds = {}, order = {}, staff = data.staff == true, canEdit = data.canEdit == true,
               limits = data.limits }
    for _, kind in ipairs(data.kinds or {}) do
        config.kinds[kind.key] = kind
        table.insert(config.order, kind.key)
    end
    window.tabs.staff:setVisible(config.staff)
    if button then
        button:setTooltip(data.unseen and data.unseen > 0 and tr('Reports (%d answered)', data.unseen) or tr('Reports'))
    end
    if isVisible() then
        selectTab(tab)
    end
end

local function onReport(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or not window then
        return
    end
    if data.type == 'config' then
        onConfig(data)
    elseif data.type == 'submitted' then
        sending = false
        removeEvent(sendTimeout)
        local fields = window.form.fields
        fields.title:clearText()
        fields.description:clearText()
        fields.target:clearText()
        statement = nil
        drawForm()
        setFeedback(tr('Report #%d was sent. Thank you! Follow it in My reports.', data.id), true)
    elseif data.type == 'error' then
        sending = false
        removeEvent(sendTimeout)
        if isVisible() and FORM_TABS[tab] then
            window.form.fields.send:setEnabled(true)
            setFeedback(data.text)
        elseif isVisible() then
            displayErrorBox(tr('Reports'), data.text)
        end
    elseif data.type == 'mine' then
        if tab == 'mine' then
            rows = data.reports or {}
            drawList()
        end
    elseif data.type == 'list' then
        if tab == 'staff' then
            rows = data.reports or {}
            staffTotal, staffPage = data.total or #rows, data.page or staffPage
            staffQuery.offset = data.offset or 0
            drawList()
        end
    elseif data.type == 'report' then
        if tab == 'staff' and data.report and data.report.id == selected then
            showDetails(data.report, true)
            for i, report in ipairs(rows) do
                if report.id == data.report.id then
                    rows[i].status = data.report.status
                end
            end
            for _, row in ipairs(window.browser.list:getChildren()) do
                if row.reportId == data.report.id then
                    setBadge(row.badge, data.report.kind, data.report.status)
                end
            end
        end
    elseif data.type == 'changed' then
        if isVisible() and tab == 'mine' then
            send({ action = 'mine' })
        end
    elseif data.type == 'new' then
        if isVisible() and tab == 'staff' and staffQuery.offset == 0 then
            requestStaffList()
        end
    end
end

local function onGameStart()
    config, tab, statement, sending, rows, selected, current = nil, 'bug', nil, false, {}, nil, nil
    staffQuery = { kind = 'all', status = 'active', query = '', offset = 0 }
    window.tabs.staff:setVisible(false)
    removeEvent(helloEvent)
    helloEvent = scheduleEvent(function()
        helloEvent = nil
        send({ action = 'hello' })
    end, HELLO_DELAY)
end

local function onGameEnd()
    removeEvent(helloEvent)
    helloEvent = nil
    hide()
    config = nil
end

function init()
    g_ui.importStyle('/modules/game_dailytasks/tasks')
    g_ui.importStyle('/modules/game_fishing/fishing')
    g_ui.importStyle('/modules/game_gts/gts')
    g_ui.importStyle('reports')
    window = g_ui.createWidget('ReportsWindow', rootWidget)
    window:hide()
    for _, name in ipairs(TABS) do
        window.tabs[name].onClick = function() selectTab(name) end
    end
    local fields = window.form.fields
    fields.description.onTextChange = updateCounter
    local search = window.browser.filters.search
    search.onTextChange = function(widget, text)
        staffQuery.query, staffQuery.offset = text, 0
        removeEvent(searchEvent)
        searchEvent = scheduleEvent(function()
            searchEvent = nil
            requestStaffList()
        end, 400)
    end

    button = modules.client_topmenu.addRightGameToggleButton('reportsButton', tr('Reports'),
        IMAGES .. 'button_reports', toggle)
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Report, onReport)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    connect(LocalPlayer, { onPositionChange = onPositionChange })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Report)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    disconnect(LocalPlayer, { onPositionChange = onPositionChange })
    removeEvent(helloEvent)
    removeEvent(searchEvent)
    removeEvent(sendTimeout)
    helloEvent, searchEvent, sendTimeout = nil, nil, nil
    for _, widget in ipairs({ button, window }) do
        if widget then
            widget:destroy()
        end
    end
    button, window = nil, nil
end
