UIGameMap = extends(UIMap, "UIGameMap")

function UIGameMap.create()
  local gameMap = UIGameMap.internalCreate()
  gameMap:setKeepAspectRatio(true)
  gameMap:setVisibleDimension({width = 15, height = 11})
  gameMap:setDrawLights(true)
  return gameMap
end

function UIGameMap:onDragEnter(mousePos)
  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = tile:getTopMoveThing()
  if not thing then return false end

  self.currentDragThing = thing

  g_mouse.pushCursor('target')
  self.allowNextRelease = false
  return true
end

function UIGameMap:onDragLeave(droppedWidget, mousePos)
  self.currentDragThing = nil
  self.hoveredWho = nil
  g_mouse.popCursor('target')
  return true
end

local function IsPokeball(id)
  if id == 16806 then return true end
  if id == 17688 then return true end
  if id == 17692 then return true end
  if id == 17696 then return true end
  if id == 17700 then return true end
  if id == 17704 then return true end
  if id == 17708 then return true end
  if id == 17712 then return true end
  if id == 17716 then return true end
  if id == 17720 then return true end
  if id == 23834 then return true end

  if id >= 11119 and id <= 11121 then return true end
  if id >= 11123 and id <= 11125 then return true end
  if id >= 11127 and id <= 11129 then return true end
  if id >= 11131 and id <= 11133 then return true end
  if id >= 11135 and id <= 11137 then return true end
  if id >= 11139 and id <= 11141 then return true end
  if id >= 11143 and id <= 11145 then return true end
  if id >= 11147 and id <= 11149 then return true end
  if id >= 11150 and id <= 11152 then return true end
  if id >= 11153 and id <= 11162 then return true end
  if id >= 11866 and id <= 11869 then return true end
  if id >= 12041 and id <= 12042 then return true end
  if id >= 16931 and id <= 16933 then return true end
  if id >= 16937 and id <= 16943 then return true end
  if id >= 12718 and id <= 12741 then return true end
  if id >= 12776 and id <= 12781 then return true end
  if id >= 12784 and id <= 12789 then return true end
  if id >= 16776 and id <= 16778 then return true end
  if id >= 17372 and id <= 17380 then return true end
  if id >= 17501 and id <= 17515 then return true end
  if id >= 17535 and id <= 17543 then return true end
  if id >= 17548 and id <= 17556 then return true end
  if id >= 17591 and id <= 17599 then return true end
  if id >= 17685 and id <= 17686 then return true end
  if id >= 17689 and id <= 17690 then return true end
  if id >= 17693 and id <= 17694 then return true end
  if id >= 17697 and id <= 17698 then return true end
  if id >= 17701 and id <= 17702 then return true end
  if id >= 17705 and id <= 17706 then return true end
  if id >= 17709 and id <= 17710 then return true end
  if id >= 17713 and id <= 17714 then return true end
  if id >= 17717 and id <= 17718 then return true end
  if id >= 17730 and id <= 17738 then return true end
  if id >= 22209 and id <= 22210 then return true end
  if id >= 23209 and id <= 23217 then return true end
  if id >= 23221 and id <= 23224 then return true end
  if id >= 23247 and id <= 23258 then return true end
  if id >= 23262 and id <= 23280 then return true end
  if id >= 23332 and id <= 23352 then return true end
  if id >= 23799 and id <= 23816 then return true end
  if id >= 23956 and id <= 23985 then return true end
  if id >= 23996 and id <= 24031 then return true end
  if id >= 26062 and id <= 26063 then return true end
  if id >= 26260 and id <= 26358 then return true end
  if id >= 26405 and id <= 26407 then return true end
  if id >= 26409 and id <= 26411 then return true end
  if id >= 26413 and id <= 26415 then return true end
  if id >= 26417 and id <= 26419 then return true end
  if id >= 26421 and id <= 26423 then return true end
  if id >= 26425 and id <= 26427 then return true end
  if id >= 26429 and id <= 26431 then return true end
  if id >= 26433 and id <= 26435 then return true end
  if id >= 26437 and id <= 26439 then return true end
  if id >= 26625 and id <= 26627 then return true end
  if id >= 26629 and id <= 26631 then return true end
  if id >= 26633 and id <= 26635 then return true end
  if id >= 26637 and id <= 26639 then return true end
  if id >= 26641 and id <= 26643 then return true end
  if id >= 26645 and id <= 26647 then return true end
  if id >= 26649 and id <= 26651 then return true end
  if id >= 26653 and id <= 26655 then return true end
  if id >= 26657 and id <= 26659 then return true end
  if id >= 26661 and id <= 26663 then return true end
  if id >= 26665 and id <= 26667 then return true end
  if id >= 26720 and id <= 26758 then return true end
  if id >= 26800 and id <= 26802 then return true end
  if id >= 26804 and id <= 26806 then return true end
  if id >= 26808 and id <= 26810 then return true end
  if id >= 26812 and id <= 26814 then return true end
  if id >= 26816 and id <= 26818 then return true end
  if id >= 26820 and id <= 26822 then return true end
  if id >= 26824 and id <= 26826 then return true end
  if id >= 26828 and id <= 26830 then return true end
  if id >= 26832 and id <= 26834 then return true end
  if id >= 26836 and id <= 26838 then return true end
  if id >= 26840 and id <= 26842 then return true end
  if id >= 26844 and id <= 26846 then return true end
  if id >= 26848 and id <= 26850 then return true end
  if id >= 26852 and id <= 26854 then return true end
  if id >= 26856 and id <= 26858 then return true end
  if id >= 26860 and id <= 26862 then return true end
  if id >= 26864 and id <= 26866 then return true end
  if id >= 26868 and id <= 26870 then return true end
  if id >= 26872 and id <= 26874 then return true end
  if id >= 26876 and id <= 26878 then return true end
  if id >= 26880 and id <= 26882 then return true end
  if id >= 26884 and id <= 26886 then return true end
  if id >= 26888 and id <= 26890 then return true end
  if id >= 28631 and id <= 28633 then return true end
  if id >= 28635 and id <= 28637 then return true end
  if id >= 28639 and id <= 28641 then return true end
  if id >= 28645 and id <= 28647 then return true end
  if id >= 28649 and id <= 28651 then return true end
  if id >= 28653 and id <= 28655 then return true end
  if id >= 28657 and id <= 28659 then return true end
  if id >= 28661 and id <= 28663 then return true end
  if id >= 28665 and id <= 28667 then return true end
  return false
