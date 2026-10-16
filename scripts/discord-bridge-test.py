#!/usr/bin/env python3
"""Integration test for the Discord bridge (src/discordbridge.cpp + 056-discordBridge.lua).

Runs against a live server started with the bridge enabled. Uses real game clients
(scripts/protocol-test.py) for the chat and catch checks. Exits non-zero on failure.

  --catch-test needs the test-only talkaction from scripts/testing/ installed as
  "/bridgetest" (scripts/test-server-linux.sh does that in its temporary copy).
  --link-test needs an account with two characters (--linker) and a server started with
  a short discordBridgeLinkCodeLifetime (--code-lifetime) so expiry can be checked.
"""
import argparse
import hashlib
import hmac
import importlib.util
import json
import os
import re
import socket
import struct
import sys
import threading
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

    def events_of(self, kind, **fields):
        return [e for e in self.events if e["event"]["kind"] == kind
                and all(e["event"].get(k) == v for k, v in fields.items())]

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
        self.lock = threading.Lock()
        self.closed = threading.Event()
        threading.Thread(target=self._keepalive, daemon=True).start()

    def _keepalive(self):
        # Idle test clients would otherwise be disconnected for not answering pings.
        while not self.closed.wait(10):
            try:
                self.send(b"\x1e")
            except OSError:
                return

    def send(self, payload):
        with self.lock:
            self.conn.send(payload)

    def open_channel(self, channel_id):
        self.send(struct.pack("<BH", 0x98, channel_id))

    def say(self, text):
        self.send(struct.pack("<BB", 0x96, 1) + pt.pstr(text))

    def say_channel(self, channel_id, text):
        self.send(struct.pack("<BBH", 0x96, 7, channel_id) + pt.pstr(text))

    def collect(self, seconds):
        self.packets += pt.drain(self.conn, seconds)

    def received(self, needle):
        return any(needle in p for p in self.packets)

    def logout(self):
        self.send(b"\x14")

    def command(self, text, seconds=1.5):
        """Says a talkaction and returns everything the server sent meanwhile, as text."""
        start = len(self.packets)
        self.say(text)
        self.collect(seconds)
        return b"\n".join(self.packets[start:]).decode("latin-1")

    def link_code(self):
        text = self.command("!discord link")
        m = re.search(r"link code is ([0-9A-Z]{4}-[0-9A-Z]{4})", text)
        return (m.group(1) if m else None), text

    def close(self):
        self.closed.set()
        self.conn.close()


DISCORD_A = "1234567890123456789"   # above 2^53: must survive without precision loss
DISCORD_B = "98765432109876543210"
DISCORD_C = "11111111111111111"


def logout_event(b, character, timeout=15):
    e = b.wait_event(lambda ev: ev["kind"] == "player_logout" and ev["character"] == character, timeout)
    if e:
        b.events.remove(e)
    return e and e["event"]


