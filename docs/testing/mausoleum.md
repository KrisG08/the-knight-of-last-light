# Village mausoleum exterior — 2026-11-05

Godot 4.7.2 Mobile renderer. Original geometry using the existing credited kit.

Replaces the old generic crypt box/prism presentation with a stone mausoleum:
tiered cornices, projecting buttresses, steep roof, twin capped towers, layered
pointed portal, iron-bound door, rose-window tracery and warm entrance torches.
Six original grave blockers retain their footprint but now display rounded stone
tablets, plinths, low slabs and carved crosses/inscription lines.

The portal retains the original collision shell, interaction position and transition
to the existing burial encounter. Buttresses and roof panels have simple colliders.
Tower caps, tracery and grave slabs are presentation geometry. No accessible new
building interior or extra boss is implied. No quest/save/reward/enemy changes.

## Verification

- Import: `.tools/mausoleum-import.log`.
- Native bounded capture exits 0: `.tools/mausoleum-capture.log`;
  `.tools/review/mausoleum-entrance.png` and `mausoleum-graveyard.png` inspected.
- Regression: `.tools/mausoleum-tests-final.log`, **516 assertions PASS**; checks village objective routes,
  crypt/boss campaign integration and roof collision above the old shell.
- Separate Windows preview: `build/windows-mausoleum`, `Play-Mausoleum.cmd`.
  All manifest hashes match; packaged headless boot exits 0 with clean
  `.tools/mausoleum-export.log`. No exported interactive acceptance claimed.
  Previous builds/player saves retained; Android 0.5.1 remains the earlier forest
  package until a subsequent Android refresh.

Remaining: interior art, detailed animation/audio, physical-device acceptance,
performance and full manual campaign. No manual traversal or high-end realism
claim from scripted screenshots/headless tests.
