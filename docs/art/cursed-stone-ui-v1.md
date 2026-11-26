# Cursed basalt UI — 2026-11-08

Original material generated with the built-in OpenAI image-generation tool.
The owner's supplied glowing-stone picture guided the design; it was not
uploaded to generation or copied into the game. No third-party game art or
downloaded texture used. Generated output does not guarantee exclusivity.

Asset: `assets/ui/cursed-stone/basalt-v1.png`, 1254 x 1254, opaque, 3,507,598 B.
Copied unchanged from generated output
`exec-41c8cc50-428d-46f9-a203-6b694d455ae6.png`; original retained.

Exact generation prompt:

> Create a production game UI material texture: a single seamless tile of dark blue-grey basalt / slate stone, square orthographic front view filling the entire image edge to edge. Photorealistic fine pitted mineral grain, layered chipped flakes, small angular rock facets and narrow deep natural hairline cracks, cool charcoal and desaturated midnight blue stone. Restrained contrast and fairly even diffuse illumination: the texture will be darkened behind small readable menu text. Dense physically believable surface detail, small-scale facets rather than large boulders. Absolutely no glowing veins (these will be drawn by the game), no purple, no rim light, no directional spotlight, no gradients across the whole tile, no metal, no frame, no object silhouette, no scene or background, no perspective, no text, symbols, letters, logos or watermark. Seamless repeating albedo-style rock surface, high quality, square texture.

`game/presentation/cursed_stone_style.gd` tiles this texture at native scale
and draws chipped outlines, bevel highlights and three batched fracture passes.
State-specific glow replaces animated shaders. Fractures stay near the rim,
preserving quiet text centers and existing native content margins. This is
2D interface art, not a new 3D environment material. Transparent focus outlines,
meters, sliders and the joystick retain their functional native shapes.
