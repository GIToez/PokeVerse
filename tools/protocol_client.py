#!/usr/bin/env python3
"""DEVELOPMENT ONLY. Headless PokeVerse protocol client (Python standard library only).

Speaks the same login and game protocol as the legacy client
(docs/REDEMPTION_PROTOCOL_COMPATIBILITY.md, sections 3-5), so a server can be tested on any
platform, including Windows CI runners without a desktop. It does not render or parse the
game state: it logs in, waits for the login-success packet, optionally says text (GM
commands) and logs out.

Usage:
  tools/protocol_client.py charlist ACCOUNT PASSWORD
  tools/protocol_client.py enter ACCOUNT PASSWORD CHARACTER [--say TEXT ...] [--stay SECONDS]
Environment: PV_HOST (127.0.0.1), PV_LOGIN_PORT (7564), PV_GAME_PORT (8548).
"""
import argparse
import os
import random
import socket
import struct
import sys
import time
import zlib

# Public half of the development OTServ key that server/source/otserv.cpp loads.
RSA_N = (14299623962416399520070177382898895550795403345466153217470516082934737582776038882967213386204600674145392845853859217990626450972452084065728686565928113
         * 7630979195970404721891201847792002125535401292779123937207447574596692788513647179235335529307251350570728407373705564708871762033017096809910315212884101)
RSA_E = 65537

OS_OTCLIENT_LINUX = 0x0B
PROTOCOL_VERSION = 312
SPEAK_SAY = 1


def adler32(data):
    return zlib.adler32(data) & 0xFFFFFFFF


def xtea_encrypt(key, data):
    out = bytearray()
    for i in range(0, len(data), 8):
        v0, v1 = struct.unpack_from("<2I", data, i)
        s = 0
        for _ in range(32):
            v0 = (v0 + ((((v1 << 4) ^ (v1 >> 5)) + v1) ^ (s + key[s & 3]))) & 0xFFFFFFFF
            s = (s + 0x9E3779B9) & 0xFFFFFFFF
            v1 = (v1 + ((((v0 << 4) ^ (v0 >> 5)) + v0) ^ (s + key[(s >> 11) & 3]))) & 0xFFFFFFFF
        out += struct.pack("<2I", v0, v1)
    return bytes(out)


def xtea_decrypt(key, data):
    out = bytearray()
    for i in range(0, len(data), 8):
        v0, v1 = struct.unpack_from("<2I", data, i)
        s = 0xC6EF3720
        for _ in range(32):
            v1 = (v1 - ((((v0 << 4) ^ (v0 >> 5)) + v0) ^ (s + key[(s >> 11) & 3]))) & 0xFFFFFFFF
            s = (s - 0x9E3779B9) & 0xFFFFFFFF
            v0 = (v0 - ((((v1 << 4) ^ (v1 >> 5)) + v1) ^ (s + key[s & 3]))) & 0xFFFFFFFF
        out += struct.pack("<2I", v0, v1)
    return bytes(out)


def rsa_encrypt(block):
    assert len(block) == 128
    return pow(int.from_bytes(block, "big"), RSA_E, RSA_N).to_bytes(128, "big")


def pstr(text):
    raw = text.encode("latin-1")
    return struct.pack("<H", len(raw)) + raw


class Reader:
    def __init__(self, data):
        self.data, self.pos = data, 0

    def u8(self):
        self.pos += 1
        return self.data[self.pos - 1]

    def u16(self):
        self.pos += 2
        return struct.unpack_from("<H", self.data, self.pos - 2)[0]

    def u32(self):
        self.pos += 4
        return struct.unpack_from("<I", self.data, self.pos - 4)[0]

    def string(self):
        n = self.u16()
        self.pos += n
        return self.data[self.pos - n:self.pos].decode("latin-1")

    def left(self):
        return len(self.data) - self.pos


class Connection:
    def __init__(self, host, port, timeout=15):
        self.sock = socket.create_connection((host, port), timeout=timeout)
        self.key = None

    def close(self):
        self.sock.close()

    def _recv_exact(self, n):
        buf = b""
        while len(buf) < n:
            chunk = self.sock.recv(n - len(buf))
            if not chunk:
                raise ConnectionError("connection closed by server")
            buf += chunk
        return buf

    def send(self, payload):
        if self.key:
            inner = struct.pack("<H", len(payload)) + payload
            inner += b"\0" * (-len(inner) % 8)
            body = xtea_encrypt(self.key, inner)
        else:
            body = payload
        body = struct.pack("<I", adler32(body)) + body
        self.sock.sendall(struct.pack("<H", len(body)) + body)

    def recv(self):
        """One server packet, decrypted and without framing."""
        size = struct.unpack("<H", self._recv_exact(2))[0]
        body = self._recv_exact(size)
        checksum, body = struct.unpack_from("<I", body)[0], body[4:]
        if checksum != adler32(body):
            raise ValueError("bad Adler-32 checksum from server")
        if self.key:
            body = xtea_decrypt(self.key, body)
        inner = struct.unpack_from("<H", body)[0]
        return body[2:2 + inner]


