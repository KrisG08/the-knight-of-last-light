# Overhead hostile health — 0.5.17

All four ordinary enemy profiles and five bosses now show a compact red meter
above the model, with a name caption and no numeric HP. Each meter faces the
camera, fills from left to right, reads actual current/maximum health and remains
depth-tested against scenery. It hides with the name on death and outside 28 m.
The hound's lower anchor and Meshy model heights keep the meter near the head.
Ordinary enemy respawns refill it. The player's own HUD is unchanged.

The duplicate bottom boss meter/debug state text and locked-target HP number
were removed. Existing visual windups, ground markers, attack timing and audio
cues remain. No combat, damage, reward, save or progression rules changed.

Implementation: `game/presentation/hostile_health.gd` plus one billboard quad
and per-actor shader material. No viewport textures or per-frame UI rebuilding.
Existing name labels are reused. Both platforms use the same presentation code.

Actual verification, Godot 4.7.2, 2026-11-07:

- `tests/run_tests.gd`: 580 assertions PASS; includes real receive-hit calls for
  all nine types, meter/health fraction agreement, dead caption/meter hiding,
  and ordinary enemy reset/refill. `.tools/hostile-bars-tests-final.log`.
- Native `tests/capture_hostile_health.gd`: ordinary enemy and boss lineups at
  full health and all nine types at half health, viewed from an angled camera.
  `.tools/review/health-*.png`, `.tools/hostile-bars-capture-final.log`.

No real-phone performance or human full-campaign acceptance claimed.
