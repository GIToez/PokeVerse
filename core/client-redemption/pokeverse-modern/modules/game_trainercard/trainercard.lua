-- The Trainer Card window. The server (TrainerCard in the server lib) sends {type = "card", ...} on
-- ExtendedIds.TrainerCard for {action = "open", name} (no name: your own card); see the server file for
-- every field. Other trainers' cards show the buttons View Trophies, Add to VIP, Trade, Message and Duel.
-- Your own card is always editable: the favorite and the trophies come from {action = "candidates"},
-- the title from {action = "titles"}, and Save sends {action = "save", favorite, trophies, title, about,
-- privacy}. Preview as Others shows it the way other trainers see it.
-- Opens from the top bar (your card), by right-clicking a trainer, and when the server answers the
-- Pokedex used on a trainer.
local IMAGES = '/modules/game_trainercard/images/'
local SCENES = IMAGES .. 'scenes/'
local MUTED_COLOR = '#96aacd'
local ERROR_COLOR = '#ff8a80'
local OK_COLOR = '#6fe08a'
local MESSAGE_MS = 4000
local WALK_MS = 30
local TILE = 64 -- the scene is the map at 2x
local WALK_SPEED = 2.2 -- px per WALK_MS
local PRIVACY = { playTime = 1, stats = 2, trophies = 4 }
local TABS = { 'overview', 'trophies', 'achievements', 'pokedex' }

local window, button
local card -- the last {type = "card"}
local draft -- own card: { favorite, trophies = {keys}, title, titleText, about, privacy }
local candidates -- own Pokemon for the picker, by key
local picking -- nil, 'favorite' or 'trophies'
local pickerSelection
local previewing = false
local tab = 'overview'
local walkEvent, messageEvent
local walkX = 0
local achievementsFor

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.TrainerCard, data)
    end
end

local function center(widget)
    local root = rootWidget:getSize()
    widget:show()
    widget:setPosition({ x = math.floor((root.width - widget:getWidth()) / 2),
                         y = math.max(0, math.floor((root.height - widget:getHeight()) / 2)) })
    widget:raise()
    widget:focus()
end

local function editing()
    return card and card.own and not previewing
end

-- The preview shows the unsaved changes too
local function drafted()
    return card and card.own and draft ~= nil
end

local function formatNumber(n)
    local text = tostring(math.floor(tonumber(n) or 0))
    local out = text:reverse():gsub('(%d%d%d)', '%1,'):reverse()
    return (out:gsub('^,', ''))
end

local function setSex(widget, sex, big)
    if sex == 'male' or sex == 'female' then
        widget:setImageSource(IMAGES .. 'sex_' .. sex .. (big and '_big' or ''))
        widget:show()
    else
        widget:hide()
    end
end

local function setPortrait(widget, pokemon)
    if pokemon and pokemon.number then
        widget:setImageSource('/images/staticPortraits/' .. pokemon.number)
        widget:show()
    else
        widget:hide()
    end
end

