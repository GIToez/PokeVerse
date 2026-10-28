#!/usr/bin/env python3
"""TEST ONLY: a local stand-in for PayPal's REST API, for scripts/payments-test.py.

It answers the calls core/payments/payments.py makes: the OAuth token, creating, capturing and reading
orders, listing and creating webhooks and verifying webhook signatures (a signature verifies when it
is "valid-sig" and the webhook id is the one created here). The test controls it through /test/...:

  POST /test/approve/<order>   the buyer approved the order in PayPal (body: {"email": ..., "capture": "COMPLETED"|"PENDING"|"DECLINED"})
  GET  /test/state             the orders and webhooks, as JSON
"""

import argparse
import base64
import json
import secrets
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

lock = threading.Lock()
orders = {}
webhooks = {}
captures_by_request = {}
tokens = set()


def new_id(prefix, n=17):
    return prefix + secrets.token_hex(n)[:n].upper()


def make_handler(client_id, client_secret):
    class Handler(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def log_message(self, fmt, *args):
            print("fake-paypal: " + fmt % args, flush=True)

        def reply(self, status, data):
            body = json.dumps(data).encode()
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def error(self, status, name, issue):
            self.reply(status, {"name": name, "details": [{"issue": issue}]})

        def body(self):
            n = int(self.headers.get("Content-Length") or 0)
            raw = self.rfile.read(n) if n else b""
            return json.loads(raw) if raw and raw[:1] in b"{[" else raw.decode()

        def authorized(self):
            auth = self.headers.get("Authorization", "")
            return auth.startswith("Bearer ") and auth[7:] in tokens

        def do_GET(self):
            path = self.path.split("?")[0]
            if path == "/test/state":
                with lock:
                    self.reply(200, {"orders": orders, "webhooks": webhooks})
                return
            if not self.authorized():
                return self.error(401, "AUTHENTICATION_FAILURE", "INVALID_TOKEN")
            if path == "/v1/notifications/webhooks":
                with lock:
                    self.reply(200, {"webhooks": list(webhooks.values())})
            elif path.startswith("/v2/checkout/orders/"):
                with lock:
                    order = orders.get(path.rsplit("/", 1)[-1])
                    self.reply(200, order) if order else self.error(404, "RESOURCE_NOT_FOUND", "INVALID_RESOURCE_ID")
            else:
                self.error(404, "NOT_FOUND", "NOT_FOUND")

        def do_PATCH(self):
            if not self.authorized():
                return self.error(401, "AUTHENTICATION_FAILURE", "INVALID_TOKEN")
            hook_id = self.path.rsplit("/", 1)[-1]
            ops = self.body()
            with lock:
                hook = webhooks.get(hook_id)
                if not hook:
                    return self.error(404, "RESOURCE_NOT_FOUND", "INVALID_RESOURCE_ID")
                for op in ops:
                    if op.get("path") == "/event_types":
                        hook["event_types"] = op["value"]
                self.reply(200, hook)

        def do_POST(self):
            path = self.path.split("?")[0]
            data = self.body()
            if path == "/v1/oauth2/token":
                expected = "Basic " + base64.b64encode(("%s:%s" % (client_id, client_secret)).encode()).decode()
                if self.headers.get("Authorization") != expected or data != "grant_type=client_credentials":
                    return self.reply(401, {"error": "invalid_client"})
                token = "A21" + secrets.token_hex(16)
                with lock:
                    tokens.add(token)
                return self.reply(200, {"access_token": token, "token_type": "Bearer", "expires_in": 32400})
            if path.startswith("/test/approve/"):
                with lock:
                    order = orders.get(path.rsplit("/", 1)[-1])
                    if not order:
                        return self.error(404, "RESOURCE_NOT_FOUND", "INVALID_RESOURCE_ID")
                    order["status"] = "APPROVED"
                    order["payer"] = {"email_address": data.get("email", "buyer@pokeverse.test"), "payer_id": new_id("P", 13)}
                    order["_capture"] = data.get("capture", "COMPLETED")
                    return self.reply(200, order)
            if not self.authorized():
                return self.error(401, "AUTHENTICATION_FAILURE", "INVALID_TOKEN")
            if path == "/v2/checkout/orders":
                unit = data["purchase_units"][0]
                amount = unit["amount"]
                if unit["items"][0]["unit_amount"]["value"] != amount["value"] or unit["items"][0].get("category") != "DIGITAL_GOODS":
                    return self.error(422, "UNPROCESSABLE_ENTITY", "ITEM_TOTAL_MISMATCH")
                order = {"id": new_id(""), "status": "CREATED", "intent": data["intent"],
                         "purchase_units": [{"reference_id": unit["reference_id"], "custom_id": unit["custom_id"], "amount": amount}]}
                with lock:
                    orders[order["id"]] = order
                return self.reply(201, order)
            if path.startswith("/v2/checkout/orders/") and path.endswith("/capture"):
                oid = path.split("/")[-2]
                request_id = self.headers.get("PayPal-Request-Id", "")
                with lock:
                    if request_id and request_id in captures_by_request:
                        return self.reply(201, orders[captures_by_request[request_id]])
                    order = orders.get(oid)
                    if not order:
                        return self.error(404, "RESOURCE_NOT_FOUND", "INVALID_RESOURCE_ID")
                    if order["status"] == "COMPLETED":
                        return self.error(422, "UNPROCESSABLE_ENTITY", "ORDER_ALREADY_CAPTURED")
                    if order["status"] != "APPROVED":
                        return self.error(422, "UNPROCESSABLE_ENTITY", "ORDER_NOT_APPROVED")
                    if order["_capture"] == "DECLINED":
                        return self.error(422, "UNPROCESSABLE_ENTITY", "INSTRUMENT_DECLINED")
                    unit = order["purchase_units"][0]
                    capture = {"id": new_id("C", 16), "status": order["_capture"], "amount": unit["amount"], "custom_id": unit["custom_id"]}
                    unit["payments"] = {"captures": [capture]}
                    order["status"] = "COMPLETED"
                    if request_id:
                        captures_by_request[request_id] = oid
                    return self.reply(201, order)
            if path == "/v1/notifications/webhooks":
                with lock:
                    if any(h["url"] == data["url"] for h in webhooks.values()):
                        return self.error(400, "WEBHOOK_URL_ALREADY_EXISTS", "WEBHOOK_URL_ALREADY_EXISTS")
                    hook = {"id": new_id("WH-", 17), "url": data["url"], "event_types": data["event_types"]}
                    webhooks[hook["id"]] = hook
                return self.reply(201, hook)
            if path == "/v1/notifications/verify-webhook-signature":
                with lock:
                    known = data.get("webhook_id") in webhooks
                ok = known and data.get("transmission_sig") == "valid-sig" and isinstance(data.get("webhook_event"), dict) \
                    and all(data.get(k) for k in ("auth_algo", "cert_url", "transmission_id", "transmission_time"))
                return self.reply(200, {"verification_status": "SUCCESS" if ok else "FAILURE"})
            self.error(404, "NOT_FOUND", "NOT_FOUND")

    return Handler


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--client-id", required=True)
    parser.add_argument("--client-secret", required=True)
    args = parser.parse_args()
    server = ThreadingHTTPServer(("127.0.0.1", args.port), make_handler(args.client_id, args.client_secret))
    print("fake-paypal: listening on 127.0.0.1:%d" % args.port, flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
