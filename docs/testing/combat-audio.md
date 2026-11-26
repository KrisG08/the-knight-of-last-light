# Layered weapon and footfall audio — 2026-11-05

Post-0.5.2 source increment. Four individual 0.32-second footfalls are derived from
Kenney's CC0 walking.ogg in the official Starter-Kit-FPS repository, pinned to
185fd2326d74a5cf858cffc616f87cf9696f9cc0. Five downloaded source sound files match
the official Git blob hashes. Only walking is wired; land/jump sources are retained
for provenance/future review. Direct pack ZIP requests returned 403; no bypass was
attempted. Official public GitHub source used instead. No upstream code executed.

tools/make_combat_audio.py uses the existing local imageio-FFmpeg binary to decode,
trim, fade and normalize the source. Generates twelve original noise/transient/
inharmonic weapon variants (swing/hit/block/windup). Existing heal/death/rest/dodge
tones remain. Tiny playback pitch variation affects sound only, never combat clocks.

Footfalls play through an independent spatial child emitter so footsteps cannot
truncate an active sword/telegraph. Death stops residual footfalls. Both layers use
the actor's SFX bus and inherit scene pause/lifetime; no background synthesis loops.

529 assertions PASS (.tools/combat-audio-tests.log), including actual simultaneous
weapon/footstep playback, step variation and death cleanup. Import log:
.tools/combat-audio-import.log. No subjective listening or final combat-mix quality
acceptance claimed. Source/license/credits in assets/vendor/kenney_fps_audio/;
LICENSE.txt included by both export presets and third-party notices generator.
Initial optional soundfile install failed certificate validation; existing pinned
FFmpeg was used without weakening TLS or introducing a new dependency.
