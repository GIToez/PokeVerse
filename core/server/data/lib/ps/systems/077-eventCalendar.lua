if (EventCalendar) then
    return
end

-- The event calendar: the holidays, which follow rules and run on their own, the server events
-- (bonus events on a schedule, such as the double weekends) and the events staff add with
-- /calendar (event_calendar table). Every running event's bonuses multiply together and
-- with the staff events of /doubleexp and /bonusshiny: exp and shiny go through the C++ event
-- multipliers (ServerExpEvent.onThink, ShinyEvent.onThink), loot through setLootEventMultiplier,
-- breeding through Daycare, fishing through Fishing. The old holiday content (Easter, the summer
-- festival, the anniversary, Halloween and Christmas) only runs while its holiday is on.
--
-- Holidays start and end at EVENT_HOUR (06:00 server time, when most players are around; the
-- daily restart is at midnight and does not move them) unless noted. Moon
-- phases use Meeus' formula (Astronomical Algorithms, ch. 49), equinoxes and solstices ch. 27,
-- Easter the Western computus. Staff can force a holiday on or off with /calendar holiday.
--
-- Clients get EXTENDED_IDS.CALENDAR JSON: {type="status"} (what runs now and what comes next) at
-- login and when that changes, and {type="range"} with the events and moon phases of the dates a
-- client asks for ({action="range", from, to}). All times are unix times; clients show them in the
-- player's own time zone.

EventCalendar = {}

local DAY, HOUR = 24 * 60 * 60, 60 * 60
local EVENT_HOUR = 6
local CACHE_SECONDS = 60
local MAX_RANGE = 62 * DAY

EventCalendar.LAUNCH_YEAR = 2026 -- the first anniversary is the one a year later
EventCalendar.BONUS_KINDS = { "exp", "shiny", "loot", "breeding", "fishing" }
EventCalendar.BONUS_LABELS = { exp = "kill EXP", shiny = "shiny chance", loot = "loot", breeding = "Day Care egg chance",
                               fishing = "fishing bites" }
EventCalendar.MAX_BONUS = 10

local GIFT_STORAGE_BASE = 61000000 -- + the holiday's index: the start time of the last occurrence given
local FORCED_KEY_BASE = GLOBAL_STORAGES.EVENT_CALENDAR_FORCED -- + index: 1 forced on, 0 forced off, -1 automatic

---------------------------------------------------------------------------------------------------
-- Dates
---------------------------------------------------------------------------------------------------

local function at(year, month, day, hour, minute)
    return os.time({ year = year, month = month, day = day, hour = hour or EVENT_HOUR, min = minute or 0, sec = 0 })
end

local function dateOf(time)
    return os.date("*t", time)
end

-- The EVENT_HOUR that opens the day `time` falls on (server time), shifted by `days`
local function dayStartOf(time, days)
    local d = dateOf(time)
    return at(d.year, d.month, d.day + (days or 0), EVENT_HOUR)
end

local function jdToUnix(jd)
    return math.floor((jd - 2440587.5) * DAY + 0.5)
end

local RAD = math.pi / 180
local sin = function(degrees) return math.sin(degrees * RAD) end

-- The new moon (full = false) or full moon (full = true) of lunation k; k = 0 is the new moon of
-- January 6, 2000
function EventCalendar.moonTime(k, full)
    if (full) then
        k = k + 0.5
    end
    local T = k / 1236.85
    local T2, T3, T4 = T * T, T * T * T, T * T * T * T
    local jde = 2451550.09766 + 29.530588861 * k + 0.00015437 * T2 - 0.000000150 * T3 + 0.00000000073 * T4
    local E = 1 - 0.002516 * T - 0.0000074 * T2
    local M = 2.5534 + 29.10535670 * k - 0.0000014 * T2 - 0.00000011 * T3
    local Mp = 201.5643 + 385.81693528 * k + 0.0107582 * T2 + 0.00001238 * T3 - 0.000000058 * T4
    local F = 160.7108 + 390.67050284 * k - 0.0016118 * T2 - 0.00000227 * T3 + 0.000000011 * T4
    local O = 124.7746 - 1.56375588 * k + 0.0020672 * T2 + 0.00000215 * T3

    local c
    if (full) then
        c = -0.40614 * sin(Mp) + 0.17302 * E * sin(M) + 0.01614 * sin(2 * Mp) + 0.01043 * sin(2 * F)
            + 0.00734 * E * sin(Mp - M) - 0.00515 * E * sin(Mp + M) + 0.00209 * E * E * sin(2 * M)
    else
        c = -0.40720 * sin(Mp) + 0.17241 * E * sin(M) + 0.01608 * sin(2 * Mp) + 0.01039 * sin(2 * F)
            + 0.00739 * E * sin(Mp - M) - 0.00514 * E * sin(Mp + M) + 0.00208 * E * E * sin(2 * M)
    end
    c = c - 0.00111 * sin(Mp - 2 * F) - 0.00057 * sin(Mp + 2 * F) + 0.00056 * E * sin(2 * Mp + M)
        - 0.00042 * sin(3 * Mp) + 0.00042 * E * sin(M + 2 * F) + 0.00038 * E * sin(M - 2 * F)
        - 0.00024 * E * sin(2 * Mp - M) - 0.00017 * sin(O) - 0.00007 * sin(Mp + 2 * M)
        + 0.00004 * sin(2 * Mp - 2 * F) + 0.00004 * sin(3 * M) + 0.00003 * sin(Mp + M - 2 * F)
        + 0.00003 * sin(2 * Mp + 2 * F) - 0.00003 * sin(Mp + M + 2 * F) + 0.00003 * sin(Mp - M + 2 * F)
        - 0.00002 * sin(Mp - M - 2 * F) - 0.00002 * sin(3 * Mp + M) + 0.00002 * sin(4 * Mp)
    return jdToUnix(jde + c)
