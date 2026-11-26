# Character surface atlas

Rejected by the owner on 2026-11-24. Preserved as an art trial outside runtime
assets. The final implementation instead uses the original front references and
matching rear views under assets/models/meshy/rear-reference-colors.

Original project material artwork generated with the built-in OpenAI ImageGen
tool on 2026-11-24. Source dimensions: 1254 x 1254. Runtime use is one shared
texture; the shader selects the appropriate inset quadrant using authored
metal/roughness masks, normalized in linear color to preserve character pigments.
It provides material detail, not baked directional illumination or model geometry.
Original inputs and previous painted meshes remain preserved. No to3D output
is used. Credited Meshy geometry retains its existing attribution.

Quadrants: upper left forged steel, upper right weathered leather, lower left
undyed linen, lower right charcoal-violet wool. Rest-space triplanar sampling
avoids rear picture projection and keeps the finish attached during movement.

Generation mode: built-in image generation, new asset, no reference image.
Final prompt:

Create ONE production game material texture atlas, a single square image divided
into EXACTLY four equal quadrants in a precise 2 by 2 grid with no gutters and no
border. This is an original dark fantasy character material atlas, not a concept
illustration, and must be flat unlit base-color texture scans viewed perfectly
orthographically from above. Entire surface covered edge to edge with material.
TOP LEFT quadrant: real weathered forged steel, medium neutral cool grey, fine
irregular scratches, tiny oxidation pits and very subtle mottling, no diamond
plate pattern and no large patches. TOP RIGHT quadrant: realistic old dark brown
leather, supple fine pores, subtle rubbed wear and small creases, no stitches,
belts, buckles, buttons or recognizable objects. BOTTOM LEFT quadrant: aged
undyed oatmeal linen, realistic dense fine woven fibers, irregular restrained
dirt and wear, no logos, no folds with strong baked shadows. BOTTOM RIGHT
quadrant: dark muted charcoal-violet woven wool, tiny intricate subtle thread
texture, weathering and faded fibers, no symbols and no large ornamental shapes.
All four quadrants should have even neutral diffuse illumination, no directional
shadows, no glints, no vignettes or edges. Each quadrant is its own small-scale
repeating seamless material swatch, with no zoomed-out objects or perspective.
High-frequency photoreal surface detail, believable organic irregularities,
sharp quality suitable for actual 3D armor and clothing. NO text, labels,
watermark, frame, objects, characters or scene.
