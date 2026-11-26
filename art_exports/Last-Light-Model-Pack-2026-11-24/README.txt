LAST LIGHT - MODEL COLLECTION - 2026-11-24

01-Images-For-3D: 52 selected PNG design references. Use individual images if
your chosen image-to-3D tool accepts pictures. These are original concept
references, not screenshots or proof of the resulting mesh quality. Open the
index.html gallery after extracting. No upload to Canva has been performed.

02-GLB: static, self-contained 3D files: assembled character variants, player,
villains with equipment, passive creatures, quest props and imported source art.
03-Worlds: all eleven authored region scenes as static GLB geometry. Buildings,
landmarks, placed props and vegetation are included here, even when they are
normally constructed by code rather than stored as separate model files.
Whole-world exports use simple untextured colors to keep these large geometry
snapshots portable; use the native sources for the original world materials.
04-Godot-Sources: native RES geometry, source GLB/GLTF files, textures, shader
definitions and presentation/region builders. Original paths are preserved.
This is an art-source collection, not a standalone runnable game project.

The GLBs are static geometry snapshots, not complete Godot scenes, game logic,
collision/navigation data, animations or ready-made character rigs. Instanced
geometry is expanded into scene nodes. Native shaders are approximated by
standard materials; Meshy front/rear coloring is baked to vertex colors to avoid
white exports. Portable albedo textures are limited to 1024 pixels; separate
normal/roughness/metallic/AO maps are omitted in favor of scalar materials.
The original full-resolution texture files remain in 04-Godot-Sources.
Animated curse/portal effects, wind, triplanar shading, microscopic
surface wear and lighting will differ from the game. Original sources are kept
alongside for work requiring full fidelity. Do not treat a world scene as one
small image-to-3D object: use individual references for object conversion.

GLB does not imply compatibility with every Canva app. The selected app's input
requirements determine whether to use a PNG reference or a 3D file. These assets
are already 3D; generating a new mesh from one picture is a separate operation.

models.json lists exports, source roles and instance counts. files.json records
file sizes and SHA-256 values. The 47 individual GLBs were read back by Godot;
all 58 files, including the large worlds, pass structural container/mesh/buffer
checks in the packager. Third-party source attribution remains applicable;
Godot's direct GLTFDocument preview may require explicitly enabling vertex
colors on imported character materials; the GLB COLOR_0 data is present.
read ASSET_CREDITS.txt and the original vendor licenses. No author endorsement.
No account configuration, API credentials, user saves or private attachments.
The playable game and its assets have not been modified by this collection.
