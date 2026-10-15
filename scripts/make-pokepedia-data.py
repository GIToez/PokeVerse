#!/usr/bin/env python3
"""Writes core/server/data/lib/ps/config/pokepedia.lua for the Pokepedia (lib/ps/systems/069-pokepedia.lua):

- POKEPEDIA_SHOP_ITEMS: every item an NPC sells (the shop_buyable parameter of data/npc/*.xml),
  known to every trainer from the start in the Items tab.
- POKEPEDIA_QUEST_ITEMS: the items quests give (lib/ps/config/003-quest.lua).
- POKEPEDIA_SPAWNS: where each species spawns in data/world/map-spawn.xml, as areas of nearby
  spawn points ({x, y, z, points}), largest first. Shinies count for their species.

Run it again after changing the NPC shops or the spawns.
"""
import os
import re
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "core/server/data")
OUTPUT = os.path.join(DATA, "lib/ps/config/pokepedia.lua")

AREA_RANGE = 40  # spawn points this close (in tiles, same floor) belong to one area
AREAS_PER_SPECIES = 8


def shop_items():
    items = set()
    npc_dir = os.path.join(DATA, "npc")
    for name in sorted(os.listdir(npc_dir)):
        if not name.endswith(".xml"):
            continue
        with open(os.path.join(npc_dir, name), encoding="latin-1") as f:
            text = f.read()
        for match in re.finditer(r'key="shop_buyable"\s+value="([^"]*)"', text, re.S):
            for entry in match.group(1).split(";"):
                parts = [p.strip() for p in entry.split(",")]
                if len(parts) >= 3 and parts[1].isdigit():
                    items.add(int(parts[1]))
    return sorted(items)


def quest_items():
    with open(os.path.join(DATA, "lib/ps/config/003-quest.lua"), encoding="latin-1") as f:
        text = f.read()
    return sorted({int(id) for id in re.findall(r"type\s*=\s*REWARD_TYPE\.ITEM\s*,\s*id\s*=\s*(\d+)", text)})


def id_list(name, ids):
    lines = ["%s = {" % name]
    for i in range(0, len(ids), 16):
        lines.append("    " + ", ".join(str(id) for id in ids[i:i + 16]) + ",")
    lines.append("}")
    return lines


def spawn_points():
    points = {}
    root = ET.parse(os.path.join(DATA, "world/map-spawn.xml")).getroot()
    for spawn in root.iter("spawn"):
        cx, cy, cz = int(spawn.get("centerx")), int(spawn.get("centery")), int(spawn.get("centerz"))
        for monster in spawn.iter("monster"):
            name = re.sub(r"^Shiny ", "", monster.get("name"))
            x, y = cx + int(monster.get("x", 0)), cy + int(monster.get("y", 0))
            points.setdefault(name, []).append((x, y, cz))
    return points


def areas(points):
    groups = []  # [sum x, sum y, z, count]
    for x, y, z in points:
        for group in groups:
            gx, gy = group[0] / group[3], group[1] / group[3]
            if group[2] == z and abs(gx - x) <= AREA_RANGE and abs(gy - y) <= AREA_RANGE:
                group[0] += x
                group[1] += y
                group[3] += 1
                break
        else:
            groups.append([x, y, z, 1])
    groups.sort(key=lambda g: -g[3])
    return [(round(g[0] / g[3]), round(g[1] / g[3]), g[2], g[3]) for g in groups[:AREAS_PER_SPECIES]]


def main():
    items = shop_items()
    spawns = spawn_points()
    lines = [
        "-- Written by scripts/make-pokepedia-data.py from the NPC shops, the quests and data/world/map-spawn.xml.",
        "-- Items every shop sells, known in the Pokepedia from the start.",
    ]
    lines += id_list("POKEPEDIA_SHOP_ITEMS", items)
    lines.append("")
    lines.append("-- Items quests give.")
    lines += id_list("POKEPEDIA_QUEST_ITEMS", quest_items())
    lines.append("")
    lines.append("-- Where each species spawns: areas of nearby spawn points {x, y, z, points}, largest first.")
    lines.append("POKEPEDIA_SPAWNS = {")
    for name in sorted(spawns):
        rows = ", ".join("{ %d, %d, %d, %d }" % area for area in areas(spawns[name]))
        lines.append('    ["%s"] = { %s },' % (name, rows))
    lines.append("}")
    with open(OUTPUT, "w", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    print("%d shop items, %d species with spawns -> %s" % (len(items), len(spawns), OUTPUT))


if __name__ == "__main__":
    main()
