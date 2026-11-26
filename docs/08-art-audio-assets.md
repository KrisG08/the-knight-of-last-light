# Art, animation, audio and asset production

## Visual direction

Owner revision, 2026-11-10: refine shared stone button/panel fractures using the
provided purple-lit broken-stone reference as visual direction. Use connected,
unequal branching seams, weathered edges, dark recesses and restrained violet
cores, preserving quiet caption areas. Do not copy the reference image into UI.

Owner revision, 2026-11-10: the animated main-menu moon must share the dim
blue atmosphere of the wind movie, with broad light/shadow, softened edges
and passing cloud veils. Its eyes look toward the knight, retaining restrained
movement and the menu's reduced-motion setting. Avoid a brightly pasted disc.
Cloud banks must also visibly pass in front of the lunar face, extending beyond
its silhouette and revealing it between passes rather than merely tinting it.

Owner revision, 2026-11-07: the opening is a moving 3D film with current game
models and articulated movement, higher image quality and genuine 60-fps motion.
Desktop uses 1080p, mobile uses a lighter 720p encode at the same frame rate.
Keep subtitles and Skip; suspend background world drawing during playback.

Stylized 3D dark fantasy with readable silhouettes, restrained texture detail and strong landmarks. Knight: recognizable helm, shield and cloak silhouette. Palette: cold blue/gray corruption, warm refuge lamps, restrained red/orange hazards. Darkness must preserve gameplay visibility on an ordinary display. Avoid a black screen as 'atmosphere.' Distant citadel silhouette anchors orientation.

Prototype uses capsules, boxes and simple materials. First region art pass uses a small coherent modular kit: walls, doorway, roof, stairs, fences, gravestones, rocks, trees and props. Prefer repeated modules arranged well to hundreds of inconsistent assets. Replace placeholders only after collision/navigation/combat acceptance. No paid assets without explicit budget approval. Do not claim AI-generated art is an animated rig or finished game-ready asset.

## Technical conventions

Meters, Y up in Godot; document model forward convention and import correction once. Apply Blender scale, keep sane transforms and pivots at functional points. Prefer glTF/GLB exports. Never require an undeclared local Blender executable simply to import source .blend files. Keep source files separate from exported runtime assets. Use primitive or simplified collision; do not use detailed concave collision on dynamic actors. Check material transparency, texture compression and normals in engine.

Initial texture ceilings: ordinary props 512–1024 px, selected hero assets up to 2048 only if justified. Provisional visible budget: roughly 0.5–1 million triangles and fewer than 1,000 draw calls on the target scene; use actual profiling rather than treating these as sufficient guarantees. Budget expensive transparency, shadows and particles explicitly.

## Animation inventory

Knight slice: idle, jog, sprint, turn/blend, light attack, heavy attack, block, guard break, dodge, hit, heal, jump/fall/land, interact and death. Minimum first prototype may use procedural visual placeholders but gameplay windows must function. Enemy archetypes need readable windup/attack/recover/hit/death. Boss needs distinct silhouette and attack anticipation even before polished animation. NPCs need idle, talk gesture and locomotion for followers. Track animation source, rig compatibility and retargeting work; do not assume downloaded animations fit every skeleton.

## Audio

Owner-directed v0.5.66 revision: gameplay exploration/combat/boss/dawn receive
original slowed dark-fantasy phonk loops; main-menu music remains preserved.
The 80-second opening uses a separate dramatic cue timed to the gate, casting
and staggered falls. Existing score-state rules, crossfades, user volume and
narration ducking remain unchanged. No commercial tracks or external samples.
Production and contact-motion evidence: docs/art/opening-v7.md.

Owner-authorized presentation increment v0.5.58: five original synthesized
stereo loops (menu, exploration, combat, boss, dawn), streamed through the Music
bus with two persistent crossfading decks. Three seconds of encounter release
avoids aggro flicker; paused journeys duck, encoded films silence the background
score, and live wizard victory / completed journeys use the peaceful theme. Environment emitters remain on
SFX. Score source, delivery settings and provenance: assets/audio/music/README.md.

SFX: footsteps, armor, sword swing/hit, shield impact, dodge, heal, enemy cues, boss cues, interaction, pickups, checkpoint, gate, menu and save failure. Region ambience layers and refuge/boss music are optional production additions. Use buses Master/Music/SFX/UI. Cap simultaneous voices, pool repeated emitters if profiling justifies it, prevent footsteps while airborne. Stream long tracks, use appropriate short SFX compression. Crossfade region ambience with owner-controlled volume. Avoid copyrighted soundtrack copying.

## Asset register and acceptance

Maintain planning/asset-register.csv for every external asset: ID, path, author, exact source URL, license, attribution, modification, redistribution constraints and verification status. 'Free download' is not a license. Include license files and credits. Unknown licensing blocks distribution of that asset, not development with an original placeholder.

Slice asset checklist: one knight representation, three enemy silhouettes, one boss, one Oren representation, sword/shield, modular village, crypt, refuge, checkpoint, seal and gate visual, HUD icons, licensed font and essential SFX. No need to produce every later region's art before the slice plays well.
