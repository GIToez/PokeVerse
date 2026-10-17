-- The Wiki tab: the game guide that used to be the Wiki Chat channel. The categories open and close
-- on the left; the picked topic reads on the right. The text lives in wiki_data.lua (WikiData), and
-- each topic's body is a list of blocks:
--   { 'p', text }                    a paragraph
--   { 'h', text }                    a heading
--   { 'steps', { text, ... } }       numbered steps
--   { 'tip', text }                  a gold note in a card
--   { 'keys', { key, ... } }         keyboard keys
--   { 'commands', { command, ... } } chat commands
--   { 'items', { { client id, caption }, ... } }
--   { 'pokemon', { { dex number, caption }, ... } }
--   { 'image', path, width, height, caption }
--   { 'table', { { heading, ... }, { cell, ... }, ... } }
--   { 'see', { topic key, ... } }    buttons to other topics
WikiTab = {}

local page
local topics = {} -- key -> { topic, category }
local expanded = {}
local rows = {}
local current
local searchEvent

local function index()
    topics = {}
    for _, category in ipairs(WikiData) do
        for _, topic in ipairs(category.topics) do
            topics[topic.key] = { topic = topic, category = category }
        end
    end
end

local function blockText(block)
    local kind, value = block[1], block[2]
    if type(value) == 'string' then
        return value
    end
    local parts = {}
    for _, entry in ipairs(value or {}) do
        if kind == 'table' then
            parts[#parts + 1] = table.concat(entry, ' ')
        else
            parts[#parts + 1] = type(entry) == 'table' and tostring(entry[2] or '') or tostring(entry)
        end
    end
    return table.concat(parts, ' ')
end

local function matches(topic, filter)
    if filter == '' then
        return true
    end
    if topic.title:lower():find(filter, 1, true) then
        return true
    end
    for _, block in ipairs(topic.body) do
        if block[1] ~= 'see' and blockText(block):lower():find(filter, 1, true) then
            return true
        end
    end
    return false
end

-- the article

local function fitHeight(widget, child, extra)
    local function fit()
        widget:setHeight(math.max(widget.minHeight or 0, child:getHeight() + (extra or 0)))
    end
    child.onGeometryChange = fit
    fit()
end

local function addChips(body, style, list)
    local chips = g_ui.createWidget('WikiChips', body)
    for _, text in ipairs(list) do
        local chip = g_ui.createWidget(style, chips)
        chip:setText(text)
    end
    return chips
end

local PICTURES_PER_ROW = 8

local function addPictures(body, list, draw)
    local row
    for index, entry in ipairs(list) do
        if (index - 1) % PICTURES_PER_ROW == 0 then
            row = g_ui.createWidget('WikiPictures', body)
            if index > 1 then
                row:setMarginTop(2)
            end
        end
        local picture = g_ui.createWidget('WikiPicture', row)
        draw(picture.frame, entry[1])
        picture.caption:setText(entry[2] or '')
        picture:setTooltip(entry[2] or '')
    end
end

local BLOCKS = {}

function BLOCKS.p(body, block)
    local text = g_ui.createWidget('WikiText', body)
    text:setText(block[2])
end

function BLOCKS.h(body, block)
    local heading = g_ui.createWidget('WikiHeading', body)
    heading:setText(block[2])
end

function BLOCKS.steps(body, block)
    for number, line in ipairs(block[2]) do
        local step = g_ui.createWidget('WikiStep', body)
        step.number:setText(tostring(number))
        step.text:setText(line)
        step.minHeight = 22
        fitHeight(step, step.text, 4)
    end
end

function BLOCKS.tip(body, block)
    local tip = g_ui.createWidget('WikiTip', body)
    tip.text:setText(block[2])
    tip.minHeight = 28
    fitHeight(tip, tip.text, 14)
end

function BLOCKS.keys(body, block)
    addChips(body, 'WikiKey', block[2])
end

function BLOCKS.commands(body, block)
    addChips(body, 'WikiCommand', block[2])
end

function BLOCKS.items(body, block)
    addPictures(body, block[2], function(frame, id)
        frame.item:setItemId(id)
        frame.item:show()
    end)
end

function BLOCKS.pokemon(body, block)
    addPictures(body, block[2], function(frame, number)
        frame.portrait:setImageSource(Pp.portrait(number))
        frame.portrait:show()
    end)
end

function BLOCKS.image(body, block)
    local image = g_ui.createWidget('WikiImage', body)
    local width, height = block[3] or 320, block[4] or 200
    image.picture:setSize({ width = width + 8, height = height + 8 })
    image.picture.image:setImageSource(block[2])
    image.caption:setText(block[5] or '')
    image:setHeight(height + 8 + (block[5] and 20 or 0))
end

function BLOCKS.table(body, block)
    local rows = block[2]
    local columns = #rows[1]
    for index, cells in ipairs(rows) do
        local row = g_ui.createWidget(index == 1 and 'WikiTableHead' or 'WikiTableRow', body)
        if index == 2 then
            row:setMarginTop(2)
        end
        if index > 1 and index % 2 == 1 then
            row:setBackgroundColor('#16244233')
        end
        local labels = {}
        for column = 1, columns do
            local label = g_ui.createWidget(index == 1 and 'WikiTableHeadCell' or 'WikiTableCell', row)
            label:setText(tostring(cells[column] or ''))
            labels[column] = label
        end
        -- the first column is wider: it names the row
        row.onGeometryChange = function()
            local width = row:getWidth()
            local first = math.floor(width * (columns > 2 and 0.34 or 0.5))
            local rest = math.floor((width - first) / math.max(1, columns - 1))
            for column, label in ipairs(labels) do
                label:setWidth(column == 1 and first or rest)
            end
        end
    end
end

function BLOCKS.see(body, block)
    local links = g_ui.createWidget('WikiLinks', body)
    local label = g_ui.createWidget('TkMuted', links)
    label:setText(tr('See also'))
    label:setTextAutoResize(true)
    for _, key in ipairs(block[2]) do
        local entry = topics[key]
        if entry then
            local button = g_ui.createWidget('TkSmallBlueButton', links)
            button:setText(entry.topic.title)
            button:setWidth(math.max(80, button:getTextSize().width + 24))
            button.onClick = function() WikiTab.open(key) end
        end
    end
end

local function drawArticle(key)
    local entry = topics[key]
    local article = page.article
    local body = article.body
    body:destroyChildren()
    if not entry then
        article.name:setText(tr('Pick a topic'))
        article.category:setText(tr('Open a category on the left'))
        return
    end
    local topic, category = entry.topic, entry.category
    article.name:setText(topic.title)
    article.category:setText(category.name)
    local frame = article.icon
    frame.item:hide()
    frame.portrait:hide()
    if topic.portrait then
        frame.portrait:setImageSource(Pp.portrait(topic.portrait))
        frame.portrait:show()
    elseif topic.item or category.item then
        frame.item:setItemId(topic.item or category.item)
        frame.item:show()
    end
    for _, block in ipairs(topic.body) do
        local draw = BLOCKS[block[1]]
        if draw then
            draw(body, block)
        else
            g_logger.warning('Pokepedia wiki: unknown block ' .. tostring(block[1]) .. ' in ' .. key)
        end
    end
    local spacer = g_ui.createWidget('UIWidget', body)
    spacer:setHeight(12)
    spacer:setPhantom(true)
    article.bodyScroll:setValue(0)
end

-- the list

local function drawList()
    local filter = page.side.search:getText():lower():gsub('^%s+', ''):gsub('%s+$', '')
    local groups = {}
    local shown = 0
    for _, category in ipairs(WikiData) do
        local entries = {}
        for _, topic in ipairs(category.topics) do
            if matches(topic, filter) then
                entries[#entries + 1] = topic
            end
        end
        if #entries > 0 then
            groups[#groups + 1] = { key = category.key, name = category.name, item = category.item,
                note = tostring(#entries), entries = entries }
            shown = shown + #entries
        end
    end
    rows = {}
    local list = page.side.list
    Pp.fillTree(list, groups, expanded, function(parent, topic)
        local row = g_ui.createWidget('PpTreeRow', parent)
        row.name:setText(topic.title)
        row.icon:setImageSource(Pp.IMAGES .. 'route_dot')
        row.icon:setSize({ width = 6, height = 6 })
        row.icon:setMarginLeft(10)
        row.name:setMarginLeft(6)
        row.topic = topic
        rows[topic.key] = row
        return row
    end, filter ~= '')
    if shown == 0 then
        local hint = g_ui.createWidget('TkMuted', list)
        hint:setText(tr('Nothing in the guide matches.'))
        hint:setMarginLeft(6)
        hint:setMarginTop(6)
    end
    local total = 0
    for _ in pairs(topics) do
        total = total + 1
    end
    page.side.total:setText(filter == '' and tr('%d topics', total) or tr('%d found', shown))
    if current and rows[current] then
        list:focusChild(rows[current], KeyboardFocusReason)
    end
end

function WikiTab.open(key)
    if not topics[key] then
        return
    end
    show('wiki')
    current = key
    expanded[topics[key].category.key] = true
    local row = rows[key]
    if not row then
        page.side.search:setText('')
        drawList()
        row = rows[key]
    end
    if row then
        page.side.list:focusChild(row, KeyboardFocusReason)
        Pp.revealRow(page.side.list, row)
    end
    drawArticle(key)
end

function WikiTab.setup(widget)
    page = widget
    index()
    page.side.search.onTextChange = function()
        removeEvent(searchEvent)
        searchEvent = scheduleEvent(drawList, 150)
    end
    page.side.list.onChildFocusChange = function(list, focused)
        if focused and focused.topic and focused.topic.key ~= current then
            current = focused.topic.key
            drawArticle(current)
        end
    end
    local first = WikiData[1]
    if first then
        expanded[first.key] = true
        current = first.topics[1] and first.topics[1].key
    end
    drawList()
    drawArticle(current)
end

function WikiTab.terminate()
    removeEvent(searchEvent)
end

-- for other modules: modules.game_pokepedia.openWiki('hotkeys')
function openWiki(key)
    WikiTab.open(key)
end

Pp.registerPage('wiki', WikiTab)
