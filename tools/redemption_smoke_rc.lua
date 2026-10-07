-- Test-only otclientrc.lua for tools/smoke_redemption_login.sh. Never staged into dist/.
-- Logs in through ProtocolLogin and ProtocolGame exactly as the UI does, then prints
-- "[pv-smoke] ..." lines that the shell script asserts on.
local account = os.getenv('PV_ACCOUNT') or 'player'
local password = os.getenv('PV_PASSWORD') or 'player'
local character = os.getenv('PV_CHARACTER') or 'Trainer'
local host = os.getenv('PV_HOST') or '127.0.0.1'
local port = tonumber(os.getenv('PV_LOGIN_PORT') or '7564')

local function report(fmt, ...)
    g_logger.info('[pv-smoke] ' .. string.format(fmt, ...))
end

local function finish(code)
    report('EXIT %d', code)
    scheduleEvent(function() g_app.exit() end, 500)
end

local function posString(pos)
    return pos and string.format('%d,%d,%d', pos.x, pos.y, pos.z) or 'nil'
end

-- First launch shows a language picker over the game window, and the login window stays
-- open because this script logs in without it; dismiss both.
local function closeLocalePicker()
    local picker = g_ui.getRootWidget():recursiveGetChildById('localesWindow')
    if picker then
        picker:destroy()
        report('LOCALE PICKER CLOSED')
    end
    if EnterGame then
        EnterGame.hide()
    end
end

local function inspectGame()
    closeLocalePicker()
    local player = g_game.getLocalPlayer()
    local pos = player:getPosition()
    report('POSITION %s', posString(pos))

    local tiles, creatures = 0, 0
    for _, tile in ipairs(g_map.getTiles(pos.z)) do
        tiles = tiles + 1
        for _, creature in ipairs(tile:getCreatures()) do
            creatures = creatures + 1
            if creatures <= 5 then
                report('CREATURE name=%s types=%d/%d level=%d summon=%s attackable=%s', creature:getName(),
                    creature:getFirstType(), creature:getSecondType(), creature:getPokeLevel(),
                    tostring(creature:isLocalPlayerSummon()), tostring(creature:isAttackable()))
            end
        end
    end
    report('MAP tiles=%d creatures=%d', tiles, creatures)

    for slot = InventorySlotFirst, InventorySlotLast do
        local item = player:getInventoryItem(slot)
        if item then
            report('INVENTORY slot=%d id=%d count=%d pokeName=%s', slot, item:getId(), item:getCount(), item:getPokeName())
        end
    end

    local pokebar = modules.game_pokebar and modules.game_pokebar.pokemonBar
    local firstPortrait
    if pokebar then
        local portraits = {}
        for _, child in ipairs(pokebar:getChildren()) do
            if child:getStyleName() == 'BeltItem' then
                firstPortrait = firstPortrait or child
                table.insert(portraits, child:getId() .. '=' .. child:getChildById('PokeName'):getText())
            end
        end
        report('MODULE game_pokebar visible=%s portraits=%d %s', tostring(pokebar:isVisible()), #portraits,
            table.concat(portraits, ','))
    else
        report('MODULE game_pokebar missing')
    end

    local function findSummon()
        for _, tile in ipairs(g_map.getTiles(player:getPosition().z)) do
            for _, creature in ipairs(tile:getCreatures()) do
                if creature:isLocalPlayerSummon() then
                    return creature
                end
            end
        end
    end
    local function portraitHealth(portrait)
        return portrait:getChildById(portrait:getId() .. 'label'):getText()
    end

    local directions = { South, North, East, West }
    local step = 0
    local function tryWalk()
        step = step + 1
        if step > #directions then
            report('WALK FAILED')
            g_game.safeLogout()
            return
        end
        local before = player:getPosition()
        g_game.walk(directions[step])
        scheduleEvent(function()
            local after = player:getPosition()
            if after.x ~= before.x or after.y ~= before.y then
                report('WALK OK %s -> %s', posString(before), posString(after))
                g_game.talk('PokeVerse Redemption smoke')
                scheduleEvent(function() g_game.safeLogout() end, 1500)
            else
                tryWalk()
            end
        end, 1500)
    end

    if not firstPortrait then
        tryWalk()
        return
    end
    -- Click portraits the way a player does; the module sends /cp <slot>. With a Pokemon already out,
    -- the server recalls it and summons the clicked one 1.5 s later.
    local function clickAndReport(portrait, label, nextStep)
        local id = portrait:getId()
        local name = portrait:getChildById('PokeName'):getText()
        portrait:onMouseRelease(portrait:getPosition(), MouseLeftButton)
        scheduleEvent(function()
            local summon = findSummon()
            local current = pokebar:getChildById(id)
            local ok = summon and summon:getName() == name
            report('%s %s creature=%s level=%d health=%s', label, ok and 'OK' or 'FAILED', summon and summon:getName() or '-',
                summon and summon:getPokeLevel() or 0, current and portraitHealth(current) or '-')
            nextStep()
        end, 3000)
    end
    local secondPortrait
    for _, child in ipairs(pokebar:getChildren()) do
        if child:getStyleName() == 'BeltItem' and child ~= firstPortrait then
            secondPortrait = child
            break
        end
    end
    clickAndReport(firstPortrait, 'SUMMON', function()
        if secondPortrait then
            clickAndReport(secondPortrait, 'SWITCH', tryWalk)
        else
            tryWalk()
        end
    end)
