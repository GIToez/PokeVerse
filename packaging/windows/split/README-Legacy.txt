PokeVerse - LEGACY client for Windows (PokeVerse-Legacy-Windows)
================================================================

This is the original PokeVerse client: the PokeJornadas interface, Pokemon
windows and effects on the customized OTClient 0.6.6 engine. It was compiled
by GitHub Actions from client\source in the PokeVerse repository with its
security fixes (no auto-updater). None of the original PokeJornadas .exe or
.dll files are used.

It connects to the PokeVerse server on this PC (127.0.0.1, port 7564), the
same server the Redemption client uses. Get the server from
PokeVerse-Server-Windows, or use PokeVerse-Client-Comparison-Windows, which
contains the server and both clients.


What you need
-------------
* Windows 10 or 11, 64-bit, with a normal graphics driver (OpenGL).
* A running PokeVerse server (see PokeVerse-Server-Windows\README.txt).
Nothing else: every DLL the client needs is in legacy-client\.


Folder layout
-------------
  Start Legacy Client.bat     start the legacy client
  legacy-client\              pokeverse-legacy-client.exe, its DLLs, data and modules
  VERSION.txt                 the commit and build this package came from

Put the folder anywhere; paths with spaces work.


Play
----
1. Start the server ("Start Server.bat" in the server package) and wait for
   "server Online!".
2. Double-click "Start Legacy Client.bat".
3. Log in with your account, or with the development accounts:
     player / player   character Trainer
     admin  / admin    character GM Admin (game master)

Settings, the window position and the log are kept in your user folder:
%USERPROFILE%\Pokecenter\ and %USERPROFILE%\Pokecenter.log. The Redemption
client uses a different folder, so the two never share settings.


Troubleshooting
---------------
"legacy-client\opengl32.dll must not be there"
    The legacy client refuses to start next to a replacement OpenGL DLL.
    Delete it and update the graphics driver.
The window is black or does not open
    Update the graphics driver.
Windows SmartScreen blocks the .bat or .exe
    The development build is not code-signed. Choose "More info" -> "Run anyway".
