# Violet Midnight environment pass — v0.5.61

2026-11-21. Godot 4.7.2.stable.official.ed1daf0bf; native Vulkan Mobile on the
RTX 3050 Ti laptop. No Git repository/commit is available in this workspace.

## Actual checks

- Import/parse completed; no script errors in final Windows/Android export logs.
- Deterministic campaign, runtime movement/presentation and optional cloud
  replica suite: **644 assertions PASS**. Log:
  `.tools/review/concepts-campaign-final.log`.
- Native source world sweep: **58 assertions PASS** after fitting chamber
  details inside the existing walls and moving showcase cameras out of portals.
  A later Peaks-only art correction added support towers beneath its high
  windows; the final package sweep below includes this correction.
- Final exported Windows PCK mounted with the pinned editor console: **58
  assertions PASS** across all eleven regions, checking transition success,
  authored detail, readable-light bounds, violet sky, valid progress and restored
  dawn after campaign completion. The beam-axis regression checks both authored
  endpoints. Log: `.tools/review/concepts-package.log`.
- Native screenshots of all eleven regions rendered at 1600x900, unedited.
  Source captures inspected across all eleven; final package Peaks/Citadel also
  inspected after the support correction. These are showcase cameras with hero,
  HUD and hostiles hidden, not default gameplay camera screenshots.
- Windows manifest: all listed file sizes and SHA-256 values verified.
- Android versionName **0.5.61**, versionCode **66**, established signing
  certificate, v2/v3 signature verification and 16 KiB page alignment: PASS.
- Platform parity: **125** compiled game scripts, **162** prepared character
  resources, **11** locale/cloud files; shared sky, existing title/moon/cloud/UI/
  character/waygate shaders, five music loops, three native catalogs and current
  platform-specific cinematic encodes: PASS.
- Local gallery links resolve; eleven selected concepts and eleven separate raw
  engine captures exist. Concepts are excluded from runtime export.

## Deliverables

- `build/windows-v0561/LastLight.exe` and accompanying PCK; `Play-Latest.cmd`
  selects this version using the existing owner save directory.
- `build/android-releases/LastLight-0.5.61.apk`, **433837555 bytes**.
- APK SHA-256:
  `77B3BAF88D8EC5B602F49325F809597CE7CC7C1292535392288D4A7E3A94DA46`.
- `art_exports/world-concepts-v061/index.html`: target concepts with links to
  raw engine comparison captures under `in-game/`.

## Limits and next review

This is an authored environment/lighting pass following the selected concepts,
not a photorealistic one-to-one reconstruction. Existing vegetation cards,
modular architecture, terrain materials and simplified lighting are still
noticeably less detailed than the generated targets. See
`docs/art/violet-midnight-worlds.md` for scope and provenance. Main menu/opening
films remain the previous encodes. No real-phone FPS, thermal or RAM measurement;
no five-hour human playthrough or new all-region performance certification.

Known pre-existing Android tooling warning: unused adaptive themed-icon resource
reference. APK signing/alignment succeed. No public upload, deletion or owner-save
mutation was performed. Automated fixtures use isolated user data and memory-only
journeys. Next: owner review of the darker palette in ordinary play, then closer
organic vegetation, surface variety and moon/cloud integration where required.
