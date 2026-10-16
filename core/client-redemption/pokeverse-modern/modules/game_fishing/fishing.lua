-- The Angler's Fishing Guide. The server (Fishing.openGuide in the server lib) talks JSON on ExtendedIds.Fishing:
-- {type = "status", enabled, rank, guideRank} says whether the trainer is an Angler (the top bar button only
-- shows for Anglers), {type = "guide", ...} fills the window and {type = "error", text} refuses it. The window
-- sends {action = "hello"} and {action = "open"}. A region's list is the Kanto pool plus that region's own;
-- Pokemon only found in the region are marked. Pokemon show as their Pokedex portraits.
local IMAGES = '/modules/game_fishing/images/'
local PORTRAITS = '/images/staticPortraits/'
local MUTED_COLOR = '#96aacd'
local OK_COLOR = '#7ee08f'
local LOCKED_COLOR = '#8a96b0'
local GOLD_COLOR = '#ffd75a'

local TYPE_COLORS = {
    normal = '#a8a878', fight = '#c03028', flying = '#a890f0', poison = '#a040a0', ground = '#e0c068',
    rock = '#b8a038', bug = '#a8b820', ghost = '#705898', steel = '#b8b8d0', fire = '#f08030',
    water = '#6890f0', grass = '#78c850', electric = '#f8c830', psychic = '#f85888', ice = '#98d8d8',
    dragon = '#7038f8', dark = '#705848', fairy = '#ee99ac'
}
local TYPE_LABELS = { fight = 'Fighting' }

local window, button
local status = { enabled = false }
local guide -- the last {type = "guide"} message
local region -- the open tab
local selected -- { name, tier }

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Fishing, data)
    end
end

local function typeLabel(name)
    return TYPE_LABELS[name] or (name:sub(1, 1):upper() .. name:sub(2))
end

local REGION_TABS = { 'kanto', 'orange', 'hoenn', 'johto' }

local function regionName(key)
    for _, r in ipairs(guide.regions or {}) do
        if r.key == key then
            return r.name
        end
    end
    return key
end

