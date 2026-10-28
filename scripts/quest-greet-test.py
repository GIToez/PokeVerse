#!/usr/bin/env python3
"""Integration test for what quest NPCs say when greeted (NpcHandler:getQuestGreeting in
data/npc/lib/npcsystem/npchandler.lua, getQuestGreetHint in data/lib/ps/systems/002-quest.lua).

Runs against a live server with the test-only talkaction from scripts/testing/ installed as
"/questtest" (scripts/test-server-linux.sh does that in its temporary copy). The trainer is put
next to each NPC at a level below and at its quest's level, says hi and checks the NPC's lines:
the "(I have a {task} for you.)" hint only once the quest can be started, the idle greeting
(message_greet_idle) before that, and an NPC without quests greeting as before.
Exits non-zero on any failure.
"""
import argparse
import importlib.util
import os
import struct
import sys
import time

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("vocation_test", os.path.join(here, "vocation-test.py"))
vt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vt)
pt = vt.pt

HINT = "(I have a {task} for you.)"

# level, NPC, what it must say, what it must not say, and what to say after hi (optional)
CASES = [
    (5, "Andy", ["You can buy bikes here"], [HINT], None),
    (5, "Jack Simps", ["can I help you?"], [HINT], None),
    (10, "Jack Simps", ["can I help you?", HINT], [], None),
    (20, "George Carter", ["plenty of stories to tell"], [HINT, "{research}"], None),
    (20, "George Carter", ["level 25"], ["(Start quest?"], "task"),
    (25, "George Carter", ["{research} and excavations", HINT], ["plenty of stories"], None),
    (25, "George Carter", ["(Start quest? {YES} or {NO})", "looking for people interested"], [], "task"),
]


def say_to_npc(player, text):
    """Says text in the NPC channel; a greeted NPC ignores ordinary speech (NpcHandler:onCreatureSay)."""
    player.send(struct.pack("<BB", 0x96, 0x04) + pt.pstr(text))


def text_of(packets):
    return "".join(p.decode("latin-1") for p in packets)


def wait_for(player, needle, timeout=10):
    seen = ""
    end = time.time() + timeout
    while time.time() < end:
        seen += text_of(pt.drain(player.conn, 0.5))
        if needle in seen:
            return seen
    return seen


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--login-port", type=int, default=7564)
    parser.add_argument("--tester", required=True, help="account:password:character")
    args = parser.parse_args()

    tester = vt.Player(args, *args.tester.split(":", 2))
    pt.drain(tester.conn, 2)
    failures, checks = [], 0
    for level, npc, want, avoid, follow in CASES:
        tester.say("/questtest %d %s" % (level, npc))
        seen = wait_for(tester, "questtest: ready")
        if "questtest: ready %d" % level not in seen:
            failures.append("%s at level %d: the trainer was not set up (%s)" % (npc, level, seen[-200:]))
            continue
        tester.say("hi")
        heard = wait_for(tester, want[0], 5) if not follow else text_of(pt.drain(tester.conn, 3))
        if follow:
            say_to_npc(tester, follow)
            heard = wait_for(tester, want[0], 5)
        time.sleep(1)
        heard += text_of(pt.drain(tester.conn, 1))
        label = "%s at level %d%s" % (npc, level, (", after \"%s\"" % follow) if follow else "")
        for text in want:
            checks += 1
            if text not in heard:
                failures.append("%s: did not say %r" % (label, text))
        for text in avoid:
            checks += 1
            if text in heard:
                failures.append("%s: said %r" % (label, text))
        say_to_npc(tester, "bye")
        pt.drain(tester.conn, 1)

    tester.logout()
    print("%d checks, %d failed" % (checks, len(failures)))
    for failure in failures:
        print("FAIL  " + failure)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
