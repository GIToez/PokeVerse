-- PokeVerse server payload helpers shared by the extended-opcode modules (Battle Pass, tasks,
-- craft, market...). The server builds them with Protocol_create/Protocol_add and table.tostring.

function Protocol_create(name)
    return { {}, 0, name }
end

function Protocol_add(protocol, value)
    table.insert(protocol[1], value)
end

function Protocol_read(protocol)
    protocol[2] = protocol[2] + 1
    return protocol[1][protocol[2]]
end

function isInArray(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end


-- Decodes a Lua table literal as produced by the server's table.tostring
-- (strings, numbers, booleans, nil and nested tables) without executing it.
-- Server payloads relay player-controlled text, so they must never reach loadstring.
local literalEscapes = { n = '\n', t = '\t', r = '\r', a = '\a', b = '\b', f = '\f', v = '\v',
                         ['\\'] = '\\', ['"'] = '"', ["'"] = "'", ['\n'] = '\n' }
local literalConstants = { ['true'] = true, ['false'] = false, inf = math.huge, nan = 0/0 }

function table.fromLiteral(text)
  local pos = 1
  local depth = 0

  local function fail(msg)
    error(string.format('invalid table literal at %d: %s', pos, msg), 0)
  end

  local function skip()
    pos = text:find('[^%s]', pos) or #text + 1
  end

  local parseValue

  local function parseString(quote)
    local parts = {}
    pos = pos + 1
    while true do
      local s, e = text:find('[\\' .. quote .. ']', pos)
      if not s then fail('unterminated string') end
      parts[#parts + 1] = text:sub(pos, s - 1)
      if text:sub(s, s) == quote then
        pos = e + 1
        return table.concat(parts)
      end
      local c = text:sub(s + 1, s + 1)
      if literalEscapes[c] then
        parts[#parts + 1] = literalEscapes[c]
        pos = s + 2
      else
        local digits = text:match('^%d%d?%d?', s + 1)
        if not digits or tonumber(digits) > 255 then fail('bad escape') end
        parts[#parts + 1] = string.char(tonumber(digits))
        pos = s + 1 + #digits
      end
    end
  end

  local function parseTable()
    depth = depth + 1
    if depth > 100 then fail('nested too deeply') end
    pos = pos + 1
    local result, index = {}, 1
    while true do
      skip()
      local c = text:sub(pos, pos)
      if c == '}' then
        pos = pos + 1
        depth = depth - 1
        return result
      end
      local key, value
      local name = text:match('^[_%a][_%w]*', pos)
      if c == '[' then
        pos = pos + 1
        skip()
        key = parseValue()
        skip()
        if text:sub(pos, pos) ~= ']' then fail("expected ']'") end
        pos = pos + 1
        skip()
        if text:sub(pos, pos) ~= '=' then fail("expected '='") end
        pos = pos + 1
        skip()
        value = parseValue()
      elseif name and text:match('^%s*=', pos + #name) and not text:match('^%s*==', pos + #name) then
        key = name
        pos = text:find('=', pos + #name, true) + 1
        skip()
        value = parseValue()
      else
        key = index
        index = index + 1
        value = parseValue()
      end
      if key == nil then fail('nil key') end
      result[key] = value
      skip()
      c = text:sub(pos, pos)
      if c == ',' or c == ';' then
        pos = pos + 1
      elseif c ~= '}' then
        fail("expected ',' or '}'")
      end
    end
  end

  parseValue = function()
    local c = text:sub(pos, pos)
    if c == '{' then return parseTable() end
    if c == '"' or c == "'" then return parseString(c) end
    local number = text:match('^-?0[xX]%x+', pos) or text:match('^-?%d+%.?%d*[eE][-+]?%d+', pos)
                   or text:match('^-?%d+%.?%d*', pos) or text:match('^-?%.%d+', pos)
    if number then
      pos = pos + #number
      return tonumber(number)
    end
    local negative = text:match('^-', pos) and 1 or 0
    local name = text:match('^[_%a][_%w]*', pos + negative)
    if name then
      pos = pos + negative + #name
      if name == 'nil' and negative == 0 then return nil end
      local constant = literalConstants[name]
      if constant == nil then fail('unexpected identifier ' .. name) end
      if negative == 1 then
        if type(constant) ~= 'number' then fail('unexpected -') end
        return -constant
      end
      return constant
    end
    fail('unexpected ' .. (c == '' and 'end of input' or c))
  end

  skip()
  local value = parseValue()
  skip()
  if pos <= #text then fail('trailing data') end
  return value
end