-- the tier's Pokemon in a region: Kanto's everywhere, then the region's own
local function poolOf(tier, key)
    local list = {}
    for _, name in ipairs((tier.pools or {}).kanto or {}) do
        list[#list + 1] = { name = name, regional = false }
    end
    if key ~= 'kanto' then
        for _, name in ipairs((tier.pools or {})[key] or {}) do
            list[#list + 1] = { name = name, regional = true }
        end
    end
    return list
end

local function infoOf(name)
    return (guide.pokemon or {})[name] or {}
end

-- the portraits are 96x96 with the Pokemon in the middle; inset trims the empty border
local function setPortrait(widget, name, inset)
    local number = tonumber(infoOf(name).number) or 0
    widget:setImageSource(PORTRAITS .. number)
    widget:setImageClip({ x = inset, y = inset, width = 96 - 2 * inset, height = 96 - 2 * inset })
end

-- Selected and skill panels -----------------------------------------------------------------------

local function refreshSelected()
    local panel = window.selected
    if not selected then
        panel.portrait:setImageSource('')
        panel.name:setText(tr('Pick a Pokemon'))
        panel.badges:destroyChildren()
        panel.details:setText(tr('Click a portrait in the list to see when and where it bites.'))
        return
    end
    local info, tier = infoOf(selected.name), selected.tier
    setPortrait(panel.portrait, selected.name, 14)
    panel.name:setText(selected.name)
    panel.badges:destroyChildren()
    for _, t in ipairs(info.types or {}) do
        local badge = g_ui.createWidget('FishingBadge', panel.badges)
        badge:setText(tr(typeLabel(t)):upper())
        badge:setImageColor(TYPE_COLORS[t] or '#8899aa')
    end
    local lines = {
        tr('Bites from skill %d', tier.skill),
        tr('Your Pokemon: level %d+', tier.minLevel),
        tr('Rods: %s', (table.concat(tier.rods or {}, ', '):gsub(' Rod', ''))),
        selected.regional and tr('Only in %s', regionName(region)) or tr('In every region'),
        tr('Caught %d, defeated %d', tonumber(info.caught) or 0, tonumber(info.defeated) or 0),
    }
    panel.details:setText(table.concat(lines, '\n'))
end

local function refreshSkill()
    local panel = window.skill
    local skill = tonumber(guide.skill) or 0
    local progress = math.max(0, math.min(1, tonumber(guide.progress) or 0))
    panel.value:setText(tr('Skill %d -> %d  (%d%%)', skill, skill + 1, math.floor(progress * 100)))
    local width = math.floor(panel.track:getWidth() * progress)
    panel.track.fill:setWidth(width)
    panel.track.fill:setVisible(width >= 6)
    local nextTier
    for _, tier in ipairs(guide.tiers or {}) do
        if tier.skill > skill and #poolOf(tier, region) > 0 then
            nextTier = tier
            break
        end
    end
    if nextTier then
        local names = {}
        for _, entry in ipairs(poolOf(nextTier, region)) do
            names[#names + 1] = entry.name
        end
        panel.nextUnlock:setText(tr('Next: %s at skill %d', table.concat(names, ', '), nextTier.skill))
    else
        panel.nextUnlock:setText(tr('Everything here can bite for you.'))
    end
end

local function refreshRods()
    local list = window.rods.list
    list:destroyChildren()
    local skill = tonumber(guide.skill) or 0
    for _, rod in ipairs(guide.rods or {}) do
        local row = g_ui.createWidget('FishingRodRow', list)
        row.item:setItemId(tonumber(rod.client) or 0)
        row.name:setText(tr('%s - skill %d', tr(rod.name), rod.skill))
        local usable = skill >= rod.skill and (not rod.anglerOnly or (guide.rank or 0) >= (guide.cranesRank or 5))
        row.name:setColor(usable and '#dce6ff' or LOCKED_COLOR)
        row.tag:setVisible(rod.anglerOnly == true)
        if rod.anglerOnly then
            row.tag:setText(tr('Rank %d', guide.cranesRank or 5))
            row.tag:setTooltip(tr('Only Master Anglers (rank %d) can fish with cranes.', guide.cranesRank or 5))
        end
    end
end

-- Tier list ---------------------------------------------------------------------------------------

local function select(name, regional, tier)
    selected = { name = name, regional = regional, tier = tier }
    for _, row in ipairs(window.list:getChildren()) do
        row:setChecked(row.tier == tier)
    end
    refreshSelected()
end

local function refreshList()
    local list = window.list
    list:destroyChildren()
    local skill = tonumber(guide.skill) or 0
    local keep
    for _, tier in ipairs(guide.tiers or {}) do
        local pool = poolOf(tier, region)
        if #pool > 0 then
            local row = g_ui.createWidget('FishingTierRow', list)
            row.tier = tier
            local open = tier.skill <= skill
            row:setOn(not open)
            row.skill:setText(tr('Skill %d', tier.skill))
            row.levels:setText(tr('Pokemon Lv %d-%d', tier.minLevel, tier.maxLevel))
            row:setTooltip(tr('Bites while your Pokemon is level %d or higher. Above level %d this tier stops biting once %d higher tiers are open.',
                tier.minLevel, tier.maxLevel, guide.top or 7))
            row.state:setText(open and tr('Can hook now') or tr('Needs skill %d', tier.skill))
            row.state:setColor(open and OK_COLOR or LOCKED_COLOR)
            row.check:setVisible(open)
            row.lock:setVisible(not open)
            for _, entry in ipairs(pool) do
                local cell = g_ui.createWidget('FishingPortrait', row.pokemon)
                setPortrait(cell.portrait, entry.name, 18)
                cell:setOn(entry.regional)
                cell:setTooltip(entry.name .. (entry.regional and (' (' .. tr('only in %s', regionName(region)) .. ')') or ''))
                cell.onClick = function() select(entry.name, entry.regional, tier) end
                if selected and selected.name == entry.name and selected.tier.skill == tier.skill then
                    keep = { entry, tier }
                end
            end
            row.onClick = function() select(pool[1].name, pool[1].regional, tier) end
        end
    end
    if keep then
        select(keep[1].name, keep[1].regional, keep[2])
    else
        selected = nil
        refreshSelected()
    end
end

local function refreshTabs()
    for _, key in ipairs(REGION_TABS) do
        local tab = window.tabs[key]
        tab:setText(regionName(key))
        tab:setOn(region == key)
        tab.pin:setVisible(guide.region == key)
        tab:setTooltip(guide.region == key and tr('You are here') or '')
    end
end

local function showRegion(key)
    region = key
    refreshTabs()
    refreshList()
    refreshSkill()
end

-- Window ------------------------------------------------------------------------------------------

function hide()
    if window then
        window:hide()
    end
    if button then
        button:setOn(false)
    end
end

local function show()
    local root = rootWidget:getSize()
    if not window:isVisible() then
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                             y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
    end
    window:show()
    window:raise()
    window:focus()
    if button then
        button:setOn(true)
    end
end

function toggle()
    if window:isVisible() then
        hide()
    elseif (status.rank or 0) < (status.guideRank or 0) then
        modules.game_textmessage.displayFailureMessage(tr('The fishing guide is for Anglers from rank %d.', status.guideRank))
    else
        send({ action = 'open' })
    end
end

local function fill(data)
    guide = data
    window.subtitle:setText(tr('%s, rank %d', data.title or '', data.rank or 0) .. '  \183  ' ..
        tr('Fishing skill %d', data.skill or 0))
    refreshRods()
    if not region or not window:isVisible() then
        region = data.region or 'kanto'
    end
    showRegion(region)
end

local function onFishing(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Fishing guide: invalid message')
        return
    end
    if data.type == 'status' then
        status = { enabled = data.enabled == true, rank = tonumber(data.rank) or 0, guideRank = tonumber(data.guideRank) or 0 }
        if button then
            button:setVisible(status.enabled)
        end
        if not status.enabled then
            hide()
        end
    elseif data.type == 'guide' then
        fill(data)
        show()
    elseif data.type == 'error' and data.text then
        modules.game_textmessage.displayFailureMessage(data.text)
    end
end

local function onGameStart()
    send({ action = 'hello' })
end

local function onGameEnd()
    status = { enabled = false }
    guide, region, selected = nil, nil, nil
    if button then
        button:setVisible(false)
    end
    hide()
end

function init()
    g_ui.importStyle('fishing')
    window = g_ui.createWidget('FishingWindow', rootWidget)
    window:hide()
    for _, key in ipairs(REGION_TABS) do
        window.tabs[key].onClick = function()
            if guide then
                showRegion(key)
            end
        end
    end

    button = modules.client_topmenu.addRightGameToggleButton('fishingButton', tr('Fishing guide (U)'),
        IMAGES .. 'button_fishing', toggle)
    button:setVisible(false)
    modules.game_vocation.registerTool('fishing', {
        enabled = function() return status.enabled and (status.rank or 0) >= (status.guideRank or 0) end,
        toggle = toggle
    })

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Fishing, onFishing)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    modules.game_vocation.unregisterTool('fishing')
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Fishing)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    for _, widget in ipairs({ button, window }) do
        if widget then
            widget:destroy()
        end
    end
    button, window = nil, nil
end
