-- The Analyser window: the hunt session, the trainer's and the Pokemon's EXP with the time to the next level, and
-- the catch chances of the last wild Pokemon the trainer defeated. The server (Analyser in the server lib) answers
-- {action = "get"} on ExtendedIds.Analyser with a "catch" and a "pokemon" message, and sends a "catch" after every
-- kill (kill = true) and throw and a "pokemon" after every EXP gain. The trainer's EXP comes from the local player.

local IMAGES = '/modules/game_dailytasks/images/'
local TABS = { 'session', 'xp', 'catch' }
local SUBTITLES = {
    session = 'Your hunt since you logged in or reset',
    xp = 'Trainer and Pokemon experience this session',
    catch = 'Odds on the last Pokemon you defeated',
}
local HELP = {
    session = {
        title = 'The Session tab',
        lines = {
            'Counts what you did since you logged in or pressed Reset session.',
            'The "/ h" rates show after a minute of hunting.',
        },
    },
    xp = {
        title = 'The XP tab',
        lines = {
            'Trainer XP is your own. Pokemon XP adds up every Pokemon you had out.',
            'Next level is how long the rest of the level takes at this session\'s XP / h.',
        },
    },
    catch = {
        title = 'How catching works',
        lines = {
            'Ball counter: every ball you throw at this species adds to it, and better balls add more. It is kept per species, shared with its shiny, until you catch one.',
            'Species chance: how hard the species is. Until your counter reaches it, each throw has the same odds.',
            'After that, every throw makes the next one better: at double the species chance the odds are at their best.',
            'Catchable after: below a quarter of the species chance a ball can not catch it at all.',
            'Roll: a throw catches when a random number up to the second value is at most the first. Each Catching skill level makes the second value 0.1% smaller, up to 25.5% at skill 255.',
            'The percent on each ball is the chance for your next throw. Hover a ball for more.',
        },
    },
}
local BOARD_TOP = 112 -- window padding, header and tabs
local PADDING_BOTTOM = 22
local MIN_RATE_SECONDS = 60 -- XP per hour waits for a minute of hunting

local window, button, tickEvent
local currentTab = 'session'
local session = {}
local catchData, pokemonData

local function resetSession()
    local player = g_game.getLocalPlayer()
    local exp = player and player:getExperience() or 0
    -- 0 until the first stats arrive: the first change then only sets where the count starts
    session = { start = os.time(), kills = 0, trainer = 0, pokemon = 0, lastExp = exp > 0 and exp or nil }
end

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Analyser, data)
    end
end

local function thousands(value)
    local text = tostring(math.floor(value or 0))
    local result = text:reverse():gsub('(%d%d%d)', '%1,'):reverse()
    return (result:gsub('^,', ''))
end

local function clock(seconds)
    seconds = math.max(0, math.floor(seconds))
    return string.format('%02d:%02dh', math.floor(seconds / 3600), math.floor(seconds % 3600 / 60))
end

local function duration(seconds)
    if not seconds or seconds ~= seconds or seconds == math.huge then
        return '-'
    end
    seconds = math.max(0, math.ceil(seconds))
    if seconds < 60 then
        return tr('%d s', seconds)
    elseif seconds < 3600 then
        return tr('%d min', math.ceil(seconds / 60))
    elseif seconds < 360000 then
        return tr('%dh %02dm', math.floor(seconds / 3600), math.floor(seconds % 3600 / 60))
    end
    return tr('days')
end

local function elapsed()
    return math.max(1, os.time() - (session.start or os.time()))
end

local function perHour(amount)
    if elapsed() < MIN_RATE_SECONDS then
        return nil
    end
    return amount * 3600 / elapsed()
end

local function hourText(amount)
    local rate = perHour(amount)
    return rate and thousands(rate) or '-'
end

local function percentText(chance)
    if not chance or chance <= 0 then
        return '0%'
    elseif chance >= 1 then
        return '100%'
    elseif chance < 0.001 then
        return '<0.1%'
    end
    return string.format('%.1f%%', chance * 100)
end

local function ballTitle(name)
    return (name:gsub('(%a)(%w*)', function(first, rest) return first:upper() .. rest end)) .. ' ' .. tr('Ball')
end

