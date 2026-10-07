lastTimeSearch = 0

marketOffers = { -- Name/diamond value/PokeCoin Value/
-- MERCADO
[1] = {'ditto', 15, 30},
[2] = {'shinyditto', 150, 300},
[3] = {'bless', 2, 4},
[4] = {'blessplus', 5, 10},
[5] = {'blessultra', 8, 16},
[6] = {'particle', 10, 20},
[7] = {'sexo', 5, 10},
[8] = {'name', 25, 50},
[9] = {'resetprofission', 100, 200},
[10] = {'city', 2, 4},
[11] = {'stamina', 5, 10},

[12] = {'vip30', 10, 20},
[13] = {'vip60', 18, 36},
[14] = {'vip90', 25, 50},

[15] = {'pallet', 2, 4},
[16] = {'viridian', 2, 4},
[17] = {'pewter', 2, 4},
[18] = {'cerulean', 2, 4},
[19] = {'vermilion', 2, 4},
[20] = {'lavender', 2, 4},
[21] = {'celadon', 2, 4},
[22] = {'fuchsia', 2, 4},
[23] = {'saffron', 2, 4},
[24] = {'cinnabar', 2, 4},

-- ROUPAS

[25] = {'ashketchum', 8, 16},
[26] = {'brock', 8, 16},
[27] = {'stevenstone', 8, 16},
[28] = {'ritchie', 8, 16},
[29] = {'traceysketchit', 8, 16},
[30] = {'bruno', 8, 16},
[31] = {'james', 8, 16},
[32] = {'butch', 8, 16},
[33] = {'lycanroccosplay', 8, 16},
[34] = {'jolteoncosplay', 8, 16},
[35] = {'vaporeoncosplay', 8, 16},
[36] = {'umbreoncosplay', 8, 16},
[37] = {'luxraycosplay', 12, 24},
[38] = {'venusaurcosplay', 8, 16},
[39] = {'blastoisecosplay', 8, 16},
[40] = {'charizardcosplay', 8, 16},
[41] = {'gengarcosplay', 8, 16},
[42] = {'exterminadordedemonios', 10, 20},
[43] = {'blueexorcist', 12, 24},
[44] = {'homemdeferro', 12, 24},
[45] = {'tonystark', 10, 20},
[46] = {'jigsawtriciclo', 15, 30},
[47] = {'reidonorte', 15, 30},
[48] = {'coringa', 10, 20},
[49] = {'deadpool', 8, 16},
[50] = {'aforma', 8, 16},
[51] = {'bruxo', 10, 20},
[52] = {'cirurgiaodamorte', 10, 20},
[53] = {'cozinheiro', 10, 20},
[54] = {'donquixotedoflamingo', 10, 20},
[55] = {'fantasym', 8, 16},
[56] = {'chefjacquin', 15, 30},
[57] = {'debonairjacquin', 15, 30},
[58] = {'gangsterjacquin', 15, 30},
[59] = {'doutor', 8, 16},
[60] = {'guitarrista', 8, 16},
[61] = {'inquilino', 12, 24},
[62] = {'halloween', 8, 16},
[63] = {'jigsaw', 15, 30},
[64] = {'ladoescuro', 8, 16},
[65] = {'palhaco', 12, 24},
[66] = {'panico', 12, 24},
[67] = {'ninjamascarado', 8, 16},
[68] = {'tutankhamoak', 15, 30},
[69] = {'ordemlugiaaprendizm', 15, 30},
[70] = {'ordemlugiaguardiao', 15, 30},
[71] = {'treinadorcampeao1', 10, 20},
[72] = {'treinadorcampeao2', 10, 20},
[73] = {'modelom', 12, 24},
[74] = {'motociclista1', 12, 24},
[75] = {'motociclista2', 12, 24},
[76] = {'motociclista3', 12, 24},
[77] = {'motociclista4', 12, 24},
[78] = {'padre', 12, 24},
[79] = {'aventureiro', 8, 16},
[80] = {'barman', 10, 20},
[81] = {'chefe', 10, 20},
[82] = {'fraternidadem', 8, 16},
[83] = {'hacker', 8, 16},
[84] = {'hippie', 8, 16},
[85] = {'mestredekarate', 8, 16},
[86] = {'karate', 8, 16},
[87] = {'lutadorderua', 10, 20},
[88] = {'mecanico', 8, 16},
[89] = {'pascoadeourom', 10, 20},
[90] = {'pokemasterm', 8, 16},
[91] = {'treinador', 8, 16},
[92] = {'treinadorespecial', 10, 20},
[93] = {'treinadorfitness', 10, 20},
[94] = {'vampiro', 15, 30},
[95] = {'viajantem', 8, 16},
[96] = {'vinganca', 8, 16},

-- ROUPAS FEMININAS

[97] = {'misty', 8, 16},
[98] = {'oficialjenny', 8, 16},
[99] = {'jessie', 8, 16},
[100] = {'cassidy', 8, 16},
[101] = {'harleyquinn', 15, 30},
[102] = {'pikachucosplay', 8, 16},
[103] = {'azumarillcosplay', 8, 16},
[104] = {'flareoncosplay', 8, 16},
[105] = {'glaceoncosplay', 8, 16},
[106] = {'meowthcosplay', 8, 16},
[107] = {'persiancosplay', 8, 16},
[108] = {'ninetalescosplay', 8, 16},
[109] = {'princesadasfadas', 12, 24},
[110] = {'rainhadasfadas', 15, 30},
[111] = {'sylveoncosplay', 12, 24},
[112] = {'melody', 8, 16},
[113] = {'oninezuko', 12, 24},
[114] = {'raposadenovecaldas', 15, 30},
[115] = {'adolescente', 8, 16},
[116] = {'cleopatra', 15, 30},
[117] = {'cynthia', 12, 24},
[118] = {'ensolarado', 8, 16},
[119] = {'fantasyf', 8, 16},
[120] = {'lutadoraoriental', 8, 16},
[121] = {'bruxa', 10, 20},
[122] = {'capetinha', 8, 16},
[123] = {'fantasma', 8, 16},
[124] = {'garotasupervila', 10, 20},
[125] = {'maedosdragoes', 15, 30},
[126] = {'ordemlugiaaprendizf', 15, 30},
[127] = {'assassina', 8, 16},
[128] = {'atriz', 8, 16},
[129] = {'bellaflorida', 8, 16},
[130] = {'coelhinha', 8, 16},
[131] = {'exploradora', 8, 16},
[132] = {'fraternidadef', 8, 16},
[133] = {'garotapossuida', 10, 20},
[134] = {'longcape', 8, 16},
[135] = {'mecanica', 8, 16},
[136] = {'modelo', 12, 24},
[137] = {'morceguinha', 10, 20},
[138] = {'pascoadeourof', 10, 20},
[139] = {'princesa', 8, 16},
[140] = {'meninadaescola', 8, 16},
[141] = {'motociclista', 8, 16},
[142] = {'playmate', 10, 20},
[143] = {'pokemasterf', 8, 16},
[144] = {'popstar', 12, 24},
[145] = {'topdebiquini', 8, 16},
[146] = {'treinadora', 8, 16},
[147] = {'treinadoraespecial', 8, 16},
[148] = {'treinadorafitness', 8, 16},
[149] = {'vaqueira', 8, 16},
[150] = {'viajantef', 8, 16},
[151] = {'senhorapirata', 8, 16},
[152] = {'rua', 8, 16},

-- ROUPAS DUPLAS
[153] = {'hotdog', 10, 20},


-- ADDONS
[154] = {'ancient', 10, 20},
[155] = {'armorcore', 20, 40},
[156] = {'battlearmor', 15, 30},
[157] = {'bearcostume', 12, 24},
[158] = {'blackadamcostume', 20, 40},
[159] = {'blueflamesmage', 15, 30},
[160] = {'cowboycostume', 8, 16},
[161] = {'cyborgarmor1', 12, 24},
[162] = {'cyborgarmor2', 12, 24},
[163] = {'cyborgarmor3', 12, 24},
[164] = {'cyborgarmor4', 12, 24},
[165] = {'cyborgarmor5', 12, 24},
[166] = {'cyborgarmor6', 12, 24},
[167] = {'deathunicorn', 10, 20},
[168] = {'death', 10, 20},
[169] = {'definitelynotmagikarp', 20, 40},
[170] = {'djcostume', 12, 24},
[171] = {'firemage', 15, 30},
[172] = {'flinstone', 12, 24},
[173] = {'genius', 20, 40},
[174] = {'guard', 12, 24},
[175] = {'guardianarmor', 10, 20},
[176] = {'icebearcostume', 12, 24},
[177] = {'lancesclothes', 20, 40},
[178] = {'leonciocostume', 12, 24},
[179] = {'malevolacostume', 15, 30},
[180] = {'mariocostume', 12, 24},
[181] = {'metalarmor', 10, 20},
[182] = {'peakyblinderscostume1', 10, 20},
[183] = {'peakyblinderscostume2', 10, 20},
[184] = {'pegasuscostume', 15, 30},
[185] = {'robotunicorn', 10, 20},
[186] = {'rockstar', 12, 24},
[187] = {'serpentarmor', 25, 50},
[188] = {'shazamcostume', 20, 40},
[189] = {'thorcostume', 15, 30},
[190] = {'tropicalcostume', 12, 24},
[191] = {'wordchampionrobe', 15, 30},
[192] = {'yakuzacostume', 15, 30},
[193] = {'adventurouspirate', 15, 30},
[194] = {'wonderwoman', 15, 30},
[195] = {'ryujincostume', 25, 50},
[196] = {'girlpower', 15, 30},
[197] = {'pufferfishcostume', 12, 24},
[198] = {'happyoctopuscostume', 12, 24},
[199] = {'octopuscostume', 12, 24},
[200] = {'flashcostume', 10, 20},
[201] = {'cyborgarmor7', 12, 24},

-- ADDONS SHINY
[202] = {'millenniuminspiration', 15, 30},
[203] = {'supremedeity', 20, 40},
[204] = {'blackraven', 15, 30},
[205] = {'diamondfury', 20, 40},
[206] = {'aldebarancostume', 20, 40},
[207] = {'babykurama', 15, 30},
[208] = {'shinycyborgarmor1', 12, 24},
[209] = {'shinycyborgarmor2', 12, 24},
[210] = {'shinycyborgarmor3', 12, 24},
[211] = {'shinycyborgarmor4', 12, 24},
[212] = {'shinycyborgarmor5', 12, 24},
[213] = {'shinycyborgarmor6', 12, 24},
[214] = {'deathcostume', 10, 20},
[215] = {'demoncostume', 10, 20},
[216] = {'angelcostume', 10, 20},
[217] = {'jigsawcostume', 10, 20},
[218] = {'jokercostume', 10, 20},
[219] = {'thornarmor', 10, 20},
[220] = {'shinymetalarmor1', 10, 20},
[221] = {'shinymetalarmor2', 10, 20},
[222] = {'shinymetalarmor3', 10, 20},
[223] = {'shinymetalarmor4', 10, 20},
[224] = {'shinymetalarmor5', 10, 20},
[225] = {'terminator', 20, 40},
[226] = {'reggaecostume', 10, 20},
[227] = {'matlachines', 10, 20},
[228] = {'vampirecostume1', 12, 24},
[229] = {'vampirecostume2', 12, 24},
[230] = {'witchcostume1', 12, 24},
[231] = {'paniccostume', 12, 24},
[232] = {'werewolfcostume', 10, 20},
[233] = {'zombiecostume', 8, 16},
[234] = {'deathskull', 10, 20},
[235] = {'alphawerewolfcostume', 10, 20},
[236] = {'jasoncostume', 12, 24},
[237] = {'batmancostume', 12, 24},
[238] = {'shinycowboycostume', 12, 24},
[239] = {'bonearmor', 12, 24},
[240] = {'anbumask', 12, 24},
[241] = {'witchcostume2', 12, 24},
[242] = {'bridecostume', 12, 24},
[243] = {'bearcoat', 10, 20},
[244] = {'enjoyingsummer1', 17, 34},
[245] = {'enjoyingsummer2', 17, 34},
[246] = {'moonfairy', 20, 40},
[247] = {'kyubimoncostume', 20, 40},
[248] = {'ahriatari', 20, 40},
[249] = {'kuramaasura', 20, 40},
[250] = {'greymoncostume', 15, 30},
[251] = {'cavegladiator', 15, 30},
[252] = {'gabumoncostume', 15, 30},
[253] = {'dreggmancostume', 15, 30},
[254] = {'killercloak', 15, 30},

-- DEPOTS
[255] = {'LycanrocDepot', 20, 40},
[256] = {'AlolanVulpixDepot', 20, 40},
[257] = {'SlurpuffDepot', 20, 40},
[258] = {'ComfeyDepot', 20, 40},
[259] = {'GliscorDepot', 20, 40},
[260] = {'LaprasDepot', 20, 40},
[261] = {'GauntletDepot', 20, 40},
[262] = {'HoHoDepot', 20, 40},
[263] = {'PrimarinaDepot', 20, 40},
[264] = {'IncineroarDepot', 20, 40},
[265] = {'LucarioDepot', 20, 40},
[266] = {'LugiaDepot', 20, 40},
[267] = {'LunalaDepot', 20, 40},
[268] = {'StarDepot', 20, 40},
[269] = {'SolgaleoDepot', 20, 40},
[270] = {'VespiquenDepot', 20, 40},
[271] = {'MimikyuDepot', 20, 40},
[272] = {'MismagiusDepot', 20, 40},
[273] = {'MoltresDepot', 20, 40},
[274] = {'ZapdosDepot', 20, 40},
[275] = {'ArticunoDepot', 20, 40},
[276] = {'RaikoDepot', 20, 40},
[277] = {'SuicuneDepot', 20, 40},
[278] = {'EnteiDepot', 20, 40},
[279] = {'MewDepot', 20, 40},
[280] = {'MewthoDepot', 20, 40},
[281] = {'UmbreonDepot', 20, 40},
[282] = {'FlareonDepot', 20, 40},
[283] = {'VaporeonDepot', 20, 40},
[284] = {'JolteonDepot', 20, 40},
[285] = {'ShinyUmbreonDepot', 20, 40},
[286] = {'ChandelureDepot', 20, 40},
[287] = {'MegaBanneteDepot', 20, 40},
[288] = {'HypnoDepot', 20, 40},
[289] = {'NinetalesDepot', 20, 40},
[290] = {'MegaBlastoiseDepot', 20, 40},
[291] = {'ShinyCharizardDepot', 20, 40},
[292] = {'MegaCharizardXDepot', 20, 40},
[293] = {'MegaCharizardYDepot', 20, 40},
[294] = {'MegaVenusaurDepot', 20, 40},
[295] = {'GyaradosDepot', 20, 40},
[296] = {'ShinyGyaradosDepot', 20, 40},
[297] = {'MegaGyaradosDepot', 20, 40},
[298] = {'MetagrossDepot', 20, 40},
[299] = {'ShinyMegaMetagrossDepot', 20, 40},
[300] = {'RoseradeDepot', 20, 40},
[301] = {'BudewDepot', 20, 40},
[302] = {'ShinyMegaGardevoirDepot', 20, 40},
[303] = {'ShinyMegaGalladeDepot', 20, 40},

[304] = {'RayquazaDepot', 12, 24},
[305] = {'GroudonDepot', 12, 24},
[306] = {'KyogreDepot', 12, 24},
[307] = {'DetetivePikachuDepot', 12, 24},
[308] = {'PrimeapeDepot', 12, 24},
[309] = {'ArcanineDepot', 12, 24},
[310] = {'AerodactylDepot', 12, 24},
[311] = {'BlastoiseDepot', 12, 24},
[312] = {'ShinyBlastoiseDepot', 12, 24},
[313] = {'VenusaurDepot', 12, 24},
[314] = {'ShinyVenusaurDepot', 12, 24},
[315] = {'kecleonDepot', 12, 24},
[316] = {'MarshadowDepot', 12, 24},
[317] = {'ZoroarkDepot', 12, 24},
[318] = {'SylveonDepot', 12, 24},
[319] = {'AbsolDepot', 12, 24},
[320] = {'AggronDepot', 12, 24},
[321] = {'CelebiDepot', 12, 24},
[322] = {'ElectivireDepot', 12, 24},
[323] = {'GardevoirDepot', 12, 24},
[324] = {'GengarDepot', 12, 24},
[325] = {'InfernapeDepot', 12, 24},
[326] = {'WitchJinxDepot', 12, 24},
[327] = {'KangaskhanDepot', 12, 24},
[328] = {'RhydonDepot', 12, 24},
[329] = {'SceptileDepot', 12, 24},
[330] = {'DragonairDepot', 12, 24},

-- DECORAÇÕES
[331] = {'lumineonaquarium', 7, 14},
[332] = {'luvdiscaquarium', 7, 14},
[333] = {'shinyluvdiscaquarium', 7, 14},
[334] = {'vaporeonaquarium', 7, 14},
[335] = {'luvdiscaquarium2', 7, 14},
[336] = {'goldeenaquarium', 7, 14},
[337] = {'magikarpaquarium', 7, 14},
[338] = {'magictable', 12, 24},
[339] = {'tentaclechair', 5, 10},
[341] = {'videogametable1', 5, 10},
[342] = {'videogametable2', 5, 10},
[343] = {'videogametable3', 5, 10},
[344] = {'videogametable4', 5, 10},

[345] = {'electrabuzzsculpture', 7, 14},
[346] = {'charizardsculpture', 7, 14},
[347] = {'laprassculpture', 7, 14},
[348] = {'gyaradossculpture', 7, 14},
[349] = {'venusaursculpture', 7, 14},
[350] = {'steelixsculpture', 7, 14},
[351] = {'gastlysculpture', 7, 14},
[352] = {'hauntersculpture', 7, 14},
[353] = {'primeapesculpture', 7, 14},
[354] = {'curtainofhearts', 7, 14},
[355] = {'curtainofmewtwo', 7, 14},
[356] = {'curtainofblastoise', 7, 14},
[357] = {'curtainofvenusaur', 7, 14},
[358] = {'curtainofcharizard', 7, 14},
[359] = {'curtainofmisdreavus', 7, 14},
[360] = {'curtainofgolem', 7, 14},
[361] = {'curtainofdragonite', 7, 14},
[362] = {'scarypicture', 12, 24},

[363] = {'greenaltar', 5, 10},
[364] = {'pinkaltar', 5, 10},
[365] = {'yellowaltar', 5, 10},
[366] = {'pinkaltar2', 5, 10},
[367] = {'plant1', 5, 10},
[368] = {'plant2', 7, 14},
[369] = {'pinkrose', 5, 10},
[370] = {'redrose', 5, 10},
[371] = {'treesprout', 5, 10},
[372] = {'plant3', 5, 10},

[373] = {'computergamer', 15, 30},
[374] = {'guitar', 15, 30},

[375] = {'coachsgauntlet', 15, 30},
[376] = {'premieraltar', 20, 40},

-- [340] = {'tentaclechair', 5, 10}, -- usar quando for add algo dps

-- MERCADO
}

