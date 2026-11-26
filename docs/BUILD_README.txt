THE KNIGHT OF LAST LIGHT - CAMPAIGN DEVELOPMENT BUILD

CURRENT VERSION: v0.5.66 (Windows and Android feature parity).
Revised 80-second 3D opening: connected skins, occupied cell, grounded separate
falls, hanging sleeves, soft violet magic, motivated cuts and a dramatic score.
Windows film: 1080p/30; Android: 720p/30. Native captions and offline narration
support all five languages. Skip safely returns to camp. This is rendered 3D
animation; no generative-AI video service or paid assets were used for the film.
Older film/voice sources are preserved separately in the source workspace.
Exploration, combat, bosses and dawn use four original slowed dark-fantasy
phonk loops. Main-menu music is preserved. Music volume and narration ducking
retain the existing controls; no external songs or samples are included.

Ten mesh-guided front textures improve faces, helmet details, heraldry, leather
and cloth. Correct front projection and alpha preserve pale steel/cloth; paired
front/rear blending reduces bands of fallback color at oblique angles.
Knight, allies, goblin and five guardians retain the colors of their original
2D references. Matching rear images supply hair armor seams straps and cloth
detail without repeating front faces or chest emblems. Existing geometry and
animation partitions remain unchanged. Windows and Android share these assets.
Localized NPC dialogue, narrative inscriptions and opening/victory/ending speech
play offline in English, Bulgarian, Russian, French and Arabic. Language follows
the interface. Settings provides Voice volume and Spoken dialogue and narration.
Closing a conversation or skipping a scene stops its voice; subtitles stay on.
Russian uses a female narrative reader. Speech is synthetic, without lip sync.
Menu wind loop: QHD / Full HD at 30 FPS; reduced motion still pauses the scene.
These are encoded frame rates, not a guarantee of sustained device frame rate.
El Messiri is the shared Latin/Cyrillic/Arabic interface family. The title uses
a heavier weight with a slow silver-violet sheen and restrained breathing light.
Disable menu motion to freeze the title and scene together. Font OFL is bundled.
The stacked account/language buttons now size independently to their caption,
stone padding and selector arrow, including localization and UI-scale changes.
Account and language now stack at the bottom left. The movie is reframed left
with full edge coverage, revealing the castle and aligning the knight's helmet
near the end of the tagline instead of under the navigation panel.
Account/language controls now sit at the bottom left. Shared stone button/panel
fractures use connected weathered seams, carved depth and softer violet cores.
Cloud banks now pass in front of the moon, partially hiding and revealing its
face. Foreground cloud movement follows the menu's reduced-motion setting.
Moon lighting now matches the dim blue sky with soft shadow, haze and passing
cloud cover. Its moving eyes look toward the knight in the menu composition.
Main-menu moon now has moving eyes, a shifting violet gaze and a slowly opening
stone mouth. Menu motion setting also freezes the face. No save schema changes.
Twenty animated violet portals at all physical forward/return map transitions.
Layered carved arches, roots/iron/gothic trim, runes, flowing mist and 3D filaments.
Locked passages retain existing requirements; use the normal interact action.
30/60/90/120 FPS targets on both platforms; Android's hidden 60 cap removed.
Native screen resolution option; current 3D dimensions and chosen target shown.
Phone (3a): display supports 120 Hz and 2392x1080, not visible 160 FPS/2160p.
High frame targets use lighter profile-mode pixel budgets; Native favors clarity.
Expanded Eclipse Citadel: 96 x 126 m forecourt, grand gate and monumental keep.
New abbey, memorial towers, summit aqueduct/monastery and taller ritual hall.
Sloping paving conforms to terrain; castle stairs retain their exposed treads.
Cursed basalt interface: original blue stone, chipped bevels and violet fissures.
Shared menu buttons, account fields, settings, dialogue and gameplay HUD panels.
Hover/pressed/disabled feedback; four mobile action icons remain text-free.
Device graphics profiles: High quality (default), Balanced and Performance.
Sharper ground textures and foliage edges; bounded shadow quality/distance.
Frame target 60 by default, selectable 30/60/90/120; optional FPS counter.
Nothing Phone (3a) starting quality profile needs real-device sustained testing.
Sixteen-second in-engine victory scene after Maldrek's defeat: stagger, kneeling,
collapse, directed cameras and violet magic returning to the intact artifact.
Skip/Esc restores play; victory saves before playback. Break the artifact to finish.
Left-shifted, brighter looping menu film with warm light, moon and violet castle wisps.
Violet interface accents, seals, wards and magic; warm gold safe lanterns.
Decorative regional curse effects follow seal/finale progress and cease when cleansed.
Five-language presentation and optional cloud synchronization.
Optional cloud account preview; email delivery/recovery setup remains owner action.
See docs/SMTP-SETUP.md in the source project. No passwords or session tokens on disk.
El Messiri is shared by menus, buttons, HUD, dialogue and world labels.
Film subtitles use the same live UI font; Skip sits above the picture captions.
Directed film: visible wizard casting, branching curse veins and vapor instead of rings.
Articulated recoil, collapse, brace and rise; closer moving camera and lens changes.
Icon-only mobile gameplay buttons; region travel preserves maximized/fullscreen windows.
New 60-fps opening: optimized 1080p on Windows and Android.
Background world rendering is suspended during the film, then restored.
Forested mountain slopes across all 11 regions, darker storm sky and distance haze.
Background tree clusters use transparent captures of the full CC0 pine models.
More broken hillside relief, dark woodland soil and higher snow line.
Detailed moon-face, photographic cloud sky and extended terrain horizons.
Background aprons follow regional elevations and blend into matching distance haze.
Desktop 4x MSAA, mobile 2x MSAA smooth geometry edges.
Ten Meshy characters have richer source geometry, welded smooth normals,
reference-projected clothing/armor detail, separate roughness/metal masks and
offline cavity shading. Textures remain attached during movement.
Reference projection still has seams at oblique angles; not a hand-painted UV atlas.
Pause: Save and main menu saves your journey and returns to the title screen.
Continue journey reloads it. Quit on the title screen closes the application.
Village/Blackwood/Order/Peaks now rise across authored terrain terraces.
Peaks climbs 13 m; the citadel climbs another 18 m through three stair flights.
Maldrek's ritual chamber sits at elevation 44 m. Collision and navigation agree.
Visible stair treads use smooth underlying collision ramps for walking.
Enemies and bosses have red health meters above them, with names and no HP numbers.
Meters decrease with damage, hide after defeat and refill when enemies respawn.
Ten Meshy characters now have baked clothing, skin, hair, leather and metal colors,
weathered surface detail and individual palettes. Colors follow limb animation.
43 passive inhabitants distributed across all 11 regions, starting camp to finale.
Goblins, troll and dwarves stroll with articulated arms/legs; remain noninteractive.
Adds passive goblins in Blackwood, a mountain troll and dwarven mine workers.
Includes passive Blackwood wraith, crowned citadel sentinel and winged gargoyle.
Use Play-Village-Detail.cmd or Play-Latest.cmd for build/windows-v0525/LastLight.exe.
Passive dark-fantasy scenery: dark barghest-inspired hounds along the road/Blackwood;
ashen dragons on an exterior Peaks ridge and a citadel bastion. No attacks, health,
hitboxes, quest effects or rewards. Small in-place idle motions pause with the game.
All four ordinary hostile types and five bosses have revised visual fittings,
cloth/cowls, armor/weapon details and individual silhouettes. Combat rules and
save progress remain unchanged. See docs/testing/villain-detail.md.
Later-region presentation revised from Blackwood to the final ritual chamber:
regional ground/path materials, vegetation, scout details, ruined Order courts,
mine equipment, forge decoration, citadel service houses and ritual architecture.
See docs/testing/chapter-map-design.md for evidence and remaining art work.
Stamina is spent only while sprinting. Walking, light/heavy attacks, dodging,
jumping and blocking cost no stamina. Attacks/dodges work with an empty reserve.
Named health/stamina meters include numeric values and low-resource indicators.
Android: tap/release Dodge to evade; swipe up from Dodge to jump. Four primary
buttons remain. Full joystick tilt runs. Cumulative region art, layered weapon
audio and skinned leg locomotion are included; full-body animation is unfinished.
Both platforms share the current frontend, fonts, saved-journey library, world
progress, detailed enemies, campaign and opening film. Windows uses keyboard/mouse;
Android uses touch controls and its mobile rendering profile.
New Journey creates an independent save. World progress lists defeated bosses,
enemy victory history, missions, regions and unlocks. Existing local saves migrate
safely with backups. Ordinary enemies can respawn; historical victories remain.
Launcher APPDATA stays .tools/userdata, preserving your laptop's existing saves.
Phone/laptop saves remain local to each device; this update does not cloud-sync them.
Close an older running game before opening the updated launcher.
Historical preview notes below describe earlier retained packages.

