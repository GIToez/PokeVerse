if (AnniversaryEvent) then
    return
end

AnniversaryEvent = {}

-- todo
local STATIC_BIG_CAKE_ITEMID = 24707
AnniversaryEvent.STATIC_BIG_CAKE_POS = { x = 5307, y = 312, z = 6 }
local EVIL_BIG_CAKE_NAME = "Mad Big Cake"

local CAKES_HP = {
    ["Minion Cake"] = 10,
    ["Minion Party Cake"] = 10,
    ["Minion Decorated Cake"] = 10,
    ["Minion Cream Cake"] = 10,
    ["Minion Chocolate Cake"] = 10,
    [EVIL_BIG_CAKE_NAME] = 1000
}
local MINIONS_NAME = { "Minion Cake", "Minion Party Cake", "Minion Decorated Cake", "Minion Cream Cake", "Minion Chocolate Cake" }

AnniversaryEvent.DAMAGE_MINIMUM_RATIO = 0.5
AnniversaryEvent.DROP_CHANCE = 30000 -- 40%
AnniversaryEvent.SURPRISE_BAG_ITEMIDS = { 24710, 24711, 24712 }
AnniversaryEvent.MINION_KILL_REQ_COUNT = 60

AnniversaryEvent.SURPRISE_BAG_REWARDS = {
    { itemid = 27935, count = 1, chance = 20000, unique = true }, -- anniversary token
    { itemid = 30152, count = 1, chance = 300, unique = nil }, -- lucky egg
    { itemid = 30153, count = 1, chance = 300, unique = nil }, -- exp share

    { itemid = 27937, count = 1, chance = 500, unique = nil }, -- PSoul backpack
    { itemid = 27847, count = 1, chance = 500, unique = nil }, -- e backpack
    { itemid = 27848, count = 1, chance = 500, unique = nil }, -- k backpack
    { itemid = 27849, count = 1, chance = 500, unique = nil }, -- l backpack
    { itemid = 27850, count = 1, chance = 500, unique = nil }, -- m backpack
    { itemid = 27851, count = 1, chance = 500, unique = nil }, -- n backpack
    { itemid = 27852, count = 1, chance = 500, unique = nil }, -- o backpack
    { itemid = 27853, count = 1, chance = 500, unique = nil }, -- p backpack
    { itemid = 27854, count = 1, chance = 500, unique = nil }, -- s backpack
    { itemid = 27855, count = 1, chance = 500, unique = nil }, -- u backpack
    { itemid = 13215, count = 1, chance = 500, unique = nil }, -- pikachu backpack
    { itemid = 10521, count = 1, chance = 500, unique = nil }, -- moon backpack

    { itemid = 24698, count = 1, chance = 1000, unique = nil }, -- cake ticket
    { itemid = 24699, count = 1, chance = 1000, unique = nil }, -- power green ticket
    { itemid = 24700, count = 1, chance = 1000, unique = nil }, -- power light purple ticket
    { itemid = 24701, count = 1, chance = 1000, unique = nil }, -- power pink ticket
    { itemid = 24702, count = 1, chance = 1000, unique = nil }, -- power purple ticket
    { itemid = 24703, count = 1, chance = 1000, unique = nil }, -- power red ticket
    { itemid = 24704, count = 1, chance = 1000, unique = nil }, -- power yellow ticket
    { itemid = 27778, count = 1, chance = 1000, unique = nil }, -- fire legendary paint ticket
    { itemid = 27782, count = 1, chance = 1000, unique = nil }, -- green vision paint ticket
    { itemid = 27794, count = 1, chance = 1000, unique = nil }, -- ocean vision paint ticket
    { itemid = 27802, count = 1, chance = 1000, unique = nil }, -- purple vision paint ticket
    { itemid = 14449, count = 1, chance = 1000, unique = nil }, -- star paint ticket
    { itemid = 14450, count = 1, chance = 1000, unique = nil }, -- yereblu paint ticket

    { itemid = 27786, count = 1, chance = 1000, unique = nil }, -- l paint ticket
    { itemid = 27790, count = 1, chance = 1000, unique = nil }, -- o paint ticket
    { itemid = 27798, count = 1, chance = 1000, unique = nil }, -- p paint ticket
    { itemid = 27806, count = 1, chance = 1000, unique = nil }, -- s paint ticket
    { itemid = 27810, count = 1, chance = 1000, unique = nil }, -- u paint ticket

    { itemid = 14440, count = 1, chance = 1000, unique = nil }, -- letter P
    { itemid = 14441, count = 1, chance = 1000, unique = nil }, -- letter S
    { itemid = 14439, count = 1, chance = 1000, unique = nil }, -- letter O
    { itemid = 14442, count = 1, chance = 1000, unique = nil }, -- letter U
    { itemid = 14438, count = 1, chance = 1000, unique = nil }, -- letter L

    { itemid = 27936, count = 1, chance = 14000, unique = nil }, -- big anniversary cake

    { itemid = 27819, count = 1, chance = 1000, unique = nil }, -- letter A
    { itemid = 27820, count = 1, chance = 1000, unique = nil }, -- letter B
    { itemid = 27821, count = 1, chance = 1000, unique = nil }, -- letter C
    { itemid = 27822, count = 1, chance = 1000, unique = nil }, -- letter D
    { itemid = 27823, count = 1, chance = 1000, unique = nil }, -- letter E
    { itemid = 27824, count = 1, chance = 1000, unique = nil }, -- letter !
    { itemid = 27825, count = 1, chance = 1000, unique = nil }, -- letter F
    { itemid = 27826, count = 1, chance = 1000, unique = nil }, -- letter G
    { itemid = 27827, count = 1, chance = 1000, unique = nil }, -- letter H
    { itemid = 27828, count = 1, chance = 1000, unique = nil }, -- letter I
    { itemid = 27829, count = 1, chance = 1000, unique = nil }, -- letter ?
    { itemid = 27830, count = 1, chance = 1000, unique = nil }, -- letter J
    { itemid = 27831, count = 1, chance = 1000, unique = nil }, -- letter K
    { itemid = 27832, count = 1, chance = 1000, unique = nil }, -- letter M
    { itemid = 27833, count = 1, chance = 1000, unique = nil }, -- letter N
    { itemid = 27834, count = 1, chance = 1000, unique = nil }, -- letter Q
    { itemid = 27835, count = 1, chance = 1000, unique = nil }, -- letter R
    { itemid = 27836, count = 1, chance = 1000, unique = nil }, -- letter T
    { itemid = 27837, count = 1, chance = 1000, unique = nil }, -- letter V
    { itemid = 27838, count = 1, chance = 1000, unique = nil }, -- letter W
    { itemid = 27839, count = 1, chance = 1000, unique = nil }, -- letter X
    { itemid = 27840, count = 1, chance = 1000, unique = nil }, -- letter Y
    { itemid = 27841, count = 1, chance = 1000, unique = nil }, -- letter Z

    { itemid = 27842, count = 1, chance = 500, unique = nil }, -- PSoul letter L
    { itemid = 27843, count = 1, chance = 500, unique = nil }, -- PSoul letter O
    { itemid = 27844, count = 1, chance = 500, unique = nil }, -- PSoul letter P
    { itemid = 27845, count = 1, chance = 500, unique = nil }, -- PSoul letter S
    { itemid = 27846, count = 1, chance = 500, unique = nil }, -- PSoul letter U

    { itemid = 24715, count = 1, chance = 100, unique = nil }, -- explorer clothes kit

    { itemid = 24676, count = 1, chance = 300, unique = nil }, -- cake tapestry
    { itemid = 24675, count = 1, chance = 300, unique = nil }, -- cake backpack
    { itemid = 24674, count = 1, chance = 300, unique = nil }, -- snow flake tapestry

    --{itemid = 6278, count = 1, chance = 2000, unique = nil}, -- cake
    --{itemid = 6279, count = 1, chance = 2000, unique = nil}, -- decorated cake
    --{itemid = 6280, count = 1, chance = 2000, unique = nil}, -- party cake
    --{itemid = 6394, count = 1, chance = 2000, unique = nil}, -- cream cake
    --    {itemid = 6576, count = 1, chance = 1000, unique = nil}, -- fireworks rocket
    --    {itemid = 6577, count = 1, chance = 1000, unique = nil}, -- green balloon
    --    {itemid = 6578, count = 1, chance = 1000, unique = nil}, -- party hat
    --    {itemid = 6572, count = 1, chance = 1000, unique = nil}, -- party trumpet
    --    {itemid = 2114, count = 1, chance = 200, unique = nil}, -- piggy bank

    --    {itemid = 27811, count = 1, chance = 200, unique = nil}, -- ash advanced generations doll
    --    {itemid = 27812, count = 1, chance = 200, unique = nil}, -- ash best wishes doll
    --    {itemid = 27813, count = 1, chance = 200, unique = nil}, -- ash diamond pearl doll
    --    {itemid = 27814, count = 1, chance = 200, unique = nil}, -- ash pokemon league doll
    --    {itemid = 27815, count = 1, chance = 200, unique = nil}, -- ash xy doll
    --    {itemid = 5796, count = 1, chance = 1000, unique = nil}, -- Dice
}
local MAGIC_FLAME_ITEMID = 24713
local MAGIC_FLAME_POSITIONS = {
    {
        { x = 5273, y = 311, z = 5 },
        { x = 5274, y = 311, z = 5 },
        { x = 5273, y = 312, z = 5 },
        { x = 5274, y = 312, z = 5 },
        { x = 5273, y = 313, z = 5 },
        { x = 5274, y = 313, z = 5 },
    },
    {
        { x = 5306, y = 278, z = 5 },
        { x = 5306, y = 279, z = 5 },
        { x = 5307, y = 278, z = 5 },
        { x = 5307, y = 279, z = 5 },
        { x = 5308, y = 278, z = 5 },
        { x = 5308, y = 279, z = 5 },
    },
    {
        { x = 5340, y = 311, z = 5 },
        { x = 5341, y = 311, z = 5 },
        { x = 5340, y = 312, z = 5 },
        { x = 5341, y = 312, z = 5 },
        { x = 5340, y = 313, z = 5 },
        { x = 5341, y = 313, z = 5 },
    },
    {
        { x = 5306, y = 345, z = 5 },
        { x = 5306, y = 346, z = 5 },
        { x = 5307, y = 345, z = 5 },
        { x = 5307, y = 346, z = 5 },
        { x = 5308, y = 345, z = 5 },
        { x = 5308, y = 346, z = 5 },
    }
}

