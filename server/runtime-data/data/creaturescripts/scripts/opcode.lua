function onExtendedOpcode(cid, opcode, buffer)

	--dungeons
  if opcode == Dz.Opcode then
    local receive = json.decode(buffer)
    if receive.protocol == "Maps" then
	  Dz.sendMaps(cid, receive.diff)
    elseif receive.protocol == "Play" then
      Dz.play(cid, receive.diff, receive.mapId)
    elseif receive.protocol == "CreateTeam" then
      Dz.createTeam(cid)
    elseif receive.protocol == "InviteToTeam" then
      Dz.inviteToTeam(cid, receive.name)
    elseif receive.protocol == "AcceptInvite" then
      Dz.acceptInvite(cid, receive.name)
    elseif receive.protocol == "LeaveTeam" then
      Dz.leaveTeam(cid)
    elseif receive.protocol == "CancelQueue" then
      Dz.cancelQueue(cid)
    elseif receive.protocol == "Ranking" then
      Dz.sendRanking(cid, receive.diff, receive.mapId)
    end
  elseif opcode == 103 then
    if string.find(buffer, '###RANK###') then
      CRAFT.sendItemsByRank(cid, string.explode(buffer, '###RANK###')[1], false)
    elseif string.find(buffer, '###CRAFT###') then
      local rank, id, qnt = 'E', 1, 1
      local explode = string.explode(buffer, ',')
      for e=1, #explode do
        if string.find(explode[e], 'RANK') then
          rank = string.explode(explode[e], 'RANK')[1]
        elseif string.find(explode[e], 'ID') then
          id = string.explode(explode[e], 'ID')[1]
        elseif string.find(explode[e], 'QNT') then
          qnt = string.explode(explode[e], 'QNT')[1]
        end
      end
      CRAFT.createItem(cid, rank, tonumber(id), tonumber(qnt))
    elseif string.find(buffer, '###SPEEDUP###') then
      local explode = string.explode(buffer, '###SPEEDUP###')
      CRAFT.speedUp(cid, explode[1], tonumber(explode[2]))
    elseif string.find(buffer, '###COLLECT###') then
      local explode = string.explode(buffer, '###COLLECT###')
      CRAFT.collectItem(cid, explode[1], tonumber(explode[2]))
    end
  elseif opcode == GameServerOpcodes.PokePass then
    if string.find(buffer, "BuyLevel") then
      buyPassLevel(cid)
    elseif string.find(buffer, "BuyPass50") then
      buyPass50(cid)
    elseif string.find(buffer, "BuyPass35") then
      buyPass35(cid)
    elseif string.find(buffer, "#Collect#") then
      local explode = string.explode(buffer, '#Collect#')
      collectPassReward(cid, tonumber(explode[1]), tonumber(explode[2]))
    end
  elseif opcode == GameServerOpcodes.DailyReward then
    if string.find(buffer, 'REQUEST') then
      local explode = string.explode(buffer, 'REQUEST')
      getDailyRewards(cid, explode[1], explode[2])
    elseif string.find(buffer, 'COLLECT') then
      collectDailyReward(cid)
    elseif string.find(buffer, "###BUYITEM###") then
      buyDRShopItem(cid, tonumber(string.explode(buffer, "###BUYITEM###")[1]))
    end
  elseif opcode == GameServerOpcodes.PokemonInfo then
    local receive = json.decode(buffer)
    if receive.protocol == "upgrade" then
      if receive.patternId == "base" then
        upgradeBase(cid, receive.tab)
      elseif receive.patternId == "ivev" then
        upgradeEv(cid, receive.tab)
      end
    elseif receive.protocol == "friendship" then
      if receive.type == "exp" then
        giveFriendshipExp(cid, receive.id)
      elseif receive.type == "level" then
        upgradeFriendshipLevel(cid, receive.useDiamonds)
      end
    elseif receive.protocol == "reset" then
      if receive.type == "ivev" then
		if getPlayerItemCount(cid, 35552) >= 1 then
		   doPlayerRemoveItem(cid, 35552, 1)
           doResetEvs(cid)
		else
		   local info = {Reset = {code = "Iv"}, protocol = "Info"}
		   doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
		end
      elseif receive.type == "base" then
		if getPlayerItemCount(cid, 35553) >= 1 then
		   doPlayerRemoveItem(cid, 35553, 1)
           doResetBase(cid)
		else
		   local info = {Reset = {code = "Base"}, protocol = "Info"}
		   doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
		end
      end
    end
	--market
  elseif opcode == GameServerOpcodes.Market then
    if string.find(buffer, '###MARKETALL###') then
      doRefreshMarketItems(true)
      sendMarketBuyItems(cid, "Todos", 1, 1)
      sendMarketSellItems(cid)
      sendMarketOffers(cid)
      sendMarketHistoric(cid)
    elseif string.find(buffer, '###MARKETOFFERSITEMS###') then
      local order = nil
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'Order:') then
          order = string.explode(explode[t], 'Order:')[1]
        end
      end
      sendMarketOffers(cid)
    elseif string.find(buffer, '###MARKETBUYITEMS###') then
      local category, page, order, searchstring = 'All', 1, nil, nil
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'Page:') then
          page = tonumber(string.explode(explode[t], 'Page:')[1])
        end
        if string.find(explode[t], 'Order:') then
          order = string.explode(explode[t], 'Order:')[1]
        end
        if string.find(explode[t], 'Category:') then
          category = string.explode(explode[t], 'Category:')[1]
        end
        if string.find(explode[t], 'Search:') then
          searchstring = string.explode(explode[t], 'Search:')[1]
        end
      end
      sendMarketBuyItems(cid, category, page, 1, order, searchstring)
    elseif string.find(buffer, '###MARKETBUYITEMSOFFERSBYITEMCODE###') then
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          sendMarketOffersByItemCode(cid, tostring(string.explode(explode[t], 'ItemCode:')[1]) or "")
        end
      end
    elseif string.find(buffer, '###MARKETBUYITEM###') then
      local item_code, count = '', 1
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          item_code = tostring(string.explode(explode[t], 'ItemCode:')[1]) or ""
        end
        if string.find(explode[t], 'Count:') then
          count = tonumber(string.explode(explode[t], 'Count:')[1]) or 1
        end
      end
      doMarketBuyItem(cid, item_code, count)
    elseif string.find(buffer, '###MARKETBUYPOSTOFFER###') then
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          doMarketPostOffer(cid, tostring(string.explode(explode[t], 'ItemCode:')[1]) or "")
        end
      end
    elseif string.find(buffer, '###MARKETBUYCANCELMAKEOFFER###') then
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          doMarketCancelMakeOffer(cid, tostring(string.explode(explode[t], 'ItemCode:')[1]) or "")
        end
      end
    elseif string.find(buffer, '###MARKETBUYMAKEOFFER###') then
      local item_code,count,x,y,z = '',1,0,0,0
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          item_code = tostring(string.explode(explode[t], 'ItemCode:')[1]) or ""
        end
        if string.find(explode[t], 'Count:') then
          count = tonumber(string.explode(explode[t], 'Count:')[1]) or 1
        end
        if string.find(explode[t], 'X:') then
          x = tonumber(string.explode(explode[t], 'X:')[1])
        end
        if string.find(explode[t], 'Y:') then
          y = tonumber(string.explode(explode[t], 'Y:')[1])
        end
        if string.find(explode[t], 'Z:') then
          z = tonumber(string.explode(explode[t], 'Z:')[1])
        end
      end
      doMarketMakeOffer(cid, item_code, y, z, count)
    elseif string.find(buffer, '###CHECKCANSELL###') then
      local x,y,z = 0,0,0
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'X:') then
          x = tonumber(string.explode(explode[t], 'X:')[1])
        end
        if string.find(explode[t], 'Y:') then
          y = tonumber(string.explode(explode[t], 'Y:')[1])
        end
        if string.find(explode[t], 'Z:') then
          z = tonumber(string.explode(explode[t], 'Z:')[1])
        end
      end
      checkMarketCanSellItem(cid, y, z)
    elseif string.find(buffer, '###MARKETSELLITEM###') then
      local item_code, itemId, count, price, onlyoffer = '', 0, 0, 0, 0
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          item_code = tostring(string.explode(explode[t], 'ItemCode:')[1]) or ""
        end
        if string.find(explode[t], 'ItemId:') then
          itemId = tonumber(string.explode(explode[t], 'ItemId:')[1]) or 0
        end
        if string.find(explode[t], 'Count:') then
          count = tonumber(string.explode(explode[t], 'Count:')[1]) or 1
        end
        if string.find(explode[t], 'Price:') then
          price = tonumber(string.explode(explode[t], 'Price:')[1]) or 0
        end
        if string.find(explode[t], 'OnlyOffer:') then
          onlyoffer = tonumber(string.explode(explode[t], 'OnlyOffer:')[1]) or 0
        end
      end
      doMarketSellItem(cid, item_code, itemId, count, onlyoffer, price)
    elseif string.find(buffer, '###MARKETREMOVESELLITEM###') then
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          doMarketRemoveItem(cid, tostring(string.explode(explode[t], 'ItemCode:')[1]) or "")
        end
      end
    elseif string.find(buffer, '###MARKETSELLITEMS###') then
      sendMarketSellItems(cid)
    elseif string.find(buffer, '###MARKETACCEPTOFFER###') then
      local item_code, playeroffer_id = '', 0
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          item_code = tostring(string.explode(explode[t], 'ItemCode:')[1]) or ""
        end
        if string.find(explode[t], 'PlayerOfferId:') then
          playeroffer_id = tonumber(string.explode(explode[t], 'PlayerOfferId:')[1]) or 0
        end
      end
      doMarketAcceptOffer(cid, item_code, playeroffer_id)
    elseif string.find(buffer, '###MARKETREFUSEOFFER###') then
      local item_code, playeroffer_id = '', 0
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          item_code = tostring(string.explode(explode[t], 'ItemCode:')[1]) or ""
        end
        if string.find(explode[t], 'PlayerOfferId:') then
          playeroffer_id = tonumber(string.explode(explode[t], 'PlayerOfferId:')[1]) or 0
        end
      end
      doMarketRefuseOffer(cid, item_code, playeroffer_id)
    elseif string.find(buffer, '###MARKETCANCELOFFER###') then
      local item_code = ''
      local explode = string.explode(buffer, ',')
      for t=1, #explode do
        if string.find(explode[t], 'ItemCode:') then
          item_code = tostring(string.explode(explode[t], 'ItemCode:')[1]) or ""
        end
      end
      doMarketRemoveOffer(cid, item_code)
    end
  end
end