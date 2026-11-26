# M8 Blackwood chapter

Implemented 2026-11-04 with Godot 4.7.2.stable.official.ed1daf0bf.

The authored forest now includes a southern lantern, eastern watchtower detour,
blighted hollow, northern root shrine, a shortcut opened from its north side and
the northeast Order ward. Five ordinary encounters include the two Lyra quest
hounds. No poison status or procedural terrain generation is implied by the hollow.

The separate grove contains a 500-HP Thorn Beast. A 0.95-second locked-direction
lunge and 1.1-second sweep telegraph alternate, with 1.65/1.8-second recovery.
Existing guard, dodge, damage/tempo assistance and per-swing hit claims apply.
The entrance closes during battle. Loss resets the unfinished guardian; victory
awards 240 XP and 110 shards once. Breaking Root Seal is a separate saved action.
It opens the Order ward, changes forest ground color and adds a refuge message.
The playable Order forecourt completes chapter II and permits a return journey;
its deeper barracks and M9 are not implemented. Lyra waits outside both guardian
arenas and can accompany the player into the forecourt.

## Evidence

- Clean Test.ps1 import and 271 assertions PASS across M0–M8. New coverage includes
  forest path connectivity around the ridge, checkpoint/recovery, north shortcut,
  lunge movement/sidestep, sweep hit uniqueness, boss loss/reset, real victory,
  reload between victory and seal, one-time reward, gate return spawns, refuge
  feedback and actual JSON schema-three promotion with a legacy backup.
- Navigation transitions now park the previous region on an inactive map and wait
  for the new region's iteration and point ownership. This prevents an old area's
  overlapping coordinates from satisfying readiness. Failure restores the old map.
- Native Mobile/Vulkan script capture exited 0 without engine errors on the NVIDIA
  RTX 3050 Ti Laptop. Actual rendered forest, boss telegraph and Order forecourt
  images were inspected under .tools/review/{blackwood_chapter,thorn_beast,order_entrance}.png.
  These are scripted captures, not a human combat playthrough.
- Windows export/package and isolated boot evidence is recorded in STATUS.md after
  the build. Test scripts use memory slots or unique .tools subfolders; existing
  player saves are not reset, migrated or copied.

## Limits and player route

From the Burial Seal, enter Blackwood. Activate the lantern west of the entrance.
Complete Lyra's optional scout quest or follow the east road past the watchtower,
then turn west along the northern trail to the shrine. Open the root bar from north.
Enter the grove, defeat Thorn Beast and interact with Root Seal. Return to forest
and take the northeast ward to the Order forecourt. Reload recovers at the last
activated lantern, including Blackwood; ordinary enemies return.

Geometry and animation remain primitive. Navigation conservatively retains the
shortcut's blocked cells after it opens; allies/enemies can still take the detour.
Human route/combat/audio acceptance and new workload performance measurement remain
pending. The M6 benchmark belongs to its older PCK and does not certify M8.
