WORKS = {
  RATE = 1,
}

WORKS.STORAGE = {
  MAIN = 14999,
}

WORKS.LIST = {
 [1] = {name = "Stylist", st = 15000,exp = 15001,mult = 1.1,init = 0,buff = 15002,debuff = 15003,percent_debuff = 15004,percent_buff = 15005},
 [2] = {name = "Adventurer", st = 15006,exp = 15007,mult = 1.1,init = 0,buff = 15008,debuff = 15009,percent_debuff = 15010,percent_buff = 15011},
 [3] = {name = "Professor", st = 15012,exp = 15013,mult = 1.1,init = 0,buff = 15014,debuff = 15015,percent_debuff = 15016,percent_buff = 15017},
 [4] = {name = "Enginner", st = 15018,exp = 15019,mult = 1.1,init = 0,buff = 15020,debuff = 15021,percent_debuff = 15022,percent_buff = 15023},
}

--mult: calculo que define a dificudade de aprendizado da work, segue o padrão do tibia, ou seja, 1.1 mais rapido de upar 2.0 muito lento

-- variavel storage indica o nivel que o player passara a gastar mais para upar a work, coloque sempre do menor para o maior    
-- custo é a quantidade de pontos que o player irá usar para upar 1 nivel da work
-- para criar mais niveis basta adicionar mais uma linha
-- Exemplo: [6] = {{storage = 5, custo = 4},{storage = 15, custo = 5},{storage = 75, custo = 8},{storage = 90, custo = 9},},

function learnWork(cid, work)
  local WORKINFO = WORKS.LIST[work]
  if not WORKINFO then return end
  setPlayerStorageValue(cid, WORKS.STORAGE.MAIN, work)
  setPlayerStorageValue(cid, WORKINFO.st, WORKINFO.init) -- LEVEL INCIAL DA PROFISSÃO
  setPlayerStorageValue(cid, WORKINFO.exp, getExpForLevel(WORKINFO.init)) -- EX PROFISSÃO
  setPlayerStorageValue(cid, WORKINFO.buff, 0) -- Buff
  setPlayerStorageValue(cid, WORKINFO.debuff, 0) -- deBuff
  setPlayerStorageValue(cid, WORKINFO.percent_buff, 0) -- Buff Percent
  setPlayerStorageValue(cid, WORKINFO.percent_debuff, 0) -- deBuff Percent
end

function getPlayerWork(cid)
  return getPlayerStorageValue(cid, WORKS.STORAGE.MAIN)
end

function getWorkPercent(cid, work)
  local WORKINFO = WORKS.LIST[work]
  if not WORKINFO then return 0 end
  local level = getPlayerStorageValue(cid, WORKINFO.st)
  local experience = getPlayerStorageValue(cid, WORKINFO.exp)
  local currExpCount = getExpForLevel(level)
  local nextExpCount = getExpForLevel(level + 1)
  if (experience < currExpCount or experience > nextExpCount) then
  	experience = currExpCount
	setPlayerStorageValue(cid, WORKINFO.exp, experience)
  end
  if (currExpCount < nextExpCount) then
  	return math.floor(getPercentLevel(experience - currExpCount, nextExpCount - currExpCount))
  else
  	return 0
  end
end

function getPercentLevel(count, nextLevelCount)
  if (nextLevelCount == 0) then
  	return 0
  end
  
  local result = (count * 100) / nextLevelCount
  if (result > 100) then
  	return 0
  end
  return result
end

function giveWorkExp(cid, work, exp)
  local WORKINFO = WORKS.LIST[work]
  if not WORKINFO then return end
  local level = getPlayerStorageValue(cid, WORKINFO.st)
  if level >= 100 then return end
  local currLevelExp = getExpForLevel(level)
  local nextLevelExp = getExpForLevel(level + 1)
  local rawExp = exp
  if (currLevelExp >= nextLevelExp) then
      -- //player has reached max level
      return
  end
  if (exp <= 0) then
    return
  end
  local experience = getPlayerStorageValue(cid, WORKINFO.exp) + exp
  local level = getPlayerStorageValue(cid, WORKINFO.st)
  local prevLevel = level
  while (experience >= nextLevelExp) do
    level = level + 1
    currLevelExp = nextLevelExp
    nextLevelExp = getExpForLevel(level + 1)
    if (currLevelExp >= nextLevelExp) then
      -- //player has reached max level
      break
    end
  end
  setPlayerStorageValue(cid, WORKINFO.exp, experience)
  if prevLevel ~= level then
    setPlayerStorageValue(cid, WORKINFO.st, level)
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você avançou em "..WORKINFO.name.." do nivel "..prevLevel.." para o nivel "..(level).."")
  end
  CRAFT.sendInfo(cid)
end 

function getExpForLevel(level)
  level = level - 1
  return ((50 * level * level * level) - (150 * level * level) + (400 * level)) / 3
end

function getWorkLevel(cid, work)
  local WORKINFO = WORKS.LIST[work]
  if not WORKINFO then return 0 end
  local realLevel, additional = 0, 0
  if getPlayerStorageValue(cid, WORKINFO.st) < WORKINFO.init then 
    setPlayerStorageValue(cid, WORKINFO.st, WORKINFO.init) 
    setPlayerStorageValue(cid, WORKINFO.exp, getWorkExpNeeded(cid, work, WORKINFO.init))
  end
  realLevel = getPlayerStorageValue(cid, WORKINFO.st)
  if getPlayerStorageValue(cid, WORKINFO.percent_debuff) > 0 then
    additional = additional - (work*(getPlayerStorageValue(cid, WORKINFO.percent_debuff)/100))
  end
  if getPlayerStorageValue(cid, WORKINFO.debuff) > 0 then
    additional = additional - getPlayerStorageValue(cid, WORKINFO.debuff)
  end
  if getPlayerStorageValue(cid, WORKINFO.percent_buff) > 0 then
    additional = additional + (work*(getPlayerStorageValue(cid, WORKINFO.percent_buff)/100))
  end
  if getPlayerStorageValue(cid, WORKINFO.buff) > 0 then
    additional = additional + getPlayerStorageValue(cid, WORKINFO.buff)
  end
  return (realLevel + additional)
end

function doPlayerAddWorkNivel(cid, work, additionLevels)
  local WORKINFO = WORKS.LIST[work]
  if not WORKINFO then return end
  local realLevel = getPlayerStorageValue(cid, WORKINFO.st)
  setPlayerStorageValue(cid, WORKINFO.st, realLevel + additionLevels)
  setPlayerStorageValue(cid, WORKINFO.exp, getWorkExpNeeded(cid, work, WORKINFO.init))
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você avançou em "..WORK.name.." para o nivel "..(realLevel + additionLevels).."")
end