function init()
  shopWindow = g_ui.displayUI('shop')
  shopWindow:hide()
  
  shopTabBar = shopWindow:getChildById('shopTabBar')
  shopTabBar:setContentWidget(shopWindow:getChildById('shopTabContent'))

  promocaoPanel = g_ui.loadUI('promocao')
  shopTabBar:addTab(tr(''), promocaoPanel, '/modules/game_shop/images/shoptabs/promocao')

  mercadoPanel = g_ui.loadUI('mercado')
  shopTabBar:addTab(tr(''), mercadoPanel, '/modules/game_shop/images/shoptabs/mercado')

  roupasPanel = g_ui.loadUI('roupas')
  shopTabBar:addTab(tr(''), roupasPanel, '/modules/game_shop/images/shoptabs/roupas')

  addonsPanel = g_ui.loadUI('addons')
  shopTabBar:addTab(tr(''), addonsPanel, '/modules/game_shop/images/shoptabs/addons')

  decoracoesPanel = g_ui.loadUI('decoracoes')
  shopTabBar:addTab(tr(''), decoracoesPanel, '/modules/game_shop/images/shoptabs/decoracoes')

  clansPanel = g_ui.loadUI('clas')
  shopTabBar:addTab(tr(''), clansPanel, '/modules/game_shop/images/shoptabs/clas')

  PanelSelectedClas = clansPanel:getChildById("PanelSelectedClas")
  ClasListPanel = clansPanel:getChildById("ClasListPanel")
  ClasListScrollBar = clansPanel:getChildById("ClasListScrollBar")
  --BigPanel
  BackgroundCla = PanelSelectedClas:getChildById("Background")
  TitleCla = clansPanel:getChildById("TitleClas")
  TitleBig = PanelSelectedClas:getChildById("Title")
  Descricao = PanelSelectedClas:getChildById("BigWindow"):getChildById("Text_desc")
  TypeSolo = PanelSelectedClas:getChildById("BigWindow"):getChildById("Type_Solo")
  TypeFirst = PanelSelectedClas:getChildById("BigWindow"):getChildById("Type_First")
  TypeSecond = PanelSelectedClas:getChildById("BigWindow"):getChildById("Type_Second")
  -- SmallPanelFirst
  ClaIcon5 = PanelSelectedClas:getChildById("SmallWindow_First"):getChildById("Cla_icon")
  ClaName5 = PanelSelectedClas:getChildById("SmallWindow_First"):getChildById("Cla_RankName")
  -- SmallPanelSecond
  ClaIcon1 = PanelSelectedClas:getChildById("SmallWindow_Second"):getChildById("Cla_icon")
  ClaName1 = PanelSelectedClas:getChildById("SmallWindow_Second"):getChildById("Cla_RankName")
  
  BuyButton5 = PanelSelectedClas:getChildById("SmallWindow_First")
  BuyButton1 = PanelSelectedClas:getChildById("SmallWindow_Second")

  ProtocolGame.registerExtendedOpcode(27, onExtendedOpcode)
