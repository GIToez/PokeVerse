-- Names from the legacy gamelib that the PokeVerse modules use and Redemption's gamelib
-- does not have (or defines differently for Tibia).

PLAYER_SKILL_DUEL_WIN = 0
PLAYER_SKILL_DUEL_LOSS = 1
PLAYER_SKILL_BATTLE_WIN = 2
PLAYER_SKILL_BATTLE_LOSS = 3
PLAYER_SKILL_HEADBUTTING = 4
PLAYER_SKILL_CATCHING = 5
PLAYER_SKILL_FISHING = 6

GameMesssageLevel = 46
GamePokeVerse = 138

-- the login packet carries the legacy client's picture signature
PIC_SIGNATURE = 0x52de78da

-- the server's NPC icons 5 to 7 are PokeVerse icons, not Redemption's traveler and hireling
NpcIconStar = 5
NpcIconBattle = 6
NpcIconSkull = 7

local npcIconPaths = {
  [NpcIconChat] = '/images/game/npcicons/icon_chat',
  [NpcIconTrade] = '/images/game/npcicons/icon_trade',
  [NpcIconQuest] = '/images/game/npcicons/icon_quest',
  [NpcIconTradeQuest] = '/images/game/npcicons/icon_tradequest',
  [NpcIconStar] = '/images/game/npcicons/icon_star',
  [NpcIconBattle] = '/images/game/npcicons/icon_battle',
  [NpcIconSkull] = '/images/game/npcicons/icon_skull',
}

function getIconImagePath(iconId)
  return npcIconPaths[iconId]
end

-- clans
local clanByVocation = { 'blaze', 'hurricane', 'voltagic', 'spectrum', 'vital', 'gaia', 'avalanche', 'heremit', 'zen' }

function getVocationNameById(vocation)
  local clan = math.floor(vocation / 10)
  if vocation % 10 <= 5 and clanByVocation[clan] then
    return clanByVocation[clan]
  end
  return 'trainer'
end

function g_game.getProtocolVersionForClient(client)
  return client
end

-- The legacy entergame calls this before setClientVersion, so Redemption's 7.60 hack
-- (custom OS 2) would fire; the server only reads the locale byte from OTClient OS ids.
function g_game.chooseRsa(host)
  if G.currentRsa ~= CIPSOFT_RSA and G.currentRsa ~= OTSERV_RSA then
    return
  end
  if G.currentRsa == CIPSOFT_RSA then
    g_game.setCustomOs(-1)
  end
  g_game.setRsa(OTSERV_RSA)
end

function Position.isIn(pos, fromPos, toPos)
  return pos.x >= fromPos.x and pos.y >= fromPos.y and pos.z >= fromPos.z and
         pos.x <= toPos.x and pos.y <= toPos.y and pos.z <= toPos.z
end

local directionOffsets = {
  [North] = { 0, -1 }, [South] = { 0, 1 }, [West] = { -1, 0 }, [East] = { 1, 0 },
  [NorthWest] = { -1, -1 }, [NorthEast] = { 1, -1 }, [SouthWest] = { -1, 1 }, [SouthEast] = { 1, 1 },
}

function Position.getPositionByDirection(position, direction, size)
  local n = size or 1
  local offset = directionOffsets[direction]
  if offset then
    position.x = position.x + offset[1] * n
    position.y = position.y + offset[2] * n
  end
  return position
end

MarketItemDescription = {
  Armor = 1, Attack = 2, Container = 3, Defense = 4, General = 5, DecayTime = 6, Combat = 7,
  MinLevel = 8, MinMagicLevel = 9, Vocation = 10, Rune = 11, Ability = 12, Charges = 13,
  WeaponName = 14, Weight = 15
}
MarketItemDescription.First = MarketItemDescription.Armor
MarketItemDescription.Last = MarketItemDescription.Weight

MarketItemDescriptionStrings = {
  [1] = 'Armor', [2] = 'Attack', [3] = 'Container', [4] = 'Defense', [5] = 'Description',
  [6] = 'Use Time', [7] = 'Combat', [8] = 'Min Level', [9] = 'Min Magic Level', [10] = 'Vocation',
  [11] = 'Rune', [12] = 'Ability', [13] = 'Charges', [14] = 'Weapon Type', [15] = 'Weight'
}

function getMarketDescriptionName(id)
  return MarketItemDescriptionStrings[id]
end

function getMarketDescriptionId(name)
  return table.find(MarketItemDescriptionStrings, name)
end

-- PokeVerse extended opcodes (server data/lib/ps)
ExtendedIds.GameplayTutorialText = 8
ExtendedIds.GameplayTutorialImage = 9
ExtendedIds.DashWalking = 10

function UIMiniWindow:setDroppable(v)
  self.droppable = v
end

function UIMiniWindow:getDroppable()
  return self.droppable
end

-- legacy corelib, used by game_pokedex (the accent table is Latin-1, like the server text)
if not string.stripAccents then
local tableAccents = {["à"] = "a", ["á"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a", ["ç"] = "c", ["è"] = "e", ["é"] = "e", ["ê"] = "e", ["ë"] = "e", ["ì"] = "i", ["í"] = "i", ["î"] = "i", ["ï"] = "i", ["ñ"] = "n", ["ò"] = "o", ["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ö"] = "o", ["ù"] = "u", ["ú"] = "u", ["û"] = "u", ["ü"] = "u", ["ý"] = "y", ["ÿ"] = "y", ["À"] = "A", ["Á"] = "A", ["Â"] = "A", ["Ã"] = "A", ["Ä"] = "A", ["Ç"] = "C", ["È"] = "E", ["É"] = "E", ["Ê"] = "E", ["Ë"] = "E", ["Ì"] = "I", ["Í"] = "I", ["Î"] = "I", ["Ï"] = "I", ["Ñ"] = "N", ["Ò"] = "O", ["Ó"] = "O", ["Ô"] = "O", ["Õ"] = "O", ["Ö"] = "O", ["Ù"] = "U", ["Ú"] = "U", ["Û"] = "U", ["Ü"] = "U", ["Ý"] = "Y"}
function string.stripAccents(str)
  local normalizedString = ""
  for strChar in str:gmatch"." do --for strChar in string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do
  if tableAccents[strChar] ~= nil then
    normalizedString = normalizedString .. tableAccents[strChar]
  else
    normalizedString = normalizedString .. strChar
  end
  end
  return normalizedString
end
end
