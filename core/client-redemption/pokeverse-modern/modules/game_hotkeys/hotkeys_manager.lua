-- Item hotkeys: Poke Balls, potions and chat text on keys, stored as Keybind hotkeys (corelib/keybind.lua)
-- so the Settings key list shows them and one clash check covers every key. Replaces Redemption's
-- hotkeys manager, which kept its own key list and bound the F keys on top of the key bindings.
-- A hotkey lives in both chat modes (one Keybind hotkey each, sharing data.uid) unless its key is a
-- plain letter or digit, which would type into the chat; those only work with the chat off.

local IMAGES = '/modules/game_hotkeys/images/'
local TOGGLE_CATEGORY, TOGGLE_ACTION = 'Windows', 'Show/hide Item hotkeys'
local MIGRATED_SETTING = 'pokeverse-hotkeys-migrated'

-- the "when pressed" choices, in the order of the grid
local HOW = {
    { action = HOTKEY_ACTION.USE_POKEMON, icon = 'poke', title = 'On my Pokemon', desc = 'Potions, revives' },
    { action = HOTKEY_ACTION.USE_CROSSHAIR, icon = 'cross', title = 'With crosshair', desc = 'Click a target' },
    { action = HOTKEY_ACTION.USE_TARGET, icon = 'target', title = 'On my target', desc = 'Who you fight' },
    { action = HOTKEY_ACTION.USE_YOURSELF, icon = 'self', title = 'On myself', desc = 'Your trainer' },
    { action = HOTKEY_ACTION.USE, icon = 'hand', title = 'Use', desc = 'Open, eat, read' },
    { action = HOTKEY_ACTION.TEXT, icon = 'text', title = 'Say text', desc = 'Chat or command' },
}

local HOW_TEXT = {
    [HOTKEY_ACTION.USE_POKEMON] = 'on my Pokemon',
    [HOTKEY_ACTION.USE_CROSSHAIR] = 'with crosshair',
    [HOTKEY_ACTION.USE_TARGET] = 'on my target',
    [HOTKEY_ACTION.USE_YOURSELF] = 'on myself',
    [HOTKEY_ACTION.USE] = 'use',
    [HOTKEY_ACTION.EQUIP] = 'equip',
    [HOTKEY_ACTION.TEXT] = 'say text',
    [HOTKEY_ACTION.TEXT_AUTO] = 'say text, sends at once',
    [HOTKEY_ACTION.SPELL] = 'say text, sends at once',
}

local window
local hotkeysWindowButton
local mouseGrabber
local editing -- { uid, itemId, action, text, autoSend, key, isNew }
local capturing = false
local clash
local rebuilding = false -- the list is being rebuilt: row focus changes are not picks
local saving = false
local howButtons = {}

local hotkeyBlockingSources = {}
local nextSourceId = 1

local function chatModes()
    return { CHAT_MODE.ON, CHAT_MODE.OFF }
end

local function isTextAction(action)
    return action == HOTKEY_ACTION.TEXT or action == HOTKEY_ACTION.TEXT_AUTO or action == HOTKEY_ACTION.SPELL
end

-- letters, digits and the like type into the chat, so they only work with the chat off
local function modesForKey(key)
    if not key or key == '' then
        return chatModes()
    end
    local base = key:match('^Shift%+(.+)$') or key
    if base:len() == 1 or base == 'Space' then
        return { CHAT_MODE.OFF }
    end
    return chatModes()
end

-- Each ball type has four client ids in a row: empty, in use, holding a Pokemon, Pokemon fainted
-- (server data/lib/ps/config/balls.lua, 12157+ there). Only the empty one is a throwable item; the
-- others are the player's Pokemon, which the pokebar calls out.
local BALL_FIRST_ID = 11118
local BALL_TYPES = { 'poke', 'great', 'ultra', 'safari', 'blue', 'red', 'yellow', 'dark' }
local EMPTY_BALL_NAMES, POKEMON_BALLS = {}, {}
for index, ball in ipairs(BALL_TYPES) do
    local empty = BALL_FIRST_ID + (index - 1) * 4
    EMPTY_BALL_NAMES[empty] = ball .. ' ball'
    for id = empty + 1, empty + 3 do
        POKEMON_BALLS[id] = true
    end
