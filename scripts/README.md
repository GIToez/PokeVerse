# scripts/

Build and setup automation.

| Script | Purpose |
| --- | --- |
| `verify-references.sh` | Checks that `references/` still matches the original archive byte-for-byte. |
| `protocol-test.py` | Pure-Python game client: login, character list, game login, walking and logout against a running server. |
| `test-server-linux.sh` | Builds a throwaway MariaDB, sets up the database, starts the server and runs the protocol tests (Linux). |
| `package-windows.sh` | Assembles `PokeVerse-Windows-Dev/` from the Windows builds (runs in MSYS2, used by CI). |
| `windows-package/` | The `.bat` files and README that ship inside the Windows package. |
| `test-package-windows.py` | Tests an extracted Windows package end to end using only its own files. |
