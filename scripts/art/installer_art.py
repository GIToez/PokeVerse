#!/usr/bin/env python3
"""Renders the Windows installer's side picture (welcome, finish and uninstall pages).

    python3 scripts/art/installer_art.py

Writes core/client-redemption/packaging/windows/installer-side.bmp: 164 x 314, the size NSIS's
Modern UI expects, in the UI's navy and gold with the app icon and the logo.
"""
import os

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ICON = os.path.join(ROOT, "core/client-redemption/data/images/clienticon.png")
LOGO = os.path.join(ROOT, "core/client-redemption/pokeverse-modern/modules/client_background/images/logo.png")
OUT = os.path.join(ROOT, "core/client-redemption/packaging/windows/installer-side.bmp")

WIDTH, HEIGHT = 164, 314
TOP, BOTTOM = (0x1b, 0x2a, 0x4a), (0x06, 0x0a, 0x14)
GOLD = (0xd9, 0xaa, 0x3b)


def main():
    image = Image.new("RGB", (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(image)
    for y in range(HEIGHT):
        t = y / (HEIGHT - 1)
        draw.line([(0, y), (WIDTH, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(TOP, BOTTOM)))

    icon = Image.open(ICON).convert("RGBA").resize((96, 96), Image.LANCZOS)
    image.paste(icon, ((WIDTH - 96) // 2, 64), icon)

    logo = Image.open(LOGO).convert("RGBA")
    width = 144
    logo = logo.resize((width, round(logo.height * width / logo.width)), Image.LANCZOS)
    image.paste(logo, ((WIDTH - width) // 2, 180), logo)

    draw.line([(WIDTH // 2 - 22, 180 + logo.height + 8), (WIDTH // 2 + 22, 180 + logo.height + 8)], fill=GOLD, width=2)
    draw.line([(WIDTH - 1, 0), (WIDTH - 1, HEIGHT)], fill=(0x37, 0x52, 0x84))

    image.save(OUT)
    print(OUT)


if __name__ == "__main__":
    main()
