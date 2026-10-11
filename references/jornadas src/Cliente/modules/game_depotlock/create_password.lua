function SetNewPassword()
new_password = depotPassWindow:getChildById('newpass')
new_repeat_password = depotPassWindow:getChildById('repeatpass')
secury_text = depotPassWindow:getChildById('securytext')

  if(string.len(new_password:getText()) == 0) then
      return PrenchPass()
  elseif(string.len(new_repeat_password:getText()) == 0) then
      return ConfirmPass()
  end

  if(string.len(new_password:getText()) < 5) then
      return MinCharacteri()
  elseif(string.len(new_password:getText()) > 12) then
      return MaxCharacteri()
  end

  if(
  	not string.find(new_password:getText(), '1') and
  	not string.find(new_password:getText(), '2') and
  	not string.find(new_password:getText(), '3') and
  	not string.find(new_password:getText(), '4') and
  	not string.find(new_password:getText(), '5') and
  	not string.find(new_password:getText(), '6') and
  	not string.find(new_password:getText(), '7') and
  	not string.find(new_password:getText(), '8') and
  	not string.find(new_password:getText(), '9') and
  	not string.find(new_password:getText(), '0')
  ) then
	    return NumberLeter()
	end
  if(
  	not string.find(new_password:getText(), 'a') and 
  	not string.find(new_password:getText(), 'b') and
  	not string.find(new_password:getText(), 'c') and
  	not string.find(new_password:getText(), 'd') and
  	not string.find(new_password:getText(), 'e') and
  	not string.find(new_password:getText(), 'f') and
  	not string.find(new_password:getText(), 'g') and
  	not string.find(new_password:getText(), 'h') and
  	not string.find(new_password:getText(), 'i') and
  	not string.find(new_password:getText(), 'j') and
  	not string.find(new_password:getText(), 'k') and
  	not string.find(new_password:getText(), 'l') and
  	not string.find(new_password:getText(), 'm') and
  	not string.find(new_password:getText(), 'n') and
  	not string.find(new_password:getText(), 'o') and
  	not string.find(new_password:getText(), 'p') and
  	not string.find(new_password:getText(), 'q') and
  	not string.find(new_password:getText(), 'r') and
  	not string.find(new_password:getText(), 's') and
  	not string.find(new_password:getText(), 't') and
  	not string.find(new_password:getText(), 'u') and
  	not string.find(new_password:getText(), 'v') and
  	not string.find(new_password:getText(), 'w') and
  	not string.find(new_password:getText(), 'x') and
  	not string.find(new_password:getText(), 'y') and
  	not string.find(new_password:getText(), 'z')
  ) then
	    return NumberLeter()
	end

	if(new_password:getText() ~= new_repeat_password:getText()) then
		return BlockPass()
	end

	g_game.talk("/depotpass password, "..new_password:getText())
hideConfig()
end

function doChangeNewPass()
change_new_password = ChangePassWindow:getChildById('atualpass')

change_password = ChangePassWindow:getChildById('newpass')
change_repeat_password = ChangePassWindow:getChildById('confirmnewpass')

  if(string.len(change_password:getText()) == 0) then
      return PrenchPass()
  elseif(string.len(change_password:getText()) == 0) then
      return ConfirmPass()
  end

  if(string.len(change_password:getText()) < 5) then
      return MinCharacteri()
  elseif(string.len(change_password:getText()) > 12) then
      return MaxCharacteri()
  end

  if(
  	not string.find(change_password:getText(), '1') and
  	not string.find(change_password:getText(), '2') and
  	not string.find(change_password:getText(), '3') and
  	not string.find(change_password:getText(), '4') and
  	not string.find(change_password:getText(), '5') and
  	not string.find(change_password:getText(), '6') and
  	not string.find(change_password:getText(), '7') and
  	not string.find(change_password:getText(), '8') and
  	not string.find(change_password:getText(), '9') and
  	not string.find(change_password:getText(), '0')
  ) then
	    return NumberLeter()
	end
  if(
  	not string.find(change_password:getText(), 'a') and 
  	not string.find(change_password:getText(), 'b') and
  	not string.find(change_password:getText(), 'c') and
  	not string.find(change_password:getText(), 'd') and
  	not string.find(change_password:getText(), 'e') and
  	not string.find(change_password:getText(), 'f') and
  	not string.find(change_password:getText(), 'g') and
  	not string.find(change_password:getText(), 'h') and
  	not string.find(change_password:getText(), 'i') and
  	not string.find(change_password:getText(), 'j') and
  	not string.find(change_password:getText(), 'k') and
  	not string.find(change_password:getText(), 'l') and
  	not string.find(change_password:getText(), 'm') and
  	not string.find(change_password:getText(), 'n') and
  	not string.find(change_password:getText(), 'o') and
  	not string.find(change_password:getText(), 'p') and
  	not string.find(change_password:getText(), 'q') and
  	not string.find(change_password:getText(), 'r') and
  	not string.find(change_password:getText(), 's') and
  	not string.find(change_password:getText(), 't') and
  	not string.find(change_password:getText(), 'u') and
  	not string.find(change_password:getText(), 'v') and
  	not string.find(change_password:getText(), 'w') and
  	not string.find(change_password:getText(), 'x') and
  	not string.find(change_password:getText(), 'y') and
  	not string.find(change_password:getText(), 'z')
  ) then
	    return NumberLeter()
	end

	if(change_new_password:getText() == change_password:getText()) then
		return BlockEqual()
	end

	if(change_password:getText() ~= change_repeat_password:getText()) then
		return BlockPass()
	end

	g_game.talk("/depotpass passchange, "..change_new_password:getText()..", "..change_password:getText())
hideConfig()
end

function doReleasePass()
pass_release = depotWindow:getChildById('SenhaAtual')

  if(string.len(pass_release:getText()) == 0) then
      return PrenchPass()
  end

	g_game.talk("/dprelease "..pass_release:getText())
hideDepotLocked()
hideConfig()
end

function doRemovePass()
pass_remove = removePassWindow:getChildById('SenhaAtual')

  if(string.len(pass_remove:getText()) == 0) then
      return PrenchPass()
  end

	g_game.talk("/depotpass remove, "..pass_remove:getText())
hideRemovePass()
hideConfig()
end