# Brighter, left-shifted menu film — v0.5.32, 2026-11-08

Owner requested a small leftward reframe and brighter moonlit detail on laptop
and phone. The original twelve-second film remains byte-for-byte unchanged.

Changes: VideoStreamPlayer now uses a lightweight canvas color-grade shader,
gamma 0.90/exposure 1.12 with a luminance-gated toe to preserve deep black.
Reduced the existing readability gradient opacity from 0.42/0.62 to 0.30/0.48.
Movie position moves left by 2.5% of viewport width; 6% horizontal overscan
preserves complete edge coverage and aspect ratio, including wide phones.
Title, controls and all game rules remain native and unchanged.

Checks performed with Godot 4.7.2.stable.official.ed1daf0bf, native Vulkan Mobile
renderer, RTX 3050 Ti Laptop GPU:

- Native paused-frame A/B fixture, same decoded video pose, original versus
  new grade/shade/reframe. Captures at 1600x900, 1600x720 and 1280x960 under
  `.tools/review/menu-light-*.png`. Desktop before/after and wide phone reviewed.
- The sampled scene below the title increased from mean luminance 21.31 to
  34.43 (1.62x) in the composite A/B images. This includes the small reframe,
  not a calibrated real-phone display measurement. Data:
  `.tools/review/menu-light-analysis.json`.
- `tests/menu_loop_playback.gd`: 11 native assertions PASS after the change,
  including an actual twelve-second wrap, pause/resume and wide-screen cover.
- Editor import/native captures reported no script or shader errors.
- Android code 37, `0.5.32-menu-light`, exported with valid v2/v3 signatures;
  archive CRC PASS. File `build/android-releases/LastLight-0.5.32.apk`,
  424,039,481 bytes, SHA-256
  `0c36a18f2bf5c58421b49860ed5194f9409ac4608a055062c53b3d790373f5c5`.
  Export output was moved, not copied, into the release directory to avoid
  another 424 MB duplicate on the nearly full disk.

Owner explicitly approved cleanup of only the 535 numbered intermediate PNG
frames in `.tools/menu-frame-cleanup-plan.json`. All absolute paths were checked
against the two named capture directories and every file's size/SHA-256 checked
before any deletion. Removed 548,230,662 bytes (522.8 MiB); six keyframes remain.
Receipt: `.tools/menu-frame-cleanup-receipt.json`. Original images, rendered
videos, saves, models, previous packages and other capture directories retained.
The deleted frames are reproducible with the original rendering scripts; old
reports' frame sequences are now represented by their retained keyframes/MP4.

Owner explicitly approved Gofile distribution of Android v0.5.32:
https://gofile.io/d/pB4x6R9t . Remote name, 424,039,481-byte size and MD5
`b041f57d01075ae59f6287fb329de26d` match the local APK; download page HTTP 200.
Windows packaging proceeded after cleanup. Real phone brightness/performance
still needs owner review.

Final package evidence:

- Windows `build/windows-v0532`: isolated PCK 39 localization assertions and
  11 native decoder/loop assertions PASS. Actual packaged A/B views saved in
  `.tools/review/package-v0532/`; desktop after view inspected. No shader errors.
- All 100 compiled game scripts, 162 prepared character resources, five
  locale/cloud JSON files, original movie and new grade shader match Android.
- Windows ZIP CRC PASS: 502,733,857 bytes; SHA-256
  `f058511ab606b4b7c80461d2e9420e60b37ad3ad21698ece648a1d3821718cc6`.
- Latest launcher updated. Previous running owner game was not closed or
  restarted; no owner journey started by QA. QA fixtures use separate storage.
