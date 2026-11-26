# Late-world landmarks and Eclipse Castle — v0.5.37

2026-11-08; Godot 4.7.2.stable.official.ed1daf0bf, Mobile renderer. No Git repo.

## Authored changes

| Area | Additions |
| --- | --- |
| Blackwood | Wayside abbey silhouette, bell tower, layered shrine/processional arches and lantern milestones |
| Thorn grove | Flanking shrine towers, rear arcade and taller sanctuary portal |
| Order ruins | Memorial/bell towers, distant cloister, flying braces and processional arch |
| Commander sanctum | Higher column rhythm, hanging banners and memorial portal |
| Ashen Peaks | Summit monastery, stepped tower silhouette and abandoned aqueduct beside the ridge |
| Forge | High structural braces and wall piers framing existing furnaces |
| Eclipse Citadel | Playable footprint 64 x 78 m → 96 x 126 m (4,992 → 12,096 m², 2.42x); extended entrance forecourt and grand gate; service pavilions, curtain towers, wings, layered keep, tiled roofs, flying buttresses and mullioned amber windows |
| Maldrek hall | Vault apex 15 → 26 m; closed clerestory walls, high columns, tracery and banners; validated 26 x 26 m battle floor retained |

New arrival at z=54, return point z=57, checkpoint at (-7,38). Existing prison,
inscription, summit portal and boss/artifact coordinates and durable IDs retained.
Navigation rebuilt after new solid gate/pavilion footprints. Lower arrival remains
26 m above baseline, reaching 44 m over the same three flights. Keep crown reaches
approximately 103 m world elevation; high exterior wings are visual architecture,
not newly traversable interiors. Pavers follow terrain shear; loose paving is
recessed beneath authored summit treads. Existing terrain collision stays authoritative.

Original geometry in `game/presentation/late_world_architecture.gd` uses registered
Poly Haven stone/roof materials. Repeated walls, shaft/drum/spire meshes are batched.
No new downloaded assets, textures, shadow lights, enemies or progression conditions.

## Actual checks before packaging

- Import/parse clean; full campaign/presentation regression after navigation and
  paving changes: 640 assertions PASS.
- Expanded-citadel floor rays and actual navigation: initial 13 assertions PASS.
- Six regions' physical floor/elevation samples PASS. Actual knight held-forward
  ascent reached (0,44,-56.18); held-back descent reached (0,26,61.18), both PASS.
- Native authored review cameras captured all eight areas plus upper citadel;
  inspected castle, forest, peaks and final hall. Corrected exposed end-wall gap,
  overly solid windows, missing roof silhouettes and floating slope pavers.
- Captures under `.tools/review/late-world-*.png`; logs `.tools/late-world-*.log`.
- Final source and Windows PCK: 20 navigation/collision assertions PASS, including
  Blackwood/Order paths past the new physical arches.
- Final native PCK wizard defeat: 19 assertions PASS; scene-07 capture inspected.
- Windows/Android match: 108 compiled game scripts, 162 character resources,
  seven locale/cloud catalogs, existing menu film/shaders and basalt material.
- APK ZIP CRC, 16 KiB alignment and v2/v3 signing PASS; signing identity remains
  `03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8`.
- Windows manifest and lossless EXE compression/hash checks PASS.

## Performance conditions and limits

Final isolated native source workload, RTX 3050 Ti laptop GPU, High, uncapped,
VSync off, 2880 x 1620 render texture under display scaling, 4x MSAA. Two-second
warmup and screenshot/readback recovery before 12 seconds timed per area:

| Area | Mean FPS | Median ms | P95 ms | Worst ms | Frames >33 ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Expanded citadel entrance | 49.73 | 19.60 | 23.79 | 48.38 | 7 / 598 |
| Active ritual encounter | 63.45 | 15.87 | 18.07 | 19.81 | 0 / 762 |

Report: `.tools/late-world-performance-single.json`. Not native-1080p measurement,
not locked 60, not an exported standalone/real-phone benchmark. Source workload
forces boss phase and restores knight health. Ordinary desktop background load
and power state are uncontrolled. Earlier six-area report was contaminated by
another isolated HUD capture still running; retain for diagnostics, not comparison.
Full human campaign, camera feel and sustained Nothing Phone (3a) testing pending.

## Storage

Owner explicitly authorized removal of only three duplicate ZIPs:
`build/Last-Light-windows-v0529.zip`, `Last-Light-windows-v0530.zip` and
`Last-Light-windows-v0533.zip`, total 1,501,086,572 bytes. Verified the corresponding
extracted PCKs exist first. Receipt `.tools/late-world-approved-cleanup.json`.
Retained all extracted old versions/APKs/saves; lossless NTFS compression of
selected generated caches/old PCKs is SHA-256 verified. No additional deletion.

## Local packages

`Play-Latest.cmd` now selects `build/windows-v0537/LastLight.exe`.
Android code 42: `build/android-releases/LastLight-0.5.37.apk`, 426,192,891 bytes,
SHA-256 `EFE52E3415063CE7E588028C5948C82FCB6A1BBD3E63B53208E742EC71354CBA`.
Windows PCK SHA-256 `DEE2BE8CB2B4C33439AC7F03D101BCDBE7CF16096ADB40985FF50EEEE0854255`.
Full receipt `.tools/late-world-release-hashes.json`. No duplicate Windows ZIP.
Owner subsequently authorized Android upload: https://gofile.io/d/ktSFPiUO.
Remote name/size/MD5 match the local APK; public download page returns HTTP 200.
Private upload receipt remains in `.tools/android/gofile-upload-v0537.json`.
`Preview-Castle.cmd` runs a separate memory-only source journey at the new arrival
for direct owner review. It does not load the owner's actual saves/account.
