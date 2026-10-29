#!/usr/bin/env bash
# One-time setup of the PokeVerse live server (Ubuntu 24.04, e.g. OVHcloud). Run as root:
#
#   sudo bash bootstrap-ovh.sh "ssh-ed25519 AAAA... pokeverse-deploy"
#
# The argument is the PUBLIC deploy key whose private half is stored in the GitHub secret
# OVH_SSH_PRIVATE_KEY. Safe to run again (for example after an update of this script): it
# never replaces the database, passwords, secrets, backups or game data.
#
# What it does:
#   - installs MariaDB (listening on 127.0.0.1 only) and the game server's runtime libraries
#   - creates the "pokeverse" system user that owns /opt/pokeverse and runs the services;
#     GitHub Actions logs in as this user with the deploy key (no password, no shell tricks)
#   - creates the production database and its user with a random password
#   - writes /opt/pokeverse/shared/config.local.lua (database password, Discord bridge secret)
#   - installs the systemd services (game server, Discord bot, payment service, daily backup) and allows
#     the pokeverse user to start/stop/restart only these services
#   - installs Caddy, which serves the payment service over HTTPS as $PAYMENTS_HOST (default
#     account.pokeverse.quest, an A record pointing at this server) with a free certificate it renews
#     itself; PAYMENTS_HOST=none leaves Caddy out
#   - opens the game ports 7564 and 8548, and 80 and 443 for Caddy, if the ufw firewall is active
set -euo pipefail

BOOTSTRAP_VERSION=2
PV_USER=pokeverse
PV_HOME=/opt/pokeverse
DB_NAME=pokeverse
GAME_PORTS="7564 8548"
PAYMENTS_HOST=${PAYMENTS_HOST:-account.pokeverse.quest}
[[ "$PAYMENTS_HOST" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]] || { echo "ERROR: invalid PAYMENTS_HOST: $PAYMENTS_HOST" >&2; exit 1; }

die() { echo "ERROR: $*" >&2; exit 1; }
step() { echo; echo "==> $*"; }

[ "$(id -u)" = 0 ] || die "run as root: sudo bash $0 \"<public deploy key>\""
. /etc/os-release
[ "${ID:-}" = ubuntu ] || die "this script supports Ubuntu (found ${ID:-unknown})"
[ "${VERSION_ID:-}" = 24.04 ] || echo "WARNING: tested on Ubuntu 24.04, this is ${VERSION_ID:-unknown}; the game server is built for 24.04."

deploy_key=${1:-}
existing_keys="$PV_HOME/.ssh/authorized_keys"
if [ -z "$deploy_key" ] && [ ! -s "$existing_keys" ]; then
  die "pass the public deploy key, e.g.: sudo bash $0 \"\$(cat pokeverse-deploy.pub)\""
fi
if [ -n "$deploy_key" ]; then
  echo "$deploy_key" | grep -Eq '^(ssh-ed25519|ecdsa-sha2-nistp[0-9]+|ssh-rsa) [A-Za-z0-9+/=]+( .*)?$' \
    || die "that does not look like a public SSH key (it must start with ssh-ed25519 ...). Never paste the private key here."
fi

here=$(cd "$(dirname "$0")" && pwd)
units_dir="$here/systemd"
if [ ! -f "$units_dir/pokeverse-server.service" ]; then
  # Running from a single downloaded file: fetch the service files from the same commit.
  ref=${POKEVERSE_REF:-main}
  units_dir=$(mktemp -d)
  for f in pokeverse-server.service pokeverse-discord.service pokeverse-payments.service pokeverse-backup.service pokeverse-backup.timer; do
    curl -fsSL "https://raw.githubusercontent.com/GIToez/PokeVerse/$ref/scripts/live/systemd/$f" -o "$units_dir/$f" \
      || die "could not download $f"
  done
fi

