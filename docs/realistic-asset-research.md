# Realistic asset selection and integration

Reviewed primary provider/creator pages on 2026-11-04, following the owner's request
to search for realistic assets and integrate compatible ones. No purchase, account
creation, credential use or engine switch was performed.

## Downloaded and actually integrated

| Resource | Source / license | Integration |
|---|---|---|
| Modular Fort 01 | https://polyhaven.com/a/modular_fort_01 · CC0 | Individual 2K stone gate/wall/tower modules; shared mesh cache; refuge and selected later regions |
| Rock Moss Set 01 | https://polyhaven.com/a/rock_moss_set_01 · CC0 | Scanned boulders along authored off-path placements |
| Dead Tree Trunk | https://polyhaven.com/a/dead_tree_trunk · CC0 | Scanned fallen wood details in refuge/forest/Peaks/village |
| Large Castle Door | https://polyhaven.com/a/large_castle_door · CC0 | Complete textured rear chapel door, decorative against existing collision wall |
| Forest Ground 04 | https://polyhaven.com/a/forest_ground_04 · CC0 | Real diffuse/normal/roughness ground; restrained albedo for night lighting |
| Metal Plate | https://polyhaven.com/a/metal_plate · CC0 | PBR maps on authored iron kit and fallback knight steel |
| Medieval Knight by Andy Woodhead | https://sketchfab.com/3d-models/medieval-knight-rigged-for-ue45-1c7a83c0832a4ab28d9f1a46d282fcf9 · CC BY 4.0 | Public simplified static copy from https://afk.ai/samples; actual player visual, adapted pivots/pose/materials |

Poly Haven license: https://polyhaven.com/license . API policy/source:
https://github.com/Poly-Haven/Public-API . Powered by Poly Haven credit is included.
The knight distributor explicitly lists Andy Woodhead / CC BY 4.0 and describes its
samples as simplified copies. It is a licensed redistribution, not a bypass of the
original store's account/download controls. All creator/source/license/change credits
are bundled in ASSET_CREDITS.txt and named in the in-game credits.

The knight sample contains no skin/animations. The adapter retains its textured
surfaces/UV/normal maps, normalizes the model and partitions left/right limbs into
procedural pivots. The existing combat pivot still owns swing timing; walk uses the
existing basic hip cycle. This improves the actual in-game model but is not a
production skeletal rig or animation-retarget deliverable.

## Suitable candidates requiring licensed files or conversion

| Candidate | What primary listing provides | Decision |
|---|---|---|
| [Gothic Ruins Modular Asset Pack](https://www.artstation.com/marketplace/p/klPrg/gothic-ruins-modular-asset-pack) by Alexey Borisov | Paid FBX/OBJ/BLEND/STL kit, 8K textures, listed archive about 4.1 GB | Generic mesh formats are viable for Godot after purchase and optimization; not bought/downloaded. Verify topology, game budget and purchased license before choosing. |
| [Medieval Knight With Sword - Rigged](https://www.fab.com/listings/d1bc23e5-22d3-4e2d-9616-c4e3a62c8439?lang=en) | Paid rigged knight listing with GLB/FBX/BLEND/OBJ | Viable licensed alternative for future rigged-animation work; not bought. A usable rig is not proof it includes the game's attack clips. |
| [Gothic Cathedral](https://www.fab.com/listings/015c9305-2af0-465e-a1e5-f1b99ce2b528) | Unreal Engine-only package, 300+ models, distance-field material workflow; knight excluded | Not directly importable as a Godot scene. Would require licensed source mesh export, material reconstruction and major optimization; not installed. |
| [Modular Gothic Cathedral](https://www.fab.com/listings/e60f3282-dcdd-4b8b-99c4-bc89f2120984) | Unreal-only, Nanite/Lumen/RVT/PCG/World Partition | Not a direct Godot install. Engine-specific tools/shaders do not transfer with meshes. Not installed. |
| [Knight Sir Roland](https://grigory-petrov.itch.io/knightroland) | Creator describes free/name-your-price low-poly rigged knight with five clips and PBR | Not selected: low-poly direction is not the requested increase in realism, and it is not necessary to replace a better visual sample merely because clips are included. |

No marketplace price promise is made; listings change. The paid candidates are
research options, not purchase recommendations based on an untested download.
For this 4 GB VRAM laptop, use a curated set with 1–2K maps/LODs instead of importing
entire 8K showcase scenes. Godot Mobile/PBR remains the verified renderer; switching
to Unreal or claiming Nanite/Lumen quality would not follow from buying a pack.
