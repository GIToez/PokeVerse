#!/usr/bin/env bash
# Refuse an Android APK that is not ready to install for testing: it must exist, be signed
# (apksigner verify), contain the arm64-v8a native client and a data.zip with the PokeVerse
# Redemption runtime (init.lua, modules, the real 854 SPR/DAT, not Git LFS pointers) and the
# data_stamp.txt that makes an updated APK replace old game data, and contain no bot module,
# test harness or smoke-test scripts.
# Usage: tools/validate_android_apk.sh <app.apk>   (apksigner from ANDROID_HOME build-tools or PATH)
set -euo pipefail
APK="${1:?usage: $0 <app.apk>}"
[ -s "$APK" ] || { echo "APK INVALID: $APK is missing or empty" >&2; exit 1; }

APKSIGNER=$(command -v apksigner || ls -1 "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/nonexistent}}"/build-tools/*/apksigner 2>/dev/null | sort -V | tail -1 || true)
[ -n "$APKSIGNER" ] || { echo "APK INVALID: apksigner not found (Android SDK build-tools)" >&2; exit 1; }
if ! "$APKSIGNER" verify --print-certs "$APK" > /tmp/apksigner.out 2>&1; then
    echo "APK INVALID: $APK is not signed or the signature does not verify:" >&2
    cat /tmp/apksigner.out >&2
    exit 1
fi
echo "Signature: $(grep -m1 'certificate DN' /tmp/apksigner.out || echo verified)"

python3 - "$APK" <<'PY'
import io, sys, zipfile
apk_path = sys.argv[1]
problems = []
apk = zipfile.ZipFile(apk_path)
names = set(apk.namelist())
for required in ('AndroidManifest.xml', 'lib/arm64-v8a/libotclient.so', 'assets/data.zip', 'assets/data_stamp.txt'):
    if required not in names:
        problems.append(f'missing {required}')
if 'assets/data.zip' in names:
    data = zipfile.ZipFile(io.BytesIO(apk.read('assets/data.zip')))
    entries = {i.filename: i for i in data.infolist()}
    for required in ('init.lua', 'modules/client/client.otmod', 'modules/gamelib/pokeverse.lua',
                     'modules/game_pokebar/pokebar.otmod', 'modules/game_pokemoves/pokemoves.otmod',
                     'modules/client_entergame/entergame.lua', 'data/things/854/Tibia.dat', 'data/things/854/Tibia.spr',
                     # the images init.lua checks at startup
                     'data/images/background.png', 'data/images/clienticon.png',
                     'data/images/game/healthcircle/bottom_empty.png', 'modules/game_pokedex/images/background.png'):
        if required not in entries:
            problems.append(f'data.zip is missing {required}')
    for asset, minimum in (('data/things/854/Tibia.spr', 1_000_000), ('data/things/854/Tibia.dat', 100_000)):
        if asset in entries:
            head = data.open(asset).read(7)
            if head == b'version':
                problems.append(f'data.zip {asset} is a Git LFS pointer')
            elif entries[asset].file_size < minimum:
                problems.append(f'data.zip {asset} is only {entries[asset].file_size} bytes')
    if '127.0.0.1' not in data.read('init.lua').decode('latin-1'):
        problems.append('init.lua has no development server profile (127.0.0.1)')
    for name in entries:
        lower = name.lower()
        if lower.startswith('mods/game_bot/') or '/game_bot/' in lower:
            problems.append(f'bot module in data.zip: {name}'); break
    for name in entries:
        if 'harness' in name.lower():
            problems.append(f'harness file in data.zip: {name}')
        elif name.endswith('.lua') and b'[pv-smoke]' in data.read(name):
            problems.append(f'smoke-test script in data.zip: {name}')
    print(f'data.zip: {len(entries)} files, Tibia.spr {entries.get("data/things/854/Tibia.spr").file_size if "data/things/854/Tibia.spr" in entries else 0} bytes')
if problems:
    print(f'APK INVALID: {apk_path}', file=sys.stderr)
    for p in problems:
        print(f'  - {p}', file=sys.stderr)
    sys.exit(1)
PY
echo "Android APK valid: $APK ($(du -h "$APK" | cut -f1))"
