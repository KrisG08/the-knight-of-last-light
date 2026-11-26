# Bottom-left utilities and stone fracture refinement — v0.5.45

Date: 2026-11-10. Godot 4.7.2.stable.official.ed1daf0bf, Vulkan Mobile,
RTX 3050 Ti Laptop GPU. No Git repository present; no commit created.

## Implemented

Account/sign-in and the native-name language selector now occupy a bottom-left
utility row, honoring display safe margins and UI scale. The journey card starts
at the top margin and gains the previous header space. Existing account/language
callbacks, modal hiding, pause restrictions and mobile targets remain native.

Shared stone StyleBox fractures now form connected unequal plate seams and
branches instead of repeated mirrored lightning marks. Deterministic small-scale
weathering breaks long straight segments. Dark recesses, raised mineral lips,
layered violet glow and finer cores add depth. Fractures use content margins to
preserve caption space. Existing basalt texture retained; no reference pixels or
new external assets downloaded. This is an authored native UI treatment, not a
claim of a scanned 3D button asset.

Visual review exposed default flat OptionButton surfaces in Arabic. Added
mirrored theme states so language/journey selectors retain the stone treatment
under right-to-left layout.

## Actual checks

- Final Windows PCK `tests/menu_utilities_layout.gd`: **331 assertions PASS**.
  Five languages, 1600x900 / 1600x720 / 1280x960, UI scales 100/125/150%.
  Checks viewport bounds, bottom-left position, separation from title/navigation,
  child containment, non-overlap and usable targets. Relocated account button
  signal opens its actual panel; settings route opens its actual panel.
- Source `tests/menu_wind_capture.gd`: **98 assertions PASS**, retained title,
  moon/knight gaze, cloud layer order and reduced-motion behavior.
- Native final-package images reviewed: Bulgarian normal/150%, Arabic wide
  150%, account form and settings. Evidence:
  `.tools/review/stone-menu-package/`. Source iteration:
  `.tools/review/menu-utilities-stone/`.
- Windows/Android parity PASS: 112 compiled game scripts including final shared
  style/UI code, 162 character resources, seven catalogs/configuration files,
  retained face/cloud/menu shaders and platform opening films.
- Android code50, `0.5.45-stone-menu`, **424,346,771 bytes**. v2/v3 signatures,
  retained signer certificate, CRC and 16 KB alignment PASS. SHA-256:
  `b082c5f3dd93bd110f978b6695ecf99bd9fa1c87e12886743beef33e6a2c6df5`.
- Windows manifest hashes PASS; receipt:
  `.tools/stone-menu-v0545-release-hashes.json`.

Logs: `.tools/review/stone-menu-{layout,wind,windows-build,android-build,parity}.log`.
Fixtures use isolated storage; no owner journey/account was opened. No physical
phone test, controller acceptance, performance measurement or unrelated full
campaign replay is claimed. Android badging retains the previously recorded
themed-icon resource warning.

## Signing recovery and local delivery

Initial Android signing failed explicitly for disk space. Owner separately
approved deleting duplicate ZIPs v054/v055/v056, then v052/v053 when temporary
signing space remained insufficient. Every absolute target was checked inside
this workspace build directory before native PowerShell removal. Extracted
versions, all APK releases, source assets and saves remain. Receipts:
`.tools/approved-cleanup-stone-menu.json` and
`.tools/approved-cleanup-stone-menu-signing.json`. Retried export/signing then
completed and final APK was independently verified.

`Play-Latest.cmd` selects `build/windows-v0545/LastLight.exe`. Android remains
local at `build/android-releases/LastLight-0.5.45.apk`; no public upload authorized.
