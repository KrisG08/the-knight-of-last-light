# Unified fantasy typography and enchanted title — v0.5.48

Date: 2026-11-10. Godot 4.7.2.stable.official.ed1daf0bf, Vulkan Mobile,
RTX 3050 Ti Laptop GPU. No Git repository or commit.

## Implementation and provenance

El Messiri by Mohamed Gaber and Jovanny Lemonad is the common primary family for
Latin, Cyrillic and Arabic. Official metadata declares all three plus Latin-ext:
https://github.com/google/fonts/blob/main/ofl/elmessiri/METADATA.pb . Description:
https://github.com/google/fonts/blob/main/ofl/elmessiri/DESCRIPTION.en_us.html .
Unmodified font downloaded from the official Google Fonts repository; 138,664
bytes, SHA-256 `5d58d5259d2accccba39cffe12e1226e88b6afc5150e3605eb2a9c2fe06ccab0`.
Bundled license: `assets/fonts/ElMessiri-OFL.txt`, SIL OFL 1.1. Asset register,
font manifests, package notices and translated credits updated. Legacy fonts and
their notices retained; Source Sans is only an exceptional-symbol fallback.

Body/buttons use native variable weight 500; title uses 700 and 0.4 emboldening.
OpenType weight is assigned with its integer tag. Native TextServer variation
coordinates verified as 500/700, not inferred solely from resource text.
The previous Bulgarian face was Noto Serif, not Times New Roman.

Main title has an explicit font-role metadata value. Localization preserves that
role instead of replacing its bold font with the body variation on every locale
change. Label geometry drives the silver-violet diagonal sheen across words;
font-atlas UVs are not used as whole-title coordinates. A slow breathing light,
dark outline and shadow add depth. Native glyph positions/shaping remain intact,
including joined Arabic. Explicit menu clock controls all motion; no shader TIME.

## Actual checks

- Native raw-font audit: **177 unique catalog letters/marks, zero missing**.
  `.tools/review/fantasy-font-coverage.log` records family and actual native axes.
- Campaign/presentation suite: **640 assertions PASS**, including updated checks
  that gameplay/buttons and bold title share the same base font family.
- Final Windows PCK layout/role fixture: **602 assertions PASS**, five languages,
  three aspect ratios, 100/125/150% scale and actual panel routes. Tests assert
  the translated title retains the bold resource after each locale change.
- Full menu section translations: **215 assertions PASS**, including the new
  font license. Shared localization keys and their four translations updated
  together so the credits do not fall back to English.
- Native atmosphere/motion: **99 assertions PASS**, including frozen title sheen
  uniform with menu motion disabled and retained moon/cloud behavior.
- Final packaged Bulgarian menu inspected. Native moving-menu capture completed
  **192 frames at fixed capture rate 24 fps**, eight seconds, fully decoded.
  Sampled frames 24/60 inspected for the moving highlight. Preview:
  `.tools/review/enchanted-title-preview.mp4` (1,047,502 bytes). The capture rate
  is not a phone/game performance benchmark. Final capture stderr empty.
- Windows/Android parity PASS for the shared imported El Messiri font data, OFL,
  exact title shader, 112 compiled game scripts, 162 character resources, seven
  catalogs/configuration files and retained platform media/effects.
- Android code53, `0.5.48-enchanted-title`, **424,440,331 bytes**. CRC, v2/v3
  signatures, existing certificate and 16 KB alignment PASS. SHA-256:
  `663ec03179f647976291f3f926152ded2d1ea975e50e9376c8beeecb1d3eb4e3`.
- Windows manifest hashes PASS. Final receipt:
  `.tools/enchanted-title-v0548-release-hashes.json`.

Logs: `.tools/review/enchanted-title-{rules,layout,sections,motion,windows-build,
android-build,parity,preview,preview-error}.log`. Images:
`.tools/review/enchanted-title-package/`, `.tools/review/enchanted-title-film/`.

## Local delivery and limits

`Play-Latest.cmd` selects `build/windows-v0548/LastLight.exe`. Signed Android:
`build/android-releases/LastLight-0.5.48.apk`. Low-space SDK signing retained the
same signing identity and restored the signed export preset. An unpublished local
candidate was rebuilt after correcting title-role preservation; the receipt above
describes the final bytes. No public upload authorized.

Fixtures used isolated storage, never an owner journey/account. No physical
Nothing Phone 3a measurement, human full campaign playthrough or native-speaker
proofreading is claimed. Arabic shaping and glyph coverage were checked visually
and through the engine, not presented as a linguistic translation review.
Previously recorded Android themed-icon badging warning remains.

Owner authorized deletion only of duplicate ZIPs forest-light, hostiles,
kings-road and mausoleum. Absolute paths were checked inside the workspace build
directory before native PowerShell removal; extracted versions and all APKs,
assets and saves remain. Receipt: `.tools/approved-cleanup-enchanted-title.json`.
