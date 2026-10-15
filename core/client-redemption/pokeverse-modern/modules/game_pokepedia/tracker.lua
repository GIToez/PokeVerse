-- The tracker panel on the side: the Pokemon the trainer tracks ("Rattata 63 / 100"), the open
-- tasks from the Tasks window (finished ones get a Claim button) and the route while it runs.
-- Lines can be pinned to the top or removed; a click opens the Pokedex entry or the Tasks tab.
Tracker = {}

local miniWindow, toggleButton
local trackedNames = {} -- ordered names
local progress = {} -- name -> { number, level, points, next }
local hidden, pinned = {}, {}
local refreshEvent

local IMAGES = '/modules/game_dailytasks/images/'
local BOARD_ICONS = { daily = IMAGES .. 'icon_daily', weekly = IMAGES .. 'icon_weekly', hunting = IMAGES .. 'icon_hunting' }
local BOARD_NAMES = { 'daily', 'weekly', 'hunting' }

-- g_settings stores the keys as OTML tags
local function lineKey(...)
    return (table.concat({ ... }, '_'):gsub('[^%w]', '_'))
end

local function saveTracked()
    Pp.save('tracked', trackedNames)
end

local function sendTracked()
    Pp.send({ action = 'track', list = trackedNames })
end

function Tracker.isTracked(name)
    for _, tracked in ipairs(trackedNames) do
        if tracked:lower() == tostring(name):lower() then
            return true
        end
    end
    return false
end

