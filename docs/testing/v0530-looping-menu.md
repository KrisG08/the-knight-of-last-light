# Looping menu film — v0.5.30, 2026-11-08

Owner feedback: the previous motion read as a still image. Replace it with
an actual looping background film: visible cloud wind, plant bending and cloak
flutter. This is an animated original illustration, not a simulated 3D character.

Implementation:

- `tools/render_menu_loop.gd` renders scenery without menu text from original
  generated layers. Stronger wind includes the cloak silhouette, not only its
  internal texture. Shoulder/armor remain rigid; plant roots remain anchored.
- `menu_living_art.gdshader` reuses the project's original generated storm-cloud
  panorama, darker moving cloud banks, lower mist and window flicker. Dual
  crossfaded advection phases close in 12 seconds without reversing the wind;
  edge blending hides the panorama wrap and a mask protects the right-hand trees.
- `assets/cinematics/menu_wind_loop.ogv`: local 1280x720, 30 fps Theora film,
  silent, 360 frames. Core VideoStreamPlayer loops the film behind normal UI.
  Cover scaling preserves aspect ratio and fills the screen. No baked labels.
- Hidden menu pauses decoding; Animated menus pauses the current movie pose
  and resumes it. Original animated layers remain available if movie loading
  fails. Saves, accounts, combat and the opening story film are unchanged.

Engine: Godot 4.7.2.stable.official.ed1daf0bf. Native checks use Windows Vulkan
Mobile renderer on NVIDIA RTX 3050 Ti Laptop. Tests and release results follow
below. No real-phone or campaign acceptance implied.

Actual source/native checks:

- Editor import/parse completed without reported script/shader errors.
- Final frame 360 versus frame 0: maximum per-channel difference 1/255,
  mean below 0.00002. Frame 0 versus frame 90: 31,409 sky pixels, 13,674 cloak
  pixels and 32,394 foreground-plant pixels changed by more than 8 channel
  values; sampled helmet and castle patches remained identical. Evidence:
  `.tools/review/menu-loop-analysis.json`. No claim of physical cloth simulation.
- `tests/menu_loop_playback.gd`: 11 native assertions PASS on the final film,
  including a real twelve-second wrap, decoded-frame capture, fallback hiding,
  pause/resume in place, hidden-menu decode suspension and wide-screen cover.
- `tests/menu_wind_capture.gd`: 48 layout/motion assertions PASS, with native
  menu captures in five languages at 1600x900, 1600x720 and 1280x960. Bulgarian
  desktop capture reviewed for title legibility and unobstructed composition.
- `tests/capture_mobile_frontend.gd -- --touch`: filled viewports and reduced
  motion PASS, including large text, settings, journey, pause and actions.
- 211 menu-section and 103 journey-translation assertions PASS.
- Original art retained; generated scenery frames are under
  `.tools/review/menu-loop-v2/`. Preview: `.tools/review/menu-loop-v2.mp4`.
  Preview has the same 360 scenery frames as the actual game film, without UI.

Movie resource: 7,163,886 bytes; SHA-256
`dfa0b55c7ca4c5779fed4d4651baeb84026a095a550f6f1b4f90a036ef7ddcb0`.
Manifest: `assets/ui/menu-wind/movie-manifest.json`.

This is source/native and package evidence, not a measured real-phone FPS result.
No campaign/combat/save schema changes or live-account fixes in this release.
Supabase email redirect and SMTP setup remain pending separately.

Release checks:

- Windows: `build/windows-v0530`, archive `build/Last-Light-windows-v0530.zip`.
  Android: `build/android-releases/LastLight-0.5.30.apk`, version code 35,
  version name `0.5.30-looping-menu`. Same Android application ID/signing key.
- Isolated Windows PCK checks (package working directory, no source fallback):
  39 localization assertions PASS; 14 movie/resources/clock assertions PASS;
  11 native decoder/real-wrap assertions PASS. Exported decoded frames in
  `.tools/review/package-v0530/`. Their sky, cloak and plant samples all changed
  by mean RGB values greater than 5, independently confirming decoded motion.
- Platform comparison: identical menu-film bytes, all 100 compiled game scripts,
  162 prepared character resources, four locale/cloud data files. Android v2/v3
  signatures verified. Both delivery archives passed full ZIP CRC checks.
- APK: 424,035,193 bytes, SHA-256
  `cde0a2bda9581388a4ff8996e748bbf5532311fce98d988607784fe7fdafceee`.
  Windows ZIP: 502,731,840 bytes, SHA-256
  `fe95a0ccf3c2ed0e7a56864bc3244aae4903c642f23ce39b641e6473a5183d6e`.
- Latest launcher updated; historical releases retained. Owner explicitly
  approved public Gofile upload of v0.5.30 on 2026-11-08. Phone download:
  https://gofile.io/d/NMb09A6j . Remote name, 424,035,193-byte size and MD5
  `6d20d2a66df02b29a1b7f47e95eced80` match the local APK. Upload management
  credentials remain only in the local receipt, outside the distributed APK.
  The v0.5.29 Gofile link continues to serve the older release.

Core video-loop behavior and format reference checked against official docs:
https://docs.godotengine.org/en/stable/classes/class_videostreamplayer.html
https://docs.godotengine.org/en/stable/tutorials/animation/playing_videos.html
