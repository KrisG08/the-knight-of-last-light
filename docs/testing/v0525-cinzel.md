# Shared title typography — 0.5.25

Owner requested the title typeface for buttons and text visible during play.
The shared title/body/button face now resolves to assets/fonts/ui_cinzel.tres:
Cinzel with bundled Source Sans fallback for symbols or unsupported glyphs.
Existing licensed font files remain intact. No new fonts were downloaded.

All authored Label3D construction sites explicitly use the shared font: region
landmarks, NPC labels, companion and enemy/boss names, and legacy training signs.
HUD resource captions inherit the shared button face. Menu, settings, dialogue,
objectives, notices, journey picker and prompts inherit the shared UI theme.
Mobile gameplay controls remain icon-only.

Film captions are drawn in the same font over the existing bottom black strip,
following stream time, shot fades and fitted movie size. The earlier baked
captions are covered. Skip is now at top right to keep the caption area clear.
The underlying 1080p60/720p60 video assets are unchanged; no re-encoding loss or
extra video decoding workload. The same Font resource supports future UI edits.

Actual native captures: .tools/cinzel-mobile-final.log and
.tools/cinzel-desktop-final.log cover wide phone, tablet, 150% text, menu, settings,
gameplay, pause and secondary actions. Reviewed menu, gameplay and large-text
images under .tools/review/mobile-*.png. Native caption capture:
.tools/cinzel-captions.log and .tools/review/cinzel-film-{4,12,19,26}.png.
Initial constant-resource setter compile error was corrected by defining fallback
fonts in an immutable resource; failed draft captures were discarded/replaced.

Visual phone checks use desktop touch emulation. A real Android phone still
needs owner verification, particularly small text on the physical display.

Caption layout follow-up: an initial per-frame font/geometry update draft failed the 40-second natural-completion guard. Moved sizing to the fitted overlay's resized signal and only replace caption text at shot changes. The exact playback guard then PASS: complete=true, stream position 29.986, elapsed 29.979 s, process median/p95 8.334/9.287 ms in desktop touch emulation (.tools/cinzel-film-playback-fixed.log). This is not a real-phone frame-rate measurement. Four seek/caption captures were refreshed after the fix (.tools/cinzel-captions-final.log). Windows and Android drafts were rebuilt after the correction before changing the latest launcher.

Final delivery: source regression 589 assertions PASS (.tools/v0525-regression-final.log). Native exported desktop video completes in 29.992 s with live Cinzel captions; process median/p95 8.387/16.821 ms while the Android build also ran (.tools/v0525-packaged-film.log). Packaged boot PASS, Windows/Android 93 compiled scripts and 162 character resources identical, correct platform film bytes/exclusion PASS. Android signature and both package CRC checks PASS. APK build/android-releases/LastLight-0.5.25.apk, 409,076,490 bytes; SHA256 436C1E1F38C7ABB5FDF2DF974D440382B380B826838190A83E1E07D8C85C6784. Latest launchers point at windows-v0525. Existing saves/builds preserved. New-version menu captures refreshed in .tools/cinzel-v0525-capture.log. No 0.5.25 external upload or real phone test performed.
