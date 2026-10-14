-- PokeVerse additions to Redemption's login (entergame.lua): the in-client account service
-- (gamelib/protocolaccount.lua), server status in the top bar, the footer buttons and the
-- login panel layout.
PokeVerseEnterGame = {}

local WEBSITE_URL = 'https://pokeverse.quest'
local STATUS_INTERVAL = 60000
local PANEL_SIZE = { width = 340, height = 446 }
local LOGO_HEIGHT = 96
local BOB_PERIOD = 3200 -- ms
local BOB_HEIGHT = 4 -- px

local enterGame
local logo
local bobEvent
local statusProtocol
local statusEvent
local motdEvent
local protocolAccount
local createAccountWindow

local function field(id)
    return enterGame:getChildById(id)
end

-- The one server of Servers_init (init.lua); the login widgets hold it after setUniqueServer.
local function server()
    return field('serverHostTextEdit'):getText(), tonumber(field('serverPortTextEdit'):getText())
end

local function prepareProtocol()
    local host = server()
    local version = tonumber(field('clientComboBox'):getText()) or 854
    g_game.setClientVersion(version)
    g_game.setProtocolVersion(g_game.getClientProtocolVersion(version))
    g_game.chooseRsa(host)
end

-- Phones in landscape are short: the logo shrinks first, then goes.
local function layoutPanel()
    if not enterGame then
        return
    end
    local room = g_ui.getRootWidget():getHeight() - 60
    local logoHeight = math.max(0, math.min(LOGO_HEIGHT, room - (PANEL_SIZE.height - LOGO_HEIGHT)))
    if logoHeight < 40 then
        logoHeight = 0
    end
    logo:setVisible(logoHeight > 0)
    logo:setHeight(logoHeight)
    -- the fields hang from the panel top, so the bobbing logo does not move them
    field('accountNameTextEdit'):setMarginTop(logoHeight > 0 and logoHeight + 14 or 0)
    enterGame:setSize({ width = PANEL_SIZE.width, height = PANEL_SIZE.height - LOGO_HEIGHT + logoHeight -
        (logoHeight > 0 and 0 or 14) })
    field('badge'):setVisible(logoHeight > 0)
end

local function bob()
    if logo and logo:isVisible() then
        local phase = (g_clock.millis() % BOB_PERIOD) / BOB_PERIOD
        logo:setMarginTop(math.floor(math.sin(phase * 2 * math.pi) * BOB_HEIGHT + 0.5))
    end
end

-- The account and password the old login kept in the settings, until Redemption's server list has them.
local function adoptRememberedAccount()
    if #field('accountNameTextEdit'):getText() > 0 then
        return
    end
    local account = g_settings.get('account')
    if account and account ~= '' then
        EnterGame.setAccountName(account)
        EnterGame.setPassword(g_settings.get('password'))
        field('autoLoginBox'):setChecked(g_settings.getBoolean('autologin'))
    end
end

-- Redemption titles its window and relabels the checkbox for the client version (updateLabelText).
function EnterGame.onLabelsUpdated(window)
    window:setText('')
    window:getChildById('rememberEmailBox'):setText(tr('Remember Account'))
end

function PokeVerseEnterGame.init()
    enterGame = g_ui.getRootWidget():getChildById('enterGame')
    logo = field('logo')
    EnterGame.onLabelsUpdated(enterGame)
    -- Redemption sizes its window for the one-server layout; ours is the panel
    field('rememberEmailBox'):setMarginTop(12)
    adoptRememberedAccount()
    layoutPanel()
    connect(g_ui.getRootWidget(), { onGeometryChange = layoutPanel })
    connect(g_ui.getRootWidget(), { onGeometryChange = CharacterList.layoutFrame })
    bobEvent = cycleEvent(bob, 50)

    -- the message of the day is not a box on the way to the character list: News shows it,
    -- and a new one is posted in game once (showNewMotd)
    EnterGame.disableMotd()
    G.motdMessage = G.motdMessage or g_settings.get('pokeverse-motd')
    connect(g_game, { onGameStart = PokeVerseEnterGame.stopStatusPolling,
                      onGameEnd = PokeVerseEnterGame.startStatusPolling })
    connect(g_game, { onGameStart = PokeVerseEnterGame.showNewMotd })
    connect(g_game, { onGameStart = CharacterList.onSessionStart, onGameEnd = CharacterList.onSessionEnd })
    PokeVerseEnterGame.startStatusPolling()
end

function PokeVerseEnterGame.terminate()
    disconnect(g_ui.getRootWidget(), { onGeometryChange = layoutPanel })
    disconnect(g_ui.getRootWidget(), { onGeometryChange = CharacterList.layoutFrame })
    disconnect(g_game, { onGameStart = PokeVerseEnterGame.stopStatusPolling,
                         onGameEnd = PokeVerseEnterGame.startStatusPolling })
    disconnect(g_game, { onGameStart = PokeVerseEnterGame.showNewMotd })
    disconnect(g_game, { onGameStart = CharacterList.onSessionStart, onGameEnd = CharacterList.onSessionEnd })
    if motdEvent then
        removeEvent(motdEvent)
        motdEvent = nil
    end
    PokeVerseEnterGame.stopStatusPolling()
    if bobEvent then
        removeEvent(bobEvent)
        bobEvent = nil
    end
    if protocolAccount then
        protocolAccount:cancel()
        protocolAccount = nil
    end
    destroyCreateAccount()
    enterGame = nil
    logo = nil
    PokeVerseEnterGame = nil
