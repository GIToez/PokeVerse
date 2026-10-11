-- Constants
local ADVANCES = {
    [30] = {
        {image = '/images/advances/safarizone', title = tr('New Feature'), description = tr('The Safari Zone')}
    },
    [10] = {
        {image = '/images/advances/rangerclub', title = tr('New Feature'), description = tr('Ranger Club - Rookie')}
    },
    [25] = {
        {image = '/images/advances/rangerclub', title = tr('New Feature'), description = tr('Ranger Club - Mentor')}
    },
    [50] = {
        {image = '/images/advances/rangerclub', title = tr('New Feature'), description = tr('Ranger Club - Coordinator')}
    },
    [75] = {
        {image = '/images/advances/rangerclub', title = tr('New Feature'), description = tr('Ranger Club - Coach')}
    },
    [85] = {
        {image = '/images/advances/daycare', title = tr('New Feature'), description = tr('Day Care')}
    },
    [70] = {
        {image = '/images/advances/battletower', title = tr('New Feature'), description = tr('Battle Tower - Twenty')}
    },
    [80] = {
        {image = '/images/advances/battletower', title = tr('New Feature'), description = tr('Battle Tower - Fifteen')}
    },
    [90] = {
        {image = '/images/advances/battletower', title = tr('New Feature'), description = tr('Battle Tower - Ten')}
    },
    [85] = {
        {image = '/images/advances/mastery', title = tr('New Feature'), description = tr('Mastery')}
    },
    [15] = {
        {image = '/images/advances/tournament', title = tr('New Feature'), description = tr('Tournament - Starter')}
    },
    [41] = {
        {image = '/images/advances/tournament', title = tr('New Feature'), description = tr('Tournament - Pro')}
    },
    [46] = {
        {image = '/images/advances/tournament', title = tr('New Feature'), description = tr('Tournament - Master')}
    },
    [61] = {
        {image = '/images/advances/tournament', title = tr('New Feature'), description = tr('Tournament - Elite')}
    },
    [75] = {
        {image = '/images/advances/tournament', title = tr('New Feature'), description = tr('Tournament - Titan')}
    },
}

local SKILLS = {
    --[PLAYER_SKILL_BATTLE_LOSS] = {image = '/images/advances/loss', title = tr('Battle Loss')},
    --[PLAYER_SKILL_BATTLE_WIN] = {image = '/images/advances/win', title = tr('Battle Win')},
    [PLAYER_SKILL_CATCHING] = {image = '/images/advances/catching', title = tr('Catching')},
    --[PLAYER_SKILL_DUEL_LOSS] = {image = '/images/advances/loss', title = tr('Duel Loss')},
    --[PLAYER_SKILL_DUEL_WIN] = {image = '/images/advances/win', title = tr('Duel Win')},
    [PLAYER_SKILL_FISHING] = {image = '/images/advances/fishing', title = tr('Fishing')},
    [PLAYER_SKILL_HEADBUTTING] = {image = '/images/advances/headbutting', title = tr('Headbutting')},
}

local MAX_VISIBLE = 4
local STAGGER = 250
local SHOW_TIME = 6000
local FADE_IN = 300
local FADE_OUT = 600
local SLIDE = 12

local BADGES = {
    up = '/modules/game_advanceeffect/images/badge-up',
    star = '/modules/game_advanceeffect/images/badge-star'
}

-- Vars
local column, lastLevel
local enabled = true
local lastSkill = {}
local groups = {}
local groupCount = 0
local queue = {}
local nextShowAt = 0
local pumpEvent

-- Methods
function setDisplay(v)
    enabled = v
    if column then
        column:setVisible(enabled)
    end
end

local pump

local function removeGroup(group)
    if groups[group] then
        groups[group] = nil
        groupCount = groupCount - 1
    end
    removeEvent(group.slideEvent)
    removeEvent(group.hideEvent)
    if not group:isDestroyed() then
        g_effects.cancelFade(group)
        group:destroy()
    end
    pump()
end

local function slideIn(group, elapsed)
    if group:isDestroyed() then
        return
    end
    local t = math.min(elapsed / FADE_IN, 1)
    group:setOpacity(t)
    group:setMarginTop(math.floor(SLIDE * (1 - t) + 0.5))
    if t < 1 then
        group.slideEvent = scheduleEvent(function()
            slideIn(group, elapsed + 30)
        end, 30)
    end
end

local function fillCard(card, spec)
    local portrait = spec.portrait or {}
    if portrait.image then
        local picture = card:recursiveGetChildById('picture')
        picture:setImageSource(portrait.image)
        if portrait.size then
            picture:setSize({ width = portrait.size, height = portrait.size })
        end
        picture:show()
    elseif portrait.outfit then
        local creature = card:recursiveGetChildById('creature')
        creature:setOutfit(portrait.outfit)
        creature:show()
    elseif portrait.item then
        local moveIcon = card:recursiveGetChildById('moveIcon')
        moveIcon:setItemId(portrait.item)
        moveIcon:show()
    end

    card:getChildById('badge'):setImageSource(BADGES[spec.kind] or '')
    card:getChildById('title'):setText(spec.title or '')
    card:getChildById('subtitle'):setText(spec.subtitle or '')
    card:getChildById('value'):setText(spec.value or '')
