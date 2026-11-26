# 0.5.3 — resource HUD and mobile jump

Health/stamina now use named red/green meters with current/max values, quarter
divisions, low-resource labels and a short loss trail. They retain ProgressBar
semantics and the existing safe-area placement; resource rules are unchanged.
HUD inventory/rank is split into two deliberate lines.

The four primary mobile buttons remain. Tap/release Dodge evades; dragging upward
44 logical pixels from the same button emits Jump once. Maximum horizontal
deviation is 65 pixels. A recognized jump suppresses dodge on release. Cancelled
contacts do neither; focus loss flushes pending gestures and jump pulses.
The button permanently displays SWIPE UP: JUMP. Existing pause-menu Jump remains
an alternative. Dodge now fires on release to distinguish these gestures.

Checks on Godot 4.7.2:

- 537 assertions PASS (`.tools/hud-jump-tests.log`). Four new gesture regressions
  cover jump without dodge, no dodge on jump release, tap dodge and cancellation.
- Native `capture_mobile.gd` routes actual screen-touch/drag events through the
  viewport and observes the real physical actor rising more than 0.2m without
  dodge. Existing movement/pause/cancel/heal checks also PASS.
- Native frontend wide/tablet/large-text captures pass; wide gameplay screenshot
  inspected for labels, values, touch targets and jump hint.
- No physical Android device was attached. Gesture comfort, phone FPS and actual
  installation still need device review.

This cumulative release also includes Order/Peaks/forge/citadel/ritual presentation,
layered combat audio and skeletal leg locomotion described in neighboring notes.
Windows/Android package verification is recorded below when exports complete.

## Package evidence

Both exports completed. Windows `build/windows-v053/LastLight.exe` headless boot
exited 0; its file manifest matches. Android ZIP CRC PASS, package
org.lastlight.knight, versionCode 8 / versionName 0.5.3-hud-jump. Signature schemes
v2/v3 verify and certificate SHA256 remains
03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8.
All 79 compiled game scripts are byte-identical in Windows PCK and Android APK.

Named APK: `build/android-releases/LastLight-0.5.3.apk`, 373,823,025 bytes.
SHA256: 72396617041BBB77B5D8A18E631CD03E5E528D3700798ED4421D6D188B837424.
MD5: 3AA1E6F7850700545D7CE43EBF15D9BB.
`Play-Latest.cmd` now launches windows-v053 with the same .tools/userdata path.
Older stable/session packages are retained. Running older windows are untouched.

Gofile upload was rejected by automatic approval review: the reviewer required
explicit authorization for sharing this APK with that external destination.
No upload was performed. Ask the owner to authorize this exact APK/destination;
do not retry via another route. Local packages are ready for review/use.

Upload completed with explicit owner permission: https://gofile.io/d/h78Ov8TR .
Gofile reports LastLight-0.5.3.apk, 373823025 bytes, MD5
3aa1e6f7850700545d7ce43ebf15d9bb; name, size and MD5 match the local release.
The earlier automatic-review upload block is resolved.
