# Authored elevation across existing regional layouts

Date: 2026-11-07. Owner request: terrain should climb through mountains into a
castle on the highest summit; stairs lead to the magician.

Use fixed, authored regional terrace profiles in `world/regions/elevation.gd`.
Apply them once during staged region construction. The existing route graph,
landmarks, encounter ownership and saves remain intact. Subdivide structural
floor/wall meshes and derive matching collision from the raised geometry;
raise navigation vertices and interaction/arrival points using the same function.
Props remain rigid at their anchor, and MultiMesh instances move individually.
Passive inhabitants receive terrain-aware stroll heights. Combat actors spawned
later resolve their authored homes onto the surface.

The three citadel flights have 40 stone treads each. A continuous collision ramp
under each flight gives smooth traversal with the existing CharacterBody motor;
rendered ground is cut away under the tread corridor. This avoids introducing
an untested automatic step solver. Slope is at most 0.5 (26.6 degrees).

Prepared/source art assets are preserved, with regional runtime copies where
geometry must change. No runtime world generation, physics snapping every frame,
save schema change or external terrain plugin. Persistent enemy IDs retain
authored home coordinates so an elevation update does not split kill history.

Tradeoffs: wide areas still use authored terraces, positioned buildings retain a
single foundation anchor, and tread collision is a smooth ramp rather than each
individual riser. More bespoke winding cliff routes can refine this increment.
