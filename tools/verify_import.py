#!/usr/bin/env python3
"""Verify the PokeVerse tree against the original PokeJornadas manifest.

Every entry of original/MANIFEST.sha256.tsv is classified, mapped to its
location in the repository and checked for presence, Git tracking and
SHA-256. PSD/PSB design sources are checked as Git LFS objects (they are no
longer in the working tree) by comparing the LFS object ids recorded in
DESIGN_COMMIT with the manifest and asking the LFS server whether it holds
each object, without downloading anything.

Usage: tools/verify_import.py [--layout phase1|phase2] [--no-remote] [--tsv OUT]
Exit status is non-zero when a REQUIRED file is missing or differs.
"""
import argparse
import base64
import collections
import hashlib
import json
import os
import re
import subprocess
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MANIFEST = os.path.join(ROOT, "original", "MANIFEST.sha256.tsv")
DESIGN_COMMIT = "5e2eaee"
LFS_POINTER = b"version https://git-lfs.github.com/spec/v1"

LAYOUTS = {
    "phase1": {
        "Cliente/Cliente/": ("client/", "client/"),
        "otclient src/otclient/": ("client-src/", "client-src/"),
        "Servidor/Servidor/": ("server/", "server/"),
        "Source Server/Source Server/": ("server-src/", "server-src/"),
        "Atualizando Cliente/Atualizando Cliente/": ("tools/updater-hash/", "tools/updater-hash/"),
    },
    # (normal destination, destination for original binaries / build output)
    "phase2": {
        "Cliente/Cliente/": ("client/runtime-data/", "original/binaries/client/"),
        "otclient src/otclient/": ("client/source/", "original/binaries/client-source/"),
        "Servidor/Servidor/": ("server/runtime-data/", "original/binaries/server/"),
        "Source Server/Source Server/": ("server/source/", "original/binaries/server-source/"),
        "Atualizando Cliente/Atualizando Cliente/": ("tools/updater-hash/", "original/binaries/updater-hash/"),
    },
}

# Files PokeVerse changed on purpose. They are reported, not counted as problems.
INTENTIONAL_CHANGES = {
    "Servidor/Servidor/data/XML/admin.xml": "plaintext admin password removed (SECURITY_AUDIT finding 3)",
}

BINARY_EXT = {".exe", ".dll", ".a", ".lib", ".def"}
BUILD_EXT = {".o", ".obj", ".res", ".pdb", ".ilk"}
OPTIONAL_PATTERNS = [
    r"/logs/", r"\.log$", r"/settings\.sav$", r"/forgottenserver\.map$", r"/\.idea/", r"/\.vscode/",
    r"/modules/\.project/", r"\.layout$", r"\.bak$", r"Thumbs\.db$", r"/\.git/", r"/\.gitignore$",
    r"/data/hash\.xml(file)?$",
]


def classify(path):
    if path.startswith("PSDS/"):
        return "DESIGN SOURCE"
    low = path.lower()
    ext = os.path.splitext(low)[1]
    if ext in BUILD_EXT or "/dev-cpp/obj/" in path:
        return "BUILD OUTPUT"
    if ext in BINARY_EXT:
        return "ORIGINAL BINARY"
    if any(re.search(p, path) for p in OPTIONAL_PATTERNS):
        return "OPTIONAL"
    return "REQUIRED"


def destination(path, category, layout):
    if path == "pokeaventuras (1).sql":
        return "database/pokeaventuras.sql"
    for prefix, (normal, binaries) in LAYOUTS[layout].items():
        if path.startswith(prefix):
            rel = path[len(prefix):]
            if category in ("ORIGINAL BINARY", "BUILD OUTPUT") and layout == "phase2":
                return binaries + rel
            return normal + rel
    if path.startswith("PSDS/PSDS/"):
        return "assets/design-psd/" + path[len("PSDS/PSDS/"):]
    return None


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def git(*args):
    return subprocess.run(["git", "-C", ROOT, *args], capture_output=True, check=False).stdout


def lfs_remote_check(objects):
    """Return {oid: True/False/None} for presence on the LFS server (None = unknown)."""
    url = git("remote", "get-url", "origin").decode().strip()
    m = re.match(r"https://(?:([^@]+)@)?github\.com/(.+?)(?:\.git)?$", url)
    if not m:
        return {oid: None for oid, _ in objects}
    cred, repo = m.groups()
    req = urllib.request.Request(
        f"https://github.com/{repo}.git/info/lfs/objects/batch",
        data=json.dumps({"operation": "download", "transfers": ["basic"],
                         "objects": [{"oid": o, "size": s} for o, s in objects]}).encode(),
        headers={"Accept": "application/vnd.git-lfs+json", "Content-Type": "application/vnd.git-lfs+json"})
    if cred:
        req.add_header("Authorization", "Basic " + base64.b64encode(cred.encode()).decode())
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            data = json.load(r)
    except Exception:
        return {oid: None for oid, _ in objects}
    return {o["oid"]: ("actions" in o and "error" not in o) for o in data.get("objects", [])}


