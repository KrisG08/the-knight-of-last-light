# Journey translation fix — v0.5.27, 2026-11-08

The reported Bulgarian picker bug was reproduced with the same OptionButton
localization adapter as the real journey selector. Before the fix:
`Пътуване 12 · Rank 1 · 0/5 bosses`. All four non-English locales failed that
assertion, even though the standalone longer summary had a translation.
Evidence: `.tools/journey-translation-red.log`.

Cause: picker captions and progress reports assemble several fragments. The
catalog had a translated suffix starting with a separator, but lacked matching
whole-picker and standalone rank/boss/state fragments. Splitting an unmatched
caption left those fragments untranslated. Whitespace normalization also applied
only to exact catalog keys, not dynamic templates.

Changes:
- Explicit whole-picker and reusable numeric/status/chapter translations.
- Dynamic templates normalize surrounding whitespace without dropping it.
- Catalog loading order is explicit; manually edited interface terminology
  takes precedence over generated gameplay entries.
- Bulgarian/Russian/Arabic world and character names are consistent throughout
  translated prose, journal and progress text. Source keys and save IDs unchanged.
- Corrected mixed-language help and gate prompts; Bulgarian bosses, character,
  objective and journal route wording manually polished.

Executed validation:
- `tests/journey_translation_regression.gd`: **102 assertions PASS**. Checks
  real OptionButton language changes, nested library captions, progressed save
  reports, journal/status text, number/ID preservation, English restoration,
  whitespace handling and unchanged serialized save data. Includes the existing
  localization/settings/catalog checks. Evidence `.tools/journey-translation-final.log`.
- Catalog shape and format-field validation: 830 gameplay keys and 196 manually
  edited interface keys, four nonempty translations each, PASS.
- Native `tests/capture_journey_translations.gd`: main menu, saved library and
  progress screens for all five languages, PASS. Fixtures are validated memory
  saves, not the player's data. Evidence `.tools/journey-native.log` and
  `.tools/review/journeys-*.png`. Bulgarian menu/progress reviewed visually.
- The full campaign suite was not repeated for a presentation-only change.
  Its last complete baseline is 627 assertions PASS on v0.5.26. No combat,
  persistence schema, account credentials or world progression changes.

This is targeted technical/readability verification, not professional literary
proofreading of every dialogue in all languages. Original author names, brand
names, physical key names and legal license text may intentionally remain in
their original form. SMTP setup/real-device account acceptance remains pending.

Export results are appended after package verification.

## Package verification

- Windows build: `build/windows-v0527/LastLight.exe` + PCK and
  `build/Last-Light-windows-v0527.zip`, export exit 0, archive CRC PASS.
- Isolated exported-PCK test from its own package directory:
  `tests/localization_package_smoke.gd`, **23 assertions PASS**, including four
  locales in the actual picker and library route. No source asset fallback.
  Evidence `.tools/v0527-package.log`.
- Android: `build/android-releases/LastLight-0.5.27.apk`, **412,327,333 bytes**,
  SHA256 `BF86C09F1DBF3A6734BB11A2FAF4319859D7A6C3C33F85B9A2E201453641E637`.
  APK signatures v2/v3 verified, archive CRC PASS; manifest versionCode 32,
  versionName `0.5.27-localization-fix`, checked with `aapt dump xmltree`.
- Windows/Android parity: 99 compiled game scripts, 162 prepared character
  resources and all three locale/cloud data files identical, PASS.
  Evidence `.tools/v0527-parity.log`.
- `Play-Latest.cmd` updated after validation; Village launcher delegates to it.
  No upload/publication or physical Android-device test performed.
