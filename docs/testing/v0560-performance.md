# Lossless loading optimization — v0.5.60

## Measurement and diagnosis

Initial actual Windows v0.5.59 EXE workload: built-in --benchmark, High profile,
VSync / 60 FPS cap, i5-12450H / RTX 3050 Ti, 1920x1080 window and actual
2880x1620 render texture. Refuge / village combat / Gravedigger phase two,
scripted movement and attacks with replenished player/boss HP. Not a human run.
Baseline: p50 16.664 ms, p95 17.310 ms, p99 17.850 ms; worst 4255.426 ms
includes synchronous region transitions. Overall mean 52.31 FPS mixes loading
and gameplay and must not be presented as steady-state combat FPS. Engine
video-memory estimate peaked at 1174613984 bytes. Release static-memory monitor
reported zero and is not usable as total process RAM.

The first attempted external-script release test was invalid: standard Godot
export templates disable --script path overrides. It stayed at the menu and
was terminated by its own 300 s timeout. It is excluded from performance data.
Local Godot --help documents this X-only option. The corrected wrapper uses the
EXE's built-in --benchmark. Explicit -PackedEditor uses an editor executable
with exported content and must be labeled differently.

The first-use native mesh partitioner was isolated with a headless CPU microtest
(not a frame-rate test). Including knight script/source loading, one paired
sample measured knight 874.390 -> 452.640 ms, strong-knight 446.152 -> 209.487 ms,
red-fox 273.737 -> 79.357 ms. These single-run timings have filesystem/cache and
background-load variability and are not device-wide guarantees. Original
conversion remains available for regeneration and equivalence checks.

## Implementation and correctness

Three compressed Resource catalogs preserve the existing model partitions.
Runtime loads them once instead of classifying triangles, remapping every
attribute and rebaking meshes/materials during first use. No polygon, texture,
material quality, animation/controller, collision, render-profile or combat
settings are reduced. Existing original sources and CC BY 4.0 attribution remain.
Resources add about 1.45 MB before platform packaging. Manual artwork is intact.

Transition feedback now yields a process frame and explicitly draws on native
renderers before synchronous region construction. This shows the passage notice
and disables input first; it does not make scene construction asynchronous or
eliminate all loading pauses. The old region remains authoritative until the
existing staged navigation/arrival validation succeeds.

153 independent source-conversion / exact-array / material checks passed on the
final Windows PCK: part order,
surface counts, vertices, indices, normals, UVs, tangents, material class,
albedo/metal/roughness/texture and fur shader texture identity. A regression
requires that runtime parts actually come from prepared catalogs. It failed
before the fast path and passed afterward. Transition feedback likewise failed
before deferred construction and passed headless/native afterward.

Final builds, paired EXE measurements, process working-set samples, signatures
and platform parity are recorded in docs/STATUS.md and .tools/review/perf-*.

## Paired standalone EXE results

Both real release EXEs used the same isolated APPDATA, unchanged High rendering,
60 FPS/VSync, actual 2880x1620 texture and Balanced power plan. No other benchmark
engine was run concurrently. Other desktop activity and disk/shader cache state
were not controlled. The route and HP assistance are identical in both builds.

| Metric | v0.5.59 | v0.5.60 |
|---|---:|---:|
| Process callback p50 | 16.664 ms | 16.664 ms |
| p95 | 17.399 ms | 17.534 ms |
| p99 | 17.911 ms | 18.416 ms |
| Worst interval including transition | 4929.539 ms | 2116.983 ms |
| Timed route elapsed | 69.158 s | 63.749 s |
| Peak process working set | 1364.66 MiB | 1110.54 MiB |
| Peak process private bytes | 2707.06 MiB | 2426.58 MiB |
| Engine video-memory estimate | 1174613984 bytes | 1157815808 bytes |

The worst transition interval decreased about 57% in this pair; steady-state
frame pacing is similar and p95/p99 are slightly higher. This does not establish
a higher sustained FPS or a universally hitch-free experience. Mean FPS values
include loading and must not be used as a steady-state combat rate.

The first new-package total process wall time was 168.600 s versus 93.715 s for
the older package, despite the shorter timed route. That interval includes
startup/untimed setup/exit, not only rendering. A warm repeat is recorded
separately; attributing this difference to shader preparation or the model cache
without more evidence would be speculative. It is not hidden by the gameplay
statistics.

Warm repeat of v0.5.60: total process wall 133.869 s, timed route 64.419 s,
p50 16.668 / p95 17.517 / p99 18.190 ms, worst 2289.916 ms. The reduced route
stall repeated, but the untimed envelope remained longer than the older build
in this session. Startup/renderer/launch-envelope diagnosis remains open; this
increment does not claim faster application startup. Evidence: perf-warm-after*.

Catalog dependency inspection also confirms original portable source JPEG /
shader paths, with no hardcoded Windows .godot texture-cache paths. Android
continues to use its own normal texture imports. This is a packaging check,
not physical-device rendering acceptance.
Owner saves are untouched; tests use memory-only journeys and isolated APPDATA.
Power plan is read, never changed. Desktop background load is not controlled.
Physical Nothing Phone 3a thermal/FPS tests and a human campaign run remain open.
No public upload or guarantee of completely hitch-free play is claimed.
