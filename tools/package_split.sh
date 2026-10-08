#!/usr/bin/env bash
# Assemble the separate PokeVerse packages from a validated development package
# (tools/package_windows.sh or tools/package_linux.sh) and a staged legacy client build
# (tools/build_client.sh production release, COPY_DATA=1 on Windows):
#   PokeVerse-Server-<OS>       server/, database/, scripts/ (Windows), database setup, start/stop
#   PokeVerse-Redemption-<OS>   redemption-client/ (client-redemption) + its launcher
#   PokeVerse-Legacy-<OS>       legacy-client/ (client/source + client/runtime-data) + its launcher
#   PokeVerse-Client-Comparison-Windows (Windows only): the three above in one folder, one server
# The server and Redemption files are copied unchanged from the development package, so they are
# the files that package's tests ran. Linux packages are also packed as .tar.gz. Ends with
# tools/validate_split_packages.sh.
# Usage: tools/package_split.sh <windows|linux> <dev-package-dir> <legacy-client-dist> <out-dir>
# Environment: POKEVERSE_VERSION (default dev) is written to VERSION.txt.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OS="${1:?usage: $0 <windows|linux> <dev-package-dir> <legacy-client-dist> <out-dir>}"
DEV="${2:?dev package dir}"
LEGACY="${3:?legacy client dist}"
OUTDIR="${4:?out dir}"
VERSION="${POKEVERSE_VERSION:-dev}"
COMMIT="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"

fail() { echo "PACKAGING REFUSED: $*" >&2; exit 1; }
to_crlf() { perl -e 'binmode STDIN; binmode STDOUT; local $/; $_ = <STDIN>; s/\r*\n/\r\n/g; print'; }
crlf() { to_crlf < "$1" > "$2"; }

case "$OS" in
    windows) OSNAME=Windows; TEMPLATES="$ROOT/packaging/windows"; X=.exe ;;
    linux) OSNAME=Linux; TEMPLATES="$ROOT/packaging/linux"; X= ;;
    *) fail "unknown OS '$OS' (windows or linux)" ;;
esac
SPLIT="$TEMPLATES/split"
[ -f "$DEV/server/pokeverse-server$X" ] || fail "$DEV is not a $OSNAME development package (no server/pokeverse-server$X)"
[ -f "$DEV/client/pokeverse-client$X" ] || fail "$DEV has no client/pokeverse-client$X"
[ -f "$LEGACY/pokeverse-client$X" ] || fail "no legacy client build $LEGACY/pokeverse-client$X (tools/build_client.sh production release)"
[ "$(cat "$LEGACY/VARIANT" 2>/dev/null)" = production ] || fail "$LEGACY/VARIANT is not production"
grep -aq Pokecenter "$LEGACY/pokeverse-client$X" "$LEGACY"/libotc_framework.* ||
    fail "$LEGACY/pokeverse-client$X is not the legacy client (no 'Pokecenter' marker)"
grep -aq Redemption "$LEGACY/pokeverse-client$X" && fail "$LEGACY/pokeverse-client$X is the Redemption client"

SERVER_PKG="$OUTDIR/PokeVerse-Server-$OSNAME"
REDEMPTION_PKG="$OUTDIR/PokeVerse-Redemption-$OSNAME"
LEGACY_PKG="$OUTDIR/PokeVerse-Legacy-$OSNAME"
COMPARISON_PKG="$OUTDIR/PokeVerse-Client-Comparison-Windows"
rm -rf "$SERVER_PKG" "$REDEMPTION_PKG" "$LEGACY_PKG" "$COMPARISON_PKG" "$OUTDIR"/PokeVerse-*-"$OSNAME".tar.gz
mkdir -p "$OUTDIR"

