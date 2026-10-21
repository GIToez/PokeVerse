#!/usr/bin/env python3
"""End-to-end test of the in-client account service (login port, protocol id 0x0B).

Creates a fresh account, creates a character on it, checks that the character
appears in the character list and enters the game at the tutorial start, then
deletes it again. Also checks that bad requests are refused. Standard library
only, so it runs on Windows and Linux CI runners.

Usage:
  account-test.py [--host 127.0.0.1] [--login-port 7564]
  account-test.py --slot-limit 3      # only the character limit (maxCharactersPerAccount)
"""
import argparse
import importlib.util
import os
import random
import string
import struct
import sys
import time

_spec = importlib.util.spec_from_file_location(
    "protocol_test", os.path.join(os.path.dirname(os.path.abspath(__file__)), "protocol-test.py"))
pt = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(pt)

PROTOCOL_ACCOUNT = 0x0B
ACTION_CREATE_ACCOUNT, ACTION_CREATE_CHARACTER, ACTION_DELETE_CHARACTER = 1, 2, 3
TUTORIAL_START = (5000, 806, 6)
# data/XML/outfits.xml: Rookie is a starter outfit, Fisher is the Angler's vocation outfit
ROOKIE_FEMALE, ROOKIE_MALE, FISHER_MALE, PREMIUM_LOOKTYPE = 2542, 2541, 628, 614
NEW_OUTFIT = (ROOKIE_MALE, 10, 20, 30, 40)


class PacedConnection(pt.Connection):
    # More than 10 connections from one IP within about a second block it for 10 seconds, and the
    # blocked connections are closed without a reply (ConnectionManager::acceptConnection).
    def __init__(self, *args, **kwargs):
        time.sleep(0.25)
        super().__init__(*args, **kwargs)


pt.Connection = PacedConnection


def request(args, action, account, password, name=None, sex=None, outfit=None):
    """Sends one account request and returns (success, message). outfit is (lookType, head, body, legs, feet)."""
    success, message = _request(args, action, account, password, name, sex, outfit)
    if not success and pt.FLOOD_MESSAGE in message:
        print("  login flood protection active; retrying in %ds" % pt.FLOOD_WAIT, flush=True)
        time.sleep(pt.FLOOD_WAIT)
        success, message = _request(args, action, account, password, name, sex, outfit)
    return success, message


def pace():
    # More than 10 connections from one IP within about a second block it for 10 seconds,
    # and the blocked connections are closed without a reply (ConnectionManager::acceptConnection).
    time.sleep(0.2)


def _request(args, action, account, password, name, sex, outfit):
    pace()
    conn = pt.Connection(args.host, args.login_port, args.timeout)
    try:
        key = pt.new_xtea_key()
        block = b"\x00" + struct.pack("<4I", *key) + bytes([action]) + pt.pstr(account) + pt.pstr(password)
        if name is not None:
            block += pt.pstr(name)
        if sex is not None:
            block += bytes([sex])
        if outfit is not None:
            block += struct.pack("<H4B", *outfit)
        block += b"\x00" * (128 - len(block))
        conn.send_first(struct.pack("<BHH", PROTOCOL_ACCOUNT, pt.CLIENT_OS, pt.CLIENT_VERSION) + pt.rsa_encrypt(block))
        conn.key = key
        msg = pt.Reader(conn.recv())
        op = msg.u8()
        if op not in (0x0A, 0x0B):
            raise pt.ProtocolError("unexpected account reply opcode 0x%02X" % op)
        return op == 0x0B, msg.string()
    finally:
        conn.close()


class Checker:
    def __init__(self):
        self.failures = 0

    def expect(self, label, result, want_success):
        success, message = result
        ok = success == want_success
        print("%s: %s -> %s (%s)" % ("OK" if ok else "FAIL", label, "accepted" if success else "refused", message))
        if not ok:
            self.failures += 1
        return ok


