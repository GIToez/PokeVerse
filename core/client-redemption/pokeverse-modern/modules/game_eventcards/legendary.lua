-- Wild legendary cards. The server (078-wildLegendaries.lua) sends JSON on ExtendedIds.Legendary:
-- type "spawn" and the trainer's own "reward" get the big banner; "sighting", "flee", "end" and
-- "caught" get a small card.
local SIGHTING_EVERY = 300

local lastSighting = {}

local function money(value)
    local text = tostring(math.floor(tonumber(value) or 0))
    while true do
        local formatted, count = text:gsub('^(%d+)(%d%d%d)', '%1,%2')
        text = formatted
        if count == 0 then
            return '$' .. text
        end
    end
end

local function minutesLeft(endsAt)
    local left = math.floor(((tonumber(endsAt) or 0) - os.time()) / 60 + 0.5)
    if left <= 0 then
        return nil
    end
    if left >= 120 then
        return tr('%d h', math.floor(left / 60 + 0.5))
    end
    return tr('%d min', left)
end

local function near(area)
    return area and area ~= '' and tr('near %s', area) or tr('somewhere in Kanto')
end

local END_CARDS = {
    defeated = function(data)
        local trainers = data.trainers or {}
        return tr('%s defeated', data.species), #trainers > 0 and tr('By %s.', table.concat(trainers, ', ')) or
            tr('The wild %s was defeated.', data.species), '#ffd75a'
    end,
    fled = function(data)
        return tr('%s flew away', data.species), tr('Nobody beat it in time.'), '#b8c4dc'
    end,
    staff = function(data)
        return tr('%s left', data.species), tr('The wild %s was sent away.', data.species), '#b8c4dc'
    end,
}

local HANDLERS = {
    spawn = function(data)
        local chips = {
            { label = tr('Strength'), value = (tonumber(data.tier) or 1) >= 2 and tr('Tier 2') or tr('Tier 1'),
              color = (tonumber(data.tier) or 1) >= 2 and '#ff8a8a' or '#ffd75a', width = 84 },
            { label = tr('Recommended'), value = tr('Level %d+', tonumber(data.level) or 50), width = 96 },
        }
        local left = minutesLeft(data.endsAt)
        if left then
            table.insert(chips, { label = tr('Flies off in'), value = left, width = 90 })
        end
        showBanner({
            name = data.species,
            highlight = tr('Wild Legendary!'),
            subtitle = tr('Appeared %s. It roams, so follow the sightings.', near(data.area)),
            look = tonumber(data.look),
            number = tonumber(data.dexNumber),
            chips = chips,
        })
    end,

    reward = function(data)
        local candies = tonumber(data.rareCandy) or 0
        showBanner({
            name = data.species,
            highlight = tr('Defeated!'),
            highlightColor = '#7cf08c',
            subtitle = tr('You dealt %d%% of the damage. Your reward:', tonumber(data.share) or 0),
            look = tonumber(data.look),
            number = tonumber(data.dexNumber),
            chips = {
                { label = tr('Rare Candy'), value = 'x' .. candies, color = '#7cf08c', width = 84 },
                { label = tr('Money'), value = money(data.money), color = '#7cf08c', width = 96 },
                { label = tr('Pokepedia'), value = tr('+1 defeat'), color = '#7cf08c', width = 90 },
            },
        })
    end,

    sighting = function(data)
        local now = os.time()
        if (lastSighting[data.species] or 0) + SIGHTING_EVERY > now then
            return
        end
        lastSighting[data.species] = now
        showCard({
            title = tr('%s spotted', data.species),
            text = tr('Seen %s.', near(data.area)),
            number = tonumber(data.dexNumber),
            color = '#8fd3ff',
        })
    end,

    flee = function(data)
        lastSighting[data.species] = os.time()
        showCard({
            title = tr('%s fled!', data.species),
            text = tr('Now %s with %d%% health.', near(data.area), math.floor((tonumber(data.health) or 0) + 0.5)),
            number = tonumber(data.dexNumber),
            color = '#ffb347',
        })
    end,

    ['end'] = function(data)
        local build = END_CARDS[data.reason]
        if not build then
            return
        end
        local title, text, color = build(data)
        showCard({ title = title, text = text, number = tonumber(data.dexNumber), color = color })
    end,

    caught = function(data)
        showCard({
            title = tr('%s caught!', data.species),
            text = tr('%s caught the wild %s.', data.trainer or tr('A trainer'), data.species),
            number = tonumber(data.dexNumber),
            color = '#7cf08c',
            duration = 8000,
        })
    end,
}

local function onLegendary(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or type(data.species) ~= 'string' or not HANDLERS[data.type] then
        g_logger.warning('EventCards: invalid legendary message')
        return
    end
    HANDLERS[data.type](data)
end

function initLegendary()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Legendary, onLegendary)
end

function terminateLegendary()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Legendary)
    lastSighting = {}
end
