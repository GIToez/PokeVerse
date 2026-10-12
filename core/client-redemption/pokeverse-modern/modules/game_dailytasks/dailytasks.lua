-- The server sends the whole state as ExtendedIds.DailyTasks JSON (DailyTasks.send in
-- 062-dailyTasks.lua) on login, on every change and at midnight; the window only asks with
-- "/dailytasks ..." and draws what comes back.
local window, button, badge
local state
local receivedAt = 0
local clockEvent

local function command(param)
    g_game.talk('/dailytasks' .. (param and (' ' .. param) or ''))
end

local function formatMoney(amount)
    local text = tostring(amount)
    repeat
        local n
        text, n = text:gsub('^(%d+)(%d%d%d)', '%1,%2')
    until n == 0
    return '$' .. text
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

local function claimable()
    local count = 0
    for _, task in ipairs(state and state.tasks or {}) do
        if not task.claimed and task.progress >= task.target then
            count = count + 1
        end
    end
    if state and state.bonus.ready then
        count = count + 1
    end
    return count
end

local function updateBadge()
    if not badge then
        return
    end
    local count = claimable()
    badge:setText(count)
    badge:setVisible(count > 0)
    if button then
        button:setTooltip(count > 0 and tr('Daily Tasks (%d to claim)', count) or tr('Daily Tasks'))
    end
end

local function updateClock()
    if not window or not state then
        return
    end
    local left = math.max(0, state.resetsIn - math.floor((g_clock.millis() - receivedAt) / 1000))
    window.resets:setText(tr('New tasks in %dh %02dm', math.floor(left / 3600), math.floor(left % 3600 / 60)))
end

local function drawTask(row, task)
    local done = task.progress >= task.target
    row.title:setText(task.title)
    row.progress:setPercent(math.floor(task.progress * 100 / math.max(1, task.target)))
    row.progress:setText(string.format('%d / %d', task.progress, task.target))
    setReward(row, task.reward)
    row.claim:setText(task.claimed and tr('Claimed') or tr('Claim'))
    row.claim:setEnabled(done and not task.claimed)
    row.claim.onClick = function() command('claim ' .. task.slot) end
    row.reroll:setVisible(not done and not task.claimed)
    row.reroll:setEnabled(state.reroll.available)
    row.reroll:setTooltip(state.reroll.available and tr('Swap this task for another one (%s, once a day)', formatMoney(state.reroll.cost))
        or tr('You already rerolled a task today'))
    row.reroll.onClick = function() command('reroll ' .. task.slot) end
end

local function draw()
    if not window or not state then
        return
    end
    window.tasks:destroyChildren()
    for _, task in ipairs(state.tasks) do
        drawTask(g_ui.createWidget('DailyTaskRow', window.tasks), task)
    end

    local bonus = window.bonus
    bonus.title:setText(state.bonus.claimed and tr('Daily bonus claimed. See you tomorrow!')
        or tr('Daily bonus: claim all three tasks'))
    bonus.progress:hide()
    bonus.reroll:hide()
    setReward(bonus, state.bonus.reward)
    bonus.claim:setText(state.bonus.claimed and tr('Claimed') or tr('Claim'))
    bonus.claim:setEnabled(state.bonus.ready)
    bonus.claim.onClick = function() command('bonus') end

    window.rerollInfo:setText(state.reroll.available
        and tr('You can reroll one unfinished task today for %s.', formatMoney(state.reroll.cost))
        or tr('You used today\'s reroll.'))
    updateClock()
end

local function onDailyTasks(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or type(data.tasks) ~= 'table' then
        g_logger.warning('Daily tasks: invalid message')
        return
    end
    state = data
    receivedAt = g_clock.millis()
    draw()
    updateBadge()
end

function toggle()
    if window:isVisible() then
        window:hide()
        return
    end
    window:show()
    window:raise()
    window:focus()
    command()
end

local function onGameEnd()
    state = nil
    if window then
        window:hide()
    end
    updateBadge()
end

function init()
    g_ui.importStyle('dailytasks')
    window = g_ui.createWidget('DailyTasksWindow', rootWidget)
    window:hide()

    button = modules.client_topmenu.addRightGameToggleButton('dailyTasksButton', tr('Daily Tasks'),
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
    connect(g_game, { onGameEnd = onGameEnd })
    clockEvent = cycleEvent(updateClock, 30000)
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.DailyTasks)
    disconnect(g_game, { onGameEnd = onGameEnd })
    removeEvent(clockEvent)
    if button then
        button:destroy()
    end
    window:destroy()
    window, button, badge, state = nil, nil, nil, nil
end
