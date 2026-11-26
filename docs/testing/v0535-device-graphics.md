# Device graphics profiles — v0.5.35

2026-11-08. Godot 4.7.2.stable.official.ed1daf0bf, shared Mobile renderer.
No Git repository/commit. Owner requested maximum practical visual quality and
smoothness for the inspected laptop and Nothing Phone (3a).

## Devices and policy

Inspected laptop: i5-12450H (8 cores/12 threads), RTX 3050 Ti Laptop 4096 MiB,
15.7 GiB physical RAM, 1920x1080/120 Hz display. Windows Balanced power plan,
plugged in at inspection; power settings/drivers were not changed. Native Godot
reports the NVIDIA GPU. Driver 537.70 / Windows version 31.0.15.3770.

Owner identifies the phone as Nothing Phone (3a). Its official specification is
Snapdragon 7s Gen 3, 1080x2392/120 Hz:
https://checkout-eu.nothing.tech/pages/phone-3a . No physical Android device was
connected to ADB. Desktop touch emulation does not establish phone frame rate,
heat or battery life. The mobile profiles are starting settings for owner review.

| High profile | Laptop | Mobile / Phone (3a) target |
|---|---|---|
| 3D scale | 100%, capped at 4,665,600 pixels | 90% at 2392x1080, capped at 2,100,000 pixels |
| MSAA | 4x | 2x |
| Anisotropic texture filtering | 16x | 8x |
| Mesh LOD threshold | 0.8 | 1.0 |
| Moonlight shadows | 4096 atlas, blended cascades, 100 m | 2048 atlas, 24 m, fade before edge |
| Default frame ceiling | 60 | 60 |
| Available frame ceilings | 30 / 60 / 120 | 30 / 60 |

Balanced/Performance reduce cost without changing progression/combat. Legacy
Low graphics migrates to Performance. Pine needle edges use alpha-to-coverage.
Optional FPS counter is inside the gameplay HUD and avoids phone gesture insets.
Settings are translated in all five languages. No per-frame dynamic resolution
allocation; explicit settings/resize events apply rendering policy. Window size
and fullscreen/maximized state are preserved when graphics changes.

No new source textures/models were generated or downloaded. These profiles
improve rendering of the existing assets. See ADR 0018 for renderer/API choices.

## Native before/after timing

Release PCKs v0.5.34 and v0.5.35 mounted separately in the same pinned native
editor runtime (`exported=false` in these reports). One process at a time,
VSync off and frame ceiling disabled to measure headroom. Five authored fixture
areas, 2 s warmup, screenshot, 0.5 s readback recovery and 12 s sampling per area.
Assisted HP and forced wizard phase; not a clean-start/human playthrough.
Background applications and temperatures were not controlled. A single run per
configuration is indicative, not a statistical FPS guarantee.

Requested window 1920x1080, logical viewport 1280x720; observed render texture
2880x1620 under DPI scaling, 3D scale 1.0. Do not label this native 1080p.
Both final routes keep the camera 4 m from its focus. Earlier harness trials
were superseded: movement was released between regions and the village camera
was moved clear of the shortcut bar before the final comparison.

| Region | Previous mean FPS | High mean FPS | High P95 ms | High worst ms |
|---|---:|---:|---:|---:|
| Refuge | 106.9 | 71.8 | 15.50 | 23.90 |
| Village | 176.7 | 160.4 | 8.68 | 15.60 |
| Blackwood | 209.9 | 179.9 | 7.46 | 12.09 |
| Peaks | 222.2 | 203.0 | 6.87 | 14.74 |
| Ritual | 209.2 | 166.7 | 7.71 | 14.76 |

Extra shadow/foliage work lowers uncapped throughput. The heaviest tested High
stage retains a 60 FPS P95 budget; 120 is an optional ceiling, not guaranteed
across the world. No frame exceeded 33.34 ms in these warmed sampling windows.
Transitions and first-load delays are reported separately, not included there.
Engine video allocation peaks: previous 1,196,174,928 bytes, High 1,229,730,384;
draw call peaks 817 / 837. These are engine monitors, not total driver VRAM.
Raw: `.tools/graphics-baseline.json`, `.tools/graphics-high.json` and matching
logs/region PNGs. Village before/after and settings captures visually reviewed.

## Actual standalone executable

`build/windows-v0535/LastLight.exe -- --benchmark` completed with exit 0 using
isolated APPDATA/memory-only journeys. Actual exported=true, NVIDIA GPU, VSync
on, High/default 60 ceiling. Existing 65.07 s slice route includes transition/
first-use stalls: 3,566 samples, overall mean 54.80 FPS, median 16.669 ms,
P95 17.588 ms, P99 18.532 ms, worst 2,623.135 ms. Village worst 1,203.122 ms;
boss phase-two worst 584.706 ms. Do not claim hitch-free or locked 60 FPS.
Normal intervals cluster around the target; loading/first-use spikes remain.
Engine video allocation peak 1,128,721,040 bytes; one observed OS working-set
sample was 1,217 MiB, not a measured working-set peak. Static-memory monitor
returned zero in release and is not used as evidence.

Raw: `.tools/graphics-standalone.json`, `.tools/graphics-standalone.log`.
The benchmark is scripted/assisted and does not certify foreground human feel,
every region, camera comfort or phone thermals. Long-form playtesting remains.

## Checks and delivery

- Full campaign/presentation regression: **640 assertions PASS**.
- Source graphics settings/policy: **29 assertions PASS** each desktop/touch;
  native five-language settings captures and real button/control checks also
  **29 PASS** each. BG touch, French desktop and Arabic touch views reviewed.
- Isolated final Windows PCK: **29 graphics assertions PASS** each desktop/touch,
  **39 localization assertions PASS**, **19 native wizard cinematic assertions PASS**.
- Windows/Android parity: **106 compiled scripts, 162 character resources,
  seven locale/cloud catalogs**, movie and menu/torch shaders identical.
- Windows folder manifest hashes PASS. Android ZIP CRC, v2/v3 signatures,
  native library alignment and unchanged signing identity PASS; code 40.

Windows: `build/windows-v0535`, no extra ZIP (`-SkipArchive`).
APK: `build/android-releases/LastLight-0.5.35.apk`, 424,078,747 bytes, SHA256
`907465251554ef0aa3d6947e7a3736c4231af31fc633724e6578c57f38dee9ed`.
PCK SHA256 `ddd3aba815d24eae3ccf38b2352e8cb220b96d6f87f0a6bb4ea24ff3784fed5c`.
Owner's local-only preference retained; no upload was made.

Logs: `.tools/graphics-full-tests.log`, `.tools/graphics-checks-*.log`,
`.tools/graphics-native-*.log`, `.tools/v0535-package-*.log`,
`.tools/v0535-platform-parity.log`, `.tools/v0535-delivery-receipt.json`,
`.tools/v0535-signing-identity.log`.

## Authorized storage cleanup

C: initially had effectively zero free bytes. Owner explicitly approved exactly
five intermediate opening AVI files and two duplicate Windows ZIPs v0.5.31/
v0.5.32. Deleted only those seven, freeing 1,996,268,833 bytes. Retained game OGV
films verified unchanged by SHA256; source scenes/models, saves, all APKs and
extracted old Windows folders preserved. Exact paths/hashes and receipt:
`.tools/graphics-cleanup-plan.json`, `.tools/graphics-cleanup-receipt.json`.
