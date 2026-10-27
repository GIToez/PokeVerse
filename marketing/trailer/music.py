#!/usr/bin/env python3
"""An original chiptune for the PokeVerse trailer: 120 BPM, D major, sections laid out on the trailer's cuts."""
import sys
import wave
import numpy as np

SR = 44100
BPM = 120
BEAT = 60 / BPM
BAR = 4 * BEAT
LENGTH = 72.0
N = int(SR * (LENGTH + 2))
rng = np.random.default_rng(7)

left = np.zeros(N)
right = np.zeros(N)


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def env(n, attack=0.005, decay=0.08, sustain=0.6, release=0.05):
    t = np.arange(n) / SR
    e = np.full(n, sustain)
    a = int(attack * SR)
    d = int(decay * SR)
    r = int(release * SR)
    if a:
        e[:a] = np.linspace(0, 1, a)
    if d:
        e[a:a + d] = np.linspace(1, sustain, len(e[a:a + d]))
    if r and n > r:
        e[-r:] *= np.linspace(1, 0, r)
    return e


def square(freq, n, duty=0.5, vibrato=0.0):
    t = np.arange(n) / SR
    f = freq * (1 + vibrato * np.sin(2 * np.pi * 5.5 * t) * np.clip(t / 0.25, 0, 1))
    phase = np.cumsum(f) / SR
    return np.where((phase % 1.0) < duty, 1.0, -1.0)


def triangle(freq, n):
    phase = np.arange(n) * freq / SR
    return 2 * np.abs(2 * (phase % 1.0) - 1) - 1


def put(sig, start, gain=1.0, pan=0.0):
    i = int(start * SR)
    if i >= N:
        return
    sig = sig[:N - i]
    left[i:i + len(sig)] += sig * gain * (1 - max(pan, 0))
    right[i:i + len(sig)] += sig * gain * (1 + min(pan, 0))


def note(kind, n, start, dur, gain, pan=0.0, duty=0.5, vib=0.0, **e):
    count = int(dur * SR)
    if kind == "sq":
        s = square(midi(n), count, duty, vib)
    else:
        s = triangle(midi(n), count)
    put(s * env(count, **e), start, gain, pan)


def kick(start, gain=0.9):
    n = int(0.25 * SR)
    t = np.arange(n) / SR
    f = 55 + 110 * np.exp(-t * 35)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 14)
    put(s, start, gain)


def snare(start, gain=0.35):
    n = int(0.18 * SR)
    t = np.arange(n) / SR
    s = rng.uniform(-1, 1, n) * np.exp(-t * 22) + 0.4 * np.sin(2 * np.pi * 190 * t) * np.exp(-t * 30)
    put(s, start, gain)


def hat(start, gain=0.09, open_=False):
    n = int((0.12 if open_ else 0.035) * SR)
    t = np.arange(n) / SR
    s = rng.uniform(-1, 1, n)
    s = s - np.concatenate([[0], s[:-1]])
    put(s * np.exp(-t * (18 if open_ else 90)), start, gain, pan=0.25)


def crash(start, gain=0.18):
    n = int(1.6 * SR)
    t = np.arange(n) / SR
    s = rng.uniform(-1, 1, n)
    s = s - 0.6 * np.concatenate([[0], s[:-1]])
    put(s * np.exp(-t * 2.6), start, gain, pan=-0.2)


# D major: D A Bm G (I V vi IV); roots as MIDI notes
CHORDS = [(50, [62, 66, 69]), (45, [61, 64, 69]), (47, [62, 66, 71]), (43, [62, 67, 71])]
CHORDS_B = [(43, [62, 67, 71]), (45, [61, 64, 69]), (47, [62, 66, 71]), (45, [61, 64, 69])]

# the hook: two bars over D and A, two over Bm and G (eighth notes, None = rest)
HOOK = [
    [74, None, 74, 76, 78, None, 76, 74],
    [73, None, 69, None, 71, 73, 76, None],
    [74, None, 74, 76, 78, None, 81, None],
    [79, 78, 76, None, 74, None, 71, None],
]
VERSE = [
    [66, None, 69, None, 74, None, 73, 71],
    [69, None, None, 64, 66, None, 69, None],
    [71, None, 74, None, 78, None, 76, 74],
    [74, None, 71, None, 67, None, None, None],
]
FINALE = [
    [78, None, 78, 79, 81, None, 79, 78],
    [76, None, 73, None, 76, 78, 81, None],
    [83, None, 81, None, 78, None, 81, 83],
    [86, None, None, None, 83, None, 81, None],
]


def bar_drums(start, level, fill=False):
    if level <= 0:
        return
    for b in range(4):
        t = start + b * BEAT
        if level >= 1 and b in (0, 2):
            kick(t)
        if level >= 2 and b in (1, 3):
            snare(t)
        if level >= 2:
            hat(t + BEAT / 2)
        if level >= 3:
            hat(t, 0.07)
            if b == 2:
                kick(t + BEAT / 2, 0.6)
    if fill:
        for k in range(4):
            snare(start + 3 * BEAT + k * BEAT / 4, 0.25 + 0.05 * k)


