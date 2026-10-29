-- Chat (docs/concepts/side-panel/chat-open.jpg, chat-folded.jpg): in Pokegear, game_console's
-- channels as a rounded card with a chip per channel and a face per private chat. Folded, the card
-- is only the text line, and new lines float over the map for a few seconds. game_console still
-- does the work: it keeps the tabs, sends what you type and tells us every line it adds
-- (onTabText). Its text line moves into the card while Pokegear is on, and the bottom panel hides.
-- NPC lines also show in Local, teal, so NPCs and players talk side by side there.
local POSITION_SETTING = 'pokegearChatPosition'
local OPEN_SETTING = 'pokegearChatOpen'
local LOCK_SETTING = 'pokegearChatLocked'
local MAX_ROWS = 120
local MAX_FLOATS = 5
local FLOAT_SECONDS = 8
local OPEN_WIDTH, OPEN_HEIGHT = 540, 330
local COMPACT_WIDTH, COMPACT_HEIGHT = 480, 230 -- small screens (Pokegear.isCompact)
local FOLDED_WIDTH = 400

-- text colours, and the fill and text of each channel's tag
local COLORS = {
    local_ = '#eef2ff',
    global = '#7fb4ff',
    help = '#8be3a0',
    npc = '#42e0c4',
    dm = '#c3a2ff',
    log = '#8fa0c4',
    channel = '#f2b45a',
    you = '#ffcb05',
    staff = '#ff8a8a',
}
local TAGS = {
    local_ = { '#3b4a6b', '#eef2ff' },
    global = { '#3a6fc4', '#ffffff' },
    help = { '#8be3a0', '#0d1f14' },
    npc = { '#42e0c4', '#06201c' },
    dm = { '#9b6dff', '#ffffff' },
    log = { '#3b4a6b', '#c9d3ea' },
    channel = { '#c98a2e', '#ffffff' },
    staff = { '#e5484d', '#ffffff' },
}
local DOTS = { global = '#5aa0ff', help = '#6fdc8c', npc = '#42e0c4', log = '#8fa0c4', channel = '#f2b45a' }

local window, floats, restorePosition
local active = false
local open = true
local history = {} -- per tab: { {name, text, kind, time, own, staff, npc, tab}, ... }
local unread = {}
local unreadFolded = 0
local tabBar
local editHome -- where consoleTextEdit lived, to put it back

Chat = {}

local function console()
    return modules.game_console
end

local function textEdit()
    local c = console()
    return c and c.consoleTextEdit
end

local myName = Pokegear.myName

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

-- the concept's chip order; other channels after NPCs, then the Server Log
local CHIP_ORDER = { local_ = 1, global = 2, help = 3, npc = 4, channel = 5, log = 6, dm = 7 }

local function chipText(tab)
    local c = console()
    if c and tab == c.defaultTab then
        return tr('Local')
    elseif c and tab == c.serverTab then
        return tr('Log')
    elseif tab.npcChat then
        return tr('NPCs')
    end
    return tab:getText()
end

local initials = Pokegear.initials

local function clock()
    local hour = tonumber(os.date('%H'))
    local suffix = hour >= 12 and 'PM' or 'AM'
    hour = hour % 12
    return string.format('%d:%s %s', hour == 0 and 12 or hour, os.date('%M'), suffix)
end

-- text goes through setColoredText, where braces mark colour runs
local function plain(text)
    return (text:gsub('[{}]', ''))
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

local function pill(parent, style, text, kind)
    local colors = TAGS[kind] or TAGS.channel
    local widget = g_ui.createWidget(style, parent)
    widget:setText(text)
    widget:setImageColor(colors[1])
    widget:setColor(colors[2])
    return widget
end

-- the client only knows an outfit while its creature is on screen, so the last one seen is kept
local outfits, npcs = {}, {}

local function outfitOf(name)
    if not name or name == '' then
        return nil
    end
    local player = g_game.getLocalPlayer()
    if player and player:getName() == name then
        outfits[name] = player:getOutfit()
        return outfits[name]
    end
    for _, creature in ipairs(getCreaturesAroundPlayer(false)) do
        if creature:getName() == name and not creature:isMonster() then
            outfits[name] = creature:getOutfit()
            npcs[name] = creature:isNpc() or nil
            break
        end
    end
    return outfits[name]
