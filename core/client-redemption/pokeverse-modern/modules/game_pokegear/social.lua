-- Social (docs/concepts/side-panel/social-window.jpg): Friends, Guild, Party and Blocked in one
-- Pokegear window. In Pokegear it takes the VIP window's place: the Friends orb and the VIP key open
-- it, and the VIP window stays hidden. Friends are the VIP list; the server (systems/100-social.lua,
-- ExtendedIds.Social) adds levels, where friends are, the guild roster and the party. Blocked is
-- game_console's ignore list.
local POSITION_SETTING = 'pokegearSocialPosition'
local TAB_SETTING = 'pokegearSocialTab'
local KEY = { 'Windows', 'Show/hide VIP list' }
local REFRESH_MS = 3000
local NEAR_TILES = 60
local TABS = { 'friends', 'guild', 'party', 'blocked' }
local TRAINER_ICONS = '/modules/game_trainercard/images/icon_'

local window, restorePosition, refreshEvent
local active = false
local tab = 'friends'
local data = { friends = {}, guild = nil, party = nil }
local vipHidden, vipWasOpen, startedAt = false, false, 0
local adding = false

Social = {}

local function send(message)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Social, message)
    end
end

local function vipIds()
    local ids = {}
    for id in pairs(g_game.getVips() or {}) do
        ids[#ids + 1] = id
    end
    return ids
end

local function request()
    send({ action = 'refresh', friends = vipIds() })
end

local function console()
    return modules.game_console
end

local function blockedList()
    local c = console()
    return c and c.getIgnoredPlayers and c.getIgnoredPlayers() or {}
end

local function localPlayer()
    return g_game.getLocalPlayer()
end

local function myName()
    return g_game.getCharacterName() or ''
end

local function initials(name)
    local letters = {}
    for word in name:gmatch('%S+') do
        letters[#letters + 1] = word:sub(1, 1):upper()
        if #letters == 2 then
            break
        end
    end
    if #letters == 1 then
        letters[2] = name:sub(2, 2):upper()
    end
    return table.concat(letters)
end

local function placeName(pos)
    local environment = modules.game_environment
    local name = environment and environment.getAreaNameAt and environment.getAreaNameAt(pos) or ''
    if name == '' then
        local map = modules.game_minimap and modules.game_minimap.PokeverseMap
        name = map and map.regionAt and map.regionAt(pos) or ''
        name = name:gsub('^%l', string.upper)
    end
    return name ~= '' and tr(name) or ''
end

-- "12 tiles away" when on screen-ish range, else the place name
local function whereText(pos, preferDistance)
    if type(pos) ~= 'table' or not pos.x then
        return ''
    end
    local player = localPlayer()
    local mine = player and player:getPosition()
    if preferDistance and mine and mine.z == pos.z then
        local tiles = math.max(math.abs(mine.x - pos.x), math.abs(mine.y - pos.y))
        if tiles <= NEAR_TILES then
            return tiles == 1 and tr('1 tile away') or tr('%d tiles away', tiles)
        end
    end
    return placeName(pos)
end

local function lastSeenText(stamp)
    stamp = tonumber(stamp) or 0
    if stamp <= 0 then
        return tr('Offline')
    end
    local seconds = math.max(0, os.time() - stamp)
    if seconds < 3600 then
        return tr('Last seen %d minutes ago', math.max(1, math.floor(seconds / 60)))
    elseif seconds < 86400 then
        local hours = math.floor(seconds / 3600)
        return hours == 1 and tr('Last seen an hour ago') or tr('Last seen %d hours ago', hours)
    end
    local days = math.floor(seconds / 86400)
    return days == 1 and tr('Last seen yesterday') or tr('Last seen %d days ago', days)
end

local function join(parts)
    local out = {}
    for _, part in ipairs(parts) do
        if part and part ~= '' then
            out[#out + 1] = part
        end
    end
    return table.concat(out, '  \183  ')
end

local function openCard(name)
    local card = modules.game_trainercard
    if card and card.open then
        card.open(name)
    end
end

local function askDuel(name)
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedJSONOpcode(ExtendedIds.TrainerCard, { action = 'duel', name = name })
    end
end

local function message(name)
    g_game.openPrivateChannel(name)
end

local function block(name)
    local c = console()
    if c and c.addIgnoredPlayer then
        c.addIgnoredPlayer(name)
        c.saveCommunicationSettings()
    end
end

local function unblock(name)
    local c = console()
    if c and c.removeIgnoredPlayer then
        c.removeIgnoredPlayer(name)
        c.saveCommunicationSettings()
    end
end

local function isBlocked(name)
    local c = console()
    return c and c.isIgnored and c.isIgnored(name) or false
end

-- the shield the server shows over us says whether we lead the party and share its experience
local function partyShield()
    local player = localPlayer()
    return player and player:getShield() or ShieldNone
end

local function isLeader()
    local shield = partyShield()
    return shield == ShieldYellow or shield == ShieldYellowSharedExp or shield == ShieldYellowNoSharedExp
        or shield == ShieldYellowNoSharedExpBlink
end

local function isSharing()
    local shield = partyShield()
    return shield == ShieldYellowSharedExp or shield == ShieldBlueSharedExp
        or shield == ShieldYellowNoSharedExpBlink or shield == ShieldBlueNoSharedExpBlink
end

local function visiblePlayers()
    local player = localPlayer()
    if not player then
        return {}
    end
    local list = {}
    for _, creature in ipairs(g_map.getSpectators(player:getPosition(), false)) do
        if creature:isPlayer() and not creature:isLocalPlayer() then
            list[#list + 1] = creature
        end
    end
    table.sort(list, function(a, b) return a:getName():lower() < b:getName():lower() end)
    return list
end

local refresh

local function addIcon(row, icon, tooltip, onClick)
    local button = g_ui.createWidget('PokegearSocialIcon', row.buttons)
    button.icon:setImageSource(TRAINER_ICONS .. icon)
    button:setTooltip(tooltip)
    button.onClick = onClick
    row.buttons:setWidth(#row.buttons:getChildren() * 25 - 3)
    return button
end

local function addRow(name, detail, outfit, online)
    local row = g_ui.createWidget('PokegearSocialRow', window.list)
    row.name:setText(name)
    row.detail:setText(detail or '')
    row.dot:setVisible(online == true)
    local shown = type(outfit) == 'table' and tonumber(outfit.type) and tonumber(outfit.type) > 0
    row.face.creature:setVisible(shown)
    row.face.initials:setText(shown and '' or initials(name))
    if shown then
        row.face.creature:setOutfit({ type = outfit.type, head = outfit.head or 0, body = outfit.body or 0,
            legs = outfit.legs or 0, feet = outfit.feet or 0, addons = outfit.addons or 0 })
    end
    return row
end

local function addGroup(text)
    local label = g_ui.createWidget('PokegearSocialGroup', window.list)
    label:setText(text)
    return label
end

local function addAction(text, onClick, gold)
    local button = g_ui.createWidget('PokegearSocialAction', window.footer)
    button:setText(text)
    button:setOn(gold == true)
    button:setWidth(button:getTextSize().width + 26)
    button.onClick = onClick
    return button
end

local function rowMenu(name, extra)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(tr('Message'), function() message(name) end)
    menu:addOption(tr('Trainer card'), function() openCard(name) end)
    menu:addOption(tr('Ask for a duel'), function() askDuel(name) end)
    for _, option in ipairs(extra or {}) do
        menu:addOption(option[1], option[2])
    end
    menu:addSeparator()
    if isBlocked(name) then
        menu:addOption(tr('Unblock'), function() unblock(name) refresh() end)
    else
        menu:addOption(tr('Block'), function() block(name) refresh() end)
    end
    menu:display()
end

local function onRowPress(name, extra)
    return function(widget, mousePos, button)
        if button == MouseRightButton then
            rowMenu(name, extra)
            return true
        end
    end
end

-- Friends

local function friendDetail(friend)
    if not friend.online then
        return lastSeenText(friend.lastSeen)
    end
    return join({ tr('Lv %d', tonumber(friend.level) or 0), whereText(friend.pos, false),
        friend.dueling and tr('in a duel') or nil })
end

local function friendsList()
    local byName = {}
    for _, friend in ipairs(data.friends) do
        byName[friend.name:lower()] = friend
    end
    local list = {}
    for id, vip in pairs(g_game.getVips() or {}) do
        local name, state = vip[1], vip[2]
        local friend = byName[name:lower()] or { name = name }
        friend.id = id
        if byName[name:lower()] == nil then
            friend.online = state == VipState.Online
        end
        list[#list + 1] = friend
    end
    table.sort(list, function(a, b)
        if (a.online == true) ~= (b.online == true) then
            return a.online == true
        end
        return a.name:lower() < b.name:lower()
    end)
    return list
end

local function fillFriends()
    local filter = window.search:getText():lower()
    local list, online, offline = friendsList(), {}, {}
    for _, friend in ipairs(list) do
        if filter == '' or friend.name:lower():find(filter, 1, true) then
            table.insert(friend.online and online or offline, friend)
        end
    end
    local function addFriend(friend)
        local row = addRow(friend.name, friendDetail(friend), friend.outfit, friend.online)
        addIcon(row, 'message', tr('Message %s', friend.name), function() message(friend.name) end)
        if friend.online then
            addIcon(row, 'swords', tr('Ask %s for a duel (stand within 7 tiles)', friend.name),
                function() askDuel(friend.name) end)
        end
        row.onMousePress = onRowPress(friend.name, {
            { tr('Remove friend'), function() g_game.removeVip(friend.id) scheduleEvent(refresh, 200) end },
        })
        row.onDoubleClick = function() openCard(friend.name) end
    end
    if #online > 0 then
        addGroup(tr('ONLINE - %d', #online))
        for _, friend in ipairs(online) do
            addFriend(friend)
        end
    end
    if #offline > 0 then
        addGroup(tr('OFFLINE - %d', #offline))
        for _, friend in ipairs(offline) do
            addFriend(friend)
        end
    end
    if #list == 0 then
        window.empty:setText(tr('No friends yet. Add a trainer by name, or right-click one and choose Add to VIP.'))
    elseif #online + #offline == 0 then
        window.empty:setText(tr('Nobody matches "%s".', window.search:getText()))
    end
    window.empty:setVisible(#online + #offline == 0)
    addAction(tr('+ Add friend'), function() Social.startAdding('friend') end, true)
end

-- Guild

local function fillGuild()
    local guild = data.guild
    if not guild then
        window.empty:setText(tr('You are not in a guild.'))
        window.empty:setVisible(true)
        window.banner:hide()
        return
    end
    local online = 0
    for _, member in ipairs(guild.members or {}) do
        if member.online then
            online = online + 1
        end
    end
    window.banner.name:setText(guild.name or '')
    window.banner.detail:setText(join({ tr('%d members', #(guild.members or {})), tr('%d online', online),
        guild.rank and guild.rank ~= '' and tr('you are a %s', guild.rank) or nil }))
    local lastRank
    for _, member in ipairs(guild.members or {}) do
        if member.rank ~= lastRank then
            lastRank = member.rank
            addGroup((member.rank or ''):upper())
        end
        local detail = member.online and join({ tr('Lv %d', tonumber(member.level) or 0), whereText(member.pos, false) })
            or join({ tr('Lv %d', tonumber(member.level) or 0), tr('Offline') })
        local row = addRow(member.name, detail, member.outfit, member.online)
        if member.name ~= myName() then
            addIcon(row, 'message', tr('Message %s', member.name), function() message(member.name) end)
            row.onMousePress = onRowPress(member.name)
        end
        row.onDoubleClick = function() openCard(member.name) end
    end
    addAction(tr('Guild chat'), function() g_game.joinChannel(0) end)
    local leave = addAction(tr('Leave'), function()
        local box
        box = displayGeneralBox(tr('Leave guild'), tr('Leave %s?', guild.name or ''), {
            { text = tr('Leave'), callback = function() box:destroy() send({ action = 'leaveGuild' }) end },
            { text = tr('Cancel'), callback = function() box:destroy() end },
        })
    end)
    if (tonumber(guild.level) or 0) >= 3 then
        leave:setEnabled(false)
        leave:setTooltip(tr('The leader passes the leadership on or disbands the guild first.'))
    end
end

-- Party

local function inviteMenu()
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    local count = 0
    for _, creature in ipairs(visiblePlayers()) do
        local shield = creature:getShield()
        if shield == ShieldNone or shield == ShieldWhiteBlue then
            local id = creature:getId()
            menu:addOption(creature:getName(), function() g_game.partyInvite(id) end)
            count = count + 1
        end
    end
    if count == 0 then
        menu:addOption(tr('Nobody nearby to invite'), function() end)
    end
    menu:display()
end

local function fillParty()
    local party = data.party
    local invites = {}
    for _, creature in ipairs(visiblePlayers()) do
        if creature:getShield() == ShieldWhiteYellow then
            invites[#invites + 1] = creature
        end
    end
    if #invites > 0 then
        addGroup(tr('INVITES - %d', #invites))
        for _, creature in ipairs(invites) do
            local row = addRow(creature:getName(), tr('wants you in their party'), creature:getOutfit(), true)
            local id = creature:getId()
            addIcon(row, 'plus', tr('Join %s\'s party', creature:getName()), function()
                g_game.partyJoin(id)
                scheduleEvent(request, 500)
            end)
        end
    end
    if party and #(party.members or {}) > 0 then
        addGroup(tr('MEMBERS - %d', #party.members))
        for _, member in ipairs(party.members) do
            local me = member.name == myName()
            local leader = member.name == party.leader
            local detail = join({ leader and tr('Leader') or tr('Lv %d', tonumber(member.level) or 0),
                me and tr('you') or whereText(member.pos, true) })
            local row = addRow(leader and (member.name .. ' \226\152\133') or member.name, detail, member.outfit, true)
            if not me then
                addIcon(row, 'message', tr('Message %s', member.name), function() message(member.name) end)
                local creature
                for _, seen in ipairs(visiblePlayers()) do
                    if seen:getName() == member.name then
                        creature = seen
                    end
                end
                local extra = {}
                if isLeader() and creature then
                    local id = creature:getId()
                    extra[#extra + 1] = { tr('Pass leadership'), function() g_game.partyPassLeadership(id) end }
                end
                row.onMousePress = onRowPress(member.name, extra)
            end
        end
        window.shared:show()
        window.shared.toggle:setOn(isSharing())
        window.shared.toggle:setEnabled(isLeader())
        window.shared.toggle.knob:setMarginLeft(isSharing() and 19 or 3)
        window.shared.toggle.onClick = function()
            g_game.partyShareExperience(not isSharing())
            scheduleEvent(refresh, 300)
        end
        if isLeader() then
            addAction(tr('+ Invite'), inviteMenu, true)
        end
        addAction(tr('Leave party'), function()
            g_game.partyLeave()
            scheduleEvent(request, 500)
        end)
    else
        if #invites == 0 then
            window.empty:setText(tr('You are not in a party. Invite a trainer standing near you.'))
            window.empty:setVisible(true)
        end
        addAction(tr('+ Invite'), inviteMenu, true)
    end
end

-- Blocked

local function fillBlocked()
    local list = {}
    for _, name in ipairs(blockedList()) do
        list[#list + 1] = name
    end
    table.sort(list, function(a, b) return a:lower() < b:lower() end)
    for _, name in ipairs(list) do
        local row = addRow(name, tr('Their messages are hidden'), nil, false)
        addIcon(row, 'remove', tr('Unblock %s', name), function() unblock(name) refresh() end)
    end
    if #list == 0 then
        window.empty:setText(tr('Nobody blocked. Right-click a trainer, or their message, to block them.'))
        window.empty:setVisible(true)
    end
    addAction(tr('+ Block player'), function() Social.startAdding('block') end)
end

local function tabCounts()
    local friends, online = 0, 0
    for _, vip in pairs(g_game.getVips() or {}) do
        friends = friends + 1
    end
    for _, friend in ipairs(friendsList()) do
        if friend.online then
            online = online + 1
        end
    end
    local guildOnline = 0
    for _, member in ipairs(data.guild and data.guild.members or {}) do
        if member.online then
            guildOnline = guildOnline + 1
        end
    end
    local tabs = window.tabs
    tabs.friends:setText(tr('Friends') .. '  ' .. online .. ' / ' .. friends)
    tabs.guild:setText(data.guild and (tr('Guild') .. '  ' .. guildOnline .. ' / ' .. #(data.guild.members or {})) or tr('Guild'))
    tabs.party:setText(data.party and (tr('Party') .. '  ' .. #(data.party.members or {})) or tr('Party'))
    tabs.blocked:setText(tr('Blocked'))
    for _, id in ipairs(TABS) do
        tabs[id]:setOn(id == tab)
    end
end

local function setListTop(widget)
    window.list:removeAnchor(AnchorTop)
    window.list:addAnchor(AnchorTop, widget:getId(), AnchorBottom)
end

refresh = function()
    if not window or not window:isVisible() then
        return
    end
    local scroll = window.scroll:getValue()
    window.list:destroyChildren()
    window.footer:destroyChildren()
    window.empty:hide()
    window.shared:hide()
    window.search:setVisible(tab == 'friends')
    window.banner:setVisible(tab == 'guild' and data.guild ~= nil)
    if tab == 'friends' then
        setListTop(window.search)
    elseif tab == 'guild' and data.guild then
        setListTop(window.banner)
    else
        setListTop(window.tabs)
    end
    tabCounts()
    if tab == 'friends' then
        fillFriends()
    elseif tab == 'guild' then
        fillGuild()
    elseif tab == 'party' then
        fillParty()
    else
        fillBlocked()
    end
    window.list:removeAnchor(AnchorBottom)
    window.list:addAnchor(AnchorBottom, window.shared:isVisible() and 'shared' or 'footer', AnchorTop)
    window.footer:setVisible(not adding)
    local key = Pokegear.boundKey(KEY)
    window.header.keyChip:setText(key)
    window.header.keyChip:setVisible(key ~= '')
    scheduleEvent(function()
        if window and window.scroll then
            window.scroll:setValue(scroll)
        end
    end, 1)
end

local function stopAdding()
    adding = false
    if window then
        window.addEdit:hide()
        window.addEdit:setText('')
        window.footer:show()
    end
end

function Social.startAdding(kind)
    adding = kind
    window.footer:hide()
    window.addEdit:mergeStyle({ placeholder = kind == 'block' and tr('Name to block, then Enter') or tr('Trainer name, then Enter') })
    window.addEdit:show()
    window.addEdit:focus()
end

local function finishAdding()
    local name = window.addEdit:getText():trim()
    local kind = adding
    stopAdding()
    if name == '' then
        return
    end
    if kind == 'block' then
        block(name)
    else
        g_game.addVip(name)
        scheduleEvent(request, 500)
    end
    refresh()
end

local function selectTab(id)
    tab = id
    g_settings.set(TAB_SETTING, id)
    stopAdding()
    if window then
        window.scroll:setValue(0)
    end
    refresh()
end

local function onSocialMessage(protocol, opcode, buffer)
    buffer = ProtocolGame.joinFragments(opcode, buffer)
    if not buffer then
        return
    end
    local ok, message = pcall(json.decode, buffer)
    if not ok or type(message) ~= 'table' then
        return
    end
    if message.type == 'social' then
        data.friends = type(message.friends) == 'table' and message.friends or {}
        data.guild = type(message.guild) == 'table' and message.guild or nil
        data.party = type(message.party) == 'table' and message.party or nil
        refresh()
    elseif message.type == 'error' then
        modules.game_textmessage.displayFailureMessage(message.text or '')
    elseif message.type == 'left' then
        data.guild = nil
        refresh()
        request()
    end
end

local function build()
    window = g_ui.createWidget('PokegearSocial', modules.game_interface.getRootPanel())
    window:hide()
    window.header.close.onClick = function()
        Social.close()
    end
    for _, id in ipairs(TABS) do
        window.tabs[id].onClick = function()
            selectTab(id)
        end
    end
    window.search.onTextChange = function()
        refresh()
    end
    window.addEdit.onKeyPress = function(widget, keyCode)
        if keyCode == KeyEnter or keyCode == KeyReturn then
            finishAdding()
            return true
        elseif keyCode == KeyEscape then
            stopAdding()
            return true
        end
    end
    window.addEdit.onFocusChange = function(widget, focused)
        if not focused and adding then
            scheduleEvent(stopAdding, 1)
        end
    end
    restorePosition = Pokegear.makeMovable(window, window.header, POSITION_SETTING, function()
        -- left of the ring, or left of the Bag when that is open there
        local besideBag = Bag.isOpen() and Pokegear.isDocked(rootWidget:recursiveGetChildById('pokegearBag'),
            'pokegearBagPosition')
        window:addAnchor(AnchorTop, 'pokegearHub', AnchorTop)
        window:addAnchor(AnchorRight, besideBag and 'pokegearBag' or 'pokegearHub', AnchorLeft)
        window:setMarginTop(besideBag and 130 or 40)
        window:setMarginRight(besideBag and 4 or -6)
    end)
end

function Social.isOpen()
    return window ~= nil and window:isVisible()
end

function Social.open()
    if not active then
        return
    end
    if not window then
        build()
    end
    if not window:isVisible() then
        restorePosition()
        window:show()
    end
    window:raise()
    refresh()
    request()
    if not refreshEvent then
        refreshEvent = cycleEvent(function()
            if Social.isOpen() then
                request()
            end
        end, REFRESH_MS)
    end
end

function Social.close()
    stopAdding()
    if refreshEvent then
        removeEvent(refreshEvent)
        refreshEvent = nil
    end
    if window then
        window:hide()
    end
end

function Social.toggle()
    if Social.isOpen() then
        Social.close()
    else
        Social.open()
    end
end

-- The VIP window stays hidden in Pokegear. Opening it (the VIP key, its top bar button) opens
-- Social instead, except when game_viplist puts it back as it was at login.
local function vipWindow()
    local vip = modules.game_viplist
    return vip and vip.vipWindow
end

local function onVipOpen(widget)
    if not active then
        return
    end
    vipWasOpen = true
    widget:hide()
    local vip = modules.game_viplist
    if vip and vip.vipButton then
        vip.vipButton:setOn(false)
    end
    if g_clock.millis() - startedAt > 3000 then
        Social.toggle()
    end
end

local function applyVip()
    local vip = vipWindow()
    if not vip then
        return
    end
    if active then
        if not vipHidden then
            vipHidden = true
            vipWasOpen = vip:isVisible()
            connect(vip, { onOpen = onVipOpen })
        end
        vip:hide()
        local module = modules.game_viplist
        if module and module.vipButton then
            module.vipButton:setOn(false)
        end
    elseif vipHidden then
        vipHidden = false
        disconnect(vip, { onOpen = onVipOpen })
        if vipWasOpen and g_game.isOnline() then
            vip:show()
            local module = modules.game_viplist
            if module and module.vipButton then
                module.vipButton:setOn(true)
            end
        end
    end
end

local function onVipChange()
    if Social.isOpen() then
        scheduleEvent(refresh, 50)
    end
end

local function onGameStart()
    startedAt = g_clock.millis()
    data = { friends = {}, guild = nil, party = nil }
end

local function onShieldChange(creature)
    if Social.isOpen() and tab == 'party' then
        scheduleEvent(refresh, 50)
    end
end

function Social.apply(isActive)
    local now = isActive and g_game.isOnline()
    active = now
    applyVip()
    if not active then
        Social.close()
    end
end

function Social.init()
    g_ui.importStyle('social')
    tab = g_settings.getString(TAB_SETTING)
    if not table.find(TABS, tab) then
        tab = 'friends'
    end
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Social, onSocialMessage)
    connect(g_game, { onGameStart = onGameStart, onAddVip = onVipChange, onVipStateChange = onVipChange })
    connect(Creature, { onShieldChange = onShieldChange })
    if g_game.isOnline() then
        startedAt = g_clock.millis()
    end
end

function Social.terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Social)
    disconnect(g_game, { onGameStart = onGameStart, onAddVip = onVipChange, onVipStateChange = onVipChange })
    disconnect(Creature, { onShieldChange = onShieldChange })
    active = false
    applyVip()
    Social.close()
    if window then
        window:destroy()
        window = nil
    end
end