VILLAIN MODEL PREVIEW (2026-11-05): Play-Villains.cmd is the latest workspace launcher.
Ordinary enemies and five bosses now use detailed armor/canine bases or authored
robes, skulls and weapons instead of block bodies. Fallen Soldier/Commander/Warden
use modified DJMaesen armor; cursed canines use modified Alexei Ostapenko fox anatomy.
Credits and license links are in ASSET_CREDITS.txt. Basic procedural gait/breathing
and existing weapon telegraphs remain; production skeletal animation is unfinished.
Attack timing, damage, collision capsules, rewards, quests and saves are retained.
The updated village, forest route and opening movie are included.

VILLAGE DETAIL PREVIEW (2026-11-05): Play-Village-Detail.cmd is the latest workspace
launcher. Ashen Village has eleven detailed timber/plaster buildings, pitched slate
roofs, shutters, projecting door canopies, a stone well, radial mill wheel, wooden
shortcut gate, cobbled streets and warm torches under a full moon. Existing village
quests, hostile encounters, checkpoint and route/seal requirements are retained.
The 30-second opening movie is included. Continue resumes your existing checkpoint;
from Refuge follow the woodland road north and interact at the village passage.

OPENING FILM PREVIEW (2026-11-05): New Journey now plays a real 30-second rendered
3D movie: the citadel curse, expedition march, defeat and survivor at camp. Includes
original atmospheric audio and burned-in English subtitles. Skip film / Escape
ends playback; normal movie completion enters the camp automatically. Continue
loads a checkpoint without replay. Workspace launcher: Play-Film.cmd. The earlier
single-painting opening described below is superseded by this movie version.

