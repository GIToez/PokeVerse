"""Shared readers and writers for the PokeVerse map tools.

OTBM is the RME/TFS map format: a tree of nodes, each `FE <type> <props> <children> FF`,
with FD escaping any FD/FE/FF byte inside the props. The map is far too big to load as
objects, so readers stream the file and only keep what is asked for, and the writer
copies the original bytes and splices new nodes in.
"""
import re
import struct

ESCAPE, START, END = 0xFD, 0xFE, 0xFF
SPECIAL = re.compile(rb'[\xfd\xfe\xff]')
UNESCAPE = re.compile(rb'\xfd(.)', re.S)

# OTBM node types
ROOT, MAP_DATA, TILE_AREA, TILE, ITEM, TOWNS, TOWN, HOUSETILE, WAYPOINTS, WAYPOINT = 0, 2, 4, 5, 6, 12, 13, 14, 15, 16
# OTBM attributes
A_DESCRIPTION, A_TILE_FLAGS, A_ACTION_ID, A_UNIQUE_ID, A_TEXT, A_TELE_DEST, A_ITEM, A_DEPOT_ID = 1, 3, 4, 5, 6, 8, 9, 10
A_SPAWN_FILE, A_RUNE_CHARGES, A_HOUSE_FILE, A_HOUSE_DOOR_ID, A_COUNT = 11, 12, 13, 14, 15


def unescape(b):
    return UNESCAPE.sub(rb'\1', b)


def escape(b):
    out = bytearray()
    for c in b:
        if c in (ESCAPE, START, END):
            out.append(ESCAPE)
        out.append(c)
    return bytes(out)


def walk(data, start=4):
    """Yields (event, node_type, depth, props_start, props_end_or_node_end).

    event 'open' fires when a node's props are complete (props_end is the first child or
    the node end); event 'close' fires at the node's FF with the index just after it.
    """
    stack = []
    i = start
    find = SPECIAL.search
    while True:
        m = find(data, i)
        if not m:
            return
        j = m.start()
        c = data[j]
        if c == ESCAPE:
            i = j + 2
            continue
        if stack and stack[-1][2] is None:
            stack[-1][2] = j
            yield 'open', stack[-1][0], len(stack) - 1, stack[-1][1], j, stack[-1][3]
        if c == START:
            stack.append([data[j + 1], j + 2, None, j])
            i = j + 2
        else:
            node = stack.pop()
            yield 'close', node[0], len(stack), node[3], j + 1, None
            i = j + 1


def parse_tile_props(p, house):
    """Returns (x_off, y_off, house_id, flags, inline item id or None)."""
    off = 2
    house_id = 0
    if house:
        house_id = struct.unpack_from('<I', p, 2)[0]
        off = 6
    flags = 0
    item = None
    while off < len(p):
        a = p[off]
        off += 1
        if a == A_TILE_FLAGS:
            flags = struct.unpack_from('<I', p, off)[0]
            off += 4
        elif a == A_ITEM:
            item = struct.unpack_from('<H', p, off)[0]
            off += 2
        else:
            break
    return p[0], p[1], house_id, flags, item


def read_region(path, x0, y0, x1, y1, floors=range(16), data=None):
    """Returns {(x, y, z): [server item ids in stored order]} for tiles inside the box."""
    if data is None:
        data = open(path, 'rb').read()
    floors = set(floors)
    tiles = {}
    area = None
    cur = None
    for ev, t, depth, a, b, _ in walk(data):
        if ev != 'open':
            if t in (TILE, HOUSETILE):
                cur = None
            continue
        if t == TILE_AREA:
            area = struct.unpack_from('<HHB', unescape(data[a:b]), 0)
        elif t in (TILE, HOUSETILE):
            p = unescape(data[a:b])
            x, y, z = area[0] + p[0], area[1] + p[1], area[2]
            if x0 <= x <= x1 and y0 <= y <= y1 and z in floors:
                _, _, _, _, item = parse_tile_props(p, t == HOUSETILE)
                cur = tiles.setdefault((x, y, z), [])
                if item is not None:
                    cur.append(item)
            else:
                cur = None
        elif t == ITEM and cur is not None and depth == 4:
            cur.append(struct.unpack_from('<H', unescape(data[a:a + 4]), 0)[0])
    return tiles


