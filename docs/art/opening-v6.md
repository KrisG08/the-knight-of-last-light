# The Last Lantern — authored opening film

Owner direction, 2026-11-25: produce the video locally or through a plugin after
Runway required a subscription. Initially no connected video-generation tool or
plugin discovery tool was available. Later in the same turn the plugin directory
became available: it returned Runway, fal and other uninstalled video integrations.
Runway was suggested for the existing account; connection is not yet confirmed.
This did not stop independent local production. The authenticated Runway editor
showed 500 credits but only Upgrade for the prepared Gen-4 Turbo pilot. No
purchase or generation was performed. One project keyframe was uploaded.

## Production choice

This alternative is actual offline-rendered Godot 3D animation, not generative
AI video and not animated still keyframes. The eight staged ImageGen frames
remain an art-direction proposal; they are not the source of the moving film.
The film uses the current game geometry, v0.5.64 painted knight and Maldrek,
authored castle, village cell and forest/refuge. Existing geometry and asset
attribution remain applicable. It does not promise the fidelity of a film studio.

The 80-second story gives ten seconds to each beat: the citadel and four seals;
Maldrek binding the artifact; the devastated village and captive Oren; the
expedition; the visible casting gesture and upward release; the knight bracing,
reaching and falling with his companions; his articulated recovery; and the
first walk toward the ruined chapel. The additional protective origin of the
seals belongs to the deeper backstory. No progression gates or save facts change.

## Implementation

- `tools/render_prologue_v6.gd`: deterministic character poses, camera tracking,
  changing field of view, original physical wind flecks, animated artifact and
  violet spell. Old film helpers remain reusable; their historical timeline is
  retained separately when the new film is installed.
- `tools/render_prologue_stream.py`: transfers rendered JPEG frames at quality
  0.98 over the child process pipe into H.264 CRF 16. There is no localhost
  server, browser upload, large AVI dump, frame interpolation or duplicated-frame
  conversion from a lower frame rate. The initial TCP transport was abandoned
  before producing usable video; only the process-pipe transport is supported.
- `tools/finish_prologue_v6.py`: original synthesized wind, low harmony, metal
  resonance, measured steps and spell impact, then master/review/platform encodes.
  No downloaded recordings or commercial soundtrack are used.
- `tools/install_prologue_v6.py`: full 4,800-frame decode checks before replacing
  runtime film assets. Preserve the previous films, caption timeline and speech
  manifest under `art/cinematics/opening-v5-archive`. Add the forty verified staged
  speech files and translations while retaining existing NPC and ending speech.

Earlier combined audio/video encodes, interrupted-tail recovery, remux and
granule-rewriting candidates are retained only for diagnosis. They are not
accepted delivery files. Full native tests exposed pacing stalls, and decoder
checks exposed invalid video data in several candidates. A clean encode from
the complete master is required; matching identification headers alone does
not establish that independently encoded Theora segments can be concatenated.

The delivery route is `tools/encode_prologue_picture.py`: freshly encode the
complete master as video-only Theora, with an independent original 48 kHz Vorbis
score. The opening starts both, ducks the score below localized narration and
stops everything on Skip. Repeated Vorbis seeks were removed from this path.
The paused-world film temporarily increases the engine's physics catch-up budget
to avoid clipping the video clock after a long decode/upload frame; teardown
restores the previous value. Gameplay physics settings remain unchanged.
The installer rejects coefficient/keyframe decoder errors and checks all 2,400
delivery frames against the 80-second, 30 fps timeline.

Target delivery: 1920×1080 at 30 fps for Windows, 1280×720 at 30 fps for Android,
80 seconds each, sampled from the preserved 4,800-frame 60 fps master. These
describe media frames, not measured game/device frame rate. The lighter delivery
avoids treating a higher media frame rate as evidence of smoother native playback.
Native captions and separately selected offline narration support English,
Bulgarian, Russian, French and Arabic. Existing voice volume/disable, score
ducking and immediate Skip behavior remain available. Captions receive a taller
native bottom strip to accommodate the longer localized paragraphs.

## Reproduction and acceptance

Use the pinned Godot 4.7.2 executable and existing FFmpeg binary:

1. `python tools/render_prologue_stream.py` only when regenerating the master.
2. `python tools/encode_prologue_picture.py --30fps` creates both films and score.
3. `python tools/install_prologue_v6.py` validates and installs the film assets.
4. Import/parse with Godot; run `tests/voice_checks.gd` and the native
   `tests/prologue_playback.gd` with isolated APPDATA. The latter watches every
   beat, captions, decoded movement, real voice/score playback, natural camp
   handoff, and Skip in all five languages. Run desktop and `--touch` separately.
5. `python tools/export_prologue_release.py`, then verify the exact included
   films, independent score and voice files with `tools/verify_platform_packs.gd`.

Preview stills: `.tools/review/prologue-v6-authored/`. Production output and
render/encoder logs: `.tools/movie-render/prologue-v6/`. The installer writes
`art/cinematics/opening-v6/authored-production.json` only after actual decoding.

Limitations: character skinning and limb partitions remain those of the game;
there is no new facial performance, simulated cloth or captured motion. Wind
affects existing foliage shaders and authored leaves; it does not add a cloth
solver. Physical Nothing Phone 3a playback is not verified by laptop tests.
The offline production process is intentionally slow and is not runtime game
performance. Final build/check results are recorded in STATUS.md after execution.
