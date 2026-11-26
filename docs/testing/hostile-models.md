# Hostile model replacement — 2026-11-05

Replaced block-body presentation for Hollow Villager, Fallen Soldier, Grave Hound,
Bound Shade and all five bosses. This is a model/presentation increment, not combat
retuning. Attack windows, damage, health, rewards, existing attack pivots, collision
capsules, quest facts and save schema remain owned by the existing controllers.

## Models

- Soldier / Commander / Warden: adapted DJMaesen Strong Knight armor/body with
  preserved textures, per-character material treatment, procedural legs, authored
  weapons and boss-specific crown, cape and heavy plates.
- Hound / Thorn Beast: Alexei Ostapenko Fox anatomy/fur base, scaled/partitioned,
  desaturated cursed-fur treatment, procedural gait/tail, thorns and branching antlers.
- Villager / Shade / Gravedigger / Maldrek: authored curved/pleated robes and cowls,
  recessed skull faces, fingers, cloth wear, chains and individual weapons. Curved
  pointed shovel blade, great sword, forge hammer and claw-crowned staff replace
  the old weapon boxes. Windup ring supplements existing weapon poses/state cues.

No original skeleton or animation clips exist in the two inspected samples. Parts
are statically partitioned at anatomical thresholds, then posed procedurally. Seams,
weapon-hand matching, gait and cloth motion still need production animation work;
this is not a fully rigged or photoreal character set. Recruited NPCs and hero remain
separate from this hostile-only pass. Public source hashes, links and modifications:
assets/vendor/hostile_sources/. Original Sketchfab API metadata confirms CC BY 4.0
for both; author/source/change notices are in menu/ending credits and beside EXE.

## Evidence

Test.ps1 clean import and **465 assertions PASS** (.tools/hostile-model-final-tests.log).
Five added checks exercise every actual actor profile/boss, absence of visual box
bodies, unchanged collision-shape/layer count, compacted imported UV/normal/index
validity, actual windup visibility and paused presentation clocks. Existing full
combat/campaign/companion/save regression still passes.

Native Mobile/Vulkan capture exited cleanly without engine errors. Inspected
.tools/review/hostiles_ordinary.png, hostiles_bosses.png and individual hostile_*
portraits. Actual region captures hostile_village_guard.png and
hostile_crypt_gravedigger.png show these actors in village/crypt windup poses.
These are engine renders; lineup images use a separate presentation stage.

Initial source adapter error from a third UV/custom channel was caught in native
rendering and corrected: UV/UV2, normals and valid compact indices retained; unused
custom/skin channels removed. Subsequent capture and regression are clean. Source
GLBs remain unchanged. Original block-helper methods were removed after integration.

Separate candidate: build/windows-hostiles/, Play-Villains.cmd. Previous village,
film and other builds remain. New meshes/texture sources require this new build;
the already-running older village executable cannot display them. Direct EXE uses
normal Windows APPDATA; workspace launcher uses the existing .tools/userdata profile.
No player slots were reset, migrated or overwritten by these automated checks.

Current candidate performance is not claimed: an older village game window remained
open during final review, so no competing native benchmark was launched. Previous
village FPS measurements identify an older PCK and are not reused for this version.
Human movement/combat/camera acceptance of the new silhouettes remains open.

Final Windows export completed without engine/script errors. All six manifest
payloads match both the output folder and Last-Light-windows-hostiles.zip.
PCK SHA256: F8E95E54752F69F6DEB9DD6C2B28938B7DCC8B42560A366CDFC23BD20802FAD7.
