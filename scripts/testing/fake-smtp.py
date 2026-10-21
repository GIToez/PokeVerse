#!/usr/bin/env python3
"""A small SMTP server for tests: STARTTLS, AUTH PLAIN, and every accepted email saved as
a JSON file ({"from", "to", "subject", "body"}) in --mailbox.

Usage:
  fake-smtp.py --port 2525 --mailbox DIR [--cert cert.pem --key key.pem] [--user U --password P]

With --cert the server only accepts AUTH and MAIL after STARTTLS, like Gmail. Standard
library only.
"""
import argparse
import base64
import email
import email.policy
import json
import os
import socketserver
import ssl
import threading
import time

counter_lock = threading.Lock()
counter = [0]


class Handler(socketserver.StreamRequestHandler):
    def setup(self):
        super().setup()
        self.tls = False
        self.authed = False

    def send(self, line):
        self.wfile.write((line + "\r\n").encode())
        self.wfile.flush()

    def readline(self):
        line = self.rfile.readline(4096)
        if not line:
            raise ConnectionError("closed")
        return line.decode("utf-8", "replace").rstrip("\r\n")

    def start_tls(self):
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(self.server.args.cert, self.server.args.key)
        self.connection = context.wrap_socket(self.connection, server_side=True)
        self.rfile = self.connection.makefile("rb")
        self.wfile = self.connection.makefile("wb")
        self.tls = True

    def handle(self):
        args = self.server.args
        sender, recipients = None, []
        self.send("220 fake-smtp ready")
        try:
            while True:
                line = self.readline()
                verb = line.split(" ", 1)[0].upper()
                rest = line[len(verb):].strip()
                need_tls = args.cert and not self.tls
                if verb in ("EHLO", "HELO"):
                    extensions = ["fake-smtp"]
                    if need_tls:
                        extensions.append("STARTTLS")
                    else:
                        extensions.append("AUTH PLAIN")
                    for i, ext in enumerate(extensions):
                        self.send("250%s%s" % (" " if i == len(extensions) - 1 else "-", ext))
                elif verb == "STARTTLS" and need_tls:
                    self.send("220 go ahead")
                    self.start_tls()
                elif verb == "AUTH":
                    parts = rest.split(" ", 1)
                    if need_tls or parts[0].upper() != "PLAIN" or len(parts) < 2:
                        self.send("530 must issue STARTTLS first" if need_tls else "504 only PLAIN")
                        continue
                    _, user, password = base64.b64decode(parts[1]).decode().split("\0")
                    if user == args.user and password == args.password:
                        self.authed = True
                        self.send("235 authenticated")
                    else:
                        self.send("535 bad credentials")
                elif verb == "MAIL":
                    if need_tls or (args.user and not self.authed):
                        self.send("530 authentication required")
                        continue
                    sender, recipients = rest.split(":", 1)[1].strip().strip("<>"), []
                    self.send("250 ok")
                elif verb == "RCPT":
                    recipients.append(rest.split(":", 1)[1].strip().strip("<>"))
                    self.send("250 ok")
                elif verb == "DATA":
                    if not sender or not recipients:
                        self.send("503 need MAIL and RCPT")
                        continue
                    self.send("354 end with <CRLF>.<CRLF>")
                    lines = []
                    while True:
                        data = self.readline()
                        if data == ".":
                            break
                        lines.append(data[1:] if data.startswith(".") else data)
                    self.save(sender, recipients, "\r\n".join(lines) + "\r\n")
                    sender, recipients = None, []
                    self.send("250 queued")
                elif verb == "RSET":
                    sender, recipients = None, []
                    self.send("250 ok")
                elif verb == "NOOP":
                    self.send("250 ok")
                elif verb == "QUIT":
                    self.send("221 bye")
                    return
                else:
                    self.send("502 not implemented")
        except (ConnectionError, ssl.SSLError, OSError):
            return

    def save(self, sender, recipients, raw):
        message = email.message_from_string(raw, policy=email.policy.default)
        with counter_lock:
            counter[0] += 1
            number = counter[0]
        record = {"from": sender, "to": recipients, "subject": str(message["subject"]),
                  "header_from": str(message["from"]), "body": message.get_content(), "time": time.time()}
        path = os.path.join(self.server.args.mailbox, "%013d-%04d.json" % (int(time.time() * 1000), number))
        with open(path + ".partial", "w") as f:
            json.dump(record, f)
        os.replace(path + ".partial", path)
        print("fake-smtp: %s -> %s: %s" % (sender, ", ".join(recipients), record["subject"]), flush=True)


class Server(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=2525)
    ap.add_argument("--mailbox", required=True)
    ap.add_argument("--cert")
    ap.add_argument("--key")
    ap.add_argument("--user", default="")
    ap.add_argument("--password", default="")
    args = ap.parse_args()
    os.makedirs(args.mailbox, exist_ok=True)
    server = Server((args.host, args.port), Handler)
    server.args = args
    print("fake-smtp listening on %s:%d%s" % (args.host, args.port, " (STARTTLS)" if args.cert else ""), flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
