# UI, controls and accessibility

Contextual onboarding, v0.5.57: new journeys show passive, skippable hints as
actions become relevant. Record learned actions per journey, validate saved IDs,
and preserve older journeys without unsolicited onboarding. Replay/Skip lives in
Journal > Controls. Desktop hints follow bindings; phone hints describe the four
existing icons and gestures. No additional gameplay buttons. Hide hints during
menus, transitions and death. Use the shared font and support enlarged text.

Owner request, 2026-11-10: a cohesive family across the five languages, with a
bold animated game title. Current implementation uses El Messiri for Latin,
Cyrillic and Arabic: body/buttons at weight 500, title at 700. Preserve the title
font role when rebinding translations. A slow silver-violet title sheen follows
the pausable menu clock; avoid moving individual Arabic letters apart.

Owner revision, 2026-11-10: put the account/sign-in entry and language selector
at the bottom left of the title screen, inside display safe margins. Keep their
native routes and usable touch targets. The journey panel may use the vacated
upper-right space; enlarged text and all five languages must still fit.
Owner refinement, 2026-11-10: stack account above language instead of placing
them side by side. Reframe the wind movie further left to expose the castle;
in Bulgarian the helmet should sit near the end of the tagline's final word.
Owner refinement, 2026-11-10: account and language buttons use their individual
caption widths with small native padding; the language arrow retains space.
Avoid stretching either button to the container or the longest dropdown item.

Owner revision, 2026-11-07: the title screen has an optional account route and
native-name language selection for English, Bulgarian, Russian, French and
Arabic. Translate presentation, not durable IDs or user input. Use Noto Serif
for missing Cyrillic glyphs and Noto Naskh Arabic for Arabic shaping, retaining
the shared title/body style per language. Mirror navigation for Arabic. New menu
art is an original project generation with restrained optional motion.

Owner revision, 2026-11-08: the menu should read as a moving loop film, with
visible wind in clouds, grass/branches and the knight's cloak. Keep the title
unobstructed and draw translated text/buttons separately over the local movie.
Animated menus still allows reduced motion; suspend decoding outside the menu.

## Initial controls

Owner revision, 2026-11-08: buttons and information/text panels use a cohesive
dark basalt appearance inspired by the owner's glowing purple cracked stone
reference. Use original blue-charcoal texture, chipped edges and violet rim
fissures; keep text centers quiet. Apply across main/pause menus, settings,
accounts, dialogue and gameplay HUD. Preserve readable focus/state feedback,
red health/green stamina and the four icon-only mobile action targets.

WASD move; mouse look; Left Mouse light attack; Right Mouse hold block; Q heavy attack; Space dodge; Shift hold sprint; F jump; E interact/advance focused interaction; R heal; Middle Mouse lock target; mouse wheel cycle locked targets; Tab inventory/journal/map tabs; C companion follow/hold toggle; Escape pause/back. These are proposed defaults, all implemented through named InputMap actions, not direct physical-key checks scattered in scripts. Rebind keyboard/mouse with duplicate-binding warning and restore defaults. Provide input hints from current bindings. No double-assignment of the same action to jump and dodge.

Gamepad is an explicit later gate: left stick movement, right stick camera, South dodge, West interact, East jump, shoulders/triggers combat, stick click lock, Start pause. Validate with actual hardware and adapt prompts. Until tested, label unsupported rather than claiming controller support.

## Screens and flows

Target focus refinement v0.5.59: acquire a visible living hostile within 15 m
using screen-centre intent with a proximity bias. Cycle in left-to-right screen
order. Retain up to 22 m with 0.6 s occlusion grace; hide the torso marker during
occlusion. Track both yaw and elevation with exponential smoothing and a downward
framing offset so the knight does not cover the opponent. Native spring-arm
collision remains authoritative. No camera shake or forced FOV change is added.
Touch: tap the visible enemy body to focus, tap it again to release, or deliberately
drag empty space on the right to regain camera control. Cancelled/long touches
do not target. Left-side body taps work outside the movement pad and action
controls. The four primary buttons, existing attack auto-focus and keyboard
bindings remain. Tutorial and Controls describe these gestures in five languages.

Boot → main menu → New/Continue/Load/Settings/Credits/Quit. Continue enabled only for a valid slot. New game slot overwrite confirmation. Loading screen shows real progress when known, otherwise honest indeterminate indicator. No fake percentages. Pause offers resume, journal, settings and save-and-quit with recovery explanation. Menus pause single-player simulation; loading uses its own process mode so it cannot deadlock while paused. Back restores focus.

HUD: HP, stamina, healing charges, interaction prompt, restrained objective text, boss health/name during encounter, target indicator and save notification. Enemy health can appear after engagement. Do not obscure telegraphs with loot panels. Death screen explains checkpoint return and offers retry; no real-time game continues behind death UI.

Owner revision, 2026-11-07: enemy and boss health is a red overhead meter with
the actor's name, without numeric HP. Keep the player's own health display.
Remove the duplicate bottom boss meter and locked-target HP numbers. Meters
track damage, hide with defeated actors and refill on ordinary enemy respawn.

Owner revision, 2026-11-07: Pause's "Save and main menu" saves the journey and
returns to the title screen, keeping the application open. Continue reloads the
saved journey. Failed saves retain the active paused session for retry. Explicit
Quit on the title screen and the desktop window-close action exit the application.

Inventory shows item description, comparison, equipped status and upgrade requirements. Reject unaffordable or incompatible actions visibly. Journal shows current objective, completed objectives and NPC notes without leaking future chapters. Map is an authored region diagram with discoveries and checkpoint/gate status, not a falsely precise generated world map. Locked routes show known reasons. Dialogue displays speaker, readable text, choices and interaction controls; leave resumes player control safely.

## Accessibility baseline

Owner revision, 2026-11-07: use the title's Cinzel typeface for buttons and all
in-game text, including HUD, dialogue, interaction/world labels and film captions.
Use the bundled Source Sans only as fallback for glyphs absent from Cinzel.

Owner revision, 2026-11-07: mobile gameplay action buttons show only their icons,
including the context flask/use button and pause icon. Keep four action targets,
hold attack, full-stick sprint and upward dodge swipe for jump. Explanations stay
in the controls/menu help rather than captions on these gameplay buttons.
Desktop region travel and boss entry preserve a window maximized through the
title bar or switched to fullscreen; only explicit display preference changes
may override that mode during play.

Subtitles on by default; scalable UI/text (at least 100/125/150%), readable font, contrast and opaque text backing. Distinguish state with icons/text as well as color. Controls remapping, sensitivity, invert Y, toggle/hold options for sprint/block where supported. Separate master/music/effects/UI volume. Camera shake, motion blur and flashes individually reducible; motion blur off initially. Do not bind critical information to stereo audio alone.

Default difficulty plus optional assist settings: incoming damage multiplier and slower enemy attack tempo with validated minimums. Keep progression/rewards identical. Telegraphed attack durations must remain coherent with animation under assistance. Difficulty does not excuse unavoidable attacks.

## Feedback and error states

Show concrete missing gate requirement, full inventory policy if later added, failed save, invalid load with backup option, missing asset fallback and failed transition recovery. User-facing messages describe actions, not stack traces. Developer logs contain enough stable IDs to diagnose failures. Mouse capture releases in menus and on focus loss; focus return must not trigger a stored attack.
