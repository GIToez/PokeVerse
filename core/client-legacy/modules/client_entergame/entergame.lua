EnterGame = { }

-- private variables
local loadBox
local enterGame
local motdWindow
local motdButton
local enterGameButton
local clientBox
local protocolLogin
local protocolAccount
local createAccountWindow
local motdEnabled = true

local SERVER_HOST = '127.0.0.1'
local SERVER_PORT = 7564
local PROTOCOL_VERSION = 854

-- private functions
local function onError(protocol, message, errorCode)
  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end

  if not errorCode then
    EnterGame.clearAccountFields()
  end

  local errorBox = displayErrorBox(tr('Login Error'), message)
  connect(errorBox, { onOk = EnterGame.show })
end

local function onMotd(protocol, motd)
  G.motdNumber = tonumber(motd:sub(0, motd:find("\n")))
  G.motdMessage = motd:sub(motd:find("\n") + 1, #motd)
  if motdEnabled then
    motdButton:show()
  end
end

local function onCharacterList(protocol, characters, account, otui)
  if enterGame:getChildById('rememberAccountBox'):isChecked() then
    g_settings.set('account', g_crypt.encrypt(G.account))
    EnterGame.clearAccountFields(true)
  else
    EnterGame.clearAccountFields()
  end

  loadBox:destroy()
  loadBox = nil

  CharacterList.create(characters, account, otui)
  CharacterList.show()

  if motdEnabled then
    local lastMotdNumber = g_settings.getNumber("motd")
    if G.motdNumber and G.motdNumber ~= lastMotdNumber then
      g_settings.set("motd", motdNumber)
      motdWindow = displayInfoBox(tr('Message of the day'), G.motdMessage)
      connect(motdWindow, { onOk = function() CharacterList.show() motdWindow = nil end })
      CharacterList.hide()
    end
  end
end

local function onUpdateNeeded(protocol, signature)
  loadBox:destroy()
  loadBox = nil

  if EnterGame.updateFunc then
    local continueFunc = EnterGame.show
    local cancelFunc = EnterGame.show
    EnterGame.updateFunc(signature, continueFunc, cancelFunc)
  else
    local errorBox = displayErrorBox(tr('Update needed'), tr('Your client needs update, try redownloading it.'))
    connect(errorBox, { onOk = EnterGame.show })
  end
end

-- public functions
function EnterGame.init()
  enterGame = g_ui.displayUI('entergame')
  enterGameButton = modules.client_topmenu.addLeftButton('enterGameButton', tr('Login') .. ' (Ctrl + G)', '/images/topbuttons/login', EnterGame.openWindow)
  motdButton = modules.client_topmenu.addLeftButton('motdButton', tr('Message of the day'), '/images/topbuttons/motd', EnterGame.displayMotd)
  motdButton:hide()
  g_keyboard.bindKeyDown('Ctrl+G', EnterGame.openWindow)

  if motdEnabled and G.motdNumber then
    motdButton:show()
  end

  local account = g_settings.get('account')
--  local password = g_settings.get('password')
  local host = g_settings.get('host')
  local port = g_settings.get('port')
  local protocolVersion = g_settings.getInteger('protocol-version')

  if port == nil or port == 0 then port = 7564 end

  EnterGame.setAccountName(account)
--  EnterGame.setPassword(password)

  enterGame:hide()

  if g_app.isRunning() and not g_game.isOnline() then
    enterGame:show()
  end
end

function EnterGame.firstShow()
  EnterGame.show()

  local account = g_crypt.decrypt(g_settings.get('account'))
  local password = g_crypt.decrypt(g_settings.get('password'))
  local host = g_settings.get('host')
  if #host > 0 and #password > 0 and #account > 0 then
    addEvent(function()
      EnterGame.doLogin()
    end)
  end
end

function EnterGame.terminate()
  g_keyboard.unbindKeyDown('Ctrl+G')
  enterGame:destroy()
  enterGame = nil
  enterGameButton:destroy()
  enterGameButton = nil
  clientBox = nil
  if motdWindow then
    motdWindow:destroy()
    motdWindow = nil
  end
  if motdButton then
    motdButton:destroy()
    motdButton = nil
  end
  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end
  if protocolLogin then
    protocolLogin:cancelLogin()
    protocolLogin = nil
  end
  if protocolAccount then
    protocolAccount:cancel()
    protocolAccount = nil
  end
  if createAccountWindow then
    createAccountWindow:destroy()
    createAccountWindow = nil
  end
  EnterGame = nil
end

function EnterGame.show()
  if loadBox then return end
  enterGame:show()
  enterGame:raise()
  enterGame:focus()
end

function EnterGame.hide()
  enterGame:hide()
end

function EnterGame.openWindow()
  if g_game.isOnline() then
    CharacterList.show()
  elseif not g_game.isLogging() and not CharacterList.isVisible() then
    EnterGame.show()
  end
end

function EnterGame.setAccountName(account)
  local account = g_crypt.decrypt(account)
  enterGame:getChildById('accountNameTextEdit'):setText(account)
  enterGame:getChildById('accountNameTextEdit'):setCursorPos(-1)
  enterGame:getChildById('rememberAccountBox'):setChecked(#account > 0)
  if (#account > 0) then
    enterGame:getChildById('accountPasswordTextEdit'):focus()
  end
end

function EnterGame.setPassword(password)
  local password = g_crypt.decrypt(password)
  enterGame:getChildById('accountPasswordTextEdit'):setText(password)
end

function EnterGame.clearAccountFields(keepAccount)
  if (not keepAccount) then
    enterGame:getChildById('accountNameTextEdit'):clearText()
    enterGame:getChildById('accountNameTextEdit'):focus()
    g_settings.remove('account')
  end
  enterGame:getChildById('accountPasswordTextEdit'):clearText()
  g_settings.remove('password')
end

local function prepareProtocol()
  G.host = SERVER_HOST
  G.port = SERVER_PORT
  local clientVersions = g_game.getSupportedClients(PROTOCOL_VERSION)
  g_game.chooseRsa(G.host)
  g_game.setProtocolVersion(PROTOCOL_VERSION)
  if #clientVersions > 0 then
    g_game.setClientVersion(clientVersions[#clientVersions])
  end
end

function EnterGame.doLogin()
  EnterGame.loginAccount(enterGame:getChildById('accountNameTextEdit'):getText(),
                         enterGame:getChildById('accountPasswordTextEdit'):getText())
end

-- Sends one account service request (see gamelib/protocolaccount.lua) behind a wait box.
-- onDone(success, message) gets message = nil when the player cancels.
function EnterGame.accountRequest(request, onDone)
  if protocolAccount then return end
  prepareProtocol()

  local waitBox = displayCancelBox(tr('Please wait'), tr('Contacting the server...'))
  protocolAccount = ProtocolAccount.create()
  protocolAccount.onResult = function(protocol, success, message)
    protocolAccount = nil
    if waitBox then
      waitBox:destroy()
      waitBox = nil
    end
    onDone(success, message)
  end
  connect(waitBox, { onCancel = function()
                                  waitBox = nil
                                  if protocolAccount then
                                    protocolAccount:cancel()
                                    protocolAccount = nil
                                  end
                                  onDone(false, nil)
                                end })
  protocolAccount:request(SERVER_HOST, SERVER_PORT, request)
end

function EnterGame.showCreateAccount()
  if not createAccountWindow then
    createAccountWindow = g_ui.displayUI('createaccount')
  end
  EnterGame.hide()
  createAccountWindow:show()
  createAccountWindow:raise()
  createAccountWindow:focus()
  createAccountWindow:getChildById('accountNameTextEdit'):focus()
end

function EnterGame.hideCreateAccount()
  if createAccountWindow then
    createAccountWindow:destroy()
    createAccountWindow = nil
  end
  EnterGame.show()
end

function EnterGame.doCreateAccount()
  local account = createAccountWindow:getChildById('accountNameTextEdit'):getText():trim():lower()
  local password = createAccountWindow:getChildById('passwordTextEdit'):getText()
  local repeated = createAccountWindow:getChildById('passwordRepeatTextEdit'):getText()

  local function retry(title, message)
    local errorBox = displayErrorBox(title, message)
    connect(errorBox, { onOk = EnterGame.showCreateAccount })
  end

  createAccountWindow:hide()
  if password ~= repeated then
    retry(tr('Create Account'), tr('The passwords do not match.'))
    return
  end

  EnterGame.accountRequest({ action = AccountRequestCreateAccount, account = account, password = password },
    function(success, message)
      if not message then
        EnterGame.showCreateAccount()
      elseif not success then
        retry(tr('Create Account'), message)
      else
        createAccountWindow:destroy()
        createAccountWindow = nil
        local infoBox = displayInfoBox(tr('Create Account'), message)
        connect(infoBox, { onOk = function()
                                    EnterGame.show()
                                    enterGame:getChildById('accountNameTextEdit'):setText(account)
                                    enterGame:getChildById('accountPasswordTextEdit'):setText(password)
                                    enterGame:getChildById('accountPasswordTextEdit'):focus()
                                  end })
      end
    end)
end

function EnterGame.loginAccount(account, password)
  G.account = account
  G.password = password
  prepareProtocol()
  EnterGame.hide()

  if g_game.isOnline() then
    local errorBox = displayErrorBox(tr('Login Error'), tr('Cannot login while already in game.'))
    connect(errorBox, { onOk = EnterGame.show })
    return
  end

  g_settings.set('host', G.host)
  g_settings.set('port', G.port)

  protocolLogin = ProtocolLogin.create()
  protocolLogin.onLoginError = onError
  protocolLogin.onMotd = onMotd
  protocolLogin.onCharacterList = onCharacterList
  protocolLogin.onUpdateNeeded = onUpdateNeeded

  loadBox = displayCancelBox(tr('Please wait'), tr('Connecting to login server...'))
  connect(loadBox, { onCancel = function(msgbox)
                                  loadBox = nil
                                  protocolLogin:cancelLogin()
                                  EnterGame.show()
                                end })

  if modules.game_things.isLoaded() then
    protocolLogin:login(G.host, G.port, G.account, G.password)
  else
    loadBox:destroy()
    loadBox = nil
    EnterGame.show()
  end
end

function EnterGame.displayMotd()
  if not motdWindow then
    motdWindow = displayInfoBox(tr('Message of the day'), G.motdMessage)
    motdWindow.onOk = function() motdWindow = nil end
  end
end

function EnterGame.disableMotd()
  motdEnabled = false
  motdButton:hide()
end
