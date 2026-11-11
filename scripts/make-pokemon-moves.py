#!/usr/bin/env python3
"""Sets every species' level-up moves (skills in core/server/data/lib/ps/config/pokemon/*.lua) to the
official ones: the Ultra Sun / Ultra Moon level-up list from PokeAPI, at the official levels.

    git clone --depth 1 https://github.com/PokeAPI/pokeapi /tmp/pokeapi
    python3 scripts/make-pokemon-moves.py /tmp/pokeapi/data/v2/csv

- "Tackle" stays first, at level 1, for every Pokemon: it is the game's fallback move.
- Only moves the game has (lib/ps/config/moves/*.lua) are given; the official moves it lacks are
  listed in docs/missing-moves.md. Run this again after adding one of them.
- Moves a Pokemon knows on evolving (level 0 in the data) are level 1 here.
- Species 1-493 only, by their own name; Smeargle (Sketch slots) and Ditto (Transform) keep their
  special lists, and custom Pokemon (Chartle, Mega and Boss forms...) are not touched. Shiny and
  event versions copy their species.
- TM and egg moves are other lists (learnableTms, eggMoves) and are not changed.
"""
import collections
import csv
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG = os.path.join(ROOT, "core/server/data/lib/ps/config")
VERSION_GROUP = "18"  # ultra-sun-ultra-moon, the generation the stats follow
GAME_NAMES = {29: "Nidorana", 32: "Nidorano", 83: "Farfetchd"}  # where the game's name differs
SPELLINGS = {"feintattack": "faintattack", "highjumpkick": "hijumpkick", "visegrip": "vicegrip"}  # official -> game
SKIP = {"Smeargle", "Ditto"}
FIRST = "Tackle"


def norm(name):
    return re.sub(r"[^a-z0-9]", "", name.lower())


def read(path):
    with open(path, encoding="latin-1", newline="") as f:
        return f.read()


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    api = sys.argv[1]
    rows = lambda name: csv.DictReader(open(os.path.join(api, name), encoding="utf-8"))

    game_moves = {}
    for name in os.listdir(os.path.join(CONFIG, "moves")):
        m = re.search(r'^MOVES\["([^"]+)"\]', read(os.path.join(CONFIG, "moves", name)), re.M)
        if m:
            game_moves[norm(m.group(1))] = m.group(1)

    move_names = {r["move_id"]: r["name"] for r in rows("move_names.csv") if r["local_language_id"] == "9"}
    species = {int(r["pokemon_species_id"]): r["name"] for r in rows("pokemon_species_names.csv")
               if r["local_language_id"] == "9" and int(r["pokemon_species_id"]) <= 493}
    species.update(GAME_NAMES)

    learn = collections.defaultdict(dict)  # number -> official move -> (level, order)
    for r in rows("pokemon_moves.csv"):
        number = int(r["pokemon_id"])
        if number > 493 or r["version_group_id"] != VERSION_GROUP or r["pokemon_move_method_id"] != "1":
            continue
        move = move_names[r["move_id"]]
        key = (max(int(r["level"]), 1), int(r["order"] or 0))
        if move not in learn[number] or key < learn[number][move]:
            learn[number][move] = key

    files = {}
    for name in sorted(os.listdir(os.path.join(CONFIG, "pokemon"))):
        if name.endswith(".lua"):
            path = os.path.join(CONFIG, "pokemon", name)
            text = read(path)
            for m in re.finditer(r'^POKEMON\["([^"]+)"\]\s*=\s*\{', text, re.M):
                files[m.group(1)] = path

    missing = collections.defaultdict(list)
    changed = 0
    for number in range(1, 494):
        name = species[number]
        if name in SKIP:
            continue
        if name not in files:
            sys.exit("no config for %s (#%d)" % (name, number))
        skills = [(FIRST, 1)]
        for move, (level, _) in sorted(learn[number].items(), key=lambda item: item[1]):
            key = norm(move)
            key = SPELLINGS.get(key, key)
            if key not in game_moves:
                missing[move].append(name)
            elif game_moves[key] != FIRST:
                skills.append((game_moves[key], level))
        line = "skills = { %s }," % ", ".join('"%s", %d' % skill for skill in skills)
        text = read(files[name])
        start = re.search(r'^POKEMON\["%s"\]\s*=\s*\{' % re.escape(name), text, re.M).end()
        block = re.compile(r"skills\s*=\s*\{[^}]*\},?")
        found = block.search(text, start)
        if not found or "\nPOKEMON[" in text[start:found.start()]:
            sys.exit("no skills line for %s" % name)
        new = text[:found.start()] + line + text[found.end():]
        if new != text:
            changed += 1
            with open(files[name], "w", encoding="latin-1", newline="") as f:
                f.write(new)

    out = ["# Official moves the game doesn't have yet", "",
           "Level-up moves of the Ultra Sun / Ultra Moon lists that no file in `lib/ps/config/moves/` makes, so",
           "`scripts/make-pokemon-moves.py` can't give them. Add the move, then run the script again.", "",
           "| Move | Pokemon that learn it | |", "|---|---|---|"]
    for move, names in sorted(missing.items(), key=lambda item: (-len(item[1]), item[0])):
        shown = ", ".join(names[:8]) + (" and %d more" % (len(names) - 8) if len(names) > 8 else "")
        out.append("| %s | %d | %s |" % (move, len(names), shown))
    with open(os.path.join(ROOT, "docs/missing-moves.md"), "w") as f:
        f.write("\n".join(out) + "\n")
    print("%d species changed; %d official moves missing (%d entries) -> docs/missing-moves.md"
          % (changed, len(missing), sum(len(v) for v in missing.values())))


if __name__ == "__main__":
    main()
