-- Battle text (docs/upcoming-features.md, section 24). With Options > Interface > Battle text on New, trainers
-- call out their moves in speech bubbles and every hit and outcome has its own look; on Classic nothing here
-- draws and the plain text shows as before. The server still sends the plain text and the chat lines, and
-- ExtendedIds.BattleText JSON (091-battleText.lua) says what they were:
--   {k = "call", c = trainer, n = nickname, m = move, t = type}  then the trainer's "Nick, Move!" line
--   {k = "wild", c = pokemon}                                    then the wild Pokemon's MOVE yell
--   {k = "hit", c = target, s = "crit"|"super"|"weak"|"immune"}  then the hit's "-N"
--   {k = "miss", c = attacker, t = target}                       then "MISS!" over the attacker
--   {k = "say", c = speaker, s = kind, x = text, n = nickname, i = ball client id, t = type}  then the speaker says x:
--     calling out or recalling a Pokemon, an order, or throwing a ball, drawn as a bubble with the ball on it
-- In New, g_game.onAnimatedText (protocolgameparse.cpp) swallows the battle words and numbers and draws them
-- again here; takeOverhead (game_console) swallows the call-outs and wild yells, which stay in Local Chat.
-- Numbers and outcomes float over the Pokemon, stat changes beside it and statuses under its feet. Back to
-- back call-outs stack: the older bubbles float up, shrink and fade, at most three per trainer.
local IMG = '/modules/game_battletext/images/'
local FONT = 'pixelify-sans'
local TICK = 30

local BUBBLE_MS = 1500
local MAX_BUBBLES = 3
local BUBBLE_FONT = { 16, 14, 12 }
local BUBBLE_ICON = { 32, 28, 24 } -- an item tile; the ball is the middle third of it
local BUBBLE_ALPHA = { 1, 0.7, 0.45 }
local BUBBLE_GAP = 3
local SAY_WAIT_MS = 1500 -- a call-out waits this long for its chat line
local HIT_WAIT_MS = 600 -- a hit kind or a miss waits this long for its text
local STACK_MS = 350 -- texts this close together on one tile and lane stack instead of overlapping

local INK = '#1e2230'
local TYPE_COLORS = { -- dark enough to read on the white bubble
    normal = '#7a7a52', fight = '#b02a22', flying = '#6a52c8', poison = '#8a2c8a', ground = '#a8812e',
    rock = '#8a7424', bug = '#6e8a12', ghost = '#5a4688', steel = '#7c7c9c', fire = '#e0560c',
    water = '#2f6ee0', grass = '#3f9a2a', electric = '#d09a00', psychic = '#e0306c', ice = '#2a9aa6',
    dragon = '#5424e0', dark = '#5a4636', fairy = '#d0508a'
}

local NUMBERS = {
    normal = { size = 20, color = '#ffffff', stroke = '#1a1d2a' },
    super = { size = 26, color = '#ffd23c', stroke = '#4a2000', caption = 'SUPER EFFECTIVE', captionColor = '#ffe08a' },
    weak = { size = 15, color = '#b4b8c4', stroke = '#22252e', caption = 'resisted', captionColor = '#b4b8c4' },
    crit = { size = 32, pop = 40, color = '#ffcf3a', stroke = '#7a0000', caption = 'CRIT!', captionColor = '#ffffff',
             captionStroke = '#b00000' },
    heal = { size = 20, color = '#7dff8c', stroke = '#0a3c14' },
    -- the type does nothing, but the server still deals the stats' difference
    immune = { size = 14, color = '#8a8f9c', stroke = '#16181e', caption = 'NO EFFECT', captionColor = '#c8ccd6' },
}

