#!/usr/bin/env python3
"""Copies the approved dev map to the server, after checking it.

    scripts/mapper/publish.py [--dry-run]

mapper/map/dev.otbm -> core/server/data/world/map.otbm, with map-spawn.xml and
map-house.xml. Nothing is copied if scripts/mapper/verify.py finds a problem.
"""
import argparse
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
SRC = os.path.join(ROOT, 'mapper', 'map')
DST = os.path.join(ROOT, 'core', 'server', 'data', 'world')
FILES = (('dev.otbm', 'map.otbm'), ('map-spawn.xml', 'map-spawn.xml'), ('map-house.xml', 'map-house.xml'))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dry-run', action='store_true')
    args = ap.parse_args()
    if subprocess.call([sys.executable, os.path.join(HERE, 'verify.py'), os.path.join(SRC, 'dev.otbm')]) != 0:
        sys.exit('verify failed, nothing copied')
    for src, dst in FILES:
        print('%s -> %s' % (os.path.join('mapper', 'map', src), os.path.relpath(os.path.join(DST, dst), ROOT)))
        if not args.dry_run:
            shutil.copyfile(os.path.join(SRC, src), os.path.join(DST, dst))


if __name__ == '__main__':
    main()
