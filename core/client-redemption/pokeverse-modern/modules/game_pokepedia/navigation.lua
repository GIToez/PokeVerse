-- Walks the player along a list of stops with the client's auto-walk, one leg at a time: the route
-- on the Map tab, or a single goal ("Walk here"). A stop counts as reached within REACH tiles on its
-- floor. Legs only run on the same floor: on another floor the controller waits for the player to
-- take the stairs. A fight or an NPC talk pauses it; walking with the keys or clicking somewhere
-- else to walk stops it.
Navigation = {}

Navigation.REACH = 3
local CYCLE = 700
local RETRY_STEPS = { 60, 30, 15 } -- tiles toward the stop to try when no path reaches it

local legs = {}
local mode -- 'route' | 'goal' | nil
local paused, pauseReason
local waitingFloor
local via, failures = nil, 0
local lastIssue = 0
local cycle
local listeners = {}
local originalAutoWalk
local issuing = false

local function notify()
    for _, listener in ipairs(listeners) do
        listener()
    end
end

function Navigation.listen(fn)
    listeners[#listeners + 1] = fn
end

local function player()
    return g_game.isOnline() and g_game.getLocalPlayer() or nil
end

local function firstOpen()
    for index, stop in ipairs(legs) do
        if not stop.reached then
            return index, stop
        end
    end
    return nil
end

function Navigation.state()
    local index, stop = firstOpen()
    local reached = 0
    for _, leg in ipairs(legs) do
        if leg.reached then
            reached = reached + 1
        end
    end
    return { mode = mode, paused = paused, reason = pauseReason, index = index, stop = stop, total = #legs,
        reached = reached, waitingFloor = waitingFloor }
end

function Navigation.isActive(kind)
    return mode ~= nil and (kind == nil or mode == kind)
end

local function stopWalking()
    local p = player()
    if p and p:isAutoWalking() then
        p:stopAutoWalk()
    end
end

local function finish(text)
    mode, paused, pauseReason, waitingFloor, via = nil, false, nil, nil, nil
    if text then
        Pp.message(text, true)
    end
    notify()
end

-- a point `steps` tiles from `from` toward `to`
local function toward(from, to, steps)
    local dx, dy = to.x - from.x, to.y - from.y
    local length = math.max(math.abs(dx), math.abs(dy))
    if length <= steps then
        return { x = to.x, y = to.y, z = to.z }
    end
    local ratio = steps / length
    return { x = from.x + math.floor(dx * ratio + 0.5), y = from.y + math.floor(dy * ratio + 0.5), z = from.z }
end

local function step()
    if not mode or paused then
        return
    end
    local p = player()
    if not p then
        return
    end
    local pos = p:getPosition()
    local index, stop = firstOpen()
    if not stop then
        stopWalking()
        finish(mode == 'route' and tr('Route complete!') or nil)
        return
    end
    if pos.z == stop.z and Pp.distance(pos, stop) <= Navigation.REACH then
        stop.reached = true
        via, failures = nil, 0
        if mode == 'route' then
            MapTab.onStopReached(index, stop)
        end
        local nextIndex = firstOpen()
        if nextIndex then
            Pp.message(tr('Reached %s.', stop.name ~= '' and stop.name or tr('the stop')), true)
        elseif mode == 'goal' then
            stopWalking()
            finish(tr('You arrived at %s.', stop.name ~= '' and stop.name or tr('the spot')))
            return
        end
        notify()
        return step()
    end
    if pos.z ~= stop.z then
        if waitingFloor ~= stop.z then
            waitingFloor = stop.z
            notify()
        end
        return
    end
    if waitingFloor then
        waitingFloor = nil
        notify()
    end
    if via and Pp.distance(pos, via) <= 2 then
        via = nil
    end
    if p:isAutoWalking() or p:isWalking() then
        return
    end
    local now = g_clock.millis()
    if now - lastIssue < 500 then
        return
    end
    lastIssue = now
    local target = via or { x = stop.x, y = stop.y, z = stop.z }
    issuing = true
    p:autoWalk(target)
    issuing = false
end

function Navigation.start(stops, kind)
    legs = stops or {}
    mode = kind or 'route'
    paused, pauseReason, waitingFloor, via, failures = false, nil, nil, nil, 0
    lastIssue = 0
    step()
    notify()
end

function Navigation.goTo(pos, name)
    if not pos then
        return
    end
    local p = player()
    if p and p:getPosition().z == pos.z and Pp.distance(p:getPosition(), pos) <= 1 then
        Pp.status(tr('You are already there.'), true)
        return
    end
    Navigation.start({ { name = name or '', x = pos.x, y = pos.y, z = pos.z } }, 'goal')
end

function Navigation.stop(text)
    if not mode then
        return
    end
    stopWalking()
    finish(nil)
    if text then
        Pp.message(text)
    end
end

function Navigation.pause(reason)
    if not mode or paused then
        return
    end
    paused, pauseReason = true, reason
    stopWalking()
    notify()
end

function Navigation.resume()
    if not mode then
        return
    end
    paused, pauseReason, via, failures = false, nil, nil, 0
    lastIssue = 0
    step()
    notify()
end

function Navigation.describe()
    local state = Navigation.state()
    if not state.mode then
        return nil
    end
    local name = state.stop and state.stop.name ~= '' and state.stop.name or tr('the next stop')
    if state.paused then
        if state.reason == 'battle' then
            return tr('Paused for a battle. Press Resume to go on to %s.', name)
        elseif state.reason == 'npc' then
            return tr('Paused while you talk to an NPC. Press Resume to go on.')
        elseif state.reason == 'path' then
            return tr('No way to %s found from here. Walk closer and press Resume.', name)
        end
        return tr('Paused.')
    end
    if state.waitingFloor then
        return tr('%s is on floor %s. Take the stairs; the route waits for you.', name, Pp.floorName(state.waitingFloor))
    end
    local p = player()
    local distance = (p and state.stop) and Pp.distance(p:getPosition(), state.stop) or 0
    return tr('Walking to %s (%d tiles).', name, distance)
end

local function onAutoWalkFail(localPlayer, status)
    if not mode or paused then
        return
    end
    local p = player()
    local _, stop = firstOpen()
    if not p or not stop then
        return
    end
    failures = failures + 1
    local steps = RETRY_STEPS[failures]
    if not steps then
        Navigation.pause('path')
        return
    end
    via = toward(p:getPosition(), stop, steps)
    lastIssue = 0
end

local function onWalk(direction)
    if mode then
        Navigation.stop(tr('You walked yourself, so the route stopped.'))
    end
end

local function onAttackingCreatureChange(creature)
    if creature and mode then
        Navigation.pause('battle')
    end
end

local function onTalk(name, level, messageMode)
    if mode and (messageMode == MessageModes.NpcFrom or messageMode == MessageModes.NpcFromStartBlock) then
        Navigation.pause('npc')
    end
end

local function onOpenNpcTrade()
    if mode then
        Navigation.pause('npc')
    end
end

local function onPositionChange()
    if mode and not paused then
        step()
    end
end

local function onGameEnd()
    mode, legs, paused, pauseReason, waitingFloor, via = nil, {}, false, nil, nil, nil
    notify()
end

-- the client walks to a clicked spot with LocalPlayer.autoWalk, which doesn't go through onWalk
local function autoWalk(self, destination, ...)
    if mode and not issuing then
        Navigation.stop(tr('You walked somewhere else, so the route stopped.'))
    end
    return originalAutoWalk(self, destination, ...)
end

function Navigation.init()
    originalAutoWalk = LocalPlayer.autoWalk
    LocalPlayer.autoWalk = autoWalk
    connect(g_game, { onWalk = onWalk, onAttackingCreatureChange = onAttackingCreatureChange, onTalk = onTalk,
        onOpenNpcTrade = onOpenNpcTrade, onGameEnd = onGameEnd })
    connect(LocalPlayer, { onPositionChange = onPositionChange, onAutoWalkFail = onAutoWalkFail })
    cycle = cycleEvent(step, CYCLE)
end

function Navigation.terminate()
    disconnect(g_game, { onWalk = onWalk, onAttackingCreatureChange = onAttackingCreatureChange, onTalk = onTalk,
        onOpenNpcTrade = onOpenNpcTrade, onGameEnd = onGameEnd })
    disconnect(LocalPlayer, { onPositionChange = onPositionChange, onAutoWalkFail = onAutoWalkFail })
    removeEvent(cycle)
    cycle = nil
    if LocalPlayer.autoWalk == autoWalk then
        LocalPlayer.autoWalk = originalAutoWalk
    end
end
