#!/usr/bin/env python3
"""Compare tables referenced by server SQL (Lua + C++) with a database schema.

The schema comes from a live MariaDB database (--database) or from SQL files
(--sql, repeatable), so the check also runs without a server.
Lines that are commented out (Lua `--`, C/C++ `//`, `/* */` blocks) are ignored.

Exit status is 1 when a table referenced by active code is missing.
"""
import argparse
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCES = [
    (ROOT / "server/runtime-data/data", (".lua",)),
    (ROOT / "server/source", (".cpp", ".h")),
]
TABLE_RE = re.compile(
    r"(?<!KEY )\b(?:FROM|INTO|UPDATE|JOIN|TABLE(?: IF (?:NOT )?EXISTS)?)\s+`?([A-Za-z_][A-Za-z0-9_]*)`?"
)
CREATE_RE = re.compile(r"CREATE TABLE(?: IF NOT EXISTS)?\s+`?([A-Za-z_][A-Za-z0-9_]*)`?", re.IGNORECASE)
NOT_TABLES = {"information_schema", "sqlite_master", "dual"}
# databasemanager.cpp only upgrades schemas older than the imported dump.
SKIP_FILES = {"server/source/databasemanager.cpp"}
# Referenced only by code that never runs; creating them would hide real gaps.
KNOWN_UNUSED = {
    "z_ots_comunication": "Gesior shop globalevent is commented out in globalevents.xml",
    "z_shop_history": "Gesior shop globalevent is commented out in globalevents.xml",
    "player_stored_items": "doPlayerInsertStoredItem/doPlayerRemoveStoredItems have no callers",
}


def strip_comments(text, suffix):
    if suffix == ".lua":
        text = re.sub(r"--\[(=*)\[.*?\]\1\]", "", text, flags=re.S)
        return "\n".join(line.split("--", 1)[0] for line in text.splitlines())
    text = re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)
    return "\n".join(line.split("//", 1)[0] for line in text.splitlines())


def referenced_tables():
    refs = {}
    for base, suffixes in SOURCES:
        for path in sorted(base.rglob("*")):
            if path.suffix not in suffixes or "disabled" in path.parts:
                continue
            if str(path.relative_to(ROOT)) in SKIP_FILES:
                continue
            text = strip_comments(path.read_text(encoding="latin-1"), path.suffix)
            for lineno, line in enumerate(text.splitlines(), 1):
                if not re.search(r"\b(SELECT|INSERT|UPDATE|DELETE|REPLACE)\b", line):
                    continue
                for name in TABLE_RE.findall(line):
                    if name.lower() in NOT_TABLES:
                        continue
                    refs.setdefault(name, []).append(f"{path.relative_to(ROOT)}:{lineno}")
    return refs


def schema_tables(args):
    tables = set()
    for sql in args.sql or []:
        tables |= set(CREATE_RE.findall(pathlib.Path(sql).read_text(encoding="latin-1")))
    if args.database:
        cmd = args.mysql.split() + ["-N", "-e",
               f"SELECT table_name FROM information_schema.tables WHERE table_schema='{args.database}'"]
        tables |= set(subprocess.check_output(cmd, text=True).split())
    return tables


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--database", help="live database name to inspect")
    parser.add_argument("--mysql", default="mariadb", help="client command, e.g. 'mariadb -upokeverse -p...'")
    parser.add_argument("--sql", action="append", help="SQL file with CREATE TABLE statements")
    args = parser.parse_args()
    if not args.database and not args.sql:
        args.sql = [str(ROOT / "database/pokeaventuras.sql")] + [
            str(p) for p in sorted((ROOT / "database/migrations").glob("*.sql"))]

    refs = referenced_tables()
    tables = {t.lower() for t in schema_tables(args)}
    missing = {name: where for name, where in refs.items()
               if name.lower() not in tables and name not in KNOWN_UNUSED}
    print(f"{len(refs)} tables referenced by active server code; {len(tables)} tables in schema")
    for name, reason in sorted(KNOWN_UNUSED.items()):
        if name in refs and name.lower() not in tables:
            print(f"UNUSED  {name}: {reason}")
    for name in sorted(missing):
        print(f"MISSING {name}: {', '.join(missing[name][:3])}" + (" ..." if len(missing[name]) > 3 else ""))
    if not missing:
        print("OK: every referenced table exists")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
