-- Key bindings page of Settings > Controls. Replaces Redemption's keybins.lua: one list per preset
-- and chat mode with every Keybind action and item hotkey, grouped by category. A key is set by
-- clicking it and pressing the new key; a key that is taken shows who has it, with Swap keys.
-- Item hotkeys are edited in the Item hotkeys window (game_hotkeys), which keeps both chat modes
-- of a hotkey together.

local IMAGES = '/modules/game_hotkeys/images/'
local ITEMS = '__items'
local GROUP_ORDER = { 'Pokemon', ITEMS, 'Windows', 'Movement', 'Chat', 'UI', 'Sound', 'Dialogs', 'Misc' }

local changedOptions = {}
local presetWindow = nil
local searchEvent
local filter -- nil for everything, 'items' for the Item hotkeys tab
local chatMode = CHAT_MODE.ON
local capture -- { row, slot }
local clashRow

local function page()
    return panels.keybindsPanel
end

local function currentPreset()
    local option = page().presets.list:getCurrentOption()
    return option and option.text
end

-- presets

function addNewPreset()
    presetWindow:setText(tr('Add hotkey preset'))
    presetWindow.info:setText(tr('Enter a name for the new preset:'))
    presetWindow.field:clearText()
    presetWindow.field:show()
    presetWindow.field:focus()
    presetWindow:setWidth(360)
    presetWindow.action = 'add'
    presetWindow:show()
    presetWindow:raise()
    presetWindow:focus()
    controller.ui:hide()
end

function copyPreset()
    presetWindow:setText(tr('Copy hotkey preset'))
    presetWindow.info:setText(tr('Enter a name for the new preset:'))
    presetWindow.field:clearText()
    presetWindow.field:show()
    presetWindow.field:focus()
    presetWindow.action = 'copy'
    presetWindow:setWidth(360)
    presetWindow:show()
    presetWindow:raise()
    presetWindow:focus()
    controller.ui:hide()
end

function renamePreset()
    presetWindow:setText(tr('Rename hotkey preset'))
    presetWindow.info:setText(tr('Enter a name for the preset:'))
    presetWindow.field:setText(currentPreset() or '')
    presetWindow.field:setCursorPos(1000)
    presetWindow.field:show()
    presetWindow.field:focus()
    presetWindow.action = 'rename'
    presetWindow:setWidth(360)
    presetWindow:show()
    presetWindow:raise()
    presetWindow:focus()
    controller.ui:hide()
end

function removePreset()
    presetWindow:setText(tr('Warning'))
    presetWindow.info:setText(tr('Do you really want to delete the hotkey preset %s?', currentPreset() or ''))
    presetWindow.field:hide()
    presetWindow.action = 'remove'
    presetWindow:setWidth(presetWindow.info:getTextSize().width + presetWindow:getPaddingLeft() +
        presetWindow:getPaddingRight())
    presetWindow:show()
    presetWindow:raise()
    presetWindow:focus()
    controller.ui:hide()
end

function okPresetWindow()
    local presetName = presetWindow.field:getText():trim()
    local selectedPreset = currentPreset()
    local list = page().presets.list

    presetWindow:hide()
    show()

    if presetWindow.action == 'add' then
        Keybind.newPreset(presetName)
        if modules.game_actionbar and modules.game_actionbar.createHotkeySet then
            modules.game_actionbar.createHotkeySet(presetName, nil)
        end
        list:addOption(presetName)
        list:setCurrentOption(presetName)
    elseif presetWindow.action == 'copy' then
        if not Keybind.copyPreset(selectedPreset, presetName) then
            return
        end
        if modules.game_actionbar and modules.game_actionbar.createHotkeySet then
            modules.game_actionbar.createHotkeySet(presetName, selectedPreset)
        end
        list:addOption(presetName)
        list:setCurrentOption(presetName)
    elseif presetWindow.action == 'rename' then
        if selectedPreset ~= presetName then
            list:updateCurrentOption(presetName)
            if changedOptions['currentPreset'] then
                changedOptions['currentPreset'].value = presetName
            end
            Keybind.renamePreset(selectedPreset, presetName)
            if modules.game_actionbar and modules.game_actionbar.renameHotkeySet then
                modules.game_actionbar.renameHotkeySet(selectedPreset, presetName)
            end
        end
    elseif presetWindow.action == 'remove' then
        if Keybind.removePreset(selectedPreset) then
            list:removeOption(selectedPreset)
            if modules.game_actionbar and modules.game_actionbar.removeHotkeySet then
                modules.game_actionbar.removeHotkeySet(selectedPreset)
                if modules.game_actionbar.selectHotkeySet then
                    modules.game_actionbar.selectHotkeySet(Keybind.currentPreset)
                end
            end
        end
    end
    updateKeybinds()
end