def bar_bass(start, root, level):
    if level <= 0:
        return
    pattern = [0, 0, 12, 0, 0, 12, 7, 12] if level >= 2 else [0, None, None, None, 12, None, None, None]
    for i, off in enumerate(pattern):
        if off is not None:
            note("tri", root + off, start + i * BEAT / 2, BEAT / 2 * 0.95, 0.30, decay=0.05, sustain=0.8)


def bar_arp(start, chord, level, octave=12):
    if level <= 0:
        return
    tones = chord + [chord[0] + 12]
    step = BEAT / 4 if level >= 2 else BEAT / 2
    count = int(BAR / step)
    for i in range(count):
        n = tones[i % len(tones)] + octave - 12
        note("sq", n, start + i * step, step * 0.8, 0.05, pan=0.35, duty=0.125, decay=0.04, sustain=0.3)


def bar_lead(start, line, gain=0.11, octave=0):
    for i, n in enumerate(line):
        if n is None:
            continue
        length = 1
        while i + length < len(line) and line[i + length] is None and length < 3:
            length += 1
        dur = length * BEAT / 2 * 0.92
        note("sq", n + octave, start + i * BEAT / 2, dur, gain, pan=-0.15, duty=0.25, vib=0.006,
             decay=0.1, sustain=0.55, release=0.04)
        note("sq", n + octave, start + i * BEAT / 2 + 0.11, dur, gain * 0.3, pan=0.4, duty=0.25,
             decay=0.1, sustain=0.5)


def chord_pad(start, chord, dur, gain=0.03):
    for n in chord:
        note("sq", n, start, dur, gain, duty=0.5, attack=0.3, decay=0.3, sustain=0.7, release=0.5)


# sections, in bars (one bar = 2 s): the cuts land on bar lines
#  0-2   intro swell (Mega Evolution)        3-6   hook (the fight, title hit at 12 s)
#  7-14  verse (legendary, storm, night)      15-22 build (cave, Halloween)
#  23-30 finale hook (the menus)              31-35 end card and the last chord
for bar in range(36):
    t = bar * BAR
    if bar < 3:
        root, chord = CHORDS[bar % 4]
        bar_arp(t, chord, 1 + (bar >= 1))
        bar_bass(t, root, 1)
        if bar == 2:
            for k in range(8):
                snare(t + 2 * BEAT + k * BEAT / 4, 0.12 + 0.03 * k)
    elif bar < 7:
        root, chord = CHORDS[(bar - 3) % 4]
        bar_drums(t, 2, fill=(bar == 6))
        bar_bass(t, root, 2)
        bar_arp(t, chord, 2)
        bar_lead(t, HOOK[(bar - 3) % 4])
    elif bar < 15:
        root, chord = CHORDS_B[(bar - 7) % 4]
        bar_drums(t, 2 if bar < 11 else 3, fill=(bar == 14))
        bar_bass(t, root, 2)
        bar_arp(t, chord, 1 if bar < 11 else 2)
        bar_lead(t, VERSE[(bar - 7) % 4], 0.1)
    elif bar < 23:
        root, chord = CHORDS[(bar - 15) % 4]
        quiet = bar < 19
        bar_drums(t, 1 if quiet else 3, fill=(bar == 22))
        bar_bass(t, root, 1 if quiet else 2)
        bar_arp(t, chord, 2)
        chord_pad(t, chord, BAR)
        if not quiet:
            bar_lead(t, HOOK[(bar - 15) % 4], 0.09, octave=-12)
    elif bar < 31:
        root, chord = CHORDS[(bar - 23) % 4]
        bar_drums(t, 3, fill=(bar == 30))
        bar_bass(t, root, 2)
        bar_arp(t, chord, 2)
        chord_pad(t, chord, BAR, 0.025)
        bar_lead(t, FINALE[(bar - 23) % 4], 0.11)
    elif bar < 35:
        root, chord = [(50, [62, 66, 69]), (43, [62, 67, 71]), (45, [61, 64, 69]), (45, [61, 64, 69])][bar - 31]
        bar_drums(t, 2 if bar < 34 else 1)
        bar_bass(t, root, 2 if bar < 34 else 1)
        bar_arp(t, chord, 2)
        bar_lead(t, HOOK[(bar - 31) % 4] if bar < 33 else [81, None, 78, None, 76, None, 73, None], 0.1)
    else:
        kick(t)
        crash(t, 0.22)
        note("tri", 38, t, 2.0, 0.35, attack=0.01, decay=0.5, sustain=0.5, release=0.6)
        for n in [62, 66, 69, 74]:
            note("sq", n, t, 2.0, 0.05, duty=0.25, decay=0.6, sustain=0.4, release=0.8)

for hit in (0.0, 6.0, 12.0, 14.0, 30.0, 46.0, 62.0):
    crash(hit)

mix = np.stack([left, right], axis=1)[: int(SR * LENGTH)]
fade = int(SR * 1.5)
mix[-fade:] *= np.linspace(1, 0, fade)[:, None]
# gentle low-pass to take the edge off the square waves
k = 3
mix = np.apply_along_axis(lambda c: np.convolve(c, np.ones(k) / k, mode="same"), 0, mix)
mix /= np.max(np.abs(mix)) / 0.89
pcm = (mix * 32767).astype(np.int16)
with wave.open(sys.argv[1], "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print("wrote", sys.argv[1], LENGTH, "s")