-- the server's words, as tags: text, lane (top over the Pokemon, side beside it, feet under it), colours, icon
local TAGS = {
    ['MISS!'] = { 'MISS', 'top', '#8a8f9c', '#ffffff', 'swoosh' },
    ['EVADED'] = { 'DODGED', 'top', '#3b82f6', '#ffffff', 'dodge' },
    ['PROTECTED'] = { 'PROTECTED', 'top', '#22a55a', '#ffffff', 'shield' },
    ['FAIL!'] = { 'FAIL', 'top', '#8b45d6', '#ffffff', 'cross' },
    ['FAIL'] = { 'FAIL', 'top', '#8b45d6', '#ffffff', 'cross' },
    ['TIRED!'] = { 'TIRED', 'top', '#8b45d6', '#ffffff', 'sweat' },
    ['BURN'] = { 'BURNED', 'feet', '#e8562a', '#ffffff', 'flame' },
    ['POISON'] = { 'POISONED', 'feet', '#a040c0', '#ffffff', 'drop' },
    ['BADPOISON'] = { 'BADLY POISONED', 'feet', '#6a1b9a', '#ffffff', 'drop' },
    ['PARALYSIS'] = { 'PARALYZED', 'feet', '#f5c518', '#3a2a00', 'bolt' },
    ['SLEEP'] = { 'ASLEEP', 'feet', '#7a8ac8', '#ffffff', 'zz' },
    ['FROZEN'] = { 'FROZEN', 'feet', '#6cc8e8', '#08303f', 'snow' },
    ['CONFUSE'] = { 'CONFUSED', 'feet', '#e0a030', '#2e1a00', 'swirl' },
    ['FLINCH'] = { 'FLINCHED', 'feet', '#c86a9a', '#ffffff', 'star' },
    ['FLINCH!'] = { 'FLINCHED', 'feet', '#c86a9a', '#ffffff', 'star' },
    ['IN LOVE'] = { 'IN LOVE', 'feet', '#ff6fa8', '#ffffff', 'heart' },
    ['INSOMNIA'] = { 'INSOMNIA', 'feet', '#d07a2a', '#ffffff', 'eye' },
    ['LOW ACCURACY'] = { 'ACCURACY DOWN', 'side', '#3a78e0', '#ffffff', 'down' },
    ['REFLECT'] = { 'REFLECT', 'side', '#e0503a', '#ffffff', 'up' },
    ['CHARGE'] = { 'CHARGING', 'side', '#e0503a', '#ffffff', 'up' },
    ['PREVENT'] = { 'GUARDED', 'side', '#22a55a', '#ffffff', 'shield' },
}

-- "+SPEED", "-ATK" and the like: ups red, downs blue
local STAT_NAMES = { ATK = 'ATTACK', DEF = 'DEFENSE', SPATK = 'SP. ATK', SPDEF = 'SP. DEF', SPD = 'SPEED', ACC = 'ACCURACY' }

local function statTag(text)
    local sign, stat = text:match('^([%+%-])(%u[%u%.]*)$')
    if not sign then
        return nil
    end
    stat = STAT_NAMES[stat] or stat
    if sign == '+' then
        return { stat .. ' UP', 'side', '#e0503a', '#ffffff', 'up' }
    end
    return { stat .. ' DOWN', 'side', '#3a78e0', '#ffffff', 'down' }
end

local LANES = { -- life, rise in tiles, step in tiles when stacked
    top = { ms = 1100, rise = 0.9, step = -0.55 },
    side = { ms = 1300, rise = 0.3, step = 0.5 },
    feet = { ms = 1400, rise = 0.1, step = 0.55 },
}

local DIRS = { [0] = { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 }, { 1, -1 }, { 1, 1 }, { -1, 1 }, { -1, -1 } }

local bubbles = {} -- [trainer id] = { list (newest first) of bubbles, pos, from }
local floaters = {} -- texts at a map position: { pos, born, ms, lane, size, stack, widgets, layout }
local says = {} -- call-outs and wild yells waiting for their chat line: { cid, message, at }
local hits = {} -- [target id] = { kind, at }
local misses = {} -- [attacker id] = { target, at }
local tickEvent
local shake = { event = nil, active = false, left = 0, top = 0 }

local function mapPanel()
    return modules.game_interface and modules.game_interface.getMapPanel()
end

local function option(key, default)
    local options = modules.client_options
    if not options or not options.getOption then
        return default
    end
    local value = options.getOption(key)
    if value == nil then
        return default
    end
    return value
end

local function enabled()
    return option('battleText', 'new') ~= 'classic'
end

local function samePos(a, b)
    return a and b and a.x == b.x and a.y == b.y and a.z == b.z
end

local function spriteSize(creature)
    local size = creature and creature:getExactSize() or 32
    return math.max(28, math.min(96, size))
end

local function setFont(widget, size, strokeWidth, strokeColor)
    widget:setTTFFont(FONT, size, strokeWidth or 0, strokeColor or '#000000')
end

local function newLabel(parent, text, size, color, stroke, strokeWidth)
    local label = g_ui.createWidget('BattleTextLabel', parent)
    setFont(label, size, stroke and (strokeWidth or 2) or 0, stroke)
    label:setColor(color)
    label:setText(text)
    label:resizeToText()
    return label
end

