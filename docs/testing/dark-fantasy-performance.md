# Exported art workload, 2026-11-04

Measured final build: Windows x86_64 release, Godot 4.7.2.stable.official.ed1daf0bf,
Mobile/Vulkan, NVIDIA RTX 3050 Ti Laptop and i5-12450H. Executed EXE directly with
`--position 2400,1400 -- --benchmark`, memory-only game slots and isolated APPDATA.
The scripted route is refuge 10 s, village combat 25 s, Gravedigger phase two 25 s.
It restores knight HP and forces the boss phase. This is not a human victory or a
full campaign workload. Power mode and other desktop background tasks were not
controlled. The window was offscreen; no foreground gameplay FPS guarantee.

PCK SHA-256: `5D694CF4347C819AAD7B7C712DB448E6646B13B4636A9DF227FC066655E548D4`.
EXE SHA-256: `D34D36F3BE1A6C49C56525AE86469B92E4F417DDF0B43CF00DD80C385C4B0562`.
This identifies the final mipmapped art package, not the earlier trial export.

| Measurement | Observed |
|---|---:|
| Timed route | 60.184 s / 7,172 rendered process intervals |
| Median wall interval | 8.324 ms |
| P95 / P99 interval | 9.076 / 9.869 ms |
| Worst interval, including startup | 215.901 ms |
| Village / boss worst interval | 57.478 / 28.560 ms |
| Sampled process working-set peak | 811.0 MiB |
| Engine-reported video allocation peak | 118.3 MiB |
| Peak draw calls | 1,018 |
| Peak physics / navigation monitor | 48.256 / 0.532 ms |

Logical viewport was 1280×720, requested window 1920×1080, actual render texture
2880×1620, VSync enabled and sun shadows on. Do not call this a native 1080p result.
Engine static-memory monitor returned zero in release, so it is not used as RAM
evidence. OS working set was sampled at 500 ms and may miss a short peak.

The steady intervals are encouraging on this laptop, but startup/load and isolated
combat hitches remain visible in the worst values. Further work should batch more
architectural kit pieces and profile region construction before increasing density
everywhere. The current scene targets fixed authored paths; this does not certify
the whole campaign, low-end hardware, audio quality or camera comfort.

Raw observations: data/art-workload.json and data/art-process.json. Native process
exited 0 with empty stderr. Full regression reported 441 assertions PASS; art capture
logs were clean. Independent EXE/PCK boot and manifests are recorded in STATUS.md.