end

local function rawItemName(itemId)
    if not itemId then
        return ''
    end
    return EMPTY_BALL_NAMES[itemId] or (getItemNameByClientId and getItemNameByClientId(itemId)) or ''
end

local function itemName(itemId)
    local name = rawItemName(itemId)
    if name == '' then
        return tr('Item %d', itemId or 0)
    end
    name = name:gsub('^pokemon ', '')
    return (name:gsub('(%a)([%w]*)', function(a, b) return a:upper() .. b end))
end

local function defaultAction(itemId)
    local name = rawItemName(itemId):lower()
    if name:find('ball') then
        return HOTKEY_ACTION.USE_CROSSHAIR
    end
    if name:find('potion') or name:find('revive') or name:find('candy') or name:find('berry') or name:find('elixir') then
        return HOTKEY_ACTION.USE_POKEMON
    end
    return HOTKEY_ACTION.USE
end

-- counts of what the player carries: open containers, plus stackable equipment such as
-- Poke Balls (the other PokeVerse slots hold trainer tools like Order and Pokedex)
local function carried()
    local counts, order = {}, {}
    local function add(item)
        if not item or POKEMON_BALLS[item:getId()] then
            return
        end
        local id = item:getId()
        if not counts[id] then
            counts[id] = 0
            table.insert(order, id)
        end
        counts[id] = counts[id] + math.max(1, item:getCount())
    end
    local player = g_game.getLocalPlayer()
    if player then
        for slot = InventorySlotFirst, InventorySlotLast do
            local item = player:getInventoryItem(slot)
            if item and item:isStackable() then
                add(item)
            end
        end
    end
    for _, container in pairs(g_game.getContainers()) do
        for _, item in ipairs(container:getItems()) do
            if not item:isContainer() then
                add(item)
            end
        end
    end
    return counts, order
end

-- the hotkeys of the current preset, both chat modes merged by uid
local function entries()
    local list, byUid = {}, {}
    local preset = Keybind.currentPreset
    for _, mode in ipairs(chatModes()) do
        for id, hotkey in ipairs(Keybind.hotkeys[mode][preset] or {}) do
            local uid = hotkey.data.uid or string.format('%d-%d', mode, id)
            local entry = byUid[uid]
            if not entry then
                entry = {
                    uid = uid,
                    action = hotkey.action,
                    itemId = hotkey.data.itemId,
                    text = hotkey.data.text or hotkey.data.words,
                    key = hotkey.primary ~= '' and hotkey.primary or hotkey.secondary,
                    ids = {}
                }
                byUid[uid] = entry
                table.insert(list, entry)
            end
            entry.ids[mode] = id
        end
    end
    return list
end

local function removeEntry(uid)
    for _, mode in ipairs(chatModes()) do
        local list = Keybind.hotkeys[mode][Keybind.currentPreset] or {}
        for id = #list, 1, -1 do
            local hotkey = list[id]
            local hotkeyUid = hotkey.data.uid or string.format('%d-%d', mode, id)
            if hotkeyUid == uid then
                Keybind.removeHotkey(id, mode)
            end
        end
    end
end

local function newUid()
    return string.format('%x%04x', os.time(), math.random(0, 0xffff))
end

-- who has the key in any chat mode the hotkey would use
local function findClash(key, uid)
    if not key or key == '' then
        return nil
    end
    for _, mode in ipairs(modesForKey(key)) do
        local user = Keybind.findKeyUser(key, mode, { uid = uid })
        if user then
            user.mode = mode
            return user
        end
    end
    return nil
end

