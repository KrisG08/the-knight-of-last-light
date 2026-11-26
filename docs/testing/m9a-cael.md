# M9a: Order exploration and Sir Cael

Implemented locally 2026-11-04, Godot 4.7.2.stable.official.ed1daf0bf.
This is the first playable increment of M9, not the complete Order chapter.

The former forecourt expands into authored open-air barracks, a collapsed courtyard
and a northwest memorial hall. Three fallen soldiers guard the route. Sir Cael asks
for the expedition record: meet him, defeat all three sentries, read/recover the
record, then return and explicitly ask him to join. Recruitment grants 50 XP and
25 shards once. The record reveals that he left to find help for the wounded and
can be reread from the journal. The Order lantern is a real recovery checkpoint.

Only one selected companion exists. The journal selects Lyra or Cael outside combat;
the other appears as a waiting refuge resident. Cael uses the same navigation,
follow/hold, ordinary-target assistance, downed/recovery and boss restrictions as
Lyra. His provisional profile is 95 HP, 12 defense and 8 melee damage; Lyra retains
70 HP, 5 defense and 6 damage. Both remain weaker than the knight's contribution.
No independent boss combat, permanent companion death or forced friendly killing.

## Executed checks

Test.ps1: clean headless import and **303 assertions PASS** across M0–M9a.
New rule/file/runtime assertions cover prerequisite rejection, explicit join choice,
one-time rewards, document consistency, version-four round-trip/legacy backup,
actual memorial route navigation, sentry signals, dialogue/record interaction,
checkpoint recovery, downed Cael, combat switching rejection, switching both ways
without duplicate followers, guardian waiting/return, refuge representations,
actual load via the campaign menu controller and journal choices.

Native Mobile/Vulkan capture on the NVIDIA RTX 3050 Ti Laptop exited 0 with no
engine errors. Actual quest, record and Cael-follower renders were inspected:
.tools/review/{cael_quest,order_record,cael_companion}.png. The script uses in-memory
slots. File tests use unique .tools/test-order subfolders, never player saves.

The Windows package is rebuilt separately; isolated boot and manifest results are
recorded in STATUS.md. No new FPS claim or human-playthrough certification is made.

## Try it

After Root Seal, enter Order's Ruins. Activate the lantern west of the entrance.
Speak to Cael farther west, clear the three sentries in the barracks/courtyard,
then recover the record at the northwest memorial. Return to Cael and select Join.
J opens companion selection; C (or the remapped key) toggles follow/hold.
Rest resets ordinary sentries; recovered documents and recruitment remain saved.

The northern Commander's sanctum remains visibly closed. Fallen Commander,
Oath Seal and the mountain passage are the remaining M9 work. Art and animation
are acknowledged primitives; full keyboard/combat/audio/companion route playtesting
remains pending. The M6 benchmark identifies an older build, not this workload.
