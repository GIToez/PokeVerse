-- The item categories the Bag (098-bag.lua), the PC stash (067-pc.lua) and the GTS (066-gts.lua) share:
-- the hand-made ones here (plus what config/itemCategories.lua adds to them), the generated ones
-- (scripts/make-item-categories.py), and Other last. An item is in the first
-- category that lists it; anything in none counts as Other. The GTS leaves out what can't be traded
-- (NOT_TRADED) and the empty ones.

ItemCategories = {}

local function range(first, last, except)
    local ret = {}
    for id = first, last do
        if (not except or not except[id]) then
            ret[#ret + 1] = id
        end
    end
    return ret
end

local function join(...)
    local ret = {}
    for _, list in ipairs({ ... }) do
        for _, id in ipairs(list) do
            ret[#ret + 1] = id
        end
    end
    return ret
end

local LIST = {
    { name = "Poke Balls", items = { 12157, 12161, 12165, 30136, 19029, 19033, 19037, 19041, 19045, 19049, 19053,
        19057, 19061 } },
    { name = "Medicine", items = { 12244, 12247, 12245, 12246, 12248, 12249, 12250, 13653, 13819 } },
    { name = "Evolution Stones", items = range(18083, 18088) },
    { name = "Held Items", items = join(range(23513, 23531), range(30137, 30144), range(30152, 30153),
        range(24724, 25048)) }, -- the last range: the Elemental Stones
    { name = "Mega Stones", items = range(MEGA_FIRST_STONE_ID, MEGA_LAST_STONE_ID) },
    { name = "Berries", items = join(range(13182, 13186), range(14766, 14770), range(30145, 30150)) },
    { name = "Berry Seeds", items = join(range(13176, 13180), range(14791, 14795)) },
    { name = "Vitamins", items = range(23450, 23457, { [23454] = true }) },
    { name = "Technical Machines", items = join(range(17337, 17383), range(18912, 18931), range(24716, 24723),
        range(29157, 29172)) },
}
-- Pokemon go on the GTS as Pokemon, a bag would go with what's inside it, key and quest items stay with
-- their trainer
for _, category in ipairs(LIST) do
    category.items = join(category.items, ITEM_CATEGORIES_MORE[category.name] or {})
end
local NOT_TRADED = { ["Key Items"] = true, ["Quest Items"] = true, ["Pokemon"] = true, ["Bags"] = true }
for _, category in ipairs(ITEM_CATEGORIES_EXTRA) do
    LIST[#LIST + 1] = { name = category.name, icon = category.icon, items = category.items,
        trade = not NOT_TRADED[category.name], generated = true }
end
LIST[#LIST + 1] = { name = "Other", items = {} }

-- only ids of a real item with that name are kept (the ball range has gaps), each in one category
local OF = {}
for index, category in ipairs(LIST) do
    local items = {}
    for _, id in ipairs(category.items) do
        local info = getItemInfo(id)
        if (info and info.name ~= "" and not OF[id]) then
            items[#items + 1] = id
            OF[id] = index
        end
    end
    category.items = items
    category.icon = category.icon or items[1]
    if (category.trade == nil) then
        category.trade = true
    end
end

ItemCategories.LIST = LIST
ItemCategories.OTHER = #LIST

-- the category's index in LIST, Other for an item in none
ItemCategories.of = function(itemid)
    return OF[itemid] or ItemCategories.OTHER
end

ItemCategories.nameOf = function(itemid)
    return LIST[ItemCategories.of(itemid)].name
end
