"""Derive CC0 footsteps and original layered weapon effects, using local FFmpeg."""
import math
import random
import struct
import subprocess
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FFMPEG = next((ROOT / '.tools/video-encoder/imageio_ffmpeg/binaries').glob('ffmpeg*.exe'))
OUT = ROOT / 'assets/audio/combat'
OUT.mkdir(parents=True, exist_ok=True)
RATE = 22050


def write(name, values, peak=0.6):
    maximum = max(abs(v) for v in values) or 1
    values = [v * peak / maximum for v in values]
    with wave.open(str(OUT / name), 'wb') as stream:
        stream.setnchannels(1)
        stream.setsampwidth(2)
        stream.setframerate(RATE)
        stream.writeframes(b''.join(struct.pack('<h', round(v * 32767)) for v in values))


source = ROOT / 'assets/vendor/kenney_fps_audio/walking.ogg'
decoded = ROOT / '.tools/kenney-walking.wav'
subprocess.run([str(FFMPEG), '-hide_banner', '-loglevel', 'error', '-y', '-i', str(source), '-ac', '1', '-ar', str(RATE), str(decoded)], check=True)
with wave.open(str(decoded)) as stream:
    data = struct.unpack('<' + 'h' * stream.getnframes(), stream.readframes(stream.getnframes()))
for index, start in enumerate((0, 0.35, 0.72, 1.18)):
    segment = data[int(start * RATE):int((start + 0.32) * RATE)]
    values = [v / 32768 * min(1, i / 60, (len(segment) - i) / 350) for i, v in enumerate(segment)]
    write(f'step_{index}.wav', values, 0.45)

for variant in range(3):
    rng = random.Random(903 + variant)
    for kind, duration in [('swing', 0.31), ('hit', 0.33), ('block', 0.55), ('windup', 0.24)]:
        values = []
        low = 0
        for i in range(int(RATE * duration)):
            t = i / RATE
            noise = rng.uniform(-1, 1)
            low = low * 0.82 + noise * 0.18
            if kind == 'swing':
                envelope = math.sin(math.pi * t / duration) ** 1.5
                value = low * envelope + noise * envelope * 0.11
            elif kind == 'hit':
                value = low * math.exp(-t * 30) + math.sin(math.tau * (82 + variant * 9) * t) * math.exp(-t * 22) * 0.55
                value += noise * math.exp(-t * 75) * 0.25
            elif kind == 'block':
                value = noise * math.exp(-t * 80) * 0.4
                for frequency, decay in [(710, 12), (1133, 16), (1831, 20), (2377, 26)]:
                    value += math.sin(math.tau * (frequency + variant * 23) * t) * math.exp(-t * decay) * 0.15
            else:
                value = low * math.sin(math.pi * t / duration) ** 2
            value *= min(1, i / 30, (RATE * duration - i) / 150)
            values.append(value)
        write(f'{kind}_{variant}.wav', values)
print('Derived four CC0 footfalls and twelve original weapon cues')
