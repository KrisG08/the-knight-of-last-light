# Instructions for Codex

## Mission and authority

Build this game in the current game repository through working increments. Explicit owner instructions outrank this pack. Within the pack, approved product pillars outrank proposals; numbered specifications define behavior; examples illustrate those specifications. Raise actual conflicts instead of guessing silently. MASTER_PROMPT.md is a generated snapshot, not a second editable source of truth.

Begin by reading README.md, CONTEXT.md, all numbered docs and milestone definitions. Inspect existing files, Git status and available Godot tooling. Preserve unrelated user changes. Do not delete, reset, force-push, publish, buy assets, or replace another repository without specific authorization. The CarPartAI repository is outside this game's scope.

Use English for code, identifiers and documentation. Explain progress to the owner in Bulgarian unless they request otherwise. Work locally and autonomously on reversible implementation tasks. Do not push or merge merely because a milestone passes.

## Engineering approach

Use pragmatic DDD for vocabulary and progression invariants; Clean Architecture for separating rules from runtime scenes; Clean Code for readable implementation. This is a real-time game, not a business backend. Do not add repositories, interfaces, factories or event buses to every script.

Favor deep modules: small interfaces hiding meaningful behavior. Keep movement/camera/physics in Godot-native runtime scripts. Keep damage decisions, gate evaluation, rewards, quest conditions and save validation independently testable. Use typed RefCounted objects for rules, immutable-by-convention Resource definitions for authoring, and Nodes for runtime behavior. Resource definitions must not hold per-actor mutable health or quest state.

State pattern: player actions and enemy/boss behavior. Observer: local signals with explicit ownership. Strategy: genuinely different attacks or targeting rules. Command: validated companion orders if needed. Adapter: persistence and input mapping. Composition: shared health, interaction and damage behavior. Record consequential architecture decisions in docs/adr/. Avoid generic frameworks, microservices, networking, ECS rewrites, procedural world generation and live-service infrastructure.

## Execution discipline

Create project.godot, input actions, a real boot scene and test entrypoint early. Build M0 then M1 before expanding. At each milestone, implement → import/parse → automated checks → interactive smoke test when supported → document evidence → continue to the next authorized step. When player feedback determines combat feel or art direction, request that feedback while continuing independent checks and cleanup; do not produce four additional regions before the first-region review.

Never report a visual or interactive test as performed without actually performing it. If the engine or UI is unavailable, implement what can be checked, explain the limitation, and provide reproducible verification steps. Headless success does not verify camera, animation readability, gamepad, audio or frame rate.

No missing referenced scenes, fake screenshots, empty tests, unexplained placeholders or inaccessible menu routes. Placeholder meshes and animations are allowed when visibly acknowledged. No multiplayer, generative AI, monetization or compulsory accounts in this scope.

Create/update docs/STATUS.md after meaningful milestones: implemented behavior, actual checks, known issues, next task, engine version, commit if present. Preserve manual asset work. Use small coherent commits when committing is authorized. Do not claim engine version, performance, export or licensing verification without evidence.

## First response and first work

Briefly state the engine/tooling found and the first milestone. If no engine is available, use an official portable distribution when environment/network permissions permit; otherwise provide precise setup instructions. Do not download large art packs as a substitute for implementing gameplay. Start with a graybox test room and deterministic rule tests.