def read_region_raw(path, x0, y0, x1, y1, floors=range(16), data=None):
    """Returns {(x, y, z): RawTile} for tiles inside the box, keeping item nodes byte for byte."""
    if data is None:
        data = open(path, 'rb').read()
    floors = set(floors)
    tiles = {}
    area = None
    cur = None
    for ev, t, depth, a, b, _ in walk(data):
        if ev == 'open':
            if t == TILE_AREA:
                area = struct.unpack_from('<HHB', unescape(data[a:b]), 0)
            elif t in (TILE, HOUSETILE):
                p = unescape(data[a:b])
                x, y, z = area[0] + p[0], area[1] + p[1], area[2]
                if x0 <= x <= x1 and y0 <= y <= y1 and z in floors:
                    _, _, house_id, flags, item = parse_tile_props(p, t == HOUSETILE)
                    cur = RawTile(house_id, flags, item, b)
                    tiles[(x, y, z)] = cur
                else:
                    cur = None
        elif t in (TILE, HOUSETILE) and cur is not None:
            cur.children = data[cur.children:b - 1]
            cur = None
    return tiles


def read_tiles(path, positions, data=None):
    """Returns {(x, y, z): [server item ids]} for the given positions that have a tile."""
    if data is None:
        data = open(path, 'rb').read()
    positions = set(positions)
    tiles = {}
    area = None
    cur = None
    for ev, t, depth, a, b, _ in walk(data):
        if ev != 'open':
            if t in (TILE, HOUSETILE):
                cur = None
            continue
        if t == TILE_AREA:
            area = struct.unpack_from('<HHB', unescape(data[a:b]), 0)
        elif t in (TILE, HOUSETILE):
            p = unescape(data[a:b])
            pos = (area[0] + p[0], area[1] + p[1], area[2])
            if pos in positions:
                _, _, _, _, item = parse_tile_props(p, t == HOUSETILE)
                cur = tiles.setdefault(pos, [])
                if item is not None:
                    cur.append(item)
            else:
                cur = None
        elif t == ITEM and cur is not None and depth == 4:
            cur.append(struct.unpack_from('<H', unescape(data[a:a + 4]), 0)[0])
    return tiles


class RawTile:
    """A tile as stored: house id, flags, inline ground id, and its child ITEM nodes still escaped."""

    def __init__(self, house_id=0, flags=0, ground=None, children=b''):
        self.house_id = house_id
        self.flags = flags
        self.ground = ground
        self.children = children

    def encode(self, x_off, y_off):
        props = bytes([x_off, y_off])
        if self.house_id:
            props += struct.pack('<I', self.house_id)
        if self.flags:
            props += bytes([A_TILE_FLAGS]) + struct.pack('<I', self.flags)
        if self.ground is not None:
            props += bytes([A_ITEM]) + struct.pack('<H', self.ground)
        kind = HOUSETILE if self.house_id else TILE
        return bytes([START, kind]) + escape(props) + self.children + bytes([END])


def item_node(sid, action_id=None, text=None):
    props = struct.pack('<H', sid)
    if action_id:
        props += bytes([A_ACTION_ID]) + struct.pack('<H', action_id)
    if text:
        props += bytes([A_TEXT]) + struct.pack('<H', len(text)) + text.encode('latin-1')
    return bytes([START, ITEM]) + escape(props) + bytes([END])


def child_item_ids(children):
    """Server ids of the top-level ITEM nodes in an escaped children blob."""
    ids = []
    for ev, t, depth, a, b, _ in walk(children, 0):
        if ev == 'open' and depth == 0:
            ids.append(struct.unpack_from('<H', unescape(children[a:a + 4]), 0)[0])
    return ids


def split_items(children):
    """Splits an escaped children blob into its top-level ITEM node blobs."""
    out = []
    for ev, t, depth, a, b, _ in walk(children, 0):
        if ev == 'close' and depth == 0:
            out.append(children[a:b])
    return out


def encode_town(town_id, name, x, y, z):
    props = struct.pack('<I', town_id) + struct.pack('<H', len(name)) + name.encode('latin-1') + struct.pack('<HHB', x, y, z)
    return bytes([START, TOWN]) + escape(props) + bytes([END])


def encode_areas(tiles):
    """tiles: {(x, y, z): RawTile} -> TILE_AREA node bytes, one area per 256x256 block and floor."""
    blocks = {}
    for (x, y, z), tile in tiles.items():
        blocks.setdefault((x & ~0xFF, y & ~0xFF, z), []).append((x, y, tile))
    out = bytearray()
    for (bx, by, z), items in sorted(blocks.items()):
        out += bytes([START, TILE_AREA]) + escape(struct.pack('<HHB', bx, by, z))
        for x, y, tile in sorted(items, key=lambda i: (i[1], i[0])):
            out += tile.encode(x - bx, y - by)
        out.append(END)
    return bytes(out)