end

function terminate()
  shopWindow:destroy()
  ProtocolGame.unregisterExtendedOpcode(27, onExtendedOpcode)
end

function onExtendedOpcode(protocol, code, buffer)
  local json_status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )

  if not json_status then
    g_logger.error("[My Module] JSON error: " .. json_data)
    return false
  end

  if json_data.value == "purchased" then
      CompradoWindow()
  elseif json_data.value == "nodiamond" then
      NoDiamondWindow()
  elseif json_data.value == "noactive" then
	  NaoDisponivelWindow()
  elseif json_data.value == "nopokecoin" then
	  NoPokeCoinWindow()
  elseif json_data.value == "sexbuy" then
	  CompradoWindowReset()
  elseif json_data.value == "NameReset" then
	  ReloadPersonagem()
  elseif json_data.value == "NameComand" then
	g_effects.fadeIn(shopWindow:getChildById("WindowSelectedName"):getChildById("Text"), 250)
	shopWindow:getChildById("WindowSelectedName"):getChildById("Text"):setImageSource('images/alert/texto/'..json_data.text.str)
	scheduleEvent(function() g_effects.fadeOut(shopWindow:getChildById("WindowSelectedName"):getChildById("Text"), 250) end, 10000)
  elseif json_data.value == "GoldRent" then
	shopWindow:getChildById("diamondvalue"):setText(json_data.Drent)
	shopWindow:getChildById("pokecoinvalue"):setText(json_data.Prent)
  elseif json_data.value == "OpenShop" then
    show()
	shopWindow:getChildById("diamondvalue"):setText(json_data.Drent)
	shopWindow:getChildById("pokecoinvalue"):setText(json_data.Prent)
  elseif json_data.value == "NoVipClas" then
	NoVipWindow()
  elseif json_data.value == "NoReqLevelClas" then
	NoReqLevelWindow()
  elseif json_data.value == "ClaBuySucess" then
	BuyClanSucessWindow()
  end
