"""Shared pieces of the scripts that edit Johto on the dev map (edit_tohjo_falls.py,
edit_johto_centers.py): reading a few regions in one pass, turning edited item lists back into
stored tiles without losing what the items carried (action ids, texts, teleport destinations) or the
tiles' flags, and moving spawns in map-spawn.xml."""
import re
import struct

import pvmap

SPAWN_BLOCK = re.compile(r'[ \t]*<spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)"[^>]*>(.*?)</spawn>\n?', re.S)


def read_boxes(data, boxes):
    """{name: {(x, y, z): RawTile}} for each (x0, y0, x1, y1) box in `boxes`, read in one pass."""
    out = {k: {} for k in boxes}
    area = cur = None
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev == 'open':
            if t == pvmap.TILE_AREA:
                area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
            elif t in (pvmap.TILE, pvmap.HOUSETILE):
                p = pvmap.unescape(data[a:b])
                x, y, z = area[0] + p[0], area[1] + p[1], area[2]
                cur = None
                for k, (x0, y0, x1, y1) in boxes.items():
                    if x0 <= x <= x1 and y0 <= y <= y1:
                        _, _, house, flags, item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)
                        cur = pvmap.RawTile(house, flags, item, b)
                        out[k][(x, y, z)] = cur
                        break
        elif t in (pvmap.TILE, pvmap.HOUSETILE) and cur is not None:
            cur.children = data[cur.children:b - 1]
            cur = None
    return out


def ids_of(tile):
    """A stored tile's server item ids, ground first."""
    if tile is None:
        return []
    return ([tile.ground] if tile.ground is not None else []) + pvmap.child_item_ids(tile.children)


def item_nodes(tile):
    """{item id: [its stored ITEM nodes]} of a tile, to reuse an item as it was stored."""
    nodes = {}
    if tile is not None:
        for blob in pvmap.split_items(tile.children):
            sid = struct.unpack_from('<H', pvmap.unescape(blob[2:6]), 0)[0]
            nodes.setdefault(sid, []).append(blob)
    return nodes


class Edit:
    """Edited tiles, kept as item lists until written. Each item that was on the tile before, or on the
    tile it was copied from, keeps its stored node; the rest are written plain."""

    def __init__(self, base):
        self.base = base      # {(x, y, z): RawTile} as on the map
        self.ids = {}         # {(x, y, z): [item ids]} for every edited tile
        self.src = {}         # {(x, y, z): RawTile} a tile was copied from (its flags and items)
        self.flags = {}       # {(x, y, z): flags} set on purpose

    def get(self, k):
        return list(self.ids[k]) if k in self.ids else ids_of(self.base.get(k))

    def set(self, k, ids, src=None, flags=None):
        self.ids[k] = list(ids)
        if src is not None:
            self.src[k] = src
        if flags is not None:
            self.flags[k] = flags

    def copy(self, k, tile):
        self.set(k, ids_of(tile), src=tile, flags=tile.flags)

    def tiles(self):
        """(new_tiles, remove) for pvmap.write_map: the tiles that changed, and the emptied ones."""
        new, remove = {}, set()
        for k, ids in self.ids.items():
            old = self.base.get(k)
            src = self.src.get(k)
            if not ids:
                if old is not None:
                    remove.add(k)
                continue
            if old is not None and src is None and k not in self.flags and ids == ids_of(old):
                continue
            pool = item_nodes(src)
            for sid, blobs in item_nodes(old).items():
                pool.setdefault(sid, []).extend(blobs)
            ground = None
            children = b''
            inline = {t.ground for t in (src, old) if t is not None and t.ground is not None}
            for n, sid in enumerate(ids):
                if n == 0 and sid in inline:
                    ground = sid
                elif pool.get(sid):
                    children += pool[sid].pop(0)
                else:
                    children += pvmap.item_node(sid)
            house = (src or old).house_id if (src or old) is not None else 0
            flags = self.flags.get(k, old.flags if old is not None else 0)
            new[k] = pvmap.RawTile(house, flags, ground, children)
        return new, remove


def edit_spawns(src, drop, add):
    """map-spawn.xml text with the spawn blocks `drop(x, y, z, body)` picks taken out and `add`
    (center (x, y, z), [(kind, name, dx, dy)]) put in before the end."""
    out = SPAWN_BLOCK.sub(lambda m: '' if drop(int(m[1]), int(m[2]), int(m[3]), m[4]) else m[0], src)
    blocks = []
    for (x, y, z), members in add:
        lines = ''.join('    <%s name="%s" x="%d" y="%d" z="%d" spawntime="60" level="0"/>\n' % (kind, name, dx, dy, z)
                        for kind, name, dx, dy in members)
        blocks.append('  <spawn centerx="%d" centery="%d" centerz="%d" radius="1">\n%s  </spawn>\n' % (x, y, z, lines))
    i = out.rindex('</spawns>')
    return out[:i] + ''.join(blocks) + out[i:]
