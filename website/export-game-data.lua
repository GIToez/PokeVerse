-- Prints the Pokémon and moves from the server config as JSON, for website/build.py.
--
--     lua5.1 website/export-game-data.lua core/server/data/lib/ps/config > game-data.json
--
-- The config files expect the whole server around them. Instead, every global they use
-- that is not defined here is a stand-in that remembers its name (ELEMENT_FIRE,
-- TM_IDS.CUT, ...), and the JSON carries those names for build.py to turn into labels.

local configDir = assert(arg[1], "usage: export-game-data.lua <config dir>")

local Name = {}
local function named(name)
    return setmetatable({ name = name }, Name)
end
Name.__index = function(self, key)
    return named(rawget(self, "name") .. "." .. tostring(key))
end
Name.__call = function(self)
    return named(rawget(self, "name") .. "()")
end
for _, op in ipairs({ "__add", "__sub", "__mul", "__div", "__concat", "__unm" }) do
    Name[op] = function(a, b)
        local self = getmetatable(a) == Name and a or b
        return self
    end
end

function table.deepcopy(value)
    if type(value) ~= "table" or getmetatable(value) == Name then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end

POKEMON = {}
MOVES = {}

setmetatable(_G, {
    __index = function(_, key)
        return named(key)
    end
})

local function files(dir)
    local list = {}
    local pipe = io.popen('ls "' .. dir .. '"')
    for file in pipe:lines() do
        if file:match("%.lua$") then
            list[#list + 1] = dir .. "/" .. file
        end
    end
    pipe:close()
    table.sort(list)
    return list
end

local function run(path)
    local chunk = assert(loadfile(path))
    local ok, err = pcall(chunk)
    if not ok then
        io.stderr:write("skipped " .. path .. ": " .. tostring(err) .. "\n")
    end
end

run(configDir .. "/pokemonsNumbers.lua")
for _, path in ipairs(files(configDir .. "/pokemon")) do
    run(path)
end
for _, path in ipairs(files(configDir .. "/moves")) do
    run(path)
end

local numbers = {}
for name in pairs(POKEMON) do
    local number = getPokemonNumberByName(name)
    if type(number) == "number" then
        numbers[name] = number
    end
end

local function encode(value, out)
    local t = type(value)
    if t == "table" and getmetatable(value) == Name then
        encode(rawget(value, "name"), out)
    elseif t == "table" then
        local n = #value
        local isArray = n > 0 or next(value) == nil
        if isArray then
            for k in pairs(value) do
                if type(k) ~= "number" or k < 1 or k > n or k % 1 ~= 0 then
                    isArray = false
                    break
                end
            end
        end
        if isArray then
            out[#out + 1] = "["
            for i = 1, n do
                if i > 1 then out[#out + 1] = "," end
                encode(value[i], out)
            end
            out[#out + 1] = "]"
        else
            local keys = {}
            for k in pairs(value) do
                keys[#keys + 1] = tostring(k)
            end
            table.sort(keys)
            out[#out + 1] = "{"
            for i, k in ipairs(keys) do
                if i > 1 then out[#out + 1] = "," end
                encode(k, out)
                out[#out + 1] = ":"
                local v = value[k]
                if v == nil then v = value[tonumber(k)] end
                encode(v, out)
            end
            out[#out + 1] = "}"
        end
    elseif t == "string" then
        out[#out + 1] = '"' .. value:gsub('[%c"\\]', function(c)
            local escapes = { ['"'] = '\\"', ["\\"] = "\\\\", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
            return escapes[c] or string.format("\\u%04x", c:byte())
        end) .. '"'
    elseif t == "number" then
        out[#out + 1] = (value ~= value or value == math.huge or value == -math.huge) and "null" or tostring(value)
    elseif t == "boolean" then
        out[#out + 1] = tostring(value)
    else
        out[#out + 1] = "null"
    end
end

local out = {}
encode({ pokemon = POKEMON, moves = MOVES, numbers = numbers }, out)
io.write(table.concat(out), "\n")
