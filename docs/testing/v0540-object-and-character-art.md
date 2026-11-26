# Object and character art pass — v0.5.40

Godot 4.7.2.stable.official.ed1daf0bf, Forward Mobile on RTX 3050 Ti.
No Git repository is present. All changes and packages remain local.

## Changes

| Object/group | Result |
|---|---|
| Blackwood scout satchel | Rounded leather body, flap, shoulder strap, brass buckle, stitches, side pouch and parchment; original pickup ID and Lyra prerequisites |
| Village family token | Open hinged enamel locket, embossed tree, linked chain; original memorial quest |
| Refuge memorial / five seals | Shaped carved memorial and batched metal crystal cradles; existing collision and seal crystals |
| Hollow Villager / Bound Shade / survivor | Detailed variants of existing artisan/robe meshes with isolated tint materials |
| Imported armed hostiles | Palm-fitted idle weapons and shader arm articulation; existing combat pivots retain authority; death disables deformation |
| Weapon details | Beveled sword geometry, proportioned hammer/cleaver, wood grain, cut staff crystal; forged companion blades replace boxes |
| Soldier / Thorn Beast | Reduced metal glare, removed floating visor lights, bark variation on creature surfaces |
| Passive troll / dwarf | Detailed goblin/artisan adaptations with changed proportions; existing named limbs, strolling/repair behavior and passive status |

Provenance and scope: [art notes](../art/quest-and-character-polish.md).

## Checks and evidence

- Source campaign/presentation suite: **640 PASS**, including companion recruitment,
  JSON save round trips, all nine hostile health/telegraph behavior and eight passive
  creatures' movement/collision invariants. `.tools/object-art-regression-final.log`.
- Exported Windows object checks: **58 PASS**. Actual rule-approved item claims,
  visibility after claim, no visual mutation of progress, material-batched geometry,
  six armed imported models' rest palm alignment, unchanged combat pivot,
  strike appearance restoration and death deformation disable.
  `.tools/object-package-checks.log`.
- Native exported wizard defeat preview: **19 PASS**;
  `.tools/wizard-defeat-v0540.log` and `.tools/review/wizard-defeat-v0540/`.
- Native review fixtures capture the hero, nine hostile, four friendly and eight
  passive types, all eleven region overviews/inventories and quest item close-ups.
  `.tools/review/object-audit-before/`, `.tools/review/object-package-final/`.
  These use neutral fill light for inspection, not a claim that the campaign's
  night lighting has been brightened. Automated render review is not human playtesting.
- Windows/Android parity: **112 compiled scripts**, **162 character resources**,
  seven catalogs/configuration files, both new/changed character/quest shaders,
  waygate shaders, menu film/grade, basalt UI and torch shader.
  `.tools/platform-parity-v0540.log`.
- APK v0.5.40-character-and-relic-art, code **45**, CRC, 16 KB alignment and
  existing signing identity verified. Windows file manifest verified.
- Exported startup/menu/journey localization smoke: **39 PASS**;
  `.tools/menu-package-v0540.log`. Final source/package logs have no script or
  shader errors. These are automated checks, not a full interactive playthrough.
- First Android signing attempt ran out of temporary disk space. Exact owner-approved
  duplicate ZIP archives v0521–v0525 were removed; extracted versions remain.
  Final normal Android export completed successfully.

## Limits and follow-up

This is an asset-wide audit and targeted polish pass, not a declaration that every
asset has final production quality. Existing scan projections retain some soft
texture detail/faceting. Troll, dwarf, shade and survivor reuse existing detailed
meshes; unique sculpted replacements and full skeletal/finger animation remain
future art work. Hero hand/shield fitting during locomotion needs a separate
animation pass; the established knight movement rig was not replaced here.
No full human campaign playthrough, controller review or real Nothing Phone 3a
frame-rate/thermal test was performed. No FPS or photorealism guarantee.

## Local deliverables

- `Play-Latest.cmd` → `build/windows-v0540/LastLight.exe`, existing owner save path.
- `build/android-releases/LastLight-0.5.40.apk` and the same signed file under
  `build/android/LastLight.apk`.

Owner explicitly authorized public upload of this exact APK to Gofile on
2026-11-08: https://gofile.io/d/fnj9njQd. Returned filename, 426,226,647-byte size
and MD5 `05770c2f2e26c3346d9764c2f0733cbe` match the local signed release.
Private management receipt: `.tools/android/gofile-upload-v0540.json`.
Initial automatic review required explicit payload/destination approval; owner
provided that approval and the upload then completed successfully.