local function setTrack(track, ratio, fill)
    track.fill:setImageSource(IMAGES .. (fill or 'fill_blue'))
    local function resize()
        local width = math.floor(track:getWidth() * math.max(0, math.min(1, ratio)))
        track.fill:setWidth(width)
        track.fill:setVisible(width >= 6)
    end
    track.onGeometryChange = resize
    resize()
end

local function setStat(stat, label, value, color)
    stat.label:setText(label)
    stat.value:setText(value)
    stat.value:setColor(color or '#dce6ff')
end

local function expForLevel(level)
    if modules.game_skills and modules.game_skills.expForLevel then
        return modules.game_skills.expForLevel(level)
    end
    return math.floor((50 * level * level * level) / 3 - 100 * level * level + (850 * level) / 3 - 200)
end

local function fitWindow(boardHeight)
    window:setHeight(BOARD_TOP + boardHeight + PADDING_BOTTOM)
end

local function refreshSession()
    local board = window.sessionBoard
    board.timeCard.time:setText(clock(elapsed()))
    local stats = board.stats
    setStat(stats.kills, tr('Pokemon defeated'), thousands(session.kills))
    setStat(stats.killsHour, tr('Defeated / h'), hourText(session.kills))
    setStat(stats.trainerXp, tr('Trainer XP gain'), thousands(session.trainer))
    setStat(stats.trainerHour, tr('Trainer XP / h'), hourText(session.trainer))
    setStat(stats.pokemonXp, tr('Pokemon XP gain'), thousands(session.pokemon))
    setStat(stats.pokemonHour, tr('Pokemon XP / h'), hourText(session.pokemon))
    fitWindow(36 + 10 + 6 * 18 + 16 + 10 + 24)
end

local function fillXpCard(card, title, level, gain, current, prev, nextAt, fill, levelText)
    card.title:setText(title)
    card.level:setText(levelText or (level and tr('Lv %d', level) or ''))
    setStat(card.gain, tr('XP gain'), thousands(gain))
    setStat(card.hour, tr('XP / h'), hourText(gain))
    local rate = perHour(gain)
    if level and nextAt and current then
        local left = nextAt - current
        setStat(card.eta, tr('Next level'), rate and rate > 0 and duration(left / rate * 3600) or '-', '#6fe08a')
        local ratio = (current - prev) / math.max(1, nextAt - prev)
        card.toLevel:setText(tr('To %d: %s XP', level + 1, thousands(left)))
        card.percent:setText(string.format('%d%%', math.floor(ratio * 100)))
        setTrack(card.track, ratio, fill)
    else
        setStat(card.eta, tr('Next level'), '-')
        card.toLevel:setText('')
        card.percent:setText('')
        setTrack(card.track, 0, fill)
    end
end

local function refreshXp()
    local board = window.xpBoard
    local player = g_game.getLocalPlayer()
    if player then
        local level = player:getLevel()
        fillXpCard(board.trainer, tr('Trainer'), level, session.trainer, player:getExperience(),
            expForLevel(level), expForLevel(level + 1), 'fill_blue')
    end

    local pokemon = pokemonData
    local note = tr('Pokemon XP counts every Pokemon you had out. The time to the next level uses this session\'s XP / h.')
    if pokemon and pokemon.name then
        if pokemon.max then
            fillXpCard(board.pokemon, pokemon.name, nil, session.pokemon, nil, nil, nil, 'fill_green', tr('Max'))
            note = tr('%s is at the highest level: its EXP raises its extra points.', pokemon.name)
        else
            fillXpCard(board.pokemon, pokemon.name, pokemon.level, session.pokemon, pokemon.exp, pokemon.prev,
                pokemon.next, 'fill_green')
            if pokemon.capped then
                setStat(board.pokemon.eta, tr('Next level'), tr('wait for you'), '#ff7a6b')
                note = tr('%s is too many levels above you: it gets no EXP until you level up.', pokemon.name)
            end
        end
    else
        fillXpCard(board.pokemon, tr('No Pokemon out'), nil, session.pokemon, nil, nil, nil, 'fill_green')
    end
    board.note:setText(note)
    fitWindow(134 + 10 + 30)
end

local function addDetail(parent, label, value)
    local stat = g_ui.createWidget('AnStat', parent)
    setStat(stat, label, value)
end

