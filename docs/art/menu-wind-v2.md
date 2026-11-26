# Layered wind menu — 2026-11-08

Original project artwork generated with the built-in OpenAI image-generation
tool. No third-party game screenshot supplied as a generation reference.
The previous panorama is preserved. Generated output is not a legal guarantee
of exclusivity. The original layers are illustrations, not simulated 3D cloth.
Version 0.5.29 displayed them live; version 0.5.30 bakes the wind scene into a
real twelve-second looping Ogg Theora film for the menu. The original layers
remain as a fallback. Playback uses Godot's built-in decoder, without network
requests or third-party extensions.

Runtime assets in `assets/ui/menu-wind/`, copied unchanged from the owner's
Codex generated-images folder:

| Asset | Source output | Dimensions |
| --- | --- | --- |
| landscape.png | exec-4a1c97dd-d2c7-4763-9c42-fe12679771cb.png | 1672 x 941 |
| knight.png | exec-58ce12f0-fb25-4866-ba14-12cf8d7c7d30.png | 1024 x 1536, alpha |
| foliage.png | exec-a5b355ad-4cf8-4af2-85f8-e5acbe9b0993.png | 1536 x 1024, alpha |

Generation prompt directions (condensed):

1. Original cinematic realistic dark fantasy night panorama. Keep the upper-left
   60% quiet blue-black sky, empty through the upper 48% for a title. A winding
   wet stone forest path leads to a detailed Gothic castle on a mountain at
   center-right, highest spire below the title zone. Ferns, moss and dark forest
   in the lower half, trees along the far right. Moonless cold night, restrained
   warm windows. No knight, lettering, logos, interface or watermark. Do not
   recreate an existing game's artwork.
2. Transparent full-body rear three-quarter knight, facing upper-right, matching
   the cold night scene. Worn realistic dark steel armor, sheathed sword at
   right hip. Burgundy sun-embroidered cloak hangs and flows to the left, with
   visible fabric folds. Rigid armored body to the right, cloth to the left.
   Entire silhouette and boots visible, no background, text or logos.
3. Transparent connected foreground cluster of realistic damp ferns, long grass
   and a drooping conifer bough. Root at bottom-left, flexible tips reach upward
   and right. Cool dark green night lighting, fine needles and leaf detail.
   No soil rectangle, sky, text or logos.

Animation: UV displacement restricted to flexible cloak fabric and rooted
vegetation. Armor and castle UVs stay fixed. Restrained low mist, window glow
and separate motes; motes exclude the whole title/tagline rectangle. A shared
explicit clock freezes all layers when Animated menus is disabled and avoids
a pose reset. Layers are hidden during the active-journey pause menu.

The version 0.5.30 film has stronger silhouette displacement, anchored shoulder
and armor masks, rolling twelve-second cloud advection from the project's
original storm panorama (see `sky-generation.md`), rooted plant bending and low
mist. Dual cloud phases crossfade over their reset, avoiding backwards drift.
The right-hand tree silhouettes are excluded from sky compositing. Integer phase
harmonics return all wind layers to the same pose at twelve seconds. It is
rendered at 1280 x 720, 30 fps, 360 frames, without baked text or audio.
The menu overlays normal localized controls on the movie. The stream pauses
when hidden or when Animated menus is disabled; aspect-cover scaling prevents
stretching or borders on wide phones.

Five-language headings fit their explicit line breaks using the actual locale
font. Text is measured independently from artwork; no knight or foreground
vegetation intersects the protected title/tagline region at tested aspects.
