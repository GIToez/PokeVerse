"""Index of our outfits: per look, size, layers, addons, mounts, the tile keys of the base layer and
its south-facing standing frame; plus what each look is (trainer outfit, Pokemon, Pokemon addon)."""
import glob, hashlib, json, os, pickle, re, sys
import numpy as np
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../..'))
sys.path.insert(0, ROOT + '/scripts/art')
import new_pokemon_art_preview as P
P.THINGS = os.path.join(ROOT, 'core/client-legacy/data/things')
Things = P.Things
S = ROOT + '/core/server/data/'


def key(a):
    a = a.copy()
    a[a[..., 3] < 128] = 0
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    if not a[..., 3].any():
        return None
    return hashlib.md5(a.tobytes()).hexdigest()


def labels():
    lab = {}
    for f in glob.glob(S + 'monster/**/*.xml', recursive=True):
        x = open(f, errors='ignore').read()
        m = re.search(r'<monster name="([^"]+)"', x)
        l = re.search(r'<look type="(\d+)"', x)
        if m and l:
            cat = f.split('/monster/')[1].split('/')[0]
            lab.setdefault(int(l.group(1)), []).append(('pokemon' if cat in ('Pokemons', 'Shiny', '_Shiny') else 'npc', m.group(1)))
    x = open(S + 'XML/outfits.xml', errors='ignore').read()
    for m in re.finditer(r'<outfit id="(\d+)"[^>]*>(.*?)</outfit>', x, re.S):
        for look, name in re.findall(r'lookType="(\d+)"[^>]*name="([^"]*)"', m.group(2)):
            lab.setdefault(int(look), []).append(('trainer', name))
    src = open(S + 'lib/ps/systems/038-pokemonAddon.lua', errors='ignore').read()
    for poke, look in re.findall(r'\["([^"]+)"\]\s*=\s*\{\s*lookType\s*=\s*(\d+)', src):
        lab.setdefault(int(look), []).append(('pokeaddon', poke))
    return lab


def main():
    t = Things()
    out = {}
    for i, th in enumerate(t.outfits):
        look = i + 1
        w, h, layers, px, py, pz, phases, sprites = th
        keys = set()
        n = w * h
        # base layer of every frame/pattern
        for idx in range(0, len(sprites), n * layers):
            for j in range(n):
                sid = sprites[idx + j]
                if sid:
                    rgba = t.spr.rgba(sid)
                    if rgba:
                        k = key(np.frombuffer(rgba, np.uint8).reshape(32, 32, 4))
                        if k:
                            keys.add(k)
        t.spr.cache.clear()
        out[look] = dict(w=w, h=h, layers=layers, px=px, py=py, pz=pz, phases=phases, keys=keys)
    pickle.dump((out, labels()), open('ours.pkl', 'wb'))
    print(len(out))


if __name__ == '__main__':
    main()