end

-- famous NPCs have a drawn portrait (game_npcdialog); a player who shares the name doesn't get it
local function portraitOf(name, npc)
    local dialog = modules.game_npcdialog
    return npc and name and dialog and dialog.getPortrait and dialog.getPortrait(name) or nil
end

local function setFace(face, name, color, fallback, npc)
    local portrait = portraitOf(name, npc)
    local outfit = not portrait and outfitOf(name) or nil
    face.portrait:setVisible(portrait ~= nil)
    if portrait then
        face.portrait:setImageSource(portrait)
    end
    local creature = face.clip.creature
    creature:setVisible(outfit ~= nil)
    if outfit then
        creature:setOutfit(outfit)
    end
    face:setText((portrait or outfit) and '' or (fallback or initials(name)))
    face:setColor(color)
    face.ring:setImageColor(color)
end

local function nameColor(line)
    if line.npc then
        return COLORS.npc
    elseif line.staff then
        return COLORS.staff
    elseif line.own then
        return COLORS.you
    elseif line.kind == 'dm' then
        return COLORS.dm
    end
    return COLORS.local_
end

local function textColor(line)
    if line.npc then
        return COLORS.npc
    elseif line.kind == 'log' then
        return COLORS.log
    end
    return '#e6ecfa'
end

local function fillRow(row, line)
    local head = row.head
    head:destroyChildren()
    local color = nameColor(line)
    if line.name then
        setFace(row.face, line.name, color, line.npc and '+' or nil, line.npc)
        if line.staff then
            pill(head, 'PokegearChatHeadPill', tr('GM'), 'staff')
        end
        local name = g_ui.createWidget('PokegearChatName', head)
        name:setText(line.name)
        name:setColor(color)
        if line.npc then
            pill(head, 'PokegearChatHeadPill', tr('NPC'), 'npc')
        end
    else
        setFace(row.face, nil, COLORS.log, 'i')
    end
    local time = g_ui.createWidget('PokegearChatTime', head)
    time:setText(line.time)
    row.text:setText(line.text)
    row.text:setColor(textColor(line))
    if line.own then
        row:setImageColor('#1a2742')
    end
end

local function rowHeight(row)
    return math.max(32, 21 + row.text:getHeight()) + 8
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
    local kind = line.npc and 'npc' or line.kind
    pill(float.tags, 'PokegearChatPill', line.npc and tr('NPC') or (line.tab and chipText(line.tab) or ''), kind)
    if line.staff then
        pill(float.tags, 'PokegearChatPill', tr('GM'), 'staff')
    end
    float.tags:setWidth(1)
    local body = line.npc and COLORS.npc or '#ffffff'
    float.text:setColor(body)
    if line.name then
        local color = line.npc and COLORS.npc or (line.staff and COLORS.staff) or (line.own and COLORS.you)
            or COLORS[line.kind] or COLORS.local_
        float.text:setColoredText(string.format('{%s:, %s} {%s, %s}', plain(line.name), color, plain(line.text), body))
    else
        float.text:setText(line.text)
    end
    local function fit()
        if float and not float:isDestroyed() then
            float:setHeight(math.max(18, float.text:getHeight() + 2))
        end
    end
    fit()
    scheduleEvent(fit, 1)
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

local function remember(tab, line)
    history[tab] = history[tab] or {}
    table.insert(history[tab], line)
    if #history[tab] > MAX_ROWS then
        table.remove(history[tab], 1)
    end
    if active and window and open and tab == currentTab() then
        local bottom = window.scroll:getValue() >= window.scroll:getMaximum() - 4
        addRow(line)
        local rows = window.list:getChildren()
        if #rows > MAX_ROWS then
            rows[1]:destroy()
        end
        if bottom then
            scrollToBottom()
        end
    elseif line.kind ~= 'log' and not line.own and not line.notice then
        unread[tab] = (unread[tab] or 0) + 1
    end
end

