#!/usr/bin/env python3
"""Packet recorder for the client parity tests.

record: a TCP proxy in front of the login and game ports. It decrypts what the client
sends (RSA login block, then XTEA) and writes one line per packet to the log. The
character list coming back is rewritten so the client also connects to the game
port through the proxy.

  packet-recorder.py record --log out.log [--listen-login 17564] [--listen-game 18548]
                            [--server 127.0.0.1] [--login-port 7564] [--game-port 8548]

diff: compares two logs and exits 1 when they differ.

  packet-recorder.py diff legacy.log redemption.log [--report diff.txt]

Log lines are "<connection> <hex payload>". XTEA keys, the login challenge and pings
are left out, since they change from run to run. Standard library only.
"""
import argparse
import difflib
import os
import signal
import socket
import struct
import sys
import threading

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
proto = __import__("protocol-test")

# Private half of the standard OpenTibia key (core/server/src/otserv.cpp).
RSA_P = int(
    "14299623962416399520070177382898895550795403345466153217470516082934737582776038882967213386204600674145392845853859217990626450972452084065728686565928113"
)
RSA_Q = int(
    "7630979195970404721891201847792002125535401292779123937207447574596692788513647179235335529307251350570728407373705564708871762033017096809910315212884101"
)
RSA_D = int(
    "46730330223584118622160180015036832148732986808519344675210555262940258739805766860224610646919605860206328024326703361630109888417839241959507572247284807035235569619173792292786907845791904955103601652822519121908367187885509270025388641700821735345222087940578381210879116823013776808975766851829020659073"
)

# Client opcodes that depend on timing rather than on what the player did.
IGNORED_OPCODES = {0x1E}  # ping


def rsa_decrypt(block):
    assert RSA_P * RSA_Q == proto.RSA_N
    m = pow(int.from_bytes(block, "big"), RSA_D, proto.RSA_N)
    return m.to_bytes(128, "big")


def frame(body):
    data = struct.pack("<I", proto.adler32(body)) + body
    return struct.pack("<H", len(data)) + data


class Stream:
    """Splits a byte stream into framed packets (u16 size, u32 checksum, body)."""

    def __init__(self):
        self.buffer = b""

    def feed(self, data):
        self.buffer += data
        packets = []
        while len(self.buffer) >= 2:
            size = struct.unpack_from("<H", self.buffer)[0]
            if len(self.buffer) < 2 + size:
                break
            packets.append(self.buffer[2:2 + size])
            self.buffer = self.buffer[2 + size:]
        return packets


def strings(reader, count):
    return [reader.string() for _ in range(count)]


def describe_login(body):
    """Account login: opcode, os, version, locale, signatures, RSA block."""
    payload = body[4:]
    header, block = payload[:-128], rsa_decrypt(payload[-128:])
    r = proto.Reader(block)
    r.u8()
    key = [r.u32() for _ in range(4)]
    account, password = strings(r, 2)
    rest = block[r.pos:]
    fields = "header=%s account=%s password=%s padding=%s" % (
        header.hex(), account, password, "zero" if not rest.strip(b"\0") else rest.hex())
    return key, fields


def describe_game_login(body):
    """Game login: opcode, os, version, RSA block (key, gm flag, names, challenge)."""
    payload = body[4:]
    header, block = payload[:-128], rsa_decrypt(payload[-128:])
    r = proto.Reader(block)
    r.u8()
    key = [r.u32() for _ in range(4)]
    gm = r.u8()
    account, character, password = strings(r, 3)
    r.u32(), r.u8()  # challenge timestamp and random byte
    rest = block[r.pos:]
    fields = "header=%s gm=%d account=%s character=%s password=%s padding=%s" % (
        header.hex(), gm, account, character, password, "zero" if not rest.strip(b"\0") else rest.hex())
    return key, fields


def decrypt(key, body):
    data = proto.xtea_decrypt(key, body[4:])
    size = struct.unpack_from("<H", data)[0]
    return data[2:2 + size]


