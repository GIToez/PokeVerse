-- Test-only otclientrc.lua for tools/smoke_redemption_login.sh. Never staged into dist/.
-- Logs in through ProtocolLogin and ProtocolGame exactly as the UI does, then prints
-- "[pv-smoke] ..." lines that the shell script asserts on.
local account = os.getenv('PV_ACCOUNT') or 'player'
local password = os.getenv('PV_PASSWORD') or 'player'
local character = os.getenv('PV_CHARACTER') or 'Trainer'
local host = os.getenv('PV_HOST') or '127.0.0.1'
local port = tonumber(os.getenv('PV_LOGIN_PORT') or '7564')
-- Walkable tile outside the starting temple's protection zone (checked against the map).
local MOVE_TEST_POSITION = os.getenv('PV_MOVE_TEST_POSITION') or '3325,806,6'

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

    local function findCreature(match)
        for _, tile in ipairs(g_map.getTiles(player:getPosition().z)) do
            for _, creature in ipairs(tile:getCreatures()) do
                if match(creature) then
                    return creature
                end
            end
        end
    end
    local function findSummon()
        return findCreature(function(creature) return creature:isLocalPlayerSummon() end)
    end

    local pokebar = modules.game_pokebar and modules.game_pokebar.pokemonBar
    -- Portraits of Pokemon that can be summoned (fainted ones say FNT).
    local ready = {}
    if pokebar then
        local portraits = {}
        for _, child in ipairs(pokebar:getChildren()) do
            if child:getStyleName() == 'BeltItem' then
                local health = child:getChildById(child:getId() .. 'label'):getText()
                if health ~= 'FNT' then
                    table.insert(ready, child)
                end
                table.insert(portraits, child:getId() .. '=' .. child:getChildById('PokeName'):getText() .. '(' .. health .. ')')
            end
        end
        report('MODULE game_pokebar visible=%s portraits=%d %s', tostring(pokebar:isVisible()), #portraits,
            table.concat(portraits, ','))
    else
        report('MODULE game_pokebar missing')
    end

    -- Click portraits the way a player does; the module sends /cp <slot>. With a Pokemon already out,
    -- the server recalls it and summons the clicked one 1.5 s later.
    local function clickPortrait(portrait, label, nextStep)
        local id = portrait:getId()
        local name = portrait:getChildById('PokeName'):getText()
        portrait:onMouseRelease(portrait:getPosition(), MouseLeftButton)
        scheduleEvent(function()
            local summon = findSummon()
            local current = pokebar:getChildById(id)
            report('%s %s creature=%s level=%d health=%s', label, summon and summon:getName() == name and 'OK' or 'FAILED',
                summon and summon:getName() or '-', summon and summon:getPokeLevel() or 0,
                current and current:getChildById(id .. 'label'):getText() or '-')
            nextStep()
        end, 3000)
    end

    local lastCooldown = {}
    connect(g_game, { onPokemonMoveCooldown = function(itemId, cooldown) lastCooldown[itemId] = cooldown end })

    -- The move bar fills for the summoned Pokemon. Moves need a target, so a GM spawns a wild one
    -- (/m needs access 5). Clicking a move says "m<slot>"; the server answers with its cooldown.
    local function useMove(nextStep)
        local window = modules.game_pokemoves and modules.game_pokemoves.pokemonMovesWindow
        if not window then
            report('MODULE game_pokemoves missing')
            return nextStep()
        end
        local icons, names = {}, {}
        for _, child in ipairs(window:getChildren()) do
            if child:getStyleName() == 'MoveItem' then
                table.insert(icons, child)
                table.insert(names, child:getTooltip())
            end
        end
        report('MODULE game_pokemoves visible=%s moves=%d %s', tostring(window:isVisible()), #icons, table.concat(names, ','))
        if #icons == 0 then
            return nextStep()
        end
        local function distance(a, b)
            return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
        end
        g_game.talk('/m Rattata')
        scheduleEvent(function()
            local here, target = player:getPosition(), nil
            for _, creature in ipairs(g_map.getSpectators(here, false)) do
                if creature:getName() == 'Rattata' and not creature:isLocalPlayerSummon() and
                    (not target or distance(creature:getPosition(), here) < distance(target:getPosition(), here)) then
                    target = creature
                end
            end
            if target then
                g_game.attack(target)
            end
            local healthBefore = target and target:getHealthPercent() or -1
            -- The first move may be melee (Tackle, Scratch), so let the summon reach the target.
            local waited = 0
            local function useWhenAdjacent()
                local summon = findSummon()
                if target and summon and distance(summon:getPosition(), target:getPosition()) > 1 and waited < 6000 then
                    waited = waited + 250
                    return scheduleEvent(useWhenAdjacent, 250)
                end
                local icon
                for _, child in ipairs(window:getChildren()) do
                    if child:getStyleName() == 'MoveItem' then icon = child break end
                end
                if not icon then
                    report('MOVE NONE move bar emptied before the move was used')
                    return nextStep()
                end
                local id, name, moveIcon = icon:getId(), icon:getTooltip(), icon:getItemId()
                icon:onMouseRelease(icon:getPosition(), MouseLeftButton)
                scheduleEvent(function()
                    -- The server usually rebuilds the bar after a move, so look the icon up again.
                    local current = window:getChildById(id)
                    report('MOVE %s move=%s cooldown=%s overlay=%s target=%s@%s health=%d->%d summon=%s waited=%d',
                        lastCooldown[moveIcon] and 'OK' or 'NONE', name, tostring(lastCooldown[moveIcon]),
                        tostring(current and current:getChildById(id .. 'cooldown') ~= nil), target and target:getName() or '-',
                        posString(target and target:getPosition()), healthBefore, target and target:getHealthPercent() or -1,
                        posString(summon and summon:getPosition()), waited)
                    g_game.cancelAttack()
                    nextStep()
                end, 600)
            end
            useWhenAdjacent()
        end, 1000)
    end

    -- Pokemon Info (ext opcode 63): the main panel button asks the server (/pokemoninfo), which sends the
    -- data and opens the window. Spend one EV point, try a forged negative upgrade, then check that the
    -- values survive a recall and a new summon.
    local function infoSummary(info)
        local evs, extra = info.evs or {}, info.extra or {}
        return string.format('name=%s level=%s evhp=%s points=%s ivhp=%s basehp=%s friendship=%s boost=%s held=%s ability=%s',
            tostring(info.main and info.main.name), tostring(info.main and info.main.level), tostring(evs.hp),
            tostring(evs.points), tostring(info.ivs and info.ivs.hp), tostring(info.base and info.base.hp),
            tostring(info.friendship and info.friendship.level), tostring(extra.boost), tostring(extra.heldItem),
            tostring(extra.ability))
    end

    local function pokemonInfoTests(portrait, nextStep)
        local info = modules.game_pokemonInfo
        if not info then
            report('MODULE game_pokemonInfo missing')
            return nextStep()
        end
        local button = modules.game_mainpanel.getButton('pokemonInfoButton')
        report('MODULE game_pokemonInfo button=%s', tostring(button ~= nil))
        local function openInfo(label, after)
            info.LastInfo = nil
            if info.isVisible() then info.hide() end
            info.toggle()
            scheduleEvent(function()
                local last = info.LastInfo
                report('INFO %s %s visible=%s %s', label, last and last.main and 'OK' or 'FAILED',
                    tostring(info.isVisible()), last and infoSummary(last) or '-')
                after(last)
            end, 1500)
        end
        openInfo('OPEN', function(before)
            if not before or not before.evs then
                return nextStep()
            end
            local hp, points = before.evs.hp, before.evs.points
            if points < 1 or hp >= 250 then
                report('EV SKIPPED points=%d hp=%d', points, hp)
                return nextStep()
            end
            info.togglePanel('ivev')
            info.addToUpgradeInfo('ivev', 'hp', 1)
            info.doUpgradeInfo('ivev')
            scheduleEvent(function()
                local after = info.LastInfo
                local ok = after and after.evs and after.evs.hp == hp + 1 and after.evs.points == points - 1
                report('EV ALLOCATE %s hp=%d->%s points=%d->%s', ok and 'OK' or 'FAILED', hp,
                    tostring(after and after.evs and after.evs.hp), points, tostring(after and after.evs and after.evs.points))
                info.sendUpgrade('ivev', { { id = 'hp', value = -50 }, { id = 'atk', value = 200 }, { id = 'atk', value = 200 } })
                scheduleEvent(function()
                    openInfo('FORGED', function(forged)
                        local same = forged and forged.evs and forged.evs.hp == hp + 1 and forged.evs.points == points - 1 and
                            forged.evs.atk == before.evs.atk
                        report('EV FORGED %s hp=%s atk=%s points=%s', same and 'REJECTED' or (forged and forged.evs and 'ACCEPTED' or 'NODATA'),
                            tostring(forged and forged.evs and forged.evs.hp), tostring(forged and forged.evs and forged.evs.atk),
                            tostring(forged and forged.evs and forged.evs.points))
                        info.hide()
                        -- Clicking the summoned Pokemon's portrait recalls it, and the server summons it
                        -- again about 1.5 s later.
                        portrait = pokebar:getChildById(portrait:getId()) or portrait
                        local name = portrait:getChildById('PokeName'):getText()
                        portrait:onMouseRelease(portrait:getPosition(), MouseLeftButton)
                        scheduleEvent(function()
                            report('RECALL %s', findSummon() and 'FAILED' or 'OK')
                        end, 700)
                        scheduleEvent(function()
                            local summon = findSummon()
                            report('RESUMMON %s creature=%s', summon and summon:getName() == name and 'OK' or 'FAILED',
                                summon and summon:getName() or '-')
                            openInfo('RESUMMON', function(again)
                                local kept = again and again.evs and again.evs.hp == hp + 1 and again.evs.points == points - 1
                                report('EV PERSIST %s hp=%s points=%s', kept and 'OK' or 'FAILED',
                                    tostring(again and again.evs and again.evs.hp), tostring(again and again.evs and again.evs.points))
                                info.hide()
                                nextStep()
                            end)
                        end, 3500)
                    end)
                end, 1000)
            end, 1500)
        end)
    end

    local function pokemonTests(nextStep)
        if not ready[1] then
            return nextStep()
        end
        -- The development characters start in a temple, and moves are refused in a protection
        -- zone. A summon stays behind when its trainer teleports, so move before summoning.
        g_game.talk('/goto ' .. MOVE_TEST_POSITION)
        scheduleEvent(function()
            report('TEST POSITION %s', posString(player:getPosition()))
            clickPortrait(ready[1], 'SUMMON', function()
                local summoned = ready[2] or ready[1]
                -- Pokemon Info runs before the move test, which spawns a hostile Pokemon.
                local afterSwitch = function() pokemonInfoTests(summoned, function() useMove(nextStep) end) end
                if ready[2] then
                    clickPortrait(ready[2], 'SWITCH', afterSwitch)
                else
                    afterSwitch()
                end
            end)
        end, 1500)
    end

    local directions = { South, North, East, West }
    local step = 0
    local function tryWalk(nextStep)
        step = step + 1
        if step > #directions then
            report('WALK FAILED')
            return nextStep()
        end
        local before = player:getPosition()
        g_game.walk(directions[step])
        scheduleEvent(function()
            local after = player:getPosition()
            if after.x ~= before.x or after.y ~= before.y then
                report('WALK OK %s -> %s', posString(before), posString(after))
                g_game.talk('PokeVerse Redemption smoke')
                nextStep()
            else
                tryWalk(nextStep)
            end
        end, 1500)
    end

    -- The move test spawns a hostile Pokemon, so walking comes first and the Pokemon tests last.
    tryWalk(function()
        pokemonTests(function()
            scheduleEvent(function() g_game.safeLogout() end, 1500)
        end)
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
    'onPokemonBarClose', 'onPokemonMoveCooldown', 'onPokedexStatus', 'onStatusBarClear', 'onDollCaseStatus', 'onTip',
    'onLootList' }
local handlers = {}
for _, name in ipairs(pokeVerseSignals) do
    handlers[name] = function(...)
        local values = {}
        for i = 1, select('#', ...) do
            local value = select(i, ...)
            table.insert(values, type(value) == 'table' and ('{' .. table.concat(value, ',') .. '}') or tostring(value))
        end
        report('POKEVERSE %s args=%d %s', name, #values, table.concat(values, ' '))
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
