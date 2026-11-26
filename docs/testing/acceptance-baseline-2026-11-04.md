# Seven-area acceptance audit — 2026-11-04

Scope: inspect the existing candidate before broad improvements. No gameplay tuning,
art replacement or save migration was made during this audit. Godot 4.7.2 Mobile,
Windows x64. Candidate: build/windows-realism/, PCK SHA256
59F4B21E89CA3AE519ABB006EE84996DCD57C2329600B60D4D34C36DA35E148B.

## Results and evidence

| Area | Executed evidence | Verdict / remaining acceptance |
|---|---|---|
| 1. Full clean-start campaign | Native menu launched through Computer Use. Selected empty Journey 3, began a journey, observed Refuge at rank 1, 100 HP, three flasks and zero shards. Slot 3 JSON exists with refuge recovery. Existing slots were not overwritten. | **Partial.** No continuous no-skip campaign, all bosses or ending playthrough was performed. The automated suite uses fixtures, direct damage and scene transitions; it cannot substitute for this gate. |
| 2. Performance | Single exported game process completed the scripted refuge/village/crypt route, exit 0, empty stderr and completion marker. See numbers below. | **Measured for this route.** Remaining: all later regions, cold/warm loading, worst fights, repeated travel and long-session memory. |
| 3. Combat balance | Read actual player, enemy, damage and all five boss implementations; reran combat/campaign regressions. Recorded numerical baseline below. | **Provisional.** No human difficulty, hit readability or victory-time acceptance. Preserve requested medium pace until representative combat feedback. |
| 4. Visuals and animation | Inspected native fresh-game Refuge, menu, journal and settings. Actual hero uses a static textured mesh split into procedural limbs. Bosses still construct primitive geometry. | **Needs production work.** Flat ambient lighting, repeated arches/lanterns, bright cyan rectangular emitters, sparse terrain, rigid motion and mixed asset quality remain visible. More imported props alone will not resolve them. |
| 5. Audio and atmosphere | Inspected audio implementation and visible settings. Short 0.15-second sine-wave cues, one shared voice per actor; each cue stops the previous one. Music slider explicitly says reserved. | **Incomplete.** No soundtrack or region ambience implementation. No listening/loudness acceptance performed. Separate impact/steps/telegraphs, add licensed/original ambience and music, then listen and mix. |
| 6. Camera, companions, saves/recovery | Test.ps1: clean import, **445 assertions PASS**, including real runtime combat, companion state, save-file backups/failures, transition guards and ending persistence. UI focus-loss paused the game; settings opened/scrolled/returned; journal opened/scrolled/returned. | **Partial.** Manual corner/near-wall camera, full companion traversal/downing/reload and exported error-recovery routes remain. Imported visual props add no physics; inspect camera passing through their surfaces. Injected J/Escape actions had no immediately observed response; keyboard automation is inconclusive, not evidence of broken physical controls. |
| 7. Windows delivery | All exported folder manifest entries and ZIP payload SHA256 hashes matched. EXE/PCK, instructions and legal notices present. Direct native app launch and new journey observed. | **Development package only.** No clean-machine install/extraction test, full exported campaign or final acceptance. Workspace CMD launch path is not reverified by this audit. Controller unsupported. |

UI review used Computer Use. The new Journey 3 remains as a beginning-of-game review
save in the normal Windows APPDATA save root, separate from workspace launcher saves.
The attempted title-bar close was not verified to exit. Later app input was detected;
no further UI actions were issued. Do not label save-and-quit/relaunch as passed here.

## Latest performance measurement

Hardware: i5-12450H / RTX 3050 Ti Laptop. Renderer Mobile/Vulkan, shadows and VSync
enabled. Requested window 1920x1080; actual render texture **2880x1620**, logical
viewport 1280x720. This is not a true 1080p render measurement. Desktop power mode
and other desktop applications were uncontrolled; no second game/capture process
ran during sampling. Earlier headless tests finished before sampling began.

