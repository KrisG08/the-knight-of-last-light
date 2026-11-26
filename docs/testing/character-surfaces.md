# Character surface/detail pass — 0.5.20

The former height-band paint made the Meshy geometry look like smooth colored
clay. This pass restores more source geometry, recalculates welded area-weighted
normals, authors reference-projected texture coordinates and bakes local cavity
occlusion with five short hemisphere rays per vertex. No runtime conversion or
online image/model service. Original GLBs and earlier prepared geometry remain.

Ten characters use the original project character reference images as detailed
surface color, with independent metalness, roughness and projection-confidence
masks. Neutral steel, worn linen, leather, restrained purple/olive/burgundy replace
the saturated blue/yellow/green patches. Rear garments reuse clothing detail;
rear heads sample hair/armor patches rather than repeating a face. Cloth/metal
boundaries still have a palette fallback. Removed the plaster surface and
screen-derivative normal perturbation from all skin/armor. Mipmapped S3TC/ETC2
texture imports support desktop/Android without loading full raw bitmaps in VRAM.

Geometry triangles (old → new):

| Model | Previous | Current |
|---|---:|---:|
| Knight | 23,452 | 46,906 |
| Oren | 17,184 | 34,368 |
| Lyra | 16,230 | 32,462 |
| Cael | 25,538 | 51,076 |
| Goblin | 8,292 | 16,588 |
| Gravedigger | 35,926 | 71,852 |
| Maldrek | 34,764 | 69,528 |
| Fallen Commander | 24,160 | 48,320 |
| Iron Warden | 34,998 | 69,998 |
| Thorn Beast | 32,400 | 64,802 |

Rebuild: run `tools/prepare_meshy_models.gd -- --refined`, then
`tools/paint_meshy_models.gd`, followed by normal Godot import. The latter is an
offline authoring command requiring source PNGs in the excluded art directory.
Runtime loads only prepared painted meshes and imported textures. UV0 is color
projection; UV2.x is roughness; UV2.y packs two 5-bit values (confidence/cavity),
decoded in the vertex shader before interpolation. Both arm and leg skins retain
those arrays. The source input images in reference-colors are unchanged copies.

Actual checks, Godot 4.7.2, RTX 3050 Ti laptop:

- 585 campaign/presentation assertions PASS: `.tools/refined-regression.log`.
- Ten-model geometry, bounds, indices, normalized normals, texture presence,
  packed mask range and limb checks PASS: `.tools/refined-model-checks-final.log`.
- Native front/back/motion views of all ten inspected:
  `.tools/refined-capture-release.log`, `.tools/review/meshy-*.png`.
- Actual knight walk/sprint/attack/dash/guard/idle reviewed in forest lighting:
  `.tools/refined-game-final.log`, `.tools/review/refined-in-game.png`.
- An earlier 180-frame stationary forest sample measured 8.28 ms median,
  10.57 ms p95 and 118.9 MiB engine static memory. This is a single desktop sample,
  not process working set, a full campaign benchmark, or real-phone performance.

Known limits: reference projection retains some baked source lighting, repeats
garment motifs on the rear, and stretches at oblique angles/UV seams. Some source
faces/hair have geometry defects. These are not hand-authored full turnaround
atlases, clean retopology or production character rigs. Further sculpting and
texture authoring would be required for close-up cinematic character quality.