end

connect(g_game, {
    onGameStart = function()
        report('GAME START character=%s', g_game.getCharacterName())
        scheduleEvent(inspectGame, 3000)
    end,
    onGameEnd = function()
        report('GAME END')
        finish(0)
    end,
    onLoginError = function(message)
        report('GAME LOGIN ERROR %s', message)
        finish(1)
    end,
    onConnectionError = function(message, code)
        report('GAME CONNECTION ERROR %s (%s)', tostring(message), tostring(code))
        finish(1)
    end,
    onTextMessage = function(mode, text)
        report('TEXT %d %s', mode, text)
    end,
    onTalk = function(name, level, mode, text)
        report('TALK %s: %s', name, text)
    end,
    onLightHour = function(hour)
        report('LIGHT HOUR %d', hour)
    end
})

local pokeVerseSignals = { 'onPokemonMoves', 'onMoveBarOpen', 'onMoveBarClose', 'onPokemonBarAdd', 'onPokemonBarOpen',
    'onPokemonBarClose', 'onPokedexStatus', 'onStatusBarClear', 'onDollCaseStatus', 'onTip', 'onLootList' }
local handlers = {}
for _, name in ipairs(pokeVerseSignals) do
    handlers[name] = function(...)
        report('POKEVERSE %s args=%d', name, select('#', ...))
    end
end
connect(g_game, handlers)

local function login()
    report('LOCALE %s', modules.client_locales.getCurrentLocale().name)
    g_game.setClientVersion(854)
    g_game.setProtocolVersion(g_game.getClientProtocolVersion(854))
    g_game.chooseRsa(host)
    if not modules.game_things.isLoaded() then
        report('THINGS NOT LOADED')
        return finish(1)
    end
    report('THINGS LOADED dat=%x spr=%x', g_things.getDatSignature(), g_sprites.getSprSignature())

    local protocol = ProtocolLogin.create()
    protocol.onLoginError = function(_, message)
        report('LOGIN ERROR %s', message)
        finish(1)
    end
    protocol.onCharacterList = function(_, characters, accountInfo)
        report('CHARLIST count=%d premDays=%d poll=%s', #characters, accountInfo.premDays,
            tostring(accountInfo.pollAvailable))
        local chosen
        for _, c in ipairs(characters) do
            report('CHARACTER name=%s world=%s %s:%d level=%s vocation=%s lookType=%s team=%d', c.name, c.worldName,
                c.worldIp, c.worldPort, tostring(c.level), tostring(c.vocation), tostring(c.outfit and c.outfit.type),
                c.pokemonTeam and #c.pokemonTeam or -1)
            if c.name == character then
                chosen = c
            end
        end
        if not chosen then
            report('CHARACTER %s NOT FOUND', character)
            return finish(1)
        end
        g_game.loginWorld(account, password, chosen.worldName, chosen.worldIp, chosen.worldPort, chosen.name, '', '', '')
    end
    protocol:login(host, port, account, password, '', false)
end

scheduleEvent(login, 1000)
scheduleEvent(function()
    report('TIMEOUT')
    finish(1)
end, tonumber(os.getenv('PV_TIMEOUT_MS') or '60000'))
