# Opening movie replacement — 2026-11-05

Owner explicitly rejected the single painting with changing text. Replaced its
runtime with a VideoStreamPlayer playing a real prerecorded 3D film. Four shots:
wizard/citadel curse, marching expedition, magical defeat and survivor rising at
camp. Characters, camera and magic geometry animate; no painting is used by the
active opener. Current models and procedural animation remain prototype quality.

File: assets/cinematics/opening_film.ogv. 30.00 seconds, 720 frames, 1280x720,
24 fps Theora/yuv420p; stereo 24 kHz Vorbis. SHA256:
189D3F92F0663858AE3608CEA3683B6ADBC9DF3F153AAB47CAD560C95CC00CA9.
Source choreography and original audio generator are under tools/. Generation
and encoder provenance: assets/cinematics/README.md. Review MP4:
.tools/review/opening_film.mp4. External 3D asset credits accompany the package.

The opener inherits always-process mode while gameplay is paused. Music-bus volume
controls film audio. Skip film / Escape finishes once and stops decoding. Normal
movie completion uses the same camp handoff. Existing save loads bypass the film.
Missing film shows a concrete error and Continue to camp; no static image fallback.

## Verification

- Test.ps1: clean import, **457 assertions PASS** (.tools/movie-tests.log). Updated
  actual new-game branch checks require a Theora stream and single Skip control;
  pause, skip, checkpoint placement and load bypass remain covered.
- Offline Godot Movie Maker produced 722 frames at 24 fps; encoded first 30 seconds.
  Final render completed normally, exit 0. Four shot frames inspected; moved the
  wizard altar into view and cleared foreground rock occlusion for the formation.
- FFmpeg decoded the full final movie without errors. Audio measured peak -3.43 dBFS,
  RMS -21.02 dBFS; this is a signal check, not a human sound-mix acceptance.
- Native Mobile/Vulkan source run: tests/verify_opening_movie.gd passed, exit 0,
  no engine errors. Checked decoded frame changes, elapsed video time, actual end
  signal and memory-only camp handoff. Screenshots under .tools/review/movie_playback_*.
- Build-Windows.ps1 -OutputDirectory build/windows-film succeeded without engine
  errors. Export log includes the actual OGV and new player script. Folder manifest
  hashes match. PCK SHA256:
  4E1B6A13E4E6D36B749DF2427FB827E6AC6D9C05927D31A8E89C9EF854290EC6.

Separate Play-Film.cmd and Windows package preserve earlier forest/art builds and
existing save data. No new campaign/save schema or gameplay balance changes. Native
export playback verification is recorded in .tools/movie-export-check/.
No new full-game FPS or full campaign acceptance claim follows from these checks.

The external-script exported playback probe timed out after 80 seconds with no
completion marker and an empty error log. It is inconclusive, not a successful
export playback test. Direct Computer Use launch reached the normal menu and
selected empty Journey 2; owner redirected work to village changes before starting
that journey. No existing slot was overwritten by those UI actions. The full native
source playback result above remains valid; ordinary exported movie handoff still
needs its own direct UI acceptance.