local function trophyKeys()
    if drafted() then
        return draft.trophies
    end
    local keys = {}
    for _, trophy in ipairs(card.trophies or {}) do
        keys[#keys + 1] = trophy.key
    end
    return keys
end

local function pokemonByKey(key)
    if not key or key == '' then
        return nil
    end
    if candidates and candidates[key] then
        return candidates[key]
    end
    if card.favorite and card.favorite.key == key then
        return card.favorite
    end
    for _, trophy in ipairs(card.trophies or {}) do
        if trophy.key == key then
            return trophy
        end
    end
    local name, level, sex = key:match('^([^|]+)|(%d+)|(%d+)$')
    if name then
        return { key = key, name = name, level = tonumber(level), sex = sex == '0' and 'female' or (sex == '1' and 'male' or nil) }
    end
end

local function showMessage(text, ok)
    removeEvent(messageEvent)
    window.subtitle:setText(text)
    window.subtitle:setColor(ok and OK_COLOR or ERROR_COLOR)
    messageEvent = scheduleEvent(function()
        messageEvent = nil
        if window and card then
            window.subtitle:setColor(MUTED_COLOR)
            fillHeader()
        end
    end, MESSAGE_MS)
end

-- Scene ------------------------------------------------------------------------------------------

local function sizeCreature(widget)
    local creature = widget:getCreature()
    local size = creature and creature:getExactSize() or 32
    size = math.max(32, math.min(96, size)) * 2
    widget:setSize({ width = size, height = size })
end

local function placeWalkers()
    local scene = window.left.scene
    local bottom = scene:getHeight() - 8
    local trainer, pokemon = scene.trainer, scene.pokemon
    trainer:setMarginLeft(math.floor(walkX + TILE - trainer:getWidth()))
    trainer:setMarginTop(bottom - trainer:getHeight())
    pokemon:setMarginLeft(math.floor(walkX - TILE + TILE - pokemon:getWidth()))
    pokemon:setMarginTop(bottom - pokemon:getHeight())
end

local function walk()
    walkX = walkX + WALK_SPEED
    if walkX > window.left.scene:getWidth() + TILE * 2 then
        walkX = -TILE
    end
    placeWalkers()
end

local function stopWalking()
    removeEvent(walkEvent)
    walkEvent = nil
end

local function fillScene()
    local scene = window.left.scene
    local town = card.town and tonumber(card.town.id) or 0
    local path = SCENES .. town
    if not g_resources.fileExists(path .. '.png') then
        path = SCENES .. 'default'
    end
    scene:setImageSource(path)
    scene.trainer:setOutfit(card.outfit or {})
    scene.trainer:setDirection(Directions and Directions.East or 1)
    sizeCreature(scene.trainer)
    local favorite = drafted() and pokemonByKey(draft.favorite) or card.favorite
    if favorite and favorite.look then
        scene.pokemon:setOutfit({ type = favorite.look })
        scene.pokemon:setDirection(Directions and Directions.East or 1)
        sizeCreature(scene.pokemon)
        scene.pokemon:show()
    else
        scene.pokemon:hide()
    end
    for _, widget in ipairs({ scene.trainer, scene.pokemon }) do
        local creature = widget:getCreature()
        if creature then
            creature:setStaticWalking(1000)
        end
    end
    scene.shield:setVisible(card.vocation ~= nil)
    scene.shield.rank:setText(card.vocation and tostring(card.vocation.rank) or '')
    stopWalking()
    walkX = -TILE
    placeWalkers()
    walkEvent = cycleEvent(walk, WALK_MS)
end

-- Overview ---------------------------------------------------------------------------------------

function fillHeader()
    if card.own then
        window.subtitle:setText(previewing and tr('Preview: how other trainers see your card') or
            tr('Your card  \183  click a pencil to change it'))
    else
        window.subtitle:setText(tr('Looking at another trainer'))
    end
end

local function infoRow(parent, icon, label, value, color)
    local row = g_ui.createWidget('TcInfoRow', parent)
    row.icon:setImageSource(IMAGES .. 'icon_' .. icon)
    row.label:setText(label)
    row.value:setText(value)
    if color then
        row.value:setColor(color)
    end
    return row
end

local function fillInfo()
    local panel = window.right.infoPanel
    panel.col1:destroyChildren()
    panel.col2:destroyChildren()
    infoRow(panel.col1, 'level', tr('Trainer level'), tr('Lv. %d', card.level or 0), '#ffd75a')
    infoRow(panel.col1, 'home', tr('Hometown'), card.town and card.town.name ~= '' and card.town.name or '-')
    local guild = card.guild and (card.guild .. (card.guildRank and card.guildRank ~= '' and ('  (' .. card.guildRank .. ')') or '')) or tr('None')
    infoRow(panel.col1, 'guild', tr('Guild'), guild, card.guild and '#c58cff' or MUTED_COLOR)
    infoRow(panel.col1, 'mastery', tr('Mastery'), card.mastery or tr('None'), card.mastery and '#ff8a3d' or MUTED_COLOR)
    local hiddenTime = card.playTime == nil or (previewing and (card.privacy or 0) % 2 == 1)
    infoRow(panel.col2, 'clock', tr('Play time'), hiddenTime and tr('Hidden') or
        tr('%s hours', formatNumber((card.playTime or 0) / 3600)), hiddenTime and MUTED_COLOR or nil)
    local since = tonumber(card.since) or 0
    infoRow(panel.col2, 'calendar', tr('Trainer since'), since > 0 and os.date('%b %d, %Y', since) or '-')
    local duels = card.duels or {}
    infoRow(panel.col2, 'duel', tr('Duels'), tr('%s won  \183  %s lost', formatNumber(duels.won), formatNumber(duels.lost)), '#ffd75a')
    infoRow(panel.col2, 'respect', tr('Respect'), formatNumber(card.respect), '#ff6f91')
end

local badgeRegion = 1 -- the region the badge row shows; Kanto when the card opens

local function fillBadges()
    local panel = window.right.badgesPanel
    panel.list:destroyChildren()
    local regions = card.badges or {}
    local earned, total = 0, 0
    for _, region in ipairs(regions) do
        for _, badge in ipairs(region.list or {}) do
            total = total + 1
            earned = earned + (badge.earned and 1 or 0)
        end
    end
    panel.count:setText(string.format('%d / %d', earned, total))
    panel.prev:setVisible(#regions > 1)
    panel.next:setVisible(#regions > 1)
    badgeRegion = math.max(1, math.min(badgeRegion, #regions))
    local region = regions[badgeRegion]
    if not region then
        panel.region:setText('')
        return
    end
    local list = region.list or {}
    local regionEarned = 0
    for _, badge in ipairs(list) do
        regionEarned = regionEarned + (badge.earned and 1 or 0)
    end
    panel.region:setText(string.format('%s  \183  %d / %d', region.region or '', regionEarned, #list))
    local size, gap = 40, 14
    local width = panel.list:getWidth()
    local step = math.min(size + gap, #list > 1 and math.floor((width - size) / (#list - 1)) or 0)
    local left = math.floor((width - (size + step * (#list - 1))) / 2)
    for i, badge in ipairs(list) do
        local slot = g_ui.createWidget('TcBadgeSlot', panel.list)
        slot:addAnchor(AnchorTop, 'parent', AnchorTop)
        slot:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        slot:setMarginLeft(left + (i - 1) * step)
        if badge.upcoming then
            slot.item:setVisible(false)
            slot:setIcon(IMAGES .. 'icon_lock')
            slot:setIconRect({ x = 12, y = 12, width = 16, height = 16 })
            slot:setOpacity(0.5)
            slot:setTooltip(tr('%s Badge  (coming soon)', badge.name or ''))
        else
            slot.item:setItemId(tonumber(badge.client) or 0)
            slot:setTooltip(tr('%s Badge', badge.name or '') .. (badge.earned and '' or ('  (' .. tr('not earned yet') .. ')')))
            if badge.earned then
                slot:setImageSource(IMAGES .. 'slot_on')
            else
                slot.item:setOpacity(0.35)
            end
        end
    end
end

function showBadgeRegion(step)
    local count = card and #(card.badges or {}) or 0
    if count == 0 then
        return
    end
    badgeRegion = (badgeRegion - 1 + step) % count + 1
    fillBadges()
end

local function fillTrophies()
    local panel = window.right.trophiesPanel
    panel.list:destroyChildren()
    local edit = editing()
    panel.edit:setVisible(edit)
    panel.note:setVisible(not edit)
    local hidden = not edit and (card.trophies == nil or (previewing and math.floor((card.privacy or 0) / 4) % 2 == 1))
    local keys = hidden and {} or trophyKeys()
    local width = panel.list:getWidth()
    local cell = math.floor((width - 5 * 8) / 6)
    local shown = edit and math.min(6, #keys + 1) or #keys
    for i = 1, shown do
        local tile = g_ui.createWidget('TcTrophy', panel.list)
        tile:setWidth(cell)
        tile:addAnchor(AnchorTop, 'parent', AnchorTop)
        tile:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        tile:setMarginLeft((i - 1) * (cell + 8))
        local pokemon = pokemonByKey(keys[i])
        if pokemon then
            setPortrait(tile.portrait, pokemon)
            tile.level:setText(tr('Lv. %d', pokemon.level or 0))
            setSex(tile.sex, pokemon.sex)
            tile.name:setText(pokemon.name or '')
            tile:setTooltip(pokemon.name or '')
            if edit then
                tile.remove:show()
                tile.remove.onClick = function()
                    table.remove(draft.trophies, i)
                    fillTrophies()
                end
                tile.onClick = function() pickTrophies() end
            else
                tile.onClick = function() showTab('trophies') end
            end
        else
            tile:setImageSource(IMAGES .. 'slot_add')
            tile.portrait:hide()
            tile.sex:hide()
            tile.add:show()
            tile.addText:show()
            tile.onClick = function() pickTrophies() end
        end
    end
    panel.empty:setVisible(shown == 0)
    panel.empty:setText(hidden and tr('Hidden by the trainer') or tr('No trophies picked yet'))
end

local STAT_ROWS = {
    { 'ball', 'Pokemon caught', function(s) return formatNumber(s.caught) end },
    { 'dex', 'Pokedex', function(s) return string.format('%s / %s', formatNumber(s.dex), formatNumber(s.dexTotal)) end },
    { 'shiny', 'Shinies caught', function(s) return formatNumber(s.shinies) end },
    { 'cup', 'Tournaments won', function(s) return formatNumber(s.tournaments) end },
    { 'medal', 'Achievements', function(s) return string.format('%s / %s', formatNumber(s.achievements), formatNumber(s.achievementsTotal)) end },
    { 'trainer', 'Trainers defeated', function(s) return formatNumber(s.trainers) end },
}

local function statsHidden()
    return card.stats == nil or (previewing and math.floor((card.privacy or 0) / 2) % 2 == 1)
end

local function fillStats()
    local panel = window.right.statsPanel
    panel.col1:destroyChildren()
    panel.col2:destroyChildren()
    local hidden = statsHidden()
    panel.hidden:setVisible(hidden)
    if hidden then
        return
    end
    for i, row in ipairs(STAT_ROWS) do
        local widget = g_ui.createWidget('TcStatRow', i <= 3 and panel.col1 or panel.col2)
        widget.icon:setImageSource(IMAGES .. 'icon_' .. row[1])
        widget.label:setText(tr(row[2]))
        widget.value:setText(row[3](card.stats))
    end
end

local function aboutText()
    if drafted() then
        return draft.about or ''
    end
    return card.about or ''
end

local function fillAbout()
    local panel = window.right.aboutPanel
    local edit = editing()
    local text = aboutText()
    panel.edit:setVisible(edit and not panel.field:isVisible())
    if not panel.field:isVisible() then
        panel.text:setText(text ~= '' and text or (edit and tr('Tell other trainers about yourself.') or tr('Nothing here yet.')))
        panel.text:setColor(text ~= '' and '#dce6ff' or MUTED_COLOR)
        panel.footer:setText(edit and tr('%d / %d letters', #text, 160) or (text ~= '' and tr('Written by the trainer') or ''))
    end
end

local function fillLeft()
    local left = window.left
    left.namePlate.name:setText((card.name or ''):upper())
    setSex(left.namePlate.sex, card.sex, true)
    local edit = editing()
    left.title:setText(drafted() and draft.titleText or card.title or '')
    left.title:setEnabled(edit)
    left.title.chevron:setVisible(edit)
    if card.vocation then
        left.vocation:setText(tr('%s  \183  rank %d of %d', card.vocation.name or '', card.vocation.rank or 1,
            card.vocation.maxRank or 5))
    else
        left.vocation:setText(tr('No vocation yet'))
    end
    local panel = left.favoritePanel
    panel.edit:setVisible(edit)
    local favorite = drafted() and pokemonByKey(draft.favorite) or card.favorite
    if drafted() and not draft.favorite then
        favorite = card.favorite
    end
    panel.empty:setVisible(favorite == nil)
    panel.creature:setVisible(favorite ~= nil and favorite.look ~= nil)
    panel.name:setVisible(favorite ~= nil)
    panel.detail:setVisible(favorite ~= nil)
    panel.sex:setVisible(false)
    if favorite then
        if favorite.look then
            panel.creature:setOutfit({ type = favorite.look })
            panel.creature:setDirection(Directions and Directions.South or 2)
        end
        panel.name:setText(favorite.name or '')
        setSex(panel.sex, favorite.sex)
        local types = favorite.types and #favorite.types > 0 and ('  \183  ' .. table.concat(favorite.types, ' / ')) or ''
        panel.detail:setText(tr('Lv. %d', favorite.level or 0) .. types)
    end
end

-- Buttons ----------------------------------------------------------------------------------------

local function addButton(style, text, icon, onClick)
    local widget = g_ui.createWidget(style, window.buttons)
    widget:setText(text)
    if icon then
        widget:setIcon(IMAGES .. 'icon_' .. icon)
        widget:setIconAlign(AlignLeftCenter)
        widget:setIconOffsetX(12)
    end
    widget.onClick = onClick
    return widget
end

local function layoutButtons()
    local list = window.buttons:getChildren()
    local gap = 10
    local width = math.floor((window.buttons:getWidth() - gap * (#list - 1)) / math.max(1, #list))
    for i, widget in ipairs(list) do
        widget:addAnchor(AnchorTop, 'parent', AnchorTop)
        widget:addAnchor(AnchorBottom, 'parent', AnchorBottom)
        widget:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        widget:setWidth(width)
        widget:setMarginLeft((i - 1) * (width + gap))
    end
end

local function fillButtons()
    window.buttons:destroyChildren()
    local name = card.name
    if not card.own then
        addButton('PVGreenButton', tr('View Trophies'), 'trophy', function() showTab('trophies') end)
        local player = g_game.getLocalPlayer()
        local vip = addButton('TcButton', tr('Add to VIP'), 'vip', function()
            g_game.addVip(name)
            showMessage(tr('%s is on your VIP list.', name), true)
        end)
        if player and player:hasVip(name) then
            vip:setEnabled(false)
            vip:setTooltip(tr('Already on your VIP list'))
        end
        addButton('TcButton', tr('Trade'), 'trade', function()
            showMessage(tr('Right-click an item and choose "Trade with ...", then click %s.', name), true)
        end)
        addButton('TcButton', tr('Message'), 'message', function()
            g_game.openPrivateChannel(name)
        end)
        addButton('TcButton', tr('Duel'), 'swords', function()
            send({ action = 'duel', name = name })
        end)
    elseif previewing then
        addButton('PVGreenButton', tr('Back to editing'), 'pencil', function() setPreview(false) end)
    else
        addButton('TcButton', tr('Change Outfit'), 'outfit', function() g_game.requestOutfit() end)
        addButton('TcButton', tr('Privacy'), 'lock', function() choosePrivacy() end)
        addButton('TcButton', tr('Preview as Others'), 'eye', function() setPreview(true) end)
        addButton('PVRedButton', tr('Cancel'), 'cancel', function() close() end)
        addButton('PVGreenButton', tr('Save'), 'save', function() save() end)
    end
    layoutButtons()
end

-- Tabs -------------------------------------------------------------------------------------------

local function fillTrophiesTab()
    local panel = window.trophiesTab
    panel.heading:setText(card.own and tr('Your trophy Pokemon') or tr('%s\'s trophy Pokemon', card.name or ''))
    panel.list:destroyChildren()
    local keys = trophyKeys()
    if not card.own and card.trophies == nil then
        keys = {}
    end
    for _, key in ipairs(keys) do
        local pokemon = pokemonByKey(key)
        if pokemon then
            local tile = g_ui.createWidget('TcBigTrophy', panel.list)
            setPortrait(tile.portrait, pokemon)
            tile.name:setText(pokemon.name or '')
            setSex(tile.sex, pokemon.sex, true)
            tile.level:setText(tr('Level %d', pokemon.level or 0))
            tile.types:setText(pokemon.types and table.concat(pokemon.types, ' / ') or '')
            tile.shiny:setVisible(pokemon.shiny == true)
        end
    end
    local hidden = not card.own and card.trophies == nil
    panel.empty:setVisible(#panel.list:getChildren() == 0)
    panel.empty:setText(hidden and tr('Hidden by the trainer') or tr('No trophies picked yet'))
end

local function fillPokedexTab()
    local panel = window.pokedexTab
    panel.heading:setText(card.own and tr('Your Pokedex') or tr('%s\'s Pokedex', card.name or ''))
    panel.list:destroyChildren()
    local hidden = statsHidden()
    panel.empty:setVisible(hidden)
    panel.empty:setText(tr('Hidden by the trainer'))
    if hidden then
        return
    end
    local s = card.stats
    local rows = {
        { 'dex', tr('Registered in the Pokedex'), string.format('%s / %s', formatNumber(s.dex), formatNumber(s.dexTotal)) },
        { 'ball', tr('Pokemon caught'), formatNumber(s.caught) },
        { 'level', tr('Different species caught'), formatNumber(s.unique) },
        { 'shiny', tr('Shinies caught'), formatNumber(s.shinies) },
        { 'cup', tr('Tournaments won'), formatNumber(s.tournaments) },
        { 'trainer', tr('Trainers defeated'), formatNumber(s.trainers) },
    }
    for _, row in ipairs(rows) do
        local tile = g_ui.createWidget('TcBigStat', panel.list)
        tile.icon:setImageSource(IMAGES .. 'icon_' .. row[1])
        tile.label:setText(row[2])
        tile.value:setText(row[3])
    end
end

local function fillAchievements(data)
    local panel = window.achievementsTab
    panel.heading:setText(card.own and tr('Your achievements') or tr('%s\'s achievements', data.name or ''))
    panel.count:setText(string.format('%s / %s', formatNumber(data.earned), formatNumber(data.total)))
    panel.list:destroyChildren()
    for _, entry in ipairs(data.list or {}) do
        local row = g_ui.createWidget('TcAchievement', panel.list)
        row.name:setText(entry.name or '')
        row.description:setText(entry.description or '')
    end
    panel.empty:setVisible(#(data.list or {}) == 0)
    panel.empty:setText(tr('No achievements yet'))
end

function showTab(id)
    tab = id
    for _, name in ipairs(TABS) do
        window.tabs[name]:setChecked(name == id)
    end
    local overview = id == 'overview'
    window.left:setVisible(overview)
    window.right:setVisible(overview)
    window.trophiesTab:setVisible(id == 'trophies')
    window.achievementsTab:setVisible(id == 'achievements')
    window.pokedexTab:setVisible(id == 'pokedex')
    if id == 'trophies' then
        fillTrophiesTab()
    elseif id == 'pokedex' then
        fillPokedexTab()
    elseif id == 'achievements' and achievementsFor ~= card.name then
        window.achievementsTab.list:destroyChildren()
        window.achievementsTab.empty:setText(tr('Loading...'))
        window.achievementsTab.empty:show()
        send({ action = 'achievements', name = not card.own and card.name or nil })
    end
end

local function layoutTabs()
    local gap = 8
    local width = math.floor((window.tabs:getWidth() - gap * (#TABS - 1)) / #TABS)
    for _, name in ipairs(TABS) do
        window.tabs[name]:setWidth(width)
    end
end

-- Filling ----------------------------------------------------------------------------------------

local function fill()
    fillHeader()
    fillLeft()
    fillScene()
    fillInfo()
    fillBadges()
    fillTrophies()
    fillStats()
    fillAbout()
    fillButtons()
    if tab ~= 'overview' then
        showTab(tab)
    end
end

local function startDraft()
    draft = { favorite = card.favorite and not card.favorite.default and card.favorite.key or nil, trophies = {},
              title = card.titleKey or '', titleText = card.title, about = card.about or '', privacy = card.privacy or 0 }
    for _, trophy in ipairs(card.trophies or {}) do
        draft.trophies[#draft.trophies + 1] = trophy.key
    end
end

local function onCard(data)
    local sameCard = card and window:isVisible() and card.name == data.name
    card = data
    if not sameCard then
        previewing = false
        candidates = nil
        achievementsFor = nil
        tab = 'overview'
        badgeRegion = 1
        closePicker()
        window.right.aboutPanel.field:hide()
    end
    if card.own then
        startDraft()
    else
        draft = nil
    end
    if not window:isVisible() then
        center(window)
        layoutTabs()
    end
    showTab(tab)
    -- sizes are known once the window is laid out
    scheduleEvent(function()
        if window and window:isVisible() and card == data then
            fill()
        end
    end, 30)
end

-- Editing ----------------------------------------------------------------------------------------

function setPreview(on)
    previewing = on and true or false
    if previewing then
        closePicker()
        window.right.aboutPanel.field:hide()
    end
    fill()
end

function editAbout()
    local panel = window.right.aboutPanel
    panel.field:setText(draft.about or '')
    panel.field:show()
    panel.text:hide()
    panel.edit:hide()
    panel.field:focus()
    onAboutChange()
end

function onAboutChange()
    local panel = window.right.aboutPanel
    if not panel.field:isVisible() or not draft then
        return
    end
    local text = panel.field:getText()
    draft.about = text
    panel.footer:setText(tr('%d / %d letters', #text, 160))
end

local function finishAbout()
    local panel = window.right.aboutPanel
    if panel.field:isVisible() then
        draft.about = panel.field:getText()
        panel.field:hide()
        panel.text:show()
    end
end

function chooseTitle()
    if not editing() then
        return
    end
    send({ action = 'titles' })
end

local function showTitles(list)
    if not editing() then
        return
    end
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addText(tr('Displayed title'))
    local group
    local shown = 0
    for _, entry in ipairs(list) do
        if entry.group ~= group then
            group = entry.group
            menu:addSeparator()
            menu:addText(group == 'vocation' and tr('Vocation') or tr('Achievements'))
        end
        if shown < 40 then
            local text = entry.text .. (entry.detail and entry.detail ~= '' and ('  -  ' .. entry.detail) or '')
            if entry.key == draft.title then
                text = '> ' .. text
            end
            menu:addOption(text, function()
                draft.title, draft.titleText = entry.key, entry.text
                fillLeft()
            end)
            shown = shown + 1
        end
    end
    if #list == 0 then
        menu:addText(tr('Earn titles with your vocation and achievements.'))
    end
    local title = window.left.title
    menu:display({ x = title:getX(), y = title:getY() + title:getHeight() })
end

function choosePrivacy()
    if not editing() then
        return
    end
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addText(tr('Hide from other trainers'))
    local options = { { 'playTime', tr('Play time') }, { 'stats', tr('Statistics and Pokedex') }, { 'trophies', tr('Trophy Pokemon') } }
    for _, option in ipairs(options) do
        local flag = PRIVACY[option[1]]
        local on = math.floor((draft.privacy or 0) / flag) % 2 == 1
        menu:addCheckBox(option[2], on, function(_, checked)
            local value = draft.privacy or 0
            if checked and not on then
                value = value + flag
            elseif not checked and on then
                value = value - flag
            end
            draft.privacy = value
            card.privacy = value
            showMessage(tr('Privacy changes take effect when you save.'), true)
        end)
    end
    menu:display(g_window.getMousePosition())
end

function save()
    if not editing() then
        return
    end
    finishAbout()
    send({ action = 'save', favorite = draft.favorite or '', trophies = draft.trophies, title = draft.title or '',
           about = draft.about or '', privacy = draft.privacy or 0 })
end

-- Picker -----------------------------------------------------------------------------------------

local function refreshPicker()
    local picker = window.picker
    for _, widget in ipairs(picker.list:getChildren()) do
        local key = widget.key
        local index
        for i, k in ipairs(pickerSelection) do
            if k == key then
                index = i
            end
        end
        widget:setChecked(index ~= nil)
        widget.order:setVisible(picking == 'trophies' and index ~= nil)
        widget.order:setText(index and tostring(index) or '')
    end
    local hint
    if picking == 'trophies' then
        hint = tr('Pick up to 6 Pokemon in the order they should show (%d / 6). Click again to remove one.',
            #pickerSelection)
    else
        hint = tr('It walks with you on your card.')
    end
    if candidates and candidates.more then
        hint = hint .. ' ' .. tr('From the PC, only your highest-level Pokemon are listed.')
    end
    picker.hint:setText(hint)
end

local function fillPicker()
    local picker = window.picker
    picker.list:destroyChildren()
    local list = candidates and candidates.list or {}
    for _, pokemon in ipairs(list) do
        local widget = g_ui.createWidget('TcCandidate', picker.list)
        widget.key = pokemon.key
        setPortrait(widget.portrait, pokemon)
        widget.name:setText(pokemon.name or '')
        widget.detail:setText(tr('Lv. %d', pokemon.level or 0) .. '  \183  ' ..
            (pokemon.where == 'pc' and tr('PC') or tr('With you')))
        setSex(widget.sex, pokemon.sex)
        widget.onClick = function()
            if picking == 'favorite' then
                pickerSelection = { pokemon.key }
            else
                for i, k in ipairs(pickerSelection) do
                    if k == pokemon.key then
                        table.remove(pickerSelection, i)
                        refreshPicker()
                        return
                    end
                end
                if #pickerSelection < 6 then
                    pickerSelection[#pickerSelection + 1] = pokemon.key
                end
            end
            refreshPicker()
        end
    end
    picker.empty:setVisible(candidates ~= nil and #list == 0)
    picker.empty:setText(candidates and tr('You have no Pokemon yet.') or tr('Loading...'))
    if not candidates then
        picker.empty:show()
    end
    refreshPicker()
end

local function openPicker(kind)
    if not editing() then
        return
    end
    finishAbout()
    picking = kind
    if kind == 'favorite' then
        pickerSelection = { draft.favorite }
        window.picker.heading:setText(tr('Choose your favorite Pokemon'))
    else
        pickerSelection = {}
        for _, key in ipairs(draft.trophies) do
            pickerSelection[#pickerSelection + 1] = key
        end
        window.picker.heading:setText(tr('Choose your trophy Pokemon'))
    end
    window.picker:show()
    window.picker:raise()
    fillPicker()
    if not candidates then
        send({ action = 'candidates' })
    end
end

function pickFavorite()
    openPicker('favorite')
end

function pickTrophies()
    openPicker('trophies')
end

function closePicker()
    picking = nil
    if window then
        window.picker:hide()
    end
end

function pickerDone()
    if picking == 'favorite' then
        draft.favorite = pickerSelection[1]
    elseif picking == 'trophies' then
        draft.trophies = pickerSelection
    end
    closePicker()
    fillLeft()
    fillScene()
    fillTrophies()
end

-- Opening ----------------------------------------------------------------------------------------

function open(name)
    send({ action = 'open', name = name })
end

function close()
    stopWalking()
    closePicker()
    if window then
        window:hide()
    end
end

function toggle()
    if window:isVisible() then
        close()
    else
        open()
    end
end

local function onMessage(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Trainer Card: invalid message')
        return
    end
    if data.type == 'card' then
        onCard(data)
    elseif data.type == 'titles' and window:isVisible() then
        showTitles(data.list or {})
    elseif data.type == 'candidates' then
        candidates = { list = data.list or {}, more = data.more }
        for _, pokemon in ipairs(candidates.list) do
            candidates[pokemon.key] = pokemon
        end
        if picking then
            fillPicker()
        end
    elseif data.type == 'achievements' and window:isVisible() and card then
        achievementsFor = card.name
        fillAchievements(data)
    elseif data.type == 'result' and data.text and window:isVisible() then
        showMessage(data.text, data.ok)
    end
end

local function hello()
    send({ action = 'hello' })
end

local function onGameEnd()
    close()
    card, draft, candidates = nil, nil, nil
    removeEvent(messageEvent)
    messageEvent = nil
end

local function menuCondition(menuPosition, lookThing, useThing, creatureThing)
    return creatureThing ~= nil and creatureThing:isPlayer()
end

local function menuOpen(menuPosition, lookThing, useThing, creatureThing)
    if creatureThing:isLocalPlayer() then
        open()
    else
        open(creatureThing:getName())
    end
end

function init()
    g_ui.importStyle('trainercard')
    window = g_ui.createWidget('TrainerCardWindow', rootWidget)
    window:hide()
    button = modules.client_topmenu.addRightGameToggleButton('trainerCardButton', tr('Trainer Card'),
        IMAGES .. 'button_trainercard', toggle)
    ProtocolGame.registerExtendedOpcode(ExtendedIds.TrainerCard, onMessage)
    connect(g_game, { onGameStart = hello, onGameEnd = onGameEnd })
    if modules.game_interface and modules.game_interface.addMenuHook then
        modules.game_interface.addMenuHook('trainercard', tr('Trainer Card'), menuOpen, menuCondition)
    end
    if g_game.isOnline() then
        hello()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.TrainerCard)
    disconnect(g_game, { onGameStart = hello, onGameEnd = onGameEnd })
    if modules.game_interface and modules.game_interface.removeMenuHook then
        modules.game_interface.removeMenuHook('trainercard')
    end
    stopWalking()
    removeEvent(messageEvent)
    if window then
        window:destroy()
        window = nil
    end
    if button then
        button:destroy()
        button = nil
    end
end
