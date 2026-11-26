# Opening cinematic assets

## Current delivery — v0.5.62, 2026-11-21

The opening is now forty seconds, newly rendered from current camp/castle art
at 2560x1440 / 60 FPS, then downsampled to 1920x1080 / 60 FPS on both platforms.
The heavier QHD runtime encode failed native real-time playback and is preserved
only under .tools/movie-render. Runtime uses the tested Full HD encode instead.
Four extended shots share their caption/voice timeline in film_script.gd.
No English subtitles are baked into the new movie. Native text and 185 bundled
voice clips supply all five languages offline, with independent voice volume,
opt-out, score ducking and safe cancellation on Skip/close. Speech provenance:
assets/audio/voice/CREDITS.txt and docs/adr/0019-bundled-localized-speech.md.

Menu films now contain 720 original frames over twelve seconds at 60 FPS:
2560x1440 Windows and 1920x1080 Android, both Theora q10. Original layers render
at 4K and stream raw RGB to the encoder, avoiding a lossy JPEG intermediary.
Framing and native moon/cloud/title effects remain. Motion-off still freezes
the decoded film. Source-art resolution limits remain; no new detail is invented.

Production notes, failed takes and test boundaries:
docs/art/cinematics-and-voice-v062.md and docs/testing/v0562-cinematics-voice.md.
Historical sections below describe older deliveries, not the selected encodes.

## Expanded castle and violet curse — 0.5.41, 2026-11-08

Both delivery videos are newly rendered from the current enlarged citadel.
A 2.6-second moving exterior reveals the towers, forecourt and terraced ascent;
the film then approaches Maldrek on the real upper terrace for the violet spell.
The staff uses the current cut-crystal geometry, fitted to the casting hand.
The expedition, fall and rise shots retain their directed animation and timing.
Thirty seconds, desktop 1920x1080/60 and mobile 1280x720/60, q7/q6 Theora,
same original score and runtime-localized captions. No frame interpolation.

Source and review notes: docs/art/opening-expanded-castle.md. Master:
.tools/movie-render/opening-v4-master.avi. Render/encode logs use v4 names;
the v3 AVI below is historical and was removed with the owner's earlier approval.
Temporarily set only desktop viewport width/height to 1920/1080, run the same
Movie Maker command below with the v4 output path, and restore project.godot
in a finally block. Re-encode the first 30 seconds and use the existing score.wav.

## Directed acting and curse — 0.5.24

The same 1080p60 / 720p60 delivery now has animated wizard casting and a staff
attached to the casting arm. Original feathered filaments, motes and dark vapor
replace both torus rings. The forest strike follows branching ground veins.
Authored articulated fall and rise poses: tools/film_body_motion.gd; offline
spell rendering: tools/film_curse.gd. Camera push/pull and lens changes follow
charge, release, recoil, collapse and recovery. No online effect generation.

Latest master: .tools/movie-render/opening-v3-master.avi, same viewport setup and
60-fps capture/encoding commands below, replacing v2 paths with v3. Review copy:
.tools/review/opening-v0524.mp4. Both earlier v2 encodes and the 0.5.23 packages
are preserved. Development character surfaces, robe deformation and hand contact
remain approximate; this is authored animation rather than motion capture.

## Renewed opening — 0.5.23, 2026-11-07

New native 60-fps render from the current colored Meshy knights with articulated
arms/legs and Maldrek, actual citadel architecture, existing forest road and new
storm textures. Four animated shots, 30 seconds; new camera framing and subtitle
typeface. Offline rendering uses 8x MSAA and deterministic 1/60-second poses.
Runtime uses Theora/Vorbis: opening_film.ogv at 1920x1080 for desktop,
opening_mobile.ogv at 1280x720 for phones, both 60 fps. Platform exports exclude
the other platform's film. Mobile resolution reduces software-decoding work;
the paused gameplay world is hidden while the film plays and restored afterwards.

Reproduction: temporarily set the project viewport width/height to 1920/1080,
preserving the original project.godot, then run the pinned engine:

    Godot --path . --resolution 1920x1080 --script res://tools/render_opening_film.gd --fixed-fps 60 --write-movie .tools/movie-render/opening-v2-master.avi --quit-after 1802