end

function onTextChangeDiamond(self)
	if lastTimeSearch > os.time() then
		return false
	end

	local text = self:getText()
	
	if tostring(text) and tostring(text) ~= "" then
		g_game.talk("/namediamond "..text)
	else
	    g_effects.fadeIn(shopWindow:getChildById("WindowSelectedName"):getChildById("Text"), 250)
	    shopWindow:getChildById("WindowSelectedName"):getChildById("Text"):setImageSource('images/alert/texto/error/semnome')
		scheduleEvent(function() g_effects.fadeOut(shopWindow:getChildById("WindowSelectedName"):getChildById("Text"), 250) end, 10000)
	end
	lastTimeSearch = os.time()+2
end

function onTextChangePokecoin(self)
	if lastTimeSearch > os.time() then
		return false
	end

	local text = self:getText()
	
	if tostring(text) and tostring(text) ~= "" then
		g_game.talk("/namepokecoin "..text)
	else
	    g_effects.fadeIn(shopWindow:getChildById("WindowSelectedName"):getChildById("Text"), 250)
	    shopWindow:getChildById("WindowSelectedName"):getChildById("Text"):setImageSource('images/alert/texto/error/semnome')
		scheduleEvent(function() g_effects.fadeOut(shopWindow:getChildById("WindowSelectedName"):getChildById("Text"), 250) end, 10000)
	end
	lastTimeSearch = os.time()+2
