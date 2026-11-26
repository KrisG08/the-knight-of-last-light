# Ashen Village reference pass — 2026-11-05

Owner requested that the village be rebuilt toward the attached moonlit half-timber
street reference. The reference is visual guidance, not a source of copied models.

## Implemented

Eleven authored timber/plaster buildings replace the simple house visuals and add
perimeter street frontage. Each has framing and diagonal braces, projecting floor
bands/corbels, upper windows/shutters, recessed-looking plank doors, door canopies,
gable infill, curved pitched slate roofs and chimneys. Repeated details are batched
by material with MultiMesh rather than hundreds of individual draw submissions.

Added a masonry well and pitched shelter in the square, radial/spoked mill wheel,
slatted crossed-brace shortcut gate, cobbled ground, warm flame torches and wooden
boundary fencing with trees beyond. Full moon and village-specific darker sky/fog
replace the earlier blue wash. Imported CC0 2K diffuse/normal/roughness maps for
plaster, timber, slate and cobbles; verified provider MD5, local SHA256 and authors
in assets/vendor/polyhaven/manifest.json. Credits accompany the executable.

House body collision extends through the new walls. Door canopy camera proxies
sit above walking height; the well has a collision/navigation footprint. Existing
checkpoint, Oren rescue/forge, token, shortcut, crypt and forest-seal conditions,
enemy definitions and save schema remain. New buildings are exteriors; interiors
and new quests are not implied by the visual doors. Earlier builds remain available.

## Checks

Test.ps1 clean import and **460 assertions PASS** (.tools/village-detail-final-tests.log).
Added actual navigation checks from the arrival to all village story interactions,
physics probe through the projecting canopy and a geometry regression check for
orthogonal timber transforms. Native render review caught a local/global scaling
error that sheared rotated braces into spikes; corrected before final export.
The full existing combat, companion, saves/recovery and campaign suite remains.

Native Mobile/Vulkan captures completed exit 0 without engine errors; final street,
square, mill and playable HUD images are .tools/review/village_detail_*.png. These
show actual game geometry, not generated concept images. Visual review includes
the final upper wall projection. Full human traversal/combat/camera acceptance and
matching the reference's final production quality remain open.

Build-Windows.ps1 -OutputDirectory build/windows-village completed without errors.
Folder manifest hashes independently matched. PCK SHA256:
2090BBC807FA6F740B395CDDA60070AFE03C98696AED523CA118E6E25610228E.
Launcher: Play-Village-Detail.cmd; archive: build/Last-Light-windows-village.zip.
The actual opening movie remains included. Player saves were not reset or migrated.
Performance evidence for this candidate is .tools/village-detail-benchmark/; no
previous forest/realism FPS result should be substituted for this new village.

First exported workload: completed exit 0, no stderr, mean interval-derived village
combat FPS 119.17 (p95 9.801 ms, p99 10.486 ms, worst 123.120 ms). Whole-route p95
9.792 ms / p99 11.004 ms. A **2,654.190 ms transition stall** was recorded in the
refuge-labelled stage, which includes loading the village. Keep it visible; this
is not a hitch-free performance pass. Actual render texture 2880x1620, requested
1920x1080, logical viewport 1280x720. RTX 3050 Ti Laptop / i5-12450H, Mobile,
shadows and VSync on. Peak working set 1,138,110,464 bytes; video-memory monitor
899,265,696 bytes. Raw evidence: data/village-detail-cold-{slice,process}.json.
Scripted assisted route (HP replenishment/forced boss phase), no human victory or
full-campaign guarantee. No simultaneous native capture/build/test during sampling;
desktop power mode/background activity uncontrolled. Same-cache follow-up is stored
under .tools/village-detail-benchmark-warm/ to distinguish initial shader/resource
work from repeated scene loading, without asserting the cause prematurely.

Same-cache repeat also completed exit 0 with empty stderr: village combat 119.81
mean interval-derived FPS, p95 9.834 ms, p99 11.027 ms and worst 50.218 ms.
Whole-route p95 9.858 ms / p99 11.429 ms. The transition still stalled **1,444.922 ms**;
it is not resolved by cache reuse, and its precise CPU/resource/pipeline attribution
remains unproven. Warm process peak 866,426,880 bytes. Raw evidence:
data/village-detail-warm-{slice,process}.json. No further repeats without a more
specific loading profile. Folder and ZIP payload hashes both match the manifest.