local CHANGES = {
    {
        addItemId = 7538,
        positions = {
            { x = 5292, y = 328, z = 7 },
            { x = 5294, y = 324, z = 7 },
            { x = 5300, y = 293, z = 7 },
            { x = 5322, y = 302, z = 7 },
            { x = 5329, y = 306, z = 7 },
            { x = 5323, y = 329, z = 7 },
            { x = 5317, y = 328, z = 7 },
            { x = 5312, y = 332, z = 7 },
            { x = 5306, y = 327, z = 7 },
            { x = 5303, y = 326, z = 7 },
            { x = 5302, y = 326, z = 7 },
            { x = 5338, y = 318, z = 7 },
            { x = 5288, y = 313, z = 7 },
            { x = 5304, y = 284, z = 7 },
            { x = 5304, y = 316, z = 6 },
            { x = 5295, y = 319, z = 6 },
            { x = 5318, y = 307, z = 6 },
            { x = 5319, y = 319, z = 6 },
            { x = 5318, y = 319, z = 6 },
            { x = 5278, y = 308, z = 5 },
            { x = 5303, y = 342, z = 5 },
            { x = 5303, y = 349, z = 5 },
            { x = 5337, y = 316, z = 5 },
            { x = 5307, y = 352, z = 6 },
            { x = 5341, y = 319, z = 6 },
            { x = 5340, y = 319, z = 6 },
            { x = 5338, y = 318, z = 6 },
            {x = 5306, y = 285, z = 6},
        }
    },
    {
        addItemId = 7539,
        positions = {
            {x = 5290, y = 325, z = 7},
            {x = 5279, y = 315, z = 7},
            {x = 5308, y = 331, z = 7},
            {x = 5320, y = 319, z = 7},
            {x = 5322, y = 311, z = 7},
            {x = 5322, y = 312, z = 7},
            {x = 5308, y = 289, z = 7},
            {x = 5313, y = 281, z = 7},
            {x = 5300, y = 289, z = 7},
            {x = 5297, y = 293, z = 7},
            {x = 5328, y = 303, z = 7},
            {x = 5329, y = 329, z = 7},
            {x = 5296, y = 306, z = 6},
            {x = 5296, y = 318, z = 6},
            {x = 5304, y = 309, z = 6},
            {x = 5311, y = 316, z = 6},
            {x = 5319, y = 306, z = 6},
            {x = 5303, y = 275, z = 5},
            {x = 5303, y = 282, z = 5},
            {x = 5270, y = 308, z = 5},
            {x = 5312, y = 342, z = 5},
            {x = 5337, y = 308, z = 5},
            {x = 5314, y = 346, z = 6},
            {x = 5344, y = 318, z = 6},
            {x = 5314, y = 278, z = 6},
            {x = 5279, y = 309, z = 6},
        }
    },
    {
        removeItemId = 10504,
        addItemId = 10506,
        positions = {
            {x = 5279, y = 325, z = 7},
            {x = 5287, y = 327, z = 7},
            {x = 5290, y = 325, z = 7},
            {x = 5294, y = 324, z = 7},
            {x = 5295, y = 327, z = 7},
            {x = 5292, y = 328, z = 7},
            {x = 5301, y = 332, z = 7},
            {x = 5312, y = 332, z = 7},
            {x = 5313, y = 335, z = 7},
            {x = 5317, y = 328, z = 7},
            {x = 5321, y = 325, z = 7},
            {x = 5323, y = 329, z = 7},
            {x = 5329, y = 329, z = 7},
            {x = 5331, y = 327, z = 7},
            {x = 5336, y = 323, z = 7},
            {x = 5329, y = 306, z = 7},
            {x = 5324, y = 304, z = 7},
            {x = 5328, y = 303, z = 7},
            {x = 5322, y = 302, z = 7},
            {x = 5323, y = 301, z = 7},
            {x = 5326, y = 293, z = 7},
            {x = 5322, y = 290, z = 7},
            {x = 5321, y = 289, z = 7},
            {x = 5318, y = 292, z = 7},
            {x = 5315, y = 285, z = 7},
            {x = 5300, y = 289, z = 7},
            {x = 5301, y = 291, z = 7},
            {x = 5300, y = 293, z = 7},
            {x = 5297, y = 293, z = 7},
            {x = 5278, y = 294, z = 7},
            {x = 5282, y = 296, z = 7},
            {x = 5279, y = 297, z = 7},
            {x = 5283, y = 307, z = 7},
            {x = 5264, y = 309, z = 7},
        }
    },
    {
        removeItemId = 2767,
        addItemId = 2784,
        positions = {
            {x = 5275, y = 321, z = 7},
            {x = 5280, y = 319, z = 7},
            {x = 5286, y = 327, z = 7},
            {x = 5293, y = 323, z = 7},
            {x = 5302, y = 331, z = 7},
            {x = 5299, y = 341, z = 7},
            {x = 5298, y = 344, z = 7},
            {x = 5297, y = 346, z = 7},
            {x = 5311, y = 352, z = 7},
            {x = 5312, y = 351, z = 7},
            {x = 5314, y = 336, z = 7},
            {x = 5323, y = 324, z = 7},
            {x = 5329, y = 330, z = 7},
            {x = 5331, y = 328, z = 7},
            {x = 5332, y = 326, z = 7},
            {x = 5350, y = 315, z = 7},
            {x = 5348, y = 311, z = 7},
            {x = 5325, y = 306, z = 7},
            {x = 5323, y = 305, z = 7},
            {x = 5317, y = 299, z = 7},
            {x = 5318, y = 300, z = 7},
            {x = 5314, y = 286, z = 7},
            {x = 5314, y = 274, z = 7},
            {x = 5296, y = 281, z = 7},
            {x = 5298, y = 284, z = 7},
            {x = 5300, y = 286, z = 7},
            {x = 5298, y = 291, z = 7},
            {x = 5287, y = 294, z = 7},
            {x = 5282, y = 295, z = 7},
            {x = 5277, y = 295, z = 7},
            {x = 5278, y = 297, z = 7},
            {x = 5280, y = 297, z = 7},
            {x = 5281, y = 297, z = 7},
            {x = 5282, y = 304, z = 7},
            {x = 5266, y = 306, z = 7},
            {x = 5265, y = 308, z = 7},
            {x = 5263, y = 311, z = 7},
        }
    },
    {
        removeItemId = 2768,
        addItemId = 2770,
        positions = {
            {x = 5277, y = 323, z = 7},
            {x = 5277, y = 324, z = 7},
            {x = 5292, y = 324, z = 7},
            {x = 5295, y = 322, z = 7},
            {x = 5293, y = 327, z = 7},
            {x = 5292, y = 329, z = 7},
            {x = 5300, y = 333, z = 7},
            {x = 5298, y = 343, z = 7},
            {x = 5310, y = 353, z = 7},
            {x = 5310, y = 331, z = 7},
            {x = 5311, y = 337, z = 7},
            {x = 5314, y = 335, z = 7},
            {x = 5315, y = 334, z = 7},
            {x = 5316, y = 329, z = 7},
            {x = 5318, y = 327, z = 7},
            {x = 5321, y = 323, z = 7},
            {x = 5321, y = 327, z = 7},
            {x = 5323, y = 325, z = 7},
            {x = 5324, y = 330, z = 7},
            {x = 5328, y = 330, z = 7},
            {x = 5337, y = 322, z = 7},
            {x = 5350, y = 318, z = 7},
            {x = 5347, y = 317, z = 7},
            {x = 5332, y = 307, z = 7},
            {x = 5326, y = 303, z = 7},
            {x = 5323, y = 290, z = 7},
            {x = 5320, y = 290, z = 7},
            {x = 5313, y = 273, z = 7},
            {x = 5315, y = 283, z = 7},
            {x = 5314, y = 285, z = 7},
            {x = 5313, y = 287, z = 7},
            {x = 5311, y = 288, z = 7},
            {x = 5312, y = 290, z = 7},
            {x = 5310, y = 288, z = 7},
            {x = 5302, y = 288, z = 7},
            {x = 5300, y = 290, z = 7},
            {x = 5299, y = 290, z = 7},
            {x = 5300, y = 294, z = 7},
            {x = 5295, y = 294, z = 7},
            {x = 5291, y = 296, z = 7},
            {x = 5285, y = 296, z = 7},
            {x = 5279, y = 298, z = 7},
            {x = 5286, y = 308, z = 7},
            {x = 5285, y = 308, z = 7},
            {x = 5284, y = 309, z = 7},
            {x = 5281, y = 306, z = 7},
            {x = 5266, y = 305, z = 7},
            {x = 5265, y = 309, z = 7},
        }
    }
}

