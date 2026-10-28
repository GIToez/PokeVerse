-- Tracking (docs/concepts/side-panel, Tracking card): the Pokepedia tracker as a Pokegear window. The
-- lines are the tracker's own (game_pokepedia/tracker.lua), grouped: pinned, the route, tasks, quests
-- and tracked Pokemon. A click opens the line, right-click pins or removes it. It grows with its
-- lines, then scrolls; folded, it's a chip under the map's name with a green dot while something is
-- ready to claim. The tracker window waits hidden while Pokegear is on.
Tracking = {}

local POSITION_SETTING = 'pokegearTrackingPosition'
local FOLDED_SETTING = 'pokegearTrackingFolded'
local KEY = { 'Windows', 'Show/hide the Pokepedia tracker' }
local LINE_HEIGHT, LINE_SPACING, GROUP_HEIGHT = 38, 4, 18
local MAX_LIST = 360
local CHROME_HEIGHT = 8 + 24 + 4 + 10
local CHIP_SPACE = 24
local GREEN, BLUE = '#4fd66a', '#5aa0ff'

local GROUPS = {
    { id = 'pinned', text = 'PINNED' },
    { id = 'route', text = 'ROUTE' },
    { id = 'tasks', text = 'TASKS' },
    { id = 'quests', text = 'QUESTS' },
    { id = 'pokedex', text = 'POKEDEX' },
}

local window, chip, restorePosition
local shown = false
local trackerWasVisible
local hideTrackerWindow

local function tracker()
    local pokepedia = modules.game_pokepedia
    return pokepedia and pokepedia.Tracker
end

local function groupOf(line, module)
    if module.isPinned(line.key) then
        return 'pinned'
    elseif line.key == 'route' then
        return 'route'
    elseif line.key:find('^dex_') then
        return 'pokedex'
    elseif line.key:find('^quest_') then
        return 'quests'
    end
    return 'tasks'
end

local function folded()
    return g_settings.getBoolean(FOLDED_SETTING)
end

local function lineMenu(line, mousePos, module)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    if line.onClick then
        menu:addOption(tr('Open'), line.onClick)
    end
    if not line.noPin then
        local pinned = module.isPinned(line.key)
        menu:addOption(pinned and tr('Unpin') or tr('Pin to the top'), function() module.setPinned(line.key, not pinned) end)
    end
    if line.onRemove then
        menu:addOption(tr('Remove from Tracking'), line.onRemove)
    end
    menu:addSeparator()
    menu:addOption(tr('Show the hidden tasks again'), module.showHidden)
    menu:display(mousePos)
end

local function fillLine(widget, line, module)
    widget.icon:setImageSource(line.icon)
    Pokegear.fitText(widget.name, tostring(line.name))
    widget.name:setColor(line.done and '#8fe08f' or '#eef2ff')
    widget:setTooltip(line.tooltip or tostring(line.name))
    widget.pin:setVisible(module.isPinned(line.key))
    local claim = widget.right.claim
    claim:setVisible(line.claim ~= nil)
    widget.right.count:setVisible(line.claim == nil)
    if line.claim then
        claim:setText(line.claim)
        claim:setOn(line.claim == tr('Claim'))
        claim.onClick = line.onClaim
    else
        widget.right.count:setText(line.count or '')
    end
    local max = math.max(1, tonumber(line.max) or 1)
    local percent = math.max(0, math.min(1, (tonumber(line.value) or 0) / max))
    local fill = widget.bar.fill
    fill:setImageColor(line.done and GREEN or BLUE)
    fill:setVisible(percent > 0)
    local function size()
        fill:setWidth(math.max(6, math.floor(widget.bar:getWidth() * percent)))
    end
    widget.bar.onGeometryChange = size
    size()
    widget.onMouseRelease = function(_, mousePos, button)
        if button == MouseRightButton then
            lineMenu(line, mousePos, module)
            return true
        elseif button == MouseLeftButton and line.onClick then
            line.onClick()
            return true
        end
        return false
    end
end

local function refreshChip(count, ready)
    if not chip then
        return
    end
    chip:setText(count > 0 and tr('Tracking  %d', count) or tr('Tracking'))
    chip:setWidth(chip:getTextSize().width + 32)
    chip.dot:setImageColor(ready > 0 and GREEN or '#56627a')
    chip:setTooltip(ready > 0 and tr('%d ready to claim. Click to open Tracking.', ready) or tr('Click to open Tracking.'))
end

