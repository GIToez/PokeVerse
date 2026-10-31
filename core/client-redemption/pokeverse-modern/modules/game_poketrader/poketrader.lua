-- The PokeTrader auction window. Saying "auction" to Tiger Kelsey opens it (PokeTrader.open in the server lib); the
-- server talks JSON on ExtendedIds.PokeTrader: {type = "trader", npc, balance, money, held, ends, now, lots, won}
-- opens or refreshes it, {type = "log", id, rows} fills a lot's bid log, {type = "history", rows} the History tab,
-- {type = "result", ok, text} answers a bid, {type = "outbid", id} marks My bids and {type = "close"} closes it.
-- The window sends {action = "hello"} at login and bid, takeback, log, history, refresh and close. It closes by itself
-- when the trainer walks away from the NPC.
local OK_COLOR = '#7ee08f'
local BAD_COLOR = '#ff8a8a'
local GOLD_COLOR = '#ffd75a'
local MUTED_COLOR = '#96aacd'
local OUTBID_COLOR = '#ff8a3c'
local RANGE = 4
local CHECK_MS = 500
local MOBILE_MARGIN = 8
local MOBILE_ROW_HEIGHT = 64

local window
local state -- the last {type = "trader"} message
local receivedAt = 0 -- g_clock.seconds() when it came
local tab = 'lots'
local selected -- the id of the lot picked on This week
local selectedMine -- the id of the lot picked on My bids
local checkEvent

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.PokeTrader, data)
    end
end

local function thousands(value)
    local text = tostring(math.floor(tonumber(value) or 0))
    local formatted
    repeat
        text, formatted = text:gsub('^(-?%d+)(%d%d%d)', '%1,%2')
    until formatted == 0
    return text
end

local function dollars(value)
    return '$' .. thousands(value)
end

local function stepUp(value, percent)
    return math.ceil(value * (100 + percent) / 100)
end

local function left()
    if not state or (state.ends or 0) == 0 then
        return nil
    end
    return math.max(0, state.ends - state.now - (g_clock.seconds() - receivedAt))
end

local function duration(seconds)
    local days, hours, minutes = math.floor(seconds / 86400), math.floor(seconds % 86400 / 3600), math.floor(seconds % 3600 / 60)
    if days > 0 then
        return tr('%dd %dh', days, hours)
    elseif hours > 0 then
        return tr('%dh %dm', hours, minutes)
    end
    return tr('%dm', math.max(1, minutes))
end

local function lotById(id)
    for _, lot in ipairs(state and state.lots or {}) do
        if lot.id == id then
            return lot
        end
    end
    return nil
end

local function itemName(lot)
    return lot.count > 1 and string.format('%dx %s', lot.count, lot.name) or lot.name
end

local function setTag(tag, status)
    local text, color = '', '#dce6ff'
    if status == 'leading' then
        text, color = tr('Your bid is the highest'), OK_COLOR
    elseif status == 'outbid' then
        text, color = tr('Outbid'), OUTBID_COLOR
    elseif status == 'none' then
        text, color = tr('No bids yet'), MUTED_COLOR
    elseif status == 'owned' then
        text, color = tr('You already have one'), MUTED_COLOR
    end
    tag:setText(text)
    tag:setColor(color)
    tag:setVisible(text ~= '')
end

local function amount()
    local text = window.details.amount:getText():gsub('[^%d]', '')
    return tonumber(text) or 0
end

local function setAmount(value)
    window.details.amount:setText(value > 0 and thousands(value) or '')
end

