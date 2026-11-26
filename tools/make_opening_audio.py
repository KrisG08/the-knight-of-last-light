"""Original deterministic cinematic ambience; no recordings or external music."""
import math
import random
import struct
import wave
import json
from pathlib import Path

rate = 24000
root = Path(__file__).resolve().parents[1]
script = json.loads((root / '.tools/voice-build/script.json').read_text(encoding='utf-8'))
seconds = int(script['opening']['length'])
starts = script['opening']['starts']
rng = random.Random(5041)
wind = 0.0
samples = []
for index in range(rate * seconds):
    t = index / rate
    wind = wind * 0.97 + rng.uniform(-1, 1) * 0.03
    drone = sum(math.sin(2 * math.pi * note * t) * gain for note, gain in
                [(55, .09), (82.4069, .045), (110.2, .025), (130.8128, .018)])
    swell = .55 + .2 * math.sin(t * .45)
    signal = drone * swell + wind * .35
    for start in [0.7, starts[1]+0.2, starts[3]+0.2]:
        age = t - start
        if 0 < age < 5:
            signal += (math.sin(2 * math.pi * 220 * age)
                       + .35 * math.sin(2 * math.pi * 587.3 * age)) * .07 * math.exp(-age)
    age = t - (starts[2]+0.4)
    if 0 < age < 4:
        signal += (math.sin(2 * math.pi * (46 - age * 3) * age) * .2
                   + wind * .8) * math.exp(-age * 1.3)
    # Measured-rate expedition steps, then silence following the shockwave.
    if starts[1] < t < starts[2]:
        step = (t - starts[1]) % .6
        signal += math.sin(2 * math.pi * 82 * step) * .08 * math.exp(-step * 55)
    fade = min(1, t / 1.2, (seconds - t) / 1.3)
    samples.append(signal * max(0, fade))

normalization = .68 / max(abs(value) for value in samples)
output = root / '.tools/movie-render/score-v5.wav'
output.parent.mkdir(parents=True, exist_ok=True)
with wave.open(str(output), 'wb') as stream:
    stream.setparams((2, 2, rate, 0, 'NONE', 'not compressed'))
    data = bytearray()
    for value in samples:
        pcm = int(value * normalization * 32767)
        data.extend(struct.pack('<hh', pcm, pcm))
    stream.writeframes(data)
print(output)