# Text files: CRLF on Windows (cmd.exe and Notepad), unchanged on Linux.
text() { if [ "$OS" = windows ]; then crlf "$1" "$2"; else install -m 0644 "$1" "$2"; fi; }
script() { install -m 0755 "$1" "$2"; }
version_file() { # <dest> <title> <lines...>
    local dest="$1" title="$2"; shift 2
    { echo "$title"; echo "version  $VERSION"; echo "commit   $COMMIT"; echo "built    $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      for line in "$@"; do echo "$line"; done; } > "$dest.tmp"
    text "$dest.tmp" "$dest"; rm "$dest.tmp"
}
SERVER_LINE='server   TFS 0.3.6 PokeVerse (server/source), listens on 127.0.0.1 (login 7564, game 8548)'
REDEMPTION_LINE='redemption-client  Redemption (client-redemption), Release, VARIANT=production'
LEGACY_LINE='legacy-client  legacy PokeVerse/PokeJornadas interface, OTClient 0.6.6 (client/source + client/runtime-data), Release, VARIANT=production'

# Server
mkdir -p "$SERVER_PKG"
cp -a "$DEV/server" "$DEV/database" "$SERVER_PKG/"
if [ "$OS" = windows ]; then
    cp -a "$DEV/scripts" "$SERVER_PKG/"
    for f in "Setup Database.bat" "Reset Development Database.bat" "Start Server.bat" "Stop Server.bat"; do
        crlf "$TEMPLATES/$f" "$SERVER_PKG/$f"
    done
else
    for f in setup-database.sh start-server.sh stop-server.sh; do script "$TEMPLATES/$f" "$SERVER_PKG/$f"; done
fi
text "$SPLIT/README-Server.txt" "$SERVER_PKG/README.txt"
version_file "$SERVER_PKG/VERSION.txt" "PokeVerse server package (PokeVerse-Server-$OSNAME)" "$SERVER_LINE"

# Redemption client
mkdir -p "$REDEMPTION_PKG"
cp -a "$DEV/client" "$REDEMPTION_PKG/redemption-client"
echo redemption > "$REDEMPTION_PKG/redemption-client/CLIENT"
if [ "$OS" = windows ]; then
    crlf "$SPLIT/Start Redemption Client.bat" "$REDEMPTION_PKG/Start Redemption Client.bat"
else
    script "$SPLIT/start-redemption-client.sh" "$REDEMPTION_PKG/start-redemption-client.sh"
fi
text "$SPLIT/README-Redemption.txt" "$REDEMPTION_PKG/README.txt"
version_file "$REDEMPTION_PKG/VERSION.txt" "PokeVerse Redemption client package (PokeVerse-Redemption-$OSNAME)" "$REDEMPTION_LINE"

# Legacy client: the executable under a name of its own, its framework library, the runtime DLLs
# (Windows) or libraries (Linux) it was linked against, and client/runtime-data without logs.
L="$LEGACY_PKG/legacy-client"
mkdir -p "$L"
MESA=' opengl32.dll libgallium_wgl.dll libglapi.dll dxil.dll '
(cd "$LEGACY" && find -L . -mindepth 1 -maxdepth 1) | while read -r entry; do
    name="${entry#./}"
    case "$MESA" in *" $name "*) continue ;; esac
    case "$name" in *.log|pokeverse-client|pokeverse-client.exe|otclientrc.lua|lib|libs) continue ;; esac
    cp -aL "$LEGACY/$name" "$L/$name"
done
find "$L" -name '*.log' -delete
install -m 0755 "$LEGACY/pokeverse-client$X" "$L/pokeverse-legacy-client$X"
echo legacy > "$L/CLIENT"
[ "$(head -c 7 "$L/data/things/Tibia.spr")" != version ] ||
    fail "$L/data/things/Tibia.spr is a Git LFS pointer; run: git lfs pull --include client/runtime-data/data/things/Tibia.spr"
if [ "$OS" = windows ]; then
    STRIP="${STRIP:-}"
    if [ -z "$STRIP" ]; then
        for s in x86_64-w64-mingw32-strip strip; do command -v "$s" > /dev/null && { STRIP=$s; break; }; done
    fi
    [ -n "$STRIP" ] && "$STRIP" --strip-debug "$L/pokeverse-legacy-client.exe" "$L/libotc_framework.dll" 2>/dev/null ||
        echo "WARNING: the legacy client keeps its debug info (no PE-capable strip)" >&2
    (cd "$L" && ls *.dll) | LC_ALL=C sort | to_crlf > "$L/required-dlls.txt"
    crlf "$SPLIT/Start Legacy Client.bat" "$LEGACY_PKG/Start Legacy Client.bat"