local function ballRow(parent, ball, data)
    local row = g_ui.createWidget('AnBallRow', parent)
    if (ball.item or 0) > 0 then
        row.item:setItemId(ball.item)
    end
    row.name:setText(ballTitle(ball.name))
    if ball.blocked then
        row.roll:setText(ball.blocked == 'type' and tr('wrong type') or tr('needs its own ball'))
        row.roll:setColor('#ff7a6b')
        row.percent:setText('-')
        row.percent:setColor('#96aacd')
        setTrack(row.track, 0, 'fill_gold')
        return
    end

    local chance = ball.chance or 0
    row.percent:setText(percentText(chance))
    if ball.unlock then
        row.roll:setText(tr('opens after %d throws', ball.unlock))
    elseif ball.roll then
        row.roll:setText(tr('roll %d / %d', math.floor(ball.rate or 1), ball.roll))
    elseif chance >= 1 then
        row.roll:setText(tr('sure catch'))
    end
    row.expected:setText(ball.expected and tr('about %s throws', thousands(math.ceil(ball.expected))) or '')
    setTrack(row.track, chance, 'fill_gold')

    local tip = { tr('%s next throw', percentText(chance)) }
    if ball.half then
        tip[#tip + 1] = tr('50%% chance in all by throw %d', ball.half)
    end
    if ball.expected then
        tip[#tip + 1] = tr('About %s throws on average', thousands(math.ceil(ball.expected)))
    end
    if data.unlockAt then
        if (data.tries or 0) < (data.chance or 0) then
            tip[#tip + 1] = tr('Same odds until your counter reaches %s, then every throw makes the next one better.',
                thousands(data.chance))
        else
            tip[#tip + 1] = tr('Your counter is past %s: every throw makes the next one better.', thousands(data.chance))
        end
    end
    row:setTooltip(table.concat(tip, '\n'))
end

local function refreshCatch()
    local board = window.catchBoard
    local data = catchData
    local has = data ~= nil and data.name ~= nil
    local safari = has and data.safari == true
    for _, id in ipairs({ 'levelBox', 'name', 'sub' }) do
        board[id]:setVisible(has)
    end
    for _, id in ipairs({ 'throws', 'skill', 'balls', 'details' }) do
        board[id]:setVisible(has and not safari)
    end
    board.empty:setVisible(not has or safari)
    if not has then
        board.empty:setText(tr('Defeat a wild Pokemon to see your chances of catching it.'))
        fitWindow(160)
        return
    end

    board.levelBox.level:setText(tostring(data.level or '?'))
    board.name:setText(data.name)
    board.sub:setText(tr('Level %s  -  your last kill', data.level or '?'))
    if safari then
        board.empty:setText(tr('Inside the Safari Zone only Safari Balls work, and they roll their own way.'))
        board.empty:setMarginTop(70)
        fitWindow(150)
        return
    end
    board.empty:setMarginTop(40)

    local tries, chance = data.tries or 0, data.chance or 0
    if data.unlockAt then
        local value, color
        if tries <= data.unlockAt then
            value, color = tr('%s  -  catchable after %s', thousands(tries), thousands(data.unlockAt)), '#ff7a6b'
        elseif tries < chance then
            value = tr('%s  -  odds start rising at %s', thousands(tries), thousands(chance))
        else
            value, color = tr('%s  -  odds rising with every throw', thousands(tries)), '#6fe08a'
        end
        setStat(board.throws, tr('Ball counter on this species'), value, color)
    else
        setStat(board.throws, tr('Ball counter on this species'), tr('not used'))
    end
    if data.skillBonus then
        setStat(board.skill, tr('Catching skill'), tr('%d  -  roll %s%% smaller', data.skill or 0, data.skillBonus))
    else
        setStat(board.skill, tr('Catching skill'), tr('%d  -  lowers the roll', data.skill or 0))
    end

    board.balls:destroyChildren()
    local balls = data.balls or {}
    for _, ball in ipairs(balls) do
        ballRow(board.balls, ball, data)
    end

    board.details:destroyChildren()
    local details = 1
    if data.unlockAt then
        addDetail(board.details, tr('Species chance'), tr('%s  -  odds rise once your counter passes it',
            thousands(chance)))
        details = details + 1
        addDetail(board.details, tr('Catchable after'), tr('your counter passes %s', thousands(data.unlockAt)))
    else
        addDetail(board.details, tr('Species chance'), thousands(chance))
    end
    if data.catcher then
        details = details + 1
        addDetail(board.details, tr('Catcher perk'), string.format('+%d%%', math.floor(data.catcher * 100 + 0.5)))
    end
    if data.boost then
        details = details + 1
        addDetail(board.details, tr('Discord boost'), string.format('x%.2f', data.boost))
    end

    local rows = math.max(1, #balls)
    fitWindow(46 + 10 + 36 + 8 + rows * 34 + (rows - 1) * 4 + 20 + 10 + details * 18)
end

local function fitHelp()
    local help = window.help
    if help:isVisible() then
        window:setHeight(math.max(window:getHeight(), BOARD_TOP + help:getHeight() + PADDING_BOTTOM))
    end
end

local function fillHelp()
    local help, info = window.help, HELP[currentTab]
    help.title:setText(tr(info.title))
    for _, child in ipairs(help:getChildren()) do
        if child ~= help.title then
            child:destroy()
        end
    end
    for _, line in ipairs(info.lines) do
        g_ui.createWidget('AnHelpLine', help):setText(tr(line))
    end
end

local function refresh()
    if not window or not window:isVisible() then
        return
    end
    window.subtitle:setText(tr(SUBTITLES[currentTab]))
    if currentTab == 'session' then
        refreshSession()
    elseif currentTab == 'xp' then
        refreshXp()
    else
        refreshCatch()
    end
    fitHelp()
    window:bindRectToParent()
end

function toggleHelp()
    local help = window.help
    help:setVisible(not help:isVisible())
    window.helpButton:setOn(help:isVisible())
    if help:isVisible() then
        fillHelp()
        help:raise()
    end
    refresh()
end

local function showTab(name)
    currentTab = name
    for _, tab in ipairs(TABS) do
        window.tabs[tab]:setChecked(tab == name)
        window[tab .. 'Board']:setVisible(tab == name)
    end
    if window.help:isVisible() then
        fillHelp()
    end
    refresh()
end

function show()
    local root = rootWidget:getSize()
    if not window:isVisible() then
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                             y = math.max(0, math.floor((root.height - 420) / 2)) })
    end
    window:show()
    window:raise()
    window:focus()
    if button then
        button:setOn(true)
    end
    send({ action = 'get' })
    showTab(currentTab)
end

function hide()
    if window then
        window:hide()
    end
    if button then
        button:setOn(false)
    end
end

function toggle()
    if window:isVisible() then
        hide()
    else
        show()
    end
end

function openTab(name)
    if not window:isVisible() then
        show()
    end
    showTab(name)
end

local function onAnalyser(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        return
    end
    if data.type == 'catch' then
        catchData = data
        if data.kill then
            session.kills = (session.kills or 0) + 1
        end
    elseif data.type == 'pokemon' then
        pokemonData = data
        session.pokemon = (session.pokemon or 0) + (tonumber(data.amount) or 0)
    else
        return
    end
    refresh()
end

local function onExperienceChange(localPlayer, value)
    if session.lastExp and value > session.lastExp then
        session.trainer = session.trainer + (value - session.lastExp)
    end
    session.lastExp = value
end

local function onGameStart()
    resetSession()
    catchData, pokemonData = nil, nil
    send({ action = 'get' })
end

local function onGameEnd()
    hide()
end

local function tick()
    if window and window:isVisible() and currentTab ~= 'catch' then
        refresh()
    end
end

function getState()
    return { session = session, catch = catchData, pokemon = pokemonData, tab = currentTab }
end

function init()
    g_ui.importStyle('analyser')
    window = g_ui.createWidget('AnalyserWindow', rootWidget)
    window:hide()
    window.help.onGeometryChange = fitHelp
    for _, name in ipairs(TABS) do
        window.tabs[name].onClick = function() showTab(name) end
    end
    window.sessionBoard.reset.onClick = function()
        resetSession()
        refresh()
    end

    button = modules.client_topmenu.addRightGameToggleButton('analyserButton', tr('Analyser'),
        '/modules/game_analyser/images/button_analyser', toggle)

    resetSession()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Analyser, onAnalyser)
    connect(LocalPlayer, { onExperienceChange = onExperienceChange })
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    tickEvent = cycleEvent(tick, 1000)
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Analyser)
    disconnect(LocalPlayer, { onExperienceChange = onExperienceChange })
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    removeEvent(tickEvent)
    tickEvent = nil
    if button then
        button:destroy()
    end
    if window then
        window:destroy()
    end
    window, button = nil, nil
end
