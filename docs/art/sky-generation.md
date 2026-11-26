# Sky art generation — 2026-11-07

Generated with the built-in ImageGen tool, not the fallback CLI/API. Outputs
were copied unchanged into the project and inspected before integration.

- [Curse moon](../../assets/sky/curse-moon-v1.png): 1254 × 1254 RGBA, transparent
  outer background verified (alpha range 0–255; corner alpha 0).
- [Storm panorama](../../assets/sky/storm-panorama-v1.png): 1774 × 887 RGB, 2:1.

The panorama is photographic-style generated art, not a measured HDR photograph.
The shader handles panoramic wrapping, haze matching and separate moon/cloud
compositing. Original generation outputs remain in the Codex generated-images
directory; runtime references only the copies above. No external service is
called by the game.

## Moon prompt

Use case: stylized-concept, physically detailed dark-fantasy game texture. Create a single front-facing full moon disc, perfectly circular and centered, filling 88 percent of a square image. Realistic high resolution lunar basalt, craters and maria in neutral silver grey. A frightening ancient humanoid face is subtly embedded in the lunar geology: two deep crater-like hollow eye sockets with brow ridges, a worn rock nose ridge, and a narrow ominous closed grimace made of impact fractures. It must remain recognizably a real moon with a sinister crater-face, not a cartoon emoji, not a pumpkin, not a human skin portrait. No glow painted beyond its edge, no stars, no scenery, no text, no frame. Soft near-frontal lunar illumination with three-dimensional crater shadows, controlled highlights and dark eye cavities. This is an actual isolated game asset to composite into a procedural night sky. Transparent background outside the circular lunar disc, preserve genuine alpha.

## Cloud panorama prompt

Use case: photorealistic-natural. Asset: seamless equirectangular 360-degree by 180-degree game sky panorama, wide 2:1 aspect ratio. Photographic realism, dark blue-grey moonlit overcast night sky, broad naturally shaped stratocumulus cloud layers with delicate wisps and soft silver edges, fine atmospheric detail and smooth gradients, restrained contrast. The sky should feel like an actual long-exposure landscape photograph, not painted or polygonal. Upper half is a realistic night cloud dome with some clear dark patches; clouds thin into a low pale slate-blue haze toward the middle horizontal horizon. Lower hemisphere is a smooth dark slate gradient with no terrain. Seamless left and right edges, consistent horizon height. No moon, no sun, no stars, no lightning, no buildings, no mountains, no ground objects, no text, no watermark. This is a background texture consumed by a game sky shader; a separate moon is composited later. Do not draw a rectangular framing border.
