# Character colors — 0.5.16

The ten Meshy source characters were untextured geometry. This pass replaces the
previous broad height tint with offline rest-space vertex paint for clothing,
skin, hair, leather, armor, trim and wear. Individual palettes distinguish the
knight, Oren, Lyra, Cael, goblins and all five bosses. The knight has a chest sun;
the Thorn Beast uses bark, moss and bone colors. Existing credited Poly Haven
maps provide subtle surface variation. No external service runs in the game.

`tools/paint_meshy_models.gd` reads the unchanged prepared source meshes and
writes compressed meshes under `assets/models/meshy/painted/`. JSON definitions
select those resources. Color alpha carries metalness; UV/UV2 preserve rest-space
detail coordinates and roughness through leg and arm skinning. Regenerate paint
after rebuilding source geometry. The original GLBs and prepared source meshes
are preserved.

Actual checks, Godot 4.7.2, 2026-11-07:

- `tests/run_tests.gd`: 577 assertions PASS, including painted arm/leg arrays.
- `tests/check_meshy_models.gd`: ten models PASS geometry, floor/height, triangle
  budget, moving limbs, paint arrays and nonuniform pigment checks.
- Native `tests/capture_meshy_models.gd`: ten rest/motion views rendered and
  inspected; `.tools/character-colors-capture-final.log` and
  `.tools/review/meshy-*.png`.
- Native `tests/capture_skeletal_gait.gd`: painted knight walking, sprinting,
  attacking, dashing, guarding and idle; actual physical walk distance 3.83 m.
  Dash retains jog animation. `.tools/character-colors-gait.log`.

These are vertex-painted and shader-detailed meshes, not authored high-resolution
skin/clothing texture atlases. Source geometry still limits face/hair detail.
No real-phone performance or full-campaign acceptance claimed by this art pass.
