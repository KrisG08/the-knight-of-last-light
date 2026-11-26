# Sky, moon and grounded horizons — 0.5.21

Owner request: detailed natural-looking backgrounds, a frightening lunar face,
and no visible map rim floating against a sky-colored void.

The archived 0.5.20 background ended about 170–200 m away. Positioned horizon
roots were raised rigidly by the elevation pass, leaving up to 7 m mismatch in
Peaks and 11 m in the citadel. Region-specific fog colors also did not match the
sky's fixed horizon. These defects combined into a floating-island impression.

New background: 384 angular segments × 64 relief bands, shared smooth normals,
real Rock Face 03 diffuse/normal/roughness maps, soil ledges and distant snow.
Low-frequency deterministic relief affects cosmetic scenery only. Outer terrain
continues to about 6 km and descends through distance haze. No collision or
navigation is added. A final fitting pass samples each apron vertex against the
same authored regional heights, including previously translated/scaled art roots.
All eleven regions have a surrounding background, including enclosed arenas when
seen through openings. The starting forest uses its actual local height callback.

Sky: original generated photographic-style cloud panorama, slow drift and wrap
blend; separate alpha moon-face texture with cloud occlusion and restrained halo.
Sky horizon and terrain aerial haze share the region's fog color. Background
terrain uses gentler explicit distance attenuation so the mountains retain detail
instead of becoming solid-color silhouettes. Desktop 4x MSAA / mobile 2x MSAA;
textures use mipmaps. Camera far plane 6500 m avoids clipping the outer terrain.

Actual Godot 4.7.2 checks:

- Red/green command: `--headless --path . --script res://tests/check_horizon_seams.gd`.
  `-- --baseline` mounts the unchanged archived 0.5.20 PCK before loading region
  scripts. `.tools/horizon-baseline.log`: village 198 m reach FAIL; Peaks 7 m gap,
  190 m reach FAIL; citadel 11 m gap, 172 m reach FAIL.
- `.tools/horizon-final.log`: eleven regions, 385 apron samples each, maximum
  measured height mismatch 0.000 m; outer reach 5.96–6.1 km PASS. This tests
  geometric continuity, not human visual acceptance of every possible view.
- Campaign runner includes moon/panorama presence and shared atmosphere checks.
  `.tools/sky-final-regression.log`: 587 assertions PASS.
- Native sky/edge capture verifies the requested region was actually entered
  before capturing: `.tools/sky-final-native.log`, `.tools/review/sky-*.png`.
  Eleven regions reviewed from north-facing and edge/downward viewpoints.
- Final forest desktop sample: 8.29 ms median / 9.24 ms p95 over 180 stationary
  frames, 121.2 MiB engine static memory on RTX 3050 Ti (.tools/sky-release-performance.log).
  Not phone performance, full campaign performance or total process memory.

The extended terrain remains cosmetic. Existing boundary colliders still define
the playable map. The generated sky is not a physical weather simulator; close
asset geometry and existing scene art retain their own limitations. No claim of
AAA/photographic quality or real-phone acceptance follows from these checks.

Rock source/license: [Poly Haven Rock Face 03](https://polyhaven.com/a/rock_face_03),
CC0; official API download hashes verified. Generated asset paths, exact prompts
and tool mode are recorded in [sky-generation.md](../art/sky-generation.md).
