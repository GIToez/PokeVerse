local MIN_FASTCALL_NUMBER = 0
local MAX_FASTCALL_NUMBER = 1000

-- the numbers this trainer's other balls already use
local function numbersInUse(playerUid, ballUid)
	local used = {}
	for _, ball in pairs(getPlayerAllBallsWithPokemon(playerUid)) do
		local number = tonumber(getItemAttribute(ball.uid, 1000))
		if (ball.uid ~= ballUid and number) then
			used[number] = true
		end
	end
	return used
end

local function generateFastcallNumber(playerUid, used)
	local newFastcallNumber = getCreatureStorage(playerUid, PLAYER_STORAGES.LAST_FASTCALL_NUMBER)
	repeat
		newFastcallNumber = newFastcallNumber + 1
		if (newFastcallNumber < MIN_FASTCALL_NUMBER or newFastcallNumber > MAX_FASTCALL_NUMBER) then
			newFastcallNumber = MIN_FASTCALL_NUMBER
		end
	until (not used[newFastcallNumber])
	doCreatureSetStorage(playerUid, PLAYER_STORAGES.LAST_FASTCALL_NUMBER, newFastcallNumber)
	return newFastcallNumber
end

-- A ball keeps its number while it moves (belt, ball slot, bag, a swap, an evolution, the next login), so
-- the client keeps its place on the quick call bar and its F key. A new ball, or one whose number another
-- of the trainer's balls already has (a trade), gets a fresh one.
function doFastcallLink(playerUid, ballUid)
	local used = numbersInUse(playerUid, ballUid)
	local current = tonumber(getItemAttribute(ballUid, 1000))
	local newFastcallNumber = current
	if (not current or current < MIN_FASTCALL_NUMBER or used[current]) then
		newFastcallNumber = generateFastcallNumber(playerUid, used)
	end
	local pokemonName = getBallPokemonName(ballUid)
	--local pokemonTotalHealth = getMonsterInfo(pokemonName).health + (70 * getBallPokemonLevel(ballUid))
	local pokemonCurrentHpPercent, textColor = getBallPokemonLastHpPercent(ballUid)

	if (pokemonCurrentHpPercent >= 80) then
		textColor = 0
	elseif (pokemonCurrentHpPercent >= 40) then
		textColor = 1
	else
		textColor = 2
    end

    if (pokemonCurrentHpPercent > 0) then
        pokemonCurrentHpPercent = tostring(pokemonCurrentHpPercent .. "%")
    else
        pokemonCurrentHpPercent = "FNT"
    end

	doItemSetAttribute(ballUid, 1000, newFastcallNumber)
	doPlayerSendPokemonWindowAddPokemonIcon(playerUid, getPokemonFastcallPortraitId(pokemonName), newFastcallNumber,
        textColor, pokemonCurrentHpPercent)
end

function getFastcallNumber(itemUid)
	return getItemAttribute(itemUid, 1000)
end

function getFastcallBall(playerUid, fastcallNumber)
    fastcallNumber = tonumber(fastcallNumber)
	for _, ball in pairs(getPlayerAllBallsWithPokemon(playerUid)) do
		if (tonumber(getFastcallNumber(ball.uid)) == fastcallNumber) then
			return ball.uid
		end
	end
	return false
end
