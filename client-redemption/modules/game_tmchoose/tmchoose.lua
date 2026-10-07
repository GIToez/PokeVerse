-- The server sends the TM's move icon and the Pokemon's move icons (0xFF 0x0D, U8 count);
-- the player picks the move to replace, confirms, and the client says "/tc <replaced move icon>".
-- The server re-validates the TM item, the Pokemon and the move (018-technicalMachine.lua).
tmChooseWindow = nil
tmConfirmWindow = nil

local tmMoveItemId
local chosenMoveItemId

local function moveName(iconItemId)
    local name = getMoveNameByIconItemId(iconItemId)
    return name ~= '' and name or tostring(iconItemId)
end

local function reset()
    tmMoveItemId = nil
    chosenMoveItemId = nil
    tmChooseWindow:getChildById('moves'):destroyChildren()
    tmChooseWindow:hide()
    tmConfirmWindow:hide()
end

local function proceed(moveItemId)
    chosenMoveItemId = moveItemId
    tmChooseWindow:hide()
    tmConfirmWindow:getChildById('description'):setText(tr('Replace %s with %s?', moveName(moveItemId),
        moveName(tmMoveItemId)))
    tmConfirmWindow:getChildById('newMove'):setItemId(tmMoveItemId)
    tmConfirmWindow:getChildById('newMove'):setTooltip(moveName(tmMoveItemId))
    tmConfirmWindow:getChildById('oldMove'):setItemId(moveItemId)
    tmConfirmWindow:getChildById('oldMove'):setTooltip(moveName(moveItemId))
    tmConfirmWindow:show()
    tmConfirmWindow:raise()
    tmConfirmWindow:focus()
end

function onTmChoose(tmItemId, moves)
    reset()
    tmMoveItemId = tmItemId
    local panel = tmChooseWindow:getChildById('moves')
    for index, moveItemId in ipairs(moves) do
        local item = g_ui.createWidget('TmMoveItem', panel)
        item:setId('move' .. index)
        item:setItemId(moveItemId)
        item:setTooltip(moveName(moveItemId))
        item.onClick = function() proceed(moveItemId) end
    end
    tmChooseWindow:show()
    tmChooseWindow:raise()
    tmChooseWindow:focus()
end

function onConfirm()
    if not chosenMoveItemId then
        return
    end
    g_game.talk('/tc ' .. chosenMoveItemId)
    reset()
end

-- Back from the confirmation to the move list.
function onCancel()
    chosenMoveItemId = nil
    tmConfirmWindow:hide()
    if tmMoveItemId then
        tmChooseWindow:show()
        tmChooseWindow:raise()
        tmChooseWindow:focus()
    end
end

function cancel()
    reset()
end

function getState()
    return {
        choose = tmChooseWindow:isVisible(),
        confirm = tmConfirmWindow:isVisible(),
        tm = tmMoveItemId,
        chosen = chosenMoveItemId,
        moves = tmChooseWindow:getChildById('moves'):getChildCount()
    }
end

function choose(index)
    local item = tmChooseWindow:getChildById('moves'):getChildById('move' .. index)
    if item then
        item:onClick()
    end
end

local function onGameEnd()
    reset()
end

function onInit()
    g_ui.importStyle('tmchoose')
    tmChooseWindow = g_ui.createWidget('TmChooseWindow', g_ui.getRootWidget())
    tmConfirmWindow = g_ui.createWidget('TmConfirmWindow', g_ui.getRootWidget())
    reset()
    connect(g_game, { onGameEnd = onGameEnd, onTmChoose = onTmChoose })
end

function onTerminate()
    disconnect(g_game, { onGameEnd = onGameEnd, onTmChoose = onTmChoose })
    tmChooseWindow:destroy()
    tmConfirmWindow:destroy()
    tmChooseWindow = nil
    tmConfirmWindow = nil
end
