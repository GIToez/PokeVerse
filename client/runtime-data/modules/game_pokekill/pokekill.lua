local pokekillWindow

function init()
  connect(g_game, { onGameEnd = onGameEnd })
  pokekillWindow = g_ui.displayUI('pokekill')
  ProtocolGame.registerExtendedOpcode(GameServerOpcodes.PokeKill, OnKillPokemon)
  pokekillWindow:hide()
end

function terminate()
  disconnect(g_game, { onGameStart = show })
  disconnect(g_game, { onGameEnd = hide })
  ProtocolGame.unregisterExtendedOpcode(GameServerOpcodes.PokeKill, OnKillPokemon)
  pokekillWindow:destroy()
end

function OnKillPokemon(protocol, code, buffer)
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

if json_data.WindowName == "modulo" then
  local WindowBack2 = pokekillWindow:getChildById("ModuloKill")
  WindowBack2:show()

  removeEvent(TimeClose)
  
  local PokeSprite = pokekillWindow:getChildById("ModuloKill"):getChildById("PokeImage")
  local PokeName = pokekillWindow:getChildById("ModuloKill"):getChildById("PokeName")
  local TaskName = pokekillWindow:getChildById("ModuloKill"):getChildById("TaskName")
  
  -- PokeSprite:setImageSource('/images/poke_sprite/'..json_data.PokeInfo.PokeSprite)
  PokeSprite:setOutfit({type=POKE_SPRITE[json_data.PokeName]})
  PokeName:setText(CORRECT_NAME[json_data.PokeName].." "..json_data.PokeInfo.KillCount)
  TaskName:setText("Cace o Pokémon")  

  show()
  TimeClose = scheduleEvent(hide, 15000)

elseif json_data.WindowName == "npc" then
  local WindowBack = pokekillWindow:getChildById("NpcKill")
  WindowBack:show()

  removeEvent(TimeClose2)
  
  local PokeSprite = pokekillWindow:getChildById("NpcKill"):getChildById("PokeImage")
  local PokeName = pokekillWindow:getChildById("NpcKill"):getChildById("PokeName")
  local TaskName = pokekillWindow:getChildById("NpcKill"):getChildById("TaskName")

  PokeSprite:setOutfit({type=POKE_SPRITE[json_data.PokeName]})
  PokeName:setText(CORRECT_NAME[json_data.PokeName].." "..json_data.PokeInfo.KillCount)
  TaskName:setText("Missão de caça")
  show()
  TimeClose2 = scheduleEvent(hide, 15000)
end

end
--- basic functions
function show()
  pokekillWindow:show()
  pokekillWindow:raise()
  pokekillWindow:focus()
  addEvent(function() g_effects.fadeIn(pokekillWindow, 250) end)
end
function hide()
	if pokekillWindow:isVisible() then
        local WindowBack2 = pokekillWindow:getChildById("ModuloKill")
        local WindowBack = pokekillWindow:getChildById("NpcKill")
		addEvent(function() g_effects.fadeOut(pokekillWindow, 250) end)
		scheduleEvent(function() pokekillWindow:hide() end, 250)
		scheduleEvent(function() pokekillWindow:hide() end, 250)
		scheduleEvent(function() WindowBack:hide() end, 250)
		scheduleEvent(function() WindowBack2:hide() end, 250)
        removeEvent(TimeClose)
        removeEvent(TimeClose2)
	end
end
-- End Public functions