-- Activity: in Pokegear, the milestones (a GTS sale, a catch, an evolution, a level-up, a finished
-- quest or task...) go in the list behind the bell on the top bar, and most also pop up as a toast over
-- the bottom of the map. The server marks them (doPlayerSendActivity, ExtendedIds.Activity) just before
-- their usual text message, which game_textmessage then hands over (takeMessage) so it doesn't show
-- twice. Every other message, and Classic, stay as they always were; the console keeps every line.
Activity = {}

local MAX_TOASTS = 3
local TOAST_TIME = 5000
local FADE_TIME = 600
local TOAST_TEXT_WIDTH = 560 -- longer lines are cut with "..." (the list has all of it)
local MAX_ENTRIES = 100
local EXPECT_MS = 3000 -- how long a milestone waits for its text message
local BUTTON_ID = 'pokegearActivityButton'
local TOASTS_ABOVE_BOTTOM = 70
local TOASTS_ABOVE_MOVES = 8
local KINDS = {
    gts = '#ffcb05', catch = '#ff6b6b', evolve = '#ba78ff', levelup = '#60dc78', quest = '#ffc42e',
    task = '#78c8e6', battle = '#ff9f43', egg = '#f8a5c2',
}
local OTHER = '#eef2ff'

local active = false
local toasts, window, button, badge
local entries = {} -- oldest first: { text, color, time }
local unread = 0
local shown = {} -- text -> { widget, count, event }
local expected = {} -- { text, at }: milestones whose text message is still on its way

