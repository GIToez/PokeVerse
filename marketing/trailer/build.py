#!/usr/bin/env python3
"""Cuts the PokeVerse trailer from the lossless 4K clips: captions, title and end cards, the chiptune."""
import subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

CLIPS = Path("/tmp/itch4k/clips")
WORK = Path("/tmp/trailer/work")
OUT = Path("/opt/cursor/artifacts/trailer")
LOGO = "/workspace/scripts/art/login-logo.png"
PIXEL = "/workspace/core/client-redemption/pokeverse-modern/data/fonts/ttf/pixelify-sans.ttf"
SANS = "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf"
W, H, FPS = 3840, 2160, 30
YELLOW, NAVY = (255, 203, 5), (16, 24, 32)
URL = "pokeverse.quest"

WORK.mkdir(parents=True, exist_ok=True)
OUT.mkdir(parents=True, exist_ok=True)


def run(args):
    subprocess.run(args, check=True)


def font(path, size):
    return ImageFont.truetype(path, size)


def centered(draw, y, text, f, fill, stroke=0):
    box = draw.textbbox((0, 0), text, font=f, stroke_width=stroke)
    draw.text(((W - (box[2] - box[0])) // 2 - box[0], y), text, font=f, fill=fill, stroke_width=stroke,
              stroke_fill=NAVY)


def logo(width):
    im = Image.open(LOGO).convert("RGBA")
    return im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)


def caption(name, title, sub):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    ft, fs = font(PIXEL, 120), font(SANS, 56)
    tb, sb = d.textbbox((0, 0), title, font=ft), d.textbbox((0, 0), sub, font=fs)
    w = max(tb[2], sb[2]) + 120
    x, y = 200, 1500
    d.rounded_rectangle((x, y, x + w, y + 300), 28, fill=(10, 16, 24, 205), outline=(*YELLOW, 255), width=5)
    d.text((x + 60, y + 30 - tb[1]), title, font=ft, fill=YELLOW)
    d.text((x + 60, y + 190 - sb[1]), sub, font=fs, fill=(240, 244, 250))
    path = WORK / f"cap_{name}.png"
    im.save(path)
    return path


def frame(clip, at, path):
    run(["ffmpeg", "-v", "error", "-y", "-ss", str(at), "-i", str(CLIPS / f"{clip}.mkv"), "-frames:v", "1", str(path)])
    return Image.open(path).convert("RGB")


