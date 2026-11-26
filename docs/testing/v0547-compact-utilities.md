# Caption-sized menu utilities — v0.5.47, 2026-11-10

Removed the account/language fixed minimum widths and expanding horizontal flags.
Each button now uses its native text/style minimum independently. OptionButton
`fit_to_longest_item=false` sizes language selection to the displayed language,
including its arrow. Stack dimensions use the actual child minimum sizes and
retain safe margins, vertical order, native touch height and physical left
alignment in right-to-left layouts. Prior film framing and gameplay unchanged.

## Actual verification

- Godot 4.7.2.stable.official.ed1daf0bf, Vulkan Mobile, RTX 3050 Ti Laptop GPU.
- Final Windows PCK native layout/route fixture: **557 assertions PASS**, five
  languages, three aspect ratios, UI scales 100/125/150%, account/settings routes,
  containment, stacked alignment and retained scene framing.
- Layout harness now waits for an actual decoded menu frame before freezing
  screenshots; an allocated video texture alone is insufficient evidence of a
  visible frame. Final review uses the real movie, not an empty early pause.
- Final Bulgarian desktop and Arabic wide/150% captures visually inspected:
  `.tools/review/compact-utilities-package/`.
- Windows/Android parity PASS: 112 game scripts, 162 character resources,
  seven catalogs/configuration files and retained movie/material assets.
- Android code52, `0.5.47-compact-utilities`, 424,353,464 bytes; signature retains
  the existing certificate. CRC, 16 KB alignment and Windows manifest PASS.
  APK SHA-256 `a250ef37732350a41b4a0f1090e217d4af26cb98dc0ffc9633b4eadf9b0ee03d`.
  Receipt: `.tools/compact-utilities-v0547-release-hashes.json`.

Logs: `.tools/review/compact-utilities-{layout,windows-build,android-build,parity}.log`.
Native UI fixtures use isolated storage. No owner journey/account was loaded,
no unrelated full campaign rerun or physical phone FPS test is claimed. Existing
Android themed-icon badging warning remains recorded in earlier package reports.

## Delivery

`Play-Latest.cmd` selects `build/windows-v0547/LastLight.exe`. Signed Android:
`build/android-releases/LastLight-0.5.47.apk`. Existing low-space SDK signing
workflow restored the signed preset; no further archive cleanup was necessary.
No public upload authorized for this version.
