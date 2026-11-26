# Camera and target focus — v0.5.59

## Behavior

Target acquisition keeps the existing 15 m range and living/visible hostile
requirements. Screen-centre intent replaces nearest-only ordering, with a small
distance bias (0.12 * distance / 15). Cycling uses horizontal screen order.
Existing focus survives to 22 m and tolerates 0.6 s of interrupted line of sight.
Dead actors, sustained occlusion and excessive distance release focus.

Yaw and elevation track with exponential smoothing (8 / 5 per second). The pitch
is bounded to -0.8 / 0.4 rad, with 0.24 rad downward framing bias to keep the
opponent above the knight's helmet. The native spring-arm sphere, collision
mask, exclusion and distance remain intact; the updated pose is applied in the
same physics step. No shake, roll or FOV pulse is added. Target height is derived
from the existing model/health-meter setup as transient actor metadata; it does
not mutate content Resources or saved progression.

A passive violet four-corner torso marker hides in menus, behind the camera,
outside screen margins, during occlusion, transitions and death. Red overhead
health meters remain. The marker does not intercept input or add text/HP counts.

Mobile body taps focus/toggle an enemy using a projected capsule rather than a
single pinpoint. Retained focus can be released by tapping even beyond the 15 m
acquisition range. Right-side look drags exceeding 24 logical pixels release
camera tracking; short taps allow at most 18 px travel / 0.32 s. Cancelled and
long touches cannot target. Left-side taps work outside joystick/action controls.
Pause/transition/input-disable guards flush stale touch ownership. Four primary
buttons and automatic focus on attack are preserved. Tutorial and Controls copy
are localized in Bulgarian, English, Russian, French and Arabic.

## Actual verification

Godot 4.7.2.stable.official.ed1daf0bf. Tests use an isolated memory-only journey,
the actual game/knight/enemy scripts, native physics, and a controlled platform
with region dressing hidden. Screenshots depict that fixture, not a new map or
a human-played campaign. Source native checks passed 50 assertions; the full
campaign/presentation suite passed 644 assertions after final source changes.

Coverage includes intended target vs closer side target, cycling, dead/behind/
out-of-range rejection, body/head taps, retained-range toggle, elevation tracking
through real physics, step-independent easing, occlusion grace and release,
cancelled/long/drag touch gestures, pause input cleanup, four-button preservation,
marker visibility, actual spring-camera retraction/recovery, and framing above
the helmet. Initial visual inspection found helmet overlap; the framing bias
was revised, and the corresponding native regression then passed.

Actual Journal > Controls testing also caught a reentrant input-clear loop:
releasing actions dispatches InputEventAction events, which reached the new
paused-state guard again. The adapter now returns immediately when inactive and
deactivates before flushing input. Real menu navigation while paused is retained
in the five-language native regression; clearing must never generate another
active cleanup cycle.

Independent final package checks add five-language HUD / Controls translation,
actual Journal > Controls navigation, and viewport bounds at 150% text. See
docs/STATUS.md for final counts and package parity results. Evidence:
.tools/review/targeting-*.log and targeting-package*/*.png.

Windows/Android local version: 0.5.59. Android versionCode 64, 432374630 bytes,
SHA-256 5CA311A16057B3162C5709CB0679E97ED394F6B3890C04CE0101D110CDA82C16.
APK v2/v3 signature / 16 KiB alignment and Windows manifest passed. The established
certificate is unchanged. The existing Android themed-icon reference warning
is unchanged; this increment does not claim to repair it.

Owner camera-feel feedback, physical-phone testing, controller hardware and
current performance measurements remain pending. No human whole-campaign run,
FPS guarantee or public upload is claimed. Next: profile the current exported
campaign and address measured load/frame-time problems.
