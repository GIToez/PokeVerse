#!/usr/bin/env bash
# Builds the PokeVerse Android APK on the Redemption engine.
#
#   scripts/build-android-client.sh [assembler options] <apk out path>
#
# The assembled client is zipped into the APK as assets/data.zip; the app unpacks it on
# first start and the updater keeps it current afterwards. Assembler options (--classic, --host, --port, --updater, --discord) are passed through.
#
# Needs ANDROID_HOME (with NDK 29.0.13599879 and CMake 3.22.1), VCPKG_ROOT and Java 17+.
# OTCLIENT_ANDROID_ABIS picks the ABIs (default arm64-v8a).
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
android=$root/core/client-redemption/android

opts=()
while [ $# -gt 1 ]; do
  case "$1" in
    --classic) opts+=("$1"); shift ;;
    --host|--port|--updater|--discord) opts+=("$1" "$2"); shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done
[ $# -eq 1 ] || { sed -n '2,11p' "$0" >&2; exit 1; }
apk=$(realpath -m "$1")

: "${ANDROID_HOME:?set ANDROID_HOME to the Android SDK}"
: "${VCPKG_ROOT:?set VCPKG_ROOT to a vcpkg checkout}"
export ANDROID_NDK_HOME=${ANDROID_NDK_HOME:-$ANDROID_HOME/ndk/29.0.13599879}
export OTCLIENT_ANDROID_ABIS=${OTCLIENT_ANDROID_ABIS:-arm64-v8a}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
"$root/scripts/assemble-redemption-client.sh" "${opts[@]}" "$work/client"

# Which engine this APK carries. The updater cannot replace the engine on Android, so when the
# Android manifest names another engine it offers the new APK instead of putting files made
# for that engine on this one. It changes only with what goes into the native library or the
# app around it, so releases that change only Lua and data still update in place.
engine_paths=(core/client-redemption/src core/client-redemption/android core/client-redemption/cmake
  core/client-redemption/overlay-ports core/client-redemption/CMakeLists.txt core/client-redemption/CMakePresets.json
  core/client-redemption/vcpkg.json core/client-redemption/vcpkg-configuration.json
  core/client-redemption/build_luajit_android.sh core/client-redemption/setup_android_deps.sh scripts/build-android-client.sh)
engine=$(cd "$root" && for p in "${engine_paths[@]}"; do git rev-parse "HEAD:$p" 2>/dev/null || echo "none"; done | sha1sum | cut -c1-12)
if [ -n "$(cd "$root" && git status --porcelain -- "${engine_paths[@]}" 2>/dev/null)" ]; then
  engine="$engine-dirty"
fi
# an engine built with another encryption key can't read the files, so the key is part of it
if [ -n "${PV_ENCRYPTION_KEY:-}" ]; then
  engine="$engine-$(printf 'pokeverse-engine:%s' "$PV_ENCRYPTION_KEY" | sha256sum | cut -c1-8)"
fi
echo "$engine" > "$work/client/engine.txt"
echo "Android engine: $engine"

mkdir -p "$android/app/src/main/assets"
rm -f "$android/app/src/main/assets/data.zip"
(cd "$work/client" && zip -qr -X "$android/app/src/main/assets/data.zip" .)

(cd "$android" && sh gradlew --no-daemon assembleRelease)

mkdir -p "$(dirname "$apk")"
cp "$android/app/build/outputs/apk/release/app-release.apk" "$apk"
echo "Android client ready: $apk"
