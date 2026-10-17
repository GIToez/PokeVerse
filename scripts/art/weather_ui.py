#!/usr/bin/env python3
"""Draws the weather artwork (game_weather): one icon per weather and one per season.

    scripts/art/weather_ui.py [out dir]

The output goes to core/client-redemption/pokeverse-modern/modules/game_weather/images:
weather_<kind>.png (18x18, the badge beside the clock), weather_<kind>_small.png (12x12, the moves bar)
and season_<season>.png (14x14, the calendar). Kinds: clear, sunny, rain, thunderstorm, fog, windy,
snow, hail, sandstorm. Seasons: spring, summer, autumn, winter.
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'core/client-redemption/pokeverse-modern/modules/game_weather/images'
K = 16  # drawn at K times, then shrunk
U = 18  # the drawing grid

SUN = (255, 200, 60, 255)
SUN_EDGE = (220, 120, 30, 255)
CLOUD = (232, 238, 248, 255)
CLOUD_EDGE = (120, 134, 160, 255)
CLOUD_DARK = (120, 128, 150, 255)
CLOUD_DARK_EDGE = (60, 66, 86, 255)
RAIN = (90, 170, 255, 255)
BOLT = (255, 226, 70, 255)
BOLT_EDGE = (190, 120, 20, 255)
SNOW = (236, 246, 255, 255)
SNOW_EDGE = (110, 160, 210, 255)
ICE = (170, 220, 255, 255)
SAND = (226, 182, 108, 255)
SAND_DARK = (170, 120, 60, 255)
WIND = (200, 228, 240, 255)
WIND_EDGE = (80, 120, 150, 255)
FOG = (200, 206, 216, 255)
FOG_EDGE = (110, 116, 130, 255)


def canvas():
    im = Image.new('RGBA', (U * K, U * K), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def q(points):
    return [(x * K, y * K) for x, y in points]


def sun(d, cx, cy, r, rays=True):
    if rays:
        for i in range(8):
            a = i * math.pi / 4
            x0, y0 = cx + math.cos(a) * (r + 1.2), cy + math.sin(a) * (r + 1.2)
            x1, y1 = cx + math.cos(a) * (r + 3.0), cy + math.sin(a) * (r + 3.0)
            d.line(q([(x0, y0), (x1, y1)]), fill=SUN_EDGE, width=int(2.0 * K))
            d.line(q([(x0, y0), (x1, y1)]), fill=SUN, width=int(1.1 * K))
    d.ellipse(q([(cx - r - 0.7, cy - r - 0.7), (cx + r + 0.7, cy + r + 0.7)]), fill=SUN_EDGE)
    d.ellipse(q([(cx - r, cy - r), (cx + r, cy + r)]), fill=SUN)
    d.ellipse(q([(cx - r * 0.5, cy - r * 0.6), (cx - r * 0.05, cy - r * 0.15)]), fill=(255, 240, 170, 255))


def cloud(d, top, fill=CLOUD, edge=CLOUD_EDGE, dy=0.0):
    """A cloud across the icon; top is the y of its bottom edge"""
    parts = [(4.2, top - 3.0, 2.8), (8.2, top - 4.8, 3.7), (12.4, top - 3.6, 3.0), (14.8, top - 2.2, 2.0)]
    for grow, color in ((0.8, edge), (0.0, fill)):
        for x, y, r in parts:
            d.ellipse(q([(x - r - grow, y + dy - r - grow), (x + r + grow, y + dy + r + grow)]), fill=color)
        d.rounded_rectangle(q([(1.6 - grow, top - 3.4 - grow), (16.6 + grow, top + grow)]), radius=1.8 * K, fill=color)


def drops(d, y, color, count=3, length=3.6):
    for i in range(count):
        x = 4.8 + i * 4.4
        dy = y + (i % 2) * 1.4
        d.line(q([(x + 1.0, dy), (x - 0.6, dy + length)]), fill=(30, 80, 170, 255), width=int(2.2 * K))
        d.line(q([(x + 1.0, dy), (x - 0.6, dy + length)]), fill=color, width=int(1.3 * K))


def flake(d, cx, cy, r, color=SNOW, edge=SNOW_EDGE):
    for grow, c, w in ((0.5, edge, 1.5), (0.0, color, 0.8)):
        for i in range(3):
            a = i * math.pi / 3
            d.line(q([(cx - math.cos(a) * (r + grow), cy - math.sin(a) * (r + grow)),
                      (cx + math.cos(a) * (r + grow), cy + math.sin(a) * (r + grow))]), fill=c, width=int(w * K))


def clear():
    im, d = canvas()
    # a crescent moon behind a small sun: clear by day and by night
    d.ellipse(q([(1.5, 1.5), (11.5, 11.5)]), fill=(150, 170, 220, 255))
    d.ellipse(q([(2.3, 2.3), (10.7, 10.7)]), fill=(232, 236, 255, 255))
    d.ellipse(q([(4.8, 0.6), (13.6, 9.4)]), fill=(0, 0, 0, 0))
    sun(d, 11.5, 11.5, 3.6)
    return im


def sunny():
    im, d = canvas()
    sun(d, 9, 9, 4.6)
    return im


def rain():
    im, d = canvas()
    cloud(d, 9.5)
    drops(d, 11.4, RAIN)
    return im


def thunderstorm():
    im, d = canvas()
    cloud(d, 9.0, CLOUD_DARK, CLOUD_DARK_EDGE)
    drops(d, 11.0, RAIN, count=1)
    bolt = [(10.4, 7.0), (6.8, 12.4), (9.4, 12.4), (7.8, 17.4), (13.2, 10.6), (10.4, 10.6), (12.4, 7.0)]
    d.polygon(q(bolt), fill=BOLT_EDGE)
    d.polygon(q([(x + (0.3 if x < 9 else -0.3), y + (0.3 if y < 12 else -0.2)) for x, y in bolt]), fill=BOLT)
    return im


def fog():
    im, d = canvas()
    cloud(d, 8.5, FOG, FOG_EDGE)
    for i, (x0, x1) in enumerate(((2.0, 14.0), (4.0, 16.0), (1.5, 12.5))):
        y = 11.0 + i * 2.6
        d.line(q([(x0, y), (x1, y)]), fill=FOG_EDGE, width=int(2.0 * K))
        d.line(q([(x0, y), (x1, y)]), fill=FOG, width=int(1.1 * K))
    return im


def gust(d, y, x1, curl):
    path = [(1.5, y), (x1, y)]
    for grow, color, w in ((0.0, WIND_EDGE, 2.2), (0.0, WIND, 1.2)):
        d.line(q(path), fill=color, width=int(w * K))
        r = curl
        d.arc(q([(x1 - r, y - 2 * r), (x1 + r, y)]), start=-90, end=90, fill=color, width=int(w * K))


def windy():
    im, d = canvas()
    gust(d, 6.0, 12.0, 2.2)
    gust(d, 10.5, 14.0, 1.8)
    gust(d, 15.0, 9.5, 1.6)
    return im


def snow():
    im, d = canvas()
    cloud(d, 8.8)
    flake(d, 4.8, 13.2, 2.4)
    flake(d, 13.0, 13.6, 2.4)
    flake(d, 9.0, 15.6, 1.8)
    return im


def hail():
    im, d = canvas()
    cloud(d, 8.8, CLOUD_DARK, CLOUD_DARK_EDGE)
    for x, y in ((4.4, 12.6), (9.0, 14.6), (13.4, 12.8), (6.8, 16.4), (11.6, 16.6)):
        d.ellipse(q([(x - 1.5, y - 1.5), (x + 1.5, y + 1.5)]), fill=SNOW_EDGE)
        d.ellipse(q([(x - 1.0, y - 1.0), (x + 1.0, y + 1.0)]), fill=ICE)
    return im


def sandstorm():
    im, d = canvas()
    # a dust devil: swirls narrowing to the ground, and blown grains
    for i, (cx, w) in enumerate(((9.6, 6.6), (9.0, 5.2), (8.6, 3.8), (8.4, 2.5), (8.6, 1.4))):
        y = 3.2 + i * 3.0
        box = q([(cx - w, y - 1.4), (cx + w, y + 1.4)])
        d.arc(box, start=0, end=360, fill=SAND_DARK, width=int(2.0 * K))
        d.arc(box, start=0, end=360, fill=SAND, width=int(1.1 * K))
    for x, y in ((2.2, 6.0), (16.0, 9.0), (3.6, 12.6), (14.4, 15.0), (1.8, 16.0)):
        d.ellipse(q([(x - 0.7, y - 0.7), (x + 0.7, y + 0.7)]), fill=SAND_DARK)
    return im


def season_spring():
    im, d = canvas()
    for i in range(5):
        a = -math.pi / 2 + i * 2 * math.pi / 5
        x, y = 9 + math.cos(a) * 4.2, 9 + math.sin(a) * 4.2
        d.ellipse(q([(x - 3.6, y - 3.6), (x + 3.6, y + 3.6)]), fill=(200, 90, 140, 255))
        d.ellipse(q([(x - 2.9, y - 2.9), (x + 2.9, y + 2.9)]), fill=(255, 170, 205, 255))
    d.ellipse(q([(6.6, 6.6), (11.4, 11.4)]), fill=(230, 160, 40, 255))
    d.ellipse(q([(7.4, 7.4), (10.6, 10.6)]), fill=(255, 220, 80, 255))
    return im


def season_summer():
    return sunny()


def season_autumn():
    im, d = canvas()
    leaf = [(9, 1.5), (12, 5), (16, 5.5), (13.5, 9), (15.5, 12.5), (11, 12), (9, 15), (7, 12), (2.5, 12.5),
            (4.5, 9), (2, 5.5), (6, 5)]
    d.polygon(q(leaf), fill=(150, 60, 20, 255))
    d.polygon(q([(9 + (x - 9) * 0.82, 8 + (y - 8) * 0.82) for x, y in leaf]), fill=(236, 120, 40, 255))
    d.line(q([(9, 4), (9, 17)]), fill=(150, 60, 20, 255), width=int(1.2 * K))
    return im


def season_winter():
    im, d = canvas()
    flake(d, 9, 9, 6.6)
    for i in range(6):
        a = i * math.pi / 3
        x, y = 9 + math.cos(a) * 4.2, 9 + math.sin(a) * 4.2
        for side in (-1, 1):
            b = a + side * 0.9
            d.line(q([(x, y), (x + math.cos(b) * 1.8, y + math.sin(b) * 1.8)]), fill=SNOW, width=int(0.8 * K))
    return im


KINDS = {'clear': clear, 'sunny': sunny, 'rain': rain, 'thunderstorm': thunderstorm, 'fog': fog, 'windy': windy,
         'snow': snow, 'hail': hail, 'sandstorm': sandstorm}
SEASONS = {'spring': season_spring, 'summer': season_summer, 'autumn': season_autumn, 'winter': season_winter}


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else OUT
    out.mkdir(parents=True, exist_ok=True)
    for name, draw in KINDS.items():
        im = draw()
        im.resize((18, 18), Image.LANCZOS).save(out / f'weather_{name}.png')
        im.resize((12, 12), Image.LANCZOS).save(out / f'weather_{name}_small.png')
    for name, draw in SEASONS.items():
        draw().resize((14, 14), Image.LANCZOS).save(out / f'season_{name}.png')
    print(out)


if __name__ == '__main__':
    main()
