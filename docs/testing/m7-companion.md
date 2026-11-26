# M7 Lyra companion proof — 2026-11-04

Owner explicitly selected continuing development with Lyra. M6 full human art/route
acceptance is still open; this milestone adds only a small scout trail, not a full
Blackwood chapter or further campaign regions.

## Reachable behavior

After Burial Seal/Blackwood discovery, meet Lyra, clear two authored trail hounds,
recover the scout satchel and explicitly ask her to join. One atomic action records
quest completion/recruitment/active selection and gives 40 XP / 20 shards once.
NPC representation disappears when active/recruited; a waiting resident appears only
at the refuge. Journal or dialogue can select/dismiss outside combat. C follow/hold
is rebindable and current-key hints display it. Legacy C controls receive a free fallback
for the newly introduced action without resetting the user's original binding.

Follower: 70 HP, 6-damage dagger with windup/recovery; low contribution, nearby ordinary
hostiles only, no boss targets or independent aggro. Follow uses offset/hysteresis,
0.3-second path update budget and NavigationAgent output to move a CharacterBody.
Hold actually stops movement. Friendly collision never blocks the knight. Hostile
swings use the same per-target claims for companion damage. Zero HP cancels attacks
and downs Lyra; checkpoint/safe passage recovers her. Restricted crypt omits the
follower but retains selected campaign state and explains where she waits.

Stuck recovery: only out of combat, valid local navigation point, unobstructed ray
from knight, clear volume, out-of-camera candidate and a cooldown. No valid point
suspends/hides Lyra with a message until checkpoint/safe passage. Falling out of bounds
suspends even during combat, without unsafe teleport. Authored locked region transitions
still use the same campaign gate checks; no companion can open or cross them alone.

## Executed checks

Clean Test.ps1 import and **230 assertions PASS**, exit 0. Prior M0–M6 regression plus
discovery/recruitment prerequisites, actual encounter/satchel/dialogue Join route,
finite reward, one follower, real physics follow/hold, resume, hostile damage, support
melee uniqueness/no friendly fire, boss exclusion, downed/checkpoint/safe passage,
closed-shortcut recovery rejection, missing safe-point suspension, out-of-bounds
suspension, crypt exclusion/rejoin, saved active selection, resident duplication and
dismissal. Real file v1→v2 save promotion/backup/JSON reconstruction and legacy controls
fallback are checked in isolated .tools folders. No player slots are reset by tests.

Native `tests/capture_companion.gd` run exited 0 on Mobile/Vulkan without engine errors.
Inspected actual `.tools/review/lyra_quest.png`, `lyra_companion.png`, `lyra_downed.png`.
Dialogue fits, active/hold and downed HUD are visible, primitive model remains acknowledged.
Capture uses scripted poses, real semantic actions and memory-only state; no human
playthrough or hearing/performance assertion follows from it.

Windows release EXE/PCK and ZIP were rebuilt; packaged SHA-256 manifest rechecked PASS.
A native boot from a separate folder containing only the new EXE/PCK ran 120 frames,
exit 0, empty error log. An exploratory external-script route smoke did not produce
completion and was stopped; that discarded helper is not shipped. No full exported
companion-route acceptance is inferred from the successful boot.

Save contract: schema one reads unchanged; first companion mutation writes schema two
with known-good backup. Schema validation ties recruitment/reward/quest/satchel/trail
facts together. New facts cannot masquerade as schema one. Earlier saves remain loadable.

Pending: human navigation/door clearance and assist balance, orders during real combat,
death/checkpoint/relaunch, and the existing full slice review. M6 timing report identifies
the older measured PCK and is not a fresh performance claim for the added companion.
Deeper Blackwood, Thorn Beast/Root Seal and additional companions remain future work.
