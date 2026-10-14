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

local IMAGES = '/modules/game_dailytasks/images/'

local function setReward(row, reward)
    row.money:setText(reward.money > 0 and formatMoney(reward.money) or '')
    row.items:destroyChildren()
    for _, item in ipairs(reward.items or {}) do
        local widget = g_ui.createWidget('TkRewardItem', row.items)
        widget:setItemId(item.id)
        widget:setItemCount(item.count)
        widget:setTooltip(string.format('%d %s', item.count, item.name or ''))
    end
end

-- the fill is sized from the track's width, which is only known once the layout has run
local function setTrack(track, value, max, fill)
    track.fill:setImageSource(IMAGES .. (fill or 'fill_blue'))
    local function resize()
        local ratio = math.min(1, value / math.max(1, max))
        local width = math.floor(track:getWidth() * ratio)
        track.fill:setWidth(width)
        track.fill:setVisible(width >= 6)
    end
    track.onGeometryChange = resize
    resize()
end

-- icon = { item = clientId } | { portrait = dex number } | { look = outfit } | { picture = path }
local function setIcon(frame, icon)
    icon = icon or {}
    frame.item:setVisible(icon.item ~= nil)
    frame.portrait:setVisible(icon.portrait ~= nil)
    frame.creature:setVisible(icon.look ~= nil)
    frame.picture:setVisible(icon.picture ~= nil)
    if icon.item then
        frame.item:setItemId(icon.item)
    elseif icon.portrait then
        frame.portrait:setImageSource('/images/staticPortraits/' .. icon.portrait)
    elseif icon.look then
        frame.creature:setOutfit({ type = icon.look })
    elseif icon.picture then
        frame.picture:setImageSource(icon.picture)
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

local function drawTask(board, card, task, state)
    local done = task.progress >= task.target
    setIcon(card.icon, task.icon)
    card.title:setText(task.title)
    card.desc:setText(task.desc or '')
    setTrack(card.track, task.progress, task.target, (done or task.claimed) and 'fill_green' or 'fill_blue')
    card.count:setText(string.format('%d / %d', math.min(task.progress, task.target), task.target))
    setReward(card, task.reward)
    local claim, reroll = card.buttons.claim, card.buttons.reroll
    claim:setText(task.claimed and tr('Claimed') or tr('Claim'))
    claim:setEnabled(done and not task.claimed)
    claim.onClick = function() command(board, 'claim ' .. task.slot) end
    reroll:setVisible(not done and not task.claimed)
    reroll:setEnabled(state.reroll.available)
    local cost = state.reroll.cost > 0 and formatMoney(state.reroll.cost) or tr('free')
    reroll:setTooltip(state.reroll.available and tr('Swap this task for another one (%s, once per reset)', cost)
        or tr('You already rerolled a task'))
    reroll.onClick = function() command(board, 'reroll ' .. task.slot) end
end