else
    strip --strip-debug "$L/pokeverse-legacy-client" "$L/libotc_framework.so"
    chmod 0644 "$L/libotc_framework.so"
    # Everything except the C library, the C++ runtime (the host's GL driver needs the host's
    # own) and the graphics, window system and sound-server libraries of the desktop.
    mkdir -p "$L/lib"
    LD_LIBRARY_PATH="$L" ldd "$L/pokeverse-legacy-client" "$L/libotc_framework.so" | awk '/=> \// {print $1, $3}' | sort -u |
    while read -r name path; do
        case "$name" in
            linux-vdso*|ld-linux*|libc.so*|libm.so*|libdl.so*|libpthread.so*|librt.so*|libresolv.so*|libutil.so*) continue ;;
            libstdc++.so*|libgcc_s.so*|libotc_framework.so) continue ;;
            libGL.so*|libGLX*|libGLdispatch*|libEGL*|libOpenGL*|libGLU*|libdrm*|libgbm*|libwayland*) continue ;;
            libX*|libxcb*|libxkb*|libasound.so*|libpulse*|libjack*) continue ;;
        esac
        install -m 0644 "$(readlink -f "$path")" "$L/lib/$name"
    done
    LD_LIBRARY_PATH="$L/lib:$L" ldd "$L/pokeverse-legacy-client" | grep -q 'not found' && fail "the legacy client has unresolved libraries"
    script "$SPLIT/start-legacy-client.sh" "$LEGACY_PKG/start-legacy-client.sh"
fi
text "$SPLIT/README-Legacy.txt" "$LEGACY_PKG/README.txt"
if [ "$OS" = linux ]; then
    needs=$(objdump -T "$L/pokeverse-legacy-client" "$L/libotc_framework.so" "$L"/lib/*.so* 2>/dev/null |
        grep -oE 'GLIBC_[0-9.]+|GLIBCXX_[0-9.]+' | sort -uV | awk -F_ '{v[$1]=$0} END {print v["GLIBC"], v["GLIBCXX"]}')
    version_file "$LEGACY_PKG/VERSION.txt" "PokeVerse legacy client package (PokeVerse-Legacy-$OSNAME)" "$LEGACY_LINE" \
        "needs    $needs or newer on the host (libstdc++, OpenGL, X11 and OpenAL's sound backend come from the host)"
else
    version_file "$LEGACY_PKG/VERSION.txt" "PokeVerse legacy client package (PokeVerse-Legacy-$OSNAME)" "$LEGACY_LINE" \
        'built with MSYS2 UCRT64 GCC; legacy updater (WinINet) compiled out'
fi

# Comparison (Windows): the three packages side by side, one server for both clients.
if [ "$OS" = windows ]; then
    mkdir -p "$COMPARISON_PKG"
    cp -a "$SERVER_PKG/server" "$SERVER_PKG/database" "$SERVER_PKG/scripts" "$COMPARISON_PKG/"
    cp -a "$REDEMPTION_PKG/redemption-client" "$LEGACY_PKG/legacy-client" "$COMPARISON_PKG/"
    for f in "Setup Database.bat" "Reset Development Database.bat" "Start Server.bat" "Stop Server.bat"; do
        cp "$SERVER_PKG/$f" "$COMPARISON_PKG/$f"
    done
    for f in "Start Legacy Client.bat" "Start Redemption Client.bat" "Start Both Clients.bat"; do
        crlf "$SPLIT/$f" "$COMPARISON_PKG/$f"
    done
    crlf "$SPLIT/README-Comparison.txt" "$COMPARISON_PKG/README.txt"
    version_file "$COMPARISON_PKG/VERSION.txt" 'PokeVerse client comparison package (PokeVerse-Client-Comparison-Windows)' \
        "$SERVER_LINE" "$REDEMPTION_LINE" "$LEGACY_LINE"
fi

"$ROOT/tools/validate_split_packages.sh" ${CHECK_IMPORTS:+--check-imports} "$OS" "$OUTDIR"

if [ "$OS" = linux ]; then
    for pkg in "$SERVER_PKG" "$REDEMPTION_PKG" "$LEGACY_PKG"; do
        name=$(basename "$pkg")
        tar -C "$OUTDIR" --owner=0 --group=0 --numeric-owner -czf "$OUTDIR/$name.tar.gz" "$name"
        echo "$OUTDIR/$name.tar.gz ($(du -h "$OUTDIR/$name.tar.gz" | cut -f1))"
    done
else
    for pkg in "$SERVER_PKG" "$REDEMPTION_PKG" "$LEGACY_PKG" "$COMPARISON_PKG"; do echo "$pkg ($(du -sh "$pkg" | cut -f1))"; done
fi
