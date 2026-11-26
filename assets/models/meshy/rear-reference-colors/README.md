# Reference-faithful rear character paint

Generated 2026-11-24 using built-in OpenAI ImageGen with each original front PNG
in `../reference-colors/` as its reference. The owner rejected a proposed new
palette and requested the colors of the original 2D images instead. Original
front PNGs, meshes, UVs and pigment resources remain preserved. These are texture
references applied to the existing models, not new 3D geometry or to3D output.

Runtime fitting: `tools/fit_rear_references.gd` records crop and body span in the
existing model JSON. `meshy_surface.gdshader` samples front or rear using original
rest coordinates and normals, so paint follows articulated limbs. Back references
do not copy faces, chest emblems or front fastening details onto the back. The
knight rear uses a neutral studio background; the other nine use alpha cutouts.
This remains a paired projection method, not a manually unwrapped production
texture atlas; oblique-side and silhouette alignment can still differ.

Final prompt set, built-in image editing/reference generation:

- Knight: exact full-body square rear view of the same closed-helmet knight;
  original weathered gray steel, muted brass, dirty ivory tabard and brown belts;
  plain back without the chest sun; no invented cape, shield or weapons.
- Oren: same middle-aged blacksmith, dirty cream rolled-sleeve shirt, dark brown
  leather apron with plausible rear straps/ties, dark trousers and brown boots;
  rear hair without a face or duplicated apron pockets.
- Lyra: same scout, worn brown leather, dull olive short shoulder mantle,
  off-white rolled sleeves, dark tied-back hair, brown trousers and boots; short
  mantle remains short, no bright green or redesign.
- Cael: same veteran, weathered steel, faded navy tabard, brown belts and gray
  hair; broken-ring emblem stays on the chest and is absent from the back.
- Goblin: same muted olive-brown skin, long ears, sparse hair, patched dark brown
  vest, burlap trousers and boots; rear seams without front buckles or buttons.
- Gravedigger: same gray-brown hooded patched coat, frayed cloth, brown leather
  gloves, straps, trousers and boots; no invented green or purple palette.
- Maldrek: same charcoal robes with faded dark plum panels and muted old
  metallic embroidery, gray hair; no bright purple or yellow-gold stripes.
- Fallen Commander: same engraved gray steel, aged brass, faded navy cloak and
  tabard, crowned helmet; no red recoloring or repeated chest heraldry.
- Iron Warden: same dark riveted iron with rust/heat discoloration, brown leather
  and dirty torn apron; rear armor and ties rather than a duplicate barred visor.
- Thorn Beast: same brown fur, gray-brown bark, gnarled wooden antlers with worn
  pale edges and sparse olive moss; rear haunches/back of head without a face.

Shared prompt constraints: match original palette/proportions/wear; full subject
visible with margins; direct square rear view; neutral standing/relaxed A-pose;
hands separated, feet apart; no scene/floor/shadow, text, labels, watermark,
collage or additional props; neutral even lighting and photoreal surface detail.
Transparent background was requested for all except the first knight image.
