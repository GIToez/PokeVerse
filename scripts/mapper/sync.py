#!/usr/bin/env python3
"""Builds or refreshes the mapper/ folder: RME set up for PokeVerse plus a work copy of the map.

    scripts/mapper/sync.py             refresh RME, items, creatures and client art
    scripts/mapper/sync.py --reset-map also replace mapper/map/ with a fresh copy of the live map

mapper/map/ is never overwritten unless --reset-map is given, so hand edits in RME are safe.
"""
import argparse
import os
import re
import shutil
import xml.etree.ElementTree as ET

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
RME_SRC = os.path.join(ROOT, 'references', 'Projeto', 'RME - PSoul', 'Remeres Map Editor By Senhor')
SERVER = os.path.join(ROOT, 'core', 'server', 'data')
THINGS = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'things')
MAPPER = os.path.join(ROOT, 'mapper')
RME = os.path.join(MAPPER, 'RME')
DATA = os.path.join(RME, 'data', '854')
WORLD_FILES = ('map.otbm', 'map-spawn.xml', 'map-house.xml')
WIP_MAP = 'johto-wip.otbm'


def copy(src, dst):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copyfile(src, dst)


def copy_rme():
    for name in ('RME.exe', 'archive.dll', 'iconv.dll', 'libxml2.dll', 'zlib1.dll', 'LICENSE.rtf', 'rme_icon.ico'):
        copy(os.path.join(RME_SRC, name), os.path.join(RME, name))
    for folder in ('brushes', 'extensions'):
        dst = os.path.join(RME, folder)
        if os.path.isdir(dst):
            shutil.rmtree(dst)
        shutil.copytree(os.path.join(RME_SRC, folder), dst)
    for name in ('clients.xml', 'menubar.xml'):
        copy(os.path.join(RME_SRC, 'data', name), os.path.join(RME, 'data', name))
    for name in os.listdir(os.path.join(RME_SRC, 'data', '854')):
        copy(os.path.join(RME_SRC, 'data', '854', name), os.path.join(DATA, name))


def copy_items():
    for name in ('items.otb', 'items.xml'):
        copy(os.path.join(SERVER, 'items', name), os.path.join(DATA, name))


def look_attrs(look):
    out = {'looktype': look.get('type', '0')}
    for part in ('head', 'body', 'legs', 'feet'):
        if look.get(part, '0') != '0':
            out['look' + part] = look.get(part)
    return out


def read_xml(path):
    # Some server files are latin-1 without saying so.
    raw = open(path, 'rb').read()
    try:
        return ET.fromstring(raw)
    except ET.ParseError:
        text = raw.decode('latin-1')
        text = re.sub(r'encoding="[^"]*"', '', text, count=1)
        return ET.fromstring(text)


def creatures_xml():
    entries = {}
    index = read_xml(os.path.join(SERVER, 'monster', 'monsters.xml'))
    for m in index.iter('monster'):
        path = os.path.join(SERVER, 'monster', m.get('file'))
        if not os.path.isfile(path):
            continue
        try:
            look = read_xml(path).find('look')
        except ET.ParseError:
            continue
        if look is not None:
            entries[m.get('name').lower()] = (m.get('name'), 'monster', look_attrs(look))
    npc_dir = os.path.join(SERVER, 'npc')
    for name in sorted(os.listdir(npc_dir)):
        if not name.endswith('.xml'):
            continue
        try:
            node = read_xml(os.path.join(npc_dir, name))
        except ET.ParseError:
            continue
        look = node.find('look')
        if node.tag == 'npc' and look is not None and node.get('name'):
            entries.setdefault(node.get('name').lower(), (node.get('name'), 'npc', look_attrs(look)))
    lines = ['<?xml version="1.0" encoding="UTF-8"?>', '<creatures>']
    for key in sorted(entries):
        name, kind, attrs = entries[key]
        extra = ''.join(' %s="%s"' % (k, v) for k, v in attrs.items())
        lines.append('\t<creature name="%s" type="%s"%s/>' % (name.replace('&', '&amp;').replace('"', '&quot;'), kind, extra))
    lines.append('</creatures>')
    with open(os.path.join(DATA, 'creatures.xml'), 'w', encoding='utf-8', newline='\r\n') as f:
        f.write('\n'.join(lines) + '\n')
    return len(entries)


def copy_client():
    copy(os.path.join(THINGS, 'data.dat'), os.path.join(MAPPER, 'client', 'Tibia.dat'))
    copy(os.path.join(THINGS, 'data.spr'), os.path.join(MAPPER, 'client', 'Tibia.spr'))


def copy_map():
    world = os.path.join(SERVER, 'world')
    for name in WORLD_FILES:
        dst = WIP_MAP if name == 'map.otbm' else name
        copy(os.path.join(world, name), os.path.join(MAPPER, 'map', dst))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--reset-map', action='store_true')
    args = ap.parse_args()
    copy_rme()
    copy_items()
    n = creatures_xml()
    copy_client()
    if args.reset_map or not os.path.isfile(os.path.join(MAPPER, 'map', WIP_MAP)):
        copy_map()
        print('copied the live map to mapper/map/%s' % WIP_MAP)
    print('mapper/ ready: RME 8.54 data, server items, %d creatures, client art' % n)


if __name__ == '__main__':
    main()