function cancelPresetWindow()
    presetWindow:hide()
    show()
end

function presetOption(widget, key, value, force)
    if not controller.ui:isVisible() then
        return
    end

    changedOptions[key] = { widget = widget, value = value, force = force }
    if key == "currentPreset" then
        Keybind.selectPreset(value)
        page().presets.list:setCurrentOption(value, true)
    end
end

function listKeybindsComboBox(value)
    presetOption(page().presets.list, 'currentPreset', value, false)
    if modules.game_actionbar and modules.game_actionbar.selectHotkeySet then
        modules.game_actionbar.selectHotkeySet(value)
    end
    changedOptions = {}
    updateKeybinds()
end

-- key caps

local function setKeyCap(widget, key, state)
    if state == 'capture' then
        widget:setImageSource(IMAGES .. 'key_capture')
        widget:setColor('#ffd75a')
        widget:setText(tr('Press a key'))
    elseif state == 'clash' then
        widget:setImageSource(IMAGES .. 'key_bad')
        widget:setColor('#ffffff')
        widget:setText(key)
    elseif not key or key == '' then
        widget:setImageSource(IMAGES .. 'key_empty')
        widget:setText('')
    else
        widget:setImageSource(IMAGES .. 'key')
        widget:setColor('#ffffff')
        widget:setText(key)
    end
end

local function userName(user)
    if user.type == 'reserved' then
        return tr('walking')
    elseif user.type == 'keybind' then
        return tr(user.action)
    end
    local name = modules.game_hotkeys and modules.game_hotkeys.describeHotkey(user.hotkey) or tr('an item hotkey')
    return tr('the %s hotkey', name)
end

local function clearClash()
    if clashRow then
        clashRow.owner:setOn(false)
        setKeyCap(clashRow.owner[clashRow.slot], clashRow.owner.keys[clashRow.slot])
        clashRow:destroy()
        clashRow = nil
    end
end

local function setActionKey(category, action, slot, key)
    if slot == 'primary' then
        Keybind.setPrimaryActionKey(category, action, currentPreset(), key, chatMode)
    else
        Keybind.setSecondaryActionKey(category, action, currentPreset(), key, chatMode)
    end
end

-- an item hotkey exists once per chat mode; a swap moves the key in every mode that has it
local function setHotkeyKey(user, key)
    local uid = user.hotkey.data.uid
    for _, mode in ipairs({ CHAT_MODE.ON, CHAT_MODE.OFF }) do
        for id, hotkey in ipairs(Keybind.hotkeys[mode][Keybind.currentPreset] or {}) do
            if (uid and hotkey.data.uid == uid) or (not uid and mode == chatMode and id == user.hotkeyId) then
                local primary = user.slot == 'primary' and key or hotkey.primary
                local secondary = user.slot == 'secondary' and key or hotkey.secondary
                Keybind.editHotkeyKeys(id, primary, secondary, mode)
            end
        end
    end
end

local function showClash(row, slot, key, user)
    clearClash()
    clashRow = g_ui.createWidget('KbClash', page().rows)
    page().rows:moveChildToIndex(clashRow, page().rows:getChildIndex(row) + 1)
    clashRow.owner, clashRow.slot = row, slot
    row:setOn(true)
    setKeyCap(row[slot], key, 'clash')
    if user.type == 'chat' then
        clashRow.text:setText(tr('%s types in the chat. Add Ctrl or Alt, or bind it under WASD.', key))
    else
        clashRow.text:setText(tr('%s is already used by %s.', key, userName(user)))
    end
    clashRow.swap:setVisible(user.type == 'keybind' or user.type == 'hotkey')
    clashRow.swap.onClick = function()
        local oldKey = row.keys[slot] or ''
        clearClash()
        if user.type == 'keybind' then
            setActionKey(user.category, user.action, user.slot, oldKey)
        else
            setHotkeyKey(user, oldKey)
        end
        setActionKey(row.category, row.action, slot, key)
        updateKeybinds()
    end
    clashRow.other.onClick = function()
        clearClash()
        startCapture(row, slot)
    end
    page().rows:ensureChildVisible(clashRow)
end

local function typesInChat(key)
    local base = key:match('^Shift%+(.+)$') or key
    return base:len() == 1 or base == 'Space'
end

local function tryKey(row, slot, key)
    if key ~= '' and chatMode == CHAT_MODE.ON and typesInChat(key) then
        showClash(row, slot, key, { type = 'chat' })
        return
    end
    if key ~= '' then
        local user = Keybind.findKeyUser(key, chatMode, { category = row.category, action = row.action })
        if user then
            showClash(row, slot, key, user)
            return
        end
    end
    setActionKey(row.category, row.action, slot, key)
    updateKeybinds()
end

