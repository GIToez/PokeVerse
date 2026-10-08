PokeVerse - client comparison package for Windows
=================================================
(PokeVerse-Client-Comparison-Windows)

One folder to compare the two PokeVerse clients against the same server:
  legacy-client\       the original PokeVerse interface (OTClient 0.6.6 engine,
                       compiled from client\source; no original .exe files)
  redemption-client\   the new Redemption client (client-redemption)
  server\              the PokeVerse server both clients connect to
Everything was built by GitHub Actions from the PokeVerse source. The
server only listens on 127.0.0.1.

DEVELOPMENT ONLY. The optional development accounts have public passwords.


What you need
-------------
* Windows 10 or 11, 64-bit, with a normal graphics driver (OpenGL).
* MariaDB Server (tested with 10.11 LTS) from https://mariadb.org/download/,
  default settings (service enabled, port 3306). Remember its root password.


Folder layout
-------------
  Setup Database.bat               create or upgrade the database (run first)
  Start Server.bat                 run the server (one server for both clients)
  Stop Server.bat                  stop the running server (it saves first)
  Start Legacy Client.bat          start the LEGACY client
  Start Redemption Client.bat      start the REDEMPTION client
  Start Both Clients.bat           start both clients (never starts a server)
  Reset Development Database.bat   DELETE the database and build it again (asks first)
  server\  legacy-client\  redemption-client\  database\  scripts\
  VERSION.txt                      the commit and build this package came from

Put the folder anywhere; paths with spaces work.


Steps
-----
1. "Setup Database.bat" once (Enter accepts the defaults; answer Yes to the
   development accounts). It ends with "Database setup: SUCCESS".
2. "Start Server.bat"; wait for "server Online!" in its window.
3. "Start Legacy Client.bat", "Start Redemption Client.bat", or
   "Start Both Clients.bat".
4. Log in:
     player / player   character Trainer
     admin  / admin    character GM Admin (game master)
   A character can only be online once. To play both clients at the same
   time, use player in one and admin in the other; to compare the same
   character, log out of one client before logging in with the other.
5. Stop the server with "Stop Server.bat", Ctrl+C in its window, or
   /shutdown as GM Admin. All of them save first.

Each client keeps its own settings: the legacy client in
%USERPROFILE%\Pokecenter, the Redemption client in %APPDATA%\pokeverse
(Windows user folders). Logs: %USERPROFILE%\Pokecenter.log (legacy),
redemption-client\pokeverse.log (Redemption), server\logs\ (server).

The test checklist and the automated comparison results are in
docs/CLIENT_COMPARISON.md in the PokeVerse repository.
