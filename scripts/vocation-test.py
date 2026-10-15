#!/usr/bin/env python3
"""Integration test for the vocation perks (data/lib/ps/systems/070-vocations.lua and its hooks).

Runs against a live server with the test-only talkaction from scripts/testing/ installed as
"/vocationtest" (scripts/test-server-linux.sh does that in its temporary copy). Logs in a tester
and a second trainer (whose Pokemon the Medic heals), says the command and checks every
"vocationtest: PASS|FAIL" line. Exits non-zero on any failure.
"""
import argparse
import importlib.util
import os
import re
import struct
import sys
import threading
import time

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("protocol_test", os.path.join(here, "protocol-test.py"))
pt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pt)


def messages(packets):
    """Text messages (0xB4, type, u16 length, text) in the packets, found by scanning like protocol-test.py."""
    found = []
    for data in packets:
        i = data.find(b"\xB4")
        while i >= 0:
            end = i
            if i + 4 <= len(data):
                n = struct.unpack_from("<H", data, i + 2)[0]
                text = data[i + 4:i + 4 + n]
                if n >= 4 and len(text) == n:
                    found.append(text.decode("latin-1"))
                    end = i + 3 + n
            i = data.find(b"\xB4", end + 1)
    return found


class Player:
    def __init__(self, args, account, password, character):
        a = argparse.Namespace(host=args.host, login_port=args.login_port, account=account, password=password,
                               timeout=30, character=character)
        chars = pt.login(a)
        name, world, ip, port = [c for c in chars if c[0] == character][0]
        self.conn, self.id, self.pos = pt.enter_game(a, args.host, port)
        self.lock = threading.Lock()
        self.closed = threading.Event()
        threading.Thread(target=self._keepalive, daemon=True).start()

    def _keepalive(self):
        while not self.closed.wait(10):
            try:
                self.send(b"\x1e")
            except OSError:
                return

    def send(self, payload):
        with self.lock:
            self.conn.send(payload)

    def say(self, text):
        self.send(struct.pack("<BB", 0x96, 1) + pt.pstr(text))

    def logout(self):
        self.closed.set()
        self.send(b"\x14")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--login-port", type=int, default=7171)
    parser.add_argument("--tester", required=True, help="account:password:character")
    parser.add_argument("--friend", required=True, help="account:password:character")
    parser.add_argument("--timeout", type=float, default=60)
    args = parser.parse_args()

    tester = Player(args, *args.tester.split(":", 2))
    friend = Player(args, *args.friend.split(":", 2))
    friend_name = args.friend.split(":", 2)[2]
    pt.drain(tester.conn, 2)
    pt.drain(friend.conn, 0.5)

    tester.say("/vocationtest " + friend_name)
    results, done = [], None
    end = time.time() + args.timeout
    while time.time() < end and not done:
        for text in messages(pt.drain(tester.conn, 1)):
            m = re.match(r"vocationtest: (PASS|FAIL) (.*)", text, re.S)
            if m:
                results.append((m.group(1), m.group(2)))
            m = re.match(r"vocationtest: done (\d+) passed, (\d+) failed", text)
            if m:
                done = (int(m.group(1)), int(m.group(2)))
        pt.drain(friend.conn, 0.1)

    tester.logout()
    friend.logout()
    failures = [name for status, name in results if status == "FAIL"]
    print("%d checks, %d failed" % (len(results), len(failures)))
    for name in failures:
        print("FAIL  " + name)
    if not done:
        print("FAIL  the test talkaction did not finish")
        return 1
    if len(results) < 40:
        print("FAIL  expected at least 40 checks, got %d" % len(results))
        return 1
    return 1 if failures or done[1] else 0


if __name__ == "__main__":
    sys.exit(main())
