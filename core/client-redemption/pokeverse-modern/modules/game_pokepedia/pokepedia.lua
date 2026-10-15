-- The Pokepedia: one window with Map, Houses, Pokedex and Items tabs, and the tracker panel
-- (tracker.lua). It talks to the server over ExtendedIds.Pokepedia JSON (069-pokepedia.lua): every
-- request is { action = ... } and every answer a { type = ... } that Handlers[type] draws.
-- Waypoints, the route, the tracked Pokemon and the tracker's hidden and pinned lines are kept per
-- character in g_settings ('Pokepedia').
Pp = {}
Handlers = {}

local window, button, trackerButton
local helloEvent
local current = 'map'
local TABS = { 'map', 'houses', 'dex', 'items', 'wiki' }
local PAGES = {}

Pp.OK_COLOR, Pp.ERROR_COLOR = '#8fe08f', '#ff8a80'
Pp.IMAGES = '/modules/game_pokepedia/images/'

function Pp.send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Pokepedia, data)
    end
end

function Pp.window()
    return window
end

function Pp.formatMoney(amount)
    local text = tostring(math.floor(tonumber(amount) or 0))
    repeat
        local n
        text, n = text:gsub('^(%d+)(%d%d%d)', '%1,%2')
    until n == 0
    return '$' .. text
end

function Pp.formatPosition(pos)
    return string.format('%d, %d, %d', pos.x, pos.y, pos.z)
end

-- floor 7 is the ground; the map shows the others as levels up or down from it
function Pp.floorName(z)
    if z == 7 then
        return tr('Ground')
    elseif z < 7 then
        return tr('+%d', 7 - z)
    end
    return tr('-%d', z - 7)
end

function Pp.distance(a, b)
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

function Pp.status(text, ok)
    if not window then
        return
    end
    window.status:setText(text or '')
    window.status:setColor(ok == false and Pp.ERROR_COLOR or (ok and Pp.OK_COLOR or '#dce6ff'))
    window.status:setVisible(text ~= nil and text ~= '')
end

function Pp.message(text, ok)
    Pp.status(text, ok)
    if modules.game_textmessage then
        if ok == false then
            modules.game_textmessage.displayFailureMessage(text)
        else
            modules.game_textmessage.displayStatusMessage(text)
        end
    end
end

-- per character settings

local function settingsKey()
    local name = g_game.getCharacterName() or ''
    return (name:gsub('[^%w]', '_'))
end

function Pp.load(field, default)
    local node = g_settings.getNode('Pokepedia') or {}
    local mine = node[settingsKey()]
    if type(mine) ~= 'table' or mine[field] == nil then
        return default
    end
    return mine[field]
end

function Pp.save(field, value)
    local node = g_settings.getNode('Pokepedia') or {}
    local key = settingsKey()
    if type(node[key]) ~= 'table' then
        node[key] = {}
    end
    node[key][field] = value
    g_settings.setNode('Pokepedia', node)
    -- waypoints and routes shouldn't be lost when the client crashes
    g_settings.save()
end

