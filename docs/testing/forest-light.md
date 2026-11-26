# Woodland canopy, horizon and lighting — 2026-11-05

Second King's Road presentation increment, Godot 4.7.2 Mobile renderer.

## Changes

- Wider pine silhouettes using the existing bounded canopy meshes. Needle
  material copies use alpha scissor at 0.35 and anisotropic mipmapped filtering;
  imported source assets and their licenses are unchanged.
- One 576-triangle decorative ridge skirt outside the playable rectangle replaces
  the bare terrain/sky seam. A northern valley retains the distant citadel view.
  No extra walkable terrain, hidden quest area or collision is implied.
- Refuge woodland fog density reduced from 0.006 to 0.0035, cooler and brighter
  ambient fill, steeper key light to improve route and structure readability.
- Three existing-kit warm torches illuminate the roadside shelter and watchtower.
  They add three local unshadowed lights, not volumetric lighting or ray tracing.

Campaign state, navigation bounds, encounters and save schema are unchanged.
Lighting changes are scoped to the uncleansed refuge; canopy material adjustment
applies wherever this pine mesh is used. Existing postgame lighting branch remains.

## Verification

- Clean import: `.tools/forest-light-import.log`.
- **511 assertions PASS**: `.tools/forest-light-tests.log`; new check verifies all
  horizon vertices stay outside playable bounds. Existing corridor, navigation,
  physical tower and campaign transition regressions remain passing.
- Native capture with bounded `--quit-after 600`: `.tools/forest-light-capture.log`,
  exit 0. Final watchtower and chapel views inspected under `.tools/review/road-*`.
  Canopies/hills and warm watchtower illumination are visible, path stays readable.
- Separate Windows export: `build/windows-forest-light`, `Play-Forest-Light.cmd`.
- All seven exported manifest payload hashes match. Packaged headless boot with
  isolated QA userdata exits 0; `.tools/forest-light-export.log` has no engine
  errors. This verifies boot/package health, not an interactive exported playthrough.

## Limits and next work

This is a modest presentation increment, not a finished realistic forest. Sparse
sapling character, repetitive ground foliage, sky cloud detail and distant castle
geometry still need work. No manual campaign, exported interactive or phone FPS
acceptance is claimed. Android follow-up: versionCode 6 / 0.5.1-forest-road now
packages this source and King's Road. Signature continuity and APK CRC pass;
phone acceptance pending. Previous builds/saves are retained. See STATUS for hash.
