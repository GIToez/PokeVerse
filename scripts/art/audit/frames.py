import hashlib, os
import numpy as np
from PIL import Image

PADV_ROOT = os.environ.get('PADV', '/tmp/padv/')
PADV = PADV_ROOT + 'sprites/creature/'
PACK = os.environ.get('PACK6500', '/tmp/sprites6500/6500 sprite pokemon/')


def padv_frame(sid, g, direction=2, addon=0, phase=0):
    img = Image.open(PADV + '%d.png' % sid).convert('RGBA')
    W, H = g['w'] * 32, g['h'] * 32
    row = addon * g['px'] + direction
    if (row + 1) * H > img.height:
        row = min(direction, img.height // H - 1)
    return img.crop((phase * W, row * H, phase * W + W, row * H + H))


def pack_frame(n, c, layers, direction=2, frame=0):
    img = Image.open(PACK + 'outfit_%d_.png' % n).convert('RGBA')
    x = direction * layers * c
    return img.crop((x, frame * c, x + c, frame * c + c))


def silhouette(im):
    a = np.array(im)[..., 3] >= 128
    if not a.any():
        return None
    ys, xs = np.where(a)
    a = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    return hashlib.md5(a.tobytes() + bytes(a.shape)).hexdigest()


def on_bg(im, size, bg=(58, 84, 58, 255)):
    bb = im.getbbox()
    out = Image.new('RGBA', (size, size), bg)
    if not bb:
        return out
    im = im.crop(bb)
    scale = max(1, min(size // max(im.width, im.height), 2))
    if max(im.width, im.height) * scale > size:
        im.thumbnail((size, size), Image.NEAREST)
    else:
        im = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
    out.alpha_composite(im, ((size - im.width) // 2, size - im.height - 2))
    return out
