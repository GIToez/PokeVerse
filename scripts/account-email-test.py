#!/usr/bin/env python3
"""End-to-end test of account emails on a server with emailRequired and an SMTP server that
saves mail to --mailbox (scripts/testing/fake-smtp.py).

Signs up with an email and the code from it, checks that unverified signups cannot log in,
then changes the password, resets it with Forgot password, changes the email with the codes
sent to the old and the new address, and checks the 7-day window of an older account
without an email. --sql runs SQL against the server's database (for the older account).

Usage:
  account-email-test.py --mailbox DIR --sql "mysql -h127.0.0.1 -upokeverse -ppokeverse pokeverse"
"""
import argparse
import glob
import importlib.util
import json
import os
import random
import re
import shlex
import string
import subprocess
import sys
import time

_here = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("account_test", os.path.join(_here, "account-test.py"))
at = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(at)
pt = at.pt

(ACTION_CREATE_ACCOUNT, ACTION_CREATE_CHARACTER, ACTION_VERIFY_EMAIL, ACTION_RESEND_CODE, ACTION_SET_EMAIL,
 ACTION_RECOVER_REQUEST, ACTION_RECOVER_RESET, ACTION_CHANGE_PASSWORD, ACTION_EMAIL_CHANGE_REQUEST,
 ACTION_EMAIL_CHANGE_CONFIRM, ACTION_ACCOUNT_INFO) = 1, 2, 5, 6, 7, 8, 9, 10, 11, 12, 13
VERIFY, ADD, CHANGE = "#verify-email#", "#add-email#", "#change-email#"
GENERIC_RECOVER = "If that account has a verified email"


def request(args, action, account, password, *texts):
    return at.request(args, action, account, password, texts if texts else None)


class Mailbox:
    def __init__(self, folder):
        self.folder = folder
        self.seen = set(glob.glob(os.path.join(folder, "*.json")))

    def wait(self, to, timeout=20):
        """Returns the next new email to `to`."""
        deadline = time.time() + timeout
        while time.time() < deadline:
            for path in sorted(glob.glob(os.path.join(self.folder, "*.json"))):
                if path in self.seen:
                    continue
                with open(path) as f:
                    mail = json.load(f)
                if to in mail["to"]:
                    self.seen.add(path)
                    return mail
            time.sleep(0.3)
        raise pt.ProtocolError("no email to %s within %ds" % (to, timeout))

    def code(self, to):
        mail = self.wait(to)
        found = re.search(r"\b(\d{6})\b", mail["subject"])
        if not found:
            raise pt.ProtocolError("no code in %r" % mail["subject"])
        return found.group(1), mail


