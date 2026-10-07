function onExtendedOpcode(player, opcode, buffer)

local json_status, json_data =
    pcall(
    function()
        return json.decode(buffer)
    end
)

if not json_status then
    g_logger.error("[Loja] JSON error: " .. json_data)
    return
end

if opcode == 21 and json_data.ServerName == "misty" and json_data.ServerType == "diamond" then
if getPlayerItemCount(cid, 34524) >= 1 then
	doPlayerAddItem(cid, 13299, 1)
	return doPlayerRemoveItem(cid, 34524, 1)
else
	return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Desculpe mas você não tem Diamonds suficientes para comprar essa outfit.")
end
	
end
end