FOREST OPENING PREVIEW (2026-11-04): New Journey plays a skippable 27-second
animated 2D backstory. Next advances a beat; Skip introduction or Escape begins
play at the expedition's last camp. Continue loads your checkpoint without replay.
Follow the winding forest road north past the ruined chapel to Ashen Village.
The initial forest is 136 x 224 metres; later campaign regions retain their prior
layouts. This is the first forest-world increment, not a complete seamless kingdom.
No voice narration or soundtrack is included yet. Workspace launcher: Play-Forest.cmd.

Run LastLight.exe. Keep LastLight.pck beside it. No editor or account is required.
This is an unsigned local Windows x86_64 development build with primitive art.

Default controls: WASD / mouse; LMB light attack; Q heavy; RMB block; Space dodge;
Shift sprint; F jump; R heal; MMB lock; wheel cycle; E interact; J journal; Esc pause.
C toggles an active companion between follow and hold. All gameplay controls remap.
Settings: sensitivity, invert Y, text size, volume buses, low graphics/shadows,
fullscreen, incoming-damage and enemy-tempo assists, keyboard/mouse remapping.
Escape cancels binding capture. Duplicate bindings are rejected. Restore defaults
is available. Gamepad is not supported. Subtitles/state text are always present.

Route: new campaign -> north passage to village -> activate lantern -> east loop
to mill -> defeat guard -> talk/free Oren -> open shortcut from north side -> optional
western family token -> refuge forge/memorial -> northern crypt -> Gravedigger ->
interact with Burial Seal -> northeast Blackwood entrance -> return to village.
Journal contains route notes. Settings and credits are available from pause/menu.

Lyra: in Blackwood, speak to the scout west of the path. Defeat the two trail hounds,
recover her satchel behind the fallen wall by the watchtower post and return to her.
Choose to ask her to join. C toggles follow/hold; E near Lyra offers orders or waiting
at the refuge. Journal also selects/dismisses a recruited companion outside combat.
Lyra helps against nearby ordinary enemies, cannot fight the crypt boss, and cannot
die permanently. At zero HP she is downed; rest at a lantern or cross a safe passage
to recover her. She waits outside the crypt and Thorn Beast grove, then rejoins on return. No safe recovery
path means she suspends and returns at a lantern rather than crossing a locked gate.

On load, recover healthy at your last activated refuge/village/Blackwood/Order/Peaks/Citadel lantern. Ordinary
enemies respawn. Oren, quests, equipment, boss reward and broken seal persist.
Lyra's recruitment and active selection persist; follow/hold resets on safe arrival.
Version-one through six saves still load. Finale progress writes version seven with backup.
Quitting after boss victory and before seal interaction is supported.
Three campaign slots; overwrite asks for confirmation. Save errors leave the game
open with Retry saving. Unsupported future-version saves are preserved.

Normally saves/settings are under:
%APPDATA%/Godot/app_userdata/The Knight of Last Light/
  campaign_saves/slot_01.json (+ .bak backup), slot_02.json, slot_03.json
  settings.cfg
Source launchers redirect APPDATA locally; exported game uses the process APPDATA.
Existing source saves can be retained by using the supplied workspace launcher.

Remaining: primitive models/procedural animations and synthesized sound cues;
Primitive final art/audio/animation and full human campaign acceptance remain unfinished.
This development build has not completed the full human clean-start slice acceptance.

Original authored geometry, icon, animation code and synthesized cues; limestone base color generated with built-in imagegen. Godot engine
MIT license and bundled third-party/font notices are in the adjacent notice files.
Licensed external 3D assets and PBR maps are now included; see ASSET_CREDITS.txt. No external soundtrack is included. No public release performed.

