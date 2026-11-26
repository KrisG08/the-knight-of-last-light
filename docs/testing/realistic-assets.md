# Verified external-model realism pass

Owner-requested web research and actual integration, 2026-11-04. Pinned Godot 4.7.2
Mobile renderer retained. Latest candidate: build/windows-realism / Play-Realism.cmd.

## Delivered

- Selected parts from Poly Haven Modular Fort 01, Rock Moss Set 01, Dead Tree Trunk
  and Large Castle Door. Model geometry, diffuse, normal and ARM maps were downloaded
  from official API/CDN URLs and checked against provider MD5. Local SHA-256/source/
  authors/resolution records are under assets/vendor/polyhaven/manifest.json.
- Forest Ground 04 and Metal Plate maps provide real 2K diffuse/normal/roughness/
  metalness details. Ground tint is restrained for moonlight. Native stone kit now
  uses the fort wall PBR maps; the earlier generated material remains as fallback.
- Actual playable hero now uses Andy Woodhead's CC-BY textured knight, via the
  public simplified afk.ai sample. The unmodified GLB is preserved with source,
  license and hash. Six mesh groups retain original UVs/normal maps. The adapter
  normalizes orientation/scale, partitions limbs, adjusts arm rest pose, adds basic
  hip movement and uses the existing combat weapon pivot. No original skeleton or
  animation clips are present in this sample; no retargeting is claimed.
- Original pointed arches were rebuilt as stone voussoir surfaces with a pointed
  profile, instead of separate cylinder beam segments. This improves shape and
  reduces arch draw calls. Shared imported mesh caches avoid repeated instantiation
  of the full collection for each placed part. Collision/navigation stay unchanged.
- Creator/license/change credits are visible in-game and ASSET_CREDITS.txt is copied
  beside the EXE. All selected Poly Haven content is CC0; the hero is CC BY 4.0.
  No paid asset or Unreal package was downloaded or bought.

## Evidence

Test.ps1 clean import and **445 assertions PASS**. Existing gameplay/campaign/save
regression remains. Added assertions verify the active credited hero, imported
environment with no new physics shapes, real ground maps and hero UV/normal-map
preservation. Public download hashes were checked before import. Native Vulkan
renders of refuge, front knight, menu and 150% UI were generated/inspected under
.tools/review/realistic_*.png; capture exited 0 without engine errors.

The Windows candidate is exported separately from previous playable versions.
The current exported workload and independent boot/manifest checks are recorded
in STATUS.md and the performance report. Test/capture/benchmark slots are isolated
or memory-only; player progress is not reset or migrated by these operations.

## Practical limits

The research/selection table is docs/realistic-asset-research.md, with primary links
and a clear installed/not-installed distinction. Popular Unreal-only cathedral packs
depend on engine-specific tools/materials, so they are not direct Godot imports.
A paid FBX/Blender kit is a possible later option after licensed files, topology and
performance review. No purchase approval is required for the free work already done.

The realistic assets improve actual in-game surfaces and silhouette; they do not
make every scene a finished cinematic environment. Refuge has the fullest composition;
later regions receive selected modules and terrain props. Individual bosses/NPCs,
production skeletal animation, terrain sculpting and controlled lighting/composition
still need their own passes. Human camera/combat/campaign acceptance remains open.
