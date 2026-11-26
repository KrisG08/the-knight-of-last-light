"""Check independently decoded delivery files for clipping and loop discontinuity."""
import array
import json
import math
import wave

report = {}
for name in ["menu", "exploration", "combat", "boss", "dawn"]:
    with wave.open(".tools/music-masters/" + name + "-decoded.wav", "rb") as audio:
        samples = array.array("h", audio.readframes(audio.getnframes()))
        result = {
            "seconds": audio.getnframes() / audio.getframerate(),
            "sample_rate": audio.getframerate(), "channels": audio.getnchannels(),
            "peak": max(map(abs, samples)) / 32768,
            "rms": math.sqrt(sum(v * v for v in samples) / len(samples)) / 32768,
            "loop_step": max(abs(samples[0] - samples[-2]), abs(samples[1] - samples[-1])) / 32768,
        }
        assert .01 < result["rms"] < .5 and result["peak"] < .95
        assert result["loop_step"] < .035
        report[name] = result
with open(".tools/review/music-quality.json", "w") as output:
    json.dump(report, output, indent=2)
print(json.dumps(report, indent=2))
