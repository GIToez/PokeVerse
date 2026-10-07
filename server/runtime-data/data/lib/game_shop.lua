-- Shared protections for the diamond shop (/shopbuy, /buymastery, /renamediamond).
-- Prices live in the talkaction config tables; the client only sends the offer key.
SHOP = {
	CURRENCY = 34524, -- diamond
	COOLDOWN = 2, -- seconds between purchases per character
	LOG_FILE = "shop.log",
	lastPurchase = {},
}

function SHOP.sendBalance(cid)
	doSendShopRent(cid)
end

-- Returns true when the character must wait before buying again; also starts the cooldown.
function SHOP.throttle(cid)
	local guid = getPlayerGUID(cid)
	local now = os.time()
	local last = SHOP.lastPurchase[guid]
	if last and now - last < SHOP.COOLDOWN then
		return true
	end
	SHOP.lastPurchase[guid] = now
	return false
end

function SHOP.log(cid, offer, cost, result)
	doWriteLogFile((LOGS_DIR or "logs/") .. SHOP.LOG_FILE, string.format("%s (guid %d) offer=%s cost=%d result=%s balance=%d",
		getCreatureName(cid), getPlayerGUID(cid), tostring(offer), cost or 0, result, getPlayerItemCount(cid, SHOP.CURRENCY)))
end

-- Removes the price before anything is granted. False when the balance is short or the removal failed.
function SHOP.debit(cid, cost)
	if cost < 0 or getPlayerItemCount(cid, SHOP.CURRENCY) < cost then
		return false
	end
	return cost == 0 or doPlayerRemoveItem(cid, SHOP.CURRENCY, cost) == true
end

function SHOP.refund(cid, cost)
	if cost > 0 then
		doPlayerAddItem(cid, SHOP.CURRENCY, cost)
	end
end

-- Adds {{itemid, count}, ...} without dropping anything on the floor; on failure removes what was added.
function SHOP.addItems(cid, items)
	local added = {}
	for _, entry in ipairs(items) do
		local result = doPlayerAddItem(cid, entry[1], entry[2] or 1, false)
		if result == false then
			for _, uid in ipairs(added) do
				doRemoveItem(uid)
			end
			return false
		end
		if result then
			added[#added + 1] = result
		end
	end
	return true
end
