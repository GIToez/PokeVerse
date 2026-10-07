createWindow = nil

addPokemon = nil
addSexo = nil
addTown = nil
addWorld = nil
Login = nil
Email = nil
PasswordAgain = nil
Password = nil
CharacterName = nil

Pokemons = {"Charmander", "Bulbasaur", "Squirtle"}
Sexos = {"Mulher", "Homem"}
Towns = {"Saffron", "Cerulean", "Lavender", "Celadon", "Vermilion", "Fuchsia", "Pewter", "Viridian", "Pallet", "Cinnabar", "Snow"}
Worlds = {"Kanto"}
local hosting = {"127.0.0.1", 7564, 7172, 7173, 854}
local enterGame
getPokes = {}
getSexos = {}
getTowns = {}
getWorlds = {}


createCharWindow = nil
addPokemonChar = nil
addSexoChar = nil
addTownChar = nil
addWorldChar = nil
CharacterNameChar = nil

function init()
    createWindow = g_ui.displayUI('create')
	
	addPokemon = createWindow:getChildById('pokemon')
    addSexo = createWindow:getChildById('sexo')
	addTown = createWindow:getChildById('town')
	addWorld = createWindow:getChildById('world')
	Login = createWindow:getChildById('accountNameTextEdit')
	Email = createWindow:getChildById('accountEmailTextEdit')
	Password = createWindow:getChildById('accountPasswordTextEdit')
	PasswordAgain = createWindow:getChildById('accountRepeatPasswordTextEdit')
	CharacterName = createWindow:getChildById('accountCharacterNameTextEdit')
	
	
	createWindow:setVisible(false)
	
	for _, poke in ipairs(Pokemons) do
        addPokemon:addOption(poke)
		getPokes[poke] = {id = _}
    end
	for _, sexo in ipairs(Sexos) do
        addSexo:addOption(sexo) 
		getSexos[sexo] = {id = _}
    end
	for _, town in ipairs(Towns) do
        addTown:addOption(town) 
		getTowns[town] = {id = _}
    end
	for _, world in ipairs(Worlds) do
        addWorld:addOption(world) 
		getWorlds[world] = {id = _}
    end
	
	createCharWindow = g_ui.displayUI('createChar')
	createCharWindow:setVisible(false)
	addPokemonChar = createCharWindow:getChildById('pokemon')
	addSexoChar = createCharWindow:getChildById('sexo')
	addTownChar = createCharWindow:getChildById('town')
	addWorldChar = createCharWindow:getChildById('world')
	CharacterNameChar = createCharWindow:getChildById('accountCharacterNameTextEdit')
	for _, poke in ipairs(Pokemons) do
        addPokemonChar:addOption(poke)
		getPokes[poke] = {id = _}
    end
	for _, sexo in ipairs(Sexos) do
        addSexoChar:addOption(sexo) 
		getSexos[sexo] = {id = _}
    end
	for _, town in ipairs(Towns) do
        addTownChar:addOption(town) 
		getTowns[town] = {id = _}
    end
	for _, world in ipairs(Worlds) do
        addWorldChar:addOption(world) 
		getWorlds[world] = {id = _}
    end
	
	connect(addPokemonChar, { onOptionChange = onPokemonChar })
    connect(addSexoChar, { onOptionChange = onSexoChar })
	connect(addTownChar, { onOptionChange = onTownChar })
	connect(addWorldChar, { onOptionChange = onWorldChar })
  
	
	
	enterGame = rootWidget:getChildById("enterGame")
	connect(addPokemon, { onOptionChange = onPokemon })
	connect(addSexo, { onOptionChange = onSexo })
	connect(addTown, { onOptionChange = onTown })
	connect(addWorld, { onOptionChange = onWorld })
end

function terminate()
    disconnect(g_game, { onGameEnd = hide })
    createWindow:destroy()
end

function onErrorChar(protocol, message, errorCode)
	local errorBox = displayErrorBox(createCharWindow:getText(), message)

	local visible = true
	if(not errorCode) then
		visible = false
	end

	connect(errorBox, { onOk = function()
							if(visible) then
								createCharWindow:setVisible(true)
								Login:focus()
							else
								CharacterList:show()
							end
						end })
end

function onRecvChar(protocol, msg)
	
	local success = msg:getU8();
	local text = msg:getString();
		
	protocol:disconnect()
	onErrorChar(protocol, text, success == 0x00)
end

