PokeVerse - Linux server package (PokeVerse-Server-Linux)
=========================================================

The PokeVerse game server (server/pokeverse-server), built by GitHub Actions
from the PokeVerse source, with everything it needs to create its MariaDB
database. Both PokeVerse clients connect to this one server:
  PokeVerse-Legacy-Linux.tar.gz      the original PokeVerse interface
  PokeVerse-Redemption-Linux.tar.gz  the new Redemption client
The server only listens on 127.0.0.1.

DEVELOPMENT ONLY. The optional development accounts have public passwords.
Never open the server or the database to a network.


What you need
-------------
* 64-bit x86 Linux with glibc 2.38 or newer (Ubuntu 24.04+, Debian 13,
  Fedora 39+, current Arch or openSUSE Tumbleweed).
* MariaDB Server, for example:
      sudo apt install mariadb-server && sudo systemctl enable --now mariadb
The libraries the server needs are in server/lib/.


Folder layout
-------------
  setup-database.sh   create or upgrade the database (run first)
  start-server.sh     run the server in this terminal (Ctrl+C saves and stops)
  stop-server.sh      stop the server started from this folder (it saves first)
  server/  database/  VERSION.txt

Extract with tar, which keeps the executable permissions:
      tar -xzf PokeVerse-Server-Linux.tar.gz && cd PokeVerse-Server-Linux


First run
---------
1. ./setup-database.sh
   Uses "sudo mariadb" as the administrator, creates the database
   "pokeverse", applies every migration, creates the database user, installs
   the development accounts player/player (Trainer) and admin/admin (GM
   Admin) and writes server/config.lua. It ends with "Database setup:
   SUCCESS". Running it again is safe. Options: --no-dev-accounts, and
   --reset (DELETES the database, asks you to type its name first).
2. ./start-server.sh and wait for "server Online!".
3. Start a client: ./start-legacy-client.sh or ./start-redemption-client.sh
   from the client packages. Both connect to 127.0.0.1:7564 unchanged.
4. Stop with Ctrl+C in the server terminal, ./stop-server.sh, or /shutdown
   as GM Admin. All of them save first.