function Tracker.track(name)
    if Tracker.isTracked(name) then
        return
    end
    if #trackedNames >= 20 then
        Pp.status(tr('You can track up to 20 Pokemon.'), false)
        return
    end
    trackedNames[#trackedNames + 1] = name
    saveTracked()
    sendTracked()
    if miniWindow and not miniWindow:isVisible() then
        Tracker.open()
    end
    Pp.status(tr('%s is now in your tracker.', name), true)
end

function Tracker.untrack(name)
    for index, tracked in ipairs(trackedNames) do
        if tracked:lower() == tostring(name):lower() then
            table.remove(trackedNames, index)
            break
        end
    end
    progress[name] = nil
    saveTracked()
    sendTracked()
    Tracker.refresh()
end

local function openTasks(board)
    local tasks = modules.game_dailytasks
    if not tasks then
        return
    end
    if tasks.openTab then
        tasks.openTab(board)
    else
        tasks.toggle()
    end
end

-- every line: { key, icon, name, count, value, max, done, claim, onClick, onRemove }
local function collect()
    local lines = {}
    if Navigation.isActive() then
        local state = Navigation.state()
        local name = state.stop and state.stop.name ~= '' and state.stop.name or tr('the spot')
        local text
        if state.paused then
            text = tr('Paused: %s', name)
        elseif state.waitingFloor then
            text = tr('Floor %s: %s', Pp.floorName(state.waitingFloor), name)
        else
            text = tr('Walking to %s', name)
        end
        lines[#lines + 1] = { key = 'route', icon = Pp.IMAGES .. 'icon_route', name = text,
            count = state.mode == 'route' and string.format('%d / %d', state.reached, state.total) or '',
            value = state.reached, max = math.max(1, state.total), done = state.paused,
            claim = state.paused and tr('Go') or nil, onClaim = Navigation.resume,
            tooltip = Navigation.describe(),
            onClick = function()
                if state.mode == 'route' then
                    show('map')
                end
            end,
            onRemove = function() Navigation.stop(tr('The route stopped.')) end, noPin = true }
    end
    for _, name in ipairs(trackedNames) do
        local row = progress[name] or {}
        local level = row.level or -1
        local complete = level >= 3
        lines[#lines + 1] = { key = lineKey('dex', name), icon = Pp.IMAGES .. 'icon_dex', name = name,
            count = complete and tr('Done') or string.format('%d / %d', row.points or 0, row.next or 0),
            value = complete and 1 or (row.points or 0), max = complete and 1 or math.max(1, row.next or 1),
            done = complete,
            tooltip = level >= 0 and tr('%s: knowledge level %d of 3', name, math.max(0, level)) or name,
            onClick = function() DexTab.open(name) end,
            onRemove = function() Tracker.untrack(name) end }
    end
    local tasks = modules.game_dailytasks
    local boards = tasks and tasks.getBoards and tasks.getBoards() or {}
    for _, board in ipairs(BOARD_NAMES) do
        local entry = boards[board]
        local state = entry and entry.state
        if state and board == 'hunting' then
            for _, hunt in ipairs(state.active or {}) do
                local key = lineKey('hunting', tostring(hunt.slot), tostring(hunt.species))
                local done = hunt.progress >= hunt.target
                lines[#lines + 1] = { key = key, icon = BOARD_ICONS.hunting, name = tr('Hunt %s', hunt.species),
                    count = string.format('%d / %d', math.min(hunt.progress, hunt.target), hunt.target),
                    value = hunt.progress, max = hunt.target, done = done, claim = done and tr('Claim') or nil,
                    onClaim = function() openTasks('hunting') end,
                    onClick = function() openTasks('hunting') end,
                    onRemove = function() hidden[key] = true; Pp.save('hiddenTasks', hidden); Tracker.refresh() end }
            end
        elseif state then
            for _, task in ipairs(state.tasks or {}) do
                if not task.claimed then
                    local key = lineKey(board, tostring(task.slot), tostring(task.title))
                    local done = task.progress >= task.target
                    lines[#lines + 1] = { key = key, icon = BOARD_ICONS[board], name = tostring(task.title),
                        count = string.format('%d / %d', math.min(task.progress, task.target), task.target),
                        value = task.progress, max = task.target, done = done, claim = done and tr('Claim') or nil,
                        tooltip = task.desc,
                        onClaim = function() openTasks(board) end,
                        onClick = function() openTasks(board) end,
                        onRemove = function() hidden[key] = true; Pp.save('hiddenTasks', hidden); Tracker.refresh() end }
                end
            end
        end
    end
    local shown = {}
    for _, line in ipairs(lines) do
        if not hidden[line.key] then
            shown[#shown + 1] = line
        end
    end
    -- pinned lines first, the rest keep their order
    for index, line in ipairs(shown) do
        line.order = (pinned[line.key] and 0 or 100000) + index
    end
    table.sort(shown, function(a, b) return a.order < b.order end)
    return shown
end

local function draw()
    if not miniWindow then
        return
    end
    local panel = miniWindow.contentsPanel
    for _, child in ipairs(panel:getChildren()) do
        if child:getId() ~= 'empty' then
            child:destroy()
        end
    end
    local lines = collect()
    panel.empty:setVisible(#lines == 0)
    for _, line in ipairs(lines) do
        local widget = g_ui.createWidget('PpTrackerLine', panel)
        widget.icon:setImageSource(line.icon)
        local name = tostring(line.name)
        widget.name:setText(#name > 16 and name:sub(1, 13) .. '...' or name)
        widget.name:setColor(line.done and '#8fe08f' or '#dfdfdf')
        widget:setTooltip(line.tooltip or name)
        Pp.setTrack(widget.track, line.value, line.max, line.done and 'fill_green' or 'fill_blue')
        widget.claim:setVisible(line.claim ~= nil)
        if line.claim then
            widget.count:setText('')
            widget.claim:setText(line.claim)
            widget.track:setMarginRight(44)
            widget.claim.onClick = line.onClaim
        else
            widget.count:setText(line.count)
        end
        local isPinned = pinned[line.key] == true
        widget.pin:setVisible(not line.noPin)
        widget.pin:setIcon(Pp.IMAGES .. (isPinned and 'icon_pinned' or 'icon_pin'))
        widget.pin:setTooltip(isPinned and tr('Unpin') or tr('Pin to the top'))
        widget.pin.onClick = function()
            pinned[line.key] = (not isPinned) or nil
            Pp.save('pinned', pinned)
            Tracker.refresh()
        end
        widget.remove.onClick = line.onRemove
        widget.onClick = line.onClick
    end
end

function Tracker.refresh()
    removeEvent(refreshEvent)
    refreshEvent = scheduleEvent(function()
        refreshEvent = nil
        draw()
    end, 100)
end

function Handlers.tracked(data)
    progress = {}
    for _, row in ipairs(data.list or {}) do
        progress[row.name] = row
    end
    Tracker.refresh()
end

function Handlers.progress(row)
    progress[row.name] = row
    DexTab.onProgress(row)
    Tracker.refresh()
end

-- the window

function Tracker.open()
    if not miniWindow then
        return
    end
    if not miniWindow:getParent() then
        local panel = modules.game_interface.findContentPanelAvailable(miniWindow, miniWindow:getMinimumHeight())
        if not panel then
            return
        end
        panel:addChild(miniWindow)
    end
    miniWindow:open()
end

function Tracker.toggle()
    if miniWindow and miniWindow:isVisible() then
        miniWindow:close()
    else
        Tracker.open()
    end
end

function Tracker.onOpen()
    if toggleButton then
        toggleButton:setOn(true)
    end
    Tracker.refresh()
end

function Tracker.onClose()
    if toggleButton then
        toggleButton:setOn(false)
    end
end

function Tracker.setButton(widget)
    toggleButton = widget
    if toggleButton and miniWindow then
        toggleButton:setOn(miniWindow:isVisible())
    end
end

function Tracker.setup()
    miniWindow = g_ui.loadUI('tracker')
    miniWindow:setup()
    miniWindow:setContentMinimumHeight(40)
    local contextMenuButton = miniWindow:recursiveGetChildById('contextMenuButton')
    if contextMenuButton then
        contextMenuButton:setVisible(true)
        contextMenuButton.onClick = function(widget, mousePos)
            local menu = g_ui.createWidget('PopupMenu')
            menu:setGameMenu(true)
            menu:addOption(tr('Show the hidden tasks again'), function()
                hidden = {}
                Pp.save('hiddenTasks', hidden)
                Tracker.refresh()
            end)
            menu:addOption(tr('Open the Pokepedia'), function() show() end)
            menu:display(mousePos)
        end
    end
    Navigation.listen(Tracker.refresh)
end

function Tracker.onGameStart()
    trackedNames = {}
    for _, name in ipairs(Pp.list(Pp.load('tracked'))) do
        trackedNames[#trackedNames + 1] = tostring(name)
    end
    hidden, pinned = {}, {}
    for key, value in pairs(Pp.load('hiddenTasks') or {}) do
        hidden[tostring(key)] = value == true or nil
    end
    for key, value in pairs(Pp.load('pinned') or {}) do
        pinned[tostring(key)] = value == true or nil
    end
    progress = {}
    miniWindow:setupOnStart()
    if toggleButton then
        toggleButton:setOn(miniWindow:isVisible())
    end
    if #trackedNames > 0 then
        sendTracked()
    end
    Tracker.refresh()
end

function Tracker.onGameEnd()
    progress = {}
    removeEvent(refreshEvent)
    refreshEvent = nil
end

function Tracker.terminate()
    removeEvent(refreshEvent)
    refreshEvent = nil
    if miniWindow then
        miniWindow:destroy()
        miniWindow = nil
    end
end
