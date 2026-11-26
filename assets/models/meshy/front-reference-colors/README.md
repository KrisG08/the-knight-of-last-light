# Mesh-guided front character paint

Created 2026-11-24 using built-in OpenAI ImageGen from two project inputs per
character: actual orthographic runtime renders and the original character concept
in `../reference-colors/`. The owner requested improved front surfaces after the
rear-texture pass. These ten RGBA images are projected onto existing meshes,
not new geometry or generated rigs. Original concepts and all original painted
resources remain unchanged. Geometry still carries its separate Meshy credits.

`tests/capture_front_paint_guides.gd` produced the original pose/shape guides in
`.tools/review/front-guides/`. `tools/fit_front_references.gd` records alpha crop
and model span in the model JSON. The runtime shader uses rest-space X/Y with
the correct front-camera handedness. Alpha excludes background while preserving
pale cloth and steel; it no longer depends on the diagonal front UVs or the
gray-background luminance rejection. Rear references remain enabled separately.
`tools/build_front_uv_coverage.py` creates nearest-covered UV coordinate fields
using Python's standard library, then the fitter saves native data textures in
`../front-uv-coverage/`. These encode coordinates only; no generated color PNG is
edited. The shader samples nearby covered paint at small outline/pose gaps to
avoid unpainted gray patches. Rebuild: run the Godot fitter with `--masks-only`,
run the Python helper, then run the fitter normally and import. Coordinate data uses nearest filtering
and two 16-bit coordinates packed in RGBA8, not sRGB color.

This is paired projection, not manually unwrapped production texturing. Side
views, deep overlaps and generated-image landmark differences remain limitations.
Original body geometry, collision, rig partitions and motion are preserved.

## Final prompt set

Shared constraints for every generation: image 1 controls actual silhouette,
pose, limb and head centers and full-body framing; image 2 supplies original
identity, colors and material design. Clean coherent front albedo, photographic
detail, transparent background, neutral diffuse light and restrained AO. No
cast shadow, dramatic baked highlights, text, props, weapons or costume redesign.
Correct duplicated/smeared details instead of retaining the angled projection.

- Knight: weathered gray steel and aged brass, ivory woven tabard with one
  centered muted ochre sun, brown belts, coherent helmet vents, gloves and boots.
- Oren: rugged middle-aged blacksmith, salt-and-pepper hair/beard, natural skin,
  cream rolled-sleeve linen, dark brown leather apron/pockets, straps and buckles.
- Lyra: coherent natural face, tied-back dark hair, muted olive short embroidered
  mantle and bronze clasp, worn brown leather armor, ivory sleeves and bracers.
- Cael: weathered older face and gray hair/beard, gray steel, dark navy tabard
  with one pale broken-ring emblem, chainmail and brown belts.
- Goblin: scarred wrinkled muted olive skin, sparse hair, hooked nose, amber eyes,
  brown leather waistcoat and toggles, patched burlap trousers and worn boots.
- Gravedigger: one gaunt pale face inside peaked hood, stringy gray hair, ragged
  charcoal-brown coat/capelet, cloth patches, leather strap, gloves and boots.
- Maldrek: aged stern face, long silver-gray hair and goatee, charcoal layered
  robes, muted plum panels, silver embroidery, clasps, chains and waist medallion.
- Fallen Commander: closed crowned helmet, ornate gray steel and aged brass,
  navy cloak/tabard, one sword-and-thorn chest emblem, coherent visor and rivets.
- Iron Warden: bulky dark iron and muted rust, coherent cage visor with dim ember
  eyes, layered plates/rivets, brown leather straps and ragged brown cloth skirt.
- Thorn Beast: frontal planted quadruped, clear central snarling wolf face,
  dark gray-brown fur, bark armor and branching thorn antlers, olive moss, pale
  teeth and claws. Bark antlers must not look like flat tan plastic.

All generated files were copied into this runtime directory before use. Source
generation filenames are retained in `.tools/review/front-reference-sources.json`.
