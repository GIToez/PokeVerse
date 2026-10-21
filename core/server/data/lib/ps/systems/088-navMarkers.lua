-- Navigation markers: the Pikachu ring on the tile to walk to and the chevrons pointing into it, seen only by
-- the trainer they are for. The client keeps a marker on screen for 2.5 s after it was last sent (things.otml,
-- image-frames on effects 939 and 940), so the server sends it again every 2 s until the trainer gets there,
-- a new marker replaces it or it is cleared.
--
-- A route is a list of stops shown one at a time. A stop is reached by standing on it, or by being one tile
-- from it on another floor: stairs and holes move the trainer next to the tile below or above them.

NavMarker = {}

local REFRESH = 2000
local MAX_SENDS = 900 -- 30 minutes

local markers = {}
local nextToken = 0

local function reached(cid, stop)
    local pos = getThingPos(cid)
    local near = math.max(math.abs(pos.x - stop.x), math.abs(pos.y - stop.y))
    if (pos.z == stop.z) then
        return near == 0
    end
    return near <= 1
end

local function tick(cid, token, sends)
    local marker = markers[cid]
    if (not marker or marker.token ~= token) then
        return
    end
    if (not isPlayer(cid) or sends >= MAX_SENDS) then
        markers[cid] = nil
        return
    end
    while (marker.route[marker.stop] and reached(cid, marker.route[marker.stop])) do
        marker.stop = marker.stop + 1
    end
    local stop = marker.route[marker.stop]
    if (not stop) then
        markers[cid] = nil
        return
    end
    doSendMagicEffect(stop, EFFECT_TUTORIAL_SQUARE, cid)
    doSendMagicEffect(stop, EFFECT_TUTORIAL_ARROW, cid)
    addEvent(tick, REFRESH, cid, token, sends + 1)
end

NavMarker.route = function(cid, stops)
    local route = {}
    for i, pos in ipairs(stops) do
        route[i] = { x = pos.x, y = pos.y, z = pos.z }
    end
    nextToken = nextToken + 1
    markers[cid] = { route = route, stop = 1, token = nextToken }
    tick(cid, nextToken, 0)
end

NavMarker.show = function(cid, pos)
    NavMarker.route(cid, { pos })
end

NavMarker.clear = function(cid)
    markers[cid] = nil
end

NavMarker.get = function(cid)
    local marker = markers[cid]
    return marker and marker.route[marker.stop]
end
