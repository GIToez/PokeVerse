PokeVerse - Windows server package (PokeVerse-Server-Windows)
=============================================================

This folder holds the PokeVerse game server (server\pokeverse-server.exe),
built by GitHub Actions from the PokeVerse source, and everything it needs to
create its MariaDB database. Both PokeVerse clients connect to this one
server:
  PokeVerse-Legacy-Windows      the original PokeVerse interface
  PokeVerse-Redemption-Windows  the new Redemption client
(PokeVerse-Client-Comparison-Windows contains this server and both clients.)

The server only listens on 127.0.0.1, so only clients on this PC can connect.
DEVELOPMENT ONLY. The optional development accounts have public passwords.
Never open the server or the database to a network.


What you need
-------------
* Windows 10 or 11, 64-bit.
* MariaDB Server (tested with 10.11 LTS). Download the MSI from
  https://mariadb.org/download/ and keep the defaults: service enabled,
  port 3306. Write down the root password you choose.
Nothing else: every DLL the server needs is in server\.


Folder layout
-------------
  Setup Database.bat               create or upgrade the database (run first)
  Start Server.bat                 run the server in a console window
  Stop Server.bat                  stop the running server (it saves first)
  Reset Development Database.bat   DELETE the database and build it again (asks first)
  server\                          pokeverse-server.exe, its DLLs, data, map and config.lua
  database\                        schema, migrations and the development seed
  scripts\                         PowerShell helper used by the .bat files
  VERSION.txt                      the commit and build this package came from

Put the folder anywhere, for example C:\PokeVerse\Server. Paths with spaces
work. Do not move single files out of it.


First run
---------
1. Make sure the MariaDB service is running.
2. Double-click "Setup Database.bat". Enter accepts each default; type the
   MariaDB root password when asked. Answer Yes to the development accounts
   to get player / player (Trainer) and admin / admin (GM Admin).
   It ends with "Database setup: SUCCESS". Running it again is safe: it keeps
   the data and only adds missing migrations.
3. Double-click "Start Server.bat". Loading takes one to three minutes; the
   server is ready when its window prints "server Online!".
4. Start a client: "Start Legacy Client.bat" from PokeVerse-Legacy-Windows or
   "Start Redemption Client.bat" from PokeVerse-Redemption-Windows. Both
   connect to 127.0.0.1:7564 without editing anything.


Stopping
--------
Double-click "Stop Server.bat", press Ctrl+C in the "PokeVerse Server"
window, close that window, or say /shutdown as GM Admin. All of them save
players and the map before the server exits.


Starting over
-------------
"Reset Development Database.bat" deletes the database (you must type its name
to confirm) and runs the setup again. Stop the server first.


Troubleshooting
---------------
"No MariaDB client found"
    Install MariaDB Server, or set POKEVERSE_MYSQL to the full path of
    mariadb.exe and run the setup again.
"Access denied for user 'root'"
    Wrong administrator password. Run the setup again.
"The database in server\config.lua is not ready"
    Run "Setup Database.bat"; it lists the missing tables.
"port 7564 is in use"
    Another PokeVerse server is still running. Run "Stop Server.bat".
The server window closes or shows an error during loading
    Read its last lines and server\logs\.
Windows SmartScreen blocks a .bat or .exe
    The development build is not code-signed. Choose "More info" -> "Run anyway".
