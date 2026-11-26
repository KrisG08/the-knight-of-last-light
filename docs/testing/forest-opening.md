# Forest opening increment

2026-11-04–05, Godot 4.7.2 Mobile/Vulkan on RTX 3050 Ti Laptop.
Implementation and scope: docs/forest-world-direction.md.

Test.ps1 clean import and **457 assertions PASS** (.tools/forest-final-tests.log).
New checks exercise the actual new-game cinematic branch with memory-only storage,
paused player input, Next, Skip and checkpoint placement; loading bypasses intro.
Physics probes verify the road segments have no trunk blockers and the spawn has
upward-facing terrain collision. Navigation connects the camp and village endpoint.
Actual travel enters existing village encounters and returns at the north forest road.
Existing combat, progression, companions, save failures/backups and ending regressions
remain included. No user campaign data was reset or migrated.

Native rendered images were inspected: .tools/review/forest_camp.png,
forest_road.png, forest_chapel.png and opening_cinematic.png. Early visual review
caught reversed terrain triangle winding; corrected and added a spawn-floor physics
probe. The first native capture sessions produced images and no reported engine
errors but did not terminate normally; they were stopped explicitly. Do not count
their exit status as a successful native shutdown test. Rendered frames establish
the visible composition, not a complete playthrough or polished visual parity.

Build-Windows.ps1 -OutputDirectory build/windows-forest exported successfully.
All build_manifest.json entries were independently hashed and matched. PCK SHA256:
CEC3A6E9280F18079EBF92992D0D78AB6CA1EC064F91DACA38D0A8B87BC8D07A.
Separate build and Play-Forest.cmd preserve previous executable packages and use
the same workspace APPDATA only when that launcher is chosen. Direct EXE uses the
normal process APPDATA, as documented in the package instructions.

Final native exported build was opened with isolated APPDATA in .tools/forest-ui/.
Computer Use observed the final build already in active camp gameplay; user input
was detected and no further app input was issued. Native mouse-click intro handoff
was not independently witnessed; the automated branch checks above remain the
evidence for Next/Skip. Camera obstruction by the cosmetic camp tent was visible
in that observation and needs a collision/composition pass. No manual full road
traversal, companion acceptance or native quit/relaunch is claimed.

## Performance correction

The initial wooded build measured only 33.91 mean callback-derived FPS in the refuge
stage (p95 32.388 ms). Used tools/inspect_forest_lods.gd to inspect imported foliage
buffers, then selected the first simplified canopy LOD as runtime base. Original
sources, UVs and normal maps are retained. Later needle-collapse levels are excluded.
A regression check bounds the runtime canopy index count and verifies UV retention.

The final PCK identified above completed the same exported 60-second workload,
exit 0, completion marker, empty stderr; no overlapping native capture/test/build.
RTX 3050 Ti Laptop / i5-12450H, Mobile/Vulkan, shadows and VSync on. Actual render
texture 2880x1620, requested window 1920x1080, logical viewport 1280x720.

| Metric | Before / after canopy optimization |
|---|---:|
| Refuge stage mean interval-derived FPS | 33.91 / 112.28 |
| Refuge p95 frame interval | 32.388 / 9.566 ms |
| Entire route mean interval-derived FPS | 104.91 / 118.57 |
| Entire route p95 / p99 after | 9.328 / 9.976 ms |
| Worst frame after, transition included | 325.242 ms |
| Peak working set after | 1,173,311,488 bytes (1.09 GiB) |
| Engine video-memory peak after | 686,959,888 bytes (655.1 MiB) |
| Peak draw calls after | 1,232 |

Raw reports: data/forest-before-lod-{slice,process}.json and
data/forest-lod-{slice,process}.json. Logs in .tools/forest-benchmark[-lod]/.
This is a scripted assisted route with HP replenishment/forced boss phase, not a
fair victory or full campaign. Power mode/background desktop activity uncontrolled.
The draw-call budget and transition hitch still need work; no blanket FPS guarantee.
The older realistic-build measurement is not attributed to this wooded scene.

Voice/music, larger map connectivity, final terrain/architecture and skeletal
animation remain future work. This is the first forest increment and still visibly
differs from the painted visual target.