end

function toggle()
  if shopWindow:isVisible() then
    hide()
  else
    show()
  end
end

function show()
  slide1()
  Prateleira1()
  doReturnSelection()
  shopWindow:show()
  shopWindow:raise()
  shopWindow:focus()
  shopWindow:getChildById("closeButton").onClick = function() hide() end
  lastTimeSearch = os.time()+2
end
function ReloadPersonagem()
  closeslide()
  hide()
  modules.game_interface.ReloadCharacter()
end

function hideMiniWindow()
  shopWindow:getChildById("WindowSelectBuy"):hide()
  shopWindow:getChildById("WindowSelected"):hide()
  shopWindow:getChildById("WindowAlert"):hide()
  shopWindow:getChildById("BackgroundBlack"):hide()
  shopWindow:getChildById("WindowSelectedName"):hide()
end

function hide()
  hideMiniWindow()
  closeslide()
  shopWindow:hide()
end

function addTab(name, panel, icon)
  shopTabBar:addTab(name, panel, icon)
end

function addButton(name, func, icon)
  shopTabBar:addButton(name, func, icon)
end

function cleartab()
	shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotItemBuy"):setImageSource('images/alert/cleaning')
	shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotOutfitBuy"):setImageSource('images/alert/cleaning')
	shopWindow:getChildById("WindowSelectBuy"):getChildById("SlotAddonBuy"):setImageSource('images/alert/cleaning')
	
	shopWindow:getChildById("WindowSelected"):getChildById("SlotItem"):setImageSource('images/alert/cleaning')
	shopWindow:getChildById("WindowSelected"):getChildById("SlotOutfit"):setImageSource('images/alert/cleaning')
	shopWindow:getChildById("WindowSelected"):getChildById("SlotAddonBuy"):setImageSource('images/alert/cleaning')
	
	shopWindow:getChildById("WindowSelectedName"):getChildById("SlotItem"):setImageSource('images/alert/cleaning')
