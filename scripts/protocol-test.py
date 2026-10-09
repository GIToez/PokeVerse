#!/usr/bin/env python3
"""End-to-end protocol test for the PokeVerse server (client protocol 8.54, version 312).

Logs in like the legacy client does, reads the character list, enters the game
with a character, walks a few steps and logs out. Exit code 0 means every step
succeeded. Standard library only, so it runs on Windows and Linux CI runners.

Usage:
  protocol-test.py --account test --password test --character Trainer \
                   [--host 127.0.0.1] [--login-port 7564] [--walk east,east,south]
"""
import argparse
import os
import socket
import struct
import sys
import time
import zlib

# Standard OpenTibia RSA public key (same as server src/otserv.cpp and client modules/gamelib/const.lua).
RSA_N = int(
    "109120132967399429278860960508995541528237502902798129123468757937266291492576446330739696001110603907230888610072655818825358503429057592827629436413108566029093628212635953836686562675849720620786279431090218017681061521755056710823876476444260558147179707119674283982419152118103759076030616683978566631413"
)
RSA_E = 65537
CLIENT_OS = 0x0A  # CLIENTOS_OTCLIENT_WINDOWS
CLIENT_VERSION = 312

WALK_OPCODES = {"north": 0x65, "east": 0x66, "south": 0x67, "west": 0x68}


class ProtocolError(Exception):
    pass


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
        s = (0x9E3779B9 * 32) & 0xFFFFFFFF
        for _ in range(32):
            v1 = (v1 - ((((v0 << 4) ^ (v0 >> 5)) + v0) ^ (s + key[(s >> 11) & 3]))) & 0xFFFFFFFF
            s = (s - 0x9E3779B9) & 0xFFFFFFFF
            v0 = (v0 - ((((v1 << 4) ^ (v1 >> 5)) + v1) ^ (s + key[s & 3]))) & 0xFFFFFFFF
        out += struct.pack("<2I", v0, v1)
    return bytes(out)


def rsa_encrypt(block):
    assert len(block) == 128
    c = pow(int.from_bytes(block, "big"), RSA_E, RSA_N)
    return c.to_bytes(128, "big")


def pstr(s):
    b = s.encode("latin-1")
    return struct.pack("<H", len(b)) + b


class Reader:
    def __init__(self, data):
        self.data, self.pos = data, 0

    def u8(self):
        v = self.data[self.pos]
        self.pos += 1
        return v

    def u16(self):
        v = struct.unpack_from("<H", self.data, self.pos)[0]
        self.pos += 2
        return v

    def u32(self):
        v = struct.unpack_from("<I", self.data, self.pos)[0]
        self.pos += 4
        return v

    def string(self):
        n = self.u16()
        v = self.data[self.pos:self.pos + n].decode("latin-1")
        self.pos += n
        return v


class Connection:
    def __init__(self, host, port, timeout):
        self.sock = socket.create_connection((host, port), timeout=timeout)
        self.key = None

    def close(self):
        try:
            self.sock.close()
        except OSError:
            pass

    def _recv_exact(self, n):
        buf = b""
        while len(buf) < n:
            chunk = self.sock.recv(n - len(buf))
            if not chunk:
                raise ProtocolError("connection closed by server")
            buf += chunk
        return buf

    def send_first(self, payload):
        framed = struct.pack("<I", adler32(payload)) + payload
        self.sock.sendall(struct.pack("<H", len(framed)) + framed)

    def send(self, payload):
        body = struct.pack("<H", len(payload)) + payload
        body += b"\x00" * ((8 - len(body) % 8) % 8)
        enc = xtea_encrypt(self.key, body)
        framed = struct.pack("<I", adler32(enc)) + enc
        self.sock.sendall(struct.pack("<H", len(framed)) + framed)

    def recv(self):
        size = struct.unpack("<H", self._recv_exact(2))[0]
        data = self._recv_exact(size)
        checksum, body = struct.unpack_from("<I", data)[0], data[4:]
        if checksum != adler32(body):
            raise ProtocolError("bad checksum from server")
        if self.key:
            body = xtea_decrypt(self.key, body)
        inner = struct.unpack_from("<H", body)[0]
        return body[2:2 + inner]


def new_xtea_key():
    return list(struct.unpack("<4I", os.urandom(16)))


