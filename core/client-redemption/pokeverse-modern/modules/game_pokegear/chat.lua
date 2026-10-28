-- Chat (docs/concepts/side-panel/chat-open.jpg, chat-folded.jpg): in Pokegear, game_console's
-- channels as a rounded card with a chip per channel and a face per private chat. Folded, the card
-- is only the text line, and new lines float over the map for a few seconds. game_console still
-- does the work: it keeps the tabs, sends what you type and tells us every line it adds
-- (onTabText). Its text line moves into the card while Pokegear is on, and the bottom panel hides.
local POSITION_SETTING = 'pokegearChatPosition'
local OPEN_SETTING = 'pokegearChatOpen'
local MAX_ROWS = 120
local MAX_FLOATS = 5
local FLOAT_SECONDS = 8
local OPEN_HEIGHT = 250

local COLORS = {
    local_ = '#eef2ff',
    global = '#5aa0ff',
    help = '#6fdc8c',
    npc = '#42e0c4',
    dm = '#b48cff',
    log = '#8fa0c4',
    channel = '#f2b45a',
    you = '#ffcb05',
    staff = '#e5484d',
}

local window, floats, restorePosition
local active = false
local open = true
local history = {} -- per tab: { {name, text, kind, time, own, staff, npc}, ... }
local unread = {}
local unreadFolded = 0
local chips, faces = {}, {}
local tabBar
local editHome -- where consoleTextEdit lived: its parent and anchors, to put it back

Chat = {}

local function console()
    return modules.game_console
end

local function textEdit()
    local c = console()
    return c and c.consoleTextEdit
end

local function myName()
    return g_game.getCharacterName() or ''
end

local function openSetting()
    return OPEN_SETTING .. '_' .. myName()
end

local function kindOf(tab)
    local c = console()
    if not c or not tab then
        return 'channel'
    end
    if tab == c.defaultTab then
        return 'local_'
    elseif tab == c.serverTab then
        return 'log'
    elseif tab.npcChat then
        return 'npc'
    end
    local name = tab:getText():lower()
    if tab.channelId then
        if name:find('global') then
            return 'global'
        elseif name:find('help') then
            return 'help'
        end
        return 'channel'
    end
    return 'dm'
end

local function chipText(tab)
    local c = console()
    if c and tab == c.defaultTab then
        return tr('Local')
    elseif c and tab == c.serverTab then
        return tr('Log')
    end
    return tab:getText()
end