end

--- ALERBWINDOW
function CompradoWindowReset()
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/reload") 
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#75ff45") 
	shopWindow:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/relogtobuy") 
	shopWindow:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() ReloadPersonagem() end 
	shopWindow:getChildById("closeButton").onClick = function() ReloadPersonagem() end
    shopWindow:getChildById("BackgroundBlack"):show()
	shopWindow:getChildById("WindowAlert"):show()
end

function NaoDisponivelWindow()
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/exclaming") shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") shopWindow:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/nao_disponivel") shopWindow:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end shopWindow:getChildById("WindowAlert"):show()
    shopWindow:getChildById("BackgroundBlack"):show()
end
function CompradoWindow()
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/money") shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#75ff45") shopWindow:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/comprei") shopWindow:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end shopWindow:getChildById("WindowAlert"):show()
    shopWindow:getChildById("BackgroundBlack"):show()
end
function NoDiamondWindow()
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/alert") shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") shopWindow:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/sem_diamante") shopWindow:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end shopWindow:getChildById("WindowAlert"):show()
    shopWindow:getChildById("BackgroundBlack"):show()
end
function NoPokeCoinWindow()
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/alert") shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") shopWindow:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/sem_pokecoin") shopWindow:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end shopWindow:getChildById("WindowAlert"):show()
    shopWindow:getChildById("BackgroundBlack"):show()
