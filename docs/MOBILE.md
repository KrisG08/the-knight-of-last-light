# Mobile preview

## Version 0.5.66 — revised cinematic and gameplay score

The opening now uses continuous character skins, an occupied prison shot,
separate grounded landing lanes, weapon releases and more varied camera cuts.
The same 80-second story retains narration in all five languages and receives
a separate dramatic cue. Gameplay exploration/combat/boss/dawn have original
slowed dark-fantasy phonk loops. Menu music, progression and save format remain.
Install over the previous app; do not uninstall or clear storage to update.
Physical Nothing Phone 3a playback, thermals and speaker balance are unverified.

## Version 0.5.65 — authored prologue

The 80-second opening uses eight authored 3D scenes, current character paint and
the expanded castle. Mobile receives its own 1280×720 / 30 fps Theora file and
independent 48 kHz score, with five localized native captions and offline voices.
This describes the media format, not measured physical-phone game performance.
Install over the existing app; do not uninstall or clear storage to update it.

## Version 0.5.41 — expanded-castle opening

Newly rendered 30-second opening shows the actual expanded castle, terraced
ascent and keep, followed by Maldrek's violet spell. Same 60 fps timeline and
localized captions; phone encode remains 1280 x 720 for lighter decoding.

## Version 0.5.40 — quest relics and character polish

Detailed scout satchel, family locket, memorial and seal cradles. Improved hostile
materials, adapted villager/shade/survivor models, fitted weapon grips and forged
companion blades. Static quest geometry is merged and shared by material.

## Version 0.5.39 — violet waygates

All 20 physical map links have animated violet apertures, layered regional
frames, carved sigils, 3D filaments and local motes. Four regional styles:
root-wrapped forest, tomb masonry, iron-banded mountain and Gothic citadel.
Existing interaction button, gate prerequisites, boss wards and save IDs remain.
The effect does not teleport on contact or add mobile buttons. Closed progression
gates show a dim vortex/crossed sigil; arena exits reflect the actual barrier.
At most one nearby shadowless portal light per region; filaments/motes limited
to close range. No new textures, external assets, global bloom or renderer switch.
Android code 44; physical-phone pacing/appearance still needs owner review.

## Version 0.5.38 — native screen resolution and high-refresh targets

Settings now offers 30/60/90/120 FPS targets. Android no longer silently clamps
the chosen rate to 60. Engine Android frame pacing stays enabled; the OS/display,
power mode, GPU load and heat still govern actual presentation. Targets are not
performance claims. Nothing Phone (3a) has a 2392x1080 panel up to 120 Hz:
https://checkout-eu.nothing.tech/pages/phone-3a . It cannot display 160 distinct
frames/s or native 2160p detail. No fake interpolation/frame-generation counter.

For clarity choose High quality + Native screen: the Phone (3a) renders the full
2392x1080 pixel grid within a 2.6 MP budget. For higher throughput choose Profile
default: at 90/120 targets the selected mobile quality reduces pixel work in
proportion to the shorter frame budget. Native stays full detail at either
target; it does not guarantee a high frame rate. UI remains full resolution.
The settings panel shows the resulting 3D buffer dimensions and selected target.

Existing preferences stay selected. To try high refresh: enable the phone's
high-refresh display mode, choose 90 or 120 FPS in game, turn on Show FPS and
compare during traversal/combat. Use Native for sharpness or Profile default /
Balanced for more headroom. Return to 60 if pacing or sustained heat worsens.
No physical phone or 120-FPS/4K acceptance has been performed. Code 43.

## Version 0.5.37 — Eclipse Castle and late-world landmarks

Enlarged 96 x 126 m playable citadel, new arrival/lantern courtyard, monumental
gate, layered keep, roofs, towers, buttresses and window tracery. Blackwood's
ruined abbey, Order memorial towers, summit aqueduct/monastery and final halls
receive distinct landmarks. Repeated masonry uses shared instanced batches;
no new shadow-casting lights or downloaded packs. Existing combat arena and
quest/save IDs remain. New architecture still needs sustained Phone (3a) review.

