# M5 Gravedigger, Burial Seal and Blackwood entrance — 2026-11-04

Engine: Godot 4.7.2.stable.official.ed1daf0bf, Windows x86_64, Mobile/Vulkan.

## Implemented

The village crypt entrance leads to a separate roughly 18×18 m fighting area. Boss
starts dormant with 420 HP and rejects pre-encounter hits. Stepping into the arena
starts the fight and closes the physical entrance ward. Boss stays inside its arena.

Authored sequence: sweep (0.8 windup / 0.25 active / 1.2 recovery), overhead slam
(1.2 / 0.18 / 1.6), advancing grab (1.0 / 0.30 / 1.5). Physical defense 8; damage
22/28/26 before player defense; guard cost 35/50/100. Grab advances slowly in its
captured facing and respects dodge invulnerability. Different shovel motion, color,
state text and synthesized windup cue announce attacks. Damage uses the existing
continuous swing/claim mechanism. No live summons, overlapping attacks or debug
defeat button. At ≤210 HP, one phase transition cancels outgoing damage, pauses
1.4 seconds and adds a delayed localized ground burst (1.4 windup, radius 2.4 m).
The burst is separate from grab/sweep/slam and can be escaped or dodged.

Death/respawn unloads the encounter; unfinished boss re-entry restores 420 HP, phase
one and no pending hazard. Defeat clears attacks and the barrier before committing
one DefeatBoss command with its 180 XP / 80 shards. Region state exposes Burial Seal
interaction. Breaking the seal is separate, requires the defeated guardian and has
no duplicate boss reward. Save between victory and seal works. Existing M4 campaign
slots use the same schema and save location; training slots remain separate.

Village ward derives collision/visuals from the seal fact. A warmer village floor
and opened ward show weakened corruption. Blackwood is a separately loaded playable
entrance with authored trees, path, bounds and return passage. First visit completes
the chapter-one objective. Return spawns near the village ward without retriggering.
The deeper forest is visibly a future route; there is no claim of a complete forest chapter.

## Executed evidence

`powershell -ExecutionPolicy Bypass -File .\Test.ps1`: clean import and prior M0–M4
plus M5 assertions. Final suite: **164 assertions PASS**, exit 0. New checks cover
locked forest rejection, dormant immunity/entrance, fight trigger/barrier, rest
rejection, real sweep damage and uniqueness, raised harmless slam windup/lateral
avoidance, actual physics-driven grab advance and dodge, one-time phase transition,
burst escape/cleanup, death/reset, one-time reward, reload with dead boss/intact seal,
actual seal interaction, ward collision, forest construction/return/chapter and reload.
Runtime stores are memory-only; existing isolated Windows-file tests cover the shared
adapter. No player saves were created/reset by automated testing.

Native render command: portable console engine `--path . --position 2400,1400 --script
res://tests/capture_burial.gd`. Exit 0, Mobile/Vulkan on RTX 3050 Ti Laptop, no engine
errors. Inspected actual viewport PNGs `.tools/review/crypt_slam.png`,
`crypt_burst.png`, `blackwood_entrance.png`; boss bar/text, raised shovel, distinct
burst marker and forest are visible. Capture uses memory-only state, scripted boss
poses/hits and valid semantic seal action; it is visual QA, not a human victory claim.

## Pending

Human boss playtest: camera near arena walls, lock/block/dodge timing, fairness and
clear telegraphs; lose/retry, win, quit before seal, reload, break seal, enter forest,
return and relaunch. No measured FPS, controller/audio-quality verification, polished
rig animations or standalone export yet. M6 presents and exports the vertical slice;
deeper chapters wait for first-region review.
