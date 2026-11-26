# World population — 0.5.12

Owner requested passive inhabitants from the beginning through every map area.
31 new placements extend the previous 12, totaling 43 in 11 regions:

| Region | Count |
|---|---:|
| Refuge / starting road | 6 |
| Village | 4 |
| Crypt | 2 |
| Blackwood | 7 |
| Grove | 2 |
| Order | 3 |
| Sanctum | 2 |
| Peaks | 6 |
| Forge | 2 |
| Citadel | 6 |
| Ritual | 3 |

Goblins/dwarves stroll on validated short corridors, troll retains its existing
route. Wraiths visibly bob, drift and sway locally. Stone statues and dragons
retain their existing scenery behavior. Road folk use the terrain height callback
as they move; no circular dependency on the forest generator. All are passive,
with no damage receivers, interactions, physical blockers or campaign effects.
No new model downloads, save changes or added enemy AI. Previous art limitations
remain: stylized/procedural inhabitants, not photoreal production characters.

Validation: full regression suite; dedicated actual-region population audit
verifies minimum two inhabitants per region, passive membership/collision rules,
all walking routes enabled, expanded obstacle clearance and floor ray hits for
walking folk. Logs `.tools/population-tests.log`, `.tools/population-audit.log`.
Native capture traverses all 11 regions and checks walking across rendered
frames, with a capture per placement plus walking follow-ups. Evidence:
`.tools/population-capture.log`, `.tools/review/population-*.png`.
Contact-sheet visual review identified a roadside rock occlusion and a lamp in
front of the citadel goblin; those placements were moved. Interior QA cameras
adjusted to remain inside halls. No phone/FPS/full campaign acceptance claimed.

Final audit: 43 inhabitants / 11 areas / zero failures. 551 regression assertions
PASS without script errors. Native final run: 43 placement screenshots and 24
walking follow-ups. Contact sheet reviewed; final refuge goblin and Order wraith
camera views inspected separately, plus moved citadel goblin. Refuge-only final
capture log: `.tools/population-refuge-capture.log`.

Windows v0512 build/ZIP complete, manifest verified and native headless boot exit
0. Android code 17 / 0.5.12-populated-world signature/CRC/attribution verified.
All 87 compiled game scripts match between platforms. Logs:
`.tools/v0512-windows-build.log`, `.tools/android/v0512-export.log`,
`.tools/v0512-pack-parity.log`. APK: `build/android-releases/LastLight-0.5.12.apk`.
SHA256: `5DAE05F6498ED4C75777267419EED0F5EE120BF0B1393E8605E1E2DCC6E3EE19`.
Play-Latest targets v0512, preserving prior builds and saves. Not uploaded externally.
