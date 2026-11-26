# Poly Haven environment assets

Models/maps downloaded from Poly Haven's official API/CDN on 2026-11-04.
License: CC0 1.0, https://polyhaven.com/license and
https://creativecommons.org/publicdomain/zero/1.0/ .
**Powered by Poly Haven** (credit for API use).

Model source URLs, authors, exact selected resolution, original MD5 and local SHA-256
are recorded in manifest.json. Texture source variants/URLs/hashes are recorded in
each material's source-files.json; only selected 2K JPEG maps are downloaded.

| Asset | Author | Selected files |
|---|---|---|
| Modular Fort 01 | Rico Cilliers | 2K glTF + diffuse/normal/ARM maps |
| Rock Moss Set 01 | Kless Gyzen | 2K glTF + diffuse/normal/ARM maps |
| Dead Tree Trunk | Rob Tuytel | 1K glTF + diffuse/normal/ARM maps |
| Large Castle Door | Tina | 2K glTF + diffuse/normal/ARM maps |
| Forest Ground 04 | Rob Tuytel, Rico Cilliers | 2K diffuse/GL normal/roughness |
| Metal Plate | Rob Tuytel | 2K diffuse/GL normal/roughness/metalness |
| Pine Sapling Small | Rob Tuytel, Rico Cilliers | 1K glTF, three source variations, Godot LODs |
| Fern 02 | Rob Tuytel, Rico Cilliers | 1K glTF, selected source variations |
| Grey Plaster 02 | Rob Tuytel | 2K diffuse/GL normal/roughness |
| Grey Roof Tiles | Rob Tuytel | 2K diffuse/GL normal/roughness |
| Dark Wooden Planks | Amal Kumar | 2K diffuse/GL normal/roughness |
| Cobblestone Floor 02 | Rob Tuytel | 2K diffuse/GL normal/roughness |

Imported models use Godot-generated LODs; textures have mipmaps. Authored placement
uses selected individual modules, canonicalized pivots, shared meshes and no added
physics colliders inside imported meshes. Forest trunks use separate authored physics
proxies outside the road, included in navigation obstacles. Normal maps use OpenGL
orientation. No 8K/whole-library downloads. Full-size pine/fir candidates were rejected
for this pass after metadata showed millions of polygons; the smaller model is reused.
Forest pine canopies select the first Godot-imported simplified index buffer as their
runtime base; useful later LODs are retained, extreme canopy-collapse levels excluded.
Original source files are unchanged. UVs, normal maps and source materials are retained.
Do not attribute these scans to the game's original procedural art author.
