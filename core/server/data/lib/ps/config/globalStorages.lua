GLOBAL_STORAGES = {
    SERVER_START_TIME = 4962,
    EVENT_CHRISTMAS_PRESENT_COUNT = 4963,
    ELITE_FOUR_CHALLENGER = 4964,
    EVENT_ANNIVERSARY_KILL_COUNT = 4965,
    EVENT_ANNIVERSARY_STATE = 4966,
    EVENT_HALLOWEEN_CAULDRON_MICROPHONE = 4967,
    EVENT_HALLOWEEN_CAULDRON_BAT_WING = 4968,
    EVENT_HALLOWEEN_CAULDRON_GYARADOS_TAIL = 4969,
    EVENT_HALLOWEEN_CAULDRON_POT_OF_LAVA = 4970,
    -- UNUSED EVENT_HALLOWEEN_CAULDRON_BAG_OF_POLEN = 4971,
    EVENT_HALLOWEEN_CAULDRON_BULB = 4972,
    EVENT_HALLOWEEN_CAULDRON_LEAF = 4973,
    EVENT_HALLOWEEN_CAULDRON_RAZOR_FANG = 4974,
    EVENT_HALLOWEEN_CAULDRON_HULL = 4975,
    EVENT_HALLOWEEN_CAULDRON_WATER_GEM = 4976,
    EVENT_HALLOWEEN_CAULDRON_FIRE_ELEMENT = 4977,
    EVENT_HALLOWEEN_CAULDRON_SEED = 4978,
    EVENT_HALLOWEEN_CAULDRON_SCREW = 4979,
    EVENT_HALLOWEEN_CAULDRON_BOTTLE_OF_POISON = 4980,
    EVENT_HALLOWEEN_CAULDRON_TANGELA_HAIR = 4981,
    EVENT_HALLOWEEN_CAULDRON_JYNX_CLOTHES = 4982,
    EVENT_HALLOWEEN_CAULDRON_YELLOW_TAIL = 4983,
    EVENT_HALLOWEEN_CAULDRON_WATER_PENDANT = 4984,
    EVENT_HALLOWEEN_CAULDRON_FIRE_PENDANT = 4985,
    EVENT_HALLOWEEN_CAULDRON_LEAF_PENDANT = 4986,
    EVENT_HALLOWEEN_CAULDRON_VENOM_PENDANT = 4987,
    EVENT_HALLOWEEN_CAULDRON_POT_OF_WATER = 4988,
    EVENT_HALLOWEEN_CAULDRON_POT_OF_MOSS_MUG = 4989,
    EVENT_HALLOWEEN_CAULDRON_SHARP_BEAK = 4990,
    EVENT_HALLOWEEN_CAULDRON_FIRE_ORB = 4991,
    EVENT_HALLOWEEN_CAULDRON_WHITE_ORB = 4992,
    EVENT_HALLOWEEN_CAULDRON_FUR = 4993,
    -- UNUSED EVENT_HALLOWEEN_SHADOW_ORB = 4994,
    EVENT_HALLOWEEN_STONE_ORB = 4995,
    EVENT_HALLOWEEN_FEATHER = 4996,
    EVENT_HALLOWEEN_REAPER_CLOTH = 4997,
    QUEST_TM_SUBSTITUTE_ROBOT_TRIES = 4999,
    TOURNAMENT_HIGHSCORE = 5000,
    SERVER_RESTART_AT = 7100,
    SERVER_RESTART_REASON = 7101,
    SERVER_RESTART_DAILY = 7102,
    SERVER_RESTART_SKIP = 7103,
    EXP_EVENT_MULTIPLIER = 7104,
    EXP_EVENT_END = 7105,
    DAYCARE_EVENT_MULTIPLIER = 7106, -- /bonusdaycare: Day Care training EXP x100 (Daycare.events)
    DAYCARE_EVENT_START = 7107,
    DAYCARE_EVENT_END = 7108,
    BREEDING_EVENT_MULTIPLIER = 7109, -- /bonusbreeding: how fast the egg wait runs x100
    BREEDING_EVENT_START = 7110,
    BREEDING_EVENT_END = 7111,
    SHINY_EVENT_MULTIPLIER = 7112, -- /bonusshiny: shiny chance x100 (ShinyEvent)
    SHINY_EVENT_END = 7113,
    EVENT_CALENDAR_FORCED = 7120, -- 7120 to 7139: a holiday forced on (1) or off (0) with /calendar holiday (EventCalendar)
    LEGENDARY_NEXT_AT = 7140, -- wild legendaries (WildLegendaries): unix time of the next spawn
    LEGENDARY_GAP_FROM = 7141, -- when the current gap started (the last spawn)
    LEGENDARY_GAP_ROLL = 7142, -- where in the population's gap range the next spawn falls, 0 to 1000
    LEGENDARY_COOLDOWNS = 7143, -- "m;Articuno=<unix time>;...": when each species may come again
    LEGENDARY_ACTIVE = 7144, -- "m;<encounter>=<cid>:<species>;...": the encounters out now
    LEGENDARY_SEQUENCE = 7145, -- last encounter id
    LEGENDARY_RECENT = 7146, -- "m;<species>=<unix time>:<encounter>": defeats whose body may still be caught
    LEGENDARY_MODE = 7147, -- "manual": only staff start wild legendaries (/legendary mode), anything else on the schedule
    LEGENDARY_SAVED = 7148, -- "m;<encounter>=<species>|<health %>|x,y,z|<minutes left>|<flags>;...": kept through a restart
    LEGENDARY_PENDING = 7149, -- "m;<species>=<spawn time>:<point>:<source>": a warning before the spawn (Mewtwo)
    EVENT_CALENDAR_SEASON = 7150, -- a season forced with /calendar season (1 spring to 4 winter), anything else automatic
    WEATHER_OVERRIDES = 7151, -- "m;<kind>:<until>=<zone runs>;...": weather staff set with /weather (Weather)
    DECORATIONS_VERSION = 7152, -- bumped when staff change decorations, so the globalevent puts them up again
    DECORATIONS_PREVIEW = 7153, -- "m;<set>:<until>": a decoration set staff preview with /deco preview
    DECORATIONS_NO_AUTO = 7154, -- "m;<zone ids>": towns staff decorate by hand only (/deco auto off)
    ANNIVERSARY_PREVIEW = 7155, -- "m;<until>": the Union Room entrance to the cake town shown with /anniversary show (AnniversaryEvent)
    DISCORD_BOOST_LEVEL = 7156, -- the Discord server boost level 0-3 the bridge last sent (DiscordBoostPerks)
    DISCORD_BOOST_COUNT = 7157, -- the Discord server's boost count sent with it
    WEATHER_REGIONS_OFF = 7158, -- "m;<region ids>": regions staff switched off with /weather region (Weather)
    LEGENDARY_FLIGHTS = 7159, -- "m;<encounter>=<species>|<health %>|x,y,z|x,y,z|<start>|<seconds>|<ends at>|<flags>|<flee stage>|<kind>": legendaries in the air or under the sea
    LEGENDARY_EVENTS = 7160, -- "m;shower=x,y,z,<until>;rayquaza=<groudon>:<kyogre>:<due, 0 not coming>": Jirachi's meteor shower and Rayquaza's call
    LEGENDARY_CLASHES = 7161, -- "m;<weather zone id>=<kind>": weather two legendaries make where they meet
    DISCORD_PING_ROLES = 7162, -- JSON {roles = {names}, everyone}: the Discord roles the Admin window can ping, sent by the bot (Announcements)
    DECORATIONS_ITEMS = 7163, -- "m;<set>:<item ids>;...": props staff added to a set's list (/deco items <set> add)
    DECORATIONS_SEEDED = 7164, -- the last Decorations.DEFAULT_SPOTS version saved into decoration_spots
    --[[
    FROM 5001 TO 5152 RESERVED TO CAUGHT HIGHSCORES RELATED (last update 23/02/12)
    ]]
    --[[
    FROM 6000 TO 6021 RESERVED TO MASTERY DUNGEONS RELATED (last update 23/02/12)
    ]]
    --[[
    FROM 6100 TO 6105 RESERVED TO BOSS RELATED (last update 17/01/13)
    ]]
    --[[
    6150 - 6156 Frontier Island Highscores Text (last update 23/01/13)
    ]]
}
