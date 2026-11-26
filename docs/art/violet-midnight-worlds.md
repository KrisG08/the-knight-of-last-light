# Violet Midnight world direction — v0.5.61

Owner requested an original image for every region from camp to final castle,
then an in-game environment update following those targets. The first image
review requested a darker and more violet palette. The three supplied references
inform atmosphere and composition only; their pixels are not shipped as game art.

## Concept provenance

Eleven original PNGs generated using the built-in OpenAI ImageGen tool for this
project on 2026-11-21 are preserved in `art_exports/world-concepts-v061/`.
Earlier blue variants remain in `originals/`. The folder is excluded from Godot
imports and release packages. The local `index.html` gallery distinguishes target
illustrations from separate, unedited native-renderer screenshots.

Common generation direction: realistic dark fantasy environment, midnight violet
and indigo sky, muted forest greens, dim lavender moonlight, small warm amber
practical lights, clear navigable path, layered Gothic architecture, atmospheric
depth, no UI or text. The references' pixel style is not adopted.

| Image | Target | Implemented authored additions |
|---|---|---|
| 01-camp | Last Camp | Cloth tents with sag, parted entrances, poles, ropes and pegs; ruined chapel facade, rose tracery, belfry and forest framing |
| 02-village | Ashen Village | Peripheral bell tower, rose tracery, arches and amber light |
| 03-blackwood | Blackwood | Ruined abbey facade, pointed arch, rose window and buttresses |
| 04-order | Order's Ruins | Rose gateway, cloister ribs, buttresses and plum banners |
| 05-peaks | Ashen Peaks | Monastery crown, bell towers and aqueduct window details |
| 06-citadel | Eclipse Citadel | Rear cathedral, layered spires, side towers, buttresses and smaller front gate windows |
| 07-crypt | Burial Crypt | Vault ribs, rear rose window, banners and amber lamps |
| 08-grove | Root Grove | Elevated arch framing, rose window, peripheral belfries and lamps |
| 09-sanctum | Commander Sanctum | Vault ribs, tracery and plum banners |
| 10-forge | Forge Fortress | Vault ribs, rear tracery and warm light contrasting the curse |
| 11-ritual | Ritual Hall | Higher vault ribs, large rose window, banners and amber lamps |

## Runtime implementation

`region_look.gd` owns the cursed-night palette. Existing restored-dawn lighting
still applies after campaign completion. Sky, fog and background atmosphere share
the final color choices to avoid separate color seams. `storm_sky.gdshader` has an
opt-in violet-night treatment; existing cinematic render tools default to their
previous appearance. Main menu and opening videos have not been re-rendered.

`concept_landmarks.gd` builds fixed authored compositions, with batched stone
blocks and one shared rib mesh per region. Existing credited Poly Haven surfaces,
project wood/iron and previously credited scanned trees are reused. The chapel,
tents and nearby trunks have collision and navigation footprints. Tent placement
was adjusted after a real spawn navigation failure. Above-floor/peripheral
architecture preserves the existing combat space and progression gates.

No new paid asset, external model, dependency, save schema or combat behavior.
All new geometry is original project work. Existing third-party material credits
remain applicable in ASSET_CREDITS.txt.

## Visual limits

This update implements the palette and architectural direction, not a pixel-for-
pixel reconstruction of the generated illustrations. Existing tree cards, terrain
textures, repeated modular buildings and lightweight material lighting remain
visible. Target art has richer organic forms and indirect illumination than the
current mobile renderer scenes. No claim of AAA photorealistic parity is made.
The sky moon's prior face remains by owner direction; its edge/cloud integration
still has room for refinement. No physical Nothing Phone 3a test was performed.

Raw comparison captures use a dedicated 1.8 m showcase camera, hide hero/HUD/
hostiles, and do not represent the default third-person gameplay framing.