local PERIODIC_TEXT = {
    daily = { resets = 'New tasks in %s', pick = 'Pick today\'s difficulty. It sets the tasks and rewards and stays until midnight.',
              locked = 'Set until midnight', bonus = 'Daily bonus', bonusDone = 'Daily bonus claimed. See you tomorrow!',
              ready = 'Ready for a new day?', readyText = 'Pick a difficulty above and press Start to get today\'s tasks.',
              reroll = 'You can reroll one unfinished task today for %s.', rerollUsed = 'You used today\'s reroll.' },
    weekly = { resets = 'New tasks in %s', pick = 'Pick this week\'s difficulty. It sets the tasks and rewards and stays until Monday.',
               locked = 'Set until Monday', bonus = 'Weekly bonus', bonusDone = 'Weekly bonus claimed. New tasks on Monday!',
               ready = 'Ready for a new week?', readyText = 'Pick a difficulty above and press Start to get this week\'s tasks.',
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

    panel.ready:setVisible(not started)
    panel.ready.picture:setImageSource(IMAGES .. 'ready_' .. name)
    panel.ready.title:setText(tr(text.ready))
    panel.ready.text:setText(tr(text.readyText))

    panel.list:setVisible(started)
    panel.list:destroyChildren()
    local claimed = 0
    for _, task in ipairs(state.tasks or {}) do
        drawTask(name, g_ui.createWidget('TkTaskCard', panel.list), task, state)
        if task.claimed then
            claimed = claimed + 1
        end
    end

    local bonus = panel.bonus
    bonus:setVisible(started)
    panel.rerollInfo:setVisible(started)
    if not started then
        return
    end
    setIcon(bonus.icon, { picture = IMAGES .. 'chest' })
    bonus.title:setText(state.bonus.claimed and tr(text.bonusDone) or tr(text.bonus))
    bonus.desc:setText(tr('Claim every task to receive a bonus reward!'))
    local total = #(state.tasks or {})
    setTrack(bonus.track, claimed, total, 'fill_gold')
    bonus.count:setText(string.format('%d / %d', claimed, total))
    bonus.rewardLabel:setText(tr('Bonus reward'))
    setReward(bonus, state.bonus.reward)
    bonus.buttons.reroll:hide()
    bonus.buttons.claim:setText(state.bonus.claimed and tr('Claimed') or tr('Claim'))
    bonus.buttons.claim:setEnabled(state.bonus.ready)
    bonus.buttons.claim.onClick = function() command(name, 'bonus') end
    local cost = state.reroll.cost > 0 and formatMoney(state.reroll.cost) or tr('free')
    panel.rerollInfo:setText(state.reroll.available and tr(text.reroll, cost) or tr(text.rerollUsed))
end

local function drawHunting()
    local entry = boards.hunting
    if not window or not entry then
        return
    end
    local panel, state = window.huntingBoard, entry.state

    local card, rank = panel.rankCard, state.rank
    card.medal:setImageSource(IMAGES .. 'rank_' .. (rank.name:lower():match('%a+') or 'bronze'))
    local rankText = tr('Rank: %s', tr(rank.name))
    if rank.bonus > 0 then
        rankText = rankText .. ' ' .. tr('(+%d%% money)', rank.bonus)
    end
    card.rank:setText(rankText)
    if rank.next then
        setTrack(card.track, rank.earned, rank.nextAt, 'fill_gold')
        card.rankNext:setText(tr('%d / %d points to %s', rank.earned, rank.nextAt, tr(rank.next)))
    else
        setTrack(card.track, 1, 1, 'fill_gold')
        card.rankNext:setText(tr('Highest rank reached'))
    end
    card.points:setText(tostring(state.points))

    local choice = setupPicker(card, state, state.difficulty, state.locked)
    local picked = state.difficulty ~= nil
    card.start:setVisible(not picked)
    card.start.onClick = function()
        local option = choice:getCurrentOption()
        if option then
            command('hunting', 'difficulty ' .. option.data)
        end
    end
    card.info:setVisible(state.locked)
    card.info:setText(tr('Locked while hunting'))
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
        local row = g_ui.createWidget('TkHuntCard', panel.active)
        setIcon(row.icon, { look = hunt.look })
        local done = hunt.progress >= hunt.target
        row.title:setText(tr('%s hunt: defeat %d %s', tr(hunt.sizeName), hunt.target, hunt.species))
        setTrack(row.track, hunt.progress, hunt.target, done and 'fill_green' or 'fill_blue')
        row.count:setText(string.format('%d / %d', math.min(hunt.progress, hunt.target), hunt.target))
        row.money:setText(formatMoney(hunt.money))
        row.points:setText(tr('+%d Hunt Points', hunt.points))
        local claim, cancel = row.buttons.claim, row.buttons.cancel
        claim:setEnabled(done)
        claim.onClick = function() command('hunting', 'claim ' .. hunt.slot) end
        cancel:setVisible(not done)
        cancel.onClick = function()
            local box
            box = displayGeneralBox(tr('Give up the hunt'), tr('Give up the %s hunt? Its progress is lost.', hunt.species),
                { { text = tr('Give up'), callback = function() box:destroy(); command('hunting', 'cancel ' .. hunt.slot) end },
                  { text = tr('Keep hunting'), callback = function() box:destroy() end } })
        end
    end
    if #state.active == 0 then
        local hint = g_ui.createWidget('TkMuted', panel.active)
        hint:setText(state.difficulty and tr('Pick a hunt from the offers below.')
            or tr('Pick a difficulty to see the offers.'))
    end

    local full = #state.active >= state.slots
    panel.offersTitle:setVisible(picked)
    panel.offers:setVisible(#state.offers > 0)
    panel.offers:destroyChildren()
    for _, offer in ipairs(state.offers) do
        local row = g_ui.createWidget('TkOfferCard', panel.offers)
        if offer.look and offer.look > 0 then
            row.creature:setOutfit({ type = offer.look })
        end
        row.title:setText(offer.species)
        row.levels:setText(tr('Level %d-%d', offer.minLevel, offer.maxLevel))
        for i = #offer.sizes, 1, -1 do
            local size = offer.sizes[i]
            local sizeButton = g_ui.createWidget('TkHuntSizeButton', row.sizes)
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
        panel.refresh:setTooltip(tr('Free once a day, again after midnight'))
    else
        panel.refresh:setText(tr('New offers (%s)', formatMoney(refresh.cost)))
        panel.refresh:setTooltip(tr('Free again in %s', formatTime(secondsLeft('hunting', 'refreshIn') or 0)))
    end
    panel.refresh.onClick = function() command('hunting', 'refresh') end

    panel.shop:destroyChildren()
    for _, item in ipairs(state.shop) do
        local tile = g_ui.createWidget('TkShopTile', panel.shop)
        tile.item:setItemId(item.id)
        tile.item:setItemCount(item.count)
        tile:setTooltip(string.format('%d %s', item.count, item.name or ''))
        local name = (item.name or ''):gsub('(%a)(%a*)', function(first, rest) return first:upper() .. rest end)
        tile.name:setText(name)
        tile.buy:setText(tr('%d pts', item.cost))
        tile.buy:setEnabled(state.points >= item.cost)
        tile.buy.onClick = function() command('hunting', 'buy ' .. item.item) end
    end
end

local fitEvent, fitCenter

-- the window follows the height of the open tab; it waits a moment so the lists have laid out
local function fitWindow(center)
    removeEvent(fitEvent)
    fitCenter = fitCenter or center
    fitEvent = scheduleEvent(function()
        fitEvent = nil
        if not window then
            return
        end
        local board = window[current .. 'Board']
        local bottom = board:getY()
        for _, child in ipairs(board:getChildren()) do
            if child:isVisible() then
                bottom = math.max(bottom, child:getY() + child:getHeight())
            end
        end
        local root = rootWidget:getSize()
        local height = math.min(bottom - window:getY() + window:getPaddingBottom(), root.height - 20)
        window:setHeight(height)
        local y = fitCenter and math.floor((root.height - height) / 2) or window:getY()
        fitCenter = nil
        window:setY(math.max(0, math.min(y, root.height - height)))
    end, 30)
end

local function updateClock()
    if not window then
        return
    end
    local resets, entry = window.tabs.resets, boards[current]
    if current == 'hunting' then
        local free = entry and entry.state.refresh and not entry.state.refresh.free
        resets:setVisible(free and true or false)
        if free then
            resets:setText(tr('Free offers in %s', formatTime(secondsLeft('hunting', 'refreshIn'))))
        end
        return
    end
    resets:setVisible(entry ~= nil)
    if entry then
        resets:setText(tr(PERIODIC_TEXT[current].resets, formatTime(secondsLeft(current, 'resetsIn'))))
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
    if name == current then
        fitWindow()
    end
end

local function showTab(name)
    current = name
    for _, board in ipairs(BOARD_NAMES) do
        window.tabs[board]:setChecked(board == name)
        window[board .. 'Board']:setVisible(board == name)
    end
    updateClock()
    fitWindow()
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
    local root = rootWidget:getSize()
    window:setWidth(math.min(660, root.width - 20))
    window:show()
    window:setX(math.floor((root.width - window:getWidth()) / 2))
    fitWindow(true)
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
    removeEvent(fitEvent)
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
