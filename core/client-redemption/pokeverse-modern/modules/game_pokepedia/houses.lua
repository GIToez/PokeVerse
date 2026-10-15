-- The Houses tab: every house with search and filters, and the picked house's details: its tiles on
-- a small map, buying from anywhere, leaving, the guest and sub-owner lists and transfers. The
-- server checks every rule (069-pokepedia.lua); the buttons only show what it allows.
HousesTab = {}

local page
local houses = {} -- { id, name, town, size, beds, price, owner, guild }
local incoming
local mine = 0
local selectedId, detail
local searchEvent
local tileWidgets = {}
local loadedAt = 0
local confirmBox
local expandedTowns = {}

local SIZES = {
    { name = 'Any size' },
    { name = 'Small (up to 40)', max = 40 },
    { name = 'Medium (41-100)', min = 41, max = 100 },
    { name = 'Large (over 100)', min = 101 },
}
local STATES = { { id = 'all', name = 'All' }, { id = 'free', name = 'For sale' }, { id = 'rented', name = 'Rented' } }

local function confirm(title, text, yes)
    if confirmBox then
        confirmBox:destroy()
    end
    local function close()
        if confirmBox then
            confirmBox:destroy()
            confirmBox = nil
        end
    end
    confirmBox = displayGeneralBox(title, text, {
        { text = tr('Yes'), callback = function() close(); yes() end },
        { text = tr('No'), callback = close },
        anchor = AnchorHorizontalCenter
    }, function() close(); yes() end, close)
end

local function matches(house)
    local side = page.side
    local filter = side.search:getText():lower()
    if filter ~= '' and not house.name:lower():find(filter, 1, true) and not house.owner:lower():find(filter, 1, true) then
        return false
    end
    local town = side.town:getCurrentOption()
    if town and town.data ~= '' and house.town ~= town.data then
        return false
    end
    local state = side.state:getCurrentOption()
    if state and state.data == 'free' and house.owner ~= '' then
        return false
    elseif state and state.data == 'rented' and house.owner == '' then
        return false
    end
    local size = SIZES[(side.size:getCurrentOption() or {}).data or 1] or SIZES[1]
    if (size.min and house.size < size.min) or (size.max and house.size > size.max) then
        return false
    end
    if side.guild:isChecked() and not house.guild then
        return false
    end
    return true
end

local function addHouseRow(list, house)
    local row = g_ui.createWidget('PpHouseRow', list)
    row.house = house
    local name = house.name
    if house.id == mine then
        name = tr('%s (yours)', name)
        row.name:setColor('#ffd75a')
    end
    row.name:setText(name)
    row.size:setText(tr('%d sqm', house.size))
    if house.owner == '' then
        row.state:setText(Pp.formatMoney(house.price))
        row.state:setColor('#8fe08f')
    else
        row.state:setText(house.owner)
        row.state:setColor('#96aacd')
    end
    row:setTooltip(tr('%s, %s\n%d sqm, %d beds%s', house.name, house.town, house.size, house.beds,
        house.guild and ('\n' .. tr('Guild hall')) or ''))
    return row
end