def login_result(args, account, password):
    login_args = argparse.Namespace(host=args.host, login_port=args.login_port, timeout=args.timeout,
                                    account=account, password=password)
    at.pace()
    try:
        pt.flood_retry(lambda: pt.login(login_args))
        return True, "character list"
    except pt.ProtocolError as e:
        return False, str(e)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--login-port", type=int, default=7564)
    ap.add_argument("--timeout", type=float, default=30)
    ap.add_argument("--mailbox", required=True)
    ap.add_argument("--sql", required=True, help="command that runs SQL from stdin on the server database")
    args = ap.parse_args()

    def sql(statement):
        out = subprocess.run(shlex.split(args.sql) + ["-N", "-e", statement], check=True, capture_output=True, text=True)
        return out.stdout.strip()

    mailbox = Mailbox(args.mailbox)
    c = at.Checker()
    suffix = "".join(random.choice(string.ascii_lowercase) for _ in range(6))
    account, password = "mail" + suffix, "secret" + suffix
    email, typo, new_email = "trainer.%s@example.com" % suffix, "trainr.%s@example.com" % suffix, "new.%s@example.org" % suffix

    def expect(label, result, success, contains=None):
        ok = c.expect(label, result, success)
        if ok and contains and contains not in result[1]:
            print("FAIL: %s: expected %r in %r" % (label, contains, result[1]))
            c.failures += 1
        return result

    try:
        expect("sign up without an email", request(args, ACTION_CREATE_ACCOUNT, account, password, ""), False, "email")
        expect("sign up with an invalid email",
               request(args, ACTION_CREATE_ACCOUNT, account, password, "not-an-email"), False, "valid email")
        expect("sign up", request(args, ACTION_CREATE_ACCOUNT, account, password, typo), True, VERIFY)
        mailbox.code(typo)
        expect("log in before verifying", login_result(args, account, password), False, VERIFY)
        expect("create a character before verifying",
               at.request(args, ACTION_CREATE_CHARACTER, account, password, "Mail " + suffix.capitalize(), 1), False, VERIFY)
        expect("another signup with the same email",
               request(args, ACTION_CREATE_ACCOUNT, "x" + account, password, typo), False, "already used")
        expect("resend at once", request(args, ACTION_RESEND_CODE, account, password), False, "wait a minute")
        expect("correct the mistyped email", request(args, ACTION_SET_EMAIL, account, password, email), True, VERIFY)
        code, mail = mailbox.code(email)
        if mail["header_from"].startswith("PokeVerse <"):
            print("OK: the email comes from %s" % mail["header_from"])
        else:
            print("FAIL: unexpected sender %r" % mail["header_from"])
            c.failures += 1
        wrong = "%06d" % ((int(code) + 1) % 1000000)
        expect("verify with a wrong code", request(args, ACTION_VERIFY_EMAIL, account, password, wrong), False, "not right")
        expect("verify", request(args, ACTION_VERIFY_EMAIL, account, password, code), True)
        expect("verify the used code again", request(args, ACTION_VERIFY_EMAIL, account, password, code), False)
        expect("log in after verifying", login_result(args, account, password), True)
        info = expect("account info", request(args, ACTION_ACCOUNT_INFO, account, password), True)
        fields = dict(line.split("=", 1) for line in info[1].split("\n"))
        if fields.get("email") == email and fields.get("verified") == "1" and fields.get("required") == "1":
            print("OK: account info %s" % fields)
        else:
            print("FAIL: unexpected account info %s" % fields)
            c.failures += 1

        new_password = "changed" + suffix
        expect("change password with the wrong password",
               request(args, ACTION_CHANGE_PASSWORD, account, "wrong" + password, new_password), False)
        expect("change to a short password", request(args, ACTION_CHANGE_PASSWORD, account, password, "short"), False, "8 to 29")
        expect("change password", request(args, ACTION_CHANGE_PASSWORD, account, password, new_password), True)
        notice = mailbox.wait(email)
        print("OK: password change notice: %s" % notice["subject"])
        expect("log in with the old password", login_result(args, account, password), False)
        password = new_password
        expect("log in with the new password", login_result(args, account, password), True)

        expect("forgot password for an unknown account",
               request(args, ACTION_RECOVER_REQUEST, "nobody" + suffix, ""), True, GENERIC_RECOVER)
        expect("forgot password by email", request(args, ACTION_RECOVER_REQUEST, email, ""), True, GENERIC_RECOVER)
        code, mail = mailbox.code(email)
        if account in mail["body"]:
            print("OK: the reset email names the account")
        else:
            print("FAIL: the reset email does not name the account: %r" % mail["body"])
            c.failures += 1
        reset_password = "recovered" + suffix
        wrong = "%06d" % ((int(code) + 1) % 1000000)
        expect("reset with a wrong code", request(args, ACTION_RECOVER_RESET, account, reset_password, wrong), False)
        expect("reset to a common password", request(args, ACTION_RECOVER_RESET, account, "password1", code), False, "common")
        expect("reset password", request(args, ACTION_RECOVER_RESET, account, reset_password, code), True)
        mailbox.wait(email)
        expect("reset again with the used code", request(args, ACTION_RECOVER_RESET, account, "again" + reset_password, code), False)
        password = reset_password
        expect("log in after the reset", login_result(args, account, password), True)

        expect("change email to the same one", request(args, ACTION_EMAIL_CHANGE_REQUEST, account, password, email), False)
        expect("ask to change the email", request(args, ACTION_EMAIL_CHANGE_REQUEST, account, password, new_email), True, CHANGE)
        old_code, _ = mailbox.code(email)
        new_code, _ = mailbox.code(new_email)
        expect("confirm with the codes swapped",
               request(args, ACTION_EMAIL_CHANGE_CONFIRM, account, password, new_code, old_code), False)
        expect("confirm the email change",
               request(args, ACTION_EMAIL_CHANGE_CONFIRM, account, password, old_code, new_code), True, new_email)
        notice = mailbox.wait(email)
        print("OK: the old email was told: %s" % notice["subject"])
        info = request(args, ACTION_ACCOUNT_INFO, account, password)
        if "email=%s\n" % new_email in info[1]:
            print("OK: the account email is now %s" % new_email)
        else:
            print("FAIL: account info after the change: %r" % info[1])
            c.failures += 1

        expect("forgot password", request(args, ACTION_RECOVER_REQUEST, account, ""), True, GENERIC_RECOVER)
        code, _ = mailbox.code(new_email)
        wrong = "%06d" % ((int(code) + 1) % 1000000)
        results = [request(args, ACTION_RECOVER_RESET, account, "tries" + suffix + "x", wrong) for _ in range(5)]
        expect("5 wrong codes", results[-1], False, "Too many")
        expect("the right code after 5 wrong ones",
               request(args, ACTION_RECOVER_RESET, account, "tries" + suffix + "x", code), False)

        old_account, old_password = "old" + suffix, "secret" + suffix
        sql("CALL pokeverse_create_account('%s', '%s')" % (old_account, old_password))
        expect("an older account without an email logs in", login_result(args, old_account, old_password), True)
        days = int(sql("SELECT CEIL((email_deadline - UNIX_TIMESTAMP()) / 86400) FROM accounts WHERE name = '%s'" % old_account))
        if days == 7:
            print("OK: the older account has 7 days to add an email")
        else:
            print("FAIL: the older account has %d days to add an email, expected 7" % days)
            c.failures += 1
        sql("UPDATE accounts SET email_deadline = UNIX_TIMESTAMP() - 1 WHERE name = '%s'" % old_account)
        expect("the older account after its 7 days", login_result(args, old_account, old_password), False, ADD)
        old_email = "old.%s@example.net" % suffix
        expect("add an email to the older account",
               request(args, ACTION_SET_EMAIL, old_account, old_password, old_email), True, VERIFY)
        code, _ = mailbox.code(old_email)
        expect("verify the older account", request(args, ACTION_VERIFY_EMAIL, old_account, old_password, code), True)
        expect("the older account logs in again", login_result(args, old_account, old_password), True)

        events = sql("SELECT GROUP_CONCAT(DISTINCT event ORDER BY event) FROM account_security_log l JOIN accounts a "
                     "ON a.id = l.account_id WHERE a.name = '%s'" % account).split(",")
        wanted = {"created", "code_sent", "email_verified", "login", "wrong_password", "password_changed",
                  "reset_requested", "password_reset", "email_change_requested", "email_changed"}
        if wanted <= set(events):
            print("OK: the security log has %s" % ", ".join(events))
        else:
            print("FAIL: the security log is missing %s" % ", ".join(sorted(wanted - set(events))))
            c.failures += 1
        hashes = sql("SELECT COUNT(*) FROM account_codes WHERE code_hash REGEXP '^[0-9]{6}$'")
        if hashes == "0":
            print("OK: no code is stored in the clear")
        else:
            print("FAIL: %s codes are stored in the clear" % hashes)
            c.failures += 1
    except (pt.ProtocolError, OSError, subprocess.CalledProcessError) as e:
        print("FAIL: " + str(e))
        return 1

    if c.failures:
        print("FAIL: %d account email check(s) failed" % c.failures)
        return 1
    print("OK: account emails verified (signup code, password change and reset, email change, 7-day window).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
