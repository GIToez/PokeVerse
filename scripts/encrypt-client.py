#!/usr/bin/env python3
"""Encrypts an assembled Redemption client's modules and images.

    PV_ENCRYPTION_KEY=<key> scripts/encrypt-client.py <client dir>
    PV_ENCRYPTION_KEY=<key> scripts/encrypt-client.py --cat <file>    prints the file decrypted

The same scheme and header as the engine built with -DPV_ENCRYPTION_KEY=<key>
(src/framework/core/resourcemanager.cpp, encrypt): the header, then each byte shifted by the
key. The engine decrypts every file it reads through ResourceManager::readFileContents that
starts with the header, and reads any other file as it is, so only these are encrypted:
Lua, OTUI, OTML and OTMOD files and PNG pictures, and the .spr and .dat in data/things, which
the engine reads through FileStream (src/framework/core/filestream.cpp). Everything else in
data/things (the .otb, .otfi, things.otml) and the rest stay as they are. A file that already
has the header is left alone, so running it twice is harmless.
"""
import functools
import hashlib
import math
import os
import re
import sys

EXTENSIONS = (".lua", ".otui", ".otml", ".otmod", ".png")
SKIP = ("data/things/",)
# the sprites and the object list they go with; the engine reads them with FileStream
# (cache(true), or decryptReads() for the sprite file of each loading thread)
THINGS = (".spr", ".dat")


def header_for(key):
    return ("PV" + hashlib.sha256(("pokeverse-header:" + key).encode()).hexdigest()[:20]).encode()


@functools.lru_cache(maxsize=4)
def _tables(key, sign):
    # byte i moves by (key[i % n] - i) on even i and by the opposite on odd i, so every byte
    # sitting at the same place in a period of lcm(n, 256) moves the same way: one translate
    # per place instead of a Python step per byte (data.spr is hundreds of megabytes)
    k = key.encode()
    n = len(k)
    shifts = [bytes(range(256))[d:] + bytes(range(256))[:d] for d in range(256)]
    tables = []
    for i in range(n * 256 // math.gcd(n, 256)):
        d = (k[i % n] - i) * sign
        tables.append(shifts[d & 0xFF if i % 2 == 0 else -d & 0xFF])
    return tables


def _shift(data, key, sign):
    tables = _tables(key, sign)
    period = len(tables)
    out = bytearray(len(data))
    for i in range(min(period, len(data))):
        out[i::period] = data[i::period].translate(tables[i])
    return bytes(out)


def encrypt(data, key):
    return _shift(data, key, 1)


def decrypt(data, key):
    return _shift(data, key, -1)


def main():
    if len(sys.argv) not in (2, 3) or (len(sys.argv) == 3 and sys.argv[1] != "--cat"):
        sys.exit(__doc__)
    key = os.environ.get("PV_ENCRYPTION_KEY", "")
    if not re.fullmatch(r"[A-Za-z0-9]{32,}", key):
        sys.exit("PV_ENCRYPTION_KEY: 32 or more letters and digits")
    header = header_for(key)
    if sys.argv[1] == "--cat":
        with open(sys.argv[2], "rb") as f:
            data = f.read()
        if data.startswith(header):
            data = decrypt(data[len(header):], key)
        sys.stdout.buffer.write(data)
        return
    root = sys.argv[1]
    count = size = 0
    for folder, _, files in os.walk(root):
        for name in files:
            path = os.path.join(folder, name)
            rel = os.path.relpath(path, root).replace(os.sep, "/")
            if rel.startswith(SKIP):
                if not name.lower().endswith(THINGS):
                    continue
            elif not name.lower().endswith(EXTENSIONS):
                continue
            with open(path, "rb") as f:
                data = f.read()
            if data.startswith(header):
                continue
            # a new file, not written over: with --link the old one is the repository's
            tmp = path + ".enc-tmp"
            with open(tmp, "wb") as f:
                f.write(header + encrypt(data, key))
            os.replace(tmp, path)
            count += 1
            size += len(data)
    print("encrypted %d files (%.1f MB) in %s" % (count, size / 1e6, root))


if __name__ == "__main__":
    main()