Restore project.godot immediately afterwards. The 1802-frame capture includes two
tail frames for writer shutdown; encode only the first 30 seconds / 1800 frames.
Use the existing original score.wav, libtheora q7 desktop / q6 phone, yuv420p,
libvorbis q4; scale the phone encode with Lanczos. Encoder logs under
.tools/movie-render/encode-v2-*.log. Old film retained in earlier builds and in
.tools/movie-render/opening-v1-preserved.ogv. This is newly animated native video,
not frame interpolation or a still-image slideshow. Animation remains authored
procedural choreography, without motion capture or voice acting.

## Current opening: rendered 3D film (2026-11-05)

The owner rejected the single-image/text opening. The current game plays
opening_film.ogv: a real 30-second, 1280x720, 24-fps Theora/Vorbis movie with four
animated shots. It depicts the curse at the citadel, four marching knights, their
defeat and the surviving knight rising at the camp. Subtitles are burned into the
movie. There is original synthesized atmosphere/score and footsteps; no voiceover.

Source choreography: tools/render_opening_film.gd. Original audio generator:
tools/make_opening_audio.py. Offline render uses pinned Godot 4.7.2 Movie Maker:

    Godot --path . --script res://tools/render_opening_film.gd --fixed-fps 24 --write-movie .tools/movie-render/opening-final.avi --quit-after 722

Encode the first 30 seconds with FFmpeg libtheora quality 8 / libvorbis quality 4,
mapping video from the AVI and audio from .tools/movie-render/score.wav. Local
encoder came from the official SHA256-verified imageio-ffmpeg 0.6.0 Windows wheel
(FFmpeg 7.1); metadata/hash in .tools/video-encoder-source.json. Encoder binaries
are development tools and are not included in the game package. The film uses
the licensed 3D assets credited in docs/ASSET_CREDITS.txt. No generated-video service,
external footage or downloaded soundtrack was used. Motion remains procedurally
choreographed with the current prototype character models.

MP4 review copy: .tools/review/opening_film.mp4. Native game playback is handled by
game/ui/opening_cinematic.gd, including Skip and automatic completion. The older
painting below is retained as the visual target and no longer drives the opening.

kingdom_fall.png was generated with the built-in Imagegen tool on 2026-11-04,
then copied into this project. It is a hand-painted-style illustration, not an
engine screenshot. The earlier opener used it for pan/zoom and three subtitle
beats; it is now retained as the visual target. No voice recording is included.

Final prompt:

Use case: illustration-story. Asset type: widescreen hand-painted game opening
panorama for The Knight of Last Light. Create a cinematic 2D dark fantasy painting,
wide 16:9 composition. A solitary medieval knight in battered steel armor and a worn
cloak stands small in the lower foreground on an ancient woodland road with the
remains of an abandoned expedition, a broken banner and extinguished camp. A vast
deep forest blankets a ruined kingdom; far across the valley a majestic gothic royal
citadel rises with an unnatural pale teal eclipse above its towers, faint sickly
curse-light threading between roots toward the citadel. Painterly oil texture with
realistic medieval details, strong layered atmospheric depth, monumental scale,
mournful and mysterious, restrained silver moonlight, deep pine greens, charcoal,
subtle muted amber dying lantern. Forest path leads the eye from knight toward the
ruined kingdom. Frame important elements clear of the bottom quarter so game
subtitles may overlay there. One coherent landscape, no panels, no typography,
no letters, no UI, no watermark, no copied film or game characters. This depicts
an evil wizard's curse and a survivor's journey without showing the wizard or
revealing the ending.

Menu video v0.5.49: Windows QHD and Android Full HD, 30 fps. See docs/art/menu-wind-hq.md for source limits and rendering provenance.

Opening v0.5.65: an authored 80-second 3D film replaces the four-beat opening.
Eight beats use the actual current castle, village, knight and Maldrek models.
Windows: 1920×1080 / 30 fps; Android: 1280×720 / 30 fps; independent score: 48 kHz.
Localized captions and 40 new offline speech clips remain native overlays/audio,
not baked into the image. This is rendered Godot animation, not AI video. Prior
film files are preserved under art/cinematics/opening-v5-archive, excluded from
exports. Source render and production evidence: docs/art/opening-v6.md.
