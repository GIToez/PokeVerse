#!/usr/bin/env python3
"""Convert a local Pokemon X/Y cries dump into /sounds/voice_cries/<dex>.ogg.

Overmap voice lines and the Pokedex blue RGB button play those files. The Pokedex
auto-play set in /sounds/cries/ is left alone.

This script does not download anything. Point it at a folder you already have
(khinsider album "Pokemon X & Y Cries"):

    scripts/convert-xy-voice-cries.py /path/to/xy-cries-dump
    scripts/convert-xy-voice-cries.py --dry-run /path/to/xy-cries-dump
    scripts/convert-xy-voice-cries.py --self-test

Tracks named like "001 Kanto - Bulbasaur.mp3" or "Kanto - Tornadus (Therian).flac"
map to a dex number. The first / base form for a number wins; later form extras
are skipped. Needs ffmpeg.
"""
import argparse
import os
import re
import subprocess
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NUMBERS = os.path.join(ROOT, "core/server/data/lib/ps/config/pokemonsNumbers.lua")
OUTPUT = os.path.join(ROOT, "core/client-redemption/data/sounds/voice_cries")

AUDIO_EXT = {".mp3", ".flac", ".ogg", ".wav", ".m4a"}
# khinsider page numbers match National Dex; form extras reuse a number
MAX_DEX = 721

# After folding (accents, punctuation, gender marks stripped)
ALIASES = {
    "nidoranf": 29,
    "nidoranfemale": 29,
    "nidoranm": 32,
    "nidoranmale": 32,
}


def fold(name):
    text = unicodedata.normalize("NFKD", name)
    text = "".join(c for c in text if not unicodedata.combining(c))
    text = text.replace("\u2640", "f").replace("\u2642", "m")  # ♀ ♂
    text = re.sub(r"[^a-zA-Z0-9]+", "", text)
    return text.lower()


def load_numbers():
    with open(NUMBERS, encoding="utf-8", errors="replace") as handle:
        source = handle.read()
    start = source.index("local pokemonsNumbers")
    end = source.index("}", start)
    numbers = {}
    for line in source[start:end].splitlines():
        match = re.match(r'\s*\["([^"]+)"\]\s*=\s*(\d+)', line)
        if match:
            numbers[fold(match.group(1))] = int(match.group(2))
    return numbers


def parse_track(filename):
    """Return (dex_or_none, base_name, form_or_none) from a dump filename."""
    stem, ext = os.path.splitext(os.path.basename(filename))
    if ext.lower() not in AUDIO_EXT:
        return None, None, None
    rest = stem
    number = None
    numbered = re.match(r"^(\d{1,3})(?:\.|\s+)\s*(.+)$", rest)
    if numbered:
        number = int(numbered.group(1))
        rest = numbered.group(2)
    if " - " in rest:
        species = rest.split(" - ", 1)[1].strip()
    else:
        species = rest.strip()
    form = None
    formed = re.match(r"^(.+?)\s*\((.+)\)\s*$", species)
    if formed:
        species = formed.group(1).strip()
        form = formed.group(2).strip()
    if number is not None and not 1 <= number <= MAX_DEX:
        number = None
    return number, species, form


def dex_for(number, species, names):
    if number:
        return number
    if not species:
        return None
    folded = fold(species)
    if folded in ALIASES:
        return ALIASES[folded]
    return names.get(folded)


def convert(src, dest):
    subprocess.check_call(
        [
            "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
            "-i", src,
            "-ac", "2", "-ar", "44100", "-c:a", "libvorbis", "-b:a", "64k",
            dest,
        ]
    )


def self_test():
    cases = [
        ("001 Kanto - Bulbasaur.mp3", 1, "Bulbasaur", None),
        ("25. Kanto - Pikachu.flac", 25, "Pikachu", None),
        ("Kanto - Nidoran\u2640.mp3", None, "Nidoran\u2640", None),
        ("386 Hoenn - Deoxys.ogg", 386, "Deoxys", None),
        ("386 Hoenn - Deoxys (Attack).ogg", 386, "Deoxys", "Attack"),
        ("641 Unova - Tornadus (Therian).mp3", 641, "Tornadus", "Therian"),
        ("Ho-Oh.wav", None, "Ho-Oh", None),
        ("notes.txt", None, None, None),
    ]
    failed = 0
    for name, number, species, form in cases:
        got = parse_track(name)
        want = (number, species, form)
        if got != want:
            print("FAIL parse %r: got %r want %r" % (name, got, want))
            failed += 1
    names = {"bulbasaur": 1, "pikachu": 25, "hooh": 250, "mrmime": 122, "farfetchd": 83}
    lookups = [
        ((1, "Bulbasaur"), 1),
        ((None, "Pikachu"), 25),
        ((None, "Nidoran\u2640"), 29),
        ((None, "Nidoran\u2642"), 32),
        ((None, "Ho-Oh"), 250),
        ((None, "Mr. Mime"), 122),
        ((None, "Farfetch'd"), 83),
        ((None, "Notapokemon"), None),
    ]
    for (number, species), want in lookups:
        got = dex_for(number, species, names)
        if got != want:
            print("FAIL dex %r: got %r want %r" % ((number, species), got, want))
            failed += 1
    loaded = load_numbers()
    if loaded.get(fold("Pikachu")) != 25 or loaded.get(fold("Ho-Oh")) != 250:
        print("FAIL load_numbers Pikachu/Ho-Oh")
        failed += 1
    if failed:
        print("%d failed" % failed)
        return 1
    print("ok")
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dump", nargs="?", help="folder of X/Y cry mp3/flac files")
    parser.add_argument("--dry-run", action="store_true", help="print the mapping, do not convert")
    parser.add_argument("--self-test", action="store_true", help="run parse tests and exit")
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    if not args.dump:
        parser.error("dump folder required (or use --self-test)")
    if not os.path.isdir(args.dump):
        print("not a folder: %s" % args.dump, file=sys.stderr)
        return 2

    names = load_numbers()
    os.makedirs(OUTPUT, exist_ok=True)
    claimed = {}
    converted = skipped_form = unmatched = 0
    for filename in sorted(os.listdir(args.dump), key=lambda n: n.lower()):
        src = os.path.join(args.dump, filename)
        if not os.path.isfile(src):
            continue
        number, species, form = parse_track(filename)
        dex = dex_for(number, species, names)
        if not dex:
            if species is not None:
                unmatched += 1
                print("skip unmatched: %s" % filename)
            continue
        if dex in claimed:
            skipped_form += 1
            print("skip extra form: %s (kept %s for #%d)" % (filename, claimed[dex], dex))
            continue
        dest = os.path.join(OUTPUT, "%d.ogg" % dex)
        claimed[dex] = filename
        print("%s -> %s" % (filename, os.path.relpath(dest, ROOT)))
        if not args.dry_run:
            convert(src, dest)
        converted += 1
    print("%d converted, %d extra forms skipped, %d unmatched -> %s" % (
        converted, skipped_form, unmatched, os.path.relpath(OUTPUT, ROOT)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
