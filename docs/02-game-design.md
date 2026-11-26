# Gameplay specification

Equipment refinement v0.5.56: two passive relic slots. Burial Ward (+6 defense),
Thorn Heart (+10 flask healing) and Oath Edge (+3 sword damage) unlock from their
guardian victories. Family Keepsake (+3 defense, +5 flask healing) unlocks from
the returned family token reward. Ownership is derived from existing campaign
facts and equipped IDs persist independently. Change outside combat. Selecting
equipment never restores health or flask charges. Older earned rewards remain
eligible without replaying encounters.

Owner-directed combat refinement, v0.5.55: player attacks consume no stamina.
Three consecutive light attacks alternate sweep direction and end in a 1.35x
finisher. Follow-up opportunity lasts 0.65 s after recovery; late input can queue
one action. Idle, dodge and the completed finisher reset the sequence. Heavy
retains its 1.8x multiplier with 2.5 m reach and longer ordinary-enemy stagger.
Active/recovery timing and visible sword arcs share authored definitions.
All timings remain subject to owner combat-feel review.

## Core loops

Moment to moment: observe → position → attack/block/dodge → manage stamina → recover → collect or interact.

Region: arrive → find checkpoint → explore loops/side paths → meet ally → learn about seal → defeat boss → break seal → persist changes → open route → return or proceed.

Campaign: improve knight → recruit allies → break four seals → confront Maldrek → break central artifact → explore the changed world.

## Movement and camera

Godot units represent meters. Capsule-based CharacterBody3D; fixed physics movement, delta-correct acceleration. Walk/jog, sprint, jump, dodge, grounded/falling. Provisional speeds: jog 4.5 m/s, sprint 6.5 m/s, acceleration 18 m/s². Do not treat these as final tuning.

Third-person orbit camera on a spring arm, initial distance 4 m, adjustable sensitivity and vertical limits. Sphere/collision sweep prevents wall clipping. Visual yaw does not overwrite movement orientation unexpectedly. Camera input is suppressed during UI and transitions. Target lock faces a visible valid hostile within 15 m, breaks above 22 m or sustained occlusion, and supports cycling. Do not select dead/unloaded targets. Free movement remains camera-relative. First implement in-place animation; root motion is deferred.

## Combat authority

Each actor action state owns movement/action permission. UI and cutscene/transition input modes are orthogonal, not hundreds of combined states. States include locomotion, light attack, heavy attack, block, dodge, stagger, heal and dead. Resolve competing requests once per physics tick: dead → transition/input suppression → forced stagger → permitted dodge → allowed attack/block/heal → locomotion. State guards define whether a request can interrupt the current action. Death cancels all hitboxes immediately.

Sword collision only activates during an explicit attack window. Every attack instance has a unique ID and a set of already-hit targets. A single swing cannot damage the same target every physics frame. Fast attacks require swept segments or equivalent continuous checks rather than relying on one overlap snapshot. Team rules prevent friendly fire by default. Dead actors cannot deal damage or receive duplicate rewards.

Damage formula, initial physical-only scope: applied damage = max(1, round(base_damage × attack_multiplier × 100 / (100 + defense))). Validate all inputs finite and nonnegative. A blocked frontal attack applies 20% health damage and consumes guard stamina; initial block cone is ±60 degrees relative to defender facing. Successful dodge invulnerability rejects eligible damage. On guard stamina depletion, apply a guard-break stagger and use the specified blocked damage for that hit; subsequent hits are unblocked until recovery. Initial enemy status effects and elemental resistance are deferred.

Provisional knight: 100 health, 100 stamina, 3 healing charges restoring 45 HP, sword base damage 22, defense 10. Light cost 15, heavy 30, dodge 25, sprint 10/second. Stamina regeneration 22/second after 0.8 seconds without expenditure; no regeneration during held block, sprint or attack. Reject an action if its required cost cannot be paid; never clamp a negative balance after granting the action.

Light attack example: 0.20 s windup, 0.12 s active, 0.30 s recovery. Heavy: 0.55/0.18/0.55 s and 1.8× damage. Dodge: 0.65 s duration, invulnerability from 0.10 through 0.28 s, steerable only during initial input capture. Input buffer 0.12 s; do not queue actions through a menu or death. No perfect parry required in the slice. Animation timelines and gameplay windows must remain aligned after animation replacement.

Damage feedback: short hit flash, sound, restrained shake and attacker hit-stop. Reduced-effects option removes shake/flash; never use feedback effects to determine damage correctness. Boss attacks telegraph through animation and audio, not red floor decals alone.

## Death, rest and rewards

Death respawns at last activated checkpoint, restores health/healing, resets ordinary regional enemies and unfinished boss encounter. Keep equipment, earned experience, allies, quests and defeated bosses. No currency corpse retrieval in the initial campaign. Set falling/out-of-bounds death planes so no softlock is possible.

Rest restores health/stamina/healing, resets ordinary enemies and saves a safe snapshot. No rest during combat. Do not allow pause-menu save to preserve a boss at 1 HP. Saving semantics are specified separately.

Experience and shards are distinct: experience raises Character Rank; shards buy upgrades. Initial next-rank cost = 100 + 50 × (rank − 1), cumulative thresholds evaluated in a loop for large rewards. Rank-up grants +5 maximum HP and restores only the gained maximum amount, clamped. No XP loss. Upgrades sword tier 0/1/2 with damage 22/26/31 and shard costs 0/60/120. No recurring maintenance costs or durability in slice.

Finite boss rewards and quest rewards are exactly-once. Ordinary enemies grant repeatable, small rewards after actual respawn. Key items have no weight and cannot be dropped or sold. Inventory is curated: weapon slot, shield slot, armor preset, two relic slots. Build sword/shield plus one upgrade first; later weapons only after combat approval.

## Interaction

One interaction focus at a time, selected by range and visibility. Interactables return prompt, eligibility and action. Reject interaction when dead, in incompatible action, in a transition, or after object despawn. Prompts distinguish talking, resting, opening, rescuing and breaking a seal. Avoid tiny precision targets.
