# The Last Lantern — opening v6 production pack

Status: the AI storyboard remains a separate preproduction proposal. An authored
Godot 3D alternative has now been rendered and integrated into v0.5.65 source.
The canonical master contains 4,800 rendered frames at 60 fps. Delivery films use
2,400 frames at 30 fps over the same 80 seconds, with an independent musical score.
Forty localized narration clips and eight caption beats were installed.
This is not generative-AI video. Native and package acceptance is recorded in
docs/STATUS.md. The former 40-second opening and voice manifest are preserved in
art/cinematics/opening-v5-archive. See authored-production.json for actual files.

2026-11-25 account check: Runway displays 500 credits, but Gen-4 Turbo still
requires Upgrade after uploading 05-casting.png and entering the 10-second
pilot prompt. Standard is offered at USD 15/month billed monthly. No purchase,
generation or credit consumption occurred. The one uploaded keyframe is not
a completed clip. The owner must decide whether to obtain a paid plan.

The owner's request is a deeper, more entertaining opening with genuine AI
motion and consistent current character/world identity. Target: eight ten-second
shots, 80 seconds total. See `Review.html` for a local keyframe/narration review,
`production.json` for the timeline and five-language story, `video-prompts/` for
per-shot motion/camera prompts, and `subtitles-draft/` for provisional SRT files.
The review page deliberately labels still keyframes separately from video.

## Story and continuity

The four seals once protected the kingdom. Maldrek captures the citadel and
binds them to the central artifact, drawing vitality to sustain his reign.
Withered crops, risen dead and prisoners show its human cost. The knight's
mentor leads the Order along the old forest road; Maldrek knowingly attacks
the expedition. A failed attempt to save another knight makes the loss personal.
The protagonist wakes, sees a remaining lantern, and must find the survivors.
The final shot points toward the actual new-journey refuge approach.

The protective origin of the seals is an authored backstory addition staged
here, not a change to existing progression rules. Maldrek remains deliberately
hostile; no misunderstood-hero twist, invented player immunity, new quest gate
or early named-mentor boss reveal. Current four-seal/artifact invariants remain.

## Artwork and prompt set

Eight keyframes were made with built-in OpenAI ImageGen on 2026-11-24. Inputs:
actual Godot renders from `tools/capture_prologue_references.gd`, the approved
v0.5.64 knight/Maldrek front paint, actual knight equipment renders, and earlier
selected frames from this pack for continuity. All generated frames were copied
into `keyframes/`. Original references and credited model geometry are preserved.
These are original generated frames, not third-party film footage or to3D models.
Existing project asset attributions remain in `docs/ASSET_CREDITS.txt`.

Shared final generation constraints: photorealistic wide 16:9 film frame, no UI,
text or letterbox bars; same actual architecture, character identity, equipment
and wardrobe; near-black indigo/violet low light with restrained amber lamps,
physically integrated illumination and readable detail; natural anatomy and
grounded weight, no costume redesign or extra limbs. Knight has a closed steel
helm, ivory sun tabard and brown belts, no cape and no back sun emblem. Maldrek
retains his aged pale face, silver hair/goatee, charcoal/plum robes, silver
embroidery/chains and forked dark staff with violet crystal.

Final per-frame prompt directions:

1. Citadel: elevate the actual terraced castle render with realistic masonry,
   roofs, pine mountains and fog; preserve cylindrical conical-roof towers,
   central stairs, pavilions and highest keep, without replacing the building.
2. Binding: same Maldrek deliberately reaches toward a brass-caged floating
   violet core; four organic threads converge; quiet controlling expression,
   same masonry/door/column architecture and realistic violet light on skin.
3. Village: exact current half-timbered plaza, well and crypt layout; dead crops
   on a cart, windblown leaves, distant captives beyond a barred side door.
4. March: exact sun-tabard knight walks with sword down and shield naturally
   carried, two distant navy-cloth Order knights behind, actual pine-road chapel.