local function stopCapture()
    if not capture then
        return
    end
    local row, slot = capture.row, capture.slot
    capture = nil
    -- the key press that follows this key down would reach the window (Esc closes it)
    addEvent(function()
        if not capture then
            page():ungrabKeyboard()
        end
    end)
    row:setOn(false)
    row.how:setText('')
    setKeyCap(row[slot], row.keys[slot])
end

-- the page keeps the keyboard while capturing, so closing Settings has to end it
function stopKeyCapture()
    stopCapture()
    clearClash()
end

function startCapture(row, slot)
    stopCapture()
    clearClash()
    capture = { row = row, slot = slot }
    row:setOn(true)
    row.how:setText(tr('Esc cancels, Backspace clears'))
    setKeyCap(row[slot], '', 'capture')
    page():grabKeyboard()
end

local function onCaptureKey(widget, keyCode, keyboardModifiers)
    if not capture then
        return false
    end
    local row, slot = capture.row, capture.slot
    if keyCode == KeyEscape then
        stopCapture()
        return true
    end
    if keyCode == KeyBackspace or keyCode == KeyDelete then
        stopCapture()
        tryKey(row, slot, '')
        return true
    end
    local key = determineKeyComboDesc(keyCode, row.alone and KeyboardNoModifier or keyboardModifiers)
    if key == '' or key == 'Shift' or key == 'Ctrl' or key == 'Alt' or key == 'Meta' then
        return true
    end
    stopCapture()
    tryKey(row, slot, key)
    return true
end

-- list

-- "Use move 10" after "Use move 9"
local function sortKey(text)
    return text:lower():gsub('%d+', function(digits) return string.format('%06d', tonumber(digits)) end)
end

local function addGroup(title, note)
    local group = g_ui.createWidget('KbGroup', page().rows)
    group.title:setText(title:upper())
    group.note:setText(note or '')
    group.isGroup = true
    return group
end

local function addKeybindRow(keybind, keys)
    local row = g_ui.createWidget('KbRow', page().rows)
    row.category, row.action, row.alone = keybind.category, keybind.action, keybind.alone
    row.keys = { primary = tostring(keys.primary or ''), secondary = tostring(keys.secondary or '') }
    row.name:setText(tr(keybind.action))
    row.searchText = string.format('%s %s %s %s', keybind.category, keybind.action, row.keys.primary,
        row.keys.secondary):lower()
    for _, slot in ipairs({ 'primary', 'secondary' }) do
        setKeyCap(row[slot], row.keys[slot])
        row[slot].onClick = function()
            startCapture(row, slot)
        end
    end
end

local function addHotkeyRow(id, hotkey)
    local row = g_ui.createWidget('KbRow', page().rows)
    local uid = hotkey.data.uid or string.format('%d-%d', chatMode, id)
    local name, how = '', ''
    if modules.game_hotkeys and modules.game_hotkeys.describeHotkey then
        name, how = modules.game_hotkeys.describeHotkey(hotkey)
    end
    row.keys = { primary = hotkey.primary or '', secondary = hotkey.secondary or '' }
    if hotkey.data.itemId then
        row.item:setItemId(hotkey.data.itemId)
        row.item:show()
        row.name:setMarginLeft(36)
    end
    row.name:setText(name)
    row.how:setText(how)
    row.searchText = string.format('%s %s %s %s', name, how, row.keys.primary, row.keys.secondary):lower()
    for _, slot in ipairs({ 'primary', 'secondary' }) do
        setKeyCap(row[slot], row.keys[slot])
        row[slot]:setTooltip(tr('Edit in Item hotkeys'))
        row[slot].onClick = function()
            modules.game_hotkeys.openEdit(uid)
        end
    end
end

local function addItemGroup(preset)
    addGroup(tr('Items'), tr('from Item hotkeys (Ctrl+K)'))
    local hotkeys = Keybind.hotkeys[chatMode] and Keybind.hotkeys[chatMode][preset] or {}
    for id, hotkey in ipairs(hotkeys) do
        addHotkeyRow(id, hotkey)
    end
    if #hotkeys == 0 then
        local row = g_ui.createWidget('KbRow', page().rows)
        row.name:setText(tr('No item hotkeys in this mode yet.'))
        row.name:setColor('#8fa3c8')
        row.primary:hide()
        row.secondary:hide()
        row.searchText = ''
    end
end

local function performSearch()
    if searchEvent then
        removeEvent(searchEvent)
        searchEvent = nil
    end
    local text = page().search:getText():trim():lower()
    local any = false
    local group, groupVisible
    for _, child in ipairs(page().rows:getChildren()) do
        if child.isGroup then
            if group then
                group:setVisible(groupVisible)
            end
            group, groupVisible = child, false
        elseif child.searchText then
            local visible = text == '' or child.searchText:find(text, 1, true) ~= nil
            child:setVisible(visible)
            groupVisible = groupVisible or visible
            any = any or visible
        end
    end
    if group then
        group:setVisible(groupVisible)
    end
    page().empty:setVisible(not any)
