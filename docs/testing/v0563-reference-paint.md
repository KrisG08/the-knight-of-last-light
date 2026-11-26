# Reference-faithful character paint — v0.5.63

The owner rejected a replacement palette and requested the original 2D character
colors. The final implementation preserves the original front references and all
50 original mesh surfaces. Ten matching rear references add plausible rear hair,
armor, clothing and straps without repeating faces and chest details on backs.
The shader blends references in rest space, preserving articulated movement.
Rejected palette experiments remain outside runtime under the ignored art folder.

## Actual checks, 2026-11-24

- Godot 4.7.2 stable official, Vulkan Mobile, RTX 3050 Ti Laptop GPU.
- Editor import/parse completed without reported script or shader errors.
- `tests/character_paint_checks.gd`: 50 surfaces, ten fitted rear references,
  zero failures. Positions, normals, UVs, indices, pigments and UV2 masks match
  the original resources; maximum position/normal/UV deviations are zero.
- `tests/run_character_appearance_checks.gd`: ten existing hostile appearance
  runtime checks passed, including animation, collision and health display checks.
- Native `tests/capture_character_paint.gd`: front and rear renders of all ten
  actual runtime models inspected at 1920 x 1080.
- Native `tests/capture_character_night.gd`: actual refuge knight and ritual
  Maldrek captured front/back under campaign lighting; all four images inspected.
  Fixtures use isolated test state, not the owner's journeys or cloud account.

Evidence is in `.tools/review/paired-character-checks.log`,
`paired-character-runtime-checks.log`, `paired-character-night.log`,
`character-paint-paired-final-{front,rear}.png` and
`character-reference-night-{refuge,maldrek}-{front,back}.png`.

## Limits

This is paired image projection onto existing geometry, not a new hand-unwrapped
mesh or a new rig. Oblique views and silhouette transitions can still show
alignment differences. A full campaign playthrough and physical Android device
performance were not tested for this material-only change. The earlier complete
campaign test attempt was interrupted and is not counted as a pass.

Rear image provenance and prompt constraints are documented in
`assets/models/meshy/rear-reference-colors/README.md`. Original vendor geometry
credits remain applicable. No model generation through to3D succeeded or is
claimed, and no new APK has been uploaded publicly for this task.

## Local packages

Windows release: `build/windows-v0563/LastLight.exe`, selected by `Play-Latest.cmd`.
Android debug-signed release copy: `build/android-releases/LastLight-0.5.63.apk`,
versionName 0.5.63 / versionCode 68, 654756079 bytes, SHA-256
`104E648D8AF11772061095884E0524BFDC5CDBBBAD39B9A49C8254AAFDD9BD3A`.
APK v2/v3 signature verification and 16 KiB ZIP alignment checks passed.
The older aapt badging reader prints an SDK attribute warning but reports the
expected version; this is not a device installation test.

`tools/verify_platform_packs.gd` passed: 128 compiled game scripts, 162 prepared
character resources, 185 localized voice clips, platform-specific films and
shared shaders/catalogs. `tests/verify_reference_paint_packages.gd` passed after
both exports completed: shader and all ten model definitions match current source;
all ten rear textures have valid imported data in both packages. These checks
verify packaged content, not sustained performance on the owner's phone.
The exported Windows executable also completed an isolated headless startup
with `--quit-after 8`, exit code zero (`v0563-release-smoke-final.log`). This
does not substitute for an interactive release playthrough or a frame-rate test.
