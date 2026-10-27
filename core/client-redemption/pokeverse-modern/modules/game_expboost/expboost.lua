-- Experience boosts for the Trainer Spirit bar in the Skills window (game_skills.patch asks for its tooltip, colour
-- and text). Players see "Trainer Spirit"; the server, the protocol and the code call it stamina. The server (ExpBoost in the server lib) answers {action = "get"} on ExtendedIds.ExpBoost with
-- {type = "boost", stamina = {minutes, rate}, premium, personal = {rate, left}, event, pokemon = {name, luckyEgg},
-- ace, trainer, pokemonTotal}, and sends a new one when a personal bonus starts or ends or the server event changes.
-- The window asks at login and again (at most once a minute) while the stamina changes.

-- hours of stamina, rate, Premium rate, name: the same levels as Player::getStaminaExperienceRate on the server
local TIERS = {
    { 41, 1.25, 1.5, 'Fired Up' },
    { 35, 1.2, 1.2, 'Pumped' },
    { 20, 1.15, 1.15, 'Focused' },
    { 10, 1.1, 1.1, 'Steady' },
    { 1, 1.05, 1.05, 'Winding Down' },
}
local WORN_OUT = 'Worn Out'
local ASK_EVERY = 60

local state
local received = 0
local lastAsk = 0

local function ask()
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        lastAsk = os.time()
        protocol:sendExtendedJSONOpcode(ExtendedIds.ExpBoost, { action = 'get' })
    end
end

local function premium()
    return state and state.premium == true
end

local function tierOf(minutes)
    local hours = math.floor((tonumber(minutes) or 0) / 60)
    for _, tier in ipairs(TIERS) do
        if hours >= tier[1] then
            return tier
        end
    end
    return nil
end

function staminaRate(minutes)
    local tier = tierOf(minutes)
    if not tier then
        return 1
    end
    return premium() and tier[3] or tier[2]
end

function staminaName(minutes)
    local tier = tierOf(minutes)
    return tr(tier and tier[4] or WORN_OUT)
end

local function percent(rate)
    return string.format('+%d%%', math.floor((rate - 1) * 100 + 0.5))
end

local function multiplier(rate)
    return string.format('x%s', (string.format('%.2f', rate):gsub('0+$', ''):gsub('%.$', '')))
end

local function minutesLeft()
    local left = ((state and state.personal and state.personal.left) or 0) - (os.time() - received)
    return math.max(0, math.ceil(left / 60))
end

-- the value shown next to "Trainer Spirit": the time and its bonus
function staminaText(stamina, timeText)
    local rate = currentStaminaRate(stamina)
    return rate > 1 and string.format('%s  %s', timeText, percent(rate)) or timeText
end

function staminaColor(stamina)
    local hours = math.floor(stamina / 60)
    if hours >= 41 then
        return '#4fd66a'
    elseif hours >= 20 then
        return '#89F013'
    elseif hours >= 1 then
        return 'orange'
    end
    return '#8a8a8a'
end

