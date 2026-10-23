#!/usr/bin/env python3
"""Encrypts an assembled Redemption client's modules and images.

    PV_ENCRYPTION_KEY=<key> scripts/encrypt-client.py <client dir>
    PV_ENCRYPTION_KEY=<key> scripts/encrypt-client.py --cat <file>    prints the file decrypted

The same scheme and header as the engine built with -DPV_ENCRYPTION_KEY=<key>
(src/framework/core/resourcemanager.cpp, encrypt): the header, then each byte shifted by the
key. The engine decrypts every file it reads through ResourceManager::readFileContents that
starts with the header, and reads any other file as it is, so only these are encrypted:
Lua, OTUI, OTML and OTMOD files and PNG pictures. data/things (the .spr, .dat and .otb, read
another way) and everything else stay as they are. A file that already has the header is
left alone, so running it twice is harmless.
"""
import hashlib
import os
import re
import sys

EXTENSIONS = (".lua", ".otui", ".otml", ".otmod", ".png")
SKIP = ("data/things/",)


def header_for(key):
    return ("PV" + hashlib.sha256(("pokeverse-header:" + key).encode()).hexdigest()[:20]).encode()


def encrypt(data, key):
    k = key.encode()
    n = len(k)
    out = bytearray(len(data))
    for i, b in enumerate(data):
        p = k[i % n]
        out[i] = (b - p + i) & 0xFF if i % 2 else (b + p - i) & 0xFF
    return bytes(out)


def decrypt(data, key):
    k = key.encode()
    n = len(k)
    out = bytearray(len(data))
    for i, b in enumerate(data):
        p = k[i % n]
        out[i] = (b + p - i) & 0xFF if i % 2 else (b - p + i) & 0xFF
    return bytes(out)


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
            if not name.lower().endswith(EXTENSIONS) or rel.startswith(SKIP):
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
