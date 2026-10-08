-- Unit tests for core/server/data/lib/013-json.lua (run: lua5.1 scripts/test-lua-json.lua)
local root = arg and arg[0] and arg[0]:match("^(.*)/scripts/") or "."
dofile(root .. "/core/server/data/lib/013-json.lua")

local failures, count = 0, 0
local function check(name, condition)
    count = count + 1
    if (not condition) then
        failures = failures + 1
        print("FAIL: " .. name)
    end
end

-- Encoding
check("encode object sorted", JSON.encode({b = 1, a = "x"}) == '{"a":"x","b":1}')
check("encode array", JSON.encode({1, 2, 3}) == "[1,2,3]")
check("encode empty array", JSON.encode(JSON.array()) == "[]")
check("encode empty object", JSON.encode({}) == "{}")
check("encode bools", JSON.encode({t = true, f = false}) == '{"f":false,"t":true}')
check("encode float", JSON.encode(1.5) == "1.5")
check("encode escapes", JSON.encode('a"b\\c\n') == '"a\\"b\\\\c\\n"')
check("encode latin1", JSON.encode("caf\233") == '"caf\\u00e9"')
check("encode control", JSON.encode("\1") == '"\\u0001"')
check("encode nested", JSON.encode({x = {y = {1}}}) == '{"x":{"y":[1]}}')
check("encode nan", JSON.encode(0 / 0) == "null")

-- Decoding
local v = JSON.decode('{"type":"request","requestId":"r1","params":{"name":"Pikachu","limit":5}}')
check("decode object", v and v.type == "request" and v.params.name == "Pikachu" and v.params.limit == 5)
v = JSON.decode('[1, "two", true, false, null, 3.25, -4e2]')
check("decode array", v and v[1] == 1 and v[2] == "two" and v[3] == true and v[4] == false and v[6] == 3.25 and v[7] == -400)
check("decode unicode latin1", JSON.decode('"caf\\u00e9"') == "caf\233")
check("decode unicode outside latin1", JSON.decode('"\\u4e2d"') == "?")
check("decode surrogate pair", JSON.decode('"a\\ud83d\\ude00b"') == "a?b")
check("decode raw utf8 2-byte", JSON.decode('"caf\195\169"') == "caf\233")
check("decode raw utf8 4-byte", JSON.decode('"x\240\159\152\128y"') == "x?y")
check("decode escapes", JSON.decode('"a\\"b\\\\c\\/d\\n"') == 'a"b\\c/d\n')
check("decode whitespace", JSON.decode('  { "a" : [ ] }  ').a ~= nil)

local bad = {'{"a":1', '{"a" 1}', '[1,]x', '"unterminated', '{"a":tru}', "", "nul", '{"a":1}x', '"\1"'}
for _, input in ipairs(bad) do
    local value, err = JSON.decode(input)
    check("reject " .. input, value == nil and type(err) == "string")
end
check("reject non-string", JSON.decode(nil) == nil)

local deep = string.rep("[", 30) .. string.rep("]", 30)
check("reject deep nesting", JSON.decode(deep) == nil)

-- Round trip
local original = {kind = "catch", trainer = "Red", level = 25, shiny = true, list = JSON.array({"a", "b"})}
local decoded = JSON.decode(JSON.encode(original))
check("round trip", decoded.kind == "catch" and decoded.trainer == "Red" and decoded.level == 25 and decoded.shiny == true
    and decoded.list[2] == "b")

print(string.format("%d/%d JSON tests passed", count - failures, count))
os.exit(failures == 0 and 0 or 1)