def rsa_block(*parts):
    block = b"\0" + b"".join(parts)
    if len(block) > 128:
        raise ValueError("credentials too long for one RSA block")
    return rsa_encrypt(block + bytes(random.randrange(256) for _ in range(128 - len(block))))


def new_key():
    return [random.getrandbits(32) for _ in range(4)]


def charlist(host, port, account, password, lang=0):
    key = new_key()
    conn = Connection(host, port)
    try:
        conn.send(struct.pack("<BHHB", 0x01, OS_OTCLIENT_LINUX, PROTOCOL_VERSION, lang)
                  + b"\0" * 12
                  + rsa_block(struct.pack("<4I", *key), pstr(account), pstr(password)))
        conn.key = key
        msg = Reader(conn.recv())
    finally:
        conn.close()
    result = {"motd": None, "characters": [], "error": None}
    while msg.left():
        op = msg.u8()
        if op == 0x0A:
            result["error"] = msg.string()
        elif op == 0x14:
            result["motd"] = msg.string()
        elif op == 0x64:
            for _ in range(msg.u8()):
                char = {"name": msg.string(), "world": msg.string(), "ip": msg.u32(), "port": msg.u16()}
                char["level"], char["vocation"], char["looktype"] = msg.u16(), msg.u8(), msg.u16()
                msg.pos += 5  # head, body, legs, feet, addons
                char["pokemons"] = [(msg.u16(), msg.string()) for _ in range(msg.u8())]
                result["characters"].append(char)
            result["premium_days"] = msg.u16()
            result["poll"] = msg.u8()
        else:
            raise ValueError(f"unexpected login opcode 0x{op:02X}")
    return result


class GameSession:
    def __init__(self, host, port, account, password, character, gamemaster=False):
        self.conn = Connection(host, port)
        challenge = self.conn.recv()
        if not challenge or challenge[0] != 0x1F:
            raise ValueError(f"expected login challenge 0x1F, got {challenge[:1].hex()}")
        key = new_key()
        self.conn.send(struct.pack("<BHH", 0x0A, OS_OTCLIENT_LINUX, PROTOCOL_VERSION)
                       + rsa_block(struct.pack("<4IB", *key, int(gamemaster)), pstr(account),
                                   pstr(character), pstr(password), challenge[1:6]))
        self.conn.key = key
        # PSoul 0xFF packets (for example for GM characters) can arrive before the login success.
        seen = []
        for _ in range(50):
            packet = self.conn.recv()
            if packet[:1] == b"\x14":
                raise PermissionError(Reader(packet[1:]).string())
            if packet[:1] == b"\x16":
                raise PermissionError("wait list: " + Reader(packet[1:]).string())
            if packet[:1] == b"\x0A":
                self.player_id = struct.unpack_from("<I", packet, 1)[0]
                return
            seen.append(f"0x{packet[0]:02X}" if packet else "empty")
        raise ValueError("no login success 0x0A; got " + " ".join(seen))

    def say(self, text):
        self.conn.send(struct.pack("<BB", 0x96, SPEAK_SAY) + pstr(text))

    def pump(self, seconds):
        """Read and discard server packets, answering pings, for `seconds`."""
        end = time.time() + seconds
        self.conn.sock.settimeout(0.5)
        try:
            while time.time() < end:
                try:
                    packet = self.conn.recv()
                except socket.timeout:
                    continue
                if packet[:1] == b"\x1E":
                    self.conn.send(b"\x1E")
        finally:
            self.conn.sock.settimeout(15)

    def logout(self):
        self.conn.send(b"\x14")
        try:
            self.pump(3)
        except ConnectionError:
            pass
        self.conn.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("charlist")
    p.add_argument("account")
    p.add_argument("password")
    p = sub.add_parser("enter")
    p.add_argument("account")
    p.add_argument("password")
    p.add_argument("character")
    p.add_argument("--say", action="append", default=[])
    p.add_argument("--stay", type=float, default=2.0)
    args = parser.parse_args()

    host = os.environ.get("PV_HOST", "127.0.0.1")
    try:
        if args.cmd == "charlist":
            result = charlist(host, int(os.environ.get("PV_LOGIN_PORT", 7564)), args.account, args.password)
            if result["error"]:
                print("LOGIN ERROR: " + result["error"])
                return 1
            for char in result["characters"]:
                print(f"{char['name']}\t{char['world']}\tlevel {char['level']}\tport {char['port']}"
                      f"\t{len(char['pokemons'])} pokemon")
            return 0
        session = GameSession(host, int(os.environ.get("PV_GAME_PORT", 8548)),
                              args.account, args.password, args.character)
        print(f"ENTERED {args.character} (player id {session.player_id})")
        session.pump(1)
        for text in args.say:
            session.say(text)
            session.pump(1)
        session.pump(args.stay)
        session.logout()
        print(f"LOGGED OUT {args.character}")
        return 0
    except (OSError, ValueError, PermissionError) as exc:
        print(f"FAIL: {type(exc).__name__}: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
