function onSay(cid, words, param, ball)

doSendCustomBroadcastMessage("Mensagem boladamente bolada para teste", "#75e545", "images/broadcast/megaphone", 5500, 0.8)

-- TIME TEST
-- local function convertTime2(seconds)
  -- local seconds = tonumber(seconds)

  -- if seconds <= 0 then
    -- return "00:00:00";
  -- else
    -- hours = string.format("%02.f", math.floor(seconds/3600));
    -- mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    -- secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    -- return hours..":"..mins..":"..secs
  -- end
-- end

-- local timer = os.time{year=2022, month=11, day=1, hour=11, sec=53}

-- print(timer)
-- print(convertTime2(timer))

-- print(os.date('%Y-%m-%d T %X', timer))
-- print(os.date('Ano: %Y', timer))
-- print(os.date('Mes: %m', timer))
-- print(os.date('Dia: %d', timer))
-- print(os.date('Tempo: %X', timer))

-- print(os.date('Hora: %H', getPassTimer()))
-- print(os.date('Minuto: %M', getPassTimer()))
-- print(os.date('Segundo: %S', getPassTimer()))
-- local segundos = os.date('%S')
-- local minutos = os.date('%M') * 60
-- local horas = os.date('%H') * 60 * 60
-- local tempo = segundos + minutos + horas

-- print(tempo)
-- print(convertTime2(tempo))

-- print("Tempo do Sistema: "..os.date('%Y-%m-%d'))
-- print(getPassTimer())
-- print(convertTime2(getPassTimer()))
-- print(getPassDaysLeft())

-- TIME TEST



--PASSE DE BATALHA OPEN\/
-- updatePassMission(cid, 9, 1)
-- updatePassMission(cid, 10, 1)
-- updatePassMission(cid, 22, 1)
-- updatePassMission(cid, 23, 1)
-- updatePassMission(cid, 24, 1)
-- addPassStars(cid, 1)

-- setPlayerStorageValue(cid, 14009, -1)
-- setPlayerStorageValue(cid, 14010, -1)
-- setPlayerStorageValue(cid, 14011, -1)
-- setPlayerStorageValue(cid, 14012, -1)
-- setPlayerStorageValue(cid, 14013, -1)
-- setPlayerStorageValue(cid, 14014, -1)
-- setPlayerStorageValue(cid, 14015, -1)
-- setPlayerStorageValue(cid, 14016, -1)
-- sendPass(cid)

-- local PokeCoin = getPlayerStorageValue(cid, 414141)
-- setPlayerStorageValue(cid, 414141, PokeCoin+20)
-- local response = {
	-- value = "OpenShop",
    -- Drent = getPlayerItemCount(cid, 34524),
    -- Prent = getPlayerStorageValue(cid, 414141),
-- }
-- doSendPlayerExtendedOpcode(cid, 27, json.encode(response))

-- setPlayerStorageValue(cid, 3457753, 44)

--AMIZADE POKÉMON
  -- doPlayerRemoveItem(cid, 35552, 1000)
-- sendPokemonInfo(cid)
-- doResetBase(cid)
-- doResetEvs(cid)
-- sendScreanSound(cid, "BAULBAA.ogg")

return true
end