end

function searchActions()
    if searchEvent then
        removeEvent(searchEvent)
    end
    searchEvent = scheduleEvent(performSearch, 200)
end

function updateKeybinds()
    local panel = page()
    if not panel then
        return
    end
    local preset = currentPreset()
    if not preset then
        return
    end
    stopCapture()
    clashRow = nil
    panel.rows:destroyChildren()

    local groups = {}
    for _, keybind in pairs(Keybind.defaultKeybinds) do
        groups[keybind.category] = groups[keybind.category] or {}
        table.insert(groups[keybind.category], keybind)
    end
    local order = {}
    for _, category in ipairs(GROUP_ORDER) do
        if groups[category] or category == ITEMS then
            table.insert(order, category)
        end
    end
    local rest = {}
    for category in pairs(groups) do
        if not table.find(GROUP_ORDER, category) then
            table.insert(rest, category)
        end
    end
    table.sort(rest)
    for _, category in ipairs(rest) do
        table.insert(order, category)
    end

    for _, category in ipairs(order) do
        if category == ITEMS then
            addItemGroup(preset)
        elseif filter ~= 'items' then
            addGroup(tr(category))
            local keybinds = groups[category]
            table.sort(keybinds, function(a, b) return sortKey(a.action) < sortKey(b.action) end)
            for _, keybind in ipairs(keybinds) do
                addKeybindRow(keybind, Keybind.getKeybindKeys(keybind.category, keybind.action, chatMode, preset))
            end
        end
    end
    performSearch()
end

function setKeybindsFilter(value)
    filter = value
    local panel = page()
    panel.buttons.reset:setVisible(value == nil)
    panel.search:clearText()
    updateKeybinds()
end

function getChatMode()
    return chatMode
end

local function setChatMode(mode)
    chatMode = mode
    local panel = page()
    panel.presets.on:setChecked(mode == CHAT_MODE.ON)
    panel.presets.off:setChecked(mode == CHAT_MODE.OFF)
    updateKeybinds()
end

-- The keys of each chat mode are separate (the numpad walks in both), so the list opens on the
-- mode the player is in: clearing a key there is what stops it. toggle() refreshes the list after.
function selectCurrentChatMode()
    chatMode = Keybind.chatMode == CHAT_MODE.OFF and CHAT_MODE.OFF or CHAT_MODE.ON
    local panel = page()
    panel.presets.on:setChecked(chatMode == CHAT_MODE.ON)
    panel.presets.off:setChecked(chatMode == CHAT_MODE.OFF)
end

function resetActions()
    local preset = currentPreset()
    local box
    local function close()
        box:destroy()
    end
    box = displayGeneralBox(tr('Reset to defaults'),
        tr('Set every key of the preset %s back to the default? Item hotkeys stay as they are.', preset), {
            { text = tr('Reset'), callback = function()
                close()
                Keybind.resetKeybindsToDefault(preset, chatMode)
                updateKeybinds()
            end },
            { text = tr('Cancel'), callback = close }
        }, nil, close)
end

local function onHotkeysChange()
    if controller.ui:isVisible() and page():isVisible() and not capture then
        updateKeybinds()
    end
end

function init_binds()
    local panel = page()
    presetWindow = g_ui.displayUI("styles/controls/preset")
    presetWindow:hide()
    panel.presets.add.onClick = addNewPreset
    panel.presets.copy.onClick = copyPreset
    panel.presets.rename.onClick = renamePreset
    panel.presets.remove.onClick = removePreset
    panel.presets.on.onClick = function() setChatMode(CHAT_MODE.ON) end
    panel.presets.off.onClick = function() setChatMode(CHAT_MODE.OFF) end
    panel.presets.on:setChecked(true)
    panel.buttons.reset.onClick = resetActions
    panel.buttons.newHotkey.onClick = function()
        if modules.game_hotkeys and modules.game_hotkeys.openNew then
            modules.game_hotkeys.openNew()
        end
    end
    panel.search.onTextChange = searchActions
    panel.onKeyDown = onCaptureKey
    presetWindow.onEnter = okPresetWindow
    presetWindow.onEscape = cancelPresetWindow
    presetWindow.buttons.ok.onClick = okPresetWindow
    presetWindow.buttons.cancel.onClick = cancelPresetWindow
    connect(Keybind, { onHotkeysChange = onHotkeysChange })
end

function terminate_binds()
    disconnect(Keybind, { onHotkeysChange = onHotkeysChange })
    stopCapture()
    if presetWindow then
        presetWindow:destroy()
        presetWindow = nil
    end
    if searchEvent then
        removeEvent(searchEvent)
        searchEvent = nil
    end
end
