# Shared 0.5.2 cumulative preview — 2026-11-05

Windows output: build/windows-v052. Android: versionCode 7,
versionName 0.5.2-world-progress, org.lastlight.knight. Source config/version 0.5.2
drives the native title and frontend badge. Play-Latest.cmd and the owner's legacy
Play-Village-Detail.cmd now open this Windows package with existing workspace
APPDATA. Play-v05.cmd retains access to the prior v0.5 package.

Includes King's Road, woodland light/horizon, village trades/terrain/mausoleum,
burial chamber architecture/synthesized ambience, Blackwood architecture,
discovery-aware journal and friendly character/companion presentation. No save
schema or gameplay-rule changes; no cloud save synchronization.

Evidence: 526 assertions PASS (.tools/v052-tests.log). Native frontend capture
(.tools/v052-frontend-capture.log) verifies wide/tablet/150%-text aspect layouts
and reduced motion. Wide menu inspected with visible 0.5.2 badge. Friendly lineup
and fresh journal images inspected separately. Windows manifest hashes match,
headless packaged boot exits 0 (.tools/v052-export.log). Scripted/headless checks
do not establish an exported manual playthrough, device FPS or subjective audio mix.

Build logs: .tools/v052-windows-build.log and .tools/android/v052-export.log.
Earlier APK retained as build/android/LastLight-v051-before-world.apk. Windows
and Android player saves are private to their installation and excluded from APKs.

All 69 compiled game scripts are byte-identical across Windows PCK and Android
APK (.tools/v052-pack-parity.log). Android signing certificate matches v0.5.1;
APK CRC and new content/persistence exclusion pass. APK SHA256:
F15F2C5034983645FBE755832A9C571ADBCC0794CA9A560194A06EE1DB4425FA.
Named phone artifact: build/android-releases/LastLight-0.5.2.apk.
Gofile phone download: https://gofile.io/d/tEm97VBu. Returned remote size 373632358
and MD5 afa8737cbce07bd12bea99354d50f6e0 match the local APK.
