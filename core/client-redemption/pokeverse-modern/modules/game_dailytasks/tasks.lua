-- The Tasks window: Daily, Weekly and Hunting tabs. The server sends each board's whole state
-- on login, on every change and when a period turns over: the daily board as
-- ExtendedIds.DailyTasks JSON (062-dailyTasks.lua), the weekly and hunting boards as
-- ExtendedIds.TaskBoards JSON with a board field (062-dailyTasks.lua, 064-huntingTasks.lua).
-- The window only asks with "/tasks <board> ..." and draws what comes back.
local window, button, badge
local boards = {} -- name -> { state = json, receivedAt = millis }
local current = 'daily'
local clockEvent

local BOARD_NAMES = { 'daily', 'weekly', 'hunting' }

local function command(board, param)
    g_game.talk('/tasks ' .. board .. (param and (' ' .. param) or ''))
end

local function formatMoney(amount)
    local text = tostring(amount)
    repeat
        local n
        text, n = text:gsub('^(%d+)(%d%d%d)', '%1,%2')
    until n == 0
    return '$' .. text
end

local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor(seconds % 86400 / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    if days > 0 then
        return tr('%dd %dh', days, hours)
    end
    return tr('%dh %02dm', hours, minutes)
end

local function secondsLeft(board, field)
    local entry = boards[board]
    if not entry or not entry.state[field] then
        return 0
    end
    return math.max(0, entry.state[field] - math.floor((g_clock.millis() - entry.receivedAt) / 1000))
end

local function setReward(row, reward)
    row.money:setText(reward.money > 0 and formatMoney(reward.money) or '')
    row.items:destroyChildren()
    for _, item in ipairs(reward.items or {}) do
        local widget = g_ui.createWidget('RewardItem', row.items)
        widget:setItemId(item.id)
        widget:setItemCount(item.count)
        widget:setTooltip(string.format('%d %s', item.count, item.name or ''))
    end
end

local function claimable(name)
    local entry = boards[name]
    if not entry then
        return 0
    end
    local state, count = entry.state, 0
    if name == 'hunting' then
        for _, hunt in ipairs(state.active or {}) do
            if hunt.progress >= hunt.target then
                count = count + 1
            end
        end
        return count
    end
    for _, task in ipairs(state.tasks or {}) do
        if not task.claimed and task.progress >= task.target then
            count = count + 1
        end
    end
    if state.bonus and state.bonus.ready then
        count = count + 1
    end
    return count
end

local TAB_TITLES = { daily = 'Daily', weekly = 'Weekly', hunting = 'Hunting' }

local function updateBadge()
    local total = 0
    for _, name in ipairs(BOARD_NAMES) do
        local count = claimable(name)
        total = total + count
        if window then
            window.tabs[name]:setText(count > 0 and string.format('%s (%d)', tr(TAB_TITLES[name]), count)
                or tr(TAB_TITLES[name]))
        end
    end
    if badge then
        badge:setText(total)
        badge:setVisible(total > 0)
    end
    if button then
        button:setTooltip(total > 0 and tr('Tasks (%d to claim)', total) or tr('Tasks'))
    end
end

-- fills the difficulty picker; onPick(id) runs when the trainer confirms a choice
local function setupPicker(picker, state, chosen, locked, onPick)
    local choice = picker.choice
    choice.onOptionChange = nil
    choice:clearOptions()
    local selected = chosen or state.suggested or 1
    for _, difficulty in ipairs(state.difficulties or {}) do
        local text = difficulty.available and tr(difficulty.name)
            or tr('%s (level %d)', tr(difficulty.name), difficulty.minLevel)
        choice:addOption(text, difficulty.id)
    end
    choice:setCurrentOptionByData(selected, true)
    choice:setEnabled(not locked)
    return choice
end

local function difficultyName(state, id)
    for _, difficulty in ipairs(state.difficulties or {}) do
        if difficulty.id == id then
            return tr(difficulty.name)
        end
    end
    return '?'
end

local function drawTask(board, row, task, state)
    local done = task.progress >= task.target
    row.title:setText(task.title)
    row.progress:setPercent(math.floor(task.progress * 100 / math.max(1, task.target)))
    row.progress:setText(string.format('%d / %d', task.progress, task.target))
    setReward(row, task.reward)
    row.claim:setText(task.claimed and tr('Claimed') or tr('Claim'))
    row.claim:setEnabled(done and not task.claimed)
    row.claim.onClick = function() command(board, 'claim ' .. task.slot) end
    row.reroll:setVisible(not done and not task.claimed)
    row.reroll:setEnabled(state.reroll.available)
    local cost = state.reroll.cost > 0 and formatMoney(state.reroll.cost) or tr('free')
    row.reroll:setTooltip(state.reroll.available and tr('Swap this task for another one (%s, once per reset)', cost)
        or tr('You already rerolled a task'))
    row.reroll.onClick = function() command(board, 'reroll ' .. task.slot) end
end

local PERIODIC_TEXT = {
    daily = { resets = 'New tasks in %s', pick = 'Pick today\'s difficulty. It sets the tasks and rewards and stays until midnight.',
              locked = 'Set until midnight', bonus = 'Daily bonus: claim every task', bonusDone = 'Daily bonus claimed. See you tomorrow!',
              reroll = 'You can reroll one unfinished task today for %s.', rerollUsed = 'You used today\'s reroll.' },
    weekly = { resets = 'New tasks in %s (Monday)', pick = 'Pick this week\'s difficulty. It sets the tasks and rewards and stays until Monday.',
               locked = 'Set until Monday', bonus = 'Weekly bonus: claim every task', bonusDone = 'Weekly bonus claimed. New tasks on Monday!',
               reroll = 'You can reroll one unfinished task this week for %s.', rerollUsed = 'You used this week\'s reroll.' },
}

local function drawPeriodic(name)
    local entry = boards[name]
    if not window or not entry then
        return
    end
    local panel, state, text = window[name .. 'Board'], entry.state, PERIODIC_TEXT[name]
    local started = state.difficulty ~= nil

    local choice = setupPicker(panel.picker, state, state.difficulty, started)
    panel.picker.start:setVisible(not started)
    panel.picker.start.onClick = function()
        local option = choice:getCurrentOption()
        if option then
            command(name, 'start ' .. option.data)
        end
    end
    panel.picker.info:setVisible(started)
    panel.picker.info:setText(started and tr(text.locked) or '')
    panel.pickHint:setVisible(not started)
    panel.pickHint:setText(tr(text.pick))

    panel.tasks:destroyChildren()
    for _, task in ipairs(state.tasks or {}) do
        drawTask(name, g_ui.createWidget('DailyTaskRow', panel.tasks), task, state)
    end

    local bonus = panel.bonus
    bonus:setVisible(started)
    panel.separator:setVisible(started)
    panel.rerollInfo:setVisible(started)
    if started then
        bonus.title:setText(state.bonus.claimed and tr(text.bonusDone) or tr(text.bonus))
        bonus.progress:hide()
        bonus.reroll:hide()
        setReward(bonus, state.bonus.reward)
        bonus.claim:setText(state.bonus.claimed and tr('Claimed') or tr('Claim'))
        bonus.claim:setEnabled(state.bonus.ready)
        bonus.claim.onClick = function() command(name, 'bonus') end
        local cost = state.reroll.cost > 0 and formatMoney(state.reroll.cost) or tr('free')
        panel.rerollInfo:setText(state.reroll.available and tr(text.reroll, cost) or tr(text.rerollUsed))
    end
end

local function setPortrait(widget, look)
    if look and look > 0 then
        widget:setOutfit({ type = look })
    end
end

local function drawHunting()
    local entry = boards.hunting
    if not window or not entry then
        return
    end
    local panel, state = window.huntingBoard, entry.state

    local rank = state.rank
    local rankText = tr('Rank: %s', tr(rank.name))
    if rank.bonus > 0 then
        rankText = rankText .. ' ' .. tr('(+%d%% money)', rank.bonus)
    end
    if rank.next then
        rankText = rankText .. '  ' .. tr('%d / %d points to %s', rank.earned, rank.nextAt, tr(rank.next))
    end
    panel.rank:setText(rankText)
    panel.points:setText(tr('%d Hunt Points', state.points))

    local choice = setupPicker(panel.picker, state, state.difficulty, state.locked)
    local picked = state.difficulty ~= nil
    panel.picker.start:setVisible(not picked)
    panel.picker.start.onClick = function()
        local option = choice:getCurrentOption()
        if option then
            command('hunting', 'difficulty ' .. option.data)
        end
    end
    panel.picker.info:setVisible(picked)
    panel.picker.info:setText(state.locked and tr('Finish or give up your hunts to change it') or '')
    if picked then
        choice.onOptionChange = function(_, _, id)
            if id ~= state.difficulty then
                command('hunting', 'difficulty ' .. id)
            end
        end
    end

    panel.activeTitle:setText(tr('Your hunts (%d / %d)', #state.active, state.slots))
    panel.active:destroyChildren()
    for _, hunt in ipairs(state.active) do
        local row = g_ui.createWidget('HuntRow', panel.active)
        setPortrait(row.creature, hunt.look)
        local done = hunt.progress >= hunt.target
        row.title:setText(tr('%s hunt: defeat %d %s', tr(hunt.sizeName), hunt.target, hunt.species))
        row.progress:setPercent(math.floor(hunt.progress * 100 / math.max(1, hunt.target)))
        row.progress:setText(string.format('%d / %d', hunt.progress, hunt.target))
        row.reward:setText(tr('%s and %d Hunt Points', formatMoney(hunt.money), hunt.points))
        row.claim:setEnabled(done)
        row.claim.onClick = function() command('hunting', 'claim ' .. hunt.slot) end
        row.cancel:setVisible(not done)
        row.cancel.onClick = function()
            local box
            box = displayGeneralBox(tr('Give up the hunt'), tr('Give up the %s hunt? Its progress is lost.', hunt.species),
                { { text = tr('Give up'), callback = function() box:destroy(); command('hunting', 'cancel ' .. hunt.slot) end },
                  { text = tr('Keep hunting'), callback = function() box:destroy() end } })
        end
    end
    if #state.active == 0 then
        local hint = g_ui.createWidget('TaskText', panel.active)
        hint:setHeight(20)
        hint:setColor('#a8b4b4')
        hint:setText(state.difficulty and tr('Pick a hunt from the offers below.')
            or tr('Pick a difficulty to see the offers.'))
    end

    local full = #state.active >= state.slots
    panel.offers:destroyChildren()
    for _, offer in ipairs(state.offers) do
        local row = g_ui.createWidget('OfferRow', panel.offers)
        setPortrait(row.creature, offer.look)
        row.title:setText(offer.species)
        row.levels:setText(tr('Level %d-%d', offer.minLevel, offer.maxLevel))
        for i = #offer.sizes, 1, -1 do
            local size = offer.sizes[i]
            local sizeButton = g_ui.createWidget('HuntSizeButton', row.sizes)
            sizeButton:setText(string.format('%s %d', tr(size.name), size.kills))
            sizeButton:setTooltip(tr('Defeat %d %s: %s and %d Hunt Points', size.kills, offer.species,
                formatMoney(size.money), size.points))
            sizeButton:setEnabled(not full)
            sizeButton.onClick = function() command('hunting', 'take ' .. offer.offer .. ' ' .. size.size) end
        end
    end

    local refresh = state.refresh
    panel.refresh:setVisible(state.difficulty ~= nil)
    if refresh.free then
        panel.refresh:setText(tr('New offers (free)'))
        panel.refresh:setTooltip(tr('Free once every 20 hours'))
    else
        panel.refresh:setText(tr('New offers (%s)', formatMoney(refresh.cost)))
        panel.refresh:setTooltip(tr('Free again in %s', formatTime(secondsLeft('hunting', 'refreshIn') or 0)))
    end
    panel.refresh.onClick = function() command('hunting', 'refresh') end

    panel.shop:destroyChildren()
    for _, item in ipairs(state.shop) do
        local widget = g_ui.createWidget('ShopItem', panel.shop)
        widget.item:setItemId(item.id)
        widget.item:setItemCount(item.count)
        widget:setTooltip(string.format('%d %s', item.count, item.name or ''))
        widget.buy:setText(tr('%d pts', item.cost))
        widget.buy:setEnabled(state.points >= item.cost)
        widget.buy.onClick = function() command('hunting', 'buy ' .. item.item) end
    end
end

local function updateClock()
    if not window then
        return
    end
    for _, name in ipairs({ 'daily', 'weekly' }) do
        if boards[name] then
            window[name .. 'Board'].resets:setText(tr(PERIODIC_TEXT[name].resets, formatTime(secondsLeft(name, 'resetsIn'))))
        end
    end
end

local function draw(name)
    if name == 'hunting' then
        drawHunting()
    else
        drawPeriodic(name)
    end
    updateClock()
    updateBadge()
end

local function showTab(name)
    current = name
    for _, board in ipairs(BOARD_NAMES) do
        window.tabs[board]:setChecked(board == name)
        window[board .. 'Board']:setVisible(board == name)
    end
end

local function receive(name, data)
    if name == 'hunting' and data.refresh then
        data.refreshIn = data.refresh.freeIn
    end
    boards[name] = { state = data, receivedAt = g_clock.millis() }
    draw(name)
end

local function decode(buffer)
    local ok, data = pcall(json.decode, buffer)
    if ok and type(data) == 'table' then
        return data
    end
    return nil
end

local function onDailyTasks(protocol, opcode, buffer)
    local data = decode(buffer)
    if not data or type(data.tasks) ~= 'table' then
        g_logger.warning('Tasks: invalid daily message')
        return
    end
    receive('daily', data)
end

local function onTaskBoards(protocol, opcode, buffer)
    local data = decode(buffer)
    if not data or (data.board ~= 'weekly' and data.board ~= 'hunting') then
        g_logger.warning('Tasks: invalid board message')
        return
    end
    if data.board == 'hunting' then
        data.active = data.active or {}
        data.offers = data.offers or {}
        data.shop = data.shop or {}
    else
        data.tasks = data.tasks or {}
    end
    receive(data.board, data)
end

function toggle()
    if window:isVisible() then
        window:hide()
        return
    end
    window:show()
    window:raise()
    window:focus()
    g_game.talk('/tasks')
end

local function onGameEnd()
    boards = {}
    if window then
        window:hide()
    end
    updateBadge()
end

function init()
    g_ui.importStyle('tasks')
    window = g_ui.createWidget('TasksWindow', rootWidget)
    window:hide()
    for _, name in ipairs(BOARD_NAMES) do
        window.tabs[name].onClick = function() showTab(name) end
    end
    showTab('daily')

    button = modules.client_topmenu.addRightGameToggleButton('dailyTasksButton', tr('Tasks'),
        '/images/options/button_taskboard', toggle)
    if button then
        badge = g_ui.createWidget('UILabel', button)
        badge:setId('badge')
        badge:setFont('verdana-11px-rounded')
        badge:setColor('#ffffff')
        badge:setBackgroundColor('#d03030')
        badge:setTextAlign(AlignCenter)
        badge:setSize({ width = 12, height = 12 })
        badge:addAnchor(AnchorTop, 'parent', AnchorTop)
        badge:addAnchor(AnchorRight, 'parent', AnchorRight)
        badge:setPhantom(true)
        badge:hide()
    end

    ProtocolGame.registerExtendedOpcode(ExtendedIds.DailyTasks, onDailyTasks)
    ProtocolGame.registerExtendedOpcode(ExtendedIds.TaskBoards, onTaskBoards)
    connect(g_game, { onGameEnd = onGameEnd })
    clockEvent = cycleEvent(updateClock, 30000)
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.DailyTasks)
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.TaskBoards)
    disconnect(g_game, { onGameEnd = onGameEnd })
    removeEvent(clockEvent)
    if button then
        button:destroy()
    end
    window:destroy()
    window, button, badge, boards = nil, nil, nil, {}
end

-- for the screenshots in tests: switch tabs without clicking
function selectTab(name)
    if window and window.tabs[name] then
        showTab(name)
    end
end
