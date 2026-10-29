-- The layout switch (Options > Interface > Layout). Classic is the side panels as they always were;
-- Pokegear replaces them piece by piece. Other modules ask isActive() and listen with
-- connect(modules.game_pokegear, { onLayoutChange = function(active) end }).
local active = false

function isActive()
    local options = modules.client_options
    return options ~= nil and options.getOption('uiLayout') == 'pokegear'
end

-- Pokegear has no Chat On / Chat Off: WASD always walks, and Enter opens one line (game_console
-- sends you back to walking after it)
local function applyWalkLock()
    local console = modules.game_console
    local toggle = console and console.consoleToggleChat
    if not toggle or g_platform.isMobile() then
        return
    end
    local textEdit = console.consoleTextEdit
    if active then
        if not toggle.isChecked and not (textEdit and textEdit:isVisible() and textEdit:getText() ~= '') then
            console.toggleChat()
        end
        -- the line itself lives in the chat card meanwhile (chat.lua moves it and puts it back)
        toggle:hide()
    else
        toggle:show()
    end
end

-- the top bar buttons for the side windows Pokegear replaces: these have no window of their own in
-- Pokegear (the ring, the HUD and the Trainer card took them over)
local REPLACED_BUTTONS = { 'miniMap', 'skillsButton' }
-- and these open the Pokegear window that took over, with its key
local REDIRECTED_BUTTONS = {
    battleButton = { name = 'Nearby', key = { 'Windows', 'Show/hide battle list' },
                     toggle = function() Nearby.toggle() end, isOpen = function() return Nearby.isOpen() end },
    vipListButton = { name = 'Social', key = { 'Windows', 'Show/hide VIP list' },
                      toggle = function() Social.toggle() end, isOpen = function() return Social.isOpen() end },
    inventory = { name = 'Bag', key = { 'Windows', 'Show/hide the Bag' },
                  toggle = function() Bag.toggle() end, isOpen = function() return Bag.isOpen() end },
}
local REDIRECT_REFRESH_MS = 300
local redirectEvent

local function refreshRedirected()
    for id, redirect in pairs(REDIRECTED_BUTTONS) do
        local button = Pokegear.topButton(id)
        if button and button.pokegearClassic then
            button:setOn(redirect.isOpen())
            local key = Pokegear.boundKey(redirect.key)
            button:setTooltip(key ~= '' and tr('%s (%s)', tr(redirect.name), key) or tr(redirect.name))
        end
    end
end

local function applyRedirected()
    for id, redirect in pairs(REDIRECTED_BUTTONS) do
        local button = Pokegear.topButton(id)
        if button and active and not button.pokegearClassic then
            button.pokegearClassic = { onMouseRelease = button.onMouseRelease, tooltip = button:getTooltip() }
            button.onMouseRelease = function(widget, mousePos, mouseButton)
                if widget:containsPoint(mousePos) and mouseButton ~= MouseMidButton then
                    redirect.toggle()
                    refreshRedirected()
                    return true
                end
            end
        elseif button and not active and button.pokegearClassic then
            button.onMouseRelease = button.pokegearClassic.onMouseRelease
            button:setTooltip(button.pokegearClassic.tooltip)
            button:setOn(false)
            button.pokegearClassic = nil
        end
        if button then
            button:show()
        end
    end
    removeEvent(redirectEvent)
    redirectEvent = nil
    if active then
        refreshRedirected()
        redirectEvent = cycleEvent(refreshRedirected, REDIRECT_REFRESH_MS)
    end
end

local function applyTopBar()
    for _, id in ipairs(REPLACED_BUTTONS) do
        local button = Pokegear.topButton(id)
        if button then
            button:setVisible(not active)
        end
    end
    applyRedirected()
end

-- The Skills window goes away in Pokegear: experience and Trainer Spirit are on the HUD (experience.lua)
-- and the trainer skills on the Trainer card. Classic gets it back as it was.
local skillsHidden, skillsWasOpen = false, false

local function skillsWindow()
    local skills = modules.game_skills
    return skills and skills.skillsWindow
end

local function keepSkillsHidden(window)
    if active then
        skillsWasOpen = true
        window:hide()
    end
end

local function applySkills()
    local window = skillsWindow()
    if not window then
        return
    end
    if active and g_game.isOnline() then
        if not skillsHidden then
            skillsHidden = true
            skillsWasOpen = window:isVisible()
            connect(window, { onOpen = keepSkillsHidden })
        end
        window:hide()
    elseif skillsHidden then
        skillsHidden = false
        disconnect(window, { onOpen = keepSkillsHidden })
        if skillsWasOpen and g_game.isOnline() then
            window:show()
        end
    end
end

-- Pokegear hangs the right-hand windows (Inventory, Skills, Friends...) under the ring in the
-- top-right corner, and under the Nearby card while it sits below the ring. Dragging either away
-- lifts the column up to whatever is still in place.
local COLUMN_SPACING = 4 -- GameSidePanel's layout spacing
local COLUMN_GAP = 4
local classicColumnHeight

function Pokegear.fitColumn()
    local column = modules.game_interface.getMainRightPanel()
    if not column or classicColumnHeight == nil then
        return
    end
    local height, count = column:getPaddingTop() + column:getPaddingBottom(), 0
    for _, child in ipairs(column:getChildren()) do
        if child:isVisible() then
            height = height + child:getHeight() + child:getMarginTop() + child:getMarginBottom()
            count = count + 1
        end
    end
    column:setHeight(height + math.max(count - 1, 0) * COLUMN_SPACING)
end

