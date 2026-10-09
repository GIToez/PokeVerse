#!/usr/bin/env python3
"""End-to-end test of the in-client account service (login port, protocol id 0x0B).

Creates a fresh account, creates a character on it, checks that the character
appears in the character list and enters the game at the tutorial start, then
deletes it again. Also checks that bad requests are refused. Standard library
only, so it runs on Windows and Linux CI runners.

Usage:
  account-test.py [--host 127.0.0.1] [--login-port 7564]
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


def request(args, action, account, password, name=None, sex=None):
    """Sends one account request and returns (success, message)."""
    conn = pt.Connection(args.host, args.login_port, args.timeout)
    try:
        key = pt.new_xtea_key()
        block = b"\x00" + struct.pack("<4I", *key) + bytes([action]) + pt.pstr(account) + pt.pstr(password)
        if name is not None:
            block += pt.pstr(name)
        if sex is not None:
            block += bytes([sex])
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


def character_list(args, account, password):
    login_args = argparse.Namespace(host=args.host, login_port=args.login_port, timeout=args.timeout,
                                    account=account, password=password)
    return {c[0]: (c[2], c[3]) for c in pt.login(login_args)}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--login-port", type=int, default=7564)
    ap.add_argument("--timeout", type=float, default=30)
    ap.add_argument("--account", help="use this existing account instead of creating a new one (live health check)")
    ap.add_argument("--password", help="password of --account")
    args = ap.parse_args()
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
        c.expect("create character with wrong password",
                 request(args, ACTION_CREATE_CHARACTER, account, "wrong" + password, character, 1), False)
        c.expect("create character with invalid name",
                 request(args, ACTION_CREATE_CHARACTER, account, password, "x1", 1), False)
        c.expect("create character", request(args, ACTION_CREATE_CHARACTER, account, password, character, 1), True)
        c.expect("create duplicate character",
                 request(args, ACTION_CREATE_CHARACTER, account, password, character, 0), False)

        characters = character_list(args, account, password)
        if character not in characters:
            print("FAIL: %s missing from the character list %s" % (character, list(characters)))
            return 1
        print("OK: %s is in the character list" % character)

        game_args = argparse.Namespace(timeout=args.timeout, account=account, password=password, character=character)
        conn, _, position = pt.enter_game(game_args, *characters[character])
        try:
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
        c.expect("delete character", request(args, ACTION_DELETE_CHARACTER, account, password, character), True)
        if character in character_list(args, account, password):
            print("FAIL: %s is still in the character list after deletion" % character)
            c.failures += 1
        else:
            print("OK: %s is gone from the character list" % character)
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
