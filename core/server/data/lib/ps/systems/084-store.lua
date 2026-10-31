-- The Store: what Verse Orbs buy, from the Store button on the top bar. It replaced the Verse Orb NPCs
-- (npc/scripts/soulTrade.lua, kept but no longer on the map) and Josh Pillberg's vitamin reset.
--
-- Verse Orbs are an account balance (`accounts`.`soulcoins`, shared by the account's characters) and an item
-- (Store.COIN_ID). Withdraw turns balance into coins in the bag and Deposit puts them back. A purchase takes the
-- balance first and then coins from the bag, so nobody has to withdraw to shop.
--
-- The window talks JSON on EXTENDED_IDS.STORE:
--   client -> server  {action = "open"}, {action = "buy", offer, count, text}, {action = "withdraw", amount},
--                     {action = "deposit", amount}, {action = "history"}, {action = "buy-orbs"}
--   server -> client  {type = "store", balance, held, buyOrbs, coin, bag, points, premiumDays, sex, ball, guild, categories,
--                     offers}
--                     {type = "result", ok, text}
--                     {type = "history", list}
--                     {type = "buy-link", url}: the page for buying Verse Orbs with PayPal (101-payments.lua)
--
-- Orbs bought with PayPal in the last 7 days (held) can be spent but not withdrawn. A refund can leave the balance
-- below zero; then nothing can be bought or withdrawn until it is paid back.

Store = {}

Store.COIN_ID = 6500
Store.MAX_COUNT = 100 -- of a consumable in one purchase
Store.MAX_TRANSFER = 10000 -- coins in one withdraw or deposit
Store.HISTORY_ROWS = 50
Store.NICK_MIN, Store.NICK_MAX = 4, 20
Store.NAME_FORBIDDEN = { "shiny", "shini", "shyni", "shyny" }

-- The categories in the window's order. Featured holds offers with featured = true (discounts, limited
-- editions, the holiday outfits while their event runs).
Store.CATEGORIES = {
    { id = "featured", name = "Featured", icon = "featured" },
    { id = "premium", name = "Premium", icon = "premium" },
    { id = "addons", name = "Pokemon Addons", icon = "addons" },
    { id = "outfits", name = "Trainer Outfits", icon = "outfits" },
    { id = "warpstyles", name = "Warp Styles", icon = "warpstyles" },
    { id = "services", name = "Services", icon = "services" },
    { id = "items", name = "Consumables", icon = "items" },
    { id = "guild", name = "Guild", icon = "guild" },
    { id = "referral", name = "Referral Rewards", icon = "referral" },
}

