-- The vocation window. The server (Vocations in the server lib) opens it with JSON on
-- ExtendedIds.Vocation: {type = "open", level, minLevel, chosen, rank, title, vocations = {{key, name, tagline, perks}, ...}},
-- then answers a choice with {type = "chosen", key, name, rank, title} or {type = "result", ok, text}.
-- A card's Select turns into Confirm and Back; Confirm sends {action = "choose", key}.
-- A trainer with a vocation gets the progress window instead: {type = "progress", key, name, tagline, rank,
-- maxRank, title, titles, levels, level, since, look, wearing, perks = {{icon, text, value}, ...}, ranks = {perks
-- of each rank}, next = {rank, title, level, trial = {goals = {{id, text, have, need}}, have, need}, gains =
-- {{icon, text, value, badge}}, ready, why}}. Its buttons send {action = "rankup"} and {action = "wear"};
-- {type = "trial", have, need, goals, ready} updates the trial and the top bar button's red "!" (also shown from level 20 until a vocation is chosen).
-- The U key is the vocation key: it opens the trainer's vocation tool (the Ranger radar, the Angler
-- fishing guide; those modules call registerTool(id, {enabled = fn, toggle = fn})), and without one
-- it asks the server for this window with {action = "open"}. Below level 20 the window opens with
-- its buttons greyed out. V only opens or closes this window.
local IMAGES = '/modules/game_vocation/images/'
local ERROR_COLOR = '#ff8a80'
local MUTED_COLOR = '#96aacd'
local MESSAGE_MS = 4000

local window
local cards = {}
local state = {}
local selected
local messageEvent
local tools = {}
local TOOL_ACTION = 'Vocation: window or vocation tool'
local WINDOW_ACTION = 'Show/hide the vocation window'
local progressWindow
local progress
local showingAll = false
local button, dot
local barEvent
local TOOL_BUTTONS = {
    radar = { text = 'Open Radar', icon = 'perk_radar' },
    fishing = { text = 'Open Fishing Guide', icon = 'perk_fish' },
}

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Vocation, data)
    end
end

local function canChoose()
    return not state.chosen and (state.level or 0) >= (state.minLevel or 0)
end

local function updateSubtitle()
    removeEvent(messageEvent)
    messageEvent = nil
    local text
    if state.chosen then
        local vocation = cards[state.chosen]
        local name = vocation and vocation.data.name or state.chosen
        local title = state.title or name
        text = tr('You are %s', (title:match('^[AEIOUaeiou]') and 'an ' or 'a ') .. title)
        if state.title then
            text = text .. ' ' .. tr('(%s, rank %d of 5)', name, state.rank or 1)
        end
    elseif canChoose() then
        text = tr('Unlocks at Trainer Level %d', state.minLevel) .. '  \183  ' .. tr('Permanent choice')
    else
        text = tr('Reach Trainer Level %d to choose. You are level %d.', state.minLevel or 0, state.level or 0)
    end
    window.subtitle:setColor(MUTED_COLOR)
    window.subtitle:setText(text)
end

local function showMessage(text)
    updateSubtitle()
    window.subtitle:setColor(ERROR_COLOR)
    window.subtitle:setText(text)
    messageEvent = scheduleEvent(updateSubtitle, MESSAGE_MS)
end

local function refreshCard(key)
    local card = cards[key].widget
    local isSelected = selected == key
    local isChosen = state.chosen == key
    card:setChecked(isSelected or isChosen)
    card.select:setVisible(not state.chosen and not isSelected)
    card.select:setEnabled(canChoose())
    card.confirm:setVisible(isSelected)
    card.back:setVisible(isSelected)
    card.note:setVisible(isSelected)
    card.chosen:setVisible(isChosen)
end

local function refreshCards()
    for key in pairs(cards) do
        refreshCard(key)
    end
end

local function pick(key)
    if not canChoose() then
        return
    end
    selected = key
    refreshCards()
end

