PokeVerse - Windows development package
========================================

Everything needed to play PokeVerse on this computer: the game server, the
game client and a private database. Nothing needs to be installed or compiled.
Everything runs on this computer only (127.0.0.1); nothing is reachable from
the internet or your local network.

Requirements
------------
- Windows 10 or 11, 64-bit.
- A graphics card with OpenGL 2.0 support (any graphics card from the last ten years).
- About 2 GB of free disk space.
- Extract the whole zip first. Do not run the files from inside the zip.
  A short path without special characters works best, for example C:\PokeVerse.

First start
-----------
1. Double-click "Setup Database.bat" and wait until it says "Database ready".
   This is only needed once. Running it again is safe; it keeps your accounts.
2. Double-click "Start Server and Client.bat".
   Three windows open: the database (minimized), the server and the client.
   The server needs about a minute to load the world.
3. In the client, log in with one of the test accounts:

     account: test    password: test    character: Trainer
     account: admin   password: admin   character: Admin (game master)

   Server address and port are already set to 127.0.0.1 and 7564.

If Windows shows "Windows protected your PC", choose "More info" then "Run anyway".
If the Windows firewall asks about pokeverse-server.exe or mariadbd.exe, you can
choose "Cancel": both only listen on 127.0.0.1 and do not need firewall access.

Scripts
-------
Setup Database.bat           Creates or updates the local database.
Start Server and Client.bat  Starts database, server and client.
Start Server.bat             Starts database and server only.
Start Client.bat             Starts the client only (the server must be running).
Create Account.bat           Creates a new account with one character.
                             Interactive, or: "Create Account.bat" name password "Character Name" [0 female / 1 male]
Stop Database.bat            Stops the database. Stop the server first.

Stopping
--------
Log out your characters, close the server window, then run "Stop Database.bat"
(or leave the database running; it uses very little memory).

Folders
-------
server-windows\          Game server (pokeverse-server.exe), its data and config.lua.
                         Server logs are in server-windows\logs\.
client-legacy-windows\   Game client (pokeverse-client.exe) and its data.
database\mariadb\        Portable MariaDB server (port 3307, 127.0.0.1 only).
database\sql\            Database setup scripts.
database\data\           Your database (created by "Setup Database.bat").
                         Delete this folder and run "Setup Database.bat" to start over.
tools\                   Helper scripts used by the files above.

Database access
---------------
Host 127.0.0.1, port 3307, database "pokeverse", user "pokeverse", password "pokeverse".
The MariaDB "root" user has no password and only accepts connections from this
computer. These are development settings; never expose this database or server.

Troubleshooting
---------------
- "The database did not start": see database\data\mariadb.err. Another program
  may be using port 3307.
- The server window closes or shows errors: see server-windows\logs\.
- The client log is pokeverse.log in your user folder (C:\Users\<you>\).
- Client shows "Connection refused": wait until the server window shows
  "server Online!", then log in again.
