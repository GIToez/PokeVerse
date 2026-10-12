#!/bin/sh
# Starts PokeVerse from the folder this script is in. On every start it also keeps a
# "PokeVerse" entry (with the PokeVerse icon) in the app menu pointing at this folder, so
# moving the folder and starting the game once fixes the entry.
#
#   sh PokeVerse.sh                     start the game (arguments go to the game)
#   sh PokeVerse.sh --remove-menu-entry remove the app menu entry and its icon, then exit
#
# Installs from before the engine was renamed still have it as ./otclient; the updater
# replaces the engine under its existing name, so both names are tried.

dir=$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")" && pwd) || exit 1
cd "$dir" || exit 1

apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
entry="$apps/pokeverse.desktop"

if [ "$1" = "--remove-menu-entry" ]; then
    rm -f "$entry" "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/128x128/apps/pokeverse.png"
    echo "Removed the PokeVerse app menu entry"
    exit 0
fi

icons="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/128x128/apps"

menu_entry() {
    # Desktop entry Exec quoting: inside the double quotes ", `, $ and \ take a backslash,
    # and every backslash is then doubled again by the general string escaping
    quoted=$(printf '%s' "$dir/PokeVerse.sh" | sed -e 's/\\/\\\\\\\\/g' -e 's/["`$]/\\\\&/g')
    cat <<EOF
[Desktop Entry]
Type=Application
Name=PokeVerse
Comment=Play PokeVerse
Exec=sh "$quoted"
Path=$dir
Icon=pokeverse
Terminal=false
Categories=Game;
EOF
}

if [ -n "$HOME" ] && mkdir -p "$apps" "$icons" 2>/dev/null; then
    if [ -f data/images/clienticon.png ] && ! cmp -s data/images/clienticon.png "$icons/pokeverse.png"; then
        cp data/images/clienticon.png "$icons/pokeverse.png" 2>/dev/null
    fi
    wanted=$(menu_entry)
    if [ "$(cat "$entry" 2>/dev/null)" != "$wanted" ]; then
        printf '%s\n' "$wanted" > "$entry" 2>/dev/null && chmod +x "$entry" 2>/dev/null
        command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$apps" >/dev/null 2>&1
    fi
fi

if [ -f ./PokeVerse ]; then
    game=./PokeVerse
elif [ -f ./otclient ]; then
    game=./otclient
else
    echo "PokeVerse: the game file is missing from $dir" >&2
    exit 1
fi
[ -x "$game" ] || chmod +x "$game" 2>/dev/null
exec "$game" "$@"
