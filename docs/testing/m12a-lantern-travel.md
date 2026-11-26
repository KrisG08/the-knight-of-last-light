# M12a: activated-lantern travel and separate preview export

Implemented 2026-11-04 with Godot 4.7.2.stable.official.ed1daf0bf.
This is usability work toward M12, not release-candidate acceptance.

J / Journal now opens Lantern travel. Stand within three metres of an activated
lantern, outside combat and outside attacks/heals/dodges. Destinations include only
activated campaign checkpoints whose existing seal gates permit travel. Training
and unknown IDs are rejected. Successful travel restores knight/follower resources,
resets ordinary encounters and records the destination recovery. Completed journeys
retain restored-refuge recovery. Existing checkpoint facts suffice: no new schema.

The menu/window title now identifies a campaign development build. New dialogues
reset their scroll position so opening the map from a long journal starts at top.

## Checks

- Test.ps1 clean import and **433 assertions PASS**, including previous campaign
  regression and new destination/source activation, seal guards, actual map button
  travel, return/reload, resource restoration, combat/action/distance rejection,
  explanation text and selected companion recovery during postgame travel.
- Native Mobile/Vulkan map capture at 150% text exited 0 without errors and was
  visually inspected: .tools/review/lantern_map_150.png. It uses memory-only slots.
- A separate Windows preview is exported to build/windows-preview, with its own
  notices, README, SHA-256 manifest and build/Last-Light-windows-preview.zip.
  Play-Preview.cmd retains the same workspace APPDATA/saves as Play-Build.cmd.
  The primary M11 EXE/PCK is preserved while the user has that version open.
  Preview boot/manifest results are recorded in STATUS.md.

The latest source and preview are M12a; Play-Build.cmd still opens the retained M11.
Build-Windows.ps1 -OutputDirectory build/windows-preview reproduces the candidate.
Default export remains build/windows. Output paths must stay under workspace build/.

Human clean-start campaign acceptance, present workload benchmarking and final
presentation remain open. The earlier M6 benchmark does not certify this build.
