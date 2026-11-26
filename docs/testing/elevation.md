# Terrain and summit ascent — 0.5.18

Village streets rise 1.5 m. Blackwood rises from 1.5 to 7 m, Order ruins from 7
to 13 m, and Ashen Peaks from 13 to 26 m with its existing level gorge bridge.
The citadel climbs from 26 to 44 m through three 6 m stair flights with landings,
120 stone treads, posts and lamps. Maldrek's room and artifact are at 44 m.
The starting forest's existing local terrain remains intact. Crypt remains below
the village; other boss arenas sit at their corresponding chapter elevations.

Collision, navmesh vertices, interaction points, arrivals, scenery, passive
creatures, enemy/companion placement and spell-ground effects agree with the
surface. Relative fall recovery avoids a long fall toward the old global floor.
Kill-history identities keep original authored coordinates. Save schema unchanged.

Godot 4.7.2 actual verification:

- Full campaign/presentation regression, including real bridge traversal with
  a selected companion, elevated arena combat, interactions, saves and finale.
  `.tools/elevation-regression-release.log`: 581 assertions PASS, including stable persistent IDs after elevation changes.
- `tests/check_elevation.gd`: ground collision rays in six regions; citadel
  navigation follows all three slopes/landings. Actual knight climbs from 26 m
  to `(0,44,-56.18)` and walks back down to `(0,26,13.18)` without jumping.
  `.tools/elevation-physics-final-pass.log`. The standalone nav check waits for
  asynchronous map registration, just like normal staged game transitions.
- Native `tests/capture_elevation.gd`: mountain approach and summit stairs
  rendered and inspected. `.tools/elevation-capture-final.log`,
  `.tools/review/elevation-peaks.png`, `.tools/review/elevation-citadel.png`.

Limitations: continuous ramp collision beneath visible stair treads, rigid prop
anchors on sloping terrain; no authored foot IK. No real-phone performance or
human full-campaign acceptance asserted by these checks.
