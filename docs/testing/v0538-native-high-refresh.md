# Native resolution and high-refresh targets — v0.5.38

2026-11-08, Godot 4.7.2.stable.official.ed1daf0bf. Owner requests sharper mobile
graphics and smoother motion, citing 160 FPS and 2160 quality.

## Hardware boundary and source

Nothing Phone (3a)'s official panel is 1080 x 2392, up to 120 Hz; Snapdragon
7s Gen 3. https://checkout-eu.nothing.tech/pages/phone-3a . A 160 engine cap
cannot produce 160 distinct visible frames on this panel. A 2160p render would
supersample above panel resolution and consume much more GPU time; do not label
the game as delivering native phone 4K. No 160 FPS or 2160p option is fabricated.

Godot resolution scaling is available in Mobile via bilinear; FSR modes require
Forward+. https://docs.godotengine.org/en/stable/tutorials/3d/resolution_scaling.html .
Frame pacing is controlled through Engine.max_fps and built-in Android pacing,
not a new Android plugin or OS setting override:
https://docs.godotengine.org/en/stable/classes/class_projectsettings.html .

## Behavior

- Shared settings offer 30/60/90/120 FPS targets; remove Android's extra min(60)
  clamp. Built-in Android frame pacing explicitly enabled. VSync retained.
- New persistent resolution setting: Profile default / Native screen. UI reports
  computed current 3D dimensions and selected target, not an achieved-FPS claim.
- Native Phone (3a): scale 1.0 at 2392x1080 within 2.6 MP budget. Larger Android
  buffers stay capped. Desktop native option has 8.2944 MP ceiling, without
  changing window size, display mode or physical monitor resolution.
- Mobile Profile default scales pixel work by 60/target above 60 FPS. Resolution
  changes only on a settings/resize event. Native bypasses this frame-target
  tradeoff, retaining maximum detail within its pixel budget. Quality presets,
  anti-aliasing, shadow distances and combat physics otherwise unchanged.
- Existing saved preferences retained; new resolution preference defaults to
  Profile default; default FPS remains 60. User chooses their own throughput /
  clarity tradeoff. The actual FPS HUD remains optional and measured by Godot.
- New controls, note and formatted dimensions translated in all five languages.

## Actual verification so far

- Import/parse clean. Graphics integration checks: 40 assertions PASS in
  headless touch and native desktop. Tests exercise real controls, Engine.max_fps
  90/120, persistent settings reconstruction, actual viewport profile, bounded
  oversized buffers, window/mode invariance, unchanged journey and localization.
- Native touch checks/captures: 40 PASS, run separately at 1600x720; final result recorded
  under `.tools/hfr-touch-native.log`, five-language screenshots under
  `.tools/review/graphics/settings-*-touch.png`.
- Original graphics checks and v0.5.37 world/combat acceptance are not physical
  Android performance results. No phone FPS, thermal stability or 120-Hz display
  mode acceptance claim. The OS, screen mode and GPU can limit actual output.
- Retained older PCKs losslessly compressed and SHA-256 verified. Owner explicitly
  approved removing only duplicate ZIPs v0526/v0527/v0528, freeing 1,473,171,191 B;
  corresponding extracted PCKs verified first and retained. No other deletion.
  Receipt `.tools/hfr-approved-cleanup.json`.

Bulgarian final touch layout with Native / 120 selected visually inspected:
readable controls, actual resolution/target and concise localized help; Arabic
and remaining languages captured by the same native fixture. Not a phone image.

## Final packages

- Windows `build/windows-v0538/LastLight.exe`; `Play-Latest.cmd` selects it.
- Android `build/android-releases/LastLight-0.5.38.apk`, code 43,
  version name `0.5.38-native-high-refresh`, 426,196,987 B.
- Final PCK: 40 graphics assertions PASS each headless touch and native desktop;
  packaged five-language views captured in `.tools/hfr-package-checks/review/graphics`.
  Bulgarian desktop Native/120 view visually inspected. No physical-phone test.
- Cross-platform parity PASS: 108 compiled scripts, 162 character resources,
  seven locale/cloud catalogs, basalt tile and retained menu/torch films/shaders.
- APK CRC, 16 KiB alignment, v2/v3 signature PASS; unchanged certificate SHA-256
  `03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8`.
  Current APK Analyzer confirms version code/name. Legacy SDK35 aapt badging
  emits an attribute-read compatibility error; not used as manifest validation.
- Windows manifest and new EXE lossless compression/hash checks PASS.
- PCK SHA-256 `E4DAD82B2F3E35E447AAF88F800C24346FD1079F69F689934CCDFBB081D032FD`.
- APK SHA-256 `BCA6317B3A3D0B50E0CAF9D3C4E6EE31C6C3FD913FB24D7848475BDD07D25F30`.
  Full receipt `.tools/hfr-release-hashes.json`.

Local only, no public upload or duplicate Windows ZIP. Next: owner sustained
device test using Show FPS and phone high-refresh display mode. Prior v0.5.37
world geometry and saves remain applicable. Actual mobile FPS not established.
