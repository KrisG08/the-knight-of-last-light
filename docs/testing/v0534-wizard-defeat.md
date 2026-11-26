# Maldrek victory choreography — v0.5.34

2026-11-08, Godot 4.7.2.stable.official.ed1daf0bf. No Git repository/commit.

## Behavior

The real lethal hit on Maldrek triggers a twelve-second live 3D cinematic in
the current ritual arena. Existing boss geometry staggers, kneels with temporary
three-bone leg skins, then collapses. Camera uses directed close, side and wide
shots with gradual pushes/pullback and checks walls before positioning. A bounded
54-particle decorative stream retreats toward the intact central artifact.
The knight faces the wizard and lowers the sword. Two additional scripts and a
small translation catalog implement this without a new movie download/encode.

The chapter records/saves the existing boss reward before playback. Gameplay
physics and input pause, touch fingers release, HUD/health meters/world labels
hide, and the current camera is retained. Skip/Esc or automatic completion
restores the original camera, actor geometry, labels and controls. Both paths
leave the explicit artifact-ending interaction intact. No campaign completion,
extra boss rewards, currency or health changes originate from the cinematic.
Loading an already defeated boss uses the existing restore path without replay.
Captions and Skip use the shared title font and all five game languages.

## Verification performed

- Complete headless campaign/presentation suite: **639 assertions PASS**.
  Actual wizard victory checked for durable save, pending artifact, cinematic
  camera/input ownership, blocked travel/artifact interaction and skip cleanup.
  Existing ritual save-failure/retry, postgame and reward-once checks still pass.
- Cinematic source checks: **19 assertions PASS** with Dummy/headless rendering.
  Actual knight attack sweep delivers the lethal hit, cancelling further capsule
  movement within the same physics tick; directed cameras change position; knight
  capsule/health and artifact position/progress remain unchanged; effects are
  capped and noncolliding; the timeline automatically completes exactly once
  and restores gameplay. Version and all four non-English caption translations
  checked. Preview advances to directed sample times, then runs
  the last interval normally to verify automatic completion. It is not a
  measured full-duration playback/FPS benchmark.
- Native frames at 1, 4, 7 and 10 seconds captured in
  `.tools/review/wizard-defeat/scene-*.png`. Close and collapse frames reviewed.
  This fixture uses authored progression state, not a clean-start playthrough.
- Continuous native twelve-second playback through `Preview-Victory.cmd`'s
  actual script completed with exit 0; no frame-time/phone benchmark claimed.
- Import/parse and final native log have no SCRIPT ERROR/ERROR lines.

Logs: `.tools/wizard-defeat-import.log`, `.tools/wizard-defeat-full-tests.log`,
`.tools/wizard-defeat-preview-final.log`.
Final source checks: `.tools/wizard-defeat-translation-check.log`.
Continuous native playback: `.tools/wizard-defeat-continuous-preview.log`.

Visual review exposed stretched golden torch flames. Their shader used vertex
height as the sway weight, which becomes about 44 after terrain elevation is
baked into arena geometry. Replaced this with normalized UV height and bounded
4 cm/3 cm displacement. Repeat native capture shows normal local flames instead
of long arcs. Also explicitly hides stale boss health meter/attack telegraphs
before freezing gameplay.

## Packaging/storage

Windows export supports optional `-SkipArchive`; normal builds still produce ZIP.
This release uses the runnable folder without a duplicate archive to limit disk
usage. Older runtime/PCK files and two Windows templates were losslessly
filesystem-compressed, each SHA256 checked before/after. No old build, save or
artwork was deleted. Receipts `.tools/wizard-build-compression-receipt.json` and
`.tools/wizard-template-compression-receipt.json` record exact paths/checksums.

Android real-device playback/frame rate and owner art-direction review remain
pending. Online account/SMTP limitations are unchanged.

Final APK: `build/android-releases/LastLight-0.5.34.apk`, 424,070,282 bytes,
SHA256 `ae821c384b12da1cb01b73b1370e243ba4b7619bbfad8d2f5de82edd8a206f79`.
The last engine signing attempt ran out of temporary disk space; recovered its
aligned output and signed it separately with the configured debug key. Final
alignment and v2/v3 signatures verify; signing certificate matches the preceding
release, CRC passes. See `.tools/v0534-final-alignment.log`,
`.tools/v0534-final-signing.log`, `.tools/v0534-apk-receipt.json`.
Windows folder manifest hashes verify in `.tools/v0534-windows-receipt.json`.
Both platforms match: 105 compiled scripts, 162 character resources, six locale/
cloud catalogs, menu movie/grade shader and corrected torch shader.
Packaged localization: 39 assertions PASS.
Final isolated Windows package cinematic checks: **19 assertions PASS**, native
Vulkan/Mobile renderer, with frames in `.tools/review/wizard-defeat-package`.
Logs: `.tools/v0534-package-cinematic.log`, `.tools/v0534-platform-parity.log`,
`.tools/v0534-package-localization.log`. Latest now targets `windows-v0534`.

Owner explicitly chose **local only** for this release. No v0.5.34 upload was made.
