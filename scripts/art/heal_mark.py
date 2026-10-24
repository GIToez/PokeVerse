"""The heal mark (game_healmark): a green cross in a round badge, the size of the NPC badges (14x14).
Run from the repository root:

    python3 scripts/art/heal_mark.py
"""
import os

from PIL import Image, ImageDraw

OUT = 'core/client-redemption/pokeverse-modern/modules/game_healmark/images'
SIZE = 14
S = 8  # drawn this many times larger, then scaled down

GREEN = (88, 214, 110, 255)
DARK = (22, 70, 36, 255)
WHITE = (255, 255, 255, 255)


def main():
    big = SIZE * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((S * 0.5, S * 0.5, big - S * 0.5, big - S * 0.5), fill=DARK)
    d.ellipse((S * 1.5, S * 1.5, big - S * 1.5, big - S * 1.5), fill=GREEN)
    arm, half = S * 1.3, big / 2
    reach = S * 4.2
    d.rectangle((half - arm, half - reach, half + arm, half + reach), fill=WHITE)
    d.rectangle((half - reach, half - arm, half + reach, half + arm), fill=WHITE)
    os.makedirs(OUT, exist_ok=True)
    img.resize((SIZE, SIZE), Image.LANCZOS).save(os.path.join(OUT, 'heal_mark.png'))
    img.resize((SIZE * 8, SIZE * 8), Image.NEAREST).save('/tmp/heal_mark_preview.png')


if __name__ == '__main__':
    main()
