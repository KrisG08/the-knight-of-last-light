# King's Road composition increment — 2026-11-05

Godot 4.7.2, existing Mobile renderer. First authored-route increment, not the
complete village-to-citadel reconstruction or AAA visual acceptance.

## Implemented

The refuge woodland route now has a broken five-column stone carriageway,
boundary stones, interrupted estate fences, a roofed roadside shelter, a wheeled
abandoned cart, a ruined watchtower with arch/buttresses/platform and a small
cross-marked graveyard. Signs and lanterns reinforce the route. Landmark clearings
exclude nearby forest tree and undergrowth placements. Foundation walls and cart
have simple physical proxies. Fine fence rails/grave markers are decorative.

Stonework and timber details are batched by material with MultiMesh. Original
geometry reuses the existing credited stone/wood materials; no new external
assets. No quest, reward, save schema, enemy placement or progression gate changes.
Existing region boundaries and separately loaded regions remain.

## Evidence

- Clean editor import: `.tools/road-import.log` (after correcting one type inference error).
- Regression run: `.tools/road-tests.log`, **510 assertions PASS**, including
  forest navigation, spawn support, road center and 2.4m corridor collision rays,
  tower wall collision and actual village travel/return.
- First test invocation used unwritable default APPDATA and failed persistence
  fixtures; rerun used isolated `.tools/road-qa-userdata`, without player saves.
- Native rendered capture: `tests/capture_kings_road.gd`, `.tools/road-capture.log`.
  Images under `.tools/review/road-{camp,watchtower,graves,chapel}.png`.
  Camp, watchtower and graveyard views inspected. The existing sparse canopy,
  distant horizon, lighting and vegetation appearance still need a dedicated pass.
- Separate Windows export completed (`.tools/road-build.log`); all seven payload
  manifest hashes match. Exported headless boot exits 0 with a clean absolute-path
  log (`.tools/road-export-headless.log`). This is not a visual desktop launch pass.
- A subsequent native capture attempt stalled and was interrupted; a hidden
  exported visual smoke also failed to complete and its QA process was stopped.
  A bounded rerun (`--quit-after 600`, `.tools/road-capture-final.log`) subsequently
  refreshed all four screenshots and exited 0; final watchtower view inspected.
  This does not establish a manual interactive playthrough or exported UI acceptance.

## Delivery and remaining work

Separate `build/windows-kings-road/` preview, launched with `Play-Kings-Road.cmd`.
Previous v0.5 build and launcher retained. Source changes are shared by Windows
and Android; this increment does not yet constitute an updated Android APK.
No FPS, phone hardware, full campaign or manual traversal acceptance is claimed.
Next: composition/lighting feedback, improve canopy/terrain transitions, then
extend the treatment to the village and onward routes.
