-- The badges next to the NPCs' name plates: the trainer's quest mark first (gold "!" to start, grey "?"
-- under way, gold "?" to hand in), then what the NPC does (NpcRoles, npc_roles.lua, and the trade and
-- battle icons the server sends). An NPC with more than one badge shows them in turn. The server's own
-- quest bubble is static (it shows on quests long done), so the trainer's marks replace it. Clients
-- older than the Creature:setIcon binding keep the server's icons.
local CYCLE_MS = 1300
local ICON_ID = 1 -- any icon but none, for NPCs the server sends without one: the texture is set right after
local BLANK = '/modules/game_quests/images/npc_none'
-- the server's icons (CREATURE_ICONS) that tell what an NPC does
local SERVER_ROLES = { [2] = 'shop', [4] = 'shop', [6] = 'battle' }

local marks = {} -- npc name -> 'available' | 'active' | 'ready'
local shown = {} -- creature id -> { creature, badges, index }
local serverIcons = {} -- creature id -> the icon the server sent
local applying = false
local baseOnIconChange
local cycleEvent

local function badgesOf(creature)
    local name = creature:getName()
    local list, seen = {}, {}
    local mark = marks[name]
    if mark then
        list[#list + 1] = IMAGES .. 'npc_quest_' .. mark
    end
    local roles = { unpack(NpcRoles[name] or {}) }
    roles[#roles + 1] = SERVER_ROLES[serverIcons[creature:getId()] or 0]
    for _, role in ipairs(roles) do
        if not seen[role] then
            seen[role] = true
            list[#list + 1] = IMAGES .. 'npc_' .. role
        end
    end
    return list
end

local function setBadge(creature, path)
    applying = true
    if path and creature:getIcon() == 0 then
        creature:setIcon(ICON_ID)
    end
    if creature:getIcon() ~= 0 then
        creature:setIconTexture(path or BLANK)
    end
    applying = false
end

local function supported(creature)
    return creature.setIcon ~= nil and creature:isNpc()
end

local function apply(creature)
    if not supported(creature) then
        return
    end
    local id = creature:getId()
    local badges = badgesOf(creature)
    local entry = shown[id] or { creature = creature, index = 1 }
    entry.badges = badges
    if entry.index > #badges then
        entry.index = 1
    end
    shown[id] = entry
    setBadge(creature, badges[entry.index])
end

local function onIconChange(self, iconId)
    if not applying and supported(self) then
        serverIcons[self:getId()] = iconId
        apply(self)
        return
    end
    return baseOnIconChange(self, iconId)
end

local function cycle()
    cycleEvent = scheduleEvent(cycle, CYCLE_MS)
    for _, entry in pairs(shown) do
        if #entry.badges > 1 then
            entry.index = entry.index % #entry.badges + 1
            setBadge(entry.creature, entry.badges[entry.index])
        end
    end
end

local function applyAll()
    for _, entry in pairs(shown) do
        apply(entry.creature)
    end
    -- NPCs on screen before the marks came
    local player = g_game.getLocalPlayer()
    if player and player:getPosition() then
        for _, creature in ipairs(g_map.getSpectators(player:getPosition(), true)) do
            if creature:isNpc() then
                apply(creature)
            end
        end
    end
end

function setMarks(list)
    marks = {}
    for name, mark in pairs(list) do
        if mark == 'available' or mark == 'active' or mark == 'ready' then
            marks[name] = mark
        end
    end
    applyAll()
end

function getMark(name)
    return marks[name]
end

local function onAppear(creature)
    if creature:isNpc() then
        apply(creature)
    end
end

local function onDisappear(creature)
    shown[creature:getId()] = nil
end

function initIcons()
    baseOnIconChange = Creature.onIconChange
    Creature.onIconChange = onIconChange
    connect(Creature, { onAppear = onAppear, onDisappear = onDisappear })
    cycleEvent = scheduleEvent(cycle, CYCLE_MS)
end

function resetIcons()
    marks, shown, serverIcons = {}, {}, {}
end

function terminateIcons()
    disconnect(Creature, { onAppear = onAppear, onDisappear = onDisappear })
    if Creature.onIconChange == onIconChange then
        Creature.onIconChange = baseOnIconChange
    end
    removeEvent(cycleEvent)
    cycleEvent = nil
    marks, shown, serverIcons = {}, {}, {}
end
