function onUse(cid, item, frompos, item2, topos)

local presente = {box = {34533, 1}}

if getPlayerItemCount(cid, presente.box[1]) >= presente.box[2] then
local Pokebolas = {
{[12157] = math.random(1, 70)}, --- Pokeball
{[12161] = math.random(1, 70)}, --- greatball
{[12165] = math.random(1, 30)}, --- superball
}
local potion = {
{[12245] = math.random(1, 50)},
{[13653] = math.random(1, 50)},
}
local PokeBalls = math.random(1,#Pokebolas)
for item, quantidade in pairs(Pokebolas[PokeBalls]) do
doPlayerAddItem(cid, item, quantidade)
end
local Potions = math.random(1,#potion)
for item, quantidade in pairs(potion[Potions]) do
doPlayerAddItem(cid, item, quantidade)
end
doRemoveItem(item.uid, 1)
else
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Para abrir este presente você precisa coloca-lo na mochila.")
doSendMagicEffect(getCreaturePosition(cid), 2)
return true
end 
end