## Version 0.5.36 — cursed basalt interface

Buttons and information panels share original blue-charcoal basalt, chipped
edges and violet fissures. Touch buttons retain their four icon-only actions,
gestures and positions. Health stays red and stamina green; text and focus
outlines remain readable. One shared material tile and native canvas drawing;
no additional UI videos or per-button shaders. Android code 41.

## Version 0.5.35 — device graphics profiles

High quality is the default: 90% 3D scale on the Phone (3a)'s 2392x1080 screen,
2x MSAA, 8x anisotropic filtering, close moonlight shadows up to 24 m and a
bounded 2048 shadow atlas. Balanced uses 80% scale/shorter shadows; Performance
retains the former 65% scale with moonlight shadows disabled. UI stays at full
screen resolution. Frame limit defaults to 60, with 30 available for sustained
load/heat; optional FPS counter helps actual phone review. No per-frame buffer
resizing. Legacy Low graphics settings migrate to Performance.

These are starting profiles targeted at Nothing Phone (3a), not measured phone
FPS guarantees: no physical Android device was connected during implementation.
Owner review should include several minutes of village/forest combat to check
heat and pacing. Android code 40; install over the old version without uninstalling.

## Version 0.5.34 — Maldrek victory scene

A twelve-second live 3D scene follows the actual lethal hit: wizard stagger,
kneeling, collapse and violet magic retreating toward the still-intact artifact.
Directed close/wide cameras, shared-language captions and a large Skip button;
combat/touch input is suspended and restored afterward. Victory is saved before
playback. Reloading a defeated wizard does not replay the scene or duplicate
rewards. The final artifact interaction remains the explicit ending choice.
Torch sway now stays bounded on elevated geometry instead of stretching across
the screen. Android code 39; install over the old version without uninstalling.

## Version 0.5.33 — violet curse and moonlit menu

The menu movie is reframed 8% left with 18% horizontal overscan. Warm yellow
detail light, a pale golden moon and animated violet wisps around the castle
sit behind native text and controls. Animated menus freezes the movie and all
new effects together. Buttons, settings controls and HUD accents share violet;
health remains red and stamina green. Regional curse particles and magic use
violet and disappear according to seal/finale progress. Safe lanterns are warm.
Android code 38, same application ID/signing key: install over the old version
without uninstalling. Real phone brightness/performance review remains pending.
Owner-approved download: https://gofile.io/d/f8WsUW4i.

## Version 0.5.32 — brighter menu film

The same twelve-second movie now has brighter moonlit detail, a gentler dark
overlay and a small leftward reframe. Native labels/buttons remain unchanged.
The film's motion and reduced-motion behavior remain. Android code 37, same
application ID/signing key; install over the old version without uninstalling.

## Version 0.5.31 — confirmation and cloud-save correction

Confirmation now returns to a working same-project information page. Native
sign-in stays in the game. Resend confirmation email is available, with cooldown
and translated expiry feedback. Cloud RPC accepts integral JSON versions such
as 8.0 from loaded saves, while rejecting fractions and strings. Existing server
fixes also apply to v0.5.30. SMTP/recovery and persistent-login limitations remain.

## Version 0.5.30 — actual looping menu movie

The main-menu background is a local twelve-second 720p/30 fps looping video,
with moving clouds, cloak silhouette and foreground plants. Text/buttons remain
native and translated. Animated menus pauses/resumes the movie. Decoding pauses
while the menu is hidden; no Internet is needed for playback. Android and Windows
share this film. Actual phone playback/performance still needs owner review.

## Version 0.5.29 — layered living menu

New original landscape with an empty dark title area, a separate knight and
foreground vegetation. Subtle wind moves cloak, branches and grass; armor and
castle stay rigid. Animated menus can freeze every effect. Same composition
and behavior on Windows and Android; existing touch actions are unchanged.
Email verification redirect and SMTP setup remain pending; this art update
does not repair account service configuration.

## Version 0.5.28 — complete menu sections

