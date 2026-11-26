# Village terrain and backdrop — 2026-11-05

Godot 4.7.2 Mobile renderer. Original presentation work reusing existing credited
Poly Haven maps and meshes; no additional external assets or licenses.

## Implemented

World-space terrain material blends cobbles along main/side streets and the square
into soil at yard edges, with irregular transitions, roughness and cobble normals.
The existing burial-seal appearance change now sets a shader tint; the old standard
material fallback remains. Physical ground and navigation surface stay unchanged.

Ten authored foundation/yard/grave-edge patches hold 950 low grass tufts, batched
in one MultiMesh. Eighteen wider outer trees and a 576-triangle ridge skirt conceal
the empty horizon behind the village fence. Shared horizon builder accepts region
extents; original forest defaults remain. Backdrop vertices stay outside the village
40x45 half-extents. Hills are scenery, not new explorable areas.

## Verification

- Import log: `.tools/village-landscape-import.log`.
- Regression log: `.tools/village-landscape-tests-final.log`, **515 assertions PASS**; covers village story
  connectivity and forest road, plus actual seal-driven shader tint changes and
  outside-bounds village backdrop geometry.
- Native rendered capture: `.tools/village-landscape-capture.log`, exit 0. East
  market view inspected: soil/stone transition, peripheral grass and wooded slopes
  visible. No new shader compile errors. Initial capture exposed an old direct
  `albedo_color` assignment; corrected to support the new terrain shader before
  the final capture/test run.
- Separate preview: `build/windows-village-landscape`,
  `Play-Village-Landscape.cmd`. Earlier builds and save files retained.
- All exported manifest hashes match. Packaged headless boot exits 0 with clean
  `.tools/village-landscape-export.log`; no exported visual-playthrough claim.

## Limits

No new walkable land, interior, quest or encounter. No real phone/FPS certification,
full manual campaign or exported interactive pass claimed. Current Android link
still serves 0.5.1 forest content; village additions need a later APK refresh.
Vegetation and distant hills still need further art review.