function Pokegear.layoutColumn()
    local column = modules.game_interface.getMainRightPanel()
    if not column then
        return
    end
    local on = active and g_game.isOnline()
    if on then
        Tracking.follow()
    end
    local under = on and (Tracking.docked() or Nearby.docked() or Hub.docked())
    column:removeAnchor(AnchorTop)
    if under then
        column:addAnchor(AnchorTop, under:getId(), AnchorBottom)
        column:setMarginTop(COLUMN_GAP)
    else
        column:addAnchor(AnchorTop, 'parent', AnchorTop)
        column:setMarginTop(0)
    end
    if on then
        if classicColumnHeight == nil then
            classicColumnHeight = column:getHeight()
        end
        Pokegear.fitColumn()
    elseif classicColumnHeight ~= nil then
        column:setHeight(classicColumnHeight)
        classicColumnHeight = nil
        -- the side panel sized the windows Pokegear hid to 0; this is after they're all back
        if modules.game_mainpanel and modules.game_mainpanel.reloadMainPanelSizes then
            modules.game_mainpanel.reloadMainPanelSizes()
        end
    end
end

local function apply()
    if g_game.isOnline() then
        Chat.apply(active)
        applyWalkLock()
        applyTopBar()
        Phone.apply(active)
    end
    Hub.apply(active)
    Nearby.apply(active)
    Tracking.apply(active)
    Social.apply(active)
    Bag.apply(active)
    Loot.apply(active)
    Sockets.apply(active)
    Experience.apply(active)
    Activity.apply(active)
    OutfitWindow.apply(active)
    applySkills()
    Pokegear.layoutColumn()
    local mainPanel = modules.game_mainpanel
    if mainPanel and mainPanel.tidyTopBar then
        mainPanel.tidyTopBar()
    end
end

-- Settings > Interface > Reset layout
function resetLayout()
    if active and g_game.isOnline() then
        Pokegear.resetLayout()
    else
        Pokegear.forgetLayout()
    end
    local messages = modules.game_textmessage
    if g_game.isOnline() and messages and messages.displayStatusMessage then
        messages.displayStatusMessage(tr('Pokegear windows are back in their places.'))
    end
end

function toggleNearby()
    Nearby.toggle()
end

-- Tab (game_battle attackNext) cycles these, in the order Nearby lists them
function nearbyCreatures()
    if active and Nearby.isOpen() then
        return Nearby.creatures()
    end
end

-- the badge case shows in its own window (game_badgecase), so in Pokegear it gets no container window
local function isBadgeCase(container)
    local badgeCase = modules.game_badgecase
    return active and badgeCase ~= nil and badgeCase.isDexContainer ~= nil and badgeCase.isDexContainer(container)
end

-- game_textmessage hands server notices over in Pokegear (activity.lua)
function takeMessage(mode, text, msgtype, bannered)
    return Activity.takeMessage(mode, text, msgtype, bannered)
end

function claimsContainer(container)
    return Bag.claimsContainer(container) or Loot.claimsContainer(container) or isBadgeCase(container)
end

function refresh()
    local now = isActive()
    if now ~= active then
        active = now
        apply()
        signalcall(onLayoutChange, active)
        return
    end
    apply()
end

local startEvent
local compact

-- full, compact, or a phone (smaller still; phone.lua)
local function sizeClass()
    return Pokegear.isCompact() and (Phone.isPhone() and 'phone' or 'compact') or 'full'
end

-- a window resize (or a phone turning) across the compact size re-fits every Pokegear window
local function onRootGeometryChange()
    local now = sizeClass()
    if now == compact then
        return
    end
    compact = now
    if not active or not g_game.isOnline() then
        return
    end
    Hub.relayout()
    Chat.relayout()
    Nearby.relayout()
    Bag.relayout()
    Social.relayout()
    Pokegear.layoutColumn()
    scheduleEvent(Tracking.refresh, 50)
end

local function onGameStart()
    -- after game_console has restored the saved Chat On / Chat Off
    removeEvent(startEvent)
    startEvent = scheduleEvent(function()
        startEvent = nil
        apply()
    end, 100)
end

local function onGameEnd()
    removeEvent(startEvent)
    startEvent = nil
    removeEvent(redirectEvent)
    redirectEvent = nil
    Phone.apply(false)
    Hub.apply(false)
    Nearby.apply(false)
    Tracking.apply(false)
    Social.apply(false)
    Chat.apply(false)
    Bag.reset()
    Loot.reset()
    Sockets.apply(false)
    Experience.apply(false)
    Activity.reset()
    Pokegear.layoutColumn()
end

function init()
    g_ui.importStyle('hub')
    g_ui.importStyle('nearby')
    g_ui.importStyle('tracking')
    g_ui.importStyle('phone')
    Social.init()
    Chat.init()
    Bag.init()
    Loot.init()
    Sockets.init()
    Experience.init()
    Activity.init()
    OutfitWindow.init()
    active = isActive()
    compact = sizeClass()
    connect(rootWidget, { onGeometryChange = onRootGeometryChange })
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    disconnect(rootWidget, { onGeometryChange = onRootGeometryChange })
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    removeEvent(startEvent)
    startEvent = nil
    if active then
        active = false
        apply()
    end
    Phone.terminate()
    Hub.terminate()
    Pokegear.terminateHang()
    Nearby.terminate()
    Tracking.terminate()
    Social.terminate()
    Chat.terminate()
    Bag.terminate()
    Loot.terminate()
    Sockets.terminate()
    Experience.terminate()
    Activity.terminate()
    OutfitWindow.terminate()
end
