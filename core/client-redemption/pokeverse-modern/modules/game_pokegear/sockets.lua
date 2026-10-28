-- The Inventory box's slots that Pokegear keeps (docs/concepts/side-panel, Equipment): the equipment
-- socket left of the HUD (F: bikes, running shoes, the flashlight...), the Pokedex (X) and badge case
-- sockets right of it, and the Order button beside the Pokemon that's out on the swap bar (E). The
-- rest of the box goes: the belt and the backpack are the Bag, and balls and respect are on the
-- Trainer card.
local EQUIP_KEY = { 'Items', 'Use equipment' }
local ORDER_KEY = { 'Pokemon', 'Order' }
local DEX_KEY = { 'Pokemon', 'Use Pokedex on target' }
local ORDER_ICON = { source = '/images/pokeverse-ui/inv-order', width = 15, height = 15, scale = 1.6 }
local DEX_ICON = { source = '/images/pokeverse-ui/inv-pokedex', width = 25, height = 20, scale = 1.6 }
local BADGE_ICONS = { -- by the badge case's client id
    [11241] = { source = '/images/pokeverse-ui/inv-badges-kanto', width = 22, height = 17, scale = 1.6 },
    [17270] = { source = '/images/pokeverse-ui/inv-badges-orange', width = 27, height = 18, scale = 1.6 },
}
-- the HUD's main panel sits 27px down pokeHud and is 58px tall (game_pokehud/pokehud.otui)
local HUD_MIDDLE = 56
local HUD_GAP = 6
local FOLLOW_MS = 200

local equipSocket, dexSocket, badgeSocket, orderButton
local shown = false
local followEvent

local function slotItem(slot)
    local player = g_game.isOnline() and g_game.getLocalPlayer()
    return player and player:getInventoryItem(slot)
end

local function nameOf(item)
    local name = Bag.equipmentName(item:getId()) or (getItemNameByClientId and getItemNameByClientId(item:getId())) or ''
    if name == '' then
        return tr('Item %d', item:getId())
    end
    return (name:gsub('(%a)([%w]*)', function(a, b) return a:upper() .. b end))
end

local function useEquipment()
    local item = slotItem(InventorySlotFinger)
    if item then
        g_game.use(item)
    end
end

local function equip(item)
    if item then
        g_game.move(item, { x = 65535, y = InventorySlotFinger, z = 0 }, item:getCount())
    end
end

