-- PokeVerse additions to Redemption's character list (characterlist.lua): character cards,
-- the detail panel, the create card, and creating (with the outfit) and deleting characters
-- through the account service.

local DEFAULT_COLORS = { head = 78, body = 68, legs = 58, feet = 76 }
local COLOR_COUNT = 133 -- 19 x 7, server MAX_OUTFIT_COLOR + 1
local AREAS_SETTING = 'pokeverse-last-areas'
local FRAME_SIZE = { width = 780, height = 476 }
local SCREEN_MARGIN = 8

local charactersWindow
local createCharacterWindow
local creation -- the outfit being made in the create window
local session -- the character in game and when it entered
local updatePreview

local function widget(id)
    return charactersWindow and charactersWindow:recursiveGetChildById(id)
end

local function maxCharacters()
    local account = G.characterAccount or {}
    return account.maxCharacters or 3
end

local function genderIcon(sex)
    return sex == 0 and '/modules/client_entergame/images/icon_female' or '/modules/client_entergame/images/icon_male'
end

local function formatPlayTime(seconds)
    seconds = tonumber(seconds) or 0
    local hours, minutes = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60)
    if hours > 0 then
        return tr('%dh %dm', hours, minutes)
    end
    return tr('%dm', minutes)
end

local function formatLastLogin(timestamp)
    timestamp = tonumber(timestamp) or 0
    if timestamp <= 0 then
        return tr('Never')
    end
    if os.date('%Y', timestamp) == os.date('%Y') then
        return os.date('%b %d, %H:%M', timestamp)
    end
    return os.date('%b %d, %Y', timestamp)
end

-- The area the character was last in (saved by the client), else its home town.
local function location(characterInfo)
    local areas = g_settings.getNode(AREAS_SETTING) or {}
    local area = areas[characterInfo.name]
    if area and area ~= '' then
        return area
    end
    return characterInfo.town or ''
end

-- Called by game_environment when the area name changes in game.
function CharacterList.setCurrentArea(text)
    local name = g_game.isOnline() and g_game.getCharacterName()
    if not name or name == '' or not text or text == '' then
        return
    end
    local areas = g_settings.getNode(AREAS_SETTING) or {}
    if areas[name] ~= text then
        areas[name] = text
        g_settings.setNode(AREAS_SETTING, areas)
        g_settings.save()
    end
end

-- Back from the game the list is the one sent at login, so the played character's card is
-- brought up to date here instead of asking the server again.
function CharacterList.onSessionStart()
    session = { name = g_game.getCharacterName(), start = os.time() }
end

function CharacterList.onSessionEnd()
    local played = session
    session = nil
    local list = played and widget('characters')
    if not list then
        return
    end
    for _, card in ipairs(list:getChildren()) do
        local info = card.characterInfo
        if info and info.name == played.name then
            info.lastLogin = played.start
            info.playTime = (tonumber(info.playTime) or 0) + os.time() - played.start
            CharacterList.onCharacterWidget(card, info)
            if list:getFocusedChild() == card then
                CharacterList.onCharacterFocus(card)
            end
        end
    end
end

local function setParty(slots, team)
    for i, slot in ipairs(slots) do
        local pokemon = team and team[i]
        local picture = slot:getChildById('picture')
        if pokemon then
            picture:setImageSource('/images/pictures/' .. pokemon.number)
            slot:setTooltip(pokemon.description)
        else
            picture:setImageSource('')
            slot:setTooltip('')
        end
    end
end

function CharacterList.layoutFrame()
    if CharacterList.layoutCreateWindow then
        CharacterList.layoutCreateWindow()
    end
    if not charactersWindow then
        return
    end
    local root = g_ui.getRootWidget()
    widget('frame'):setSize({ width = math.min(FRAME_SIZE.width, root:getWidth() - 2 * SCREEN_MARGIN),
                              height = math.min(FRAME_SIZE.height, root:getHeight() - 2 * SCREEN_MARGIN) })
end

function CharacterList.onCharacterWidget(card, characterInfo)
    card:setBackgroundColor('alpha')
    card:getChildById('genderIcon'):setImageSource(genderIcon(characterInfo.sex))
    local town = card:getChildById('town')
    town:setText(location(characterInfo))
    town:setVisible(town:getText() ~= '')
    local slots = {}
    for i = 1, 6 do
        slots[i] = card:getChildById('party' .. i)
    end
    setParty(slots, characterInfo.pokemonTeam)