end

local LUNATION = 29.530588861 * DAY
local FIRST_NEW_MOON = jdToUnix(2451550.09766)

-- New and full moons from `from` to `to`, in order: { time, full }
function EventCalendar.moonPhases(from, to)
    local phases = {}
    local k = math.floor((from - FIRST_NEW_MOON) / LUNATION) - 1
    while (true) do
        for _, full in ipairs({ false, true }) do
            local time = EventCalendar.moonTime(k, full)
            if (time > to) then
                return phases
            elseif (time >= from) then
                phases[#phases + 1] = { time = time, full = full }
            end
        end
        k = k + 1
    end
end

-- Equinoxes and solstices (Meeus ch. 27, mean terms, minutes off): 1 March, 2 June, 3 September, 4 December
function EventCalendar.seasonTime(year, season)
    local Y = (year - 2000) / 1000
    local terms = {
        { 2451623.80984, 365242.37404, 0.05169, -0.00411, -0.00057 },
        { 2451716.56767, 365241.62603, 0.00325, 0.00888, -0.00030 },
        { 2451810.21715, 365242.01767, -0.11575, 0.00337, 0.00078 },
        { 2451900.05952, 365242.74049, -0.06223, -0.00823, 0.00032 },
    }
    local t = terms[season]
    return jdToUnix(t[1] + t[2] * Y + t[3] * Y * Y + t[4] * Y * Y * Y + t[5] * Y * Y * Y * Y)
end

-- Western Easter Sunday: month, day
function EventCalendar.easter(year)
    local a, b, c = year % 19, math.floor(year / 100), year % 100
    local d, e = math.floor(b / 4), b % 4
    local f = math.floor((b + 8) / 25)
    local g = math.floor((b - f + 1) / 3)
    local h = (19 * a + b - d - g + 15) % 30
    local i, k = math.floor(c / 4), c % 4
    local l = (32 + 2 * e + 2 * i - h - k) % 7
    local m = math.floor((a + 11 * h + 22 * l) / 451)
    local n = h + l - 7 * m + 114
    return math.floor(n / 31), n % 31 + 1
end

-- Lunar New Year's day (China, UTC+8): the second new moon after the December solstice. Returns year, month, day.
function EventCalendar.lunarNewYear(year)
    local solstice = EventCalendar.seasonTime(year - 1, 4)
    local phases = EventCalendar.moonPhases(solstice, solstice + 70 * DAY)
    local count = 0
    for _, phase in ipairs(phases) do
        if (not phase.full) then
            count = count + 1
            if (count == 2) then
                local d = os.date("!*t", phase.time + 8 * HOUR)
                return d.year, d.month, d.day
            end
        end
    end
end

-- The full moon nearest the September equinox
function EventCalendar.harvestMoon(year)
    local equinox = EventCalendar.seasonTime(year, 3)
    local best
    for _, phase in ipairs(EventCalendar.moonPhases(equinox - 20 * DAY, equinox + 20 * DAY)) do
        if (phase.full and (not best or math.abs(phase.time - equinox) < math.abs(best - equinox))) then
            best = phase.time
        end
    end
    return best
end

-- The night (20:00 to 06:00 server time) nearest a time
local function nightAround(time)
    local d = dateOf(time - HOUR + 12 * HOUR)
    local starts = at(d.year, d.month, d.day - 1, 20)
    return starts, at(d.year, d.month, d.day, EVENT_HOUR)
end

local function days(year, month, day, count)
    return { { at(year, month, day), at(year, month, day + count) } }
end

---------------------------------------------------------------------------------------------------
-- Holidays
---------------------------------------------------------------------------------------------------

-- dates(year) returns the {starts, ends} of the occurrences that start in that year
EventCalendar.HOLIDAYS = {
    { id = "newyear", name = "New Year", color = "#f0d070",
      description = "1.5x kill EXP, and a New Year gift when you log in.",
      bonuses = { exp = 1.5 }, gift = { money = 10000, items = { { 14463, 1 } } },
      dates = function(year) return days(year, 12, 31, 3) end },
    { id = "lunarnewyear", name = "Lunar New Year", color = "#e05050",
      description = "1.5x loot, and a red envelope with money when you log in.",
      bonuses = { loot = 1.5 }, gift = { money = 8888 },
      dates = function(year)
          local y, m, d = EventCalendar.lunarNewYear(year)
          return y and days(y, m, d, 3) or {}
      end },
    { id = "valentines", name = "Valentine's", color = "#f080b0",
      description = "2x Day Care egg chance, Luvdisc bite more often while fishing, and a rare candy when you log in.",
      bonuses = { breeding = 2 }, luvdisc = true, gift = { items = { { 14463, 1 } } },
      dates = function(year) return days(year, 2, 13, 3) end },
    { id = "pokemonday", name = "Pokemon Day", color = "#f0c040",
      description = "2x shiny chance, and a rare candy when you log in.",
      bonuses = { shiny = 2 }, gift = { items = { { 14463, 1 } } },
      dates = function(year) return days(year, 2, 27, 1) end },
    { id = "easter", name = "Easter", color = "#a0e070", content = "easter",
      description = "Wild Pokemon drop Easter eggs full of prizes.",
      dates = function(year)
          local month, day = EventCalendar.easter(year)
          return days(year, month, day - 2, 4)
      end },
    { id = "summer", name = "Summer Festival", color = "#50c0f0", content = "summer",
      description = "1.5x fishing bites, and reward chests for playing.",
      bonuses = { fishing = 1.5 },
      dates = function(year) return days(year, 7, 1, 31) end },
    { id = "harvestmoon", name = "Harvest Moon", color = "#e09040", berries = true,
      description = "Berry trees grow twice as fast and give up to 8 berries, wild Pokemon drop more berries and seed boxes give twice the seeds.",
      dates = function(year)
          local moon = EventCalendar.harvestMoon(year)
          return moon and { { dayStartOf(moon, -1), dayStartOf(moon, 2) } } or {}
      end },
    { id = "clefairy", name = "Clefairy Night", color = "#f0b0d0", clefairy = true, night = true,
      description = "Full moon: Clefairy and Clefable gather in Mt. Moon, and may drop a Moon Stone.",
      dates = function(year)
          local list = {}
          for _, phase in ipairs(EventCalendar.moonPhases(at(year, 1, 1, 0), at(year + 1, 1, 1, 0) - 1)) do
              if (phase.full) then
                  list[#list + 1] = { nightAround(phase.time) }
              end
          end
          return list
      end },
    { id = "anniversary", name = "Anniversary", color = "#c080f0", content = "anniversary",
      description = "2x kill EXP and 2x shiny chance, the cake invasion, surprise bags, and an anniversary gift when you log in.",
      bonuses = { exp = 2, shiny = 2 }, gift = { items = { { 24710, 1 }, { 14463, 1 } } },
      dates = function(year) return days(year, 10, 3, 3) end },
    { id = "halloween", name = "Halloween", color = "#f08030", content = "halloween",
      description = "The Halloween quests, the witch's cauldron and spooky Pokemon.",
      dates = function(year) return days(year, 10, 24, 9) end },
    { id = "christmas", name = "Christmas", color = "#60d080", content = "christmas",
      description = "Presents from wild Pokemon, and Christmas Pokemon in the wild.",
      dates = function(year) return days(year, 12, 18, 10) end },
}

local HOLIDAY_BY_ID = {}
for index, holiday in ipairs(EventCalendar.HOLIDAYS) do
    holiday.index = index
    HOLIDAY_BY_ID[holiday.id] = holiday
end

EventCalendar.getHoliday = function(id)
    return HOLIDAY_BY_ID[id]
end

-- nil = automatic, true = forced on, false = forced off
EventCalendar.getForced = function(id)
    local holiday = HOLIDAY_BY_ID[id]
    local value = holiday and tonumber(getStorage(FORCED_KEY_BASE + holiday.index)) or -1
    if (value == 1) then
        return true
    elseif (value == 0) then
        return false
    end
    return nil
end

local function store(key, value)
    doSetStorage(key, value)
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        key, getConfigValue("worldId") or 0, db.escapeString(tostring(value))))
end