local function refreshAction()
    local details = window.details
    local lot = lotById(selected)
    local value = amount()
    if not lot then
        details.action:setEnabled(false)
        details.takeBack:setEnabled(false)
        details.note:setText('')
        return
    end
    local extra = value - (lot.mine or 0)
    local can = lot.status ~= 'owned' and value > 0 and value ~= lot.mine and
        (value >= lot.lowest or (lot.mine > 0 and lot.status == 'outbid' and value >= lot.min))
    if lot.status == 'owned' then
        details.note:setText(tr('Each trainer can only win this once.'))
        details.note:setColor(MUTED_COLOR)
    elseif value > 0 and not can then
        details.note:setText(tr('Your maximum has to be at least %s.', dollars(lot.lowest)))
        details.note:setColor(BAD_COLOR)
    elseif extra > (state.balance or 0) + (state.money or 0) then
        details.note:setText(tr('You need %s in your bank or bag.', dollars(extra)))
        details.note:setColor(BAD_COLOR)
        can = false
    elseif extra > 0 then
        details.note:setText(tr('%s more will be held from your bank until the week ends.', dollars(extra)))
        details.note:setColor(MUTED_COLOR)
    elseif extra < 0 then
        details.note:setText(tr('%s goes back to your bank.', dollars(-extra)))
        details.note:setColor(MUTED_COLOR)
    else
        details.note:setText(tr('The auction bids for you, just 1%% over the next trainer, never past your maximum.'))
        details.note:setColor(MUTED_COLOR)
    end
    details.action:setText(lot.mine > 0 and tr('Raise maximum') or tr('Place bid'))
    if lot.mine > 0 and value > 0 and value < lot.mine then
        details.action:setText(tr('Lower maximum'))
    end
    details.action:setEnabled(can)
    details.takeBack:setEnabled(lot.mine > 0 and lot.status == 'outbid')
end

local function fillDetails()
    local details = window.details
    local lot = lotById(selected)
    details:setVisible(lot ~= nil)
    if not lot then
        return
    end
    details.name:setText(itemName(lot))
    details.kind:setText(lot.kind or '')
    details.minimum.caption:setText(tr('Minimum bid'))
    details.minimum.value:setText(dollars(lot.min))
    details.highest.caption:setText(tr('Highest bid'))
    details.highest.value:setText(lot.price > 0 and dollars(lot.price) or tr('None yet'))
    details.yours.caption:setText(tr('Your maximum'))
    details.yours.value:setText(lot.mine > 0 and dollars(lot.mine) or '-')
    details.yours.value:setColor(lot.status == 'leading' and OK_COLOR or (lot.status == 'outbid' and OUTBID_COLOR or '#ffffff'))
    details.count.caption:setText(tr('Bids'))
    details.count.value:setText(tostring(lot.bids))
    setAmount(lot.status ~= 'owned' and lot.lowest or 0)
    refreshAction()
end

