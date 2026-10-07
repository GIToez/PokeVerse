#!/usr/bin/env bash
# Build OTClient Redemption (client-redemption/) with its upstream CMake presets and vcpkg.
# Output goes to build/client-redemption/<type>/bin (never into the source tree).
# Usage: tools/build_redemption.sh [release|debug]
# Linux: presets linux-release / linux-debug, GCC 14 by default (CC/CXX override).
# Windows (Git Bash or MSYS2 with the MSVC developer environment loaded): presets
# windows-release / windows-debug, MSVC (cl.exe). See docs/BUILD_REDEMPTION.md.
# Environment: VCPKG_ROOT (default ~/vcpkg), JOBS, EXTRA_CMAKE_ARGS.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TYPE="${1:-release}"
case "$TYPE" in release|debug) ;; *) echo "usage: $0 [release|debug]" >&2; exit 2 ;; esac
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) PLATFORM=windows ;;
    *) PLATFORM=linux; export CC="${CC:-gcc-14}" CXX="${CXX:-g++-14}" ;;
esac
PRESET="$PLATFORM-$TYPE"
export VCPKG_ROOT="${VCPKG_ROOT:-$HOME/vcpkg}"
export VCPKG_DEFAULT_BINARY_CACHE="${VCPKG_DEFAULT_BINARY_CACHE:-$HOME/.cache/vcpkg/archives}"
mkdir -p "$VCPKG_DEFAULT_BINARY_CACHE"
[ -f "$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" ] || { echo "vcpkg not found at $VCPKG_ROOT" >&2; exit 1; }
BUILD="$ROOT/build/client-redemption/$TYPE"
cmake -S "$ROOT/client-redemption" -B "$BUILD" --preset "$PRESET" \
    -DTOGGLE_BIN_FOLDER=ON ${EXTRA_CMAKE_ARGS:-}
cmake --build "$BUILD" -j"${JOBS:-$(nproc)}"
ls "$BUILD/bin/"otclient* > /dev/null
echo "Built $(ls "$BUILD/bin/"otclient*)"
