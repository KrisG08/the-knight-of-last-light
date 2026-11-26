# Journey score, v0.5.58

Original authored synthesized loops: menu (32 s), exploration (35.556 s),
combat (22.857 s), boss (20 s), dawn (32 s). Stereo 44.1 kHz Ogg Vorbis q6,
about 1.1 MB total. Source generator: tools/render_score.py. No external music,
samples, downloaded recordings or runtime synthesis. The instrument palette is
synthetic pads, bells, plucked notes and low percussion, not a recorded orchestra.

One game-owned journey_music node survives region transitions. Its two decks
crossfade in linear amplitude over two seconds, stop decoding at zero level,
and route to the existing Music bus. Three-second combat release prevents
idle/aggro flicker. Boss encounters take precedence over ordinary combat;
death releases combat music. Menu, paused-journey ducking, encoded-film silence,
live wizard victory cue and completed-world dawn theme are explicit states.
Opening movies retain their baked soundtrack; the live victory scene declares
its dawn cue via score_theme metadata. Saves and gameplay rewards are untouched.

Validation uses Godot 4.7.2.stable.official.ed1daf0bf. The music fixture exercises
real game/region/encounter objects, stream loop flags, unchanged-state playback,
crossfades/old-deck stopping, Music mute/unmute with independent SFX, paused
ducking, film suppression, live-victory cue, defeat/completion and menu return.
Native checks additionally capture decoded samples on the actual Music bus for
all five themes and assert nonzero, unclipped output. This is an objective audio
check, not a claim of subjective listening approval or physical-phone testing.

FFmpeg independently decoded all delivery tracks; tools/check_score.py measured
peak 0.677–0.691, RMS 0.143–0.176 and wrap sample step 0.0031–0.0079. Files fully
decode without errors; clipping and discontinuity thresholds pass. These values
describe the assets, not sound-card loudness or device speaker quality.
Evidence: .tools/review/music-quality.json and music-checks-*.log.

The full campaign/presentation suite passed 643 assertions in the diagnostic
copy, which only adds per-assertion logging. Two earlier cold-start attempts were
interrupted while synchronously constructing fixtures; no assertion failure was
reported. The completed run is music-campaign-probe.log. It does not establish
a human clean-start playthrough, current FPS or phone thermal performance.

Final native PCK checks passed 29 assertions with touch controls. Android v0.5.58
uses versionCode 63; APK signature v2/v3 and 16 KiB page alignment passed with
the established signing certificate. APK: 432365997 bytes, SHA-256
5B9BCA214D093872E01B9F48AA5D9074738377AA6C0657FC227A41ECB6304000.
Final delivery verification is recorded in docs/STATUS.md. Public upload is not
part of this increment. Owner listening feedback and a real Nothing Phone 3a
speaker/headphone mix review remain pending; the score uses short repeating
themes rather than a full-length orchestral album.
