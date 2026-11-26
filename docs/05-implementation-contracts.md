# Runtime interfaces and content contracts

These are behavioral contracts, not exact engine code. Check actual APIs against the pinned Godot version before implementing.

## Damage

DamageRequest fields: source_actor_id, target_actor_id, attack_instance_id, base_damage, multiplier, source_position, guard_damage, damage_kind. Resolve only on the game thread/physics step. Runtime first validates actor life, team, distance/collision, active window and target uniqueness. Pure damage rules calculate health/stamina deltas and reaction from validated inputs. Result: accepted/rejected reason, health_delta, stamina_delta, guard_broken and stagger_duration. Do not perform disk writes from hit callbacks.

Authority order: gameplay action timing controls attack activity. Animation plays in sync; marker callbacks may signal events but cannot be the sole source of timing for headless tests. When using both, define one authority and compare timing, never apply twice. On low frame rate, swept hit checks and fixed physics retain correctness. Record the final tick convention explicitly.

Collision layers, recommended initial mapping: 1 world, 2 player body, 3 hostile body, 4 friendly body, 5 hurtboxes, 6 attack query areas, 7 interactables, 8 camera blockers. Use named constants and a matrix. Rigid body collision masks and Area3D overlap masks are distinct. Attack queries target hurtboxes; actor filtering enforces factions. Corpses do not permanently block doors or attacks.

## Campaign commands

`apply_action(action, state) -> outcome`: synchronous, deterministic, no scene access. Outcome includes accepted flag, reason, next_state and semantic effects. Validate IDs, prerequisites and repeated application. Actions include ActivateCheckpoint, DefeatBoss, BreakSeal, RecruitAlly, CompleteQuest, ClaimPickup, UpgradeWeapon and CompleteCampaign. Use small explicit types/dispatch, not an extensible command framework before needed.

`gate_access(gate_id, state) -> access_result`: allowed plus missing conditions. UI and world use the same rule. Repeated DefeatBoss or ClaimPickup cannot grant duplicate finite rewards. A recorded boss defeat without its seal broken loads the boss dead and seal interactable.

## Region loading contract

`request_transition(gate_id)`: accepted only from active session, valid eligible gate and player in interaction range. Set a transition guard once, suppress input, capture a safe checkpoint snapshot and show loading. Load target in staging, instantiate/configure, wait for required navigation readiness, find a valid named spawn, then switch active region and restore camera. Preserve the old region until the target is ready where feasible. On missing scene/spawn/failure, keep or restore old safe state and show recovery UI. Never strand the player on a loading screen. Target spawn must not trigger immediate return transition. No save contains half-loaded references.

## AI

Enemy states: idle/patrol, investigate, chase, attack, recover, stagger, return, dead. Perception uses distance plus line of sight, with memory delay; no omniscience through walls. Patrol/chase uses NavigationAgent3D path output and explicit CharacterBody3D movement. Wait until the navigation map is synchronized before first path query. Update destinations on a budget or meaningful movement; do not rebake navigation each frame. Avoidance is an optional movement input, not pathfinding or automatic movement.

Leash resets enemy if player exits authored territory; do not allow free ranged damage during an invulnerable return state. Bosses stay in arenas. Encounter reset restores boss HP/phase/projectiles/barrier state, but never resurrects a persistently defeated boss. Seed randomness for automated pattern tests.

Companion states: follow, hold, engage, regroup, downed, suspended. Follow a target offset with hysteresis; do not chase the exact player transform every frame. Obstacle avoidance, stop distance, door clearance and stuck timeout are explicit. A stuck companion may relocate to a validated navigation point near the knight only outside combat, outside camera view where possible and never across a locked gate. If no safe point exists, suspend and return at a checkpoint. No teleport spam, distant enemy aggro or independent boss completion. Commands: follow/hold; focus-target is later. Companion damage stays below the knight's sustained contribution. In slice, implement and test a temporary follower after its own milestone; do not claim a refuge NPC proves follower AI.

## Content definitions

Stable IDs are required for items, pickups, bosses, gates, checkpoints, allies, quests, dialogue nodes and spawns. Store authored definitions as typed Resources; validate uniqueness and references on import/test. JSON examples in examples/ illustrate interchange and save fixtures, not mandatory replacement of Godot Resources.

AttackDefinition: id, costs, windup/active/recovery, damage multiplier, range, impulse and animation reference. EnemyDefinition: id, stats, perception/leash, attacks, reward, visual reference. RegionDefinition: id, scene, entry spawns, gates, map metadata. QuestDefinition: id, activation conditions, objectives, effects, reward ID. DialogueDefinition: nodes/choices/conditions/effects. ItemDefinition: id, type, display key, icon and allowed equipment slot.

Validate nonnegative finite numeric values, positive durations, nonempty IDs, valid graph destinations, compatible slots, complete attack windows and reachable required objectives. Definition catalogs are not mutated during play. Avoid serializing .tscn or .tres paths from untrusted saves and loading arbitrary resources.
