# Passive mythical fauna — 0.5.7, 2026-11-06

Owner requested realistic mythical creatures purely as environment decoration.
Implemented pale five-tailed foxes beside the starting road and in Blackwood, an
ice dragon on an exterior Peaks crag and a second on a flat-topped exterior citadel
bastion. The new bastion is wholly beyond the existing physical map boundary.
The starting-road fox aligns to the local terrain normal. Creatures do not move
through the world, chase, attack, accept damage, join enemy groups or grant rewards.
No new quest/state/schema or collision shape. Only very small breathing scale and
fox-tail idle motion occur, owned by the pausable decorative Node3D.
The initial roadside placement intersected a cosmetic fence in native review;
the fox was moved into the neighboring clearing and recaptured. The capture also
rejects fox positions overlapping inflated authored obstacle footprints.

## Assets / art review

Icy Dragon by chengzijieczj: 44,997-triangle textured static sample, CC BY 4.0,
original-author license independently checked through public Sketchfab API.
Moon fox uses existing credited Alexei Ostapenko Fox geometry/UVs with a separate
pale fur material and five posed tail parts. Source assets are never mutated.
The Coffeek Crystal deer sample was inspected but rejected for active map placement
because its stylized proportions/pink treatment did not fit the realism direction.
It remains a credited source candidate, not an active creature in this release.
Public original sources, license snapshots and GLB hashes: assets/vendor/mythic_fauna.
Credits in menu/ending, ASSET_CREDITS and THIRD_PARTY_NOTICES include authors,
sources, modifications and the CC BY link. No paid rigging, upload or new account.

These detailed textured models improve the material/anatomy quality but are static
source samples with procedural idle, not a production animated or photoreal pack.
No claim of original authorship or physical-phone FPS acceptance is made.

## Checks

546 campaign/presentation assertions PASS. New tests instantiate all supported
decorative model types, verify real meshes, no hostile group/damage method/physical
blockers, no translation during idle, and pause freezing both time and tails.
All 23 later-map route/spawn/arena checks pass. Native in-region captures inspected
for fox, dragon/crag and citadel bastion; initial crown-deer shot was diagnostic
only. Source-model inspection confirms zero skeletons/AnimationPlayers in the two
new sample GLBs. The fox shader/resource cache is separate from hostile fur.

Evidence: .tools/mythic-{import,tests,routes,capture}.log;
.tools/review/fauna-*.png. Renderer: Godot 4.7.2 Mobile/Vulkan on RTX 3050 Ti Laptop.
No full manual playthrough or real-phone test was performed.

## Packages

Windows build/windows-v057 export complete, file manifest matches and packaged
headless boot exited 0. Play-Latest (and Session/Villains aliases) now launches this
version with the same local player-save path; older packages remain.
Android org.lastlight.knight code12 / 0.5.7-mythic-fauna export, signature and ZIP CRC
verified. Fauna LICENSE.txt is inside the APK. Certificate remains
03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8.
All 85 compiled game scripts are byte-identical across Windows and Android.
Named APK: build/android-releases/LastLight-0.5.7.apk, 384497998 bytes.
SHA256: BF0E42A2AEEF2717DEE4C3CEF5B726FEB73B536BD99AD4588C34C6C80D788020.
MD5: E40B950097301C7576D8B8F98D7CDDD8.
New Gofile sharing is pending owner permission for this APK payload, consistent
with the earlier automatic-review requirement for version-specific approval.
