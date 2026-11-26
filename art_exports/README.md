# Original model exports

Static GLB snapshots of the original code-authored meshes used by this art pass:
knight_v2, gothic_lantern, gothic_arch and dead_tree. Generated with Godot's GLTF
exporter using tools/export_art_models.gd and verified by importing each file back.

These are editable low-poly starting assets, not externally generated photorealistic
or rigged production characters. The game uses the authored builders in
game/presentation/ so its combat weapon pivot and basic leg cycle stay live. The
knight GLB is a static mesh assembly without a skeleton/animation clips. The lantern
and arch embed the generated limestone material where applicable. Tree is bare bark.

This folder is ignored by Godot import/export to avoid duplicate runtime assets.
Open the GLBs in a 3D editor or viewer. Material/prompt provenance lives in
assets/materials/README.md. Public distribution licensing has not been selected.

These original snapshots predate the realistic-asset pass. The active hero now uses
the credited CC-BY Andy Woodhead sample under assets/vendor/andy_woodhead; these
older original GLBs remain available and are not relabeled as that creator's work.
