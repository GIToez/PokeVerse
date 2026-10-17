-- Quest notices: a banner at the top of the screen when a quest starts or is done (the level-up banner's
-- look), and a small card at the top right of the map for progress and when the goal is reached. The
-- server sends progress only at milestones (every step up to 10, then each tenth and the last three).
local BANNER_MS = 3800
local TOAST_MS = 3200
local READY_TOAST_MS = 5000
local FADE_IN_MS = 250
local FADE_OUT_MS = 450
local GAP_MS = 200
local MAX_TOASTS = 3
local TOAST_SPACING = 6
local TOAST_TOP = 70
local TOAST_RIGHT = 14
local BANNER_TOP = 128

local banners = {} -- queued notices
local banner
local toasts = {} -- { widget, id, event }
local events = {}

local function schedule(fn, delay)
    local event
    event = scheduleEvent(function()
        table.removevalue(events, event)
        fn()
    end, delay)
    table.insert(events, event)
    return event
end

local function root()
    return modules.game_interface and modules.game_interface.getRootPanel()
end

local function bannerTop()
    local panel = root()
    local area = panel and panel:recursiveGetChildById('environment')
    if area and area:isVisible() then
        return area:getMarginTop() + area:getHeight() + 6
    end
    return BANNER_TOP
end

-- the level-up banners own the top of the screen while they show
local function levelUpShowing(panel)
    for _, child in ipairs(panel:getChildren()) do
        if child:getStyleName() == 'LevelUpStack' then
            return true
        end
    end
    return false
end

local showNextBanner

local function buildBanner(panel, data)
    local widget = g_ui.createWidget('QuestBanner', panel)
    widget:setMarginTop(bannerTop())
    local name = questTitle(data)
    widget.name:setText(#name > 70 and name:sub(1, 67) .. '...' or name)
    if data.kind == 'complete' then
        widget.title:setText(tr('Quest complete!'))
        widget.title:setColor('#ffd75a')
        local rewards = rewardsSummary(data)
        widget.line:setText(rewards ~= '' and tr('Rewards: %s', rewards) or tr('Well done, trainer.'))
        if data.daily then
            widget.line:setText(widget.line:getText() .. '   ' .. tr('(again after the restart)'))
        end
    else
        widget.title:setText(tr('Quest started'))
        local line = data.objective or ''
        if data.need and data.need > 1 then
            line = line .. string.format('   (%d / %d)', math.min(data.have or 0, data.need), data.need)
        end
        widget.line:setText(line)
    end
    local text = widget.line:getText()
    if #text > 74 then
        widget.line:setText(text:sub(1, 71) .. '...')
        widget:setTooltip(text)
    end
    return widget
end

showNextBanner = function()
    if banner or #banners == 0 then
        return
    end
    local panel = root()
    if not panel then
        banners = {}
        return
    end
    if levelUpShowing(panel) then
        schedule(showNextBanner, 500)
        return
    end
    banner = buildBanner(panel, table.remove(banners, 1))
    g_effects.fadeIn(banner, FADE_IN_MS)
    schedule(function()
        if not banner then
            return
        end
        g_effects.fadeOut(banner, FADE_OUT_MS)
        schedule(function()
            if banner then
                banner:destroy()
                banner = nil
            end
            schedule(showNextBanner, GAP_MS)
        end, FADE_OUT_MS)
    end, FADE_IN_MS + BANNER_MS)
end

-- toasts

local function layoutToasts()
    local panel = root()
    local map = modules.game_interface.getMapPanel and modules.game_interface.getMapPanel()
    if not panel or not map then
        return
    end
    local rect = map:getRect()
    -- the side panels can lie over the map: the cards go left of them
    local right = rect.x + rect.width
    for _, name in ipairs({ 'getRightPanel', 'getRightExtraPanel', 'getMainRightPanel' }) do
        local side = modules.game_interface[name] and modules.game_interface[name]()
        if side and side:isVisible() and side:getWidth() > 0 then
            local x = side:getRect().x
            if x > rect.x and x < right then
                right = x
            end
        end
    end
    local y = rect.y + TOAST_TOP
    for _, toast in ipairs(toasts) do
        local widget = toast.widget
        widget:setPosition({ x = right - widget:getWidth() - TOAST_RIGHT, y = y })
        y = y + widget:getHeight() + TOAST_SPACING
    end
end

local function removeToast(toast)
    table.removevalue(toasts, toast)
    if toast.event then
        removeEvent(toast.event)
        table.removevalue(events, toast.event)
    end
    if not toast.widget:isDestroyed() then
        toast.widget:destroy()
    end
    layoutToasts()
end

local function expire(toast, delay)
    if toast.event then
        removeEvent(toast.event)
        table.removevalue(events, toast.event)
    end
    toast.event = schedule(function()
        toast.event = nil
        if toast.widget:isDestroyed() then
            return
        end
        g_effects.fadeOut(toast.widget, FADE_OUT_MS)
        toast.event = schedule(function()
            toast.event = nil
            removeToast(toast)
        end, FADE_OUT_MS)
    end, delay)
end

local function showToast(data)
    local panel = root()
    if not panel then
        return
    end
    local ready = data.kind == 'ready'
    local toast
    for _, existing in ipairs(toasts) do
        if existing.id == data.id then
            toast = existing
        end
    end
    if not toast then
        if #toasts >= MAX_TOASTS then
            removeToast(toasts[1])
        end
        local widget = g_ui.createWidget('QuestToast', panel)
        toast = { widget = widget, id = data.id }
        table.insert(toasts, toast)
        g_effects.fadeIn(widget, FADE_IN_MS)
    end
    local widget = toast.widget
    g_effects.cancelFade(widget)
    widget:setOpacity(1)
    local name = data.name or tr('Quest')
    widget.name:setText(#name > 30 and name:sub(1, 27) .. '...' or name)
    widget.icon:setImageSource(IMAGES .. (ready and 'npc_quest_ready' or 'npc_quest_active'))
    widget.line:setText(ready and tr('Done! Go back to %s', data.npc or tr('the NPC')) or (data.objective or ''))
    widget.line:setColor(ready and '#8fe08f' or '#dce6ff')
    local need = tonumber(data.need) or 0
    widget.count:setText(need > 0 and string.format('%d / %d', math.min(data.have or 0, need), need) or '')
    setTrack(widget.track, data.have, math.max(1, need), ready and 'fill_green' or 'fill_blue')
    widget:setTooltip((data.objective or name) .. (ready and ('\n' .. tr('Done! Go back to %s.', data.npc or '')) or ''))
    layoutToasts()
    expire(toast, ready and READY_TOAST_MS or TOAST_MS)
end

function showNotice(data)
    data.id = tonumber(data.id)
    if data.kind == 'started' or data.kind == 'complete' then
        -- a finished quest's card goes away with its banner
        for _, toast in ipairs(toasts) do
            if toast.id == data.id then
                removeToast(toast)
                break
            end
        end
        table.insert(banners, data)
        schedule(showNextBanner, 100)
    elseif data.kind == 'progress' or data.kind == 'ready' then
        showToast(data)
    end
end

function resetNotices()
    for _, event in ipairs(events) do
        removeEvent(event)
    end
    events = {}
    banners = {}
    if banner then
        banner:destroy()
        banner = nil
    end
    for _, toast in ipairs(toasts) do
        if not toast.widget:isDestroyed() then
            toast.widget:destroy()
        end
    end
    toasts = {}
end
