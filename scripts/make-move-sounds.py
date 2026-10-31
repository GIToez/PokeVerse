#!/usr/bin/env python3
"""Converts the move sounds of BellBlitzKing's Pokemon SFX pack into the client's sounds/moves.

    scripts/make-move-sounds.py <pack folder> [--dry-run]

<pack folder> holds the "GEN n SFX - Attack Moves - ..." folders. Every move in
core/server/data/lib/ps/config/moves gets the newest generation's recording of its name (Sun and Moon
first, then X and Y, Black and White...), whole: no trim and no fade, since the client fades the sound
out when the move ends. Out: core/client-legacy/data/sounds/moves/<move>.ogg, mono Vorbis, where
<move> is the move name in lower case with every run of other characters turned into "_"
(game_sounds/move_sounds.lua does the same). SOUND_LIKE gives the moves newer than the pack an
older move's sound. Moves without a recording are listed at the end.
"""
import glob
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOVES = os.path.join(ROOT, 'core/server/data/lib/ps/config/moves')
OUT = os.path.join(ROOT, 'core/client-legacy/data/sounds/moves')

# our name -> the pack's name, where they differ
ALIASES = {
    'Faint Attack': 'Feint Attack',
    'Sand-Attack': 'Sand Attack',
    'Hi Jump Kick': 'High Jump Kick',
    'Vicegrip': 'Vise Grip',
    'ViceGrip': 'Vise Grip',
    'Selfdestruct': 'Self-Destruct',
    'Softboiled': 'Soft-Boiled',
    'Smellingsalt': 'Smelling Salts',
    'SmellingSalt': 'Smelling Salts',
    'Precipice Blade': 'Precipice Blades',
    'Thunderpunch': 'Thunder Punch',
    'ThunderPunch': 'Thunder Punch',
    'Dynamicpunch': 'Dynamic Punch',
    'DynamicPunch': 'Dynamic Punch',
    'Bubblebeam': 'Bubble Beam',
    'Doubleslap': 'Double Slap',
    'DoubleSlap': 'Double Slap',
    'Solarbeam': 'Solar Beam',
    'SolarBeam': 'Solar Beam',
    'Poisonpowder': 'Poison Powder',
    'PoisonPowder': 'Poison Powder',
    'Thundershock': 'Thunder Shock',
    'ThunderShock': 'Thunder Shock',
    'Extremespeed': 'Extreme Speed',
    'ExtremeSpeed': 'Extreme Speed',
    'Ancientpower': 'Ancient Power',
    'AncientPower': 'Ancient Power',
    'Dragonbreath': 'Dragon Breath',
    'DragonBreath': 'Dragon Breath',
    'Grasswhistle': 'Grass Whistle',
    'GrassWhistle': 'Grass Whistle',
}


# moves newer than the pack (Gen 8 and 9) sound like an older move until they get their own
SOUND_LIKE = {
    'Aqua Cutter': 'Razor Shell',
    'Barb Barrage': 'Poison Sting',
    'Body Press': 'Body Slam',
    'Headlong Rush': 'High Horsepower',
    'Hyper Drill': 'Horn Drill',
    'Mirror Move': 'Copycat',
    'Mystical Power': 'Psychic',
    'Psyshield Bash': 'Zen Headbutt',
    'Rage Fist': 'Shadow Punch',
    'Raging Bull': 'Take Down',
    'Raging Fury': 'Outrage',
    'Wave Crash': 'Waterfall',
}


def key(name):
    return re.sub(r'[^a-z0-9]', '', name.lower())


def slug(name):
    return re.sub(r'[^a-z0-9]+', '_', name.lower()).strip('_')


def our_moves():
    names = set()
    for path in glob.glob(os.path.join(MOVES, '*.lua')):
        with open(path, encoding='latin-1') as f:
            names.update(re.findall(r'MOVES\["([^"]+)"\]', f.read()))
    return sorted(names)


def pack_index(pack):
    """{name key: path} per generation, newest first. A whole recording wins over its "part n"s."""
    gens = []
    for gen in range(7, 0, -1):
        folders = glob.glob(os.path.join(pack, f'GEN {gen} SFX*'))
        index = {}
        for folder in folders:
            for path in sorted(glob.glob(os.path.join(folder, '*'))):
                stem, ext = os.path.splitext(os.path.basename(path))
                if ext.lower() not in ('.mp3', '.wav', '.ogg'):
                    continue
                part = re.search(r'\s*part\s*(\d+)$', stem, re.I)
                hits = re.search(r'\s*(\d+)\s*hits?$', stem, re.I)
                if part:
                    base, rank = stem[:part.start()], int(part.group(1))
                elif hits:
                    base, rank = stem[:hits.start()], 10 - int(hits.group(1))
                else:
                    base = re.sub(r'(?<=[a-z])1$', '', stem)
                    rank = 0 if base == stem else 1
                k = key(base)
                if k not in index or rank < index[k][0]:
                    index[k] = (rank, path)
        gens.append({k: v[1] for k, v in index.items()})
    return gens


def convert(src, dst):
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', src, '-vn', '-ac', '1', '-ar', '44100',
                    '-c:a', 'libvorbis', '-q:a', '3', '-map_metadata', '-1', dst], check=True)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if len(args) != 1:
        sys.exit(__doc__)
    gens = pack_index(args[0])
    jobs, missing = [], []
    for name in our_moves():
        k = key(ALIASES.get(name, SOUND_LIKE.get(name, name)))
        src = next((g[k] for g in gens if k in g), None)
        if src:
            jobs.append((name, src, os.path.join(OUT, slug(name) + '.ogg')))
        else:
            missing.append(name)
    for name, src, _ in jobs:
        print(f'{name}: {os.path.relpath(src, args[0])}')
    if '--dry-run' not in sys.argv:
        os.makedirs(OUT, exist_ok=True)
        with ThreadPoolExecutor(os.cpu_count() or 4) as pool:
            list(pool.map(lambda job: convert(job[1], job[2]), jobs))
    print(f'{len(jobs)} moves with a sound; {len(missing)} without: {", ".join(missing)}')


if __name__ == '__main__':
    main()
