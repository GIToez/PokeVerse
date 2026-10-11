function onSay(cid, words, param, channel)

local config = {
["gaia5"] = {cost = 80, npc = "Enzo", style = "mastery_5", cla = MASTERYID_GAIA, 
	rank0 = VOCATIONID_GAIASTARTER,
	rank1 = VOCATIONID_GAIAFOREST,
	rank2 = VOCATIONID_GAIAJUNGLE,
	rank3 = VOCATIONID_GAIACATCHER,
	rank4 = VOCATIONID_GAIAEXOARMOR,
	rank5 = VOCATIONID_GAIANATURAL
},
["avalanche5"] = {cost = 80, npc = "Bronson", style = "mastery_5", cla = MASTERYID_AVALANCHE, 
	rank0 = VOCATIONID_AVALANCHESTARTER,
	rank1 = VOCATIONID_AVALANCHECOLDHEART,
	rank2 = VOCATIONID_AVALANCHEREEF,
	rank3 = VOCATIONID_AVALANCHEOCEANBORN,
	rank4 = VOCATIONID_AVALANCHECRUSTACEA,
	rank5 = VOCATIONID_AVALANCHELEAVIATHAN
},
["spectrum5"] = {cost = 80, npc = "Roxy", style = "mastery_5", cla = MASTERYID_SPECTRUM, 
	rank0 = VOCATIONID_SPECTRUMSTARTER,
	rank1 = VOCATIONID_SPECTRUMVIPER,
	rank2 = VOCATIONID_SPECTRUMGAS,
	rank3 = VOCATIONID_SPECTRUMASSASSIN,
	rank4 = VOCATIONID_SPECTRUMVENOM,
	rank5 = VOCATIONID_SPECTRUMVIRUS
},
["heremit5"] = {cost = 80, npc = "Reana", style = "mastery_5", cla = MASTERYID_HEREMIT, 
	rank0 = VOCATIONID_HEREMITSTARTER,
	rank1 = VOCATIONID_HEREMITMINER,
	rank2 = VOCATIONID_HEREMITGUARD,
	rank3 = VOCATIONID_HEREMITTOMB,
	rank4 = VOCATIONID_HEREMITEARTHQUAKE,
	rank5 = VOCATIONID_HEREMITEDGE
},
["zen5"] = {cost = 80, npc = "Luka", style = "mastery_5", cla = MASTERYID_ZEN, 
	rank0 = VOCATIONID_ZENSTARTER,
	rank1 = VOCATIONID_ZENAMNESIA,
	rank2 = VOCATIONID_ZENTELEPATIC,
	rank3 = VOCATIONID_ZENKINESIS,
	rank4 = VOCATIONID_ZENINTELLECT,
	rank5 = VOCATIONID_ZENLUNAR
},
["voltagic5"] = {cost = 80, npc = "West", style = "mastery_5", cla = MASTERYID_VOLTAGIC, 
	rank0 = VOCATIONID_VOLTAGICSTARTER,
	rank1 = VOCATIONID_VOLTAGICSPARK,
	rank2 = VOCATIONID_VOLTAGICCHARGE,
	rank3 = VOCATIONID_VOLTAGICSTRIKE,
	rank4 = VOCATIONID_VOLTAGICBOLT,
	rank5 = VOCATIONID_VOLTAGICRISE
},
["blaze5"] = {cost = 80, npc = "", style = "mastery_5", cla = MASTERYID_BLAZE, 
	rank0 = VOCATIONID_BLAZESTARTER,
	rank1 = VOCATIONID_BLAZEEMBER,
	rank2 = VOCATIONID_BLAZEBURST,
	rank3 = VOCATIONID_BLAZEFLARE,
	rank4 = VOCATIONID_BLAZESTORM,
	rank5 = VOCATIONID_BLAZEINFERNO
},
["hurricane5"] = {cost = 80, npc = "Ilan", style = "mastery_5", cla = MASTERYID_HURRICANE, 
	rank0 = VOCATIONID_HURRICANESTARTER,
	rank1 = VOCATIONID_HURRICANEWIND,
	rank2 = VOCATIONID_HURRICANEGALE,
	rank3 = VOCATIONID_HURRICANEACE,
	rank4 = VOCATIONID_HURRICANETWISTER,
	rank5 = VOCATIONID_HURRICANETORNADO
},
["vital5"] = {cost = 80, npc = "Ceazar", style = "mastery_5", cla = MASTERYID_VITAL, 
	rank0 = VOCATIONID_VITALSTARTER,
	rank1 = VOCATIONID_VITALPACIFIC,
	rank2 = VOCATIONID_VITALADEPT,
	rank3 = VOCATIONID_VITALCOMBAT,
	rank4 = VOCATIONID_VITALSMASHER,
	rank5 = VOCATIONID_VITALRAGE
},

["gaia1"] = {cost = 60, npc = "Enzo", style = "mastery_1", cla = MASTERYID_GAIA, 
	rank0 = VOCATIONID_GAIASTARTER,
	rank1 = VOCATIONID_GAIAFOREST
},
["avalanche1"] = {cost = 60, npc = "Bronson", style = "mastery_1", cla = MASTERYID_AVALANCHE,
	rank0 = VOCATIONID_AVALANCHESTARTER, 
	rank1 = VOCATIONID_AVALANCHECOLDHEART
},
["spectrum1"] = {cost = 60, npc = "Roxy", style = "mastery_1", cla = MASTERYID_SPECTRUM, 
	rank0 = VOCATIONID_SPECTRUMSTARTER,
	rank1 = VOCATIONID_SPECTRUMVIPER
},
["heremit1"] = {cost = 60, npc = "Reana", style = "mastery_1", cla = MASTERYID_HEREMIT, 
	rank0 = VOCATIONID_HEREMITSTARTER,
	rank1 = VOCATIONID_HEREMITMINER
},
["zen1"] = {cost = 60, npc = "Luka", style = "mastery_1", cla = MASTERYID_ZEN, 
	rank0 = VOCATIONID_ZENSTARTER,
	rank1 = VOCATIONID_ZENAMNESIA
},
["voltagic1"] = {cost = 60, npc = "West", style = "mastery_1", cla = MASTERYID_VOLTAGIC, 
	rank0 = VOCATIONID_VOLTAGICSTARTER,
	rank1 = VOCATIONID_VOLTAGICSPARK
},
["blaze1"] = {cost = 60, npc = "", style = "mastery_1", cla = MASTERYID_BLAZE, 
	rank0 = VOCATIONID_BLAZESTARTER,
	rank1 = VOCATIONID_BLAZEEMBER
},
["hurricane1"] = {cost = 60, npc = "Ilan", style = "mastery_1", cla = MASTERYID_HURRICANE, 
	rank0 = VOCATIONID_HURRICANESTARTER,
	rank1 = VOCATIONID_HURRICANEWIND
},
["vital1"] = {cost = 60, npc = "Ceazar", style = "mastery_1", cla = MASTERYID_VITAL, 
	rank0 = VOCATIONID_VITALSTARTER,
	rank1 = VOCATIONID_VITALPACIFIC
},

}

	local cfg = config[param]
	if not cfg then return false end
	
	local ItemName = getItemNameById(cfg.add)
	
	local mastery = getPlayerMastery(cid)

	if getPlayerItemCount(cid, 34524) >= cfg.cost then
	
		if not isPremium(cid) then
			local response = {value = "NoVipClas"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
			return true
		end
		
		if getPlayerLevel(cid) < getMasteryRequiredLevel(cfg.cla) then
			local response = {value = "NoReqLevelClas"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
			return true
		end
	
		if mastery then
            doPlayerMasteryReset(cid, mastery)
        end
	
		if cfg.style == "mastery_5" then

            setPlayerMasteryRank(cid, cfg.cla, cfg.rank0)
            setPlayerMasteryRank(cid, cfg.cla, cfg.rank1)
            setPlayerMasteryRank(cid, cfg.cla, cfg.rank2)
            setPlayerMasteryRank(cid, cfg.cla, cfg.rank3)
            setPlayerMasteryRank(cid, cfg.cla, cfg.rank4)
            setPlayerMasteryRank(cid, cfg.cla, cfg.rank5)
			
			local response = {value = "ClaBuySucess"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "mastery_1" then
            setPlayerMasteryRank(cid, cfg.cla, cfg.rank0)
            setPlayerMasteryRank(cid, cfg.cla, cfg.rank1)
		
			local response = {value = "ClaBuySucess"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		end

		doPlayerRemoveItem(cid, 34524, cfg.cost)
		doSendMagicEffect(getCreaturePosition(cid), 1143)
		doSendShopRent(cid)
	else
	doSendMagicEffect(getCreaturePosition(cid), 1142)
    local response = {value = "nodiamond"}
    doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
	
	doSendShopRent(cid)
		return true
	end
	
	return true
end