EventCalendar.setForced = function(id, value)
    local holiday = HOLIDAY_BY_ID[id]
    if (not holiday) then
        return false
    end
    store(FORCED_KEY_BASE + holiday.index, value == true and 1 or (value == false and 0 or -1))
    EventCalendar.invalidate()
    return true
end

---------------------------------------------------------------------------------------------------
-- Seasons (northern, real time): each one starts at the EVENT_HOUR after its equinox or solstice
---------------------------------------------------------------------------------------------------

EventCalendar.SEASONS = {
    { id = "spring", name = "Spring", color = "#9ad870" },
    { id = "summer", name = "Summer", color = "#f0c850" },
    { id = "autumn", name = "Autumn", color = "#e08a40" },
    { id = "winter", name = "Winter", color = "#a8d0f0" },
}
local SEASON_BY_ID = {}
for index, season in ipairs(EventCalendar.SEASONS) do
    season.index = index
    SEASON_BY_ID[season.id] = season
end
local SEASON_KEY = GLOBAL_STORAGES.EVENT_CALENDAR_SEASON

EventCalendar.getSeason = function(id)
    return SEASON_BY_ID[id]
end

local function seasonStart(year, index)
    local moment = EventCalendar.seasonTime(year, index)
    local start = dayStartOf(moment)
    return start >= moment and start or dayStartOf(moment, 1)
end

