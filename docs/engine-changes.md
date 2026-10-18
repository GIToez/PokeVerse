# PokeVerse changes to the Redemption engine

`core/client-redemption` started as a byte-for-byte copy of OTClient Redemption
([opentibiabr/otclient](https://github.com/opentibiabr/otclient) commit `53c3878`, kept unchanged in
`references/otclient-redemption`). Every engine change since then is listed here, so that taking a
newer Redemption means re-applying this list and nothing else.

```bash
# every engine change, file by file
diff -r references/otclient-redemption/src core/client-redemption/src
# the commits behind them (3ed80871 added the folder)
git log --oneline 3ed80871.. -- core/client-redemption/src core/client-redemption/cmake core/client-redemption/android
```

Rules for new engine changes:

- Fix it in the engine when the engine is wrong; don't add a Lua timer that keeps putting things
  right. The Lua modules (`core/client-redemption/pokeverse-modern`) should only describe the game.
- PokeVerse protocol behaviour sits behind `Otc::GamePokeVerse`, so the client still speaks the
  normal Tibia protocols.
- Add the change to this file in the same commit.

## Protocol (8.54, version 313)

| Where | What |
| --- | --- |
| `client/pokeverse.cpp`, `protocolcodes.h`, `protocolgame.h` | Server opcode 255 with its sub-opcodes (move bar, poll, ...), client opcodes 250 and 251. |
| `protocolgameparse.cpp` | Login `lightHour` field, the extra creature bytes (`localPlayerSummon`, `attackable`), the U16 channel-list count, extended opcodes without the handshake. |
| `protocolgameparse.cpp` (`getCreature`) | A creature's shader is only taken from the packet when `GameCreatureShader` is on. The PokeVerse server never sends one, and clearing it on every resend wiped the shiny and status shaders Lua puts on. |
| `protocolgamesend.cpp`, `game.cpp/.h` | Poll answers, `dashWalk`, 8.54 version limits. |
| `const.h`, `thingtype.cpp` | `GamePokeVerse` feature, 8.54 DAT quirks, OTServ 0.6 OS ids. |
| `game.cpp`, `localplayer.cpp` | The first value of each player stat reaches Lua (Redemption skipped unchanged ones). Auto-walk no longer stops on long walks. Diagonal steps at walking speed. |

## Creatures and the map

| Where | What |
| --- | --- |
| `creature.cpp/.h` | Ghost creatures, outfit colours (`setOutfitColor`), legacy health/experience/icon layout, crosshairs, PokeVerse name plates (party blue, PvP red, a Pokemon follows its trainer's colour). `setOutfit` gives a Lua outfit its category before comparing it (otherwise `{ type = 0 }` left a creature without a thing type: "Invalid thing type ... category 4" every frame). |
| `tile.cpp/.h` | Ghost creatures (client-side copies for effects, stack position 256). |
| `map.cpp` | Path finding searches up to 400000 nodes (50000 ran out around 200 tiles, which minimap and world map walks reach); with `GamePokeVerse`, only items on the current floor count for a tile. |
| `statictext.cpp` | Speech text passes through the PokeVerse translation with `GamePokeVerse`. |
| `mapview.cpp/.h`, `uimap.cpp/.h` | Wider zoomed-out view, flashlight on diagonals. `setShader` looks the shader up when the switch runs (after a shader created just before it has compiled) and compares with the shader coming next, so switching back during a fade-out works. |
| `uicreature.cpp/.h` | Legacy outfit widgets, `setFixedCreatureSize`. |
| `satellitemap.cpp/.h`, `uiminimap.h` | A 4 px per tile level (lod 8); at most 64 chunk textures loaded. |
| `uiradarchart.cpp/.h` | New `UIRadarChart` widget (Pokemon stats). |
| `luafunctions.cpp` | Bindings for the PokeVerse modules: `setOutfitColor`, `setGhost`, `isAttackable`, `isLocalPlayerSummon`, `dashWalk`, the poll functions, `setDrawExperienceBars`, `restartImageAnimation`, `setFixedCreatureSize`, `Creature:setIcon`. |

## Graphics

| Where | What |
| --- | --- |
| `framework/graphics/shadermanager.cpp/.h` | The shader list is locked (`std::shared_mutex`): the main thread adds shaders while Lua and the draw threads look them up. Queued shader work keeps its own copy of the name and code. At most 255 shaders (the id is a `uint8_t`). |
| `client/shadermanager.cpp` | Queued shader work keeps its own copy of the name and code (upstream kept pointers into Lua strings that could be freed first). |
| `drawpool.cpp/.h`, `drawpoolmanager.cpp/.h` | Draw orders stay in order when a frame's objects are merged. Attached widgets take their scale from the map view's pool (the preload thread has none). |
| `texture.cpp/.h` | A texture dropped from the atlas no longer draws the image that took its place (wrong Pokedex type icons). |
| `bitmapfont.cpp`, `fontmanager.h` | Legacy `.otfont` y-offset and nbsp width (`setLegacyFonts`). |
| `framebuffer.h` | `draw(dest, src)` helper. |

## UI

| Where | What |
| --- | --- |
| `framework/ui/uiwidget*.cpp/.h`, `uimanager.h` | UI scale 1, legacy `text-offset` (`setLegacyTextOffset`), word wrap no longer runs a line long when only the space overflows, clicks a few pixels off a text link count. |
| `framework/const.h` | Message mode and log level constants mapped to Redemption's numbering, legacy modifier values. |

## Lua

| Where | What |
| --- | --- |
| `cmake/Lua51.cmake`, `src/CMakeLists.txt` | PUC Lua 5.1.5 (`OPTIONS_USE_LUA51`, on) instead of LuaJIT, so table iteration order (and list order in the UI) is the same as the legacy client. Built as C++ (`OTC_LUA51_CXX`), so `lua_error` throws instead of `longjmp` and C++ frames it passes through are unwound properly; linked with the client's C runtime on Windows, without FORTIFY on Android. |
| `framework/luaengine/lbitlib.cpp` | Legacy `bit32` (headers without `extern "C"` when Lua is C++). |
| `framework/luaengine/luainterface.cpp/.h` | A failed C++ call raises its Lua error only after the `catch` block has ended. With Lua built as C (LuaJIT, the browser build) errors `longjmp`, and jumping out of an MSVC `catch` freed the exception's strings twice (heap corruption `0xC0000374`). With Lua built as C++, a Lua error raised inside a C++ call is re-thrown as it is. Lua panics write a crash report. |

## Platform

| Where | What |
| --- | --- |
| `framework/platform/win32crashhandler.cpp`, `crashhandler.h` | `crashreport.log` (backtrace with module+offset, last 200 log lines) and `crashreport.dmp` in the client folder. A vectored handler catches heap corruption and stack overruns, which skip the unhandled exception filter; CRT fatal errors, `std::terminate`, stack overflow and Lua panics are reported too. Upstream's `unixcrashhandler.cpp` is removed: `CRASH_HANDLER` is only defined for MSVC, so it never compiled. |
| `framework/core/logger.cpp/.h`, `graphicalapplication.cpp` | Every log line is flushed; the last session's log is kept as `pokeverse-previous.log`; the crash handler is installed again after GL and sound init. |
| `framework/core/resourcemanager.cpp`, `unzipper.cpp/.h` | The updater replaces the executable under its own name (shortcuts survive). Android unpacks `data.zip` without loading it into memory, with progress, again when the APK changes, and restarts an interrupted unpack. |
| `framework/core/minizip/crypt.c` | `getrandom` instead of `arc4random_buf` (needs glibc 2.36). |
| `framework/net/protocolhttp.cpp/.h` | Downloads spread over four HTTP clients; `g_http.forgetDownload`; Android verifies HTTPS against the system CA store. |
| `framework/platform/android*.cpp/.h`, `android/` | Reports itself as a mobile Android device (not Linux), long press opens the right-click menu, volume buttons control media volume, foreground service while updating or logged in, first-start progress screen, PokeVerse name and icon. |
| `platformwindow.cpp`, `win32window.cpp` | Ctrl is the plain Ctrl modifier, not Redemption's primary modifier. |
| `platform.h` | Android reports a mobile Android device. |
| `application.cpp` | OS name `android` on Android (it also defines `__linux`), build revision from CI, ARM64 as the build architecture. |
| `gitinfo.h`, `src/CMakeLists.txt` | Version label shows the CI run number and commit. |