def design_sources(manifest_rows, remote):
    pointers = {}
    in_git = set()
    for entry in git("ls-tree", "-r", "-z", DESIGN_COMMIT, "--", "assets/design-psd").decode("utf-8").split("\0"):
        if not entry:
            continue
        meta, path = entry.split("\t", 1)
        blob = git("cat-file", "-p", meta.split()[2])
        if blob.startswith(LFS_POINTER):
            fields = dict(l.split(" ", 1) for l in blob.decode().splitlines() if " " in l)
            pointers[path] = (fields["oid"].split(":", 1)[1], int(fields["size"]))
        else:
            pointers[path] = (hashlib.sha256(blob).hexdigest(), len(blob))
            in_git.add(path)
    lfs_objects = [v for k, v in pointers.items() if k not in in_git]
    status = lfs_remote_check(list(set(lfs_objects))) if remote and lfs_objects else {}
    results = []
    for path, size, digest in manifest_rows:
        dest = destination(path, "DESIGN SOURCE", "phase1")
        rec = pointers.get(dest)
        on_server = True if dest in in_git else (status.get(rec[0]) if rec else None)
        results.append((path, size, digest, dest, rec is not None, rec is not None and rec[0] == digest, on_server))
    return results


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--layout", default="phase2", choices=LAYOUTS)
    ap.add_argument("--no-remote", action="store_true", help="skip the LFS server presence check")
    ap.add_argument("--tsv", help="write a per-file report to this path")
    args = ap.parse_args()

    tracked = set(git("ls-files", "-z").decode("utf-8").split("\0"))
    rows = []
    for line in open(MANIFEST, encoding="utf-8"):
        parts = line.rstrip("\n").split("\t")
        if len(parts) == 3 and parts[1].isdigit():
            rows.append((parts[0], int(parts[1]), parts[2]))

    report = []
    summary = collections.defaultdict(collections.Counter)
    design_rows = []
    for path, size, digest in rows:
        cat = classify(path)
        if cat == "DESIGN SOURCE":
            design_rows.append((path, size, digest))
            continue
        dest = destination(path, cat, args.layout)
        full = os.path.join(ROOT, dest) if dest else None
        present = bool(full) and os.path.isfile(full)
        state = "missing"
        if present:
            with open(full, "rb") as f:
                head = f.read(len(LFS_POINTER))
            if head == LFS_POINTER and size > 200:
                state = "lfs-pointer"
            else:
                state = "match" if sha256(full) == digest else "differs"
        is_tracked = dest in tracked
        summary[cat][state] += 1
        summary[cat]["tracked" if is_tracked else "untracked"] += 1
        report.append((cat, path, dest or "", size, state, "tracked" if is_tracked else "untracked"))

    design = design_sources(design_rows, not args.no_remote)
    for path, size, digest, dest, recorded, oid_ok, on_server in design:
        state = "lfs-history-match" if oid_ok else ("lfs-history-differs" if recorded else "missing")
        summary["DESIGN SOURCE"][state] += 1
        summary["DESIGN SOURCE"]["on-lfs-server" if on_server else ("lfs-server-unknown" if on_server is None else "not-on-lfs-server")] += 1
        report.append(("DESIGN SOURCE", path, f"{dest} @ {DESIGN_COMMIT}", size, state,
                       "on-lfs-server" if on_server else ("unknown" if on_server is None else "absent")))

    if args.tsv:
        with open(args.tsv, "w", encoding="utf-8") as out:
            out.write("category\toriginal_path\trepo_path\tsize\tcontent\tgit\n")
            for r in report:
                out.write("\t".join(map(str, r)) + "\n")

    print(f"Manifest entries: {len(rows)}  (layout: {args.layout})")
    for cat in ("REQUIRED", "OPTIONAL", "BUILD OUTPUT", "ORIGINAL BINARY", "DESIGN SOURCE"):
        print(f"  {cat:16s} " + ", ".join(f"{k}={v}" for k, v in sorted(summary[cat].items())))
    for r in report:
        if r[1] in INTENTIONAL_CHANGES and r[4] == "differs":
            print("  intentional change:", r[1], "-", INTENTIONAL_CHANGES[r[1]])
    problems = [r for r in report if r[0] == "REQUIRED" and r[1] not in INTENTIONAL_CHANGES
                and (r[4] != "match" or r[5] != "tracked")]
    for r in problems:
        print("  REQUIRED problem:", r[4], r[5], r[1], "->", r[2])
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
