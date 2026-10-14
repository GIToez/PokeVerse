-- Any locker opens the PC window (lib/ps/systems/067-pc.lua) for clients that have it, without
-- opening the container first; false lets it open as a container (old clients, "Open depot").
function onUse(cid, item, fromPosition, itemEx, toPosition)
    return PC.open(cid, getThingPos(item.uid))
end