local function userName(user)
    if user.type == 'reserved' then
        return tr('walking')
    elseif user.type == 'keybind' then
        return tr(user.action)
    end
    local hotkey = user.hotkey
    if isTextAction(hotkey.action) then
        return tr('the "%s" hotkey', hotkey.data.text or hotkey.data.words or '')
    end
    return tr('the %s hotkey', itemName(hotkey.data.itemId))
end

local function setKeyLabel(widget, key)
    widget:setText(key ~= '' and key or tr('none'))
end

-- left list

local function refreshList()
    if not window then
        return
    end
    local listWidget = window.left.list
    rebuilding = true
    listWidget:destroyChildren()
    local counts = carried()
    local all = entries()
    for _, entry in ipairs(all) do
        local row = g_ui.createWidget('HkRow', listWidget)
        row.uid = entry.uid
        if entry.key and entry.key ~= '' then
            for part in entry.key:gmatch('[^+]+') do
                local cap = g_ui.createWidget('HkKey', row.keys)
                cap:setText(part)
            end
        else
            local cap = g_ui.createWidget('HkKey', row.keys)
            cap:setImageSource(IMAGES .. 'key_empty')
            cap:setColor('#7f93bb')
            cap:setText('-')
        end
        if isTextAction(entry.action) then
            row.item:hide()
            row.textIcon:show()
            row.name:setText(string.format('"%s"', entry.text or ''))
        else
            row.item:setItemId(entry.itemId)
            row.name:setText(itemName(entry.itemId))
            row.count:setText(counts[entry.itemId] and tostring(counts[entry.itemId]) or '')
        end
        row.how:setText(tr(HOW_TEXT[entry.action] or ''))
        row.onFocusChange = function(widget, focused)
            if focused and not rebuilding then
                modules.game_hotkeys.edit(widget.uid)
            end
        end
    end
    listWidget:focusChild(nil)
    for _, row in ipairs(listWidget:getChildren()) do
        if editing and row.uid == editing.uid then
            row:focus()
        end
    end
    rebuilding = false
    window.left.empty:setVisible(#all == 0)
    window.left.preset:setText(tr('Preset: %s', Keybind.currentPreset or ''))
end

local function focusRow(uid)
    for _, row in ipairs(window.left.list:getChildren()) do
        if row.uid == uid then
            row:focus()
            window.left.list:ensureChildVisible(row)
            return
        end
    end
end

-- editor

local function refreshBag()
    local bag = window.right.bag
    bag:destroyChildren()
    local counts, order = carried()
    local shown = 0
    for _, id in ipairs(order) do
        if shown >= 10 then
            break
        end
        local slot = g_ui.createWidget('HkBagSlot', bag)
        slot:setItemId(id)
        slot:setItemCount(counts[id])
        slot:setTooltip(itemName(id))
        slot:setChecked(editing and editing.itemId == id)
        slot.onClick = function()
            modules.game_hotkeys.setItem(id)
        end
        shown = shown + 1
    end
    window.right.bagEmpty:setVisible(shown == 0)
end

local function refreshKey()
    local box = window.right.keyBox
    local key = editing and editing.key or ''
    clash = nil
    window.right.swap:hide()
    box:setOn(capturing)
    box.key:setOn(false)
    if capturing then
        box.key:setText('...')
        box.statusIcon:setImageSource('')
        box.status:setColor('#ffd75a')
        box.status:setText(tr('Press a key. Esc cancels, Backspace clears.'))
        return
    end
    setKeyLabel(box.key, key)
    if key == '' then
        box.statusIcon:setImageSource('')
        box.status:setColor('#8fa3c8')
        box.status:setText(tr('Click here, then press the key you want.'))
        return
    end
    clash = findClash(key, editing.uid)
    if clash then
        box.key:setOn(true)
        box.statusIcon:setImageSource(IMAGES .. 'icon_warn')
        box.status:setColor('#ffc2bb')
        box.status:setText(tr('%s is already used by %s.', key, userName(clash)))
        window.right.swap:setVisible(clash.type ~= 'reserved')
        return
    end
    box.statusIcon:setImageSource(IMAGES .. 'icon_check')
    box.status:setColor('#9be8b0')
    if #modesForKey(key) == 1 then
        box.status:setText(tr('Free. Works with the chat off (WASD), since letters type in the chat.'))
    else
        box.status:setText(tr('Free, with the chat on or off.'))
    end
end

local function refreshEditor()
    local right = window.right
    local textMode = editing and isTextAction(editing.action)
    local counts = carried()

    right.itemStep:setText(textMode and tr('1 - TEXT') or tr('1 - ITEM'))
    for _, name in ipairs({ 'slot', 'itemInfo', 'pick', 'clearItem', 'dragHint', 'bag', 'bagEmpty' }) do
        right[name]:setVisible(not textMode)
    end
    right.text:setVisible(textMode)
    right.autoSend:setVisible(textMode)
    right.itemName:setMarginLeft(textMode and 0 or 12)
    right.itemName:removeAnchor(AnchorLeft)
    if textMode then
        right.itemName:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        right.itemName:addAnchor(AnchorTop, 'itemStep', AnchorBottom)
        right.itemName:setText(tr('What to say'))
        right.howStep:removeAnchor(AnchorTop)
        right.howStep:addAnchor(AnchorTop, 'autoSend', AnchorBottom)
        right.text:setText(editing.text or '')
        right.autoSend:setChecked(editing.action ~= HOTKEY_ACTION.TEXT)
    else
        right.itemName:addAnchor(AnchorLeft, 'slot', AnchorRight)
        right.itemName:addAnchor(AnchorTop, 'slot', AnchorTop)
        right.howStep:removeAnchor(AnchorTop)
        right.howStep:addAnchor(AnchorTop, 'bag', AnchorBottom)
        local itemId = editing and editing.itemId
        right.slot:setChecked(itemId ~= nil)
        right.slot.item:setItemId(itemId or 0)
        right.slot.item:setVisible(itemId ~= nil)
        right.clearItem:setEnabled(itemId ~= nil)
        if itemId then
            right.itemName:setText(itemName(itemId))
            right.itemInfo:setText(counts[itemId] and tr('%d in your bag.', counts[itemId]) or tr('None in your open bags.'))
        else
            right.itemName:setText(tr('No item yet'))
            right.itemInfo:setText(tr('Pick a Poke Ball, a potion or any item you carry.'))
        end
        refreshBag()
    end

    for _, button in ipairs(howButtons) do
        local action = button.how.action
        local selected = editing and (editing.action == action or (action == HOTKEY_ACTION.TEXT and textMode))
        button:setChecked(selected or false)
        button:setEnabled(editing ~= nil and (action == HOTKEY_ACTION.TEXT or editing.itemId ~= nil or textMode))
    end

    refreshKey()
    window.footer.delete:setEnabled(editing ~= nil and not editing.isNew)
    window.footer.save:setEnabled(editing ~= nil)
end

local function stopCapture()
    if capturing then
        capturing = false
        window.right.keyBox:ungrabKeyboard()
    end
end

local function onCaptureKey(widget, keyCode, keyboardModifiers)
    if not capturing then
        return false
    end
    if keyCode == KeyEscape then
        stopCapture()
        refreshKey()
        return true
    end
    if keyCode == KeyBackspace or keyCode == KeyDelete then
        editing.key = ''
        stopCapture()
        refreshKey()
        return true
    end
    local key = determineKeyComboDesc(keyCode, keyboardModifiers)
    -- a modifier alone is not a key yet
    if key == '' or key == 'Shift' or key == 'Ctrl' or key == 'Alt' or key == 'Meta' then
        return true
    end
    editing.key = key
    stopCapture()
    refreshKey()
    return true
end

-- public: editor actions

function edit(uid)
    stopCapture()
    for _, entry in ipairs(entries()) do
        if entry.uid == uid then
            editing = {
                uid = entry.uid,
                itemId = entry.itemId,
                action = entry.action == HOTKEY_ACTION.SPELL and HOTKEY_ACTION.TEXT_AUTO or entry.action,
                text = entry.text,
                key = entry.key or '',
                originalKey = entry.key or ''
            }
            window.footer.message:setText('')
            refreshEditor()
            return
        end
    end
end

function newHotkey()
    stopCapture()
    editing = { uid = newUid(), key = '', originalKey = '', isNew = true }
    window.left.list:focusChild(nil)
    window.footer.message:setText(tr('Pick an item, choose what happens, then press a key.'))
    refreshEditor()
end

function setItem(itemId)
    if not editing then
        newHotkey()
    end
    if POKEMON_BALLS[itemId] then
        window.footer.message:setText(tr('That ball holds a Pokemon: call it with its key in Settings > Controls.'))
        return
    end
    local wasItem = editing.itemId
    editing.itemId = itemId
    if isTextAction(editing.action or 0) then
        editing.action = nil
    end
    if not editing.action or not wasItem then
        editing.action = defaultAction(itemId)
    end
    refreshEditor()
end

function clearItem()
    if editing then
        editing.itemId = nil
        refreshEditor()
    end
end

function setHow(action)
    if not editing then
        return
    end
    if action == HOTKEY_ACTION.TEXT then
        editing.action = window.right.autoSend:isChecked() and HOTKEY_ACTION.TEXT_AUTO or HOTKEY_ACTION.TEXT
        if not editing.text then
            editing.text = ''
        end
    else
        editing.action = action
    end
    refreshEditor()
end

function startCapture()
    if not editing then
        newHotkey()
    end
    capturing = true
    window.right.keyBox:grabKeyboard()
    refreshKey()
end

-- the other side gets this hotkey's old key (or none), and this hotkey takes the key
function swapKey()
    if not editing or not clash then
        return
    end
    local other = clash
    local key, oldKey = editing.key, editing.originalKey or ''
    for _, mode in ipairs(modesForKey(key)) do
        local user = Keybind.findKeyUser(key, mode, { uid = editing.uid })
        if user and user.type == 'keybind' then
            if user.slot == 'primary' then
                Keybind.setPrimaryActionKey(user.category, user.action, Keybind.currentPreset, oldKey, mode)
            else
                Keybind.setSecondaryActionKey(user.category, user.action, Keybind.currentPreset, oldKey, mode)
            end
        elseif user and user.type == 'hotkey' then
            local other = user.hotkey
            local primary = user.slot == 'primary' and oldKey or other.primary
            local secondary = user.slot == 'secondary' and oldKey or other.secondary
            Keybind.editHotkeyKeys(user.hotkeyId, primary, secondary, mode)
        end
    end
    window.footer.message:setText(tr('%s moved to %s. Save to keep this hotkey.', (userName(other):gsub('^%l', string.upper)),
        oldKey ~= '' and oldKey or tr('no key')))
    refreshKey()
end

function saveHotkey()
    if not editing then
        return
    end
    stopCapture()
    local textMode = isTextAction(editing.action or 0)
    if textMode then
        editing.text = window.right.text:getText()
        editing.action = window.right.autoSend:isChecked() and HOTKEY_ACTION.TEXT_AUTO or HOTKEY_ACTION.TEXT
        if editing.text == '' then
            window.footer.message:setText(tr('Type the text to say first.'))
            return
        end
    elseif not editing.itemId then
        window.footer.message:setText(tr('Pick an item first.'))
        return
    elseif not editing.action then
        window.footer.message:setText(tr('Choose what happens when you press the key.'))
        return
    end
    if editing.key ~= '' and findClash(editing.key, editing.uid) then
        window.footer.message:setText(tr('That key is taken. Swap it or press another key.'))
        return
    end

    local uid, action, key = editing.uid, editing.action, editing.key
    local data = { uid = uid }
    if textMode then
        data.text = editing.text
    else
        data.itemId = editing.itemId
    end
    local ids = {}
    for _, entry in ipairs(entries()) do
        if entry.uid == uid then
            ids = entry.ids
        end
    end
    local wanted = {}
    for _, mode in ipairs(modesForKey(key)) do
        wanted[mode] = true
    end

    -- existing hotkeys are edited in place so the list keeps its order
    saving = true
    for _, mode in ipairs(chatModes()) do
        local id = ids[mode]
        if wanted[mode] and id then
            Keybind.editHotkey(id, action, table.recursivecopy(data), mode)
            Keybind.editHotkeyKeys(id, key, '', mode)
        elseif wanted[mode] then
            Keybind.newHotkey(action, table.recursivecopy(data), key, '', mode)
        elseif id then
            Keybind.removeHotkey(id, mode)
        end
    end
    saving = false

    refreshList()
    edit(uid)
    focusRow(uid)
    window.footer.message:setText(tr('Saved.'))
end

function deleteHotkey()
    if not editing or editing.isNew then
        return
    end
    stopCapture()
    removeEntry(editing.uid)
    editing = nil
    refreshList()
    refreshEditor()
    window.footer.message:setText(tr('Deleted.'))
end

-- picking an item anywhere on screen, as Redemption's manager did
local function onPickRelease(self, mousePosition, mouseButton)
    local item
    if mouseButton == MouseLeftButton then
        local clicked = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
        if clicked then
            if clicked:getClassName() == 'UIGameMap' then
                local tile = clicked:getTile(mousePosition)
                local thing = tile and tile:getTopMoveThing()
                if thing and thing:isItem() then
                    item = thing
                end
            elseif clicked:getClassName() == 'UIItem' and not clicked:isVirtual() then
                item = clicked:getItem()
            end
        end
    end
    self:ungrabMouse()
    g_mouse.popCursor('target')
    window:show()
    if item then
        setItem(item:getId())
    end
    return true
end

function startPick()
    if not editing then
        newHotkey()
    end
    mouseGrabber:grabMouse()
    g_mouse.pushCursor('target')
    window:hide()
end

-- moving the old window's hotkeys over, once per character

local LEGACY_USE = {
    [0] = HOTKEY_ACTION.USE,
    [1] = HOTKEY_ACTION.USE_YOURSELF,
    [2] = HOTKEY_ACTION.USE_TARGET,
    [3] = HOTKEY_ACTION.USE_CROSSHAIR,
    [4] = HOTKEY_ACTION.USE_CROSSHAIR,
    [5] = HOTKEY_ACTION.USE_POKEMON,
}

local function legacyHotkeys()
    local node = g_settings.getNode('game_hotkeys')
    if type(node) ~= 'table' or table.empty(node) then
        return nil
    end
    local host = G.host and string.gsub(G.host, '^https?://', '') or nil
    if host and type(node[host]) == 'table' then
        node = node[host]
    end
    local char = g_game.getCharacterName()
    if type(node[char]) == 'table' then
        return node[char]
    end
    return nil
end

local function migrate()
    local char = g_game.getCharacterName()
    local done = g_settings.getList(MIGRATED_SETTING) or {}
    if table.find(done, char) then
        return
    end
    table.insert(done, char)
    g_settings.setList(MIGRATED_SETTING, done)

    local old = legacyHotkeys()
    if not old then
        return
    end
    local moved, skipped = 0, {}
    for key, setting in pairs(old) do
        key = tostring(key)
        local itemId = tonumber(setting.itemId)
        local text = setting.value and tostring(setting.value) or ''
        local action, data
        if itemId then
            action = LEGACY_USE[tonumber(setting.useType) or 0] or HOTKEY_ACTION.USE
            data = { itemId = itemId }
        elseif text ~= '' then
            local auto = setting.autoSend == true or setting.autoSend == 'true'
            action = auto and HOTKEY_ACTION.TEXT_AUTO or HOTKEY_ACTION.TEXT
            data = { text = text }
        end
        if action then
            local user = findClash(key, nil)
            if user then
                table.insert(skipped, tr('%s (used by %s)', key, userName(user)))
            else
                data.uid = newUid() .. moved
                for _, mode in ipairs(modesForKey(key)) do
                    Keybind.newHotkey(action, table.recursivecopy(data), key, '', mode)
                end
                moved = moved + 1
            end
        end
    end
    if moved > 0 or #skipped > 0 then
        local text = tr('Your old hotkeys moved to Item hotkeys (Ctrl+K): %d moved.', moved)
        if #skipped > 0 then
            text = text .. ' ' .. tr('Not moved because the key is taken: %s.', table.concat(skipped, ', '))
        end
        modules.game_textmessage.displayGameMessage(text)
    end
end

-- window

local function createWindow()
    if window then
        return
    end
    g_ui.importStyle('hotkeys_manager')
    window = g_ui.createWidget('HkWindow', rootWidget)
    window:hide()
    local toggleKeys = Keybind.getKeybindKeys(TOGGLE_CATEGORY, TOGGLE_ACTION)
    window.toggleKey:setText(toggleKeys and toggleKeys.primary or '')
    for _, how in ipairs(HOW) do
        local button = g_ui.createWidget('HkAction', window.right.how)
        button.how = how
        button:setIcon(IMAGES .. 'act_' .. how.icon)
        button.title:setText(tr(how.title))
        button.desc:setText(tr(how.desc))
        button.onClick = function()
            setHow(how.action)
        end
        table.insert(howButtons, button)
    end
    window.right.autoSend.onCheckChange = function(widget, checked)
        if editing and isTextAction(editing.action or 0) then
            editing.action = checked and HOTKEY_ACTION.TEXT_AUTO or HOTKEY_ACTION.TEXT
        end
    end
    window.right.text.onTextChange = function(widget, text)
        if editing then
            editing.text = text
        end
    end
    window.right.keyBox.onKeyDown = onCaptureKey
    window.right.slot.onDrop = function(widget, dragged)
        local item = dragged and dragged.currentDragThing
        if item and item.isItem and item:isItem() then
            setItem(item:getId())
            return true
        end
        return false
    end
    mouseGrabber = g_ui.createWidget('UIWidget')
    mouseGrabber:setVisible(false)
    mouseGrabber:setFocusable(false)
    mouseGrabber.onMouseRelease = onPickRelease
end

local function layoutWindow()
    if window and window:isVisible() then
        window:setPosition({
            x = math.max(0, math.floor((rootWidget:getWidth() - window:getWidth()) / 2)),
            y = math.max(0, math.floor((rootWidget:getHeight() - window:getHeight()) / 2))
        })
    end
end

function show()
    if not g_game.isOnline() then
        return
    end
    createWindow()
    window:show()
    window:raise()
    window:focus()
    refreshList()
    if not editing then
        local first = window.left.list:getFirstChild()
        if first then
            first:focus()
            edit(first.uid)
        else
            newHotkey()
        end
    else
        refreshEditor()
    end
    if hotkeysWindowButton then
        hotkeysWindowButton:setOn(true)
    end
end

function hide()
    if window then
        stopCapture()
        window:hide()
    end
    if hotkeysWindowButton then
        hotkeysWindowButton:setOn(false)
    end
end

function toggle()
    if window and window:isVisible() then
        hide()
    else
        show()
    end
end

local function onHotkeysChange()
    if saving or not window or not window:isVisible() then
        return
    end
    refreshList()
    if editing and not capturing then
        refreshKey()
    end
end

local function online()
    migrate()
end

local function offline()
    hide()
    editing = nil
end

function init()
    Keybind.new(TOGGLE_CATEGORY, TOGGLE_ACTION, 'Ctrl+K', '')
    Keybind.bind(TOGGLE_CATEGORY, TOGGLE_ACTION, { { type = KEY_DOWN, callback = toggle } })
    hotkeysWindowButton = modules.client_topmenu.addRightGameToggleButton('hotkeysWindowButton',
        tr('Item hotkeys') .. ' (Ctrl+K)', '/images/options/hotkeys', toggle)
    connect(g_game, { onGameStart = online, onGameEnd = offline })
    connect(Keybind, { onHotkeysChange = onHotkeysChange, onBind = onHotkeysChange })
    connect(rootWidget, { onGeometryChange = layoutWindow })
    if g_game.isOnline() then
        online()
    end
end

function terminate()
    disconnect(g_game, { onGameStart = online, onGameEnd = offline })
    disconnect(Keybind, { onHotkeysChange = onHotkeysChange, onBind = onHotkeysChange })
    disconnect(rootWidget, { onGeometryChange = layoutWindow })
    Keybind.delete(TOGGLE_CATEGORY, TOGGLE_ACTION)
    stopCapture()
    if window then
        window:destroy()
        window = nil
    end
    if mouseGrabber then
        mouseGrabber:destroy()
        mouseGrabber = nil
    end
    if hotkeysWindowButton then
        hotkeysWindowButton:destroy()
        hotkeysWindowButton = nil
    end
    howButtons = {}
end

-- used by the Settings key list (client_options): a Keybind hotkey's name and how it is used
function describeHotkey(hotkey)
    if isTextAction(hotkey.action) then
        return string.format('"%s"', hotkey.data.text or hotkey.data.words or ''), tr(HOW_TEXT[hotkey.action] or '')
    end
    return itemName(hotkey.data.itemId), tr(HOW_TEXT[hotkey.action] or '')
end

function openNew()
    show()
    newHotkey()
end

function openEdit(uid)
    show()
    focusRow(uid)
    edit(uid)
end

-- other modules pause hotkeys while a dialog takes the keyboard (game_interface, game_console)

function enableHotkeys(sourceId)
    if sourceId then
        hotkeyBlockingSources[sourceId] = nil
    end
end

function disableHotkeys(sourceIdentifier)
    local sourceId = sourceIdentifier or ('auto_' .. nextSourceId)
    nextSourceId = nextSourceId + 1
    hotkeyBlockingSources[sourceId] = true
    return sourceId
end

function createHotkeyBlock(sourceIdentifier)
    local fullId = (sourceIdentifier or 'auto') .. '_' .. nextSourceId
    local blockId = disableHotkeys(fullId)
    return {
        release = function()
            enableHotkeys(blockId)
        end,
        getId = function()
            return fullId
        end
    }
end

function areHotkeysDisabled()
    return next(hotkeyBlockingSources) ~= nil
end

function clearAllHotkeyBlocks()
    hotkeyBlockingSources = {}
end

function getHotkeyBlockingInfo()
    local sources = {}
    for sourceId in pairs(hotkeyBlockingSources) do
        table.insert(sources, sourceId)
    end
    table.sort(sources)
    return #sources, sources
end

-- game_actionbar (hidden in PokeVerse) still asks these

function canPerformKeyCombo(keyCombo)
    if areHotkeysDisabled() then
        return false
    end
    if not modules.game_console.isChatEnabled() then
        return true
    end
    return string.match(keyCombo, 'Ctrl%+') or string.match(keyCombo, 'Alt%+') or string.match(keyCombo, 'F%d+')
end

function toggleChaseMode()
    local nextMode = g_game.getChaseMode() == ChaseOpponent and DontChase or ChaseOpponent
    g_game.setChaseMode(nextMode)
end

function isHotkeyUsedByManager(keyCombo)
    return false
end

function removeHotkeyByCombo(keyCombo)
    return false
end
