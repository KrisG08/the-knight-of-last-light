# Directed introduction — 0.5.24

Owner feedback after 0.5.23: wizard shot was good but did not show him casting;
the curse ring, rigid falls and simple rising motion looked static. Requested
more character movement and situation-dependent camera zooms.

The offline director now animates Maldrek's arms, torso turn and a staff attached
to his right arm. Gathering motes and filaments form at the staff before the
release spreads away from it. Removed both torus ring effects. New original
camera-facing filaments have feathered edges, drifting motes and dark procedural
vapor. The forest strike travels as branching ground veins, not an expanding disc.

Authored joint poses replace a single rigid root roll: recoil, bending knees,
collapse and settling; surviving knight braces, rises through a split kneel,
extends his legs and settles upright. Skin/equipment follow the same arm/leg
rigs. Neighboring pose interpolation uses cubic curves with staggered fall times.
This is authored procedural motion, not motion capture or simulated ragdolls.

The camera moves inward toward the charge, pulls back at release, follows the
march, widens at the impact and returns toward the fallen formation. The final
camera starts low, rises with the knight and withdraws at the camp reveal.
Lens changes are continuous inside each shot; fades cover inter-shot cuts.

All effects/director scripts live under tools/, are baked into video and are
excluded from runtime packages. Runtime cost remains video decoding, with the
0.5.23 hidden-world optimization, Skip and automatic return to gameplay.

Native preview evidence: `.tools/film-v3-preview-final.log`, actual images
`.tools/review/film-v3-{4,12,17,18,19,23,25,27}.png`. These were reviewed while
iterating arm gestures, soft ribbon edges and the fall/rise framing. Final master
and encoder logs are under `.tools/movie-render/*v3*`.

Limits: source character meshes and authored poses remain development assets;
hand contact and robe/armor deformation are approximate. Real phone performance
must still be checked on a phone; desktop touch emulation is not hardware testing.

Final checks: Godot 4.7.2, 589 assertions PASS (.tools/v0524-final-tests.log). Native exported desktop film completes; mobile-emulation film completes in 29.994 s (process median/p95 8.333/8.882 ms), not a phone measurement. The first desktop sample overlapped another video and an Android build (median/p95 9.317/25.395 ms); an isolated follow-up is recorded separately. FFmpeg full decode: desktop 1920x1080/60, 30.00 s, 102,664,382 bytes; mobile 1280x720/60, 30.00 s, 26,002,963 bytes. Encoder consumes 1800 source frames; desktop decode reports 1799 distinct frames due to duplicate black-frame packet handling. No media decode errors. Offline writer emits the same shutdown-only two ObjectDB/resource cleanup warnings as v2, after successful capture. Exported package boot exits successfully; compiled game script parity 93 PASS, character resources 162 PASS, correct per-platform film inclusion/exclusion and bytes PASS. Android signature verified, APK/Windows ZIP CRC recorded in .tools/v0524-package-crc.log. APK: build/android-releases/LastLight-0.5.24.apk, 409,072,176 bytes; SHA256 558932807F1F3873617CADEB9DC50FBCE9396BEC74F564830D393D335F3B0B6C. Latest launchers now select windows-v0524. Existing builds and saves retained.

Isolated exported desktop playback follow-up: completed in 29.987 s; 3419 process callbacks, median/p95 8.323/15.239 ms (.tools/v0524-film-desktop-isolated.log). This measures native playback on this laptop, not Android hardware or full-campaign FPS.
