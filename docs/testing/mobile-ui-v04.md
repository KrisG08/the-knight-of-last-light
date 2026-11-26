# Mobile UI v0.4 — comparison and hold regression

## References and design decisions

Reviewed the publisher's Pascal's Wager presentation/store material and the
Dead Cells mobile port producer's first-person UX account, not a hands-on playtest
of those games. No screenshots, logos, fonts or UI assets were copied from either.

Sources:
- Laura Saada / Playdigious, mobile port breakdown:
  https://www.gamedeveloper.com/design/porting-i-dead-cells-i-to-mobile-an-in-depth-breakdown
- Pascal's Wager official presentation: https://pw.giant.games/
- Publisher App Store listing: https://apps.apple.com/us/app/pascals-wager/id1476649036

| Area | Our previous state | Implemented / remaining |
| --- | --- | --- |
| Menu access | Hidden on a gameplay-button hold | Explicit HUD pause control; no gameplay-button hold opens a menu. Dead Cells' producer describes replacing HP-only menu access with a visible icon after playtests. |
| Control meaning | Text-only circles | Original sword/shield/dodge/use/flask symbols plus readable labels and pressed/charge feedback. |
| Button typography | Same body face everywhere | Barlow Semi Condensed Semibold for buttons; Source Sans for prose, Cinzel for title. Licensed independently, not borrowed from a game. |
| Frontend identity | Static key art, identical startup/pause | Slow art drift, embers, page fades; pause overlays the actual frozen scene, names its region/objective and explicitly says JOURNEY PAUSED. |
| Hierarchy | New journey and slot picker mixed into pause | Slot/new controls only on startup; resume and journey status lead pause. |
| Personal fit | Fixed four-button layout | Still fixed. Dead Cells' producer describes adjustable position/size; this is a next improvement requiring phone feedback, not claimed implemented. |
| Atmosphere | Prototype assets/animation | UI polish helps presentation; it does not establish production-level character animation or performance parity with Pascal's Wager. |

## Reproduction and fix

Command: pinned Godot --headless --path . --script
res://tests/probe_mobile_holds.gd -- --touch.
Before: Attack/Dodge/Guard PASS; context FAIL — a 0.85-second hold returned to
the full-screen menu. The adapter deliberately sent pause after 0.65 seconds.
This reproduces an in-game menu return, not an Android process crash/home intent.

Removed that multiplexed pause gesture. Context retains one action on release,
with cancellation and touch-down action snapshot. Attack retains heavy hold;
Guard retains continuous hold. A separate labeled HUD pause target handles a
deliberate tap/release. Cancelled or dragged-away pause touches do not pause.
The four primary combat targets remain. Android Back also remains available.
After: all four held actions stay in gameplay. Native replay verifies dedicated
pause, release cleanup and exactly one flask heal after resuming from More actions.

New shared rounded button states and font apply across menus, settings and choices;
original code-drawn gameplay icons use the same palette. Short press animations
reset on hide. Ambient menu motion/page fading can be disabled in Settings.

## Verification limits

Native desktop captures cover startup, pause, world, settings, More actions,
1600x720, tablet 1280x960 and 150% text. Explicit native rendering is used in the
capture harness so an occluded window cannot stall the screenshot frame signal.
Actual Android launcher exits, OS gesture interception, device logs, FPS and
phone touch ergonomics remain unverified. The owner was asked to distinguish
the game menu from the Android launcher; do not claim a crash fix without evidence.

485 campaign/presentation assertions PASS, including the new button font, visible
rounded-square corner hit area and menu-motion setting. Native replay also checks
cancelled pause touches, separate HUD pause and secondary healing. Native frontend
capture verifies that disabling menu motion freezes the atmosphere clock.
