-- Experience on the HUD (docs/concepts/side-panel, "The Skills window goes away in Pokegear"): Trainer
-- Spirit with its hours and a bar left of the HUD's XP bar, a chip with the total rate right of it
-- while an XP boost runs, and a card with the numbers and every boost while you hover your XP. The
-- boosts come from game_expboost, which asks the server for them.

local FULL_SPIRIT = 42 * 60 -- minutes
local HOUR = 3600
local MIN_SPAN = 120 -- seconds of samples before a per-hour estimate means anything
local REFRESH_MS = 30 * 1000
local GAP = 4

local spiritPill, boostChip, card
local refreshEvent
local shown = false
local hovered = false
local samples = {}

local function hudPanel()
    local hud = modules.game_interface.getRootPanel():getChildById('pokeHud')
    return hud and hud.experiencePanel
end

local function boost()
    return modules.game_expboost
end

local function player()
    return g_game.getLocalPlayer()
end

local function percentText(rate)
    return string.format('%d%%', math.floor(rate * 100 + 0.5))
end

local function plusText(rate)
    return string.format('+%d%%', math.floor((rate - 1) * 100 + 0.5))
end

local function timeText(seconds)
    local minutes = math.floor(seconds / 60)
    if minutes >= 60 then
        return tr('%dh %dm', math.floor(minutes / 60), minutes % 60)
    end
    return tr('%dm', math.max(minutes, 1))
end

local function expForLevel(level)
    return math.floor((50 * level * level * level) / 3 - 100 * level * level + (850 * level) / 3 - 200)
end

