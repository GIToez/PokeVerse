function onSay(cid, words, param, channel)
	local id = tonumber(param)
	if(id) then
		Reports.sayOne(cid, id)
	else
		Reports.sayList(cid)
	end
	return true
end
