local boards = {
  [34315] = {rank = "E", work = 1, level = 0}, --- estilista
  [34314] = {rank = "E", work = 1, level = 0}, --- estilista
  [34313] = {rank = "E", work = 1, level = 0}, --- estilista
  [34312] = {rank = "E", work = 1, level = 0}, --- estilista
  
  [34319] = {rank = "D", work = 1, level = 20}, --- estilista
  [34318] = {rank = "D", work = 1, level = 20}, --- estilista
  [34317] = {rank = "D", work = 1, level = 20}, --- estilista
  [34316] = {rank = "D", work = 1, level = 20}, --- estilista
  
  [34323] = {rank = "C", work = 1, level = 40}, --- estilista
  [34322] = {rank = "C", work = 1, level = 40}, --- estilista
  [34321] = {rank = "C", work = 1, level = 40}, --- estilista
  [34320] = {rank = "C", work = 1, level = 40}, --- estilista
  
  [34327] = {rank = "B", work = 1, level = 60}, --- estilista
  [34326] = {rank = "B", work = 1, level = 60}, --- estilista
  [34325] = {rank = "B", work = 1, level = 60}, --- estilista
  [34324] = {rank = "B", work = 1, level = 60}, --- estilista
  
  [34331] = {rank = "A", work = 1, level = 80}, --- estilista
  [34330] = {rank = "A", work = 1, level = 80}, --- estilista
  [34329] = {rank = "A", work = 1, level = 80}, --- estilista
  [34328] = {rank = "A", work = 1, level = 80}, --- estilista
  
  [34329] = {rank = "S", work = 1, level = 100}, --- estilista

  [2081] = {rank = "E", work = 1, level = 20},
  [2082] = {rank = "C", work = 1, level = 40},
  [2083] = {rank = "B", work = 1, level = 60},
  [2084] = {rank = "A", work = 1, level = 80},
  
  [27372] = {rank = "S", work = 1, level = 100},
}

function onUse(cid, item, fromPos, itemEx, toPos)
  local board = boards[item.itemid]
  if not board then return end
  local workId = getPlayerWork(cid)
  if board.work ~= workId then
    doPlayerSendCancel(cid, "This table is not for your profession.")
	return false
  end
  -- if getWorkLevel(cid, workId) < board.level then
    -- doPlayerSendCancel(cid, "Insufficient level to use this table.")
    -- return false
  -- end
  CRAFT.sendInfo(cid, true)
  CRAFT.sendItemsByRank(cid, board.rank, true)
  return true
end