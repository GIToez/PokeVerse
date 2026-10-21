-- The Bank window. The bank NPCs open it (Bank.open in the server lib); the server talks JSON on ExtendedIds.Bank:
-- {type = "bank", npc, balance, money} opens or refreshes it, {type = "check", name, found, own, self} answers a
-- name check, {type = "history", rows} fills History, {type = "result", ok, text} answers an action and
-- {type = "close"} closes it (the trainer walked away). The window sends {action = "hello"} at login (so the NPCs
-- know to open it) and the actions: deposit, withdraw, check, transfer, history, close.
local OK_COLOR = '#7ee08f'
local BAD_COLOR = '#ff8a8a'
local GOLD_COLOR = '#ffd75a'
local MUTED_COLOR = '#96aacd'
local QUICK = { q1000 = 1000, q10000 = 10000, q100000 = 100000 }

local window
local state -- the last {type = "bank"} message
local tab = 'deposit'
local checked -- the last {type = "check"} answer, for the name in the box
local confirmBox

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Bank, data)
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

local function closeConfirm()
    if confirmBox then
        confirmBox:destroy()
        confirmBox = nil
    end
end

-- the most this tab can move: what you carry for a deposit, the bank balance otherwise
local function limit()
    if not state then
        return 0
    end
    return tab == 'deposit' and (state.money or 0) or (state.balance or 0)
end

local function amount()
    local text = window.form.amount:getText():gsub('[^%d]', '')
    return tonumber(text) or 0
end

local function setAmount(value)
    window.form.amount:setText(value > 0 and thousands(value) or '')
end

local function transferName()
    return (window.form.name:getText():gsub('^%s+', ''):gsub('%s+$', ''))
end

local function nameReady()
    return checked and checked.found and not checked.self and checked.name:lower() == transferName():lower()
end

local function refreshAction()
    local form = window.form
    local value, max = amount(), limit()
    local over = value > max
    local action = form.action
    if tab == 'deposit' then
        action:setText(value > 0 and tr('Deposit %s', dollars(value)) or tr('Deposit'))
        form.note:setText(over and tr('You only carry %s.', dollars(max)) or
            tr('You carry %s. Money in the bank is safe and every character can send it on.', dollars(max)))
    elseif tab == 'withdraw' then
        action:setText(value > 0 and tr('Withdraw %s', dollars(value)) or tr('Withdraw'))
        form.note:setText(over and tr('You only have %s in the bank.', dollars(max)) or
            tr('You have %s in the bank.', dollars(max)))
    else
        local who = nameReady() and checked.name or nil
        action:setText(value > 0 and who and tr('Send %s to %s', dollars(value), who) or tr('Send'))
        form.note:setText(over and tr('You only have %s in the bank.', dollars(max)) or
            tr('Transfers come out of your bank balance and arrive in theirs at once, also while they are offline.'))
    end
    form.note:setColor(over and BAD_COLOR or MUTED_COLOR)
    action:setEnabled(value > 0 and not over and (tab ~= 'transfer' or nameReady()))
end

local function placeAmount(below)
    local caption = window.form.amountCaption
    caption:breakAnchors()
    caption:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    if below then
        caption:addAnchor(AnchorTop, below, AnchorBottom)
        caption:setMarginTop(12)
    else
        caption:addAnchor(AnchorTop, 'parent', AnchorTop)
        caption:setMarginTop(0)
    end
end

local function selectTab(name)
    tab = name
    closeConfirm()
    for _, id in ipairs({ 'deposit', 'withdraw', 'transfer', 'history' }) do
        window.tabs[id]:setOn(id == name)
    end
    local form, history = window.form, window.historyPanel
    form:setVisible(name ~= 'history')
    history:setVisible(name == 'history')
    if name == 'history' then
        history.empty:setText(tr('Loading...'))
        history.list:destroyChildren()
        send({ action = 'history' })
        return
    end
    local transfer = name == 'transfer'
    for _, id in ipairs({ 'nameCaption', 'name', 'check', 'nameStatus' }) do
        form[id]:setVisible(transfer)
    end
    placeAmount(transfer and 'nameStatus' or nil)
    setAmount(0)
    refreshAction()
    if transfer then
        form.name:focus()
    else
        form.amount:focus()
    end
end

local function fill(data)
    state = data
    window.subtitle:setText((data.npc ~= '' and (data.npc .. '  -  ') or '') ..
        tr('Keep your money safe and send it to other trainers'))
    window.balance.value:setText(dollars(data.balance))
    window.carried.value:setText(dollars(data.money))
    refreshAction()
end

