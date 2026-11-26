# Stacked utilities and castle composition — v0.5.46, 2026-11-10

## Implemented

Account/sign-in now sits above language in a compact bottom-left VBoxContainer,
honoring safe margins and UI scale. Existing native button callbacks, account
modal and language selection remain intact.

The same twelve-second film is reframed further left with 1.46-width minimum
overscan, retaining its original aspect ratio. An authored helmet landmark in the
movie is placed near the end of the translated tagline, bounded to retain the
castle composition and viewport coverage. This translates and scales the film;
it does not stretch it or re-encode the media. The main citadel landmark now sits
left of the navigation card. The procedural fallback knight and lunar gaze use
the new composition position. Layout also refreshes on menu/pause mode changes.

## Actual checks

Godot **4.7.2.stable.official.ed1daf0bf**, Vulkan Mobile, RTX 3050 Ti Laptop GPU.

- Final Windows PCK `tests/menu_utilities_layout.gd`: **556 assertions PASS**.
  Five languages, three viewport proportions, UI scales 100/125/150%. Covers
  vertical ordering/alignment, viewport and title/navigation separation, touch
  sizes, full movie edge coverage, helmet anchor, castle landmark and actual
  account/settings panel signal routes.
- `tests/menu_wind_capture.gd`: **98 assertions PASS**, including title/foreground
  separation, knight-directed gaze, cloud layer order and reduced-motion clocks.
- Final Windows PCK `tests/menu_loop_playback.gd`: **11 assertions PASS**, actual
  decoder wrap, pause/resume, hidden-menu suspension and aspect/cover behavior.
- Final native package desktop and wide-phone Bulgarian captures inspected:
  `.tools/review/menu-framing-package/1600x900-bg-1.0.png` and
  `1600x720-bg-1.0.png`. Source iteration views:
  `.tools/review/menu-reframe-source/`.
- Windows/Android parity PASS: exact current face/cloud/effect assets, **112**
  compiled game scripts, **162** character resources and **seven** catalogs,
  retained menu film and appropriate platform-specific opening encodes.
- Android code **51**, name **0.5.46-menu-framing**, **424,353,464 bytes**. CRC,
  v2/v3 signatures, established signer certificate and 16 KB alignment PASS.
  SHA-256 `981d1598e02100c9625d8939e53565040d12372270c9e0921249190a21fca2af`.
- Windows manifest hashes PASS; receipt:
  `.tools/menu-framing-v0546-release-hashes.json`.

Logs: `.tools/review/menu-framing-{layout,wind,loop,windows-build,android-build,
parity}.log`. No owner journey/account was loaded; fixtures use isolated storage.
No physical phone performance test or unrelated full campaign replay is claimed.
Android badging inspection retains the previously recorded themed-icon warning.

## Low-space Android packaging

To avoid another simultaneous set of Godot signing copies, helper
`.tools/android/build-low-space.ps1` exports unsigned staging, restores
`export_presets.cfg` byte-for-byte in `finally`, checks/repairs alignment, then
uses SDK apksigner with a separate output file and the existing debug signer.
Keystore credentials stay local and are passed through a temporary environment
variable, which is cleared. The final signed APK is independently verified.

Staging is explicitly named `build/android/LastLight-unsigned.apk`; it is not the
installable release. No change to public signing identity or gameplay rules.

## Local delivery and authorized cleanup

`Play-Latest.cmd` selects `build/windows-v0546/LastLight.exe`. Installable Android:
`build/android-releases/LastLight-0.5.46.apk`. No public upload authorized.

Owner specifically approved removal of only four duplicate ZIPs:
`Last-Light-windows-v05.zip`, `Last-Light-windows-blackwood-art.zip`,
`Last-Light-windows-burial-art.zip`, `Last-Light-windows-burial-sound.zip`.
Resolved absolute file paths were checked inside this workspace build directory
before native PowerShell removal. Extracted builds, all APK releases, assets and
saves remain. Receipt: `.tools/approved-cleanup-menu-framing.json`.