function doRegisterChar()
	if not G.account then
	    createCharWindow:setVisible(false)
		onErrorChar(protocol, "O nome da conta é obrigatório.", true)
	    return
	end
	if(string.len(CharacterNameChar:getText()) < 4) then
	    createCharWindow:setVisible(false)
		onErrorChar(protocol, "O nome do personagem deve ter pelo menos 4 caracteres.", true)
	    return
	end
	
	
	-- EnterGame.setUniqueServer(hosting[1], 7564, 854, 371, 285)
	local clientVersion = 854
	
 	g_settings.set('host', hosting[1])
    g_settings.set('port', hosting[2])
    g_settings.set('client-version', clientVersion)

    protocolLogin = ProtocolLogin.create()
    protocolLogin.onRecv = onRecvChar
    protocolLogin.onLoginError = onErrorChar
  
    g_game.chooseRsa(hosting[1])
    g_game.setClientVersion(clientVersion)

    protocolLogin:CreateCharacter(hosting[1], hosting[2], G.account, CharacterNameChar:getText(), 1, getSexos[addSexoChar:getCurrentOption().text].id - 1, 1, getWorlds[addWorldChar:getCurrentOption().text].id - 1)
	createCharWindow:setVisible(false)
end

function showChar()
    CharacterList:hide()
    enterGame:hide()
    createCharWindow:setVisible(true)
	modules.client_background.CloseInfos()
	modules.client_background.ShowBlackWindow()
end

function hideChar()
    createCharWindow:setVisible(false)
    CharacterList:show()
	modules.client_background.HideBlackWindow()
end

function show()
    enterGame:hide()
    createWindow:setVisible(true)
	modules.client_background.CloseInfos()
	modules.client_background.ShowBlackWindow()
end

function hide()
    enterGame:show()
    createWindow:setVisible(false)
	modules.client_background.OpenInfos()
	modules.client_background.HideBlackWindow()
end

function onError(protocol, message, errorCode)
	local errorBox = displayErrorBox(createWindow:getText(), message)

	local visible = true
	if(not errorCode) then
		visible = false
	end

	connect(errorBox, { onOk = function()
							if(visible) then
								createWindow:setVisible(true)
								Login:focus()
							else
								EnterGame.show() 
							end
						end })
end

function onRecv(protocol, msg)
	
	local success = msg:getU8();
	local text = msg:getString();
		
	protocol:disconnect()
	onError(protocol, text, success == 0x00)
end

function regras()
    g_platform.openUrl("pokezring.net/regras.php")
  return true
end

function doRegisterAccount()
    if not Login:getText() then
	    createWindow:setVisible(false)
		onError(protocol, "O campo Nome da conta é obrigatório.", true)
	    return
	end
    if(not string.find(Email:getText(), '@')) then
	    createWindow:setVisible(false)
		onError(protocol, "O campo Email deve conter um endereço de email válido.", true)
	    return
	end
    if(string.len(Password:getText()) < 4 or string.len(Login:getText()) < 4) then
	    createWindow:setVisible(false)
		onError(protocol, "O campo Nome da conta e Senha deve ter pelo menos 4 caracteres.", true)
	    return
	end
	if(PasswordAgain:getText() ~= Password:getText()) then
		createWindow:setVisible(false)
		onError(protocol, "O campo Senha não corresponde ao campo de repetição.", true)
		return
	end
	if(string.len(CharacterName:getText()) < 4) then
	    createWindow:setVisible(false)
		onError(protocol, "O campo Nome do caractere deve ter pelo menos 4 caracteres.", true)
	    return
	end
	
	
-- EnterGame.setUniqueServer(hosting[1], 7564, 854, 270, 210)
  local clientVersion = 854
  g_settings.set('host', hosting[1])
  g_settings.set('port', hosting[2])
  g_settings.set('client-version', clientVersion)

  protocolLogin = ProtocolLogin.create()
  protocolLogin.onRecv = onRecv
  protocolLogin.onLoginError = onError
  
  g_game.chooseRsa(hosting[1])
  g_game.setClientVersion(clientVersion)

  protocolLogin:CreateAccount(hosting[1], hosting[2], Login:getText(), Password:getText(), CharacterName:getText(), getPokes[addPokemon:getCurrentOption().text].id, getSexos[addSexo:getCurrentOption().text].id - 1, getTowns[addTown:getCurrentOption().text].id, getWorlds[addWorldChar:getCurrentOption().text].id)
  createWindow:setVisible(false)
end