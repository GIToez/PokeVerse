-- Pop-up cards for game events. Two sizes:
--   showBanner(spec): the big banner at the top of the screen (one at a time, queued), for big
--     moments such as a wild legendary appearing or the trainer's own reward.
--   showCard(spec): a small card at the top right of the game window, for everything else.
-- Feature scripts (legendary.lua) turn server messages into specs. The Options switch
-- "Show event pop-up cards" (showEventCards) turns all of them off; the chat messages stay.
local FADE_IN_MS = 300
local FADE_OUT_MS = 500
local SLIDE = 16
local BANNER_MS = 5200
local CARD_MS = 6500
local GAP_MS = 250
local MAX_CARDS = 3
local TOP_MARGIN = 128

local bannerQueue = {}
local banner
local cardQueue = {}
local cardStack
local events = {}

local function schedule(fn, delay)
    local event
    event = scheduleEvent(function()
        table.removevalue(events, event)
        fn()
    end, delay)
    table.insert(events, event)
end

function isEnabled()
    local options = modules.client_options
    return not (options and options.getOption and options.getOption('showEventCards') == false)
end

function shorten(text, max)
    text = tostring(text or '')
    if #text > max then
        return text:sub(1, max - 3) .. '...'
    end
    return text
end

local function setPortrait(widget, spec)
    if spec.look and widget.creature then
        widget.creature:setOutfit({ type = spec.look })
        widget.creature:show()
    elseif spec.number then
        widget.picture:setImageSource('/images/staticPortraits/' .. spec.number)
        widget.picture:show()
    elseif spec.image then
        widget.picture:setImageSource(spec.image)
        widget.picture:show()
    end
end

local function otherBannerShowing()
    local levelup, evolution = modules.game_levelup, modules.game_evolution
    return (levelup and levelup.isShowing and levelup.isShowing()) or
        (evolution and evolution.isShowing and evolution.isShowing())
end

local function topMargin()
    local root = modules.game_interface.getRootPanel()
    local area = root and root:recursiveGetChildById('environment')
    if area and area:isVisible() then
        return area:getMarginTop() + area:getHeight() + 6
    end
    return TOP_MARGIN
end

local function slideIn(widget, elapsed, base)
    if widget:isDestroyed() then
        return
    end
    local t = math.min(elapsed / FADE_IN_MS, 1)
    widget:setMarginTop(math.floor(base - SLIDE * (1 - t) + 0.5))
    if t < 1 then
        schedule(function() slideIn(widget, elapsed + 30, base) end, 30)
    end
end

local function clearBanner()
    if banner then
        g_effects.cancelFade(banner)
        banner:destroy()
        banner = nil
    end
end

local showNextBanner

local function displayBanner(spec)
    local root = modules.game_interface.getRootPanel()
    banner = g_ui.createWidget('EventBanner', root)
    setPortrait(banner, spec)
    banner.name:setText(shorten(spec.name, 18))
    banner.highlight:setText(spec.highlight or '')
    if spec.highlightColor then
        banner.highlight:setColor(spec.highlightColor)
    end
    banner.subtitle:setText(shorten(spec.subtitle, 80))
    for _, chipSpec in ipairs(spec.chips or {}) do
        local chip = g_ui.createWidget('EventChip', banner.chips)
        if chipSpec.icon then
            chip.icon:setImageSource(chipSpec.icon)
        else
            chip.icon:setWidth(0)
            chip.label:setMarginLeft(2)
        end
        chip.label:setText(chipSpec.label or '')
        chip.value:setText(chipSpec.value or '')
        if chipSpec.color then
            chip.value:setColor(chipSpec.color)
        end
        if chipSpec.width then
            chip:setWidth(chipSpec.width)
        end
    end
    local base = topMargin()
    banner:setMarginTop(base - SLIDE)
    g_effects.fadeIn(banner, FADE_IN_MS)
    slideIn(banner, 0, base)
    schedule(function()
        if not banner then
            return
        end
        g_effects.fadeOut(banner, FADE_OUT_MS)
        schedule(function()
            clearBanner()
            schedule(showNextBanner, GAP_MS)
        end, FADE_OUT_MS)
    end, FADE_IN_MS + (spec.duration or BANNER_MS))
end

showNextBanner = function()
    if banner or #bannerQueue == 0 then
        return
    end
    if otherBannerShowing() then
        schedule(showNextBanner, 500)
        return
    end
    displayBanner(table.remove(bannerQueue, 1))
end

function showBanner(spec)
    if not isEnabled() or not g_game.isOnline() then
        return false
    end
    table.insert(bannerQueue, spec)
    schedule(showNextBanner, 50)
    return true
end

local function liveCards()
    return cardStack and cardStack:getChildCount() or 0
end

-- The map runs under the side panels, so keep the cards left of whatever is open on the right.
function placeCardStack()
    local root = modules.game_interface.getRootPanel()
    local map = modules.game_interface.getMapPanel()
    if not cardStack or not root or not map then
        return
    end
    local rootRect = root:getRect()
    local left = rootRect.x + rootRect.width
    for _, id in ipairs({ 'gameRightPanel', 'gameRightExtraPanel', 'gameMainRightPanel' }) do
        local panel = root:getChildById(id)
        if panel and panel:isVisible() and panel:getWidth() > 0 then
            left = math.min(left, panel:getX())
        end
    end
    cardStack:setMarginRight(math.max(0, rootRect.x + rootRect.width - left) + 12)
    cardStack:setMarginTop(math.max(0, map:getY() - rootRect.y) + 12)
end

local showNextCard

local function displayCard(spec)
    if not cardStack or cardStack:isDestroyed() then
        cardStack = g_ui.createWidget('EventCardStack', modules.game_interface.getRootPanel())
    end
    placeCardStack()
    local card = g_ui.createWidget('EventCard', cardStack)
    setPortrait(card, spec)
    card.title:setText(shorten(spec.title, 40))
    if spec.color then
        card.title:setColor(spec.color)
    end
    card.text:setText(shorten(spec.text, 90))
    g_effects.fadeIn(card, FADE_IN_MS)
    schedule(function()
        if card:isDestroyed() then
            return
        end
        g_effects.fadeOut(card, FADE_OUT_MS)
        schedule(function()
            if not card:isDestroyed() then
                card:destroy()
            end
            schedule(showNextCard, GAP_MS)
        end, FADE_OUT_MS)
    end, FADE_IN_MS + (spec.duration or CARD_MS))
end

showNextCard = function()
    while #cardQueue > 0 and liveCards() < MAX_CARDS do
        displayCard(table.remove(cardQueue, 1))
    end
end

function showCard(spec)
    if not isEnabled() or not g_game.isOnline() then
        return false
    end
    table.insert(cardQueue, spec)
    if #cardQueue > 6 then
        table.remove(cardQueue, 1)
    end
    showNextCard()
    return true
end

function isShowing()
    return banner ~= nil
end

local function reset()
    for _, event in ipairs(events) do
        removeEvent(event)
    end
    events = {}
    bannerQueue, cardQueue = {}, {}
    clearBanner()
    if cardStack then
        cardStack:destroy()
        cardStack = nil
    end
end

function init()
    g_ui.importStyle('eventcards')
    connect(g_game, { onGameEnd = reset })
    initLegendary()
end

function terminate()
    terminateLegendary()
    disconnect(g_game, { onGameEnd = reset })
    reset()
end
