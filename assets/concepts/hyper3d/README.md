# Hyper3D image-to-3D trial inputs

Created 2026-11-06 with the built-in imagegen tool at the owner's request.
These are original raster concept references, NOT generated 3D models.
No game models have been replaced by these images. The owner signed in to the
Hyper3D workspace, but browser control was stopped with physical Escape before
a confirmed upload/generation. No 3D generation has been submitted or charged.
An expanded 52-object image package is now in art/reference-pack; its selected
images and offline gallery are in build/Last-Light-Reference-Images-52.zip.

- `goblin-scavenger-v1.png`: full-body neutral A-pose, separated limbs, realistic
  olive skin, worn leather/linen, no carried weapon or environment.
- `roadside-shrine-v1.png`: isolated gothic stone shrine, three-quarter view,
  integrated footing, carved knight relief and weathered limestone.

## Proposed first conversion trial

Upload one image per object in Rodin Image-to-3D. Keep the two subjects in separate
jobs. Prefer GLB and PBR material output. Start with a modest topology budget for
the shared Windows/Android target; do not assume the API's default geometry size
is mobile-ready. Confirm any credit charge before paid generation. Do not create
an account, API key or subscription automatically.

Official documentation checked: https://docs.hyper3d.ai/en/api-specification/rodin-gen2-5
Supports GLB/PBR; Raw medium is documented as 500,000 faces, so it needs explicit
budget control or simplification before use in this game's mobile scenes.

After conversion: verify actual geometry/texture output, proportions, feet/base
origin, front direction, UVs/normals, materials, triangle/material count and usage
rights. Import first into an isolated Godot review scene, then test under the
game's lighting and Android rendering profile. Character movement requires a
usable rig or a separate rigging pass; image-to-3D is not proof of animation.
Preserve the original downloads and existing actor gameplay/collision authority.

Full source image prompts are in `prompts.md`. No source files, saves or private
account data are intended for upload, only these two generated concept images.