function Tracking.refresh()
    local module = tracker()
    if not shown or not module then
        return
    end
    hideTrackerWindow(true)
    local lines = module.getLines()
    local ready = 0
    local byGroup = {}
    for _, line in ipairs(lines) do
        local group = groupOf(line, module)
        byGroup[group] = byGroup[group] or {}
        table.insert(byGroup[group], line)
        if line.claim == tr('Claim') then
            ready = ready + 1
        end
    end
    refreshChip(#lines, ready)
    if not window:isVisible() then
        return
    end

    local list = window.list
    list:destroyChildren()
    local height = 0
    for _, group in ipairs(GROUPS) do
        local entries = byGroup[group.id]
        if entries then
            local heading = g_ui.createWidget('PokegearTrackGroup', list)
            heading:setText(tr(group.text))
            height = height + GROUP_HEIGHT + LINE_SPACING
            for _, line in ipairs(entries) do
                fillLine(g_ui.createWidget('PokegearTrackLine', list), line, module)
                height = height + LINE_HEIGHT + LINE_SPACING
            end
        end
    end
    height = math.max(0, height - LINE_SPACING)
    window.empty:setVisible(#lines == 0)
    window.header.count:setText(#lines > 0 and tostring(#lines) or '')
    local listHeight = #lines == 0 and 34 or math.min(height, MAX_LIST)
    list:setHeight(listHeight)
    window.scroll:setHeight(listHeight)
    local scrolls = height > MAX_LIST
    window.scroll:setVisible(scrolls)
    window.scroll:setWidth(scrolls and 10 or 0)
    list:setMarginRight(scrolls and 4 or 0)
    window:setHeight(CHROME_HEIGHT + listHeight)
    local key = Pokegear.boundKey(KEY)
    window.header.keyChip:setText(key)
    window.header.keyChip:setVisible(key ~= '')
    Pokegear.fitColumn()
end

-- under Nearby while it's in its spot, else under the ring, else in the top-right corner
local function placeDefault()
    Pokegear.unhang(window)
    window:breakAnchors()
    local under = Nearby.docked() or Hub.docked()
    if under then
        window:addAnchor(AnchorTop, under:getId(), AnchorBottom)
        window:addAnchor(AnchorRight, under:getId(), AnchorRight)
        window:setMarginTop(4)
        window:setMarginRight(under == Nearby.docked() and 0 or 25)
    else
        Pokegear.hangFromMapTop(window, 4)
        window:addAnchor(AnchorRight, 'parent', AnchorRight)
        window:setMarginRight(4)
    end
end

local function build()
    local root = modules.game_interface.getRootPanel()
    window = g_ui.createWidget('PokegearTracking', root)
    window:hide()
    window.header.fold.onClick = function() Tracking.setFolded(true) end
    window.header.onMouseRelease = function(widget, mousePos, button)
        if button == MouseRightButton then
            local module = tracker()
            local menu = g_ui.createWidget('PopupMenu')
            menu:setGameMenu(true)
            menu:addOption(tr('Fold'), function() Tracking.setFolded(true) end)
            if module then
                menu:addOption(tr('Show the hidden tasks again'), module.showHidden)
            end
            menu:display(mousePos)
            return true
        end
        return false
    end
    restorePosition = Pokegear.makeMovable(window, window.header, POSITION_SETTING, placeDefault)
end

local function showChip(on)
    local ribbon = Hub.ribbon()
    if on and ribbon then
        if not chip then
            chip = g_ui.createWidget('PokegearTrackingChip', ribbon)
            chip:addAnchor(AnchorBottom, 'parent', AnchorBottom)
            chip:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
            chip:setMarginBottom(6)
            chip.onClick = function() Tracking.setFolded(false) end
        end
        chip:show()
        Hub.extendRibbon(CHIP_SPACE)
    else
        if chip then
            chip:hide()
        end
        Hub.extendRibbon(0)
    end
end

hideTrackerWindow = function(hide)
    local module = tracker()
    local miniWindow = module and module.getWindow()
    if not miniWindow then
        return
    end
    if hide then
        -- it may open after Pokegear is on (logging in), so any time it shows counts
        trackerWasVisible = trackerWasVisible == true or miniWindow:isVisible()
        miniWindow:hide()
    elseif trackerWasVisible ~= nil then
        miniWindow:setVisible(trackerWasVisible)
        trackerWasVisible = nil
    end
end

local function layout()
    if folded() then
        if window then
            window:hide()
        end
        showChip(true)
    else
        showChip(false)
        if not window then
            build()
        end
        restorePosition()
        window:show()
        window:raise()
    end
    Tracking.refresh()
    Pokegear.layoutColumn()
end

function Tracking.setFolded(on)
    if not shown then
        return
    end
    g_settings.set(FOLDED_SETTING, on)
    layout()
end

-- the column hangs under the card while it is in its spot
function Tracking.docked()
    return shown and window and not folded() and Pokegear.isDocked(window, POSITION_SETTING) and window or nil
end

-- Nearby moved, opened or closed: the card follows it while it's in its own spot
function Tracking.follow()
    if shown and window and window:isVisible() and Pokegear.isDocked(window, POSITION_SETTING) then
        placeDefault()
    end
end

local delegate = {
    open = function() Tracking.setFolded(false) end,
    toggle = function() Tracking.setFolded(not folded()) end,
}

function Tracking.apply(active)
    local module = tracker()
    local on = active and g_game.isOnline() and module ~= nil
    if on == shown then
        if on then
            hideTrackerWindow(true)
            Tracking.refresh()
        end
        return
    end
    shown = on
    if on then
        hideTrackerWindow(true)
        module.listen(Tracking.refresh)
        module.setDelegate(delegate)
        layout()
    else
        if module then
            module.unlisten(Tracking.refresh)
            module.setDelegate(nil)
        end
        if window then
            window:hide()
        end
        showChip(false)
        hideTrackerWindow(false)
    end
end

function Tracking.terminate()
    Tracking.apply(false)
    if window then
        window:destroy()
        window = nil
    end
    if chip and not chip:isDestroyed() then
        chip:destroy()
    end
    chip = nil
end
