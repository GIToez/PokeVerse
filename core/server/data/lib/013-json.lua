-- Minimal JSON encoder/decoder (Lua 5.1) used by the Discord bridge.
-- Game strings are Latin-1: encode() writes bytes >= 0x7F as \u00XX so the output is
-- plain ASCII (valid UTF-8); decode() maps code points up to U+00FF back to single
-- bytes and replaces anything the game client cannot display with "?".

JSON = {}

local ARRAY_MT = {__jsontype = "array"}

-- Marks a table as a JSON array (needed for empty arrays).
function JSON.array(t)
    return setmetatable(t or {}, ARRAY_MT)
end

local function isArray(t)
    local mt = getmetatable(t)
    if (mt and mt.__jsontype == "array") then
        return true
    end

    local count = 0
    for k in pairs(t) do
        if (type(k) ~= "number" or k < 1 or math.floor(k) ~= k) then
            return false
        end
        count = count + 1
    end
    return count > 0 and count == #t
end

local function escapeString(s)
    return (s:gsub('[%c"\\\127-\255]', function(c)
        if (c == '"') then
            return '\\"'
        elseif (c == "\\") then
            return "\\\\"
        elseif (c == "\n") then
            return "\\n"
        elseif (c == "\r") then
            return "\\r"
        elseif (c == "\t") then
            return "\\t"
        end
        return string.format("\\u%04x", c:byte())
    end))
end

local encodeValue

