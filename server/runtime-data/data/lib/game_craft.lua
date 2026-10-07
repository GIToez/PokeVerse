--[[ Por Ryukiimaru

      Sistema de Craft
        Estrutura da tablea = CRAF.ITEMS~[idwork][rank][id]
		st = storage de base pra verificar
		qnt = quantidade total por unidade que é craftado
		name = ... nome
		itemid = itemid do item :D
		level = level requisitado minimo para craftar
		exp = experiência adiquirida por unidade ( mesmo que ele faça + de 1x por craft )
		recipe = receita requirida, {itemid, quantidade}, etc..
		desc = descrição do item

]]

CRAFT = {}
CRAFT.ITEMS = {}

CRAFT.ITEMS[1] = {} -- Ex* Profissão Aventureiro, o index vai ser o id da profissão.
CRAFT.ITEMS[1]["E"] = {}
CRAFT.ITEMS[1]["E"][1] = {st = 1, qnt = 1, itemid = 26083, level = 0, timeByUnit = 5, exp = 0, recipe = {{12129,1}}, desc = "A very delicate fabric used to make decorations and fashion accessories."}
CRAFT.ITEMS[1]["E"][2] = {st = 2, qnt = 20, itemid = 25498, level = 2, timeByUnit = 5, exp = 2, recipe = {{34524,1}}, desc = "This material is used to speed up crafting."}
CRAFT.ITEMS[1]["E"][3] = {st = 3, qnt = 1, itemid = 29838, unique = true, level = 0, timeByUnit = 300, exp = 5, recipe = {{12138,50},{34275,25}}, desc = "Encourage your team with this war banner and get 5% extra experience!"}

CRAFT.ITEMS[1]["D"] = {}
CRAFT.ITEMS[1]["D"][1] = {st = 6, qnt = 1, itemid = 2000, level = 20, timeByUnit = 10, exp = 10, recipe = {{2001,2},{2002,2}}, desc = "Placeholder recipe."}
CRAFT.ITEMS[1]["D"][2] = {st = 7, qnt = 1, itemid = 2000, level = 22, timeByUnit = 10, exp = 10, recipe = {{2001,2},{2002,2}}, desc = "Placeholder recipe."}
CRAFT.ITEMS[1]["D"][3] = {st = 8, qnt = 1, itemid = 2000, level = 25, timeByUnit = 10, exp = 10, recipe = {{2001,2},{2002,2}}, desc = "Placeholder recipe."}
CRAFT.ITEMS[1]["D"][4] = {st = 9, qnt = 1, itemid = 2000, level = 30, timeByUnit = 10, exp = 10, recipe = {{2001,2},{2002,2}}, desc = "Placeholder recipe."}
CRAFT.ITEMS[1]["D"][5] = {st = 10, qnt = 1, itemid = 2000, level = 35, timeByUnit = 10, exp = 10, recipe = {{2001,2},{2002,2}}, desc = "Placeholder recipe."}

CRAFT.ITEMS[1]["C"] = {}
CRAFT.ITEMS[1]["C"][1] = {st = 11, qnt = 1, itemid = 29838, level = 0, timeByUnit = 120, exp = 0, recipe = {{34275,1}}, desc = "A very delicate fabric used to make decorations and fashion accessories."}

CRAFT.ITEMS[1]["B"] = {}
CRAFT.ITEMS[1]["B"][1] = {st = 12, qnt = 1, itemid = 29838, level = 0, timeByUnit = 120, exp = 0, recipe = {{34275,1}}, desc = "A very delicate fabric used to make decorations and fashion accessories."}

CRAFT.ITEMS[1]["A"] = {}
CRAFT.ITEMS[1]["A"][1] = {st = 13, qnt = 1, itemid = 29838, level = 0, timeByUnit = 120, exp = 0, recipe = {{34275,1}}, desc = "A very delicate fabric used to make decorations and fashion accessories."}

