# Cursed basalt UI verification — v0.5.36, 2026-11-08

Presentation-only owner request: dark chipped blue stone with purple glowing
cracks, inspired by the supplied reference without copying its composition.
Original material provenance: `../art/cursed-stone-ui-v1.md`.

## Implemented

Shared custom StyleBox draws one tiled material, a chipped bevel, offset shadow
and violet edge fractures. Normal/hover/pressed/disabled brightness differs.
No per-control shader or new movie. Text centers and native padding remain
clear. Native focus outlines stay visible; small sliders/meters retain their
functional shapes. Main/pause navigation, account forms, settings/dialogue,
journey buttons, gameplay HUD/objective/region/prompt and touch icons use it.
Legacy training/equipment frames also adopt the theme. Red health and green
stamina remain distinct. No combat, progression, saves or touch gestures changed.

## Actual checks

- Godot 4.7.2.stable.official.ed1daf0bf import/parse: no script errors.
- Full campaign/presentation regression: 640 assertions PASS.
- Native source menu section fixture: 100 views/routes, all five languages PASS.
  Visually inspected Bulgarian main/settings and Arabic signup/RTL fields.
- Native touch graphics/settings checks: 29 assertions PASS, including unchanged
  window dimensions/mode and journey data, plus five-language settings captures.
- Actual gameplay captures at 1600x900 desktop and 1600x720 touch: inspected
  stone HUD, prompt, task panel, pause and four icon-only action buttons.
- Final Windows PCK: 39 localization assertions PASS; native rendered menu
  inspected at desktop/wide-phone/tablet aspect ratios. The wide layout retains
  a readable title and disabled actions have dimmed state feedback.
- Windows/Android parity: 107 compiled scripts, 162 prepared character resources,
  seven localization/cloud catalogs, menu movie, grade shader and torch shader
  match. Both contain the imported basalt tile. Texture is successfully loaded
  and drawn by the final native PCK.
- APK full ZIP CRC, 16 KiB alignment, v2/v3 signature PASS. Signing certificate
  SHA-256: `03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8`.
- Windows folder manifest PASS. NTFS compression of the new EXE preserves its
  SHA-256; no old release removed. No duplicate Windows ZIP created.

Native captures used the pinned desktop runtime and isolated testing journeys,
not a physical Android device or a human campaign playthrough. No claim of new
phone FPS measurements or zero UI rendering cost. v0.5.35 graphics profiles,
movie, animations, gameplay rules and saves remain applicable.

## Local outputs

- Windows: `build/windows-v0536/LastLight.exe`, through `Play-Latest.cmd`.
- Android: `build/android-releases/LastLight-0.5.36.apk`, version code 41.
- PCK SHA-256: `BCEEC8CB388A904796751A574BC0586F97F9C8C70142C7B34DC537CF8A9E59E4`.
- APK SHA-256: `BCB97D3648896A7E331060E98397B946E4ACFF7518262B9E6EE5AE6D29699E73`.
- Evidence: `.tools/stone-ui-*.log`, `.tools/stone-ui-release-hashes.json`,
  `.tools/review/sections-*.png`, `stone-gameplay-*.png`, `stone-package/`.

Owner subsequently authorized Android upload to Gofile, 2026-11-08:
https://gofile.io/d/DhClZGt1. Remote size/name/MD5 match the local APK; public page
returns HTTP 200. Private upload receipt retained under `.tools/android/`.
Next: owner art-direction feedback and real-phone
readability/touch review; sustained device performance remains a separate check.
