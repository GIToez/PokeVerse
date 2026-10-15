-- The Items tab: every item a trainer can know, by category. Shop items are known from the start;
-- any other item shows as ??? until the trainer had one in the bag or depot, or looked at one.
ItemsTab = {}

local page
local categories = {} -- { name, known, total }
local current
local items = {} -- { false | { id, client, name, shop } }
local incoming
local searchEvent

local function drawCategories()
    local list = page.side.list
    list:destroyChildren()
    local known, total = 0, 0
    local focus
    for index, category in ipairs(categories) do
        local row = g_ui.createWidget('PpCategoryRow', list)
        row.index = index
        row.name:setText(tr(category.name))
        row.count:setText(string.format('%d / %d', category.known, category.total))
        row.count:setColor(category.known >= category.total and '#8fe08f' or '#96aacd')
        known, total = known + category.known, total + category.total
        if index == current then
            focus = row
        end
    end
    page.side.total:setText(tr('%d / %d known', known, total))
    if focus then
        list:focusChild(focus, KeyboardFocusReason)
    end
end

local function drawItems()
    local grid = page.grid
    local panel = grid.items
    panel:destroyChildren()
    local category = categories[current]
    grid.name:setText(category and tr(category.name) or '')
    local filter = grid.search:getText():lower()
    for _, item in ipairs(items) do
        local visible = filter == '' or (item and item.name:lower():find(filter, 1, true))
        if visible then
            local cell = g_ui.createWidget('PpItemCell', panel)
            if item then
                cell.item:setItemId(item.client)
                local text = item.shop and tr('%s (sold in shops)', item.name) or item.name
                cell:setTooltip(text)
                cell.text = text
            else
                cell.item:hide()
                cell.unknown:show()
                cell:setTooltip(tr('Not discovered yet'))
                cell.text = '???'
            end
            cell.onHoverChange = function(widget, hovered)
                if hovered then
                    grid.selected:setText(widget.text)
                end
            end
        end
    end
    if category then
        local known = category.known
        grid.selected:setText(tr('%d of %d discovered', known, category.total))
    else
        grid.selected:setText('')
    end
end

function Handlers.items(data)
    categories = {}
    for _, category in ipairs(data.categories or {}) do
        categories[#categories + 1] = { name = tostring(category.name), known = category.known or 0, total = category.total or 0 }
    end
    if not current or not categories[current] then
        current = categories[1] and 1 or nil
    end
    drawCategories()
    if current then
        Pp.send({ action = 'category', id = current })
    end
end

function Handlers.category(data)
    if data.index ~= current then
        return
    end
    if data.part == 1 or not incoming then
        incoming = {}
    end
    for _, row in ipairs(data.items or {}) do
        if type(row) == 'table' then
            incoming[#incoming + 1] = { id = row[1], client = row[2], name = tostring(row[3]), shop = row[4] == 1 }
        else
            incoming[#incoming + 1] = false
        end
    end
    if data.part >= data.parts then
        items, incoming = incoming, nil
        drawItems()
    end
end

function Handlers.discovered(data)
    local category = categories[data.category]
    if category then
        category.known = math.min(category.total, category.known + 1)
    end
    if page and page:isVisible() then
        drawCategories()
        if data.category == current then
            Pp.send({ action = 'category', id = current })
        end
    end
end

function ItemsTab.setup(widget)
    page = widget
    page.side.list.onChildFocusChange = function(list, focused)
        if focused and focused.index and focused.index ~= current then
            current = focused.index
            items = {}
            drawItems()
            Pp.send({ action = 'category', id = current })
        end
    end
    page.grid.search.onTextChange = function()
        removeEvent(searchEvent)
        searchEvent = scheduleEvent(drawItems, 150)
    end
end

function ItemsTab.onShow()
    Pp.send({ action = 'items' })
end

function ItemsTab.onGameEnd()
    categories, current, items, incoming = {}, nil, {}, nil
    if page then
        page.side.list:destroyChildren()
        page.grid.items:destroyChildren()
    end
end

function ItemsTab.terminate()
    removeEvent(searchEvent)
end

Pp.registerPage('items', ItemsTab)
