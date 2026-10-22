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

FOOTPRINTS = {
    trainer = {dirt = 18136, grass = 18140, sand = 18156},
    pokemon = {dirt = 30154, grass = 30155, sand = 30156},
}

-- Pokemon with prints of their own; every other Pokemon leaves the "pokemon" set.
FOOTPRINT_SPECIES = {
}