Blackwood: activate the lantern west of the entrance. Follow the eastern watchtower
road north, then west to the root shrine. Open the shortcut from the northern side.
Defeat Thorn Beast, interact with Root Seal, return and take the northeast ward to
the Order forecourt. Sidestep the locked lunge and attack during recovery.


Order: activate the lantern west of the entrance and speak to Sir Cael farther west.
Defeat the three courtyard/barracks sentries. Read the expedition record in the
northwest memorial hall, return to Cael and explicitly ask him to join. J selects
Lyra or Cael outside combat; only one follows. Waiting companions appear at refuge.
Cael obeys follow/hold and recovers at lanterns. Enter the northern sanctum to face the Fallen Commander. The recovered record remains in J.

Commander: the crosscut has TWO swings, each with its own warning. Block, dodge or
keep your distance, then attack during the lowered-sword recovery. Thrust advances
in a locked direction; overhead is slow. Companions wait outside the sanctum.
After victory, explicitly break Oath Seal behind the Commander. Return to Order
and take the northeast mountain ward to Ashen Peaks. Activate the Peaks lantern, explore the western mine and cross the railed bridge
to the forge fortress. Boss rewards and seals persist through reload.

Peaks: keep inside the bridge rails. A real fall restores your last activated
lantern. Open the eastern service bar from the fortress side for an alternate
return. Iron Warden alternates hammer sweep and a slow local slam. Move beyond
the slam's reach, block or dodge, then counter during the lowered-hammer pause.
Companions wait outside the forge arena. Defeat Warden and explicitly break Forge
Seal. All FOUR regional seals open the northeast Eclipse Citadel ward. The gatehouse, prison and ritual approach are playable; the north chamber holds Maldrek.

Finale: activate the citadel lantern. Optional prisoners are west; defeat their
jailer before opening the bars. The eastern inscription explains the ritual.
Face Maldrek north: sidestep orbs, leave marked ground and manage at most two shades
in phase two. Victory alone does not break the curse. Interact with the central
artifact and confirm. A failed save offers Retry before ending/credits appear.
After the ending, Continue exploring returns control. Main ordinary enemies no
longer respawn. Earlier optional rescues can still finish on peaceful roads.
Completed saves always reopen at the restored refuge, even after postgame rest
elsewhere. No debug victory controls are included in the release.

Lantern routes: open J and choose Lantern travel. Stand beside an activated lantern
outside combat. Only destinations you activated are offered. Travel restores the
knight and selected follower, resets ordinary encounters and sets destination
recovery. Completed journeys continue to reload at the restored refuge.

DARK FANTASY ART PREVIEW: use Play-Art.cmd in the workspace, or run this folder's
LastLight.exe. The knight, refuge cathedral dressing, cyan lanterns, storm sky,
stone materials and compact HUD have a new first art pass. Later regions receive
selected kit props; enemies/companions/bosses still retain prototype models.
Stone base color is an original AI-generated asset. There is no runtime AI service.
Text size and low shadows remain available in Settings. This is not final art.

REALISTIC ASSET PREVIEW: Play-Realism.cmd runs build/windows-realism. The actual
player uses Andy Woodhead's CC-BY knight sample, adapted with procedural limb and
weapon pivots. It has no original skeleton/animation clips; animation polish remains.
Poly Haven CC0 fortress modules, rock scans, fallen trunks, castle door and PBR
materials are integrated. Source/license/modification credits are bundled in
ASSET_CREDITS.txt and identified in the Credits screen. No paid assets included.
LATEST CUMULATIVE PREVIEW: 0.5.2
Run LastLight.exe from the complete Windows folder. In the source workspace,
Play-Latest.cmd and Play-Village-Detail.cmd launch build/windows-v052 using the
existing workspace save profile. Play-v05.cmd retains the earlier version.
Android: LastLight-0.5.2.apk updates the same app; do not uninstall/clear storage.
Both platforms share world/journal/friendly-character changes. Saves are local
per installation. Human campaign, real-phone performance and final art acceptance
remain in development. Historical build notes below describe earlier milestones.


0.5.13: Ten prepared Meshy character/creature meshes, simplified geometry, procedural materials and existing movement/combat adapters. Source models have no authored textures or full character rig. Further art and animation refinement remains.

0.5.14: Smooth leg gait, skinned shoulder/elbow/wrist motion, equipment following wrists, restrained shield swing, stronger running arm bend and subtle torso movement. Procedural character animation remains subject to visual polish.

0.5.15: Space dash keeps the walking gait and arm motion at increased cadence rather than switching to stand. Dash speed, invulnerability and stamina rules are unchanged.
