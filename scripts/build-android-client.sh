#!/usr/bin/env bash
# Builds the PokeVerse Android APK on the Redemption engine.
#
#   scripts/build-android-client.sh [assembler options] <apk out path>
#
# The assembled client (legacy modules and data plus the Redemption overlay) is zipped into
# the APK as assets/data.zip; the app unpacks it on first start and the updater keeps it
# current afterwards. Assembler options (--host, --port, --updater) are passed through.
#
# Needs ANDROID_HOME (with NDK 29.0.13599879 and CMake 3.22.1), VCPKG_ROOT and Java 17+.
# OTCLIENT_ANDROID_ABIS picks the ABIs (default arm64-v8a).
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
android=$root/core/client-redemption/android

opts=()
while [ $# -gt 1 ]; do
  case "$1" in
    --host|--port|--updater) opts+=("$1" "$2"); shift 2 ;;
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

mkdir -p "$android/app/src/main/assets"
rm -f "$android/app/src/main/assets/data.zip"
(cd "$work/client" && zip -qr -X "$android/app/src/main/assets/data.zip" .)

(cd "$android" && sh gradlew --no-daemon assembleRelease)

mkdir -p "$(dirname "$apk")"
cp "$android/app/build/outputs/apk/release/app-release.apk" "$apk"
echo "Android client ready: $apk"
