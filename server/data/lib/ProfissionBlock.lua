local TerraTile = {103, 351, 352, 353, 354, 355, 9021, 9022, 9023, 9024, 9025, 5815}
local TerraJungleTile = {103, 351, 352, 353, 354, 355, 9021, 9022, 9023, 9024, 9025, 106, 108, 109, 4526, 4527, 4528, 4529, 4530, 4531, 4532, 4533, 4534, 4535, 4536, 4537, 4538, 4539, 4540, 4541, 9043, 9044, 9045, 9046, 9047, 9048, 9049, 9050, 9051, 9052, 9053, 9054, 9055, 9056, 9057, 9058}
local PraiaTile = {231}
local PedraTile = {4405, 4406, 4407, 4408, 4409, 4410, 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4418, 4419, 4420, 4421, 4566, 4567, 4568, 4569, 4570, 4571, 4572, 4573, 4574, 4575, 4576, 4577, 4578, 4579, 7356}
local SnowTile = {670, 6580, 6581, 6582, 6583, 6584, 6585, 6586, 6587, 6588, 6589, 6590, 6591, 6592, 6593, 6594, 6595, 6596, 6597, 6598, 6599, 6600, 6601, 6602, 6603, 6604, 6605, 6606, 6607, 6608}
local GramaTile = {4526, 4527, 4528, 4529, 4530, 4531, 4532, 4533, 4534, 4535, 4536, 4537, 4538, 4539, 4540, 4541, 9043, 9044, 9045, 9046, 9047, 9048, 9049, 9050, 9051, 9052, 9053, 9054, 9055, 9056, 9057, 9058}

local AllBauTile = {103, 351, 352, 353, 354, 355, 9021, 9022, 9023, 9024, 9025, 5815, 103, 351, 352, 353, 354, 355, 9021, 9022, 9023, 9024, 9025, 106, 108, 109, 4526, 4527, 4528, 4529, 4530, 4531, 4532, 4533, 4534, 4535, 4536, 4537, 4538, 4539, 4540, 4541, 9043, 9044, 9045, 9046, 9047, 9048, 9049, 9050, 9051, 9052, 9053, 9054, 9055, 9056, 9057, 9058, 231, 4405, 4406, 4407, 4408, 4409, 4410, 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4418, 4419, 4420, 4421, 4566, 4567, 4568, 4569, 4570, 4571, 4572, 4573, 4574, 4575, 4576, 4577, 4578, 4579, 7356, 670, 6580, 6581, 6582, 6583, 6584, 6585, 6586, 6587, 6588, 6589, 6590, 6591, 6592, 6593, 6594, 6595, 6596, 6597, 6598, 6599, 6600, 6601, 6602, 6603, 6604, 6605, 6606, 6607, 6608, 4526, 4527, 4528, 4529, 4530, 4531, 4532, 4533, 4534, 4535, 4536, 4537, 4538, 4539, 4540, 4541, 9043, 9044, 9045, 9046, 9047, 9048, 9049, 9050, 9051, 9052, 9053, 9054, 9055, 9056, 9057, 9058}

local GoldBauTile = {231, 4405, 4406, 4407, 4408, 4409, 4410, 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4418, 4419, 4420, 4421, 4566, 4567, 4568, 4569, 4570, 4571, 4572, 4573, 4574, 4575, 4576, 4577, 4578, 4579, 7356, 670, 6580, 6581, 6582, 6583, 6584, 6585, 6586, 6587, 6588, 6589, 6590, 6591, 6592, 6593, 6594, 6595, 6596, 6597, 6598, 6599, 6600, 6601, 6602, 6603, 6604, 6605, 6606, 6607, 6608, 3263, 5815}

local BlockProfitItem = {16983, 16984, 16985, 16986, 16987, 16988, 16989, 16990, 16991, 16992, 16993, 16994, 16995, 16996, 16997, 16998, 16999, 17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 17009, 17010, 17011, 17012, 17013, 17014, 17015, 17016, 17017, 17018, 17019, 17020, 17021, 17022, 17023, 17024, 17025, 17026, 17027, 17028, 17029, 17030, 17031, 17032, 17033, 17034, 17035, 17036, 17037, 17038, 17039, 17040, 17041, 17042, 17043, 17044, 17045, 17046, 17047, 17048, 17049, 17050, 17065, 17066, 17067, 17068, 17069, 17070, 17071, 17072, 17073, 17074, 17075, 17076, 17077, 17078, 17079, 17080, 17081, 17082, 17083, 17084, 17108, 17109, 17110}

---- FUNÇÕES
-- isWalkableTerraTile <== Envia somente para pisos do tipo terra
-- isWalkableTerraJungleTile <== Envia somente para pisos do tipo terra e grama escura
-- isWalkablePraiaTile <== Envia somente para pisos do tipo areia na praia etc
-- isWalkablePedraTile <== Envia somente para pisos do tipo pedra
-- isWalkableSnowTile <== Envia somente para pisos do tipo neve

function isWalkableGoldBauTile(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water and isOnlySurfTile(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or not isInArray(GoldBauTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or isInArray(BlockProfitItem, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

function getRandomPosGoldBauTile(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    if not isWalkableGoldBauTile(pos, true, true, true, true) then
        pos = getRandomPosGoldBauTile(f, t)
    end
    return pos
end

function isWalkableAllBauTile(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water and isOnlySurfTile(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or not isInArray(AllBauTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or isInArray(BlockProfitItem, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

function getRandomPosAllBauTile(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    if not isWalkableAllBauTile(pos, true, true, true, true) then
        pos = getRandomPosAllBauTile(f, t)
    end
    return pos
end

function isWalkableGramaTile(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water and isOnlySurfTile(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or not isInArray(GramaTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or isInArray(BlockProfitItem, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

function getRandomPosGramaTile(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    if not isWalkableGramaTile(pos, true, true, true, true) then
        pos = getRandomPosGramaTile(f, t)
    end
    return pos
end

function isWalkableSnowTile(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water and isOnlySurfTile(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or not isInArray(SnowTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or isInArray(BlockProfitItem, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

function getRandomPosSnowTile(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    if not isWalkableSnowTile(pos, true, true, true, true) then
        pos = getRandomPosSnowTile(f, t)
    end
    return pos
end

function isWalkablePedraTile(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water and isOnlySurfTile(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or not isInArray(PedraTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or isInArray(BlockProfitItem, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

function getRandomPosPedraTile(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    if not isWalkablePedraTile(pos, true, true, true, true) then
        pos = getRandomPosPedraTile(f, t)
    end
    return pos
end

function isWalkablePraiaTile(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water and isOnlySurfTile(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or not isInArray(PraiaTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or isInArray(BlockProfitItem, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

function getRandomPosPraiaTile(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    if not isWalkablePraiaTile(pos, true, true, true, true) then
        pos = getRandomPosPraiaTile(f, t)
    end
    return pos
end

function isWalkableTerraJungleTile(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water and isOnlySurfTile(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or not isInArray(TerraJungleTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or isInArray(BlockProfitItem, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

function getRandomPosTerraJungleTile(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    if not isWalkableTerraJungleTile(pos, true, true, true, true) then
        pos = getRandomPosTerraJungleTile(f, t)
    end
    return pos
end

function isWalkableTerraTile(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water and isOnlySurfTile(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or not isInArray(TerraTile, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) or isInArray(BlockProfitItem, getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

function getRandomPosTerraTile(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    if not isWalkableTerraTile(pos, true, true, true, true) then
        pos = getRandomPosTerraTile(f, t)
    end
    return pos
end