-- The natural seasons that overlap from..to: { season, startsAt, endsAt }
function EventCalendar.seasonSpans(from, to)
    local starts = {}
    for year = dateOf(from).year - 1, dateOf(to).year + 1 do
        for index = 1, 4 do
            starts[#starts + 1] = { season = EventCalendar.SEASONS[index], startsAt = seasonStart(year, index) }
        end
    end
    local spans = {}
    for i = 1, #starts - 1 do
        local span = starts[i]
        span.endsAt = starts[i + 1].startsAt
        if (span.endsAt > from and span.startsAt <= to) then
            spans[#spans + 1] = span
        end
    end
    return spans
end

-- nil = automatic, or the season staff forced
EventCalendar.getForcedSeason = function()
    return EventCalendar.SEASONS[tonumber(getStorage(SEASON_KEY)) or 0]
end

EventCalendar.setForcedSeason = function(id)
    local season = id and SEASON_BY_ID[id]
    store(SEASON_KEY, season and season.index or 0)
end

local naturalSpan = nil

-- What season it is: the season, when it started and ends, and whether staff forced it
function EventCalendar.currentSeason(now)
    now = now or os.time()
    local span = naturalSpan
    if (not span or now < span.startsAt or now >= span.endsAt) then
        local spans = EventCalendar.seasonSpans(now, now)
        span = spans[#spans]
        naturalSpan = span
    end
    local forced = EventCalendar.getForcedSeason()
    if (forced) then
        return { season = forced, startsAt = span.startsAt, endsAt = span.endsAt, forced = true }
    end
    return { season = span.season, startsAt = span.startsAt, endsAt = span.endsAt, forced = false }
end

EventCalendar.seasonId = function(now)
    return EventCalendar.currentSeason(now).season.id
end

---------------------------------------------------------------------------------------------------
-- Staff events (event_calendar)
---------------------------------------------------------------------------------------------------

-- "exp=2,shiny=1.5" -> { exp = 2, shiny = 1.5 }, or nil and why not
function EventCalendar.parseBonuses(text)
    local bonuses, any = {}, false
    for kind, value in tostring(text or ""):lower():gmatch("(%a+)%s*=%s*(%d+%.?%d*)x?") do
        if (not EventCalendar.BONUS_LABELS[kind]) then
            return nil, "Unknown bonus " .. kind .. ". Use " .. table.concat(EventCalendar.BONUS_KINDS, ", ") .. "."
        end
        value = tonumber(value)
        if (not value or value <= 1 or value > EventCalendar.MAX_BONUS) then
            return nil, "A bonus must be above 1x and at most " .. EventCalendar.MAX_BONUS .. "x."
        end
        bonuses[kind], any = value, true
    end
    if (not any) then
        return nil, "Give at least one bonus, such as exp=2 or loot=1.5."
    end
    return bonuses
end

function EventCalendar.formatBonuses(bonuses)
    local parts = {}
    for _, kind in ipairs(EventCalendar.BONUS_KINDS) do
        if (bonuses and bonuses[kind]) then
            parts[#parts + 1] = string.format("%gx %s", bonuses[kind], EventCalendar.BONUS_LABELS[kind])
        end
    end
    return table.concat(parts, ", ")
end

local staffCache, staffCachedAt = nil, 0

local function loadStaffEvents()
    if (staffCache and os.time() - staffCachedAt < CACHE_SECONDS) then
        return staffCache
    end
    local list = {}
    local result = db.getResult("SELECT `id`, `name`, `rule`, `starts_at`, `length`, `nth`, `bonuses` FROM `event_calendar`" ..
        " WHERE `world_id` = " .. (getConfigValue("worldId") or 0) .. " ORDER BY `id`;")
    if (result:getID() ~= -1) then
        repeat
            list[#list + 1] = { id = result:getDataInt("id"), name = result:getDataString("name"),
                                rule = result:getDataString("rule"), startsAt = result:getDataInt("starts_at"),
                                length = result:getDataInt("length"), nth = result:getDataInt("nth"),
                                bonuses = EventCalendar.parseBonuses(result:getDataString("bonuses")) or {} }
        until not result:next()
        result:free()
    end
    staffCache, staffCachedAt = list, os.time()
    return list
end

EventCalendar.getStaffEvents = loadStaffEvents

-- Friday evening to Monday morning (server time), for the weekend whose Friday is on `friday` (a date table)
local WEEKEND_START_HOUR, WEEKEND_END_HOUR = 17, 5

local function weekendOf(friday)
    return { at(friday.year, friday.month, friday.day, WEEKEND_START_HOUR),
             at(friday.year, friday.month, friday.day + 3, WEEKEND_END_HOUR) }
end

-- The weekends that take turns, Friday evening to Monday morning, counted from the weekend of
-- `first`: the ones of `year` where this event's turn of `turns` comes up
local function weekendTurns(year, first, turns, turn)
    local list = {}
    local firstNoon = at(first.year, first.month, first.day, 12)
    for day = 1, 366 do
        local d = dateOf(at(year, 1, day, 12))
        if (d.year ~= year) then
            break
        end
        local noon = at(d.year, d.month, d.day, 12)
        -- rounded, so a clock change in between doesn't shift the count
        local weeks = math.floor((noon - firstNoon) / (7 * DAY) + 0.5)
        if (d.wday == 6 and noon >= firstNoon and weeks % turns == turn) then
            list[#list + 1] = weekendOf(d)
        end
    end
    return list
end

-- Server events: bonus events the calendar runs on its own, next to the ones staff add, with no
-- holiday content, gifts or decorations. dates(year) returns the {starts, ends} of the occurrences
-- that start in that year. For now the four double events take turns on the weekends
local ROTATION_FIRST = { year = 2026, month = 10, day = 16 }

local function rotation(turn)
    return function(year) return weekendTurns(year, ROTATION_FIRST, 4, turn) end
end

EventCalendar.SERVER_EVENTS = {
    { id = "doubleexp", name = "Double EXP", color = "#70c0f0", description = "2x kill EXP.",
      bonuses = { exp = 2 }, dates = rotation(0) },
    { id = "doubleshiny", name = "Double Shiny", color = "#f0d850", description = "2x shiny chance.",
      bonuses = { shiny = 2 }, dates = rotation(1) },
    { id = "doubleeggs", name = "Double Eggs", color = "#f0a0c0", description = "2x Day Care egg chance.",
      bonuses = { breeding = 2 }, dates = rotation(2) },
    { id = "doubleloot", name = "Double Loot", color = "#a0e080", description = "2x loot.",
      bonuses = { loot = 2 }, dates = rotation(3) },
}

-- The Fridays of a month
local function fridays(year, month)
    local list = {}
    for day = 1, 31 do
        local d = dateOf(at(year, month, day, 12))
        if (d.month ~= month) then
            break
        elseif (d.wday == 6) then
            list[#list + 1] = d
        end
    end
    return list
end

-- {starts, ends} of a staff event's occurrences that overlap [from, to]
local function staffOccurrences(event, from, to)
    local list = {}
    local function add(starts, ends)
        if (starts < to and ends > from) then
            list[#list + 1] = { starts, ends }
        end
    end
    if (event.rule == "once") then
        add(event.startsAt, event.startsAt + event.length)
    elseif (event.rule == "yearly") then
        local d = dateOf(event.startsAt)
        for year = dateOf(from).year - 1, dateOf(to).year do
            local starts = at(year, d.month, d.day, d.hour, d.min)
            add(starts, starts + event.length)
        end
    elseif (event.rule == "weekend" or event.rule == "nthweekend") then
        local first, last = dateOf(from - 4 * DAY), dateOf(to)
        local year, month = first.year, first.month
        while (year < last.year or (year == last.year and month <= last.month)) do
            local list2 = fridays(year, month)
            if (event.rule == "weekend") then
                for _, friday in ipairs(list2) do
                    add(unpack(weekendOf(friday)))
                end
            else
                local friday = event.nth == -1 and list2[#list2] or list2[event.nth]
                if (friday) then
                    add(unpack(weekendOf(friday)))
                end
            end
            month = month + 1
            if (month > 12) then
                year, month = year + 1, 1
            end
        end
    end
    return list
end

local function lengthOf(text)
    local amount, unit = tostring(text or ""):lower():match("^(%d+)([mhd])$")
    local units = { m = 60, h = HOUR, d = DAY }
    return amount and tonumber(amount) * units[unit] or nil
end

-- "/calendar add" arguments: once 2026-11-06 18:00 2d exp=2 Name | weekend exp=1.5 Name |
-- weekend 1 loot=2 Name | weekend last exp=2 Name | yearly 11-06 18:00 1d exp=2 Name
-- Returns the event to insert, or nil and why not.
function EventCalendar.parseAdd(text)
    local tokens = {}
    for token in tostring(text or ""):gmatch("%S+") do
        tokens[#tokens + 1] = token
    end
    local rule = (tokens[1] or ""):lower()
    local event, rest = { rule = rule, startsAt = 0, length = 0, nth = 0 }, 2
    if (rule == "once" or rule == "yearly") then
        local date, time, length = tokens[2] or "", tokens[3] or "", lengthOf(tokens[4])
        local year, month, day
        if (rule == "once") then
            year, month, day = date:match("^(%d%d%d%d)-(%d%d?)-(%d%d?)$")
        else
            month, day = date:match("^(%d%d?)-(%d%d?)$")
            year = dateOf(os.time()).year
        end
        local hour, minute = time:match("^(%d%d?):(%d%d)$")
        if (not month or not hour) then
            return nil, rule == "once" and "Write the start as 2026-11-06 18:00." or "Write the date as 11-06 18:00."
        elseif (not length or length < 60 or length > 31 * DAY) then
            return nil, "The length must be 1 minute to 31 days, such as 2h or 3d."
        end
        event.startsAt = at(tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(minute))
        event.length, rest = length, 5
    elseif (rule == "weekend") then
        local nth = (tokens[2] or ""):lower()
        if (nth == "last" or nth:match("^[1-5]$")) then
            event.rule, event.nth, rest = "nthweekend", nth == "last" and -1 or tonumber(nth), 3
        end
    else
        return nil, "The rule must be once, weekend or yearly."
    end

    local bonuses, err = EventCalendar.parseBonuses(tokens[rest])
    if (not bonuses) then
        return nil, err
    end
    event.bonusText = tokens[rest]:lower()
    event.bonuses = bonuses
    event.name = table.concat(tokens, " ", rest + 1)
    if (event.name == "" or #event.name > 40) then
        return nil, "Give the event a name of up to 40 letters after the bonuses."
    end
    return event
end

function EventCalendar.addStaffEvent(event, author)
    db.executeQuery(string.format("INSERT INTO `event_calendar` (`world_id`, `name`, `rule`, `starts_at`, `length`, `nth`, " ..
        "`bonuses`, `created_by`, `created_at`) VALUES (%d, %s, %s, %d, %d, %d, %s, %s, %d);", getConfigValue("worldId") or 0,
        db.escapeString(event.name), db.escapeString(event.rule), event.startsAt, event.length, event.nth,
        db.escapeString(event.bonusText), db.escapeString(author or ""), os.time()))
    EventCalendar.invalidate()
end

function EventCalendar.removeStaffEvent(id)
    local found = false
    for _, event in ipairs(loadStaffEvents()) do
        found = found or event.id == id
    end
    if (found) then
        db.executeQuery(string.format("DELETE FROM `event_calendar` WHERE `id` = %d;", id))
        EventCalendar.invalidate()
    end
    return found
end

function EventCalendar.describeRule(event)
    if (event.rule == "once") then
        return "once, " .. os.date("%Y-%m-%d %H:%M", event.startsAt) .. " for " .. ServerExpEvent.formatDuration(event.length)
    elseif (event.rule == "yearly") then
        return "every year, " .. os.date("%m-%d %H:%M", event.startsAt) .. " for " .. ServerExpEvent.formatDuration(event.length)
    elseif (event.rule == "weekend") then
        return "every weekend"
    end
    local names = { "first", "second", "third", "fourth", "fifth" }
    return "the " .. (event.nth == -1 and "last" or names[event.nth] or "?") .. " weekend of every month"
end

---------------------------------------------------------------------------------------------------
-- Occurrences
---------------------------------------------------------------------------------------------------

-- Every event that overlaps [from, to], by start time:
-- { key, id, name, description, color, startsAt, endsAt, bonuses, holiday, server, staff, forced }
function EventCalendar.getEvents(from, to)
    local list = {}
    local first, last = dateOf(from).year - 1, dateOf(to).year
    for _, holiday in ipairs(EventCalendar.HOLIDAYS) do
        local forced = EventCalendar.getForced(holiday.id)
        local now = os.time()
        local running = false
        for year = first, last do
            for _, dates in ipairs(holiday.dates(year)) do
                local starts, ends = dates[1], dates[2]
                if (starts < to and ends > from and forced ~= false) then
                    list[#list + 1] = { key = holiday.id .. ":" .. starts, holiday = holiday, name = holiday.name,
                                        description = holiday.description, color = holiday.color, startsAt = starts,
                                        endsAt = ends, bonuses = holiday.bonuses or {} }
                end
                running = running or (starts <= now and ends > now)
            end
        end
        -- forced on: runs now until staff set it back to automatic
        if (forced == true and not running and now >= from and now < to) then
            list[#list + 1] = { key = holiday.id .. ":forced", holiday = holiday, name = holiday.name,
                                description = holiday.description, color = holiday.color, startsAt = now,
                                endsAt = now + DAY, bonuses = holiday.bonuses or {}, forced = true }
        end
    end
    for _, server in ipairs(EventCalendar.SERVER_EVENTS) do
        for year = first, last do
            for _, dates in ipairs(server.dates(year)) do
                if (dates[1] < to and dates[2] > from) then
                    list[#list + 1] = { key = server.id .. ":" .. dates[1], server = server, name = server.name,
                                        description = server.description, color = server.color, startsAt = dates[1],
                                        endsAt = dates[2], bonuses = server.bonuses }
                end
            end
        end
    end
    for _, event in ipairs(loadStaffEvents()) do
        for _, dates in ipairs(staffOccurrences(event, from, to)) do
            list[#list + 1] = { key = "staff" .. event.id .. ":" .. dates[1], staff = event, id = event.id, name = event.name,
                                description = EventCalendar.formatBonuses(event.bonuses) .. ".", color = "#80b0ff",
                                startsAt = dates[1], endsAt = dates[2], bonuses = event.bonuses }
        end
    end
    table.sort(list, function(a, b)
        if (a.startsAt ~= b.startsAt) then
            return a.startsAt < b.startsAt
        end
        return a.name < b.name
    end)
    return list
end

local activeCache, activeCachedAt = nil, -1
local nextCache, nextCachedAt = nil, -1

function EventCalendar.invalidate()
    staffCache, activeCache, nextCachedAt = nil, nil, -1
end

-- The events running now (cached for a minute in each Lua state)
function EventCalendar.getActive(now)
    now = now or os.time()
    if (activeCache and math.floor(now / CACHE_SECONDS) == activeCachedAt) then
        return activeCache
    end
    local list = {}
    for _, event in ipairs(EventCalendar.getEvents(now - 40 * DAY, now + 1)) do
        if (event.startsAt <= now and event.endsAt > now) then
            list[#list + 1] = event
        end
    end
    activeCache, activeCachedAt = list, math.floor(now / CACHE_SECONDS)
    return list
end

-- The running occurrence of a holiday (by id), or nil
function EventCalendar.isActive(id)
    for _, event in ipairs(EventCalendar.getActive()) do
        if (event.holiday and event.holiday.id == id) then
            return event
        end
    end
    return nil
end

-- Whether any running holiday has this flag (berries, clefairy, luvdisc)
function EventCalendar.hasFlag(flag)
    for _, event in ipairs(EventCalendar.getActive()) do
        if (event.holiday and event.holiday[flag]) then
            return event
        end
    end
    return nil
end

-- The product of the running events' bonuses of a kind
function EventCalendar.multiplier(kind)
    local value = 1
    for _, event in ipairs(EventCalendar.getActive()) do
        value = value * (event.bonuses[kind] or 1)
    end
    return value
end

-- The first event that starts after now (cached like getActive)
function EventCalendar.getNext(now)
    now = now or os.time()
    if (nextCachedAt == math.floor(now / CACHE_SECONDS)) then
        return nextCache or nil
    end
    nextCache = false
    for _, event in ipairs(EventCalendar.getEvents(now, now + 400 * DAY)) do
        if (event.startsAt > now) then
            nextCache = event
            break
        end
    end
    nextCachedAt = math.floor(now / CACHE_SECONDS)
    return nextCache or nil
end

---------------------------------------------------------------------------------------------------
-- Clients
---------------------------------------------------------------------------------------------------

local function send(cid, data)
    if (getPlayerUsingOtClient(cid)) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.CALENDAR, JSON.encode(data))
    end
end

local function eventData(event)
    local bonuses = {}
    for _, kind in ipairs(EventCalendar.BONUS_KINDS) do
        if (event.bonuses[kind]) then
            bonuses[#bonuses + 1] = { kind = kind, label = EventCalendar.BONUS_LABELS[kind], value = event.bonuses[kind] }
        end
    end
    local id = event.holiday and event.holiday.id or event.server and event.server.id or ("staff" .. event.id)
    return { key = event.key, id = id, name = event.name,
             description = event.description, color = event.color, startsAt = event.startsAt, endsAt = event.endsAt,
             bonuses = bonuses, holiday = event.holiday ~= nil, night = event.holiday and event.holiday.night or false,
             forced = event.forced or false }
end

local function seasonData(span)
    return { id = span.season.id, name = span.season.name, color = span.season.color, startsAt = span.startsAt,
             endsAt = span.endsAt, forced = span.forced or false }
end

function EventCalendar.statusData(now)
    now = now or os.time()
    local active = {}
    for _, event in ipairs(EventCalendar.getActive(now)) do
        active[#active + 1] = eventData(event)
    end
    local nextEvent = EventCalendar.getNext(now)
    return { type = "status", now = now, active = active, next = nextEvent and eventData(nextEvent) or nil,
             season = seasonData(EventCalendar.currentSeason(now)) }
end

function EventCalendar.sendStatus(cid)
    send(cid, EventCalendar.statusData())
end

function EventCalendar.rangeData(from, to)
    from, to = math.floor(tonumber(from) or 0), math.floor(tonumber(to) or 0)
    if (to <= from or to - from > MAX_RANGE) then
        return nil
    end
    local events = {}
    for _, event in ipairs(EventCalendar.getEvents(from, to)) do
        events[#events + 1] = eventData(event)
    end
    local moons = {}
    for _, phase in ipairs(EventCalendar.moonPhases(from - LUNATION, to + LUNATION)) do
        moons[#moons + 1] = { time = phase.time, full = phase.full }
    end
    local seasons = {}
    for _, span in ipairs(EventCalendar.seasonSpans(from, to)) do
        seasons[#seasons + 1] = seasonData(span)
    end
    return { type = "range", from = from, to = to, now = os.time(), events = events, moons = moons, seasons = seasons }
end

function EventCalendar.onClientMessage(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "status") then
        EventCalendar.sendStatus(cid)
    elseif (data.action == "range") then
        local range = EventCalendar.rangeData(data.from, data.to)
        if (range) then
            send(cid, range)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Gifts
---------------------------------------------------------------------------------------------------

local function ordinal(n)
    local suffix = "th"
    if (n % 100 < 11 or n % 100 > 13) then
        suffix = ({ "st", "nd", "rd" })[n % 10] or "th"
    end
    return n .. suffix
end

-- The holiday gift of each running holiday, once per occurrence
function EventCalendar.giveGifts(cid)
    for _, event in ipairs(EventCalendar.getActive()) do
        local holiday, gift = event.holiday, event.holiday and event.holiday.gift
        local key = holiday and GIFT_STORAGE_BASE + holiday.index
        if (gift and not event.forced and tonumber(getPlayerStorageValue(cid, key)) ~= event.startsAt) then
            setPlayerStorageValue(cid, key, event.startsAt)
            local text = "Happy " .. holiday.name .. "!"
            if (holiday.id == "anniversary") then
                local years = dateOf(event.startsAt).year - EventCalendar.LAUNCH_YEAR
                text = years > 0 and string.format("Happy %s anniversary of PokeVerse!", ordinal(years)) or text
            end
            if (gift.money) then
                doPlayerAddMoney(cid, gift.money)
            end
            for _, item in ipairs(gift.items or {}) do
                doPlayerSafeAddItem(cid, item[1], item[2], false)
            end
            doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, text .. " Your holiday gift is in your bag.")
            doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_YELLOW)
        end
    end
end

function EventCalendar.describeLeft(event)
    return event.forced and "On until staff end it" or ServerExpEvent.formatDuration(event.endsAt - os.time()) .. " left"
end

function EventCalendar.onLogin(cid)
    for _, event in ipairs(EventCalendar.getActive()) do
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format("%s: %s %s.", event.name, event.description,
            EventCalendar.describeLeft(event)))
    end
    EventCalendar.giveGifts(cid)
end

---------------------------------------------------------------------------------------------------
-- Clefairy nights (globalevent state)
---------------------------------------------------------------------------------------------------

EventCalendar.CLEFAIRY_AREAS = {
    { x = 3567, y = 280, z = 6 }, { x = 3528, y = 341, z = 2 }, { x = 3601, y = 303, z = 7 }, { x = 3539, y = 325, z = 3 },
    { x = 3601, y = 307, z = 7 }, { x = 3596, y = 337, z = 8 }, { x = 3522, y = 343, z = 1 }, { x = 3530, y = 325, z = 3 },
}
EventCalendar.CLEFAIRY_PER_AREA = { { "Clefairy", 2 }, { "Clefable", 1 } }
EventCalendar.MOON_STONE_ITEMID = 18084
EventCalendar.MOON_STONE_CHANCE = 2000 -- of RANDOM_CHANCE_MAX: 2% for each Clefairy or Clefable of the night

local nightSpawns = {}

local function spawnClefairy()
    for _, area in ipairs(EventCalendar.CLEFAIRY_AREAS) do
        for _, entry in ipairs(EventCalendar.CLEFAIRY_PER_AREA) do
            for _ = 1, entry[2] do
                local pos = { x = area.x + getRandom(-4, 4), y = area.y + getRandom(-4, 4), z = area.z }
                local cid = doCreateMonster(entry[1], pos, false)
                if (isCreature(cid)) then
                    nightSpawns[#nightSpawns + 1] = cid
                    doSendMagicEffect(getCreaturePosition(cid), EFFECT_TELEPORT_DOWN)
                end
            end
        end
    end
end

local function despawnClefairy()
    for _, cid in ipairs(nightSpawns) do
        if (isCreature(cid) and isPokemonWild(cid)) then
            doSendMagicEffect(getCreaturePosition(cid), EFFECT_POFF)
            doRemoveCreature(cid)
        end
    end
    nightSpawns = {}
end

-- onKill: a Moon Stone from a Clefairy or Clefable on a Clefairy night
EventCalendar.onPlayerKill = function(cid, target)
    local name = getCreatureName(target)
    if ((name == "Clefairy" or name == "Clefable") and EventCalendar.hasFlag("clefairy")
            and getRandom(RANDOM_CHANCE_MIN, RANDOM_CHANCE_MAX) <= EventCalendar.MOON_STONE_CHANCE) then
        doPlayerSafeAddItem(cid, EventCalendar.MOON_STONE_ITEMID, 1, false)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "The full moon left a Moon Stone behind!")
    end
    if (EventCalendar.hasFlag("berries") and isPokemonName(name)
            and getRandom(RANDOM_CHANCE_MIN, RANDOM_CHANCE_MAX) <= EventCalendar.HARVEST_BERRY_CHANCE) then
        local berry = EventCalendar.HARVEST_BERRIES[getRandom(1, #EventCalendar.HARVEST_BERRIES)]
        doPlayerSafeAddItem(cid, berry, 1, false)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format("Harvest Moon: you found %s.",
            getItemArticleById(berry) .. " " .. getItemNameById(berry)))
    end
end

---------------------------------------------------------------------------------------------------
-- Harvest Moon (015-berry.lua and the seed box ask these)
---------------------------------------------------------------------------------------------------

EventCalendar.HARVEST_BERRIES = { 13182, 13183, 13184, 13185, 13186, 14766, 14767, 14768, 14769, 14770 }
EventCalendar.HARVEST_BERRY_CHANCE = 5000 -- of RANDOM_CHANCE_MAX: 5% of wild Pokemon defeated
EventCalendar.HARVEST_GROWTH = 2
EventCalendar.HARVEST_MAX_BERRIES = 8
EventCalendar.HARVEST_SEEDS = 2

EventCalendar.berryStageInterval = function(interval)
    return EventCalendar.hasFlag("berries") and math.ceil(interval / EventCalendar.HARVEST_GROWTH) or interval
end

EventCalendar.berryMaxCount = function(count)
    return EventCalendar.hasFlag("berries") and math.max(count, EventCalendar.HARVEST_MAX_BERRIES) or count
end

EventCalendar.seedCount = function(count)
    return EventCalendar.hasFlag("berries") and count * EventCalendar.HARVEST_SEEDS or count
end

---------------------------------------------------------------------------------------------------
-- Executor (serverExpEvent globalevent, every second)
---------------------------------------------------------------------------------------------------

-- The old holiday raids (data/raids/raids.xml, enabled="no"): one of them every interval while the holiday runs
EventCalendar.RAIDS = {
    halloween = { interval = 45 * 60, names = { "Halloween", "Halloween Caldron", "Halloween Suramoon" } },
    christmas = { interval = 35 * 60, names = { "christmasGrinchInvasion", "christmasStolenPresent", "christmasRocketBots",
                                                "christmasRunawayStantler" } },
}
local RAID_FIRST_DELAY = 5 * 60

-- AnniversaryEvent and the old globalevents call this name
if (not executeRaid) then
    executeRaid = function(name)
        return doExecuteRaid(name)
    end
end

local running = nil
-- For the Discord bot: which occurrence started or ended, and its kind (it pings for holidays and the
-- weekend events, and links the Discord event made for the occurrence)
function EventCalendar.announcementTag(event, state)
    local id = event.holiday and event.holiday.id or event.server and event.server.id or ("staff" .. tostring(event.id))
    return { key = event.key, id = id, state = state,
             type = event.holiday and "holiday" or event.server and "server" or "staff" }
end

local lastStatusKey = nil
local lastSeason = nil
local lastRaid = {}

local function keysOf(list)
    local keys = {}
    for _, event in ipairs(list) do
        keys[event.key] = event
    end
    return keys
end

function EventCalendar.onThink()
    local now = os.time()
    local active = EventCalendar.getActive(now)
    local keys = keysOf(active)

    if (running) then
        for key, event in pairs(keys) do
            if (not running[key]) then
                local title = event.name .. " has started"
                local text = string.format("%s %s.", event.description,
                    event.forced and "It runs until staff end it" or "It runs for " .. ServerExpEvent.formatDuration(event.endsAt - now))
                doBroadcastMessage(title .. ": " .. text, MESSAGE_STATUS_WARNING,
                    { category = "event", title = title, text = text, calendar = EventCalendar.announcementTag(event, "started") })
                for _, pid in ipairs(getPlayersOnline()) do
                    EventCalendar.giveGifts(pid)
                end
            end
        end
        for key, event in pairs(running) do
            if (not keys[key]) then
                doBroadcastMessage(string.format("%s has ended.", event.name), MESSAGE_STATUS_WARNING,
                    { category = "event", title = event.name .. " has ended", text = "Thanks for playing! See the calendar (C) for the next events.",
                      calendar = EventCalendar.announcementTag(event, "ended") })
            end
        end
    else
        for _, event in ipairs(active) do
            print(string.format("> Event calendar: %s until %s", event.name, os.date("%Y-%m-%d %H:%M", event.endsAt)))
        end
    end

    local clefairy = EventCalendar.hasFlag("clefairy") ~= nil
    if (clefairy and #nightSpawns == 0) then
        spawnClefairy()
    elseif (not clefairy and #nightSpawns > 0) then
        despawnClefairy()
    end
    running = keys
    AnniversaryEvent.sync()
    AnniversaryEvent.syncNpcs()
    HalloweenEvent.syncNpcs()

    for id, raid in pairs(EventCalendar.RAIDS) do
        if (not EventCalendar.isActive(id)) then
            lastRaid[id] = nil
        elseif (not lastRaid[id]) then
            lastRaid[id] = now - raid.interval + RAID_FIRST_DELAY
        elseif (now - lastRaid[id] >= raid.interval) then
            lastRaid[id] = now
            doExecuteRaid(raid.names[getRandom(1, #raid.names)])
        end
    end

    local loot = EventCalendar.multiplier("loot")
    if (getLootEventMultiplier and getLootEventMultiplier() ~= loot) then
        setLootEventMultiplier(loot)
    end

    local season = EventCalendar.seasonId(now)
    if (lastSeason and lastSeason ~= season) then
        local name = SEASON_BY_ID[season].name
        doBroadcastMessage(string.format("%s has come to the regions, and the weather changes with it.", name),
            MESSAGE_STATUS_WARNING)
        if (EventCalendar.onSeasonChange) then
            EventCalendar.onSeasonChange(season, lastSeason)
        end
    end
    lastSeason = season

    local nextEvent = EventCalendar.getNext(now)
    local statusKey = table.concat((function()
        local list = {}
        for _, event in ipairs(active) do
            list[#list + 1] = event.key
        end
        list[#list + 1] = nextEvent and nextEvent.key or ""
        list[#list + 1] = season
        return list
    end)(), ",")
    if (statusKey ~= lastStatusKey) then
        if (lastStatusKey) then
            local data = EventCalendar.statusData(now)
            for _, pid in ipairs(getPlayersOnline()) do
                send(pid, data)
            end
        end
        lastStatusKey = statusKey
    end
end
