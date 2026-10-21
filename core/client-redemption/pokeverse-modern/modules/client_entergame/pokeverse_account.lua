-- Account emails (server src/accountemail.h): the code from the signup email, adding an email
-- to an older account, Forgot password on the login screen, and the Account window (character
-- list and Settings) to change the password or the email. Every window is a PVFormWindow
-- built from a list of fields and buttons.
PokeVerseAccount = {}

local VERIFY_MARKER = '#verify-email#'
local ADD_MARKER = '#add-email#'
local CHANGE_MARKER = '#change-email#'
local MAX_EMAIL = 50
local DISCORD_INVITE_URL = 'https://discord.gg/P88WNBB56E'

local form
local reminded = {}

local function closeForm()
    if form then
        form:destroy()
        form = nil
    end
end

-- The marker at the start of a server message, and the message without it.
local function splitMarker(message)
    for _, marker in ipairs({ VERIFY_MARKER, ADD_MARKER, CHANGE_MARKER }) do
        if message:sub(1, #marker) == marker then
            return marker, message:sub(#marker + 1)
        end
    end
    return nil, message
end

local function cleanEmail(text)
    return text:trim():lower()
end

local function emailProblem(email, repeated)
    if not email:match('^[^@%s]+@[^@%s]+%.[^@%s]+$') or #email > MAX_EMAIL then
        return tr('Please enter a valid email address (at most %d characters).', MAX_EMAIL)
    end
    if repeated and email ~= repeated then
        return tr('The emails do not match.')
    end
end

--[[ spec: title, message, fields = { { id, placeholder, password, max, text, icon } },
     buttons = { { text, style, onClick = function(values, widget) } }; an entry { row = { button, button } }
     puts two buttons side by side. Enter presses the first button, Escape the last one. ]]
function PokeVerseAccount.openForm(spec)
    closeForm()
    form = g_ui.createWidget('PVFormWindow', g_ui.getRootWidget())
    form:getChildById('title'):setText(spec.title)
    local message = form:getChildById('message')
    message:setText(spec.message or '')
    message:setVisible(spec.message ~= nil and spec.message ~= '')

    local fields = {}
    for _, field in ipairs(spec.fields or {}) do
        -- the placeholder is a style property only, so the field comes from OTUI text
        local edit = g_ui.loadUIFromString(string.format(
            '%s\n  id: %s\n  placeholder: %s\n  max-length: %d\n  PVFieldIcon\n    image-source: /modules/client_entergame/images/%s\n',
            field.password and 'PVPasswordField' or 'PVField', field.id, field.placeholder, field.max or 50,
            field.icon or (field.password and 'icon_lock' or 'icon_user')), form)
        edit:setText(field.text or '')
        table.insert(fields, edit)
    end

    local window = form
    local function values()
        local result = {}
        for _, edit in ipairs(fields) do
            result[edit:getId()] = edit:getText()
        end
        return result
    end

    local buttons = {}
    local function addButton(button, parent, defaultStyle)
        local widget = g_ui.createWidget(button.style or defaultStyle, parent)
        widget:setText(button.text)
        widget.onClick = function()
            if form == window then
                button.onClick(values(), widget)
            end
        end
        table.insert(buttons, widget)
        return widget
    end
    for i, button in ipairs(spec.buttons) do
        local defaultStyle = i == 1 and 'PVYellowButton' or 'PVBlueButton'
        local first
        if button.row then
            first = g_ui.createWidget('PVButtonRow', form)
            local left = addButton(button.row[1], first, defaultStyle)
            left:addAnchor(AnchorTop, 'parent', AnchorTop)
            left:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            left:addAnchor(AnchorRight, 'parent', AnchorHorizontalCenter)
            left:setMarginRight(5)
            local right = addButton(button.row[2], first, 'PVBlueButton')
            right:addAnchor(AnchorTop, 'parent', AnchorTop)
            right:addAnchor(AnchorLeft, 'parent', AnchorHorizontalCenter)
            right:addAnchor(AnchorRight, 'parent', AnchorRight)
            right:setMarginLeft(5)
        else
            first = addButton(button, form, defaultStyle)
        end
        if i == 1 then
            first:setMarginTop(8)
        end
    end
    form.onEnter = function() buttons[1].onClick() end
    form.onEscape = function() buttons[#buttons].onClick() end

    form:show()
    form:raise()
    form:focus()
    for _, edit in ipairs(fields) do
        if edit:getText() == '' then
            edit:focus()
            break
        end
    end
    if fields[1] and not form:getFocusedChild() then
        fields[1]:focus()
    end
    return form
end

-- One account service request; the window goes while it runs and onDone(success, message)
-- gets message = nil when the player cancels.
local function send(request, onDone)
    closeForm()
    EnterGame.accountRequest(request, onDone)
end

local function showError(title, message, onOk)
    local box = displayErrorBox(title, message)
    connect(box, { onOk = onOk })
end

local function showInfo(title, message, onOk)
    local box = displayInfoBox(title, message)
    connect(box, { onOk = onOk })
end

--[[ The flows below get an account table: { name, password, onDone(verified), onLater }.
     onDone runs once the email is verified, onLater when the player leaves the window. ]]
local openAddEmail, openChangeCodes

local function openVerify(account, message)
    local function again(text)
        openVerify(account, text or message)
    end
    PokeVerseAccount.openForm({
        title = tr('Verify your email'),
        message = message,
        fields = { { id = 'code', placeholder = tr('6-digit code'), max = 6, icon = 'icon_key' } },
        buttons = {
            { text = tr('Verify'), onClick = function(values)
                send({ action = AccountRequestVerifyEmail, account = account.name, password = account.password,
                       texts = { values.code:trim() } }, function(success, reply)
                    if not reply then return again() end
                    local marker, text = splitMarker(reply)
                    if success then
                        showInfo(tr('Verify your email'), text, function()
                            if account.onDone then account.onDone(true) end
                        end)
                    elseif marker == ADD_MARKER then
                        openAddEmail(account, text)
                    else
                        showError(tr('Verify your email'), text, function() again() end)
                    end
                end)
            end },
            { text = tr('Send a new code'), onClick = function()
                send({ action = AccountRequestResendCode, account = account.name, password = account.password },
                    function(success, reply)
                        if not reply then return again() end
                        local marker, text = splitMarker(reply)
                        if marker == ADD_MARKER then
                            openAddEmail(account, text)
                        elseif success then
                            again(text)
                        else
                            showError(tr('Verify your email'), text, function() again() end)
                        end
                    end)
            end },
            { text = tr('Change email'), onClick = function()
                openAddEmail(account, tr('Enter the email to send the code to.'))
            end },
            { text = tr('Later'), onClick = function()
                closeForm()
                if account.onLater then account.onLater() end
            end },
        },
    })
end

openAddEmail = function(account, message, values)
    values = values or {}
    local function again(text)
        openAddEmail(account, text or message, values)
    end
    PokeVerseAccount.openForm({
        title = tr('Add your email'),
        message = message,
        fields = {
            { id = 'email', placeholder = tr('Email'), max = MAX_EMAIL, text = values.email, icon = 'icon_mail' },
            { id = 'repeat', placeholder = tr('Repeat Email'), max = MAX_EMAIL, text = values['repeat'], icon = 'icon_mail' },
        },
        buttons = {
            { text = tr('Send code'), onClick = function(entered)
                values = entered
                local email = cleanEmail(entered.email)
                local problem = emailProblem(email, cleanEmail(entered['repeat']))
                if problem then
                    return showError(tr('Add your email'), problem, function() again() end)
                end
                send({ action = AccountRequestSetEmail, account = account.name, password = account.password,
                       texts = { email } }, function(success, reply)
                    if not reply then return again() end
                    local _, text = splitMarker(reply)
                    if success then
                        openVerify(account, text)
                    else
                        showError(tr('Add your email'), text, function() again() end)
                    end
                end)
            end },
            { text = tr('Later'), onClick = function()
                closeForm()
                if account.onLater then account.onLater() end
            end },
        },
    })
end

-- A server message with a marker opens its window; true when it did.
function PokeVerseAccount.handleMarker(message, account)
    local marker, text = splitMarker(message or '')
    if marker == VERIFY_MARKER then
        openVerify(account, text)
    elseif marker == ADD_MARKER then
        openAddEmail(account, text)
    elseif marker == CHANGE_MARKER then
        openChangeCodes(account, text)
    else
        return false
    end
    return true
end

-- A login refused for the email (entergame.lua onError): the window instead of the error, then
-- the login again once the email is verified.
function EnterGame.onLoginRefused(message)
    local account = {
        name = G.account,
        password = G.password,
        onDone = function()
            EnterGame.show()
            EnterGame.doLogin()
        end,
        onLater = EnterGame.show,
    }
    if not account.name or account.name == '' then
        return false
    end
    if PokeVerseAccount.handleMarker(message, account) then
        EnterGame.hide()
        return true
    end
    return false
end

-- After signup: the code window, then straight into the character list.
function PokeVerseAccount.afterSignup(name, password, message)
    local account = {
        name = name,
        password = password,
        onDone = function() EnterGame.loginAccount(name, password) end,
        onLater = function()
            EnterGame.show()
            EnterGame.fillLogin(name, password)
        end,
    }
    if not PokeVerseAccount.handleMarker(message, account) then
        showInfo(tr('Create Account'), message, account.onLater)
    end
end

-- Forgot password: a code to the account's email, then the new password.
function PokeVerseAccount.openForgotPassword(prefill)
    EnterGame.hide()
    local function back()
        closeForm()
        EnterGame.show()
    end
    local function step1(text)
        PokeVerseAccount.openForm({
            title = tr('Forgot password'),
            message = tr('Enter your account name or your email. We will send a code to the email of the account.'),
            fields = { { id = 'account', placeholder = tr('Account Name or Email'), max = MAX_EMAIL, text = text } },
            buttons = {
                { text = tr('Send code'), onClick = function(values)
                    local input = values.account:trim():lower()
                    if input == '' then return end
                    send({ action = AccountRequestRecoverRequest, account = input, password = '' }, function(success, reply)
                        if not reply then return step1(input) end
                        if not success then
                            return showError(tr('Forgot password'), reply, function() step1(input) end)
                        end
                        PokeVerseAccount.openResetPassword(input:find('@') and '' or input, reply, function() step1(input) end, back)
                    end)
                end },
                { text = tr('Back'), onClick = back },
            },
        })
    end
    step1(prefill)
end

function PokeVerseAccount.openResetPassword(name, message, onSendAgain, onBack, values)
    values = values or { account = name }
    local function again()
        PokeVerseAccount.openResetPassword(name, message, onSendAgain, onBack, values)
    end
    PokeVerseAccount.openForm({
        title = tr('New password'),
        message = message .. '\n' .. tr('The email names your account if you asked with your email.'),
        fields = {
            { id = 'account', placeholder = tr('Account Name'), max = 25, text = values.account },
            { id = 'code', placeholder = tr('6-digit code'), max = 6, text = values.code, icon = 'icon_key' },
            { id = 'password', placeholder = tr('New Password'), max = 29, password = true, text = values.password },
            { id = 'repeat', placeholder = tr('Repeat Password'), max = 29, password = true, text = values['repeat'] },
        },
        buttons = {
            { text = tr('Change password'), onClick = function(entered)
                values = entered
                local account = entered.account:trim():lower()
                if entered.password ~= entered['repeat'] then
                    return showError(tr('New password'), tr('The passwords do not match.'), again)
                end
                send({ action = AccountRequestRecoverReset, account = account, password = entered.password,
                       texts = { entered.code:trim() } }, function(success, reply)
                    if not reply then return again() end
                    if not success then
                        return showError(tr('New password'), reply, again)
                    end
                    showInfo(tr('New password'), reply, function()
                        EnterGame.show()
                        EnterGame.fillLogin(account, entered.password)
                    end)
                end)
            end },
            { text = tr('Send a new code'), onClick = onSendAgain },
            { text = tr('Back'), onClick = onBack },
        },
    })
end

local function parseInfo(reply)
    local info = {}
    for line in reply:gmatch('[^\n]+') do
        local key, value = line:match('^(%w+)=(.*)$')
        if key then
            info[key] = value
        end
    end
    return info
end

-- The logged in account: G.account and G.password (character list and game).
local function currentAccount(onDone)
    return { name = G.account, password = G.password, onDone = onDone, onLater = onDone }
end

local openAccount, openDiscordLink

local function openChangePassword(values)
    values = values or {}
    local function again()
        openChangePassword(values)
    end
    PokeVerseAccount.openForm({
        title = tr('Change password'),
        message = tr('Password: 8 to 29 characters, not a common one.'),
        fields = {
            { id = 'current', placeholder = tr('Current Password'), max = 29, password = true, text = values.current },
            { id = 'password', placeholder = tr('New Password'), max = 29, password = true, text = values.password },
            { id = 'repeat', placeholder = tr('Repeat Password'), max = 29, password = true, text = values['repeat'] },
        },
        buttons = {
            { text = tr('Change password'), onClick = function(entered)
                values = entered
                if entered.password ~= entered['repeat'] then
                    return showError(tr('Change password'), tr('The passwords do not match.'), again)
                end
                send({ action = AccountRequestChangePassword, account = G.account, password = entered.current,
                       texts = { entered.password } }, function(success, reply)
                    if not reply then return again() end
                    if not success then
                        return showError(tr('Change password'), reply, again)
                    end
                    G.password = entered.password
                    if g_settings.get('password') and g_settings.get('password') ~= '' then
                        g_settings.set('password', g_crypt.encrypt(G.password))
                        if ServerList and G.host then
                            ServerList.setServerPassword(G.host, G.password)
                            ServerList.save()
                        end
                    end
                    showInfo(tr('Change password'), reply, openAccount)
                end)
            end },
            { text = tr('Back'), onClick = function() openAccount() end },
        },
    })
end

openChangeCodes = function(account, message, values)
    values = values or {}
    local function again(text)
        openChangeCodes(account, text or message, values)
    end
    PokeVerseAccount.openForm({
        title = tr('Change email'),
        message = message,
        fields = {
            { id = 'old', placeholder = tr('Code from your current email'), max = 6, text = values.old, icon = 'icon_key' },
            { id = 'new', placeholder = tr('Code from the new email'), max = 6, text = values.new, icon = 'icon_key' },
        },
        buttons = {
            { text = tr('Change email'), onClick = function(entered)
                values = entered
                send({ action = AccountRequestEmailChangeConfirm, account = account.name, password = account.password,
                       texts = { entered.old:trim(), entered.new:trim() } }, function(success, reply)
                    if not reply then return again() end
                    if not success then
                        return showError(tr('Change email'), reply, function() again() end)
                    end
                    showInfo(tr('Change email'), reply, function()
                        if account.onDone then account.onDone(true) end
                    end)
                end)
            end },
            { text = tr('Back'), onClick = function()
                closeForm()
                if account.onLater then account.onLater() end
            end },
        },
    })
end

local function openChangeEmail(values)
    values = values or {}
    local function again()
        openChangeEmail(values)
    end
    PokeVerseAccount.openForm({
        title = tr('Change email'),
        message = tr('We will send a code to your current email and one to the new email.'),
        fields = {
            { id = 'email', placeholder = tr('New Email'), max = MAX_EMAIL, text = values.email, icon = 'icon_mail' },
            { id = 'repeat', placeholder = tr('Repeat Email'), max = MAX_EMAIL, text = values['repeat'], icon = 'icon_mail' },
        },
        buttons = {
            { text = tr('Send codes'), onClick = function(entered)
                values = entered
                local email = cleanEmail(entered.email)
                local problem = emailProblem(email, cleanEmail(entered['repeat']))
                if problem then
                    return showError(tr('Change email'), problem, again)
                end
                send({ action = AccountRequestEmailChangeRequest, account = G.account, password = G.password,
                       texts = { email } }, function(success, reply)
                    if not reply then return again() end
                    if not success then
                        return showError(tr('Change email'), reply, again)
                    end
                    PokeVerseAccount.handleMarker(reply, currentAccount(openAccount))
                end)
            end },
            { text = tr('Back'), onClick = function() openAccount() end },
        },
    })
end

local function describe(info)
    local lines = { tr('Account: %s', G.account) }
    if info.email ~= '' and info.verified == '1' then
        table.insert(lines, tr('Email: %s', info.email))
    elseif info.pending ~= '' or info.email ~= '' then
        table.insert(lines, tr('Email: %s (not verified yet)', info.pending ~= '' and info.pending or info.email))
    else
        table.insert(lines, tr('Email: none'))
    end
    local days = tonumber(info.daysLeft) or -1
    if info.required == '1' and info.verified ~= '1' and days > 0 then
        table.insert(lines, tr('Add an email within %d days to keep playing.', days))
    end
    table.insert(lines, info.recovery == '1' and tr('Recovery key: set') or tr('Recovery key: not set'))
    table.insert(lines, info.discord == '1' and tr('Discord: linked') or tr('Discord: not linked'))
    return table.concat(lines, '\n')
end

local function joinDiscordButton()
    return { text = tr('Join Discord'), style = 'PVBlueButton', onClick = function() PokeVerseAccount.joinDiscord() end }
end

-- A one-time code for /link in the Discord server; Copy command puts "/link code:<code>" on the clipboard.
-- onBack replaces going back to the Account window (the Pokepedia passes closeForm).
openDiscordLink = function(onBack)
    local back = onBack or openAccount
    if not G.account or G.account == '' or not G.password then
        return showInfo(tr('Link Discord'), tr('Log in first to manage your account.'))
    end
    send({ action = AccountRequestDiscordCode, account = G.account, password = G.password }, function(success, reply)
        if not reply then return back() end
        if not success then
            return showError(tr('Link Discord'), reply, back)
        end
        local command = '/link code:' .. reply
        PokeVerseAccount.openForm({
            title = tr('Link Discord'),
            message = tr('Your code is %s\n\nCopy the command and paste it into any channel of the PokeVerse Discord server. The code works once and expires in 10 minutes. Never share it with anyone.', reply),
            buttons = {
                { row = {
                    { text = tr('Copy command'), style = 'PVYellowButton', onClick = function(_, widget)
                        g_window.setClipboardText(command)
                        widget:setText(tr('Copied!'))
                    end },
                    joinDiscordButton() } },
                { text = onBack and tr('Close') or tr('Back'), style = 'PVBlueButton', onClick = function() back() end },
            },
        })
    end)
end

-- The Account window: what the account has, and the changes.
openAccount = function()
    if not G.account or G.account == '' or not G.password then
        return showInfo(tr('Account'), tr('Log in first to manage your account.'))
    end
    send({ action = AccountRequestAccountInfo, account = G.account, password = G.password }, function(success, reply)
        if not reply then return end
        if not success then
            return showError(tr('Account'), reply)
        end
        local info = parseInfo(reply)
        local buttons = {}
        if info.verified == '1' then
            table.insert(buttons, { text = tr('Change email'), style = 'PVBlueButton', onClick = function() openChangeEmail() end })
        elseif info.pending ~= '' then
            table.insert(buttons, { text = tr('Enter email code'), style = 'PVYellowButton', onClick = function()
                openVerify(currentAccount(openAccount), tr('Enter the code we sent to %s.', info.pending))
            end })
        else
            table.insert(buttons, { text = tr('Add email'), style = 'PVYellowButton', onClick = function()
                openAddEmail(currentAccount(openAccount), tr('We will send a 6-digit code to it.'))
            end })
        end
        table.insert(buttons, { text = tr('Change password'), style = 'PVBlueButton', onClick = function() openChangePassword() end })
        if info.discord == '1' then
            table.insert(buttons, joinDiscordButton())
        else
            table.insert(buttons, { row = {
                { text = tr('Link Discord'), style = 'PVBlueButton', onClick = function() openDiscordLink() end },
                joinDiscordButton() } })
        end
        table.insert(buttons, { text = tr('Close'), style = 'PVBlueButton', onClick = closeForm })
        PokeVerseAccount.openForm({ title = tr('Your Account'), message = describe(info), buttons = buttons })
    end)
end
PokeVerseAccount.openAccount = openAccount
PokeVerseAccount.openDiscordLink = openDiscordLink
PokeVerseAccount.closeForm = closeForm
function PokeVerseAccount.joinDiscord()
    g_platform.openUrl(DISCORD_INVITE_URL)
end

-- Once per account and client run, after the character list: older accounts without a
-- verified email are asked to add one while their days last.
function PokeVerseAccount.remindEmail()
    local name, password = G.account, G.password
    if not name or name == '' or reminded[name] then
        return
    end
    reminded[name] = true
    local protocol = ProtocolAccount.create()
    protocol.onResult = function(_, success, reply)
        if not success or not CharacterList.isVisible() or g_game.isOnline() then
            return
        end
        local info = parseInfo(reply)
        local days = tonumber(info.daysLeft) or -1
        if info.required ~= '1' or info.verified == '1' or days <= 0 then
            return
        end
        local account = { name = name, password = password }
        local message = tr('Please add an email to your account, so you can reset your password if you forget it. In %d days it is needed to play.', days)
        if info.pending ~= '' then
            openVerify(account, tr('Enter the code we sent to %s.', info.pending))
        else
            openAddEmail(account, message)
        end
    end
    local host, port = EnterGame.getServer()
    protocol:request(host, port, { action = AccountRequestAccountInfo, account = name, password = password })
end

function PokeVerseAccount.terminate()
    closeForm()
    PokeVerseAccount = nil
end
