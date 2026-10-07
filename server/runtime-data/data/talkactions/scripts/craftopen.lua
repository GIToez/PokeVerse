-- Development only (GM): opens the crafting window exactly like using a crafting table of that rank.
function onSay(cid, words, param)
  local rank = param ~= "" and param:upper() or "E"
  CRAFT.sendInfo(cid, true)
  CRAFT.sendItemsByRank(cid, rank, true)
  return true
end
