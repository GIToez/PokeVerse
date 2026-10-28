#!/usr/bin/env python3
"""PokeVerse payment service: Verse Orbs bought with PayPal Checkout (docs/payments.md).

Serves the buy page the Store's Buy Verse Orbs button opens, creates and captures the PayPal orders,
and takes PayPal's webhooks. Bought orbs go onto `accounts`.`soulcoins` (Verse Orbs are the
player-facing name of Soul Coins); the game server shows the messages left in `payment_notices`.

It listens on 127.0.0.1 only; on the live server Caddy serves it over HTTPS as account.pokeverse.quest.
The database and email settings come from the game server's config.lua and config.local.lua, the PayPal
keys from the environment or the --settings file (KEY=VALUE lines):

  PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET   the PayPal app's keys (without them buying is closed)
  PAYPAL_ENV                               sandbox (default) or live
  PAYPAL_WEBHOOK_ID                        optional; otherwise the webhook is found or created at start
  PAYMENTS_PUBLIC_URL                      the address players open, e.g. https://account.pokeverse.quest
  PAYPAL_API, PAYPAL_SDK_URL               tests only: a fake PayPal
"""

import argparse
import base64
import decimal
import html
import json
import os
import re
import secrets
import smtplib
import ssl
import sys
import threading
import time
import traceback
import urllib.error
import urllib.parse
import urllib.request
from email.message import EmailMessage
from email.utils import formataddr, formatdate, make_msgid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import pymysql

HERE = os.path.dirname(os.path.abspath(__file__))
TOKEN_RE = re.compile(r"^[0-9a-f]{32}$")
ORDER_ID_RE = re.compile(r"^[A-Za-z0-9-]{5,36}$")
HOLD_DAYS = 7
MAX_BODY = 256 * 1024
MAX_ORDERS_PER_HOUR = 20
REQUESTS_PER_MINUTE = 60
WEBHOOK_EVENTS = [
    "CHECKOUT.ORDER.APPROVED",
    "PAYMENT.CAPTURE.COMPLETED",
    "PAYMENT.CAPTURE.PENDING",
    "PAYMENT.CAPTURE.DENIED",
    "PAYMENT.CAPTURE.REFUNDED",
    "PAYMENT.CAPTURE.REVERSED",
    "CUSTOMER.DISPUTE.CREATED",
]
LUA_ASSIGN = re.compile(r"""^\s*([A-Za-z_]\w*)\s*=\s*("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|true|false|-?\d+)\s*(?:--.*)?$""")


def log(text):
    print(time.strftime("%Y-%m-%d %H:%M:%S"), text, flush=True)


def read_lua_config(paths):
    """The plain `key = value` lines of the server's config files; later files win."""
    values = {}
    for path in paths:
        if not os.path.isfile(path):
            continue
        with open(path, encoding="latin-1") as f:
            for line in f:
                m = LUA_ASSIGN.match(line.rstrip("\r\n"))
                if not m:
                    continue
                raw = m.group(2)
                if raw[0] in "\"'":
                    value = re.sub(r"\\(.)", r"\1", raw[1:-1])
                elif raw in ("true", "false"):
                    value = raw == "true"
                else:
                    value = int(raw)
                values[m.group(1)] = value
    return values