-- kind: "premium" (days), "item" (itemId), "outfit" (outfitId from XML/outfits.xml), "warpstyle" (a style from
-- WarpStyles.STYLES; slot is the kind of slot it goes in), "sex", "nickname", "unnickname", "vitamins", "guild",
-- "rank" and "referral" (below). look/looks are what the window draws: a Pokemon or one look per sex (female,
-- male); image is a game_warpfx picture; names, one name per sex (female, male). use is the datalog_coin_uses id the NPCs logged the same thing with.
Store.OFFERS = {
    { id = "premium30", category = "premium", kind = "premium", days = 30, price = 15, use = 1, name = "30 days Premium",
      description = "Premium for the whole account, shared by its 3 characters. Added to the days you have left." },
    { id = "premium90", category = "premium", kind = "premium", days = 90, price = 40, was = 45, use = 1,
      name = "90 days Premium", description = "Three months of Premium for the price of less than three." },

    { id = "addon_kabutops", category = "addons", kind = "item", itemId = 29826, price = 15, use = 12, look = 2496,
      name = "Fossilized Kabutops", pokemon = "Kabutops", description = "Gives Kabutops its fossil look, also while it surfs." },
    { id = "addon_aerodactyl", category = "addons", kind = "item", itemId = 29827, price = 15, use = 12, look = 2494,
      name = "Fossilized Aerodactyl", pokemon = "Aerodactyl", description = "Gives Aerodactyl its fossil look, also while it flies." },
    { id = "addon_armaldo", category = "addons", kind = "item", itemId = 29829, price = 15, use = 12, look = 2497,
      name = "Fossilized Armaldo", pokemon = "Armaldo", description = "Gives Armaldo its fossil look." },
    { id = "addon_omastar", category = "addons", kind = "item", itemId = 29830, price = 15, use = 12, look = 2478,
      name = "Fossilized Omastar", pokemon = "Omastar", description = "Gives Omastar its fossil look, also while it surfs." },
    { id = "addon_greybeard", category = "addons", kind = "item", itemId = 29855, price = 15, use = 12, look = 2380,
      name = "Greybeard Costume", pokemon = "Slowking", description = "Dresses Slowking as a bearded wizard." },
    { id = "addon_frankenstein", category = "addons", kind = "item", itemId = 29640, price = 15, use = 12, look = 2176,
      featured = true, name = "Frankenstein Cap", pokemon = "Psyduck", description = "Bolts, stitches and a flat top for Psyduck." },
    { id = "addon_clownmask", category = "addons", kind = "item", itemId = 29678, price = 15, use = 12, look = 2229,
      featured = true, name = "Clown Mask", pokemon = "Dewgong", description = "A creepy clown mask for Dewgong, also while it surfs." },
    { id = "addon_hannya", category = "addons", kind = "item", itemId = 29847, price = 15, use = 12, look = 2526,
      featured = true, name = "Hannya Mask", pokemon = "Steelix", description = "A horned demon mask for Steelix, also while you ride it." },
    { id = "addon_skullcap", category = "addons", kind = "item", itemId = 29621, price = 15, use = 12, look = 2171,
      featured = true, name = "Skull Cap", pokemon = "Sandshrew", description = "A skull helmet for Sandshrew." },
    { id = "addon_redscarf", category = "addons", kind = "item", itemId = 29606, price = 15, use = 12, look = 2188,
      name = "Red Scarf", pokemon = "Fearow", description = "A red scarf for Fearow, also while it flies." },
    { id = "addon_greenscarf", category = "addons", kind = "item", itemId = 29607, price = 15, use = 12, look = 2186,
      name = "Green Scarf", pokemon = "Fearow", description = "A green scarf for Fearow, also while it flies." },
    { id = "addon_pinkbow", category = "addons", kind = "item", itemId = 29608, price = 15, use = 12, look = 2148,
      name = "Pink Bow", pokemon = "Arbok", description = "A pink bow for Arbok." },
    { id = "addon_yellowbow", category = "addons", kind = "item", itemId = 29609, price = 15, use = 12, look = 2161,
      name = "Yellow Bow", pokemon = "Arbok", description = "A yellow bow for Arbok." },
    { id = "addon_purplestripe", category = "addons", kind = "item", itemId = 29727, price = 15, use = 12, look = 2183,
      name = "Purple Stripe", pokemon = "Nidoqueen", description = "A purple stripe for Nidoqueen." },
    { id = "addon_romanhelmet", category = "addons", kind = "item", itemId = 29633, price = 15, use = 12, look = 2170,
      name = "Roman Helmet", pokemon = "Golbat", description = "A Roman helmet for Golbat." },
    { id = "addon_redkarateheadband", category = "addons", kind = "item", itemId = 29642, price = 15, use = 12, look = 2177,
      name = "Red Karate Headband", pokemon = "Golduck", description = "A red karate headband for Golduck, also while it surfs." },
    { id = "addon_yellowkarateheadband", category = "addons", kind = "item", itemId = 29643, price = 15, use = 12, look = 2178,
      name = "Yellow Karate Headband", pokemon = "Golduck", description = "A yellow karate headband for Golduck, also while it surfs." },
    { id = "addon_blackkarateheadband", category = "addons", kind = "item", itemId = 29644, price = 15, use = 12, look = 2179,
      name = "Black Karate Headband", pokemon = "Golduck", description = "A black karate headband for Golduck, also while it surfs." },
    { id = "addon_gentlemanclothes", category = "addons", kind = "item", itemId = 29861, price = 15, use = 12, look = 2403,
      name = "Gentleman Clothes", pokemon = "Golduck", description = "Dresses Golduck in gentleman clothes, also while it surfs." },
    { id = "addon_banana", category = "addons", kind = "item", itemId = 29645, price = 15, use = 12, look = 2184,
      name = "Banana", pokemon = "Mankey", description = "A banana for Mankey." },
    { id = "addon_truechampionbelt", category = "addons", kind = "item", itemId = 29646, price = 15, use = 12, look = 2185,
      name = "True Champion Belt", pokemon = "Primeape", description = "A champion belt for Primeape." },
    { id = "addon_dogcollar", category = "addons", kind = "item", itemId = 29647, price = 15, use = 12, look = 2212,
      name = "Dog Collar", pokemon = "Growlithe", description = "A dog collar for Growlithe." },
    { id = "addon_wrestlingmask", category = "addons", kind = "item", itemId = 29663, price = 15, use = 12, look = 2214,
      name = "Wrestling Mask", pokemon = "Machamp", description = "A wrestling mask for Machamp." },
    { id = "addon_banecostume", category = "addons", kind = "item", itemId = 29773, price = 15, use = 12, look = 2413,
      name = "Bane Costume", pokemon = "Machamp", description = "Dresses Machamp in Bane's costume." },
    { id = "addon_disguise", category = "addons", kind = "item", itemId = 29667, price = 15, use = 12, look = 2254,
      name = "Disguise", pokemon = "Victreebel", description = "A disguise for Victreebel." },
    { id = "addon_ponysaddle", category = "addons", kind = "item", itemId = 29674, price = 15, use = 12, look = 2267,
      name = "Pony Saddle", pokemon = "Ponyta", description = "A pony saddle for Ponyta, also while you ride it." },
    { id = "addon_horsesaddle", category = "addons", kind = "item", itemId = 29675, price = 15, use = 12, look = 2531,
      name = "Horse Saddle", pokemon = "Rapidash", description = "A horse saddle for Rapidash, also while you ride it." },
    { id = "addon_djcap", category = "addons", kind = "item", itemId = 29679, price = 15, use = 12, look = 2231,
      name = "DJ Cap", pokemon = "Muk", description = "A DJ cap for Muk." },
    { id = "addon_pirateflag", category = "addons", kind = "item", itemId = 29680, price = 15, use = 12, look = 2228,
      name = "Pirate Flag", pokemon = "Cloyster", description = "A pirate flag for Cloyster." },
    { id = "addon_redglasses", category = "addons", kind = "item", itemId = 29681, price = 15, use = 12, look = 2232,
      name = "Red Glasses", pokemon = "Cloyster", description = "Red glasses for Cloyster." },
    { id = "addon_emeraldturban", category = "addons", kind = "item", itemId = 29690, price = 15, use = 12, look = 2246,
      name = "Emerald Turban", pokemon = "Hypno", description = "An emerald turban for Hypno." },
    { id = "addon_rubyturban", category = "addons", kind = "item", itemId = 29691, price = 15, use = 12, look = 2247,
      name = "Ruby Turban", pokemon = "Hypno", description = "A ruby turban for Hypno." },
    { id = "addon_mechanicalclothes", category = "addons", kind = "item", itemId = 29860, price = 15, use = 12, look = 2404,
      name = "Mechanical Clothes", pokemon = "Exeggutor", description = "Dresses Exeggutor in mechanical clothes." },
    { id = "addon_pipe", category = "addons", kind = "item", itemId = 29699, price = 15, use = 12, look = 2266,
      name = "Pipe", pokemon = "Weezing", description = "A pipe for Weezing." },
    { id = "addon_fakefork", category = "addons", kind = "item", itemId = 29705, price = 15, use = 12, look = 2335,
      name = "Fake Fork", pokemon = "Tangela", description = "A fake fork for Tangela." },
    { id = "addon_santoryucostume", category = "addons", kind = "item", itemId = 29837, price = 15, use = 12, look = 2512,
      name = "Santoryu Costume", pokemon = "Scyther", description = "Dresses Scyther in a three-sword Santoryu costume." },
    { id = "addon_flamethrowkit", category = "addons", kind = "item", itemId = 29725, price = 15, use = 12, look = 2286,
      name = "Flamethrow Kit", pokemon = "Magmar", description = "A flamethrow kit for Magmar." },
    { id = "addon_yellowribbon", category = "addons", kind = "item", itemId = 29605, price = 15, use = 12, look = 2273,
      name = "Yellow Ribbon", pokemon = "Pinsir", description = "A yellow ribbon for Pinsir." },
    { id = "addon_blackbullsaddle", category = "addons", kind = "item", itemId = 29728, price = 15, use = 12, look = 2291,
      name = "Black Bull Saddle", pokemon = "Tauros", description = "A black bull saddle for Tauros, also while you ride it." },
    { id = "addon_redbullsaddle", category = "addons", kind = "item", itemId = 29729, price = 15, use = 12, look = 2293,
      name = "Red Bull Saddle", pokemon = "Tauros", description = "A red bull saddle for Tauros, also while you ride it." },
    { id = "addon_waterpendant", category = "addons", kind = "item", itemId = 29735, price = 15, use = 12, look = 2308,
      name = "Water Pendant", pokemon = "Lapras", description = "A water pendant for Lapras, also while it surfs." },
    { id = "addon_pearlnecklace", category = "addons", kind = "item", itemId = 29736, price = 15, use = 12, look = 2307,
      name = "Pearl Necklace", pokemon = "Lapras", description = "A pearl necklace for Lapras, also while it surfs." },
    { id = "addon_yellowshell", category = "addons", kind = "item", itemId = 29738, price = 15, use = 12, look = 2310,
      name = "Yellow Shell", pokemon = "Lapras", description = "A yellow shell for Lapras, also while it surfs." },
    { id = "addon_darkpendant", category = "addons", kind = "item", itemId = 29739, price = 15, use = 12, look = 2311,
      name = "Dark Pendant", pokemon = "Lapras", description = "A dark pendant for Lapras, also while it surfs." },
    { id = "addon_fossilizedomanyte", category = "addons", kind = "item", itemId = 29832, price = 15, use = 12, look = 2501,
      name = "Fossilized Omanyte", pokemon = "Omanyte", description = "Gives Omanyte its fossil look." },
    { id = "addon_partycap", category = "addons", kind = "item", itemId = 29745, price = 15, use = 12, look = 2327,
      name = "Party Cap", pokemon = "Omastar", description = "A party cap for Omastar." },
    { id = "addon_starglasses", category = "addons", kind = "item", itemId = 29746, price = 15, use = 12, look = 2328,
      name = "Star Glasses", pokemon = "Omastar", description = "Star glasses for Omastar, also while it surfs." },
    { id = "addon_fossilizedkabuto", category = "addons", kind = "item", itemId = 29831, price = 15, use = 12, look = 2500,
      name = "Fossilized Kabuto", pokemon = "Kabuto", description = "Gives Kabuto its fossil look." },
    { id = "addon_redcape", category = "addons", kind = "item", itemId = 29744, price = 15, use = 12, look = 2330,
      name = "Red Cape", pokemon = "Kabutops", description = "A red cape for Kabutops, also while it surfs." },
    { id = "addon_bearcap", category = "addons", kind = "item", itemId = 29749, price = 15, use = 12, look = 2348,
      name = "Bear Cap", pokemon = "Snorlax", description = "A bear cap for Snorlax." },
    { id = "addon_pokemontrainercostume", category = "addons", kind = "item", itemId = 29804, price = 15, use = 12, look = 2468,
      name = "Pokemon Trainer Costume", pokemon = "Typhlosion", description = "Dresses Typhlosion in a Pokemon Trainer costume." },
    { id = "addon_ninjacostume", category = "addons", kind = "item", itemId = 29806, price = 15, use = 12, look = 2466,
      name = "Ninja Costume", pokemon = "Typhlosion", description = "Dresses Typhlosion in the ninja costume." },
    { id = "addon_clancostume", category = "addons", kind = "item", itemId = 29807, price = 15, use = 12, look = 2467,
      name = "Clan Costume", pokemon = "Typhlosion", description = "Dresses Typhlosion in the clan costume." },
    { id = "addon_huntercostume", category = "addons", kind = "item", itemId = 29810, price = 15, use = 12, look = 2457,
      name = "Hunter Costume", pokemon = "Feraligatr", description = "Dresses Feraligatr in the hunter costume, also while it surfs." },
    { id = "addon_lifejacket", category = "addons", kind = "item", itemId = 29811, price = 15, use = 12, look = 2461,
      name = "Life Jacket", pokemon = "Feraligatr", description = "A life jacket for Feraligatr, also while it surfs." },
    { id = "addon_titaniumarmor", category = "addons", kind = "item", itemId = 29812, price = 15, use = 12, look = 2462,
      name = "Titanium Armor", pokemon = "Feraligatr", description = "Dresses Feraligatr in the titanium armor, also while it surfs." },
    { id = "addon_seaknightcostume", category = "addons", kind = "item", itemId = 29814, price = 15, use = 12, look = 2464,
      name = "Sea Knight Costume", pokemon = "Feraligatr", description = "Dresses Feraligatr in the sea knight costume, also while it surfs." },
    { id = "addon_lifesavercostume", category = "addons", kind = "item", itemId = 29815, price = 15, use = 12, look = 2458,
      name = "Lifesaver Costume", pokemon = "Feraligatr", description = "Dresses Feraligatr in the lifesaver costume, also while it surfs." },
    { id = "addon_superherocostume", category = "addons", kind = "item", itemId = 29845, price = 15, use = 12, look = 2513,
      name = "Superhero Costume", pokemon = "Ampharos", description = "Dresses Ampharos in the superhero costume." },
    { id = "addon_superherocape", category = "addons", kind = "item", itemId = 29858, price = 15, use = 12, look = 2386,
      name = "Superhero Cape", pokemon = "Sudowoodo", description = "A superhero cape for Sudowoodo." },
    { id = "addon_metallicpack", category = "addons", kind = "item", itemId = 29856, price = 15, use = 12, look = 2384,
      name = "Metallic Pack", pokemon = "Girafarig", description = "A metallic pack for Girafarig, also while you ride it." },
    { id = "addon_surfboard", category = "addons", kind = "item", itemId = 31095, price = 15, use = 12, look = 2898,
      name = "Surfboard", pokemon = "Pikachu and Raichu", description = "A surfboard for Pikachu and Raichu (and their shinies). Wearing it, they can surf, on the board too." },
    { id = "addon_ironjaw", category = "addons", kind = "item", itemId = 29862, price = 15, use = 12, look = 2405,
      name = "Iron Jaw", pokemon = "Steelix", description = "An iron jaw for Steelix, also while you ride it." },
    { id = "addon_evilillidancostume", category = "addons", kind = "item", itemId = 29834, price = 15, use = 12, look = 2505,
      name = "Evil Illidan Costume", pokemon = "Scizor", description = "Dresses Scizor in an Evil Illidan costume." },
    { id = "addon_mercenarymask", category = "addons", kind = "item", itemId = 29852, price = 15, use = 12, look = 2369,
      name = "Mercenary Mask", pokemon = "Scizor", description = "A mercenary mask for Scizor." },
    { id = "addon_ninjaclothes", category = "addons", kind = "item", itemId = 29859, price = 15, use = 12, look = 2409,
      name = "Ninja Clothes", pokemon = "Scizor", description = "Dresses Scizor in ninja clothes." },
    { id = "addon_tanukihat", category = "addons", kind = "item", itemId = 29825, price = 15, use = 12, look = 2491,
      name = "Tanuki Hat", pokemon = "Ursaring", description = "A tanuki hat for Ursaring." },
    { id = "addon_dynomuttcostume", category = "addons", kind = "item", itemId = 29800, price = 15, use = 12, look = 2448,
      name = "Dynomutt Costume", pokemon = "Houndoom", description = "Dresses Houndoom in a Dynomutt costume, also while you ride it." },
    { id = "addon_luffycostume", category = "addons", kind = "item", itemId = 29835, price = 15, use = 12, look = 2507,
      name = "Luffy Costume", pokemon = "Smeargle", description = "Dresses Smeargle in Luffy's outfit." },
    { id = "addon_mafiacap", category = "addons", kind = "item", itemId = 29836, price = 15, use = 12, look = 2506,
      name = "Mafia Cap", pokemon = "Smeargle", description = "A mafia cap for Smeargle." },
    { id = "addon_farmercostume", category = "addons", kind = "item", itemId = 29794, price = 15, use = 12, look = 2424,
      name = "Farmer Costume", pokemon = "Miltank", description = "Dresses Miltank in the farmer costume." },
    { id = "addon_nursecostume", category = "addons", kind = "item", itemId = 29820, price = 15, use = 12, look = 2479,
      name = "Nurse Costume", pokemon = "Blissey", description = "Dresses Blissey in the nurse costume." },
    { id = "addon_flowercostume", category = "addons", kind = "item", itemId = 29821, price = 15, use = 12, look = 2477,
      name = "Flower Costume", pokemon = "Blissey", description = "Dresses Blissey in the flower costume." },
    { id = "addon_ukuleleplayercostume", category = "addons", kind = "item", itemId = 29833, price = 15, use = 12, look = 2502,
      name = "Ukulele Player Costume", pokemon = "Ludicolo", description = "Dresses Ludicolo in the ukulele player costume, also while it surfs." },
    { id = "addon_pirateempressbluedress", category = "addons", kind = "item", itemId = 29802, price = 15, use = 12, look = 2439,
      name = "Pirate Empress Blue Dress", pokemon = "Gardevoir", description = "Dresses Gardevoir in the blue Pirate Empress dress." },
    { id = "addon_elderironmask", category = "addons", kind = "item", itemId = 29798, price = 15, use = 12, look = 2450,
      name = "Elder Iron Mask", pokemon = "Manectric", description = "An elder iron mask for Manectric, also while you ride it." },

    { id = "outfit_business", category = "outfits", kind = "outfit", outfitId = 53, price = 15, looks = { 1380, 1381 },
      name = "Business", description = "A sharp suit for trainers who mean business." },
    { id = "outfit_rider", category = "outfits", kind = "outfit", outfitId = 55, price = 15, looks = { 1384, 1385 },
      name = "Rider", description = "Biker leathers for the open road." },
    { id = "outfit_shinymaniac", category = "outfits", kind = "outfit", outfitId = 50, price = 15, looks = { 1370, 1370 },
      name = "Shiny Poke Maniac", description = "The Poke Maniac costume in its rare shiny colours." },
    { id = "outfit_costume_water", category = "outfits", kind = "outfit", outfitId = 78, price = 15, looks = { 2560, 2554 },
      featured = true, name = "Pokemon Costume", names = { "Azurill Costume", "Blastoise Costume" },
      description = "Dress up as a Pokemon: Azurill for female trainers, Blastoise for male trainers." },
    { id = "outfit_costume_classic", category = "outfits", kind = "outfit", outfitId = 79, price = 15, looks = { 2553, 2548 },
      featured = true, name = "Pokemon Costume", names = { "Pikachu Costume", "Charizard Costume" },
      description = "Dress up as a Pokemon: Pikachu for female trainers, Charizard for male trainers." },

    { id = "warp_pokeball", category = "warpstyles", kind = "warpstyle", style = "pokeball", slot = "warp", price = 10,
      image = "pokeball", featured = true, name = "Poke Ball Warp",
      description = "A Poke Ball's red light pulls you in, three wobbles and a click. Plays when you log in, log out and teleport." },
    { id = "warp_fireworks", category = "warpstyles", kind = "warpstyle", style = "fireworks", slot = "victory", price = 5,
      image = "spark-2", name = "Fireworks Victory", description = "Three rockets burst into coloured sparks when you win a duel or a trainer battle." },
    { id = "warp_trophy", category = "warpstyles", kind = "warpstyle", style = "trophy", slot = "victory", price = 5,
      image = "trophy", name = "Trophy Victory", description = "A gold cup rises over your head when you win a duel or a trainer battle." },
    { id = "warp_sweatdrop", category = "warpstyles", kind = "warpstyle", style = "sweatdrop", slot = "defeat", price = 5,
      image = "sweat", name = "Sweat Drop Defeat", description = "Gloom lines and a big sweat drop when you lose a duel or a trainer battle." },
    { id = "warp_ghost", category = "warpstyles", kind = "warpstyle", style = "ghost", slot = "defeat", price = 5,
      image = "orb", name = "Ghost Defeat", description = "Your spirit floats out of you and gets pulled back in when you lose a duel or a trainer battle." },

    { id = "nickname", category = "services", kind = "nickname", price = 1, use = 5, name = "Pokemon Nickname",
      description = "Names the Pokemon in your ball slot. 4 to 20 letters and spaces; it can't be a Pokemon's name or contain \"shiny\"." },
    { id = "unnickname", category = "services", kind = "unnickname", price = 0, name = "Remove Nickname",
      description = "The Pokemon in your ball slot goes back to its species name." },
    { id = "vitamins", category = "services", kind = "vitamins", price = 1, use = 10, name = "Vitamin Reset",
      description = "Removes every vitamin from the Pokemon in your ball slot, so you can give it new ones." },
    { id = "sex", category = "services", kind = "sex", price = 3, use = 2, name = "Sex Change",
      description = "Changes your trainer from male to female, or back." },

    { id = "stamina", category = "items", kind = "item", itemId = 13971, price = 1, use = 6, stack = true,
      name = "Spirit Tonic", description = "Restores 10 hours of Trainer Spirit. It works below 30 hours, and can't take you past 40." },
    { id = "eggmove", category = "items", kind = "item", itemId = 28915, price = 1, use = 11, stack = true,
      name = "Egg Move Capsule", description = "Teaches a Pokemon one of its egg moves." },

    { id = "guild", category = "guild", kind = "guild", price = 5, use = 8, name = "Create a Guild",
      description = "Forms a new guild with you as its leader. Needs level %d and no guild." },
    { id = "rank", category = "guild", kind = "rank", price = 1, use = 9, name = "New Guild Rank",
      description = "Adds a rank to your guild. Leaders only; give it to a member with /setrank name, rank." },
}

