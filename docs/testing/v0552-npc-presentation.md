# NPC presentation — v0.5.52

Godot 4.7.2.stable.official.ed1daf0bf, 2026-11-17.

NPC conversations use a bottom panel and a portrait above its physical left edge.
Oren, Lyra and Sir Cael reuse their actual credited 3D meshes in an isolated
512 × 640 viewport with 4x MSAA and warm/violet studio lighting. The viewport
renders once per conversation/model change and stops rendering while hidden.
Responses wrap into rows. Long content remains scrollable. Non-NPC screens
return to their previous layout. Gameplay pauses throughout the conversation.

Oren's cell has stone side/back walls, a roof, an arched entrance, iron bars,
hinges, a lock, chains, a wooden cot, a bucket and warm torch lighting. The
citadel prisoner enclosure receives matching ironwork, furnishings and walls.
Existing rescue flags now open the hinged doors while disabling their blocking
collision. The cell architecture stays after rescue and reload.

Oren's village position moved from (27, 0, -4) to (27, 0, -12), clearing the mill
building and providing an approach from the cross street. The focus ray excludes
only his own door collider, allowing conversation through bars while other walls
still block interaction. Navigation acceptance checks the outside of the locked
cell. Campaign/save identifiers and rescue prerequisites are unchanged.

## Actual checks

- Campaign/presentation suite: 640 assertions PASS.
- Native source conversation/cell captures: 197 assertions PASS before adding
  the large-text acceptance cases.
- Final Windows PCK: 200 assertions PASS with five languages, two screen sizes,
  three portraits, pause/leave behavior, normal-screen restoration, large French
  text, all responses retained, closed/open gates and both prisoner locations.
- Native portraits, bottom panels, Arabic placement, closed/open village cell
  and citadel enclosure visually inspected. Source and package evidence is in
  `.tools/review/npc-refresh*`.
- Windows manifest verified. Android versionCode 57 / v0.5.52 signed with the
  existing certificate and zip alignment verified.
- Windows/Android parity passed for 114 game scripts, 162 character resources,
  seven catalogs/configs and the checked shared rendering assets.

Local builds are `build/windows-v0552/` and
`build/android-releases/LastLight-0.5.52.apk`. No physical Android-device test was
performed. Portraits use the existing character meshes, so their original model
detail remains visible. No new external art assets were downloaded.