step "Installing packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y -q --no-install-recommends \
  mariadb-server mariadb-client python3 python3-pymysql rsync gzip openssl ca-certificates curl \
  libboost-filesystem1.83.0 libboost-thread1.83.0 libgmp10 libicu74 liblua5.1-0 libmariadb3 \
  libsqlite3-0 libssl3t64 libxml2 zlib1g
systemctl enable --now mariadb

step "Checking that MariaDB only listens on this machine"
bind=$(my_print_defaults --mysqld 2>/dev/null | sed -n 's/^--bind-address=//p' | tail -1)
case "${bind:-}" in
  127.0.0.1|localhost|::1) echo "MariaDB bind-address: $bind" ;;
  *)
    cat > /etc/mysql/mariadb.conf.d/90-pokeverse.cnf <<'CNF'
# PokeVerse: the database is only used by the game server on this machine.
[mysqld]
bind-address = 127.0.0.1
CNF
    systemctl restart mariadb
    echo "MariaDB bind-address set to 127.0.0.1"
    ;;
esac

step "Creating the $PV_USER user and folders"
if ! id "$PV_USER" >/dev/null 2>&1; then
  useradd --system --home-dir "$PV_HOME" --create-home --shell /bin/bash --user-group "$PV_USER"
fi
# "*" = no password login possible; unlike a locked account ("!") it still allows SSH keys.
usermod -p '*' "$PV_USER"
install -d -m 750 -o "$PV_USER" -g "$PV_USER" "$PV_HOME"
install -d -m 750 -o "$PV_USER" -g "$PV_USER" "$PV_HOME/releases" "$PV_HOME/shared" "$PV_HOME/shared/logs" \
  "$PV_HOME/discord" "$PV_HOME/discord/releases" "$PV_HOME/discord/shared" "$PV_HOME/discord/shared/data" \
  "$PV_HOME/discord/shared/logs"
install -d -m 700 -o "$PV_USER" -g "$PV_USER" "$PV_HOME/backups" "$PV_HOME/.ssh"
for d in server chat bots; do install -d -m 750 -o "$PV_USER" -g "$PV_USER" "$PV_HOME/shared/logs/$d"; done

if [ -n "$deploy_key" ]; then
  # "restrict" disables port forwarding, agent forwarding and terminals for this key.
  line="restrict $deploy_key"
  touch "$existing_keys"
  grep -qxF "$line" "$existing_keys" || echo "$line" >> "$existing_keys"
  chown "$PV_USER:$PV_USER" "$existing_keys"
  chmod 600 "$existing_keys"
fi

step "Creating the production database"
secrets="$PV_HOME/shared/config.local.lua"
if [ -f "$secrets" ]; then
  db_pass=$(sed -n 's/^sqlPass = "\([^"]*\)".*/\1/p' "$secrets" | head -1)
  [ -n "$db_pass" ] || die "$secrets exists but has no sqlPass line; fix it by hand or move it away"
  echo "Keeping the existing database password and secrets in $secrets"
else
  db_pass=$(openssl rand -hex 24)