def card(name, background, lines):
    bg = background.filter(ImageFilter.GaussianBlur(28))
    bg = Image.blend(bg, Image.new("RGB", (W, H), NAVY), 0.62)
    d = ImageDraw.Draw(bg)
    for kind, value, y in lines:
        if kind == "logo":
            lg = logo(value)
            bg.paste(lg, ((W - lg.width) // 2, y), lg)
        else:
            text, size, fill, path = value
            centered(d, y, text, font(path, size), fill, stroke=6 if path == PIXEL else 0)
    path = WORK / f"card_{name}.png"
    bg.save(path)
    return path


def segment(name, clip, start, dur, cap=None, fade_in=False, fade_out=False):
    out = WORK / f"seg_{name}.mp4"
    inputs = ["-ss", str(start), "-t", str(dur), "-i", str(CLIPS / f"{clip}.mkv")]
    chain = "[0:v]fps=30,format=yuv444p"
    if fade_in:
        chain += ",fade=in:st=0:d=0.35"
    if fade_out:
        chain += f",fade=out:st={dur - 0.35}:d=0.35"
    chain += "[v]"
    if cap:
        inputs += ["-loop", "1", "-t", str(dur), "-i", str(cap)]
        chain += (f";[1:v]format=rgba,fade=in:st=0.35:d=0.4:alpha=1,fade=out:st={dur - 0.8}:d=0.45:alpha=1[c]"
                  ";[v][c]overlay=0:0[v]")
    encode(inputs, chain, out)
    return out


def still(name, image, dur, fade_in=0.4, fade_out=0.4):
    out = WORK / f"seg_{name}.mp4"
    chain = (f"[0:v]fps=30,format=yuv444p,fade=in:st=0:d={fade_in},fade=out:st={dur - fade_out}:d={fade_out},"
             f"zoompan=z='1+0.00025*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s={W}x{H}:fps=30[v]")
    encode(["-loop", "1", "-t", str(dur), "-i", str(image)], chain, out)
    return out


def encode(inputs, chain, out):
    run(["ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", chain, "-map", "[v]", "-r", str(FPS),
         "-c:v", "libx264", "-preset", "medium", "-crf", "12", "-pix_fmt", "yuv420p", "-an", str(out)])


segments = []
segments.append(segment("01", "t01_mega", 0.5, 6.0,
                        caption("mega", "Mega Evolution", "Mega Evolve your partner in the middle of a fight"),
                        fade_in=True))
segments.append(segment("02", "t02_fight", 1.9, 6.0,
                        caption("fight", "Real-time battles", "Every move is a hotkey away")))
fight_end = frame("t02_fight", 7.5, WORK / "fight_end.png")
segments.append(still("03", card("title", fight_end, [
    ("logo", 1700, 560),
    ("text", ("A Pokemon MMO", 120, (255, 255, 255), PIXEL), 1330),
    ("text", (URL, 84, YELLOW, SANS), 1560),
]), 2.0, 0.25, 0.25))
segments.append(segment("04", "t03_zapdos", 1.0, 6.0,
                        caption("zapdos", "Wild legendaries", "They roam the world, and every sighting is announced")))
segments.append(segment("04b", "t03b_catch", 3.0, 9.0,
                        caption("catch", "Catch them all", "Knock out a wild Pokemon, then throw a Poke Ball")))
segments.append(segment("05", "t04_storm", 0.3, 6.0,
                        caption("storm", "Live weather", "Storms roll in across the routes")))
segments.append(segment("06", "t06_cave", 0.6, 6.0,
                        caption("cave", "Dark caves", "Your light only reaches so far")))
segments.append(segment("07", "t07_halloween", 0.3, 7.0,
                        caption("halloween", "Seasonal events", "Halloween in the Union Room, and more all year")))
ui = caption("ui", "Quest log, Pokepedia and more", "World map, Trainer Card and vocations")
segments.append(segment("08", "t08_ui", 2.0, 4.0, ui))
segments.append(segment("09", "t08_ui", 8.2, 6.0, ui))
# a quick reprise on the beat before the end card
segments.append(segment("10", "t01_mega", 2.6, 1.0))
segments.append(segment("11", "t03_zapdos", 6.0, 1.0))
segments.append(segment("12", "t02_fight", 6.3, 1.0))
segments.append(segment("12b", "t03b_catch", 6.0, 1.0))
segments.append(segment("13", "t07_halloween", 3.0, 1.0, fade_out=True))
world = frame("t03_zapdos", 4.0, WORK / "world.png")
segments.append(still("14", card("end", world, [
    ("logo", 1500, 330),
    ("text", ("Free to play", 110, (255, 255, 255), PIXEL), 1010),
    ("text", (URL, 190, YELLOW, SANS), 1260),
]), 9.0, 0.4, 1.4))

total = 0.0
listing = WORK / "list.txt"
with listing.open("w") as f:
    for s in segments:
        f.write(f"file '{s}'\n")
        total += float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                                                "-of", "csv=p=0", str(s)]).decode())
print(f"picture: {total:.2f} s")

video = WORK / "video.mp4"
run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", str(listing), "-c", "copy", str(video)])
final = OUT / "pokeverse-trailer-4k.mp4"
run(["ffmpeg", "-v", "error", "-y", "-i", str(video), "-i", "/tmp/trailer/music.wav", "-map", "0:v", "-map", "1:a",
     "-c:v", "libx264", "-preset", "slow", "-crf", "16", "-maxrate", "60M", "-bufsize", "120M",
     "-pix_fmt", "yuv420p", "-profile:v", "high", "-level", "5.2", "-c:a", "aac", "-b:a", "320k",
     "-af", f"afade=out:st={total - 1.5}:d=1.5", "-shortest", "-movflags", "+faststart", str(final)])
small = OUT / "pokeverse-trailer-1080p.mp4"
run(["ffmpeg", "-v", "error", "-y", "-i", str(final), "-vf", "scale=1920:1080:flags=lanczos", "-c:v", "libx264",
     "-preset", "slow", "-crf", "18", "-pix_fmt", "yuv420p", "-c:a", "copy", "-movflags", "+faststart", str(small)])
print(final, small)