-- what in the open bags goes in the equipment slot, one of each
local function carriedEquipment()
    local list, seen = {}, {}
    for _, container in pairs(g_game.getContainers()) do
        for _, item in ipairs(container:getItems()) do
            if Bag.equipmentName(item:getId()) and not seen[item:getId()] then
                seen[item:getId()] = true
                list[#list + 1] = item
            end
        end
    end
    table.sort(list, function(a, b) return nameOf(a) < nameOf(b) end)
    return list
end

local function openEquipMenu(mousePos)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    local list = carriedEquipment()
    for _, item in ipairs(list) do
        menu:addOption(nameOf(item), function() equip(item) end)
        local option = menu:getLastChild()
        local icon = g_ui.createWidget('UIItem', option)
        icon:setVirtual(true)
        icon:setPhantom(true)
        icon:setItemId(item:getId())
        icon:setSize({ width = 16, height = 16 })
        icon:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        icon:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
        option:setTextOffset({ x = 18, y = 0 })
    end
    if #list == 0 then
        menu:addOption(tr('Nothing to equip in your Bag'), function() end, nil, true)
    end
    if slotItem(InventorySlotFinger) then
        menu:addSeparator()
        menu:addOption(tr('Put it back in the Bag'), function()
            -- onto the starting bag's slot puts it inside the bag
            local item = slotItem(InventorySlotFinger)
            if item and slotItem(InventorySlotAmmo) then
                g_game.move(item, { x = 65535, y = InventorySlotAmmo, z = 0 }, item:getCount())
            end
        end)
    end
    menu:display(mousePos)
end

local function setIcon(socket, icon)
    socket.icon:setImageSource(icon.source)
    socket.icon:setSize({ width = math.floor(icon.width * icon.scale), height = math.floor(icon.height * icon.scale) })
    socket.icon:show()
    socket.item:hide()
end

local function refreshKeys()
    for _, entry in ipairs({ { equipSocket, EQUIP_KEY }, { dexSocket, DEX_KEY }, { orderButton, ORDER_KEY } }) do
        local socket, key = entry[1], entry[2]
        if socket then
            local bound = Pokegear.boundKey(key)
            socket.chip:setText(bound)
            socket.chip:setVisible(bound ~= '')
        end
    end
end

local function refreshEquipSocket()
    if not equipSocket then
        return
    end
    local item = slotItem(InventorySlotFinger)
    equipSocket.item:setItem(item)
    equipSocket.item:setOpacity(item and 1 or 0)
    equipSocket:setTooltip(item and (nameOf(item) .. '\n' .. tr('Click to use, right-click to equip something else'))
        or tr('Equipment (bikes, running shoes, the flashlight...): right-click to pick from your Bag, or drop one here'))
end

local function refreshDexSocket()
    if dexSocket then
        dexSocket:setOpacity(slotItem(InventorySlotLeft) and 1 or 0.5)
    end
end

local function refreshBadgeSocket()
    if not badgeSocket then
        return
    end
    local item = slotItem(InventorySlotRight)
    local icon = item and BADGE_ICONS[item:getId()]
    if icon then
        setIcon(badgeSocket, icon)
    else
        badgeSocket.icon:hide()
        badgeSocket.item:setItem(item)
        badgeSocket.item:setVisible(item ~= nil)
    end
    badgeSocket:setOpacity(item and 1 or 0.5)
end

local function inventoryWindow()
    local inventory = modules.game_inventory
    return inventory and inventory.inventoryController and inventory.inventoryController.ui
end

-- the Order button rides beside the Pokemon that's out: to its right on a standing swap bar, above
-- it on a lying one. game_inventory shows its box again whenever the view mode changes, so it is
-- put away here too.
local function follow()
    local inventory = inventoryWindow()
    if inventory and inventory:isVisible() then
        inventory:hide()
    end
    local bar = modules.game_pokebar
    local slot = bar and bar.getActiveSlot and bar.getActiveSlot()
    local item = slotItem(InventorySlotHead)
    if not slot or not slot:isVisible() or not item then
        orderButton:hide()
        return
    end
    local rect = slot:getRect()
    local size = orderButton:getWidth()
    local barRect = bar.pokemonBar:getRect()
    if barRect.height > barRect.width then
        orderButton:setPosition({ x = rect.x + rect.width + 6, y = rect.y + math.floor((rect.height - size) / 2) })
    else
        orderButton:setPosition({ x = rect.x + math.floor((rect.width - size) / 2), y = rect.y - size - 6 })
    end
    if not orderButton:isVisible() then
        orderButton:show()
        orderButton:raise()
    end
end

local function build()
    local root = modules.game_interface.getRootPanel()

    equipSocket = g_ui.createWidget('PokegearSocket', root)
    equipSocket:setId('pokegearEquipment')
    equipSocket:addAnchor(AnchorRight, 'pokeHud', AnchorLeft)
    equipSocket:addAnchor(AnchorTop, 'pokeHud', AnchorTop)
    equipSocket:setMarginRight(HUD_GAP)
    equipSocket:setMarginTop(HUD_MIDDLE - equipSocket:getHeight() / 2)
    equipSocket.onClick = useEquipment
    equipSocket.onMouseRelease = function(widget, mousePos, button)
        if button == MouseRightButton then
            openEquipMenu(mousePos)
            return true
        end
        return false
    end
    equipSocket.onDrop = function(widget, dragged)
        if dragged and dragged.currentDragThing then
            local item = dragged.currentDragThing
            if item.isItem and item:isItem() then
                equip(item)
                return true
            end
        end
        return false
    end

    dexSocket = g_ui.createWidget('PokegearSocket', root)
    dexSocket:setId('pokegearPokedex')
    dexSocket:addAnchor(AnchorLeft, 'pokeHud', AnchorRight)
    dexSocket:addAnchor(AnchorTop, 'pokeHud', AnchorTop)
    dexSocket:setMarginLeft(HUD_GAP)
    dexSocket:setMarginTop(HUD_MIDDLE - dexSocket:getHeight() / 2)
    dexSocket:setTooltip(tr('Pokedex: click to use it on your target'))
    setIcon(dexSocket, DEX_ICON)
    dexSocket.onClick = function() modules.game_pokemoves.useDexOnTarget() end

    badgeSocket = g_ui.createWidget('PokegearSocket', root)
    badgeSocket:setId('pokegearBadges')
    badgeSocket:addAnchor(AnchorLeft, 'pokegearPokedex', AnchorRight)
    badgeSocket:addAnchor(AnchorTop, 'pokegearPokedex', AnchorTop)
    badgeSocket:setMarginLeft(HUD_GAP)
    badgeSocket:setTooltip(tr('Badge case'))
    badgeSocket.chip:hide()
    badgeSocket.onClick = function()
        local item = slotItem(InventorySlotRight)
        if item then
            g_game.use(item)
        end
    end

    orderButton = g_ui.createWidget('PokegearOrderButton', root)
    orderButton:setId('pokegearOrder')
    orderButton:setTooltip(tr('Order: tell your Pokemon where to go or what to use'))
    orderButton.chip:setMarginRight(-4)
    orderButton.chip:setMarginBottom(-4)
    setIcon(orderButton, ORDER_ICON)
    orderButton.onClick = function() modules.game_pokemoves.useOrder() end
end

local function onInventoryChange(player, slot)
    if slot == InventorySlotFinger then
        refreshEquipSocket()
    elseif slot == InventorySlotLeft then
        refreshDexSocket()
    elseif slot == InventorySlotRight then
        refreshBadgeSocket()
    end
end

local function show()
    if not equipSocket then
        build()
    end
    shown = true
    for _, widget in ipairs({ equipSocket, dexSocket, badgeSocket }) do
        widget:show()
        widget:raise()
    end
    refreshKeys()
    refreshEquipSocket()
    refreshDexSocket()
    refreshBadgeSocket()
    connect(LocalPlayer, { onInventoryChange = onInventoryChange })
    connect(Keybind, { onBind = refreshKeys })
    if not followEvent then
        followEvent = cycleEvent(follow, FOLLOW_MS)
    end
    follow()
end

local function hide()
    if followEvent then
        removeEvent(followEvent)
        followEvent = nil
    end
    if shown then
        disconnect(LocalPlayer, { onInventoryChange = onInventoryChange })
        disconnect(Keybind, { onBind = refreshKeys })
        local inventory = inventoryWindow()
        if inventory and g_game.isOnline() then
            inventory:show()
        end
    end
    shown = false
    for _, widget in ipairs({ equipSocket, dexSocket, badgeSocket, orderButton }) do
        if widget then
            widget:hide()
        end
    end
end

Sockets = {}

function Sockets.apply(active)
    if active and g_game.isOnline() then
        show()
    else
        hide()
    end
end

function Sockets.init()
    g_ui.importStyle('sockets')
    Keybind.new(EQUIP_KEY[1], EQUIP_KEY[2], { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'F' }, '')
    Keybind.bind(EQUIP_KEY[1], EQUIP_KEY[2], { { type = KEY_DOWN, callback = useEquipment } })
end

function Sockets.terminate()
    hide()
    Keybind.delete(EQUIP_KEY[1], EQUIP_KEY[2])
    for _, widget in ipairs({ equipSocket, dexSocket, badgeSocket, orderButton }) do
        if widget then
            widget:destroy()
        end
    end
    equipSocket, dexSocket, badgeSocket, orderButton = nil, nil, nil, nil
end
