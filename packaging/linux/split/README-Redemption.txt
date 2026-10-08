PokeVerse - REDEMPTION client for Linux (PokeVerse-Redemption-Linux)
====================================================================

The new PokeVerse client, built by GitHub Actions from client-redemption
(OTClient Redemption engine) with the PokeVerse modules ported so far and the
PokeVerse sprites (854 SPR/DAT), graphics and fonts.

It connects to the PokeVerse server on this PC (127.0.0.1, port 7564), the
same server the legacy client uses (PokeVerse-Server-Linux.tar.gz).


What you need
-------------
* 64-bit x86 Linux with glibc 2.38 or newer and a desktop session with OpenGL.
* A running PokeVerse server.
The client only uses the system's OpenGL and X11 libraries.


Play
----
      tar -xzf PokeVerse-Redemption-Linux.tar.gz && cd PokeVerse-Redemption-Linux
      ./start-redemption-client.sh

Log in with your account, or with the development accounts player / player
(Trainer) and admin / admin (GM Admin). Settings are kept in
~/.local/share/pokeverse, the log in redemption-client/pokeverse.log; the
legacy client uses other folders.