def link_tests(b, args, boot, listener, speaker, trainer, speaker_name):
    account, password, first, second = args.linker.split(":", 3)

    # Linking from the second character still makes the first-created character the main.
    linker = Player(args, account, password, second)
    linker.collect(1.5)
    text = linker.command("!discord status")
    check("in-game status: not linked", "is not linked" in text, text)
    code, text = linker.link_code()
    check("!discord link shows a code", code is not None, text)
    again = linker.command("!discord link")
    check("code requests are rate limited", "too recently" in again, again)

    r = b.request("link.redeem", {"discordUserId": "12ab", "code": code})
    check("link.redeem rejects invalid Discord ids", r and not r["ok"] and r["error"]["code"] == "invalid_params", str(r))
    r = b.request("link.redeem", {"discordUserId": DISCORD_A, "code": "AAAA-AAAA"})
    check("link.redeem rejects a wrong code", r and not r["ok"] and r["error"]["code"] == "invalid_code", str(r))
    r = b.request("link.redeem", {"discordUserId": DISCORD_A, "code": code.lower().replace("-", " ")})
    res = r and r.get("result") or {}
    check("link.redeem links the account (code is case and separator insensitive)",
          r and r["ok"] and res.get("linked") and res.get("discordUserId") == DISCORD_A
          and res.get("main", {}).get("name") == first and res.get("characterCount") == 2
          and isinstance(res.get("premium"), bool), str(r))
    check("link results never contain account ids or names",
          "accountId" not in res and account not in json.dumps(res), str(res))
    linker.collect(1)
    check("online character is told about the link", linker.received(b"now linked to Discord"))
    r = b.request("link.redeem", {"discordUserId": DISCORD_B, "code": code})
    check("a code works only once", r and not r["ok"] and r["error"]["code"] == "invalid_code", str(r))
    r = b.request("link.redeem", {"discordUserId": DISCORD_A, "code": "BBBB-BBBB"})
    check("a linked Discord user can't link a second account",
          r and not r["ok"] and r["error"]["code"] == "already_linked", str(r))
    text = linker.command("!discord link")
    check("!discord link refuses an already linked account", "already linked" in text, text)
    text = linker.command("!discord status")
    check("in-game status: linked", "is linked to Discord since" in text, text)

    r = b.request("link.account", {"discordUserId": DISCORD_A})
    check("link.account", r and r["ok"] and r["result"]["linked"] and r["result"]["main"]["name"] == first
          and r["result"]["mainChanged"] is False, str(r))
    r = b.request("link.account", {"discordUserId": DISCORD_B})
    check("link.account for an unlinked user", r and r["ok"] and r["result"] == {"linked": False}, str(r))
    r = b.request("link.characters", {"discordUserId": DISCORD_A})
    chars = r and r.get("ok") and r["result"]["characters"] or []
    check("link.characters lists the account's characters with the main marked",
          [c["name"] for c in chars] == [first, second] and chars[0]["main"] and not chars[1]["main"]
          and chars[1]["online"] and all(c.get("vocation") for c in chars), str(r))
    r = b.request("link.setMain", {"discordUserId": DISCORD_A, "character": speaker_name})
    check("link.setMain refuses a character of another account",
          r and not r["ok"] and r["error"]["code"] == "not_owned", str(r))
    r = b.request("link.setMain", {"discordUserId": DISCORD_A, "character": second.upper()})
    check("link.setMain", r and r["ok"] and r["result"]["main"]["name"] == second, str(r))
    r = b.request("link.list", {"limit": 50})
    check("link.list includes the link", r and r["ok"]
          and any(x["discordUserId"] == DISCORD_A and x["main"]["name"] == second for x in r["result"]["links"]), str(r))

    # Rapid reconnect to the same character keeps the session: no second login, no logout.
    logins = len(b.events_of("player_login", character=second))
    again = Player(args, account, password, second)
    again.collect(2)
    b.pump(1)
    check("reconnect keeps the session (no extra login or logout)",
          len(b.events_of("player_login", character=second)) == logins and not b.events_of("player_logout", character=second))
    linker.close()

    # Client logout, then a deleted main falls back to the first character.
    again.logout()
    ev = logout_event(b, second)
    check("player_logout after a client logout", ev is not None and ev.get("reason") == "logout"
          and ev.get("sessionId", "").startswith(boot + "-s") and ev.get("duration", -1) >= 0
          and ev.get("logoutTime", 0) >= ev.get("loginTime", 1) and "ip" not in ev, str(ev))
    again.close()
    time.sleep(1)
    acc = argparse.Namespace(host=args.host, login_port=args.login_port, timeout=30)
    ok, message = account_request(acc, 3, account, password, second)
    check("character deleted through the account service", ok, message)
    e = b.wait_event(lambda ev: ev["kind"] == "account_characters" and ev.get("change") == "deleted", 10)
    check("account_characters event for the linked account", e is not None
          and e["event"]["discordUserId"] == DISCORD_A and e["event"]["character"] == second, str(e))
    r = b.request("link.account", {"discordUserId": DISCORD_A})
    check("deleted main falls back to the first character", r and r["ok"]
          and r["result"]["main"]["name"] == first and r["result"]["mainChanged"] is True
          and r["result"]["characterCount"] == 1, str(r))
    r = b.request("link.account", {"discordUserId": DISCORD_A})
    check("the fallback main is saved", r and r["ok"] and r["result"]["mainChanged"] is False, str(r))

    # Unlinking in game needs a confirmation and tells the bot.
    linker = Player(args, account, password, first)
    linker.collect(1.5)
    text = linker.command("!discord unlink")
    check("!discord unlink asks for confirmation", "unlink confirm" in text, text)
    check("nothing is unlinked before confirming", b.request("link.account", {"discordUserId": DISCORD_A})["result"]["linked"])
    text = linker.command("!discord unlink confirm")
    e = b.wait_event(lambda ev: ev["kind"] == "account_link" and ev.get("action") == "unlinked", 10)
    check("in-game unlink emits account_link", e is not None and e["event"]["discordUserId"] == DISCORD_A
          and e["event"]["scope"] == "account", str(e) + " " + text)
    r = b.request("link.account", {"discordUserId": DISCORD_A})
    check("account is unlinked", r and r["ok"] and r["result"] == {"linked": False}, str(r))

    # Kick reason.
    speaker.say("/kick " + first)
    ev = logout_event(b, first)
    check("player_logout reason kick", ev is not None and ev.get("reason") == "kick", str(ev))
    linker.close()

    # Unlink requested from Discord.
    code, text = speaker.link_code()
    r = b.request("link.redeem", {"discordUserId": DISCORD_B, "code": code})
    check("second account links", r and r["ok"] and r["result"]["main"]["name"] == speaker_name, str(r))
    r = b.request("link.unlink", {"discordUserId": DISCORD_B})
    check("link.unlink", r and r["ok"] and r["result"] == {"unlinked": True}, str(r))
    r = b.request("link.unlink", {"discordUserId": DISCORD_B})
    check("link.unlink is idempotent", r and r["ok"] and r["result"] == {"unlinked": False}, str(r))
    speaker.collect(1)
    check("online character is told about the unlink", speaker.received(b"no longer linked to Discord"))

    # Expiry, then brute-force lockout.
    if args.code_lifetime:
        code, text = listener.link_code()
        check("code for the expiry check", code is not None, text)
        time.sleep(args.code_lifetime + 2)
        r = b.request("link.redeem", {"discordUserId": DISCORD_C, "code": code})
        check("an expired code is refused", r and not r["ok"] and r["error"]["code"] == "expired", str(r))
    codes = []
    for i in range(6):
        r = b.request("link.redeem", {"discordUserId": DISCORD_C, "code": "ZZZZ-ZZZ%d" % i})
        codes.append(r and r.get("error", {}).get("code"))
    check("repeated wrong codes lock the Discord user", codes == ["invalid_code"] * 5 + ["locked"], str(codes))


