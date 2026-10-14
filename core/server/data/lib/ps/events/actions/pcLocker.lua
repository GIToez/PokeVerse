-- The locker always opens as a container, like standard Tibia. The modern client shows the PC
-- window when that container opens at a Pokemon Center (extended opcode to 067-pc.lua).
function onUse(cid, item, fromPosition, itemEx, toPosition)
    return false
end
