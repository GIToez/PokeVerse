#!/usr/bin/env python3
"""Buying Verse Orbs end to end against a fake PayPal (scripts/testing/fake-paypal.py).

Needs the game server (with paymentsUrl and the test-only /paytest talkaction), the payment service
(core/payments/payments.py) and the fake PayPal running; scripts/test-server-linux.sh starts them.
It plays a buyer through the Store's button, the buy page, approving and capturing in PayPal, the
webhooks (repeated, pending, wrong amount, bad signature), the 7-day withdraw hold, a partial refund,
reversals that take the balance below zero, the in-game messages and the email receipts.
"""

import argparse
import glob
import json
import os
import re
import shlex
import subprocess
import sys
import time
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
args = None
passed = 0
sessions = []


def ok(name):
    global passed
    passed += 1
    print("PASS " + name, flush=True)


def fail(text):
    print("FAIL " + text, flush=True)
    sys.exit(1)


def check(condition, name, detail=""):
    if not condition:
        fail("%s %s" % (name, detail))
    ok(name)


def sql(query):
    out = subprocess.run(shlex.split(args.sql) + ["-N", "-e", query], check=True, capture_output=True, text=True).stdout
    return out.strip()


def game(*say):
    account, password, character = args.buyer.split(":")
    command = [sys.executable, os.path.join(ROOT, "scripts", "protocol-test.py"), "--account", account, "--password", password,
               "--character", character, "--walk", ""]
    for text in say:
        command += ["--say", text]
    out = subprocess.run(command, capture_output=True, text=True).stdout
    sessions.append(out)
    return out


def store_messages(out):
    found = []
    for line in out.splitlines():
        if "extended opcode 41: " in line:
            try:
                found.append(json.loads(line.split("extended opcode 41: ", 1)[1]))
            except ValueError:
                pass
    return found


def http(method, url, body=None, headers=None):
    data = None if body is None else (body if isinstance(body, bytes) else json.dumps(body).encode())
    request = urllib.request.Request(url, data=data, method=method)
    request.add_header("Content-Type", "application/json")
    for key, value in (headers or {}).items():
        request.add_header(key, value)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            status, raw, response_headers = response.status, response.read(), response.headers
    except urllib.error.HTTPError as e:
        status, raw, response_headers = e.code, e.read(), e.headers
    text = raw.decode("utf-8", "replace")
    try:
        return status, json.loads(text), response_headers
    except ValueError:
        return status, text, response_headers


def service(method, path, body=None):
    status, data, _ = http(method, args.service + path, body)
    return status, data


def paypal(method, path, body=None):
    status, data, _ = http(method, args.paypal + path, body)
    return status, data


event_counter = [0]


