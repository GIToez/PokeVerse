#!/usr/bin/env python3
"""Moves the wild Togepi from Hoenn to Route 30 in Johto, where Mr. Pokemon gives you its egg in
the original games (docs/orange-islands-gen4.md).

Each Hoenn Togepi is taken out (and its spawn with it when nothing else is in it); the same number
go on free tiles next to Route 30 spawns, spread along the route, with the Hoenn spawn time.
Uses the free-tile rules of orange-gen4-spawns.py. Refuses to run twice.

    python3 scripts/mapper/togepi-to-johto.py
"""
import importlib.util
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
spec = importlib.util.spec_from_file_location("orange", os.path.join(ROOT, "scripts/mapper/orange-gen4-spawns.py"))
orange = importlib.util.module_from_spec(spec)
spec.loader.exec_module(orange)
anchors, pvmap = orange.anchors, orange.pvmap

NAME, FROM, TO, AREA = "Togepi", "hoenn", "johto", "Route 30"


def main():
    lines, monsters = orange.read()
    area_of = anchors.area_finder()
    region = lambda s: anchors.region_of(s["x"], s["y"])
    if any(s["name"] == NAME and region(s) == TO for s in monsters):
        raise SystemExit("Johto already has wild %s; nothing written" % NAME)
    moving = [s for s in monsters if s["name"] == NAME and region(s) == FROM]
    if not moving:
        raise SystemExit("no wild %s in Hoenn" % NAME)
    route = [s for s in monsters if region(s) == TO and area_of(s["x"], s["y"], s["z"]) == AREA]
    first = orange.spread(route, len(moving))
    hosts = first + [s for s in route if s not in first]

    taken = {(s["x"], s["y"], s["z"]) for s in monsters}
    near = [(dx, dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if dx or dy]
    tiles = pvmap.read_tiles(anchors.MAP, {(s["x"] + dx, s["y"] + dy, s["z"]) for s in hosts for dx, dy in near + [(0, 0)]})
    blocking = orange.blocking_items()

    inserts = {}
    for s in hosts:
        if len(inserts) == len(moving):
            break
        if s["block"] in inserts:
            continue
        own = tiles.get((s["x"], s["y"], s["z"]))
        for dx, dy in near:
            p = (s["x"] + dx, s["y"] + dy, s["z"])
            t = tiles.get(p)
            if p in taken or not t or not own or t[0] != own[0] or blocking & set(t):
                continue
            taken.add(p)
            cx, cy, _ = s["center"]
            inserts[s["block"]] = '    <monster name="%s" x="%d" y="%d" z="%d" spawntime="%d" level="0"/>' % (
                NAME, p[0] - cx, p[1] - cy, p[2], moving[len(inserts)]["spawntime"])
            print("%s at %d,%d,%d (next to %s)" % (NAME, p[0], p[1], p[2], s["name"]))
            break
    if len(inserts) < len(moving):
        raise SystemExit("only %d free tiles on %s for %d %s" % (len(inserts), AREA, len(moving), NAME))

    drop = {s["line"] for s in moving}
    edits = [(s["block"], None) for s in moving] + [(b, l) for b, l in inserts.items()]
    for block, line in sorted(edits, key=lambda e: -e[0]):
        end = block + 1
        while "</spawn>" not in lines[end]:
            end += 1
        if line is None:
            inside = [i for i in range(block + 1, end) if orange.MONSTER.search(lines[i])]
            if all(i in drop for i in inside):
                del lines[block:end + 1]
            else:
                for i in sorted(set(inside) & drop, reverse=True):
                    del lines[i]
        else:
            radius = re.search(r'radius="(\d+)"', lines[block])
            needed = max(abs(int(v)) for v in re.findall(r' [xy]="(-?\d+)"', line))
            if radius and needed > int(radius.group(1)):
                lines[block] = lines[block].replace(radius.group(0), 'radius="%d"' % needed)
            lines[end:end] = [line]

    open(orange.SPAWNS, "w", encoding="utf-8").write("\n".join(lines))
    shutil.copyfile(orange.SPAWNS, orange.MAPPER_SPAWNS)
    print("moved %d %s from Hoenn to %s" % (len(moving), NAME, AREA))


if __name__ == "__main__":
    sys.exit(main())