local function drawList()
    local side = page.side
    local list = side.list
    local groups, byTown, count = {}, {}, 0
    for _, house in ipairs(houses) do
        if matches(house) then
            local town = house.town ~= '' and house.town or tr('Elsewhere')
            local group = byTown[town]
            if not group then
                group = { key = town, name = town, icon = Pp.IMAGES .. 'icon_house', entries = {}, free = 0 }
                byTown[town] = group
                groups[#groups + 1] = group
            end
            group.entries[#group.entries + 1] = house
            if house.owner == '' then
                group.free = group.free + 1
            end
            count = count + 1
        end
    end
    table.sort(groups, function(a, b) return a.name < b.name end)
    for _, group in ipairs(groups) do
        table.sort(group.entries, function(a, b) return a.sortName < b.sortName end)
        group.note = group.free > 0 and tr('%d of %d for sale', group.free, #group.entries) or tr('%d houses', #group.entries)
    end
    -- a search or a single town shows every match without opening groups by hand
    local openAll = side.search:getText() ~= '' or #groups == 1
    local focus
    Pp.fillTree(list, groups, expandedTowns, function(parent, house)
        local row = addHouseRow(parent, house)
        if house.id == selectedId then
            focus = row
        end
        return row
    end, openAll)
    if count == 0 then
        local hint = g_ui.createWidget('TkMuted', list)
        hint:setText(#houses == 0 and tr('Loading the houses...') or tr('No house matches.'))
        hint:setMarginLeft(6)
        hint:setMarginTop(6)
    end
    side.count:setText(tr('%d houses', count))
    if focus then
        list:focusChild(focus, KeyboardFocusReason)
        Pp.revealRow(list, focus)
    end
end

local function fillTowns()
    local combo = page.side.town
    local chosen = combo:getCurrentOption() and combo:getCurrentOption().data or ''
    local towns, seen = {}, {}
    for _, house in ipairs(houses) do
        if house.town ~= '' and not seen[house.town] then
            seen[house.town] = true
            towns[#towns + 1] = house.town
        end
    end
    table.sort(towns)
    combo.onOptionChange = nil
    combo:clearOptions()
    combo:addOption(tr('All towns'), '')
    for _, town in ipairs(towns) do
        combo:addOption(town, town)
    end
    combo:setCurrentOptionByData(chosen, true)
    combo.onOptionChange = drawList
end

function Handlers.houses(data)
    if data.part == 1 or not incoming then
        incoming = {}
    end
    for _, row in ipairs(data.list or {}) do
        incoming[#incoming + 1] = { id = row[1], name = tostring(row[2]), town = tostring(row[3]), size = row[4] or 0,
            beds = row[5] or 0, price = row[6] or 0, owner = tostring(row[7] or ''), guild = row[8] == 1 }
        local house = incoming[#incoming]
        -- numbers padded so House #2 sorts before House #10
        house.sortName = house.name:lower():gsub('%d+', function(n) return ('%08d'):format(tonumber(n)) end)
    end
    if data.part >= data.parts then
        houses, incoming = incoming, nil
        mine = data.mine or 0
        loadedAt = g_clock.millis()
        fillTowns()
        drawList()
    end
end

-- details

local function clearTiles()
    for _, widget in ipairs(tileWidgets) do
        widget:destroy()
    end
    tileWidgets = {}
end

local function addLine(label, value, color)
    local line = g_ui.createWidget('PpLine', page.details.content.info)
    line.label:setText(label)
    line.value:setText(value)
    if color then
        line.value:setColor(color)
    end
end

-- the pictures rendered from the map (scripts/mapper/render_pokepedia.py); without them the minimap
local PICTURES = '/images/pokepedia/houses/'
local pictures
local shown = { zoom = 1, x = 0, y = 0 } -- the picture on screen: house, floor, zoom and offset

local function picturesIndex()
    if pictures == nil then
        pictures = false
        local path = PICTURES .. 'index.json'
        if g_resources.fileExists(path) then
            local ok, index = pcall(json.decode, g_resources.readFileContents(path))
            if ok and type(index) == 'table' then
                pictures = index
            else
                g_logger.warning('Pokepedia: invalid house picture index')
            end
        end
    end
    return pictures or nil
end

local function floorName(z)
    if z == 7 then
        return tr('Ground')
    elseif z < 7 then
        return tr('Floor %d', 7 - z)
    end
    return tr('Cellar %d', z - 7)
end

local function placePicture()
    local view = page.details.content.preview.view
    local picture = view.picture
    local box = shown.box
    local ppt = box[5] / box[3] * shown.zoom
    local width, height = math.floor(box[5] * shown.zoom), math.floor(box[6] * shown.zoom)
    local viewWidth, viewHeight = view:getWidth(), view:getHeight()
    -- a picture smaller than the view stays centered; a bigger one can be dragged up to its edges
    if width <= viewWidth then
        shown.x = math.floor((viewWidth - width) / 2)
    else
        shown.x = math.max(viewWidth - width, math.min(0, shown.x))
    end
    if height <= viewHeight then
        shown.y = math.floor((viewHeight - height) / 2)
    else
        shown.y = math.max(viewHeight - height, math.min(0, shown.y))
    end
    picture:setSize({ width = width, height = height })
    picture:setMarginLeft(shown.x)
    picture:setMarginTop(shown.y)
    local size = math.max(1, math.floor(ppt))
    for _, widget in ipairs(tileWidgets) do
        local spot = widget.spot
        if widget.houseTile then
            widget:setSize({ width = size, height = size })
            widget:setMarginLeft(math.floor((spot.x - box[1]) * ppt))
            widget:setMarginTop(math.floor((spot.y - box[2]) * ppt))
        else
            widget:setMarginLeft(math.floor((spot.x - box[1] + 0.5) * ppt - widget:getWidth() / 2))
            widget:setMarginTop(math.floor((spot.y - box[2] + 0.5) * ppt - widget:getHeight() / 2))
        end
    end
end

local function fitZoom(box)
    local view = page.details.content.preview.view
    return math.min(1, view:getWidth() / box[5], view:getHeight() / box[6])
end

local function showFloor(data, z)
    local preview = page.details.content.preview
    local box = picturesIndex()[tostring(data.id)][tostring(z)]
    clearTiles()
    shown.id, shown.z, shown.box = data.id, z, box
    shown.zoom = fitZoom(box)
    shown.x, shown.y = 0, 0
    local picture = preview.view.picture
    picture:setImageSource(PICTURES .. data.id .. '_' .. z)
    local entry = data.entry
    local count = 0
    for _, tile in ipairs(data.tiles or {}) do
        if tile[3] == z and count < 600 then
            local widget = g_ui.createWidget('PpHousePictureTile', picture)
            widget.houseTile = true
            widget.spot = { x = entry.x + tile[1], y = entry.y + tile[2] }
            widget:addAnchor(AnchorTop, 'parent', AnchorTop)
            widget:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            tileWidgets[#tileWidgets + 1] = widget
            count = count + 1
        end
    end
    if entry.z == z then
        local door = g_ui.createWidget('PpMapMark', picture)
        door:setImageSource(Pp.IMAGES .. 'mark_stop')
        door:setPhantom(true)
        door.spot = { x = entry.x, y = entry.y }
        door:addAnchor(AnchorTop, 'parent', AnchorTop)
        door:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        tileWidgets[#tileWidgets + 1] = door
    end
    for _, button in ipairs(preview.floors:getChildren()) do
        button:setChecked(button.z == z)
    end
    placePicture()
end

local function drawPicture(data, floors)
    local preview = page.details.content.preview
    preview.minimap:hide()
    preview.view:show()
    preview.floors:destroyChildren()
    preview.floors:setHeight(0)
    local list = {}
    for z in pairs(floors) do
        list[#list + 1] = tonumber(z)
    end
    -- top floor first, the way the buttons read left to right
    table.sort(list, function(a, b) return a > b end)
    if #list > 1 then
        preview.floors:setHeight(25)
        for _, z in ipairs(list) do
            local button = g_ui.createWidget('PpFloorButton', preview.floors)
            button:setText(floorName(z))
            button.z = z
            button.onClick = function()
                if detail then
                    showFloor(detail, z)
                end
            end
        end
    end
    showFloor(data, floors[tostring(data.entry.z)] and data.entry.z or list[1])
end

local function drawPreview(data)
    local preview = page.details.content.preview
    local index = picturesIndex()
    if index and index[tostring(data.id)] then
        drawPicture(data, index[tostring(data.id)])
        return
    end
    preview.view:hide()
    preview.floors:destroyChildren()
    preview.floors:setHeight(0)
    preview.minimap:show()
    preview = preview.minimap
    clearTiles()
    local entry = data.entry
    preview:setCameraPosition({ x = entry.x, y = entry.y, z = entry.z })
    local count = 0
    local size = math.max(1, math.floor(preview:getScale()))
    for _, tile in ipairs(data.tiles or {}) do
        if tile[3] == entry.z and count < 600 then
            local widget = g_ui.createWidget('PpHouseTile', preview)
            widget.houseTile = true
            widget:setSize({ width = size, height = size })
            preview:centerInPosition(widget, { x = entry.x + tile[1], y = entry.y + tile[2], z = tile[3] })
            tileWidgets[#tileWidgets + 1] = widget
            count = count + 1
        end
    end
    local door = g_ui.createWidget('PpMapMark', preview)
    door:setImageSource(Pp.IMAGES .. 'mark_stop')
    door:setPhantom(true)
    door:setTooltip(tr('Entrance'))
    preview:centerInPosition(door, { x = entry.x, y = entry.y, z = entry.z })
    tileWidgets[#tileWidgets + 1] = door
end

local function drawDetail(data)
    detail = data
    local details = page.details
    details.empty:hide()
    local content = details.content
    content:show()
    content.name:setText(data.name)
    content.town:setText(data.guild and tr('Guild hall in %s', data.town) or data.town)
    content.info:destroyChildren()
    addLine(tr('Size'), tr('%d sqm', data.size))
    addLine(tr('Beds'), tostring(data.beds))
    addLine(tr('Price'), Pp.formatMoney(data.price), '#ffd75a')
    addLine(tr('Rent'), tr('%s a week', Pp.formatMoney(data.rent)))
    if data.owner ~= '' then
        addLine(tr('Owner'), data.owner, data.mine and '#ffd75a' or nil)
        if (data.paidUntil or 0) > 0 then
            addLine(tr('Paid until'), os.date('%d %b %Y', data.paidUntil))
        end
    else
        addLine(tr('Owner'), tr('Nobody, it is for sale'), '#8fe08f')
    end
    drawPreview(data)

    local buttons = content.buttons
    local free = data.owner == ''
    buttons.buy:setVisible(free)
    buttons.buy:setEnabled(data.canBuy == true)
    buttons.buy:setText(tr('Buy'))
    buttons.buy:setTooltip(data.canBuy and tr('Buy it for %s', Pp.formatMoney(data.price)) or data.reason)
    buttons.leave:setVisible(data.mine == true)
    if data.mine then
        buttons.leave:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    else
        buttons.leave:addAnchor(AnchorLeft, 'buy', AnchorRight)
    end

    local reason = content.reason
    if free and not data.canBuy then
        reason:setText(data.reason ~= '' and data.reason or tr('You can\'t buy this house.'))
        reason:setColor(Pp.ERROR_COLOR)
    elseif free then
        reason:setText(tr('First come, first served: you can buy it from anywhere. You have %s.', Pp.formatMoney(data.funds)))
        reason:setColor('#dce6ff')
    elseif data.mine then
        reason:setText(tr('Your house. The rent is paid from your bank every week.'))
        reason:setColor('#dce6ff')
    else
        reason:setText(tr('%s lives here.', data.owner))
        reason:setColor('#96aacd')
    end

    local access = content.access
    access:setVisible(data.editGuests == true)
    if data.editGuests then
        access.guests:setText(tostring(data.guests or ''))
        local subowners = data.editSubowners == true
        access.subownersTitle:setVisible(subowners)
        access.subowners:setVisible(subowners)
        access.saveSubowners:setVisible(subowners)
        access.subowners:setText(tostring(data.subowners or ''))
    end

    local transfer = content.transfer
    local canTransfer = data.mine == true and not data.guild
    transfer:setVisible(canTransfer)
    if canTransfer then
        transfer:addAnchor(AnchorTop, data.editGuests and 'access' or 'reason', AnchorBottom)
        local pending = data.transfer and data.transfer ~= false
        transfer.buyer:setVisible(not pending)
        transfer.price:setVisible(not pending)
        transfer.offer:setVisible(not pending)
        transfer.pending:setVisible(pending)
        transfer.cancel:setVisible(pending)
        if pending then
            transfer.pending:setText(tr('Offered to %s for %s. Waiting for an answer.', data.transfer.name,
                Pp.formatMoney(data.transfer.price)))
        end
    end

    for _, house in ipairs(houses) do
        if house.id == data.id and house.owner ~= data.owner then
            house.owner = data.owner
            if data.mine then
                mine = data.id
            elseif mine == data.id then
                mine = 0
            end
            drawList()
            break
        end
    end
end

function Handlers.house(data)
    if data.id == selectedId then
        drawDetail(data)
    end
end

local function request(id)
    selectedId = id
    Pp.send({ action = 'house', id = id })
end

function HousesTab.setup(widget)
    page = widget
    local side = page.side
    side.search.onTextChange = function()
        removeEvent(searchEvent)
        searchEvent = scheduleEvent(drawList, 150)
    end
    for _, state in ipairs(STATES) do
        side.state:addOption(tr(state.name), state.id)
    end
    for index, size in ipairs(SIZES) do
        side.size:addOption(tr(size.name), index)
    end
    side.town:addOption(tr('All towns'), '')
    side.state.onOptionChange = drawList
    side.size.onOptionChange = drawList
    side.town.onOptionChange = drawList
    side.guild.onCheckChange = drawList
    side.list.onChildFocusChange = function(list, focused)
        if focused and focused.house and focused.house.id ~= (detail and detail.id) then
            request(focused.house.id)
        end
    end

    local content = page.details.content
    local preview = content.preview.minimap
    preview.autowalk = false
    preview.onMouseRelease = function() return true end
    preview.onMouseWheel = function(self, mousePos, direction)
        if direction == MouseWheelUp then
            self:zoomIn()
        else
            self:zoomOut()
        end
        local size = math.max(1, math.floor(self:getScale()))
        for _, widget in ipairs(tileWidgets) do
            if widget.houseTile then
                widget:setSize({ width = size, height = size })
            end
        end
        return true
    end

    local view = content.preview.view
    view.onMouseWheel = function(self, mousePos, direction)
        if not shown.box then
            return true
        end
        local fit = fitZoom(shown.box)
        local zoom = direction == MouseWheelUp and shown.zoom * 1.25 or shown.zoom / 1.25
        zoom = math.max(fit, math.min(math.max(fit, 3), zoom))
        -- keep the spot under the cursor in place
        local pos = self:getPosition()
        local cx, cy = mousePos.x - pos.x, mousePos.y - pos.y
        shown.x = math.floor(cx - (cx - shown.x) * zoom / shown.zoom)
        shown.y = math.floor(cy - (cy - shown.y) * zoom / shown.zoom)
        shown.zoom = zoom
        placePicture()
        return true
    end
    view.onMousePress = function(self, mousePos, button)
        if button == MouseLeftButton then
            self.dragFrom = { x = mousePos.x - shown.x, y = mousePos.y - shown.y }
        end
        return true
    end
    view.onMouseMove = function(self, mousePos)
        if self.dragFrom and shown.box then
            shown.x, shown.y = mousePos.x - self.dragFrom.x, mousePos.y - self.dragFrom.y
            placePicture()
        end
    end
    view.onMouseRelease = function(self)
        self.dragFrom = nil
        return true
    end
    view.onGeometryChange = function()
        if shown.box then
            placePicture()
        end
    end

    local buttons = content.buttons
    buttons.buy.onClick = function()
        if not detail then
            return
        end
        local data = detail
        confirm(tr('Buy a house'), tr('Buy %s in %s for %s?\nThe rent of %s a week is paid from your bank.', data.name,
            data.town, Pp.formatMoney(data.price), Pp.formatMoney(data.rent)), function()
            Pp.send({ action = 'buy', id = data.id })
        end)
    end
    buttons.leave.onClick = function()
        if not detail then
            return
        end
        local data = detail
        confirm(tr('Leave your house'), tr('Leave %s? You get no money back; what is inside goes to your depot.', data.name), function()
            Pp.send({ action = 'leave', id = data.id })
        end)
    end
    buttons.show.onClick = function()
        if detail then
            MapTab.showPosition(detail.entry, detail.name)
        end
    end
    buttons.walk.onClick = function()
        if detail then
            Navigation.goTo(detail.entry, detail.name)
        end
    end

    local access = content.access
    access.saveGuests.onClick = function()
        if detail then
            Pp.send({ action = 'access', id = detail.id, list = 'guests', text = access.guests:getText() })
        end
    end
    access.saveSubowners.onClick = function()
        if detail then
            Pp.send({ action = 'access', id = detail.id, list = 'subowners', text = access.subowners:getText() })
        end
    end
    access.guests:setTooltip(tr('One name per line'))
    access.subowners:setTooltip(tr('One name per line. Sub-owners can change the guests.'))

    local transfer = content.transfer
    transfer.offer.onClick = function()
        if not detail then
            return
        end
        local name = transfer.buyer:getText():gsub('^%s+', ''):gsub('%s+$', '')
        local price = tonumber((transfer.price:getText():gsub('[^%d]', '')))
        if name == '' or not price then
            Pp.status(tr('Enter the trainer\'s name and a price (0 to give it away).'), false)
            return
        end
        local data = detail
        confirm(tr('Transfer your house'), tr('Offer %s to %s for %s?\nThe house is theirs as soon as they accept.', data.name,
            name, Pp.formatMoney(price)), function()
            Pp.send({ action = 'transfer', id = data.id, name = name, price = price })
        end)
    end
    transfer.cancel.onClick = function()
        if detail then
            Pp.send({ action = 'canceltransfer', id = detail.id })
        end
    end
end

function HousesTab.onShow()
    if #houses == 0 or g_clock.millis() - loadedAt > 60000 then
        Pp.send({ action = 'houses' })
    end
    if selectedId then
        request(selectedId)
    end
end

function HousesTab.onGameEnd()
    houses, incoming, mine, selectedId, detail = {}, nil, 0, nil, nil
    loadedAt = 0
    shown.box = nil
    if page then
        clearTiles()
        page.details.content:hide()
        page.details.empty:show()
        page.side.list:destroyChildren()
    end
    if confirmBox then
        confirmBox:destroy()
        confirmBox = nil
    end
end

function HousesTab.terminate()
    removeEvent(searchEvent)
    HousesTab.onGameEnd()
end

Pp.registerPage('houses', HousesTab)
