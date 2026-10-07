# Security Audit (static, pre-execution)

**Scope:** the full PokeJornadas package imported into PokeVerse (client, client source, server, server source, SQL dump, updater tool, design files).
**Method:** static inspection only. **No executable, script, launcher, patcher or updater from the package was run.** Windows PE files were inspected with `pefile` (import tables and exports) and `strings`. Text files were searched with `grep`.

Severity levels: **High** (fix before any public deployment), **Medium** (fix before production), **Low** (hygiene or informational).

## Summary

| # | Finding | Severity | Location |
|---|---|---|---|
| 1 | The client runs server-sent Lua (`loadstring(buffer)()`) | **High** | `client/modules/game_market/market.lua:502`, `game_craft/craft.lua:191`, `game_pass/pass.lua:155`, `game_calendar/calendar.lua:90`, `game_task/task.lua:93` |
| 2 | Built-in client updater uses plain HTTP, verifies only MD5 from an unauthenticated `hash.xml`, and can replace any client file, including `otclient.exe` and DLLs | **High** | `client-src/src/client/game.cpp` (`UpdaterClientThread`, `UpdaterVerificClient`), `client-src/src/client/download.cpp` (WinINet), `client/modules/game_updater` |
| 3 | Remote admin protocol enabled, reachable from outside localhost, unencrypted, with a plaintext password (value **redacted** in the import) | **High** | `server/data/XML/admin.xml` |
| 4 | SQL queries built by string concatenation (JSON blobs, names, and client-supplied values) | **Medium/High** | `server/data/lib/game_market.lua`, `game_dungeon.lua`, `lib/ps/functions/others.lua`, `globalevents/scripts/gesior-shop-system.lua`, and many others |
| 5 | The SQL dump seeds a `GOD` account (group 1, player group 6) whose SHA-1 password hash is the well-known hash of `123456`; a second account uses the same hash | **Medium** | `database/pokeaventuras.sql` (identical copy at `server/poketibia.sql`) |
| 6 | Passwords stored as unsalted SHA-1 | **Medium** | `server/config.lua` (`encryptionType = "sha1"`) |
| 7 | Server ships `iidking-v2.01.exe`, a PE import-table patcher used to inject DLLs into executables | **Medium** (provenance) | `server/iidking-v2.01.exe` (committed as shipped; do not run) |
| 8 | Client ships `ex.dll` (lua-ex: `os.spawn`, `CreateProcessA`, env/dir functions). Nothing in the package loads it. | **Low/Medium** | `client/ex.dll` (committed as shipped) |
| 9 | Client anti-tamper check refuses to start if `LanEngine.dll`, `opengl32.dll`, `d3dcompiler_4x.dll`, `LanEngine.key` or `engine.spr` exist (anti-bot / anti-injection heuristic) | Info | `client/init.lua` |
| 10 | Server's client-version check is commented out in `ProtocolGame::login` | Low | `server-src/protocolgame.cpp` (around line 489) |
| 11 | Server's ExtendedOpcode handler (`opcode.lua`) does not check `json.decode` results or parameter types | Medium | `server/data/creaturescripts/scripts/opcode.lua` |
| 12 | Nested Git repository in the server source whose remote points at the original developer's Bitbucket | Info | `server-src/.git` (moved out to `_import/source-server.git`, not committed) |
| 13 | Personal Windows paths and usernames leaked in build files, logs and state files | Low (privacy) | `server-src/dev-cpp/Makefile.win` (`C:/Users/walox/...`), `server/settings.sav` (`C:\Users\Natanael\...`), `client/crashreport.log` |
| 14 | Hardcoded public IPs in the server list | Info | `server/data/XML/servers.xml` (`192.99.251.233:7172`; `192.254.73.118:7567` commented out) |
| 15 | Login-protocol "create character" packet (`0xFD`) adds a character to **any account, given only its name, with no password**. The vocation (starter Pokémon), town and world bytes are passed through unchecked. The staff-name filter on both create packets uses `&&` instead of `\|\|`, so it never matches. Account creation (`0xFC`) has no rate limit. | **High** | `server-src/protocollogin.cpp` (around lines 103–298), client side `client/modules/poke_create`, `gamelib/protocollogin.lua` |