class Recorder:
    def __init__(self, args):
        self.args = args
        self.lock = threading.Lock()
        self.log = open(args.log, "w", buffering=1)
        self.game_endpoint = struct.pack("<4sH", socket.inet_aton(args.server), args.game_port)
        self.proxy_endpoint = struct.pack("<4sH", socket.inet_aton(args.server), args.listen_game)

    def write(self, line):
        with self.lock:
            self.log.write(line + "\n")

    def serve(self, listen_port, game):
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind(("127.0.0.1", listen_port))
        server.listen(8)
        while True:
            client, _ = server.accept()
            threading.Thread(target=self.session, args=(client, game), daemon=True).start()

    def session(self, client, game):
        name = "game" if game else "login"
        port = self.args.game_port if game else self.args.login_port
        try:
            upstream = socket.create_connection((self.args.server, port))
        except OSError as e:
            self.write("%s error %s" % (name, e))
            client.close()
            return
        state = {"key": None}
        threading.Thread(target=self.server_to_client, args=(upstream, client, state, game), daemon=True).start()
        self.client_to_server(client, upstream, state, name)

    def client_to_server(self, client, upstream, state, name):
        stream = Stream()
        try:
            while True:
                data = client.recv(65536)
                if not data:
                    break
                upstream.sendall(data)
                for body in stream.feed(data):
                    self.record(name, body, state)
        except OSError:
            pass
        finally:
            self.write("%s close" % name)
            for s in (client, upstream):
                try:
                    s.shutdown(socket.SHUT_RDWR)
                except OSError:
                    pass

    def record(self, name, body, state):
        if state["key"] is None:
            try:
                describe = describe_game_login if name == "game" else describe_login
                state["key"], fields = describe(body)
                self.write("%s login %s" % (name, fields))
            except Exception as e:  # keep proxying even if the first packet is unexpected
                self.write("%s unreadable-first-packet %s (%s)" % (name, body.hex(), e))
            return
        payload = decrypt(state["key"], body)
        if payload and payload[0] in IGNORED_OPCODES:
            return
        self.write("%s %s" % (name, payload.hex()))

    def server_to_client(self, upstream, client, state, game):
        stream = Stream()
        try:
            while True:
                data = upstream.recv(65536)
                if not data:
                    break
                if game:
                    client.sendall(data)
                    continue
                # Login replies: point the character list at the proxy's game port.
                for body in stream.feed(data):
                    if state["key"] is not None:
                        plain = proto.xtea_decrypt(state["key"], body[4:])
                        if self.game_endpoint in plain:
                            plain = plain.replace(self.game_endpoint, self.proxy_endpoint)
                            client.sendall(frame(proto.xtea_encrypt(state["key"], plain)))
                            continue
                    client.sendall(struct.pack("<H", len(body)) + body)
        except OSError:
            pass
        finally:
            try:
                client.shutdown(socket.SHUT_RDWR)
            except OSError:
                pass


def record(args):
    recorder = Recorder(args)
    for port, game in ((args.listen_login, False), (args.listen_game, True)):
        threading.Thread(target=recorder.serve, args=(port, game), daemon=True).start()
    print("recording %d -> %d and %d -> %d into %s" % (
        args.listen_login, args.login_port, args.listen_game, args.game_port, args.log), flush=True)
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    try:
        threading.Event().wait()
    except KeyboardInterrupt:
        pass


def load(path):
    with open(path) as f:
        return [line.rstrip("\n") for line in f if line.strip()]


def diff(args):
    ignored = tuple("game %s" % opcode.lower() for opcode in args.ignore)
    a, b = ([line for line in load(path) if not (ignored and line.startswith(ignored))]
            for path in (args.a, args.b))
    lines = list(difflib.unified_diff(a, b, args.a, args.b, lineterm=""))
    text = "\n".join(lines) + "\n" if lines else "identical (%d packets)\n" % len(a)
    if args.report:
        with open(args.report, "w") as f:
            f.write(text)
    sys.stdout.write(text)
    return 1 if lines else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    rec = sub.add_parser("record")
    rec.add_argument("--log", required=True)
    rec.add_argument("--server", default="127.0.0.1")
    rec.add_argument("--login-port", type=int, default=7564)
    rec.add_argument("--game-port", type=int, default=8548)
    rec.add_argument("--listen-login", type=int, default=17564)
    rec.add_argument("--listen-game", type=int, default=18548)
    d = sub.add_parser("diff")
    d.add_argument("a")
    d.add_argument("b")
    d.add_argument("--report")
    d.add_argument("--ignore", action="append", default=[], metavar="OPCODE",
                   help="leave out game packets with this opcode (hex), may repeat")
    args = parser.parse_args()
    if args.command == "record":
        record(args)
        return 0
    return diff(args)


if __name__ == "__main__":
    sys.exit(main())
