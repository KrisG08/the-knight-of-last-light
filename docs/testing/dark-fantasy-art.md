# Dark fantasy presentation pass

Owner-directed visual update, 2026-11-04. Pinned Godot 4.7.2 Mobile renderer retained.
Direction: the attached blue/cyan gothic ruin reference, original adaptation rather
than copied TikTok footage or a claim to reproduce a particular creator's work.

## Implemented

- Original 3D knight assembled from tapered armor, layered cuirass/gorget/waist,
  great helm slit/vents, pauldrons, articulated legs, shield/rim, sword and shaped
  cape. Existing capsule, weapon pivot, hit windows and controls remain authoritative.
  Legs receive a basic movement cycle; this is not a production skeletal rig.
- Reusable 3D gothic kit: pointed arch segments, column bases/capitals, spires,
  caged emissive lanterns, bare branching trees, paving, grass blades and rubble.
  Refuge receives the full first scene dressing; village, forest and later regions
  receive selected shared props. Collision-free dressing preserves authored routes.
  Dense paving/grass/rubble use MultiMesh batches instead of one node per pebble.
- Built-in imagegen limestone base-color texture, triplanar stone materials, cool
  moonlight/cyan pools, distance fog and original animated procedural storm sky.
  Mipmapped anisotropic texture filtering; no volumetric fog/GI/renderer migration. Two added refuge lights cast no shadows.
- Compact resource HUD; separate right-side objective/ally state, center interaction
  prompt, expiring notices, region caption; menus hide gameplay overlays. Dark framed
  buttons, serif title, focus/hover states, shorter menu labels, conditional save retry,
  and existing 100/125/150% text/scrolling/rebinding retained. Save warnings persist.

## Evidence

Test.ps1 clean import and **441 assertions PASS**. Added checks verify actual texture
use, instancing, no new dressing colliders, knight weapon/legs, separated HUD prompt/
objective, menu visibility and 150% overlay theme. Existing combat/navigation/save/
campaign regression remains included. The runner now fails on script/parser errors
even if a partial assertion runner would otherwise print PASS.

Native Vulkan renders of the refuge, menu, knight and 150% journal were generated
with memory slots, inspected and iterated: .tools/review/dark_fantasy_*.png.
The runnable art candidate is build/windows-art, launched with Play-Art.cmd; earlier
builds remain separate. Exported workload measurements are recorded after execution
in the accompanying performance report. Existing player saves are not reset.

## Scope and limitations

This first art pass materially changes the knight, reusable kit, atmosphere and UI.
It does not claim finished high-poly assets across every NPC/boss or parity with a
prerendered reference. Earlier enemy/companion/boss shapes still need individual art
passes. Refuge is the visual review scene; later regions have lighter dressing.
All decoration placements are fixed authored composition with deterministic prop
variation; terrain, encounters and progression remain hand-authored. AI generation
is an offline asset-authoring step, not a runtime service.

Material provenance/prompt: assets/materials/README.md. New asset records are in
planning/asset-register.csv. Human camera/readability/art feedback and full campaign
acceptance remain pending; measured workload is not a human playthrough.

Static GLB snapshots are available in art_exports/: knight_v2, gothic_lantern,
gothic_arch and dead_tree. Each was exported and imported back with real meshes.
These are editable static assemblies without a production skeletal rig; runtime
builders retain the live weapon pivot and basic knight leg cycle.
