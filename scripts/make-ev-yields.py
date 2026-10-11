#!/usr/bin/env python3
"""Writes core/server/data/lib/ps/config/evYields.lua from PokeAPI's official EV yields.

Every species defined in core/server/data/lib/ps/config/pokemon/ is matched to PokeAPI by name.
Event and variant forms ("RC Abra", "Noisy Rattata", "Cloned Gengar") use the species in their
last word; bosses and custom characters get no yield and are listed on stderr.

Usage: make-ev-yields.py [--csv-dir DIR]   (downloads pokemon.csv and pokemon_stats.csv without it)
"""
import argparse
import collections
import csv
import io
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPECIES_DIR = os.path.join(ROOT, "core/server/data/lib/ps/config/pokemon")
OUTPUT = os.path.join(ROOT, "core/server/data/lib/ps/config/evYields.lua")
CSV_URL = "https://raw.githubusercontent.com/PokeAPI/pokeapi/master/data/v2/csv/%s.csv"

# Game names that differ from PokeAPI identifiers
ALIASES = {"Deoxys": "deoxys-normal", "Nidorana": "nidoran-f", "Nidorano": "nidoran-m"}


def read_csv(name, csv_dir):
    if csv_dir:
        with open(os.path.join(csv_dir, name + ".csv"), newline="") as f:
            return list(csv.DictReader(f))
    with urllib.request.urlopen(CSV_URL % name) as response:
        return list(csv.DictReader(io.StringIO(response.read().decode("utf-8"))))


def identifier(name):
    return ALIASES.get(name) or name.lower().replace("'", "").replace(".", "").replace(" ", "-")


def game_species():
    names = set()
    for file in os.listdir(SPECIES_DIR):
        if file.endswith(".lua"):
            with open(os.path.join(SPECIES_DIR, file), encoding="latin-1") as f:
                names.update(re.findall(r'^POKEMON\["([^"]+)"\]', f.read(), re.M))
    return sorted(names)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--csv-dir")
    args = parser.parse_args()

    ids = {row["identifier"]: int(row["id"]) for row in read_csv("pokemon", args.csv_dir)}
    efforts = collections.defaultdict(lambda: [0] * 6)
    for row in read_csv("pokemon_stats", args.csv_dir):
        efforts[int(row["pokemon_id"])][int(row["stat_id"]) - 1] = int(row["effort"])

    lines, derived, missing = [], [], []
    for name in game_species():
        if identifier(name) in ids:
            lines.append((name, efforts[ids[identifier(name)]], None))
            continue
        base = name.split()[-1]
        if " " in name and identifier(base) in ids:
            derived.append((name, efforts[ids[identifier(base)]], base))
        else:
            missing.append(name)

    out = ["-- Official EV yields (HP, Atk, Def, SpA, SpD, Spe) from PokeAPI, written by scripts/make-ev-yields.py.",
           "-- Event and variant forms use their base species; bosses and custom characters give none.",
           "-- Shinies use the normal species (PokemonStats.getEvYield).",
           "EV_YIELDS = {"]
    for name, yields, base in lines + derived:
        entry = '    ["%s"] = { %s },' % (name, ", ".join(map(str, yields)))
        out.append(entry + (" -- " + base if base else ""))
    out.append("}")
    with open(OUTPUT, "w", newline="\n") as f:
        f.write("\n".join(out) + "\n")

    print("%d species: %d from PokeAPI, %d from their base species, %d without a yield"
          % (len(lines) + len(derived) + len(missing), len(lines), len(derived), len(missing)))
    if missing:
        print("No yield: " + ", ".join(missing), file=sys.stderr)


if __name__ == "__main__":
    main()