local function trim(text)
    return (tostring(text or ''):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function isExpected(text, take)
    local now = g_clock.millis()
    text = trim(text)
    for i = #expected, 1, -1 do
        local entry = expected[i]
        if now - entry.at > EXPECT_MS then
            table.remove(expected, i)
        elseif entry.text == text then
            if take then
                table.remove(expected, i)
            end
            return true
        end
    end
    return false
end

-- the Pokegear chat leaves a milestone's line out of its floating lines and unread counts
function Activity.claims(text)
    return active and isExpected(text, false)
end

-- Bell ---------------------------------------------------------------------------------------------

local function refreshBadge()
    if not badge then
        return
    end
    badge:setText(unread > 9 and '9+' or tostring(unread))
    badge:setVisible(unread > 0)
end

local function refreshButton()
    if button then
        button:setVisible(active and g_game.isOnline())
        button:setOn(window ~= nil and window:isVisible())
    end
    refreshBadge()
end

-- Toasts -------------------------------------------------------------------------------------------

local function removeToast(text)
    local toast = shown[text]
    if not toast then
        return
    end
    shown[text] = nil
    removeEvent(toast.event)
    if not toast.widget:isDestroyed() then
        toast.widget:destroy()
    end
end

local function clearToasts()
    for text in pairs(shown) do
        removeToast(text)
    end
end

local function fadeLater(text)
    local toast = shown[text]
    removeEvent(toast.event)
    toast.event = scheduleEvent(function()
        g_effects.fadeOut(toast.widget, FADE_TIME)
        toast.event = scheduleEvent(function()
            toast.event = nil
            if shown[text] == toast then
                removeToast(text)
            end
        end, FADE_TIME)
    end, TOAST_TIME)
end

local function setToastText(label, text)
    label:setText(text)
    local cut = #text
    while cut > 1 and label:getTextSize().width > TOAST_TEXT_WIDTH do
        cut = cut - 1
        label:setText(text:sub(1, cut):gsub('%s+$', '') .. '...')
    end
end

-- above the move bar while it sits at the bottom of the map (game_pokemoves), else near the map's bottom
local function placeToasts()
    local map = modules.game_interface.getMapPanel()
    local moves = modules.game_pokemoves and modules.game_pokemoves.pokemonMovesWindow
    toasts:breakAnchors()
    toasts:addAnchor(AnchorHorizontalCenter, 'gameMapPanel', AnchorHorizontalCenter)
    local mapRect = map:getRect()
    local movesRect = moves and moves:isVisible() and moves:getRect()
    if movesRect and movesRect.width > movesRect.height
        and movesRect.y + movesRect.height > mapRect.y + mapRect.height * 0.6 then
        toasts:addAnchor(AnchorBottom, moves:getId(), AnchorTop)
        toasts:setMarginBottom(TOASTS_ABOVE_MOVES)
    else
        toasts:addAnchor(AnchorBottom, 'gameMapPanel', AnchorBottom)
        toasts:setMarginBottom(TOASTS_ABOVE_BOTTOM)
    end
end

-- the same notice again while it still shows counts up instead of stacking
local function addToast(text, color)
    if not toasts then
        return
    end
    local toast = shown[text]
    if toast then
        g_effects.cancelFade(toast.widget)
        toast.widget:setOpacity(1)
        toasts:moveChildToIndex(toast.widget, #toasts:getChildren())
    else
        toast = { widget = g_ui.createWidget('PokegearToast', toasts), count = 0 }
        shown[text] = toast
        local children = toasts:getChildren()
        if #children > MAX_TOASTS then
            for key, other in pairs(shown) do
                if other.widget == children[1] then
                    removeToast(key)
                    break
                end
            end
        end
    end
    toast.count = toast.count + 1
    local pill = toast.widget.pill
    pill.dot:setImageColor(color)
    setToastText(pill.text, toast.count > 1 and string.format('%s  x%d', text, toast.count) or text)
    pill:setWidth(pill.text:getWidth() + 44)
    placeToasts()
    toasts:show()
    toasts:raise()
    fadeLater(text)
end

-- List ---------------------------------------------------------------------------------------------

local function addListRow(entry)
    local row = g_ui.createWidget('PokegearActivityRow', window.list)
    row.dot:setImageColor(entry.color)
    row.time:setText(os.date('%H:%M', entry.time))
    row.text:setText(entry.text)
    row.text:setColor('#e6ecfa')
    local function fit()
        if row and not row:isDestroyed() then
            row:setHeight(math.max(20, row.text:getHeight() + 6))
        end
    end
    fit()
    scheduleEvent(fit, 1)
    return row
end

local function scrollToTop()
    scheduleEvent(function()
        if window and window.scroll then
            window.scroll:setValue(0)
        end
    end, 10)
end

-- newest first
local function fillList()
    if not window then
        return
    end
    window.list:destroyChildren()
    for i = #entries, 1, -1 do
        addListRow(entries[i])
    end
    window.empty:setVisible(#entries == 0)
    scrollToTop()
end

-- under the bell, beside the ring while it's in its corner
local function place()
    window:breakAnchors()
    local hub = Hub.docked()
    if hub then
        window:addAnchor(AnchorRight, hub:getId(), AnchorLeft)
    else
        window:addAnchor(AnchorRight, 'parent', AnchorRight)
    end
    window:setMarginRight(8)
    Pokegear.hangFromMapTop(window, 6)
end

function Activity.hide()
    if window and window:isVisible() then
        window:hide()
        Pokegear.unhang(window)
    end
    refreshButton()
end

function Activity.show()
    if not window or not active then
        return
    end
    place()
    fillList()
    window:show()
    window:raise()
    unread = 0
    refreshButton()
end

function Activity.toggle()
    if window and window:isVisible() then
        Activity.hide()
    else
        Activity.show()
    end
end

local function remember(text, color)
    local entry = { text = text, color = color, time = os.time() }
    entries[#entries + 1] = entry
    if #entries > MAX_ENTRIES then
        table.remove(entries, 1)
    end
    if window and window:isVisible() then
        local row = addListRow(entry)
        window.list:moveChildToIndex(row, 1)
        local rows = window.list:getChildren()
        if #rows > MAX_ENTRIES then
            rows[#rows]:destroy()
        end
        window.empty:hide()
    else
        unread = unread + 1
        refreshBadge()
    end
end

-- game_textmessage: true for a milestone's own text message, which the toast already shows
function Activity.takeMessage(mode, text, msgtype, bannered)
    return active and g_game.isOnline() and isExpected(text, true)
end

local function onActivity(protocol, opcode, buffer)
    if not active then
        return
    end
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        return
    end
    local text = trim(data.text)
    if text == '' then
        return
    end
    local color = KINDS[data.kind] or OTHER
    remember(text, color)
    if not data.quiet then
        expected[#expected + 1] = { text = text, at = g_clock.millis() }
        addToast(text, color)
    end
end

-- Layout -------------------------------------------------------------------------------------------

function Activity.apply(on)
    active = on and g_game.isOnline()
    if not active then
        clearToasts()
        if toasts then
            toasts:hide()
        end
        Activity.hide()
    end
    refreshButton()
end

function Activity.reset()
    entries, expected = {}, {}
    unread = 0
    Activity.apply(false)
end

function Activity.init()
    g_ui.importStyle('activity')
    local root = modules.game_interface.getRootPanel()
    toasts = g_ui.createWidget('PokegearToasts', root)
    toasts:hide()
    window = g_ui.createWidget('PokegearActivity', root)
    window:hide()
    window.header.close.onClick = Activity.hide
    window.header.clear.onClick = function()
        entries = {}
        unread = 0
        fillList()
        refreshBadge()
    end
    button = modules.client_topmenu.addRightGameToggleButton(BUTTON_ID, tr('Activity'),
        '/modules/game_pokegear/images/button_bell', Activity.toggle)
    if button then
        badge = g_ui.createWidget('UILabel', button)
        badge:setId('badge')
        badge:setImageSource('/modules/game_pokegear/images/badge')
        badge:setSize({ width = 14, height = 14 })
        badge:addAnchor(AnchorTop, 'parent', AnchorTop)
        badge:addAnchor(AnchorRight, 'parent', AnchorRight)
        badge:setMarginTop(-4)
        badge:setMarginRight(-4)
        badge:setTextAlign(AlignCenter)
        badge:setFont('verdana-11px-rounded')
        badge:setColor('#ffffff')
        badge:setPhantom(true)
        badge:hide()
    end
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Activity, onActivity)
    refreshButton()
end

function Activity.terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Activity)
    clearToasts()
    if toasts then
        toasts:destroy()
        toasts = nil
    end
    if window then
        Pokegear.unhang(window)
        window:destroy()
        window = nil
    end
    if button then
        button:destroy()
        button, badge = nil, nil
    end
    entries, expected, unread, active = {}, {}, 0, false
end
