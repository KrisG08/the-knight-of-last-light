# Cinematic and localized speech work — 2026-11-21

Local v0.5.62 development release. No external publication is authorized here.

## New opening

`film_script.gd` is the shared source for four caption lines and a 40-second
timeline: castle/casting 11 s, expedition 10 s, curse impact 9 s, survivor 10 s.
`render_opening_film.gd` uses the current authored camp/castle geometry, violet
night treatment, rim light, eased approach/casting camera moves, skeletal march,
staggered falls, recovery and subtle breathing. All English caption pixels are
removed from the film: native UI owns localized text and speech cues.

The complete master has 2402 frames at 60 FPS and 2560x1440; only its first 2400
frames are used. Exact fixed-frame timing, not interpolated video frames. The
source render completed in 4:59. A preliminary direct launch initialized Movie
Maker at 1280x720 before the window override; that interrupted take is excluded.
`render_opening_film.ps1` preserves/restores project.godot around initialization
at the real QHD viewport and keeps the original project bytes on disk.

Runtime delivery: Full HD/60 on both platforms, downsampled from the QHD master.
The 125 Mbps QHD encode failed real-time native playback twice (only about eight
seconds decoded in 50/63 seconds). Closing two old QA sessions did not resolve
that failure. The 43 Mbps Full HD encode completed its forty seconds in 40.10
seconds in the desktop mobile-layout check. It therefore replaces the desktop
QHD runtime encode too; the QHD encode/master remain outside runtime resources.
This is a measured delivery tradeoff, not a claim that encoded FPS equals device
frame rate. Physical-phone playback remains unmeasured. Source geometry, material
detail and authored animation remain the current game assets; higher output
resolution is not a replacement for production character animation. Film score
is the original synthesized project score, re-timed to the new cuts. Source
generator: `tools/make_opening_audio.py`; master `score-v5.wav`.

The menu wind loop is re-rendered with 720 original supersampled frames
over 12 seconds, at 60 FPS. Framing, title, moon/cloud overlay and existing art
remain. Final delivery uses raw RGB streaming from 4K scene captures, bypassing
the JPEG intermediary that visibly softened a discarded take. First-frame SSIM
against the raw target is 0.991843, matching the old 30 FPS encode's first-frame
SSIM. Endpoint RMS is 0.0032153. These narrow comparisons do not measure every
frame or prove device FPS. Native loop checks cover repeat, reduced-motion start,
pause/resume and display sizing. The earlier native JPEG master is not selected.
Original source-art resolution limits documented in menu-wind-hq.md still apply.

Wizard defeat is a live 16-second scene. Its two localized caption/voice cues have
10 and 6 seconds. Existing victory persistence, collision-free magic, camera
restoration, explicit artifact confirmation and safe skipping remain authoritative.

## Speech pipeline

37 authored speech units currently yield 185 target clips. Extracted from NPC
dialogue, inscriptions, opening/victory captions and the ending. Speaker-specific
keys let the same companion response have different voices for Lyra and Cael.
Five languages match the existing UI catalogs. A missing ending paragraph was
translated in assets/localization/voice.json. New voice volume and toggle labels
also have all four non-English translations.

Development dependencies are installed locally in .tools/voice-build/python,
not in the game. System trust certificates are used without disabling TLS.
The initial automatic review rejection was followed by explicit owner permission
for Microsoft Edge synthesis. The sample succeeded and all 185 clips were
produced. Russian DmitryNeural returned NoAudioReceived on repeated identical
requests; SvetlanaNeural passed with the same Russian text and is the Russian
narrative reader for every speaker. No wrong-language substitute. Clip tests and
platform parity must pass before delivery; voice quality is synthetic narration,
not a professional actor performance.

See ADR 0019 for lifetime/cancellation, scope, external-service and privacy
boundaries. No microphone, voice cloning, account information or runtime text
transmission is involved. Synthetic voices are not professional actor recordings
or facial lip synchronization.

Older films are preserved in .tools/movie-render and existing v0.5.61 exports.
No owner saves, older packages or source art have been deleted. No public upload.
