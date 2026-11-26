# Offline native model parts

Lossless cached output of the existing source partitioners. Regenerate with
Godot --headless --path . --script res://tools/prepare_native_parts.gd.
No triangles, vertex attributes, texture resolution or material quality were
reduced. Controllers, pivots, transforms and collision are unchanged.

crusader-knight: Andy Woodhead via afk.ai, CC BY 4.0; see
assets/vendor/andy_woodhead/README.md and docs/ASSET_CREDITS.txt.
strong-knight: DJMaesen via afk.ai, CC BY 4.0; red-fox: Alexei Ostapenko via
afk.ai, CC BY 4.0. Original sources/credits remain in assets/vendor/hostile_sources
and docs/ASSET_CREDITS.txt. Catalogs are modified derivatives under those terms.

Runtime loads the compressed Resource catalogs once per process. Original
partition functions remain for offline regeneration and equivalence checks.
tests/native_parts_checks.gd compares all mesh arrays, part/surface order and
material appearance against freshly converted source geometry.
