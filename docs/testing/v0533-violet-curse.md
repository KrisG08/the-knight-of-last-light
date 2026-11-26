# Violet curse and moonlit menu — v0.5.33

Date: 2026-11-08. Godot 4.7.2.stable.official.ed1daf0bf, Mobile renderer,
RTX 3050 Ti Laptop GPU. No Git repository/commit is present.

## Owner request and implementation

Owner confirmed that violet applies both to the curse across the world and to
interface accents. Menu film now uses 18% horizontal overscan and an additional
8% viewport-width shift left. A luminance-gated warm yellow fill reveals existing
cloak, armor and stone details. The original crater-face moon is reused with a
pale gold tint and restrained halo, placed between protected title and navigation.
Two broken, tapered violet filaments orbit the castle at different heights;
a small curling plume joins them. All animation uses the menu's explicit clock
and freezes together with the movie when Animated menus is disabled.

The original 720p/30 fps twelve-second film is unchanged, SHA256:
`dfa0b55c7ca4c5779fed4d4651baeb84026a095a550f6f1b4f90a036ef7ddcb0`.
No new third-party art was added. Moon provenance remains in the original sky
asset documentation. Toggle and slider SVGs are original code-authored UI art.

Buttons, focus/hover borders, input fields, popup lists, toggles, sliders,
scrollbars, mobile icons and HUD frames use violet accents. Health stays red
and stamina green to preserve functional recognition. Safe lanterns use warm
gold light; seals, magical wards, wizard spells and hostile magical details use
violet. Existing cleansed terrain colors remain intact.

All eleven loaded-region types receive decorative curse presence: at most
32 CPU particles and one shadowless local light per region, without collision,
navigation, interaction or damage authority. Burial/Root/Oath/Forge areas stop
these effects after their seal breaks; remaining areas stop after the finale.
Regional atmosphere blends toward violet before final cleansing.

## Executed checks

- Headless complete campaign/presentation suite: **633 assertions PASS**.
- Curse state, effect cap, no collision, live seal cleanup: **37 assertions PASS**
  with Dummy audio driver. This does not test sound output.
- Native menu layout: **80 assertions PASS**, five languages at 1600x900,
  1600x720 and 1280x960. Moon stays on-screen and off the title; reduced motion
  freezes the movie artwork clock, moon halo and curse shader.
- Native actual decoder loop: **11 assertions PASS**, including real loop
  boundary, pause/resume, hidden pause and aspect coverage.
- Native main/pause section capture and button routes: **PASS**, 100 views.
- Eight native region debug camera views captured. Crypt and current desktop
  menu/settings views visually reviewed. These use authored fixtures/debug
  travel, **not a clean-start campaign playthrough**.

Evidence: `.tools/violet-full-tests.log`, `.tools/violet-rules.log`,
`.tools/violet-menu-layout-final.log`, `.tools/violet-loop-final.log`,
`.tools/violet-menu-sections-capture.log`, `.tools/violet-regions.log`,
`.tools/review/wind-*`, `.tools/review/sections-*`, `.tools/review/violet-*`.

A native capture exposed two old lantern material cache consumers comparing
null overrides to an absent cache entry. Updated both to guard null and select
the new warm-lantern resource. Repeated native regions and full suite pass.
The save-and-return assertion previously demanded the obsolete static menu
image. It now accepts the actual decoded movie or visible fallback, retaining
all session, pause, input and menu-state checks.

## Storage and limitations

38 old standalone executable copies were losslessly compressed with Windows
XPRESS16K filesystem compression. SHA256 before/after is identical for each.
No files, old packages or saves were deleted. Receipts:
`.tools/compression-probe.json`, `.tools/build-executable-compression-receipt.json`.

An already-running owner window was v0.5.31, explaining why opening the launcher
alone could leave an older menu visible. Latest launcher must point at the
verified v0.5.33 export. Real phone brightness/performance review remains pending;
native desktop captures do not certify Android FPS. Existing SMTP/recovery and
memory-only login limitations remain unchanged.

## Verified delivery

Windows `build/windows-v0533`, Latest launcher updated. Isolated PCK:
39 localization assertions and 11 native decoder assertions PASS. Native menu
capture reviewed from the exported PCK; actual executable window title and menu
v0.5.33 also observed. The fresh preview was closed at the menu. Reopening
Latest with the usual save environment could not complete because computer-use
app approval timed out; owner can open the launcher directly.

Android code 38, version name `0.5.33-violet-curse`; v2/v3 signature verifies.
Windows/Android parity: 103 compiled game scripts, 162 character resources,
five locale/cloud JSON files, original movie and grade shader identical.
Logs: `.tools/v0533-package-localization.log`, `.tools/v0533-package-loop.log`,
`.tools/v0533-package-menu.log`, `.tools/v0533-platform-parity.log`.
Both archives pass full CRC checks; Windows ZIP README version and every file's
manifest SHA256 also checked. Receipt: `.tools/v0533-package-receipt.json`.

- Windows ZIP: 502,746,244 bytes, SHA256
  `8c64c7ff4c3ab474dc488d1c9710135aea14c19d3bba58c67203aaeb2fda5057`.
- Android APK: 424,057,511 bytes, SHA256
  `1dcfe37c9aa9a040ea8f7b51d295e5f933798be78d2070ebaa5297b8cbd59e4f`.

Owner explicitly approved uploading only this APK to Gofile:
https://gofile.io/d/f8WsUW4i. Returned filename/size match the verified package;
remote reported MD5 `683d398687a95bb16ef0bd63d66d13d2`.
Local MD5 matches the upload receipt; download page returns HTTP 200.
Receipt `.tools/android/gofile-upload-v0533.json` includes a private management
token and must not be printed or included in public deliverables.