local function encodeTable(t, out, depth)
    if (depth > 20) then
        error("JSON.encode: nesting too deep")
    end

    if (isArray(t)) then
        out[#out + 1] = "["
        for i = 1, #t do
            if (i > 1) then
                out[#out + 1] = ","
            end
            encodeValue(t[i], out, depth + 1)
        end
        out[#out + 1] = "]"
        return
    end

    local keys = {}
    for k, v in pairs(t) do
        if (type(k) == "string" or type(k) == "number") and type(v) ~= "function" then
            keys[#keys + 1] = tostring(k)
        end
    end
    table.sort(keys)

    out[#out + 1] = "{"
    for i, k in ipairs(keys) do
        if (i > 1) then
            out[#out + 1] = ","
        end
        out[#out + 1] = '"' .. escapeString(k) .. '":'
        local v = t[k]
        if (v == nil) then
            v = t[tonumber(k)]
        end
        encodeValue(v, out, depth + 1)
    end
    out[#out + 1] = "}"
end

encodeValue = function(v, out, depth)
    local kind = type(v)
    if (v == nil) then
        out[#out + 1] = "null"
    elseif (kind == "boolean") then
        out[#out + 1] = v and "true" or "false"
    elseif (kind == "number") then
        if (v ~= v or v == math.huge or v == -math.huge) then
            out[#out + 1] = "null"
        elseif (math.floor(v) == v and math.abs(v) < 2 ^ 53) then
            out[#out + 1] = string.format("%d", v)
        else
            out[#out + 1] = string.format("%.14g", v)
        end
    elseif (kind == "string") then
        out[#out + 1] = '"' .. escapeString(v) .. '"'
    elseif (kind == "table") then
        encodeTable(v, out, depth)
    else
        out[#out + 1] = "null"
    end
end

function JSON.encode(v)
    local out = {}
    encodeValue(v, out, 0)
    return table.concat(out)
end

-- Decoder

local function decodeError(str, pos, msg)
    error(string.format("JSON.decode: %s at position %d", msg, pos), 0)
end

local function skipWhitespace(str, pos)
    return str:find("[^ \t\r\n]", pos) or (#str + 1)
end

local function codepointToLatin1(cp)
    if (cp <= 0xFF) then
        return string.char(cp)
    end
    return "?"
end

local decodeValue

local function decodeString(str, pos)
    local out, i = {}, pos + 1
    while (true) do
        local c = str:sub(i, i)
        if (c == "") then
            decodeError(str, i, "unterminated string")
        elseif (c == '"') then
            return table.concat(out), i + 1
        elseif (c == "\\") then
            local e = str:sub(i + 1, i + 1)
            local simple = {['"'] = '"', ["\\"] = "\\", ["/"] = "/", b = "\b", f = "\f", n = "\n", r = "\r", t = "\t"}
            if (simple[e]) then
                out[#out + 1] = simple[e]
                i = i + 2
            elseif (e == "u") then
                local hex = str:sub(i + 2, i + 5)
                if (not hex:match("^%x%x%x%x$")) then
                    decodeError(str, i, "invalid unicode escape")
                end
                local cp = tonumber(hex, 16)
                i = i + 6
                if (cp >= 0xD800 and cp <= 0xDBFF and str:sub(i, i + 1) == "\\u") then
                    i = i + 6 -- surrogate pair: outside Latin-1
                end
                out[#out + 1] = codepointToLatin1(cp)
            else
                decodeError(str, i, "invalid escape")
            end
        else
            local b = c:byte()
            if (b < 0x20) then
                decodeError(str, i, "control character in string")
            elseif (b < 0x80) then
                out[#out + 1] = c
                i = i + 1
            else
                -- Raw UTF-8 sequence.
                local length = (b >= 0xF0 and 4) or (b >= 0xE0 and 3) or (b >= 0xC0 and 2) or 1
                local cp = nil
                if (length == 2) then
                    local b2 = str:byte(i + 1) or 0
                    cp = (b % 0x20) * 0x40 + (b2 % 0x40)
                end
                out[#out + 1] = cp and codepointToLatin1(cp) or "?"
                i = i + length
            end
        end
    end
end

local function decodeNumber(str, pos)
    local num = str:match("^-?%d+%.?%d*[eE]?[-+]?%d*", pos)
    if (not num or num == "" or num == "-") then
        decodeError(str, pos, "invalid number")
    end
    local value = tonumber(num)
    if (not value) then
        decodeError(str, pos, "invalid number")
    end
    return value, pos + #num
end

decodeValue = function(str, pos, depth)
    if (depth > 20) then
        decodeError(str, pos, "nesting too deep")
    end

    pos = skipWhitespace(str, pos)
    local c = str:sub(pos, pos)
    if (c == "{") then
        local obj = {}
        pos = skipWhitespace(str, pos + 1)
        if (str:sub(pos, pos) == "}") then
            return obj, pos + 1
        end
        while (true) do
            pos = skipWhitespace(str, pos)
            if (str:sub(pos, pos) ~= '"') then
                decodeError(str, pos, "expected string key")
            end
            local key
            key, pos = decodeString(str, pos)
            pos = skipWhitespace(str, pos)
            if (str:sub(pos, pos) ~= ":") then
                decodeError(str, pos, "expected ':'")
            end
            obj[key], pos = decodeValue(str, pos + 1, depth + 1)
            pos = skipWhitespace(str, pos)
            local d = str:sub(pos, pos)
            if (d == "}") then
                return obj, pos + 1
            elseif (d ~= ",") then
                decodeError(str, pos, "expected ',' or '}'")
            end
            pos = pos + 1
        end
    elseif (c == "[") then
        local arr = JSON.array()
        pos = skipWhitespace(str, pos + 1)
        if (str:sub(pos, pos) == "]") then
            return arr, pos + 1
        end
        local index = 0
        while (true) do
            index = index + 1
            arr[index], pos = decodeValue(str, pos, depth + 1)
            pos = skipWhitespace(str, pos)
            local d = str:sub(pos, pos)
            if (d == "]") then
                return arr, pos + 1
            elseif (d ~= ",") then
                decodeError(str, pos, "expected ',' or ']'")
            end
            pos = pos + 1
        end
    elseif (c == '"') then
        return decodeString(str, pos)
    elseif (str:sub(pos, pos + 3) == "true") then
        return true, pos + 4
    elseif (str:sub(pos, pos + 4) == "false") then
        return false, pos + 5
    elseif (str:sub(pos, pos + 3) == "null") then
        return nil, pos + 4
    elseif (c:match("[-%d]")) then
        return decodeNumber(str, pos)
    end

    decodeError(str, pos, "unexpected character '" .. c .. "'")
end

-- Returns value or nil, errorMessage.
function JSON.decode(str)
    if (type(str) ~= "string") then
        return nil, "JSON.decode: expected a string"
    end

    local ok, value, pos = pcall(decodeValue, str, 1, 0)
    if (not ok) then
        return nil, value
    end

    pos = skipWhitespace(str, pos)
    if (pos <= #str) then
        return nil, "JSON.decode: trailing characters at position " .. pos
    end
    return value
end