-- Referral Rewards are paid with the account's referral points (Referral.onPlayerBuy takes them), not Soul
-- Coins: 5 points for each friend who reaches level 30 and buys Premium.
local REFERRAL_DESCRIPTIONS = {
    ["hunter outfit"] = "The Hunter trainer outfit.",
    ["pikachu backpack"] = "A Pikachu to carry on your back.",
    ["doll box"] = "A box with a random Pokemon doll.",
    ["rare seal box"] = "A box with a rare ball seal.",
}
do
    local rewards = {}
    for key, option in pairs(Referral.OPTIONS) do
        rewards[#rewards + 1] = { key = key, option = option }
    end
    table.sort(rewards, function(a, b)
        if (a.option.points ~= b.option.points) then
            return a.option.points > b.option.points
        end
        return a.key < b.key
    end)
    for _, reward in ipairs(rewards) do
        local option = reward.option
        local name = option.name:gsub("(%a)(%w*)", function(first, rest) return first:upper() .. rest end)
        Store.OFFERS[#Store.OFFERS + 1] = { id = "referral_" .. reward.key:gsub("%s", "_"), category = "referral",
            kind = "referral", referral = reward.key, price = option.points, points = true, itemId = option.itemId,
            looks = option.outfits, name = name,
            description = REFERRAL_DESCRIPTIONS[reward.key] or "Paid with referral points." }
    end
end

local byId = {}
for _, offer in ipairs(Store.OFFERS) do
    byId[offer.id] = offer
end

Store.offer = function(id)
    return byId[tostring(id or "")]
end

local function send(cid, data)
    doSendPlayerLongExtendedOpcode(cid, EXTENDED_IDS.STORE, JSON.encode(data))
end

local function result(cid, ok, text, ...)
    send(cid, { type = "result", ok = ok, text = string.format(__L(cid, text), ...) })
    return ok
end

-- Balance -----------------------------------------------------------------------------------------------

Store.getBalance = function(accountId)
    local r = db.getResult(string.format("SELECT `soulcoins` FROM `accounts` WHERE `id` = %d", accountId))
    if (r:getID() == -1) then
        return 0
    end
    local balance = r:getDataInt("soulcoins")
    r:free()
    return balance
end

local function changedRows()
    local r = db.getResult("SELECT ROW_COUNT() AS `n`")
    if (r:getID() == -1) then
        return 0
    end
    local n = r:getDataInt("n")
    r:free()
    return n
end

-- Takes amount from the balance in one statement that can't go below zero; false when it isn't there.
-- Nothing else (a second character, a payment landing) can change the balance between the check and the write.
Store.takeBalance = function(accountId, amount)
    if (amount <= 0) then
        return true
    end
    db.executeQuery(string.format("UPDATE `accounts` SET `soulcoins` = `soulcoins` - %d WHERE `id` = %d AND `soulcoins` >= %d",
        amount, accountId, amount))
    return changedRows() == 1
end

Store.addBalance = function(accountId, amount)
    if (amount <= 0) then
        return true
    end
    return db.executeQuery(string.format("UPDATE `accounts` SET `soulcoins` = `soulcoins` + %d WHERE `id` = %d", amount, accountId))
end

local function log(cid, text, amount)
    db.executeQuery(string.format("INSERT INTO `store_history` (`account_id`, `player_id`, `date`, `amount`, `description`)"
        .. " VALUES (%d, %d, %d, %d, %s)", getPlayerAccountId(cid), getPlayerGUID(cid), os.time(), amount,
        db.escapeString(text)))
end

-- Pays price from the balance first, then from coins in the bag: true, or false and why not
local function pay(cid, price)
    if (price <= 0) then
        return true
    end
    local account = getPlayerAccountId(cid)
    local balance = Store.getBalance(account)
    if (balance < 0) then
        return false, "A PayPal refund took back orbs you had already spent, so the Store is closed for this account until the balance is above zero."
    end
    local fromBalance = math.min(balance, price)
    local fromBag = price - fromBalance
    if (getPlayerItemCount(cid, Store.COIN_ID) < fromBag) then
        return false, "You need %d Verse Orbs for this."
    elseif (not Store.takeBalance(account, fromBalance)) then
        return false, "Your Verse Orb balance changed. Try again."
    elseif (fromBag > 0 and not doPlayerRemoveItem(cid, Store.COIN_ID, fromBag)) then
        Store.addBalance(account, fromBalance)
        return false, "You need %d Verse Orbs for this."
    end
    return true
end

local function refund(cid, price)
    Store.addBalance(getPlayerAccountId(cid), price)
end

-- State -------------------------------------------------------------------------------------------------

local function ballInfo(cid)
    local ball = getPlayerBall(cid)
    if (not isItem(ball) or not isBallWithPokemon(ball.uid)) then
        return nil
    end
    local name = getBallPokemonName(ball.uid)
    local nickname = getBallPokemonNickname(ball.uid)
    return { name = name, level = getBallPokemonLevel(ball.uid), number = getPokemonNumberByName(name),
             nickname = (nickname and nickname ~= "" and nickname ~= name) and nickname or nil,
             vitamins = getBallTotalVitamins(ball.uid) }
end

local function guildInfo(cid)
    local id = getPlayerGuildId(cid)
    if (id <= 0) then
        return nil
    end
    return { name = getPlayerGuildName(cid), leader = getPlayerGuildLevel(cid) == GUILDLEVEL_LEADER or nil }
end

local function hasOutfit(cid, offer)
    if (offer.outfitId) then
        return canPlayerWearOutfitId(cid, offer.outfitId, 0)
    end
    local looks = offer.looks or {}
    local look = getPlayerSex(cid) == PLAYERSEX_FEMALE and looks[1] or looks[2]
    return look ~= nil and canPlayerWearOutfit(cid, look, 0)
end

local function offerName(cid, offer)
    local name = offer.names and offer.names[getPlayerSex(cid) == PLAYERSEX_FEMALE and 1 or 2] or offer.name
    return __L(cid, name)
end

local function owned(cid, offer)
    if (offer.kind == "warpstyle") then
        return WarpStyles.bought(cid, offer.style)
    end
    return (offer.kind == "outfit" or (offer.kind == "referral" and offer.looks)) and hasOutfit(cid, offer)
end

local function offerList(cid)
    local list = JSON.array()
    for _, offer in ipairs(Store.OFFERS) do
        local entry = { id = offer.id, category = offer.category, featured = offer.featured or nil, kind = offer.kind,
                        name = offerName(cid, offer), price = offer.price, was = offer.was, look = offer.look,
                        looks = offer.looks, pokemon = offer.pokemon, stack = offer.stack or nil, days = offer.days,
                        points = offer.points, image = offer.image, style = offer.style, slot = offer.slot }
        entry.description = __L(cid, offer.description)
        if (offer.kind == "guild") then
            entry.description = string.format(entry.description, getConfigValue("levelToFormGuild"))
        end
        if (offer.itemId) then
            entry.item = getItemClientId(offer.itemId) or 0
        end
        if (owned(cid, offer)) then
            entry.owned = true
        end
        list[#list + 1] = entry
    end
    return list
end

local function categoryList(cid)
    local list = JSON.array()
    for _, category in ipairs(Store.CATEGORIES) do
        list[#list + 1] = { id = category.id, name = __L(cid, category.name), icon = category.icon }
    end
    return list
end

Store.sendState = function(cid)
    local account = getPlayerAccountId(cid)
    send(cid, { type = "store", balance = Store.getBalance(account), held = Payments.getHeld(account),
                buyOrbs = Payments.enabled() or nil, coin = getItemClientId(Store.COIN_ID),
                bag = getPlayerItemCount(cid, Store.COIN_ID), points = Referral.getPoints(cid), premiumDays = getPlayerPremiumDays(cid),
                sex = getPlayerSex(cid), ball = ballInfo(cid), guild = guildInfo(cid),
                categories = categoryList(cid), offers = offerList(cid),
                nick = { min = Store.NICK_MIN, max = Store.NICK_MAX } })
end

Store.sendHistory = function(cid)
    local list = JSON.array()
    local r = db.getResult(string.format("SELECT h.`date`, h.`amount`, h.`description`, p.`name` FROM `store_history` h"
        .. " LEFT JOIN `players` p ON p.`id` = h.`player_id` WHERE h.`account_id` = %d ORDER BY h.`id` DESC LIMIT %d",
        getPlayerAccountId(cid), Store.HISTORY_ROWS))
    if (r:getID() ~= -1) then
        repeat
            list[#list + 1] = { date = r:getDataInt("date"), amount = r:getDataInt("amount"),
                                text = r:getDataString("description"), player = r:getDataString("name") }
        until not r:next()
        r:free()
    end
    send(cid, { type = "history", list = list })
end

-- Checks ------------------------------------------------------------------------------------------------

-- A nickname or guild name the NPCs accepted: letters and spaces, no Pokemon's name, no "shiny"
Store.nameAcceptable = function(name)
    name = tostring(name or "")
    if (#name < Store.NICK_MIN or #name > Store.NICK_MAX or not name:match("^[A-Za-z ]+$") or name:match("^ ")
            or name:match(" $") or name:match("  ")) then
        return false
    end
    local lower = name:lower()
    for _, word in ipairs(Store.NAME_FORBIDDEN) do
        if (lower:find(word, 1, true)) then
            return false
        end
    end
    return not isPokemonName(name)
end

local function ballBusy(cid)
    return isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid)
end

-- Why this purchase can't happen, or nil. text is the name the offer asks for.
local function blocker(cid, offer, text)
    local kind = offer.kind
    if (kind == "warpstyle" and owned(cid, offer)) then
        return "You already have this Warp Style."
    elseif ((kind == "outfit" or (kind == "referral" and offer.looks)) and hasOutfit(cid, offer)) then
        return "You already have this outfit."
    elseif (kind == "referral" and Referral.getPoints(cid) < offer.price) then
        return string.format(__L(cid, "You need %d referral points for this."), offer.price)
    elseif (kind == "nickname" or kind == "unnickname" or kind == "vitamins") then
        local ball = getPlayerBall(cid)
        if (not isItem(ball) or not isBallWithPokemon(ball.uid)) then
            return "Put a ball in your ball slot first."
        elseif (ballBusy(cid)) then
            return "Call your Pokemon back into its ball first."
        elseif (kind == "nickname" and not Store.nameAcceptable(text)) then
            return "A nickname is 4 to 20 letters and spaces, and can't be a Pokemon's name or contain \"shiny\"."
        elseif (kind == "unnickname" and not ballInfo(cid).nickname) then
            return "This Pokemon has no nickname."
        elseif (kind == "vitamins" and getBallTotalVitamins(ball.uid) == 0) then
            return "This Pokemon has no vitamins."
        end
    elseif (kind == "guild") then
        if (getPlayerGuildId(cid) > 0) then
            return "You are already in a guild."
        elseif (getPlayerLevel(cid) < getConfigValue("levelToFormGuild")) then
            return string.format(__L(cid, "You need at least level %d to form a guild."), getConfigValue("levelToFormGuild"))
        elseif (getPlayerPremiumDays(cid) < getConfigValue("premiumDaysToFormGuild")) then
            return string.format(__L(cid, "You need at least %d premium days to form a guild."), getConfigValue("premiumDaysToFormGuild"))
        elseif (not Store.nameAcceptable(text)) then
            return "A guild name is 4 to 20 letters and spaces, and can't be a Pokemon's name or contain \"shiny\"."
        elseif (getGuildId(text)) then
            return "There is already a guild with that name."
        end
    elseif (kind == "rank") then
        if (getPlayerGuildId(cid) <= 0) then
            return "You aren't in a guild."
        elseif (getPlayerGuildLevel(cid) ~= GUILDLEVEL_LEADER) then
            return "Only the leader of your guild can add ranks."
        elseif (not Store.nameAcceptable(text)) then
            return "A rank name is 4 to 20 letters and spaces, and can't be a Pokemon's name or contain \"shiny\"."
        end
    end
    return nil
end

-- Gives what was bought: true, or false when it couldn't be given (the coins go back)
local function deliver(cid, offer, count, text)
    local kind = offer.kind
    if (kind == "premium") then
        doPlayerAddPremiumDays(cid, offer.days)
        Referral.onPlayerAcquirePremium(cid)
    elseif (kind == "item") then
        return doPlayerSafeAddItem(cid, offer.itemId, count, false) ~= false
    elseif (kind == "outfit") then
        doPlayerAddOutfitId(cid, offer.outfitId, 0)
    elseif (kind == "warpstyle") then
        return WarpStyles.give(cid, offer.style) and true or false
    elseif (kind == "sex") then
        doPlayerSetSex(cid, getPlayerSex(cid) == PLAYERSEX_FEMALE and PLAYERSEX_MALE or PLAYERSEX_FEMALE)
    elseif (kind == "nickname" or kind == "unnickname") then
        local ball = getPlayerBall(cid)
        local oldNick = getBallPokemonNickname(ball.uid) or ""
        if (kind == "nickname") then
            setPlayerPokemonNickname(cid, text, false)
            doDatalogPokeNickChange(cid, oldNick, text, os.time())
            doPlayerAddStatistic(cid, PLAYER_STATISTIC_IDS.CHANGE_POKEMON_NICKNAME, 1)
        else
            setPlayerPokemonNickname(cid, (getBallPokemonName(ball.uid):gsub("^Shiny ", "")), true)
            doDatalogPokeNickChange(cid, oldNick, "", os.time())
        end
    elseif (kind == "vitamins") then
        Vitamin.doResetBall(getPlayerBall(cid))
    elseif (kind == "guild") then
        return doCreateGuild(cid, text) and true or false
    elseif (kind == "rank") then
        return doGuildCreateRank(getPlayerGuildId(cid), text) and true or false
    end
    return true
end

local DONE = {
    premium = "%d days of Premium were added to your account.",
    item = "You got %s. It is in your bag, or in your depot if the bag was full.",
    outfit = "The %s outfit is yours. Pick it in the outfit window.",
    warpstyle = "%s is yours. Put it on in Customise Trainer > Warp Styles.",
    sex = "Your trainer's sex has been changed.",
    referral = "You got the %s for referral points.",
    nickname = "Your Pokemon is now called %s.",
    unnickname = "Your Pokemon's nickname was removed.",
    vitamins = "Your Pokemon's vitamins were reset.",
    guild = "Your guild %s has been formed!",
    rank = "The rank %s was added to your guild.",
}

Store.buy = function(cid, id, count, text)
    local offer = Store.offer(id)
    if (not offer) then
        return result(cid, false, "That offer isn't in the Store anymore.")
    end
    count = offer.stack and math.max(1, math.min(Store.MAX_COUNT, math.floor(tonumber(count) or 1))) or 1
    text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local why = blocker(cid, offer, text)
    if (why) then
        return result(cid, false, why)
    end
    if (offer.kind == "referral") then
        if (not Referral.onPlayerBuy(cid, Referral.OPTIONS[offer.referral])) then
            Store.sendState(cid)
            return result(cid, false, "That didn't work. Check your referral points and try again.")
        end
        log(cid, string.format("%s (%d referral points)", offer.name, offer.price), 0)
        print(string.format("> Store: %s took %s for %d referral points", getCreatureName(cid), offer.name, offer.price))
        Store.sendState(cid)
        return result(cid, true, DONE.referral, offer.name)
    end
    local price = offer.price * count
    local ok, payWhy = pay(cid, price)
    if (not ok) then
        return result(cid, false, payWhy, price)
    end
    if (not deliver(cid, offer, count, text)) then
        refund(cid, price)
        Store.sendState(cid)
        return result(cid, false, "That didn't work, and your Verse Orbs went back to your balance.")
    end
    if (offer.use and price > 0) then
        doDatalogCoinUse(os.time(), getPlayerGUID(cid), offer.use, price)
    end
    local label = (offer.stack and count > 1) and string.format("%dx %s", count, offer.name) or (offer.names and offerName(cid, offer)) or offer.name
    if (offer.kind == "nickname" or offer.kind == "guild" or offer.kind == "rank") then
        label = string.format("%s: %s", offer.name, text)
    end
    log(cid, label, -price)
    doPlayerSave(cid)
    print(string.format("> Store: %s bought %s for %d Verse Orbs", getCreatureName(cid), label, price))

    local done = DONE[offer.kind]
    local arg = offer.kind == "premium" and offer.days or (offer.kind == "item" and label) or
        ((offer.kind == "outfit" or offer.kind == "warpstyle") and offerName(cid, offer)) or text
    Store.sendState(cid)
    return result(cid, true, done, arg)
end

Store.withdraw = function(cid, amount)
    amount = math.floor(tonumber(amount) or 0)
    if (amount <= 0 or amount > Store.MAX_TRANSFER) then
        return result(cid, false, "Withdraw between 1 and %d Verse Orbs.", Store.MAX_TRANSFER)
    end
    local account = getPlayerAccountId(cid)
    -- one statement, so a payment or a refund landing at the same moment can't get around the hold
    db.executeQuery(string.format("UPDATE `accounts` SET `soulcoins` = `soulcoins` - %d WHERE `id` = %d AND `soulcoins` - %d >= %s",
        amount, account, amount, Payments.heldSql(account)))
    if (changedRows() ~= 1) then
        local held = Payments.getHeld(account)
        if (held > 0 and Store.getBalance(account) >= amount) then
            return result(cid, false, "%d of your Verse Orbs were bought in the last %d days and can't be withdrawn yet. Spend them in the Store any time.",
                held, Payments.HOLD_DAYS)
        end
        return result(cid, false, "Your balance doesn't have %d Verse Orbs.", amount)
    end
    local given = 0
    while (given < amount) do
        local stack = math.min(100, amount - given)
        if (not doPlayerSafeAddItem(cid, Store.COIN_ID, stack, false)) then
            break
        end
        given = given + stack
    end
    if (given < amount) then
        Store.addBalance(account, amount - given)
        if (given == 0) then
            return result(cid, false, "There is no room for the orbs. Nothing was withdrawn.")
        end
        amount = given
    end
    log(cid, "Withdrew to the bag", -amount)
    doPlayerSave(cid)
    Store.sendState(cid)
    return result(cid, true, "%d Verse Orbs are in your bag now (or your depot, where the bag was full).", amount)
end

Store.deposit = function(cid, amount)
    amount = math.floor(tonumber(amount) or 0)
    if (amount <= 0 or amount > Store.MAX_TRANSFER) then
        return result(cid, false, "Deposit between 1 and %d Verse Orbs.", Store.MAX_TRANSFER)
    elseif (getPlayerItemCount(cid, Store.COIN_ID) < amount or not doPlayerRemoveItem(cid, Store.COIN_ID, amount)) then
        return result(cid, false, "You don't carry %d Verse Orbs.", amount)
    end
    Store.addBalance(getPlayerAccountId(cid), amount)
    log(cid, "Deposited from the bag", amount)
    doPlayerSave(cid)
    Store.sendState(cid)
    return result(cid, true, "%d Verse Orbs were added to your balance.", amount)
end

Store.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or "")
    if (action == "open") then
        Store.sendState(cid)
    elseif (action == "buy") then
        Store.buy(cid, data.offer, data.count, data.text)
    elseif (action == "withdraw") then
        Store.withdraw(cid, data.amount)
    elseif (action == "deposit") then
        Store.deposit(cid, data.amount)
    elseif (action == "history") then
        Store.sendHistory(cid)
    elseif (action == "buy-orbs") then
        local url, why = Payments.createLink(cid)
        if (url) then
            send(cid, { type = "buy-link", url = url })
        else
            result(cid, false, why)
        end
    end
end
