-- Prints QUESTS_CONFIG (lib/ps/config/003-quest.lua) as JSON for scripts/npc_conversation_audit.py.
-- Any global the file reads that the audit has no use for is a stub.
--
--   lua5.1 scripts/npc_quests_dump.lua core/server/data/lib/ps/config/003-quest.lua

local stub
stub = setmetatable({}, {
  __index = function() return stub end,
  __call = function() return stub end,
  __add = function() return 0 end, __sub = function() return 0 end,
  __mul = function() return 0 end, __concat = function() return "" end,
})
setmetatable(_G, { __index = function() return stub end })

local chunk = assert(loadfile(arg[1]))
chunk()

local source = {}
for line in io.lines(arg[1]) do source[#source + 1] = line end

-- functions become { "__fn": <their source> } so the audit can read item checks in them
local function functionSource(f)
  local info = debug.getinfo(f, "S")
  if not info or info.linedefined < 1 then return "" end
  return table.concat(source, "\n", info.linedefined, info.lastlinedefined)
end

local function esc(s)
  return '"' .. s:gsub('[%c"\\]', function(c)
    if c == '"' then return '\\"' elseif c == '\\' then return '\\\\' end
    return string.format('\\u%04x', c:byte())
  end) .. '"'
end

local encode
function encode(v)
  local t = type(v)
  if t == "string" then return esc(v) end
  if t == "number" then return tostring(v) end
  if t == "boolean" then return tostring(v) end
  if t == "function" then return '{"__fn":' .. esc(functionSource(v)) .. '}' end
  if t ~= "table" or v == stub then return "null" end
  local n = #v
  local parts = {}
  if n > 0 then
    for i = 1, n do parts[i] = encode(v[i]) end
    return "[" .. table.concat(parts, ",") .. "]"
  end
  for k, val in pairs(v) do
    parts[#parts + 1] = esc(tostring(k)) .. ":" .. encode(val)
  end
  return "{" .. table.concat(parts, ",") .. "}"
end

io.write(encode(QUESTS_CONFIG))
