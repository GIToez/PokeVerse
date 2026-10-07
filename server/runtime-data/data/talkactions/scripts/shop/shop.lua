function onSay(cid, words, param, channel)

local config = {
-- Sex --
["sexo"] = {cost = 5, add = 0, style = "sex"},
-- Profission --
["resetprofission"] = {cost = 100, add = 34600, count = 1, style = "item"},
-- Bless --
["bless"] = {cost = 2, add = "30", style = "bless"},
["blessplus"] = {cost = 5, add = "8", style = "bless"},
["blessultra"] = {cost = 8, add = "3", style = "bless"},
-- Vip --
["vip30"] = {cost = 10, add = 30, style = "vip"},
["vip60"] = {cost = 18, add = 60, style = "vip"},
["vip90"] = {cost = 25, add = 90, style = "vip"},
-- Pokemon --
["ditto"] = {cost = 15, add = "Ditto", count = 0, style = "pokemon"},
["shinyditto"] = {cost = 150, add = "Shiny Ditto", count = 0, style = "pokemon"},
-- Itens --
["stamina"] = {cost = 5, add = 13971, count = 1, style = "item"},
-- clas --
["Snorlax"] = {cost = 30, add = 19852, count = 20, style = "clas"},
-- City --
["pallet"] = {cost = 2, town = 32, style = "city"},
["viridian"] = {cost = 2, town = 1, style = "city"},
["pewter"] = {cost = 2, town = 2, style = "city"},
["cerulean"] = {cost = 2, town = 3, style = "city"},
["vermilion"] = {cost = 2, town = 6, style = "city"},
["lavender"] = {cost = 2, town = 7, style = "city"},
["celadon"] = {cost = 2, town = 5, style = "city"},
["fuchsia"] = {cost = 2, town = 8, style = "city"},
["saffron"] = {cost = 2, town = 4, style = "city"},
["cinnabar"] = {cost = 2, town = 9, style = "city"},
-- Outfit Itens --
["ashketchum"] = {cost = 8, outfitID = 34728, style = "outfit"},
["brock"] = {cost = 8, outfitID = 34676, style = "outfit"},
["stevenstone"] = {cost = 8, outfitID = 34709, style = "outfit"},
["ritchie"] = {cost = 8, outfitID = 34672, style = "outfit"},
["traceysketchit"] = {cost = 8, outfitID = 34677, style = "outfit"},
["bruno"] = {cost = 8, outfitID = 34659, style = "outfit"},
["james"] = {cost = 8, outfitID = 34652, style = "outfit"},
["butch"] = {cost = 8, outfitID = 34658, style = "outfit"},
["lycanroccosplay"] = {cost = 8, outfitID = 34717, style = "outfit"},
["jolteoncosplay"] = {cost = 8, outfitID = 34621, style = "outfit"},
["vaporeoncosplay"] = {cost = 8, outfitID = 34624, style = "outfit"},
["umbreoncosplay"] = {cost = 8, outfitID = 34607, style = "outfit"},
["luxraycosplay"] = {cost = 12, outfitID = 34601, style = "outfit"},
["venusaurcosplay"] = {cost = 8, outfitID = 34692, style = "outfit"},
["blastoisecosplay"] = {cost = 8, outfitID = 34691, style = "outfit"},
["charizardcosplay"] = {cost = 8, outfitID = 34687, style = "outfit"},
["gengarcosplay"] = {cost = 8, outfitID = 34693, style = "outfit"},
["exterminadordedemonios"] = {cost = 10, outfitID = 34620, style = "outfit"},
["blueexorcist"] = {cost = 12, outfitID = 34609, style = "outfit"},
["homemdeferro"] = {cost = 12, outfitID = 34628, style = "outfit"},
["tonystark"] = {cost = 10, outfitID = 34627, style = "outfit"},
["reidonorte"] = {cost = 15, outfitID = 34603, style = "outfit"},
["coringa"] = {cost = 10, outfitID = 34615, style = "outfit"},
["deadpool"] = {cost = 8, outfitID = 34629, style = "outfit"},
["aforma"] = {cost = 8, outfitID = 34618, style = "outfit"},
["bruxo"] = {cost = 10, outfitID = 34710, style = "outfit"},
["cirurgiaodamorte"] = {cost = 10, outfitID = 34680, style = "outfit"},
["cozinheiro"] = {cost = 10, outfitID = 34666, style = "outfit"},
["donquixotedoflamingo"] = {cost = 10, outfitID = 34699, style = "outfit"},
["fantasym"] = {cost = 8, outfitID = 34632, style = "outfit"},
["chefjacquin"] = {cost = 15, outfitID = 34605, style = "outfit"},
["debonairjacquin"] = {cost = 15, outfitID = 34604, style = "outfit"},
["gangsterjacquin"] = {cost = 15, outfitID = 34606, style = "outfit"},
["doutor"] = {cost = 8, outfitID = 34633, style = "outfit"},
["guitarrista"] = {cost = 8, outfitID = 34616, style = "outfit"},
["inquilino"] = {cost = 12, outfitID = 34635, style = "outfit"},
["halloween"] = {cost = 8, outfitID = 34665, style = "outfit"},
["jigsaw"] = {cost = 15, outfitID = 34610, style = "outfit"},
["ladoescuro"] = {cost = 8, outfitID = 34626, style = "outfit"},
["palhaco"] = {cost = 12, outfitID = 34705, style = "outfit"},
["panico"] = {cost = 12, outfitID = 34702, style = "outfit"},
["ninjamascarado"] = {cost = 8, outfitID = 34625, style = "outfit"},
["tutankhamoak"] = {cost = 15, outfitID = 34608, style = "outfit"},
["ordemlugiaaprendizm"] = {cost = 15, outfitID = 34670, style = "outfit"},
["ordemlugiaguardiao"] = {cost = 15, outfitID = 34669, style = "outfit"},
["treinadorcampeao1"] = {cost = 10, outfitID = 34721, style = "outfit"},
["treinadorcampeao2"] = {cost = 10, outfitID = 34727, style = "outfit"},
["modelom"] = {cost = 12, outfitID = 34683, style = "outfit"},
["motociclista1"] = {cost = 12, outfitID = 34716, style = "outfit"},
["motociclista2"] = {cost = 12, outfitID = 34673, style = "outfit"},
["motociclista3"] = {cost = 12, outfitID = 34675, style = "outfit"},
["motociclista4"] = {cost = 12, outfitID = 34674, style = "outfit"},
["padre"] = {cost = 12, outfitID = 34619, style = "outfit"},
["aventureiro"] = {cost = 8, outfitID = 34681, style = "outfit"},
["barman"] = {cost = 10, outfitID = 34725, style = "outfit"},
["chefe"] = {cost = 10, outfitID = 34685, style = "outfit"},
["fraternidadem"] = {cost = 8, outfitID = 34631, style = "outfit"},
["hacker"] = {cost = 8, outfitID = 34688, style = "outfit"},
["hippie"] = {cost = 8, outfitID = 34655, style = "outfit"},
["mestredekarate"] = {cost = 8, outfitID = 34686, style = "outfit"},
["karate"] = {cost = 8, outfitID = 34678, style = "outfit"},
["lutadorderua"] = {cost = 10, outfitID = 34695, style = "outfit"},
["mecanico"] = {cost = 8, outfitID = 34668, style = "outfit"},
["pascoadeourom"] = {cost = 10, outfitID = 34713, style = "outfit"},
["pokemasterm"] = {cost = 8, outfitID = 34630, style = "outfit"},
["treinador"] = {cost = 8, outfitID = 34617, style = "outfit"},
["treinadorespecial"] = {cost = 10, outfitID = 34622, style = "outfit"},
["treinadorfitness"] = {cost = 10, outfitID = 34718, style = "outfit"},
["vampiro"] = {cost = 15, outfitID = 34720, style = "outfit"},
["viajantem"] = {cost = 8, outfitID = 34715, style = "outfit"},
["vinganca"] = {cost = 8, outfitID = 34634, style = "outfit"},

["misty"] = {cost = 8, outfitID = 34654, style = "outfit"},
["oficialjenny"] = {cost = 8, outfitID = 34650, style = "outfit"},
["jessie"] = {cost = 8, outfitID = 34651, style = "outfit"},
["cassidy"] = {cost = 8, outfitID = 34657, style = "outfit"},
["harleyquinn"] = {cost = 15, outfitID = 34611, style = "outfit"},
["pikachucosplay"] = {cost = 8, outfitID = 34690, style = "outfit"},
["azumarillcosplay"] = {cost = 8, outfitID = 34697, style = "outfit"},
["flareoncosplay"] = {cost = 8, outfitID = 34643, style = "outfit"},
["glaceoncosplay"] = {cost = 8, outfitID = 34614, style = "outfit"},
["meowthcosplay"] = {cost = 8, outfitID = 34696, style = "outfit"},
["persiancosplay"] = {cost = 8, outfitID = 34723, style = "outfit"},
["ninetalescosplay"] = {cost = 8, outfitID = 34640, style = "outfit"},
["princesadasfadas"] = {cost = 12, outfitID = 34641, style = "outfit"},
["rainhadasfadas"] = {cost = 15, outfitID = 34613, style = "outfit"},
["sylveoncosplay"] = {cost = 12, outfitID = 34623, style = "outfit"},
["melody"] = {cost = 8, outfitID = 34660, style = "outfit"},
["oninezuko"] = {cost = 12, outfitID = 34639, style = "outfit"},
["raposadenovecaldas"] = {cost = 15, outfitID = 34729, style = "outfit"},
["adolescente"] = {cost = 8, outfitID = 34648, style = "outfit"},
["cleopatra"] = {cost = 15, outfitID = 34636, style = "outfit"},
["cynthia"] = {cost = 12, outfitID = 34708, style = "outfit"},
["ensolarado"] = {cost = 8, outfitID = 34706, style = "outfit"},
["fantasyf"] = {cost = 8, outfitID = 34646, style = "outfit"},
["lutadoraoriental"] = {cost = 8, outfitID = 34656, style = "outfit"},
["bruxa"] = {cost = 10, outfitID = 34711, style = "outfit"},
["capetinha"] = {cost = 8, outfitID = 34661, style = "outfit"},
["fantasma"] = {cost = 8, outfitID = 34664, style = "outfit"},
["garotasupervila"] = {cost = 10, outfitID = 34612, style = "outfit"},
["maedosdragoes"] = {cost = 15, outfitID = 34602, style = "outfit"},
["ordemlugiaaprendizf"] = {cost = 15, outfitID = 34671, style = "outfit"},
["assassina"] = {cost = 8, outfitID = 34704, style = "outfit"},
["atriz"] = {cost = 8, outfitID = 34724, style = "outfit"},
["bellaflorida"] = {cost = 8, outfitID = 34722, style = "outfit"},
["coelhinha"] = {cost = 8, outfitID = 34663, style = "outfit"},
["exploradora"] = {cost = 8, outfitID = 34649, style = "outfit"},
["fraternidadef"] = {cost = 8, outfitID = 34645, style = "outfit"},
["garotapossuida"] = {cost = 10, outfitID = 34638, style = "outfit"},
["longcape"] = {cost = 8, outfitID = 34689, style = "outfit"},
["mecanica"] = {cost = 8, outfitID = 34667, style = "outfit"},
["modelo"] = {cost = 12, outfitID = 34684, style = "outfit"},
["morceguinha"] = {cost = 10, outfitID = 34703, style = "outfit"},
["pascoadeourof"] = {cost = 10, outfitID = 34712, style = "outfit"},
["princesa"] = {cost = 8, outfitID = 34701, style = "outfit"},
["meninadaescola"] = {cost = 8, outfitID = 34700, style = "outfit"},
["motociclista"] = {cost = 8, outfitID = 34707, style = "outfit"},
["playmate"] = {cost = 10, outfitID = 34647, style = "outfit"},
["pokemasterf"] = {cost = 8, outfitID = 34644, style = "outfit"},
["popstar"] = {cost = 12, outfitID = 34719, style = "outfit"},
["topdebiquini"] = {cost = 8, outfitID = 34698, style = "outfit"},
["treinadora"] = {cost = 8, outfitID = 34637, style = "outfit"},
["treinadoraespecial"] = {cost = 8, outfitID = 34726, style = "outfit"},
["treinadorafitness"] = {cost = 8, outfitID = 34662, style = "outfit"},
["vaqueira"] = {cost = 8, outfitID = 34694, style = "outfit"},
["viajantef"] = {cost = 8, outfitID = 34714, style = "outfit"},
["senhorapirata"] = {cost = 8, outfitID = 34679, style = "outfit"},
["rua"] = {cost = 8, outfitID = 34730, style = "outfit"},

["hotdog"] = {cost = 10, outfitID = 34682, style = "outfit"},

-- Addons --
["ancient"] = {cost = 10, AddonID = 34778, style = "addons"},
["armorcore"] = {cost = 20, AddonID = 34779, style = "addons"},
["battlearmor"] = {cost = 15, AddonID = 34774, style = "addons"},
["bearcostume"] = {cost = 12, AddonID = 34772, style = "addons"},
["blackadamcostume"] = {cost = 20, AddonID = 34780, style = "addons"},
["blueflamesmage"] = {cost = 15, AddonID = 34782, style = "addons"},
["cowboycostume"] = {cost = 8, AddonID = 34776, style = "addons"},
["cyborgarmor1"] = {cost = 12, AddonID = 34784, style = "addons"},
["cyborgarmor2"] = {cost = 12, AddonID = 34785, style = "addons"},
["cyborgarmor3"] = {cost = 12, AddonID = 34786, style = "addons"},
["cyborgarmor4"] = {cost = 12, AddonID = 34812, style = "addons"},
["cyborgarmor5"] = {cost = 12, AddonID = 34787, style = "addons"},
["cyborgarmor6"] = {cost = 12, AddonID = 34788, style = "addons"},
["deathunicorn"] = {cost = 10, AddonID = 34817, style = "addons"},
["death"] = {cost = 10, AddonID = 34818, style = "addons"},
["definitelynotmagikarp"] = {cost = 20, AddonID = 34789, style = "addons"},
["djcostume"] = {cost = 12, AddonID = 34775, style = "addons"},
["firemage"] = {cost = 15, AddonID = 34783, style = "addons"},
["flinstone"] = {cost = 12, AddonID = 34791, style = "addons"},
["genius"] = {cost = 20, AddonID = 34792, style = "addons"},
["guard"] = {cost = 12, AddonID = 34794, style = "addons"},
["guardianarmor"] = {cost = 10, AddonID = 34795, style = "addons"},
["icebearcostume"] = {cost = 12, AddonID = 34773, style = "addons"},
["lancesclothes"] = {cost = 20, AddonID = 34797, style = "addons"},
["leonciocostume"] = {cost = 12, AddonID = 34771, style = "addons"},
["malevolacostume"] = {cost = 15, AddonID = 34798, style = "addons"},
["mariocostume"] = {cost = 24, AddonID = 34799, style = "addons"},
["metalarmor"] = {cost = 10, AddonID = 34814, style = "addons"},
["peakyblinderscostume1"] = {cost = 10, AddonID = 34801, style = "addons"},
["peakyblinderscostume2"] = {cost = 10, AddonID = 34802, style = "addons"},
["pegasuscostume"] = {cost = 15, AddonID = 34816, style = "addons"},
["robotunicorn"] = {cost = 10, AddonID = 34815, style = "addons"},
["rockstar"] = {cost = 12, AddonID = 34813, style = "addons"},
["serpentarmor"] = {cost = 25, AddonID = 34810, style = "addons"},
["shazamcostume"] = {cost = 20, AddonID = 34781, style = "addons"},
["thorcostume"] = {cost = 15, AddonID = 34808, style = "addons"},
["tropicalcostume"] = {cost = 12, AddonID = 34811, style = "addons"},
["wordchampionrobe"] = {cost = 15, AddonID = 34807, style = "addons"},
["yakuzacostume"] = {cost = 15, AddonID = 34805, style = "addons"},
["adventurouspirate"] = {cost = 15, AddonID = 34777, style = "addons"},
["wonderwoman"] = {cost = 15, AddonID = 34806, style = "addons"},
["ryujincostume"] = {cost = 25, AddonID = 34809, style = "addons"},
["girlpower"] = {cost = 15, AddonID = 34793, style = "addons"},
["pufferfishcostume"] = {cost = 12, AddonID = 34803, style = "addons"},
["happyoctopuscostume"] = {cost = 12, AddonID = 34796, style = "addons"},
["octopuscostume"] = {cost = 12, AddonID = 34800, style = "addons"},
["flashcostume"] = {cost = 10, AddonID = 34790, style = "addons"},
["cyborgarmor7"] = {cost = 12, AddonID = 34819, style = "addons"},

-- Addons Shiny --
["millenniuminspiration"] = {cost = 15, AddonID = 34872, style = "addons"},
["supremedeity"] = {cost = 20, AddonID = 34873, style = "addons"},
["blackraven"] = {cost = 15, AddonID = 34827, style = "addons"},
["diamondfury"] = {cost = 20, AddonID = 34864, style = "addons"},
["aldebarancostume"] = {cost = 20, AddonID = 34865, style = "addons"},
["babykurama"] = {cost = 15, AddonID = 34861, style = "addons"},
["shinycyborgarmor1"] = {cost = 12, AddonID = 34822, style = "addons"},
["shinycyborgarmor2"] = {cost = 12, AddonID = 34823, style = "addons"},
["shinycyborgarmor3"] = {cost = 12, AddonID = 34824, style = "addons"},
["shinycyborgarmor4"] = {cost = 12, AddonID = 34825, style = "addons"},
["shinycyborgarmor5"] = {cost = 12, AddonID = 34826, style = "addons"},
["shinycyborgarmor6"] = {cost = 12, AddonID = 34835, style = "addons"},
["deathcostume"] = {cost = 10, AddonID = 34832, style = "addons"},
["demoncostume"] = {cost = 10, AddonID = 34833, style = "addons"},
["angelcostume"] = {cost = 10, AddonID = 34834, style = "addons"},
["jigsawcostume"] = {cost = 10, AddonID = 34846, style = "addons"},
["jokercostume"] = {cost = 10, AddonID = 34874, style = "addons"},
["thornarmor"] = {cost = 10, AddonID = 34850, style = "addons"},
["shinymetalarmor1"] = {cost = 10, AddonID = 34830, style = "addons"},
["shinymetalarmor2"] = {cost = 10, AddonID = 34831, style = "addons"},
["shinymetalarmor3"] = {cost = 10, AddonID = 34847, style = "addons"},
["shinymetalarmor4"] = {cost = 10, AddonID = 34848, style = "addons"},
["shinymetalarmor5"] = {cost = 10, AddonID = 34849, style = "addons"},
["terminator"] = {cost = 20, AddonID = 34868, style = "addons"},
["reggaecostume"] = {cost = 10, AddonID = 34829, style = "addons"},
["matlachines"] = {cost = 10, AddonID = 34828, style = "addons"},
["vampirecostume1"] = {cost = 12, AddonID = 34836, style = "addons"},
["vampirecostume2"] = {cost = 12, AddonID = 34837, style = "addons"},
["witchcostume1"] = {cost = 12, AddonID = 34838, style = "addons"},
["paniccostume"] = {cost = 12, AddonID = 34839, style = "addons"},
["werewolfcostume"] = {cost = 10, AddonID = 34840, style = "addons"},
["zombiecostume"] = {cost = 8, AddonID = 34841, style = "addons"},
["deathskull"] = {cost = 10, AddonID = 34842, style = "addons"},
["alphawerewolfcostume"] = {cost = 10, AddonID = 34843, style = "addons"},
["jasoncostume"] = {cost = 12, AddonID = 34844, style = "addons"},
["batmancostume"] = {cost = 12, AddonID = 34845, style = "addons"},
["shinycowboycostume"] = {cost = 12, AddonID = 34851, style = "addons"},
["bonearmor"] = {cost = 12, AddonID = 34852, style = "addons"},
["anbumask"] = {cost = 12, AddonID = 34853, style = "addons"},
["witchcostume2"] = {cost = 12, AddonID = 34854, style = "addons"},
["bridecostume"] = {cost = 12, AddonID = 34855, style = "addons"},
["bearcoat"] = {cost = 10, AddonID = 34856, style = "addons"},
["enjoyingsummer1"] = {cost = 17, AddonID = 34857, style = "addons"},
["enjoyingsummer2"] = {cost = 17, AddonID = 34858, style = "addons"},
["moonfairy"] = {cost = 20, AddonID = 34859, style = "addons"},
["kyubimoncostume"] = {cost = 20, AddonID = 34860, style = "addons"},
["ahriatari"] = {cost = 20, AddonID = 34862, style = "addons"},
["kuramaasura"] = {cost = 20, AddonID = 34863, style = "addons"},
["greymoncostume"] = {cost = 15, AddonID = 34866, style = "addons"},
["cavegladiator"] = {cost = 15, AddonID = 34867, style = "addons"},
["gabumoncostume"] = {cost = 15, AddonID = 34869, style = "addons"},
["dreggmancostume"] = {cost = 15, AddonID = 34870, style = "addons"},
["killercloak"] = {cost = 15, AddonID = 34871, style = "addons"},

-- Depósitos --
["LycanrocDepot"] = {cost = 20, DepotID = 34952, style = "deposito"},
["AlolanVulpixDepot"] = {cost = 20, DepotID = 34953, style = "deposito"},
["SlurpuffDepot"] = {cost = 20, DepotID = 34954, style = "deposito"},
["ComfeyDepot"] = {cost = 20, DepotID = 34955, style = "deposito"},
["GliscorDepot"] = {cost = 20, DepotID = 34956, style = "deposito"},
["LaprasDepot"] = {cost = 20, DepotID = 34999, style = "deposito"},
["GauntletDepot"] = {cost = 20, DepotID = 34993, style = "deposito"},
["HoHoDepot"] = {cost = 20, DepotID = 34959, style = "deposito"},
["PrimarinaDepot"] = {cost = 20, DepotID = 34960, style = "deposito"},
["IncineroarDepot"] = {cost = 20, DepotID = 34961, style = "deposito"},
["LucarioDepot"] = {cost = 20, DepotID = 34962, style = "deposito"},
["LugiaDepot"] = {cost = 20, DepotID = 34963, style = "deposito"},
["LunalaDepot"] = {cost = 20, DepotID = 34964, style = "deposito"},
["StarDepot"] = {cost = 20, DepotID = 34965, style = "deposito"},
["SolgaleoDepot"] = {cost = 20, DepotID = 34972, style = "deposito"},
["VespiquenDepot"] = {cost = 20, DepotID = 34996, style = "deposito"},
["MimikyuDepot"] = {cost = 20, DepotID = 34968, style = "deposito"},
["MismagiusDepot"] = {cost = 20, DepotID = 34969, style = "deposito"},
["MoltresDepot"] = {cost = 20, DepotID = 34970, style = "deposito"},
["ZapdosDepot"] = {cost = 20, DepotID = 34975, style = "deposito"},
["ArticunoDepot"] = {cost = 20, DepotID = 34957, style = "deposito"},
["RaikoDepot"] = {cost = 20, DepotID = 34971, style = "deposito"},
["SuicuneDepot"] = {cost = 20, DepotID = 34973, style = "deposito"},
["EnteiDepot"] = {cost = 20, DepotID = 34958, style = "deposito"},
["MewDepot"] = {cost = 20, DepotID = 34966, style = "deposito"},
["MewthoDepot"] = {cost = 20, DepotID = 34967, style = "deposito"},
["UmbreonDepot"] = {cost = 20, DepotID = 34974, style = "deposito"},
["FlareonDepot"] = {cost = 20, DepotID = 34978, style = "deposito"},
["VaporeonDepot"] = {cost = 20, DepotID = 34979, style = "deposito"},
["JolteonDepot"] = {cost = 20, DepotID = 34981, style = "deposito"},
["ShinyUmbreonDepot"] = {cost = 20, DepotID = 35000, style = "deposito"},
["ChandelureDepot"] = {cost = 20, DepotID = 34976, style = "deposito"},
["MegaBanneteDepot"] = {cost = 20, DepotID = 34977, style = "deposito"},
["HypnoDepot"] = {cost = 20, DepotID = 34980, style = "deposito"},
["NinetalesDepot"] = {cost = 20, DepotID = 34982, style = "deposito"},
["MegaBlastoiseDepot"] = {cost = 20, DepotID = 34983, style = "deposito"},
["ShinyCharizardDepot"] = {cost = 20, DepotID = 34984, style = "deposito"},
["MegaCharizardXDepot"] = {cost = 20, DepotID = 34985, style = "deposito"},
["MegaCharizardYDepot"] = {cost = 20, DepotID = 34986, style = "deposito"},
["MegaVenusaurDepot"] = {cost = 20, DepotID = 34987, style = "deposito"},
["GyaradosDepot"] = {cost = 20, DepotID = 34988, style = "deposito"},
["ShinyGyaradosDepot"] = {cost = 20, DepotID = 34989, style = "deposito"},
["MegaGyaradosDepot"] = {cost = 20, DepotID = 34990, style = "deposito"},
["MetagrossDepot"] = {cost = 20, DepotID = 34991, style = "deposito"},
["ShinyMegaMetagrossDepot"] = {cost = 20, DepotID = 34992, style = "deposito"},
["RoseradeDepot"] = {cost = 20, DepotID = 34994, style = "deposito"},
["BudewDepot"] = {cost = 20, DepotID = 34995, style = "deposito"},
["ShinyMegaGardevoirDepot"] = {cost = 20, DepotID = 34997, style = "deposito"},
["ShinyMegaGalladeDepot"] = {cost = 20, DepotID = 34998, style = "deposito"},
["RayquazaDepot"] = {cost = 12, DepotID = 35012, style = "deposito"},
["GroudonDepot"] = {cost = 12, DepotID = 35013, style = "deposito"},
["KyogreDepot"] = {cost = 12, DepotID = 35014, style = "deposito"},
["DetetivePikachuDepot"] = {cost = 12, DepotID = 35021, style = "deposito"},
["PrimeapeDepot"] = {cost = 12, DepotID = 35022, style = "deposito"},
["ArcanineDepot"] = {cost = 12, DepotID = 35018, style = "deposito"},
["AerodactylDepot"] = {cost = 12, DepotID = 35015, style = "deposito"},
["BlastoiseDepot"] = {cost = 12, DepotID = 35023, style = "deposito"},
["ShinyBlastoiseDepot"] = {cost = 12, DepotID = 35024, style = "deposito"},
["VenusaurDepot"] = {cost = 12, DepotID = 35025, style = "deposito"},
["ShinyVenusaurDepot"] = {cost = 12, DepotID = 35026, style = "deposito"},
["kecleonDepot"] = {cost = 12, DepotID = 35016, style = "deposito"},
["MarshadowDepot"] = {cost = 12, DepotID = 35027, style = "deposito"},
["ZoroarkDepot"] = {cost = 12, DepotID = 35019, style = "deposito"},
["SylveonDepot"] = {cost = 12, DepotID = 35017, style = "deposito"},
["AbsolDepot"] = {cost = 12, DepotID = 35001, style = "deposito"},
["AggronDepot"] = {cost = 12, DepotID = 35002, style = "deposito"},
["CelebiDepot"] = {cost = 12, DepotID = 35003, style = "deposito"},
["ElectivireDepot"] = {cost = 12, DepotID = 35004, style = "deposito"},
["GardevoirDepot"] = {cost = 12, DepotID = 35005, style = "deposito"},
["GengarDepot"] = {cost = 12, DepotID = 35006, style = "deposito"},
["InfernapeDepot"] = {cost = 12, DepotID = 35007, style = "deposito"},
["WitchJinxDepot"] = {cost = 12, DepotID = 35008, style = "deposito"},
["KangaskhanDepot"] = {cost = 12, DepotID = 35009, style = "deposito"},
["RhydonDepot"] = {cost = 12, DepotID = 35010, style = "deposito"},
["SceptileDepot"] = {cost = 12, DepotID = 35011, style = "deposito"},
["DragonairDepot"] = {cost = 12, DepotID = 35020, style = "deposito"},
-- Depósitos --
-- Decorações --
["lumineonaquarium"] = {cost = 7, DecoracaoID = 35073, style = "decoracao"},
["luvdiscaquarium"] = {cost = 7, DecoracaoID = 35074, style = "decoracao"},
["shinyluvdiscaquarium"] = {cost = 7, DecoracaoID = 35075, style = "decoracao"},
["vaporeonaquarium"] = {cost = 7, DecoracaoID = 35076, style = "decoracao"},
["luvdiscaquarium2"] = {cost = 7, DecoracaoID = 35077, style = "decoracao"},
["goldeenaquarium"] = {cost = 7, DecoracaoID = 35078, style = "decoracao"},
["magikarpaquarium"] = {cost = 7, DecoracaoID = 35079, style = "decoracao"},
["magictable"] = {cost = 12, DecoracaoID = 35080, style = "decoracao"},
["tentaclechair"] = {cost = 5, DecoracaoID = 35081, style = "decoracao"},
["videogametable1"] = {cost = 5, DecoracaoID = 35082, style = "decoracao"},
["videogametable2"] = {cost = 5, DecoracaoID = 35083, style = "decoracao"},
["videogametable3"] = {cost = 5, DecoracaoID = 35084, style = "decoracao"},
["videogametable4"] = {cost = 5, DecoracaoID = 35085, style = "decoracao"},

["electrabuzzsculpture"] = {cost = 7, CortinaID = 35055, style = "cortina"},
["charizardsculpture"] = {cost = 7, CortinaID = 35056, style = "cortina"},
["laprassculpture"] = {cost = 7, CortinaID = 35057, style = "cortina"},
["gyaradossculpture"] = {cost = 7, CortinaID = 35058, style = "cortina"},
["venusaursculpture"] = {cost = 7, CortinaID = 35059, style = "cortina"},
["steelixsculpture"] = {cost = 7, CortinaID = 35060, style = "cortina"},
["gastlysculpture"] = {cost = 7, CortinaID = 35061, style = "cortina"},
["hauntersculpture"] = {cost = 7, CortinaID = 35062, style = "cortina"},
["primeapesculpture"] = {cost = 7, CortinaID = 35063, style = "cortina"},
["curtainofhearts"] = {cost = 7, CortinaID = 35064, style = "cortina"},
["curtainofmewtwo"] = {cost = 7, CortinaID = 35065, style = "cortina"},
["curtainofblastoise"] = {cost = 7, CortinaID = 35066, style = "cortina"},
["curtainofvenusaur"] = {cost = 7, CortinaID = 35067, style = "cortina"},
["curtainofcharizard"] = {cost = 7, CortinaID = 35068, style = "cortina"},
["curtainofmisdreavus"] = {cost = 7, CortinaID = 35069, style = "cortina"},
["curtainofgolem"] = {cost = 7, CortinaID = 35070, style = "cortina"},
["curtainofdragonite"] = {cost = 7, CortinaID = 35071, style = "cortina"},
["scarypicture"] = {cost = 12, CortinaID = 35072, style = "cortina"},

["greenaltar"] = {cost = 5, DecoracaoID = 35090, style = "decoracao"},
["pinkaltar"] = {cost = 5, DecoracaoID = 35091, style = "decoracao"},
["yellowaltar"] = {cost = 5, DecoracaoID = 35092, style = "decoracao"},
["pinkaltar2"] = {cost = 5, DecoracaoID = 35093, style = "decoracao"},
["plant1"] = {cost = 5, DecoracaoID = 35094, style = "decoracao"},
["plant2"] = {cost = 7, DecoracaoID = 35095, style = "decoracao"},
["pinkrose"] = {cost = 5, DecoracaoID = 35096, style = "decoracao"},
["redrose"] = {cost = 5, DecoracaoID = 35097, style = "decoracao"},
["treesprout"] = {cost = 5, DecoracaoID = 35098, style = "decoracao"},
["plant3"] = {cost = 5, DecoracaoID = 35099, style = "decoracao"},

["computergamer"] = {cost = 15, DecoracaoID = 35086, style = "decoracao"},
["guitar"] = {cost = 15, DecoracaoID = 35087, style = "decoracao"},

["coachsgauntlet"] = {cost = 15, DecoracaoID = 35088, style = "decoracao"},
["premieraltar"] = {cost = 30, DecoracaoID = 35089, style = "decoracao"},

} 

