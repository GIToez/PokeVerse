#!/usr/bin/env python3
"""Cuts the PokeVerse action trailer (v2) from the lossless 4K clips: every cut lands on a bar line of the
150 BPM chiptune (music2.py), gameplay is cropped in so the trainer and the moves read, captions name each system."""
import subprocess
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

CLIPS = Path("/tmp/trailer/clips2")
WORK = Path("/tmp/trailer/v2/work")
OUT = Path("/tmp/trailer/v2/out")
SHARE = Path("/opt/cursor/artifacts/trailer-v2")
MUSIC = Path("/tmp/trailer/v2/music2.wav")
LOGO = "/workspace/scripts/art/login-logo.png"
PIXEL = "/workspace/core/client-redemption/pokeverse-modern/data/fonts/ttf/pixelify-sans.ttf"
SANS = "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf"
W, H, FPS = 3840, 2160, 30
BAR = 1.6
YELLOW, NAVY = (255, 203, 5), (16, 24, 32)
URL = "pokeverse.quest"
ZOOM = 1.3

WORK.mkdir(parents=True, exist_ok=True)
OUT.mkdir(parents=True, exist_ok=True)
SHARE.mkdir(parents=True, exist_ok=True)


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
    ft, fs = font(PIXEL, 130), font(SANS, 58)
    tb, sb = d.textbbox((0, 0), title, font=ft), d.textbbox((0, 0), sub, font=fs)
    w = max(tb[2], sb[2]) + 120
    x, y = 200, 1540
    d.rounded_rectangle((x, y, x + w, y + 310), 28, fill=(10, 16, 24, 210), outline=(*YELLOW, 255), width=5)
    d.text((x + 60, y + 30 - tb[1]), title, font=ft, fill=YELLOW)
    d.text((x + 60, y + 200 - sb[1]), sub, font=fs, fill=(240, 244, 250))
    path = WORK / f"cap_{name}.png"
    im.save(path)
    return path


def frame(clip, at, path, zoom=ZOOM):
    run(["ffmpeg", "-v", "error", "-y", "-ss", str(at), "-i", str(CLIPS / f"{clip}.mkv"), "-frames:v", "1",
         "-vf", crop(zoom), "-update", "1", str(path)])
    return Image.open(path).convert("RGB")


def crop(zoom):
    if zoom == 1:
        return "null"
    return f"crop=iw/{zoom}:ih/{zoom}:(iw-iw/{zoom})/2:(ih-ih/{zoom})/2,scale={W}:{H}:flags=lanczos"


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


segments = []


def segment(clip, start, bars, cap=None, zoom=ZOOM, fade_in=False, fade_out=False, flash=False):
    dur = round(bars * BAR, 3)
    out = WORK / f"seg_{len(segments):02d}_{clip}.mp4"
    inputs = ["-ss", str(start), "-t", str(dur), "-i", str(CLIPS / f"{clip}.mkv")]
    chain = f"[0:v]fps={FPS},{crop(zoom)},format=yuv444p"
    if fade_in:
        chain += ",fade=in:st=0:d=0.3"
    if fade_out:
        chain += f",fade=out:st={dur - 0.35}:d=0.35"
    if flash:
        chain += ",fade=in:st=0:d=0.12:color=white"
    chain += "[v]"
    if cap:
        inputs += ["-loop", "1", "-t", str(dur), "-i", str(cap)]
        chain += (f";[1:v]format=rgba,fade=in:st=0.25:d=0.3:alpha=1,fade=out:st={dur - 0.55}:d=0.35:alpha=1[c]"
                  ";[v][c]overlay=0:0[v]")
    encode(inputs, chain, out, round(dur * FPS))
    segments.append(out)


def still(name, image, bars, fade_in=0.3, fade_out=0.4):
    dur = round(bars * BAR, 3)
    out = WORK / f"seg_{len(segments):02d}_{name}.mp4"
    chain = (f"[0:v]fps={FPS},format=yuv444p,fade=in:st=0:d={fade_in},fade=out:st={dur - fade_out}:d={fade_out},"
             f"zoompan=z='1+0.0003*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s={W}x{H}:fps={FPS}[v]")
    encode(["-loop", "1", "-t", str(dur), "-i", str(image)], chain, out, round(dur * FPS))
    segments.append(out)


def encode(inputs, chain, out, frames):
    if "--reuse" in sys.argv and out.exists():
        return
    run(["ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", chain, "-map", "[v]", "-r", str(FPS), "-frames:v", str(frames),
         "-c:v", "libx264", "-preset", "medium", "-crf", "12", "-pix_fmt", "yuv420p", "-an", str(out)])