-- an OTML list comes back as a table keyed 1..n, sometimes with string keys
function Pp.list(value)
    local list = {}
    if type(value) ~= 'table' then
        return list
    end
    local keys = {}
    for key in pairs(value) do
        keys[#keys + 1] = tonumber(key) or key
    end
    table.sort(keys, function(a, b)
        if type(a) == type(b) then
            return a < b
        end
        return type(a) == 'number'
    end)
    for _, key in ipairs(keys) do
        list[#list + 1] = value[key] or value[tostring(key)]
    end
    return list
end

-- the 0-1 fill of a TkTrack, sized once the layout has run
function Pp.setTrack(track, value, max, fill)
    track.fill:setImageSource('/modules/game_dailytasks/images/' .. (fill or 'fill_blue'))
    local function resize()
        local ratio = math.min(1, (value or 0) / math.max(1, max or 1))
        local width = math.floor(track:getWidth() * ratio)
        track.fill:setWidth(width)
        track.fill:setVisible(width >= 6)
    end
    track.onGeometryChange = resize
    resize()
end

function Pp.portrait(number)
    return '/images/staticPortraits/' .. number
end

-- A list of groups that open and close: groups = { { key, name, note, icon, item, entries } }.
-- addEntry(list, entry, group) makes an entry's row; expanded[key] keeps which groups are open, and
-- an open search opens them all. Hiding rows keeps the scroll position, so a group opens in place.
function Pp.fillTree(list, groups, expanded, addEntry, openAll)
    list:destroyChildren()
    local headers = {}
    for _, group in ipairs(groups) do
        local header = g_ui.createWidget('PpGroupRow', list)
        header.name:setText(group.name)
        header.note:setText(group.note or '')
        if group.item then
            header.item:setItemId(group.item)
            header.item:show()
        elseif group.icon then
            header.icon:setImageSource(group.icon)
            header.icon:show()
        end
        header.rows = {}
        for _, entry in ipairs(group.entries) do
            local row = addEntry(list, entry, group)
            row:setMarginLeft(14)
            header.rows[#header.rows + 1] = row
        end
        header.apply = function()
            local open = openAll or expanded[group.key] == true
            header.chevron:setImageSource(Pp.IMAGES .. (open and 'chevron_down' or 'chevron_right'))
            header:setOn(open)
            for _, row in ipairs(header.rows) do
                row:setVisible(open)
            end
        end
        header.open = function()
            expanded[group.key] = true
            header.apply()
        end
        header.onMouseRelease = function(widget, mousePos, mouseButton)
            if mouseButton == MouseLeftButton and widget:containsPoint(mousePos) and not openAll then
                expanded[group.key] = not expanded[group.key]
                header.apply()
            end
            return true
        end
        header.apply()
        headers[#headers + 1] = header
    end
    return headers
end

-- opens the group holding a row and scrolls to it
function Pp.revealRow(list, row)
    for _, header in ipairs(list:getChildren()) do
        if header.rows and table.find(header.rows, row) and not row:isVisible() then
            header.open()
        end
    end
    list:ensureChildVisible(row)
end

-- window

local function showTab(name)
    current = name
    for _, tab in ipairs(TABS) do
        window.tabs[tab]:setChecked(tab == name)
        window[tab .. 'Page']:setVisible(tab == name)
    end
    if PAGES[name] and PAGES[name].onShow then
        PAGES[name].onShow()
    end
end

function Pp.registerPage(name, page)
    PAGES[name] = page
end

function show(tab)
    if not window or not g_game.isOnline() then
        return
    end
    if not window:isVisible() then
        local root = rootWidget:getSize()
        window:setSize({ width = math.min(1120, root.width - 20), height = math.min(720, root.height - 20) })
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
            y = math.floor((root.height - window:getHeight()) / 2) })
        window:show()
        Pp.status(nil)
    end
    window:raise()
    window:focus()
    showTab(tab or current)
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
    if window and window:isVisible() then
        hide()
    else
        show()
    end
end

-- P and M are plain letters: they shouldn't fire while the trainer types in a text field
local function typing()
    local widget = rootWidget
    while widget:getFocusedChild() do
        widget = widget:getFocusedChild()
    end
    return widget:getClassName() == 'UITextEdit' and widget:isEnabled() and widget:isVisible()
end

local function onToggleKey()
    if not typing() then
        toggle()
    end
end

-- the M key (game_minimap)
function openMap()
    if typing() then
        return
    end
    if window and window:isVisible() and current == 'map' then
        hide()
        return
    end
    show('map')
end

function openTab(name)
    show(name)
end

function isVisible()
    return window ~= nil and window:isVisible()
end

-- for the screenshots in tests
function selectTab(name)
    if window and window.tabs[name] then
        showTab(name)
    end
end

-- messages

function Handlers.result(data)
    Pp.message(data.text, data.ok)
end

local offerBox

function Handlers.transferOffer(data)
    if offerBox then
        offerBox:destroy()
        offerBox = nil
    end
    local text = tr('%s offers you %s in %s (%d sqm, rent %s a week) for %s.\n\nTake it? The price is paid from your bank first, then your bag.',
        data.from or '?', data.name or '?', data.town or '?', data.size or 0, Pp.formatMoney(data.rent),
        Pp.formatMoney(data.price))
    local function answer(accept)
        if offerBox then
            offerBox:destroy()
            offerBox = nil
        end
        Pp.send({ action = 'answer', id = data.id, accept = accept })
    end
    offerBox = displayGeneralBox(tr('House transfer'), text, {
        { text = tr('Take the house'), callback = function() answer(true) end },
        { text = tr('Turn down'), callback = function() answer(false) end },
        anchor = AnchorHorizontalCenter
    }, function() answer(true) end, function() answer(false) end)
end

-- messages over 8 KB arrive as "#id:index:count:" fragments, and the server's output pool can
-- deliver them out of order
local fragments, fragmentIds = {}, {}

local function onPokepedia(protocol, opcode, buffer)
    if buffer:sub(1, 1) == '#' then
        local id, index, count, piece = buffer:match('^#(%d+):(%d+):(%d+):(.*)$')
        if not id then
            g_logger.warning('Pokepedia: invalid fragment')
            return
        end
        index, count = tonumber(index), tonumber(count)
        local entry = fragments[id]
        if not entry then
            entry = { count = count, got = 0, pieces = {} }
            fragments[id] = entry
            table.insert(fragmentIds, id)
            if #fragmentIds > 8 then
                fragments[table.remove(fragmentIds, 1)] = nil
            end
        end
        if not entry.pieces[index] then
            entry.pieces[index] = piece
            entry.got = entry.got + 1
        end
        if entry.got < entry.count then
            return
        end
        fragments[id] = nil
        table.removevalue(fragmentIds, id)
        buffer = table.concat(entry.pieces)
    end
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or not Handlers[data.type] then
        g_logger.warning('Pokepedia: invalid message')
        return
    end
    Handlers[data.type](data)
end

local function sayHello()
    removeEvent(helloEvent)
    helloEvent = scheduleEvent(function()
        helloEvent = nil
        if g_game.isOnline() then
            Pp.send({ action = 'hello' })
            for _, page in pairs(PAGES) do
                if page.onGameStart then
                    page.onGameStart()
                end
            end
            Tracker.onGameStart()
        end
    end, 1600)
end

local function onGameEnd()
    removeEvent(helloEvent)
    helloEvent = nil
    if offerBox then
        offerBox:destroy()
        offerBox = nil
    end
    for _, page in pairs(PAGES) do
        if page.onGameEnd then
            page.onGameEnd()
        end
    end
    Tracker.onGameEnd()
    hide()
end

function init()
    g_ui.importStyle('/modules/game_dailytasks/tasks')
    g_ui.importStyle('/modules/game_gts/gts')
    g_ui.importStyle('pokepedia')
    window = g_ui.createWidget('PokepediaWindow', rootWidget)
    window:hide()
    for _, name in ipairs(TABS) do
        window.tabs[name].onClick = function() showTab(name) end
    end

    MapTab.setup(window.mapPage)
    HousesTab.setup(window.housesPage)
    DexTab.setup(window.dexPage)
    ItemsTab.setup(window.itemsPage)
    WikiTab.setup(window.wikiPage)
    Tracker.setup()
    showTab('map')
    window:hide()

    button = modules.client_topmenu.addRightGameToggleButton('pokepediaButton', tr('Pokepedia (P)'),
        Pp.IMAGES .. 'button_pokepedia', toggle)
    trackerButton = modules.client_topmenu.addRightGameToggleButton('pokepediaTrackerButton', tr('Tracker'),
        Pp.IMAGES .. 'button_tracker', function() Tracker.toggle() end)
    Tracker.setButton(trackerButton)

    Keybind.new('Windows', 'Show/hide the Pokepedia', { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'P' }, '')
    Keybind.bind('Windows', 'Show/hide the Pokepedia', { { type = KEY_DOWN, callback = onToggleKey } })

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Pokepedia, onPokepedia)
    connect(g_game, { onGameStart = sayHello, onGameEnd = onGameEnd })
    Navigation.init()
    if g_game.isOnline() then
        sayHello()
    end
end

function terminate()
    Keybind.delete('Windows', 'Show/hide the Pokepedia')
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Pokepedia)
    disconnect(g_game, { onGameStart = sayHello, onGameEnd = onGameEnd })
    removeEvent(helloEvent)
    helloEvent = nil
    Navigation.terminate()
    Tracker.terminate()
    for _, page in pairs(PAGES) do
        if page.terminate then
            page.terminate()
        end
    end
    if offerBox then
        offerBox:destroy()
        offerBox = nil
    end
    for _, widget in ipairs({ button, trackerButton }) do
        if widget then
            widget:destroy()
        end
    end
    button, trackerButton = nil, nil
    window:destroy()
    window = nil
end
