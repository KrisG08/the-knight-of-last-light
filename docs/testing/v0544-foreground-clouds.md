# Foreground lunar cloud banks — v0.5.44, 2026-11-10

## Implementation

Added a separate ColorRect after the moon TextureRect, so clouds composite in
front of the face instead of only shading its surface. The layer spans six lunar
diameters horizontally and three vertically, with faded bounds. Original smooth
multi-scale noise forms rolling banks and thin trailing wisps. Gaps reveal the
face; moderate opacity preserves the previous dim blue atmosphere. The layer
ignores pointer input and stays behind native menu text/buttons.

Clouds use the same explicit animation clock as the face/halo/curse. Reduced
motion freezes them and hidden menus stop clock advancement. The knight-directed
gaze, existing menu movie, controls, gameplay and save schema are unchanged.

## Actual verification

- Godot 4.7.2.stable.official.ed1daf0bf, Vulkan Mobile, RTX 3050 Ti Laptop GPU.
- Native menu fixture: **98 assertions PASS**, five languages at three aspect
  ratios, title/viewport safety, knight-directed gaze, frozen material clocks and
  actual foreground child order.
- Final Windows PCK captures at 1600x900 and 1600x720 with poses 0/5/10 seconds.
  Final desktop pose10 and source poses0/5 inspected. Evidence:
  `.tools/review/foreground-clouds-package/`,
  `.tools/review/moon-foreground-clouds/`.
- Final PCK moving-menu preview completed 192 native frames at a fixed capture
  step of 24 fps; actual wind movie, face and foreground cloud layers advance.
  Eight-second review encode fully decodes:
  `.tools/review/foreground-clouds-preview.mp4`. Completion log:
  `.tools/review/foreground-clouds-preview-final.log`; final stderr empty.
  The capture rate is not a measured game/phone performance claim.
- Windows/Android parity PASS: exact current foreground cloud and lunar face
  shaders, 112 compiled game scripts, 162 character resources, seven catalogs,
  retained menu/effect assets and correct platform opening encodes.
- Android code49, `0.5.44-foreground-clouds`, 424,342,675 bytes. CRC, v2/v3
  signature, existing signer certificate and 16 KB alignment PASS. SHA-256:
  `87df53d2fb7d554fc87e1faa170e51c606228eecbb65693f54b9a18c713ac859`.
- Windows manifest hashes PASS. Receipt:
  `.tools/foreground-clouds-v0544-release-hashes.json`.
- Android badging retains its previously noted themed-icon resource warning.
  No actual phone installation/FPS result or full unrelated campaign replay is
  claimed for this presentation-only increment.

Logs: `.tools/review/foreground-clouds-{layout,windows-build,android-build,
package-capture,parity}.log`. QA uses isolated storage and never opens owner saves.

## Local delivery

`Play-Latest.cmd` selects `build/windows-v0544/LastLight.exe`; Android is
`build/android-releases/LastLight-0.5.44.apk`. No public upload authorized.

Owner explicitly approved deletion of only duplicate ZIPs v057, v058 and v059.
Absolute file paths were checked inside the workspace build directory before
native PowerShell deletion. Extracted versions, all APKs, art and saves remain.
Receipt: `.tools/approved-cleanup-foreground-clouds.json`.