local function fillLots()
    local panel = window.lotsPanel
    panel.list:destroyChildren()
    local lots = state.lots or {}
    panel.empty:setVisible(#lots == 0)
    if not lotById(selected) then
        selected = lots[1] and lots[1].id or nil
    end
    for _, lot in ipairs(lots) do
        local row = g_ui.createWidget('TraderRow', panel.list)
        if g_platform.isMobile() then
            row:setHeight(MOBILE_ROW_HEIGHT)
        end
        row.frame.item:setItemId(lot.client or 0)
        row.name:setText(itemName(lot))
        row.note:setText(lot.kind or '')
        row.price:setText(dollars(lot.price > 0 and lot.price or lot.min))
        row.price:setColor(lot.price > 0 and GOLD_COLOR or MUTED_COLOR)
        setTag(row.tag, lot.status)
        row:setOn(lot.status == 'owned')
        row:setChecked(lot.id == selected)
        row.onClick = function()
            selected = lot.id
            for _, child in ipairs(panel.list:getChildren()) do
                child:setChecked(child == row)
            end
            fillDetails()
        end
    end
    fillDetails()
end

local function fillLog(id, rows)
    local panel = window.logPanel
    if id ~= selectedMine then
        return
    end
    panel.list:destroyChildren()
    local lot = lotById(id)
    panel.subtitle:setText(lot and tr('%s. Other bidders stay anonymous until the week ends.', itemName(lot)) or '')
    for _, row in ipairs(rows) do
        local line = g_ui.createWidget('TraderLine', panel.list)
        line.text:setText(row.mine and tr('You') or tr('A trainer'))
        line.text:setColor(row.mine and OK_COLOR or '#ffffff')
        line.when:setText(os.date('%a %H:%M', row.date or 0) .. (row.auto and ('  -  ' .. tr('automatic')) or ''))
        line.amount:setText(dollars(row.price))
        line.amount:setColor(GOLD_COLOR)
    end
end

local function selectMine(id)
    selectedMine = id
    for _, child in ipairs(window.minePanel.list:getChildren()) do
        child:setChecked(child.lotId == id)
    end
    window.logPanel.list:destroyChildren()
    window.logPanel.subtitle:setText(id and tr('Loading...') or tr('Pick one of your bids to see how its price moved.'))
    if id then
        send({ action = 'log', id = id })
    end
end

local function fillMine()
    local panel = window.minePanel
    panel.list:destroyChildren()
    panel.held:setText(tr('Held for your maximums: %s', dollars(state.held or 0)))
    local any = false
    for _, lot in ipairs(state.lots or {}) do
        if lot.mine > 0 then
            any = true
            local row = g_ui.createWidget('TraderRow', panel.list)
            row.lotId = lot.id
            row.frame.item:setItemId(lot.client or 0)
            row.name:setText(itemName(lot))
            row.note:setText(tr('Your maximum %s', dollars(lot.mine)))
            row.price:setText(dollars(lot.price))
            row.price:setColor(GOLD_COLOR)
            setTag(row.tag, lot.status)
            row.onClick = function() selectMine(lot.id) end
        end
    end
    for _, won in ipairs(state.won or {}) do
        any = true
        local row = g_ui.createWidget('TraderRow', panel.list)
        row.frame.item:setItemId(won.client or 0)
        row.name:setText(won.count > 1 and string.format('%dx %s', won.count, won.name) or won.name)
        row.note:setText(tr('Won %s. It was sent to your depot.', os.date('%b %d', won.date or 0)))
        row.price:setText(dollars(won.bid))
        row.tag:setText(tr('Won'))
        row.tag:setColor(OK_COLOR)
        row:setEnabled(false)
    end
    panel.empty:setVisible(not any)
    local keep = selectedMine and lotById(selectedMine) and lotById(selectedMine).mine > 0
    if not keep then
        local first
        for _, lot in ipairs(state.lots or {}) do
            if lot.mine > 0 then
                first = first or lot.id
            end
        end
        selectMine(first)
    else
        selectMine(selectedMine)
    end
end

local function fillHistory(rows)
    local panel = window.historyPanel
    panel.list:destroyChildren()
    panel.empty:setVisible(#rows == 0)
    panel.empty:setText(tr('No auctions in the last two weeks.'))
    for _, row in ipairs(rows) do
        local line = g_ui.createWidget('TraderLine', panel.list)
        line.text:setText(row.count > 1 and string.format('%dx %s', row.count, row.name) or row.name)
        line.when:setText(os.date('%b %d', row.date or 0) .. '  -  ' ..
            (row.winner ~= '' and tr('Won by %s', row.winner) or tr('No bids')))
        line.amount:setText(row.winner ~= '' and dollars(row.bid) or '-')
        line.amount:setColor(row.winner ~= '' and GOLD_COLOR or MUTED_COLOR)
    end
end

local function fillFooter()
    local seconds = left()
    local text = seconds and tr('Bidding ends in %s (%s), with no extra time for late bids.', duration(seconds),
        os.date('%a %b %d, %H:%M', state.ends)) or ''
    window.footer:setText(text)
    window.subtitle:setText((state.npc ~= '' and (state.npc .. '  -  ') or '') ..
        (seconds and tr('Ends in %s', duration(seconds)) or tr('Weekly auction')))
end

-- refreshing: the same tab with new data, so History isn't asked for again
local function selectTab(name, refreshing)
    tab = name
    for _, id in ipairs({ 'lots', 'mine', 'history' }) do
        window.tabs[id]:setOn(id == name)
    end
    window.lotsPanel:setVisible(name == 'lots')
    window.details:setVisible(name == 'lots' and lotById(selected) ~= nil)
    window.minePanel:setVisible(name == 'mine')
    window.logPanel:setVisible(name == 'mine')
    window.historyPanel:setVisible(name == 'history')
    if name == 'mine' then
        window.tabs.mine.dot:setVisible(false)
        fillMine()
    elseif name == 'history' and not refreshing then
        window.historyPanel.empty:setText(tr('Loading...'))
        window.historyPanel.empty:setVisible(true)
        window.historyPanel.list:destroyChildren()
        send({ action = 'history' })
    end
end

local function fill(data)
    state, receivedAt = data, g_clock.seconds()
    window.bank.value:setText(dollars(data.balance))
    fillLots()
    fillFooter()
    selectTab(tab, true)
end

local function act()
    local lot = lotById(selected)
    if not lot or not window.details.action:isEnabled() then
        return
    end
    send({ action = 'bid', id = lot.id, max = amount() })
end

local function npcInRange()
    local player = g_game.getLocalPlayer()
    if not player or not state or state.npc == '' then
        return false
    end
    local pos = player:getPosition()
    for _, creature in ipairs(g_map.getSpectators(pos, false)) do
        if creature:isNpc() and creature:getName() == state.npc then
            local p = creature:getPosition()
            return p and p.z == pos.z and math.max(math.abs(p.x - pos.x), math.abs(p.y - pos.y)) <= RANGE
        end
    end
    return false
end

local function stopCheck()
    if checkEvent then
        removeEvent(checkEvent)
        checkEvent = nil
    end
end

local function hide()
    stopCheck()
    if window then
        window:hide()
    end
end

function close()
    if window and window:isVisible() then
        send({ action = 'close' })
    end
    hide()
end

local function check()
    if not window or not window:isVisible() then
        return stopCheck()
    end
    if not npcInRange() then
        return close()
    end
    fillFooter()
end

-- phones get the whole screen, bigger rows and no History tab (it is in the Pokepedia's PokeTrader page)
local function fitScreen()
    local mobile = g_platform.isMobile()
    window.tabs.history:setVisible(not mobile)
    if mobile then
        local root = rootWidget:getSize()
        window:setSize({ width = root.width - 2 * MOBILE_MARGIN, height = root.height - 2 * MOBILE_MARGIN })
        local side = math.floor(window:getWidth() * 0.4)
        window.details:setWidth(side)
        window.logPanel:setWidth(side)
        if tab == 'history' then
            tab = 'lots'
        end
    end
end

local function show()
    local root = rootWidget:getSize()
    if not window:isVisible() then
        fitScreen()
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                             y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
    end
    window:show()
    window:raise()
    window:focus()
    if not checkEvent then
        checkEvent = cycleEvent(check, CHECK_MS)
    end
end

local function onTrader(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('PokeTrader: invalid message')
        return
    end
    if data.type == 'trader' then
        if not window:isVisible() then
            tab, selectedMine = 'lots', nil
        end
        show()
        fill(data)
    elseif data.type == 'log' then
        fillLog(data.id, data.rows or {})
    elseif data.type == 'history' then
        if tab == 'history' then
            fillHistory(data.rows or {})
        end
    elseif data.type == 'outbid' then
        if tab ~= 'mine' then
            window.tabs.mine.dot:setVisible(true)
        end
    elseif data.type == 'close' then
        hide()
    elseif data.type == 'result' and data.text then
        if data.ok then
            modules.game_textmessage.displayGameMessage(data.text)
        else
            modules.game_textmessage.displayFailureMessage(data.text)
        end
    end
end

local function onGameStart()
    send({ action = 'hello' })
end

local function onGameEnd()
    state, selected, selectedMine = nil, nil, nil
    hide()
end

function init()
    g_ui.importStyle('poketrader')
    window = g_ui.createWidget('TraderWindow', rootWidget)
    window:hide()

    for _, id in ipairs({ 'lots', 'mine', 'history' }) do
        window.tabs[id].onClick = function() selectTab(id) end
    end
    local details = window.details
    details.amount.onTextChange = function()
        local digits = details.amount:getText():gsub('[^%d]', '')
        local text = digits ~= '' and thousands(tonumber(digits)) or ''
        if text ~= details.amount:getText() then
            details.amount:setText(text)
            details.amount:setCursorPos(#text)
        end
        refreshAction()
    end
    details.amount.onKeyPress = function(widget, keyCode)
        if keyCode == KeyEnter then
            act()
            return true
        end
    end
    details.quick.lowest.onClick = function()
        local lot = lotById(selected)
        if lot then
            setAmount(lot.lowest)
        end
    end
    details.quick.plus5.onClick = function()
        local lot = lotById(selected)
        if lot then
            setAmount(stepUp(math.max(amount(), lot.lowest), 5))
        end
    end
    details.quick.plus10.onClick = function()
        local lot = lotById(selected)
        if lot then
            setAmount(stepUp(math.max(amount(), lot.lowest), 10))
        end
    end
    details.action.onClick = act
    details.takeBack.onClick = function()
        local lot = lotById(selected)
        if lot then
            send({ action = 'takeback', id = lot.id })
        end
    end

    ProtocolGame.registerExtendedOpcode(ExtendedIds.PokeTrader, onTrader)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.PokeTrader)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    stopCheck()
    if window then
        window:destroy()
    end
    window = nil
end
