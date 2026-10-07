# Client Variants

PokeVerse builds its clients in three variants. **Only `production` may ever be packaged or shipped.**

| Variant | Purpose | Bot protection | Build type (default) | Build dir | Staged dir | Executable |
|---|---|---|---|---|---|---|
| `production` | What players get | ON | RelWithDebInfo | `build/client` | `dist/client` | `pokeverse-client` |
| `debug` | Developer debugging | ON | Debug | `build/client-debug` | `dist/client-debug` | `pokeverse-client-debug` |
| `harness` | Automated runtime tests (`tools/runtime_test.sh`) | **OFF** | RelWithDebInfo | `build/client-harness` | `dist/client-harness` | `pokeverse-client-harness` |

Build any variant with `VARIANT=<variant> tools/build_client.sh`. `BUILD_TYPE=...` overrides the build type.

Production uses RelWithDebInfo rather than Release on purpose: it keeps assertions on. Phase 2 found the `StaticText::compose` stack leak only because an assertion fired.

## The harness variant

The harness needs bot protection off so a Lua test module (`tools/runtime-harness/pv_harness`) can perform game actions such as using items, walking and sending extended opcodes. That is exactly what a bot does, so **the harness client must never be shipped as a production client.**

These safeguards keep the harness out of releases:

| Safeguard | Where |
|---|---|
| A separate CMake variable `BUILD_VARIANT=harness`. It defines `POKEVERSE_HARNESS_BUILD`. | `client/source/src/framework/CMakeLists.txt` |
| CMake refuses to configure `BOT_PROTECTION=OFF` with any variant except `harness`. It also refuses `harness` with bot protection on. | `client/source/src/client/CMakeLists.txt` |
| Different directories and executable names, plus a `VARIANT` marker file in the staged directory | `tools/build_client.sh` |
| The window title is prefixed `[HARNESS - NOT FOR DISTRIBUTION]`. This is done in the platform window code, so no Lua module can remove it. | `x11window.cpp`, `win32window.cpp` |
| A red banner reading "HARNESS BUILD - TEST AUTOMATION ENABLED - NOT FOR DISTRIBUTION" spans the top of the client. It ignores clicks. | `modules/client/client.lua` (`g_app.getBuildVariant()`) |
| A startup log warning | `core/application.cpp` |
| The harness module is not part of `client/runtime-data`. `runtime_test.sh` copies it into the user directory for the run and deletes it afterwards. | `tools/runtime_test.sh` |
| `runtime_test.sh` refuses any client whose `VARIANT` file is not `harness` | `tools/runtime_test.sh` |
| The **packaging guard** (below) | `tools/package_client.sh` |

## Packaging guard

`tools/package_client.sh [dist-dir] [output.tar.gz]` is the only supported way to make a client package. It refuses to package (exit 1, `PACKAGING REFUSED: ...`) when:

- any of the environment variables `VARIANT` (other than `production`), `BOT_PROTECTION_DISABLED` or `TEST_AUTOMATION_ENABLED` is set;
- the staged `VARIANT` file is missing or not `production`;
- an executable name contains `harness` or `debug`;
- an executable or shared library contains the harness markers compiled in by `POKEVERSE_HARNESS_BUILD`, even if it was renamed;
- a `pv_harness` module is anywhere in the tree.

CI checks both directions: the production build packages, and the harness build is refused. `tools/validate.py regressions` also fails if the guard is removed.

### Verified (2026-10-07, Linux)

| Case | Result |
|---|---|
| `tools/package_client.sh dist/client` | Packaged |
| `tools/package_client.sh dist/client-harness` | Refused (`VARIANT is 'harness'`) |
| `TEST_AUTOMATION_ENABLED=1 tools/package_client.sh dist/client` | Refused |
| Harness binaries renamed to `pokeverse-client` with a forged `VARIANT=production` | Refused (`libotc_framework.so contains harness markers`) |

## Harness tests as regression tests

`tools/runtime_test.sh` is the runtime regression suite for the legacy client. It covers the Phase 2 fixes: the Pokédex, speech bubbles, Pokémon Info with the Pokémon in its ball, and containers. It must be run against a freshly started server. Wild Pokémon spawned by earlier runs (`/m rattata`) stay on the map, attack the test Pokémon, and make later steps fail. On 2026-10-07 the variant build passed every step listed in `FEATURE_TEST_MATRIX.md` on a fresh server.

## Redemption client

The Redemption client (`client-redemption/`) uses the same three variant names and output pattern: `build/client-redemption/<type>`, staged to `dist/client-redemption` and `dist/client-redemption-harness`. The same packaging guard applies. See `BUILD_REDEMPTION.md`.

## Reference client location

The current PokeVerse client, `client/source` plus `client/runtime-data` (OTClient 0.6.6 fork), is the **legacy reference client**. It is the parity reference for Redemption and is kept unmodified except for bug fixes. It is not moved to `legacy-reference/`: moving it again would add another ~11,000 renames on top of Phase 2 (`PHASE_2_DIFF_AUDIT.md`). Its location is documented here and in `ARCHITECTURE.md` instead.
