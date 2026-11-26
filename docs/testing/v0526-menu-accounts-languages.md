# v0.5.26 validation — 2026-11-08

Godot 4.7.2.stable.official.ed1daf0bf, Windows, Mobile renderer; no Git repository.

Implemented: original animated menu panorama, charcoal/brass navigation,
hover/focus ornament, reduced-motion option, native-name language selection,
English/Bulgarian/Russian/French/Arabic presentation, Cyrillic/Arabic font
fallbacks, optional account panel, private account save libraries and Supabase
revision-checked replicas. The campaign remains usable offline without login.

## Executed checks

- Full campaign/presentation suite: **627 assertions PASS**. The final run used
  `.tools/trace_runner.gd`, generated directly from `tests/run_tests.gd` with
  extra progress prints. Evidence `.tools/runtime-trace.log`. Earlier runs exposed
  three empty machine-translated values; these were corrected before this pass.
- `tests/cloud_disk_smoke.gd`: **5 checks PASS**, including durable-save signal
  suppression on failed promotion and replacement of an existing sidecar file.
  Evidence `.tools/cloud-disk-smoke.log`.
- Replica integration checks use two in-memory clients against a deterministic
  fake transport: first upload, second-client download, boss progression,
  explicit guest import, divergent offline branches, isolation and network loss.
  These are part of the 627 assertions; they are not live-device verification.
- Native render capture of menu/account/settings in all five languages plus
  Bulgarian/Arabic HUD: `.tools/language-final.log`, screenshots in
  `.tools/review/menu-*.png`, `account-*.png`, `settings-*.png`, `world-*.png`.
  Arabic shaping and mirrored navigation were visible. Core menu, French
  settings, Bulgarian account and HUD reviewed visually.
- Touch frontend native captures at 1600x720, 1280x960 and 150% text;
  all seven viewport checks PASS. Reduced menu motion freeze PASS.
  Evidence `.tools/v0526-touch.log`. Desktop simulation, not an Android device.
- Headless import completed without script errors:
  `.tools/premium-import-final.log`.
- Supabase project `vtvvevevkhqwyemrpawy`: private table/RLS and commit function
  installed through SQL Editor; UI reported Success. Public auth settings show
  email login enabled and email confirmation retained.
- Real HTTPS anonymous table read and complete-parameter RPC commit each
  returned HTTP 401 / SQLSTATE 42501, permission denied. Evidence
  `.tools/cloud-anon-read.json`, `.tools/cloud-anon-write.json`.

## Limits and owner action

SMTP is **not configured**. Supabase's default sender is restricted to project
organization members and template editing requires custom SMTP. Registration
is therefore marked as testing; default email confirmation link is supported,
but in-app password recovery is visibly unavailable. Ready templates and owner
steps are in `docs/SMTP-SETUP.md`. Do not disable email confirmation to bypass it.

No live account creation, real two-device synchronization or password recovery
has been verified. Session tokens/passwords are memory-only; login is required
after restart to reopen an account library. Guest saves remain separate.

Gameplay/story translation is machine-assisted with manual core UI corrections;
native-language literary review is pending. New source art is 1672x941, not 4K.
No new frame-rate benchmark or physical-device performance claim is made.
Windows and Android package verification is recorded after export below.

## Export results

- Windows: `build/windows-v0526/LastLight.exe` + `.pck`, archived as
  `build/Last-Light-windows-v0526.zip`. Build exit 0. Real executable headless
  boot from its own directory, isolated test data, exit 0 and clean log:
  `.tools/v0526-exe-boot.log`. This does not constitute a new interactive playthrough.
- `tests/v0526_package_smoke.gd` run with the exported Windows PCK as the main
  pack, from its package directory: **10 checks PASS**. No source-project asset
  fallback. Version, four extra catalogs, public config, image, fonts, menu and
  account route checked. Evidence `.tools/v0526-windows-package.log`.
- Android: `build/android-releases/LastLight-0.5.26.apk`, **412,319,141 bytes**,
  SHA256 `B94217D2133ACD8E9FC46C3A67BAEF7D285688DBF0BF5F61F1C5C0627C87069D`.
  Package `org.lastlight.knight`, versionCode 31,
  versionName `0.5.26-menu-languages`; signature v2/v3 verified, one signer.
  `aapt dump permissions` confirms `android.permission.INTERNET`.
- Legacy `aapt dump badging` printed the correct version but also an unsupported
  manifest-attribute warning for `android:required`; do not report that command
  as a clean pass. Signature verification and permission inspection passed.
- Platform parity: **99 compiled game scripts, 162 prepared character resources,
  3 locale/cloud configuration files identical**, all PASS.
  Evidence `.tools/v0526-parity.log`.
- Android and Windows ZIP CRC checks passed. Launchers updated to v0.5.26 only
  after package validation. No upload, publication or real-phone install performed.
