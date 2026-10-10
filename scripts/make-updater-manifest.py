#!/usr/bin/env python3
"""Builds the static updater site for one assembled Redemption client package.

    scripts/make-updater-manifest.py --package <client dir> --os windows|linux|android
        --site <site dir> --files-url <url of <site>/files> --version <tag>
        [--binary otclient.exe] [--release-dir <dir> --release-url <url>]
        [--max-size 95000000] [--skip <path>]...

Writes <site>/<os>.json and copies every package file into <site>/files/<path>, the
layout modules/updater/updater.lua expects. Files over --max-size (the Pages limit is
100 MB) go to --release-dir instead, to be uploaded as GitHub Release assets, and the
manifest points at them with absolute URLs under --release-url.

Several platforms can share one site: common files are stored once, and a path that
already exists with different content is an error.
"""
import argparse
import json
import os
import shutil
import sys
import zlib


def crc32(path):
    crc = 0
    with open(path, "rb") as f:
        while True:
            chunk = f.read(1 << 20)
            if not chunk:
                break
            crc = zlib.crc32(chunk, crc)
    # same format as the client (Crypt::crc32): lowercase hex, no leading zeros
    return format(crc & 0xFFFFFFFF, "x")


def asset_name(rel):
    return rel.replace("/", ".")


def same_file(a, b):
    return os.path.getsize(a) == os.path.getsize(b) and crc32(a) == crc32(b)


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--package", required=True)
    p.add_argument("--os", required=True, choices=["windows", "linux", "android", "mac"])
    p.add_argument("--site", required=True)
    p.add_argument("--files-url", required=True)
    p.add_argument("--version", required=True)
    p.add_argument("--binary", default="")
    p.add_argument("--release-dir", default="")
    p.add_argument("--release-url", default="")
    p.add_argument("--max-size", type=int, default=95_000_000)
    p.add_argument("--skip", action="append", default=[],
                   help="package path left out of the manifest, e.g. a binary the platform cannot replace")
    args = p.parse_args()
    skip = {s.strip("/") for s in args.skip}

    package = os.path.abspath(args.package)
    site = os.path.abspath(args.site)
    files_dir = os.path.join(site, "files")
    os.makedirs(files_dir, exist_ok=True)
    if args.release_dir:
        os.makedirs(args.release_dir, exist_ok=True)

    manifest = {"version": args.version, "url": args.files_url.rstrip("/"), "files": {}, "urls": {}}

    def publish(rel, src):
        if os.path.getsize(src) > args.max_size:
            if not args.release_dir or not args.release_url:
                sys.exit(f"{rel} is over {args.max_size} bytes: pass --release-dir and --release-url")
            dest = os.path.join(args.release_dir, asset_name(rel))
            if os.path.exists(dest) and not same_file(src, dest):
                sys.exit(f"release asset {asset_name(rel)} already exists with different content")
            shutil.copyfile(src, dest)
            manifest["urls"]["/" + rel] = args.release_url.rstrip("/") + "/" + asset_name(rel)
            return
        dest = os.path.join(files_dir, rel)
        if os.path.exists(dest):
            if not same_file(src, dest):
                sys.exit(f"{rel} differs between platforms; it cannot share one site")
            return
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        shutil.copyfile(src, dest)

    binary = args.binary.strip("/")
    for root, dirs, names in os.walk(package):
        dirs.sort()
        for name in sorted(names):
            src = os.path.join(root, name)
            rel = os.path.relpath(src, package).replace(os.sep, "/")
            if rel == binary or rel in skip:
                continue
            manifest["files"]["/" + rel] = crc32(src)
            publish(rel, src)

    if binary:
        src = os.path.join(package, binary)
        if not os.path.isfile(src):
            sys.exit(f"binary {binary} not found in {package}")
        manifest["binary"] = {"file": "/" + binary, "checksum": crc32(src)}
        publish(binary, src)

    if not manifest["urls"]:
        del manifest["urls"]
    out = os.path.join(site, args.os + ".json")
    with open(out, "w") as f:
        json.dump(manifest, f, indent=1, sort_keys=True)
    print(f"{out}: {len(manifest['files'])} files" + (f", binary {binary}" if binary else ""))


if __name__ == "__main__":
    main()
