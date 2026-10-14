-- The locker always opens as a container, like standard Tibia. The modern client shows the PC
-- window when any locker opens (extended opcode to 067-pc.lua).
function onUse(cid, item, fromPosition, itemEx, toPosition)
    return false
end