local BOSS_PROTECTION_CONDITION = createConditionObject(CONDITION_INVULNERABLE, -1)
AnniversaryEvent.EVENT_STATES = { UNSTARTED = 0, KILLING_MINIONS = 1, KILLING_BOSS = 2 }

AnniversaryEvent.getEventState = function()
    local r = getStorage(GLOBAL_STORAGES.EVENT_ANNIVERSARY_STATE)
    return r > -1 and r or 0
end

AnniversaryEvent.setEventState = function(v)
    doSetStorage(GLOBAL_STORAGES.EVENT_ANNIVERSARY_STATE, v)
end

AnniversaryEvent.getMinionKillCount = function()
    local r = getStorage(GLOBAL_STORAGES.EVENT_ANNIVERSARY_KILL_COUNT)
    return r > -1 and r or 0
end

AnniversaryEvent.setMinionKillCount = function(count)
    doSetStorage(GLOBAL_STORAGES.EVENT_ANNIVERSARY_KILL_COUNT, count)
end

AnniversaryEvent.doSummonBoss = function()
    local item = getTileItemById(AnniversaryEvent.STATIC_BIG_CAKE_POS, STATIC_BIG_CAKE_ITEMID)
    if (not isItem(item)) then
        log(LOG_TYPES.ERROR, "AnniversaryEvent.doSummonBoss - Can't find cake item at pos", item)
        return
    end

    doRemoveItem(item.uid)
    local m = doCreateMonster(EVIL_BIG_CAKE_NAME, AnniversaryEvent.STATIC_BIG_CAKE_POS, false)
    setCreatureMaxHealth(m, CAKES_HP[EVIL_BIG_CAKE_NAME])
    doCreatureChangeHealth(m, CAKES_HP[EVIL_BIG_CAKE_NAME])
    AnniversaryEvent.doActivateBossProtection()

    for _, mainPos in pairs(MAGIC_FLAME_POSITIONS) do
        for __, pos in pairs(mainPos) do
            doCreateItem(MAGIC_FLAME_ITEMID, 1, pos)
        end
    end

    AnniversaryEvent.setEventState(AnniversaryEvent.EVENT_STATES.KILLING_BOSS)
    doBroadcastMessage("The Evil Cake has appeared!")
