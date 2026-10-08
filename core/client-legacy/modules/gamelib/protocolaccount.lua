-- @docclass
-- Account service on the login port (server src/protocolaccount.h): one request per connection,
-- answered with a success or error message.
ProtocolAccount = extends(Protocol, "ProtocolAccount")

AccountRequestCreateAccount = 1
AccountRequestCreateCharacter = 2
AccountRequestDeleteCharacter = 3

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
  msg:addU16(312)

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
  elseif request.action == AccountRequestDeleteCharacter then
    msg:addString(request.name)
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
  self:finish(false, translateNetworkError(code, self:isConnecting(), msg))
end

function ProtocolAccount:finish(success, message)
  if self.finished then return end
  self.finished = true
  self:disconnect()
  signalcall(self.onResult, self, success, message)
end