local function record()
    local p = player()
    if not p then
        return
    end
    -- logging in, the player exists before the server sends its experience
    local exp = p:getExperience()
    if exp <= 0 then
        return
    end
    local now = g_clock.seconds()
    samples[#samples + 1] = { now, exp }
    -- keep the newest sample from before the hour as the baseline
    while #samples > 2 and samples[2][1] <= now - HOUR do
        table.remove(samples, 1)
    end
end

-- experience gained over the last hour (or since login) and the seconds that covers
local function gained()
    local p = player()
    if not p or #samples == 0 then
        return 0, 0
    end
    local now = g_clock.seconds()
    local first = samples[1]
    local span = math.min(now - first[1], HOUR)
    return math.max(0, p:getExperience() - first[2]), span
end

local function boostState()
    local module = boost()
    if module and module.getState then
        return module.getState()
    end
end

local function stamina()
    local p = player()
    return p and p:getStamina() or 0
end

local function extraBoostRunning(state)
    if not state then
        return false
    end
    return (state.personal and (state.personal.rate or 0) > 0) or (state.event or 1) ~= 1
        or (state.discordBoost or 1) > 1
end

local function refreshSpirit()
    local minutes = stamina()
    local module = boost()
    spiritPill.hours:setText(tr('%dh', math.floor(minutes / 60)))
    local fill = spiritPill.bar.fill
    local width = math.floor(spiritPill.bar:getWidth() * math.min(minutes, FULL_SPIRIT) / FULL_SPIRIT)
    fill:setWidth(math.max(width, 6))
    fill:setVisible(minutes > 0)
    if module and module.staminaColor then
        fill:setImageColor(module.staminaColor(minutes))
        spiritPill:setTooltip(module.staminaTooltip(minutes))
    end
end

local function refreshChip()
    local state = boostState()
    local module = boost()
    if not extraBoostRunning(state) or not module then
        boostChip:hide()
        return
    end
    boostChip.text:setText(tr('XP %s', percentText(module.trainerRate(stamina()))))
    boostChip:setWidth(boostChip.text:getWidth() + boostChip:getPaddingLeft() + boostChip:getPaddingRight())
    boostChip:setTooltip(tr('An XP boost is running. Hover your XP for every boost and its time left.'))
    boostChip:show()
end

local function addRow(label, value, color, indent)
    local row = g_ui.createWidget('PokegearXpRow', card.rows)
    row.label:setText(label)
    row.label:setMarginLeft(indent and 10 or 0)
    row.value:setText(value)
    if color then
        row.value:setColor(color)
    end
end

local function addGap()
    g_ui.createWidget('PokegearXpGap', card.rows)
end

local function fillCard()
    local p = player()
    if not p then
        return
    end
    local level, exp = p:getLevel(), p:getExperience()
    local toNext = math.max(0, expForLevel(level + 1) - exp)
    local percent = p:getLevelPercent()
    card.title:setText(tr('Level %d', level))
    card.progress:setText(tr('%d%% of the way to level %d', percent, level + 1))
    card.rows:destroyChildren()

    addRow(tr('Experience'), comma_value(exp))
    addRow(tr('To the next level'), comma_value(toNext))
    local amount, span = gained()
    addRow(span >= HOUR and tr('Gained this hour') or tr('Gained since you logged in'), comma_value(amount))
    if span >= MIN_SPAN and amount > 0 then
        local perHour = amount * HOUR / span
        addRow(tr('Next level in'), timeText(toNext / perHour * HOUR))
    end

    local module = boost()
    if not module or not module.trainerRate then
        return
    end
    local state, received = boostState()
    local minutes = stamina()
    local spiritRate = module.currentStaminaRate(minutes)
    local personal = state and state.personal and state.personal.rate or 0
    local event = state and state.event or 1
    local discord = state and state.discordBoost or 1
    local GREEN, MUTED = '#4fd66a', '#8a9ab8'

    addGap()
    addRow(tr('XP gain rate'), percentText(module.trainerRate(minutes)), '#ffcb05')
    addRow(tr('Base'), '100%', nil, true)
    addRow(tr('Trainer Spirit (%s left)', timeText(minutes * 60)),
           spiritRate > 1 and plusText(spiritRate) or '-', spiritRate > 1 and GREEN or MUTED, true)
    addRow(personal > 0 and tr('XP Boost (%s left)', timeText(module.personalSecondsLeft())) or tr('XP Boost'),
           personal > 0 and plusText(1 + personal) or '-', personal > 0 and GREEN or MUTED, true)
    addRow(tr('Server event'), event ~= 1 and string.format('x%s', event) or '-', event ~= 1 and GREEN or MUTED, true)
    if discord > 1 then
        addRow(tr('Discord server boost'), plusText(discord), GREEN, true)
    end

    if state then
        local pokemon = state.pokemon or {}
        local lucky, ace = pokemon.luckyEgg or 1, state.ace or 0
        local total = lucky * spiritRate * (1 + personal) * (1 + ace) * event * discord
        addGap()
        addRow(pokemon.name and tr('Pokemon EXP (%s)', pokemon.name) or tr('Pokemon EXP'), percentText(total),
               '#ffcb05')
        addRow(tr('Lucky Egg'), lucky ~= 1 and plusText(lucky) or '-', lucky ~= 1 and GREEN or MUTED, true)
        if ace > 0 then
            addRow(tr('Ace Trainer perk'), plusText(1 + ace), GREEN, true)
        end
    end
    card.note:setText(tr('Trainer Spirit goes down while you hunt and comes back while you are logged out.'))
end

local function placeCard()
    local panel = hudPanel()
    if not panel then
        return
    end
    local anchor = spiritPill:isVisible() and spiritPill:getRect() or panel:getRect()
    card:setPosition({ x = anchor.x + anchor.width - card:getWidth(), y = anchor.y + anchor.height + GAP })
end

local function setHovered(on)
    hovered = on
    if on then
        fillCard()
        card:show()
        card:raise()
        placeCard()
    else
        card:hide()
    end
end

local function refresh()
    if not shown then
        return
    end
    refreshSpirit()
    refreshChip()
    if hovered then
        fillCard()
    end
end

local function onExperienceChange()
    record()
    if hovered then
        fillCard()
    end
end

local function onTick()
    record()
    refresh()
end

local function build()
    local root = modules.game_interface.getRootPanel()

    spiritPill = g_ui.createWidget('PokegearSpiritPill', root)
    spiritPill:setId('pokegearSpirit')
    spiritPill:addAnchor(AnchorRight, 'pokeHud', AnchorHorizontalCenter)
    spiritPill:addAnchor(AnchorTop, 'pokeHud', AnchorTop)

    boostChip = g_ui.createWidget('PokegearBoostChip', root)
    boostChip:setId('pokegearXpBoost')
    boostChip:addAnchor(AnchorLeft, 'pokeHud', AnchorHorizontalCenter)
    boostChip:addAnchor(AnchorTop, 'pokeHud', AnchorTop)

    card = g_ui.createWidget('PokegearXpCard', root)
    card:setId('pokegearXpCard')
    card:hide()
end

-- the pills sit either side of the XP bar, which is centred in the HUD
local function placePills()
    local panel = hudPanel()
    local half = panel and math.floor(panel:getWidth() / 2) or 170
    spiritPill:setMarginRight(half + GAP)
    boostChip:setMarginLeft(half + GAP)
end

local function show()
    local panel = hudPanel()
    if not panel then
        return
    end
    if shown then
        refresh()
        return
    end
    if not spiritPill then
        build()
    end
    shown = true
    placePills()
    spiritPill:show()
    spiritPill:raise()
    boostChip:raise()

    -- the whole XP bar answers the hover instead of the plain tooltip on its track
    panel:setPhantom(false)
    panel.experience:setPhantom(true)
    panel.onHoverChange = function(widget, on)
        setHovered(on)
    end

    samples = {}
    record()
    connect(LocalPlayer, { onExperienceChange = onExperienceChange, onStaminaChange = refresh,
                           onLevelChange = refresh })
    local module = boost()
    if module then
        connect(module, { onBoostChange = refresh })
        if module.askNow and not module.getState() then
            module.askNow()
        end
    end
    if not refreshEvent then
        refreshEvent = cycleEvent(onTick, REFRESH_MS)
    end
    refresh()
end

local function hide()
    if refreshEvent then
        removeEvent(refreshEvent)
        refreshEvent = nil
    end
    if shown then
        disconnect(LocalPlayer, { onExperienceChange = onExperienceChange, onStaminaChange = refresh,
                                  onLevelChange = refresh })
        if boost() then
            disconnect(boost(), { onBoostChange = refresh })
        end
        local panel = hudPanel()
        if panel then
            panel.onHoverChange = nil
            panel:setPhantom(true)
            panel.experience:setPhantom(false)
        end
    end
    shown = false
    hovered = false
    for _, widget in ipairs({ spiritPill, boostChip, card }) do
        if widget then
            widget:hide()
        end
    end
end

Experience = {}

function Experience.apply(active)
    if active and g_game.isOnline() then
        show()
    else
        hide()
    end
end

function Experience.init()
    g_ui.importStyle('experience')
end

function Experience.terminate()
    hide()
    for _, widget in ipairs({ spiritPill, boostChip, card }) do
        if widget then
            widget:destroy()
        end
    end
    spiritPill, boostChip, card = nil, nil, nil
end
