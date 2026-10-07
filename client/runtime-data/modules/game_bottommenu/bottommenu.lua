local bottommenu

function init()
  connect(g_game, { onGameEnd = onGameEnd })
  bottommenu = g_ui.displayUI('bottommenu')
  bottommenu:hide()
end

function terminate()
  disconnect(g_game, { onGameStart = show })
  disconnect(g_game, { onGameEnd = hide })
  bottommenu:destroy()
end

--- buttons fuctions
function closeallbutton()
scheduleEvent(function() bottommenu:getChildById("topbackground"):setVisible(false)end, 100)
scheduleEvent(function() bottommenu:getChildById("bottombackground"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("pokeivs_button"):setVisible(false)end, 100)
scheduleEvent(function() bottommenu:getChildById("combatcontrols_button"):setVisible(false)end, 100)
scheduleEvent(function() bottommenu:getChildById("pokeaddons_button"):setVisible(false)end, 100)
scheduleEvent(function() bottommenu:getChildById("pokebar_button"):setVisible(false)end, 100)
scheduleEvent(function() bottommenu:getChildById("healthinfo_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("minimap_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("party_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("battle_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("viplist_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("inventory_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("skills_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("questlog_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("progress_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("tasks_button"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("brokes_info"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("duel_player"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("setaTask"):setVisible(false)end, 100)

scheduleEvent(function() bottommenu:getChildById("mainbutton").onClick = showbuttons end, 300)

hideTask()
end

function showbuttons()
scheduleEvent(function() bottommenu:getChildById("topbackground"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("bottombackground"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("setaTask"):setVisible(true)end, 100)

scheduleEvent(function() bottommenu:getChildById("pokeivs_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("pokeivs_button"):setTooltip(tr("Pokeinfos: not active")) end, 100)

scheduleEvent(function() bottommenu:getChildById("combatcontrols_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("combatcontrols_button"):setTooltip(tr("Coambat controls")) end, 100)

scheduleEvent(function() bottommenu:getChildById("pokeaddons_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("pokeaddons_button"):setTooltip(tr("Poke Addons")) end, 100)

scheduleEvent(function() bottommenu:getChildById("pokebar_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("pokebar_button"):setTooltip(tr("Pokebar")) end, 100)

scheduleEvent(function() bottommenu:getChildById("healthinfo_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("healthinfo_button"):setTooltip(tr("Health info")) end, 100)

scheduleEvent(function() bottommenu:getChildById("minimap_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("minimap_button"):setTooltip(tr("Map")) end, 100)

scheduleEvent(function() bottommenu:getChildById("party_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("party_button"):setTooltip(tr("Hunting party: not active")) end, 100)

scheduleEvent(function() bottommenu:getChildById("battle_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("battle_button"):setTooltip(tr("Battle")) end, 100)

scheduleEvent(function() bottommenu:getChildById("viplist_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("viplist_button"):setTooltip(tr("Friend's list")) end, 100)

scheduleEvent(function() bottommenu:getChildById("inventory_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("inventory_button"):setTooltip(tr("Inventory")) end, 100)

scheduleEvent(function() bottommenu:getChildById("skills_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("skills_button"):setTooltip(tr("Character skills")) end, 100)

scheduleEvent(function() bottommenu:getChildById("questlog_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("questlog_button"):setTooltip(tr("Quest Log")) end, 100)

scheduleEvent(function() bottommenu:getChildById("progress_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("progress_button"):setTooltip(tr("journey progress: not active")) end, 100)

scheduleEvent(function() bottommenu:getChildById("tasks_button"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("tasks_button"):setTooltip(tr("Poke mission")) end, 100)
scheduleEvent(function() bottommenu:getChildById("tasks_button").onClick = showTask end, 300)

scheduleEvent(function() bottommenu:getChildById("brokes_info"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("brokes_info"):setTooltip(tr("Capture information: not active")) end, 100)

scheduleEvent(function() bottommenu:getChildById("duel_player"):setVisible(true)end, 100)
scheduleEvent(function() bottommenu:getChildById("duel_player"):setTooltip(tr("Duel: not active")) end, 100)

scheduleEvent(function() bottommenu:getChildById("mainbutton").onClick = closeallbutton end, 300)
end

function showTask()
g_effects.fadeIn(bottommenu:getChildById("taskbackground"), 250)
g_effects.fadeIn(bottommenu:getChildById("task_kill"), 250)
g_effects.fadeIn(bottommenu:getChildById("task_catch"), 250)

scheduleEvent(function() bottommenu:getChildById("taskbackground"):show() end, 300)

scheduleEvent(function() bottommenu:getChildById("task_catch"):show() end, 300)
scheduleEvent(function() bottommenu:getChildById("task_catch"):setTooltip(tr("Missão de Captura")) end, 300)
scheduleEvent(function() bottommenu:getChildById("task_kill"):show() end, 300)
scheduleEvent(function() bottommenu:getChildById("task_kill"):setTooltip(tr("Missão de caça")) end, 300)
scheduleEvent(function() bottommenu:getChildById("tasks_button").onClick = hideTask end, 300)

scheduleEvent(function() bottommenu:getChildById("setaTask"):setImageSource('images/down') end, 300)
end
function hideTask()
g_effects.fadeOut(bottommenu:getChildById("taskbackground"), 250)
g_effects.fadeOut(bottommenu:getChildById("task_kill"), 250)
g_effects.fadeOut(bottommenu:getChildById("task_catch"), 250)
  
scheduleEvent(function() bottommenu:getChildById("taskbackground"):hide()end, 300)
scheduleEvent(function() bottommenu:getChildById("task_kill"):hide()end, 300)
scheduleEvent(function() bottommenu:getChildById("task_catch"):hide()end, 300)

scheduleEvent(function() bottommenu:getChildById("tasks_button").onClick = showTask end, 300)
scheduleEvent(function() bottommenu:getChildById("setaTask"):setImageSource('images/up') end, 250)
end

function showPokebar()
modules.game_pokebar.pokemonBar:show()
end
function hidePokebar()
modules.game_pokebar.pokemonBar:hide()
end

--- basic functions
function show()
  bottommenu:getChildById("mainbutton").onClick = showbuttons
  bottommenu:show()
  bottommenu:raise()
  bottommenu:focus()
  addEvent(function() g_effects.fadeIn(bottommenu, 250) end)
end
function hide()
	if bottommenu:isVisible() then
	addEvent(function() g_effects.fadeOut(bottommenu, 250) end)
	bottommenu:hide()
end
end
-- End Public functions