end
function NoVipWindow()
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/alert") shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") shopWindow:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/no_vip") shopWindow:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end shopWindow:getChildById("WindowAlert"):show()
    shopWindow:getChildById("BackgroundBlack"):show()
end
function NoReqLevelWindow()
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/alert") shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") shopWindow:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/no_level") shopWindow:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end shopWindow:getChildById("WindowAlert"):show()
    shopWindow:getChildById("BackgroundBlack"):show()
end
function BuyClanSucessWindow()
	shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/money") shopWindow:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#75ff45") shopWindow:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/buy_clan") shopWindow:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end shopWindow:getChildById("WindowAlert"):show()
    shopWindow:getChildById("BackgroundBlack"):show()
end

function HideAllPanelsDec()
	decoracoesPanel:getChildById("DepotListPanel"):hide()decoracoesPanel:getChildById("DepotListScrollBar"):hide()decoracoesPanel:getChildById("MobiliaListPanel"):hide()decoracoesPanel:getChildById("MobiliaListScrollBar"):hide()decoracoesPanel:getChildById("CortinaListPanel"):hide()decoracoesPanel:getChildById("CortinaListScrollBar"):hide()decoracoesPanel:getChildById("EletronicoListPanel"):hide()decoracoesPanel:getChildById("EletronicoListScrollBar"):hide()decoracoesPanel:getChildById("JardinagemListPanel"):hide()decoracoesPanel:getChildById("JardinagemListScrollBar"):hide()decoracoesPanel:getChildById("EstatuaListPanel"):hide()decoracoesPanel:getChildById("EstatuaListScrollBar"):hide()
	decoracoesPanel:getChildById("PanelDeposito"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionar")decoracoesPanel:getChildById("PanelMobilias"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionar")decoracoesPanel:getChildById("PanelCortina"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionar")decoracoesPanel:getChildById("PanelEletronico"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionar")decoracoesPanel:getChildById("PanelJardinagem"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionar")decoracoesPanel:getChildById("PanelEstatua"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionar")
