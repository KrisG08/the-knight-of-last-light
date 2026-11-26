# Fit cosmetic backgrounds after elevation

Date: 2026-11-07. Owner requested grounded, continuous distant terrain.

Positioned horizon roots passed through the rigid-prop branch of the elevation
adapter. One center height could not match a perimeter spanning multiple terrace
heights. The resulting 7–11 m gaps survived headless gameplay checks because
navigation/collision remained valid.

Horizon roots now carry explicit metadata. The elevation pass skips direct
deformation of those roots, and a final presentation pass fits every apron vertex
using Region.height_at, accounting for inherited root elevation and scale.
This pass also runs for the starting forest and enclosed-arena backdrops. Scenery
adds no navigation, collision or new playable geography. Deterministic surface
noise supplies cosmetic rock relief only; authored world/route generation is
unchanged. Terrain texture maps and original sky images are prepared assets.

Atmosphere remains owned by the world runtime. Once its regional fog values are
selected, it supplies a common horizon tint to sky and background terrain. The
background material handles its own slower aerial attenuation to retain distant
detail while closing the far skirt into the same horizon color.

Prevention: a geometric seam/reach check now exercises every region, and can
mount the archived 0.5.20 PCK to prove the original defect. Native capture also
asserts that the requested region was actually entered before taking screenshots.
