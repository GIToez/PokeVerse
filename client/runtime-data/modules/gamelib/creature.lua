-- @docclass Creature

-- @docconsts @{

SkullNone = 0
SkullYellow = 1
SkullGreen = 2
SkullWhite = 3
SkullRed = 4
SkullBlack = 5
SkullOrange = 6

ShieldNone = 0
ShieldWhiteYellow = 1
ShieldWhiteBlue = 2
ShieldBlue = 3
ShieldYellow = 4
ShieldBlueSharedExp = 5
ShieldYellowSharedExp = 6
ShieldBlueNoSharedExpBlink = 7
ShieldYellowNoSharedExpBlink = 8
ShieldBlueNoSharedExp = 9
ShieldYellowNoSharedExp = 10

EmblemNone = 0
EmblemGreen = 1
EmblemRed = 2
EmblemBlue = 3

NpcIconNone = 0
NpcIconChat = 1
NpcIconTrade = 2
NpcIconQuest = 3
NpcIconTradeQuest = 4
NpcIconStar = 5
NpcIconBattle = 6
NpcIconSkull = 7

-- @}

function getTypingImagePath(typeId)
  local path
  if typeId == 1 then
    path = '/images/types/mini_type/Normal'
  elseif typeId == 2 then
    path = '/images/types/mini_type/Fighting'
  elseif typeId == 3 then
    path = '/images/types/mini_type/Fly'
  elseif typeId == 4 then
    path = '/images/types/mini_type/Poison'
  elseif typeId == 5 then
    path = '/images/types/mini_type/Ground'
  elseif typeId == 6 then
    path = '/images/types/mini_type/Rock'
  elseif typeId == 7 then
    path = '/images/types/mini_type/Bug'
  elseif typeId == 8 then
    path = '/images/types/mini_type/Ghost'
  elseif typeId == 9 then
    path = '/images/types/mini_type/Steel'
  elseif typeId == 10 then
    path = '/images/types/mini_type/Fire'
  elseif typeId == 11 then
    path = '/images/types/mini_type/Water'
  elseif typeId == 12 then
    path = '/images/types/mini_type/Grass'
  elseif typeId == 13 then
    path = '/images/types/mini_type/Electric'
  elseif typeId == 14 then
    path = '/images/types/mini_type/Psychic'
  elseif typeId == 15 then
    path = '/images/types/mini_type/Ice'
  elseif typeId == 16 then
    path = '/images/types/mini_type/Dragon'
  elseif typeId == 17 then
    path = '/images/types/mini_type/Dark'
  elseif typeId == 18 then
    path = '/images/types/mini_type/Fairy'
  elseif typeId == 20 then
    path = '/images/types/mini_type/clean'
  end
  return path
end

function getSkullImagePath(skullId)
  local path
  if skullId == SkullYellow then
    path = '/images/game/skulls/skull_yellow'
  elseif skullId == SkullGreen then
    path = '/images/game/skulls/skull_green'
  elseif skullId == SkullWhite then
    path = '/images/game/skulls/skull_white'
  elseif skullId == SkullRed then
    path = '/images/game/skulls/skull_red'
  elseif skullId == SkullBlack then
    path = '/images/game/skulls/skull_black'
  elseif skullId == SkullOrange then
    path = '/images/game/skulls/skull_orange'
  end
  return path
end

function getShieldImagePathAndBlink(shieldId)
  local path, blink
  if shieldId == ShieldWhiteYellow then
    path, blink = '/images/game/shields/shield_yellow_white', false
  elseif shieldId == ShieldWhiteBlue then
    path, blink = '/images/game/shields/shield_blue_white', false
  elseif shieldId == ShieldBlue then
    path, blink = '/images/game/shields/shield_blue', false
  elseif shieldId == ShieldYellow then
    path, blink = '/images/game/shields/shield_yellow', false
  elseif shieldId == ShieldBlueSharedExp then
    path, blink = '/images/game/shields/shield_blue_shared', false
  elseif shieldId == ShieldYellowSharedExp then
    path, blink = '/images/game/shields/shield_yellow_shared', false
  elseif shieldId == ShieldBlueNoSharedExpBlink then
    path, blink = '/images/game/shields/shield_blue_not_shared', true
  elseif shieldId == ShieldYellowNoSharedExpBlink then
    path, blink = '/images/game/shields/shield_yellow_not_shared', true
  elseif shieldId == ShieldBlueNoSharedExp then
    path, blink = '/images/game/shields/shield_blue_not_shared', false
  elseif shieldId == ShieldYellowNoSharedExp then
    path, blink = '/images/game/shields/shield_yellow_not_shared', false
  elseif shieldId == ShieldGray then
    path, blink = '/images/game/shields/shield_gray', false
  end
  return path, blink
end

function getEmblemImagePath(emblemId)
  local path
  if emblemId == EmblemGreen then
    path = '/images/game/emblems/emblem_green'
  elseif emblemId == EmblemRed then
    path = '/images/game/emblems/emblem_red'
  elseif emblemId == EmblemBlue then
    path = '/images/game/emblems/emblem_blue'
  elseif emblemId == EmblemMember then
    path = '/images/game/emblems/emblem_member'
  elseif emblemId == EmblemOther then
    path = '/images/game/emblems/emblem_other'
  end
  return path
end

function getIconImagePath(iconId)
  local path
  if iconId == NpcIconChat then
    path = '/images/game/npcicons/icon_chat'
  elseif iconId == NpcIconTrade then
    path = '/images/game/npcicons/icon_trade'
  elseif iconId == NpcIconQuest then
    path = '/images/game/npcicons/icon_quest'
  elseif iconId == NpcIconTradeQuest then
    path = '/images/game/npcicons/icon_tradequest'
  elseif iconId == NpcIconStar then
    path = '/images/game/npcicons/icon_star'
  elseif iconId == NpcIconBattle then
    path = '/images/game/npcicons/icon_battle'
  elseif iconId == NpcIconSkull then
    path = '/images/game/npcicons/icon_skull'
  end
  return path
end

function Creature:onSetNewInfo(firstType, secondType, clevel, cexp)
  local imagePath = getTypingImagePath(firstType)
  if imagePath then
    self:setFirstTypeTexture(imagePath)
  end
  imagePath = getTypingImagePath(secondType)
  if imagePath then
    self:setSecondTypeTexture(imagePath)
  end
end

function Creature:onSkullChange(skullId)
  local imagePath = getSkullImagePath(skullId)
  if imagePath then
    self:setSkullTexture(imagePath)
  end
end

function Creature:onShieldChange(shieldId)
  local imagePath, blink = getShieldImagePathAndBlink(shieldId)
  if imagePath then
    self:setShieldTexture(imagePath, blink)
  end
end

function Creature:onEmblemChange(emblemId)
  local imagePath = getEmblemImagePath(emblemId)
  if imagePath then
    self:setEmblemTexture(imagePath)
  end
end

function Creature:onIconChange(iconId)
  local imagePath = getIconImagePath(iconId)
  if imagePath then
    self:setIconTexture(imagePath)
  end
end