local function onTabText(tab, text, speaktype, creatureName)
    local name, message = split(text, creatureName)
    local kind = kindOf(tab)
    local line = { name = name, text = message, raw = text, kind = kind, tab = tab, time = clock(),
        own = name ~= nil and name == myName(), staff = isStaff(speaktype),
        npc = speaktype ~= nil and speaktype.npcChat == true and name ~= nil and name ~= myName() }
    -- a milestone pops up as a toast and goes in Activity (activity.lua), so it doesn't float here too
    line.notice = name == nil and Activity.claims(text)
    outfitOf(name)
    -- an NPC talking aloud comes as a plain say
    line.npc = line.npc or (name ~= nil and name ~= myName() and npcs[name] == true)
    remember(tab, line)
    local c = console()
    if line.npc and c and c.defaultTab and tab ~= c.defaultTab then
        local copy = {}
        for k, v in pairs(line) do
            copy[k] = v
        end
        copy.kind = 'local_'
        remember(c.defaultTab, copy)
    end
    if not active or not window then
        return
    end
    if not open and not line.notice then
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

local function addFace(parent, tab, current)
    local face = g_ui.createWidget('PokegearChatFace', parent)
    setFace(face, tab:getText(), tab == current and COLORS.you or COLORS.dm)
    face:setTooltip(tab:getText())
    local count = unread[tab] or 0
    face.count:setText(tostring(count))
    face.count:setVisible(count > 0)
    face.onClick = function()
        selectTab(tab)
        if not open then
            Chat.setOpen(true)
        end
    end
    return face
end

refreshChips = function()
    if not window then
        return
    end
    local header = window.header
    header.chips:destroyChildren()
    header.faces:destroyChildren()
    window.foldedFaces:destroyChildren()
    local current = currentTab()
    local faceCount = 0
    local list = tabs()
    local index = {}
    for i, tab in ipairs(list) do
        index[tab] = i
    end
    table.sort(list, function(a, b)
        local ra, rb = CHIP_ORDER[kindOf(a)] or 5, CHIP_ORDER[kindOf(b)] or 5
        if ra ~= rb then
            return ra < rb
        end
        return index[a] < index[b]
    end)
    for _, tab in ipairs(list) do
        local kind = kindOf(tab)
        local count = unread[tab] or 0
        if kind == 'dm' then
            addFace(header.faces, tab, current)
            addFace(window.foldedFaces, tab, current)
            faceCount = faceCount + 1
        else
            local chip = g_ui.createWidget('PokegearChatChip', header.chips)
            local on = tab == current
            chip:setOn(on)
            chip.label:setText(chipText(tab))
            chip.label:setColor(on and '#0d1424' or '#eef2ff')
            local dot = not on and DOTS[kind]
            chip.dot:setVisible(dot ~= nil and dot ~= false)
            if dot then
                chip.dot:setImageColor(dot)
            end
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
    local plus = g_ui.createWidget('PokegearChatChip', header.chips)
    plus.label:setText('+')
    plus.dot:hide()
    plus:setPaddingLeft(9)
    plus:setPaddingRight(9)
    plus:setTooltip(tr('Join a channel'))
    plus.onClick = function() g_game.requestChannels() end
    local facesWidth = math.max(1, faceCount * 34 - 6)
    header.faces:setWidth(facesWidth)
    window.foldedFaces:setWidth(facesWidth)
    if not open then
        window:setWidth(FOLDED_WIDTH + (faceCount > 0 and facesWidth + 10 or 0))
    end
end

refreshInput = function()
    if not window then
        return
    end
    local tab = currentTab()
    local input = window.input
    local edit = textEdit()
    local typing = edit ~= nil and edit:isExplicitlyVisible()
    local empty = not typing or edit:getText() == ''
    -- folded, the pill names the channel; open, the chips already do
    input.channel:setVisible(not open)
    if tab then
        input.channel:setText(chipText(tab))
    end
    input.channel:setWidth(open and 0 or input.channel:getTextSize().width + 24)
    input.channel:setMarginLeft(open and 0 or 6)
    -- the edit's own placeholder is a bitmap font that never lines up with the hint, so the hint stands in
    input.hint:setVisible(empty)
    input.enterChip:setVisible(not typing)
    if typing then
        input.hint:setText(tr('Type here to chat'))
    elseif not open and unreadFolded > 0 then
        input.hint:setText(tr('Press Enter to chat') .. '  \183  ' .. tr('%d new', unreadFolded))
    else
        input.hint:setText(tr('Press Enter to chat'))
    end