end

-- The fade-out is scheduled before the content is built, so a card can never stay on screen
local function display(spec)
    local group = g_ui.createWidget('AdvanceGroup', column)
    groups[group] = true
    groupCount = groupCount + 1
    group:setOpacity(0)
    group:setMarginTop(SLIDE)
    group.hideEvent = scheduleEvent(function()
        if group:isDestroyed() then
            return
        end
        g_effects.fadeOut(group, FADE_OUT)
        group.hideEvent = scheduleEvent(function()
            removeGroup(group)
        end, FADE_OUT)
    end, FADE_IN + SHOW_TIME)
    slideIn(group, 0)

    fillCard(g_ui.createWidget('AdvanceCard', group), spec)
    for _, row in ipairs(spec.rows or {}) do
        local widget = g_ui.createWidget('AdvanceFeatureRow', group)
        widget:getChildById('icon'):setImageSource(row.image)
        widget:getChildById('title'):setText(row.title)
        widget:getChildById('value'):setText(row.value)
    end
end

pump = function()
    if pumpEvent or not column or #queue == 0 or groupCount >= MAX_VISIBLE then
        return
    end
    local wait = nextShowAt - g_clock.millis()
    if wait > 0 then
        pumpEvent = scheduleEvent(function()
            pumpEvent = nil
            pump()
        end, wait)
        return
    end
    nextShowAt = g_clock.millis() + STAGGER
    display(table.remove(queue, 1))
    pump()
end

local function pushCard(spec)
    if not enabled then
        return
    end
    table.insert(queue, spec)
    pump()
end

local function reset()
    lastLevel = nil
    lastSkill = {}
    queue = {}
    removeEvent(pumpEvent)
    pumpEvent = nil
    for group in pairs(groups) do
        removeEvent(group.slideEvent)
        removeEvent(group.hideEvent)
        if not group:isDestroyed() then
            g_effects.cancelFade(group)
            group:destroy()
        end
    end
    groups = {}
    groupCount = 0
end

local function show(value)
    local player = g_game.getLocalPlayer()
    local rows = {}
    for _, advance in ipairs(ADVANCES[value] or {}) do
        table.insert(rows, { image = advance.image, title = advance.title, value = advance.description })
    end
    pushCard({
        kind = 'up',
        portrait = player and { outfit = player:getOutfit() } or nil,
        title = tr('Level Up!'),
        subtitle = player and player:getName() or '',
        value = tr('Level %d', value),
        rows = rows
    })
end

local function showSkill(id, value)
    local skill = SKILLS[id]
    if not skill then
        return
    end
    pushCard({
        kind = 'up',
        portrait = { image = skill.image, size = 34 },
        title = tr('Skill Up!'),
        subtitle = skill.title,
        value = tr('Level %d', value)
    })
end

local function showMove(pokemonName, iconItemId)
    local moveName = getMoveNameByIconItemId(iconItemId)
    pushCard({
        kind = 'star',
        portrait = { item = iconItemId },
        title = tr('New Move!'),
        subtitle = tr('%s learned', pokemonName),
        value = moveName
    })
    if moveName ~= '' and modules.game_textmessage then
        modules.game_textmessage.displayMessage(MessageModes.Status, tr('Your %s learned %s!', pokemonName, moveName))
    end
end

local function showPokemon(id, value, newMoves)
    local pokemonName = getPokemonNameByNumber(id) or ''
    pushCard({
        kind = 'up',
        portrait = { image = '/images/staticPortraits/' .. id },
        title = tr('Level Up!'),
        subtitle = pokemonName,
        value = tr('Level %d', value)
    })
    for _, iconItemId in ipairs(newMoves) do
        showMove(pokemonName, iconItemId)
    end
end

-- Hooks
function onOnline()
end

function onOffline()
    reset()
end

function onLevelChange(localPlayer, value, percent)
    if (not lastLevel) then -- Receiving first data from server, isnt a really skill change
        lastLevel = value
        return

    elseif (value == lastLevel) then
        return
    end

    show(value)
    lastLevel = value
end

function onSkillChange(localPlayer, id, level, percent)
    if (not lastSkill[id]) then
        lastSkill[id] = level
        return

    elseif (level == lastSkill[id]) then
        return
    end

    showSkill(id, level)
    lastSkill[id] = level
end

function onPokemonLevelUp(pokemonNumber, newLevel, newMoves)
    showPokemon(pokemonNumber, newLevel, newMoves)
end

function onInit()
    column = g_ui.loadUI('advanceeffect', modules.game_interface.getRootPanel())
    column:setVisible(enabled)

    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonLevelUp = onPokemonLevelUp
    })

    connect(LocalPlayer, {
        onLevelChange = onLevelChange,
        onSkillChange = onSkillChange,
    })

    if (g_game.isOnline()) then
        onOnline()
    end
end

function onTerminate()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonLevelUp = onPokemonLevelUp
    })

    disconnect(LocalPlayer, {
        onLevelChange = onLevelChange,
        onSkillChange = onSkillChange,
    })

    reset()

    if (column) then
        column:destroy()
        column = nil
    end
end
