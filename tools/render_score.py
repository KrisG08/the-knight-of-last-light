"""Author the original Last Light score; no downloaded samples or runtime synthesis.

Run with Python 3, then encode the WAV masters with FFmpeg/libvorbis.
All voices and musical events are deterministic; wrapped tails make loop seams quiet.
"""
import array
import math
import os
import random
import wave

RATE = 44100
TAU = math.tau
OUT = ".tools/music-masters"
os.makedirs(OUT, exist_ok=True)


def render(name, bpm, intensity, warm=False):
    beat = 60.0 / bpm
    duration = beat * 32
    size = round(duration * RATE)
    mix = array.array("f", [0.0]) * size
    rng = random.Random(580)

    def note(midi, at, length, gain, voice="pad"):
        freq = 440 * 2 ** ((midi - 69) / 12)
        count = round(length * RATE)
        start = round(at * RATE)
        for i in range(count):
            t = i / RATE
            phase = TAU * freq * t
            if voice == "pad":
                env = min(1, t / .65) * min(1, (length - t) / 1.1)
                value = (math.sin(phase) + .23 * math.sin(phase * 2 + .2)
                         + .12 * math.sin(phase * 1.002)) * env
            elif voice == "bell":
                env = min(1, t / .012) * math.exp(-t * 1.8) * min(1, (length - t) / .15)
                value = (math.sin(phase) + .17 * math.sin(phase * 2.01)) * env
            else:
                env = min(1, t / .025) * math.exp(-t * 3.8) * min(1, (length - t) / .1)
                value = (math.sin(phase) + .24 * math.sin(phase * 2)) * env
            mix[(start + i) % size] += value * gain

    # Eight bars: Em, C, Am, Bm, then a related second phrase.
    chords = [[40, 47, 55], [36, 43, 52], [33, 45, 52], [35, 42, 50],
              [40, 47, 55], [36, 43, 52], [38, 45, 54], [35, 42, 50]]
    if warm:
        chords = [[36, 43, 52], [43, 50, 59], [38, 45, 54], [40, 47, 55]] * 2
    melody = [76, 74, 71, 67, 69, 71, 66, 71]
    for bar, chord in enumerate(chords):
        at = bar * 4 * beat
        for pitch in chord:
            note(pitch, at, 4 * beat + 1.3, .045, "pad")
        note(melody[bar] - (12 if name == "exploration" else 0),
             at + beat, 3 * beat, .065 if intensity == 0 else .045, "bell")
        if intensity:
            for step in range(8):
                note(chord[step % 3] + 12, at + step * beat / 2, beat * .8,
                     .045 if intensity == 1 else .06, "pluck")
            for hit in ([0, 2] if intensity == 1 else [0, 1.5, 2, 3]):
                start = round((at + hit * beat) * RATE)
                for i in range(round(.45 * RATE)):
                    t = i / RATE
                    env = min(1, t / .006) * math.exp(-t * 12)
                    drum = math.sin(TAU * (52 * t + 5 * (1 - math.exp(-t * 18))))
                    noise = rng.uniform(-1, 1) * math.exp(-t * 60)
                    mix[(start + i) % size] += (drum + .13 * noise) * env * .13
    # Circular early reflections / stereo width, same state at every wrap.
    delays = [(round(RATE * .19), .21), (round(RATE * .37), .13), (round(RATE * .61), .08)]
    peak = 0
    stereo = array.array("f")
    for i in range(size):
        dry = mix[i]
        left = dry + sum(mix[(i - d) % size] * g for d, g in delays)
        right = dry + sum(mix[(i - d - 313) % size] * g for d, g in delays)
        stereo.extend((left, right))
        peak = max(peak, abs(left), abs(right))
    gain = .68 / max(peak, .001)
    pcm = array.array("h", (round(v * gain * 32767) for v in stereo))
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm.tobytes())
    print(name, "seconds", round(duration, 3), "peak", round(peak * gain, 3), flush=True)


for args in [("menu", 60, 0), ("exploration", 54, 0),
             ("combat", 84, 1), ("boss", 96, 2), ("dawn", 60, 0, True)]:
    render(*args)
