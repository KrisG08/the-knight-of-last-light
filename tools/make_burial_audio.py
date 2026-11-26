"""Original deterministic PCM ambience; no external samples or dependencies."""
import math
import random
import struct
import wave
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "assets/audio/burial"
OUT.mkdir(parents=True, exist_ok=True)
RATE = 22050


def write(name, values):
    with wave.open(str(OUT / name), "wb") as stream:
        stream.setnchannels(1)
        stream.setsampwidth(2)
        stream.setframerate(RATE)
        stream.writeframes(b"".join(struct.pack("<h", round(max(-1, min(1, v)) * 32767)) for v in values))


rng = random.Random(4851)
duration = 12
air = []
filtered = 0
for i in range(RATE * duration):
    t = i / RATE
    filtered = filtered * 0.985 + rng.uniform(-1, 1) * 0.015
    fade = min(1, t / 0.7, (duration - t) / 0.7)
    breath = 0.65 + 0.2 * math.sin(math.tau * t / 6)
    air.append(fade * (filtered * 1.4 * breath + 0.025 * math.sin(math.tau * 46 * t)))
write("chamber_air.wav", air)

for index, frequency in enumerate((930, 1260, 1710)):
    values = []
    for i in range(int(RATE * 0.9)):
        t = i / RATE
        strike = (1 - math.exp(-t * 500)) * math.exp(-t * 19)
        reflection = max(0, t - 0.13)
        tail = math.sin(math.tau * frequency * reflection) * math.exp(-reflection * 9) * 0.04 if t > 0.13 else 0
        values.append(strike * math.sin(math.tau * (frequency * t + 18 * (1 - math.exp(-t * 45)))) * 0.4 + tail)
    write(f"drip_{index}.wav", values)

# All frequencies/modulation complete integer cycles over the three-second loop.
write("seal_resonance.wav", [
    (math.sin(math.tau * 65 * i / RATE) * 0.08 + math.sin(math.tau * 98 * i / RATE) * 0.035)
    * (0.8 + 0.2 * math.cos(math.tau * i / (RATE * 3)))
    for i in range(RATE * 3)
])
print("Generated five original burial PCM assets")
