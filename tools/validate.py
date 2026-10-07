#!/usr/bin/env python3
"""Static validation of the PokeVerse source tree (no server, client or database needed).

Checks:
  regressions  Phase 2 fixes and the harness guard are still in place
  lua        every .lua file under server/ and client/ runtime-data compiles (luac5.1 -p)
  xml        every server data XML is well-formed
  scripts    script files referenced by the server registries, monsters.xml and NPC XMLs exist
             (case-sensitive, as on Linux)
  modules    client .otmod dependencies name existing modules and listed scripts exist
  payloads   no client module evaluates server payloads with loadstring
  codec      server table.tostring payloads round-trip through client table.fromLiteral,
             and code-bearing input is rejected (tools/test_payload_codec.lua)
  db         every table referenced by server SQL exists in the dump + migrations

Usage: tools/validate.py [check ...]   (default: all checks). Exit status 1 on any failure.
"""
import os
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SERVER_DATA = os.path.join(ROOT, "server", "runtime-data", "data")
CLIENT_DATA = os.path.join(ROOT, "client", "runtime-data")
MODULES = os.path.join(CLIENT_DATA, "modules")

# JSON written by game_dungeon at runtime; it only has a .lua name.
NOT_LUA = {os.path.join("client", "runtime-data", "modules", "game_dungeon", "favorites.lua")}

# Stock TFS NPC left in the import; never spawned (absent from map-spawn.xml) so its script is never loaded.
STALE_NPCS = {"Soya.xml"}

REGISTRIES = ["actions", "movements", "talkactions", "creaturescripts", "globalevents", "spells", "weapons"]


def rel(path):
    return os.path.relpath(path, ROOT)


def walk(top, suffix):
    for dirpath, _, files in os.walk(top):
        for name in sorted(files):
            if name.lower().endswith(suffix):
                yield os.path.join(dirpath, name)


def exists_exact(path):
    """os.path.exists, but case-sensitive on every component even on case-insensitive filesystems."""
    path = os.path.normpath(path)
    if not os.path.exists(path):
        return False
    parts = os.path.relpath(path, ROOT).split(os.sep)
    cur = ROOT
    for part in parts:
        if part == "..":
            cur = os.path.dirname(cur)
            continue
        if part not in os.listdir(cur):
            return False
        cur = os.path.join(cur, part)
    return True


def check_lua():
    luac = shutil.which("luac5.1") or shutil.which("luac")
    if not luac:
        return ["luac5.1 not found (apt install lua5.1)"]
    errors = []
    count = 0
    for top in (os.path.join(ROOT, "server", "runtime-data"), CLIENT_DATA):
        for path in walk(top, ".lua"):
            if rel(path) in NOT_LUA:
                continue
            count += 1
            res = subprocess.run([luac, "-p", path], capture_output=True, text=True)
            if res.returncode != 0:
                errors.append(res.stderr.strip().splitlines()[0])
    print(f"  lua: {count} files compiled")
    return errors


def parse_xml(path):
    try:
        return ET.parse(path), None
    except ET.ParseError as exc:
        return None, f"{rel(path)}: {exc}"


def check_xml():
    errors = []
    count = 0
    for path in walk(SERVER_DATA, ".xml"):
        count += 1
        _, err = parse_xml(path)
        if err:
            errors.append(err)
    print(f"  xml: {count} files parsed")
    return errors


def check_scripts():
    errors = []
    count = 0
    for reg in REGISTRIES:
        xml_path = os.path.join(SERVER_DATA, reg, reg + ".xml")
        tree, err = parse_xml(xml_path)
        if err:
            errors.append(err)
            continue
        base = os.path.join(SERVER_DATA, reg, "scripts")
        for el in tree.iter():
            refs = []
            if el.get("event") == "script" and el.get("value"):
                refs.append(el.get("value"))
            if el.get("script"):
                refs.append(el.get("script"))
            for ref in refs:
                count += 1
                if not exists_exact(os.path.join(base, ref)):
                    errors.append(f"{rel(xml_path)}: <{el.tag}> script not found: {ref}")

    monsters_xml = os.path.join(SERVER_DATA, "monster", "monsters.xml")
    tree, err = parse_xml(monsters_xml)
    if err:
        errors.append(err)
    else:
        for el in tree.iter("monster"):
            count += 1
            if not exists_exact(os.path.join(SERVER_DATA, "monster", el.get("file", ""))):
                errors.append(f"{rel(monsters_xml)}: monster file not found: {el.get('file')}")

    npc_dir = os.path.join(SERVER_DATA, "npc")
    for path in walk(npc_dir, ".xml"):
        tree, err = parse_xml(path)
        if err or tree.getroot().get("script") is None or os.path.basename(path) in STALE_NPCS:
            continue
        count += 1
        if not exists_exact(os.path.join(npc_dir, "scripts", tree.getroot().get("script"))):
            errors.append(f"{rel(path)}: npc script not found: {tree.getroot().get('script')}")
    print(f"  scripts: {count} references resolved")
    return errors