local cfg = config[param]
	if not cfg then return false end
	
	local ItemName = getItemNameById(cfg.add)

	if getPlayerItemCount(cid, 34524) >= cfg.cost then
		if cfg.style == "vip" then
			doPlayerAddPremiumDays(cid, cfg.add)
			local response = {value = "purchased"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "pokemon" then
			if cfg.add == "Ditto" then
				param = string.explode(param, ",")
				local ball = doCreatePokemonBall(cid, "x-gold", "Ditto", 1, nil, nil, 1, nil, nil, 99999999999, nil, getPokemonRandomSpecialAbility("Ditto"))
				if (param[4] and getPokemonSkillCategory(param[4])) then
					setBallEggMove(ball, 2, param[4])
					doBallUpdateDescription(ball)
				end
				local response = {value = "purchased"}
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
			elseif cfg.add == "Shiny Ditto" then
				param = string.explode(param, ",")
				local ball = doCreatePokemonBall(cid, "x-gold", "Shiny Ditto", 1, nil, nil, 1, nil, nil, 99999999999, nil, getPokemonRandomSpecialAbility("Shiny Ditto"))
				if (param[4] and getPokemonSkillCategory(param[4])) then
					setBallEggMove(ball, 2, param[4])
					doBallUpdateDescription(ball)
				end		
				local response = {value = "purchased"}
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
			end
		elseif cfg.style == "sex" then
			    doPlayerSetSex(cid, (getPlayerSex(cid) == 0 and 1 or 0))
				local response = {value = "sexbuy"}
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "bless" then
			if cfg.add == "30" then	

				local response = {value = "purchased"}
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
			elseif cfg.add == "8" then

				local response = {value = "purchased"}
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
			elseif cfg.add == "3" then

				local response = {value = "purchased"}
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
			end
		elseif cfg.style == "city" then
				doPlayerSetTown(cid, cfg.town)
				local response = {value = "purchased"}
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "item" then
			doPlayerAddItem(cid, cfg.add, cfg.count)
			local response = {value = "purchased"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "outfit" then
			doPlayerAddItem(cid, cfg.outfitID, 1)
			local response = {value = "purchased"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "addons" then
			doPlayerAddItem(cid, cfg.AddonID, 1)
			local response = {value = "purchased"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "deposito" then
			doPlayerAddItem(cid, 2557, 1) -- martelin
			doPlayerAddItem(cid, cfg.DepotID, 1)
			local response = {value = "purchased"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "decoracao" then
			doPlayerAddItem(cid, 2557, 1) -- martelin
			doPlayerAddItem(cid, cfg.DecoracaoID, 1)
			local response = {value = "purchased"}
			doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		elseif cfg.style == "cortina" then
			doPlayerAddItem(cid, cfg.CortinaID, 1)
			local response = {value = "purchased"}
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
