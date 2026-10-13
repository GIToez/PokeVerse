"""Draws client items as PNG images, straight from the game's items.otb, data.dat and data.spr.

    from sprites import ItemImages
    images = ItemImages("core/server/data/items/items.otb", "core/client-legacy/data/things")
    png = images.png(server_item_id)    # bytes, or None if the item has no sprite

Only the first frame and pattern of an item is drawn, which is how the client shows
portraits and icons.
"""
import importlib.util
import os
import struct
import zlib

SCRIPTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scripts")
TILE = 32


def _script(name):
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), os.path.join(SCRIPTS, name + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


_otb = _script("otb-add-item")
_dat = _script("dat-add-items")


def server_to_client_ids(otb_path):
    data = open(otb_path, "rb").read()
    _, _, children, _ = _otb.read_node(data, 4)
    ids = {}
    for start, _ in children:
        _, props, _, _ = _otb.read_node(data, start)
        _, attrs = _otb.item_attrs(props)
        values = dict(attrs)
        if _otb.ATTR_SERVERID in values and _otb.ATTR_CLIENTID in values:
            server_id = struct.unpack("<H", values[_otb.ATTR_SERVERID])[0]
            ids[server_id] = struct.unpack("<H", values[_otb.ATTR_CLIENTID])[0]
    return ids


def _thing_sprites(data, start, end, pattern_x=0):
    """(width, height, sprite ids in draw order) for frame 0, layer 0 and the given
    horizontal pattern (the direction, for outfits) of the thing in data[start:end]."""
    i = start
    while data[i] != _dat.LAST_ATTR:
        attr = data[i]
        i += 1
        if attr in _dat.U16_ATTRS:
            i += 2
        elif attr in _dat.U16X2_ATTRS:
            i += 4
        elif attr == _dat.MARKET_ATTR:
            i += 6
            i += 2 + struct.unpack_from("<H", data, i)[0] + 4
    i += 1
    width, height = data[i], data[i + 1]
    i += 2
    if width > 1 or height > 1:
        i += 1
    layers, patterns_x = data[i], data[i + 1]
    i += 5
    count = (end - i) // 4
    ids = struct.unpack_from("<%dI" % count, data, i)
    tiles = width * height
    first = (min(pattern_x, patterns_x - 1) * layers) * tiles
    return width, height, ids[first:first + tiles]


class ItemImages:
    def __init__(self, otb_path, things_dir):
        self.client_ids = server_to_client_ids(otb_path)
        self.dat = open(os.path.join(things_dir, "data.dat"), "rb").read()
        _, _, outfits, _, _, self.offsets, items_end = _dat.parse(self.dat)
        self.outfit_offsets = {}
        i = items_end
        for outfit_id in range(1, outfits + 1):
            end = _dat.read_thing(self.dat, i)
            self.outfit_offsets[outfit_id] = (i, end)
            i = end
        self.spr = open(os.path.join(things_dir, "data.spr"), "rb")
        _, self.sprite_count = struct.unpack("<II", self.spr.read(8))

    def _sprite(self, sprite_id):
        """32x32 RGBA bytes, or None for an empty sprite."""
        if sprite_id == 0 or sprite_id > self.sprite_count:
            return None
        self.spr.seek(8 + 4 * (sprite_id - 1))
        offset = struct.unpack("<I", self.spr.read(4))[0]
        if offset == 0:
            return None
        self.spr.seek(offset + 3)
        size = struct.unpack("<H", self.spr.read(2))[0]
        data = self.spr.read(size)
        pixels = bytearray(TILE * TILE * 4)
        pos = 0
        i = 0
        while i + 4 <= len(data):
            transparent, colored = struct.unpack_from("<HH", data, i)
            i += 4
            pos += transparent * 4
            n = colored * 4
            pixels[pos:pos + n] = data[i:i + n]
            pos += n
            i += n
        return bytes(pixels)

    def rgba(self, server_id):
        """(width, height, RGBA bytes) for the item, or None."""
        client_id = self.client_ids.get(server_id)
        if client_id not in self.offsets:
            return None
        return self._draw(*self.offsets[client_id])

    def client_rgba(self, client_id):
        """Like rgba() for an id the client uses directly (no items.otb entry)."""
        if client_id not in self.offsets:
            return None
        return self._draw(*self.offsets[client_id])

    def outfit_rgba(self, look_type):
        """The outfit (a monster's look type) standing and facing south, or None."""
        if look_type not in self.outfit_offsets:
            return None
        return self._draw(*self.outfit_offsets[look_type], pattern_x=2)

    def _draw(self, start, end, pattern_x=0):
        w, h, ids = _thing_sprites(self.dat, start, end, pattern_x)
        if not ids:
            return None
        width, height = w * TILE, h * TILE
        canvas = bytearray(width * height * 4)
        drawn = False
        for index, sprite_id in enumerate(ids):
            tile = self._sprite(sprite_id)
            if tile is None:
                continue
            drawn = True
            # tiles are stored right to left, bottom to top
            tx = (w - 1 - index % w) * TILE
            ty = (h - 1 - index // w) * TILE
            for row in range(TILE):
                line = tile[row * TILE * 4:(row + 1) * TILE * 4]
                at = ((ty + row) * width + tx) * 4
                canvas[at:at + TILE * 4] = line
        return (width, height, bytes(canvas)) if drawn else None

    def png(self, server_id):
        image = self.rgba(server_id)
        return encode_png(*image) if image else None

    def outfit_png(self, look_type):
        image = self.outfit_rgba(look_type)
        return encode_png(*image) if image else None


def encode_png(width, height, rgba):
    def chunk(kind, body):
        return struct.pack(">I", len(body)) + kind + body + struct.pack(">I", zlib.crc32(kind + body) & 0xFFFFFFFF)

    stride = width * 4
    raw = b"".join(b"\x00" + rgba[y * stride:(y + 1) * stride] for y in range(height))
    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
