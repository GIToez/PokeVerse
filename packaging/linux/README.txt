PokeVerse - Linux development package
======================================

This folder runs a complete PokeVerse game on one Linux PC: the server
(server/pokeverse-server), its MariaDB database, and the Redemption client
(client/pokeverse-client). Everything was built by GitHub Actions from the
PokeVerse source; nothing needs to be compiled. The server only listens on
127.0.0.1, so nobody else can connect.

DEVELOPMENT ONLY. The optional development accounts below have public
passwords. Never open the server or the database to a network.


What you need
-------------
* 64-bit x86 Linux with glibc 2.38 or newer: Ubuntu 24.04 or newer,
  Debian 13, Fedora 39 or newer, or a current Arch/openSUSE Tumbleweed.
* A desktop session with OpenGL (any normal graphics driver).
* MariaDB Server, for example:
      sudo apt install mariadb-server        (Debian/Ubuntu)
      sudo dnf install mariadb-server        (Fedora)
      sudo systemctl enable --now mariadb
* About 1 GB of free disk space.

Nothing else: no compiler, CMake, vcpkg or Git. The libraries the server
needs (Boost, Lua, libxml2, OpenSSL, the MariaDB client library, ...) are in
server/lib/. The client only uses the system's OpenGL and X11 libraries.


Folder layout
-------------
  setup-database.sh   create or upgrade the database (run first)
  start-server.sh     run the server in this terminal
  start-client.sh     run the client
  client/             pokeverse-client and the game data
  server/             pokeverse-server, server/lib/, data, map and config.lua
  database/           schema, migrations and the development seed
  VERSION.txt         the commit and build this package came from

Extract the archive with tar (it keeps the executable permissions):
      tar -xzf PokeVerse-Linux-Dev.tar.gz
      cd PokeVerse-Linux-Dev


Step 1 - database (once)
------------------------
      ./setup-database.sh

It uses "sudo mariadb" as the database administrator (you may be asked for
your sudo password), checks that MariaDB answers, creates the database
"pokeverse" if it is missing, imports the schema, applies every migration in
order, creates or updates the database user "pokeverse" (password
"pokeverse-dev"), installs the development accounts, writes
server/config.lua and checks that every table the server needs exists.
It ends with "Database setup: SUCCESS"; any error stops it with "FAILED".

Running it again is safe: an existing database keeps its data. Options:
      ./setup-database.sh --no-dev-accounts   skip player/player and admin/admin
      ./setup-database.sh --reset             DELETE the database and build it again
                                              (asks you to type its name)
Another administrator login: POKEVERSE_DB_ADMIN_USER=root
POKEVERSE_DB_ADMIN_PASSWORD=... ./setup-database.sh  (see the top of the script).


Step 2 - play
-------------
Terminal 1:   ./start-server.sh       wait for "server Online!"
Terminal 2:   ./start-client.sh

The client connects to the local server (127.0.0.1, login port 7564)
without any editing. Log in with:

  account   password   character   role
  player    player     Trainer     normal player
  admin     admin      GM Admin    game master (God)

These two accounts exist only if the development accounts were installed.
They are DEVELOPMENT ONLY.

A new GM Admin has no Pokemon. In game, as GM Admin, say for example:
  /cb Charmander, 15, 10


Step 3 - stop
-------------
Press Ctrl+C in the server terminal, or say /shutdown as GM Admin. Both save
players and the map before the server exits.


Logs
----
  server/logs/            server logs (and the server terminal)
  client/pokeverse.log    client log


Troubleshooting
---------------
"no MariaDB client found" / "cannot connect to MariaDB"
    Install and start MariaDB (see "What you need").
"port 7564 is in use"
    Another PokeVerse server is still running.
"the database in server/config.lua is not ready"
    Run ./setup-database.sh.
"version `GLIBC_2.38' not found"
    The Linux distribution is too old; see "What you need".
"Permission denied" when starting a script
    Extract the archive with tar, or run: chmod +x *.sh server/pokeverse-server client/pokeverse-client
The client window is black or does not open
    Install or update the graphics driver (Mesa or the vendor driver).
