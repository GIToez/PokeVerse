new_password = nil
new_repeat_password = nil
new_securytext = nil

secury_text = nil
textos = {"Pokémon favorito", "Nome da mãe", "Nome do cachorro", "Apelido de infãcia", "Comida favorita", "Data de nascimento"}
gettext = {}

function init()
  connect(g_game, { onGameEnd = onGameEnd })
  
  depotPassWindow = g_ui.displayUI('ui/pass_create')
  new_securytext = depotPassWindow:getChildById('securytext')

  for _, securytext in ipairs(textos) do
        new_securytext:addOption(securytext)
    gettext[securytext] = {id = _}
  end

  depotWindow = g_ui.displayUI('ui/depotlock')
  depotWindow:hide()
  depotPassWindow:hide()
  termsWindow = g_ui.displayUI('ui/terms')
  termsWindow:hide()
  ChangePassWindow = g_ui.displayUI('ui/pass_change')
  ChangePassWindow:hide()
  removePassWindow = g_ui.displayUI('ui/pass_remove')
  removePassWindow:hide()
  alertWindow = g_ui.displayUI('ui/alertbox')
  alertWindow:hide()
  configWindow = g_ui.displayUI('ui/config')
  configWindow:hide()

  ProtocolGame.registerExtendedOpcode(GameServerOpcodes.DepotLock, doReceiveOpcode)
end

function terminate()
  disconnect(g_game, { onGameStart = show })
  disconnect(g_game, { onGameEnd = hide })
  depotWindow:destroy()
  depotPassWindow:destroy()
  termsWindow:destroy()
  ChangePassWindow:destroy()
  removePassWindow:destroy()
  alertWindow:destroy()
  configWindow:destroy()

  ProtocolGame.unregisterExtendedOpcode(GameServerOpcodes.DepotLock, doReceiveOpcode)
end
--- basic functions
function showDepotLocked()
  depotWindow:raise()
  depotWindow:focus()
  depotWindow:show()
  addEvent(function() g_effects.fadeIn(depotWindow, 250) end)
end
function hideDepotLocked()
	if depotWindow:isVisible() then
		addEvent(function() g_effects.fadeOut(depotWindow, 250) end)
		scheduleEvent(function() depotWindow:hide() end, 250)
	end
end
function showDepotPass()
  depotPassWindow:raise()
  depotPassWindow:focus()
  depotPassWindow:show()
  addEvent(function() g_effects.fadeIn(depotPassWindow, 250) end)
end
function hideDepotPass()
  if depotPassWindow:isVisible() then
    addEvent(function() g_effects.fadeOut(depotPassWindow, 250) end)
    scheduleEvent(function() depotPassWindow:hide() end, 250)
  end
end
function showTerms()
  termsWindow:raise()
  termsWindow:focus()
  termsWindow:show()
  addEvent(function() g_effects.fadeIn(termsWindow, 250) end)
end
function hideTerms()
  if termsWindow:isVisible() then
    addEvent(function() g_effects.fadeOut(termsWindow, 250) end)
    scheduleEvent(function() termsWindow:hide() end, 250)
  end
end
function showChangePass()
  ChangePassWindow:raise()
  ChangePassWindow:focus()
  ChangePassWindow:show()
  addEvent(function() g_effects.fadeIn(ChangePassWindow, 250) end)
end
function hideChangePass()
  if ChangePassWindow:isVisible() then
    addEvent(function() g_effects.fadeOut(ChangePassWindow, 250) end)
    scheduleEvent(function() ChangePassWindow:hide() end, 250)
  end
end
function showRemovePass()
  removePassWindow:raise()
  removePassWindow:focus()
  removePassWindow:show()
  addEvent(function() g_effects.fadeIn(ChangePassWindow, 250) end)
end
function hideRemovePass()
  if removePassWindow:isVisible() then
    removePassWindow:hide()
  end
end
function showAlertWindow()
  alertWindow:raise()
  alertWindow:focus()
  alertWindow:show()
  addEvent(function() g_effects.fadeIn(alertWindow, 250) end)
end
function hideAlertWindow()
  if alertWindow:isVisible() then
    alertWindow:hide()
    --addEvent(function() g_effects.fadeOut(alertWindow, 250) end)
  end
end
function showConfig()
  configWindow:raise()
  configWindow:focus()
  configWindow:show()
  addEvent(function() g_effects.fadeIn(configWindow, 250) end)
end
function hideConfig()
  if configWindow:isVisible() then
    addEvent(function() g_effects.fadeOut(configWindow, 250) end)
    scheduleEvent(function() configWindow:hide() end, 250)
  end
end
-- End Public functions