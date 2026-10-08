#!/usr/bin/env python3
"""Integration test for the Discord bridge (src/discordbridge.cpp + 056-discordBridge.lua).

Runs against a live server started with the bridge enabled. Uses real game clients
(scripts/protocol-test.py) for the chat and catch checks. Exits non-zero on failure.

  --catch-test needs the test-only talkaction from scripts/testing/ installed as
  "/bridgetest" (scripts/test-server-linux.sh does that in its temporary copy).
"""
import argparse
import hashlib
import hmac
import importlib.util
import json
import os
import socket
import struct
import sys
import time

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("protocol_test", os.path.join(here, "protocol-test.py"))
pt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pt)

failures = []


def check(name, condition, detail=""):
    print(("PASS  " if condition else "FAIL  ") + name + (("  (" + detail + ")") if detail and not condition else ""))
    if not condition:
        failures.append(name)


class Bridge:
    def __init__(self, host, port, secret, timeout=10):
        self.sock = socket.create_connection((host, port), timeout=timeout)
        self.buf = b""
        self.events = []
        self.responses = {}
        self.next_id = 0
        hello = self.read()
        self.hello = hello
        if secret is not None:
            mac = hmac.new(secret.encode(), hello["nonce"].encode(), hashlib.sha256).hexdigest()
            self.send({"type": "auth", "hmac": mac})
            self.welcome = self.read()

    def send(self, obj):
        self.sock.sendall((json.dumps(obj) + "\n").encode())

    def read(self, timeout=10):
        self.sock.settimeout(timeout)
        while b"\n" not in self.buf:
            chunk = self.sock.recv(65536)
            if not chunk:
                return None
            self.buf += chunk
        line, self.buf = self.buf.split(b"\n", 1)
        return json.loads(line)

    def pump(self, seconds):
        """Reads messages for up to `seconds`, storing events/responses."""
        end = time.time() + seconds
        while time.time() < end:
            try:
                msg = self.read(timeout=max(0.05, end - time.time()))
            except socket.timeout:
                break
            if msg is None:
                raise RuntimeError("bridge closed the connection")
            if msg["type"] == "event":
                self.events.append(msg)
            elif msg["type"] == "response":
                self.responses[msg["requestId"]] = msg
            elif msg["type"] == "ping":
                self.send({"type": "pong"})

    def request(self, method, params=None, timeout=10):
        self.next_id += 1
        rid = "t%d" % self.next_id
        self.send({"type": "request", "requestId": rid, "method": method, "params": params or {}})
        end = time.time() + timeout
        while rid not in self.responses and time.time() < end:
            self.pump(0.2)
        return self.responses.pop(rid, None)

    def wait_event(self, predicate, timeout):
        end = time.time() + timeout
        while time.time() < end:
            for e in self.events:
                if predicate(e["event"]):
                    return e
            self.pump(0.2)
        return None


