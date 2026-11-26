# Opening revision v7 — motion, contact and score

Owner feedback on v0.5.65, 2026-11-26: detached wizard arms, an empty-looking
prison, floating/interpenetrating fallen knights, uniform pacing, and music.
This revision keeps the same story, current painted models and five offline
narration languages. It does not change progression, combat, accounts or saves.

## Reproduction and diagnosis

`tools/check_prologue_motion.gd --preview` exercises the former v6 choreography.
The actual baseline returned 40 failures from 64 checks: torso/shoulder anchor
drift; Oren rotating away from the cell; terrain penetration as deep as 0.95 m;
and intersecting fallen-character bounds. Sources are retained for comparison.

The prisoner wrapper contains its model at a world-offset position. Rotating
that wrapper around the region origin moved Oren outside the cell. The v7
shot rotates the contained model around its own origin and explicitly retains
his cell position. Camera framing shows his face before the gate closes.

Partitioned character surfaces previously moved with independent transforms.
`film_stitched_skin.gd` places the original mesh surfaces in shared rest space
and applies consistent skeletal weights across their cut boundaries. UVs,
paint, material masks, provenance and source geometry remain unchanged. Wizard
arms follow the chest and bent elbows; the staff follows the hand while keeping
an upright shaft. Spell emission is recomputed from the final staff transform.
The adapter is offline-only; gameplay character construction is unchanged.

`film_grounded_motion.gd` stages a stagger, bent knees, accelerating angular
fall, impact and settle. Four authored landing lanes stay spatially separate.
Contact is fitted using actual deformed mesh samples and the authored terrain
height, rather than rotating a body around its feet without support correction.
Final roll variations match each lane's slope. A corresponding recovery pose
uses the same intact skin. Sparse support samples are validated against a denser
independent mesh probe. This is authored animation, not simulated ragdoll physics.

Weapons are released as separate props and come to rest using their fitted
surface plane and vertex support, rather than standing upright or vanishing.
The hero reacts to the first impacts before falling; cameras cut from the group
to his collapse and then settle near the aftermath.

## Timing and music

Eight scene durations: 10, 10, 9.6, 9.2, 9, 11.2, 10.5 and 10.5 seconds (80 s).
The camera has motivated internal cuts in the cell and fall sequences instead
of equal, uniformly eased holds. Existing narration fits each revised beat.

`compose_dark_fantasy_score.py` writes an original cinematic cue with tension
swells, a pre-release pause, spell impact, staggered armor/ground accents and
a restrained survivor/lantern return. It synthesizes all instruments; it uses
no third-party recordings, commercial melodies or sampled human voices.

Four gameplay loops use a slower dark-fantasy phonk interpretation: minor-mode
bell/FM motifs, saturated sub/bass harmonics, swung hats, half-time snare and
restrained atmospheric layers. Exploration 62 BPM, combat 70, bosses 76, dawn 58.
The existing menu music is preserved byte-for-byte. Cinematic music remains
separate from gameplay loops. Existing volume, voice ducking, crossfades and
music-state selection remain authoritative. Genre/fidelity are creative choices
for owner review, not a claim of a recorded orchestral or commercial production.

## Production and acceptance

1. `python tools/prepare_prologue_v7.py` prepares the revised production plan.
2. Run `tools/check_prologue_v7_motion.gd --preview` through pinned Godot; review
   native `render_prologue_v7.gd --preview` images and contact poses.
3. `python tools/compose_dark_fantasy_score.py`; `python tools/verify_new_score.py`.
4. `python tools/render_prologue_v7_stream.py`: 2,400 actual 1080p frames at 30 fps,
   streamed to H.264 without a large raw frame dump. The complete-frame marker
   and exact frame count are mandatory; a partial render cannot be promoted.
5. `python tools/finish_prologue_v7.py`; review the narrated MP4, then
   `python tools/install_prologue_v7.py`. Full delivery decoding must have 2,400
   frames, correct dimensions/duration and no coefficient/keyframe errors.
6. Import; run voice/music checks and complete native opening checks for desktop
   and touch. Export both platforms, verify included assets and signing identity.

One native preview reached its final capture but stalled during Vulkan teardown
and hit the runner timeout. It is not reported as a clean command pass. The frame
streamer separately records normal engine shutdown and bounds cleanup only after
all frames and the encoder have completed. This is not a runtime film workaround.
Physical Nothing Phone 3a testing and remaining native decode/pacing limits stay
explicit in STATUS.md; source/mesh checks cannot certify perceived motion quality.

## Additional owner image feedback during production

The owner supplied two frames and explicitly requested both less stretched caster
sleeves and a smoother purple curse. The first complete 2,400-frame master is
therefore a retained pre-revision source, not the final delivery. The final skin
adds gravity-oriented cuff-following fabric binds, uses the existing front paint
to preserve hand deformation, and limits excessive lateral shoulder abduction.
It remains an authored drape approximation rather than simulated cloth.

`film_curse_v7.gd` replaces the converging spoke fan with finely sampled curved
flows and low-opacity rolling haze. Ground haze follows terrain and fades near
the camera; a small gathering core disappears on release rather than becoming a
large bubble. Explicit effect clocks make seeking and offline patches deterministic.

Only frames [300,600) and [1164,1770) contain the changed caster/effects. Run
`python tools/render_prologue_v7_stream.py --patch` for all 906 replacement frames,
then `python tools/apply_prologue_v7_patch.py`. The compositor decodes the retained
base and patch, replaces the exact intervals and verifies a new 2,400-frame H.264
master before platform encoding. It does not concatenate independently encoded
Theora headers/packets. The base master and both render receipts remain available.

Final encoded-frame review also exposed hard particle/terrain intersections.
The ground haze now reconstructs scene depth and fades at opaque geometry;
near-camera fading and a continuous soft mask avoid hard billboard cuts. Only
the fall interval [1434,1770) requires this final 336-frame replacement:
`render_prologue_v7_stream.py --ground-only`, followed by
`apply_prologue_v7_patch.py --ground-only`. The compositor uses the original
base plus the violet and ground patches, avoiding an extra compression generation
on unchanged shots. All source clips and render receipts are retained.
