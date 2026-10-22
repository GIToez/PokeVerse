"""The website's world map: the Pokepedia's map pictures as WebP tiles, and the names of places.

The tiles come from scripts/mapper/render_pokepedia.py's surface chunks (lods 64, 32, 16 and 8,
the web map's zooms 0 to 3), so the website shows the same map as the game, with the same
hidden regions and bounds. The names come from game_minimap's map_labels.lua.
"""
import json
import os
import re
import sys
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
MAPPER = os.path.join(ROOT, "scripts/mapper")
LABELS_LUA = os.path.join(ROOT, "core/client-redemption/pokeverse-modern/modules/game_minimap/map_labels.lua")
HIDDEN_REGIONS = os.path.join(MAPPER, "hidden-regions.txt")
LODS = (64, 32, 16, 8)
SURFACE = 7
CHUNK_PIXELS = 512

LABEL_RE = re.compile(r'\{\s*(?:kind = "(\w+)", )?.*?\bname = "((?:[^"\\]|\\.)*)", '
                      r'position = \{ x = (\d+), y = (\d+), z = (\d+) \}')
BOUNDS_RE = re.compile(r'^\s*bounds\s*:\s*(\d+)\s*,\s*(\d+)\s*-\s*(\d+)\s*,\s*(\d+)', re.I | re.M)


def load_labels():
    """Regions (kind "region"), cities, routes and landmarks on the surface."""
    labels = []
    for line in open(LABELS_LUA, encoding="utf-8"):
        m = LABEL_RE.search(line)
        if not m or int(m.group(5)) != SURFACE:
            continue
        labels.append({"kind": m.group(1) or "region", "name": m.group(2).replace('\\"', '"'),
                       "x": int(m.group(3)), "y": int(m.group(4))})
    return labels


def load_bounds():
    """x1, y1, x2, y2 of hidden-regions.txt's bounds line, or None."""
    if not os.path.exists(HIDDEN_REGIONS):
        return None
    m = BOUNDS_RE.search(open(HIDDEN_REGIONS).read())
    if not m:
        return None
    x1, y1, x2, y2 = (int(v) for v in m.groups())
    return [min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)]


def _convert(job):
    src, dst = job
    import render_pokepedia as rp
    img = rp.read_chunk(src)
    if img.getchannel("A").getbbox() is None:
        return None
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    img.save(dst, "WEBP", lossless=True, method=4)
    return dst


def write_tiles(render_dir, out_dir, jobs=None):
    """<out_dir>/<zoom>/<x>-<y>.webp from <render_dir>/world, and <out_dir>/index.json listing
    them, so the page doesn't ask for the empty sea. Returns the number of tiles."""
    sys.path.insert(0, MAPPER)
    world = os.path.join(render_dir, "world")
    names = os.listdir(world)
    todo, index = [], {}
    for zoom, lod in enumerate(LODS):
        tiles = CHUNK_PIXELS * lod // 32
        pattern = re.compile(r"^satellite-%d-(\d+)-(\d+)-%d-pv\.bmp\.lzma$" % (lod, SURFACE))
        for name in names:
            m = pattern.match(name)
            if m:
                cx, cy = int(m.group(1)) * 32 // tiles, int(m.group(2)) * 32 // tiles
                todo.append((os.path.join(world, name), os.path.join(out_dir, str(zoom), "%d-%d.webp" % (cx, cy))))
    with Pool(jobs) as pool:
        for dst in pool.imap_unordered(_convert, todo, chunksize=16):
            if dst:
                zoom = os.path.basename(os.path.dirname(dst))
                index.setdefault(zoom, []).append(os.path.basename(dst)[:-5])
    for tiles in index.values():
        tiles.sort()
    with open(os.path.join(out_dir, "index.json"), "w") as f:
        json.dump(index, f, separators=(",", ":"), sort_keys=True)
    return sum(len(t) for t in index.values())