local function initials(name)
    local letters = {}
    for word in (name or ''):gmatch('%S+') do
        letters[#letters + 1] = word:sub(1, 1):upper()
        if #letters == 2 then
            break
        end
    end
    if #letters == 1 then
        letters[2] = name:sub(2, 2):upper()
    end
    return table.concat(letters)
end

local function tabs()
    local c = console()
    if not c or not c.consoleTabBar then
        return {}
    end
    local bar = c.consoleTabBar
    local all = {}
    for _, list in ipairs({ bar.preTabs or {}, bar.tabs or {}, bar.postTabs or {} }) do
        for _, tab in ipairs(list) do
            all[#all + 1] = tab
        end
    end
    return all
end

local function currentTab()
    local c = console()
    return c and c.consoleTabBar and c.consoleTabBar:getCurrentTab()
end

-- "Red [100]: hi" -> "Red", "hi"
local function split(text, creatureName)
    if creatureName and creatureName ~= '' and text:sub(1, #creatureName) == creatureName then
        local rest = text:sub(#creatureName + 1)
        local message = rest:match('^ %[%d+%]: (.*)$') or rest:match('^: (.*)$')
        if message then
            return creatureName, message
        end
    end
    return nil, text
end

local refreshChips, refreshInput

local function isStaff(speaktype)
    local c = console()
    local types = c and c.SpeakTypesSettings
    return types ~= nil and (speaktype == types.channelRed or speaktype == types.privateRed
        or speaktype == types.broadcast)
end

local function addTag(row, text, color)
    local tag = g_ui.createWidget('PokegearChatTag', row.tags)
    tag:setText(text)
    tag:setImageColor(color)
end

local function fillRow(row, line)
    local color = line.own and COLORS.you or COLORS[line.kind] or COLORS.local_
    row.tags:destroyChildren()
    if line.name then
        row.face:setText(initials(line.name))
        row.face:setColor(color)
        row.name:setText(line.name)
        row.name:setColor(color)
        if line.npc then
            addTag(row, tr('NPC'), COLORS.npc)
        end
        if line.staff then
            addTag(row, tr('GM'), COLORS.staff)
        end
        row.time:setText(line.time)
    else
        row.face:setText('')
        row.face:setImageSource('')
        row.name:setText('')
        row.time:setText(line.time)
    end
    row.text:setText(line.text)
    row.text:setColor(line.npc and COLORS.npc or (line.kind == 'log' and COLORS.log or '#c9d3ea'))
end

local function rowHeight(row)
    return math.max(30, 18 + row.text:getHeight()) + 8
end

local function addRow(line)
    local row = g_ui.createWidget('PokegearChatRow', window.list)
    fillRow(row, line)
    row:setHeight(rowHeight(row))
    -- text-auto-resize sets the height once the label has its width
    scheduleEvent(function()
        if row and not row:isDestroyed() then
            row:setHeight(rowHeight(row))
        end
    end, 1)
    row.onMouseRelease = function(widget, mousePos, button)
        if button == MouseRightButton and line.name then
            local c = console()
            if c and c.processMessageMenu then
                c.processMessageMenu(mousePos, button, line.name, line.raw, nil, line.tab)
            end
            return true
        end
    end
    return row
end

local function scrollToBottom()
    scheduleEvent(function()
        if window and window.scroll then
            window.scroll:setValue(window.scroll:getMaximum())
        end
    end, 20)
end

local function fillList()
    if not window then
        return
    end
    window.list:destroyChildren()
    local tab = currentTab()
    for _, line in ipairs(tab and history[tab] or {}) do
        addRow(line)
    end
    scrollToBottom()
end

local function clearFloats()
    if floats then
        floats:destroyChildren()
    end
end

local function addFloat(line)
    if not floats or line.kind == 'log' then
        return
    end
    local float = g_ui.createWidget('PokegearChatFloat', floats)
    local tab = line.tab
    float.tag:setText(tab and chipText(tab) or '')
    float.tag:setImageColor(COLORS[line.kind] or COLORS.local_)
    local text = line.name and (line.name .. ': ' .. line.text) or line.text
    float.text:setText(text)
    float.text:setColor(line.npc and COLORS.npc or (line.own and COLORS.you or '#eef2ff'))
    float:setHeight(math.max(18, float.text:getHeight() + 2))
    scheduleEvent(function()
        if float and not float:isDestroyed() then
            float:setHeight(math.max(18, float.text:getHeight() + 2))
        end
    end, 1)
    while #floats:getChildren() > MAX_FLOATS do
        floats:getChildren()[1]:destroy()
    end
    scheduleEvent(function()
        if float and not float:isDestroyed() then
            g_effects.fadeOut(float, 600)
            scheduleEvent(function()
                if float and not float:isDestroyed() then
                    float:destroy()
                end
            end, 650)
        end
    end, FLOAT_SECONDS * 1000)
end

local function onTabText(tab, text, speaktype, creatureName)
    local name, message = split(text, creatureName)
    local kind = kindOf(tab)
    local line = { name = name, text = message, raw = text, kind = kind, tab = tab,
        time = os.date('%H:%M'), own = name ~= nil and name == myName(),
        npc = speaktype ~= nil and speaktype.npcChat and name ~= myName(), staff = isStaff(speaktype) }
    history[tab] = history[tab] or {}
    table.insert(history[tab], line)
    if #history[tab] > MAX_ROWS then
        table.remove(history[tab], 1)
    end
    if not active or not window then
        return
    end
    if open and tab == currentTab() then
        local bottom = window.scroll:getValue() >= window.scroll:getMaximum() - 4
        addRow(line)
        local rows = window.list:getChildren()
        if #rows > MAX_ROWS then
            rows[1]:destroy()
        end
        if bottom then
            scrollToBottom()
        end
    elseif kind ~= 'log' then
        unread[tab] = (unread[tab] or 0) + 1
    end
    if not open then
        addFloat(line)
        if kind ~= 'log' and not line.own then
            unreadFolded = unreadFolded + 1
        end
        refreshInput()
    end
    refreshChips()
end

local function selectTab(tab)
    local c = console()
    if c and c.consoleTabBar then
        c.consoleTabBar:selectTab(tab)
    end
end

-- the tab bar signals before it updates its current tab
local function onTabChange(bar, tab)
    if tab then
        unread[tab] = nil
    end
    scheduleEvent(function()
        if active and window then
            refreshChips()
            refreshInput()
            if open then
                fillList()
            end
        end
    end, 1)
end

refreshChips = function()
    if not window then
        return
    end
    window.header.chips:destroyChildren()
    window.header.faces:destroyChildren()
    local current = currentTab()
    local faceCount = 0
    for _, tab in ipairs(tabs()) do
        local kind = kindOf(tab)
        local count = unread[tab] or 0
        if kind == 'dm' then
            local face = g_ui.createWidget('PokegearChatFace', window.header.faces)
            face:setText(initials(tab:getText()))
            face:setTooltip(tab:getText())
            face:setOn(tab == current)
            face.count:setText(tostring(count))
            face.count:setVisible(count > 0)
            face.onClick = function() selectTab(tab) end
            faceCount = faceCount + 1
        else
            local chip = g_ui.createWidget('PokegearChatChip', window.header.chips)
            chip:setText(chipText(tab))
            chip:setOn(tab == current)
            if tab ~= current then
                chip:setColor(COLORS[kind] or COLORS.channel)
            end
            chip:setWidth(chip:getTextSize().width + 22)
            chip.count:setText(tostring(count))
            chip.count:setVisible(count > 0)
            chip.onClick = function() selectTab(tab) end
            chip.onMouseRelease = function(widget, mousePos, button)
                if button == MouseRightButton then
                    local c = console()
                    if c and c.processChannelTabMenu then
                        c.processChannelTabMenu(tab, mousePos, button)
                    end
                    return true
                end
            end
        end
    end
    local plus = g_ui.createWidget('PokegearChatChip', window.header.chips)
    plus:setText('+')
    plus:setWidth(24)
    plus:setTooltip(tr('Join a channel'))
    plus.onClick = function() g_game.requestChannels() end
    window.header.faces:setWidth(math.max(1, faceCount * 28 - 4))
end

refreshInput = function()
    if not window then
        return
    end
    local tab = currentTab()
    local input = window.input
    local kind = kindOf(tab)
    input.channel:setText(tab and chipText(tab) or '')
    input.channel:setImageColor(COLORS[kind] or COLORS.local_)
    local edit = textEdit()
    local typing = edit ~= nil and edit:isExplicitlyVisible()
    input.hint:setVisible(not typing)
    input.enterChip:setVisible(not typing)
    if not open and unreadFolded > 0 then
        input.hint:setText(tr('Press Enter to chat') .. '  \183  ' .. tr('%d new', unreadFolded))
    else
        input.hint:setText(tr('Press Enter to chat'))
    end
    input.open:setVisible(not open)
end

local function applyOpen()
    if not window then
        return
    end
    window.header:setVisible(open)
    window.list:setVisible(open)
    window.scroll:setVisible(open)
    if open then
        window:setImageSource('/modules/game_pokegear/images/card')
        window:setPadding(8)
        window:setPaddingLeft(10)
        window:setPaddingRight(10)
        window:setHeight(OPEN_HEIGHT)
        clearFloats()
        unreadFolded = 0
        fillList()
    else
        window:setImageSource('')
        window:setPadding(0)
        window:setHeight(window.input:getHeight())
    end
    floats:setVisible(not open)
    refreshChips()
    refreshInput()
end

function Chat.setOpen(on)
    open = on
    if g_game.isOnline() then
        g_settings.set(openSetting(), on)
    end
    applyOpen()
end

function Chat.isOpen()
    return open
end

local function onEditVisibility()
    refreshInput()
end

-- the text line moves into the card and back
local function adoptEdit()
    local edit = textEdit()
    if not edit or edit:getParent() == window.input.slot then
        return
    end
    editHome = editHome or { parent = edit:getParent() }
    edit:breakAnchors()
    edit:setParent(window.input.slot)
    edit:fill('parent')
    edit:setMarginLeft(0)
    edit:setMarginRight(0)
    edit:setMarginBottom(0)
    edit:setMarginTop(0)
    edit:setImageColor('#00000000')
    edit:setTextOffset({ x = 4, y = 2 })
    connect(edit, { onVisibilityChange = onEditVisibility })
end

local function releaseEdit()
    local edit = textEdit()
    if not edit or not editHome or edit:getParent() == editHome.parent then
        return
    end
    disconnect(edit, { onVisibilityChange = onEditVisibility })
    edit:breakAnchors()
    edit:setParent(editHome.parent)
    edit:addAnchor(AnchorLeft, 'sayModeButton', AnchorRight)
    edit:addAnchor(AnchorRight, 'toggleChat', AnchorLeft)
    edit:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    edit:setMarginLeft(5)
    edit:setMarginRight(5)
    edit:setMarginBottom(3)
    edit:setHeight(18)
    edit:setTextOffset({ x = 0, y = 0 })
    edit:setImageColor('#ffffff')
end

local function bottomPanel()
    return modules.game_interface.getBottomPanel()
end

local function build()
    window = g_ui.createWidget('PokegearChat', modules.game_interface.getRootPanel())
    floats = g_ui.createWidget('PokegearChatFloats', modules.game_interface.getRootPanel())
    floats:addAnchor(AnchorLeft, 'pokegearChat', AnchorLeft)
    floats:addAnchor(AnchorBottom, 'pokegearChat', AnchorTop)
    floats:setMarginBottom(8)
    window:hide()
    floats:hide()
    window.header.fold.onClick = function() Chat.setOpen(false) end
    window.input.open.onClick = function() Chat.setOpen(true) end
    window.input.onMouseRelease = function(widget, mousePos, button)
        if button == MouseLeftButton and not open then
            Chat.setOpen(true)
            return true
        end
    end
    window.header.chips.onMouseWheel = function(widget, mousePos, direction)
        local c = console()
        if c and c.consoleTabBar then
            if direction == MouseWheelUp then
                c.consoleTabBar:selectPrevTab()
            else
                c.consoleTabBar:selectNextTab()
            end
        end
        return true
    end
    restorePosition = Pokegear.makeMovable(window, window.header, POSITION_SETTING, function()
        window:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        window:addAnchor(AnchorBottom, 'parent', AnchorBottom)
        window:setMarginLeft(12)
        window:setMarginBottom(12)
    end)
end

local function show()
    if not window then
        build()
    end
    open = g_settings.getBoolean(openSetting(), true)
    local panel = bottomPanel()
    if panel then
        panel:hide()
    end
    adoptEdit()
    local c = console()
    tabBar = c and c.consoleTabBar
    if tabBar then
        connect(tabBar, { onTabChange = onTabChange })
    end
    restorePosition()
    window:show()
    window:raise()
    floats:raise()
    applyOpen()
end

local function hide()
    if tabBar then
        disconnect(tabBar, { onTabChange = onTabChange })
        tabBar = nil
    end
    releaseEdit()
    local panel = bottomPanel()
    if panel and g_game.isOnline() then
        panel:show()
    end
    if window then
        window:hide()
        floats:hide()
        clearFloats()
    end
end

function Chat.apply(isActive)
    local now = isActive and g_game.isOnline()
    if now == active then
        if active then
            refreshChips()
        end
        return
    end
    active = now
    if active then
        show()
    else
        hide()
    end
end

local function onGameEnd()
    history, unread, unreadFolded = {}, {}, 0
end

function Chat.init()
    g_ui.importStyle('chat')
    local c = console()
    if c then
        connect(c, { onTabText = onTabText })
    end
    connect(g_game, { onGameEnd = onGameEnd })
end

function Chat.terminate()
    local c = console()
    if c then
        disconnect(c, { onTabText = onTabText })
    end
    disconnect(g_game, { onGameEnd = onGameEnd })
    active = false
    hide()
    if window then
        window:destroy()
        window = nil
    end
    if floats then
        floats:destroy()
        floats = nil
    end
end
