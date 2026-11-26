# Touch icons, stable window mode and renewed introduction

## Changes

Four gameplay touch buttons now show centered larger symbols only, including the
flask/use context swap. The HUD pause control shows two pause strokes. Hold-attack
progress remains visible; upward dodge swipe still jumps. Touch rectangles and
gesture ownership did not change. Menu entries keep descriptive text.

Region transitions used to call apply_settings(), which always forced the stored
fullscreen boolean onto the native window. Maximizing via the Windows title bar
did not update that boolean, so E travel and boss entry restored 1280x720. The
runtime now remembers the last applied preference and changes display mode only
on startup or a changed fullscreen preference. Other settings and region refreshes
preserve native maximize/fullscreen state.

The introduction is newly rendered at 1920x1080 and 60 genuine animation frames
per second, with the current colored Meshy characters, articulated knight legs
and arms, actual citadel architecture, storm textures, smoother camera framing,
eight-sample offline antialiasing and updated subtitles. The four story beats and
original score remain. Separate 1080p desktop / 720p mobile encodes retain 60 fps.
The paused region and player are hidden while the opaque video is on screen and
restored on completion or Skip, avoiding drawing the background world during
software video decoding. This remains an in-engine authored film, with prototype
fall/rise choreography; it is not motion-captured acting.

## Evidence

- Native repro before fix: `.tools/window-transitions-before.log`: all four
  E-passage/boss-entry cases FAIL, maximize/fullscreen reset to windowed 1280x720.
- Native regression after fix: `.tools/window-transitions-final.log`: all four
  cases PASS, plus explicit fullscreen preference toggles still PASS.
- `.tools/icons-mobile-native.log`: real touch movement, swipe jump, canceled pause,
  pause tap and secondary healing action PASS. Reviewed actual gameplay capture
  `.tools/review/mobile-controls.png` for icon-only touch presentation.
- `.tools/v0523-tests-initial.log`: 587 assertions PASS before the two additional
  film hide/restore checks. Final suite runs after media replacement.
- Offline render master log `.tools/movie-render/render-v2-master.log` and actual
  1080p shot previews `.tools/review/film-v2-{4,12,19,26}.png`.

Real Android phone playback/performance still requires owner testing. Desktop
touch emulation does not establish phone frame pacing or thermal behavior.

Final validation: 589 assertions PASS (.tools/v0523-final-tests.log). Desktop film 1920x1080/60, 84,745,294 bytes; mobile 1280x720/60, 21,395,359 bytes; each 30.00 s. Native playback completed in 30.003 s desktop (process median/p95 8.336/17.371 ms), 29.995 s mobile-emulation (8.335/8.912 ms) on this laptop. Actual files decode successfully. Not phone FPS. Offline master shutdown emitted two ObjectDB/resource cleanup warnings after successful recording; runtime playback and packaged boot have no such errors. Platform script parity: 93 PASS; character resources: 162 PASS. Platform-film check from the package working directory PASS (source directory would incorrectly expose excluded source resources). Android signature and APK/Windows ZIP CRC PASS. APK v0.5.23: 404,464,176 bytes, SHA256 5850B706856A5F750C9CE565F6A40BDD2862F1A3F26DFE044638C2B0E6181B57. Latest launchers updated; existing saves retained. Android phone deployment remains untested.

Evidence preservation note: some film-v2 stills were reused during early 0.5.24 iteration. The actual 0.5.23 film is preserved in .tools/movie-render/opening-v2-preserved.ogv and opening-v2-mobile-preserved.ogv, its review copy is .tools/review/opening-v0523.mp4, and both 0.5.23 exported packages remain unchanged.