end
local function IsBag(id)
  if id == 2853 then return true end
  if id == 2854 then return true end
  if id == 11243 then return true end
  if id == 11872 then return true end
  if id == 11418 then return true end
  if id == 16951 then return true end
  if id == 16969 then return true end
  if id == 17368 then return true end
  if id == 17590 then return true end
  if id == 23330 then return true end
  if id == 23885 then return true end

  if id >= 22121 and id <= 22153 then return true end
  if id >= 22160 and id <= 22169 then return true end
  if id >= 11599 and id <= 11608 then return true end
  if id >= 23878 and id <= 23879 then return true end
  if id >= 24046 and id <= 24049 then return true end
  if id >= 26477 and id <= 26485 then return true end
  if id >= 26567 and id <= 26570 then return true end
  return false
end

function UIGameMap:onDrop(widget, mousePos)
  if not self:canAcceptDrop(widget, mousePos) then return false end

  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = widget.currentDragThing
  local toPos = tile:getPosition() --Tem certeza que deseja jogar seu Pokémon ou mochila no chão?

  local frombag
  local thingPos = thing:getPosition()
  if thingPos.x == toPos.x and thingPos.y == toPos.y and thingPos.z == toPos.z then
    return false
  elseif tonumber(thingPos.x) and tonumber(thingPos.x) == 65535 then
  frombag = true
  else
  frombag = false
  end

  if thing:isItem() and thing:getCount() > 1 then
    modules.game_interface.moveStackableItem(thing, toPos)
  elseif frombag and (thing:isContainer() or IsBag(thing:getId())) then -- bag
  showBagWindow(thing, toPos)
  elseif IsPokeball(thing:getId()) then -- pokemon
  showPokeWindow(thing, toPos)
  else
    g_game.move(thing, toPos, 1)
  end

  return true
end

function UIGameMap:onMousePress()
  if not self:isDragging() then
    self.allowNextRelease = true
  end
end

function UIGameMap:onMouseRelease(mousePosition, mouseButton)
  if not self.allowNextRelease then
    return true
  end

  local autoWalkPos = self:getPosition(mousePosition)

  -- happens when clicking outside of map boundaries
  if not autoWalkPos then return false end

  local localPlayerPos = g_game.getLocalPlayer():getPosition()
  if autoWalkPos.z ~= localPlayerPos.z then
    local dz = autoWalkPos.z - localPlayerPos.z
    autoWalkPos.x = autoWalkPos.x + dz
    autoWalkPos.y = autoWalkPos.y + dz
    autoWalkPos.z = localPlayerPos.z
  end

  local lookThing
  local useThing
  local creatureThing
  local multiUseThing
  local attackCreature

  local tile = self:getTile(mousePosition)
  if tile then
    lookThing = tile:getTopLookThing()
    useThing = tile:getTopUseThing()
    creatureThing = tile:getTopCreature()
  end

  local autoWalkTile = g_map.getTile(autoWalkPos)
  if autoWalkTile then
    attackCreature = autoWalkTile:getTopCreature()
  end

  local ret = modules.game_interface.processMouseAction(mousePosition, mouseButton, autoWalkPos, lookThing, useThing, creatureThing, attackCreature)
  if ret then
    self.allowNextRelease = false
  end

  return ret
end

function UIGameMap:canAcceptDrop(widget, mousePos)
  if not widget or not widget.currentDragThing then return false end

  local children = rootWidget:recursiveGetChildrenByPos(mousePos)
  for i=1,#children do
    local child = children[i]
    if child == self then
      return true
    elseif not child:isPhantom() then
      return false
    end
  end

  error('Widget ' .. self:getId() .. ' not in drop list.')
  return false
end
