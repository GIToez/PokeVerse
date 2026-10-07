-- @docclass table

function table.dump(t, depth)
  if not depth then depth = 0 end
  for k,v in pairs(t) do
    str = (' '):rep(depth * 2) .. k .. ': '
    if type(v) ~= "table" then
      print(str .. tostring(v))
    else
      print(str)
      table.dump(v, depth+1)
    end
  end
end

function table.clear(t)
  for k,v in pairs(t) do
    t[k] = nil
  end
end

function table.copy(t)
  local res = {}
  for k,v in pairs(t) do
    res[k] = v
  end
  return res
end

function table.recursivecopy(t)
  local res = {}
  for k,v in pairs(t) do
    if type(v) == "table" then
      res[k] = table.recursivecopy(v)
    else
      res[k] = v
    end
  end
  return res
end

function table.selectivecopy(t, keys)
  local res = { }
  for i,v in ipairs(keys) do
    res[v] = t[v]
  end
  return res
end

function table.merge(t, src)
  for k,v in pairs(src) do
    t[k] = v
  end
end

function table.find(t, value, lowercase)
  for k,v in pairs(t) do
    if lowercase and type(value) == 'string' and type(v) == 'string' then
      if v:lower() == value:lower() then return k end
    end
    if v == value then return k end
  end
end

function table.findbykey(t, key, lowercase)
  for k,v in pairs(t) do
    if lowercase and type(key) == 'string' and type(k) == 'string' then
      if k:lower() == key:lower() then return v end
    end
    if k == key then return v end
  end
end

function table.contains(t, value, lowercase)
  return table.find(t, value, lowercase) ~= nil
end

function table.findkey(t, key)
  if t and type(t) == 'table' then
    for k,v in pairs(t) do
      if k == key then return k end
    end
  end
end

function table.haskey(t, key)
  return table.findkey(t, key) ~= nil
end

function table.removevalue(t, value)
  for k,v in pairs(t) do
    if v == value then
      table.remove(t, k)
      return true
    end
  end
  return false
end

function table.popvalue(value)
  local index = nil
  for k,v in pairs(t) do
    if v == value or not value then
      index = k
    end
  end
  if index then
    table.remove(t, index)
    return true
  end
  return false
end

function table.compare(t, other)
  if #t ~= #other then return false end
  for k,v in pairs(t) do
    if v ~= other[k] then return false end
  end
  return true
end

function table.empty(t)
  if t and type(t) == 'table' then
    return next(t) == nil
  end
  return true
end

function table.permute(t, n, count)
  n = n or #t
  for i=1,count or n do
    local j = math.random(i, n)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

function table.findbyfield(t, fieldname, fieldvalue)
  for _i,subt in pairs(t) do
    if subt[fieldname] == fieldvalue then
      return subt
    end
  end
  return nil
end

function table.size(t)
  local size = 0
  for i, n in pairs(t) do
    size = size + 1
  end

  return size
end

function table.tostring(t)
  local maxn = #t
  local str = ""
  for k,v in pairs(t) do
    v = tostring(v)
    if k == maxn and k ~= 1 then
      str = str .. " and " .. v
    elseif maxn > 1 and k ~= 1 then
      str = str .. ", " .. v
    else
      str = str .. " " .. v
    end
  end
  return str
end

function table.collect(t, func)
  local res = {}
  for k,v in pairs(t) do
    local a,b = func(k,v)
    if a and b then
      res[a] = b
    elseif a ~= nil then
      table.insert(res,a)
    end
  end
  return res
end

function table.random(t)
    return t[math.random(1, #t)]
end

function table.print(t, sub)
    if (not sub) then
        print("\n\nPrinting table:")
    end
    for k, v in pairs(t) do
        if (type(v) == "table") then
            print("Printing sub-table...")
            table.print(v, true)
        else
            print("[" .. tostring(k) .. "] = " .. tostring(v))
        end
    end
end

function table.shuffle(t)
    table.sort(t, function(a, b) return math.random() > 0.5 end)
end

-- declare local variables
--// exportstring( string )
--// returns a "Lua" portable version of the string
local function exportstring( s )
    return string.format("%q", s)
end

--// The Save Function
function table.save(  tbl,filename )
    local charS,charE = "   ","\n"
    local file,err = io.open( filename, "wb" )
    if err then return err end

    -- initiate variables for save procedure
    local tables,lookup = { tbl },{ [tbl] = 1 }
    file:write( "return {"..charE )

    for idx,t in ipairs( tables ) do
        file:write( "-- Table: {"..idx.."}"..charE )
        file:write( "{"..charE )
        local thandled = {}

        for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
                if not lookup[v] then
                    table.insert( tables, v )
                    lookup[v] = #tables
                end
                file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
                file:write(  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
                file:write(  charS..tostring( v )..","..charE )
            end
        end

        for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then

                local str = ""
                local stype = type( i )
                -- handle index
                if stype == "table" then
                    if not lookup[i] then
                        table.insert( tables,i )
                        lookup[i] = #tables
                    end
                    str = charS.."[{"..lookup[i].."}]="
                elseif stype == "string" then
                    str = charS.."["..exportstring( i ).."]="
                elseif stype == "number" then
                    str = charS.."["..tostring( i ).."]="
                end

                if str ~= "" then
                    stype = type( v )
                    -- handle value
                    if stype == "table" then
                        if not lookup[v] then
                            table.insert( tables,v )
                            lookup[v] = #tables
                        end
                        file:write( str.."{"..lookup[v].."},"..charE )
                    elseif stype == "string" then
                        file:write( str..exportstring( v )..","..charE )
                    elseif stype == "number" then
                        file:write( str..tostring( v )..","..charE )
                    end
                end
            end
        end
        file:write( "},"..charE )
    end
    file:write( "}" )
    file:close()
end

--// The Load Function
function table.load( sfile )
    local ftables,err = loadfile( sfile )
    if err then return _,err end
    local tables = ftables()
    for idx = 1,#tables do
        local tolinki = {}
        for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
                tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
                table.insert( tolinki,{ i,tables[i[1]] } )
            end
        end
        -- link indices
        for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
        end
    end
    return tables[1]
end

--[[function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end]]

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