local function fillCheck(data)
    checked = data
    local status = window.form.nameStatus
    if not data.found then
        status:setText(tr('There is no trainer called %s.', data.name ~= '' and data.name or '...'))
        status:setColor(BAD_COLOR)
    elseif data.self then
        status:setText(tr('That is you. Pick another trainer.'))
        status:setColor(BAD_COLOR)
    else
        window.form.name:setText(data.name)
        status:setText(data.own and tr('%s, one of your characters.', data.name) or tr('%s found.', data.name))
        status:setColor(OK_COLOR)
    end
    refreshAction()
end

local function fillHistory(rows)
    local panel = window.historyPanel
    panel.list:destroyChildren()
    panel.empty:setVisible(#rows == 0)
    panel.empty:setText(tr('No deposits, withdrawals or transfers yet.'))
    for _, row in ipairs(rows) do
        local widget = g_ui.createWidget('BankHistoryRow', panel.list)
        local sign, color
        if row.kind == 'deposit' then
            widget.text:setText(tr('Deposit'))
            sign, color = '+', OK_COLOR
        elseif row.kind == 'withdraw' then
            widget.text:setText(tr('Withdrawal'))
            sign, color = '-', GOLD_COLOR
        elseif row.kind == 'sent' then
            widget.text:setText(tr('Sent to %s', row.other or '?'))
            sign, color = '-', BAD_COLOR
        else
            widget.text:setText(tr('Received from %s', row.other or '?'))
            sign, color = '+', OK_COLOR
        end
        widget.when:setText(os.date('%b %d %Y, %H:%M', row.date or 0))
        widget.amount:setText(sign .. dollars(row.amount))
        widget.amount:setColor(color)
    end
end

local function act()
    if not window.form.action:isEnabled() then
        return
    end
    local value = amount()
    if tab == 'deposit' or tab == 'withdraw' then
        send({ action = tab, amount = value >= limit() and 'all' or value })
        setAmount(0)
        return
    end
    if not nameReady() then
        return
    end
    local name = checked.name
    closeConfirm()
    confirmBox = displayGeneralBox(tr('Send money'), tr('Send %s to %s?', dollars(value), name),
        { { text = tr('Send'), callback = function()
                closeConfirm()
                send({ action = 'transfer', name = name, amount = value })
                setAmount(0)
            end },
          { text = tr('Cancel'), callback = closeConfirm }, anchor = AnchorHorizontalCenter },
        closeConfirm, closeConfirm)
end

local function show()
    local root = rootWidget:getSize()
    if not window:isVisible() then
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                             y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
        selectTab('deposit')
    end
    window:show()
    window:raise()
    window:focus()
end

local function hide()
    closeConfirm()
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

local function onBank(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Bank: invalid message')
        return
    end
    if data.type == 'bank' then
        fill(data)
        show()
    elseif data.type == 'check' then
        fillCheck(data)
    elseif data.type == 'history' then
        fillHistory(data.rows or {})
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
    state, checked = nil, nil
    hide()
end

function init()
    g_ui.importStyle('bank')
    window = g_ui.createWidget('BankWindow', rootWidget)
    window:hide()

    window.balance.caption:setText(tr('In the bank'))
    window.carried.caption:setText(tr('Carried'))
    for _, id in ipairs({ 'deposit', 'withdraw', 'transfer', 'history' }) do
        window.tabs[id].onClick = function() selectTab(id) end
    end
    local form = window.form
    form.amount.onTextChange = function()
        local digits = form.amount:getText():gsub('[^%d]', '')
        local text = digits ~= '' and thousands(tonumber(digits)) or ''
        if text ~= form.amount:getText() then
            form.amount:setText(text)
            form.amount:setCursorPos(#text)
        end
        refreshAction()
    end
    form.name.onTextChange = refreshAction
    form.name.onKeyPress = function(widget, keyCode)
        if keyCode == KeyEnter then
            form.check:onClick()
            return true
        end
    end
    form.amount.onKeyPress = function(widget, keyCode)
        if keyCode == KeyEnter and form.action:isEnabled() then
            act()
            return true
        end
    end
    form.check.onClick = function()
        local name = transferName()
        if name ~= '' then
            send({ action = 'check', name = name })
        end
    end
    form.all.onClick = function() setAmount(limit()) end
    form.quick.clear.onClick = function() setAmount(0) end
    for id, value in pairs(QUICK) do
        form.quick[id].onClick = function() setAmount(math.min(limit(), amount() + value)) end
    end
    form.action.onClick = act

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Bank, onBank)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Bank)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    closeConfirm()
    if window then
        window:destroy()
    end
    window = nil
end
