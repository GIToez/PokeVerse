-- PokeVerse server sub-protocol: opcode 0xFF, then a u8 sub-opcode.
-- Raises the same g_game signals as the legacy client (client/source/src/client/protocolgameparse.cpp),
-- so PokeVerse modules can connect() to them unchanged.
PokeVerseOpcode = 0xFF

PokeVerseSubOpcodes = {
    MoveBarUpdate = 1,
    MoveBarClose = 2,
    MoveBarOpen = 3,
    PokemonBarAdd = 4,
    PokemonBarRemove = 5,
    PokemonBarUpdate = 6,
    PokemonBarOpen = 7,
    PokemonBarClose = 8,
    MoveCooldown = 9,
    PokedexStatus = 10,
    PokedexOpen = 11,
    PokedexUpdate = 12,
    TmChoose = 13,
    StatusBarAdd = 14,
    StatusBarRemove = 15,
    StatusBarClear = 16,
    PokedexInfo = 17,
    CreatureJump = 18,
    CreatureEffect = 19,
    DollCaseStatus = 20,
    DollCaseUpdate = 21,
    SlotMachine = 22,
    Tip = 23,
    PollWindow = 24,
    PokemonLevelUp = 25,
    LootList = 26
}

local function emit(name, ...)
    signalcall(g_game[name], ...)
end

local function readU16List(msg, count)
    local list = {}
    for i = 1, count do
        list[i] = msg:getU16()
    end
    return list
end

local function readU8List(msg, count)
    local list = {}
    for i = 1, count do
        list[i] = msg:getU8()
    end
    return list
end

local function readPokemonBarEntry(msg)
    local textColor = msg:getU8()
    local text = msg:getString()
    local level = msg:getU8()
    local maxMana = msg:getU16()
    local mana = msg:getU16()
    local gender = msg:getU16()
    local experience = msg:getU8()
    return textColor, text, level, maxMana, mana, gender, experience
end

