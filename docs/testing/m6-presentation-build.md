# M6 settings, HUD and Windows build — 2026-11-04

Engine pinned to 4.7.2.stable.official.ed1daf0bf. Matching standard Windows x86_64
export template extracted from official Godot release archive; `version.txt` checked.

## Delivered implementation

Separate validated ConfigFile settings: camera sensitivity/inverted Y, 100/125/150%
text, fullscreen, low shadows preset, master/music/SFX/UI buses, incoming-damage and
enemy-tempo assists. Music bus is explicitly reserved; no music track is claimed.
Menu scroll containers keep enlarged text reachable. Duplicate-binding checks cover
mouse wheel secondary event; Escape cancels capture. Restore defaults and current-key
hints are present. Settings writes are separate from all campaign slots. Help, credits,
objective text, health/stamina bars and backed HUD improve slice readability.
Short original cues now cover footsteps, dodge and menu activation as placeholders.

Incoming assist changes only the knight's validated damage multiplier. Attack tempo
scales enemy/boss state time and active sweep intervals together; grab advance scales
to retain its authored travel distance. Rewards/progression are unchanged. No blur,
camera shake or hit flash is introduced. Gamepad remains unsupported.

`Build-Windows.ps1` imports, exports real release executable plus PCK, generates MIT
engine and bundled component/font notices through Engine license tables, copies player
README, hashes artifacts and creates `build/Last-Light-Windows-Slice.zip`. The default
export opens the campaign; Play.cmd explicitly preserves the training entrypoint.
`Play-Build.cmd` runs the export with workspace APPDATA to keep existing source saves.
The regular executable supports normal Windows APPDATA. No public publication/signing.

## Verification evidence

Clean import and **186 assertions PASS**, exit 0: all movement/combat/persistence and
M4/M5 route regressions plus settings validation, disk reconstruction/replacement,
duplicate controls/wheel conflict rejection, SFX muting, default restore, camera look
calculation, applied damage assist, coherent slower boss windup, 150% theme/viewport
bounds, paused settings, key capture/conflict/Escape cancellation.

Native render capture `tests/capture_settings.gd` exited 0 without engine errors.
Inspected `.tools/review/settings_100.png`, `settings_150.png`, `menu_150.png` and
`hud_150.png`; corrected the settings panel's anchored offsets and confirmed enlarged
text stays in the visible panel with scrolling. Capture is actual viewport rendering,
not an interactive keyboard/gamepad or complete human route check.

Actual release export completed with exit 0. Independent exported headless boot
completed with exit 0; native exported benchmark is recorded separately in
`docs/testing/m6-performance.md`. Export pack excludes tests/tools/docs/design examples
and local caches/downloads/saves. ZIP content and engine/font/library notice files
were inspected. The build's hash manifest identifies the packaged files.
An additional native launch from a disposable folder containing only EXE/PCK ran
180 frames with exit 0 and an empty error log, independent of the source project/editor.
Final packaged file hashes were rechecked against the manifest: PASS.

## Remaining acceptance

Full human clean-start exported slice route, old-slot reopen, new slot, relaunch,
sound balance, camera/animation readability, remapping through physical hardware and
art direction approval. The scripted benchmark/test route cannot replace those checks.
Primitive geometry and procedural animations remain visibly acknowledged. No full
campaign, deeper Blackwood or final production assets are claimed. M6 is implemented
as a development slice build, with full human acceptance still pending before expansion.
