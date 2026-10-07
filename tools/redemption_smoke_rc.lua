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
                -- PokeVerse reuses the Tibia stats: mana is the summon's energy and magic level its level.
                local summon = findSummon()
                report('HUD trainer=%d/%d energy=%d/%d pokemonLevel=%d(%d%%) summon=%s health=%d%% skull=%d shield=%d',
                    player:getHealth(), player:getMaxHealth(), player:getMana(), player:getMaxMana(),
                    player:getMagicLevel(), player:getMagicLevelPercent(), summon and summon:getName() or '-',
                    summon and summon:getHealthPercent() or -1, player:getSkull(), player:getShield())
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

    -- Pokedex (0xFF sub-opcodes 10/11/17): the status grid arrives at login, the main panel button
    -- uses the Pokedex on the player (the server answers with the status list and opens the window),
    -- and clicking a known entry asks for /dexview and gets that Pokemon's details.
    local dexInfo
    connect(g_game, { onPokedexInfo = function(id, details, moves, effectiveness, families)
        dexInfo = { id = id, details = details, moves = moves, effectiveness = effectiveness, families = families }
    end })
    local function pokedexTests(nextStep)
        local dex = modules.game_pokedex
        if not dex then
            report('MODULE game_pokedex missing')
            return nextStep()
        end
        report('MODULE game_pokedex button=%s', tostring(modules.game_mainpanel.getButton('pokedexButton') ~= nil))
        if not player:getInventoryItem(InventorySlotLeft) then
            report('DEX SKIPPED no Pokedex in the Pokedex slot')
            return nextStep()
        end
        report('DEX LOGIN STATUS %s entries=%d', dex.getEntryCount() > 0 and 'OK' or 'FAILED', dex.getEntryCount())
        dex.toggle()
        scheduleEvent(function()
            local entries = dex.getEntryCount()
            report('DEX OPEN %s visible=%s entries=%d', dex.isVisible() and entries > 0 and 'OK' or 'FAILED',
                tostring(dex.isVisible()), entries)
            local known
            for _, child in ipairs(dex.panel:getChildren()) do
                local status = dex.getStatus(tonumber(child:getId()))
                if status and status ~= 0 then known = child break end
            end
            if not known then
                report('DEX INFO SKIPPED no known entry')
                dex.hide()
                report('DEX CLOSE %s', dex.isVisible() and 'FAILED' or 'OK')
                return nextStep()
            end
            dexInfo = nil
            known:onMouseRelease(known:getPosition(), MouseLeftButton)
            if os.getenv('PV_DEX_TAB') then
                dex.selectTab(tonumber(os.getenv('PV_DEX_TAB')))
            end
            scheduleEvent(function()
                local window = dex.pokedexWindow
                local name = window:recursiveGetChildById('pokeName'):getText()
                local type1 = window:recursiveGetChildById('pokeType1'):getTooltip()
                local moveRows = dex.getMoveRowCount()
                report('DEX INFO %s id=%s name=%s type1=%s moves=%d families=%s',
                    dexInfo and tonumber(dexInfo.id) == tonumber(known:getId()) and 'OK' or 'FAILED',
                    tostring(dexInfo and dexInfo.id), name, type1, moveRows, tostring(dexInfo and dexInfo.families))
                scheduleEvent(function()
                    dex.hide()
                    report('DEX CLOSE %s', dex.isVisible() and 'FAILED' or 'OK')
                    nextStep()
                end, tonumber(os.getenv('PV_DEX_HOLD_MS') or '300'))
            end, 1500)
        end, 1500)
    end

    -- Achievements are quest 15 of the quest log (server onQuestInfo fills it from player_achievements).
    local ACHIEVEMENTS_QUEST_ID = 15
    local questLog, questLines = nil, {}
    connect(g_game, {
        onQuestLog = function(list) questLog = list end,
        onQuestLine = function(questId, missions) questLines[questId] = missions end })
    local function achievementTests(nextStep)
        local quests = modules.game_questlog
        if not quests then
            report('MODULE game_questlog missing')
            return nextStep()
        end
        quests.show()
        scheduleEvent(function()
            local found
            for _, quest in ipairs(questLog or {}) do
                if quest[1] == ACHIEVEMENTS_QUEST_ID then found = quest end
            end
            report('QUESTLOG %s quests=%d achievements=%s', questLog and 'OK' or 'FAILED', questLog and #questLog or -1,
                found and tostring(found[2]) or '-')
            if not found then
                quests.questLogController:close()
                return nextStep()
            end
            g_game.requestQuestLine(ACHIEVEMENTS_QUEST_ID)
            scheduleEvent(function()
                local missions = questLines[ACHIEVEMENTS_QUEST_ID]
                local completed = 0
                for _, mission in ipairs(missions or {}) do
                    if tostring(mission[1]):find(' %(complet') then completed = completed + 1 end
                end
                report('ACHIEVEMENTS %s entries=%d completed=%d first=%s', missions and #missions > 0 and 'OK' or 'FAILED',
                    missions and #missions or -1, completed, missions and missions[1] and tostring(missions[1][1]) or '-')
                scheduleEvent(function()
                    quests.questLogController:close()
                    nextStep()
                end, tonumber(os.getenv('PV_QUEST_HOLD_MS') or '300'))
            end, 1500)
        end, 1500)
    end

    -- TM chooser: the window is driven by a locally injected 0xFF 0x0D signal (Mega Punch over Tackle,
    -- Ember, Scratch). Confirming says /tc; with no TM actually used the server must refuse it.
    local lastCancel
    connect(g_game, { onTextMessage = function(mode, text) lastCancel = text end })
    local function tmTests(nextStep)
        local tm = modules.game_tmchoose
        if not tm then
            report('MODULE game_tmchoose missing')
            return nextStep()
        end
        signalcall(g_game.onTmChoose, 12026, { 11749, 11695, 11726 })
        local state = tm.getState()
        report('TM WINDOW %s moves=%d', state.choose and state.moves == 3 and 'OK' or 'FAILED', state.moves)
        tm.choose(2)
        state = tm.getState()
        report('TM CONFIRM %s chosen=%s', state.confirm and not state.choose and state.chosen == 11695 and 'OK' or 'FAILED',
            tostring(state.chosen))
        scheduleEvent(function()
            tm.onCancel()
            state = tm.getState()
            report('TM BACK %s', state.choose and not state.confirm and 'OK' or 'FAILED')
            tm.choose(1)
            lastCancel = nil
            tm.onConfirm()
            scheduleEvent(function()
                state = tm.getState()
                report('TM FORGED %s closed=%s reply=%s', lastCancel and 'REJECTED' or 'NOREPLY',
                    tostring(not state.choose and not state.confirm), tostring(lastCancel))
                nextStep()
            end, 1000)
        end, tonumber(os.getenv('PV_TM_HOLD_MS') or '100'))
    end

    -- Status condition bar: icons come from the server during battle; here the 0xFF 0x0E/0x0F/0x10
    -- signals are injected so the icon, countdown, removal and clear are checked on every run.
    local function statusBarTests(nextStep)
        local bar = modules.game_statusbar
        if not bar then
            report('MODULE game_statusbar missing')
            return nextStep()
        end
        signalcall(g_game.onStatusBarAdd, 16715, 5)
        signalcall(g_game.onStatusBarAdd, 16719, 30)
        signalcall(g_game.onStatusBarAdd, 16715, 8)
        scheduleEvent(function()
            local state = bar.getState()
            report('STATUSBAR ADD %s visible=%s icons=%s', #state.icons == 2 and 'OK' or 'FAILED', tostring(state.visible),
                table.concat(state.icons, ','))
            scheduleEvent(function()
                signalcall(g_game.onStatusBarRemove, 16719)
                state = bar.getState()
                report('STATUSBAR REMOVE %s icons=%s', #state.icons == 1 and 'OK' or 'FAILED', table.concat(state.icons, ','))
                signalcall(g_game.onStatusBarClear)
                state = bar.getState()
                report('STATUSBAR CLEAR %s icons=%d', #state.icons == 0 and 'OK' or 'FAILED', #state.icons)
                nextStep()
            end, tonumber(os.getenv('PV_STATUS_HOLD_MS') or '100'))
        end, 1200)
    end

    -- Battle Pass (ext opcode 61): /pass fills the window from the server. The bundled season
    -- ended in 2021, so buying must be refused and a forged collect must grant nothing.
    local function passTests(nextStep)
        local pass = modules.game_pass
        if not pass then
            report('MODULE game_pass missing')
            return nextStep()
        end
        local root = g_ui.getRootWidget()
        report('MODULE game_pass button=%s', tostring(root:recursiveGetChildById('passButton') ~= nil))
        pass.open()
        scheduleEvent(function()
            local state = pass.getState()
            report('PASS OPEN %s visible=%s level=%d/%d premium=%s vipRewards=%d premiumRewards=%d daysLeft="%s" missions=%d',
                state.visible and state.vipRewards > 0 and 'OK' or 'FAILED', tostring(state.visible), state.level,
                state.maxLevel, tostring(state.premium), state.vipRewards, state.premiumRewards, state.daysLeft,
                state.missions)
            scheduleEvent(function()
                local protocol = g_game.getProtocolGame()
                lastCancel = nil
                protocol:sendExtendedOpcode(61, (state.level + 1) .. '#Collect#1')
                protocol:sendExtendedOpcode(61, 'x#Collect#')
                scheduleEvent(function()
                    report('PASS FORGED COLLECT %s reply=%s', lastCancel and 'FAILED' or 'IGNORED', tostring(lastCancel))
                    lastCancel = nil
                    protocol:sendExtendedOpcode(61, 'BuyPass50')
                    scheduleEvent(function()
                        report('PASS BUY %s reply=%s', lastCancel and lastCancel:find('season has ended') and 'REFUSED' or 'FAILED',
                            tostring(lastCancel))
                        pass.open()
                        report('PASS CLOSE %s', pass.getState().visible and 'FAILED' or 'OK')
                        nextStep()
                    end, 1000)
                end, 1000)
            end, tonumber(os.getenv('PV_PASS_HOLD_MS') or '100'))
        end, 1500)
    end

    -- Kill tasks (ext opcode 58): the list comes from /taskrank. Accept Rattata through the window,
    -- check that a second task and an early collect are refused, and leave it active so the move
    -- test's kill can count; taskFinish reports the kills and cancels it.
    local TASK_ID = 'rattata'
    local function pressTask(id, buttonId)
        local entry = modules.game_task.getEntry(id)
        local button = entry and entry.buttons and entry.buttons:getChildById(buttonId)
        if button then button.onClick() end
        return button ~= nil
    end

    local function taskTests(nextStep)
        local tasks = modules.game_task
        if not tasks then
            report('MODULE game_task missing')
            return nextStep()
        end
        report('MODULE game_task button=%s', tostring(modules.game_mainpanel.getButton('taskButton') ~= nil))
        tasks.toggle()
        scheduleEvent(function()
            local state = tasks.getState()
            if state.doing then
                report('TASK RESET cancelling %s', state.doing.id)
                pressTask(state.doing.id, 'cancelButtonWidget')
            end
            scheduleEvent(function()
                tasks.hideAlert()
                state = tasks.getState()
                report('TASK OPEN %s visible=%s tasks=%d points=%s doing=%s', state.visible and state.tasks > 0 and not state.doing and 'OK' or 'FAILED',
                    tostring(state.visible), state.tasks, state.points, tostring(state.doing and state.doing.id))
                if not pressTask(TASK_ID, 'acceptButtonWidget') then
                    report('TASK ACCEPT FAILED no %s entry', TASK_ID)
                    tasks.hide()
                    return nextStep()
                end
                scheduleEvent(function()
                    state = tasks.getState()
                    local widget = tasks.getEntry(TASK_ID):getChildById('SlotOutfit'):getFirstChild()
                    local creature = widget and widget.getCreature and widget:getCreature()
                    local outfit = creature and creature:getOutfit().type
                    report('TASK SPRITE %s outfit=%s widget=%s', outfit == 370 and 'OK' or 'FAILED', tostring(outfit),
                        widget and widget:getClassName() or '-')
                    report('TASK ACCEPT %s doing=%s kills=%s/%s alert=%s', state.doing and state.doing.id == TASK_ID and
                        state.alert == '[PegueiUmaMissao]' and 'OK' or 'FAILED', tostring(state.doing and state.doing.id),
                        tostring(state.doing and state.doing.kills), tostring(state.doing and state.doing.count), tostring(state.alert))
                    tasks.hideAlert()
                    lastCancel = nil
                    pressTask('caterpie', 'acceptButtonWidget')
                    scheduleEvent(function()
                        state = tasks.getState()
                        report('TASK SECOND %s doing=%s reply=%s', lastCancel and lastCancel:find('already doing') and
                            state.doing and state.doing.id == TASK_ID and 'REFUSED' or 'FAILED', tostring(state.doing and state.doing.id),
                            tostring(lastCancel))
                        pressTask(TASK_ID, 'doneButtonWidget')
                        scheduleEvent(function()
                            state = tasks.getState()
                            report('TASK EARLY COLLECT %s alert=%s doing=%s', state.alert == '[TaskNaoCompleta]' and state.doing and
                                'REFUSED' or 'FAILED', tostring(state.alert), tostring(state.doing and state.doing.id))
                            tasks.hideAlert()
                            report('TASK LIST SHOWN')
                            scheduleEvent(function()
                                tasks.hide()
                                report('TASK CLOSE %s', tasks.isVisible() and 'FAILED' or 'OK')
                                nextStep()
                            end, tonumber(os.getenv('PV_TASK_HOLD_MS') or '100'))
                        end, 1000)
                    end, 1000)
                end, 1000)
            end, 1000)
        end, 1500)
    end

    local function findWild(name)
        local here, best = player:getPosition(), nil
        local function dist(c) local p = c:getPosition() return math.max(math.abs(p.x - here.x), math.abs(p.y - here.y)) end
        for _, creature in ipairs(g_map.getSpectators(here, false)) do
            if creature:getName() == name and not creature:isLocalPlayerSummon() and not creature:isDead() and
                (not best or dist(creature) < dist(best)) then
                best = creature
            end
        end
        return best
    end

    -- The summon keeps attacking the move test's Rattata so the kill reaches the task.
    local function finishWild(name, nextStep)
        local target = findSummon() and findWild(name)
        if not target then
            report('TASK KILL SKIPPED summon=%s', tostring(findSummon() ~= nil))
            return nextStep()
        end
        g_game.attack(target)
        local targetId = target:getId()
        local function alive()
            local creature = g_map.getCreatureById(targetId)
            return creature and not creature:isDead() and creature:getHealthPercent() > 0
        end
        local waited = 0
        local function poll()
            if alive() and waited < 15000 then
                if not g_game.isAttacking() then g_game.attack(g_map.getCreatureById(targetId)) end
                waited = waited + 500
                local window = modules.game_pokemoves and modules.game_pokemoves.pokemonMovesWindow
                if window and waited % 1500 == 0 then
                    for _, child in ipairs(window:getChildren()) do
                        if child:getStyleName() == 'MoveItem' then
                            child:onMouseRelease(child:getPosition(), MouseLeftButton)
                            break
                        end
                    end
                end
                return scheduleEvent(poll, 500)
            end
            g_game.cancelAttack()
            local creature = g_map.getCreatureById(targetId)
            report('TASK KILL %s waited=%d health=%s', alive() and 'ALIVE' or 'DEFEATED', waited,
                tostring(creature and creature:getHealthPercent()))
            nextStep()
        end
        scheduleEvent(poll, 500)
    end

    local taskProgress
    local function taskFinish(nextStep)
        local tasks = modules.game_task
        if not tasks then return nextStep() end
        finishWild('Rattata', function() taskProgress(nextStep) end)
    end

    taskProgress = function(nextStep)
        local tasks = modules.game_task
        tasks.toggle()
        scheduleEvent(function()
            local state = tasks.getState()
            report('TASK PROGRESS doing=%s kills=%s/%s', tostring(state.doing and state.doing.id),
                tostring(state.doing and state.doing.kills), tostring(state.doing and state.doing.count))
            pressTask(TASK_ID, 'cancelButtonWidget')
            scheduleEvent(function()
                state = tasks.getState()
                report('TASK CANCEL %s alert=%s doing=%s', state.alert == '[MissaoAbandonada]' and not state.doing and 'OK' or 'FAILED',
                    tostring(state.alert), tostring(state.doing and state.doing.id))
                tasks.hide()
                nextStep()
            end, 1000)
        end, 1500)
    end

    -- Crafting (ext opcode 103), GM only: /learnwork grants the Stylist profession and /craftopen
    -- sends what using a rank E crafting table sends. Ball of wool -> Cloth takes 5 s per unit, so the test checks the missing-materials refusal, forged quantities,
    -- material consumption, the timer and the collected item.
    local fyi
    connect(g_game, { onLoginAdvice = function(message) fyi = message end })
    local function closeInfoBoxes()
        for _, child in ipairs(g_ui.getRootWidget():getChildren()) do
            if child.title and child.title:getText() == tr('For Your Information') then child:destroy() end
        end
    end

    local function countItem(clientId)
        local total = 0
        for slot = InventorySlotFirst, InventorySlotLast do
            local item = player:getInventoryItem(slot)
            if item and item:getId() == clientId then total = total + item:getCount() end
        end
        for _, container in pairs(g_game.getContainers()) do
            for _, item in ipairs(container:getItems()) do
                if item:getId() == clientId then total = total + item:getCount() end
            end
        end
        return total
    end

    local function craftTests(nextStep)
        local craft = modules.game_craft
        if not craft then
            report('MODULE game_craft missing')
            return nextStep()
        end
        report('MODULE game_craft loaded=true')
        if account ~= 'admin' then
            report('CRAFT SKIPPED needs GM commands')
            return nextStep()
        end
        g_game.talk('/learnwork')
        g_game.talk('/craftopen E')
        -- PokeVerse characters keep their bag in the ammo slot; slot 5 holds the badge case.
        if not next(g_game.getContainers()) then
            for slot = InventorySlotLast, InventorySlotFirst, -1 do
                local bag = player:getInventoryItem(slot)
                if bag and bag:isContainer() then
                    g_game.open(bag)
                    break
                end
            end
        end
        scheduleEvent(function()
            local state = craft.getState()
            report('CRAFT OPEN %s visible=%s work=%s level=%d rank=%s items=%d', state.visible and state.items > 0 and
                state.work and 'OK' or 'FAILED', tostring(state.visible), tostring(state.work), state.level,
                tostring(state.rank), state.items)
            if not state.visible or not craft.selectItem(1) then
                craft.hide()
                return nextStep()
            end
            state = craft.getState()
            local woolId, clothId = state.recipe[1][1], state.itemid
            local queued = state.queued
            fyi = nil
            craft.createItem(100)
            scheduleEvent(function()
                state = craft.getState()
                report('CRAFT MISSING %s queued=%d reply=%s', fyi and fyi:find('required materials') and state.queued == queued and
                    'REFUSED' or 'FAILED', state.queued, tostring(fyi and fyi:gsub('\n', ' ')))
                closeInfoBoxes()
                g_game.getProtocolGame():sendExtendedOpcode(103, '###CRAFT###,RANKE,ID1,QNT0.5')
                g_game.getProtocolGame():sendExtendedOpcode(103, '###CRAFT###,RANKE,ID1,QNT-3')
                g_game.talk('/i 12129,1')
                scheduleEvent(function()
                    state = craft.getState()
                    report('CRAFT FORGED QUANTITY %s queued=%d', state.queued == queued and 'REJECTED' or 'ACCEPTED', state.queued)
                    local woolBefore, clothBefore = countItem(woolId), countItem(clothId)
                    craft.showCreateWindow()
                    craft.doCreateItem()
                    scheduleEvent(function()
                        state = craft.getState()
                        local woolAfter = countItem(woolId)
                        report('CRAFT CREATE %s queued=%d timeLeft=%d wool=%d->%d', state.queued == math.max(0, queued) + 1 and
                            woolAfter == woolBefore - 1 and 'OK' or 'FAILED', state.queued, state.timeLeft, woolBefore, woolAfter)
                        scheduleEvent(function()
                            state = craft.getState()
                            lastCancel = nil
                            craft.collectItemCraft()
                            scheduleEvent(function()
                                local clothAfter = countItem(clothId)
                                state = craft.getState()
                                report('CRAFT COLLECT %s collectable=%d cloth=%d->%d queued=%d reply=%s', clothAfter == clothBefore + 1 and
                                    'OK' or 'FAILED', state.collectable, clothBefore, clothAfter, state.queued, tostring(lastCancel))
                                report('CRAFT WINDOW SHOWN')
                                scheduleEvent(function()
                                    craft.hide()
                                    closeInfoBoxes()
                                    report('CRAFT CLOSE %s', craft.getState().visible and 'FAILED' or 'OK')
                                    nextStep()
                                end, tonumber(os.getenv('PV_CRAFT_HOLD_MS') or '100'))
                            end, 1500)
                        end, 6000)
                    end, 1500)
                end, 1500)
            end, 1500)
        end, 2000)
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
        pokedexTests(function()
            achievementTests(function()
                tmTests(function()
                    statusBarTests(function()
                        passTests(function()
                            taskTests(function()
                                craftTests(function()
                                    pokemonTests(function()
                                        taskFinish(function()
                                            scheduleEvent(function() g_game.safeLogout() end, 1500)
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end)
                end)
            end)
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
    'onPokemonBarClose', 'onPokemonMoveCooldown', 'onPokedexStatus', 'onStatusBarClear', 'onStatusBarAdd',
    'onStatusBarRemove', 'onTmChoose', 'onPokedexOpen', 'onDollCaseStatus', 'onTip',
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
