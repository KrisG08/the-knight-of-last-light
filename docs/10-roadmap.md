# Roadmap and work order

Do not implement the whole campaign in one generation. Each milestone must leave the previous playable path working. Owner reviews concern feel and creative direction; continue independent technical work while waiting, but do not fabricate feedback.

| ID | Milestone | Acceptance gate |
|---|---|---|
| M0 | Repository and boot | pinned engine; project imports; boot/menu opens; test runner executes real assertion; setup documented |
| M1 | Knight playground | movement, orbit/collision camera, sprint/jump/dodge, input focus, safe reset; interactive review |
| M2 | Combat prototype | sword/block/heal/stamina, one enemy, telegraph, damage uniqueness, death/checkpoint loop |
| M3 | Durable progression | versioned save, backup recovery, inventory, finite rewards, seal/gate rules; reload tests |
| M4 | Village graybox | refuge, connected village paths, encounters, Oren quest/dialogue, shortcut and checkpoint |
| M5 | First boss and route | Gravedigger phases/reset, reward once, seal interaction, forest entrance transition and return |
| M6 | Slice presentation | coherent placeholder/final mix, audio/UI/settings, Windows export, performance report and full playtest |
| M7 | Companion proof | Lyra introductory quest in small forest segment; recruitment, follow/hold, navigation and downed recovery |
| M8 | Blackwood chapter | authored region, Thorn Beast, Root Seal, new route and refuge changes |
| M9 | Order chapter | Cael quest, companion switching, Fallen Commander, Oath Seal and mountain route |
| M10 | Peaks chapter | traversal, Iron Warden, Forge Seal, citadel gate and validated backtracking |
| M11 | Finale | citadel, Maldrek phases, artifact interaction, cleansing, ending, credits, postgame load |
| M12 | Release candidate | campaign clean-start playthrough, save resilience, performance, asset licensing, export package |

## First implementation tasks

M0: inspect repository → create project.godot and input action names → boot/menu/test-room scenes → native rule test runner → engine/version/setup notes → import and launch checks. Use primitive meshes. Keep the pack readable; no mass generation of empty planned scripts.

M1: capsule movement → camera orbit → collision camera → slope/step/fall handling → sprint/jump → dodge shape/timing → UI mouse capture → reset/death plane → test route → owner controls review.

M2: actor stats/actions → damage request/result → one light sword hit → per-attack uniqueness → enemy telegraph → block/guard break → heal interruption → target lock → death/respawn → review combat feel before more weapon types.

M3: CampaignState and IDs → idempotent commands → save seam with memory and file adapters → schema validation/backup → checkpoint recovery → boss/seal fixtures → inventory and upgrades → reload checks. Persist incrementally early, not after five regions exist.

## Owner review prompts

After M1: is the camera comfortable, knight scale/speed correct, and keyboard layout acceptable? After M2: does combat feel responsive/readable, should pace be slower/faster? After M5: is the region/boss loop enjoyable and story tone appropriate? After M6: approve current art direction and whether to expand campaign. Do not ask for the name of every future NPC before implementing movement.

## Definition of done per task

Behavior reachable through the real game, references valid, relevant tests pass, interactive checks honestly recorded, no new parse/runtime errors, docs/STATUS.md updated, known limitations listed. Code existence, a placeholder scene title or a passing mocked call alone does not satisfy gameplay completion.