local function destroyAll(list)
    for _, widget in ipairs(list) do
        if not widget:isDestroyed() then
            widget:destroy()
        end
    end
end

-- Shake

local function stopShake()
    removeEvent(shake.event)
    shake.event = nil
    local map = mapPanel()
    if map and shake.active then
        map:setMarginLeft(shake.left)
        map:setMarginTop(shake.top)
    end
    shake.active = false
end

local function startShake()
    local map = mapPanel()
    if not map or not option('battleTextCritShake', true) then
        return
    end
    if not shake.active then
        shake.left, shake.top = map:getMarginLeft(), map:getMarginTop()
        shake.active = true
    end
    removeEvent(shake.event)
    local started = g_clock.millis()
    shake.event = cycleEvent(function()
        local t = g_clock.millis() - started
        if t >= 220 or not g_game.isOnline() then
            stopShake()
            return
        end
        local a = t < 110 and 3 or 2
        map:setMarginLeft(shake.left + math.random(-a, a))
        map:setMarginTop(shake.top + math.random(-a, a))
    end, 30)
end

-- Texts at a position

local function clearFloaters()
    for _, f in ipairs(floaters) do
        destroyAll(f.widgets)
    end
    floaters = {}
end

local function addFloater(pos, lane, widgets, layout, ms)
    local creature = g_map.getTile(pos) and g_map.getTile(pos):getTopCreature()
    local now = g_clock.millis()
    local stack = 0
    for _, f in ipairs(floaters) do
        if f.lane == lane and samePos(f.pos, pos) and now - f.born < STACK_MS then
            stack = math.max(stack, f.stack + 1)
        end
    end
    table.insert(floaters, {
        pos = { x = pos.x, y = pos.y, z = pos.z }, born = now, ms = ms or LANES[lane].ms, lane = lane,
        size = spriteSize(creature), stack = stack, widgets = widgets, layout = layout
    })
end

-- the point a lane's text is centred on, in screen pixels, t seconds into its life (0 to 1)
local function lanePoint(f, rect, t)
    local scale = rect.width / 32
    local right, bottom = rect.x + rect.width, rect.y + rect.height
    local size = f.size * scale
    local cx = right - size / 2
    local lane = LANES[f.lane]
    local rise = (1 - (1 - t) * (1 - t)) * lane.rise * rect.height
    local step = f.stack * lane.step * rect.height
    if f.lane == 'top' then
        return cx, bottom - size * 0.8 - rise + step
    elseif f.lane == 'side' then
        return right + 4 * scale, bottom - size * 0.55 - rise + step, true
    end
    return cx, bottom + 4 * scale - rise + step
end

local function updateFloaters(map, now, z)
    for i = #floaters, 1, -1 do
        local f = floaters[i]
        local t = (now - f.born) / f.ms
        local rect = f.pos.z == z and map:getTileRect(f.pos)
        if t >= 1 then
            destroyAll(f.widgets)
            table.remove(floaters, i)
        elseif not rect or rect.width <= 0 then
            for _, widget in ipairs(f.widgets) do
                widget:hide()
            end
        else
            local x, y, leftAligned = lanePoint(f, rect, t)
            local alpha = math.min(1, (now - f.born) / 80)
            if t > 0.65 then
                alpha = math.min(alpha, (1 - t) / 0.35)
            end
            f.layout(x, y, alpha, now - f.born, leftAligned)
        end
    end
end

local function place(widget, x, y, alpha, leftAligned)
    local w, h = widget:getWidth(), widget:getHeight()
    widget:setRect({ x = math.floor(leftAligned and x or x - w / 2), y = math.floor(y - h / 2), width = w, height = h })
    widget:setOpacity(alpha)
    widget:show()
    widget:raise()
end

local function newTag(map, spec)
    local tag = g_ui.createWidget('BattleTextTag', map)
    tag:setImageColor(spec[3])
    tag.icon:setImageSource(IMG .. 'icon_' .. spec[5])
    tag.icon:setImageColor(spec[4])
    setFont(tag.text, 12, 0)
    tag.text:setColor(spec[4])
    tag.text:setText(spec[1])
    tag.text:resizeToText()
    tag:setWidth(5 + 12 + 3 + tag.text:getWidth() + 7)
    tag:hide()
    return tag
end

local function showTag(pos, spec)
    local map = mapPanel()
    if not map then
        return
    end
    local tag = newTag(map, spec)
    addFloater(pos, spec[2], { tag }, function(x, y, alpha, age, leftAligned)
        place(tag, x, y, alpha, leftAligned)
    end)
