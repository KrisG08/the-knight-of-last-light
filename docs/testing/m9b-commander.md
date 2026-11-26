# M9b: Fallen Commander, Oath Seal and mountain passage

Implemented locally 2026-11-04 with Godot 4.7.2.stable.official.ed1daf0bf.
Completes the current graybox scope of M9 after the Cael/exploration increment.

The northern Order portal enters a separate 24 m sanctum. The Commander starts
dormant at 600 HP. Entering closes the physical ward; companions explicitly wait
outside and rejoin on return. Recruitment and the record quest remain optional.

The deterministic sword sequence is crosscut, thrust, overhead, then repeat:

| Technique | Telegraph | Active | Recovery |
|---|---|---|---|
| Crosscut | 0.8 s, then a separate 0.65 s second-cut warning | 0.18 s each | 1.6 s after both |
| Thrust | 1.05 s | 0.28 s with locked-direction advance | 1.8 s |
| Overhead | 1.25 s with raised blade | 0.22 s | 2.1 s |

Each cut owns its hit ledger. The second cut displays SECOND CUT in the boss HUD.
The blade lowers during recovery. Existing blocking, dodge invulnerability and
damage/tempo assistance apply. No compulsory parry or rare equipment is required.
Defense is 12; damage is 20/27/32 before knight defense, guard costs 28/40/55.
These are provisional medium-pace tuning values, not human-validated balance.

Victory grants 300 XP / 140 shards once and clears the ward. The separately saved
Oath Seal interaction opens the northeast mountain ward, warms the Order floor,
updates refuge feedback and Cael's dialogue. The playable Peaks approach permits
walking, companion arrival and return; its mine/bridge/fortress remain M10 work.
Discovery completes chapter III. There is no new checkpoint in the approach;
loading recovers at the last actual lantern, including the Order lantern.

## Evidence

- Test.ps1 clean import and **339 assertions PASS** across M0–M9. New checks cover
  discovery/gate prerequisites, optional recruitment, atomic finite rewards, XP
  thresholds, schema promotion/backup/round-trip, actual sanctum interaction,
  companion exclusion, ward/exit/rest rejection, both crosscut warnings and hit
  claims, counter window, frontal guard cost, overhead dodge, loss/reset, reload
  between victory and seal, explicit seal, companion reconstruction, actual mountain
  interaction, return spawn and refuge feedback.
- Native Mobile/Vulkan capture exited 0 with no engine errors on NVIDIA RTX 3050 Ti
  Laptop. Actual overhead/second-cut/Peaks renders were visually inspected under
  .tools/review/{commander_overhead,commander_second_cut,ashen_peaks_entrance}.png.
  Capture is scripted and uses in-memory slots; no human boss victory is claimed.
- Windows package is rebuilt; isolated 120-frame native boot and manifest checks
  are recorded in STATUS.md. Player saves are not reset/copied by tests or export.

## Try it / outstanding review

From Order lantern, follow the courtyard north to Commander's Sanctum and press E.
Keep distance during both crosscuts, sidestep thrust and punish the lowered blade.
After winning, interact with Oath Seal behind him. Leave, then head east to the
mountain ward. Return freely; unfinished bosses reset on loss, defeated bosses stay
dead. No debug victory input exists in the release.

Art/animation remain original primitives and procedural poses. Human combat feel,
camera/audio, full companion backtracking and clean-start campaign route acceptance
remain pending. M6 performance data belongs to an older PCK; no M9 FPS claim.
