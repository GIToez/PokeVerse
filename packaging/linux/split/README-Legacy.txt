PokeVerse - LEGACY client for Linux (PokeVerse-Legacy-Linux)
============================================================

The original PokeVerse client: the PokeJornadas interface, Pokemon windows
and effects on the customized OTClient 0.6.6 engine, compiled by GitHub
Actions from client/source in the PokeVerse repository with its security
fixes (no auto-updater). No original PokeJornadas binaries are used.

It connects to the PokeVerse server on this PC (127.0.0.1, port 7564), the
same server the Redemption client uses (PokeVerse-Server-Linux.tar.gz).


What you need
-------------
* 64-bit x86 Linux with glibc 2.38 or newer and an X11 desktop session
  (XWayland works) with OpenGL.
* A running PokeVerse server.
The libraries the client needs (Boost, PhysFS, GLEW, OpenAL, Vorbis, Lua,
OpenSSL) are in legacy-client/lib/; OpenGL and X11 come from the system.


Play
----
      tar -xzf PokeVerse-Legacy-Linux.tar.gz && cd PokeVerse-Legacy-Linux
      ./start-legacy-client.sh

Log in with your account, or with the development accounts player / player
(Trainer) and admin / admin (GM Admin). Settings are kept in ~/.Pokecenter,
the log in ~/Pokecenter.log; the Redemption client uses other folders.
