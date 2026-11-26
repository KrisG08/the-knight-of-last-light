# Violet map-transition waygates — v0.5.39

2026-11-08, Godot 4.7.2.stable.official.ed1daf0bf / Mobile renderer. No Git repo.
Owner supplied a violet vortex in a stone arch as visual direction; the image
is not embedded, edited or used as a game texture. All new geometry, sigils and
shaders are original project work, reusing registered stone/wood/iron materials.

## Implementation

All twenty physical forward/return links across eleven campaign regions have
a pointed-arch opaque aperture, layered carved arch mouldings, columns, geometric
sigils, continuous animated mist/vortex, protruding 3D additive filaments and
fading motes. Four regional frame styles: root-wrapped forest, tomb masonry,
iron-banded peaks/forge and Gothic citadel. The ritual ascent has a larger 5.2 x
8.2 m aperture. Existing architecture remains as the surrounding building.

| Region | Physical portal point keys |
| --- | --- |
| Refuge | travel |
| Village | travel, crypt, forest |
| Crypt | crypt_exit |
| Blackwood | forest_exit, grove, order_gate |
| Grove | grove_exit |
| Order | order_exit, order_depth, peaks_gate |
| Sanctum | sanctum_exit |
| Peaks | peaks_exit, fortress, citadel_gate |
| Forge | forge_exit |
| Citadel | citadel_exit, citadel_depth |
| Ritual | ritual_exit |

Geometry anchors after elevation at existing interaction points; return portals
face inward. No new CollisionObject, point, navigation obstacle, travel action,
auto-contact teleport or save field. Existing E / mobile context interaction,
combat travel restrictions and progression rules retain authority. Four sealed
routes read the existing gate evaluator; a dim vortex and crossed sigil show
closed state. Arena exit visuals observe the actual entrance barrier. Original
flat ward visual hidden while its authoritative collision/state is preserved.
These are traversal magic and remain visible after curse cleansing. Refuge UI
fast travel / scripted ending transfer do not gain extra physical anchors.

One nearest shadowless light per loaded region, off beyond 18 m; no new global
bloom or renderer change. Filaments hidden/motes stopped beyond 32 m, geometry
ranges 24–85 m. Update proximity/arena state four times/second, not full-world
queries every frame. Shader TIME animates the field; no video/texture download.
Shared stone resources remain immutable; frame tint and effect state are local.

## Actual source verification

- Import/parse clean after correction. Initial check caught the refuge's early
  return skipping common presentation setup; added the portal build there.
- `tests/portal_checks.gd`: 98 assertions PASS. Every physical link has an arch,
  follows its point, retains collision-free decoration and immutable campaign
  data, responds to sealed/unlocked facts and uses a shadowless shared light.
- Full campaign/presentation regression: 640 assertions PASS.
- Native review fixture photographed all twenty portals, plus one-second motion
  and locked variants. Inspected refuge, village/forest and ritual-ascent views.
  Initial hashed turbulence showed precision/grid seams on Mobile; replaced by
  continuous analytic turbulence. Review camera moved to the open approach to
  avoid photographing from inside a neighbouring village house.
- Portal-center ROI comparison one second apart: mean RGB difference 40.93/255,
  59.94% pixels changed by >12 levels. Evidence supports visible animation, not
  a phone FPS/quality benchmark. `.tools/portal-motion-evidence.json`.
- Evidence: `.tools/portal-checks-final.log`, `portal-regression.log`,
  `portal-captures-refined.log`, `.tools/review/portal-*.png`.

No physical Android test or human complete campaign acceptance. These are game
renderer captures and automated fixtures, not a photo-realism guarantee. Source
asset quality, mobile thermal limits and previous campaign limitations remain.

Local direct review: `Preview-Portals.cmd` starts a memory-only journey near
the village/forest portal; it does not load the owner's slots/account.

## Final package checks

- Final Windows PCK: 100 portal assertions PASS. Includes actual timed arena
  barrier changes closing/reopening the ritual return portal; no travel bypass.
- Native final-PCK review captured nine representative gates across village,
  crypt, peaks and citadel plus motion/closed variants. Inspected iron forge
  facade and Gothic ritual ascent; no shader errors. Captures under
  `.tools/review/portal-package/`; `.tools/portal-package-native.log`.
- Windows/Android parity PASS: 110 compiled scripts, both animated portal
  shaders, 162 character resources, seven locale/cloud catalogs and retained
  menu art/film/torch shaders. `.tools/portal-parity.log`.
- APK full ZIP CRC, 16 KiB alignment, v2/v3 signature and current APK Analyzer
  code/name PASS. Certificate remains
  `03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8`.
- Windows manifest and new EXE lossless NTFS compression/hash checks PASS.
- Preview launcher headless startup/120-frame exit PASS; this is not manual
  interactive acceptance. `.tools/portal-preview-smoke.log`.

Windows: `build/windows-v0539`, selected by `Play-Latest.cmd`.
Android: `build/android-releases/LastLight-0.5.39.apk`, code 44, 426,209,815 B.
PCK SHA-256 `5ED4A8FAE44B506225EF64369A8325718B14DAF7FE314B57D5A6882AF30C1B86`.
APK SHA-256 `8F88832496C09C1C08F142438B0B16C2C6413CBB5606FF3D1BA1D90073678AFD`.
Receipt `.tools/portal-release-hashes.json`. Local only, no public upload or
duplicate Windows ZIP. No new deletion. Next: owner visual feedback and real
Phone (3a) appearance/pacing test, especially during close portal approaches.