end

-- FUNÇÕES PARA MOSTRAR PAINEIS DE DECORAÇÕES
function doShowDepositoPanel()
	HideAllPanelsDec()
	decoracoesPanel:getChildById("DepotListPanel"):show()
	decoracoesPanel:getChildById("DepotListScrollBar"):show()
	decoracoesPanel:getChildById("PanelDeposito"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionado")
	decoracoesPanel:getChildById("TitleList"):setImageSource("images/decoracoes/background/title/deposito")
end
function doShowMobiliaPanel()
	HideAllPanelsDec()
	decoracoesPanel:getChildById("MobiliaListPanel"):show()
	decoracoesPanel:getChildById("MobiliaListScrollBar"):show()
	decoracoesPanel:getChildById("PanelMobilias"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionado")
	decoracoesPanel:getChildById("TitleList"):setImageSource("images/decoracoes/background/title/mobilia")
end
function doShowCortinaPanel()
	HideAllPanelsDec()
	decoracoesPanel:getChildById("CortinaListPanel"):show()
	decoracoesPanel:getChildById("CortinaListScrollBar"):show()
	decoracoesPanel:getChildById("PanelCortina"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionado")
	decoracoesPanel:getChildById("TitleList"):setImageSource("images/decoracoes/background/title/cortina")
end
function doShowEletronicoPanel()
	HideAllPanelsDec()
	decoracoesPanel:getChildById("EletronicoListPanel"):show()
	decoracoesPanel:getChildById("EletronicoListScrollBar"):show()
	decoracoesPanel:getChildById("PanelEletronico"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionado")
	decoracoesPanel:getChildById("TitleList"):setImageSource("images/decoracoes/background/title/eletronico")
end
function doShowJardinagemPanel()
	HideAllPanelsDec()
	decoracoesPanel:getChildById("JardinagemListPanel"):show()
	decoracoesPanel:getChildById("JardinagemListScrollBar"):show()
	decoracoesPanel:getChildById("PanelJardinagem"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionado")
	decoracoesPanel:getChildById("TitleList"):setImageSource("images/decoracoes/background/title/jardinagem")
end
function doShowEstatuaPanel()
	HideAllPanelsDec()
	decoracoesPanel:getChildById("EstatuaListPanel"):show()
	decoracoesPanel:getChildById("EstatuaListScrollBar"):show()
	decoracoesPanel:getChildById("PanelEstatua"):getChildById("SelectButton"):setImageSource("images/decoracoes/background/selecionado")
	decoracoesPanel:getChildById("TitleList"):setImageSource("images/decoracoes/background/title/estatua")
end
-- FUNÇÕES PARA MOSTRAR PAINEIS DE DECORAÇÕES