end

local function applyOpen()
    if not window then
        return
    end
    window.header:setVisible(open)
    window.list:setVisible(open)
    window.scroll:setVisible(open)
    window.send:setVisible(open)
    window.foldedFaces:setVisible(not open)
    window.input:removeAnchor(AnchorRight)
    if open then
        window.input:addAnchor(AnchorRight, 'send', AnchorLeft)
        window:setImageSource('/modules/game_pokegear/images/card')
        window:setPadding(10)
        window:setPaddingLeft(12)
        window:setPaddingRight(12)
        local compact = Pokegear.isCompact()
        window:setWidth(compact and COMPACT_WIDTH or OPEN_WIDTH)
        window:setHeight(compact and COMPACT_HEIGHT or OPEN_HEIGHT)
        clearFloats()
        unreadFolded = 0
        fillList()
    else
        window.input:addAnchor(AnchorRight, 'parent', AnchorRight)
        window:setImageSource('')
        window:setPadding(0)
        window:setHeight(window.input:getHeight())
    end
    floats:setVisible(not open)
    refreshChips()
    if not open then
        window.input:setMarginRight(window:getWidth() - FOLDED_WIDTH)
    else
        window.input:setMarginRight(8)
    end
    refreshInput()
end

-- the screen crossed the compact size
function Chat.relayout()
    applyOpen()
end

-- a card you moved folds down onto its line and opens upwards from it, like the one in its corner
local function keepBottom(change)
    local saved = g_settings.getPoint(POSITION_SETTING)
    if not window or not saved or (saved.x == 0 and saved.y == 0) then
        change()
        return
    end
    local bottom = window:getY() + window:getHeight()
    change()
    local pos = { x = window:getX(), y = math.max(0, bottom - window:getHeight()) }
    window:setPosition(pos)
    g_settings.set(POSITION_SETTING, pos)
end

local function applyLock()
    if not window then
        return
    end
    local locked = g_settings.getBoolean(LOCK_SETTING, false)
    window.pokegearLocked = locked
    local lock = window.header.lock
    lock:setOn(locked)
    lock.icon:setImageSource('/modules/game_pokegear/images/' .. (locked and 'lock' or 'unlock'))
    lock.icon:setImageColor(locked and '#ffcb05' or '#8fa0c4')
    lock:setTooltip(locked and tr('Locked: click to move the chat again') or tr('Lock the chat where it is'))
    window.header:setTooltip(locked and '' or tr('Drag to move'))
end

local function setOpenNow(on)
    open = on
    -- what came in while folded is in front of you once it opens
    local tab = on and currentTab()
    if tab then
        unread[tab] = nil
    end
    if g_game.isOnline() then
        g_settings.set(openSetting(), on)
    end
    applyOpen()
end

function Chat.setOpen(on)
    if window and on ~= open then
        keepBottom(function() setOpenNow(on) end)
    else
        setOpenNow(on)
    end
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
    editHome.font = editHome.font or edit:getFont()
    editHome.align = editHome.align or edit:getTextAlign()
    edit:setImageColor('#00000000')
    edit:mergeStyle({ ['ttf-font'] = '/fonts/ttf/arialb.ttf', ['ttf-font-size'] = 12 })
    editHome.paddingTop = editHome.paddingTop or edit:getPaddingTop()
    editHome.paddingLeft = editHome.paddingLeft or edit:getPaddingLeft()
    edit:setTextAlign(AlignLeft)
    -- a text edit places its text by padding, not text-offset
    edit:setPaddingTop(11)
    edit:setPaddingLeft(4)
    edit:mergeStyle({ ['placeholder-color'] = '#00000000' })
    connect(edit, { onVisibilityChange = onEditVisibility, onTextChange = onEditVisibility })
end

