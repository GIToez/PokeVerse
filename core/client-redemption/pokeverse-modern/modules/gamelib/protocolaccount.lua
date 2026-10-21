-- @docclass
-- Account service on the login port (server src/protocolaccount.h): one request per connection,
-- answered with a success or error message.
ProtocolAccount = extends(Protocol, "ProtocolAccount")

-- PokeVerse client version sent by the login and account protocols (server CLIENT_VERSION_MAX).
-- 314: the character list has sex, town, last login, play time and the starter outfits, and
-- create character sends the chosen outfit.
POKEVERSE_CLIENT_VERSION = 314

AccountRequestCreateAccount = 1
AccountRequestCreateCharacter = 2
AccountRequestDeleteCharacter = 3
AccountRequestServerStatus = 4 -- answered with the number of players online
-- account emails (server src/protocolaccount.h): the strings after the password are request.texts
AccountRequestVerifyEmail = 5 -- texts: code
AccountRequestResendCode = 6
AccountRequestSetEmail = 7 -- texts: email (accounts without a verified email)
AccountRequestRecoverRequest = 8 -- account: the account name or the email, no password
AccountRequestRecoverReset = 9 -- password: the new password; texts: code
AccountRequestChangePassword = 10 -- texts: new password
AccountRequestEmailChangeRequest = 11 -- texts: new email
AccountRequestEmailChangeConfirm = 12 -- texts: code sent to the old email, code sent to the new one
AccountRequestAccountInfo = 13 -- answered with key=value lines
AccountRequestDiscordCode = 14 -- answered with a Discord link code, as !discord link gives in the game

local ProtocolAccountId = 0x0B
local AccountReplySuccess = 0x0B

function ProtocolAccount:request(host, port, request)
  if string.len(host) == 0 or port == nil or port == 0 then
    signalcall(self.onResult, self, false, tr("You must enter a valid server address and port."))
    return
  end

  self.accountRequest = request
  self:connect(host, port)
end

function ProtocolAccount:cancel()
  self.finished = true
  self:disconnect()
end

function ProtocolAccount:onConnect()
  local request = self.accountRequest
  local msg = OutputMessage.create()
  msg:addU8(ProtocolAccountId)
  msg:addU16(g_game.getOs())
  msg:addU16(POKEVERSE_CLIENT_VERSION)

  local offset = msg:getMessageSize()
  msg:addU8(0) -- first RSA byte must be 0
  self:generateXteaKey()
  local xteaKey = self:getXteaKey()
  for i = 1, 4 do
    msg:addU32(xteaKey[i])
  end

  msg:addU8(request.action)
  msg:addString(request.account)
  msg:addString(request.password)
  if request.action == AccountRequestCreateCharacter then
    msg:addString(request.name)
    msg:addU8(request.sex)
    -- no outfit (look type 0): the server keeps the default one
    local outfit = request.outfit or {}
    msg:addU16(outfit.type or 0)
    msg:addU8(outfit.head or 0)
    msg:addU8(outfit.body or 0)
    msg:addU8(outfit.legs or 0)
    msg:addU8(outfit.feet or 0)
  elseif request.action == AccountRequestDeleteCharacter then
    msg:addString(request.name)
  else
    for _, text in ipairs(request.texts or {}) do
      msg:addString(text)
    end
  end

  local paddingBytes = g_crypt.rsaGetSize() - (msg:getMessageSize() - offset)
  if paddingBytes < 0 then
    self:finish(false, tr("The entered values are too long."))
    return
  end
  msg:addPaddingBytes(paddingBytes, 0)
  msg:encryptRsa()

  if g_game.getFeature(GameProtocolChecksum) then
    self:enableChecksum()
  end

  self:send(msg)
  self:enableXteaEncryption()
  self:recv()
end

function ProtocolAccount:onRecv(msg)
  local success = msg:getU8() == AccountReplySuccess
  self:finish(success, msg:getString())
end

function ProtocolAccount:onError(msg, code)
  self:finish(false, translateNetworkError(code, self:isConnecting(), msg), true)
end

-- networkError is true when the server could not be reached at all
function ProtocolAccount:finish(success, message, networkError)
  if self.finished then return end
  self.finished = true
  self:disconnect()
  signalcall(self.onResult, self, success, message, networkError == true)
end