end

local function showNumber(pos, kind, value)
    local map = mapPanel()
    local style = NUMBERS[kind]
    if not map or not style then
        return
    end
    local text = kind == 'heal' and ('+' .. value) or tostring(value)
    local number = newLabel(map, text, style.pop or style.size, style.color, style.stroke, kind == 'crit' and 3 or 2)
    number:hide()
    local widgets = { number }
    local caption, burst
    if style.caption then
        caption = newLabel(map, style.caption, kind == 'crit' and 14 or 11, style.captionColor, style.captionStroke or style.stroke)
        caption:hide()
        table.insert(widgets, caption)
    end
    if kind == 'crit' then
        burst = g_ui.createWidget('BattleTextWidget', map)
        burst:setImageSource(IMG .. 'burst')
        burst:hide()
        table.insert(widgets, 1, burst)
        startShake()
    end
    local popped = style.pop == nil
    addFloater(pos, 'top', widgets, function(x, y, alpha, age)
        if not popped and age >= 110 then
            popped = true
            setFont(number, style.size, 3, style.stroke)
            number:resizeToText()
        end
        if burst then
            local grow = math.min(1, age / 120)
            local w, h = math.floor(72 * (0.6 + 0.4 * grow)), math.floor(56 * (0.6 + 0.4 * grow))
            burst:setRect({ x = math.floor(x - w / 2), y = math.floor(y - h / 2), width = w, height = h })
            burst:setOpacity(alpha * (age < 500 and 0.95 or 0.95 * math.max(0, 1 - (age - 500) / 300)))
            burst:show()
            burst:raise()
        end
        place(number, x, y, alpha)
        if caption then
            if kind == 'crit' then
                place(caption, x + number:getWidth() / 2 + 6, y - number:getHeight() / 2 - 2, alpha)
            else
                place(caption, x, y + number:getHeight() / 2 + 5, alpha)
            end
        end
    end, kind == 'crit' and 1300 or nil)
end

-- Bubbles

local function destroyBubble(bubble)
    bubble.widget:destroy()
    bubble.tail:destroy()
end

local function clearBubbles()
    for _, trainer in pairs(bubbles) do
        for _, bubble in ipairs(trainer.list) do
            destroyBubble(bubble)
        end
    end
    bubbles = {}
end

local function clean(text)
    return (tostring(text or ''):gsub('[{}]', ''))
end

local function setBubbleSlot(bubble, slot)
    bubble.slot = slot
    local label = bubble.widget.text
    setFont(label, BUBBLE_FONT[slot], 0)
    label:setColor(INK)
    label:setColoredText(bubble.text)
    label:resizeToText()
    local width = label:getWidth() + 16
    if bubble.icon then
        local size = BUBBLE_ICON[slot]
        bubble.widget.icon:setSize({ width = size, height = size })
        bubble.widget.icon:setMarginLeft(-math.floor(size * 0.06))
        label:setMarginLeft(-math.floor(size * 0.3))
        width = label:getWidth() + 8 + math.floor(size * 0.64)
    end
    bubble.widget:setSize({ width = width, height = label:getHeight() + 10 })
end

local function typeColor(element)
    return TYPE_COLORS[tostring(element or ''):lower()] or TYPE_COLORS.normal
end

local function segment(text, color)
    return text ~= '' and string.format('{%s, %s}', text, color) or ''
end

