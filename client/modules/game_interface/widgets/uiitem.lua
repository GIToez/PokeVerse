function UIItem:onDragEnter(mousePos)
  if self:isVirtual() then return false end

  local item = self:getItem()
  if not item then return false end

  self:setBorderWidth(1)
  self.currentDragThing = item
  g_mouse.pushCursor('target')
  return true
end

function UIItem:onDragLeave(droppedWidget, mousePos)
  if self:isVirtual() then return false end
  self.currentDragThing = nil
  g_mouse.popCursor('target')
  self:setBorderWidth(0)
  self.hoveredWho = nil
  return true
end

function UIItem:onDrop(widget, mousePos)
  if not self:canAcceptDrop(widget, mousePos) then return false end

  local item = widget.currentDragThing

  if not item:isItem() then return false end
  
  if self.itemVirtual then
    UIItemVirtual:hide()
    return false
  end

  local toPos = self.position
  if modules.game_market.getMakeOfferWindow():isVisible() then
  local toWidget = modules.game_market.getMakeOfferWindow():recursiveGetChildByPos(mousePos, false)
    if toWidget then
      toWidget:setBorderWidth(0)
      local pos = item:getPosition()
      local x,y,z = pos.x,pos.y,pos.z
      getStackableItemCount(item, x,y,z)
    return false
    end
  end

  local itemPos = item:getPosition()
  if not itemPos then
    self:setBorderWidth(0)
    self.hoveredWho = nil
    return false
  end
  if itemPos.x == toPos.x and itemPos.y == toPos.y and itemPos.z == toPos.z then return false end

  if item:getCount() > 1 then
    modules.game_interface.moveStackableItem(item, toPos)
  else
    g_game.move(item, toPos, 1)
  end

  self:setBorderWidth(0)
  return true
end

function getStackableItemCount(item, x,y,z)
  if countWindow then return end
  if g_keyboard.isCtrlPressed() then
    return modules.game_market.marketMakeOffer(x, y, z, item:getCount())
  elseif g_keyboard.isShiftPressed() then
    return modules.game_market.marketMakeOffer(x, y, z, 1)
  end
  local count = item:getCount()
  
  countWindow = g_ui.createWidget('CountWindow', rootWidget)
  local itembox = countWindow:getChildById('item')
  local scrollbar = countWindow:getChildById('countScrollBar')
  itembox:setItemId(item:getId())
  itembox:setItemCount(count)
  scrollbar:setMaximum(count)
  scrollbar:setMinimum(1)
  scrollbar:setValue(count)
  
  local spinbox = countWindow:getChildById('spinBox')
  spinbox:setMaximum(count)
  spinbox:setMinimum(0)
  spinbox:setValue(0)
  spinbox:hideButtons()
  spinbox:focus()
  spinbox.firstEdit = true
  
  local spinBoxValueChange = function(self, value)
  spinbox.firstEdit = false
  scrollbar:setValue(value)
  end
  spinbox.onValueChange = spinBoxValueChange
  
  local check = function()
    if spinbox.firstEdit then
      spinbox:setValue(spinbox:getMaximum())
      spinbox.firstEdit = false
    end
  end
  g_keyboard.bindKeyPress("Up", function() check() spinbox:up() end, spinbox)
  g_keyboard.bindKeyPress("Down", function() check() spinbox:down() end, spinbox)
  g_keyboard.bindKeyPress("Right", function() check() spinbox:up() end, spinbox)
  g_keyboard.bindKeyPress("Left", function() check() spinbox:down() end, spinbox)
  g_keyboard.bindKeyPress("PageUp", function() check() spinbox:setValue(spinbox:getValue()+10) end, spinbox)
  g_keyboard.bindKeyPress("PageDown", function() check() spinbox:setValue(spinbox:getValue()-10) end, spinbox)
  
  scrollbar.onValueChange = function(self, value)
    itembox:setItemCount(value)
    spinbox.onValueChange = nil
    spinbox:setValue(value)
    spinbox.onValueChange = spinBoxValueChange
  end
  
  local okButton = countWindow:getChildById('buttonOk')
  local moveFunc = function()
    count = itembox:getItemCount()
    okButton:getParent():destroy()
    countWindow = nil
    return modules.game_market.marketMakeOffer(x, y, z, count)
  end
  local cancelButton = countWindow:getChildById('buttonCancel')
  local cancelFunc = function()
    cancelButton:getParent():destroy()
    countWindow = nil
  end
  
  countWindow.onEnter = moveFunc
  countWindow.onEscape = cancelFunc
  
  okButton.onClick = moveFunc
  cancelButton.onClick = cancelFunc
end

function UIItem:onDestroy()
  if self == g_ui.getDraggingWidget() and self.hoveredWho then
    self.hoveredWho:setBorderWidth(0)
  end

  if self.hoveredWho then
    self.hoveredWho = nil
  end
end

function UIItem:onHoverChange(hovered)
  UIWidget.onHoverChange(self, hovered)

  if self:isVirtual() or not self:isDraggable() then return end

  local draggingWidget = g_ui.getDraggingWidget()
  if draggingWidget and self ~= draggingWidget then
    local gotMap = draggingWidget:getClassName() == 'UIGameMap'
    local gotItem = draggingWidget:getClassName() == 'UIItem' and not draggingWidget:isVirtual()
    if hovered and (gotItem or gotMap) then
      self:setBorderWidth(1)
      draggingWidget.hoveredWho = self
    else
      self:setBorderWidth(0)
      draggingWidget.hoveredWho = nil
    end
  end
end

function UIItem:onMouseRelease(mousePosition, mouseButton)
  if self.cancelNextRelease then
    self.cancelNextRelease = false
    return true
  end

  if self:isVirtual() then return false end

  local item = self:getItem()
  if not item or not self:containsPoint(mousePosition) then return false end

  if modules.client_options.getOption('classicControl') and
     ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton) or
      (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
    g_game.look(item)
    self.cancelNextRelease = true
    return true
  elseif modules.game_interface.processMouseAction(mousePosition, mouseButton, nil, item, item, nil, nil) then
    return true
  end
  return false
end

function UIItem:canAcceptDrop(widget, mousePos)
  if self:isVirtual() or not self:isDraggable() then return false end
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