local function build(vocations)
    window.grid:destroyChildren()
    cards = {}
    selected = nil
    for _, data in ipairs(vocations) do
        local card = g_ui.createWidget('VocationCard', window.grid)
        card:setId(data.key)
        card.banner:setImageSource(IMAGES .. 'banner_' .. data.key)
        card.icon:setImageSource(IMAGES .. 'icon_' .. data.key)
        card.name:setText(data.name or '')
        card.tagline:setText(data.tagline or '')
        for _, perk in ipairs(data.perks or {}) do
            g_ui.createWidget('VocationPerk', card.perks):setText(perk)
        end
        card.select:setText(tr('Select %s', data.name or ''))
        card.select.onClick = function() pick(data.key) end
        card.back.onClick = function()
            selected = nil
            refreshCards()
        end
        card.confirm.onClick = function()
            send({ action = 'choose', key = data.key })
        end
        cards[data.key] = { widget = card, data = data }
    end
    refreshCards()
end

local function center(widget)
    local root = rootWidget:getSize()
    widget:show()
    widget:setPosition({ x = math.floor((root.width - widget:getWidth()) / 2),
                         y = math.max(0, math.floor((root.height - widget:getHeight()) / 2)) })
    widget:raise()
    widget:focus()
end

local function show()
    progressWindow:hide()
    center(window)
end

-- Progress window --------------------------------------------------------------------------------

-- The red "!" on the top bar button: a vocation to choose (choose) or a rank up ready
local function setDot(visible, choose)
    if dot then
        dot:setVisible(visible and true or false)
    end
    if button then
        if visible then
            button:setTooltip(choose and tr('Vocation (choose your vocation!)') or tr('Vocation (rank up ready!)'))
        else
            button:setTooltip(tr('Vocation'))
        end
    end
end

local function setBar(bar, have, need)
    local width = bar:getWidth()
    bar.fill:setWidth(need > 0 and math.floor(width * math.min(1, have / need)) or width)
end

local function perkRow(parent, perk, gain)
    local row = g_ui.createWidget('VocationPerkRow', parent)
    row.icon:setImageSource(IMAGES .. 'perk_' .. (perk.icon or 'star'))
    if gain then
        row.tick:setImageSource(IMAGES .. 'perk_' .. (perk.icon or 'star'))
        row.icon:setVisible(false)
        row.icon:setWidth(0)
        row.icon:setMarginLeft(0)
        local on = perk.value == tr('On') or perk.value == 'On'
        row.text:setText(on and perk.text or (perk.text .. '  ' .. (perk.value or '')))
        row.value:setVisible(false)
        row.badge:setText(perk.badge or '')
        row.badge:setVisible(true)
    else
        row.text:setText(perk.text or '')
        row.value:setText(perk.value or '')
    end
    return row
end

local function fillRanks(data)
    local panel = progressWindow.ranksPanel
    panel.count:setText(tr('Rank %d of %d', data.rank, data.maxRank))
    panel.nodes:destroyChildren()
    local width = panel.nodes:getWidth()
    local cell = math.floor(width / data.maxRank)
    for r = 1, data.maxRank do
        local node = g_ui.createWidget('VocationRankNode', panel.nodes)
        node:setWidth(cell)
        node:addAnchor(AnchorTop, 'parent', AnchorTop)
        node:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        node:setMarginLeft((r - 1) * cell)
        local kind = r < data.rank and 'done' or (r == data.rank and 'current' or (r == data.rank + 1 and 'next' or 'locked'))
        node.node:setImageSource(IMAGES .. 'node_' .. kind)
        node.number:setText((kind == 'current' or kind == 'next') and tostring(r) or '')
        node.title:setText(data.titles[r] or '')
        node.title:setColor(kind == 'current' and '#ffd75a' or (kind == 'locked' and '#7d8aa8' or '#ffffff'))
        node.level:setText(tr('Trainer Lv. %d', data.levels[r] or 0))
        if kind == 'current' or kind == 'next' then
            node.tag:setText(kind == 'current' and tr('YOU') or tr('NEXT'))
            node.tag:setColor(kind == 'current' and '#2a1e00' or '#ffffff')
            node.tag:setImageColor(kind == 'current' and '#ffc83c' or '#3a78d8')
            node.tag:setVisible(true)
        end
    end
    panel.track:setMarginLeft(math.floor(cell / 2))
    panel.track:setMarginRight(width - cell * data.maxRank + math.floor(cell / 2))
    local trackWidth = cell * (data.maxRank - 1)
    panel.track.fill:setWidth(math.floor(trackWidth * (data.rank - 1) / (data.maxRank - 1)))
