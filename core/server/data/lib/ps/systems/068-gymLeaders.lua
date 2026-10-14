-- Gym leader duels: the intro and victory banners in the client (game_gymbattle), sent as JSON on
-- EXTENDED_IDS.GYM:
--   {type = "intro", key, name, gym, title, element, badge, quote, look}
--   {type = "victory", key, name, gym, title, element, badge, quote, look}
-- key names the leader's portrait and badge icon in the client. NpcBattle sends them for the NPCs
-- listed here that give a badge.

GymLeaders = {}

GymLeaders.LEADERS = {
    ["Brock"] = { key = "brock", gym = "Pewter City Gym", title = "The Rock-Solid Pokemon Trainer",
        element = ELEMENT_ROCK, badge = BADGES.BOULDER,
        intro = "My defense is as hard as stone. Let's see you crack it!",
        victory = "You broke through my rock-hard defense... The Boulder Badge is yours!" },
    ["Misty"] = { key = "misty", gym = "Cerulean City Gym", title = "The Tomboyish Mermaid",
        element = ELEMENT_WATER, badge = BADGES.CASCADE,
        intro = "My water Pokemon are going to wash you right out of my gym!",
        victory = "Wow, you're too much! Fine, take the Cascade Badge!" },
    ["Lt. Surge"] = { key = "ltsurge", gym = "Vermilion City Gym", title = "The Lightning American",
        element = ELEMENT_ELECTRIC, badge = BADGES.THUNDER,
        intro = "Hey kid! Electric Pokemon saved me in the war. They'll zap you just the same!",
        victory = "Whoa! You're the real deal, kid! Take the Thunder Badge!" },
    ["Erika"] = { key = "erika", gym = "Celadon City Gym", title = "The Nature-Loving Princess",
        element = ELEMENT_GRASS, badge = BADGES.RAINBOW,
        intro = "I'm afraid my grass Pokemon will not wilt so easily.",
        victory = "Oh my, I concede defeat... Please accept the Rainbow Badge." },
    ["Koga"] = { key = "koga", gym = "Fuchsia City Gym", title = "The Poisonous Ninja Master",
        element = ELEMENT_POISON, badge = BADGES.SOUL,
        intro = "A ninja's poison strikes before you ever see it coming!",
        victory = "Humph! You have proven your worth. Take the Soul Badge!" },
    ["Sabrina"] = { key = "sabrina", gym = "Saffron City Gym", title = "The Master of Psychic Pokemon",
        element = ELEMENT_PSYCHIC, badge = BADGES.MARSH,
        intro = "I foresaw your arrival. I also foresaw your defeat.",
        victory = "This loss... I did not see it coming. The Marsh Badge is yours." },
    ["Blaine"] = { key = "blaine", gym = "Cinnabar Island Gym", title = "The Hotheaded Quiz Master",
        element = ELEMENT_FIRE, badge = BADGES.VOLCANO,
        intro = "Hah! I hope you brought Burn Heal, because my fire burns hot!",
        victory = "I have burnt out! You've earned the Volcano Badge!" },
    ["Giovanni"] = { key = "giovanni", gym = "Viridian City Gym", title = "The Self-Proclaimed Strongest Trainer",
        element = ELEMENT_GROUND, badge = BADGES.EARTH,
        intro = "So you've come this far. Now face the strongest trainer in Kanto!",
        victory = "Ha! That was a truly intense battle. Take the Earth Badge, you have earned it." },
}

function GymLeaders.get(npcName, rewardBadge)
    local leader = GymLeaders.LEADERS[npcName]
    if (leader and rewardBadge and leader.badge == rewardBadge) then
        return leader
    end
    return nil
end

function GymLeaders.send(cid, kind, npcName, npcUid)
    local leader = GymLeaders.LEADERS[npcName]
    if (not leader or not isPlayer(cid) or not getPlayerUsingOtClient(cid)) then
        return
    end

    local outfit = isCreature(npcUid) and getCreatureOutfit(npcUid) or nil
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GYM, JSON.encode({
        type = kind,
        key = leader.key,
        name = npcName,
        gym = __L(cid, leader.gym),
        title = __L(cid, leader.title),
        element = leader.element,
        badge = leader.badge.name,
        quote = __L(cid, kind == "victory" and leader.victory or leader.intro),
        look = outfit and outfit.lookType or nil
    }))
end