# cold open (bars 0-9): Mega Evolution, the fight, a burst of what's coming, the title
segment("a_hook", 6.4, 2, caption("mega", "Mega Evolution", "Mega Evolve your partner mid-fight"), fade_in=True)
segment("a_hook", 15.8, 3, caption("fight", "Real-time battles", "Every move is a hotkey away"))
segment("b_misty", 14.0, 1, flash=True)
segment("b_surge", 16.0, 1, flash=True)
segment("a_groudon", 9.0, 1, flash=True)
still("title", card("title", frame("a_groudon", 9.5, WORK / "title_bg.png"), [
    ("logo", 1700, 560),
    ("text", ("A Pokemon MMO", 120, (255, 255, 255), PIXEL), 1330),
    ("text", (URL, 84, YELLOW, SANS), 1560),
]), 2, 0.15, 0.25)

# gyms (bars 10-21): Brock from the challenge to the badge, then Misty and Lt. Surge
segment("b_brock", 4.6, 3, caption("gyms", "Gym battles", "Take on the Kanto Gym Leaders for their badges"))
segment("b_brock", 20.0, 2)
segment("b_brock", 38.6, 3)
segment("b_misty", 15.6, 2, caption("leaders", "Misty, Lt. Surge and more", "Every leader brings their own team"))
segment("b_surge", 12.0, 2)

# legendary (bars 22-30): Groudon rises, the fight, the knockout, the catch
segment("a_groudon", 0.3, 3, caption("legend", "Wild legendaries", "They roam the world, and every sighting is announced"))
segment("a_groudon", 7.0, 2, caption("legendfight", "Legendary battles", "Bring your strongest team"))
segment("a_groudon", 17.0, 2)
segment("a_groudon", 22.4, 2, caption("catch", "Catch them", "Win the fight, then throw your ball"))

# regions (bars 31-50): fly over four regions, each with its legendary, then surf, ride and warp
segment("c_fly_kanto", 0.4, 3, caption("kanto", "Kanto", "Fly across four regions"), flash=True)
segment("c_fly_johto", 0.4, 3, caption("johto", "Johto", "Fly across four regions"))
segment("c_fly_orange", 0.4, 3, caption("orange", "Orange Islands", "Fly across four regions"))
segment("c_fly_hoenn", 0.4, 3, caption("hoenn", "Hoenn", "Fly across four regions"))
segment("c_surf", 1.6, 3, caption("surf", "Surf, ride and fly", "Your Pokemon carry you over land and sea"))
segment("d_ride", 2.4, 2)
warps = caption("warps", "Warp Styles", "Pick how you arrive and how you celebrate")
segment("c_warps", 0.3, 2, warps)
segment("c_warps", 6.6, 1, warps)

# systems and the reprise (bars 51-57)
segment("d_storm", 0.3, 2, caption("storm", "Live weather", "Storms roll in across the routes"))
ui = caption("ui", "Quest log, Pokepedia and more", "World map, Trainer Card and vocations")
segment("d_ui", 3.2, 1, ui, zoom=1.15)
segment("d_ui", 6.0, 1, ui, zoom=1.15)
segment("d_ui", 9.6, 1, ui, zoom=1.15)
for clip, at in (("a_hook", 8.6), ("b_brock", 39.6), ("a_groudon", 8.0), ("c_fly_orange", 2.6)):
    run_bars = 0.5
    segment(clip, at, run_bars, flash=True, fade_out=(clip == "c_fly_orange"))

# end card (bars 58-62)
still("end", card("end", frame("c_fly_kanto", 3.0, WORK / "end_bg.png"), [
    ("logo", 1500, 330),
    ("text", ("Free to play", 110, (255, 255, 255), PIXEL), 1010),
    ("text", (URL, 190, YELLOW, SANS), 1260),
]), 5, 0.4, 1.4)

total = 0.0
listing = WORK / "list.txt"
with listing.open("w") as f:
    for s in segments:
        f.write(f"file '{s}'\n")
        total += float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                                                "-of", "csv=p=0", str(s)]).decode())
print(f"picture: {total:.2f} s ({total / BAR:.2f} bars)")
if "--picture" in sys.argv:
    sys.exit(0)

video = WORK / "video.mp4"
run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", str(listing), "-c", "copy", str(video)])
final = OUT / "pokeverse-trailer-v2-4k.mp4"
run(["ffmpeg", "-v", "error", "-y", "-i", str(video), "-i", str(MUSIC), "-map", "0:v", "-map", "1:a",
     "-c:v", "libx264", "-preset", "slow", "-crf", "18", "-maxrate", "45M", "-bufsize", "90M",
     "-pix_fmt", "yuv420p", "-profile:v", "high", "-level", "5.2", "-c:a", "aac", "-b:a", "320k",
     "-af", f"afade=out:st={total - 1.5}:d=1.5", "-shortest", "-movflags", "+faststart", str(final)])
small = OUT / "pokeverse-trailer-v2-1080p.mp4"
run(["ffmpeg", "-v", "error", "-y", "-i", str(final), "-vf", "scale=1920:1080:flags=lanczos", "-c:v", "libx264",
     "-preset", "slow", "-crf", "18", "-pix_fmt", "yuv420p", "-c:a", "copy", "-movflags", "+faststart", str(small)])
# the artifact share takes the 1080p cut; the 4K one ships on the download branch
run(["cp", str(small), str(SHARE / small.name)])
print(final, small)