end

local function fillNext(data)
    local panel = progressWindow.nextPanel
    panel.list:destroyChildren()
    local next = data.next
    panel.goals:destroyChildren()
    for _, id in ipairs({ 'levelText', 'levelValue', 'levelBar', 'goals', 'newAt' }) do
        panel[id]:setVisible(next ~= nil)
    end
    panel.topRank:setVisible(next == nil)
    if not next then
        panel.heading:setText(tr('Top rank'))
        panel.topRank:setText(tr('You are %s, the top rank of the %s. Every perk of the vocation is yours.',
            data.title or '', data.name or ''))
        return
    end
    panel.heading:setText(tr('Next: %s  (rank %d)', next.title or '', next.rank or 0))
    panel.levelText:setText(tr('Trainer level %d', next.level or 0))
    local reached = (data.level or 0) >= (next.level or 0)
    panel.levelValue:setText(reached and tr('Lv. %d  \183  done', data.level or 0) or
        tr('Lv. %d / %d', data.level or 0, next.level or 0))
    panel.levelValue:setColor(reached and '#6fe08a' or '#ffffff')
    local goals = {}
    for _, goal in ipairs((next.trial or {}).goals or {}) do
        local row = g_ui.createWidget('VocationGoal', panel.goals)
        local have, need = tonumber(goal.have) or 0, tonumber(goal.need) or 0
        row.text:setText(goal.text or '')
        row.value:setText(have >= need and tr('%d / %d  \183  done', have, need) or string.format('%d / %d', have, need))
        row.value:setColor(have >= need and '#6fe08a' or '#ffffff')
        goals[#goals + 1] = { bar = row.bar, have = have, need = need }
    end
    panel.newAt:setText(tr('New at rank %d', next.rank or 0))
    for _, gain in ipairs(next.gains or {}) do
        perkRow(panel.list, gain, true)
    end
    removeEvent(barEvent)
    barEvent = scheduleEvent(function()
        barEvent = nil
        if progressWindow and progress then
            setBar(panel.levelBar, data.level or 0, next.level or 0)
            for _, goal in ipairs(goals) do
                setBar(goal.bar, goal.have, goal.need)
            end
            local rows = panel.list:getChildCount()
            local overflow = rows * 34 - 4 > panel.list:getHeight()
            panel.nextScroll:setVisible(overflow)
            panel.list:setMarginRight(overflow and 16 or 0)
            panel.nextScroll:setValue(0)
        end
    end, 50)
end

local function fillAll(data)
    local list = progressWindow.allPanel.list
    list:destroyChildren()
    for r = 1, data.maxRank do
        local section = g_ui.createWidget('VocationRankSection', list)
        local heading = g_ui.createWidget('VocationPanelTitle', section)
        heading:setText(tr('Rank %d  \183  %s  \183  Trainer Lv. %d', r, data.titles[r] or '', data.levels[r] or 0))
        heading:setIcon(IMAGES .. (r < data.rank and 'node_done' or (r == data.rank and 'node_current' or 'node_locked')))
        heading:setColor(r <= data.rank and '#ffd75a' or '#96aacd')
        for _, perk in ipairs(data.ranks[r] or {}) do
            local row = perkRow(section, perk)
            if r > data.rank then
                row:setOpacity(0.6)
            end
        end
    end
end

local function activeTool()
    for id, tool in pairs(tools) do
        if tool.enabled() then
            return id, tool
        end
    end
end

local function fillButtons(data)
    local main = progressWindow.buttons.main
    main:setEnabled(true)
    main:setTooltip('')
    local next = data.next
    if next and next.ready then
        main:setText(tr('Rank up to %s', next.title or ''))
        main:setIcon(IMAGES .. 'perk_up')
        main.onClick = function() send({ action = 'rankup' }) end
        return
    end
    local id, tool = activeTool()
    if tool then
        local info = TOOL_BUTTONS[id] or { text = 'Open', icon = 'perk_star' }
        main:setText(tr(info.text))
        main:setIcon(IMAGES .. info.icon)
        main.onClick = function()
            close()
            tool.toggle()
        end
        return
    end
    main:setText(next and tr('Rank up') or tr('Top rank reached'))
    main:setIcon(IMAGES .. (next and 'perk_up' or 'perk_crown'))
    main:setEnabled(false)
    main:setTooltip(next and next.why or '')
    main.onClick = nil
end

local function setView()
    progressWindow.allPanel:setVisible(showingAll)
    progressWindow.perksPanel:setVisible(not showingAll)
    progressWindow.nextPanel:setVisible(not showingAll)
    progressWindow.buttons.all:setText(showingAll and tr('Back') or tr('All Ranks'))
end

local function fillProgress(data)
    progress = data
    local w = progressWindow
    w.headerIcon:setImageSource(IMAGES .. 'icon_' .. data.key)
    w.subtitle:setText(tr('%s  \183  rank %d of %d', data.name or '', data.rank or 1, data.maxRank or 5))
    w.banner:setImageSource(IMAGES .. 'wide_' .. data.key)
    w.banner.vocation:setText((data.name or ''):upper())
    w.banner.title:setText(data.title or '')
    local since = tonumber(data.since) or 0
    w.banner.tagline:setText((data.tagline or '') ..
        (since > 0 and ('  \183  ' .. tr('%s since %s', data.name or '', os.date('%b %d, %Y', since))) or ''))
    w.banner.outfitTag:setText(tr('%s outfit unlocked', data.name or ''))
    w.banner.wear:setVisible(not data.wearing)
    local outfit = { type = tonumber(data.look) or 0, addons = 0 }
    local player = g_game.getLocalPlayer()
    if player then
        local own = player:getOutfit()
        outfit.head, outfit.body, outfit.legs, outfit.feet = own.head, own.body, own.legs, own.feet
    end
    w.banner.outfit:setOutfit(outfit)
    w.banner.outfit:setDirection(Directions and Directions.South or 2)
    w.perksPanel.heading:setText(tr('Your perks at rank %d', data.rank or 1))
    w.perksPanel.list:destroyChildren()
    for _, perk in ipairs(data.perks or {}) do
        perkRow(w.perksPanel.list, perk)
    end
    fillRanks(data)
    fillNext(data)
    fillAll(data)
    fillButtons(data)
    setView()
    setDot(data.next and data.next.ready)
end

local function showProgress(data)
    window:hide()
    if not progressWindow:isVisible() then
        showingAll = false
        center(progressWindow)
    end
    fillProgress(data)
end

function toggleAllRanks()
    showingAll = not showingAll
    setView()
end

function openGuide()
    if progress and modules.game_pokepedia and modules.game_pokepedia.openWiki then
        close()
        modules.game_pokepedia.openWiki('voc_' .. progress.key)
    end
end

function wearOutfit()
    send({ action = 'wear' })
end

-- The top bar button and the vocation key's fallback: the picker or the progress window
local function toggleWindow()
    if window:isVisible() or progressWindow:isVisible() then
        close()
    else
        send({ action = 'open' })
    end
end

function registerTool(id, tool)
    tools[id] = tool
end

function unregisterTool(id)
    tools[id] = nil
end

local function typing()
    local widget = rootWidget
    while widget:getFocusedChild() do
        widget = widget:getFocusedChild()
    end
    return widget:getClassName() == 'UITextEdit' and widget:isEnabled() and widget:isVisible()
end

local function onToolKey()
    if typing() or not g_game.isOnline() then
        return
    end
    if window:isVisible() or progressWindow:isVisible() then
        close()
        return
    end
    for _, tool in pairs(tools) do
        if tool.enabled() then
            tool.toggle()
            return
        end
    end
    send({ action = 'open' })
end

local function onWindowKey()
    if not typing() and g_game.isOnline() then
        toggleWindow()
    end
end

function close()
    if window and window:isVisible() then
        window:hide()
        send({ action = 'close' })
    end
    if progressWindow and progressWindow:isVisible() then
        progressWindow:hide()
    end
    selected = nil
end

local function onVocation(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Vocation: invalid message')
        return
    end
    if data.type == 'open' and type(data.vocations) == 'table' then
        state = { level = tonumber(data.level) or 0, minLevel = tonumber(data.minLevel) or 0, chosen = data.chosen,
                  rank = tonumber(data.rank), title = data.title }
        build(data.vocations)
        updateSubtitle()
        show()
    elseif data.type == 'chosen' then
        state.chosen = data.key
        state.rank = tonumber(data.rank)
        state.title = data.title
        selected = nil
        refreshCards()
        updateSubtitle()
    elseif data.type == 'progress' and data.key then
        showProgress(data)
    elseif data.type == 'trial' then
        setDot(data.ready, data.choose)
        if progress and progress.next and progressWindow:isVisible() then
            progress.next.trial = { goals = data.goals or {}, have = tonumber(data.have) or 0, need = tonumber(data.need) or 0 }
            progress.next.ready = data.ready
            fillNext(progress)
            fillButtons(progress)
        end
    elseif data.type == 'result' and data.text then
        if window:isVisible() then
            showMessage(data.text)
        elseif progressWindow:isVisible() then
            progressWindow.subtitle:setText(data.text)
            progressWindow.subtitle:setColor(ERROR_COLOR)
            removeEvent(messageEvent)
            messageEvent = scheduleEvent(function()
                messageEvent = nil
                if progress then
                    progressWindow.subtitle:setColor(MUTED_COLOR)
                    fillProgress(progress)
                end
            end, MESSAGE_MS)
        end
    end
end

local function onGameEnd()
    removeEvent(messageEvent)
    messageEvent = nil
    selected = nil
    state = {}
    progress = nil
    removeEvent(barEvent)
    barEvent = nil
    setDot(false)
    if window then
        window:hide()
    end
    if progressWindow then
        progressWindow:hide()
    end
end

function init()
    g_ui.importStyle('vocation')
    g_ui.importStyle('progress')
    window = g_ui.createWidget('VocationWindow', rootWidget)
    window:hide()
    progressWindow = g_ui.createWidget('VocationProgressWindow', rootWidget)
    progressWindow:hide()
    button = modules.client_topmenu.addRightGameToggleButton('vocationButton', tr('Vocation'),
        IMAGES .. 'button_vocation', toggleWindow)
    if button then
        -- the same badge as the Tasks button's count
        dot = g_ui.createWidget('UILabel', button)
        dot:setFont('verdana-11px-rounded')
        dot:setColor('#ffffff')
        dot:setBackgroundColor('#d03030')
        dot:setTextAlign(AlignCenter)
        dot:setText('!')
        dot:setSize({ width = 12, height = 12 })
        dot:addAnchor(AnchorTop, 'parent', AnchorTop)
        dot:addAnchor(AnchorRight, 'parent', AnchorRight)
        dot:setPhantom(true)
        dot:hide()
    end
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Vocation, onVocation)
    connect(g_game, { onGameEnd = onGameEnd })
    Keybind.new('Windows', TOOL_ACTION, { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'U' }, '')
    Keybind.bind('Windows', TOOL_ACTION, { { type = KEY_DOWN, callback = onToolKey } })
    Keybind.new('Windows', WINDOW_ACTION, { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'V' }, '')
    Keybind.bind('Windows', WINDOW_ACTION, { { type = KEY_DOWN, callback = onWindowKey } })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Vocation)
    disconnect(g_game, { onGameEnd = onGameEnd })
    Keybind.delete('Windows', TOOL_ACTION)
    Keybind.delete('Windows', WINDOW_ACTION)
    removeEvent(messageEvent)
    removeEvent(barEvent)
    if window then
        window:destroy()
        window = nil
    end
    if progressWindow then
        progressWindow:destroy()
        progressWindow = nil
    end
    if button then
        button:destroy()
        button, dot = nil, nil
    end
end
