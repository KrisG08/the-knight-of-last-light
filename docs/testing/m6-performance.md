# Exported slice workload — 2026-11-04

This is an actual native Windows release run, not a headless timing claim or a human
combat victory. Raw data: `m6-performance.json`, `m6-process-memory.json`.

Build: Godot 4.7.2 standard x86_64 release, Mobile/Vulkan, shadows enabled, default
damage/tempo, VSync enabled. PCK SHA-256:
`EA82FF59DA9981E791F79094008B81A751BDBC2C998E2C00C5CBA4FC64DF6138`.
Hardware: i5-12450H, RTX 3050 Ti Laptop GPU. Windows power scheme: Balanced.
Editor closed; Codex/browser/background desktop applications remained open.

Window requested 1920×1080 borderless; engine reported 1920×1080 window coordinates
and **2880×1620 render texture**, with 1280×720 logical UI. Report the actual render
texture rather than calling this a native-1080p measurement; desktop scaling affects
the mapping. The window was placed offscreen and launched with Hidden style, so
foreground presentation/driver behavior may differ. Draw calls and the actual native
rendering device remained active. No other capture/test game was run during this pass.

Route: 10 seconds refuge movement, 25 seconds village pursuit/light attacks, 25 seconds
Gravedigger phase two. Saves/settings use memory-only review mode. Benchmark replenishes
runner HP and forces the boss's half-health phase with real damage, then replenishes boss
HP near defeat to sustain load. Those diagnostic behaviors are not exposed by normal
menus. Movement, AI, collision, attack windows, HUD and rendering still execute.

| Measurement | Observed |
|---|---:|
| Elapsed | 60.13 s |
| Wall-clock frame samples | 7,167 |
| Mean FPS | 119.20 |
| Median frame interval | 8.343 ms |
| p95 frame interval | 9.519 ms |
| p99 frame interval | 10.430 ms |
| Worst frame interval | 255.219 ms |
| Village p99 / worst | 10.737 / 59.351 ms |
| Boss phase-two p99 / worst | 10.369 / 23.021 ms |
| Observed process peak working set | 564.3 MiB |
| Observed private memory maximum (1 s samples) | 721.4 MiB |
| Engine-reported video allocation peak | 86.7 MiB |
| Peak draw calls | 150 |
| Physics monitor peak | 51.075 ms |
| Navigation monitor peak | 0.355 ms |

Frame intervals use Time.get_ticks_usec() between rendered process callbacks, not
Godot's smoothed/quantized simulation delta. The 255 ms outlier occurred in the refuge
stage, which includes initial startup/shader warmup; it was not removed. The ~120 FPS
ceiling is VSync-limited and does not establish uncapped GPU capacity. Static-memory
monitor returns zero in the release template, so it is unavailable, not zero usage.
Process memory came from Windows process sampling. Video allocation is the engine's
resource monitor, not a complete OS/driver dedicated-VRAM accounting.

Reproduce: run the exported executable with `-- --benchmark` from a PowerShell process
that waits for GUI exit. Benchmark JSON is written to `user://benchmarks/slice.json`.
Set APPDATA to a disposable workspace folder. It ends after about 60 seconds and never
persists player progress. The source launchers are not needed by the standalone binary.

These results support headroom for the current primitive slice on this machine. They do
not certify future art/animation, background workloads, low-power mode, gamepad/audio,
frame pacing during every transition, or a full human clean-start exported playthrough.
