# Knight skeletal locomotion — 2026-11-06

Source now enables an original six-bone leg skin and authored jog/run/standing
clips over the credited Andy Woodhead mesh. UVs and materials are retained. Knee
and ankle bending replace rigid hip-only leg rotation. Footstep events use the
separate emitter; legacy timer footsteps are suppressed for the skinned actor.
`--legacy-locomotion` selects the old presentation for comparison.

Physics, attack authority, stamina, camera and save format are unchanged. Combat,
dodge and airborne states blend back to standing legs; full-body attack/dodge
animation is still procedural and remains unfinished. This is authored animation,
not motion capture. No IK or slope-aware foot placement is claimed. Cosmetic road
stones were lowered toward the real floor to reduce boot/stone intersections.

## Diagnosis and regression evidence

Initial native render showed boots without upper legs. The deterministic unshaded
leg-render check failed with zero upper/shin pixels. A headless bind-origin check
also failed: rest origins were correct but all active pose translations were zero.
Godot 4 requires parent-relative pose positions in addition to bone rest matrices.
Setting each bone's initial pose position fixed the collapsed skin. The same render
reproduction then passed with 63,131 upper/shin pixels. Temporary debug output was
removed; the standalone render and bind checks remain reproducible regressions.

`tests/run_tests.gd`: 533 assertions PASS with the new default. Added checks verify
bind origins, every vertex's normalized weights and retained UVs, actual knee bend,
and that sampling a clip cannot move the physical body or spend stamina.

Native `tests/capture_skeletal_gait.gd` used real movement input: 3.83 metres over
60 physics ticks. Captured and inspected jog, sprint and attack views. Logged
transitions: attack/stand, dodge/stand, sprint/run. These scripted captures verify
rendering/state transitions, not subjective combat feel or a complete playthrough.

Run with the pinned Godot console, `--path . --script res://tests/<name>.gd`:

- `check_leg_bind_pose.gd` (headless supported).
- `check_leg_render.gd` (native GPU required).
- `capture_skeletal_gait.gd` (native GPU required).

Evidence: `.tools/skeletal-default-tests.log`, `.tools/leg-render-final.log`,
`.tools/skeletal-transitions.log` and `.tools/review/skeletal-*.png`.
Engine: Godot 4.7.2. Not present in the published 0.5.2 Android package.