end

function CharacterList.onCharactersRebuilt(list, characters, focusLabel)
    if #characters >= maxCharacters() then
        return focusLabel
    end
    local card = g_ui.createWidget('CreateCharacterCard', list)
    card.createCard = true
    card:getChildById('slots'):setText(tr('%d of %d slots used', #characters, maxCharacters()))
    card.onClick = function()
        list:focusChild(card, MouseFocusReason)
        CharacterList.showCreateCharacter()
        return true
    end
    return focusLabel or card
end

function CharacterList.onCharacterFocus(card)
    if not card or not card:getParent() then
        return
    end
    -- the focus moves while Redemption builds a new window, before onCreate
    charactersWindow = card:getParent():getParent()
    local info = card.characterInfo
    for _, id in ipairs({ 'portrait', 'detailOutfit', 'detailName', 'detailGender', 'detailLevel', 'detailLocation',
                          'detailPlayTime', 'detailLastLogin', 'partySeparator', 'partyCaption', 'partyGrid' }) do
        widget(id):setVisible(info ~= nil)
    end
    widget('emptyCaption'):setVisible(info == nil)
    widget('deleteButton'):setEnabled(info ~= nil)
    widget('playButton'):setText(info and tr('Play') or tr('Create'))
    if not info then
        return
    end

    widget('detailOutfit'):setOutfit(info.outfit)
    widget('detailName'):setText(info.name)
    widget('detailGender'):setImageSource(genderIcon(info.sex))
    local rows = {
        { 'detailLevel', 'icon_level', tr('Level:'), tostring(info.level or 0) },
        { 'detailLocation', 'icon_location', tr('Location:'), location(info) },
        { 'detailPlayTime', 'icon_playtime', tr('Playtime:'), formatPlayTime(info.playTime) },
        { 'detailLastLogin', 'icon_lastlogin', tr('Last Login:'), formatLastLogin(info.lastLogin) },
    }
    for _, row in ipairs(rows) do
        local w = widget(row[1])
        w:getChildById('icon'):setImageSource('/modules/client_entergame/images/' .. row[2])
        w:getChildById('caption'):setText(row[3])
        w:getChildById('value'):setText(row[4])
    end

    local grid = widget('partyGrid')
    if grid:getChildCount() == 0 then
        for i = 1, 6 do
            g_ui.createWidget('PVPartySlot', grid)
        end
    end
    setParty(grid:getChildren(), info.pokemonTeam)
end

function CharacterList.onCreate(window)
    charactersWindow = window
    if G.motdMessage then
        g_settings.set('pokeverse-motd', G.motdMessage)
    end
    CharacterList.layoutFrame()
    connect(window, { onKeyPress = function(self, keyCode)
        local list = self:getChildById('characters')
        if keyCode == KeyUp then
            list:focusPreviousChild(KeyboardFocusReason)
            return true
        elseif keyCode == KeyDown then
            list:focusNextChild(KeyboardFocusReason)
            return true
        end
        return false
    end })
    local list = window:getChildById('characters')
    CharacterList.onCharacterFocus(list:getFocusedChild())
end

-- Logs in again for the updated character list, with focusName selected.
local function refreshCharacters(focusName)
    if focusName then
        g_settings.set('last-used-character', focusName)
    end
    EnterGame.loginAccount(G.account, G.password)
end

-- create character ------------------------------------------------------------------------

-- Palette ids: column 0 is grey (light to dark), columns 1-18 step the hue by 20 degrees,
-- rows 0-6 go from pale to dark (outfit color table, getOutfitColor).
local COLOR_PARTS = {
    { part = 'head', row = 'headRow', icon = 'icon_hair', caption = 'Hair Color',
      presets = { 114, 116, 115, 41, 77, 57, 0 } },
    { part = 'body', row = 'bodyRow', icon = 'icon_shirt', caption = 'Primary Color',
      presets = { 94, 88, 82, 79, 89, 114, 0 } },
    { part = 'legs', row = 'legsRow', icon = 'icon_pants', caption = 'Secondary Color',
      presets = { 126, 57, 114, 132, 120, 116, 0 } },
    { part = 'feet', row = 'feetRow', icon = 'icon_shoes', caption = 'Accent Color',
      presets = { 94, 88, 79, 82, 89, 92, 0 } },
}

local colorPalette

local function createChild(id)
    return createCharacterWindow:recursiveGetChildById(id)
end

local function creationOutfits()
    local outfits = {}
    for _, outfit in ipairs((G.characterAccount or {}).starterOutfits or {}) do
        if outfit.sex == creation.sex then
            table.insert(outfits, outfit)
        end
    end
    if #outfits == 0 then
        -- an older server without the starter outfit list: the server picks the outfit
        table.insert(outfits, { type = creation.sex == 0 and 611 or 612, name = tr('Trainer'), fallback = true })
    end
    return outfits
end

local function creationOutfit(lookType)
    return { type = lookType, head = creation.head, body = creation.body, legs = creation.legs,
             feet = creation.feet, addons = 0 }
end

-- The worlds this account can create characters on: the login server's own world and any world
-- its characters are on.
local function creationWorlds()
    local worlds, seen = {}, {}
    local function add(name)
        if name and name ~= '' and not seen[name] then
            seen[name] = true
            table.insert(worlds, name)
        end
    end
    add((G.characterAccount or {}).serverName)
    for _, character in ipairs(G.characters or {}) do
        add(character.worldName)
    end
    return worlds
end

local function hideColorPalette()
    if colorPalette then
        colorPalette:destroy()
        colorPalette = nil
    end
end

local function hasDefaultColors()
    for part, color in pairs(DEFAULT_COLORS) do
        if creation[part] ~= color then
            return false
        end
    end
    return true
end

local function summaryValues(outfits)
    local server = createChild('serverComboBox'):getText()
    local name = createChild('nameTextEdit'):getText():trim()
    return {
        { tr('Server:'), server ~= '' and server or '-' },
        { tr('Name:'), name ~= '' and name or '-' },
        { tr('Gender:'), creation.sex == 0 and tr('Female') or tr('Male') },
        { tr('Outfit:'), tr('%s (%d / %d)', outfits[creation.outfitIndex].name, creation.outfitIndex, #outfits) },
        { tr('Colors:'), hasDefaultColors() and tr('Default') or tr('Custom') },
    }
end

function CharacterList.updateCreateSummary()
    if not createCharacterWindow then
        return
    end
    local rows = createChild('summaryRows')
    local values = summaryValues(creationOutfits())
    if rows:getChildCount() == 0 then
        for _ = 1, #values do
            g_ui.createWidget('PVSummaryRow', rows)
        end
    end
    for i, row in ipairs(rows:getChildren()) do
        row:getChildById('caption'):setText(values[i][1])
        row:getChildById('value'):setText(values[i][2])
    end
end

local function updateOutfitStrip(outfits)
    local thumbs, dots = createChild('outfitThumbs'), createChild('outfitDots')
    if thumbs:getChildCount() ~= #outfits then
        thumbs:destroyChildren()
        dots:destroyChildren()
        for i = 1, #outfits do
            local thumb = g_ui.createWidget('PVOutfitThumb', thumbs)
            thumb.onClick = function()
                creation.outfitIndex = i
                updatePreview()
            end
            g_ui.createWidget('PVDot', dots)
        end
        thumbs:setWidth(#outfits * 56 + (#outfits - 1) * 8)
        dots:setWidth(#outfits * 8 + (#outfits - 1) * 6)
    end
    for i, thumb in ipairs(thumbs:getChildren()) do
        thumb:getChildById('creature'):setOutfit(creationOutfit(outfits[i].type))
        thumb:setTooltip(outfits[i].name)
        thumb:setChecked(i == creation.outfitIndex)
        dots:getChildByIndex(i):setOn(i == creation.outfitIndex)
    end
    createChild('outfitCount'):setText(tr('Outfit %d / %d', creation.outfitIndex, #outfits))
    createChild('previousOutfit'):setEnabled(#outfits > 1)
    createChild('nextOutfit'):setEnabled(#outfits > 1)
end

local function updateColorRows()
    for _, info in ipairs(COLOR_PARTS) do
        local current = createChild(info.row):getChildById('swatches'):getChildByIndex(1)
        current:setBackgroundColor(getOutfitColor(creation[info.part]))
    end
end

updatePreview = function()
    local outfits = creationOutfits()
    creation.outfitIndex = math.max(1, math.min(creation.outfitIndex, #outfits))
    local current = outfits[creation.outfitIndex]
    local preview = createChild('preview')
    preview:setOutfit(creationOutfit(current.type))
    preview:setDirection(creation.direction)
    createChild('summaryOutfit'):setOutfit(creationOutfit(current.type))
    createChild('maleButton'):setOn(creation.sex == 1)
    createChild('femaleButton'):setOn(creation.sex == 0)
    updateOutfitStrip(outfits)
    updateColorRows()
    CharacterList.updateCreateSummary()
end

local function setColor(part, color)
    creation[part] = color
    hideColorPalette()
    updatePreview()
end

local function showColorPalette(part, anchor)
    hideColorPalette()
    colorPalette = g_ui.createWidget('PVColorPalette', g_ui.getRootWidget())
    for id = 0, COLOR_COUNT - 1 do
        local cell = g_ui.createWidget('PVSwatch', colorPalette)
        cell:setBackgroundColor(getOutfitColor(id))
        cell:setChecked(id == creation[part])
        cell.onClick = function()
            setColor(part, id)
        end
    end
    local root = g_ui.getRootWidget()
    local pos = anchor:getPosition()
    colorPalette:setPosition({
        x = math.max(0, math.min(pos.x + anchor:getWidth() - colorPalette:getWidth(), root:getWidth() - colorPalette:getWidth())),
        y = math.max(0, math.min(pos.y + anchor:getHeight() + 4, root:getHeight() - colorPalette:getHeight())),
    })
    colorPalette:raise()
    colorPalette:focus()
    colorPalette.onFocusChange = function(self, focused)
        if not focused then
            scheduleEvent(hideColorPalette, 1)
        end
    end
    colorPalette.onEscape = hideColorPalette
end

local function buildColorRows()
    for _, info in ipairs(COLOR_PARTS) do
        local row = createChild(info.row)
        local caption = row:getChildById('caption')
        caption:setText(tr(info.caption))
        caption:setIcon('/modules/client_entergame/images/' .. info.icon)
        local swatches = row:getChildById('swatches')
        local current = g_ui.createWidget('PVSwatch', swatches)
        current:setTooltip(tr('Current color'))
        current:setChecked(true)
        current.onClick = function()
            showColorPalette(info.part, current)
        end
        for _, id in ipairs(info.presets) do
            local swatch = g_ui.createWidget('PVSwatch', swatches)
            swatch:setBackgroundColor(getOutfitColor(id))
            swatch.onClick = function()
                setColor(info.part, id)
            end
        end
        local more = g_ui.createWidget('PVMoreSwatch', swatches)
        more.onClick = function()
            showColorPalette(info.part, more)
        end
    end
end

local CREATE_SIZE = { width = 760, height = 540 }
local PORTRAIT_HEIGHT = 704

local function anchor(id, anchors)
    local w = createChild(id)
    w:breakAnchors()
    for _, a in ipairs(anchors) do
        w:addAnchor(a[1], a[2], a[3])
    end
    return w
end

-- The window as designed (wide), with the summary dropped and the server and gender rows inline on
-- short screens (phone landscape), or as one column on narrow ones (phone portrait).
-- screen defaults to the root widget's size.
function CharacterList.layoutCreateWindow(screen)
    if not createCharacterWindow then
        return
    end
    screen = screen or g_ui.getRootWidget():getSize()
    local portrait = screen.width < CREATE_SIZE.width + 2 * SCREEN_MARGIN
    local short = not portrait and screen.height < CREATE_SIZE.height + 2 * SCREEN_MARGIN
    local padding = (portrait or short) and 16 or 26
    createCharacterWindow:setPadding(padding)
    createCharacterWindow:setSize({
        width = math.min(CREATE_SIZE.width, screen.width - 2 * SCREEN_MARGIN),
        height = portrait and math.min(PORTRAIT_HEIGHT, screen.height - 2 * SCREEN_MARGIN)
            or math.min(CREATE_SIZE.height, screen.height - 2 * SCREEN_MARGIN),
    })

    local stage = anchor('stage', portrait and {
        { AnchorTop, 'titleSeparator', AnchorBottom }, { AnchorLeft, 'parent', AnchorLeft },
        { AnchorRight, 'parent', AnchorRight },
    } or { { AnchorTop, 'titleSeparator', AnchorBottom }, { AnchorLeft, 'parent', AnchorLeft } })
    stage:setMarginTop(portrait and 8 or 12)
    stage:setHeight((portrait or short) and 150 or 200)
    if not portrait then
        stage:setWidth(296)
    end
    createChild('summary'):setVisible(not portrait and not short)

    local inline = short or portrait
    local server = anchor('serverSection', portrait and {
        { AnchorTop, 'outfitCount', AnchorBottom }, { AnchorLeft, 'parent', AnchorLeft },
        { AnchorRight, 'parent', AnchorRight },
    } or { { AnchorTop, 'stage', AnchorTop }, { AnchorLeft, 'stage', AnchorRight }, { AnchorRight, 'parent', AnchorRight } })
    server:setMarginTop(portrait and 10 or 0)
    server:setMarginLeft(portrait and 0 or 16)
    server:setHeight(inline and 50 or 66)
    anchor('serverTitle', inline and { { AnchorLeft, 'parent', AnchorLeft }, { AnchorVerticalCenter, 'parent', AnchorVerticalCenter } }
        or { { AnchorTop, 'parent', AnchorTop }, { AnchorLeft, 'parent', AnchorLeft } })
    local combo = anchor('serverComboBox', {
        { AnchorLeft, 'parent', AnchorLeft }, { AnchorRight, 'serverSignal', AnchorLeft },
        { AnchorBottom, 'parent', AnchorBottom } })
    combo:setMarginLeft(inline and 90 or 0)
    combo:setMarginRight(12)

    createChild('nameSection'):setHeight(short and 71 or 89)
    createChild('nameHint'):setVisible(not short)

    createChild('genderSection'):setHeight(inline and 50 or 72)
    anchor('genderTitle', inline and { { AnchorLeft, 'parent', AnchorLeft }, { AnchorVerticalCenter, 'parent', AnchorVerticalCenter } }
        or { { AnchorTop, 'parent', AnchorTop }, { AnchorLeft, 'parent', AnchorLeft } })
    -- inline, the buttons share the space right of the 90px title around its middle (center + 45)
    local male = anchor('maleButton', { { AnchorLeft, 'parent', AnchorLeft }, { AnchorRight, 'parent', AnchorHorizontalCenter },
                                        { AnchorBottom, 'parent', AnchorBottom } })
    male:setMarginLeft(inline and 90 or 0)
    male:setMarginRight(inline and -40 or 5)
    local female = anchor('femaleButton', { { AnchorLeft, 'parent', AnchorHorizontalCenter }, { AnchorRight, 'parent', AnchorRight },
                                            { AnchorBottom, 'parent', AnchorBottom } })
    female:setMarginLeft(inline and 50 or 5)

    local colors = anchor('colorSection', short and {
        { AnchorTop, 'genderSection', AnchorBottom }, { AnchorLeft, 'serverSection', AnchorLeft },
        { AnchorRight, 'serverSection', AnchorRight }, { AnchorBottom, 'parent', AnchorBottom },
    } or { { AnchorTop, 'genderSection', AnchorBottom }, { AnchorLeft, 'serverSection', AnchorLeft },
           { AnchorRight, 'serverSection', AnchorRight }, { AnchorBottom, 'createButton', AnchorTop } })
    colors:setMarginBottom(short and 0 or 12)
    -- narrow rows tighten the swatches so the longest caption still fits
    local spacing = portrait and 4 or 7
    for _, color in ipairs(COLOR_PARTS) do
        local swatches = createChild(color.row):getChildById('swatches')
        swatches:getLayout():setSpacing(spacing)
        swatches:setWidth(swatches:getChildCount() * (20 + spacing) - spacing)
    end

    -- on short screens the buttons take the summary's place under the outfits
    anchor('createButton', { { AnchorBottom, 'parent', AnchorBottom },
                             { AnchorLeft, short and 'stage' or 'serverSection', AnchorLeft },
                             { AnchorRight, 'cancelButton', AnchorLeft } })
    anchor('cancelButton', { { AnchorBottom, 'parent', AnchorBottom },
                             { AnchorRight, short and 'stage' or 'parent', AnchorRight } })
    createChild('cancelButton'):setWidth(short and 96 or 120)
end

function CharacterList.showCreateCharacter()
    if not createCharacterWindow then
        createCharacterWindow = g_ui.displayUI('createcharacter')
        creation = { sex = 1, outfitIndex = 1, direction = Directions.South }
        for part, color in pairs(DEFAULT_COLORS) do
            creation[part] = color
        end
        local servers = createChild('serverComboBox')
        for _, world in ipairs(creationWorlds()) do
            servers:addOption(world)
        end
        servers:setEnabled(#servers.options > 1)
        buildColorRows()
        updatePreview()
    end
    CharacterList.layoutCreateWindow()
    if charactersWindow then
        charactersWindow:hide()
    end
    createCharacterWindow:show()
    createCharacterWindow:raise()
    createCharacterWindow:focus()
    createChild('nameTextEdit'):focus()
end

function CharacterList.hideCreateCharacter()
    hideColorPalette()
    if createCharacterWindow then
        createCharacterWindow:destroy()
        createCharacterWindow = nil
    end
    CharacterList.show()
end

function CharacterList.setCreateSex(sex)
    if creation.sex ~= sex then
        creation.sex = sex
        creation.outfitIndex = 1
        updatePreview()
    end
end

function CharacterList.changeOutfit(step)
    local count = #creationOutfits()
    creation.outfitIndex = (creation.outfitIndex - 1 + step) % count + 1
    updatePreview()
end

function CharacterList.turnPreview(step)
    creation.direction = (creation.direction + step) % 4
    updatePreview()
end

function CharacterList.randomColors()
    for part in pairs(DEFAULT_COLORS) do
        creation[part] = math.random(0, COLOR_COUNT - 1)
    end
    updatePreview()
end

function CharacterList.doCreateCharacter()
    hideColorPalette()
    local name = createChild('nameTextEdit'):getText():trim()
    local outfit = creationOutfits()[creation.outfitIndex]
    createCharacterWindow:hide()

    EnterGame.accountRequest({ action = AccountRequestCreateCharacter, account = G.account, password = G.password,
                               name = name, sex = creation.sex,
                               outfit = not outfit.fallback and { type = outfit.type, head = creation.head,
                                   body = creation.body, legs = creation.legs, feet = creation.feet } or nil },
        function(success, message)
            if not message then
                CharacterList.showCreateCharacter()
            elseif not success then
                connect(displayErrorBox(tr('Create Character'), message), { onOk = CharacterList.showCreateCharacter })
            else
                createCharacterWindow:destroy()
                createCharacterWindow = nil
                connect(displayInfoBox(tr('Create Character'), message), { onOk = function() refreshCharacters(name) end })
            end
        end)
end

-- delete character ------------------------------------------------------------------------

function CharacterList.deleteCharacter()
    local list = charactersWindow and charactersWindow:getChildById('characters')
    local selected = list and list:getFocusedChild()
    if not selected or selected.createCard then
        return
    end

    local name = selected.characterName
    local confirmBox
    local function cancel()
        confirmBox:destroy()
        CharacterList.show()
    end
    local function confirm()
        confirmBox:destroy()
        EnterGame.accountRequest({ action = AccountRequestDeleteCharacter, account = G.account, password = G.password,
                                   name = name },
            function(success, message)
                if not message then
                    CharacterList.show()
                elseif not success then
                    connect(displayErrorBox(tr('Delete Character'), message), { onOk = CharacterList.show })
                else
                    connect(displayInfoBox(tr('Delete Character'), message), { onOk = function() refreshCharacters() end })
                end
            end)
    end

    charactersWindow:hide()
    confirmBox = displayGeneralBox(tr('Delete Character'),
        tr('Do you really want to delete %s?\nThis cannot be undone.', name),
        { { text = tr('Yes'), callback = confirm }, { text = tr('No'), callback = cancel }, anchor = AnchorHorizontalCenter },
        nil, cancel)
end