local function tierLines()
    local lines = { tr('Trainer Spirit bonus to trainer and Pokemon EXP:') }
    for index, tier in ipairs(TIERS) do
        local upper = index == 1 and 42 or TIERS[index - 1][1]
        local text = tier[2] == tier[3] and percent(tier[2])
            or tr('%s, Premium %s', percent(tier[2]), percent(tier[3]))
        lines[#lines + 1] = tr('  %s, %d-%d hours: %s', tr(tier[4]), tier[1], upper, text)
    end
    lines[#lines + 1] = tr('  %s, under 1 hour: no bonus, but never less experience', tr(WORN_OUT))
    lines[#lines + 1] = tr('It goes down while you hunt and comes back while you are logged out.')
    return lines
end

function staminaTooltip(stamina)
    local hours, minutes = math.floor(stamina / 60), stamina % 60
    local rate = currentStaminaRate(stamina)
    local lines = { tr('Trainer Spirit: %s, %d hours and %d minutes left.', staminaName(stamina), hours, minutes) }
    lines[#lines + 1] = rate > 1 and tr('It gives your trainer and Pokemon %s EXP now.', percent(rate))
        or tr('No bonus right now.')
    if hours >= 41 and not premium() and rate < 1.5 then
        lines[#lines + 1] = tr('Premium trainers get +50%% here instead of +25%%.')
    end
    lines[#lines + 1] = ''

    local personal = state and state.personal and state.personal.rate or 0
    local event = state and state.event or 1
    local trainer = rate * (1 + personal) * event
    lines[#lines + 1] = tr('Trainer EXP %s', multiplier(trainer))
    if rate > 1 then
        lines[#lines + 1] = tr('  Trainer Spirit %s', percent(rate))
    end
    if personal > 0 then
        lines[#lines + 1] = tr('  XP boost %s (%d min left)', percent(1 + personal), minutesLeft())
    end
    if event ~= 1 then
        lines[#lines + 1] = tr('  Server event %s', multiplier(event))
    end

    if state then
        local pokemon = state.pokemon or {}
        local lucky, ace = pokemon.luckyEgg or 1, state.ace or 0
        local total = lucky * rate * (1 + personal) * (1 + ace) * event
        lines[#lines + 1] = pokemon.name and tr('Pokemon EXP %s (%s)', multiplier(total), pokemon.name)
            or tr('Pokemon EXP %s', multiplier(total))
        if lucky ~= 1 then
            lines[#lines + 1] = tr('  Lucky Egg %s', percent(lucky))
        end
        if rate > 1 then
            lines[#lines + 1] = tr('  Trainer Spirit %s', percent(rate))
        end
        if personal > 0 then
            lines[#lines + 1] = tr('  XP boost %s', percent(1 + personal))
        end
        if ace > 0 then
            lines[#lines + 1] = tr('  Ace Trainer %s (not in duels or NPC battles)', percent(1 + ace))
        end
        if event ~= 1 then
            lines[#lines + 1] = tr('  Server event %s', multiplier(event))
        end
    end

    lines[#lines + 1] = ''
    for _, line in ipairs(tierLines()) do
        lines[#lines + 1] = line
    end
    return table.concat(lines, '\n')
end

local function refreshSkills()
    local player = g_game.getLocalPlayer()
    if player and modules.game_skills and modules.game_skills.onStaminaChange then
        modules.game_skills.onStaminaChange(player, player:getStamina())
    end
end

-- game_skills calls this from its own stamina handler
function onStaminaChanged()
    if os.time() - lastAsk >= ASK_EVERY then
        ask()
    end
end

local function onBoost(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or data.type ~= 'boost' then
        return
    end
    state = data
    received = os.time()
    refreshSkills()
    signalcall(onBoostChange, state)
end

-- the last answer and the os.time() it came at (Pokegear's experience on the HUD reads it too)
function getState()
    return state, received
end

-- the server's own stamina rate while it still matches the stamina tier the client sees
function currentStaminaRate(stamina)
    local sent = state and state.stamina
    if sent and sent.rate and tierOf(sent.minutes) == tierOf(stamina) then
        return sent.rate
    end
    return staminaRate(stamina)
end

-- what multiplies the trainer's kill experience: the same product as the server's trainer value
function trainerRate(stamina)
    local personal = state and state.personal and state.personal.rate or 0
    local event = state and state.event or 1
    local discord = state and state.discordBoost or 1
    return currentStaminaRate(stamina) * (1 + personal) * event * discord
end

function personalSecondsLeft()
    local left = ((state and state.personal and state.personal.left) or 0) - (os.time() - received)
    return math.max(0, left)
end

function askNow()
    ask()
end

local function onGameStart()
    ask()
end

local function onGameEnd()
    state = nil
    lastAsk = 0
end

function init()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.ExpBoost, onBoost)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.ExpBoost)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
end