All Credits paragraphs are localized; Settings wording has been edited in the
four additional languages. Progress includes localized historical enemy names,
including Grave Hound. Original legal-license texts and attribution names are
preserved. Account and email-service limitations are unchanged.

## Version 0.5.27 — journey translation correction

Saved journey captions, rank/boss counts, chapter names and progress/ally status
fragments translate consistently on language changes. Bulgarian, Russian,
French and Arabic share the fixes; save content and IDs are preserved.
World-name wording and mixed-language help/gate messages were also corrected.
Account/email setup limitations from v0.5.26 remain unchanged.

## Version 0.5.26 — shared menu, languages and account preview

Android and Windows share the original animated menu, refined buttons and
English/Bulgarian/Russian/French/Arabic presentation. Four icon-only touch
actions, jump swipe and full-screen play remain. Android now has Internet
permission for optional account sync. Offline play remains available.

Supabase storage is installed, but email delivery setup is pending. Registration
is labelled as testing and password recovery is temporarily unavailable. See
`docs/SMTP-SETUP.md` in the source project. Tokens/passwords are never persisted;
sign in again after restarting to open an account library. No real-device
email/sync or performance acceptance has been claimed for this version.

## Version 0.5.12 — inhabitants throughout the campaign

43 passive inhabitants across all 11 regions, including the starting road,
village, crypt, grove, Order, sanctum, forge and final ritual hall. Goblins and
dwarves stroll; wraiths float and sway. Existing troll, hounds, dragons and stone
figures retained. Roadside folk follow the starting terrain's authored height.
All remain noninteractive, without combat/rewards or changes to saved journeys.

## Version 0.5.11 — moving passive folk

Goblins, troll and dwarves now stroll along short authored corridors, pause and
return. Arms/legs animate around joints; the dwarf hammer follows the hand.
Routes are checked against expanded physical obstacle footprints; blocked routes
fall back to idle. Pause freezes movement. These inhabitants cannot be attacked,
talked to or used, grant no rewards and have no collision or campaign effects.

## Version 0.5.10 — goblins, troll and dwarves

Two goblins near the Blackwood watchtower approach; a large troll at the eastern
Peaks rock shelf; two dwarves at the mine. All remain passive scenery, without
combat, conversations, quest effects or rewards. Original procedural models:
pointed ears, tusks, hide clothing, beards, metal helmets and a smithing hammer.
Model/material batches are cached between instances and region revisits.
These are stylized procedural models; realistic sculpted character art remains
unfinished. Prior passive entities, mobile controls and saved journeys retained.

## Version 0.5.9 — passive dark entities

Added a floating robed wraith in Blackwood and a crowned stone sentinel and
winged gargoyle in the citadel. These are visual-only scenery with no damage,
interaction, rewards or navigation behavior. Original procedural geometry;
sentinel uses the already credited Strong Knight mesh with a stone override.
These additions are an authored art pass, not photoreal scanned creatures.

## Version 0.5.8 — dark-fantasy fauna direction

Owner corrected the fauna art direction. Bright five-tailed foxes are replaced by
larger single-tailed, dark hounds with pale skull-like brow markings. Dragons use
desaturated ash/brown scale materials retaining original textures/normals rather
than ice blue. Both remain passive decoration with the same safe placements.
All map/villain/HUD/jump/sprint-only stamina changes remain included.

## Version 0.5.7 — passive mythical scenery

Five-tailed pale foxes appear beside the starting road and Blackwood paths. An ice
dragon stands beyond the Peaks boundary and another above the citadel's exterior
bastion. They are scenery only: no attacks, damage receiver, collision blockers,
target lock, quests or rewards. Tiny in-place idle movement pauses with the game.
Includes all 0.5.6 villain appearances, 0.5.5 map updates and sprint-only stamina.
New source-model credits/licenses are bundled. Physical-phone performance remains
unverified; the crystal deer candidate is not placed in maps after art review.

## Version 0.5.6 — villain appearance detail

