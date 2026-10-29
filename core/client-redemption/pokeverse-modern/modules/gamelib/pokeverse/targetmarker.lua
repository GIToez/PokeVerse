-- The mark under the attacked, followed or hovered creature (Options > Interface > Target marker).
-- The battle list and game_battle mark a creature with Creature:showStaticSquare(color); in the ring
-- styles that colour picks a ring drawn under the creature (Creature:setCrosshairTexture) instead of
-- Redemption's square. Colours that aren't the battle list's keep the square.

TargetMarker = {}

local RINGS = {
    classic = {
        target = '/images/ui/crosshair-target',
        follow = '/images/ui/crosshair-follow',
        idle = '/images/ui/crosshair-idle',
    },
    pokeball = {
        target = '/images/game/target/pokeball-target',
        follow = '/images/game/target/pokeball-follow',
        idle = '/images/game/target/pokeball-idle',
    },
}

-- UICreatureButton's colours (the Battle List restyle in gamelib.patch picks them), not hovered and hovered
local KINDS = { onTargeted = 'target', onFollowed = 'follow', onIdle = 'idle' }
local states

local function stateOf(color)
    if not states then
        states = {}
        local colors = UICreatureButton and UICreatureButton.getCreatureButtonColors() or {}
        for kind, state in pairs(KINDS) do
            for _, value in pairs(colors[kind] or {}) do
                states[tostring(value):upper()] = state
            end
        end
    end
    return states[tostring(color):upper()]
end

local style = 'classic'
local nativeShow = Creature.showStaticSquare
local nativeHide = Creature.hideStaticSquare
-- creature id: colour, to restyle the marked creatures when the option changes
local marked = {}

local function apply(creature, color)
    local rings = RINGS[style]
    local state = stateOf(color)
    if rings and state then
        nativeHide(creature)
        creature:setCrosshairTexture(rings[state])
    else
        creature:setCrosshairTexture('~')
        nativeShow(creature, color)
    end
end

function Creature:showStaticSquare(color)
    marked[self:getId()] = color
    apply(self, color)
end

-- the target or followed creature keeps its mark whatever asks to hide it: the Battle List resets its rows
-- (and their creatures' marks) as creatures come and go, even while hidden behind Pokegear's Nearby
local function keptKind(creature)
    local attacking = g_game.getAttackingCreature()
    if attacking and attacking:getId() == creature:getId() then
        return 'onTargeted'
    end
    local following = g_game.getFollowingCreature()
    if following and following:getId() == creature:getId() then
        return 'onFollowed'
    end
end

local function keptColor(creature)
    local kind = keptKind(creature)
    local colors = kind and UICreatureButton and UICreatureButton.getCreatureButtonColors()
    return colors and colors[kind] and colors[kind].notHovered
end

function Creature:hideStaticSquare()
    local color = keptColor(self)
    if color then
        self:showStaticSquare(color)
        return
    end
    marked[self:getId()] = nil
    self:setCrosshairTexture('~')
    nativeHide(self)
end

-- a creature that left the screen and came back is a fresh mark-less creature to the client
local function onAppear(creature)
    local color = keptColor(creature)
    if color then
        creature:showStaticSquare(color)
    end
end
connect(Creature, { onAppear = onAppear })

-- 'classic', 'pokeball' or 'square'
function TargetMarker.setStyle(value)
    style = value
    for id, color in pairs(marked) do
        local creature = g_map.getCreatureById(id)
        if creature then
            apply(creature, color)
        else
            marked[id] = nil
        end
    end
end

function TargetMarker.getStyle()
    return style
end
