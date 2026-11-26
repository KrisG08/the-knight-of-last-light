# M4 refuge and village — 2026-11-03

Engine: 4.7.2.stable.official.ed1daf0bf Windows x86_64, Mobile/Vulkan on RTX 3050 Ti Laptop.

Implemented route: new campaign → safe refuge → village passage → village lantern
→ east mill encounter → explicit Oren rescue dialogue choice → permanent shortcut
→ optional western family token → return to changed refuge → forge improvement /
memorial quest → save/load at activated lantern. Three enemy profiles, five authored
placements. Village layout is an initial 80×90 m graybox with fixed building placement;
the floor navigation grid is derived once from that authored layout, not a procedural world.

Transitions stage and validate the new region, suppress player actions and old-region
processing, wait for navigation map synchronization, then replace the old region.
Missing target/readiness timeout preserves the previous region and exposes retry.
NavigationAgent destinations update at 0.25-second intervals, path output moves the
CharacterBody explicitly; sight and short last-seen memory control pursuit. The
conservative navigation mesh still excludes the opened shortcut. No per-frame bake.
Enemy definitions are typed immutable-by-convention Resources; health is actor-local.

Campaign persistence uses the existing tested save adapter in a separate
`user://campaign_saves/` directory. Training remains at `user://saves/`. No migration
or overwrite of existing training data occurred. Oren/family-token facts, rewards and
quest states validate together. Recruitment cannot bypass the authored rescue action.
Refuge has no hostile actors. Rescued Oren is hidden at the mill and shown at the forge.

Verification: `powershell -ExecutionPolicy Bypass -File .\Test.ps1`: import and 129
real assertions PASS, exit 0. Includes prior M0–M3 tests plus campaign start, absent
refuge enemies, missing-region recovery, navigation paths around buildings/barrier,
actual pursuing actor movement, three profiles, shared-definition health isolation,
village recovery, mill prerequisite, focused Oren dialogue/Free button, one-time
rescue, token/shortcut world changes, forge upgrade, memo reward idempotency, reload
and death. Runtime tests use memory stores; file tests remain isolated in .tools/test-saves.

Native render review: `tests/capture_village.gd` booted memory-only campaign and
captured actual viewport pixels for refuge, village, menu and journal. Inspected all
four local PNGs under `.tools/review/`; text fits the panels and gameplay is visible.
Command: portable console engine `--path . --position 2400,1400 --script
res://tests/capture_village.gd`. Final capture run exited 0 without engine errors.
This verifies rendered construction/layout, not human playability, audio balance,
gamepad, FPS, export or the full walking route. No computer-use input was used.

Pending manual route: walk both village loops, fight each profile, rescue/revisit Oren,
open shortcut from correct side, return token, upgrade, die at village lantern, save /
relaunch. Check camera around houses and whether pursuit/leashing feels fair.
Crypt boss, Burial Seal and forest entrance remain M5; no debug boss victory is exposed.

Godot API checks: [NavigationMesh](https://docs.godotengine.org/en/4.7/classes/class_navigationmesh.html)
and [NavigationAgent3D](https://docs.godotengine.org/en/4.7/classes/class_navigationagent3d.html).
