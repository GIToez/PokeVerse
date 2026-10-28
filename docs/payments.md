# Buying Verse Orbs (PayPal)

Players buy Verse Orbs (the player-facing name of Soul Coins, `accounts.soulcoins`) with PayPal
Checkout. It is phase 4 of [Accounts, Soul Coins and the Store](upcoming-features.md#19-accounts-soul-coins-and-the-store).

## How a purchase works

1. **Buy Verse Orbs** in the Store (top right, next to Bank). The button only shows while the
   server has `paymentsUrl` set. The account needs a verified email.
2. The game server makes a one-time link for the account (32 random hex characters in
   `payment_links`, valid 30 minutes, at most 10 open per account) and the client opens it
   in the browser: `https://account.pokeverse.quest/buy?t=...`. No website login.
3. The page shows the character, the balance, the packs and PayPal's buttons (PayPal, Pay
   Later and cards, whatever PayPal offers the buyer).
4. The page asks the payment service to create the PayPal order. The price comes from the
   server's pack list, never from the browser. The order carries the account in
   `custom_id` (`pv-account-N`) and is a digital good with no shipping.
5. When the buyer approves, the service captures the payment. Once PayPal says it's
   completed and the amount and currency match the pack, in one database transaction:
   the order becomes `completed`, the orbs go onto the balance, a line goes into the
   purchase history (`store_history`) and a message is left for the game
   (`payment_notices`). A receipt goes to the account's email.
6. The game server checks `payment_notices` every 5 seconds and tells the account's online
   character ("You bought 40 Verse Orbs...", in the activity feed too) and refreshes an open
   Store. If nobody on the account is online, the message waits until one of its characters
   logs in. Staff messages are printed to the server log straight away.

**Every payment is credited once.** The order row is the lock: only a `created` or
`pending` order can become `completed`, so the browser's capture, a second click and
PayPal's webhooks can arrive in any order and any number of times.

**Webhooks** (`/paypal/webhook`) are checked with PayPal's verify-webhook-signature API and
recorded by event id (`payment_events`), so a repeated event does nothing. The service finds
or creates its webhook at start (logged as `PayPal webhook WH-... found/created`). Events:

| Event | What happens |
| --- | --- |
| `CHECKOUT.ORDER.APPROVED` | Captures the order (a buyer who closed the page before it finished still gets the orbs). |
| `PAYMENT.CAPTURE.COMPLETED` | Credits the order (eCheck and other payments that were `PENDING` at capture). |
| `PAYMENT.CAPTURE.PENDING` | Marks the order pending; the player is told the orbs come when PayPal finishes. |
| `PAYMENT.CAPTURE.DENIED` | Marks the order failed. Nothing was credited. |
| `PAYMENT.CAPTURE.REFUNDED` | Takes back the refunded share of the orbs (a half refund takes back half). |
| `PAYMENT.CAPTURE.REVERSED` | Chargeback: takes back all the orbs not already taken back. |
| `CUSTOMER.DISPUTE.CREATED` | Only tells staff; the orbs go when PayPal reverses or refunds the payment. |

## Refunds, chargebacks and the 7-day hold

- **Taking orbs back can push the balance below zero** (if they were already spent). Below
  zero the Store refuses every purchase and Withdraw is closed until the balance is above
  zero again. The player is told in game; staff are told in the server log and in game
  (every staff character online).
- **Bought orbs can't be withdrawn for 7 days** (`Payments.HOLD_DAYS`), when most reversals
  happen. They can be spent in the Store at once. Withdraw allows `balance - held`, where
  held is the orbs bought in the last 7 days minus any already taken back. The Store
  shows how many are held.
- Reversing a payment on purpose should be a ban under the Terms (still to be written, with
  the refund policy).

## Packs

`core/payments/packs.json` (USD). Changing it needs only a deployment, no client update.

| Pack | Price | Per orb | Badge |
| --- | --- | --- | --- |
| 15 | $7.50 | $0.50 | |
| 40 | $18.00 | $0.45 | 10% off |
| 85 | $36.00 | $0.42 | 15% off |
| 160 | $64.00 | $0.40 | 20% off |

## Security

- The service listens on 127.0.0.1:7200 only. Caddy serves it over HTTPS and gets and
  renews the certificate itself.
- Links are single-account, expire in 30 minutes and are never written to a log (request
  logging is off; the Linux test checks the logs for the token).
- The page sends a Content-Security-Policy that only allows PayPal's scripts and frames,
  `Referrer-Policy: no-referrer` and `Cache-Control: no-store`.