end

AnniversaryEvent.onMinionKill = function(cid, killer)
    if (isCreature(killer)) then
        killer = getCreatureMaster(killer)
        if (isPlayer(killer)) then
            doPlayerSafeAddItem(killer, 27935, 1, true, true) -- Anniversary token
        end
    end

    AnniversaryEvent.doCheckTempleMinions()

    local eventState = AnniversaryEvent.getEventState()
    if (eventState ~= AnniversaryEvent.EVENT_STATES.KILLING_MINIONS) then
        return
    end

    local count = AnniversaryEvent.getMinionKillCount() + 1
    AnniversaryEvent.setMinionKillCount(count)

    if (count >= AnniversaryEvent.MINION_KILL_REQ_COUNT) then
        AnniversaryEvent.doSummonBoss()
    else
        doBroadcastMessage(string.format("Anniversary Event - Cake Minion Defeat Status: %s/%s", count, AnniversaryEvent.MINION_KILL_REQ_COUNT))
    end
end

AnniversaryEvent.onBossKill = function(cid, killer)
    AnniversaryEvent.undoCenarionTransformation()
    -- the kill count back to 0 too, or doCheckTempleMinions keeps bringing temple minions back
    AnniversaryEvent.doResetState()
    for _, group in pairs(MAGIC_FLAME_POSITIONS) do
        for _, pos in pairs(group) do
            local flame = getTileItemById(pos, MAGIC_FLAME_ITEMID)
            if (isItem(flame)) then
                doRemoveItem(flame.uid)
            end
        end
    end
    doCreateItem(STATIC_BIG_CAKE_ITEMID, 1, AnniversaryEvent.STATIC_BIG_CAKE_POS)