fi
mariadb <<SQL
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET latin1 COLLATE latin1_swedish_ci;
CREATE USER IF NOT EXISTS '$PV_USER'@'localhost' IDENTIFIED BY '$db_pass';
CREATE USER IF NOT EXISTS '$PV_USER'@'127.0.0.1' IDENTIFIED BY '$db_pass';
ALTER USER '$PV_USER'@'localhost' IDENTIFIED BY '$db_pass';
ALTER USER '$PV_USER'@'127.0.0.1' IDENTIFIED BY '$db_pass';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$PV_USER'@'localhost', '$PV_USER'@'127.0.0.1';
-- Scratch database used only to test-restore backups.
GRANT ALL PRIVILEGES ON \`${DB_NAME}_restore_check\`.* TO '$PV_USER'@'localhost', '$PV_USER'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

if [ ! -f "$secrets" ]; then
  bridge_secret=$(openssl rand -hex 32)
  umask 077
  cat > "$secrets" <<LUA
-- PokeVerse live server settings, loaded after config.lua. Created by bootstrap-ovh.sh.
-- This file lives only on the server and is never committed or packaged.

-- BEGIN DEPLOYMENT SETTINGS (rewritten by every deployment from the GitHub variables)
-- END DEPLOYMENT SETTINGS

-- Production database (MariaDB on this machine) and Discord bridge secret.
sqlHost = "127.0.0.1"
sqlPort = 3306
sqlUser = "$PV_USER"
sqlPass = "$db_pass"
sqlDatabase = "$DB_NAME"
discordBridgeEnabled = true
discordBridgeSecret = "$bridge_secret"

-- Your own overrides go below this line; later lines win.
LUA
  umask 022
fi
chown "$PV_USER:$PV_USER" "$secrets"
chmod 600 "$secrets"

umask 077
cat > "$PV_HOME/.my.cnf" <<CNF
[client]
host=127.0.0.1
port=3306
user=$PV_USER
password=$db_pass
CNF
umask 022
chown "$PV_USER:$PV_USER" "$PV_HOME/.my.cnf"
chmod 600 "$PV_HOME/.my.cnf"
mariadb --defaults-file="$PV_HOME/.my.cnf" "$DB_NAME" -e "SELECT 1" >/dev/null || die "the $PV_USER database login does not work"

step "Installing the systemd services"
for f in pokeverse-server.service pokeverse-discord.service pokeverse-payments.service pokeverse-backup.service pokeverse-backup.timer; do
  install -m 644 "$units_dir/$f" "/etc/systemd/system/$f"
done
systemctl daemon-reload
systemctl enable pokeverse-server.service >/dev/null
systemctl enable --now pokeverse-backup.timer >/dev/null

cat > /etc/sudoers.d/pokeverse <<'SUDO'
# The pokeverse user (GitHub Actions deployments) may only control the PokeVerse services.
Cmnd_Alias PV_CONTROL = \
  /usr/bin/systemctl start pokeverse-server.service, \
  /usr/bin/systemctl stop pokeverse-server.service, \
  /usr/bin/systemctl restart pokeverse-server.service, \
  /usr/bin/systemctl start pokeverse-discord.service, \
  /usr/bin/systemctl stop pokeverse-discord.service, \
  /usr/bin/systemctl restart pokeverse-discord.service, \
  /usr/bin/systemctl enable pokeverse-discord.service, \
  /usr/bin/systemctl disable pokeverse-discord.service, \
  /usr/bin/systemctl start pokeverse-payments.service, \
  /usr/bin/systemctl stop pokeverse-payments.service, \
  /usr/bin/systemctl restart pokeverse-payments.service, \
  /usr/bin/systemctl enable pokeverse-payments.service, \
  /usr/bin/systemctl disable pokeverse-payments.service, \
  /usr/bin/journalctl -u pokeverse-server.service -n 300 --no-pager, \
  /usr/bin/journalctl -u pokeverse-discord.service -n 300 --no-pager, \
  /usr/bin/journalctl -u pokeverse-payments.service -n 200 --no-pager
pokeverse ALL=(root) NOPASSWD: PV_CONTROL
SUDO
chmod 440 /etc/sudoers.d/pokeverse
visudo -cf /etc/sudoers.d/pokeverse >/dev/null || { rm -f /etc/sudoers.d/pokeverse; die "sudoers rule rejected"; }

cat > /etc/logrotate.d/pokeverse <<'ROTATE'
/opt/pokeverse/shared/logs/*.log /opt/pokeverse/shared/logs/*/*.log /opt/pokeverse/discord/shared/logs/*.log {
  weekly
  rotate 8
  compress
  missingok
  notifempty
  copytruncate
  su pokeverse pokeverse
}
ROTATE

step "HTTPS for the payment service (Caddy)"
if [ "$PAYMENTS_HOST" = none ]; then
  echo "PAYMENTS_HOST=none: skipping Caddy; buying Verse Orbs needs HTTPS in front of 127.0.0.1:7200"
else
  apt-get install -y -q --no-install-recommends caddy
  caddyfile=/etc/caddy/Caddyfile
  # Only a Caddyfile this script wrote, or Ubuntu's untouched example, is replaced.
  if [ ! -f "$caddyfile" ] || grep -q "^# PokeVerse (bootstrap-ovh.sh)" "$caddyfile" || grep -q "^:80 {" "$caddyfile"; then
    cat > "$caddyfile" <<CADDY
# PokeVerse (bootstrap-ovh.sh): the payment service over HTTPS. Caddy gets and renews the certificate
# for $PAYMENTS_HOST itself; that name's A record must point at this server.
$PAYMENTS_HOST {
	encode gzip
	header -Server
	reverse_proxy 127.0.0.1:7200
}
CADDY
    caddy validate --config "$caddyfile" --adapter caddyfile >/dev/null 2>&1 || die "the Caddyfile was rejected"
    systemctl enable caddy >/dev/null
    systemctl reload-or-restart caddy
    echo "Caddy serves https://$PAYMENTS_HOST (the certificate comes once the DNS record points here)"
  else
    echo "WARNING: $caddyfile was changed by hand; add this site yourself:"
    echo "  $PAYMENTS_HOST { reverse_proxy 127.0.0.1:7200 }"
  fi
fi

echo "$BOOTSTRAP_VERSION" > "$PV_HOME/shared/bootstrap-version"
chown "$PV_USER:$PV_USER" "$PV_HOME/shared/bootstrap-version"

step "Firewall"
open_ports=$GAME_PORTS
[ "$PAYMENTS_HOST" = none ] || open_ports="$open_ports 80 443"
if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then
  for p in $open_ports; do ufw allow "$p/tcp" >/dev/null; done
  echo "ufw is active: opened $open_ports (TCP). The database (3306), the Discord bridge (7199) and the payment service (7200) stay closed."
else
  echo "ufw is not active. If OVH's network firewall is enabled, allow TCP $open_ports there."
fi

step "Checking SSH access for $PV_USER"
# Read once: under pipefail, `sshd -T | awk '... exit'` dies of SIGPIPE, and sshd -T itself fails
# when socket-activated ssh hasn't made /run/sshd yet. Either used to end the script silently here.
mkdir -p /run/sshd
sshd_settings=$(sshd -T 2>/dev/null || true)
if [ -z "$sshd_settings" ]; then
  echo "WARNING: could not read sshd's settings (sshd -T); check SSH logins for '$PV_USER' by hand."
fi
if grep -Eqi '^(allowusers|allowgroups) ' <<<"$sshd_settings"; then
  echo "WARNING: sshd has AllowUsers/AllowGroups set. Add '$PV_USER' there or GitHub Actions cannot log in:"
  grep -Ei '^(allowusers|allowgroups) ' <<<"$sshd_settings"
fi
if grep -qi '^pubkeyauthentication no' <<<"$sshd_settings"; then
  echo "WARNING: PubkeyAuthentication is disabled in sshd; GitHub Actions needs it."
fi
ssh_port=$(awk '/^port / {print $2; exit}' <<<"$sshd_settings")

host_key=/etc/ssh/ssh_host_ed25519_key.pub
[ -f "$host_key" ] || die "$host_key is missing"
cat <<DONE

============================================================================
 PokeVerse server setup complete.

 Add this to GitHub: Settings > Secrets and variables > Actions > Secrets
 Name:  OVH_SSH_HOST_KEY
 Value: $(cut -d' ' -f1,2 "$host_key")

 SSH port of this server: ${ssh_port:-22}  (set the variable OVH_SSH_PORT if it is not 22)
 Then run the "Live server" workflow with action "verify".
============================================================================
DONE