def otmod_list(text, key):
    """Values of an OTML list field, either inline `key: [ a, b ]` or as indented `- a` lines."""
    m = re.search(rf"^[ \t]*{key}[ \t]*:[ \t]*(.*)$", text, re.M)
    if not m:
        return []
    inline = m.group(1).strip()
    if inline:
        return [v.strip() for v in inline.strip("[]").split(",") if v.strip()]
    values = []
    for line in text[m.end():].splitlines():
        s = line.strip()
        if not s or s.startswith("//"):
            continue
        if not s.startswith("-"):
            break
        values.append(s[1:].strip())
    return values


def check_modules():
    errors = []
    names = {}
    for path in walk(MODULES, ".otmod"):
        text = open(path, encoding="latin-1").read()
        m = re.search(r"^\s*name\s*:\s*(\S+)", text, re.M)
        if m:
            names[m.group(1)] = (path, text)
    for name, (path, text) in sorted(names.items()):
        for dep in otmod_list(text, "dependencies"):
            if dep not in names:
                errors.append(f"{rel(path)}: dependency on missing module {dep}")
        moddir = os.path.dirname(path)
        for script in otmod_list(text, "scripts"):
            script = script.strip("'\"")
            target = os.path.join(moddir, script)
            if not script.endswith(".lua"):
                target += ".lua"
            if not os.path.exists(target):
                errors.append(f"{rel(path)}: script not found: {script}")
    print(f"  modules: {len(names)} modules checked")
    return errors


def check_payloads():
    errors = []
    allowed = {os.path.join("client_terminal", "terminal.lua")}
    for path in walk(MODULES, ".lua"):
        if os.path.relpath(path, MODULES) in allowed:
            continue
        for lineno, line in enumerate(open(path, encoding="latin-1"), 1):
            code = line.split("--", 1)[0]
            if re.search(r"\bloadstring\s*\(", code):
                errors.append(f"{rel(path)}:{lineno}: loadstring on module data; use table.fromLiteral or json.decode")
    return errors


def check_codec():
    lua = shutil.which("lua5.1") or shutil.which("lua")
    if not lua:
        return ["lua5.1 not found (apt install lua5.1)"]
    res = subprocess.run([lua, os.path.join("tools", "test_payload_codec.lua")],
                         cwd=ROOT, capture_output=True, text=True)
    out = (res.stdout + res.stderr).strip().splitlines()
    if res.returncode == 0:
        print("  codec: " + (out[-1] if out else "ok"))
        return []
    return out or ["test_payload_codec.lua failed"]


def check_db():
    res = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "check_db_tables.py")],
                         capture_output=True, text=True)
    out = (res.stdout + res.stderr).strip()
    print("  db: " + (out.splitlines()[-1] if out else "no output"))
    return [] if res.returncode == 0 else out.splitlines()


# (file, regex that must match, what regresses without it). Runtime coverage: tools/runtime_test.sh.
REGRESSIONS = [
    ("server/runtime-data/data/lib/ps/config/pokemon.lua",
     r"function\s+getPokemonDexStorage\s*\(", "Pokedex: getPokemonDexStorage undefined"),
    ("client/source/src/client/statictext.cpp",
     r"MessageBarkLoud\)\s*\{\s*g_lua\.pop\(\);", "speech bubbles: Lua stack leak in StaticText::compose (monster/spell)"),
    ("client/source/src/client/statictext.cpp",
     r"\}\s*else\s*\{\s*g_lua\.pop\(\);\s*g_logger\.warning", "speech bubbles: Lua stack leak in StaticText::compose (unknown mode)"),
    ("server/runtime-data/data/lib/game_pokemonInfo.lua",
     r"if not summon or not isCreature\(summon\) then", "Pokemon Info errors when the Pokemon is in its ball"),
    ("client/runtime-data/modules/game_containers/containers.lua",
     r"if previousContainer and previousContainer\.window then", "container slot reuse crash"),
    ("client/runtime-data/modules/game_chat/chat.lua",
     r"bindKeyPress\('Ctrl\+A', function\(\) textEdit:clearText\(\) end, chatWindow\)", "chat Ctrl+A"),
    ("client/source/src/client/CMakeLists.txt",
     r"BOT_PROTECTION=OFF is only allowed with BUILD_VARIANT=harness", "harness guard: bot protection off outside harness"),
    ("tools/package_client.sh",
     r"TEST_AUTOMATION_ENABLED", "harness guard: packaging check"),
    ("server/source/server.cpp",
     r"running = true;\s*try\s*\{\s*m_io_service\.run\(\);", "shutdown: server process never exits (ServiceManager::stop no-op)"),
    ("server/source/protocolgame.cpp",
     r"m_acceptPackets = true;\s*if\(!g_game\.placeCreature", "login: client packets dropped until after placeCreature and the login DB write"),
    ("tools/package_client.sh",
     r"-name game_bot", "packaging: Redemption bot module not refused"),
    ("tools/stage_redemption.sh",
     r'rm -rf "\$DIST/mods/game_bot"', "staging: Redemption bot module shipped"),
]


