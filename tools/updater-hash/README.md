# updater-hash (original "Atualizando Cliente" package)

This is the original PokeJornadas client-updater helper. It contains only:

- `Tools/Release/Hash.exe` (301,126 bytes, x86 MinGW, **no source available**, committed as shipped). It generates the `hash.xml` manifest (`<hashings><hashing name="path" hash="MD5"/>…`) that the in-client updater (`client/modules/game_updater`, C++ `Game::UpdaterVerificClient`) compares against.
- `OTClientHash/` (empty; presumably where the generated files went).

`Hash.exe` imports `LIBEAY32.dll`, `libphysfs.dll`, `libgcc_s_dw2-1.dll` and `libstdc++-6.dll`. None of these DLLs ship with it, so it does not run as provided. It has no network imports.

It has not been executed. A replacement should be written from scratch (for example a small script that emits SHA-256 manifests) once the updater is redesigned. See `docs/SECURITY_AUDIT.md`.
