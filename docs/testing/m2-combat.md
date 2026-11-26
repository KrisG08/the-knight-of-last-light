# M2 combat verification — 2026-11-03

Engine: 4.7.2.stable.official.ed1daf0bf, standard Windows x86_64.
Owner accepted M1 controls and requested medium-paced combat with readable swings and short pauses.

## Timing and authority

Physics-step elapsed time is the sole authority for active windows. Light attack:
0.20 windup / 0.12 active / 0.30 recovery. Heavy: 0.55 / 0.18 / 0.55.
A tick crossing either boundary sweeps the clipped angular interval, including a
tick spanning the entire active window. Each attack owns its target claim set.
Targets require hostile group, living state, horizontal swept-blade contact, height
eligibility and an unobstructed world ray. The procedural sword follows that sweep.
Enemy: 0.8 windup / 0.2 active / 1.1 recovery; current open training patch uses
line-of-sight chase with a leash, not regional pathfinding. There are no rewards yet.

Player priority: dead, menu suppression, existing forced stagger/action,
eligible dodge, permitted attack/block/heal, locomotion. Attack input buffers for
0.12 seconds. Attacks/heal/stagger cannot be cancelled into another action;
dodge is eligible from locomotion/block. Menus clear buffered attacks and suppress
two physics ticks on re-entry so their initiating click cannot become a sword hit.
Movement dodge lasts 0.65 seconds; invulnerability is 0.10–0.28 inclusive.

## Automated evidence

Command: `powershell -ExecutionPolicy Bypass -File .\Test.ps1`.
Clean headless editor import and 49 M0/M1/M2 assertions PASS, exit 0.
Tests use the actual boot scene, actor/controller instances and collision world.
Coverage: normalized camera-relative movement, actual physics travel, fall reset,
pause/start, damage/defense, finite input rejection, frontal/rear guard, guard break
and following hit, swept low-tick attack, one claim per swing, real sword damage,
insufficient stamina, dodge invulnerability/recovery, healing completion/interruption,
checkpoint combat rejection/reset, death cleanup/retry, enemy telegraph/strike/recovery,
living target selection/camera direction and target removal on death.
Runner has a 20-second failure timeout. Audio players are stopped/drained at teardown.

## Graphical smoke

Launched native Mobile/Vulkan game on RTX 3050 Ti Laptop. Inspected menu and start
view; corrected camera spring-arm processing while paused, overlapping HUD rows
and oversized checkpoint text in the camera path. Verified Enter click and actual
LMB light attack: procedural sword moved, ATTACK displayed, stamina fell 100→85.
Keyboard injection was inconclusive; this is not a full interactive combat playthrough.
Audio is implemented and exercised by runtime checks, not listening-verified.

## Remaining limits

No FPS, audio-quality or combat-fun claim follows from headless checks.
Human review should exercise LMB/Q/RMB/Space/R/MMB/E and death/retry, camera near
walls, and keyboard input while menus open. No campaign persistence, loot, hit-stop,
production rig animation, settings, gamepad or Windows standalone export exists yet.
