PokeVerse - REDEMPTION client for Windows (PokeVerse-Redemption-Windows)
=======================================================================

This is the new PokeVerse client, built by GitHub Actions from
client-redemption in the PokeVerse repository (OTClient Redemption engine)
with the PokeVerse modules ported so far, the PokeVerse sprites (854 SPR/DAT),
graphics and fonts.

It connects to the PokeVerse server on this PC (127.0.0.1, port 7564), the
same server the legacy client uses. Get the server from
PokeVerse-Server-Windows, or use PokeVerse-Client-Comparison-Windows, which
contains the server and both clients.


What you need
-------------
* Windows 10 or 11, 64-bit, with a normal graphics driver (OpenGL).
* A running PokeVerse server (see PokeVerse-Server-Windows\README.txt).
Nothing else: no Visual C++ redistributable is needed.


Folder layout
-------------
  Start Redemption Client.bat   start the Redemption client
  redemption-client\            pokeverse-client.exe, data, modules and mods
  VERSION.txt                   the commit and build this package came from

Put the folder anywhere; paths with spaces work.


Play
----
1. Start the server ("Start Server.bat" in the server package) and wait for
   "server Online!".
2. Double-click "Start Redemption Client.bat".
3. Log in with your account, or with the development accounts:
     player / player   character Trainer
     admin  / admin    character GM Admin (game master)

Settings are kept in %APPDATA%\pokeverse; the log is
redemption-client\pokeverse.log. The legacy client uses a different folder,
so the two never share settings.


Troubleshooting
---------------
"The client folder ... has no images"
    The client was started from an incomplete folder. Extract the package
    again and use "Start Redemption Client.bat".
The window is black or does not open
    Update the graphics driver. Do not copy opengl32.dll into redemption-client\.
Windows SmartScreen blocks the .bat or .exe
    The development build is not code-signed. Choose "More info" -> "Run anyway".
