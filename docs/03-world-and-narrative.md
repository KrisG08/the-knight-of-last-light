# World, characters and campaign

All names, dialogue and detailed lore below are proposals, not owner-approved canon. Keep them data-driven. Preserve the knight, evil wizard, curse, gradual region unlocking and allies even if names change.

## Premise

Maldrek occupied the royal citadel and bound four regional seals to a central artifact. He draws vitality through the seals to sustain an unnatural reign. The knight survived an expedition that failed before reaching the citadel. The first goal is finding survivors; the larger goal emerges through discoveries. The wizard is deliberately hostile. Do not silently replace him with a misunderstood hero or force a moral twist.

## Region graph

Owner revision, 2026-11-08: mark every physical campaign region/arena transition
with a moving violet portal inspired by the owner's arched vortex reference.
Use region-specific roots, tomb masonry, iron or Gothic carving. Existing
progression requirements, explicit interaction and boss exit wards retain their
authority. These waygates remain usable as traversal magic after cleansing;
they are not additional seals or quest requirements.

Refuge ↔ Ashen Village → Blackwood → Order's Ruins → Ashen Peaks → Eclipse Citadel.

Each region has optional loops and a shortcut back to its checkpoint; unlocked travel permits revisits. The refuge links only to discovered/activated safe checkpoints, not unexplored areas. Regions are hand-authored and loaded separately. Gates are visualized by mist, collapsed passage, ward or locked mechanism; they must have an explicit prompt explaining the missing condition.

## Region plan

Owner revision, 2026-11-08: increase visual density and landmark variety from
Blackwood through the finale, especially the castle's scale. Eclipse Citadel's
playable bounds expand from 64 x 78 m to 96 x 126 m with a lower forecourt,
grand processional gate, retained three-flight summit ascent and a much larger
layered keep silhouette. Preserve existing upper quest coordinates, save IDs
and final combat floor while enlarging the ritual hall's vertical architecture.

R0, Lantern Refuge: ruined chapel, first checkpoint, training corner, blacksmith location and map table. No hostile spawns in refuge. Recruitment changes authored props and dialogue, not a construction simulator.

R1, Ashen Village: chapel approach, village square, burning mill side route, burial yard, boss crypt, forest gate. Ordinary enemies: Hollow Villager, Fallen Soldier, Grave Hound. Rescue blacksmith Oren at the mill. Optional quest retrieves a family token; cosmetic/dialogue reward plus shards, never a mandatory gate item. First boss is the Gravedigger. After its defeat, the player explicitly breaks the Burial Seal; mist withdraws and Blackwood becomes accessible. Graybox target: roughly 150×150 m, one main loop, two side paths, one shortcut, one rest point, three landmarks. Scale based on traversal tests, not area alone.

R2, Blackwood: poisoned paths, watchtower, root shrine. Meet scout Lyra during a shared escape. Earn trust through her authored quest and recruit her. Boss Thorn Beast alternates lunges, sweeps and a recovery window. Breaking the Root Seal reveals the Order's Ruins route. Unlock a shortcut and changed forest ambience.

R3, Order's Ruins: barracks, collapsed courtyard, memorial hall. Documents reveal the failed expedition. Encounter companion candidate Sir Cael, a deserter carrying guilt. Boss Fallen Commander is the knight's former mentor. Fight emphasizes familiar sword techniques and readable counter windows. Breaking the Oath Seal opens the mountain passage. Do not require killing a friendly recruit for progression.

R4, Ashen Peaks: narrow paths, abandoned mine, bridge, forge fortress. Environment adds spacing and navigation danger, not untelegraphed instant deaths. Boss Iron Warden guards the Forge Seal. Four broken seals unlock the citadel ward. Oren's upgrade quest may make the fight easier but is never mandatory.

R5, Eclipse Citadel: gatehouse, prison, ritual ascent, wizard arena. Rescue optional prisoners and learn the artifact mechanism before the fight. Maldrek's first phase uses projectiles, ground hazards and short-range spells; second phase rearranges pressure with a capped number of summoned enemies. All attacks have avoidance options available to a basic knight; no mandatory rare item. Defeat does not itself trigger credits: interact with the central artifact, confirm the ending action, cleanse the curse, save, then show an in-engine ending and credits. Reopening the save resumes in the cleansed refuge. The wizard and seal bosses remain defeated.

## First boss: Gravedigger specification

Arena around 18×18 m, enough room for camera and dodge; entrance barrier only activates once the player enters and encounter starts. HP 420, initial damage 18–28 before defense; provisional values. Attacks: shovel sweep (0.8 s telegraph), overhead slam (1.2 s), slow advancing grab (1.0 s) with recovery. Phase two starts once at ≤50% HP, adds one delayed ground burst, not arbitrary speed doubling. Never overlap unavoidable grab and arena-wide damage. Avoid repeated use of the same attack more than twice when other valid attacks exist. No live summons in first boss. Practice mode and debug defeat are developer-only, disabled in release.

## NPC states and relationships

Oren: captive → freed → refuge resident. Once freed, he leaves the mill; returning/reloading cannot produce duplicate Orens. Resident blacksmith unlocks upgrades and conversations. Oren is not an active follower.

Lyra and Cael: encountered → quest active → recruited → available → active or waiting. Only one active companion. Recruitment requires explicit story facts; automatic proximity recruitment is forbidden. Companion eligibility excludes first boss and selected narrow/cinematic spaces. Explain restrictions at entry and return the companion safely. Companions cannot die permanently in the initial scope; at zero HP they are downed until encounter reset or safe recovery.

## Dialogue and quest authoring

Dialogue nodes: stable ID, speaker, text, choices, conditions, effects and next ID. Show subtitles; skip/advance safely; choices cannot apply effects twice. Main quest Q_MAIN_CH01: reach refuge → discover village threat → defeat Gravedigger → break Burial Seal → reach forest entrance. Oren rescue is an independent optional quest in the slice, though recruitment demonstrates the ally pillar. Advance progress based on semantic facts, not arbitrary scene order or elapsed time.

Keep scripts short and skippable. Example first dialogue: Oren: 'The things in the churchyard were our neighbors. Something below the graves keeps calling them back.' Knight choices: ask about the crypt, ask about the forge, leave. Information choices need not duplicate quest rewards.

## Visible consequence

After Burial Seal: crypt ward gone, forest path open, refuge dialogue changes, slightly warmer village lighting and fewer ambient whispers. Ordinary enemies may still respawn until full cleansing; explain lingering corruption. After final cleansing: gates remain open, main hostile encounters are disabled or replaced with a peaceful postgame layout; no claims of cleansing while all original enemies respawn unchanged.


## Initial first-boss reward fixture

Gravedigger reward ID: reward.boss.gravedigger. Grant 180 experience and 80 shards exactly once with the persistent defeat. Starting from rank 1 / 0 experience this produces rank 2 with 80 experience toward the next rank. Breaking the Burial Seal grants access and story progression without awarding this boss reward again. The example post-boss save intentionally leaves the seal intact to exercise recovery between victory and the seal interaction.
