-- A Pokemon Center locker opens the PC window (lib/ps/systems/067-pc.lua) for clients that have it;
-- false lets it open as a container, as it always has.
function onUse(cid, item, fromPosition, itemEx, toPosition)
    return PC.open(cid, getThingPos(item.uid))
end
