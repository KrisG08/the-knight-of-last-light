# Forested night — 0.5.22

Owner reference: bare pale hills behind Ashen Village. Requested forests and a
much darker sky. The shared background now has broken rock relief, dark woodland
soil, a higher snow line and dense pine belts in all eleven regions. Storm panorama
brightness is 0.18–0.24 of its original texture; moon brightness is independent.
Regional fog and the custom terrain/sky horizon share a darker tint.

Background pines are fixed-axis, alpha-tested impostors baked locally from the
full-detail CC0 Pine Sapling Small meshes, including two smaller understory trees
per cluster. This preserves fine needles without repeating high-poly geometry.
Three 512x768 RGBA images use mipmaps and MSAA alpha coverage. Existing close-up
trees remain meshes. Background clusters have no collisions or gameplay actions.
They are seated on the same triangles as the fitted landscape; slope filtering
and grouped instancing limit work. This is cosmetic relief outside authored maps,
not generated playable geography.

## Checks performed

- Godot 4.7.2 import/parse and campaign suite: 587 assertions PASS,
  `.tools/forest-final-tests.log`.
- All 11 terrain perimeter checks PASS, each 385 samples, maximum reported seam
  0.000 m. Every backdrop has over 5,000 accepted pine clusters and no added
  collision shapes: `.tools/forest-night-seams-final.log`.
- Prototype geometry check: two triangles per cluster and normalized height
  1.06, `.tools/distant-forest-budget-pass.log`.
- Actual native north/edge captures entered all 11 unlocked regions; village and
  Peaks images reviewed. Capture logs: `.tools/forest-night-capture.log` and final
  `.tools/forest-final-native.log`; images `.tools/review/sky-*.png`.
- Native movement/attack/dodge/sprint capture: `.tools/forest-performance.log`.
  Stationary forest 180-frame sample median 8.84 ms, p95 10.04 ms, engine static
  memory 129.2 MiB, rendered primitives 8,340,353 on this RTX 3050 Ti laptop.
  This is neither a complete campaign performance run nor a phone measurement.

## Limits

The distant tree clusters face the camera and can reveal repetition during fast
sideways camera movement. Near forests still need mature tree asset variety.
Regional art and animation remain a developing game, not photorealistic production
assets. Android must still be visually and performance tested on a real phone.

Windows packaged boot exited 0. Windows/Android comparison: 93 compiled game scripts and 162 character resources identical. Android signature verification passed. Local packages: build/windows-v0522 and build/android-releases/LastLight-0.5.22.apk. Latest launchers point to v0.5.22; existing user data path retained.

Owner explicitly approved Gofile distribution of 0.5.22 on 2026-11-07. Uploaded https://gofile.io/d/guaaJRVE ; remote LastLight-0.5.22.apk size 434020910 and MD5 ac228762829dd504cc1ed96c9901e0e9 match local; download page HTTP 200. Earlier automatic-review block resolved by explicit payload/site permission.
