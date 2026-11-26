# Living menu — v0.5.29, 2026-11-08

Godot 4.7.2.stable.official.ed1daf0bf, Windows native Vulkan Mobile renderer,
NVIDIA GeForce RTX 3050 Ti Laptop GPU. No Git repository available.

Replaced the old flattened background with original layered artwork. The dark
upper-left sky is reserved for the heading and tagline. Foreground plants and
knight sit below it. Locale-font measurement fits explicit title line breaks;
the previous wrapped multiline measurement left excess vertical space for
Bulgarian/French. Motes now avoid the text rectangle. Wind affects the cloak and
plant tips; the helmet, armor and castle remain rigid. Reduced motion freezes
the current pose rather than snapping back to the first frame. Pause continues
to display the active world instead of this main-menu artwork.

Actual checks:

- Editor import/parse completed; no shader/parse errors in native captures.
- `tests/menu_wind_capture.gd`: 48 assertions PASS. Five languages, 1600x900,
  1600x720 and 1280x960; title/tagline exclusion, knight/vegetation bounds,
  synchronized motion and reduced-motion freeze. Fifteen native layout images
  plus effect frames in `.tools/review/wind-*.png`. Bulgarian desktop and Arabic
  wide screenshots visually inspected; no title/art intersection in those views.
- `tests/capture_mobile_frontend.gd -- --touch`: filled-viewports and reduced
  motion PASS, including large UI scale, settings, journey, pause and actions.
- Translation regressions: 211 section assertions and 103 journey assertions PASS.
- Exported Windows PCK, isolated package working directory: 39 localization and
  12 living-menu resource/clock assertions PASS. No source-folder fallback.
- Native deterministic 180-frame recording, encoded to a six-second 30 fps MP4:
  `.tools/review/menu-wind-preview.mp4`. This is a preview recording, not an FPS
  benchmark. Pixel comparison between frames 0 and 90: title rectangle unchanged,
  helmet/castle samples unchanged; 2,251 cloak pixels and 13,166 vegetation pixels
  changed by more than 8 channel values. Region data in
  `.tools/review/wind-motion-analysis.json`.

No owner journey started and no owner save data modified by these fixtures:
all game fixtures use `game.testing=true` with a separate QA data directory.
No new full campaign, real-phone performance, live-account or SMTP test.

Release outputs: `build/windows-v0529`, `build/Last-Light-windows-v0529.zip`,
`build/android-releases/LastLight-0.5.29.apk`. Android version code 34,
version name `0.5.29-living-menu`; APK v2/v3 signatures verified. Platform
comparison: all 100 compiled game scripts, 162 prepared character resources
and four locale/cloud data files identical. Latest launcher points to v0.5.29.
Both delivery archives passed full ZIP CRC checks. Android: 416,907,746 bytes,
SHA-256 `a2332818f0e85ca1516db092526d22b32f9bca83a635a765ca3332ee318f3253`.
Windows ZIP: 495,608,488 bytes, SHA-256
`1c1d7424f97d987eece42ac8f30e841fb5bb1858f30a17f124ce36b52af2cf08`.

Owner explicitly approved Gofile distribution of this v0.5.29 APK on 2026-11-08.
Phone download: https://gofile.io/d/Wql5i32R . Upload returned the exact file
name, 416,907,746-byte size and MD5 `725243b33b84d6dd1776944be984f689`, matching
the local release. Guest management credentials remain in the local upload
receipt and are not included in this document or the distributed package.

Art dimensions/prompts/provenance: `docs/art/menu-wind-v2.md`; SHA-256 manifest:
`assets/ui/menu-wind/provenance.json`. Old art and previous exports preserved.

Known account issue remains separate: server verification redirects to the
default localhost Site URL; dashboard correction has not been applied. Custom
SMTP/email templates also remain pending. Do not describe this visual release
as a fix for registration redirects.