CRAFT.ITEMS[1]["S"] = {}
CRAFT.ITEMS[1]["S"][1] = {st = 14, qnt = 1, itemid = 29838, level = 0, timeByUnit = 120, exp = 0, recipe = {{34275,1}}, desc = "A very delicate fabric used to make decorations and fashion accessories."}

CRAFT.ITEMS[2] = {} -- Profissão de id 2
CRAFT.ITEMS[3] = {}
CRAFT.ITEMS[4] = {}

CRAFT.DUST = 25498
CRAFT.MAX_QUANTITY = 100
CRAFT.OPCODE = 103
CRAFT.STORAGE = {
  BASEQNT = 8887400,
  BASECOLLECTED = 8888500,
  BASETIME = 8889600,
}

function CRAFT.sendInfo(cid, open_window)
  local work = getPlayerWork(cid)
  local ITEMS = CRAFT.ITEMS[work]
  if not ITEMS then
    doPlayerPopupFYI(cid, __L(cid, "You do not have a profession."))
	return
  end
  local protocol = Protocol_create("work")
  Protocol_add(protocol, WORKS.LIST[work].name)
  Protocol_add(protocol, getWorkLevel(cid, work))
  Protocol_add(protocol, getWorkPercent(cid, work))
  Protocol_add(protocol, open_window)
  doSendPlayerExtendedOpcode(cid, CRAFT.OPCODE, table.tostring(protocol))
end

