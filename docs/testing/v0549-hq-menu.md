# v0.5.49 — higher-resolution menu video

Engine: Godot 4.7.2.stable.official.ed1daf0bf. Local Windows RTX 3050 Ti laptop.

## Change

Re-rendered the original layered art and wind shaders at 3840 × 2160 and streamed
360 PNG frames directly to two Theora quality-10 encoders. Windows receives
2560 × 1440 (21,542,360 bytes); Android receives 1920 × 1080 (13,984,932 bytes).
Both are 30 fps, 12-second loops. Legacy 720p source remains, excluded from exports.
No new art generation, gameplay changes or owner save access.

Cold reduced-motion startup decodes a real initial frame before pausing and
showing it; fallback art matches the movie's existing framing while loading.
The test for title/art collision now checks visible paint, excluding transparent
canvas margins and sub-10% alpha residue. Native resize checks also wait for actual
window notifications instead of only a few uncapped frames. Native wide-screen
captures confirmed no visible overlap.

## Actual verification

- Headless import/parse passed. Both complete films decode without FFmpeg errors.
- Source desktop and touch-selected mobile native decoder checks: 14 PASS each.
  These cross a real twelve-second loop boundary, inspect decoded texture size,
  pause/resume, hidden suspension and cold reduced-motion startup.
- Final Windows PCK decoder check: 14 PASS; layout/routes: 602 PASS, covering
  five languages, three aspect ratios and three interface scales.
- Native wind/title/moon/cloud checks: 99 PASS across five languages and three
  aspect ratios, including reduced motion and gaze direction.
- Native 1920 × 1080 old/new menu captures inspected: original 720p, new QHD and
  Full HD. Armor, cloak and path retain more detail; composition stays consistent.
- Pack parity: 112 compiled game scripts, 162 character resources, seven catalogs
  and all checked shared shaders/font data match. Platform menu encodes match
  the current source bytes. Android contains its Full HD film without QHD/legacy.
  Windows film selection also passed from its isolated build directory.
- Android versionCode 54, versionName 0.5.49-hq-menu; apksigner verification,
  established certificate, zip alignment and complete ZIP CRC check passed.
- Windows build manifest files, sizes and hashes verified.

Native evidence/logs: `.tools/review/menu-hq-*`; release hashes:
`.tools/menu-hq-v0549-release-hashes.json`. Movie hashes/provenance:
`assets/ui/menu-wind/movie-manifest.json`, `docs/art/menu-wind-hq.md`.

## Limits

The landscape source is 1672 × 941: supersampling improves rendering and encoding,
but does not produce newly authored 4K details. Native decoding was tested on the
laptop, including the phone encode; no physical Nothing Phone 3a test or phone FPS
claim. Existing Android themed-icon packaging warning remains unrelated.
No campaign completion or general gameplay benchmark was performed for this change.

## Delivery and cleanup

Local packages: `build/windows-v0549/`,
`build/android-releases/LastLight-0.5.49.apk`. No public upload.
Only the four specifically owner-authorized duplicate ZIPs session,
village-landscape, village-life and village were deleted. Extracted builds,
all APKs, source assets and saves retained; receipt in
`.tools/approved-cleanup-menu-hq.json`.