class Player:
    def __init__(self, args, account, password, character):
        a = argparse.Namespace(host=args.host, login_port=args.login_port, account=account, password=password,
                               timeout=30)
        chars = pt.login(a)
        name, world, ip, port = [c for c in chars if c[0] == character][0]
        a.character = character
        self.conn, self.id, self.pos = pt.enter_game(a, args.host, port)
        self.packets = []

    def open_channel(self, channel_id):
        self.conn.send(struct.pack("<BH", 0x98, channel_id))

    def say(self, text):
        self.conn.send(struct.pack("<BB", 0x96, 1) + pt.pstr(text))

    def say_channel(self, channel_id, text):
        self.conn.send(struct.pack("<BBH", 0x96, 7, channel_id) + pt.pstr(text))

    def collect(self, seconds):
        self.packets += pt.drain(self.conn, seconds)

    def received(self, needle):
        return any(needle in p for p in self.packets)

    def close(self):
        self.conn.close()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--login-port", type=int, default=7564)
    ap.add_argument("--bridge-port", type=int, default=7199)
    ap.add_argument("--secret", required=True)
    ap.add_argument("--catch-test", action="store_true")
    ap.add_argument("--listener", default="test:test:Trainer", help="account:password:character (ordinary trainer)")
    ap.add_argument("--speaker", default="admin:admin:Admin",
                    help="account:password:character allowed to talk in Game-Chat (level 10+ or staff)")
    ap.add_argument("--staff-character", default="Admin", help="staff character that lookups must hide")
    args = ap.parse_args()

    # Authentication
    bad = Bridge(args.host, args.bridge_port, None)
    check("hello has protocol and nonce", bad.hello.get("type") == "hello" and len(bad.hello.get("nonce", "")) == 64)
    bad.send({"type": "auth", "hmac": "00" * 32})
    reply = bad.read()
    check("wrong secret is rejected", reply and reply.get("code") == "auth_failed", str(reply))
    check("connection closed after failed auth", bad.read() is None)

    b = Bridge(args.host, args.bridge_port, args.secret)
    check("welcome after valid auth", b.welcome and b.welcome.get("type") == "welcome", str(b.welcome))
    boot = b.welcome["bootId"]
    b.pump(2)
    states = [e["event"]["state"] for e in b.events if e["event"]["kind"] == "server_state"]
    check("queued server_state events delivered after connect", "normal" in states, str(states))
    ids = [e["id"] for e in b.events]
    check("event ids unique and prefixed with boot id", len(ids) == len(set(ids)) and all(i.startswith(boot + "-") for i in ids))

    # Read-only requests
    r = b.request("server.status")
    check("server.status", r and r["ok"] and r["result"]["state"] == "normal" and r["result"]["uptime"] >= 0, str(r))
    r = b.request("bridge.config")
    check("bridge.config", r and r["ok"] and r["result"]["chatChannelId"] == 7 and "Mewtwo" in r["result"]["legendary"], str(r))
    r = b.request("pokemon.lookup", {"name": "pikachu"})
    res = r and r.get("result") or {}
    check("pokemon.lookup Pikachu", r and r["ok"] and res.get("found") and res.get("dexNumber") == 25
          and res.get("types") == ["Electric"], str(r)[:300])
    r = b.request("pokemon.lookup", {"name": "Mewtwo"})
    check("pokemon.lookup legendary flag", r and r["result"].get("legendary") is True, str(r)[:300])
    r = b.request("pokemon.lookup", {"name": "Not A Pokemon"})
    check("pokemon.lookup unknown", r and r["ok"] and r["result"] == {"found": False}, str(r))
    r = b.request("pokemon.search", {"query": "bulba", "limit": 5})
    check("pokemon.search", r and r["ok"] and "Bulbasaur" in r["result"]["names"], str(r))
    listener_account, listener_password, trainer = args.listener.split(":", 2)
    speaker_account, speaker_password, speaker_name = args.speaker.split(":", 2)
    r = b.request("trainer.lookup", {"name": trainer.lower()})
    check("trainer.lookup", r and r["ok"] and r["result"].get("found") and r["result"]["name"] == trainer, str(r))
    r = b.request("trainer.lookup", {"name": args.staff_character})
    check("trainer.lookup hides staff", r and r["ok"] and r["result"] == {"found": False}, str(r))
    r = b.request("trainer.lookup", {"name": "a' OR '1'='1"})
    check("trainer.lookup rejects invalid names", r and not r["ok"] and r["error"]["code"] == "invalid_params", str(r))
    r = b.request("no.such.method")
    check("unknown method", r and not r["ok"] and r["error"]["code"] == "unknown_method", str(r))
    b.send({"type": "request", "requestId": "x", "method": "server.status", "params": "not-an-object"})
    b.sock.sendall(b"this is not json\n")
    r = b.request("server.status")
    check("bridge survives malformed input", r is not None and r["ok"], str(r))

    # Chat in both directions with real game clients
    listener = Player(args, listener_account, listener_password, trainer)
    speaker = Player(args, speaker_account, speaker_password, speaker_name)
    listener.open_channel(7)
    speaker.open_channel(7)
    listener.collect(1.5)
    speaker.collect(0.5)

    marker = "bridge test %d" % int(time.time())
    speaker.say_channel(7, marker)
    e = b.wait_event(lambda ev: ev["kind"] == "chat" and ev.get("text") == marker, 10)
    check("game chat -> bridge event", e is not None and e["event"]["author"] == speaker_name and e["event"]["channelId"] == 7)

    r = b.request("chat.send", {"author": "Jim", "text": "hello from discord \u00e9 \U0001F600 @everyone"})
    check("chat.send delivered", r and r["ok"] and r["result"]["delivered"] >= 2, str(r))
    listener.collect(2)
    expected = pt.pstr("[Discord] Jim") + struct.pack("<HBH", 0, 7, 7) + pt.pstr("hello from discord \xe9 ? @everyone")
    check("discord message shown in game channel", listener.received(expected))
    b.pump(2)
    echoed = [x for x in b.events if x["event"]["kind"] == "chat" and "discord" in x["event"].get("text", "")]
    check("discord message is not echoed back (no loop)", not echoed, str(echoed))

    r = b.request("chat.send", {"author": "", "text": "x"})
    check("chat.send validates params", r and not r["ok"], str(r))

    if args.catch_test:
        before = b.request("trainer.lookup", {"name": trainer})["result"]["caught"]
        listener.say("/bridgetest miss Bulbasaur")
        listener.collect(7)
        b.pump(1)
        check("failed catch produces no catch event", not [x for x in b.events if x["event"]["kind"] == "catch"])

        listener.say("/bridgetest catch Rattata")
        e = b.wait_event(lambda ev: ev["kind"] == "catch", 15)
        check("successful catch event", e is not None and e["event"]["trainer"] == trainer
              and e["event"]["species"] == "Rattata" and e["event"]["ball"] == "ultra"
              and e["event"]["shiny"] is False and e["event"]["legendary"] is False, str(e))
        listener.collect(1)
        after = b.request("trainer.lookup", {"name": trainer})["result"]["caught"]
        check("catch is registered in game data", after == before + 1, "%s -> %s" % (before, after))
        catches = [x for x in b.events if x["event"]["kind"] == "catch"]
        check("exactly one catch event", len(catches) == 1, str(len(catches)))

        listener.say("/bridgetest spawn Shiny Rattata")
        e = b.wait_event(lambda ev: ev["kind"] == "spawn" and ev["species"] == "Shiny Rattata", 10)
        check("shiny spawn event (script)", e is not None and e["event"]["shiny"] is True
              and e["event"]["source"] == "script" and e["event"]["startup"] is False, str(e))
        listener.say("/bridgetest spawn Mewtwo")
        e = b.wait_event(lambda ev: ev["kind"] == "spawn" and ev["species"] == "Mewtwo", 10)
        check("legendary spawn event", e is not None and e["event"]["legendary"] is True, str(e))
        listener.say("/bridgetest spawn Mewtwo")
        listener.collect(2)
        b.pump(1)
        check("repeated script legendary spawn is rate limited",
              len([x for x in b.events if x["event"]["kind"] == "spawn" and x["event"]["species"] == "Mewtwo"]) == 1)
        listener.say("/bridgetest spawn Rattata")
        listener.collect(2)
        b.pump(1)
        check("ordinary spawn produces no event",
              not [x for x in b.events if x["event"]["kind"] == "spawn" and x["event"]["species"] == "Rattata"])

    spawn_events = [x for x in b.events if x["event"]["kind"] == "spawn" and x["event"]["source"] == "spawn"]
    print("INFO  spawn-system shiny spawns seen: %d" % len(spawn_events))

    # Reconnect: a second authenticated client replaces the first.
    listener.close()
    speaker.close()
    b2 = Bridge(args.host, args.bridge_port, args.secret)
    check("reconnect accepted", b2.welcome and b2.welcome.get("bootId") == boot)
    r = b2.request("server.status")
    check("requests work after reconnect", r and r["ok"])
    try:
        old = b.read(timeout=3)
    except (socket.timeout, OSError):
        old = "timeout"
    check("previous session closed on reconnect", old is None, str(old))

    print()
    if failures:
        print("FAIL: %d check(s) failed: %s" % (len(failures), ", ".join(failures)))
        return 1
    print("PASS: Discord bridge integration checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