def write_map(data, out_path, new_tiles, remove=(), towns=()):
    """Writes `data` (an OTBM file's bytes) to out_path with tiles added, replaced and towns added.

    new_tiles: {(x, y, z): RawTile}. Existing tiles at those positions, and at any position in
    `remove`, are dropped. towns: (id, name, x, y, z) tuples appended to the town list.
    """
    drop = set(new_tiles) | set(remove)
    cuts = []
    towns_start = towns_end = None
    area = None
    pos = None
    for ev, t, depth, a, b, _ in walk(data):
        if ev == 'open':
            if t == TILE_AREA:
                area = struct.unpack_from('<HHB', unescape(data[a:b]), 0)
            elif t in (TILE, HOUSETILE) and depth == 3:
                p = unescape(data[a:a + 4])
                pos = (area[0] + p[0], area[1] + p[1], area[2])
            elif t == TOWNS:
                towns_start = a - 2
        else:
            if t in (TILE, HOUSETILE) and depth == 3 and pos in drop:
                cuts.append((a, b))
            elif t == TOWNS:
                towns_end = b - 1
    if towns_start is None:
        raise ValueError('map has no town list')
    with open(out_path, 'wb') as f:
        i = 0
        for a, b in cuts:
            f.write(data[i:a])
            i = b
        f.write(data[i:towns_start])
        f.write(encode_areas(new_tiles))
        f.write(data[towns_start:towns_end])
        for town in towns:
            f.write(encode_town(*town))
        f.write(data[towns_end:])
    return len(cuts)


class Otb:
    """items.otb: server id -> (client id, group, flags)."""

    def __init__(self, path):
        data = open(path, 'rb').read()
        self.items = {}
        for ev, t, depth, a, b, _ in walk(data):
            if ev != 'open' or depth != 1:
                continue
            p = unescape(data[a:b])
            flags = struct.unpack_from('<I', p, 0)[0]
            off = 4
            sid = cid = None
            while off + 3 <= len(p):
                attr = p[off]
                ln = struct.unpack_from('<H', p, off + 1)[0]
                if attr == 0x10:
                    sid = struct.unpack_from('<H', p, off + 3)[0]
                elif attr == 0x11:
                    cid = struct.unpack_from('<H', p, off + 3)[0]
                off += 3 + ln
            if sid is not None:
                self.items[sid] = (cid, t, flags)

    def client_id(self, sid):
        v = self.items.get(sid)
        return v[0] if v else None

    def blocks(self, sid):
        v = self.items.get(sid)
        return bool(v and v[2] & 1)


class Dat:
    """PokeVerse data.dat (8.54 layout, u32 sprite ids). Only items are indexed."""
    U16 = {0, 9, 10, 26, 29, 30}
    U16X2 = {22, 25}
    MARKET = 33

    def __init__(self, path):
        data = open(path, 'rb').read()
        self.signature, self.count = struct.unpack_from('<IH', data, 0)
        self.things = {}
        i = 12
        for cid in range(100, self.count + 1):
            attrs = {}
            while True:
                a = data[i]
                i += 1
                if a == 0xFF:
                    break
                if a in self.U16:
                    attrs[a] = struct.unpack_from('<H', data, i)[0]
                    i += 2
                elif a in self.U16X2:
                    attrs[a] = struct.unpack_from('<HH', data, i)
                    i += 4
                elif a == self.MARKET:
                    i += 6
                    n = struct.unpack_from('<H', data, i)[0]
                    i += 2 + n + 4
                else:
                    attrs[a] = True
            w, h = data[i], data[i + 1]
            i += 2
            if w > 1 or h > 1:
                i += 1
            layers, px, py, pz, frames = data[i:i + 5]
            i += 5
            n = w * h * layers * px * py * pz * frames
            sprites = struct.unpack_from('<%dI' % n, data, i)
            i += 4 * n
            self.things[cid] = (attrs, w, h, layers, px, py, pz, frames, sprites)


class Spr:
    def __init__(self, path):
        self.f = open(path, 'rb')
        self.signature, self.count = struct.unpack('<II', self.f.read(8))
        self.cache = {}

    def rgba(self, sid):
        """Returns 32*32*4 RGBA bytes, or None for an empty sprite."""
        if sid == 0 or sid > self.count:
            return None
        if sid in self.cache:
            return self.cache[sid]
        self.f.seek(8 + (sid - 1) * 4)
        off = struct.unpack('<I', self.f.read(4))[0]
        if off == 0:
            self.cache[sid] = None
            return None
        self.f.seek(off + 3)
        size = struct.unpack('<H', self.f.read(2))[0]
        raw = self.f.read(size)
        px = bytearray(32 * 32 * 4)
        pos = 0
        j = 0
        while j + 4 <= size:
            transparent, colored = struct.unpack_from('<HH', raw, j)
            j += 4
            pos += transparent * 4
            n = colored * 4
            px[pos:pos + n] = raw[j:j + n]
            pos += n
            j += n
        self.cache[sid] = bytes(px)
        return self.cache[sid]