end

function PokeVerseEnterGame.openSettings()
    if modules.client_options then
        modules.client_options.show()
    end
end

function PokeVerseEnterGame.openWebsite()
    g_platform.openUrl(WEBSITE_URL)
end

-- A refused login (wrong password, outdated client) keeps the account name and stops auto login.
function EnterGame.clearAccountFields()
    field('accountPasswordTextEdit'):clearText()
    field('accountPasswordTextEdit'):focus()
    g_settings.remove('password')
    g_settings.set('autologin', false)
end

-- Posts a message of the day the player has not seen yet, once the game screen is up.
function PokeVerseEnterGame.showNewMotd()
    if not G.motdNumber or G.motdNumber == g_settings.getNumber('motd') or not G.motdMessage
        or G.motdMessage == '' then
        return
    end
    if motdEvent then
        removeEvent(motdEvent)
    end
    motdEvent = scheduleEvent(function()
        motdEvent = nil
        if g_game.isOnline() and modules.game_console then
            g_settings.set('motd', G.motdNumber)
            modules.game_console.addText(tr('News: %s', G.motdMessage), { color = '#ffd75a' }, tr('Local Chat'))
        end
    end, 2000)
end

function EnterGame.displayMotd()
    local message = G.motdMessage
    if not message or message == '' then
        message = tr('News appear here after your first login. Visit the website for more.')
    end
    local box = displayInfoBox(tr('News'), message)
    connect(box, { onOk = function()
        if not g_game.isOnline() and not CharacterList.isVisible() then
            EnterGame.show()
        end
    end })
end

-- Server status for the top bar: a status request on the login port every minute while not in game.
function PokeVerseEnterGame.pollServerStatus()
    if statusProtocol or g_game.isOnline() or g_game.isLogging() then
        return
    end
    local topMenu = modules.client_topmenu
    if not (topMenu and topMenu.setServerStatus) then
        return
    end

    prepareProtocol()
    statusProtocol = ProtocolAccount.create()
    statusProtocol.onResult = function(protocol, success, message, networkError)
        statusProtocol = nil
        if networkError then
            topMenu.setServerStatus(false)
        else
            topMenu.setServerStatus(true, success and tonumber(message) or nil)
        end
    end
    local host, port = server()
    statusProtocol:request(host, port, { action = AccountRequestServerStatus, account = '', password = '' })
end

function PokeVerseEnterGame.startStatusPolling()
    PokeVerseEnterGame.stopStatusPolling()
    PokeVerseEnterGame.pollServerStatus()
    statusEvent = cycleEvent(PokeVerseEnterGame.pollServerStatus, STATUS_INTERVAL)
end

function PokeVerseEnterGame.stopStatusPolling()
    if statusEvent then
        removeEvent(statusEvent)
        statusEvent = nil
    end
    if statusProtocol then
        statusProtocol:cancel()
        statusProtocol = nil
    end
end

-- Sends one account service request behind a wait box. onDone(success, message) gets
-- message = nil when the player cancels.
function EnterGame.accountRequest(request, onDone)
    if protocolAccount then
        return
    end
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
    local host, port = server()
    protocolAccount:request(host, port, request)
end

-- Logs in again with the account in use, for a fresh character list.
function EnterGame.loginAccount(account, password)
    field('accountNameTextEdit'):setText(account)
    field('accountPasswordTextEdit'):setText(password)
    EnterGame.doLogin()
end

-- Redemption's character list closes its own create account window through this.
function destroyCreateAccount()
    if createAccountWindow then
        createAccountWindow:destroy()
        createAccountWindow = nil
    end
end

function EnterGame.showCreateAccount()
    if not createAccountWindow then
        createAccountWindow = g_ui.displayUI('pokeverse_createaccount')
    end
    EnterGame.hide()
    createAccountWindow:show()
    createAccountWindow:raise()
    createAccountWindow:focus()
    createAccountWindow:getChildById('accountNameTextEdit'):focus()
end

function EnterGame.hideCreateAccount()
    destroyCreateAccount()
    EnterGame.show()
end

function EnterGame.doCreateAccount()
    local account = createAccountWindow:getChildById('accountNameTextEdit'):getText():trim():lower()
    local password = createAccountWindow:getChildById('passwordTextEdit'):getText()
    local repeated = createAccountWindow:getChildById('passwordRepeatTextEdit'):getText()

    local function retry(message)
        local errorBox = displayErrorBox(tr('Create Account'), message)
        connect(errorBox, { onOk = EnterGame.showCreateAccount })
    end

    createAccountWindow:hide()
    if password ~= repeated then
        retry(tr('The passwords do not match.'))
        return
    end

    EnterGame.accountRequest({ action = AccountRequestCreateAccount, account = account, password = password },
        function(success, message)
            if not message then
                EnterGame.showCreateAccount()
            elseif not success then
                retry(message)
            else
                destroyCreateAccount()
                local infoBox = displayInfoBox(tr('Create Account'), message)
                connect(infoBox, { onOk = function()
                    EnterGame.show()
                    field('accountNameTextEdit'):setText(account)
                    field('accountPasswordTextEdit'):setText(password)
                    field('accountPasswordTextEdit'):focus()
                end })
            end
        end)
end
