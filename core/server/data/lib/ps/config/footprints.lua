-- Written by scripts/add-footprints.py from scripts/art/footprints.json; do not edit.
-- The ground a walker steps on, and the trace item each set of footprints turns it into.
FOOTPRINT_GROUNDS = {
    -- Dirt
    [351] = "dirt",
    [352] = "dirt",
    [353] = "dirt",
    [354] = "dirt",
    -- Grass
    [4526] = "grass",
    [4527] = "grass",
    [4528] = "grass",
    [4529] = "grass",
    [4530] = "grass",
    [4531] = "grass",
    [4532] = "grass",
    [4533] = "grass",
    [4534] = "grass",
    [4535] = "grass",
    [4536] = "grass",
    [4537] = "grass",
    [4538] = "grass",
    [4539] = "grass",
    [4540] = "grass",
    [4541] = "grass",
    -- Sand
    [231] = "sand",
}

-- set -> ground -> the way the walker faces -> trace item
FOOTPRINTS = {
    trainer = {
        dirt = {north = 18136, east = 30157, south = 30158, west = 30159},
        grass = {north = 18140, east = 30160, south = 30161, west = 30162},
        sand = {north = 18156, east = 30163, south = 30164, west = 30165},
    },
    pokemon = {
        dirt = {north = 30154, east = 30166, south = 30167, west = 30168},
        grass = {north = 30155, east = 30169, south = 30170, west = 30171},
        sand = {north = 30156, east = 30172, south = 30173, west = 30174},
    },
}

-- Pokemon with prints of their own; every other Pokemon leaves the "pokemon" set.
FOOTPRINT_SPECIES = {
}
