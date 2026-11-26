# Moon atmosphere and directed gaze — v0.5.43, 2026-11-10

## Change

Owner found the bright face disconnected from the low-light menu film and asked
for matching light/shadow and a gaze toward the knight. The existing face shader
now applies broad spherical directional shade, cool blue albedo grading, aerial
haze and soft edge transparency. The existing storm panorama supplies moving
screen-coordinate cloud attenuation, allowing the actual movie underneath to
show through. Replaced the yellow halo with a much weaker cool halo.

This is an authored atmospheric composite, not a claim of physical sky lighting.
The shared pausable menu clock drives the face and clouds. Gaze is calculated
from the moon center toward the authored knight position after menu layout;
small movements do not scan away from the knight. Existing title exclusion,
animation, video, controls, gameplay and save schema remain intact.

## Actual checks

- Godot 4.7.2.stable.official.ed1daf0bf, Vulkan Mobile, RTX 3050 Ti Laptop GPU.
- Native source menu layout/motion: **96 assertions PASS**, five languages and
  three aspect ratios. Includes gaze alignment toward the knight, title exclusion,
  viewport bounds and reduced-motion uniform/clock freeze.
- Final Windows PCK native capture: face poses at 0/2/5/8 seconds and actual
  menus at 1600x900 and 1600x720. Desktop menu and face closeup inspected:
  `.tools/review/moon-atmosphere-package/`. Source comparison captures:
  `.tools/review/moon-sky-blend/`.
- Final Windows PCK real decoder loop/pause/resume test: **11 assertions PASS**.
- Windows/Android parity PASS for the current face shader, 112 compiled game
  scripts, 162 character resources, seven catalogs/configuration files and
  retained effects/menu film. Platform-specific opening encodes remain current.
- Android code48, `0.5.43-moon-atmosphere`, 424,342,580 bytes. APK CRC, v2/v3
  signature and 16 KB alignment PASS; signer matches existing releases.
  SHA-256 `8cdf5e5d47f8d23684f96d23a86e7853abd3c2793e291a1d27646e34fe43336c`.
- Windows manifest hashes PASS; release hashes saved in
  `.tools/moon-atmosphere-v0543-release-hashes.json`.
- No source/package shader error observed. Android badging inspection retains
  its themed-icon warning. No real phone installation, FPS/thermal result or
  unrelated full campaign acceptance is claimed for this presentation increment.

Logs: `.tools/review/moon-atmosphere-{windows-build,android-build,layout,parity,
package-capture,package-loop}.log`.

## Delivery and cleanup

`Play-Latest.cmd` selects `build/windows-v0543/LastLight.exe`; Android is local
at `build/android-releases/LastLight-0.5.43.apk`. No public upload authorized.
QA used isolated storage and did not open owner saves. Owner specifically
approved deleting only ZIP archives v0510, v0511 and v0512. Absolute paths were
checked against the workspace build directory before native PowerShell removal;
all extracted versions/APKs/assets/saves remain. Receipt:
`.tools/approved-cleanup-moon-atmosphere.json`.
