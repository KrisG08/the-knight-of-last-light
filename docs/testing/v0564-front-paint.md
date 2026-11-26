# Mesh-guided front paint — v0.5.64

The owner requested improved front painting after the rear-view pass. Ten new
RGBA front references use actual orthographic runtime mesh guides and original
2D concepts. Faces, helmet slits, chest heraldry, straps, rivets, cloth weave and
fur/bark details are painted for the frontal body layout instead of the previous
diagonal projection. Original front artwork, rear references and mesh resources
remain preserved.

The runtime uses rest-space frontal coordinates with correct camera handedness.
Alpha avoids discarding light cloth and gray steel as background. Normalized
paired front/rear coverage reduces fallback-pigment bands at grazing angles.
Offline nearest-covered UV coordinate fields extend nearby paint over small
outline gaps without editing generated color images or changing geometry.
The helper uses Python's standard library; no new Python package is required.

## Actual verification, 2026-11-24

- Godot 4.7.2 stable official; native Vulkan Mobile on RTX 3050 Ti Laptop GPU.
- Editor import/parse completed without reported script or shader errors.
- Character paint checks: 50 original surfaces, ten front/rear fits and runtime
  material wiring including UV coverage textures; zero failures. Positions,
  normals, UVs, indices, pigment and mask data match the original resources.
- Ten hostile appearance runtime checks passed, covering original mesh
  partitions, collision, attack animation, pause behavior and health displays.
- Native 1920 x 1080 front, oblique and rear renders of all ten actual runtime
  models inspected. Four campaign-lit knight/Maldrek front/back captures produced.
- Source generation mapping and the complete prompt constraints are in
  `.tools/review/front-reference-sources.json` and the adjacent asset README.

Evidence: `.tools/review/front-reference-{fit,import,checks,runtime-checks,final,night}.log`,
`character-paint-front-final-{front,oblique,rear}.png` and
`character-reference-night-front-final-{refuge,maldrek}-{front,back}.png`.

## Limits

Paired image projection is still not a manually unwrapped texture atlas. Deep
overlaps, thin shapes and side silhouettes may have residual alignment changes.
This pass does not replace character topology, rigs or animations. Encoded
opening/movie footage is not re-rendered by changing live character materials.
No full campaign playthrough or physical-phone performance test was performed.
Packages remain local; this task does not authorize a public upload.

## Local delivery

- `build/windows-v0564/LastLight.exe`, selected by `Play-Latest.cmd`.
- `build/android-releases/LastLight-0.5.64.apk`, 663205401 bytes, debug-signed.
- Windows release headless startup (`--quit-after 8`) exited zero, logged in
  `.tools/review/v0564-release-smoke.log`. This is not an interactive playthrough.
- APK signature verification passed v2/v3, and ZIP alignment passed 16 KiB.
- Platform parity passed: 128 compiled game scripts, 172 character resources,
  185 voice clips, films, fonts, shaders and catalogs.
- Focused package check passed: shader, all ten model definitions and all ten
  UV fields match current source; all twenty front/rear textures have imported
  data in both packages. Logs: `v0564-platform-parity.log`,
  `v0564-reference-package-check.log`, `v0564-android-alignment.log`.
