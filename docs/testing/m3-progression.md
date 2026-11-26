# M3 durable progression — 2026-11-03

Engine 4.7.2.stable.official.ed1daf0bf, Windows x86_64; Mobile renderer.
Owner accepted M2 combat and requested continuation. Existing medium combat pace retained.

## Implemented route

Start one of three slots → defeat soldier → earn one-time training reward → interact
with training seal → walk through opened physical gate into enclosed training alcove
→ return → upgrade sword at training anvil → save/quit/load at full-resource checkpoint.
The ordinary soldier respawns; the finite reward, seal state and equipment persist.
Training uses its own region/checkpoint/spawn IDs; campaign bosses remain undefeated.
The domain also verifies the supplied Gravedigger reward/seal fixtures and four-seal
gate rules. No campaign scene or actual story boss is claimed by this milestone.

## Persistence contract

Synchronous single writer; session revision increases on accepted durable mutations.
Actions produce a copied next state. Finite reward and victory fact commit together.
File adapter validates state, writes/flushes/closes same-directory temp, validates it,
copies valid current primary to backup temp and promotes that, then replaces primary
and verifies. Failed writes leave current session dirty with visible retry. Retrying
the save serializes existing state; it never reruns reward logic. Corrupt primary
uses valid backup with a warning; unsupported future schema blocks overwrite.
File size capped at 2 MiB. IDs, duplicates, types, numeric bounds, reward/fact/seal
consistency, equipment and recovery spawns are validated. No save resource paths load.

## Verification

`powershell -ExecutionPolicy Bypass -File .\Test.ps1`: clean import and 99 assertions
PASS before final prompt/layout-only cleanup. Tests include prior movement/combat,
pack fixtures, multi-rank XP, exact upgrade costs, insufficient currency, one-time
boss/training rewards, separate boss/seal conditions, ending prerequisites, corrupt
and wrong-type/ID/spawn data, duplicates, future-schema preservation, Windows rename
replacement, backup round-trip/recovery, failure before promotion, reward retry,
slot isolation, and real training actor/seal/gate/anvil/reload integration.
Tests use in-memory runtime slots and unique `.tools/test-saves/` directories,
never the player's `user://saves`. No real player slots reset or corrupted.

Graphical Mobile/Vulkan launch succeeded. Actual running M3 showed a defeated
soldier, rank 2, 60 shards and saved training reward in HUD. Further computer-use
inspection stopped when user input was detected, and a separate memory-only UI
review was stopped by the user's physical Escape. No full menu/layout or manual
save/relaunch verification is claimed. Automated integration covers corresponding
controllers and real Windows files; it cannot certify UI comfort or power-loss safety.

## Remaining

Human review of three-slot menus, overwrite dialog, equipment readability and the
complete save/quit/relaunch route. No power-cut test, production asset pass, FPS
measurement, gamepad, settings/rebinding, standalone export or full campaign yet.
M4 builds the actual refuge/village, checkpoint routes, Oren and quest/dialogue.
