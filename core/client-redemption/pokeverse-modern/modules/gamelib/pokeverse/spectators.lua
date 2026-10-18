-- Creatures the local player can see. Empty while logging in: the player has no position until the
-- server places them, and g_map.getSpectators raises an error for a missing position.
function getCreaturesAroundPlayer(multiFloor)
    local player = g_game.getLocalPlayer()
    local position = player and player:getPosition()
    if not position then
        return {}
    end
    return g_map.getSpectators(position, multiFloor == true)
end
