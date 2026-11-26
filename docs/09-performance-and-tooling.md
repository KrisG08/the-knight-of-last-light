# Engine, tools, performance and delivery

## Baseline proposal

Godot 4.7.2 standard build, typed GDScript, Windows x86_64 export. Official download checked 2026-11-03; verify actual availability/version when implementing. Pin engine patch and matching export templates. Avoid .NET tooling unless owner changes language choice. Blender is optional for original models. VS Code/Codex can edit text; scene editor is useful for levels/navigation/animation.

Initial renderer Mobile, authored lighting, minimal real-time shadow lights, no volumetric fog dependency or real-time global illumination. Switch to Compatibility only after testing feature differences; switch to Forward+ only after an evidenced benefit/budget review. Plan a low preset. Engine defaults and API details must be checked against version-specific docs, not assumed from old tutorials.

## Targets, not measured claims

Known laptop: i5-12450H, RTX 3050 Ti Laptop 4 GB, 16 GB RAM. Aim for 60 FPS at 1080p low/medium in exported build; acceptable early slice floor 30 FPS at 720p low, subject to owner review. Target process RAM below 4 GB and VRAM below 3 GB for headroom. These are provisional budgets requiring measurements. Test with editor closed when measuring the exported game and report power mode/settings.

Initial encounter caps: 6 ordinary active combatants, 1 companion, 1 boss, 12 nearby animated actors. Disable unnecessary distant processing; do not make actors vanish in view. Use loaded-region boundaries and navigation/perception budgets. Avoid per-frame allocations, repeated node searches and per-frame full-world queries. Optimize measured bottlenecks after correctness.

## Measurements

Performance increment v0.5.60: runtime uses lossless prepartitioned native model
catalogs under assets/models/native-parts instead of converting the credited
source meshes at first use. Offline regeneration and exact-array/material checks
remain available. A passage frame is presented before synchronous region builds.
No quality-profile values, triangles, texture resolutions or combat rules change.
Use tools/debug/run_graphics_profile.ps1 for the actual release EXE's built-in
--benchmark. Standard release templates disable external --script overrides;
the explicit -PackedEditor mode uses the editor executable with exported content
and must be reported as a different engine build, not as a standalone EXE test.

Record device, engine, renderer, resolution, preset, build type, route and elapsed time. Measure frame-time percentiles, RAM, GPU memory where tools support it, enemy counts, physics/navigation spikes and load/save times. Run a repeatable 60-second path including one combat and a boss phase. A profiler screenshot alone without route/settings is insufficient. No performance claims from headless mode.

## Git and dependencies

Ignore .godot/, generated caches, crash dumps, user saves and exported build directories. Commit authored .tscn/.tres, scripts, metadata/UID files required by the pinned engine, project settings and original content definitions. Use Git LFS for genuinely large binary sources when available; do not introduce it for small scripts or buy storage automatically. Keep asset provenance. Do not commit credentials, portable editor binaries or hundreds of megabytes of unrelated packs.

## Commands and setup

Discover the actual engine executable. Document its absolute local path as a user setting, not a hardcoded project dependency. Typical commands, verify against pinned engine help:

```
godot --version
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/run_tests.gd
godot --path .
godot --headless --path . --export-release "Windows Desktop" build/windows/last_light.exe
```

Create the test runner and export preset before documenting them as available. Set a bounded timeout on smoke/import commands. Export requires matching templates, appropriate preset and writable output. Automated rule runner must return nonzero on failures and exercise real assertions. A small native runner is sufficient initially; a test plugin may be added only with version/license pinning. Do not add a broad testing framework before it earns its maintenance cost.

## Delivery

Produce Windows executable plus any required .pck and redistributable files; test the complete folder on a clean launch. Document save location, controls, known limitations and credits. Reopen an old slot, create a fresh one, complete the slice and exit/relaunch before calling an export verified. Signing and public distribution are separate tasks; no automatic publication.