5. Casting: same wizard on the actual keep terrace raises the same staff;
   narrow violet filament joins storm clouds, sleeves/hair move in wind.
6. Fall: knight braces on one knee with shield, sword visibly dropped on road,
   right hand reaches for fallen companion; violet gust and leaves, no gore,
   floating bodies, flat neon ring or duplicated equipment.
7. Survivor: same grounded knight pushes from wet earth on one knee, sword
   within reach, broken Order banner, distant warm lamp and actual ruined arch.
8. Lantern: over-shoulder first step into the actual refuge approach; plain
   rear tabard, retrieved sword, shield on left, warm iron-cage lamp, tent,
   barrels, stone path and broken rose-window arch; no sunrise/color redesign.

Generation receipt filenames in the chat's generated-images directory:

| Shot | Generated source PNG |
| --- | --- |
| 01 | exec-69a3d33e-3271-47e0-9af0-c8368e61fbe7.png |
| 02 | exec-281caf16-2a3d-4627-89d6-b01231b26a68.png |
| 03 | exec-7cbdc0ad-e725-4cca-a92b-db4df4f56900.png |
| 04 | exec-651e2f45-911d-4668-9c05-606f7b30450d.png |
| 05 | exec-86b71648-6411-4add-845e-dfd53926e52c.png |
| 06 | exec-baa777a6-3cfa-4ee9-b5e1-c12a358b9ce3.png |
| 07 | exec-c2beac22-ad53-474d-a70d-72666c1b3b91.png |
| 08 | exec-3269d066-c45d-4d50-9c2a-3e667f9724ea.png |

## Narration and actual checks

The existing owner permission for Microsoft Edge synthesis covers this authored
game narration. Only the eight localized story passages were sent. Forty OGG
clips are staged under `narration/`, with original MP3 takes/receipts in
`voice-masters/`. Nothing is copied to the active runtime voice manifest yet.
Voices follow the current project mapping, including the existing Russian female
narrator. Synthetic voices, no voice cloning, facial lip sync or actor recording.
No claim of a native-speaker pronunciation review.

`python tools/prepare_prologue_video_pack.py` validates the contiguous 80-second
timeline, all 40 translations, eight high-resolution near-16:9 PNG headers,
narration text/speaker/language/hash/timing, and fully decodes all 40 OGG files
with the pinned FFmpeg. It exports motion prompts, draft subtitles, the review
page and `preflight.json`. All eight frames were inspected after generation.
Native guides were rendered in Godot 4.7.2 / Vulkan Mobile with current models.
Evidence: `.tools/review/prologue-v6-{native-guides,voice,preflight}.log`.

To regenerate narration only into this staging pack:

`python tools/build_voice_audio.py --prologue-plan art/cinematics/opening-v6/production.json`

## AI-service route — historical preproduction plan

Runway's official pricing was checked on 2026-11-24: Free includes a one-time
125-credit grant, not an unlimited video allowance. Source:
https://runway.com/pricing . The later authenticated account check on 2026-11-25
showed 500 credits, but the prepared Gen-4 Turbo image-to-video pilot required
Upgrade. Standard was offered at USD 15/month billed monthly. No generation,
credit consumption, subscription or payment occurred; one keyframe was uploaded.

If the owner later obtains paid service access: produce one real motion pilot
using the supplied frame; review identity, anatomy and
temporal motion; then produce the remaining shots within authorized credit
limits. A still-image camera pan does not satisfy this request.

Only once all clips are accepted: assemble with original score/sound, retain
source FPS honestly, encode practical desktop/mobile runtime files and verify
native decode/pacing. Merge the new eight captions/translations/40 voice clips
with the runtime, generalize shot selection, preserve Skip/voice cancellation,
check language changes and camp handoff, export both platforms and verify parity.
These are the outstanding steps for the generative-AI alternative, not proof
that it was produced. The owner subsequently requested local video production;
see docs/art/opening-v6.md and STATUS.md for the authored Godot film's actual
render, integration and verification results. No physical-phone or complete
campaign verification is established by this art-direction pack.
