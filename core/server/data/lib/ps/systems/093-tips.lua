-- The rotating tips (globalMessages.lua), sent as Tip announcements: the news banner shows them when the
-- trainer isn't in a fight, and Options > Interface > Show tips turns them off. Old clients get the white text.
-- Adding a tip is one line; keep them to one line of the banner (about 75 letters).
Tips = {}

Tips.LIST = {
    "Never share your password. Staff will never ask for it.",
    "Bots and hacks get characters deleted. Play fair!",
    "Questions? Ask in the Help channel or read the Wiki tab of the Pokepedia.",
    "Enjoying PokeVerse? Invite your friends, it's more fun together!",
    "Have a suggestion? Let the staff know in the Help channel.",
    "Press M to open the Pokepedia and read the Wiki tab.",
    "Sell Pokemon you don't want to Ron in the Union Room.",
    "Every Pokemon Center has a way into the Union Room. Meet trainers there!",
    "Every locker opens your PC: boxes, stash, inbox and depot.",
    "Trade Pokemon with other trainers on the GTS.",
    "Leave a Pokemon at the Day Care to train it, or to find an egg.",
    "Drag a held item onto a Pokemon to give it to them.",
    "Moves use energy: watch the bar under your Pokemon's health.",
    "Press X, then click a Pokemon (or yourself) to open the Pokedex.",
    "Press E to order your Pokemon: push rocks, cut trees, climb and more.",
    "Flying or levitating? Press Q to go up a floor and Z to go down.",
    "Press Tab to attack the next target.",
    "Every key can be changed in Settings > Controls.",
    "Press T for Tasks: daily and hunting tasks with rewards.",
    "Press L for your Quest Log.",
    "Press C for the calendar: holidays, weekend events and more.",
    "Press P for your Trainer Card. Show it on Discord with /trainer.",
    "Log in every day: the 7-day login streak gets better each day.",
    "At level 20, pick a vocation. Press V to see them.",
    "Press U for your vocation's tool, like the radar or the Fishing Guide.",
    "Link Discord in the Account window to get the Verified Trainer role.",
    "Join our Discord for event pings and legendary sightings.",
    "Shiny Pokemon are stronger. Watch for shiny events on the calendar!",
    "Strange signs mean a legendary is near. Keep your eyes open!",
    "Try the Vibrant or Toon visual style in Options.",
    "Soul Coins buy nicknames and more in the Store.",
}

Tips.INTERVAL_MINUTES = 60 -- globalevents.xml runs globalMessages.lua this often

local deck = {}

local function shuffle()
    deck = {}
    for i = 1, #Tips.LIST do
        deck[i] = i
    end
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

-- each tip comes up once before any comes back
function Tips.next()
    if (#deck == 0) then
        shuffle()
    end
    return Tips.LIST[table.remove(deck)]
end

function Tips.broadcast()
    local tip = Tips.next()
    if (tip) then
        doBroadcastMessage(tip, MESSAGE_EVENT_ADVANCE, { category = "tip", title = "Did you know?", text = tip })
    end
end
