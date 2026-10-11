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

-- Vars
local window, panel, lastLevel
local enabled = true
local lastSkill = {}
local popups = {}

-- Methods
function setDisplay(v)
    enabled = v
    window:setVisible(enabled)
end

local function reset()
    lastLevel = nil
    lastSkill = {}
    for widget in pairs(popups) do
        if not widget:isDestroyed() then
            widget:destroy()
        end
    end
    popups = {}
end

-- Starts the fade before the content is built, so a popup can never stay on screen
local function showTimed(widget, keep)
    widget:show()
    g_effects.fadeIn(widget, 2000)
    if not keep then
        popups[widget] = true
    end
    scheduleEvent(function()
        if widget:isDestroyed() then
            return
        end
        g_effects.fadeOut(widget, 3000)
        scheduleEvent(function()
            if widget:isDestroyed() then
                return
            end
            if keep then
                widget:hide()
            else
                popups[widget] = nil
                widget:destroy()
            end
        end, 3000)
    end, 9000)
end

local function show(value)
    panel:destroyChildren()
    showTimed(window, true)

    window:recursiveGetChildById('advanceMessage2'):setText(tr('Level %d', value))

    if (ADVANCES[value]) then
        for k, v in pairs(ADVANCES[value]) do
            local parent = g_ui.createWidget('AdvanceSection', panel)

            local image = g_ui.createWidget('UIWidget', parent)
            image:setId(0)
            image:setImageSource(v.image)
            image:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            image:addAnchor(AnchorTop, 'parent', AnchorTop)
            image:addAnchor(AnchorBottom, 'parent', AnchorBottom)

            local title = g_ui.createWidget('UILabel', parent)
            title:setText(v.title)
            --title:setFont("sans-bold-16px_cp1252")
            title:setColor('#b6b6b6')
            title:setTextAlign(AlignCenter)
            title:addAnchor(AnchorLeft, 0, AnchorRight)
            title:addAnchor(AnchorRight, 'parent', AnchorRight)
            title:addAnchor(AnchorTop, 'parent', AnchorTop)

            local description = g_ui.createWidget('UILabel', parent)
            description:setText(v.description)
            description:setFont("sans-bold-16px")
            description:setTextAlign(AlignCenter)
            description:addAnchor(AnchorLeft, 0, AnchorRight)
            description:addAnchor(AnchorRight, 'parent', AnchorRight)
            description:addAnchor(AnchorTop, 'prev', AnchorBottom)
            description:addAnchor(AnchorBottom, 'parent', AnchorBottom)
        end
    end
end

local function showSkill(id, value)
    if (SKILLS[id]) then
        local skillWindow = g_ui.createWidget('AdvanceWindow', modules.game_interface.getRootPanel())
        local panel = skillWindow:recursiveGetChildById('panel')
        showTimed(skillWindow)

        local parent = g_ui.createWidget('AdvanceSection', panel)

        local image = g_ui.createWidget('UIWidget', parent)
        image:setId(0)
        image:setImageSource(SKILLS[id].image)
        image:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        image:addAnchor(AnchorTop, 'parent', AnchorTop)
        image:addAnchor(AnchorBottom, 'parent', AnchorBottom)
        image:setPhantom(true)

        local title = g_ui.createWidget('UILabel', parent)
        title:setText(SKILLS[id].title)
        --title:setFont("sans-bold-16px_cp1252")
        title:setColor('#b6b6b6')
        title:setTextAlign(AlignCenter)
        title:addAnchor(AnchorLeft, 0, AnchorRight)
        title:addAnchor(AnchorRight, 'parent', AnchorRight)
        title:addAnchor(AnchorTop, 'parent', AnchorTop)

        local description = g_ui.createWidget('UILabel', parent)
        description:setText(value)
        description:setFont("sans-bold-16px")
        description:setTextAlign(AlignCenter)
        description:addAnchor(AnchorLeft, 0, AnchorRight)
        description:addAnchor(AnchorRight, 'parent', AnchorRight)
        description:addAnchor(AnchorTop, 'prev', AnchorBottom)
        description:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    end
end

local function showPokemon(id, value, newMoves)
    local skillWindow = g_ui.createWidget('PokemonAdvanceWindow', modules.game_interface.getRootPanel())
    showTimed(skillWindow)
    local panel = skillWindow:recursiveGetChildById('panel')
    local image = skillWindow:recursiveGetChildById('pokemonIcon')
    image:setImageSource('/images/staticPortraits/' .. id)

    local parent = g_ui.createWidget('AdvanceSection', panel)

    local title = g_ui.createWidget('UILabel', parent)
    local pokemonName = getPokemonNameByNumber(id) or ''
    title:setText(pokemonName)
    --title:setFont("sans-bold-16px_cp1252")
    title:setColor('#b6b6b6')
    title:setTextAlign(AlignCenter)
    title:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    title:addAnchor(AnchorRight, 'parent', AnchorRight)
    title:addAnchor(AnchorTop, 'parent', AnchorTop)

    local description = g_ui.createWidget('UILabel', parent)
    description:setText(value)
    description:setFont("sans-bold-16px")
    description:setTextAlign(AlignCenter)
    description:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    description:addAnchor(AnchorRight, 'parent', AnchorRight)
    description:addAnchor(AnchorTop, 'prev', AnchorBottom)
    description:addAnchor(AnchorBottom, 'parent', AnchorBottom)

    for k, v in pairs(newMoves) do
        local parent = g_ui.createWidget('AdvanceSection', panel)

        local image = g_ui.createWidget('AdvanceMoveItem', parent)
        image:setId(0)
        image:setItemId(v)
        image:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        image:addAnchor(AnchorTop, 'parent', AnchorTop)
        image:addAnchor(AnchorBottom, 'parent', AnchorBottom)

        local title = g_ui.createWidget('UILabel', parent)
        title:setText(tr('%s learned', pokemonName))
        title:setColor('#b6b6b6')
        title:setTextAlign(AlignCenter)
        title:addAnchor(AnchorLeft, 0, AnchorRight)
        title:addAnchor(AnchorRight, 'parent', AnchorRight)
        title:addAnchor(AnchorTop, 'parent', AnchorTop)

        local description = g_ui.createWidget('UILabel', parent)
        local moveName = getMoveNameByIconItemId(v)
        description:setText(moveName)
        if moveName ~= '' and modules.game_textmessage then
            modules.game_textmessage.displayMessage(MessageModes.Status, tr('Your %s learned %s!', pokemonName, moveName))
        end
        description:setFont("sans-bold-16px")
        description:setTextAlign(AlignCenter)
        description:addAnchor(AnchorLeft, 0, AnchorRight)
        description:addAnchor(AnchorRight, 'parent', AnchorRight)
        description:addAnchor(AnchorTop, 'prev', AnchorBottom)
        description:addAnchor(AnchorBottom, 'parent', AnchorBottom)
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
    window = g_ui.loadUI('advanceeffect', modules.game_interface.getRootPanel())
    panel = window:recursiveGetChildById('panel')
    window:hide()

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

    if (window) then
        window:destroy()
        window = nil
    end
end