# Village trades and yards — 2026-11-05

Godot 4.7.2, Mobile renderer. New authored prop composition in the existing village.

## Changes

Two abandoned market counters with timber framing and sagging canopy strips, one
partly torn; four storage groups with banded crates and barrel hoops; two stacked
woodpiles, two stone water troughs, interrupted picket yard fences, a laundry line,
gutters/downpipes and small localized rubble groups. Original weathered-canvas
shader gives linen/canopies a coarse weave, stains and subtle motion.

Counter, canopy, trough, storage and woodpile proxies are world colliders. New
footprints are included before the village's final navigation rebuild. Fine fence
pickets, hanging laundry and small rubble are decorative. Geometry is original,
reusing the existing credited material kit. No external downloads or new licenses.
Timber details are batched; two extra unshadowed market torches are local lights.
Campaign, enemy placement, quests, rewards and save schema remain unchanged.

## Evidence

- Import: `.tools/village-life-import.log`.
- **513 assertions PASS**: `.tools/village-life-tests.log`. Includes actual routes
  from village spawn to checkpoint, Oren, token, crypt, forest gate and return;
  new checks cover market canopy and storage collision.
- Bounded native review: `tests/capture_village_life.gd`,
  `.tools/village-life-capture-final.log`; screenshots under `.tools/review/`.
  East market and west yard compositions inspected. Scripted captures are not a
  manual playthrough or performance benchmark.
- Separate Windows preview: `build/windows-village-life`, `Play-Village-Life.cmd`.
- Exported headless boot exits 0 (`.tools/village-life-export.log`); manifest
  payload hashes verified. No exported visual/manual-playthrough pass claimed.

## Limits

Village horizon, terrain variation, natural ground layering and richer building
interiors still need work. Thin fences/decorations do not block actors. No actual
phone test or performance certification. Android 0.5.1 still contains the preceding
forest increment; this village pass needs a subsequent Android export. Older
builds and existing player saves retained.