def login(args):
    conn = Connection(args.host, args.login_port, args.timeout)
    try:
        key = new_xtea_key()
        rsa_block = b"\x00" + struct.pack("<4I", *key) + pstr(args.account) + pstr(args.password)
        rsa_block += b"\x00" * (128 - len(rsa_block))
        payload = struct.pack("<BHHB", 0x01, CLIENT_OS, CLIENT_VERSION, 0)  # protocol, os, version, language
        payload += b"\x00" * 12  # dat, spr and pic signatures (not checked by the server)
        payload += rsa_encrypt(rsa_block)
        conn.send_first(payload)
        conn.key = key

        msg = Reader(conn.recv())
        characters = []
        while msg.pos < len(msg.data):
            op = msg.u8()
            if op == 0x0A:
                raise ProtocolError("login refused: " + msg.string())
            elif op == 0x14:
                msg.string()  # motd
            elif op == 0x64:
                for _ in range(msg.u8()):
                    name, world = msg.string(), msg.string()
                    ip, port = msg.u32(), msg.u16()
                    characters.append((name, world, socket.inet_ntoa(struct.pack("<I", ip)), port))
                    # OTClient extras: level, vocation, outfit (type, 4 colors, addons), Pokemon team.
                    msg.u16(), msg.u8(), msg.u16()
                    for _ in range(5):
                        msg.u8()
                    for _ in range(msg.u8()):
                        msg.u16(), msg.string()
                break
            else:
                raise ProtocolError("unexpected login opcode 0x%02X" % op)
        return characters
    finally:
        conn.close()


def enter_game(args, host, port):
    conn = Connection(host, port, args.timeout)
    challenge = Reader(conn.recv())
    if challenge.u8() != 0x1F:
        raise ProtocolError("expected challenge packet")
    c_time, c_zero, c_rand = challenge.u16(), challenge.u16(), challenge.u8()

    key = new_xtea_key()
    rsa_block = b"\x00" + struct.pack("<4I", *key) + b"\x00"  # first byte, xtea key, gamemaster flag
    rsa_block += pstr(args.account) + pstr(args.character) + pstr(args.password)
    rsa_block += struct.pack("<HHB", c_time, c_zero, c_rand)
    rsa_block += b"\x00" * (128 - len(rsa_block))
    conn.send_first(struct.pack("<BHH", 0x0A, CLIENT_OS, CLIENT_VERSION) + rsa_encrypt(rsa_block))
    conn.key = key

    deadline = time.time() + args.timeout
    while time.time() < deadline:
        data = conn.recv()
        if not data:
            continue
        op = data[0]
        if op == 0x14:
            raise ProtocolError("game login refused: " + Reader(data[1:]).string())
        if op == 0x16:
            raise ProtocolError("placed in the wait list")
        if op == 0x0A:
            player_id = struct.unpack_from("<I", data, 1)[0]
            # 0x0A id(4) beat(2) canReportBugs(1) lightHour(2, OTClient only),
            # then optional 0x0B violation flags (20 bytes), then 0x64 map description.
            position = None
            i = 10
            if len(data) > i and data[i] == 0x0B:
                i += 21
            if len(data) >= i + 6 and data[i] == 0x64:
                position = struct.unpack_from("<HHB", data, i + 1)
            return conn, player_id, position
    raise ProtocolError("timed out waiting for game login")


def drain(conn, seconds):
    """Reads server packets for a while and returns them."""
    seen = []
    conn.sock.settimeout(0.5)
    end = time.time() + seconds
    while time.time() < end:
        try:
            data = conn.recv()
            if data:
                seen.append(data)
        except socket.timeout:
            continue
        except ProtocolError:
            break
    return seen


def parse_quest_log(data):
    msg = Reader(data[1:])
    quests = []
    for _ in range(msg.u16()):
        quests.append((msg.u16(), msg.string(), msg.u8()))
    return quests


def check_quest_log(conn):
    """Opens the quest log and every quest in it, like clicking through the client's quest window."""
    conn.send(b"\xF0")
    packets = drain(conn, 3)
    log = [d[d.index(b"\xF0"):] for d in packets if d and d[0] == 0xF0]
    if not log:
        raise ProtocolError("no quest log reply (did the server crash?)")
    quests = parse_quest_log(log[0])
    print("  quest log: %d quest(s): %s" % (len(quests), ", ".join(q[1] for q in quests[:5])))
    for quest_id, name, _ in quests:
        header = b"\xF1" + struct.pack("<H", quest_id)
        conn.send(header)
        deadline = time.time() + 10
        while time.time() < deadline:
            # The server may batch the reply after other messages in the same packet.
            if any(header in d for d in drain(conn, 0.5)):
                break
        else:
            raise ProtocolError("no reply for quest %d %r (did the server crash?)" % (quest_id, name))
    print("  opened all %d quest(s)" % len(quests))


FLOOD_MESSAGE = "Too many connections attempts"
FLOOD_WAIT = 65  # loginTimeout in config.lua is 60 seconds


