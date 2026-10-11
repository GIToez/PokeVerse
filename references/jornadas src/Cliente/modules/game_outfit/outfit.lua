local OutfitWindow
local outfits
local maxperlist = 9
local currentpage = 1
local maxpages = 1
local selectedOutfit
local selectedWidget
local currentClotheButtonBox
local colorBoxes = {}

function init()
  connect(g_game, {
    onOpenOutfitWindow = create,
    onGameEnd = destroy
  })
end

function terminate()
  disconnect(g_game, {
    onOpenOutfitWindow = create,
    onGameEnd = destroy
  })
  destroy()
end

function create(creatureOutfit, outfitList, creatureMount, mountList)
  if OutfitWindow then OutfitWindow:destroy() OutfitWindow = nil end
  selectedOutfit = creatureOutfit:getOutfit()
  OutfitWindow = g_ui.displayUI('outfit')
  
  outfits = outfitList
  maxpages = math.ceil(#outfitList/maxperlist)
  
  for num, out in ipairs(outfitList) do
    if creatureOutfit:getOutfit().type == out[1] then
	  currentpage = math.ceil(num/maxperlist)
	  selectedOutfit = {type = out[1], head = selectedOutfit.head, body = selectedOutfit.body, legs = selectedOutfit.legs, feet = selectedOutfit.feet}
      OutfitWindow:getChildById('outfitPanel'):getChildById('outfit'):setOutfit(selectedOutfit)
      OutfitWindow:getChildById('outfitPanel'):getChildById('name'):setText(out[2])
	  break
	end
  end
  drawOutfitList()
  updatePageButtons()
  -- Drawing Outfit Panel
  
  currentClotheButtonBox = OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('head')
  OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('head').onCheckChange = onClotheCheckChange
  OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('primary').onCheckChange = onClotheCheckChange
  OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('secondary').onCheckChange = onClotheCheckChange
  OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('detail').onCheckChange = onClotheCheckChange

  -- populate color panel
  for j=0,6 do
    for i=0,18 do
      local colorBox = g_ui.createWidget('ColorBox', OutfitWindow:getChildById('outfitPanel'):getChildById('colorBoxPanel'))
      local outfitColor = getOufitColor(j*19 + i)
      colorBox:setImageColor(outfitColor)
      colorBox:setId('colorBox' .. j*19+i)
      colorBox.colorId = j*19 + i

      if j*19 + i == selectedOutfit.head then
        currentColorBox = colorBox
        colorBox:setChecked(true)
      end
      colorBox.onCheckChange = onColorCheckChange
      colorBoxes[#colorBoxes+1] = colorBox
    end
  end
end

function drawOutfitList()
  OutfitWindow:getChildById('pagePanel'):getChildById('page'):setText(tr('Página')..': '..currentpage..'/'..maxpages)
  OutfitWindow:getChildById('outfitList'):destroyChildren()
  for num, out in ipairs(outfits) do
    if math.ceil(num/maxperlist) == currentpage then
      local ot = {type = out[1], head = selectedOutfit.head, body = selectedOutfit.body, legs = selectedOutfit.legs, feet = selectedOutfit.feet}
	  local widget = g_ui.createWidget('OutfitToList', OutfitWindow:getChildById('outfitList'))
	  widget:setOutfit(ot)
	  widget.ot = ot
	  widget:setTooltip(out[2])
	  if selectedOutfit.type == out[1] then
	    selectedWidget = widget
		selectedWidget:setBorderColor('blue')
	  end
	  widget.onClick = function()
	    selectedOutfit = ot
		if selectedWidget then selectedWidget:setBorderColor('black') end
		selectedWidget = widget
		selectedWidget:setBorderColor('blue')
		OutfitWindow:getChildById('outfitPanel'):getChildById('outfit'):setOutfit(ot)
        OutfitWindow:getChildById('outfitPanel'):getChildById('name'):setText(out[2])
	  end
	end
  end
end

function randomize()
  local outfitTemplate = {
    OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('head'),
    OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('primary'),
    OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('secondary'),
    OutfitWindow:getChildById('outfitPanel'):getChildById('template'):getChildById('detail')
  }

  for i = 1, #outfitTemplate do
    outfitTemplate[i]:setChecked(true)
    colorBoxes[math.random(1, #colorBoxes)]:setChecked(true)
    outfitTemplate[i]:setChecked(false)
  end
  outfitTemplate[1]:setChecked(true)
end

function onClotheCheckChange(clotheButtonBox)
  if clotheButtonBox == currentClotheButtonBox then
    clotheButtonBox.onCheckChange = nil
    clotheButtonBox:setChecked(true)
    clotheButtonBox.onCheckChange = onClotheCheckChange
  else
    currentClotheButtonBox.onCheckChange = nil
    currentClotheButtonBox:setChecked(false)
    currentClotheButtonBox.onCheckChange = onClotheCheckChange

    currentClotheButtonBox = clotheButtonBox

    local colorId = 0
    if currentClotheButtonBox:getId() == 'head' then
      colorId = selectedOutfit.head
    elseif currentClotheButtonBox:getId() == 'primary' then
      colorId = selectedOutfit.body
    elseif currentClotheButtonBox:getId() == 'secondary' then
      colorId = selectedOutfit.legs
    elseif currentClotheButtonBox:getId() == 'detail' then
      colorId = selectedOutfit.feet
    end
    OutfitWindow:getChildById('outfitPanel'):getChildById('colorBoxPanel'):recursiveGetChildById('colorBox' .. colorId):setChecked(true)
  end
end

function onColorCheckChange(colorBox)
  if colorBox == currentColorBox then
    colorBox.onCheckChange = nil
    colorBox:setChecked(true)
    colorBox.onCheckChange = onColorCheckChange
  else
    currentColorBox.onCheckChange = nil
    currentColorBox:setChecked(false)
    currentColorBox.onCheckChange = onColorCheckChange

    currentColorBox = colorBox

    if currentClotheButtonBox:getId() == 'head' then
      selectedOutfit.head = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == 'primary' then
      selectedOutfit.body = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == 'secondary' then
      selectedOutfit.legs = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == 'detail' then
      selectedOutfit.feet = currentColorBox.colorId
    end
	
    -- currentColorBox:setBorderColor(getOufitColor(currentColorBox.colorId))

    OutfitWindow:getChildById('outfitPanel'):getChildById('outfit'):setOutfit(selectedOutfit)
	for i, child in ipairs(OutfitWindow:getChildById('outfitList'):getChildren()) do
	  local out = child.ot
	  out.head = selectedOutfit.head
	  out.body = selectedOutfit.body
	  out.legs = selectedOutfit.legs
	  out.feet = selectedOutfit.feet
	  child:setOutfit(out)
	end
  end
end

function destroy()
  if OutfitWindow then
    OutfitWindow:destroy()
    OutfitWindow = nil
	selectedOutfit = nil
    currentColorBox = nil
    currentClotheButtonBox = nil
    colorBoxes = {}
  end
end

function accept()
  if not selectedOutfit then return end
  g_game.changeOutfit(selectedOutfit)
  destroy()
end

function firstPage()
  currentpage = 1
  updatePageButtons()
  drawOutfitList()
end

function lastPage()
  currentpage = maxpages
  updatePageButtons()
  drawOutfitList()
end

function prevPage()
  currentpage = math.max(1, currentpage - 1)
  updatePageButtons()
  drawOutfitList()
end

function nextPage()
  currentpage = math.min(maxpages, currentpage + 1)
  updatePageButtons()
  drawOutfitList()
end

function updatePageButtons()
  if maxpages == 1 then
    OutfitWindow:getChildById('pagePanel'):getChildById('firstPage'):disable()
    OutfitWindow:getChildById('pagePanel'):getChildById('prevPage'):disable()
    OutfitWindow:getChildById('pagePanel'):getChildById('nextPage'):disable()
    OutfitWindow:getChildById('pagePanel'):getChildById('lastPage'):disable()
  else
    if currentpage == maxpages then
      OutfitWindow:getChildById('pagePanel'):getChildById('firstPage'):enable()
      OutfitWindow:getChildById('pagePanel'):getChildById('prevPage'):enable()
      OutfitWindow:getChildById('pagePanel'):getChildById('nextPage'):disable()
      OutfitWindow:getChildById('pagePanel'):getChildById('lastPage'):disable()
	elseif currentpage == 1 then
      OutfitWindow:getChildById('pagePanel'):getChildById('firstPage'):disable()
      OutfitWindow:getChildById('pagePanel'):getChildById('prevPage'):disable()
      OutfitWindow:getChildById('pagePanel'):getChildById('nextPage'):enable()
      OutfitWindow:getChildById('pagePanel'):getChildById('lastPage'):enable()
	else
      OutfitWindow:getChildById('pagePanel'):getChildById('firstPage'):enable()
      OutfitWindow:getChildById('pagePanel'):getChildById('prevPage'):enable()
      OutfitWindow:getChildById('pagePanel'):getChildById('nextPage'):enable()
      OutfitWindow:getChildById('pagePanel'):getChildById('lastPage'):enable()
	
    end
  end
  
end