| Metric | Observed |
|---|---:|
| Timed route / total process | 60.218 s / 72.512 s |
| Mean callback interval-derived FPS | 118.93 |
| p50 / p95 / p99 frame interval | 8.340 / 9.387 / 10.380 ms |
| Worst frame, refuge stage including transition | 266.475 ms |
| Village / boss-stage worst frame | 58.464 / 29.204 ms |
| Peak process working set | 1,131,163,648 bytes (1.05 GiB) |
| Engine video-memory monitor peak | 657,990,000 bytes (627.5 MiB) |
| Peak draw calls / physics / navigation | 394 / 49.993 ms / 1.244 ms |

Raw evidence: data/acceptance-baseline-slice.json and
data/acceptance-baseline-process.json. Original logs:
.tools/acceptance-baseline-benchmark/. This repeat did not reproduce the previous
8.7-second hitch. A single successful repeat does not establish its root cause.
HP replenishment and a forced boss phase make this a repeatable workload, not a
fair fight, clean-start campaign or stable FPS guarantee. Engine static-memory
monitor returned zero and is not a valid RAM reading.

## Combat numerical baseline

Default knight: 100 HP, defense 10, stamina 100; three 45-HP heals requiring one
second and interruptible. Light attack: 15 stamina, 0.20/0.12/0.30 seconds.
Heavy: 30 stamina, 0.55/0.18/0.55 seconds, 1.8 damage multiplier. Dodge costs 25,
lasts 0.65 seconds and is invulnerable only from 0.10 to 0.28 seconds. Six lights
or three heavies fit a full bar without regeneration; spending all stamina limits
defensive options. Heavy has lower damage per stamina than light; this is a tuning
question requiring a tactical benefit/readability review, not automatically a bug.

Theoretical landed light hits from full boss HP, without regeneration, misses,
companions, phases or external damage (actual damage rounding formula applied):

| Boss | HP / defense | Tier 0 sword (22) | Tier 2 sword (31) | Windup / recovery baseline |
|---|---:|---:|---:|---|
| Gravedigger | 420 / 8 | 21 | 15 | 0.8–1.4 s / 1.2–1.6 s |
| Thorn Beast | 500 / 6 | 24 | 18 | 0.95–1.1 s / 1.65–1.8 s |
| Fallen Commander | 600 / 12 | 30 | 22 | 0.8–1.25 s; combo second warning 0.65 s / 1.6–2.1 s |
| Iron Warden | 720 / 20 | 40 | 28 | 1.0–1.4 s / 1.9–2.4 s |
| Maldrek | 780 / 10 | 39 | 28 | 0.9–1.1 s / 1.6 s plus 0.8 s ready |

Late-boss hit counts suggest a possible repetitive-duration problem; they do not
prove actual encounter duration. Measure attempts, landed/missed hits, stamina
starvation, healing, deaths and time to victory before changing global damage/HP.

## Findings and improvement order

1. **High, journal usability/story:** a brand-new save exposes the entire route,
   all bosses and final artifact action. Repro: New Journey -> pause -> Journal.
   This contradicts discovery-based journal guidance in docs/07. Replace with
   current/discovered chapter notes; keep a concise next objective.
2. **High, presentation:** rigid static hero adaptation, primitive enemies/bosses,
   repeated architecture and flat lighting prevent the intended dark-fantasy feel.
   Begin with one approved Refuge/village composition and hero motion pass before
   dressing every region. Preserve readable enemy attacks and collision authority.
3. **High, sound:** add actual atmosphere and differentiated combat sounds; the
   reserved music slider is not a music system. Audition the mix during combat.
4. **Medium, navigation/UI:** Back/Save-and-back are below the fold in journal and
   settings. Pin essential navigation actions outside scrollable text/controls.
5. **Medium, performance:** investigate 266 ms transition hitch, separate loading
   from steady-state telemetry and expose actual render resolution/quality choices.
6. **Release gate:** continuous no-skip campaign, manual combat/camera/follower
   acceptance, ordinary save/relaunch and clean-machine Windows delivery remain
   open. Do not rename the candidate a final release while these are incomplete.

No new distribution-blocking corruption was observed in the automated checks;
this statement does not certify the unplayed campaign. Asset licenses remain
bundled; purchases, publishing and controller support were not introduced.
