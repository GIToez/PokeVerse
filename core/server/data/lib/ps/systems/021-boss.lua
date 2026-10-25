-- World bosses: one hard spawn after each server start. The news banner shows that boss's own
-- Pokedex line plus a place hint. Discord gets spawn and defeat only; the 10-minute reminder
-- stays in game (Announcements discord = false).
BOSS_REWARD_STORAGE = 8381
BOSS_REWARD_INTERVAL = 7 * 24 * 60 * 60

WorldBoss = {}

local BOSS_LEVEL_IDS = {
    EASY = 0,
    MEDIUM = 1,
    HARD = 2
}

local LEVELS = {
    --[[[BOSS_LEVEL_IDS.EASY] = {
        storageLastBoss = 6100, storageLastBossDate = 6101, spawnMinInterval = 2 * 24 * 60 * 60,
    },
    [BOSS_LEVEL_IDS.MEDIUM] = {
        storageLastBoss = 6102, storageLastBossDate = 6103, spawnMinInterval = 5 * 24 * 60 * 60,
    },]]
    [BOSS_LEVEL_IDS.HARD] = {
        storageLastBoss = 6104, storageLastBossDate = 6105, spawnMinInterval = 3 * 24 * 60 * 60,
    },
}

local BOSSES = {
    ["Grisly Mind"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4198, y = 217, z = 11}},
        hint = "Seek it near Temple of Illusion, close to Saffron.",
        messages = {
            "It wields a silver spoon in each hand.",
            "This is a large mustache!",
            "He is emerging dark psychic powers!",
            "Its brain can outperform a super-computer. Its intelligence quotient is said to be 5,000.",
            "A Pokemon that can memorize anything. It never forgets what it learns -- that's why this Pokemon is smart."
        }
    },
    ["Blastertoise"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 3458, y = 551, z = 9}},
        hint = "Seek it in a deep cave near Viridian.",
        messages = {
            "The powerful cannons on this Pokemon's back are capable of producing water blasts that can pierce steel and concrete.",
            "A brutal Pokemon with pressurized water jets on its shell.",
            "Once it takes aim at its enemy, it blasts out water with even more force than a fire hose.",
            "The rocket cannons on its shell fire jets of water capable of punching holes through thick steel."
        }
    },
    ["Pink Fury"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 3531, y = 342, z = 2}},
        hint = "Seek it near Mt. Moon, close to Celadon.",
        messages = {
            "A timid fairy Pokemon that is rarely seen. It will run and hide the moment it senses people.",
            "They appear to be very protective of their own world. It is a kind of fairy, rarely seen by people.",
            "Its ears are very sensitive, so it does not like loud noises or busy places.",
            "With its acute hearing, it can pick up sounds from far away."
        }
    },
    ["Smaug"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4019, y = 146, z = 6}},
        hint = "Seek it near Route 25, close to Cerulean.",
        messages = {
            "An extremely rarely seen marine Pokemon. Its intelligence is said to match that of humans.",
            "It is said that this Pokemon lives somewhere in the sea and that it flies. However, it is only a rumor.",
            "Has intelligence on par with people. This \"sea guardian\" is said to be capable of flying around the globe in about 16 hours.",
        }
    },
    ["The Turbo"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4156, y = 369, z = 4}},
        hint = "Seek it near the Power Plant, close to Lavender.",
        messages = {
            "Normally found near power plants, they can wander away and cause major blackouts in cities.",
            "If a major power outage occurs, it is certain that this Pokemon has eaten electricity at a power plant.",
            "Its body constantly discharges electricity. Getting close to it will make your hair stand on end.",
            "It windmills its arms to slightly boost its punches. Foes have been known to escape in the meantime."
        }
    },
    ["Toby"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4256, y = 528, z = 1}},
        hint = "Seek it near Lavender Tower.",
        messages = {
            "Under a full moon, this Pokemon likes to mimic the shadows of people and laugh at their fright.",
            "Appears to attack people who get lost in the mountains. Said to be the culprit behind shadows that laugh in the moonlight.",
            "To steal the life of its target, it slips into the prey's shadow and silently waits for an opportunity.",
        }
    },
    ["King Panlong"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 3513, y = 1108, z = 8}},
        hint = "Seek it near Seafoam Mountain, close to Cinnabar.",
        messages = {
            "Rarely seen in the wild. Huge and vicious, it is capable of destroying entire cities in a rage.",
            "Brutally vicious and enormously destructive. Known for totally destroying cities in ancient times.",
            "Once it appears, its rage never settles until it has razed the fields and mountains around it.",
        }
    },
    ["The A. Mesmer"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4226, y = 272, z = 4}},
        hint = "Seek it near Hill of Confusion, close to Lavender.",
        messages = {
            "When it locks eyes with an enemy, it will use a mix of PSI moves such as Hypnosis and Confusion.",
            "Avoid eye contact if you come across one. It will try to put you to sleep by using its pendulum.",
            "When it is very hungry, it puts humans it meets to sleep, then it feasts on their dreams.",
        }
    },
    ["Sweet Lover"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 3592, y = 979, z = 5}},
        hint = "Seek it near Seafoam Mountain, close to Cinnabar.",
        messages = {
            "It seductively wiggles its hips as it walks. It can cause people to dance in unison with it.",
            "Appears to move to a rhythm of its own, as if it were dancing. It wiggles its hips as it walks.",
            "Talks in a strange, incomprehensible language. It is known for its weird wiggling that causes people to dance.",
        }
    },
    ["Mad Mum"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4189, y = 400, z = 10}},
        hint = "Seek it near Rock Tunnel, close to Lavender.",
        messages = {
            "The infant rarely ventures out of its mother's protective pouch until it is 3 years old.",
            "Raises its young in its belly pouch. Won't run from any fight to keep its young protected.",
            "The female raises its young in its belly pouch for around three years. The young is taken out once it learns to find food."
        }
    },
    ["DoomBoy"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4075, y = 567, z = 6}},
        hint = "Seek it near Stone Mountain, close to Vermilion.",
        messages = {
            "Using its heavy muscles, it throws powerful punches that can send the victim clear over the horizon.",
            "One arm alone can move mountains. Using all four arms, this Pokemon fires off awesome punches.",
            "It can knock a train flying with a punch. However, it is terrible at delicate work using its fingers."
        }
    },
    ["Flesh'n Fire"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 3351, y = 934, z = 4}},
        hint = "Seek it near the Volcano, close to Pallet.",
        messages = {
            "Its body always burns with an orange glow that enables it to hide perfectly among flames.",
            "Born in an active volcano. Its body is always cloaked in flames, so it looks like a big ball of fire.",
            "When it breathes deeply, heat waves form around its body, making it hard to see clearly."
        }
    },
    ["Charles Spencer"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4077, y = 593, z = 3}},
        hint = "Seek it near Mind Forest, close to Vermilion.",
        messages = {
            "If interrupted while it is miming, it will slap around the offender with its broad hands.",
            "Always practices its pantomime act. It makes enemies believe something exists that really doesn't.",
            "It is an expert at miming and loves to perform. It is said to slap around anyone who disturbs it with its broad hands."
        }
    },
    ["Winged Wisdom"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4011, y = 418, z = 6}},
        hint = "Seek it near Nook of Birds, close to Saffron.",
        messages = {
            "This Pokemon flies at Mach 2 speed, seeking prey. Its large talons are feared as wicked weapons.",
            "Capable of flying incredibly quickly. In full flight, by the time its flapping is heard, it is long gone.",
            "Its outstanding vision allows it to spot splashing Magikarp, even while flying at 3,300 feet."
        }
    },
    ["Phyllo Terribil"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 3694, y = 560, z = 8}},
        hint = "Seek it near Cave Route 16, close to Celadon.",
        messages = {
            "A swimmer adept at both the front crawl and breaststroke. Easily overtakes the best human swimmers.",
            "Although an energetic, skilled swimmer that uses all of its muscles, it lives on dry land.",
            "This strong and skilled swimmer is even capable of crossing the Pacific Ocean just by kicking.",
        }
    },
    ["Cesar, The Simian"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 3220, y = 634, z = 5}},
        hint = "Seek it near Ape Mountain, close to Viridian.",
        messages = {
            "Always furious and tenacious to boot. It will not abandon chasing its quarry until it is caught.",
            "It stops being angry only when nobody else is around. To view this moment is very difficult.",
            "It grows angry if you see its eyes and gets angrier if you run. If you beat it, it gets even madder."
        }
    },
    ["Great Saul"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4006, y = 274, z = 4}},
        hint = "Seek it near Cerulean Mountain, close to Cerulean.",
        messages = {
            "Curls up into a spiny ball when threatened. It can roll while curled up to attack or escape.",
            "It is skilled at slashing enemies with its claws. If broken, they start to grow back in a day.",
            "It curls up, then rolls into foes with its back. Its sharp spines inflict severe damage."
        }
    },
    ["Twisted Blades"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4178, y = 773, z = 5}},
        hint = "Seek it near Mountain Butterfly, close to Vermilion.",
        messages = {
            "With ninja-like agility and speed, it can create the illusion that there is more than one.",
            "Leaps out of tall grass and slices prey with its scythes. The movement looks like that of a ninja.",
            "When it moves, it leaves only a blur. If it hides in grass, its protective colors make it invisible."
        }
    },
    ["Mr. Gormandize"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 4176, y = 612, z = 4}},
        hint = "Seek it near Mount Asleep, close to Lavender.",
        messages = {
            "Very lazy. Just eats and sleeps. As its rotund bulk builds, it becomes steadily more slothful.",
            "Will eat anything, even if the food happens to be a little moldy. It never gets an upset stomach.",
            "What sounds like its cry may actually be its snores or the rumblings of its hungry belly."
        }
    },
    ["Kirby"] = {
        level = BOSS_LEVEL_IDS.HARD,
        spawns = {{x = 3559, y = 356, z = 4}},
        hint = "Seek it near Mt. Moon, close to Celadon.",
        messages = {
            "The body is soft and rubbery. When angered, it will suck in air and inflate itself to an enormous size.",
            "Its body is full of elasticity. By inhaling deeply, it can continue to inflate itself without limit.",
            "Their fur feels so good that if two of them snuggle together, they won't want to be separated."
        }
    },
}

