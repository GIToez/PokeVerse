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

-- Using the evolve icon (server item 13204, kept in the hidden necklace slot) evolves the
-- Pokemon that is out; the server checks level, stones and time of day.
EVOLVE_ICON_ITEMID = 11595

function g_game.evolvePokemon()
  g_game.useInventoryItem(EVOLVE_ICON_ITEMID)
end

-- True while a text field has the focus (the chat, a search box, a window's name field...).
function Keybind.isTyping()
  local widget = rootWidget:getFocusedChild()
  while widget do
    if widget:getClassName() == 'UITextEdit' and widget:isEnabled() and widget:isVisible() then
      return true
    end
    widget = widget:getFocusedChild()
  end
  return false
end

local function typesText(keyCode)
  local modifiers = g_keyboard.getModifiers()
  return keyCode and keyCode >= KeySpace and keyCode <= KeyTilde
    and (modifiers == KeyboardNoModifier or modifiers == KeyboardShiftModifier)
end

-- With the chat off letters are keybinds, but a focused text field still gets them as text.
-- Key up stays unguarded so a held walk key always stops.
local function guardCallbacks(callbacks)
  if not callbacks or callbacks.guarded then
    return callbacks
  end
  local guarded = { guarded = true }
  for i, entry in ipairs(callbacks) do
    local callback = entry.callback
    if entry.type == KEY_UP or type(callback) ~= 'function' then
      guarded[i] = entry
    else
      guarded[i] = { type = entry.type, alone = entry.alone, callback = function(widget, keyCode, ...)
        if typesText(keyCode) and Keybind.isTyping() then
          return false
        end
        return callback(widget, keyCode, ...)
      end }
    end
  end
  return guarded
end

local hotkeyCallback = Keybind.hotkeyCallback
function Keybind.hotkeyCallback(hotkeyId, chatMode)
  local modifiers = g_keyboard.getModifiers()
  if (modifiers == KeyboardNoModifier or modifiers == KeyboardShiftModifier) and Keybind.isTyping() then
    return
  end
  return hotkeyCallback(hotkeyId, chatMode)
end

-- Keybind has no change event; every rebind and chat mode switch binds the keys again.
local keybindBind = Keybind.bind
function Keybind.bind(category, action, callbacks, widget)
  keybindBind(category, action, guardCallbacks(callbacks), widget)
  signalcall(Keybind.onBind, category, action)
end

local keyLabelPrefixes = { ['Ctrl+'] = 'C', ['Shift+'] = 'S', ['Alt+'] = 'A' }

-- The primary key of a keybind in the current chat mode, short enough for a slot corner.
function Keybind.getShortLabel(category, action)
  local keys = Keybind.defaultKeybinds[category .. '_' .. action] and Keybind.getKeybindKeys(category, action)
  local label = keys and keys.primary or ''
  for prefix, short in pairs(keyLabelPrefixes) do
    label = label:gsub(prefix:gsub('%+', '%%+'), short)
  end
  return label
end

function g_game.getProtocolVersionForClient(client)
  return client
end

-- The public half of the live server's login key (scripts/live/rsa-public.txt; the server keeps the
-- private half in rsaKeyFile). Local and LAN servers have no private key and use the open OTSERV_RSA.
POKEVERSE_RSA = '1370212124277828241391014579465689169715776223351497970034338772' ..
  '2934560134687802832439342361963057476393284893871131732860435658' ..
  '2172586513605952870081552071314463015892547516009731659457467234' ..
  '7447192739775193466847117351663138559610791329703090765978219150' ..
  '36331377901836590004001817446365041607212123021152273'

local function isLocalHost(host)
  host = host:lower()
  if host == 'localhost' or host:find('^127%.') or host:find('^10%.') or host:find('^192%.168%.') then
    return true
  end
  local second = tonumber(host:match('^172%.(%d+)%.'))
  return second ~= nil and second >= 16 and second <= 31
end

-- The legacy entergame calls this before setClientVersion, so Redemption's 7.60 hack
-- (custom OS 2) would fire; the server only reads the locale byte from OTClient OS ids.
function g_game.chooseRsa(host)
  if G.currentRsa == CIPSOFT_RSA then
    g_game.setCustomOs(-1)
  end
  g_game.setRsa(isLocalHost(host or '') and OTSERV_RSA or POKEVERSE_RSA)
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
ExtendedIds.SummonOwner = 11
ExtendedIds.PokemonStats = 12
ExtendedIds.AutoLoot = 13
ExtendedIds.Evolution = 14
ExtendedIds.DailyTasks = 15
ExtendedIds.LevelUp = 16
ExtendedIds.TaskBoards = 17
ExtendedIds.DailyLogin = 18
ExtendedIds.MoveEnergy = 19
ExtendedIds.Gts = 20
ExtendedIds.Pc = 21
ExtendedIds.Gym = 22
ExtendedIds.Pokepedia = 23
ExtendedIds.Vocation = 24
ExtendedIds.Radar = 25
ExtendedIds.Fishing = 26
ExtendedIds.TrainerCard = 27
ExtendedIds.Daycare = 28
ExtendedIds.HeldItem = 29
ExtendedIds.Admin = 30
ExtendedIds.Quest = 31
ExtendedIds.MoveInfo = 32
ExtendedIds.Calendar = 33
ExtendedIds.Legendary = 34
ExtendedIds.Weather = 35
ExtendedIds.CreatureStatus = 36
ExtendedIds.PokemonShop = 37
ExtendedIds.Hints = 38
ExtendedIds.Report = 39
ExtendedIds.Ping = 40
ExtendedIds.Store = 41
ExtendedIds.ExpBoost = 42
ExtendedIds.PokedexDetails = 43
ExtendedIds.Bank = 44
ExtendedIds.LegendaryFlight = 45
ExtendedIds.BattleText = 46
ExtendedIds.Announcement = 47
ExtendedIds.HealMark = 48
ExtendedIds.EventShop = 49
ExtendedIds.Analyser = 50
ExtendedIds.Mega = 51
ExtendedIds.MegaEvolve = 52
ExtendedIds.Bag = 53

-- Long extended opcode messages arrive as "#id:index:count:" fragments (doSendPlayerLongExtendedOpcode
-- on the server), and the server's output pool can deliver them out of order. Gives back the whole
-- message once every piece is in, nil until then.
local fragments, fragmentKeys = {}, {}
function ProtocolGame.joinFragments(opcode, buffer)
  if buffer:sub(1, 1) ~= '#' then
    return buffer
  end
  local id, index, count, piece = buffer:match('^#(%d+):(%d+):(%d+):(.*)$')
  if not id then
    g_logger.warning('Invalid message fragment on extended opcode ' .. tostring(opcode))
    return nil
  end
  index, count = tonumber(index), tonumber(count)
  local key = opcode .. ':' .. id
  local entry = fragments[key]
  if not entry then
    entry = { count = count, got = 0, pieces = {} }
    fragments[key] = entry
    table.insert(fragmentKeys, key)
    if #fragmentKeys > 16 then
      fragments[table.remove(fragmentKeys, 1)] = nil
    end
  end
  if not entry.pieces[index] then
    entry.pieces[index] = piece
    entry.got = entry.got + 1
  end
  if entry.got < entry.count then
    return nil
  end
  fragments[key] = nil
  table.removevalue(fragmentKeys, key)
  return table.concat(entry.pieces)
end

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

-- legacy corelib, used by game_environment
if not isTable then
function isTable(v)
  return type(v) == 'table'
end
end