end

AnniversaryEvent.doActivateBossProtection = function()
    local boss = getCreatureByName(EVIL_BIG_CAKE_NAME)
    if (isMonster(boss) and not getCreatureCondition(boss, CONDITION_INVULNERABLE)) then
        doAddCondition(boss, BOSS_PROTECTION_CONDITION)
    end
end

AnniversaryEvent.doRemoveBossProtection = function()
    local boss = getCreatureByName(EVIL_BIG_CAKE_NAME)
    if (isMonster(boss) and getCreatureCondition(boss, CONDITION_INVULNERABLE)) then
        doRemoveCondition(boss, CONDITION_INVULNERABLE)
    end
end

AnniversaryEvent.onMagicFlameStepIn = function(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    if (isPlayer(cid)) then
        doSendMagicEffect(position, EFFECT_CAKE)
        for _, mainPos in pairs(MAGIC_FLAME_POSITIONS) do
            local mainFound = false
            for __, pos in pairs(mainPos) do
                local specs = getSpectators(pos, 1, 1)
                if (specs) then
                    for _, spec in pairs(specs) do
                        if (isPlayer(spec)) then
                            mainFound = true
                            break
                        end
                    end
                end
            end

            if (not mainFound) then
                return
            end
        end

        AnniversaryEvent.doRemoveBossProtection()
    end
end

AnniversaryEvent.onMagicFlameStepOut = function(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    if (isPlayer(cid)) then
        doSendMagicEffect(position, EFFECT_CAKE)
        for _, mainPos in pairs(MAGIC_FLAME_POSITIONS) do
            local mainFound = false
            for __, pos in pairs(mainPos) do
                local specs = getSpectators(pos, 1, 1)
                if (specs) then
                    for _, spec in pairs(specs) do
                        if (isPlayer(spec) and spec ~= cid) then
                            mainFound = true
                            break
                        end
                    end
                end
            end

            if (not mainFound) then
                AnniversaryEvent.doActivateBossProtection()
            end
        end
    end
end

AnniversaryEvent.doCenarionTransformation = function()
    for _, change in pairs(CHANGES) do
        if (change.removeItemId) then
            for __, changePos in pairs(change.positions) do
                local item = getTileItemById(changePos, change.removeItemId)
                if (isItem(item)) then
                    doTransformItem(item.uid, change.addItemId)
                    doSendMagicEffect(changePos, EFFECT_POFF)
                end
            end

        else
            for __, changePos in pairs(change.positions) do
                doCreateItem(change.addItemId, 1, changePos)
                doSendMagicEffect(changePos, EFFECT_POFF)
            end
        end
    end
end

AnniversaryEvent.undoCenarionTransformation = function()
    for _, change in pairs(CHANGES) do
        if (change.addItemId) then
            for __, changePos in pairs(change.positions) do
                local item = getTileItemById(changePos, change.addItemId)
                if (isItem(item)) then
                    if (change.removeItemId) then
                        doTransformItem(item.uid, change.removeItemId)
                    else
                        doRemoveItem(item.uid)
                    end
                    doSendMagicEffect(changePos, EFFECT_POFF)
                end
            end

        else
            for __, changePos in pairs(change.positions) do
                doCreateItem(change.removeItemId, 1, changePos)
                doSendMagicEffect(changePos, EFFECT_POFF)
            end
        end
    end
end

AnniversaryEvent.onPlayerKill = function(cid, target, lastHit)
    if (not isPokemonName(getCreatureName(target)) or
            getCreatureDamageRatioByMaster(target, cid) < AnniversaryEvent.DAMAGE_MINIMUM_RATIO) then
        return
    end

    if (getRandom(RANDOM_CHANCE_MIN, RANDOM_CHANCE_MAX) <= AnniversaryEvent.DROP_CHANCE * (getMonsterLevel(target) / 100)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have found a surprise bag.")
        doPlayerSafeAddItem(cid, table.random(AnniversaryEvent.SURPRISE_BAG_ITEMIDS), 1, true, true)
    end
end

AnniversaryEvent.onPlayerUseSurpriseBag = function(cid, item)
    doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.ANNIVERSARY_PRESENT)

    doRemoveItem(item.uid, 1)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_YELLOW)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Surprise bag contains: ")

    local nothing = true
    while (nothing) do
        for _, item in pairs(AnniversaryEvent.SURPRISE_BAG_REWARDS) do
            if (not item.chance or getRandom(RANDOM_CHANCE_MIN, RANDOM_CHANCE_MAX) <= item.chance) then
                local count = ((item.mincount and item.maxcount) and getRandom(item.mincount, item.maxcount) or
                        item.count)
                nothing = false
                doPlayerSafeAddItem(cid, item.itemid, count, true, item.unique)
                doDatalogAnniversaryDrops(getPlayerGUID(cid), item.itemid, count, os.time())
                if (item.onReceive) then
                    item.onReceive(cid)
                end
            end
        end
    end

    if (nothing) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Nothing.")
    end
end

AnniversaryEvent.onSpawn = function(cid) -- Just an ugly hack to fix the hp
    local name = getCreatureName(cid)
    if (CAKES_HP[name]) then
        setCreatureMaxHealth(cid, CAKES_HP[name])
        doCreatureChangeHealth(cid, CAKES_HP[name])
    end
end

AnniversaryEvent.doStartEvent = function()
    -- doExecuteRaid refuses while another raid runs: the state stays UNSTARTED so the hourly
    -- globalevent tries again
    if (AnniversaryEvent.getEventState() == AnniversaryEvent.EVENT_STATES.UNSTARTED and executeRaid("anniversary")) then
        AnniversaryEvent.setMinionKillCount(0)
        AnniversaryEvent.setEventState(AnniversaryEvent.EVENT_STATES.KILLING_MINIONS)
    end
end


AnniversaryEvent.doCheckTempleMinions = function()
    if (AnniversaryEvent.getMinionKillCount() >= AnniversaryEvent.MINION_KILL_REQ_COUNT) then
        for k, v in pairs(MAGIC_FLAME_POSITIONS) do
            for _, pos in pairs(v) do
                local specs = getSpectators(pos, 20, 20)
                local found = false
                if (specs) then
                    for _, spec in pairs(specs) do
                        if (isPokemonWild(spec)) then
                            found = true
                            break
                        end
                    end
                end

                if (not found) then
                    doCreateMonster(table.random(MINIONS_NAME), pos, false)
                end

                break
            end
        end
    end
end

AnniversaryEvent.doResetState = function()
    AnniversaryEvent.setMinionKillCount(0)
    AnniversaryEvent.setEventState(AnniversaryEvent.EVENT_STATES.UNSTARTED)
end

-- The cake town is only open while the Anniversary holiday runs (EventCalendar, or /anniversary on).
-- Its only way in is the sign and teleport in the Union Room: the map has them, and they are taken
-- away while the holiday is off, like a decoration. The town's own teleports all lead back to EXIT_POS.
AnniversaryEvent.ENTRANCE = {
    sign = { pos = { x = 4721, y = 132, z = 7 }, itemid = 1438, text = "Event Anniversary" },
    teleport = { pos = { x = 4721, y = 133, z = 7 }, itemid = 17440, dest = { x = 5285, y = 302, z = 7 } },
}
AnniversaryEvent.EXIT_POS = { x = 4721, y = 138, z = 7 }
AnniversaryEvent.AREA = { center = { x = 5307, y = 315 }, rangeX = 45, rangeY = 45, floors = { 5, 6, 7 } }

AnniversaryEvent.isEntranceOpen = function()
    return isItem(getTileItemById(AnniversaryEvent.ENTRANCE.teleport.pos, AnniversaryEvent.ENTRANCE.teleport.itemid))
end

AnniversaryEvent.setEntrance = function(open)
    local sign, teleport = AnniversaryEvent.ENTRANCE.sign, AnniversaryEvent.ENTRANCE.teleport
    local signItem = getTileItemById(sign.pos, sign.itemid)
    local teleportItem = getTileItemById(teleport.pos, teleport.itemid)
    if (open) then
        if (not isItem(signItem)) then
            local uid = doCreateItem(sign.itemid, 1, sign.pos)
            if (uid) then
                doItemSetAttribute(uid, "text", sign.text)
            end
        end
        if (not isItem(teleportItem)) then
            doCreateTeleport(teleport.itemid, teleport.dest, teleport.pos)
        end
    else
        if (isItem(signItem)) then
            doRemoveItem(signItem.uid)
        end
        if (isItem(teleportItem)) then
            doRemoveItem(teleportItem.uid)
        end
    end
end

-- Everything in the cake town: players are sent back to the Union Room, the cakes removed
local function forEachInArea(fn)
    local area = AnniversaryEvent.AREA
    for _, z in ipairs(area.floors) do
        for _, creature in ipairs(getSpectators({ x = area.center.x, y = area.center.y, z = z }, area.rangeX, area.rangeY) or {}) do
            fn(creature)
        end
    end
end

-- reset: clear the invasion but leave the players and the entrance alone
AnniversaryEvent.close = function(reset)
    local players = 0
    forEachInArea(function(creature)
        if (isPlayer(creature)) then
            if (reset) then
                return
            end
            doTeleportThing(creature, AnniversaryEvent.EXIT_POS, false)
            doSendMagicEffect(AnniversaryEvent.EXIT_POS, EFFECT_TELEPORT)
            doPlayerSendTextMessage(creature, MESSAGE_STATUS_CONSOLE_BLUE, "The cake town is closed until the next Anniversary.")
            players = players + 1
        elseif (isMonster(creature) and CAKES_HP[getCreatureName(creature)] and not isPlayer(getCreatureMaster(creature))) then
            doRemoveCreature(creature)
        end
    end)

    if (AnniversaryEvent.getEventState() ~= AnniversaryEvent.EVENT_STATES.UNSTARTED) then
        AnniversaryEvent.undoCenarionTransformation()
    end
    for _, group in pairs(MAGIC_FLAME_POSITIONS) do
        for _, pos in pairs(group) do
            local flame = getTileItemById(pos, MAGIC_FLAME_ITEMID)
            if (isItem(flame)) then
                doRemoveItem(flame.uid)
            end
        end
    end
    if (not isItem(getTileItemById(AnniversaryEvent.STATIC_BIG_CAKE_POS, STATIC_BIG_CAKE_ITEMID))) then
        doCreateItem(STATIC_BIG_CAKE_ITEMID, 1, AnniversaryEvent.STATIC_BIG_CAKE_POS)
    end
    AnniversaryEvent.doResetState()
    if (not reset) then
        AnniversaryEvent.setEntrance(false)
    end
    return players
end

AnniversaryEvent.open = function()
    AnniversaryEvent.setEntrance(true)
    AnniversaryEvent.doStartEvent()
end

-- Staff can show the entrance for a while without the holiday (/anniversary show), to test it
AnniversaryEvent.PREVIEW_MINUTES = 30
AnniversaryEvent.PREVIEW_MAX_MINUTES = 24 * 60
local KEY_PREVIEW = GLOBAL_STORAGES.ANNIVERSARY_PREVIEW

-- When the preview ends (0: until /anniversary hide), or nil
AnniversaryEvent.getPreview = function()
    local endsAt = tonumber(tostring(getStorage(KEY_PREVIEW) or ""):match("^m;(%d+)$"))
    if (endsAt and (endsAt == 0 or endsAt > os.time())) then
        return endsAt
    end
    return nil
end

AnniversaryEvent.setPreview = function(minutes)
    local value = minutes and string.format("m;%d", minutes == 0 and 0 or os.time() + minutes * 60) or "m;"
    doSetStorage(KEY_PREVIEW, value)
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        KEY_PREVIEW, getConfigValue("worldId") or 0, db.escapeString(value)))
end

