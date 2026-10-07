-- Round-trip test for the ExtendedOpcode payload format: server table.tostring
-- (data/lib/012-table.lua) -> client table.fromLiteral (modules/corelib/table.lua).
-- Run from the repository root: lua5.1 tools/test_payload_codec.lua
-- The client file is loaded first because it also defines table.tostring.
dofile("client/runtime-data/modules/corelib/table.lua")
dofile("server/runtime-data/data/lib/012-table.lua")

local failures = 0

local function eq(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k, v in pairs(a) do if not eq(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end

local payloads = {
  {protocol = "Market", items = {[1] = {name = "Ultra Ball", price = 1500}, [5] = {name = 'x"] os.exit() --', price = -2.5}}},
  {list = {1, 2, 3, nil, 5}, mixed = {10, 20, key = "v", [100] = true}},
  {s = "back\\slash \"quote\" \n newline \0 nul \200 latin1", t = {}},
  {deep = {a = {b = {c = {d = "x"}}}}, flag = false},
}
for i, payload in ipairs(payloads) do
  local text = table.tostring(payload)
  local ok, decoded = pcall(table.fromLiteral, text)
  if not (ok and eq(payload, decoded)) then
    failures = failures + 1
    print("FAIL round trip " .. i .. ": " .. tostring(decoded) .. " :: " .. text)
  end
end

local hostile = {
  "{os.exit(1)}", '{a = print("x")}', 'os.execute("id")', "{[1] = (function() end)}",
  "{x = y}", "{a = 1} os.exit(1)", string.rep("{", 200) .. string.rep("}", 200),
}
for _, text in ipairs(hostile) do
  local ok, decoded = pcall(table.fromLiteral, text)
  if ok and decoded ~= nil then
    failures = failures + 1
    print("FAIL accepted code: " .. text:sub(1, 60))
  end
end

if failures > 0 then os.exit(1) end
print(#payloads .. " payloads round-tripped, " .. #hostile .. " hostile inputs rejected")