local function releaseEdit()
    local edit = textEdit()
    if not edit or not editHome or edit:getParent() == editHome.parent then
        return
    end
    disconnect(edit, { onVisibilityChange = onEditVisibility, onTextChange = onEditVisibility })
    edit:mergeStyle({ ['placeholder-color'] = '#707070' })
    edit:breakAnchors()
    edit:setParent(editHome.parent)
    edit:addAnchor(AnchorLeft, 'sayModeButton', AnchorRight)
    edit:addAnchor(AnchorRight, 'toggleChat', AnchorLeft)
    edit:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    edit:setMarginLeft(5)
    edit:setMarginRight(5)
    edit:setMarginBottom(3)
    edit:setHeight(18)
    edit:setImageColor('#ffffff')
    if editHome.paddingTop then
        edit:setPaddingTop(editHome.paddingTop)
        edit:setPaddingLeft(editHome.paddingLeft)
    end
    if editHome.font then
        edit:setFont(editHome.font)
    end
    if editHome.align then
        edit:setTextAlign(editHome.align)
    end
end

local function bottomPanel()
    return modules.game_interface.getBottomPanel()
end

-- One line at a time, the Pokegear way: Enter, Send or a click on the line opens it (WASD types),
-- Enter sends it and you walk again, Escape or an empty Enter drops it. game_console's own Enter
-- lives on the hidden bottom panel, so the card binds its own.

local function lineOpen()
    local edit = textEdit()
    return edit ~= nil and edit:isExplicitlyVisible()
end

-- key events only reach the edit when every parent up to the root has it as its focused child
local function focusEdit(edit)
    local child, parent = edit, edit:getParent()
    while parent do
        parent:focusChild(child, KeyboardFocusReason)
        child, parent = parent, parent:getParent()
    end
end

local function openLine()
    local c, edit = console(), textEdit()
    local toggle = c and c.consoleToggleChat
    if not toggle or not edit or not window then
        return
    end
    if toggle.isChecked then
        c.toggleChat()
        if toggle.isChecked then
            return -- the interface is locked (cutscenes)
        end
    end
    focusEdit(edit)
end

local function closeLine()
    local c = console()
    local toggle = c and c.consoleToggleChat
    if toggle and not toggle.isChecked then
        c.toggleChat()
    end
end

local function sendLine()
    local c, edit = console(), textEdit()
    if not c or not edit then
        return
    end
    if lineOpen() and edit:getText() ~= '' then
        c.sendCurrentMessage()
        closeLine()
    else
        openLine()
    end
end

local function onEnter()
    local hotkeys = modules.game_hotkeys
    if not active or not g_game.isOnline() or (hotkeys and hotkeys.areHotkeysDisabled and hotkeys.areHotkeysDisabled()) then
        return false
    end
    local edit = textEdit()
    if not edit then
        return false
    end
    if not lineOpen() or not edit:isActive() then
        openLine()
    elseif edit:getText() ~= '' then
        sendLine()
    else
        closeLine()
    end
    return true
end

local function onEscape()
    if active and lineOpen() then
        closeLine()
        return true
    end
    return false
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
    window.header.lock.onClick = function()
        g_settings.set(LOCK_SETTING, not g_settings.getBoolean(LOCK_SETTING, false))
        applyLock()
    end
    window.send.onClick = sendLine
    window.input:setTooltip(tr('Click to chat'))
    window.input.onMouseRelease = function(widget, mousePos, button)
        if button ~= MouseLeftButton then
            return false
        end
        if not open then
            Chat.setOpen(true)
        end
        openLine()
        return true
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
    local root = modules.game_interface.getRootPanel()
    g_keyboard.bindKeyDown('Enter', onEnter, root)
    g_keyboard.bindKeyDown('Escape', onEscape, root)
    local c = console()
    tabBar = c and c.consoleTabBar
    if tabBar then
        connect(tabBar, { onTabChange = onTabChange })
    end
    restorePosition()
    applyLock()
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
    local root = modules.game_interface.getRootPanel()
    if root then
        g_keyboard.unbindKeyDown('Enter', onEnter, root)
        g_keyboard.unbindKeyDown('Escape', onEscape, root)
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
        -- what came in before the card showed is already on it
        if open then
            local tab = currentTab()
            if tab then
                unread[tab] = nil
            end
        end
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