def character_list(args, account, password, details=None):
    login_args = argparse.Namespace(host=args.host, login_port=args.login_port, timeout=args.timeout,
                                    account=account, password=password)
    pace()
    return {c[0]: (c[2], c[3]) for c in pt.flood_retry(lambda: pt.login(login_args, details))}


def slot_limit_test(args):
    """Fills a fresh account up to the character limit and checks that one more is refused."""
    suffix = "".join(random.choice(string.ascii_lowercase) for _ in range(6))
    account, password = "slots" + suffix, "secret" + suffix
    names = ["Slot " + suffix.capitalize() + chr(ord("a") + i) for i in range(args.slot_limit + 1)]
    c = Checker()
    try:
        c.expect("create account", request(args, ACTION_CREATE_ACCOUNT, account, password), True)
        for name in names[:-1]:
            c.expect("create %s" % name, request(args, ACTION_CREATE_CHARACTER, account, password, name, 0), True)
        c.expect("create one more than %d characters" % args.slot_limit,
                 request(args, ACTION_CREATE_CHARACTER, account, password, names[-1], 0), False)
    except (pt.ProtocolError, OSError) as e:
        print("FAIL: " + str(e))
        return 1
    if c.failures:
        print("FAIL: %d character limit check(s) failed" % c.failures)
        return 1
    print("OK: an account holds at most %d characters." % args.slot_limit)
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--login-port", type=int, default=7564)
    ap.add_argument("--timeout", type=float, default=30)
    ap.add_argument("--account", help="use this existing account instead of creating a new one (live health check)")
    ap.add_argument("--password", help="password of --account")
    ap.add_argument("--slot-limit", type=int,
                    help="only check that a new account holds at most this many characters")
    args = ap.parse_args()
    if args.slot_limit:
        return slot_limit_test(args)
    if bool(args.account) != bool(args.password):
        ap.error("--account and --password go together")

    suffix = "".join(random.choice(string.ascii_lowercase) for _ in range(6))
    account, password = args.account or "acct" + suffix, args.password or "secret" + suffix
    character = "Tester " + suffix.capitalize()
    c = Checker()

    try:
        if not args.account:
            c.expect("create account", request(args, ACTION_CREATE_ACCOUNT, account, password), True)
            c.expect("create duplicate account", request(args, ACTION_CREATE_ACCOUNT, account, password), False)
            c.expect("create account with short password",
                     request(args, ACTION_CREATE_ACCOUNT, "x" + account, "abc"), False)
            c.expect("create account with a 7-character password",
                     request(args, ACTION_CREATE_ACCOUNT, "x" + account, "abcdefg"), False)
            c.expect("create account with a common password",
                     request(args, ACTION_CREATE_ACCOUNT, "x" + account, "Pokemon123"), False)
        c.expect("create character with wrong password",
                 request(args, ACTION_CREATE_CHARACTER, account, "wrong" + password, character, 1), False)
        c.expect("create character with invalid name",
                 request(args, ACTION_CREATE_CHARACTER, account, password, "x1", 1), False)
        c.expect("create character with a premium outfit",
                 request(args, ACTION_CREATE_CHARACTER, account, password, character, 1, (PREMIUM_LOOKTYPE, 0, 0, 0, 0)), False)
        c.expect("create character with a vocation outfit",
                 request(args, ACTION_CREATE_CHARACTER, account, password, character, 1, (FISHER_MALE, 0, 0, 0, 0)), False)
        c.expect("create character with a female outfit on a male",
                 request(args, ACTION_CREATE_CHARACTER, account, password, character, 1, (ROOKIE_FEMALE, 0, 0, 0, 0)), False)
        c.expect("create character with an invalid outfit color",
                 request(args, ACTION_CREATE_CHARACTER, account, password, character, 1, (ROOKIE_MALE, 133, 0, 0, 0)), False)
        c.expect("create character", request(args, ACTION_CREATE_CHARACTER, account, password, character, 1, NEW_OUTFIT), True)
        c.expect("create duplicate character",
                 request(args, ACTION_CREATE_CHARACTER, account, password, character, 0), False)

        details = {}
        characters = character_list(args, account, password, details)
        if character not in characters:
            print("FAIL: %s missing from the character list %s" % (character, list(characters)))
            return 1
        print("OK: %s is in the character list" % character)
        info = details[character]
        if (info["looktype"], *info["colors"]) == NEW_OUTFIT and info["sex"] == 1 and info["town"] and info["last_login"] == 0:
            print("OK: %s has the chosen outfit %s, sex male, town %s" % (character, NEW_OUTFIT, info["town"]))
        else:
            print("FAIL: unexpected character details %s" % info)
            c.failures += 1
        starters = details["starter outfits"]
        if ((1, ROOKIE_MALE, "Rookie") in starters and (0, ROOKIE_FEMALE, "Rookie") in starters
                and not [o for o in starters if o[1] in (PREMIUM_LOOKTYPE, FISHER_MALE)]):
            print("OK: starter outfits %s" % starters)
        else:
            print("FAIL: unexpected starter outfits %s" % starters)
            c.failures += 1
        if details["max characters"] == 3 and details["server name"] == "LeafGreen":  # config.lua
            print("OK: the character list reports 3 character slots on LeafGreen")
        else:
            print("FAIL: the character list reports %d character slots on %r, expected 3 on LeafGreen"
                  % (details["max characters"], details["server name"]))
            c.failures += 1
        old_client = argparse.Namespace(host=args.host, login_port=args.login_port, timeout=args.timeout,
                                        account=account, password=password)
        pace()
        if character in [ch[0] for ch in pt.flood_retry(lambda: pt.login(old_client, version=313))]:
            print("OK: a version 313 client still gets the character list")
        else:
            print("FAIL: version 313 character list is missing %s" % character)
            c.failures += 1

        game_args = argparse.Namespace(timeout=args.timeout, account=account, password=password, character=character)
        pace()
        conn, _, position = pt.flood_retry(lambda: pt.enter_game(game_args, *characters[character]))
        try:
            pt.drain(conn, 3)
            conn.send(b"\x14")  # logout
            pt.drain(conn, 2)
        finally:
            conn.close()
        if position == TUTORIAL_START:
            print("OK: %s entered the game at the tutorial start %s" % (character, position))
        else:
            print("FAIL: %s entered the game at %s, expected %s" % (character, position, TUTORIAL_START))
            c.failures += 1

        time.sleep(2)  # let the logout save finish before deleting
        details = {}
        character_list(args, account, password, details)
        info = details[character]
        if info["last_login"] > 0 and info["play_time"] >= 3:
            print("OK: last login %d, play time %ds after one session" % (info["last_login"], info["play_time"]))
        else:
            print("FAIL: last login %d, play time %d after one session" % (info["last_login"], info["play_time"]))
            c.failures += 1
        c.expect("delete character", request(args, ACTION_DELETE_CHARACTER, account, password, character), True)
        if character in character_list(args, account, password):
            print("FAIL: %s is still in the character list after deletion" % character)
            c.failures += 1
        else:
            print("OK: %s is gone from the character list" % character)
        for attempt in (1, 2):
            c.expect("create the deleted name again (%d)" % attempt,
                     request(args, ACTION_CREATE_CHARACTER, account, password, character, 1), True)
            c.expect("delete the reused name (%d)" % attempt,
                     request(args, ACTION_DELETE_CHARACTER, account, password, character), True)
    except (pt.ProtocolError, OSError) as e:
        print("FAIL: " + str(e))
        return 1

    if c.failures:
        print("FAIL: %d account service check(s) failed" % c.failures)
        return 1
    print("OK: account service verified (create account, create character, delete character).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