## Details

### 1. Server-to-client Lua execution (High)

Five client modules turn the server's ExtendedOpcode payload directly into code:

```lua
local receive = loadstring("return ".. buffer)()   -- market, craft, pass, calendar
loadstring("__newBuffer = ".. buffer)()            -- task
```

On the server side, these payloads come from `table.tostring(...)`. Anyone who controls the server, a malicious fork, or a man-in-the-middle (the game protocol uses XTEA, not authenticated TLS) can execute arbitrary Lua in the client. The client exposes `g_resources`, `io` and `os`, so that means file access on the player's machine. **Recommendation:** switch these five channels to JSON (the dungeon, pokemonInfo, notification and shop channels already use JSON).

### 2. Client auto-updater (High)

- `Game::UpdaterXmlClient` downloads `data/hash.xml` from `http://localhost/otclient/` (hardcoded in the source and present in the shipped `otclient.exe`). In production this would be the operator's HTTP server.
- `Game::UpdaterVerificClient` compares local MD5s against that file and `Game::DownProgress` downloads each mismatched path with `InternetOpenUrl` (WinINet, `INTERNET_FLAG_NO_CACHE_WRITE`, no TLS, no signature).
- File names come from `hash.xml` and are written relative to the client directory. There is no check for `..`, so path traversal outside the client folder is likely possible (needs confirmation).
- **Recommendation:** keep this disabled until it has HTTPS, a signed manifest, path normalization, and an allow-list of updatable paths.

The standalone updater tool (`tools/updater-hash/Tools/Release/Hash.exe`) only *generates* hash lists. It imports `LIBEAY32`, `libphysfs`, `libstdc++` and `libgcc`; it has no network imports.

### 3. Admin protocol (High)

`admin.xml` had `enabled="1"`, `onlylocalhost="0"`, `encryption required="0"` and a plaintext `loginpassword`. The admin port shares the login port (`7564`) according to `config.lua`. **In the import, the password value was replaced with `CHANGE_ME`.** Nothing else was changed. **Recommendation:** disable this protocol or set `onlylocalhost="1"`.

### 4. SQL injection surface (Medium/High)

The Lua layer builds queries such as:

```lua
db.executeQuery("UPDATE `market_historic` set `historic` = '"..json.encode(historic).."' WHERE `player_id` = "..guid)
db.executeQuery("INSERT INTO `dungeon_ranking` (`ranking`, `diff`, `mapId`) VALUES ('"..json.encode(newRanking).."', "..diff..", "..mapId..")")
```

`diff` and `mapId` come from client JSON on opcode 41. This needs a full review (use `db.escapeString`, and cast numbers with `tonumber`).

### 5–6. Default accounts and password hashing

- Account `GOD` (id 70846) and `Canibal` (id 70848) both use `7c4a8d09ca3762af61e59520943dc26494f8941b`, which is SHA-1(`123456`). Their e-mail values look like placeholders.
- TFS 0.3.6 supports only plain, MD5 or SHA-1. Modernizing should include salted hashing (and matching website support).

### 7–8. Unusual binaries

| File | What it is | Imports of note | Assessment |
|---|---|---|---|
| `server/iidking-v2.01.exe` | IIDKing 2.01, a PE Import Table patcher (adds DLL imports to an EXE) | `ShellExecuteA`, `LoadLibraryA` | Not needed to run the server. Likely used to inject a DLL into `PS.exe` or `otclient.exe` at some point. Do not run. Do not redistribute. |
| `server/Large Address Aware.exe` | .NET utility that sets the LAA PE flag | `mscoree.dll` | Not needed. Committed as shipped; candidate for removal. |
| `client/ex.dll` | lua-ex 5.1 extension (`luaopen_ex`: `spawn`, `sleep`, `dirent`, `setenv`, ...) | `CreateProcessA`, `CreatePipe` | Not imported by `otclient.exe` and not `require`d by any module. Leftover. Remove. |
| `client/libtest.a`, `client/libtest.def` | MinGW import library exporting `Test(void*)` | — | Build leftover. |