def flood_retry(action):
    """Runs action(); if the server's login flood protection refused it, waits once and retries."""
    try:
        return action()
    except ProtocolError as e:
        if FLOOD_MESSAGE not in str(e):
            raise
        print("  login flood protection active (%s); retrying in %ds" % (e, FLOOD_WAIT), flush=True)
        time.sleep(FLOOD_WAIT)
        return action()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--login-port", type=int, default=7564)
    ap.add_argument("--account", required=True)
    ap.add_argument("--password", required=True)
    ap.add_argument("--character", required=True)
    ap.add_argument("--walk", default="east,east,west,west")
    ap.add_argument("--timeout", type=float, default=30)
    ap.add_argument("--step-delay", type=float, default=1.5, help="seconds to wait after each step")
    ap.add_argument("--quest-log", action="store_true", help="also open the quest log and every quest in it")
    ap.add_argument("--say", action="append", default=[], help="say this in the default channel (repeatable)")
    ap.add_argument("--expect-login-failure", action="store_true",
                    help="succeed only if the login server refuses the credentials")
    ap.add_argument("--game-host", default="127.0.0.1",
                    help="game server address the character list must announce ('any' accepts every address)")
    ap.add_argument("--connect-host", help="connect to this address instead of the announced game server address")
    ap.add_argument("--expect-position", help="x,y,z the character must enter the game at (saved position)")
    ap.add_argument("--stay-online", type=float, default=0,
                    help="after walking, stay in game up to this many seconds and succeed only if the "
                         "server disconnects the character (server shutdown or restart)")
    args = ap.parse_args()

    try:
        characters = flood_retry(lambda: login(args))
    except ProtocolError as e:
        if args.expect_login_failure:
            print("OK: login refused as expected (%s)" % e)
            return 0
        print("FAIL: " + str(e))
        return 1
    if args.expect_login_failure:
        print("FAIL: login unexpectedly succeeded")
        return 1

    print("Login OK. Characters: " + ", ".join("%s (%s %s:%d)" % c for c in characters))
    match = [c for c in characters if c[0].lower() == args.character.lower()]
    if not match:
        print("FAIL: character %r not in the character list" % args.character)
        return 1
    _, _, host, port = match[0]
    if args.game_host != "any" and host != args.game_host:
        print("FAIL: game server address is %s, expected %s" % (host, args.game_host))
        return 1

    try:
        conn, player_id, position = flood_retry(lambda: enter_game(args, args.connect_host or host, port))
    except ProtocolError as e:
        print("FAIL: " + str(e))
        return 1
    print("Entered game as %s (creature id %d) at %s." % (args.character, player_id, position))
    if args.expect_position:
        expected = tuple(int(v) for v in args.expect_position.split(","))
        if position != expected:
            conn.close()
            print("FAIL: entered the game at %s, expected the saved position %s" % (position, expected))
            return 1
        print("  saved position %s verified" % (expected,))

    try:
        drain(conn, 3)
        if args.quest_log:
            try:
                check_quest_log(conn)
            except ProtocolError as e:
                print("FAIL: " + str(e))
                return 1
        for text in args.say:
            conn.send(b"\x96\x01" + pstr(text))  # say, talk type 1 (default channel)
            drain(conn, 1)
            print("  said %r" % text)
        moves = 0
        for step in [s.strip() for s in args.walk.split(",") if s.strip()]:
            conn.send(bytes([WALK_OPCODES[step]]))
            packets = drain(conn, args.step_delay)
            moved_to = None
            if position:
                marker = b"\x6d" + struct.pack("<HHB", *position)
                for data in packets:
                    i = data.find(marker)
                    if i >= 0 and len(data) >= i + 12:
                        moved_to = struct.unpack_from("<HHB", data, i + 7)
                        break
            elif any(d[0] == 0x6D for d in packets):
                moved_to = "unknown"
            if moved_to:
                moves += 1
                print("  walk %-5s -> moved to %s" % (step, moved_to))
                if position:
                    position = moved_to
            elif any(d[0] == 0xB5 for d in packets):
                print("  walk %-5s -> blocked by server" % step)
            else:
                print("  walk %-5s -> no move seen" % step)
        if position:
            print("POSITION %d,%d,%d" % tuple(position))
        if args.stay_online:
            print("  staying online until the server disconnects (max %ds)" % args.stay_online)
            if not stay_online(conn, args.stay_online):
                print("FAIL: the server did not disconnect the character within %ds" % args.stay_online)
                return 1
            print("  disconnected by the server")
        else:
            conn.send(b"\x14")  # logout
            drain(conn, 2)
    finally:
        conn.close()

    if moves == 0:
        print("FAIL: the character did not move")
        return 1
    print("OK: login, character list, game login and %d movement step(s) verified." % moves)
    return 0


def stay_online(conn, seconds):
    """Answers pings until the server closes the connection. Returns False on timeout."""
    conn.sock.settimeout(1)
    end = time.time() + seconds
    while time.time() < end:
        try:
            data = conn.recv()
        except socket.timeout:
            continue
        except (ProtocolError, OSError):
            return True
        if data and data[0] == 0x1E:
            conn.send(b"\x1E")
        elif data and data[0] == 0xB4:  # text message: type, text
            try:
                print("  server message: " + Reader(data[2:]).string(), flush=True)
            except (IndexError, struct.error):
                pass
    return False


if __name__ == "__main__":
    sys.exit(main())