All nine enemy/boss types have individual fittings: open cowls, folded cloth,
work aprons/cleaver, spectral mask, soldier tabard/arm plates, Commander heraldry,
Warden furnace fittings/hammer, Gravedigger bone collar/lantern, beast bone plates
and Maldrek ritual regalia. Static fittings are batched and shared between same
type actors. Existing four-button controls, sprint-only stamina, upgraded maps and
journeys remain. Production animation and physical-phone art/performance review
are still open.

## Version 0.5.5 — Blackwood to finale map presentation

All eight later areas receive regional floor/path materials and additional
landmarks/set dressing: forest undergrowth/scout tower, root grove, Order ruins,
Commander hall, mine/Peaks, forge, citadel courtyard/prison and ritual chamber.
Later forests use separate bounded tree meshes; the starting road/village tree
catalog is preserved. Health HUD, four-button jump gesture, sprint-only stamina
and existing journeys remain. Phone performance/feel still need device review.

## Version 0.5.4 — sprint-only stamina

Only sprinting spends stamina (10 per second). Walking, light/heavy attacks,
dodging, jumping and frontal blocking cost none. Empty sprint reserve cannot
prevent attacks, dodging or blocking. Normal combat timings, dodge grounding and
frontal guard damage reduction remain. Reserve regenerates after the sprint delay
even during combat. Full joystick tilt sprints; partial tilt walks without drain.

## Version 0.5.3 — labelled resource bars and jump gesture

Health and stamina have named meters, current/max numbers, quarter divisions,
low-resource labels and a fading damage trail. Tap Dodge to evade; swipe upward
at least 44 logical pixels from Dodge to jump. Releasing a jump swipe cannot also
dodge. The fourth-button layout remains. Full joystick tilt still sprints.
Includes cumulative Order/Peaks/forge/citadel/ritual art, layered combat audio and
skinned knight leg animation. Update over the installed app to retain journeys.
Physical-phone gesture comfort and performance still need device review.

## Version 0.5.2 — cumulative world presentation

Includes the forest road/horizon, village trades/terrain/mausoleum, burial vault and
region-owned ambience, Blackwood trail/landmarks, discovery-aware journal and
friendly character silhouettes. Menu shows Version 0.5.2. Ordinary saves/recovery,
boss/quest facts and four-button touch controls retain their existing semantics.
Civilian models and movement remain stylized/procedural, not finished realism.
Update over the old app to retain journeys; do not uninstall or clear storage.
526 automated assertions pass; actual device/FPS/audio mix acceptance remains open.
See docs/testing/v052-shared.md for package parity and verification evidence.

## Version 0.5 — saved journeys and world progress

Every New Journey creates a separate save instead of replacing one of three slots.
Saved journeys are listed in the startup picker and Saved journeys screen. World
progress shows named bosses, mission states, seals, allies, collected items,
shortcuts, character upgrades, explored regions and ordinary-enemy victory counts.
Defeated bosses remain defeated. Ordinary enemies can return on rest/reload, while
their victory history remains. Loading resumes at the safe lantern checkpoint.

Existing v1-v7 saves are preserved and upgraded to v8 with a legacy backup. Old boss
and quest progress remains; earlier ordinary kills were not recorded, so that
history is explicitly incomplete. No invented retrospective kill counts. Data is
local to this app installation, not synchronized between phones/Windows. Update
over the prior APK; do not uninstall or clear app data to keep your journeys.

506 automated checks pass, including six on-disk journeys, fresh-session reload,
legacy migration, dirty-write retry, corruption recovery, future-version ID
reservation, actual runtime deaths and non-overwriting New Journey UI allocation.
Native library/progress captures use seeded QA campaigns, not a claimed manual
playthrough. See docs/adr/0009-journey-library-and-victory-history.md.

## Version 0.4 — modern buttons and separate pause

Current APK is version code 4, 0.4-modern-controls. Four primary action buttons now
use original code-drawn symbols, Barlow Semi Condensed Semibold labels, rounded
panels and clear pressed/charge states. Other UI buttons share the typography and
state styling. Holding Use/Flask no longer opens any menu: the explicit II PAUSE
control beside the top-left status panel opens pause on a deliberate tap. Android
Back also pauses. Do not use the older hold-for-menu instructions below.

