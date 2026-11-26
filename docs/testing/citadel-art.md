# Citadel / ritual architecture — source increment, 2026-11-06

Added stone pillar shafts/capitals/spires over the six original colliders,
wall buttresses/crenels, external corner towers, processional paving, timber/iron
ascent portal, individually modelled prison bars and low relief lore tablet.
Replacement bars remain children of the original authoritative gate, so rescue
visibility and collision still follow campaign state. The ritual arena now has a
closed barrel vault, repeated ribs, wall shafts, four lit torches and cool fill,
thin ritual floor inlays and a faceted artifact attached to the original seal.

Original collision bodies, navigation, spawn/interaction points and encounter
rules are retained. This is an architectural increment; broad flat wall areas,
repeated geometry, simple wizard silhouette and sparse set dressing still need
art work. No final quality or FPS acceptance is claimed.

Native `tests/capture_citadel_art.gd` completed successfully. Processional courtyard
and ritual hall captures inspected. Images under `.tools/review/citadel-*.png` and
`ritual-*.png`; import/capture logs `.tools/citadel-art-{import,capture}.log`.
Automated campaign: 533 assertions PASS, exit 0, recorded in
`.tools/citadel-art-tests.log`.

Not yet in a packaged build. `Play-Session.cmd` currently contains the earlier
Order/Peaks/forge/audio/skeletal increment, not this citadel work. Published Android
remains 0.5.2. Next: review prison/ascent/artifact closeups,
then rebuild cumulative packages with matching Windows/Android version and scripts.
