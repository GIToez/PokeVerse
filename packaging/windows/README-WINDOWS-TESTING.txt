PokeVerse - Windows local test package
======================================

This folder runs a complete PokeVerse game on one Windows PC: the server
(PokeVerseServer.exe), its MariaDB database, and the Redemption client
(PokeVerse.exe). The server only listens on 127.0.0.1, so nobody else can
connect to it.

FOR LOCAL TESTING ONLY. The optional development accounts below have public
passwords. Never open the server or the database to a network.


What you need
-------------
* Windows 10 or 11, 64-bit.
* A graphics driver with OpenGL (any normal GPU driver).
* MariaDB Server. Tested with MariaDB 10.11 (LTS); newer LTS versions should work.
  Download the MSI from https://mariadb.org/download/ and keep the defaults:
  service enabled, port 3306. Write down the root password you choose.
* About 1 GB of free disk space.

Nothing else: no Visual C++ redistributable, no Python, no Git.


Folder layout
-------------
  Setup-PokeVerse-Database.bat   create or upgrade the database (run first)
  Reset-PokeVerse-Database.bat   DELETE the database and build it again
  Start-PokeVerse-Server.bat     run the server in a console window
  Start-PokeVerse-Client.bat     run the client
  Start-PokeVerse-Test.bat       check the database, start the server, wait, start the client
  client\                        PokeVerse.exe and the game data
  server\                        PokeVerseServer.exe, its DLLs, data and config.example.lua
  database\                      schema, migrations and the development seed
  scripts\                       PowerShell helper used by the .bat files

You can put this folder anywhere, for example C:\PokeVerse-Test\. Paths with
spaces work. Do not move single files out of it.


Step 1 - database (once)
------------------------
1. Make sure the MariaDB service is running (Services -> MariaDB, or the
   MariaDB installer's "Start service" option).
2. Double-click Setup-PokeVerse-Database.bat and answer the questions.
   Enter accepts the default in [brackets]:
     MariaDB host                  127.0.0.1
     MariaDB port                  3306
     administrator user            root
     administrator password        the password you chose when installing MariaDB
     database name                 pokeverse
     database user for the server  pokeverse
     its password                  pokeverse-dev (fine for local testing)
     development accounts          Yes
3. The script finds mariadb.exe (PATH, then C:\Program Files\MariaDB*\bin and
   the usual XAMPP/WAMP/Laragon folders; set POKEVERSE_MYSQL=<full path to
   mariadb.exe> to choose one), creates the database, imports the schema,
   applies every migration, creates the database user, writes
   server\config.lua and checks that every table the server needs exists.
4. It ends with "Database setup: SUCCESS". Any SQL error stops it with
   "FAILED" and the MariaDB error message; nothing is ignored.

Running it again is safe: an existing database keeps its data and only gets
missing migrations and seeds.


Step 2 - play
-------------
Double-click Start-PokeVerse-Test.bat. It
  1. checks the database with the settings in server\config.lua,
  2. opens a "PokeVerse Server" window and waits until the server accepts
     logins (loading takes about one to three minutes),
  3. starts PokeVerse.exe.
It does not log in, type or click anything for you.

Or run the two parts yourself: Start-PokeVerse-Server.bat, wait for
"server Online!", then Start-PokeVerse-Client.bat.

In the client, log in to the 127.0.0.1 server with:

  account   password   character   role
  player    player     Trainer     normal player
  admin     admin      GM Admin    game master (God)

These two accounts exist only if you answered Yes to the development
accounts. They are DEVELOPMENT ONLY.

A new GM Admin has no Pokemon. In game, as GM Admin, say for example:
  /cb Charmander, 15, 10
to receive a level 15 Charmander (the full list is /commands).


Step 3 - stop
-------------
As GM Admin say /shutdown (saves everything), or close the "PokeVerse Server"
window. The server window shows the exit code before it closes.


Starting over
-------------
Reset-PokeVerse-Database.bat deletes the database (you must type its name to
confirm) and runs the setup again. Stop the server first.


What to test
------------
The checklist is docs/WINDOWS_HANDS_ON_TESTING.md in the PokeVerse repository.
Mark each item PASS / FAIL / NOT TESTED, with notes and screenshots
(Win+Shift+S). Logs are in:
  server\logs\                      server logs
  the "PokeVerse Server" window     startup and error messages
  client\pokeverse.log              client log


Troubleshooting
---------------
"No MariaDB client found"
    Install MariaDB Server, or set POKEVERSE_MYSQL to the full path of
    mariadb.exe (or mysql.exe) and run the setup again.
"Access denied for user 'root'"
    Wrong administrator password. Run the setup again.
"Can't connect to server on '127.0.0.1'"
    The MariaDB service is not running, or it uses another port.
"The database is not ready" in Start-PokeVerse-Test.bat
    Run Setup-PokeVerse-Database.bat; it lists the missing tables.
"port 7564 is in use"
    Another PokeVerse server is still running. Close its window.
The server window closes or shows an error during loading
    Read its last lines and server\logs\. A database error usually means
    server\config.lua has other credentials than the setup created; run the
    setup again.
The client window is black or does not open
    Update the graphics driver. Do not copy opengl32.dll into client\.
Windows SmartScreen blocks a .bat or .exe
    The test build is not signed. Choose "More info" -> "Run anyway".
