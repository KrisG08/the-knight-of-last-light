# Living menu moon — v0.5.42, 2026-11-10

## Implementation

The main-menu moon is an independently animated canvas layer over the existing
twelve-second wind movie. The original crater-face texture is retained. A local
shader deforms the eye relief into slow asymmetric squints and a blink, moves a
restrained violet gaze, and separates the carved mouth into a dark opening with
irregular stone teeth. Vertex tint is preserved without multiplying the original
texture twice. The face remains clear of the title and menu navigation.

The material uses the existing menu clock, not shader TIME. Disabling menu
motion therefore freezes the movie, curse, halo, eyes and mouth at the same pose;
hidden menus do not advance the animation. No additional texture, network call,
new external artwork or gameplay/save-schema change is involved. This remains
a stylized animated lunar relief, not a new fully rigged 3D character.

## Actual checks

- Godot 4.7.2.stable.official.ed1daf0bf, Vulkan Mobile renderer, RTX 3050 Ti.
- Native editor import completed without script errors.
- `tests/menu_wind_capture.gd`: **81 assertions PASS**, including five languages
  at 1600x900, 1600x720 and 1280x960, title/foreground/moon exclusion, viewport
  bounds, advancing/frozen menu clock and frozen face material uniform.
- `tests/menu_loop_playback.gd`: **11 assertions PASS** on source and **11 PASS**
  against the final Windows PCK. Actual decoder loop boundary, pause/resume,
  hidden-menu suspension and wide-display cover were exercised.
- Native closeups at 0, 2, 5 and 8 seconds and real desktop/wide-menu views
  captured. Final packaged wide menu visually inspected. Evidence:
  `.tools/review/living-moon/`, `.tools/review/living-moon-package/`.
- Animated native GPU preview: 240 frames at 24 fps, ten seconds, encoded to
  `.tools/review/living-moon-preview.mp4`. Preview sampling rate is not a claimed
  game performance measurement; the actual face updates with the menu clock.
- Windows/Android package parity PASS: exact current face shader, 112 compiled
  game scripts, 162 character resources, seven localization/configuration files,
  retained menu movie/effects and correct platform-specific opening films.
- Android version code **47**, name **0.5.42-living-moon**. APK CRC and 16 KB
  alignment PASS, v2/v3 signatures valid, existing signer certificate SHA-256
  `03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8`.
  APK SHA-256 `d7682e8dc9db26ebf6318eed54b128d0756034eb879cb3c2ea3baee51607f445`,
  424,342,580 bytes. Android badging inspection retains a themed-icon resource
  warning; no actual Android installation or phone frame-rate claim is made.

## Delivery and limits

`Play-Latest.cmd` selects `build/windows-v0542/LastLight.exe`. Android is local at
`build/android-releases/LastLight-0.5.42.apk`; no public upload is authorized for
this version. Existing owner userdata and journeys were not opened by fixtures.
Unrelated campaign rules/full human playthrough were not rerun for a menu-only
presentation change. Owner review of the expression and real phone presentation
remains useful.

Owner explicitly authorized deletion of only the duplicate ZIP archives v0513,
v0514, v0515, v0516 and v0517. Each absolute target was checked inside this
workspace's build directory before native PowerShell file removal. Extracted
versions, APK releases, source art and saves remain. Receipt:
`.tools/approved-cleanup-living-moon.json`.