def webhook(event_type, resource, sig="valid-sig", event_id=None):
    event_counter[0] += 1
    event_id = event_id or "WH-TEST-%d-%d" % (int(time.time()), event_counter[0])
    headers = {"PAYPAL-AUTH-ALGO": "SHA256withRSA", "PAYPAL-CERT-URL": args.paypal + "/certs/test",
               "PAYPAL-TRANSMISSION-ID": "tx-%d" % event_counter[0], "PAYPAL-TRANSMISSION-SIG": sig,
               "PAYPAL-TRANSMISSION-TIME": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
    event = {"id": event_id, "event_type": event_type, "resource": resource}
    status, data, _ = http("POST", args.service + "/paypal/webhook", event, headers)
    return status, data, event_id


def balance():
    return int(sql("SELECT soulcoins FROM accounts WHERE name = '%s'" % args.buyer.split(":")[0]))


def order_field(oid, field):
    return sql("SELECT `%s` FROM payment_orders WHERE paypal_order_id = '%s'" % (field, oid))


def new_link():
    out = game("/paytest link")
    links = [m for m in store_messages(out) if m.get("type") == "buy-link"]
    if not links:
        fail("no buy link from the Store:\n" + out[-2000:])
    match = re.search(r"[?&]t=([0-9a-f]{32})$", links[0]["url"])
    if not match or not links[0]["url"].startswith(args.service + "/buy?"):
        fail("buy link looks wrong: %s" % links[0]["url"])
    return match.group(1)


def create(token, pack):
    status, data = service("POST", "/api/orders", {"t": token, "pack": pack})
    if status != 200 or not data.get("id"):
        fail("order for pack %s not created: %s %s" % (pack, status, data))
    return data["id"]


def capture_resource(oid, cap, value, status="COMPLETED"):
    return {"id": cap, "status": status, "amount": {"currency_code": "USD", "value": value},
            "supplementary_data": {"related_ids": {"order_id": oid}}}


def refund_resource(cap, value):
    return {"id": "R%d" % int(time.time() * 1000), "status": "COMPLETED", "amount": {"currency_code": "USD", "value": value},
            "links": [{"rel": "self", "href": args.paypal + "/v2/payments/refunds/x"},
                      {"rel": "up", "href": args.paypal + "/v2/payments/captures/" + cap}]}


def main():
    global args
    parser = argparse.ArgumentParser()
    parser.add_argument("--service", required=True, help="payment service, e.g. http://127.0.0.1:7200")
    parser.add_argument("--paypal", required=True, help="the fake PayPal, e.g. http://127.0.0.1:7290")
    parser.add_argument("--sql", required=True, help="mariadb command for the game database")
    parser.add_argument("--buyer", required=True, help="account:password:character with no Soul Coins yet")
    parser.add_argument("--mailbox", help="fake-smtp mailbox: check the receipts")
    args = parser.parse_args()
    account = args.buyer.split(":")[0]
    account_id = sql("SELECT id FROM accounts WHERE name = '%s'" % account)

    status, data = service("GET", "/healthz")
    check(status == 200 and data == "ok", "service health")

    sql("UPDATE accounts SET email = '%s@pokeverse.test', email_verified = 0 WHERE id = %s" % (account, account_id))
    refused = [m for m in store_messages(game("/paytest link")) if m.get("type") == "result"]
    check(refused and not refused[0]["ok"] and "verified email" in refused[0]["text"], "no buy link without a verified email", refused)
    sql("UPDATE accounts SET email_verified = 1 WHERE id = %s" % account_id)

    token = new_link()
    row = sql("SELECT CONCAT(account_id, ',', expires_at - created_at) FROM payment_links WHERE token = '%s'" % token)
    check(row == "%s,1800" % account_id, "the Store's button makes a 30-minute link for the account", row)

    status, page, headers = http("GET", args.service + "/buy?t=" + token)
    check(status == 200 and "Buy Verse Orbs" in page and "$18.00 USD" in page and "Test mode" in page
          and "client-id=ci-paypal-client" in page, "buy page shows the packs and loads PayPal with the app's client id")
    check("paypal.com" in headers.get("Content-Security-Policy", "") and headers.get("Referrer-Policy") == "no-referrer",
          "buy page keeps the link out of referrers and limits scripts")
    status, page, _ = http("GET", args.service + "/buy?t=" + "0" * 32)
    check(status == 410 and "expired" in page, "an unknown link shows the expired page")
    status, data = service("POST", "/api/orders", {"t": token, "pack": "999"})
    check(status == 400, "an unknown pack is refused", data)

    # A plain purchase: create, capture too early, approve, capture, capture again
    start = balance()
    check(start == 0, "buyer starts with no orbs", start)
    first = create(token, "40")
    state = paypal("GET", "/test/state")[1]["orders"][first]
    unit = state["purchase_units"][0]
    check(unit["amount"]["value"] == "18.00" and unit["custom_id"] == "pv-account-%s" % account_id,
          "the order's price comes from the server's pack list", unit)
    status, data = service("POST", "/api/capture", {"t": token, "orderID": first})
    check(status == 200 and not data["ok"] and balance() == 0, "capturing before PayPal approval adds nothing", data)
    paypal("POST", "/test/approve/" + first, {"email": "paypal-buyer@pokeverse.test"})
    status, data = service("POST", "/api/capture", {"t": token, "orderID": first})
    check(status == 200 and data["ok"] and data["orbs"] == 40 and data["balance"] == 40 and balance() == 40,
          "capturing the approved order adds 40 orbs", data)
    status, data = service("POST", "/api/capture", {"t": token, "orderID": first})
    check(data["ok"] and balance() == 40, "capturing again adds nothing", data)
    history = sql("SELECT CONCAT(amount, ' ', description) FROM store_history WHERE account_id = %s ORDER BY id DESC LIMIT 1" % account_id)
    check(history == "40 Bought 40 Verse Orbs with PayPal", "the purchase is in the Store history", history)
    first_capture = order_field(first, "capture_id")
    check(order_field(first, "status") == "completed" and first_capture and order_field(first, "payer_email") == "paypal-buyer@pokeverse.test",
          "the order is completed with PayPal's capture id")

    # Webhooks for the same payment change nothing; a repeated event is ignored; a bad signature is refused
    status, data, _ = webhook("CHECKOUT.ORDER.APPROVED", {"id": first, "status": "APPROVED"})
    check(status == 200 and balance() == 40, "the approval webhook after the capture adds nothing", data)
    status, data, event_id = webhook("PAYMENT.CAPTURE.COMPLETED", capture_resource(first, first_capture, "18.00"))
    check(status == 200 and balance() == 40, "the capture webhook after the capture adds nothing", data)
    status, data, _ = webhook("PAYMENT.CAPTURE.COMPLETED", capture_resource(first, first_capture, "18.00"), event_id=event_id)
    check(status == 200 and data.get("result") == "duplicate", "a repeated webhook is recognised", data)
    status, data, _ = webhook("PAYMENT.CAPTURE.REVERSED", refund_resource(first_capture, "18.00"), sig="forged")
    check(status == 400 and balance() == 40, "a webhook with a bad signature is refused", data)
    status, data, _ = http("POST", args.service + "/paypal/webhook", b"not json", {"PAYPAL-TRANSMISSION-SIG": "valid-sig"})
    check(status == 400, "a webhook that isn't JSON is refused")

    # A payment PayPal is still clearing arrives with the webhook
    second = create(token, "15")
    paypal("POST", "/test/approve/" + second, {"capture": "PENDING"})
    status, data = service("POST", "/api/capture", {"t": token, "orderID": second})
    check(data.get("pending") and balance() == 40 and order_field(second, "status") == "pending", "a pending payment adds nothing yet", data)
    second_capture = order_field(second, "capture_id")
    status, data, _ = webhook("PAYMENT.CAPTURE.COMPLETED", capture_resource(second, second_capture, "7.50"))
    check(status == 200 and balance() == 55 and order_field(second, "status") == "completed", "the cleared payment adds 15 orbs", data)

    # The approval webhook captures an order whose page was closed before it finished
    third = create(token, "15")
    paypal("POST", "/test/approve/" + third)
    status, data, _ = webhook("CHECKOUT.ORDER.APPROVED", {"id": third, "status": "APPROVED"})
    check(status == 200 and balance() == 70 and order_field(third, "status") == "completed", "the approval webhook captures and adds 15 orbs", data)

    # A capture for the wrong amount adds nothing and tells staff
    wrong = create(token, "85")
    status, data, _ = webhook("PAYMENT.CAPTURE.COMPLETED", capture_resource(wrong, "CWRONGAMOUNT0001", "1.00"))
    check(status == 200 and balance() == 70 and order_field(wrong, "status") == "failed", "a capture for the wrong amount adds nothing", data)

    # A declined card asks PayPal to let the buyer choose again
    declined = create(token, "160")
    paypal("POST", "/test/approve/" + declined, {"capture": "DECLINED"})
    status, data = service("POST", "/api/capture", {"t": token, "orderID": declined})
    check(data.get("restart") and balance() == 70, "a declined card restarts PayPal's checkout", data)

    # The 7-day hold: bought orbs can be spent but not withdrawn
    out = game("/paytest state", "/paytest withdraw 10")
    check("paytest: balance 70 held 70" in out, "all 70 bought orbs are held", out[-600:])
    refused = [m for m in store_messages(out) if m.get("type") == "result"]
    check(refused and not refused[-1]["ok"] and "can't be withdrawn yet" in refused[-1]["text"] and balance() == 70,
          "withdrawing held orbs is refused", refused)
    sql("UPDATE payment_orders SET credited_at = credited_at - 8 * 86400 WHERE paypal_order_id = '%s'" % first)
    out = game("/paytest withdraw 10", "/paytest state")
    check(balance() == 60 and "paytest: balance 60 held 30" in out, "orbs bought 8 days ago can be withdrawn", out[-600:])

    # Refunds and reversals take orbs back, below zero if they were spent
    status, data, _ = webhook("PAYMENT.CAPTURE.REFUNDED", refund_resource(first_capture, "9.00"))
    check(status == 200 and balance() == 40 and order_field(first, "taken_back") == "20", "a half refund takes back 20 orbs", data)
    status, data, _ = webhook("PAYMENT.CAPTURE.REVERSED", refund_resource(first_capture, "18.00"))
    check(balance() == 20 and order_field(first, "taken_back") == "40" and order_field(first, "status") == "reversed",
          "the reversal takes back the other 20", data)
    status, data, _ = webhook("PAYMENT.CAPTURE.REVERSED", refund_resource(first_capture, "18.00"))
    check(balance() == 20, "reversing it again takes nothing more", data)
    status, data, _ = webhook("CUSTOMER.DISPUTE.CREATED", {"dispute_id": "PP-D-TEST", "disputed_transactions": [{"seller_transaction_id": second_capture}]})
    check(status == 200 and balance() == 20 and "dispute" in data.get("result", ""), "a dispute is noted for staff without taking orbs", data)
    for oid, cap, value in ((second, second_capture, "7.50"), (third, order_field(third, "capture_id"), "7.50")):
        webhook("PAYMENT.CAPTURE.REVERSED", refund_resource(cap, value))
    check(balance() == -10, "reversing orbs that were withdrawn leaves the balance below zero", balance())
    out = game("/paytest buy premium30", "/paytest withdraw 1", "/paytest notices")
    results = [m for m in store_messages(out) if m.get("type") == "result"]
    check(len(results) >= 2 and not results[0]["ok"] and "Store is closed" in results[0]["text"] and not results[1]["ok"],
          "a balance below zero closes the Store and Withdraw", results)
    check(balance() == -10, "nothing was bought or withdrawn")

    # The messages: the buyer's when online, staff's for reversals, the wrong amount and the dispute
    notices = sql("SELECT CONCAT(SUM(kind = 'credited'), ',', SUM(kind = 'reversed'), ',', SUM(delivered = 0))"
                  " FROM payment_notices WHERE account_id = %s AND kind <> 'staff'" % account_id)
    check(notices == "3,4,0", "the buyer got 3 purchase and 4 refund messages in the game (credited,reversed,undelivered)", notices)
    everything = "\n".join(sessions)
    check("Verse Orbs were added to your balance" in everything and "below zero" in out, "the messages reached the client", out[-1500:])
    staff = sql("SELECT COUNT(*) FROM payment_notices WHERE kind = 'staff'")
    check(int(staff) >= 5, "staff were told about the reversals, the wrong amount and the dispute", staff)

    # An expired link stops working
    sql("UPDATE payment_links SET expires_at = 1 WHERE token = '%s'" % token)
    status, data = service("POST", "/api/orders", {"t": token, "pack": "15"})
    check(status == 403 and "expired" in data.get("error", ""), "an expired link can't start a payment", data)

    if args.mailbox:
        receipts = []
        for _ in range(20):
            receipts = [json.load(open(f)) for f in glob.glob(os.path.join(args.mailbox, "*.json"))]
            receipts = [m for m in receipts if "receipt" in m.get("subject", "")]
            if len(receipts) >= 3:
                break
            time.sleep(0.5)
        subjects = sorted(m["subject"] for m in receipts)
        check(subjects == ["Your PokeVerse receipt: 15 Verse Orbs", "Your PokeVerse receipt: 15 Verse Orbs", "Your PokeVerse receipt: 40 Verse Orbs"],
              "an email receipt for each purchase", subjects)
        body = [m for m in receipts if "40" in m["subject"]][0]["body"]
        check(first_capture in body and "$18.00 USD" in body, "the receipt has the price and PayPal's transaction id")

    print("PASS payments: %d checks" % passed)


if __name__ == "__main__":
    main()