-- "event" (the holiday runs), "preview" (only the entrance, for staff) or "off"
AnniversaryEvent.mode = function()
    if (EventCalendar.isActive("anniversary")) then
        return "event"
    end
    return AnniversaryEvent.getPreview() and "preview" or "off"
end

-- Timothy Kelvin and Murray Aaron stand in the Union Room only while the holiday (or a staff
-- preview) is on. The map spawn puts them there year-round; this takes them away afterwards.
AnniversaryEvent.NPCS = { "Timothy Kelvin", "Murray Aaron" }
AnniversaryEvent.NPC_SPOTS = {
    ["Timothy Kelvin"] = { x = 4720, y = 141, z = 7 },
    ["Murray Aaron"] = { x = 4722, y = 132, z = 7 },
}

local npcSpots = nil
AnniversaryEvent.getNpcSpots = function()
    if (npcSpots) then
        return npcSpots
    end
    npcSpots = {}
    local wanted, found = {}, {}
    for _, name in ipairs(AnniversaryEvent.NPCS) do
        wanted[name] = true
    end
    local file = io.open(string.format("data/world/%s-spawn.xml", getConfigValue("mapName") or "map"), "r")
    if (file) then
        local text = file:read("*a")
        file:close()
        for cx, cy, body in text:gmatch('<spawn centerx="(%d+)" centery="(%d+)"[^>]*>(.-)</spawn>') do
            for name, x, y, z in body:gmatch('<npc name="([^"]+)" x="(%-?%d+)" y="(%-?%d+)" z="(%d+)"') do
                if (wanted[name]) then
                    found[name] = true
                    npcSpots[#npcSpots + 1] = {
                        name = name,
                        pos = { x = tonumber(cx) + tonumber(x), y = tonumber(cy) + tonumber(y), z = tonumber(z) },
                    }
                end
            end
        end
    end
    for _, name in ipairs(AnniversaryEvent.NPCS) do
        if (not found[name] and AnniversaryEvent.NPC_SPOTS[name]) then
            npcSpots[#npcSpots + 1] = { name = name, pos = AnniversaryEvent.NPC_SPOTS[name] }
        end
    end
    return npcSpots
end

local npcsShown = nil
AnniversaryEvent.syncNpcs = function()
    local active = AnniversaryEvent.mode() ~= "off"
    if (npcsShown == active) then
        return
    end
    npcsShown = active
    for _, spot in ipairs(AnniversaryEvent.getNpcSpots()) do
        local npc = getNpcAtPosition(spot.pos, spot.name)
        if (active and not npc) then
            doCreateNpc(spot.name, spot.pos, false)
        elseif (not active and npc) then
            doRemoveCreature(npc)
        end
    end
end

-- Called every second by EventCalendar.onThink, and by /anniversary with now = true. Every Lua
-- state keeps its own `synced`; open and close are safe to repeat, so the states agree.
local synced = nil
AnniversaryEvent.sync = function(now)
    local mode = AnniversaryEvent.mode()
    if (mode == synced and not now) then
        return mode
    end
    local startup = synced == nil and not now
    local was = synced
    synced = mode
    if (mode == "event") then
        AnniversaryEvent.open()
    elseif (mode == "preview") then
        if (was == "event") then
            AnniversaryEvent.close(true)
        end
        AnniversaryEvent.setEntrance(true)
    elseif (startup) then
        AnniversaryEvent.setEntrance(false)
    else
        AnniversaryEvent.syncNpcs()
        return mode, AnniversaryEvent.close()
    end
    AnniversaryEvent.syncNpcs()
    return mode
end
