# 0.5.4 — sprint-only stamina

Owner requested free attacks/walking and stamina consumption only when sprinting.
Light/heavy attacks no longer spend stamina or reject an empty reserve. Dodge no
longer spends/requires stamina; grounded/active-dodge restrictions remain. Player
guard passes zero stamina cost into damage resolution; zero-cost guard cannot
break from an empty sprint reserve. Frontal reduced damage and rear-hit behavior
remain. Regeneration after the sprint delay is allowed during combat as well.
The only player stamina deduction is sprinting at 10 units/second, with existing
0.8-second recovery delay and 22 units/second regeneration.

Mobile partial joystick tilt walks; full tilt explicitly sprints and spends the
reserve. Standing with Sprint held has no movement direction and cannot spend it.
No save schema changes. This intentionally supersedes older numbered combat-cost
specifications under the owner's explicit instruction.

Godot 4.7.2 checks:

- Campaign/presentation suite: 538 assertions PASS, exit 0.
- Standalone real CharacterBody3D/floor/input test: walking moves without spending;
  sprint spends ten per second; reserve recovers; grounded dodge at zero reserve
  works without spending. All four PASS (`tests/check_sprint_reserve.gd`).
- Runtime attack checks verify light/heavy attacks at zero reserve. Commander and
  Warden tests still verify frontal damage reduction with no stamina loss.
- Pure damage regression verifies zero-cost guard works at zero reserve without
  guard break; positive-cost damage-rule capability remains independently tested.

Evidence: `.tools/sprint-only-final-tests.log`, `.tools/sprint-reserve-runtime.log`.
Physical-phone feel/performance acceptance is not covered by these checks.

Windows export completed, manifest matches, packaged headless boot exit 0.
Android versionCode 9 / versionName 0.5.4-sprint-reserve exported successfully;
APK CRC and signature verification PASS, same signing certificate as 0.5.3.
All 79 compiled game scripts are byte-identical across Windows and Android.
Named APK: build/android-releases/LastLight-0.5.4.apk, 373818929 bytes.
SHA256: 914A5A3F39E083343BAF4DDA6674E57D5A20DDE4DE75E38085BF1EB95FF97DC4.
MD5: 32A4899BE59C95E26E011DA5141FDAA3.
Play-Latest points to windows-v054 with the same player-save location. Prior
packages and currently running windows are retained; restart to use the new code.

Gofile upload was rejected by automatic approval review: the reviewer treated
owner authorization as specific to 0.5.3 and requires permission for the new
0.5.4 payload. No upload performed; local packages are complete and usable.

0.5.4 upload completed after explicit owner permission: https://gofile.io/d/3g11f8Wj .
Remote name LastLight-0.5.4.apk, size 373818929 and MD5
32a4899be59c95e26e011da5141fdaa3 match the local release. Prior upload block resolved.
