-- The Warp Styles window (Customise Trainer > Warp Styles): a slot for each moment (Log in, Log out,
-- Teleport, Victory, Defeat, Faint) with the styles that fit it, and the chosen one playing on the stage.
-- The server sends {type = "state", open = true, styles, triggers} (warpfx.lua passes it on) and takes
-- {action = "equip", trigger, style} for each slot changed on Save.
WarpWindow = {}

local PREVIEW_KEY = 'warp-preview'
local window, state, picks, selected, previewEvent, host
local imported = false

local function trigger(id)
    for _, entry in ipairs(state and state.triggers or {}) do
        if entry.id == id then
            return entry
        end
    end
end

local function style(id)
    for _, entry in ipairs(state and state.styles or {}) do
        if entry.id == id then
            return entry
        end
    end
end

local function stopPreview()
    removeEvent(previewEvent)
    previewEvent = nil
    stopKey(PREVIEW_KEY)
end

function WarpWindow.close()
    stopPreview()
    if window then
        window:destroy()
        window = nil
    end
    state, picks, selected, host = nil, nil, nil, nil
end

-- out, a moment hidden, in; Faint has no way back, the trainer just stands up again
local function steps(entry, styleId)
    if entry.kind == 'warp' then
        return { { styleId, 'out', 60 }, { 'gap', 'hide', 450 }, { styleId, 'in' }, { nil, nil, 900 } }
    elseif entry.kind == 'faint' then
        return { { styleId, 'out', 60 }, { 'gap', 'hide', 700 }, { nil, nil, 600 } }
    end
    return { { styleId, 'fx' }, { nil, nil, 700 } }
end

local function runPreview()
    stopPreview()
    local entry = window and trigger(selected)
    if not entry then
        return
    end
    local list, i = steps(entry, picks[selected]), 0
    local function step()
        if not window then
            return
        end
        i = i % #list + 1
        local s = list[i]
        local length
        if s[1] then
            length = LENGTHS[s[1]][s[2]] + (s[1] == 'gap' and s[3] or 0)
            local creature = window.stage.creature:getCreature()
            -- a little longer than the step so the trainer never shows between two halves
            playOn({ host = host, key = PREVIEW_KEY, style = s[1], half = s[2], length = length + (s[3] and 60 or 0),
                     outfit = creature and creature:getOutfit(), dir = creature and creature:getDirection() })
        else
            length = s[3]
        end
        previewEvent = scheduleEvent(step, length)
    end
    step()
end

local function refreshWindow()
    local entry = trigger(selected)
    for _, row in ipairs(window.rows:getChildren()) do
        row.name:setColor(row.triggerId == selected and '#ffcb05' or '#c9d3ee')
        for _, pill in ipairs(row.styles:getChildren()) do
            pill:setOn(picks[row.triggerId] == pill.styleId)
        end
    end
    local chosen = entry and style(picks[selected])
    window.stage.name:setText(chosen and entry and (tr(entry.name) .. ': ' .. tr(chosen.name)) or '')
    window.hint:setText(tr('Everyone around sees your styles. Victory and Defeat play when you win or lose a duel or a trainer battle, Faint when your trainer faints. Beam comes with Premium.'))
    runPreview()
end

local function save()
    if state then
        for _, entry in ipairs(state.triggers) do
            if picks[entry.id] ~= entry.style then
                equip(entry.id, picks[entry.id])
            end
        end
    end
    WarpWindow.close()
end

local function dragByHeader(widget)
    local header = widget.header
    header.onDragEnter = function(self, mousePos)
        local pos = widget:getPosition()
        self.dragOffset = { x = mousePos.x - pos.x, y = mousePos.y - pos.y }
        widget:breakAnchors()
        return true
    end
    header.onDragMove = function(self, mousePos)
        local root = g_ui.getRootWidget()
        widget:setPosition({
            x = math.max(0, math.min(mousePos.x - self.dragOffset.x, root:getWidth() - widget:getWidth())),
            y = math.max(0, math.min(mousePos.y - self.dragOffset.y, root:getHeight() - widget:getHeight())) })
        return true
    end
    header.onDragLeave = function()
        return true
    end
end

local function turn(step)
    local creature = window.stage.creature:getCreature()
    if creature then
        creature:setDirection((creature:getDirection() + step) % 4)
        runPreview()
    end
end

local function open(data)
    WarpWindow.close()
    state = data
    picks = {}
    for _, entry in ipairs(state.triggers or {}) do
        picks[entry.id] = entry.style or entry.default
    end
    selected = state.triggers and state.triggers[1] and state.triggers[1].id
    if not imported then
        g_ui.importStyle('window')
        imported = true
    end
    window = g_ui.createWidget('WarpStylesWindow', g_ui.getRootWidget())
    window.header.title:setText(tr('Warp Styles'))
    dragByHeader(window)
    window.header.close.onClick = WarpWindow.close
    window.footer.cancel.onClick = WarpWindow.close
    window.footer.save.onClick = save
    window.onKeyDown = function(_, keyCode)
        if keyCode == KeyEscape then
            WarpWindow.close()
            return true
        elseif keyCode == KeyEnter or keyCode == KeyReturn then
            save()
            return true
        end
        return false
    end

    local stage = window.stage
    stage:setClipping(true)
    local player = g_game.getLocalPlayer()
    stage.creature:setOutfit(player and player:getOutfit() or { type = 0 })
    local creature = stage.creature:getCreature()
    if creature then
        if creature.setDrawFullFrame then
            creature:setDrawFullFrame(true)
        end
        creature:setDirection(Directions.South)
    end
    stage.left.onClick = function() turn(1) end
    stage.right.onClick = function() turn(-1) end
    host = {
        parent = stage,
        widgets = true,
        anchor = function(play)
            if not window then
                return nil
            end
            local rect = window.stage.creature:getRect()
            local tile = rect.width * 32 / play.frame
            return { x = rect.x + rect.width - tile / 2, y = rect.y + rect.height, tile = tile }
        end,
        real = function()
            return window and window.stage.creature:getCreature()
        end,
    }

    for _, entry in ipairs(state.triggers or {}) do
        local row = g_ui.createWidget('WarpStylesRow', window.rows)
        row.triggerId = entry.id
        row.name:setText(tr(entry.name))
        row.onClick = function()
            selected = entry.id
            refreshWindow()
        end
        for _, s in ipairs(state.styles or {}) do
            if s.kind == entry.kind then
                local pill = g_ui.createWidget('PokegearPill', row.styles)
                pill.styleId = s.id
                pill:setText(tr(s.name))
                pill:setTooltip(s.owned and tr(s.how) or tr('%s: %s', tr(s.name), tr(s.how)))
                if not s.owned then
                    pill:setOpacity(0.45)
                end
                pill.onClick = function()
                    selected = entry.id
                    if s.owned then
                        picks[entry.id] = s.id
                    end
                    refreshWindow()
                end
            end
        end
    end
    window:raise()
    window:focus()
    refreshWindow()
end

function WarpWindow.onState(data)
    if data.open then
        open(data)
    end
end
