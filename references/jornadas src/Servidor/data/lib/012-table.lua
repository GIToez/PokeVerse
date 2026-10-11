-- table.join :: [a] -> [a] -> [a]      
-- Funcao impura, pois nao cria uma nova tabela, e sim joga os valores de `table_to_join` em `table` que foi passado por referência e não por valor
table.join_ = function (xs, xs_to_join)
  for _, x in pairs(xs_to_join) do
    table.insert(xs, x)
  end
end

------ Prelude + other table functions
table.filterFind = function (xs, foo)
  for index, value in pairs(xs) do
    if foo(index, value) then
      return {index = index, value = value}
    end
  end
  return nil
end

table.random = function (xs)
  return xs[math.random(1, #xs)]
end

-- table.concatMapStr :: [a] -> (a -> Char/String) -> String
table.concatMapStr = function (xs, foo)
  local retorno = ""
  for index, value in pairs(xs) do
    retorno = retorno .. foo(index, value)
  end
  return retorno
end

-- table.concatMap :: [[a]] -> [a]
table.concatMap = function (xs)
  local retorno = {}
  for index, table_value in pairs(xs) do
    for index, value in pairs(table_value) do
      table.insert(retorno, value)
    end 
  end
  return retorno
end

table.map = function (xs, foo)
  local retorno = {}
  for index, value in pairs(xs) do
    retorno[index] = foo(index, value)
  end
  return retorno
end

-- Impure map, passa por referencia e pode mudar o valor de `xs` caso bem entender
table.map_ = function (xs, foo)
  for index, value in pairs(xs) do
    foo(index, value)
  end
end

table.foldr = function (xs, start_value, foo)
  local retorno = start_value
  for _, value in pairs(xs) do
    retorno = foo(retorno, value)
  end
  return retorno
end

table.filter = function (xs, foo)
  local retorno = {}
  for index, value in pairs(xs) do
    if foo(index, value) then
      retorno[index] = value
    end
  end
  return retorno
end

table.any = function (xs, foo)
  for index, value in pairs(xs) do
    if foo(index, value) then
      return true
    end
  end
  return false
end

table.all = function (xs, foo)
  for index, value in pairs(xs) do
    if not foo(index, value) then
      return false
    end
  end
  return true
end

table.none = function (xs, foo)
  --local clock = os.clock()
  for index, value in pairs(xs) do
    if foo(index, value) then
      return false
    end
  end
  --print('> Tempo: ' .. (os.clock() - clock))  
  return true
end
----------------------- F I M    P R E L U D E ---------------------------------
--------------------------------------------------------------------------------

table.find = function (t, value)
	for i, v in pairs(t) do
		if (v == value) then
			return i
		end
	end

	return nil
end

table.findAsTable = function (t, value)
    local f
    for k, v in pairs(value) do
        f = table.find(t, v)
        if (f) then
            return f
        end
    end
    return f
end

table.removeValue = function (t, value, onlyFirst)
    if (not onlyFirst) then
        onlyFirst = true
    end

    local removed = false
    for k, v in pairs(t) do
        if (v == value) then
            table.remove(t, k)

            if (onlyFirst) then
                return true
            end

            removed = true
        end
    end

    return removed
end

table.contains = function (txt, str)
	for i, v in pairs(str) do
		if(txt:find(v) and not txt:find('(%w+)' .. v) and not txt:find(v .. '(%w+)')) then
			return true
		end
	end

	return false
end
table.isStrIn = table.contains

table.count = function (table, item)
	local count = 0
	for i, n in pairs(table) do
		if(item == n) then
			count = count + 1
		end
	end

	return count
end
table.countElements = table.count

table.getCombinations = function (table, num)
	local a, number, select, newlist = {}, #table, num, {}
	for i = 1, select do
		a[#a + 1] = i
	end

	local newthing = {}
	while(true) do
		local newrow = {}
		for i = 1, select do
			newrow[#newrow + 1] = table[a[i]]
		end

		newlist[#newlist + 1] = newrow
		i = select
		while(a[i] == (number - select + i)) do
			i = i - 1
		end

		if(i < 1) then
			break
		end

		a[i] = a[i] + 1
		for j = i, select do
			a[j] = a[i] + j - i
		end
	end

	return newlist
end

function table_concat(...)
    local t = {}
    for n = 1,select("#",...) do
        local arg = select(n,...)
        if type(arg)=="table" then
            for _,v in ipairs(arg) do
                t[#t+1] = v
            end
        else
            t[#t+1] = arg
        end
    end
    return t
end

table.random = function(t)
	return t[math.random(1, #t)]
end

function table.randFrom( t )
    local choice = "F"
    local n = 0
    for i, o in pairs(t) do
        n = n + 1
        if math.random() < (1/n) then
            choice = o
        end
    end
    return choice
end

table.randomRemove = function(t)
    local k = math.random(1, #t)
    local v = t[k]
    table.remove(t, k)
    return v
end

table.copy = function(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

table.deepcopy = function(o, seen) -- http://stackoverflow.com/a/16077650/1150772
    seen = seen or {}
    if o == nil then return nil end
    if seen[o] then return seen[o] end

    local no
    if type(o) == 'table' then
        no = {}
        seen[o] = no

        for k, v in next, o, nil do
            no[table.deepcopy(k, seen)] = table.deepcopy(v, seen)
        end
        setmetatable(no, table.deepcopy(getmetatable(o), seen))
    else -- number, string, boolean, etc
        no = o
    end
    return no
end

table.print = function(t, sub)
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

table.clear = function(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

table.set = function(t)
    local set = {}
    for _, v in pairs(t) do
        set[v] = true
    end
    return set
end

table.inverse = function(t)
    local r = {}
    for k, v in pairs(t) do
        r[v] = k
    end
    return r
end

table.shuffle = function(array)
    local function swap(array, index1, index2)
        array[index1], array[index2] = array[index2], array[index1]
    end

    local counter = #array
    local antiLoop = 0
    while counter > 1 do
        local index = getRandom(1, counter)
        swap(array, index, counter)
        counter = counter - 1

        if (antiLoop > 999999) then
            break
        end
        antiLoop = antiLoop + 1
    end
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str(v) )
    done[ k ] = true
  end
  for k, v in pairs(tbl) do
    if not done[k] then
      table.insert(result, table.key_to_str(k) .. "=" .. table.val_to_str(v))
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

--[[
table.getMin = function (table)
	if (#table < 1) then
		return nil
	end

	local resultKey, resultValue, tableKey, tableValue = -1, -1

	for tableKey = 1, #table do
		tableValue = table[tableKey]

		if (tableValue > -1 and tableValue < resultValue) then
			resultKey = tableKey
			resultValue = tableValue
		end
	end

	if (resultValue > -1) then
		return resultKey

	else
		return nil
	end
end
]]

    -- "Sorted by key" table iterator
    -- Extracted from http://www.lua.org/pil/19.3.html

    --function pairsKeySorted(t, f)
    --local a = {}
    --for n in pairs(t) do
    --table.insert(a, n)
    --end
    --table.sort(a, f)

    --local i = 0 -- iterator variable
    --local iter = function () -- iterator function
    --i = i + 1
    --if a[i] == nil then
    --return nil
    --else
    --return a[i], t[a[i]]
    --end
    --end

    --return iter
    --end