local S = PokeVerseSubOpcodes
local parsers = {
    [S.MoveBarUpdate] = function(msg)
        local iconItemId = msg:getU16()
        emit('onPokemonMoves', iconItemId, readU16List(msg, msg:getU8()))
    end,
    [S.MoveBarClose] = function()
        emit('onMoveBarClose')
    end,
    [S.MoveBarOpen] = function()
        emit('onMoveBarOpen')
        emit('onPokemonBarOpen')
    end,
    [S.PokemonBarAdd] = function(msg)
        local itemId = msg:getU16()
        local fastcallNumber = msg:getU16()
        emit('onPokemonBarAdd', itemId, fastcallNumber, readPokemonBarEntry(msg))
    end,
    [S.PokemonBarRemove] = function(msg)
        emit('onPokemonBarRemove', msg:getU16())
    end,
    [S.PokemonBarUpdate] = function(msg)
        local fastcallNumber = msg:getU16()
        emit('onPokemonBarUpdate', fastcallNumber, readPokemonBarEntry(msg))
    end,
    [S.PokemonBarOpen] = function()
        emit('onPokemonBarOpen')
    end,
    [S.PokemonBarClose] = function()
        emit('onPokemonBarClose')
    end,
    [S.MoveCooldown] = function(msg)
        local itemId = msg:getU16()
        emit('onPokemonMoveCooldown', itemId, msg:getU8())
    end,
    [S.PokedexStatus] = function(msg)
        emit('onPokedexStatus', readU8List(msg, msg:getU16()))
    end,
    [S.PokedexOpen] = function()
        emit('onPokedexOpen')
    end,
    [S.PokedexUpdate] = function(msg)
        local pokemonNumber = msg:getU16()
        emit('onPokedexUpdate', pokemonNumber, msg:getU8())
    end,
    [S.TmChoose] = function(msg)
        local tmMoveItemId = msg:getU16()
        emit('onTmChoose', tmMoveItemId, readU16List(msg, msg:getU8()))
    end,
    [S.StatusBarAdd] = function(msg)
        local itemId = msg:getU16()
        emit('onStatusBarAdd', itemId, msg:getU8())
    end,
    [S.StatusBarRemove] = function(msg)
        emit('onStatusBarRemove', msg:getU16())
    end,
    [S.StatusBarClear] = function()
        emit('onStatusBarClear')
    end,
    [S.PokedexInfo] = function(msg)
        local pokemonId = msg:getU16()
        local details = msg:getString()
        local moves = msg:getString()
        local effectiveness = msg:getString()
        local families = msg:getString()
        emit('onPokedexInfo', pokemonId, details, moves, effectiveness, families)
    end,
    [S.CreatureJump] = function(msg)
        local creature = g_map.getCreatureById(msg:getU32())
        if creature then
            creature:jump(20, 450)
        end
    end,
    [S.CreatureEffect] = function(msg)
        local creature = g_map.getCreatureById(msg:getU32())
        local effectId = msg:getU8()
        local var = msg:getU32()
        if creature and creature.onEffect then
            creature:onEffect(effectId, var)
        end
    end,
    -- The legacy client stored this u16 count in a u8; read the full count.
    [S.DollCaseStatus] = function(msg)
        emit('onDollCaseStatus', readU8List(msg, msg:getU16()))
    end,
    [S.DollCaseUpdate] = function(msg)
        local pokemonNumber = msg:getU16()
        emit('onDollCaseUpdate', pokemonNumber, msg:getU8())
    end,
    [S.SlotMachine] = function(msg)
        local result1 = msg:getU8()
        local result2 = msg:getU8()
        emit('onSlotMachine', result1, result2, msg:getU8())
    end,
    [S.Tip] = function(msg)
        emit('onTip', msg:getU8())
    end,
    [S.PollWindow] = function(msg)
        local name = msg:getString()
        local textMode = msg:getU8() ~= 0
        if textMode then
            emit('onPollWindow', name, textMode)
            return
        end
        local options = {}
        for _ = 1, msg:getU8() do
            local optionId = msg:getU8()
            options[optionId] = msg:getString()
        end
        emit('onPollWindow', name, options)
    end,
    -- The legacy client stored this u16 count in a u8; read the full count.
    [S.PokemonLevelUp] = function(msg)
        local pokemonNumber = msg:getU16()
        local newLevel = msg:getU8()
        emit('onPokemonLevelUp', pokemonNumber, newLevel, readU16List(msg, msg:getU16()))
    end,
    [S.LootList] = function(msg)
        local lootList = {}
        for _ = 1, msg:getU8() do
            local itemId = msg:getU16()
            lootList[itemId] = msg:getU8()
        end
        emit('onLootList', lootList)
    end
}

local function parsePokeVerse(protocol, msg)
    local subOpcode = msg:getU8()
    local parser = parsers[subOpcode]
    if not parser then
        -- Unknown payload length: the rest of this server message cannot be parsed.
        g_logger.error(string.format('[PokeVerse] unknown 0xFF sub-opcode %d; skipping %d bytes', subOpcode,
            msg:getUnreadSize()))
        msg:skipBytes(msg:getUnreadSize())
        return
    end
    parser(msg)
end

-- Server-bound PokeVerse packets (server/source/protocolgame.cpp parsePacket).
function g_game.sendPokeVersePollOpen()
    local protocol = g_game.getProtocolGame()
    if not protocol then
        return
    end
    local msg = OutputMessage.create()
    msg:addU8(0xFA)
    protocol:send(msg)
end

function g_game.sendPokeVersePollAnswer(answer)
    local protocol = g_game.getProtocolGame()
    if not protocol then
        return
    end
    local msg = OutputMessage.create()
    msg:addU8(0xFB)
    if type(answer) == 'string' then
        msg:addString(answer)
    else
        msg:addU8(answer)
    end
    protocol:send(msg)
end

-- No upstream Tibia protocol uses game opcode 0xFF, so this is safe to register for every version.
ProtocolGame.unregisterOpcode(PokeVerseOpcode)
ProtocolGame.registerOpcode(PokeVerseOpcode, parsePokeVerse)