def read_settings_file(path):
    values = {}
    if path and os.path.isfile(path):
        with open(path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    values[key.strip()] = value.strip()
    return values


def to_cents(value):
    try:
        return int((decimal.Decimal(str(value)) * 100).to_integral_value(decimal.ROUND_HALF_UP))
    except (decimal.InvalidOperation, TypeError, ValueError):
        return -1


def money(cents, currency):
    symbol = "$" if currency == "USD" else ""
    return "%s%d.%02d %s" % (symbol, cents // 100, cents % 100, currency)


class ApiError(Exception):
    def __init__(self, status, message):
        Exception.__init__(self, message)
        self.status = status
        self.message = message


class Settings:
    def __init__(self, args):
        env = dict(os.environ)
        env.update(read_settings_file(args.settings))
        self.client_id = env.get("PAYPAL_CLIENT_ID", "").strip()
        self.client_secret = env.get("PAYPAL_CLIENT_SECRET", "").strip()
        self.live = env.get("PAYPAL_ENV", "sandbox").strip().lower() == "live"
        self.api = (env.get("PAYPAL_API") or ("https://api-m.paypal.com" if self.live else "https://api-m.sandbox.paypal.com")).rstrip("/")
        self.sdk_url = env.get("PAYPAL_SDK_URL") or "https://www.paypal.com/sdk/js"
        self.webhook_id = env.get("PAYPAL_WEBHOOK_ID", "").strip()
        self.public_url = env.get("PAYMENTS_PUBLIC_URL", "").strip().rstrip("/")
        self.website = env.get("PAYMENTS_WEBSITE", "https://pokeverse.quest")
        self.host = args.host
        self.port = args.port
        lua = read_lua_config([os.path.join(args.server_dir, "config.lua"), os.path.join(args.server_dir, "config.local.lua")])
        self.db = dict(host=lua.get("sqlHost", "127.0.0.1"), port=int(lua.get("sqlPort", 3306)), user=lua.get("sqlUser", ""),
                       password=lua.get("sqlPass", ""), database=lua.get("sqlDatabase", ""))
        self.require_email = env.get("PAYMENTS_REQUIRE_EMAIL", "1") != "0"
        self.smtp = dict(host=lua.get("smtpHost", ""), port=int(lua.get("smtpPort", 587)), starttls=bool(lua.get("smtpStartTls", True)),
                         user=lua.get("smtpUser", ""), password=lua.get("smtpPassword", ""),
                         sender=lua.get("smtpFrom", "") or lua.get("smtpUser", ""), name=lua.get("smtpFromName", "PokeVerse"),
                         ca=lua.get("smtpCaFile", ""))
        with open(args.packs, encoding="utf-8") as f:
            data = json.load(f)
        self.currency = data["currency"]
        self.packs = []
        for pack in data["packs"]:
            cents = to_cents(pack["price"])
            if cents <= 0 or int(pack["orbs"]) <= 0:
                raise SystemExit("packs.json: pack %s has no price or orbs" % pack.get("id"))
            self.packs.append(dict(id=str(pack["id"]), orbs=int(pack["orbs"]), price="%d.%02d" % (cents // 100, cents % 100),
                                   cents=cents, badge=pack.get("badge", "")))
        self.pack_by_id = {p["id"]: p for p in self.packs}

    def paypal_configured(self):
        return bool(self.client_id and self.client_secret)


class PayPal:
    def __init__(self, settings):
        self.s = settings
        self.lock = threading.Lock()
        self.token = None
        self.expires = 0

    def _open(self, request):
        context = ssl.create_default_context() if request.full_url.startswith("https:") else None
        return urllib.request.urlopen(request, timeout=30, context=context)

    def access_token(self, refresh=False):
        with self.lock:
            if self.token and not refresh and time.time() < self.expires - 60:
                return self.token
            auth = base64.b64encode(("%s:%s" % (self.s.client_id, self.s.client_secret)).encode()).decode()
            request = urllib.request.Request(self.s.api + "/v1/oauth2/token", data=b"grant_type=client_credentials", method="POST",
                                             headers={"Authorization": "Basic " + auth, "Accept": "application/json",
                                                      "Content-Type": "application/x-www-form-urlencoded"})
            try:
                with self._open(request) as response:
                    data = json.loads(response.read())
            except urllib.error.HTTPError as e:
                raise ApiError(502, "PayPal refused the app's keys (HTTP %d). Check PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET and PAYPAL_ENV." % e.code)
            self.token = data["access_token"]
            self.expires = time.time() + int(data.get("expires_in", 3600))
            return self.token

    def call(self, method, path, body=None, headers=None):
        """(HTTP status, JSON body) of a PayPal REST call; an expired token is renewed once."""
        for attempt in (0, 1):
            token = self.access_token(refresh=attempt == 1)
            request = urllib.request.Request(self.s.api + path, method=method,
                                             data=None if body is None else json.dumps(body).encode())
            request.add_header("Authorization", "Bearer " + token)
            request.add_header("Accept", "application/json")
            request.add_header("Content-Type", "application/json")
            for key, value in (headers or {}).items():
                request.add_header(key, value)
            try:
                with self._open(request) as response:
                    raw = response.read()
                    return response.status, json.loads(raw) if raw else {}
            except urllib.error.HTTPError as e:
                raw = e.read()
                if e.code == 401 and attempt == 0:
                    continue
                try:
                    return e.code, json.loads(raw) if raw else {}
                except ValueError:
                    return e.code, {}
        return 401, {}


def issue_of(data):
    for detail in data.get("details") or []:
        if detail.get("issue"):
            return detail["issue"]
    return data.get("name", "")


def capture_id_of(resource):
    for link in resource.get("links") or []:
        href = link.get("href", "")
        if link.get("rel") == "up" and "/captures/" in href:
            return href.rstrip("/").rsplit("/", 1)[-1]
    return None


class Service:
    def __init__(self, settings):
        self.s = settings
        self.paypal = PayPal(settings)
        self.rate_lock = threading.Lock()
        self.requests = {}
        self.webhook_lock = threading.Lock()

    # Database -------------------------------------------------------------------------------------------

    def connect(self):
        return pymysql.connect(connect_timeout=10, autocommit=False, cursorclass=pymysql.cursors.DictCursor, charset="utf8mb4", **self.s.db)

    def find_link(self, cur, token):
        if not TOKEN_RE.match(token or ""):
            return None
        cur.execute("SELECT l.`account_id`, l.`player_id`, l.`expires_at`, a.`email`, a.`email_verified`, a.`soulcoins`, p.`name` AS `player`"
                    " FROM `payment_links` l JOIN `accounts` a ON a.`id` = l.`account_id` LEFT JOIN `players` p ON p.`id` = l.`player_id`"
                    " WHERE l.`token` = %s AND l.`expires_at` > %s", (token, int(time.time())))
        return cur.fetchone()

    def held(self, cur, account_id):
        cur.execute("SELECT COALESCE(SUM(`orbs` - `taken_back`), 0) AS `n` FROM `payment_orders` WHERE `account_id` = %s"
                    " AND `status` = 'completed' AND `credited_at` > %s", (account_id, int(time.time()) - HOLD_DAYS * 86400))
        return int(cur.fetchone()["n"])

    def balance(self, cur, account_id):
        cur.execute("SELECT `soulcoins` FROM `accounts` WHERE `id` = %s", (account_id,))
        row = cur.fetchone()
        return int(row["soulcoins"]) if row else 0

    def order_row(self, cur, paypal_order_id=None, capture_id=None, lock=False):
        column, value = ("paypal_order_id", paypal_order_id) if paypal_order_id else ("capture_id", capture_id)
        if not value:
            return None
        cur.execute("SELECT * FROM `payment_orders` WHERE `%s` = %%s%s" % (column, " FOR UPDATE" if lock else ""), (value,))
        return cur.fetchone()

    def notice(self, cur, account_id, kind, orbs, text):
        cur.execute("INSERT INTO `payment_notices` (`account_id`, `kind`, `orbs`, `text`, `created_at`) VALUES (%s, %s, %s, %s, %s)",
                    (account_id, kind, orbs, text[:255], int(time.time())))

    # Orders ---------------------------------------------------------------------------------------------

    def create_order(self, token, pack_id):
        pack = self.s.pack_by_id.get(str(pack_id or ""))
        if not pack:
            raise ApiError(400, "Choose one of the packs.")
        conn = self.connect()
        try:
            with conn.cursor() as cur:
                link = self.check_link(cur, token)
                cur.execute("SELECT COUNT(*) AS `n` FROM `payment_orders` WHERE `account_id` = %s AND `created_at` > %s",
                            (link["account_id"], int(time.time()) - 3600))
                if cur.fetchone()["n"] >= MAX_ORDERS_PER_HOUR:
                    raise ApiError(429, "That's a lot of payments started in one hour. Try again later.")
            conn.commit()
            value = {"currency_code": self.s.currency, "value": pack["price"]}
            name = "%d Verse Orbs" % pack["orbs"]
            body = {
                "intent": "CAPTURE",
                "purchase_units": [{
                    "reference_id": "orbs-" + pack["id"],
                    "custom_id": "pv-account-%d" % link["account_id"],
                    "description": name + " for PokeVerse",
                    "soft_descriptor": "POKEVERSE",
                    "amount": dict(value, breakdown={"item_total": value}),
                    "items": [{"name": name, "quantity": "1", "unit_amount": value, "category": "DIGITAL_GOODS", "sku": "orbs-" + pack["id"]}],
                }],
                "application_context": {"brand_name": "PokeVerse", "shipping_preference": "NO_SHIPPING", "user_action": "PAY_NOW"},
            }
            status, data = self.paypal.call("POST", "/v2/checkout/orders", body, {"PayPal-Request-Id": "pv-order-" + secrets.token_hex(12)})
            if status not in (200, 201) or not ORDER_ID_RE.match(str(data.get("id", ""))):
                log("PayPal order not created for account %d: HTTP %d %s" % (link["account_id"], status, issue_of(data)))
                raise ApiError(502, "PayPal could not start the payment. Try again in a minute.")
            now = int(time.time())
            with conn.cursor() as cur:
                cur.execute("INSERT INTO `payment_orders` (`paypal_order_id`, `account_id`, `player_id`, `pack`, `orbs`, `amount_cents`, `currency`,"
                            " `status`, `created_at`, `updated_at`) VALUES (%s, %s, %s, %s, %s, %s, %s, 'created', %s, %s)",
                            (data["id"], link["account_id"], link["player_id"], pack["id"], pack["orbs"], pack["cents"], self.s.currency, now, now))
            conn.commit()
            log("Order %s created: account %d, %d orbs for %s" % (data["id"], link["account_id"], pack["orbs"], money(pack["cents"], self.s.currency)))
            return {"id": data["id"]}
        finally:
            conn.close()

    def check_link(self, cur, token):
        link = self.find_link(cur, token)
        if not link:
            raise ApiError(403, "This link has expired. Open the Store in the game and press Buy Verse Orbs again.")
        if self.s.require_email and not link["email_verified"]:
            raise ApiError(403, "Verify your account's email first (Account, on the character list).")
        return link

    def capture_order(self, token, paypal_order_id):
        if not ORDER_ID_RE.match(str(paypal_order_id or "")):
            raise ApiError(400, "Unknown payment.")
        conn = self.connect()
        try:
            with conn.cursor() as cur:
                link = self.check_link(cur, token)
                row = self.order_row(cur, paypal_order_id=paypal_order_id)
            conn.commit()
            if not row or row["account_id"] != link["account_id"]:
                raise ApiError(404, "Unknown payment.")
            return self.capture(conn, row)
        finally:
            conn.close()

    def capture(self, conn, row):
        if row["status"] == "completed":
            return self.done_message(conn, row)
        oid = row["paypal_order_id"]
        status, data = self.paypal.call("POST", "/v2/checkout/orders/%s/capture" % oid, {},
                                        {"PayPal-Request-Id": "pv-capture-" + oid, "Prefer": "return=representation"})
        if status in (200, 201):
            return self.apply_order(conn, row, data)
        issue = issue_of(data)
        if issue == "ORDER_ALREADY_CAPTURED":
            status, data = self.paypal.call("GET", "/v2/checkout/orders/%s" % oid)
            if status == 200:
                return self.apply_order(conn, row, data)
        if issue == "INSTRUMENT_DECLINED":
            return {"ok": False, "restart": True, "message": "PayPal declined that card or account. Choose another way to pay."}
        if issue == "ORDER_NOT_APPROVED":
            return {"ok": False, "message": "The payment wasn't approved in PayPal. Nothing was charged."}
        log("Capture of %s failed: HTTP %d %s" % (oid, status, issue))
        return {"ok": False, "message": "PayPal could not finish the payment. Nothing was charged; try again."}

    def apply_order(self, conn, row, order):
        units = order.get("purchase_units") or []
        captures = ((units[0].get("payments") or {}).get("captures") or []) if units else []
        if not captures:
            return {"ok": False, "message": "PayPal has not taken the payment yet. Try again."}
        return self.apply_capture(conn, row, captures[0], (order.get("payer") or {}).get("email_address", ""))

    def apply_capture(self, conn, row, capture, payer_email=""):
        capture_id = str(capture.get("id", ""))[:36]
        state = capture.get("status")
        amount = capture.get("amount") or {}
        now = int(time.time())
        if state == "COMPLETED":
            if to_cents(amount.get("value")) != row["amount_cents"] or amount.get("currency_code") != row["currency"]:
                with conn.cursor() as cur:
                    cur.execute("UPDATE `payment_orders` SET `status` = 'failed', `capture_id` = %s, `updated_at` = %s WHERE `id` = %s AND `credited_at` = 0",
                                (capture_id, now, row["id"]))
                    self.notice(cur, row["account_id"], "staff", 0, "Payments: order %s paid %s %s instead of %s; no orbs added. Check it in PayPal."
                                % (row["paypal_order_id"], amount.get("value"), amount.get("currency_code"), money(row["amount_cents"], row["currency"])))
                conn.commit()
                log("Order %s: captured amount %s %s does not match" % (row["paypal_order_id"], amount.get("value"), amount.get("currency_code")))
                return {"ok": False, "message": "Something is off with this payment. Staff have been told and will sort it out."}
            if self.credit(conn, row, capture_id, payer_email):
                threading.Thread(target=self.send_receipt, args=(row["id"],), daemon=True).start()
            return self.done_message(conn, row)
        if state == "PENDING":
            with conn.cursor() as cur:
                cur.execute("UPDATE `payment_orders` SET `status` = 'pending', `capture_id` = %s, `payer_email` = %s, `updated_at` = %s"
                            " WHERE `id` = %s AND `status` = 'created'", (capture_id, payer_email[:255], now, row["id"]))
            conn.commit()
            log("Order %s: capture %s is pending at PayPal" % (row["paypal_order_id"], capture_id))
            return {"ok": True, "pending": True,
                    "message": "PayPal is still clearing this payment. The orbs arrive by themselves when it clears, with a message in the game."}
        if state in ("DECLINED", "FAILED"):
            with conn.cursor() as cur:
                cur.execute("UPDATE `payment_orders` SET `status` = 'failed', `updated_at` = %s WHERE `id` = %s AND `status` IN ('created', 'pending')",
                            (now, row["id"]))
            conn.commit()
            return {"ok": False, "message": "PayPal declined the payment. Nothing was charged."}
        return {"ok": False, "message": "This payment is %s at PayPal." % str(state).lower()}

    def done_message(self, conn, row):
        with conn.cursor() as cur:
            balance = self.balance(cur, row["account_id"])
        conn.commit()
        return {"ok": True, "orbs": row["orbs"], "balance": balance,
                "message": "%d Verse Orbs were added to your balance. Thank you for supporting PokeVerse!" % row["orbs"]}

    def credit(self, conn, row, capture_id, payer_email):
        """Adds the order's orbs once: the status change and the deposit are one transaction."""
        now = int(time.time())
        with conn.cursor() as cur:
            cur.execute("UPDATE `payment_orders` SET `status` = 'completed', `capture_id` = %s, `payer_email` = IF(%s = '', `payer_email`, %s),"
                        " `credited_at` = %s, `updated_at` = %s WHERE `id` = %s AND `status` IN ('created', 'pending')",
                        (capture_id, payer_email[:255], payer_email[:255], now, now, row["id"]))
            if cur.rowcount != 1:
                conn.commit()
                return False
            cur.execute("UPDATE `accounts` SET `soulcoins` = `soulcoins` + %s WHERE `id` = %s", (row["orbs"], row["account_id"]))
            cur.execute("INSERT INTO `store_history` (`account_id`, `player_id`, `date`, `amount`, `description`) VALUES (%s, %s, %s, %s, %s)",
                        (row["account_id"], row["player_id"], now, row["orbs"], "Bought %d Verse Orbs with PayPal" % row["orbs"]))
            self.notice(cur, row["account_id"], "credited", row["orbs"],
                        "%d Verse Orbs were added to your balance. Thank you for supporting PokeVerse!" % row["orbs"])
        conn.commit()
        row["status"] = "completed"
        log("Order %s completed: %d orbs added to account %d (capture %s)" % (row["paypal_order_id"], row["orbs"], row["account_id"], capture_id))
        return True

    def take_back(self, conn, order_id, wanted, kind):
        """Takes up to `wanted` orbs of a credited order off the balance after a refund or reversal."""
        now = int(time.time())
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM `payment_orders` WHERE `id` = %s FOR UPDATE", (order_id,))
            row = cur.fetchone()
            if row["credited_at"] == 0:
                cur.execute("UPDATE `payment_orders` SET `status` = %s, `updated_at` = %s WHERE `id` = %s", (kind, now, order_id))
                conn.commit()
                return 0
            n = min(wanted, row["orbs"] - row["taken_back"])
            if n <= 0:
                conn.commit()
                return 0
            cur.execute("UPDATE `payment_orders` SET `taken_back` = `taken_back` + %s, `status` = %s, `updated_at` = %s WHERE `id` = %s",
                        (n, kind, now, order_id))
            cur.execute("UPDATE `accounts` SET `soulcoins` = `soulcoins` - %s WHERE `id` = %s", (n, row["account_id"]))
            balance = self.balance(cur, row["account_id"])
            what = "refund" if kind == "refunded" else "reversal"
            cur.execute("INSERT INTO `store_history` (`account_id`, `player_id`, `date`, `amount`, `description`) VALUES (%s, %s, %s, %s, %s)",
                        (row["account_id"], row["player_id"], now, -n, "PayPal %s: %d Verse Orbs taken back" % (what, n)))
            text = "PayPal %s a payment, so %d Verse Orbs were taken off your balance." % ("refunded" if kind == "refunded" else "reversed", n)
            if balance < 0:
                text += " Your balance is below zero, so the Store is closed for this account until it is paid back."
            self.notice(cur, row["account_id"], "reversed", -n, text)
            if kind == "reversed" or balance < 0:
                self.notice(cur, row["account_id"], "staff", -n, "Payments: PayPal %s on account %d (order %s): %d orbs taken back, balance now %d."
                            % (what, row["account_id"], row["paypal_order_id"], n, balance))
        conn.commit()
        log("Order %s %s: %d orbs taken back from account %d, balance %d" % (row["paypal_order_id"], kind, n, row["account_id"], balance))
        return n

    # Webhooks -------------------------------------------------------------------------------------------

    def ensure_webhook(self):
        """Finds or creates the PayPal webhook for PAYMENTS_PUBLIC_URL, unless PAYPAL_WEBHOOK_ID is set."""
        with self.webhook_lock:
            if self.s.webhook_id or not self.s.public_url or not self.s.paypal_configured():
                return self.s.webhook_id
            url = self.s.public_url + "/paypal/webhook"
            status, data = self.paypal.call("GET", "/v1/notifications/webhooks")
            if status != 200:
                log("Could not list the PayPal webhooks: HTTP %d %s" % (status, issue_of(data)))
                return ""
            wanted = [{"name": name} for name in WEBHOOK_EVENTS]
            for hook in data.get("webhooks") or []:
                if hook.get("url") == url:
                    have = {t.get("name") for t in hook.get("event_types") or []}
                    if not set(WEBHOOK_EVENTS) <= have and "*" not in have:
                        self.paypal.call("PATCH", "/v1/notifications/webhooks/%s" % hook["id"],
                                         [{"op": "replace", "path": "/event_types", "value": wanted}])
                    self.s.webhook_id = hook["id"]
                    log("PayPal webhook %s found for %s" % (hook["id"], url))
                    return self.s.webhook_id
            status, data = self.paypal.call("POST", "/v1/notifications/webhooks", {"url": url, "event_types": wanted})
            if status in (200, 201) and data.get("id"):
                self.s.webhook_id = data["id"]
                log("PayPal webhook %s created for %s" % (data["id"], url))
            else:
                log("Could not create the PayPal webhook for %s: HTTP %d %s" % (url, status, issue_of(data)))
            return self.s.webhook_id

    def verify_webhook(self, headers, event):
        webhook_id = self.ensure_webhook()
        if not webhook_id:
            log("Webhook refused: no PayPal webhook id yet")
            return False
        fields = {"auth_algo": "PAYPAL-AUTH-ALGO", "cert_url": "PAYPAL-CERT-URL", "transmission_id": "PAYPAL-TRANSMISSION-ID",
                  "transmission_sig": "PAYPAL-TRANSMISSION-SIG", "transmission_time": "PAYPAL-TRANSMISSION-TIME"}
        body = {}
        for key, header in fields.items():
            value = headers.get(header)
            if not value:
                return False
            body[key] = value
        body["webhook_id"] = webhook_id
        body["webhook_event"] = event
        status, data = self.paypal.call("POST", "/v1/notifications/verify-webhook-signature", body)
        return status == 200 and data.get("verification_status") == "SUCCESS"

    def webhook(self, headers, raw):
        try:
            event = json.loads(raw)
        except ValueError:
            raise ApiError(400, "not JSON")
        if not isinstance(event, dict) or not self.verify_webhook(headers, event):
            log("Webhook refused: the signature did not verify")
            raise ApiError(400, "signature")
        event_id = str(event.get("id", ""))[:64]
        event_type = str(event.get("event_type", ""))[:64]
        conn = self.connect()
        try:
            with conn.cursor() as cur:
                cur.execute("INSERT IGNORE INTO `payment_events` (`event_id`, `event_type`, `received_at`) VALUES (%s, %s, %s)",
                            (event_id, event_type, int(time.time())))
                fresh = cur.rowcount == 1
            conn.commit()
            if not fresh:
                return {"result": "duplicate"}
            try:
                result, order_id = self.handle_event(conn, event_type, event.get("resource") or {})
            except Exception:
                conn.rollback()
                with conn.cursor() as cur:
                    cur.execute("DELETE FROM `payment_events` WHERE `event_id` = %s", (event_id,))
                conn.commit()
                raise
            with conn.cursor() as cur:
                cur.execute("UPDATE `payment_events` SET `result` = %s, `order_id` = %s WHERE `event_id` = %s", (result[:64], order_id, event_id))
            conn.commit()
            log("Webhook %s %s: %s" % (event_type, event_id, result))
            return {"result": result}
        finally:
            conn.close()

    def handle_event(self, conn, event_type, resource):
        with conn.cursor() as cur:
            if event_type == "CHECKOUT.ORDER.APPROVED":
                row = self.order_row(cur, paypal_order_id=resource.get("id"))
            elif event_type in ("PAYMENT.CAPTURE.COMPLETED", "PAYMENT.CAPTURE.PENDING", "PAYMENT.CAPTURE.DENIED"):
                related = (resource.get("supplementary_data") or {}).get("related_ids") or {}
                row = self.order_row(cur, paypal_order_id=related.get("order_id")) or self.order_row(cur, capture_id=resource.get("id"))
            elif event_type in ("PAYMENT.CAPTURE.REFUNDED", "PAYMENT.CAPTURE.REVERSED"):
                row = self.order_row(cur, capture_id=capture_id_of(resource) or resource.get("id"))
            elif event_type == "CUSTOMER.DISPUTE.CREATED":
                row = None
                for t in resource.get("disputed_transactions") or []:
                    row = row or self.order_row(cur, capture_id=t.get("seller_transaction_id"))
            else:
                return "ignored", None
        conn.commit()
        if not row:
            return "unknown order", None
        if event_type == "CHECKOUT.ORDER.APPROVED":
            if row["status"] != "created":
                return "already " + row["status"], row["id"]
            return "capture: " + self.capture(conn, row)["message"][:50], row["id"]
        if event_type.startswith("PAYMENT.CAPTURE.") and event_type not in ("PAYMENT.CAPTURE.REFUNDED", "PAYMENT.CAPTURE.REVERSED"):
            if event_type == "PAYMENT.CAPTURE.DENIED":
                resource = dict(resource, status="DECLINED")
            self.apply_capture(conn, row, resource)
            return "capture " + str(resource.get("status", "")).lower(), row["id"]
        if event_type == "PAYMENT.CAPTURE.REFUNDED":
            cents = to_cents((resource.get("amount") or {}).get("value"))
            wanted = row["orbs"] if cents >= row["amount_cents"] else (row["orbs"] * cents + row["amount_cents"] // 2) // row["amount_cents"]
            return "refund: %d orbs taken back" % self.take_back(conn, row["id"], wanted, "refunded"), row["id"]
        if event_type == "PAYMENT.CAPTURE.REVERSED":
            return "reversal: %d orbs taken back" % self.take_back(conn, row["id"], row["orbs"], "reversed"), row["id"]
        with conn.cursor() as cur:
            self.notice(cur, row["account_id"], "staff", 0, "Payments: PayPal dispute %s opened on account %d (order %s, %d orbs). The orbs are"
                        " taken back if PayPal reverses the payment." % (str(resource.get("dispute_id", ""))[:24], row["account_id"],
                                                                        row["paypal_order_id"], row["orbs"]))
        conn.commit()
        return "dispute noted", row["id"]

    # Receipts -------------------------------------------------------------------------------------------

    def send_receipt(self, order_id):
        try:
            conn = self.connect()
            try:
                with conn.cursor() as cur:
                    cur.execute("SELECT o.*, a.`email`, p.`name` AS `player` FROM `payment_orders` o JOIN `accounts` a ON a.`id` = o.`account_id`"
                                " LEFT JOIN `players` p ON p.`id` = o.`player_id` WHERE o.`id` = %s", (order_id,))
                    row = cur.fetchone()
                conn.commit()
            finally:
                conn.close()
            to = (row or {}).get("email") or ""
            if not to:
                return
            smtp = self.s.smtp
            message = EmailMessage()
            message["From"] = formataddr((smtp["name"], smtp["sender"]))
            message["To"] = to
            message["Subject"] = "Your PokeVerse receipt: %d Verse Orbs" % row["orbs"]
            message["Date"] = formatdate(localtime=True)
            message["Message-ID"] = make_msgid(domain=(smtp["sender"].split("@")[-1] or "pokeverse.quest"))
            message.set_content(
                "Hello,\n\n"
                "Thank you for supporting PokeVerse! Here is your receipt.\n\n"
                "  %d Verse Orbs\n"
                "  Character: %s\n"
                "  Paid: %s\n"
                "  PayPal transaction: %s\n"
                "  Date: %s\n\n"
                "The orbs are on your account's balance, shared by its characters. Spend them in the Store right away;\n"
                "orbs you buy can be withdrawn to your bag after %d days.\n\n"
                "The PokeVerse Team\n" % (row["orbs"], row["player"] or "-", money(row["amount_cents"], row["currency"]), row["capture_id"],
                                          time.strftime("%Y-%m-%d %H:%M UTC", time.gmtime(row["credited_at"])), HOLD_DAYS))
            if not smtp["host"]:
                log("Receipt for order %s not sent: no smtpHost in config.lua" % row["paypal_order_id"])
                return
            context = ssl.create_default_context(cafile=smtp["ca"] or None)
            with smtplib.SMTP(smtp["host"], smtp["port"], timeout=30) as client:
                client.ehlo()
                if smtp["starttls"]:
                    client.starttls(context=context)
                    client.ehlo()
                if smtp["user"]:
                    client.login(smtp["user"], smtp["password"])
                client.send_message(message)
            log("Receipt for order %s sent" % row["paypal_order_id"])
        except Exception as e:
            log("Receipt for order %s failed: %s" % (order_id, e))

    # Page -----------------------------------------------------------------------------------------------

    def buy_page(self, token):
        conn = self.connect()
        try:
            with conn.cursor() as cur:
                link = self.find_link(cur, token)
                held = self.held(cur, link["account_id"]) if link else 0
            conn.commit()
        finally:
            conn.close()
        if not link:
            return 410, self.message_page("This link has expired",
                                          "Buy links work for 30 minutes. Open the Store in the game and press Buy Verse Orbs again.")
        if self.s.require_email and not link["email_verified"]:
            return 403, self.message_page("Verify your email first",
                                          "Buying Verse Orbs needs a verified email. On the character list, open Account and verify it.")
        if not self.s.paypal_configured():
            return 503, self.message_page("Buying isn't open yet", "Verse Orbs can't be bought yet. Check the PokeVerse Discord for news.")
        packs = []
        for pack in self.s.packs:
            per = pack["cents"] / pack["orbs"] / 100
            packs.append('<button type="button" class="pack" data-pack="%s"><span class="orb"></span><b>%d</b><span class="name">Verse Orbs</span>'
                         '<span class="price">%s</span><span class="per">$%.2f each</span>%s</button>'
                         % (html.escape(pack["id"]), pack["orbs"], html.escape(money(pack["cents"], self.s.currency)), per,
                            '<span class="badge">%s</span>' % html.escape(pack["badge"]) if pack["badge"] else ""))
        config = {"token": token, "sdk": "%s?%s" % (self.s.sdk_url, urllib.parse.urlencode(
            {"client-id": self.s.client_id, "currency": self.s.currency, "intent": "capture", "disable-funding": "paylater"}))}
        with open(os.path.join(HERE, "buy.html"), encoding="utf-8") as f:
            page = f.read()
        balance = int(link["soulcoins"])
        replacements = {
            "{{player}}": html.escape(link["player"] or "your account"),
            "{{balance}}": "{:,}".format(balance),
            "{{held}}": ("%s of them can be withdrawn to the bag in a few days." % "{:,}".format(held)) if held > 0 else "",
            "{{packs}}": "\n".join(packs),
            "{{sandbox}}": "" if self.s.live else '<p class="sandbox">Test mode: PayPal sandbox, no real money is taken.</p>',
            "{{config}}": json.dumps(config).replace("<", "\\u003c"),
            "{{website}}": html.escape(self.s.website),
            "{{hold_days}}": str(HOLD_DAYS),
        }
        for key, value in replacements.items():
            page = page.replace(key, value)
        return 200, page

    def message_page(self, title, text):
        with open(os.path.join(HERE, "message.html"), encoding="utf-8") as f:
            page = f.read()
        return page.replace("{{title}}", html.escape(title)).replace("{{text}}", html.escape(text)).replace("{{website}}", html.escape(self.s.website))

    def allow(self, ip):
        now = time.time()
        with self.rate_lock:
            recent = [t for t in self.requests.get(ip, []) if now - t < 60]
            recent.append(now)
            self.requests[ip] = recent
            if len(self.requests) > 10000:
                self.requests = {k: v for k, v in self.requests.items() if v and now - v[-1] < 60}
            return len(recent) <= REQUESTS_PER_MINUTE


CSP = ("default-src 'self'; script-src 'self' https://*.paypal.com https://*.paypalobjects.com; "
       "style-src 'self' 'unsafe-inline'; img-src 'self' data: https://*.paypal.com https://*.paypalobjects.com; "
       "frame-src https://*.paypal.com; connect-src 'self' https://*.paypal.com; base-uri 'none'; form-action 'none'; frame-ancestors 'none'")
STATIC = {"/buy.js": "application/javascript; charset=utf-8", "/buy.css": "text/css; charset=utf-8"}


def make_handler(service):
    class Handler(BaseHTTPRequestHandler):
        server_version = "PokeVerse"
        sys_version = ""
        protocol_version = "HTTP/1.1"

        def log_message(self, fmt, *args):
            pass  # the request line carries the buy link's token

        def client_ip(self):
            forwarded = self.headers.get("X-Forwarded-For", "")
            if self.client_address[0] == "127.0.0.1" and forwarded:
                return forwarded.split(",")[-1].strip()
            return self.client_address[0]

        def send(self, status, body, content_type="text/html; charset=utf-8", extra=None):
            data = body.encode("utf-8") if isinstance(body, str) else body
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("Referrer-Policy", "no-referrer")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Content-Security-Policy", CSP)
            for key, value in (extra or {}).items():
                self.send_header(key, value)
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(data)

        def send_json(self, status, data):
            self.send(status, json.dumps(data), "application/json")

        def do_HEAD(self):
            self.do_GET()

        def do_GET(self):
            url = urllib.parse.urlsplit(self.path)
            try:
                if url.path == "/healthz":
                    conn = service.connect()
                    conn.close()
                    self.send(200, "ok", "text/plain")
                elif url.path == "/buy":
                    if not service.allow(self.client_ip()):
                        self.send(429, service.message_page("Slow down", "Too many requests. Wait a minute and try again."))
                        return
                    token = (urllib.parse.parse_qs(url.query).get("t") or [""])[0]
                    status, page = service.buy_page(token)
                    self.send(status, page)
                elif url.path in STATIC:
                    with open(os.path.join(HERE, "static", url.path[1:]), "rb") as f:
                        self.send(200, f.read(), STATIC[url.path], {"Cache-Control": "max-age=3600"})
                elif url.path == "/":
                    self.send(302, "", "text/plain", {"Location": service.s.website})
                else:
                    self.send(404, service.message_page("Not found", "There is nothing here."))
            except Exception:
                log("GET %s failed:\n%s" % (url.path, traceback.format_exc()))
                self.send(500, service.message_page("Something went wrong", "Try again in a minute."))

        def do_POST(self):
            path = urllib.parse.urlsplit(self.path).path
            try:
                length = int(self.headers.get("Content-Length") or 0)
                if length <= 0 or length > MAX_BODY:
                    raise ApiError(413, "Request too large.")
                raw = self.rfile.read(length)
                if path == "/paypal/webhook":
                    self.send_json(200, service.webhook(self.headers, raw))
                    return
                if not service.allow(self.client_ip()):
                    raise ApiError(429, "Too many requests. Wait a minute and try again.")
                try:
                    data = json.loads(raw)
                except ValueError:
                    raise ApiError(400, "Bad request.")
                if not isinstance(data, dict):
                    raise ApiError(400, "Bad request.")
                if path == "/api/orders":
                    self.send_json(200, service.create_order(data.get("t"), data.get("pack")))
                elif path == "/api/capture":
                    self.send_json(200, service.capture_order(data.get("t"), data.get("orderID")))
                else:
                    raise ApiError(404, "Not found.")
            except ApiError as e:
                self.send_json(e.status, {"error": e.message})
            except Exception:
                log("POST %s failed:\n%s" % (path, traceback.format_exc()))
                self.send_json(500, {"error": "Something went wrong. If you were charged, the orbs still arrive; staff can check."})

    return Handler


def check(service):
    """--check: the settings the service would start with, for the deploy."""
    ok = True
    try:
        service.connect().close()
        print("database: ok (%s@%s:%d/%s)" % (service.s.db["user"], service.s.db["host"], service.s.db["port"], service.s.db["database"]))
    except Exception as e:
        print("database: FAILED (%s)" % e)
        ok = False
    if not service.s.paypal_configured():
        print("paypal: not configured (buying is closed)")
    else:
        try:
            service.paypal.access_token()
            print("paypal: ok (%s)" % ("live" if service.s.live else "sandbox"))
        except Exception as e:
            print("paypal: FAILED (%s)" % e)
            ok = False
    print("public url: %s" % (service.s.public_url or "(not set)"))
    print("receipts: %s" % (("through %s:%d" % (service.s.smtp["host"], service.s.smtp["port"])) if service.s.smtp["host"] else "off (no smtpHost)"))
    return ok


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--server-dir", required=True, help="the game server's folder (config.lua, config.local.lua)")
    parser.add_argument("--settings", default="", help="KEY=VALUE file with the PayPal settings")
    parser.add_argument("--packs", default=os.path.join(HERE, "packs.json"))
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=7200)
    parser.add_argument("--check", action="store_true", help="check the settings, the database and PayPal, then exit")
    args = parser.parse_args()
    service = Service(Settings(args))
    if args.check:
        sys.exit(0 if check(service) else 1)
    if service.s.paypal_configured():
        try:
            service.paypal.access_token()
            log("PayPal %s keys accepted" % ("live" if service.s.live else "sandbox"))
            service.ensure_webhook()
        except Exception as e:
            log("PayPal is not reachable yet: %s" % e)
    else:
        log("PAYPAL_CLIENT_ID and PAYPAL_CLIENT_SECRET are not set: the buy page says buying isn't open")
    server = ThreadingHTTPServer((args.host, args.port), make_handler(service))
    server.daemon_threads = True
    log("Payments listening on %s:%d (%s)" % (args.host, args.port, "live" if service.s.live else "sandbox"))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
