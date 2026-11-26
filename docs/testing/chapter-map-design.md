# Blackwood through finale — map presentation pass, 2026-11-06

Owner requested the later maps receive the same attention as the starting road and
village. This pass keeps the existing campaign graph/encounters/saves and replaces
or dresses the large empty surfaces with distinct regional materials and landmarks.

| Area | Added / changed |
| --- | --- |
| Blackwood | Blended earth/moss trail follows actual route bends; scattered fine fern clusters, edge pines/crags, fallen-log visuals over existing solid obstacles, scout supplies, ladder, banner, route signs, mushrooms and Order portal. |
| Thorn Beast grove | Curved root canopy, mossy boundary banks, rock/tree backdrop, restrained undergrowth, root entrance barrier and faceted Root Seal replace the bare square enclosure. |
| Order ruins | Worn slab/soil ground, dry vegetation, stained-glass wall bays, banners, barracks timber/stone courses and supplies, high courtyard braces, physical route signs and Peaks arch. |
| Commander sanctum | Carved slab floor, wall bays and relief knight statues, seal-end windows/banners and central medallion build on the existing vault. |
| Ashen Peaks | Ash/stone ground instead of forest soil, additional exterior crags, mine rails/ties, braced ore cart over the original solid crate, entrance reinforcement, hanging banners and a distinct citadel portal. Real bridge gap remains. |
| Forge | Slab floor/inlay, iron wall courses, rear pipe collars, hanging forging tools and banners complement the existing furnaces/vault. |
| Eclipse Citadel | Processional stone ground, colored wall bays/banners, upper cathedral towers, enclosed rear prison cell, two detailed sealed service houses and a prison/ascent sign. |
| Ritual chamber | Dark slab floor, additional radial inlays, colored window bays, relief statues/banners and a suspended circular ceiling structure with hanging crystals. |

Original assets remain credited in ASSET_CREDITS and the existing asset register.
New geometry, shader and arrangements are original code-authored work; no new
external download or license was introduced. Colored glass uses batched geometry.
Fern density scales with authored area and avoids routes, interaction points and
known obstacle footprints. No procedural world generation or new quests added.

## Gameplay authority / checks

Existing floor/route/gate positions and campaign facts remain. Blackwood/Order
curse-state ground tint now supports their shader material without aborting later
state application. Initial regression exposed that missed Order material adapter;
it was corrected before packaging. Gate visibility continues to own replacement
root/bar meshes. Seal replacements remain children of authoritative seal nodes.

The citadel's new rear cell walls, roof and two closed houses have actual collision.
The navigation grid is rebuilt once at construction with these footprints. New
architecture does not pretend to offer enterable houses or a climbable tower.

`tests/check_chapter_routes.gd` traverses all eight regions from a copied fixture,
checks reachable required outdoor destinations through the actual navigation map,
physical floor at every spawn and unobstructed central approaches in original
direct-steering boss arenas. It is not a substitute for a full player playthrough.
`tests/capture_chapter_design.gd` captures 15 native views across those areas,
with enemies frozen for architecture inspection. This fixture has defeated earlier
bosses, so some captured guardians are dead. It does not represent a fresh journey.

Evidence logs: `.tools/chapter-design-{import,routes,final-tests,capture}.log`.
Images: `.tools/review/chapter-*.png`. Engine Godot 4.7.2, native Mobile renderer
on RTX 3050 Ti Laptop GPU for screenshots. Render counters are single-view
observations, not a timed FPS benchmark. Phone FPS/visual comfort are unverified.

Final source checks: 540 campaign/presentation assertions PASS, all 23 route /
arena-approach / physical-spawn-floor checks PASS, clean import and native capture
logs. Fifteen rendered views completed; trail, tower, grove, courtyard, sanctum,
mine, forge, citadel and ritual views inspected. No manual campaign completion
or physical-phone test was performed.

Native fixed-view regression initially failed at 5,138,269 primitives. Imported
pine canopy LODs were the main cost; later forests now select bounded b/c variants
in separate resource catalogs. The same regression passes at 1,904,129 primitives
with the desktop render passes, about 63% fewer. Desktop --touch mobile rendering
profile reports 567,831. These are geometry counters, not FPS or device benchmarks.
The starting/village catalog is unchanged; two regressions protect the later mesh
budgets and resource isolation. Repro: tests/check_blackwood_render_budget.gd.

## Remaining art work

This is a substantial presentation pass, not final production art. Broad wall
sections, repeated vault modules, sky/foliage quality, humanoid combat animation,
fine prop variety and physical-phone lighting/performance still need refinement.
The region layouts remain compact separate authored maps, not a newly enlarged
seamless world. No claim of matching high-budget games is made.

## 0.5.5 packages

Windows build/windows-v055 export complete, file manifest matches, packaged
headless boot exit 0. Play-Latest and Play-Session now launch this version with
the existing .tools/userdata save location. Older build directories are retained.
Android org.lastlight.knight code10 / 0.5.5-chapter-design export, signature and ZIP
CRC pass; certificate remains
03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8.
All 82 compiled game scripts are byte-identical across Windows and Android.
Named APK: build/android-releases/LastLight-0.5.5.apk, 373848257 bytes.
SHA256: 7965961939132D72AD850637AE9FF16C81D57A49ACFD50F3E33154F4236614F0.
MD5: 948A4D86C8224677E39F84D238113043.
No 0.5.5 Gofile upload yet: previous automatic-review decisions required owner
permission for each new APK payload, beyond the prior version-specific approval.

0.5.5 delivery completed after owner requested the upload/download:
https://gofile.io/d/TzVqXwSO . Remote LastLight-0.5.5.apk name, 373848257-byte size
and MD5 948a4d86c8224677e39f84d238113043 match the local release. Download page
returned HTTP 200. The version-specific delivery permission is now resolved.