function CRAFT.sendItemsByRank(cid, rank, max_board)
  local ITEMS = CRAFT.ITEMS[getPlayerWork(cid)]
  if not ITEMS then
    doPlayerPopupFYI(cid, __L(cid, "You do not have a profession."))
	return
  end
  if not ITEMS[rank] then
    doPlayerPopupFYI(cid, __L(cid, "There are no items for this rank."))
    return
  end
  local first, send_items, maxSend = true, {}, 5
  for id, info in ipairs(ITEMS[rank]) do
    local INFO = {}
	INFO.id = id
	INFO.qnt = info.qnt
	INFO.desc = info.desc
	INFO.name = getItemNameById(info.itemid)
	INFO.level = info.level
	INFO.timeByUnit = info.timeByUnit
	INFO.exp = info.exp
	INFO.storage_qnt = getPlayerStorageValue(cid, CRAFT.STORAGE.BASEQNT + info.st)
	INFO.storage_collected = getPlayerStorageValue(cid, CRAFT.STORAGE.BASECOLLECTED + info.st)
    INFO.storage_time = getPlayerStorageValue(cid, CRAFT.STORAGE.BASETIME + info.st)
	if INFO.storage_time > os.time() then
	  INFO.storage_time = INFO.storage_time - os.time()
    else
      INFO.storage_time = 0
	end
	INFO.itemid = getItemInfo(info.itemid).clientId
	INFO.recipe = {}
    for _, item in pairs(info.recipe) do
	  INFO.recipe[#INFO.recipe+1] = {
	    getItemInfo(item[1]).clientId, item[2], getItemNameById(item[1])
	  }
    end
    send_items[#send_items + 1] = INFO
	if #send_items == maxSend then
	  CRAFT.sendItems(cid, rank, max_board, send_items, first)
	  first = false
	  send_items = {}
	end
  end
  if #send_items > 0 then
    CRAFT.sendItems(cid, rank, max_board, send_items, first)
  end
end

function CRAFT.sendItems(cid, rank, max_board, items, first)
  local protocol = Protocol_create("items")
  Protocol_add(protocol, first)
  Protocol_add(protocol, rank)
  Protocol_add(protocol, max_board)
  Protocol_add(protocol, items)
  doSendPlayerExtendedOpcode(cid, CRAFT.OPCODE, table.tostring(protocol))
end

function CRAFT.refreshItem(cid, rank, id)
  local ITEMS = CRAFT.ITEMS[getPlayerWork(cid)]
  if not ITEMS then
    doPlayerPopupFYI(cid, __L(cid, "You do not have a profession."))
	return
  end
  if not ITEMS[rank] then
    doPlayerPopupFYI(cid, __L(cid, "There are no items for this rank."))
    return
  end
  local INFO = ITEMS[rank][id]
  if not INFO then
    doPlayerPopupFYI(cid, __L(cid, "There is no item with this ID."))
    return
  end
  INFO.storage_qnt = getPlayerStorageValue(cid, CRAFT.STORAGE.BASEQNT + INFO.st)
  INFO.storage_collected = getPlayerStorageValue(cid, CRAFT.STORAGE.BASECOLLECTED + INFO.st)
  INFO.storage_time = getPlayerStorageValue(cid, CRAFT.STORAGE.BASETIME + INFO.st)
  if INFO.storage_time > os.time() then
    INFO.storage_time = INFO.storage_time - os.time()
  else
    INFO.storage_time = 0
  end
  local protocol = Protocol_create("refreshItem")
  Protocol_add(protocol, rank)
  Protocol_add(protocol, id)
  Protocol_add(protocol, INFO)
  doSendPlayerExtendedOpcode(cid, CRAFT.OPCODE, table.tostring(protocol))
end

function CRAFT.createItem(cid, rank, id, qnt)
  -- The quantity comes from the client: whole units within the window's slider range only.
  if not qnt or qnt ~= math.floor(qnt) or qnt < 1 or qnt > CRAFT.MAX_QUANTITY then return end
  local ITEMS = CRAFT.ITEMS[getPlayerWork(cid)]
  if not ITEMS then
    doPlayerPopupFYI(cid, __L(cid, "You do not have a profession."))
	return
  end
  if not ITEMS[rank] then
    doPlayerPopupFYI(cid, __L(cid, "There are no items for this rank."))
    return
  end
  local INFO = ITEMS[rank][id]
  if not INFO then
    doPlayerPopupFYI(cid, __L(cid, "There is no item with this ID."))
    return
  end
  if getWorkLevel(cid, getPlayerWork(cid)) < INFO.level then
    doPlayerPopupFYI(cid, __L(cid, "Your profession level is too low to craft this item."))
    return
  end
  local missing = {}
  for _, item in pairs(INFO.recipe) do
	local itemCount, reqCount = getPlayerItemCount(cid, item[1]), (item[2] * qnt)
	if itemCount < reqCount then
	  missing[#missing + 1] = (reqCount - itemCount).." "..getItemNameById(item[1])
	end
  end
  if #missing > 0 then
    doPlayerPopupFYI(cid, __L(cid, "You do not have the required materials.").."\n"..string.format(__L(cid, "Missing: %s."), table.concat(missing, ", ")))
    return 
  end
  for _, item in pairs(INFO.recipe) do
	if not doPlayerRemoveItem(cid, item[1], (item[2] * qnt)) then return end
  end
  -- VERIFICAÇÕES DA RECEITA E NIVEL
  local currentQnt = getPlayerStorageValue(cid, CRAFT.STORAGE.BASEQNT + INFO.st)
  local currentTime = getPlayerStorageValue(cid, CRAFT.STORAGE.BASETIME + INFO.st)
  setPlayerStorageValue(cid, CRAFT.STORAGE.BASEQNT + INFO.st, (currentQnt <= 0 and 0 or currentQnt) + qnt)
  setPlayerStorageValue(cid, CRAFT.STORAGE.BASETIME + INFO.st, (INFO.timeByUnit * qnt) + (currentTime > os.time() and currentTime or os.time()))
  CRAFT.refreshItem(cid, rank, id)
end

function CRAFT.speedUp(cid, rank, id)
  local ITEMS = CRAFT.ITEMS[getPlayerWork(cid)]
  if not ITEMS then
    doPlayerPopupFYI(cid, __L(cid, "You do not have a profession."))
	return
  end
  if not ITEMS[rank] then
    doPlayerPopupFYI(cid, __L(cid, "There are no items for this rank."))
    return
  end
  local INFO = ITEMS[rank][id]
  if not INFO then
    doPlayerPopupFYI(cid, __L(cid, "There is no item with this ID."))
    return
  end
  local currentTime = getPlayerStorageValue(cid, CRAFT.STORAGE.BASETIME + INFO.st)
  if currentTime < os.time() then return end
  currentTime = currentTime - os.time()
  local dustCost =  math.ceil(currentTime/(5*60))
  if getPlayerItemCount(cid, CRAFT.DUST) < dustCost then
    doPlayerPopupFYI(cid, __L(cid, "You do not have enough diamond dust."))
	return
  end
  doPlayerRemoveItem(cid, CRAFT.DUST, dustCost)
  setPlayerStorageValue(cid, CRAFT.STORAGE.BASETIME + INFO.st, os.time()-1)
  CRAFT.refreshItem(cid, rank, id)
  doPlayerPopupFYI(cid, __L(cid, "Crafting sped up!"))
end

-- Unique items are bound to the crafter; every collected unit is handed over either way.
function CRAFT.grantItem(cid, INFO, count)
  local function add(amount)
    local uid = doPlayerAddItem(cid, INFO.itemid, amount)
    if INFO.unique and uid then setItemUniqueOwner(uid, cid) end
  end
  if isItemStackable(INFO.itemid) then
    local left = count
    while left > 0 do
      add(math.min(left, 100))
      left = left - 100
    end
  else
    for i = 1, count do add(1) end
  end
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, string.format(__L(cid, "You collected %dx %s."), count, getItemNameById(INFO.itemid)))
end

function CRAFT.collectItem(cid, rank, id)
  local ITEMS = CRAFT.ITEMS[getPlayerWork(cid)]
  if not ITEMS then
    doPlayerPopupFYI(cid, __L(cid, "You do not have a profession."))
	return
  end
  if not ITEMS[rank] then
    doPlayerPopupFYI(cid, __L(cid, "There are no items for this rank."))
    return
  end
  local INFO = ITEMS[rank][id]
  if not INFO then
    doPlayerPopupFYI(cid, __L(cid, "There is no item with this ID."))
    return
  end
  local currentQnt = getPlayerStorageValue(cid, CRAFT.STORAGE.BASEQNT + INFO.st)
  currentQnt = (currentQnt < 0 and 0 or currentQnt)
  if currentQnt <= 0 then
    doPlayerPopupFYI(cid, __L(cid, "There is nothing to collect."))
	return
  end
  local currentCollectable = getPlayerStorageValue(cid, CRAFT.STORAGE.BASECOLLECTED + INFO.st)
  currentCollectable = (currentCollectable < 0 and 0 or currentCollectable)
  local availableQnt = currentQnt - currentCollectable
  if availableQnt <= 0 then
    doPlayerPopupFYI(cid, __L(cid, "There is nothing to collect."))
	return
  end
  local currentTime = getPlayerStorageValue(cid, CRAFT.STORAGE.BASETIME + INFO.st)
  if currentTime > os.time() then
	local collectable = math.floor(((currentQnt * INFO.timeByUnit) - (currentTime - os.time())) / INFO.timeByUnit)
	local availableCollectable = collectable - currentCollectable
	if availableCollectable <= 0 then
	  doPlayerPopupFYI(cid, __L(cid, "Please wait, nothing is ready to collect yet."))
	  return
	end
    setPlayerStorageValue(cid, CRAFT.STORAGE.BASECOLLECTED + INFO.st, availableCollectable + (currentCollectable <= 0 and 0 or currentCollectable))
	giveWorkExp(cid, getPlayerWork(cid), INFO.exp * availableCollectable)
	CRAFT.grantItem(cid, INFO, INFO.qnt * availableCollectable)
  else
    setPlayerStorageValue(cid, CRAFT.STORAGE.BASEQNT + INFO.st, -1)
    setPlayerStorageValue(cid, CRAFT.STORAGE.BASETIME + INFO.st, -1)
	setPlayerStorageValue(cid, CRAFT.STORAGE.BASECOLLECTED + INFO.st, -1)
	giveWorkExp(cid, getPlayerWork(cid), INFO.exp * availableQnt)
	CRAFT.grantItem(cid, INFO, INFO.qnt * availableQnt)
  end
  CRAFT.refreshItem(cid, rank, id)
end