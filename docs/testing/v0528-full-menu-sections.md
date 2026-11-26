# Full menu section translation — v0.5.28, 2026-11-08

The owner's running window was inspected through native computer use. It was
**v0.5.26**, despite the latest launcher having been updated to v0.5.27. Changing
a launcher does not replace an already running process. Native selection of
Bulgarian reproduced the old English rank/boss caption; opening Settings showed
translated but poorly worded Bulgarian. No game journey was started or altered.

There was also a real remaining source defect: the large Credits string
contained a URL, so earlier catalog extraction omitted the complete literal.
Its nine paragraphs had no translations. The previous targeted journey check
did not exercise Credits. This is corrected, not attributed only to the old build.

## Changes

- Explicit authored translations of all nine Credits paragraphs in Bulgarian,
  Russian, French and Arabic. Author names, source links and license identifiers
  retained. Noto fonts added to the displayed font attribution.
- Manually edited the full Settings labels/help, including master/effects/music
  volume, assistance, camera inversion, rebinding and save/back wording.
- Legal-license view has a translated heading/explanation and all five original
  font license texts. A small verbatim binding option prevents translations from
  modifying the legal originals; normal dialogue remains localized by default.
- Latest/default build launcher routes updated after validation. Historical named
  preview builds are preserved.

## Executed verification

- `tests/menu_sections_translation.gd`: red reproduction **85 assertions, 16
  failures**, all four Credits narrative checks failing in each extra locale.
  Evidence `.tools/menu-sections-red.log`.
- Expanded same section test: **211 assertions PASS**, including every Credits
  paragraph, attribution retention, all five legal notices verbatim, settings,
  progress, accounts and saved library. The final test includes every authored
  enemy Resource profile, catching historical `Grave Hound` names missed by
  earlier GDScript-only catalog extraction. Evidence `.tools/menu-sections-final.log`.
- Journey/localization regression: **103 assertions PASS**, including the new
  catalog. Evidence `.tools/menu-journey-regression.log`.
- Native `tests/capture_menu_sections.gd`: **100 captures**, 20 per language.
  Actual menu button signals open the relevant routes. Main menu, Credits,
  progress, Settings, five account forms, saved library, More actions and Journal
  captured; long sections include top/middle/bottom scroll positions.
  All routes PASS. Evidence `.tools/menu-sections-native.log` and
  `.tools/review/sections-*.png`. Bulgarian Credits top and Settings bottom
  reviewed visually. These use validated in-memory fixtures, not owner saves.

The last full campaign baseline is v0.5.26's 627 passing assertions. No new
campaign playthrough, performance measurement, real-phone test or live-account
verification is claimed. SMTP setup remains pending. Original license texts,
author/product names and physical key names intentionally retain their form.

Export and actual executable review results are appended after completion.

Native review of the first v0.5.28 candidate used the actual executable and
owner's existing library. Credits and Progress were opened through their buttons
and scrolled to the bottom. Credits were translated; Progress revealed the
remaining `Grave Hound` resource-name gap. This was fixed before final delivery,
and both platforms rebuilt. No original save files were edited to translate it.

Account sessions are memory-only in the current account preview. Restarting the
old app signs out; account journeys remain on disk and require signing back in.
Do not mistake the guest library after restart for missing account journeys.

## Final exports and save preservation

- Windows `build/windows-v0528` and `build/Last-Light-windows-v0528.zip` rebuilt
  after the historical-enemy-name correction; archive CRC PASS.
- Isolated final PCK test: **39 assertions PASS**, including four languages,
  full Credits paragraphs, Settings and the historical Grave Hound label.
  Evidence `.tools/v0528-package.log`.
- Android `build/android-releases/LastLight-0.5.28.apk`: **412,331,514 bytes**,
  SHA256 `F381B08E70D738DB2CAC9637844C8F4C716C36B244186D00C5622EBD420D3C66`.
  Debug signature v2/v3 verified; archive CRC PASS. Version code 33.
- Platform parity: **99 compiled game scripts, 162 prepared character resources,
  4 locale/cloud files identical**, PASS. Evidence `.tools/v0528-parity.log`.
- **95 original save/backup files hashed before native review; zero changed**
  after restart and menu inspection. No journey was started during the review.
- `Play-Latest.cmd` and `Play-Build.cmd` now route to v0.5.28; historical preview
  exports are preserved. Final build opened with the owner's usual workspace
  userdata and persisted Bulgarian preference. No upload/publication performed.