Startup has ambient art drift/embers and page transitions. Pause instead overlays
the frozen current scene and shows JOURNEY PAUSED, region, objective and rank/flasks.
New journey/slot selection is not mixed into the pause screen. Menu motion can be
disabled in Settings. Saves, combat rules and package/signing identity are retained.
Comparison, hold-regression evidence and limitations: docs/testing/mobile-ui-v04.md.

## Version 0.3 — full-screen menu update

Version code 3 retains the same package/signing identity. Stretch aspect now
expands to fill the device instead of keeping a 16:9 letterbox. Android edge-to-edge
and immersive mode are enabled; mobile settings no longer apply the desktop
windowed/fullscreen preference, and fullscreen is restored on focus/resume.
Only interactive UI is inset from device safe areas; the world/menu art fills
the viewport. Android gesture bars may still appear temporarily when requested
by the OS. The film retains its authored 16:9 aspect ratio.

New full-screen frontend uses the existing kingdom artwork, separate boot/pause
actions and a secondary More actions page. It retains the three campaign slots,
save validation and overwrite confirmation. Settings removes keyboard rebinding
and the desktop fullscreen switch on mobile, with larger slider hit areas.
Dialogs/settings fit the safe rectangle on viewport changes.

Bundled Source Sans 3 medium UI and Cinzel title fonts replace system/fallback
font dependence. Both are SIL OFL 1.1, unmodified from Google Fonts; full notices
are bundled and reachable from Credits > Font licenses. Source Sans weight uses
the numeric OpenType wght tag. Text scaling is supported in the frontend.
An extra finger on Attack/Use cannot start a second tap/hold gesture.

482 automated assertions PASS. The targeted mobile layout probe first failed on
16:9 keep-aspect and utilities appearing on boot; it now passes. Native desktop
captures cover 1600x720, 1280x960, 150% text, settings, world, pause and More actions.
Native input replay verifies movement, hold-to-menu and one-flask healing after
resuming. These are not physical Android-device tests; the owner's unspecified
small phone bugs still need a concrete reproduction. No new phone FPS claim.

Official implementation references:
https://docs.godotengine.org/en/4.7/tutorials/rendering/multiple_resolutions.html
https://docs.godotengine.org/en/4.7/classes/class_editorexportplatformandroid.html

Android preview: `build/android/LastLight.apk`. Debug-signed local test package,
not a store release. ARM64 only, landscape, minimum Android API 24; Vulkan-capable
device required by the Mobile renderer. These are package requirements, not a
claim that every qualifying phone runs this game well. Full campaign content,
opening film and detailed enemies are included. Windows packages remain intact.

Copy the APK to your Android phone, open it from Files and allow installation
from that specific app if Android asks. Install and launch The Knight of Last
Light. Future builds must retain the same signing key to update without removing
the installed app. Do not uninstall to troubleshoot: that can delete local saves.
Android starts with its own local saves; Windows saves are not synchronized.

Four primary buttons: Attack, Dodge, Guard and Use/Flask. Tap Attack for light;
hold 0.36 seconds for heavy, with a charging ring. Heavy does not also fire light.
Attack selects a nearby visible target when there is no valid locked target.
Hold Guard to block. Tap/release Dodge to evade; swipe up from it to jump.
The fourth button offers Use beside
an interaction outside combat, otherwise Flask. Its tap action is fixed on touch
down so a label change cannot turn a Use tap into drinking a flask. No gameplay
button hold opens a menu. Tap the labeled II PAUSE utility beside the top-left
status panel, or use Android Back. The four primary gameplay targets remain.

Left pad moves; full tilt runs, smaller tilt walks. Drag open space on the right
to look. Journal/routes, a manual flask override, Jump, Lock/unlock, Next target
and companion follow/hold are in the scrollable pause menu. Those action entries
resume and dispatch after input grace ticks; they do not execute while paused.
Keyboard/mouse controls remain unchanged. Menus/dialogues use touch and scrolling.
The introductory film has a larger Skip button. Controls respect display insets.
Focus loss, backgrounding and pause release held inputs; Android Back pauses.

