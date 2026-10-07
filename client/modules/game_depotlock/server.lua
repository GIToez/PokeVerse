function doReceiveOpcode(protocol, code, buffer)
  local json_status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )

  if not json_status then
    g_logger.error("[My Module] JSON error: " .. json_data)
    return false
  end

  if json_data.argument == "NoPass" then
    configWindow:getChildById("newpass"):setImageSource("ui/images/config/nova_senha")
    configWindow:getChildById("changepass"):setImageSource("ui/images/config/trocar_senha_off")
    configWindow:getChildById("removepass"):setImageSource("ui/images/config/remover_senha_off")
    configWindow:getChildById("lock"):setImageSource("ui/images/config/trancar_off")
    
    configWindow:getChildById("newpass").onClick = function() showDepotPass() end
    configWindow:getChildById("changepass").onClick = function() CreateNewPass() end
    configWindow:getChildById("removepass").onClick = function() CreateNewPass() end
    configWindow:getChildById("lock").onClick = function() CreateNewPass() end
  showConfig()
  elseif json_data.argument == "NoRelease" then
      showDepotLocked()
  elseif json_data.argument == "Release" then
    configWindow:getChildById("newpass"):setImageSource("ui/images/config/nova_senha_off")
    configWindow:getChildById("changepass"):setImageSource("ui/images/config/trocar_senha")
    configWindow:getChildById("removepass"):setImageSource("ui/images/config/remover_senha")
    configWindow:getChildById("lock"):setImageSource("ui/images/config/trancar")
    
    configWindow:getChildById("newpass").onClick = function() BlockToPass() end
    configWindow:getChildById("changepass").onClick = function() showChangePass() end
    configWindow:getChildById("removepass").onClick = function() showRemovePass() end
    configWindow:getChildById("lock").onClick = function() g_game.talk("/depotpass lock ") hideConfig() end
  showConfig()
  end

end