local BOSSES_BY_LEVEL = {}
for _, level in pairs(BOSS_LEVEL_IDS) do
    BOSSES_BY_LEVEL[level] = {}
end

for name, boss in pairs(BOSSES) do
    BOSSES_BY_LEVEL[boss.level][#BOSSES_BY_LEVEL[boss.level] + 1] = name
end

local SPAWN = { category = "event", title = "World Boss" }
local REMIND = { category = "event", title = "World Boss", discord = false }

WorldBoss.get = function(name)
    return BOSSES[name]
end

WorldBoss.each = function(fn)
    for name, boss in pairs(BOSSES) do
        fn(name, boss)
    end
end

-- "World Boss: <flavor> <hint>"
WorldBoss.announceText = function(name, flavor)
    local boss = BOSSES[name]
    if (not boss) then
        return ""
    end
    return "World Boss: " .. (flavor or table.random(boss.messages)) .. " " .. boss.hint
end

-- reminder true: in-game banner only. Spawn and defeat omit that so Discord gets them.
WorldBoss.announce = function(name, reminder, flavor)
    if (not BOSSES[name]) then
        return false
    end
    return doBroadcastMessage(WorldBoss.announceText(name, flavor), MESSAGE_STATUS_WARNING,
        reminder and REMIND or SPAWN)
end

WorldBoss.defeated = function()
    return doBroadcastMessage("The World Boss has been defeated.", MESSAGE_STATUS_WARNING, SPAWN)
end

local function remind(name)
    if (not getCreatureByName(name)) then
        return
    end
    WorldBoss.announce(name, true)
    addEvent(remind, 10 * 60 * 1000, name)
end

local function doBossSpawn(name)
    local pos = table.random(BOSSES[name].spawns)
    if (doCreateMonster(name, pos)) then
        WorldBoss.announce(name, false)

        local timeNow = os.time()
        setGlobalStorageValue(LEVELS[BOSSES[name].level].storageLastBoss, name)
        setGlobalStorageValue(LEVELS[BOSSES[name].level].storageLastBossDate, timeNow)

        if (not doDatalogBossSpawn(getConfigValue('worldId'), name, pos, timeNow)) then
            log(LOG_TYPES.ERROR, "doBossSpawn - Can't datalog boss spawn.", name, pos)
        end

        addEvent(remind, 10 * 60 * 1000, name)
    else
        log(LOG_TYPES.ERROR, "doBossSpawn - Can't spawn boss at position.", name, pos)
    end
end

function doBossStart() -- Server Start
    for level, config in pairs(LEVELS) do
        if (#BOSSES_BY_LEVEL[level] > 0) then
            local lastSpawnDate = getGlobalStorageValue(config.storageLastBossDate)
            if (lastSpawnDate == -1) then
                lastSpawnDate = os.time()
                setGlobalStorageValue(config.storageLastBossDate, lastSpawnDate)
            end

            local lastBoss = getGlobalStorageValue(config.storageLastBoss)
            local boss = table.random(BOSSES_BY_LEVEL[level])

            if (boss == lastBoss) then
                local count = 0
                while (boss == lastBoss and count < 1000) do
                    boss = table.random(BOSSES_BY_LEVEL[level])
                    count = count + 1
                end
            end

            local min = config.spawnMinInterval - (os.time() - lastSpawnDate)
            local interval = (getRandom(5 * 60 * 60, 16 * 60 * 60) + (min > 0 and min or 0)) -- 11:00 ~~ 22:00 (If ss is 06:00)
            addEvent(doBossSpawn, interval * 1000, boss)
            print(">> Scheduled Boss Spawn: " .. boss .. " in " .. table.concat(string.timediff(interval)))
        end
    end
end