def check_regressions():
    errors = []
    for path, pattern, what in REGRESSIONS:
        with open(os.path.join(ROOT, path), encoding="latin-1") as f:
            if not re.search(pattern, f.read()):
                errors.append(f"{path}: {what}")
    print(f"  regressions: {len(REGRESSIONS) - len(errors)}/{len(REGRESSIONS)} guarded fixes present")
    return errors


CENTER_RE = re.compile(rb"pok(?:e|\xe9|\xc3\xa9)mon[ _]?cent(?:er|re)|centro[ _]pok(?:e|\xe9|\xc3\xa9)mon|nurse[ _]?joy", re.I)
# The in-game Pokemon Center (building, Nurse Joy, heal/depot text) is a gameplay term and must
# survive the PokeVerse rebrand (docs/POKEVERSE_REBRAND_AUDIT.md section 3). Counts at Phase 3.
CENTER_MINIMUM = {
    "client/runtime-data": {"pokemon center": 1096, "centro pokemon": 78, "nurse joy": 6},
    "server/runtime-data": {"pokemon center": 76, "centro pokemon": 27, "nurse joy": 73},
}
MISBRAND_RE = re.compile(rb"pokeverse[ _]?cent(?:er|re)|centro[ _]pokeverse|nurse[ _]pokeverse|pokeverse[ _]joy", re.I)
OLD_BRAND_RE = re.compile(rb"psoul\.net|pokecenter\.(?:com|net)|pokenordic|pokezring", re.I)
BINARY_EXT = (".png", ".jpg", ".spr", ".dat", ".otbm", ".otb", ".ogg", ".wav", ".dll", ".exe", ".ttf", ".ico", ".zip")


def tracked(*paths):
    out = subprocess.run(["git", "ls-files", "-z", *paths], cwd=ROOT, capture_output=True).stdout
    return [p for p in out.decode("utf-8", "replace").split("\0") if p and not p.endswith(BINARY_EXT)]


def check_brand():
    errors = []
    counts = {area: dict.fromkeys(mins, 0) for area, mins in CENTER_MINIMUM.items()}
    for path in tracked("client", "server", "client-redemption/modules", "client-redemption/data", "tools"):
        try:
            with open(os.path.join(ROOT, path), "rb") as f:
                data = f.read()
        except OSError:
            continue
        if path != "tools/validate.py" and MISBRAND_RE.search(data):
            errors.append(f"{path}: the Pokemon Center was renamed ({MISBRAND_RE.search(data).group().decode('latin-1')})")
        area = "/".join(path.split("/")[:2])
        if area in counts:
            for m in CENTER_RE.finditer(data):
                key = re.sub(rb"[ _]", b" ", m.group().lower()).replace(b"\xc3\xa9", b"e").replace(b"\xe9", b"e")
                key = "nurse joy" if key == b"nursejoy" else key.decode()
                counts[area][key] += 1
        if path.startswith(("client/runtime-data", "server/runtime-data", "server/source")) and not path.endswith(".otmod"):
            for line in data.splitlines():
                if OLD_BRAND_RE.search(line) and not line.lstrip().startswith(b"--"):
                    errors.append(f"{path}: old project URL in user-facing text: {line.strip()[:100].decode('latin-1')}")
    for area, mins in CENTER_MINIMUM.items():
        for key, minimum in mins.items():
            if counts[area][key] < minimum:
                errors.append(f"{area}: '{key}' occurs {counts[area][key]} times, expected at least {minimum}")
    nurse = os.path.join(ROOT, "server/runtime-data/data/npc/Nurse Joy.xml")
    if not os.path.exists(nurse) or b'name="Nurse Joy"' not in open(nurse, "rb").read():
        errors.append("server/runtime-data/data/npc/Nurse Joy.xml: Nurse Joy NPC missing")
    spawns = open(os.path.join(ROOT, "server/runtime-data/data/world/map-spawn.xml"), "rb").read().count(b'name="Nurse Joy"')
    if spawns < 60:
        errors.append(f"map-spawn.xml: {spawns} Nurse Joy spawns, expected 60")
    summary = ", ".join(f"{a.split('/')[0]} {k} {v}" for a, c in counts.items() for k, v in c.items())
    print(f"  brand: {summary}; Nurse Joy spawns {spawns}")
    return errors


CHECKS = {
    "regressions": check_regressions,
    "brand": check_brand,
    "lua": check_lua,
    "xml": check_xml,
    "scripts": check_scripts,
    "modules": check_modules,
    "payloads": check_payloads,
    "codec": check_codec,
    "db": check_db,
}


def main():
    selected = sys.argv[1:] or list(CHECKS)
    failed = False
    for name in selected:
        if name not in CHECKS:
            sys.exit(f"unknown check {name}; choose from {', '.join(CHECKS)}")
        print(f"[{name}]")
        errors = CHECKS[name]()
        for err in errors:
            print(f"  FAIL {err}")
        failed |= bool(errors)
        print(f"  {'FAIL' if errors else 'OK'} ({len(errors)} problems)")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