Mobile starts with 65% 3D render scale and directional shadows disabled. UI remains
at full logical resolution, with larger menu targets and touch-specific hints.
This is an initial mobile profile, not device-specific performance tuning.

## Build locally

Pinned engine: Godot 4.7.2 standard. Workspace tools: OpenJDK 17, matching official
Godot Android debug template and official Google Android SDK platform/build tools.
`powershell -ExecutionPolicy Bypass -File Build-Android.ps1` exports and verifies
the APK signature. Optional SdkPath/JavaPath parameters select installed tools.
It configures only this repository's self-contained editor. No Play Store upload,
release signing identity or paid account was created.

Sources: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html
and https://godotengine.org/download/archive/4.7.2-stable/ .
`tools/fetch_android_tools.py` downloads official tools with bounded HTTP ranges;
template ZIP CRC and SDK package published checksums are verified. SDK manifests
are read from Google's official repository. Tools stay under .tools/.

## Verification and limits

482 automated assertions pass, including joystick deadzone/diagonal limits,
multiple fingers holding one action, focus-loss release, four action hit areas,
tap-versus-hold attack selection, cancelled touches, contextual interaction,
menu holds without drinking, automatic sprint and release of pending actions.
Desktop native touch-preview captures are in .tools/review/mobile-controls.png
and mobile-menu.png. This verifies rendering on Windows, not on an Android GPU.
APK signing and manifest/ARM64 packaging are checked separately.
Native viewport-injected touch events also verify movement without a phantom
mouse attack, hold-to-Menu routing through the real pause/release flow, and a
secondary menu flask action that resumes, heals once and releases its input. Synthetic
positions use viewport-local coordinates to avoid desktop window stretch offsets.
The capture suppresses focus pauses only after startup has completed, so the
automated benchmark cannot start and override movement or player health.

Previous 13-button APK is retained at build/android-v01/LastLight.apk.
The current APK is version 0.2-four-button-preview (version code 2), with the same
package name and signing key so it can update the prior installation.
ZIP CRC checks pass. Manifest declares API 24 minimum/API 36 target and ARM64.
SDK 35 aapt2 reports an unused stock template themed_icon resource reference;
the manifest points to the existing primary icon, whose adaptive XML is present.
This inspector warning still needs confirmation on an actual Android launcher.

No physical-phone install, Android FPS/temperature/memory measurement, touchscreen
combat playthrough or background/recovery acceptance has been completed. ADB could
not start its local daemon in this session. Device testing remains required before
calling this a mobile release. Check movement/look/combat together, cancel touches,
dialogue scrolling, film/audio, boss readability, saves and app switching.

iOS shares the touch adapter, but no iPhone package is built or verified. A separate
macOS/Xcode signing and device-testing workflow is still required for iPhone.

## Design references

The tap/hold consolidation follows a familiar mobile action-game pattern described
for normal/charged attacks in this HoYoLAB gameplay guide (Q25):
https://www.hoyolab.com/article/20104529 . This game's thresholds, context button,
automatic sprint and menu routing are our design choices, not a copied layout.
Pascal's Wager's developer guidance also keeps camera sensitivity in settings:
https://pw.giant.games/html/news/1343ab4/m_000-1579-0001f-179609.shtml . Existing
sensitivity/invert settings remain usable here. Physical-phone feel still needs
owner review, especially release-to-light-attack timing and automatic target lock.

## Icon-only controls (0.5.23+)
Four primary targets keep their original touch areas: sword = tap attack / hold heavy attack; shield = hold guard; curved arrow = tap dash / swipe up jump; flask = heal, changing to the diamond interaction symbol near usable objects outside combat. Full joystick tilt sprints. Two strokes at the HUD open pause. Gameplay buttons have no captions; secondary menu actions retain text. Opening film is a 30-second 720p60 Theora/Vorbis encode; gameplay background drawing is suspended during playback. A real phone is still required for frame-pacing and thermal verification.