def account_request(args, action, account, password, name):
    spec = importlib.util.spec_from_file_location("account_test", os.path.join(here, "account-test.py"))
    at = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(at)
    return at.request(args, action, account, password, name)


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
    ap.add_argument("--link-test", action="store_true", help="player session and account linking checks")
    ap.add_argument("--linker", default="bridgelink:secret:Link Alpha:Link Beta",
                    help="account:password:first character:second character (account linking checks)")
    ap.add_argument("--code-lifetime", type=int, default=0, help="discordBridgeLinkCodeLifetime of the server")
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
    if args.link_test:
        check("welcome lists playerSessions and accountLinking features",
              {"playerSessions", "accountLinking"} <= set(b.welcome.get("features", [])), str(b.welcome))
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
    card = (r and r["ok"] and r["result"].get("card")) or {}
    check("trainer.lookup card", r["result"].get("vocation") == "Trainer" and card.get("title") == "Pokemon Trainer"
          and [b_["region"] for b_ in card.get("badges", [])] == ["Kanto", "Orange Islands"]
          and card["badges"][0]["total"] == 8 and isinstance(card.get("trophies"), list)
          and isinstance(card.get("hidden"), list) and "since" in card, str(r)[:600])
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
    if args.link_test:
        e = b.wait_event(lambda ev: ev["kind"] == "player_login" and ev["character"] == trainer, 10)
        ev = e and e["event"] or {}
        check("player_login event after a successful login", e is not None and ev.get("scope") == "admin"
              and ev.get("sessionId", "").startswith(boot + "-s") and ev.get("ip") == "127.0.0.1"
              and ev.get("clientOs") == "otclient-windows" and ev.get("clientVersion") == pt.CLIENT_VERSION
              and isinstance(ev.get("accountId"), int) and ev.get("level", 0) >= 1 and ev.get("playersOnline", 0) >= 1,
              str(e))
        r = b.request("admin.sessions")
        sessions = r and r.get("ok") and r["result"]["sessions"] or []
        check("admin.sessions lists the session without IPs",
              any(x["sessionId"] == ev.get("sessionId") for x in sessions) and not any("ip" in x for x in sessions),
              str(r))
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
        e = b.wait_event(lambda ev: ev["kind"] == "spawn" and ev["species"] == "Shiny Rattata"
                         and ev["source"] == "script", 10)
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

    if args.link_test:
        link_tests(b, args, boot, listener, speaker, trainer, speaker_name)

    # Reconnect: a second authenticated client replaces the first.
    listener.close()
    speaker.close()
    if args.link_test:
        ev = logout_event(b, trainer, 30)
        check("player_logout reason connection_lost when the client disappears",
              ev is not None and ev.get("reason") == "connection_lost", str(ev))
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