- 60 requests a minute per IP and 20 orders an hour per account.
- The PayPal secret reaches the server through stdin (`pokeverse-ctl set-payments`) and lives
  in `/opt/pokeverse/shared/payments.env` (mode 600). It is never on a command line.

## Live server

The pieces: `pokeverse-payments.service` (runs `payments/payments.py` from the active
release as the `pokeverse` user), Caddy (installed by `bootstrap-ovh.sh` version 2) and the
GitHub settings below. Deployments restart the service with each release and roll it back
with the game server.

1. **DNS:** an A record `account.pokeverse.quest` pointing at the server (done at Spaceship:
   `40.160.145.24`).
2. **Run `bootstrap-ovh.sh` again** (version 2), as in [live-server.md](live-server.md#2-prepare-the-server-one-command).
   It installs Caddy and `python3-pymysql`, the payment service and its sudo rules, and
   opens 80 and 443 if ufw is on. It keeps everything else. Until then deployments leave
   buying off and `verify` says why.
3. **Firewall:** if OVH's network firewall is on, allow TCP 80 and 443 (Caddy needs 80 for
   the certificate).
4. **GitHub settings** (Settings > Secrets and variables > Actions):

   | Kind | Name | Value |
   | --- | --- | --- |
   | Secret | `PAYPAL_CLIENT_ID` | the PayPal app's Client ID (Developer Dashboard > Apps & Credentials) |
   | Secret | `PAYPAL_CLIENT_SECRET` | that app's Secret |
   | Variable | `PAYPAL_ENV` | `sandbox` (default) or `live`; the keys must match (Sandbox and Live apps have different keys) |
   | Variable | `PAYPAL_WEBHOOK_ID` | optional; normally the service creates the webhook itself |
   | Variable | `PAYMENTS_HOST` | optional, default `account.pokeverse.quest` |

5. **Deploy.** The run summary shows "Buying Verse Orbs: PayPal sandbox at https://...", and
   the deploy checks `https://account.pokeverse.quest/healthz` from outside (a warning, not
   a failure, while DNS or the certificate isn't ready).
6. **Test with sandbox accounts** (Developer Dashboard > Sandbox accounts: a personal
   account pays). Then switch: put the **Live** app's keys into the two secrets, set
   `PAYPAL_ENV` to `live` and deploy. Make one small real purchase and refund it from
   PayPal to check the take-back.

`status` shows the service; `logs` shows its last lines; on the server
`pokeverse-ctl payments-logs`, or a check of the settings, database and PayPal keys:

    sudo -u pokeverse python3 /opt/pokeverse/current/payments/payments.py --server-dir /opt/pokeverse/current --settings /opt/pokeverse/shared/payments.env --check

## Local test

`scripts/test-server-linux.sh` runs the whole flow against a fake PayPal
(`scripts/testing/fake-paypal.py`) and a fake mail server: `scripts/payments-test.py` covers
the verified email, the link, the page and its headers, capture, double captures and
repeated webhooks, bad signatures, pending payments, a wrong amount, a declined card,
the 7-day hold, partial refunds, chargebacks below zero, the in-game messages, an expired
link and the receipts. The `/paytest` talkaction (`scripts/testing/payments-test-talkaction.lua`)
is only copied in by the test.

Locally, with a sandbox app:

    PAYPAL_CLIENT_ID=... PAYPAL_CLIENT_SECRET=... PAYMENTS_PUBLIC_URL=http://127.0.0.1:7200 \
      python3 core/payments/payments.py --server-dir core/server

and `paymentsUrl = "http://127.0.0.1:7200"` in `core/server/config.local.lua`. PayPal can't
reach a local webhook, so only the browser's capture credits orders there.

## Files

| File | |
| --- | --- |
| `core/payments/payments.py` | the service (Python 3, standard library and PyMySQL) |
| `core/payments/buy.html`, `message.html`, `static/` | the buy page |
| `core/payments/packs.json` | packs and prices |
| `core/server/data/lib/ps/systems/101-payments.lua` | links, the hold, in-game messages |
| `core/server/data/lib/ps/systems/084-store.lua` | Buy Verse Orbs, Withdraw with the hold, purchases below zero |
| `core/server/data/lib/ps/events/globalevents/payments.lua` | delivers the messages every 5 seconds |
| `core/server/schemas/pokeverse-extensions.sql` | `payment_links`, `payment_orders`, `payment_events`, `payment_notices` |
| `scripts/live/systemd/pokeverse-payments.service` | the systemd unit |