The import tables of `otclient.exe` and `PS.exe` show nothing beyond what the source explains: WinINet for the updater, `ShellExecuteW` (OTClient's `openUrl`), MySQL, OpenSSL, Lua and libxml2. **The shipped `PS.exe` is byte-identical to `server-src/dev-cpp/PS.exe`** (SHA-256 `38eca75e…a1f9`). That matches the included server source's build output, but it does not prove the binary was built from exactly this source revision.

### 9. Anti-cheat / anti-bot

- `client/init.lua` aborts with a fatal error if known injector or bot artifacts are present (`LanEngine.dll`, `opengl32.dll` proxy, `d3dcompiler_43/47.dll`, `LanEngine.key`, `engine.spr`).
- The client CMake has `ENCRYPTIONKEY_NUMERIC_*` options. `spritemanager.cpp` (`decryptSPR`) and `thingtypemanager.cpp` (`decryptDAT`) can decrypt `.spr`/`.dat` files with keys derived from `g_app.getCode(1..3)`. That is asset obfuscation, not real security, and other tools must know about it to read the assets. The shipped `Tibia.spr`/`Tibia.dat` headers look normal (signatures `0x4B1E2C87`/`0x4B1E2CAA`, 169,214 sprites in extended u32 format). Whether the pixel data is encrypted is **unknown**.
- There is no kernel-level anti-cheat and no telemetry beyond the stock OTClient crash report (`crashreport.log`, written locally).

### 15. In-client account and character creation (High)

The `poke_create` module sends two custom login packets in place of the normal protocol version:

- `0xFC` creates an account plus its first character. The town and world bytes are mapped through `server/data/XML/CreateAcc.xml`. The `pokemon` byte becomes the vocation id without validation. The return value of `createAccount` is ignored.
- `0xFD` reads `accountName, characterName, pokemon, sex, town, world`, looks up the account **by name only**, and calls `createCharacter`. No password is read. Town, world and vocation are used raw.

The staff-prefix check `tmp.substr(0, 4) == "god " && tmp.substr(0, 3) == "cm " && ...` can never be true, so names like `GOD Foo` are accepted. **Recommendation:** require the account password (or a session token) for `0xFD`, validate vocation/town/world against allow-lists, fix the `&&` to `||`, and rate-limit both packets per IP.

### Network endpoints found

| Endpoint | Where | Purpose |
|---|---|---|
| `http://localhost/otclient/` | `client-src/src/client/game.cpp`, `otclient.exe` | Updater base URL |
| `192.99.251.233:7172` | `server/data/XML/servers.xml` | Game world "Yellow" |
| `192.254.73.118:7567` | `server/data/XML/servers.xml` (commented) | Game world "Red" |
| `127.0.0.1` | `server/config.lua` (`ip`, login port 7564, game port 8548) | Local bind |
| `www.pokecenter.com`, `forum.pokecenter.com`, `www.pokecenter.net`, `www.psoul.net`, `forum.psoul.net`, `www.pokenordic.com` | NPC dialogue, tutorials, `config.lua` `url`, `resources.h` | Branding text only (no requests) |
| `facebook.com/systemyart` | client tutorial/background | Credit link |
| `contato@pokejornadas.com` | `client/init.lua` | Support e-mail in an error message |

**No webhooks (Discord or otherwise), FTP or SSH credentials, API keys, cloud tokens or private keys were found.** `rsakey.private` is referenced but commented out in `admin.xml` and not shipped. The OTClient/TFS game RSA key is the stock public OpenTibia key.

### Payment-related code

- **Database only:** `donates`, `paypal_items`, `instant_payment_notifications` (PayPal IPN), `znote_paypal`, `znote_paygol`, `znote_shop*`. No website or payment handler code is in the package.
- `server/data/globalevents/scripts/gesior-shop-system.lua` delivers items from `z_ots_comunication` and `z_shop_history`. **Neither table exists in the SQL dump.**

## Actions taken during import

- Redacted the admin password in `server/data/XML/admin.xml` (`loginpassword="CHANGE_ME"`).
- Excluded all `.exe` and `.dll` files from Git (see `BINARY_INVENTORY.md`).
- Moved the nested `server-src/.git` out of the tree (`_import/source-server.git`, ignored).
- Excluded logs, crash reports and state files that contain personal paths.
- Did **not** modify any gameplay code.