-- the line as said, with the Pokemon's name in its type's colour
local function sayText(text, nick, element)
    text = clean(text)
    nick = nick and clean(nick) or ''
    local at = nick ~= '' and text:find(nick, 1, true)
    if not at then
        return segment(text, INK)
    end
    return segment(text:sub(1, at - 1), INK) .. segment(nick, typeColor(element)) .. segment(text:sub(at + #nick), INK)
end

local function addBubble(cid, text, icon)
    local map = mapPanel()
    local creature = g_map.getCreatureById(cid)
    if not map or not creature then
        return
    end
    local trainer = bubbles[cid]
    if not trainer then
        trainer = { list = {}, pos = creature:getPosition() }
        bubbles[cid] = trainer
    end
    local bubble = {
        widget = g_ui.createWidget(icon and 'BattleTextIconBubble' or 'BattleTextBubble', map),
        tail = g_ui.createWidget('BattleTextTail', map),
        text = text,
        icon = icon,
        born = g_clock.millis(),
        rise = -6,
    }
    if icon then
        bubble.widget.icon:setItemId(icon)
    end
    bubble.widget:hide()
    bubble.tail:hide()
    table.insert(trainer.list, 1, bubble)
    while #trainer.list > MAX_BUBBLES do
        destroyBubble(table.remove(trainer.list))
    end
    for slot, b in ipairs(trainer.list) do
        setBubbleSlot(b, slot)
    end
end

local function callText(nick, move, element)
    return string.format('{%s, , %s}{%s, %s}{!, %s}', clean(nick), INK, clean(move), typeColor(element), INK)
end

-- where the trainer's sprite is drawn this frame: its tile, eased back toward the one it is walking from
local function trainerOffset(trainer, creature)
    local pos = creature:getPosition()
    if not samePos(pos, trainer.pos) then
        trainer.from, trainer.pos = trainer.pos, pos
    end
    local from = trainer.from
    if not from or not creature:isWalking() or math.abs(from.x - pos.x) > 1 or math.abs(from.y - pos.y) > 1 then
        return 0, 0
    end
    local left = 1 - math.max(0, math.min(1, creature:getStepProgress()))
    return (from.x - pos.x) * left, (from.y - pos.y) * left
end

local function updateBubbles(map, now, z)
    for cid, trainer in pairs(bubbles) do
        local list = trainer.list
        for i = #list, 1, -1 do
            if now - list[i].born >= BUBBLE_MS then
                destroyBubble(table.remove(list, i))
            end
        end
        local creature = g_map.getCreatureById(cid)
        if #list == 0 then
            bubbles[cid] = nil
        else
            local rect = creature and creature:getPosition().z == z and map:getTileRect(creature:getPosition())
            if not rect or rect.width <= 0 then
                for _, bubble in ipairs(list) do
                    bubble.widget:hide()
                    bubble.tail:hide()
                end
            else
                local ox, oy = trainerOffset(trainer, creature)
                local scale = rect.width / 32
                local size = spriteSize(creature) * scale
                local cx = rect.x + rect.width + ox * rect.width - math.min(size, 40 * scale) / 2
                local head = rect.y + rect.height + oy * rect.height - math.max(size, 32 * scale)
                local bottom = math.floor(head - 22 * scale)
                local above = 0
                for slot, bubble in ipairs(list) do
                    if bubble.slot ~= slot then
                        setBubbleSlot(bubble, slot)
                    end
                    local age = now - bubble.born
                    bubble.rise = bubble.rise + (above - bubble.rise) * 0.35
                    local alpha = BUBBLE_ALPHA[slot] * math.min(1, age / 120)
                    if age > BUBBLE_MS - 300 then
                        alpha = alpha * math.max(0, (BUBBLE_MS - age) / 300)
                    end
                    local w, h = bubble.widget:getWidth(), bubble.widget:getHeight()
                    local y = math.floor(bottom - h - bubble.rise)
                    bubble.widget:setRect({ x = math.floor(cx - w / 2), y = y, width = w, height = h })
                    bubble.widget:setOpacity(alpha)
                    bubble.widget:show()
                    bubble.widget:raise()
                    if slot == 1 then
                        bubble.tail:setRect({ x = math.floor(cx - 4), y = y + h - 4, width = 14, height = 12 })
                        bubble.tail:setOpacity(alpha)
                        bubble.tail:show()
                        bubble.tail:raise()
                    else
                        bubble.tail:hide()
                    end
                    above = above + h + BUBBLE_GAP
                end
            end
        end
    end
end

-- Loop

local function clearAll()
    clearFloaters()
    clearBubbles()
    says, hits, misses = {}, {}, {}
    removeEvent(tickEvent)
    tickEvent = nil
end

local function update()
    local map = mapPanel()
    local player = g_game.getLocalPlayer()
    if not map or not player or not g_game.isOnline() then
        clearAll()
        return
    end
    local now = g_clock.millis()
    local z = player:getPosition().z
    updateFloaters(map, now, z)
    updateBubbles(map, now, z)
    if #floaters == 0 and next(bubbles) == nil then
        removeEvent(tickEvent)
        tickEvent = nil
    end
end

local function wake()
    if not tickEvent then
        tickEvent = cycleEvent(update, TICK)
    end
    update()
end

local function expectSay(cid, message)
    table.insert(says, { cid = cid, message = message, at = g_clock.millis() })
end

local function recent(entry, now)
    return entry and now - entry.at <= HIT_WAIT_MS
end

-- The engine's animated text: true when it is drawn here instead
local function onAnimatedText(text, color, pos)
    if not enabled() or type(text) ~= 'string' or not pos then
        return false
    end
    local now = g_clock.millis()
    local damage = text:match('^%-(%d+)$')
    if damage then
        local kind = 'normal'
        for cid, hit in pairs(hits) do
            local creature = g_map.getCreatureById(cid)
            if not recent(hit, now) or not creature then
                hits[cid] = nil
            elseif samePos(creature:getPosition(), pos) then
                kind = hit.kind
                hits[cid] = nil
                break
            end
        end
        showNumber(pos, kind, tonumber(damage))
        wake()
        return true
    end
    local heal = text:match('^%+(%d+)$')
    if heal and color == 66 then
        showNumber(pos, 'heal', tonumber(heal))
        wake()
        return true
    end
    if text == 'CRITICAL!' then
        return true -- the crit shows on the target's number
    end
    if text == 'MISS!' then
        local at = pos
        for cid, miss in pairs(misses) do
            local attacker = g_map.getCreatureById(cid)
            if not recent(miss, now) or not attacker then
                misses[cid] = nil
            elseif samePos(attacker:getPosition(), pos) then
                local target = miss.target and g_map.getCreatureById(miss.target)
                if target then
                    at = target:getPosition()
                end
                misses[cid] = nil
                break
            end
        end
        showTag(at, TAGS['MISS!'])
        wake()
        return true
    end
    local tag = TAGS[text] or statTag(text)
    if tag then
        showTag(pos, tag)
        wake()
        return true
    end
    return false
end

-- game_console: true when a creature's overhead line is a call-out or wild yell drawn (or hidden) here.
-- The speaker is found by where it stands: the names on the map carry the level, the chat's do not.
function takeOverhead(name, mode, message, pos)
    if #says == 0 or not enabled() or type(message) ~= 'string' then
        return false
    end
    local now = g_clock.millis()
    for i = #says, 1, -1 do
        if now - says[i].at > SAY_WAIT_MS then
            table.remove(says, i)
        end
    end
    for i, say in ipairs(says) do
        local creature = g_map.getCreatureById(say.cid)
        local matches = say.message and say.message == message or (not say.message and message == message:upper())
        if matches and creature and samePos(creature:getPosition(), pos) then
            table.remove(says, i)
            return true
        end
    end
    return false
end

local function onMessage(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('BattleText: invalid message')
        return
    end
    local cid = tonumber(data.c)
    if not cid or not enabled() then
        return
    end
    local now = g_clock.millis()
    if data.k == 'call' then
        expectSay(cid, string.format('%s, %s!', tostring(data.n), tostring(data.m)))
        addBubble(cid, callText(data.n, data.m, data.t))
        wake()
    elseif data.k == 'say' and type(data.x) == 'string' then
        expectSay(cid, data.x)
        local icon = tonumber(data.i)
        addBubble(cid, sayText(data.x, data.n, data.t), icon and icon > 0 and icon or nil)
        wake()
    elseif data.k == 'wild' then
        expectSay(cid, nil)
    elseif data.k == 'hit' then
        hits[cid] = { kind = tostring(data.s), at = now }
    elseif data.k == 'miss' then
        misses[cid] = { target = tonumber(data.t), at = now }
    end
end

-- Options > Interface: back to Classic takes everything off the map
function refresh()
    if not enabled() then
        clearAll()
        stopShake()
    end
end

-- for tests and the screenshots: as if the server sent these
function demoCallout(cid, nick, move, element)
    addBubble(cid, callText(nick, move, element))
    expectSay(cid, string.format('%s, %s!', nick, move))
    wake()
end

function demoHit(pos, kind, value)
    showNumber(pos, kind, value)
    wake()
end

function demoSay(cid, kind, text, nick, element, icon)
    addBubble(cid, sayText(text, nick, element), icon)
    expectSay(cid, text)
    wake()
end

function demoText(pos, text, color)
    return onAnimatedText(text, color or 215, pos)
end

local function onGameEnd()
    clearAll()
    stopShake()
end

function init()
    g_ui.importStyle('battletext')
    ProtocolGame.registerExtendedOpcode(ExtendedIds.BattleText, onMessage)
    connect(g_game, { onGameEnd = onGameEnd })
    g_game.onAnimatedText = onAnimatedText
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.BattleText)
    disconnect(g_game, { onGameEnd = onGameEnd })
    if g_game.onAnimatedText == onAnimatedText then
        g_game.onAnimatedText = nil
    end
    clearAll()
    stopShake()
end
