# Project status

## GitHub repository preparation — v0.5.66, 2026-11-26

Owner explicitly requested creating a repository in their GitHub account and
uploading the organized full project. New private repository:
https://github.com/KrisG08/the-knight-of-last-light . Existing repositories were
not reused or changed. The working game folder is now a Git repository with
`main` as its initial branch and `origin` pointing to that project.

Preserved runtime resource paths, all authored code, assets, source art/history,
unpacked model exchange packs, docs, backend schema and tools. Added current
README/development/layout guides, CHANGELOG, contribution/issue/PR templates,
Git LFS attributes and a repository-hygiene CI template. The original planning README is
archived; historical SETUP notes remain with a current-instructions banner.
Original work remains all rights reserved; third-party credits/licenses remain.

Excluded local editors/SDKs, caches, build outputs, signing identities, session
files, private chat attachments and player saves. Duplicate model-pack ZIPs are
excluded while their unpacked contents are included. No local files deleted.
The bundled Supabase key is publishable/client-only, not an administrative key.

Actual checks: candidate source/JSON/layout/credential-pattern checks PASS;
Godot 4.7.2 clean import and 646 general campaign/presentation assertions PASS
through the new portable `tools/project.py test` runner with isolated test data.
No game behavior or asset appearance was changed for repository organization.
`git diff --check --cached` reports pre-existing whitespace in historical game
sources and upstream font license text; those files were preserved rather than
rewritten for an import-only task. GitHub accepted all 844 LFS objects (1.4 GB)
but rejected the first Git ref push because the OAuth credential lacks
`workflow` scope. Preserve that local import commit on a separate local branch,
include CI at tools/ci/repository-checks.yml, and publish a clean initial main
without the restricted workflow path; no account permissions are expanded.
Remote publication/integrity evidence will
be recorded in docs/testing/github-import.md after the first accepted push.

## Cinematic motion / score revision — v0.5.66 accepted, 2026-11-26

Supersedes the previous v0.5.66 in-progress notes and older v0.5.65 delivery.
Continuous offline film skins keep caster shoulders and sleeves attached;
gravity-oriented cuff binds and restrained shoulder movement avoid stretched
bat-wing cloth. The occupied cell now shows Oren at the gate close. Four separate
fall lanes, bounded stumble/contact/settle, slope-specific body support and
ground-fitted dropped equipment replace floating/intersecting collapse poses.
Purple casting uses curved flow, restrained haze and depth-softened intersections
instead of straight polygon spokes and ground webs. Motivated camera cuts and
varied beat lengths retain an 80-second film. Final 2,400-frame master includes
the 906-frame sleeve/curse revision and 336-frame soft-particle refinement.

Installed fresh video-only 1080p30 desktop / 720p30 mobile Theora films, separate
original event-scored cinematic music, and four original slowed dark-fantasy
phonk loops (62/70/76/58 BPM). Menu music is unchanged. Existing five-language
narration remains offline. No commercial samples, new voice transmissions,
paid generation, file deletion or gameplay rig/control/save changes.

Actual evidence:
- Old motion baseline: 40 failed / 64 checks; final revision: 101 checks PASS.
- Native preview frames and final encoded curse frame visually inspected.
  An earlier preview captured its frames but timed out at Vulkan shutdown;
  production renders completed normally and have frame-count receipts.
- Full decoding: 2,400 frames per platform, 80 seconds; correct size/rate,
  no coefficient/keyframe errors. Audio decode/peak/RMS/loop-seam checks PASS.
- Import/parse PASS; 569 voice assertions and 29 native music assertions PASS.
- Full native Vulkan playback: 72 assertions PASS for each platform path,
  including moving beats, BG captions/voice, score, camp handoff, five-locale
  Skip and restoration of the physics catch-up budget. Desktop elapsed 80.023s,
  median/p95 16.668/19.967ms; mobile-video path elapsed 80.004s,
  median/p95 16.669/19.566ms. These are laptop measurements, not phone FPS.
- Windows/Android exports, APK signature and 16KB alignment PASS.
- org.lastlight.knight versionName 0.5.66 / versionCode 71; signer matches
  v0.5.65 for an in-place update. One aapt2 themed-icon resource warning remains;
  signature/alignment and package identity checks succeeded.
- Platform parity PASS: current film variants, independent score, five music
  tracks, 225 voice clips, 128 compiled scripts, 172 character resources,
  13 locale/config files, current shaders/font/menu assets.

Packages: build/windows-v0566 and build/android-releases/LastLight-0.5.66.apk
(504,855,965 bytes). Play-Latest.cmd now selects v0.5.66.
Isolated packaged Windows headless startup PASS; no visual certification.

Owner-authorized public Android delivery: https://gofile.io/d/21Lq0hzF
Remote filename/size/MD5 match. APK SHA-256: 03e95a0aa72adb015379119de28f9835784b5eaef73054eec51347a460a4e833
Public browser page verified: one public LastLight-0.5.66.apk item, 505 MB.

Limits: Nothing Phone 3a physical installation/thermals/sustained pacing remain
untested. This is an authored 30fps film, not AI-generated video or cloth/ragdoll
simulation. No stutter-free phone promise or complete campaign certification.
Engine 4.7.2.stable.official.ed1daf0bf; no Git repository. Evidence:
docs/art/opening-v7.md, art/cinematics/opening-v7/authored-production.json,
.tools/review/prologue-v6-v066-*.log and release-0.5.66-*.log.
Next: owner review on the physical phone and targeted fixes from that feedback.

## Expanded opening delivered — v0.5.65, 2026-11-26

Implemented an authored 80-second, eight-scene Godot 3D prologue with current
painted characters and castle, visible casting/recovery, moving cameras, deeper
backstory, original music, native captions and 40 additional offline narration
clips in English, Bulgarian, Russian, French and Arabic. This is not AI video.
The complete master preserves 4,800 rendered 1080p frames at 60 fps. Delivery
uses fresh 1080p/30 Windows and 720p/30 Android video-only encodes plus independent
48 kHz music; no recovered/concatenated or granule-rewritten candidate is shipped.
The paused film temporarily expands the physics catch-up budget and restores it
on completion/Skip so decode spikes do not clip its clock. Old media and saves
remain preserved. Engine: Godot 4.7.2.stable.official.ed1daf0bf; no Git repository.

Actual checks:
- Full decode: 2,400 delivery frames per platform; no coefficient/keyframe errors.
- Import/parse PASS; 569 localized-voice assertions PASS.
- Native Vulkan full-game playback: 72 assertions PASS on each platform path;
  all eight beats visibly move, Bulgarian captions/voice and score play, camp
  handoff succeeds, and all five locales support immediate Skip/timing restore.
  Elapsed: mobile path 81.655 s; desktop 81.699 s.
- Windows release export, isolated headless packaged boot (exit 0, no log errors),
  Android export, signature verification and 16 KB alignment checks PASS.
- Android package org.lastlight.knight, versionName 0.5.65 / versionCode 70;
  signer matches v0.5.64, allowing an in-place update.
- Platform package comparison PASS: current films, independent score, 225 voice
  clips, 128 compiled scripts, 172 character resources and 13 locale/config files.

Packages: build/windows-v0565 and build/android-releases/LastLight-0.5.65.apk
(501,349,789 bytes). Play-Latest.cmd selects v0.5.65. Under explicit owner upload
authorization, Gofile confirmed filename/size and matching MD5; public download:
https://gofile.io/d/GBwAF5E9 . APK SHA-256:
34da1d62814b1848a034f3b525f7346623e7ff08ae1b63bd95adbc26e14c4e16
The public Gofile browser page was verified to show one public item named
LastLight-0.5.65.apk, 501 MB. A synthetic storage-server HEAD URL returned the
site HTML shell and is not offered as a direct APK link; use the verified page.

Known limits: physical Nothing Phone 3a installation, thermals and pacing remain
untested. Native laptop observations still include long decode/upload frames
(p95 approximately 262 ms); encoded 30 fps does not promise 30 displayed fps.
Do not claim stutter-free playback or new facial/cloth simulation. Next task:
owner phone review, then profile and reduce remaining presentation stalls if
they occur on the actual target device. Evidence: .tools/review/prologue-v6-*
logs, art/cinematics/opening-v6/authored-production.json and release delivery JSON.

## Authored expanded prologue — v0.5.65 source, acceptance in progress, 2026-11-26

Rendered the complete 80-second eight-beat 3D film with current castle, village,
knight and Maldrek models: 4,800 source frames at 1920×1080 / 60 fps. The staged
AI keyframes are not the moving footage. Original synthesized score and a
Bulgarian narrated review are complete under .tools/movie-render/prologue-v6/.
Installed eight caption beats, their four translated catalogs and forty staged
offline narration clips; all existing NPC/ending speech remains. Caption space
is taller. Godot 4.7.2 import/parse and 569 localized-voice assertions passed.
The former films and speech manifest are preserved in art/cinematics/opening-v5-archive.

Do not treat this source increment as an accepted new build yet. Initial 64-bit
FFmpeg encodes passed full AV decoding, but native playback showed serious pacing
delays. A short seek-based hotspot probe passed, while complete native files did
not. Remuxing with a verified 32-bit FFmpeg and 20 ms Ogg pages made the complete
mobile probe finish in 79.983 s, but subsequent desktop cadence validation found
71 held frames and rejected that candidate. Remuxing changes packet handling;
it is not sufficient to call the result frame-exact. The experimental outputs
and red logs remain for diagnosis; no quality or performance acceptance is claimed.

Fresh Win32 combined encodes also failed coefficient/cadence validation. They
and granule-rewrite experiments are retained only as diagnostic outputs. Fresh
video-only 1080p/720p 60 fps encodes now pass full decoding without the corrupt
data, with an independent original 48 kHz score. Voice checks pass 569 assertions.
Native full playback passed all eight movement/voice/caption/camp checks but
failed wall-clock pacing. Removing score seeks and changing renderer did not
resolve pacing. Increasing the paused-film physics catch-up budget from 8 to 32
made the same 14-second native hotspot finish in 13.860 seconds (previously
22.192 seconds). The previous budget is restored when the film exits. This
fix addresses clock clipping after long decode/upload frames; it is not proof
of a high displayed frame rate. Lighter 30 fps delivery encodes are being made
from the preserved 60 fps master before final native acceptance and packaging.

Play-Latest.cmd still selects accepted v0.5.64. Source is 0.5.65 / Android
versionCode 70; no accepted v0.5.65 package or public upload exists yet.
The owner explicitly authorized publishing the final APK in Gofile on 2026-11-26.
Physical Nothing Phone 3a remains untested.

Plugin discovery became available later in this turn and found an uninstalled
Runway integration, which was suggested. Connection is not confirmed. No AI
video was generated, credits spent or subscription purchased. A local authored
3D film is the current deliverable route authorized by the owner.

## Runway authenticated access check — 2026-11-25

The owner signed in. The authenticated Runway editor displays 500 credits.
Uploaded only opening-v6/keyframes/05-casting.png and entered a motion prompt
for the pilot: Gen-4 Turbo, 10 seconds, 16:9. The editor still offers Upgrade
instead of Generate; selecting it opens the subscription offer, not a job.
The plan comparison shows Standard at USD 15/month billed monthly. No plan
was purchased, no generation started and no credits consumed. The uploaded
image is a reference, not a generated video. The Runway tab is retained for
owner handoff; payment/plan selection remains the owner's decision.
Evidence: .tools/review/runway-plan-required-2026-11-25.jpg.
All eight video clips remain missing; runtime/game packages are unchanged.
This account-specific observation supersedes the generic Free-plan expectation
and pending-login notes below. Next: obtain authorized video-generation access,
then generate and visually assess the pilot before spending on remaining shots.

## Expanded AI prologue — preproduction, 2026-11-24

Prepared art/cinematics/opening-v6: an 80-second eight-shot narrative, all five
language drafts, eight visually inspected ImageGen keyframes, per-shot motion
prompts, SRT drafts and a local Review.html with language/scene/audio selection.
Nine actual world/character reference captures use current v0.5.64 models and
authored castle/village/refuge geometry in Godot 4.7.2 / Vulkan Mobile.
Forty Edge-synthesized narration clips completed under existing owner permission.
Preflight passed timeline, translation coverage, high-resolution PNG shape,
exact voice text/speaker/hash/timing and full FFmpeg decoding of all forty clips.

No actual AI video clip exists yet. Runway Free was verified on its official
pricing page as 125 one-time credits; account-specific access/cost is unverified.
The in-app guest page opened, but authentication returned a connection reset.
A separate Runway-only Chrome login is pending from the owner. No account was
created, credits consumed, paid service purchased or content uploaded to Runway.
The optional local HTML browser check could not reach the loopback preview;
page assets/data were validated, but interactive browser acceptance is pending.

Current game version, runtime film, active captions, voice manifest, journeys
and accounts remain unchanged at v0.5.64. Next: access the dedicated Runway
session, verify available free generation, produce/review a genuine motion
pilot, then obtain the remaining footage and integrate both platform encodes.
The still storyboard is not presented as an AI film. See the pack README for
provenance, story additions, exact pending integration work and limitations.

## Mesh-guided front character paint — v0.5.64, 2026-11-24

Added ten front RGBA references based on actual mesh guides and original 2D
concepts, improving coherent faces, helmet vents, heraldry, straps and material
detail. Correct frontal rest-space projection avoids diagonal UV smearing;
alpha preserves pale steel/cloth, paired coverage blends into the rear paint,
and native UV-coordinate fields reduce small uncovered outline patches. All
original source art, rear references and geometry remain preserved.

Godot 4.7.2 stable import/parse passed. Paint checks preserve all 50 original
surfaces (zero geometry/normal/UV deviation) and validate ten front/rear fits,
runtime front textures and UV fields. Ten hostile appearance runtime checks
passed. Native front/oblique/rear studio renders and actual campaign-lit knight
and Maldrek captures inspected. Evidence/limits: docs/testing/v0564-front-paint.md.
Oblique/deep-overlap alignment remains a projection limitation; no full campaign
or physical-phone FPS claim. Windows and Android v0.5.64 packages completed.
Play-Latest.cmd selects windows-v0564; the local Android release copy is
android-releases/LastLight-0.5.64.apk (663205401 bytes). APK v2/v3 signature and
16 KiB alignment checks passed. Package parity passed for 128 compiled scripts,
172 character resources and 185 voice clips; focused verification confirms all
twenty front/rear textures and ten UV fields. Windows release headless startup
completed with exit code zero. No Git commit or public upload; existing journeys
and accounts are not modified.

## Reference-faithful character paint — v0.5.63, 2026-11-24

Preserved the original 2D front colors and all original painted mesh resources
for knight, Oren, Lyra, Cael, goblin and five guardians. Added ten matching rear
reference images and rest-space shader projection. Backs now have rear hair,
straps, cloth and armor detail instead of duplicated front features. The earlier
replacement palette was rejected by the owner and is preserved only in the
ignored art trials directory. No successful to3D model is claimed.

Godot 4.7.2 stable: import/parse succeeded; character resource checks passed for
50 unchanged surfaces and ten rear fits, with zero geometry/normal/UV deviation
and unchanged pigment/mask channels. Ten hostile appearance runtime checks passed.
Native Vulkan Mobile front/back renders of all ten models and four campaign-lit
knight/Maldrek images were inspected. See docs/testing/v0563-reference-paint.md.
This is image projection on existing meshes; oblique seams/alignment remain a
limitation. No full campaign playthrough or physical-phone FPS validation is
claimed. Windows and Android v0.5.63 exports completed; Play-Latest.cmd selects
windows-v0563 and the local APK is android-releases/LastLight-0.5.63.apk (code 68).
APK v2/v3 signature and 16 KiB alignment checks passed. Package parity passed
for 128 compiled scripts, 162 character resources, 185 voice clips and shared
catalogs/shaders; the focused check confirms all ten rear textures are packaged
and the shader/model definitions match current source. No public upload,
deletion, Git repository or commit.

## Local model collection — 2026-11-24

Created art_exports/Last-Light-Model-Pack-2026-11-24 and two verified ZIPs:
the complete art collection (516044246 bytes) and image-only references
(112905602 bytes). Includes 52 hash-verified selected PNG concepts, 47 individual
static GLBs, 11 complete static region geometry snapshots, native model/material
resources, vendor textures, presentation builders and attribution. The pack has
512 indexed files with SHA-256 values, plus its own file index. No account data,
credentials, saves or private attachments are copied. Nothing was uploaded.

Godot 4.7.2: individual exports passed engine readback; 58 GLBs passed independent
header/length, mesh/node counts, embedded images/buffers and buffer bounds checks.
Both ZIPs passed CRC verification. Native rendered previews of knight, soldier
and scout satchel were inspected. Direct GLTFDocument preview needs explicit
vertex-color activation for the colored Meshy geometry. A source knight custom
channel export error was repaired by stripping unused custom channels and
rechecked; its final GLB has all five mesh instances. Large world readback was
too slow for the collection workflow, so those eleven files have structural
validation only, not an interactive visual acceptance claim.

Portable GLBs are rest-pose geometry, without rigs, animation, gameplay, sky or
Godot-only effects. Individual albedo copies are limited to 1024 pixels; separate
normal/ORM maps are omitted. Whole-world GLBs use simple untextured materials.
Original art sources remain alongside. Canva compatibility is not verified;
the image-only archive is intended for tools accepting individual PNG inputs.
Playable game version/assets/builds remain unchanged at v0.5.62. Next: owner
tries the selected Canva tool's input requirements. No Git commit available.

## Cinematics and five-language narration — v0.5.62, 2026-11-21

Added 185 offline voice clips for 37 authored narrative units in all five UI
languages: NPC conversations, inscriptions, opening/victory captions and ending.
Independent volume/opt-out, score ducking, paragraph queue and owner-scoped
close/skip/locale cancellation. Explicit owner approval preceded Microsoft Edge
synthesis. Account data and saves are excluded; no runtime synthesis/microphone.
Russian uses a female narrative reader after the male service voice failed.
Speech is synthetic narration without facial lip sync.

New forty-second opening rendered from current camp/castle geometry with moving
cameras, casting, march, fall/recovery and localized native captions. QHD source
master retained; selected runtime is supersampled Full HD/60 on both platforms
after the heavier QHD encode failed real-time playback. Menu wind films now have
720 original frames / 12 s / 60 FPS, QHD Windows and Full HD Android, using raw
RGB to preserve detail. Wizard victory lasts 16 s and speaks both captions;
explicit artifact interaction and existing rewards/progress remain intact.

Godot 4.7.2. Campaign/runtime/settings 645 PASS; final native Windows PCK speech/
five-language settings checks 461 PASS; final voiced wizard scene 22 PASS; native
menu 14 PASS; final full opening/camp handoff PASS. Platform parity 128 scripts,
185 voice clips, 162 character resources, 12 locale/cloud files and shared media/
shaders/catalogs PASS. Windows manifest and Android code67 signature/16 KiB
alignment PASS. Play-Latest selects windows-v0562. APK local only:
build/android-releases/LastLight-0.5.62.apk (642320890 bytes).

Video callback evidence and rejected takes are recorded honestly in
docs/testing/v0562-cinematics-voice.md. No zero-stutter or real-phone FPS claim;
Nothing Phone 3a playback and pronunciation/listening acceptance remain owner
checks. Older media/packages/saves retained, no public upload. Next: owner audio
balance review and physical-phone video/thermal checks. No Git commit available.

## Violet Midnight world concepts and authored scenery — v0.5.61, 2026-11-21

Created eleven original environment concepts for the six exterior regions and
five boss locations. Owner feedback selected a darker, more violet direction.
Implemented a shared cursed-night palette, dim lavender moonlight, coherent fog,
amber lamps, complex Gothic arch/rose/buttress/tower details and cloth camp tents
with ropes and pegs. Existing restored dawn, saves, combat, elevation and gates
remain. New tent placement was corrected after a spawn navigation failure;
rib transform axes, chamber placement and unsupported high windows were corrected
through native visual review. No external art purchase or manual-asset removal.

Godot 4.7.2. Campaign/runtime suite 644 PASS; final native exported PCK sweep of
all eleven regions 58 PASS; Windows manifest and Android code66 signature/16 KiB
alignment PASS. Platform parity 125 scripts, 162 character resources, 11 locale/
cloud files and current shared shaders/media/catalogs PASS. Play-Latest selects
windows-v0561. Android: build/android-releases/LastLight-0.5.61.apk, local only.

Gallery: art_exports/world-concepts-v061/index.html, with eleven generated target
images and separate raw engine captures. The 3D pass follows palette/architecture;
it does not yet match target illustrations' photorealistic detail. Existing tree
cards, repeated surfaces, lighting and moon/cloud integration remain visible
limits. Main menu/opening films were not re-rendered. No real Nothing Phone 3a
performance test or manual full campaign claimed. Next: owner art review in normal
gameplay, then vegetation/material refinement and physical-phone performance.
Evidence: docs/testing/v0561-world-direction.md. No commit (workspace has no Git).

## Lossless model preparation and measured loading — v0.5.60, 2026-11-21

Moved existing native model partitioning out of first-use gameplay into three
compressed catalogs (crusader knight, strong knight, red fox). Original source
converters remain for offline regeneration; geometry, materials, textures,
controllers, collision, rendering presets, combat and saved progress are intact.
Passage feedback now renders before synchronous region construction, with input
already disabled. Region builds remain synchronous; loading is not eliminated.

Godot 4.7.2. Full campaign/presentation 644 PASS; final native Windows PCK
camera/touch/Controls regression 50 PASS; 153 independent raw-source / prepared
mesh and material checks PASS. Transition feedback failed before and passed
headless/native after the yield. Windows manifest and Android code65 signature /
16 KiB alignment PASS. Platform parity: 123 scripts, 162 character resources,
11 locale/cloud configs and all three new catalogs plus existing media/shaders.
Android APK is local: build/android-releases/LastLight-0.5.60.apk (433824901 bytes).
SHA-256 EBF652C584255C84A9DE35FD806F1558FA51B59BF3C2CD44C7878288B41D3EE1.

Sequential actual EXE workload on i5-12450H / RTX 3050 Ti, unchanged High,
Balanced power, 60 FPS/VSync and actual 2880x1620 render texture: worst callback
interval including transitions 4929.539 -> 2116.983 ms; warm repeat 2289.916 ms.
P50 remains about 16.664 ms. P95/p99 are slightly higher, so no higher sustained
FPS claim. Peak process working set 1364.66 -> 1110.54 MiB in the paired run.
Engine video estimate about 1.17 -> 1.16 GB. Private bytes are reported separately.
These are scripted assisted refuge/village/Gravedigger workloads, not a human
campaign, all-region performance certification or real-phone measurement.

Known limit: the new package's total process wall envelope was longer (168.600 s,
warm 133.869 s versus old 93.715 s) despite its shorter timed route. The extra
startup/untimed setup/exit cost is not diagnosed or claimed fixed. Other desktop
activity/cache state was not controlled. Initial external-script release test
was invalid and excluded. Full evidence: docs/testing/v0560-performance.md.
Next: investigate the untimed launch envelope, remaining scene build costs and
physical Nothing Phone 3a performance. No public upload performed.
Final exported hero/hostile fixture inspected after catalog loading; colors and
geometry remain present. Play-Latest now selects windows-v0560.

## Camera framing and target focus — v0.5.59, 2026-11-20

Target acquisition now favors screen-centre intent with a proximity bias;
cycling follows left-to-right screen order. Existing 15 m acquisition, 22 m
retention and 0.6 s obstruction grace remain. Yaw/elevation tracking uses
exponential easing and downward framing so the opponent stays above the helm.
A passive violet torso marker hides when obstructed, paused, transitioning,
dead or off-screen. Native spring-camera collision remains authoritative.

Touch can focus/toggle a visible enemy with a body tap, including releasing a
retained target beyond acquisition range. A deliberate right-side look drag
returns camera control. Cancelled/long touches do not target; pause flushes
pending gestures before dispatching release events, preventing reentrant input
cleanup. Four action buttons and attack auto-focus remain. Updated tutorial and
Controls instructions are translated into all five languages. Saves unchanged.

Godot 4.7.2. Final campaign/presentation suite: 644 PASS. Final Windows PCK
targeting/UI checks: 50 PASS in desktop mode and 50 PASS with touch controls,
including actual Journal > Controls navigation in five languages at 150% text,
body/head taps, elevation physics, obstacle release, spring-arm retraction /
recovery and helmet-clear framing. Native fixture/HUD and Bulgarian/Arabic
Controls captures inspected. Windows manifest and Android code64 signature /
16 KiB alignment PASS. Evidence: docs/testing/v0559-targeting.md.
Final platform parity PASS: 123 game scripts, 162 character resources, 11 locale /
cloud configs, score assets and shared shaders. Play-Latest selects windows-v0559;
Android release is build/android-releases/LastLight-0.5.59.apk.

Owner camera-feel feedback and physical-phone acceptance remain pending. These
checks do not certify a human campaign playthrough, controller hardware or FPS.
Next: profile the latest exported campaign and investigate measured load/frame
time bottlenecks. Packages are local only; no public upload authorized/performed.

## Adaptive journey score — v0.5.58, 2026-11-20

Added five original stereo synthesized themes: menu, exploration, ordinary
combat, guardian battles and dawn. A persistent two-deck Music bus owner
crossfades, delays combat release to avoid aggro flicker, ducks paused journeys,
and stops faded decoders. Encoded opening films retain their own soundtrack;
live wizard victory choreography and completed-world exploration use dawn.
The existing Music slider now controls a real score and no longer says reserved
in English; all four translated captions remain connected. Gameplay/save rules
are unchanged. Score assets total about 1.1 MB; no external samples or melodies.

Godot 4.7.2. Full campaign/presentation suite: 643 PASS. Initial music checks:
23 headless / 28 native PASS; final Windows PCK with touch controls: 29 PASS,
including live victory cue and native captured decoded samples for all themes.
Independent FFmpeg decode / peak / RMS / loop seam checks PASS. Final Windows
manifest PASS. Evidence and limitations: docs/testing/v0558-journey-music.md.
These checks do not certify subjective listening quality, phone loudspeakers
or current FPS. Next: owner listening feedback and physical-phone mix review.
Final Windows / Android parity PASS: 121 compiled game scripts, 162 character
resources, 10 locale/cloud configs and all five streaming score assets identical.
Android code63 signature v2/v3 / alignment PASS with the existing certificate.
Both packages are local; Play-Latest selects windows-v0558. No public upload.

## Contextual journey onboarding — v0.5.57, 2026-11-20

New journeys receive passive contextual lessons for movement/look, sprint, jump,
light/heavy attacks, guard/dodge, target lock, healing, lanterns and NPC interaction.
Completion follows actual movement/input/combat events and persists per journey
in an optional validated tutorial_completed_ids array. Existing journeys opt in
through Journal > Controls > Replay tutorial hints; Skip is also available there.
Keyboard hints use current bindings. Touch hints identify the existing four
icons and their hold/swipe/stick gestures. Menus/death/transitions suppress the
panel. Lessons never gate campaign progression. Tutorial saves are coalesced.

Godot 4.7.2. Campaign/presentation 643 PASS; initial native tutorial checks 19 PASS
on desktop and touch, including progress persistence, skip/replay, legacy behavior,
rebinding, pause and translated bounds. Final package checks add real Controls
navigation and JSON disk round-trip. Native captures inspected. Physical phone
acceptance remains pending. Evidence: .tools/review/tutorial-*.log.
Next: owner onboarding review, then music/atmosphere work.
Final Windows PCK touch checks passed 23 assertions with 150% text and five
languages, actual Controls skip navigation, disk round-trip and opted-in legacy
tracking. Windows manifest and Android code62 signature/alignment verified.
Both local packages and latest launcher use v0.5.57. No public upload.

## Equipment and earned relics — v0.5.56, 2026-11-20

Added Tab equipment and a journal entry with current sword/shield, combat stats,
two relic slots, unlock requirements and before/after comparisons. Four passive
relics derive ownership from existing guardian victories and the completed
family-token quest. Older journeys gain their earned choices automatically.
Selections are durable in equipped_relic_ids, validated for ownership, uniqueness
and the two-slot cap. Ordinary save/cloud snapshot structure remains compatible.
Runtime buttons prevent changes during combat. Bonuses reach real sword damage,
defense and consumed-flask healing, and compose with blacksmith upgrades.
No health/flask charges are generated by changing equipment.

Normalized numeric slot keys in the memory persistence adapter after a JSON
round-trip fixture exposed float/int key mismatch. Disk relic round-trip passed.
Godot 4.7.2. Campaign/presentation 642 PASS; dedicated native relic checks 26 PASS
before adding large-text bounds assertions. Five-language views inspected.
Physical-phone and live authenticated cloud acceptance remain pending.
Final Windows PCK touch-mode relic checks passed 33 assertions, including five
languages at 150% text, real effects, autosave, disk round-trip and rejection
of equipment changes during combat. Windows manifest and Android code61
signature/alignment passed. Both local builds and latest launcher use v0.5.56.
Next: owner equipment review, then onboarding/tutorial work.

## Three-hit sword chain and heavy reactions — v0.5.55, 2026-11-20

Added three light stages: opening sweep, reverse sweep, and a slower 1.35x
finisher. A 0.65 s follow-up window resets after the finisher or an idle gap.
Late recovery input can queue one follow-up; menus clear buffered input while
preserving the active swing. Dodge resets the chain. Heavy remains 1.8x, reaches
2.5 m and staggers ordinary enemies for 0.8 s instead of 0.4 s. Boss phase rules
remain authoritative. Shared immutable attack definitions drive sweep and sword
pose timings. Torso/arms brace for attacks and sword recovery eases to neutral.
Ordinary enemies visibly recoil. All attacks remain free of stamina cost.

Godot 4.7.2. Campaign/presentation 641 PASS. Dedicated real-hit combo checks
18 PASS headless/native, covering chained damage, one hit per swing, finisher
reset, idle gap, empty stamina, heavy stagger and input cancellation. Native
windup/follow-through/impact captures inspected in .tools/review/combo/.
Owner combat-feel and physical-phone acceptance remain pending.
Final Windows PCK passed 20 real-hit/pose checks, including pause mid-chain and
expiry of early input. Android code60 signature/alignment and Windows manifest
verified. Both local packages and latest launcher use v0.5.55.
Next: review this combat increment before equipment/relic work.

## Visual exploration map — v0.5.54, 2026-11-17

Journal now opens World map: a north-up local plan derived from authored
navigation polygons, physical floor footprints in guardian rooms, and authored
obstacles. It shows the current position, checkpoint activation, selectable
landmarks, the next regional landmark and a navigation route where available.
A six-region overview reveals names as regions are discovered. Hidden pickups
are excluded. Lantern travel reuses the existing proximity/combat/discovery
validation. Map browsing pauses gameplay and leaves campaign state untouched.
Added five-language map UI text.

Godot 4.7.2. Campaign/presentation 641 PASS. Native map tests 32 PASS over five
languages and all main regions/guardian rooms; captures inspected. This is a
schematic gameplay plan, not illustrated terrain or a live HUD minimap. Room
floors are projected in 2D, including their authored elevations. Physical phone
performance remains unverified. Evidence: .tools/review/world-map-complete.log,
map-campaign.log and world-map/*.png. Next: owner review of navigation map.
Final Windows PCK map checks also passed 32 assertions in touch mode. Windows
manifest, Android code59 signature/alignment and cross-platform parity passed
(115 game scripts, 162 character resources, eight catalogs/configs). Local
Windows/Android packages and latest launcher use v0.5.54. No public upload.

## Journal bounds regression — v0.5.53, 2026-11-17

Fixed the non-NPC dialog restoration introduced in v0.5.52: assigning negative
position after center anchors moved the journal outside its parent. Non-NPC
panels now use explicit top-left coordinates centered within safe bounds, a
viewport-bounded size and wrapping width. Resizes update visible dialogs.
Native J-input regression reproduced the failure and then passed 80 assertions
across five languages, two window sizes and 100/150% text, including transition
from NPC conversation. Captures inspected. Godot 4.7.2.
Final Windows PCK touch-mode J regression also passed 80 assertions. Windows
manifest and Android code58 signing/alignment verified. Both local packages
are v0.5.53; latest launcher updated. Existing running game needs a restart.
Evidence: .tools/review/journal-before.log and journal-after.log.

## NPC conversations and captive cells — v0.5.52, 2026-11-17

Added bottom NPC conversations with isolated 3D portraits for Oren, Lyra and
Sir Cael above the physical left edge. Responses wrap, long content scrolls,
and non-NPC dialogs restore their own layout. Portraits render once on demand.
Rebuilt Oren's cell and the citadel prisoner enclosure with stone architecture,
ironwork, hinged doors, locks, chains, cots and warm lighting. Rescue flags open
doors and remove blocking collision. Moved Oren's cell north of the mill to
clear the approach; conversation remains possible through its own bars.

Godot 4.7.2. Campaign/presentation 640 PASS; final Windows PCK NPC checks 200 PASS,
covering five languages, two aspect ratios, larger text, portraits, choice routes
and rescue presentation. Native captures inspected. Windows manifest and Android
code57 signing/alignment verified. Both local packages use v0.5.52. Physical
Android acceptance remains pending. Next: owner review of NPC presentation.
Stop here before the next feature, as requested.
[Evidence](testing/v0552-npc-presentation.md).

## Phone high-quality graphics — v0.5.51, 2026-11-17

Android High now uses the Phone 3a native pixel budget (2.6 MP), 4x MSAA,
16x anisotropy, desktop High mesh detail and longer 48 m shadows. The default
target remains 60 FPS. Existing explicit high-refresh/resolution choices persist.
Godot 4.7.2. Regression checks caught the old quality limitations then passed
41 assertions headless and 41 through native touch settings. Signed/aligned
Android code56 package is local at build/android-releases/LastLight-0.5.51.apk.
The existing game manifest classification supports manual Nothing Game Mode
addition. Source: https://support.nothing.tech/hc/en-us/articles/32978553837457-How-do-I-enable-Game-Mode-on-my-Nothing-Phone

A five-second-per-region native laptop workload with the mobile profile averaged
52.9 FPS in Blackwood and 55.7 in Citadel. Blackwood p95 33.0 ms, worst 97.5 ms;
Citadel p95 25.1 ms, worst 30.0 ms. These measured runs do not establish sustained
Phone 3a performance. ADB was unavailable, so physical-device FPS and thermal
acceptance remain pending. Evidence: .tools/review/phone-quality-*.log/json.
Windows launcher remains on v0.5.50. Public upload of the new APK awaits owner
authorization. Next: install and measure on Phone 3a with Game Mode enabled.

## App icon — v0.5.50, 2026-11-17

Replaced the lantern app icon with an original silver helmet and violet visor.
Windows uses the SVG for its project and executable icon. Android includes
legacy, adaptive and themed launcher artwork. Godot 4.7.2 exported both packages.
The Windows executable icon and Android launcher artwork were extracted for
inspection. The Android adaptive XML references background, foreground and
monochrome layers. Signing and alignment passed. The existing unused Android
themed-icon resource warning remains; launcher rendering needs a device check.
The latest Windows launcher and local Android APK use v0.5.50.

## Higher-resolution menu films — v0.5.49, 2026-11-10

Re-rendered the original layered wind scene at 3840 × 2160, streamed directly
into QHD Windows and Full HD Android Theora quality-10 films, 30 fps / 12 seconds.
Each export selects its own encode; legacy 720p retained in source only. Loading
keeps matching fallback art until a real decoded frame is ready, including cold
reduced-motion startup. Existing framing, animated moon/clouds and title remain.

Godot 4.7.2.stable.official.ed1daf0bf. Both complete files decode cleanly; native
source desktop/mobile loop checks 14 PASS each; final Windows PCK loop 14 PASS,
layout/routes 602 PASS; native wind/title/moon/cloud checks 99 PASS. Native
full-screen-sized old/new captures inspected.
Windows/Android shared assets/scripts and current encodes match; isolated Windows
payload and Android CRC/platform film selection verified. Android code54 signature,
alignment and Windows manifest PASS. Local packages and latest launcher use v0.5.49.
Only four explicitly authorized duplicate ZIPs session, village-landscape,
village-life and village deleted; extracted builds/APKs/resources/saves retained.
Original landscape detail remains bounded by its source resolution. No physical
phone FPS or general gameplay performance claim. Next: owner review on both devices.
[Evidence and limitations](testing/v0549-hq-menu.md).

## Shared fantasy typeface and enchanted title — v0.5.48, 2026-11-10

Unified all five languages on the unmodified OFL El Messiri family instead of
different Latin/Cyrillic/Arabic families. Native font audit covers 177 used letters
and marks with none missing. Body/buttons use weight 500, title uses 700 with
restrained extra emboldening, depth and a slow silver-violet moving sheen.
Localization now preserves the explicit title font role. Reduced motion freezes
the effect; Arabic shaping stays native. Credits, notices and asset register updated.

Godot 4.7.2.stable.official.ed1daf0bf. Campaign/presentation 640 PASS; final PCK
layout/title roles 602 PASS; full menu translations 215 PASS; motion 99 PASS.
Native eight-second title preview rendered/decoded and sampled frames inspected.
Windows/Android shared font data/OFL/effect and script parity PASS; Android code53
signature/CRC/alignment and Windows manifest PASS. Packages local; latest launcher
selects v0.5.48. Only specifically authorized duplicate ZIPs forest-light, hostiles,
kings-road and mausoleum deleted; extracted builds/APKs/assets/saves retained.
No real-phone performance or human campaign completion claim. Next: owner review
of the unified typeface and title sheen.
[Evidence and font provenance](testing/v0548-enchanted-title.md).

## Caption-sized account and language — v0.5.47, 2026-11-10

Removed fixed utility-button widths and horizontal fill. Account and language
size independently to their actual caption, stone margins and selector arrow;
the language picker no longer reserves the longest dropdown item's width. The
bottom-left stack adapts to language/UI scale and keeps physical left alignment
under Arabic layout. Native touch height and prior movie framing remain.

Godot 4.7.2.stable.official.ed1daf0bf. Final Windows PCK layout/routes 557 PASS
over five languages, three aspect ratios and 100/125/150% scale. Bulgarian and
Arabic package views inspected. Windows/Android parity, Android code52 signature,
CRC/alignment and Windows manifest PASS. Both packages local; latest launcher
selects v0.5.47. Low-space signing needed no further archive deletion. No owner
saves opened and no real-phone performance claim. Next: owner button-size review.
[Evidence](testing/v0547-compact-utilities.md).

## Stacked utilities and castle framing — v0.5.46, 2026-11-10

Stacked account above language at bottom left. Reframed the existing wind movie
left with aspect-preserving overscan and a tagline-based helmet anchor, revealing
the main castle instead of hiding it behind navigation. Native gaze follows the
repositioned knight. Refreshes layout when entering/leaving pause as well.

Godot 4.7.2.stable.official.ed1daf0bf. Final PCK layout/composition 556 PASS,
menu atmosphere 98 PASS, final PCK decoder/loop 11 PASS. Desktop and wide-phone
Bulgarian package captures inspected. Windows/Android script/material parity,
Android code51 signature/CRC/alignment and Windows manifest PASS. Android used
unsigned staging plus direct SDK signing with the established signer to reduce
temporary copies; signed preset restored byte-for-byte. Packages local; latest
launcher selects v0.5.46. No real-phone performance claim. Only specifically
approved ZIPs v05/blackwood-art/burial-art/burial-sound removed; extracted builds,
all APK releases, assets and saves retained. Next: owner framing review.
[Evidence and low-space packaging notes](testing/v0546-menu-framing.md).

## Bottom-left utilities and stone seams — v0.5.45, 2026-11-10

Moved account/sign-in and language selection to the bottom left within safe
margins; expanded right-side journey navigation into the freed vertical space.
Replaced mirrored lightning-like marks with connected irregular fractures,
branching weathered paths, carved recesses and softer violet cores across the
shared stone style. Added missing mirrored OptionButton styling for Arabic.

Godot 4.7.2.stable.official.ed1daf0bf. Final Windows PCK layout/routes 331 PASS
across five languages, three aspect ratios and 100/125/150% scales; account and
settings routes exercised. Menu atmosphere/layout 98 PASS. Bulgarian/Arabic,
large text, account and settings captures reviewed. Windows/Android parity,
Android code50 signature/CRC/alignment and Windows manifest PASS. Latest launcher
selects v0.5.45; Android remains local. Only specifically approved duplicate ZIPs
v052–v056 deleted; extracted versions, all APKs, assets and saves retained.
Next: owner review of button appearance. No real-phone performance claim.
[Checks, initial signing failure and cleanup](testing/v0545-stone-menu.md).

## Foreground cloud banks — v0.5.44, 2026-11-10

Added a separate foreground cloud layer over the moon. Soft rolling banks extend
beyond the disc, cross the face and reveal it again. The clouds share the menu
clock and reduced-motion freeze; eye direction and existing atmospheric grading
remain. No gameplay or save changes. Godot 4.7.2.stable.official.ed1daf0bf.

Native menu/layout/motion 98 PASS, final Windows PCK desktop/wide captures
reviewed, Windows/Android current cloud/face shader and 112-script parity PASS.
Android code49 signature/CRC/16 KB alignment and Windows manifest PASS. Packages
remain local; launcher selects v0.5.44. No real-phone performance claim. Only
owner-approved duplicate ZIPs v057–v059 removed; extracted versions, APKs, assets
and saves retained. Next: owner review of the foreground cloud movement.
[Evidence and limits](testing/v0544-foreground-clouds.md).

## Atmospheric moon and knight-directed gaze — v0.5.43, 2026-11-10

Replaced the bright lunar treatment with cool directional shade, aerial haze,
soft silhouette and moving storm-texture cloud attenuation. Violet eyes now
look toward the knight's authored menu position across aspect ratios/languages,
with small natural movement. All motion still uses the pausable menu clock.

Godot 4.7.2.stable.official.ed1daf0bf. Native menu 96 PASS; final Windows PCK
decoder/loop 11 PASS. Final package closeups and desktop/wide menu views
captured and inspected. Windows/Android current shader and script parity PASS,
Android code48 signature/CRC/alignment and Windows manifest PASS. Packages
local; latest launcher selects v0.5.43. No real-phone or performance claim.
Only owner-authorized duplicate ZIPs v0510–v0512 were deleted; extracted
versions, APKs, assets and saves retained. Next: owner review of moon integration.
[Evidence and limits](testing/v0543-moon-atmosphere.md).

## Living menu moon — v0.5.42, 2026-11-10

Animated the existing main-menu crater face with moving/squinting eyes, a violet
gaze and a slowly opening stone-toothed mouth. The face shares the pausable menu
clock and respects reduced motion; title placement and all game/save rules stay
unchanged. No new external artwork. Godot 4.7.2.stable.official.ed1daf0bf.

Native menu layout/motion 81 PASS; actual video loop source and packaged PCK
11 PASS each. Closeups and desktop/wide menu captures reviewed. Windows and
Android v0.5.42/code47 packaged with identical current shader, 112 game scripts,
162 character resources and seven catalogs. Android signature, CRC and alignment
PASS; no real-phone performance claim. Latest launcher updated; Android remains
local. Owner authorized deletion of only ZIPs v0513–v0517; extracted versions and
all saves/APKs retained. Next: owner review of lunar expression and phone motion.
[Checks and delivery limits](testing/v0542-living-menu-moon.md).

## Expanded-castle opening — v0.5.41, 2026-11-09

Re-rendered the 30-second new-journey opening from the actual enlarged citadel.
A moving exterior establishes towers, keep and terraced ascent before a close
casting shot; Maldrek uses the current crystal staff with violet spell/light.
Expedition, collapse, survivor and localized caption timing remain intact.
Desktop 1080p60 and phone 720p60 encodes are packaged in their respective builds.

Godot 4.7.2.stable.official.ed1daf0bf. Both videos decode; native desktop/touch
new-journey playback and final Windows PCK automatic camp handoff PASS. Platform
parity verifies current film bytes, 112 scripts, 162 models and seven catalogs;
APK code46 signature/alignment/CRC and Windows manifest PASS. Launcher updated;
owner approved Android upload: https://gofile.io/d/1QmaRGax (name/size/MD5
verified). No real-phone smoothness guarantee. Offline Movie Maker
still reports its earlier shutdown resource diagnostic; final runtime playback
logs are clean. Next: owner review of the new film, then character rig polish.
[Evidence, review paths and limits](testing/v0541-expanded-castle-opening.md).

## Quest objects and character polish — v0.5.40, 2026-11-08

Replaced the actual Blackwood scout-satchel cube and village token box with
recognizable detailed props. Added carved memorial and seal cradles. Improved
villager/shade/survivor and passive troll/dwarf with existing detailed model
adaptations, isolated materials, fitted hostile weapon grips, beveled blades,
staff crystal and reduced metal glare. Companion blades no longer use boxes.
Quest IDs, pickup/recruitment rules, saves, combat pivots and passive movement
retain their existing authority. Static prop detail is merged and cached.

Godot 4.7.2.stable.official.ed1daf0bf. Campaign/presentation 640 PASS;
exported object checks 58 PASS; native wizard defeat 19 PASS. All eleven regions
inventoried and captured; character and quest close-ups reviewed. Windows and
Android match 112 scripts, 162 character resources, seven catalogs and retained
effects. v0.5.40 / Android code45; launcher updated. Owner subsequently approved
public Android upload: https://gofile.io/d/fnj9njQd (name/size/MD5 verified).
Scan texture/faceting, reused variants and full skeletal/finger animation remain
art limitations. No real-phone performance or full human campaign acceptance.
Next: owner review of this art pass, then dedicated character rig/hand fitting.
[Evidence and limits](testing/v0540-object-and-character-art.md).

## Animated violet map portals — v0.5.39, 2026-11-08

All 20 physical forward/return links across eleven campaign regions now have
layered pointed arches, regional roots/tomb/iron/Gothic trim, geometric runes,
moving mist/vortex, protruding 3D filaments and fading motes. Gates anchor after
elevation at existing interaction points. Four progression wards show closed
sigils/dim energy until unlocked; boss exit visuals observe actual barriers.
Existing collision, navigation, E/mobile context actions, saves and prerequisites
retain authority. Original geometry/shaders; existing credited materials; owner
reference used only as art direction. One nearby shadowless light per region,
range-limited secondary effects; no renderer switch/bloom or external textures.

Godot 4.7.2.stable.official.ed1daf0bf. Source portal checks 98 PASS; final PCK
100 PASS including timed boss-barrier visual changes. Full regression 640 PASS.
Native captures of all twenty portals plus motion/closed variants; final PCK
nine representative portals captured. Inspected forest, tomb/iron and Gothic
views. One-second portal ROI difference confirms motion (mean 40.93/255,
59.94% changed >12 levels). Corrected initial refuge setup omission and hashed
turbulence seams. Final logs have no script/shader errors. Windows/Android:
110 scripts, both portal shaders, 162 character resources, seven catalogs and
retained film/materials match. APK CRC/alignment/signature/version and Windows
manifest PASS. Preview startup/120-frame headless exit PASS. No human campaign
or real-phone performance acceptance claimed. [Evidence](testing/v0539-violet-waygates.md).

Latest → `build/windows-v0539`; Android code 44 →
`build/android-releases/LastLight-0.5.39.apk`. Direct memory-only review:
`Preview-Portals.cmd`. Local only; no public upload. No new deletions. New EXE
losslessly compressed/hash-verified; no duplicate Windows ZIP. No Git repo.
Next: owner visual feedback and Phone (3a) close-portal pacing/readability test.

## Native resolution and high-refresh settings — v0.5.38, 2026-11-08

2026-11-08; Godot 4.7.2.stable.official.ed1daf0bf. Added shared 30/60/90/120 FPS
ceilings, removed the Android-only min(60), retained Android frame pacing/VSync.
New persistent Profile default / Native screen resolution preference. Phone (3a)
native mode supports the full 2392x1080 buffer within 2.6 MP; desktop native
budget 8.2944 MP. Profile mode reduces mobile pixel work at 90/120 targets;
native favors detail. Settings show computed 3D dimensions and selected target,
translated in five languages. Existing choices/default 60/Profile retained.
No 160-FPS/2160p phone promise; physical panel supports up to 120 Hz.

Import/parse clean; 40 graphics checks PASS in headless touch, native desktop
and native touch. Actual controls exercise 90/120 engine ceilings, pixel policy,
persistence, five-language labels and untouched window/journey state. Inspected
Bulgarian desktop/touch settings captures. No physical-phone performance claim.
[Evidence](testing/v0538-native-high-refresh.md). Final Windows PCK: 40 graphics
checks PASS each native desktop/headless touch; packaged five-language settings
captured and Bulgarian view inspected. Windows/Android parity: 108 scripts,
162 character resources, seven catalogs and retained art/films/shaders. APK
CRC/alignment/v2-v3 signing, APK Analyzer code/name and Windows manifest PASS.
Latest now selects `build/windows-v0538`; Android code 43 is
`build/android-releases/LastLight-0.5.38.apk`. Local only, no public upload.
Owner approved and removed exactly three duplicate ZIPs v0526/v0527/v0528,
freeing 1,473,171,191 B. Extracted versions/APKs/saves retained. Selected old
PCKs/new EXE losslessly compressed/hash-verified. No Git. Next: physical Phone
(3a) sustained FPS/heat test, high-refresh display mode and preference review.

## Late-world landmarks and enlarged Eclipse Castle — v0.5.37, 2026-11-08

Eight areas from Blackwood to Maldrek receive new authored architecture: abbey,
memorial towers/cloister, ridge aqueduct/monastery, hall braces and a monumental
castle. Playable citadel expands 64 x 78 → 96 x 126 m, 2.42x area, with entrance
forecourt/lantern, grand gate, pavilions, high curtain towers, layered keep,
tiled roofs and mullioned windows. Ritual vault apex rises 15 → 26 m; battle
floor remains 26 x 26 m. Upper quest/boss/artifact coordinates and save IDs
retained. New gate/pavilion collision included in rebuilt navigation. Pavers
follow slopes and remain recessed beneath summit treads. Shared instanced
masonry; existing credited materials; no new downloaded packs or shadow lights.

Godot 4.7.2.stable.official.ed1daf0bf. Full regression 640 PASS; source and final
PCK navigation/collision 20 PASS; six-region height rays and actual knight's
ascent/descent PASS; native eight-area/upper-castle captures reviewed. Final PCK
wizard cinematic 19 PASS. Windows/Android parity: 108 scripts, 162 character
resources, seven catalogs and retained films/shaders. APK CRC/alignment/signing
and Windows manifest PASS. Native source High measured citadel 49.73 FPS mean,
ritual 63.45 at a 2880x1620 render buffer, not native 1080p or a phone result.
No locked-60 or human campaign acceptance claim. [Evidence](testing/v0537-eclipse-expansion.md).

Latest → `build/windows-v0537`; Android code 42 →
`build/android-releases/LastLight-0.5.37.apk`. Owner subsequently authorized
Gofile upload: https://gofile.io/d/ktSFPiUO (426,192,891 B; remote name/size/MD5
verified against local APK; download page HTTP 200).
Direct isolated review: `Preview-Castle.cmd`. Owner approved deleting exactly
three duplicate ZIPs (v0529/v0530/v0533), freeing 1,501,086,572 B; extracted
versions/APKs/saves preserved. Selected caches/old PCKs/new EXE losslessly NTFS
compressed with hash verification. No Git repository/commit. Next: owner art
feedback, real Phone (3a) pacing and sustained performance/route acceptance.

## Cursed basalt buttons and panels — v0.5.36, 2026-11-08

Original generated blue-charcoal stone material, chipped frames and purple
rim fissures now theme main/pause menus, settings, account fields, journey and
dialogue controls, information HUD/prompt and four icon-only touch actions.
State-specific glow, quiet text centers, native padding and focus feedback.
Health/stamina retain red/green. No new shaders/movies or gameplay changes.
Material provenance and exact prompt: `art/cursed-stone-ui-v1.md`.

Godot 4.7.2.stable.official.ed1daf0bf. Import/parse clean; 640 regression PASS,
100 native menu views/routes PASS, 29 native touch graphics PASS, final PCK 39
localization PASS. Inspected native desktop/touch gameplay HUD and final package
menu at desktop/wide-phone/tablet aspects. Windows/Android parity: 107 scripts,
162 character resources, seven catalogs and retained film/shaders; basalt import
present on both. APK CRC/alignment/signature and Windows manifest PASS.

Latest launcher now selects `build/windows-v0536`; Android code 41 is
`build/android-releases/LastLight-0.5.36.apk`. Owner subsequently authorized
Gofile upload: https://gofile.io/d/DhClZGt1. Uploaded 426,184,498 B; remote MD5
matches local file and public download page returns HTTP 200.
No deletions; new Windows EXE losslessly compressed/hash-verified; no ZIP copy.
No Git repository/commit. No real-phone FPS or physical touch acceptance claim.
[Evidence](testing/v0536-cursed-stone-ui.md). Next: owner visual feedback and
Phone (3a) readability review; prior SMTP/recovery limitations remain unchanged.

## Device graphics and measured pacing — v0.5.35, 2026-11-08

Owner targets Nothing Phone (3a) and the inspected i5-12450H/RTX 3050 Ti Laptop
4 GiB/15.7 GiB RAM, 1920x1080/120 Hz system. Added High/Balanced/Performance
rendering profiles, default High with 60 FPS ceiling. Desktop also offers 120;
mobile offers 30/60. Optional FPS HUD, five-language settings, validated local
preferences and legacy Low graphics migration. High adds 16x filtering/blended
soft shadow cascades/retained detail on desktop; Phone (3a) starting profile uses
90% 3D scale, 2x MSAA, 8x filtering and 24 m shadows. UI stays full resolution;
pixel budgets bound HiDPI buffers. Pine edges use alpha-to-coverage. Graphics
changes preserve window size/mode and journey progress. ADR 0018 records policy.

Godot 4.7.2.stable.official.ed1daf0bf. Full regression: 640 PASS. Graphics checks:
29 PASS each desktop/touch, headless and native; five-language settings captures
reviewed. Final PCK: 29 graphics PASS each desktop/touch, 39 localization PASS,
19 native wizard cinematic PASS. Windows/Android match: 106 scripts, 162 character
resources, seven locale/cloud catalogs, movie and menu/torch shaders. APK CRC,
alignment, v2/v3 signature and unchanged signing identity PASS; folder hashes PASS.

Native before/after workload used the release PCKs in the pinned editor runtime,
sequentially, uncapped/VSync off, 60 s warmed samples over five fixture areas.
High mean throughput 71.8–203.0 FPS; worst area's P95 15.50 ms, worst 23.90 ms.
Extra quality costs throughput; 120 is not guaranteed throughout the world.
Observed render texture 2880x1620 under DPI scaling, not native 1080p. Actual
standalone EXE's 65.07 s capped slice run exited 0: median 16.669 ms, P95 17.588,
overall mean 54.80 FPS including loading/first-use stalls up to 2,623 ms.
Do not claim hitch-free/locked 60. No human campaign or real-phone FPS acceptance.

Latest now targets `build/windows-v0535`. Android code 40:
`build/android-releases/LastLight-0.5.35.apk`. Local only, no public upload.
No duplicate Windows ZIP. Owner approved exactly five intermediate AVI files
and two duplicate old Windows ZIPs; removed those seven, freeing 1,996,268,833 B.
Retained game movies hash-verified unchanged; source, models, saves, APKs and
extracted old Windows versions preserved. About 1.5 GiB free at final checks.
No Git repository/commit. [Evidence and limits](testing/v0535-device-graphics.md).

Next: install locally on Phone (3a), inspect FPS/heat over sustained play; improve
loading/first-use stalls separately. SMTP/recovery and memory-only-login limits
remain unchanged.

## Maldrek victory animation — v0.5.34, 2026-11-08

Twelve-second live 3D scene follows the lethal hit: stagger, skinned kneeling,
collapse, directed close/side/wide cameras and violet magic withdrawing toward
the intact central artifact. Victory saves before playback. Physics/input/HUD
are suspended; Skip/Esc or timeline completion restores actor geometry, camera
and controls. The explicit artifact interaction still completes the campaign;
reloading a defeated boss neither replays the scene nor duplicates rewards.
Shared font, five-language captions and touch-sized Skip. Knight movement now
stops within the same physics tick when its lethal attack starts the scene.
Corrected height-dependent torch sway that produced long golden streaks.

Godot 4.7.2.stable.official.ed1daf0bf. Full campaign/presentation suite:
639 assertions PASS. Source cinematic checks: 19 PASS, including real knight
attack sweep, immediate input/camera handoff, decorative effect cap, translations
and automatic completion. Isolated Windows PCK: 39 localization and 19 native
cinematic assertions PASS; four directed sample frames captured. Continuous
twelve-second native preview also completed successfully. Actual close/collapse
frames reviewed. This is fixture-based verification, not a new full campaign
playthrough or real-phone/FPS certification.

Windows: `build/windows-v0534`, Latest launcher updated. `Preview-Victory.cmd`
plays the scene continuously with isolated test state, then closes; no owner
saves/accounts used. Windows folder hashes verify. No duplicate ZIP produced
(`Build-Windows.ps1 -SkipArchive`) because disk remains limited.
Android: `build/android-releases/LastLight-0.5.34.apk`, code 39. Final APK CRC,
alignment, v2/v3 signature and unchanged signing certificate verified. Engine
signing initially ran out of temporary space; separate signing of its aligned
output succeeded. Windows/Android match: 105 scripts, 162 character resources,
six locale/cloud catalogs, movie, menu shader and corrected torch shader.

Owner chose **local only**: no v0.5.34 public upload. Old releases/saves/artwork
preserved. Lossless filesystem compression with before/after SHA256 checks was
used on old runtime/PCK copies and Windows templates; about 540 MiB free remains.
No Git repository/commit. Evidence: [v0.5.34 review](testing/v0534-wizard-defeat.md).
Next: owner review of the full-speed scene and real-phone performance.
SMTP/recovery and memory-only-login limitations remain unchanged.

## Violet curse and moonlit menu — v0.5.33, 2026-11-08

Owner confirmed violet curse and UI accents. Menu film reframed 8% left with
18% horizontal overscan; added warm yellow detail light, pale gold crater-face
moon and clock-driven violet castle filaments. Reduced motion freezes all layers.
Purple buttons, focus borders, inputs, toggles, sliders, scrollbars and mobile
icons; health remains red and stamina green. Magic/seals/wards use violet;
safe lanterns stay warm. All eleven regions have bounded decorative curse
presence, removed according to local seal/finale state. Original film unchanged.

Godot 4.7.2.stable.official.ed1daf0bf. 633 campaign/presentation assertions,
37 curse checks, 80 native language/layout/motion checks and 11 native decoder
checks PASS. Native main/pause button routes and 100 section captures PASS.
Eight region debug views captured; selected crypt/menu/settings views reviewed.
Packaged Windows: 39 localization and 11 native movie checks PASS; actual package
menu captured/reviewed. Both delivery archives pass CRC; Windows manifest hashes
match. Android v2/v3 signature verifies. Windows/Android: 103 compiled scripts,
162 character resources, five locale/cloud files, movie and grading shader match.

Latest launcher now targets `build/windows-v0533`. Owner approved Android upload:
https://gofile.io/d/f8WsUW4i, `build/android-releases/LastLight-0.5.33.apk`, code 38.
Receipt: `.tools/android/gofile-upload-v0533.json`; private management token must
not be published. Windows ZIP: `build/Last-Light-windows-v0533.zip`.

Native window title/menu v0.5.33 verified. Earlier owner window was v0.5.31;
it was no longer running before the new package check. Fresh preview was closed
at its menu. Reopening through Latest with the usual save environment was not
completed because computer-use app approval timed out. Owner can use Latest.
Real phone brightness/performance review remains pending. This was not a full
campaign playthrough. SMTP/recovery and memory-only-login limits unchanged.

38 old executable copies losslessly filesystem-compressed; SHA256 unchanged.
No additional deletions, old packages and owner saves preserved. About 875 MiB
free at last check. Evidence: [v0.5.33 review](testing/v0533-violet-curse.md).

Next: owner visual review on both devices, especially phone brightness and FPS.

## Brighter left-shifted menu film — v0.5.32, 2026-11-08

Owner requested improved visibility on laptop/phone. Added a lightweight movie
grade with deep-black protection, reduced the dark overlay and reframed the
movie left by 2.5% of viewport width. 6% overscan keeps edges covered. Original
movie bytes/motion are unchanged; title and button styling/positions unchanged.

Godot 4.7.2.stable.official.ed1daf0bf. Native fixed-pose A/B at desktop, wide
phone and tablet aspects captured; desktop/wide views reviewed. Sampled scene
luminance 1.62x old composite (not calibrated phone brightness). 11 native loop
assertions PASS. Isolated Windows package: 39 localization and 11 native decoder
assertions PASS, plus actual menu A/B captures. Windows/Android: 100 scripts,
162 character resources, five locale/cloud JSON files, movie and grading shader
identical. APK v2/v3 signature and both archives' CRC checks PASS.

Latest launcher targets `build/windows-v0532`. Android code 37:
`build/android-releases/LastLight-0.5.32.apk`; explicitly approved Gofile upload
https://gofile.io/d/pB4x6R9t verified by name/size/MD5 and HTTP 200.
Owner separately approved deleting exactly 535 reproducible menu-render PNG
intermediates after a manifest/hash review; 548,230,662 bytes freed, six keyframes
retained. No originals, movies, saves, models or previous builds removed.
Evidence: [v0.5.32 review](testing/v0532-menu-light.md).

Known limit: real phone display/performance review pending. Only about 325 MB
disk space remains after the new packages; avoid another large export until
more workspace space is explicitly authorized. Account fixes remain deployed;
SMTP/recovery and persistent-login limitations unchanged. Owner app left open.

## Confirmation return and working cloud sync — v0.5.31, 2026-11-08

Reproduced and repaired the live Supabase confirmation return: default localhost
Site URL replaced with a same-project public informational return function.
Explicit clean fragment removes session/error fragments before displaying fixed
instructions. Five languages; no credentials, database or auth SDK in this page.
The invalid-token public redirect probe went from FAIL to PASS. Real new Gmail
verification/recovery round trip has not been performed by the agent.

Owner's screenshot then confirmed successful sign-in but failed cloud upload.
Actual loaded-save wire JSON contains numeric schema version 8.0. The deployed
RPC used a text regex accepting only 8, incorrectly rejecting loaded saves and
accepting the string "8". Replaced only that routine's schema-number predicate
with numeric type/value validation. Actual read-only RPC regression: three
failures before, all 12 cases PASS after. No table data/RLS/grants reset.
Running owner client subsequently acknowledged all 9 journeys, 0 pending,
observed through read-only sync metadata. No token/password accessed.

Client: resend confirmation action, local cooldown/server limit handling,
specific expiry feedback and correct link/code delivery wording. Signed-in
profile no longer displays the registration-preview banner. New UI translated.
13 adapter, 21 replica and 211 section assertions PASS; native five-language
account captures/25 UI assertions PASS. Isolated PCK: 39 localization, 13 auth
and 27 UI assertions PASS. Evidence: [v0.5.31 review](testing/v0531-account-confirmation.md).
Windows/Android scripts, models, five locale/cloud files and menu movie match;
APK v2/v3 signature and both delivery archive CRC checks PASS. Real anonymous
journey read remains rejected (HTTP 401).

Godot 4.7.2.stable.official.ed1daf0bf. Latest launcher targets
`build/windows-v0531`; Android code 36 in `build/android-releases/LastLight-0.5.31.apk`.
The server fixes apply to already installed versions; resend UI needs v0.5.31.
No v0.5.31 public upload or owner-app restart performed. Custom SMTP/default
sender restrictions, password recovery and persistent-login limitations remain.
Next: owner phone sign-in/sync acceptance and SMTP configuration when ready.

## Actual looping menu movie — v0.5.30, 2026-11-08

Owner found v0.5.29 motion too subtle. Menu now plays a real twelve-second
720p/30 fps local film: clearly moving storm clouds, a moving cloak silhouette
and wind in foreground grass/branches. Translated UI remains separate and
legible. Native looping decoder, cover scaling, pause/resume in place and hidden
menu decode suspension verified. Original layered artwork remains as fallback.

Godot 4.7.2.stable.official.ed1daf0bf. 11 native loop/playback assertions PASS,
48 layout/motion assertions PASS, touch viewport/reduced-motion checks PASS,
211 section and 103 journey translation assertions PASS. Isolated Windows PCK:
39 localization, 14 menu resources and 11 native decoder assertions PASS.
Windows/Android have identical movie bytes, 100 compiled scripts, 162 prepared
character resources and four locale/cloud JSON files. APK v2/v3 signature and
both delivery ZIP CRC checks PASS. No real-phone FPS or new campaign test.

Latest launcher: `build/windows-v0530`. Android code 35,
`build/android-releases/LastLight-0.5.30.apk`. Owner approved v0.5.30 upload;
Gofile phone download: https://gofile.io/d/NMb09A6j . Remote file name, size
and MD5 match the checked release. Previous v0.5.29 URL remains an older build.
Evidence and preview: [v0.5.30 review](testing/v0530-looping-menu.md).
Next: owner review of visible wind/phone playback. Email redirect and SMTP
setup remain pending separately; no account change in this visual release.

## Layered living menu — v0.5.29, 2026-11-08

New original landscape with a quiet dark title zone and separate knight/plant
layers. Wind moves cloak and foliage; armor and castle remain rigid. Full
title/tagline rectangle excludes motes. Locale heading measurement corrected;
all layers freeze in place when Animated menus is disabled. Old art retained.

Godot 4.7.2.stable.official.ed1daf0bf. Native layout/effect checks: 48 PASS across
five languages and three aspects. Touch viewport/reduced-motion checks PASS;
211 section and 103 journey localization assertions PASS. Exported Windows
package: 39 localization and 12 living-menu assertions PASS. Windows/Android:
100 compiled scripts, 162 character resources and four locale/cloud JSON files
identical. Android v2/v3 signature PASS. Preview and evidence:
[v0.5.29 review](testing/v0529-living-menu.md).

Latest launcher now targets `build/windows-v0529`; Android version code 34,
`build/android-releases/LastLight-0.5.29.apk`. No new campaign/performance or
real-phone test. No live account verification performed. Supabase confirmation
still redirects to default localhost; dashboard correction and SMTP remain
pending. Next service task: repair and verify the email-confirmation return
route without exposing session tokens or changing existing journeys.

## Complete menu sections — v0.5.28, 2026-11-08

Owner's open app was v0.5.26; a launcher update had not restarted that process.
Confirmed and fixed a separate source gap: all nine Credits paragraphs were
absent from translation catalogs. Credits now translated in BG/RU/FR/AR, with
source attribution preserved. Full Settings wording manually edited. Original
legal font texts stay verbatim under a translated heading; all five fonts shown.
Actual owner-record review additionally caught and fixed the missing Grave Hound
Resource name in victory history, without rewriting saved data.

211 full-section assertions and 103 journey/localization assertions PASS.
100 native section/scroll captures across five languages PASS; actual packaged
Windows Credits and Progress reviewed through native UI. Package results and
final restart evidence: [v0.5.28 review](testing/v0528-full-menu-sections.md).
No new campaign/performance/live-account test. Account sessions remain memory-
only; restart requires signing back in to view the account library. SMTP pending.
Final v0.5.28 exports verified: 39 isolated package assertions PASS; Android
signature/CRC PASS; 99 game scripts and all four locale/cloud data files match.
95 original save/backup files checked, zero changed during native menu review.
Latest and Build launchers updated. APK: `build/android-releases/LastLight-0.5.28.apk`.

## Journey translation correction — v0.5.27, 2026-11-08

Reproduced mixed Bulgarian picker text (`Rank`, `bosses`) in all four extra
locales. Added missing composed/atomic journey, chapter and status templates;
fixed dynamic whitespace handling and deterministic catalog precedence.
Normalized translated place/character names across prose and polished Bulgarian
progress/journal terminology. Source/save IDs and progression unchanged.

102 targeted localization assertions PASS, including saved picker updates,
nested library summaries, reports/statuses, catalog fields and save preservation.
Native main menu/library/progress captures in all five languages PASS; Bulgarian
screens reviewed. Exported Windows package localization smoke PASS. See
[v0.5.27 evidence](testing/v0527-journey-translations.md) for package results.
Windows `build/windows-v0527` and Android code 32 are exported and verified.
23 isolated package assertions PASS; compiled scripts and locale/cloud data
match between platforms. APK signature and archive CRC pass. Latest launcher
now starts v0.5.27. APK: `build/android-releases/LastLight-0.5.27.apk`.
General campaign baseline remains v0.5.26's 627 assertions; no new campaign,
performance or real-phone test is claimed. SMTP owner setup remains pending.

## Menu, five languages and optional cloud preview — v0.5.26, 2026-11-08

New original menu panorama with restrained animated light/mist, charcoal/brass
buttons, focus ornament, persistent language picker and modal menu backdrop.
English, Bulgarian, Russian, French and Arabic UI/story catalogs are present;
Noto font fallbacks support Cyrillic and Arabic. Core UI manually edited;
machine-assisted narrative translations still require native-language review.

Optional Supabase sign-in, explicit guest import, private account libraries,
revision-checked cloud snapshots and conflict preservation implemented. The
private table and commit function are installed in project
`vtvvevevkhqwyemrpawy`; live anonymous reads/writes are denied. Tokens/passwords
are memory-only. Account login is required again after application restart.

**Owner dependency: email delivery remains unconfigured.** Registration is
visibly in testing, default email-link confirmation is supported for eligible
project-member addresses, and code-based recovery is unavailable. Ready templates
and exact owner steps: [SMTP setup](SMTP-SETUP.md). Do not call public account
creation, recovery or actual Android/Windows sync verified until SMTP and a
real-device account test are completed. Offline campaign play remains available.

Godot 4.7.2; 627 campaign/presentation assertions PASS, 5 durable cloud-file checks
PASS, five-language native captures, seven touch viewport checks and reduced
motion PASS. Isolated Windows package smoke: 10 checks PASS. No new FPS benchmark.
See [v0.5.26 evidence](testing/v0526-menu-accounts-languages.md).
Windows/Android export verification and package paths are appended there.
Both v0.5.26 exports are ready locally. Android signature v2/v3 and archive CRC
passed; 99 compiled scripts, 162 prepared character resources and three locale/
cloud files match across platforms. Android code 31 includes Internet permission.
`Play-Latest.cmd` now starts `build/windows-v0526/LastLight.exe`.
APK: `build/android-releases/LastLight-0.5.26.apk` (412,319,141 bytes).
Next: owner SMTP setup, email/real two-device acceptance and translation review.

## Shared Cinzel typography — v0.5.25, 2026-11-07

Title, body and buttons share Cinzel with a bundled symbol fallback resource.
HUD, dialogue, menu, prompts, world/NPC/hostile labels now use that same family.
Icon-only touch actions retained. Live film captions cover the old baked strip,
track stream timing/fades and fit the movie rectangle; Skip moved above captions.
No video re-encoding, downloaded fonts, save changes or gameplay rule changes.
Godot 4.7.2; 589 regression assertions PASS. Native phone/tablet/150%-text and
Windows captures plus film caption captures recorded and reviewed. See
[typography evidence](testing/v0525-cinzel.md). No Git repository.
Next: owner readability review on the physical phone.


## Directed casting, collapse and recovery — v0.5.24, 2026-11-07

After completing 0.5.23, applied the owner's new cinematic feedback: wizard arm
and staff gestures, gathering/releasing filaments, dark vapor and forest ground
veins replace both rings. Authored articulated recoil, knee collapse, settling,
brace/kneel/rise replace rigid actor rotations. Camera push/pull, height and lens
changes follow the action. Offline-only effects and pose scripts under tools/;
no new runtime rendering cost beyond the existing local video decoder.
1080p60/720p60 formats and 0.5.23 UI/window fixes retained. Native pose previews
reviewed and new master rendered. Evidence and limits:
[film direction](testing/v0524-film-direction.md). Engine 4.7.2; no Git repository.
Next acceptance: owner review of the full moving film and real Android playback.


## Touch icons, stable window size and 60-fps film — v0.5.23, 2026-11-07

Four icon-only mobile gameplay buttons and pause icon, keeping gesture controls.
Native E-travel / boss-entry regression reproduced a reset from both maximized
and fullscreen to 1280x720. Cache the last applied fullscreen preference so map
refreshes preserve native window state; explicit settings toggles still work.
Five native display cases PASS; native touch movement/swipe/pause/heal checks PASS.
Introduction renewed with current colored characters and articulated gait, actual
citadel, new sky, 8x offline MSAA, 1080p60 desktop / 720p60 mobile. Background region
and player drawing are suspended during video and restored on completion/Skip.
Theora/Vorbis stays local; no accounts or new online runtime services.
Engine 4.7.2; no Git repository. Validation and limitations are recorded in
[the evidence note](testing/v0523-ui-film.md). Real phone verification remains.


## Forested slopes and darker night — v0.5.22, 2026-11-07

All eleven regional horizons now have pine belts seated on the fitted hillside
triangles. Full-detail CC0 pine/understory clusters are baked to mipmapped RGBA
impostors and grouped for distant rendering; close-up meshes stay in place.
Added finer relief, dark woodland soil, a higher snow line, significantly darker
storm panorama and matching darker distance haze. No progression or save changes.
Godot 4.7.2: 587 campaign assertions PASS; all eleven seam/forest checks PASS;
native captures and locomotion/performance sample recorded. See
[forested-night.md](testing/forested-night.md) for evidence and known limitations.
No Git repository. Next: owner review and real Android device visual/performance test.


## Grounded horizons, storm sky and lunar face — v0.5.21, 2026-11-07

New photographic-style cloud panorama with drift/wrap blend, alpha moon-face
texture with crater eyes/closed grimace and cloud occlusion. Both original assets
created with built-in ImageGen, copied unchanged into assets/sky; prompts and
paths in docs/art/sky-generation.md. Desktop 4x MSAA / mobile 2x MSAA, mipmaps.
Background mountains now use 384x64 cosmetic relief bands, smooth shared normals,
real Rock Face 03 diffuse/normal/roughness, soil ledges and distant snow. Terrain
extends about 6 km through regional aerial haze; camera far plane 6500 m.

Root cause: archived horizon ended 170-200 m away, positioned art roots were
raised rigidly instead of matching regional floor heights (Peaks 7 m mismatch,
citadel 11 m), and sky/fog horizon tints differed. Final per-vertex fitting now
matches terrain, sky/haze share regional color, and all 11 regions have backdrop
coverage including arena openings. No new collision/navmesh or progression/save
changes. Deterministic relief is cosmetic, not playable world generation.

Grounded archived-build repro: .tools/horizon-baseline.log FAIL; current
.tools/horizon-final.log all 11 PASS, 385 perimeter samples each, max measured
height mismatch 0.000 m. Native region-verified north/edge screenshots reviewed:
.tools/sky-final-native.log and .tools/review/sky-*.png. 587 campaign/presentation assertions PASS (.tools/sky-final-regression.log). See docs/testing/sky-horizon.md.
Final forest sample: 8.29 ms median / 9.24 ms p95 over 180 stationary frames,
121.2 MiB engine static memory on RTX 3050 Ti; not phone/whole-campaign profiling.
Windows/Android packages verified: packaged Windows boot exit 0, manifest/ZIP
CRC/credits PASS; Android CRC/v2-v3 signatures, both sky assets and both sky/
landscape shaders PASS. 92 compiled scripts and 162 character resources identical.
Play-Latest.cmd selects build/windows-v0521. APK:
build/android-releases/LastLight-0.5.21.apk; SHA256
5A6616E03E439ADB450D70627924DAE4854D86A97008C45C6A5AA04453E6BBA5.
Previous builds/saves preserved; no external upload performed.
Godot 4.7.2; no Git commit. Cosmetic terrain remains outside playable boundaries;
not a physical weather simulation, AAA quality guarantee or real-phone acceptance.

## Refined character geometry and surfaces — v0.5.20, 2026-11-07

All ten Meshy characters upgraded from broad color bands to detailed original
reference-projected surface color: armor, cloth, leather, skin, trim and wear.
Restored ~2x source geometry (16,588-71,852 triangles), welded area-weighted
normals and offline five-ray-per-vertex cavity shading. Separate metalness/
roughness, neutral/desaturated fallback palettes, detailed rear garments and
hair/armor patches on rear heads. Removed plaster/derivative normal relief.
Compressed mipmapped S3TC/ETC2 textures; UVs/masks preserved through arm/leg skins.
Original source GLBs/earlier prepared resources preserved; no runtime AI service.

585 campaign/presentation checks PASS; all ten model geometry, height, texture,
mask, normal and limb checks PASS. Native front/back/motion views and actual
forest walk/sprint/attack/dash/guard/idle inspected. Logs:
.tools/refined-regression.log, .tools/refined-model-checks-final.log,
.tools/refined-capture-release.log, .tools/refined-game-final.log.
Latest stationary forest sample: 8.20 ms median / 9.04 ms p95 over 180 frames,
119.3 MiB engine static memory on RTX 3050 Ti; not a full benchmark or phone test.
Reference seams/stretching, repeated rear garment motifs, baked source lighting
and imperfect face/hair geometry remain. See docs/testing/character-surfaces.md.
Godot 4.7.2; no Git commit. No real-phone quality/performance acceptance claimed.
Windows/Android 0.5.20 built and verified: packaged Windows boot exit 0,
manifest/ZIP CRC/credits PASS; Android CRC, v2/v3 signatures and all ten ETC2
character textures present; character shader matches source. 92 compiled scripts
and 162 character resources identical, excluding platform-specific texture import
remaps. Play-Latest.cmd selects build/windows-v0520. Android release:
build/android-releases/LastLight-0.5.20.apk; SHA256
B9BAC97F87E27A06A9A22901E086199CB20D2ED984CC8F2D3940C895E0A45663.
Previous builds/saves preserved, no external upload performed.

## Save and main menu — v0.5.19, 2026-11-07

Pause's former Save and quit button now saves and returns to the title screen
without closing the application. Clear target/input, deactivate journey, pause
world and restore title art, journey selector and Continue. Continue reloads the
same saved slot. Failed save retains the active paused session for retry. Explicit
Quit on title and window close retain application-exit behavior. Shared desktop/
Android frontend; inactive journal hotkeys cannot reopen journey UI.

585 campaign/presentation assertions PASS, including real temporary disk save
failure, footer press/retry, title state and same-slot Continue. Native desktop
and touch-preview captures inspected: .tools/save-menu-native-desktop.log,
.tools/save-menu-native-mobile.log, .tools/save-menu-tests-final.log.
See docs/testing/save-main-menu.md. Godot 4.7.2; no Git commit. Existing checkpoint
save semantics retained; no real-phone interaction acceptance claimed.
Windows and Android 0.5.19 built/verified: packaged Windows boot exit 0,
manifest hashes/ZIP CRC, APK CRC and v2/v3 signatures PASS. 92 compiled game
scripts and 112 character resources identical. Play-Latest.cmd selects
build/windows-v0519. APK: build/android-releases/LastLight-0.5.19.apk;
SHA256 F0113444CF4D5C753E8AB31A10979B04E461C499C6D0689AC0AEC3A8DA7B6DBE.
Previous builds and saves preserved; no external upload performed.

## Authored elevation and summit stairs — v0.5.18, 2026-11-07

Village rises 1.5 m, Blackwood 1.5 to 7 m, Order 7 to 13 m, Peaks 13 to 26 m.
Citadel rises 26 to 44 m through three 6 m stair flights/landings, 120 treads,
posts and lamps; final wizard chamber/central artifact at 44 m. Existing starting
forest terrain retained. Shared authored surface raises subdivided floor/wall
meshes, collision, navmesh, arrivals, interactions, scenery, passive creatures
and later-spawned actors. Rigid structures/instanced props retain their shapes.
Smooth collision ramps beneath visible treads avoid jump/step snags. Fall
recovery is relative to terrain. Ground spells respect the elevated wizard room.
Enemy persistent IDs keep original authored homes; no save schema changes.

Native mountain/summit screenshots inspected; actual knight climbs all three
flights to (0,44,-56.18) and descends to (0,26,13.18). Collision rays pass in six
regions and registered navmesh path follows all three slopes. See
.tools/elevation-physics-final-pass.log, .tools/elevation-capture-final.log and
docs/testing/elevation.md. 581 campaign/presentation assertions PASS including persistent-ID regression.
Windows/Android packages verified: 92 identical compiled game scripts and 112
character resources. Windows packaged boot exit 0, manifest hashes/ZIP CRC,
Android CRC/ground shader/v2-v3 signatures PASS. Play-Latest.cmd selects
build/windows-v0518; Android build/android-releases/LastLight-0.5.18.apk.
SHA256 B2D01E4A4D2173ECDD796523A9740BF75E42F84E95CF8A7AD4D1CCF90B1C26D9.
Previous builds/saves preserved; no external upload.
Godot 4.7.2; no Git commit. Rigid prop anchors and smooth tread collision are
known limitations; no real-phone performance/full human campaign acceptance.

## Overhead red enemy health — v0.5.17, 2026-11-07

Four enemy profiles and all five bosses now use camera-facing red world-space
health meters with name captions. No hostile HP numbers or debug action/state
captions; duplicate bottom boss HUD removed. Actual health drives fill. Dead
meters/names hide, ordinary respawns refill, distant meters hide beyond 28 m,
and scenery occludes them. Height anchors account for smaller hounds and Meshy
bosses. Combat, telegraphs, player HUD, rewards and persistence unchanged.

580 regression assertions PASS, including actual damage for all nine types,
fraction agreement, death visibility and respawn refill. Native full/half health
captures inspected. See docs/testing/hostile-health.md and
.tools/hostile-bars-tests-final.log, .tools/hostile-bars-capture-final.log.
Godot 4.7.2; no Git commit. No real-phone performance acceptance claimed.
Windows and Android 0.5.17 built and checked: packaged Windows boot exit 0,
manifest hashes/Windows ZIP CRC, Android APK CRC and v2/v3 signatures PASS.
91 compiled game scripts and 112 character resources identical across platforms;
Android overhead meter shader matches source. Play-Latest.cmd selects
build/windows-v0517. Android: build/android-releases/LastLight-0.5.17.apk;
SHA256 03E82A5A6C219BAAD9424F25C2B07FD8A3666BD8CD10A2233901DD4AC8CAD23A.
Previous builds/saves preserved; no external upload performed.

## Painted character materials — v0.5.16, 2026-11-07

All ten integrated Meshy characters now use individual rest-space vertex paint:
clothing, skin, hair, leather, metal, trim, rust and wear. Knight chest sun,
blue steel/tan cloth, green/brown Lyra, purple/gold Maldrek, green goblins,
burgundy Commander, rusted Warden and bark/moss/bone Thorn Beast. Existing
credited Poly Haven maps add restrained surface detail. Original source meshes
are preserved; 50 painted derived meshes total 5.33 MB. Leg/arm skinning retains
paint and rest coordinates, avoiding sliding colors during animation.

577 campaign/presentation assertions PASS; ten-model paint/geometry checks PASS.
Native ten-model rest/motion capture and actual knight walk/sprint/attack/dash/
guard/idle capture inspected. Logs: .tools/character-colors-tests.log,
.tools/character-color-checks.log, .tools/character-colors-capture-final.log,
.tools/character-colors-gait.log. See docs/testing/character-colors.md.
Godot 4.7.2, no Git commit. Source facial/hair detail remains limited; these are
vertex-painted models with surface detail, not high-resolution authored atlases.
No real-phone performance/full campaign acceptance claimed.
Windows/Android 0.5.16 built: 90 identical compiled game scripts and 112 identical
character resources, including all 50 painted meshes. Android shader matches
source; APK and Windows ZIP CRC, Windows manifest hashes and Android v2/v3
signatures PASS. Packaged Windows boot exit 0. Play-Latest.cmd selects
build/windows-v0516. Android: build/android-releases/LastLight-0.5.16.apk;
SHA256 6F5AA46B595BC5A1AF40C4C67CC102BF5BC6B432B20C44203B58D04B091058D2.
Packages remain local; no upload performed. Previous builds and saves preserved.

## Animated Space dash — v0.5.15, 2026-11-07

Space dash now retains the walking cycle, played at velocity-derived faster
cadence (2.162x at the existing 8 m/s dash), including arm/wrist motion and
footfalls. Walking-to-dash keeps the existing clip phase. The previous visual
guard excluded all dodge states and selected stand; the upper-body guard also
disabled arm movement during the dash. Both visual exclusions are removed.
Dash physics, collision, duration, invulnerability and stamina rules unchanged.

Grounded runtime repro: baseline stand / 1.0x FAIL; fixed jog / 2.162x PASS.
Command: Godot --headless --path . --script res://tests/check_dash_gait.gd
(-- --baseline exercises the former guard). Logs: .tools/dash-gait-baseline.log,
.tools/dash-gait-grounded.log. Native actual-input capture reports dodge_left
0.52 / jog, cadence >2 asserted, frame inspected (.tools/review/skeletal-dodge.png).
575 campaign/presentation assertions PASS. Packaged Windows boot exit 0, Windows manifest/ZIP CRC and Android CRC/signatures PASS. Windows/Android parity: 90 compiled game scripts and 62 character resources identical. Play-Latest.cmd selects build/windows-v0515. Android release: build/android-releases/LastLight-0.5.15.apk; SHA256 51B770C24E25EDE465E9DC9CDE2F216DD283D387F8FF8E73916EE12E69D78898. No real-phone performance/full campaign acceptance claimed. Godot 4.7.2, no Git commit.

## Natural knight gait — v0.5.14, 2026-11-07

Player shoulder/elbow/wrist skins now animate with the legs. Opposite arm/leg
phase, restrained shield swing, stronger running elbow bend, wrist-driven weapon
carry, small torso rotation/lean/breathing, speed-dependent cadence and continuous
cubic leg poses. Smooth transitions to idle; shield guard has its own arm pose.
Attack/heal/stagger/dodge release secondary motion without writing the combat
pivot, physics, movement speeds, camera or stamina. Uses existing Meshy geometry
and original credited equipment. No new external service or asset purchases.

574 regression assertions PASS, including eight new upper-body checks. Actual
native forest capture reviewed for walking/running, attack/dodge transition,
shield guard and return to idle; 3.83 m physical walking sampled. Logs:
.tools/natural-gait-tests-final.log, .tools/natural-gait-release-capture.log.
See docs/testing/natural-gait.md. Procedural motion still needs human feel review;
not authored mocap, full foot IK, or phone performance acceptance. Windows/Android packages built and verified: 90 identical compiled game scripts and 62 identical character resources; signatures, APK/Windows ZIP CRC and Windows manifest hashes PASS. Packaged Windows boot exit 0. Play-Latest.cmd selects windows-v0514. Android release: build/android-releases/LastLight-0.5.14.apk; SHA256 58443157EEB8DB6BB066CA8E779E7FC7C34ED85D758A8079E8B432D88149690F. Godot 4.7.2; no Git repository/commit.

## Meshy integration — v0.5.13, 2026-11-07

Integrated all ten downloaded character meshes: player knight, Oren, Lyra,
Cael, passive goblins, Gravedigger, Thorn Beast, Fallen Commander, Iron Warden,
Maldrek. Offline Godot ImporterMesh simplification and compact limb meshes:
8,292–35,926 triangles per character; 3.6 MB prepared resources total.
No runtime conversion/service/account dependency. Procedural metal/cloth/skin
materials replace the untextured source appearance. Knight retains its existing
six-bone leg locomotion and detailed credited sword/shield. Other actors retain
procedural movement, weapons, combat clocks, telegraphs and collision ownership.
Full authored character rigs/textures and animation polish remain unfinished.

Checks: 566 regression assertions PASS (.tools/meshy-tests-final.log); ten-model
geometry/floor/height/triangle-budget/limb checks PASS. Native rest/motion captures
for all ten models reviewed, actual boss lineup captured and inspected. Knight
native forest gait/attack/dodge/sprint capture passed: 3.83 m actual walking;
jog/run/stand transitions and knee deformation sampled. This does not establish
phone FPS, full human playthrough, or final animation quality. Windows packaged
headless boot exit 0. Windows/Android packages built and verified: 89 compiled game scripts and 62 prepared character resources identical. APK signature/CRC and Windows manifest hashes PASS. Play-Latest.cmd now selects build/windows-v0513. Android release: build/android-releases/LastLight-0.5.13.apk; SHA256 B7785680E4AC53D666278C0870C32F735355CC0DF6DCF66B334D703BEB610FD9.
Godot 4.7.2. No Git repository/commit. Four online-only models remain inaccessible
for export and 38 references ungenerated because Meshy free quotas were exhausted.

## Meshy source meshes — partial batch, 2026-11-06

Owner authorized conversion of all 52 reference images. Meshy 6 Lite generated
14 models using available free credits. Downloaded/validated 10 GLB source meshes:
knight, Oren, Lyra, Cael, all five bosses, goblin. Troll, dwarf, village house and
watchtower are generated in the account but not downloaded. Observed balances:
0 credits and 0 free monthly downloads. 38 references remain ungenerated.
No paid plan/trial activated. Source meshes and 52-item status/provenance manifest
are in art/model-sources/meshy. GLB v2/header lengths/JSON checked; no textures,
skins or animation. Each has 129,848–560,004 triangles; no game integration or
platform rebuild. Geometry cleanup, materials, optimization and rigging remain.

## Asset references — 52-object image pack, 2026-11-06

Owner requested independent images for upgrading the game's assets via Hyper3D.
Created 50 new distinct references plus reused the approved goblin/shrine inputs;
selected 52 objects: 21 characters/creatures, 12 architecture, 15 props, 4 nature.
Dragon framing edited into a wider v2, leaving its original intact. Built-in
imagegen used for generation/editing; all selected images visually reviewed as
returned. art/reference-pack contains the offline searchable gallery, prompts,
selected-image manifest/dimensions/SHA256. tools/build_reference_pack.py verifies
all image decodes and ZIP hashes/CRC. ZIP: build/Last-Light-Reference-Images-52.zip.
These are raster references, not converted models or integrated game changes.
Hyper3D browser work stopped twice by physical Escape; no 3D job submitted.

Unexported opening-world work is preserved: work/scavenge activities, expedition
props, Oren forge dressing and Burial Seal presentation consequences. Initial
regression reached 566 PASS; final native visual QA and packaging remain pending.

## Latest — 0.5.12 inhabitants in every region, 2026-11-06

43 passive inhabitants distributed across all 11 regions from the starting camp
to the ritual finale (31 new placements). Walking goblins/dwarves, existing troll,
floating wraiths and previous scenery creatures. Road folk follow authored terrain
height. Noninteractive, no combat/rewards/save changes. Region audit: all 43 pass
passivity/clearance/floor checks, all 24 walking folk have enabled safe corridors.
551 regression assertions PASS. Native 43 placement captures plus 24 walking
follow-ups; contact sheet reviewed, corrected placements/cameras reinspected.
Art remains stylized/procedural; no phone/performance/full campaign acceptance.
See docs/testing/world-population.md. Both platform exports completed; Windows
headless native boot exit 0 and manifest verified. Android signature/CRC/license
verified; all 87 compiled game scripts identical between platforms. Play-Latest
targets windows-v0512; previous builds/saves retained. APK ready locally, not uploaded.

## Latest — 0.5.11 moving noninteractive folk, 2026-11-06

Goblins, troll and dwarves stroll along validated short corridors, rest and return.
Articulated arms/legs and hand-mounted dwarf hammer; cached limb meshes shared.
Remain passive without interactions, damage, collision, rewards or save changes.
Pause freezes movement. 551 assertions PASS without script errors; native runtime
verified all five placed folk moving, three species' walking images inspected.
See docs/testing/passive-folk-motion.md. Both exports complete; Windows headless
executable boot exit 0 and manifest verified; Android signature/CRC/attribution
verified. All 87 compiled game scripts identical between platforms. Play-Latest
targets windows-v0511. APK prepared locally; not uploaded externally.

## Latest — 0.5.10 goblins, troll and dwarves, 2026-11-06

Added five passive inhabitants: two goblins at the Blackwood watchtower approach,
a large troll at the eastern Peaks shelf, two dwarves beside the mine. Distinct
ears, tusks, hides, beard strands, helmets and smithing tools; original geometry
and existing credited PBR materials, cached material batches. Remain scenery
only, with no combat, dialogue, rewards, quest state or physical blockers.
548 assertions PASS without script errors. Twelve native placement captures,
five final folk images inspected, new roots clear expanded obstacle footprints.
Stylized procedural art still needs sculpting/texturing for the requested realism.
See docs/testing/dark-folk.md. Windows/Android exports complete; Windows native
headless boot exit 0, manifest verified; Android signature/CRC/license verified.
All 87 compiled game scripts match across platforms. Play-Latest targets v0510.
APK ready locally as LastLight-0.5.10.apk; no external upload performed.

## Latest — 0.5.9 passive non-animal entities, 2026-11-06

Added a hovering robed wraith in Blackwood, a crowned stone sentinel and winged
gargoyle in the citadel. Original procedural forms and credited knight derivative;
no new downloaded assets. Passive Node3D visuals only, outside the central route.
548 assertions PASS; seven native captures completed without script errors and
all three final new entity images visually inspected. Detailed evidence and art
limitations: docs/testing/dark-entities.md. Both platforms exported successfully;
Windows headless executable boot exited 0 and its manifest matched. Android
signature verified, all 86 compiled game scripts identical between platforms.
Play-Latest now targets windows-v059; older builds and saves preserved.
APK prepared locally; no external upload authorized for this payload.

## Latest — 0.5.8 dark-fantasy fauna direction, 2026-11-06

Owner requested genre-typical fauna. Replaced the active bright five-tail treatment
with larger single-tailed dark hounds / pale skull-like brow markings. Dragons
now use desaturated ash/brown scale materials retaining original texture/normal
maps in separate resource copies. Same passive behavior / four safe placements.
Stable source-scene/mesh cache prevents extra recolored copies on region revisits.
548 assertions PASS; native four-placement captures completed and inspected;
original source-material preservation and shared-resource reuse tested. Source
assets/credits retained. Static/procedural art and phone acceptance remain open.
Windows v058 export/manifest and approved host headless boot verified; Android
code13 signature/CRC/attribution inclusion verified; all 85 compiled game scripts
identical across platforms. Play-Latest and aliases route to v058 with prior
saves/builds preserved. APK ready locally, new Gofile sharing awaits permission.
See docs/testing/dark-fauna.md for evidence and hashes.

## Latest — 0.5.7 passive mythical fauna, 2026-11-06

Two pale five-tailed foxes (old road / Blackwood) and two detailed textured ice
dragons (exterior Peaks crag / citadel bastion) added as passive scenery. No health,
hostile membership, hitboxes, interaction, navigation AI, quest facts or rewards.
Only tiny in-place breathing / tail movement; pauses with the game. Roadside fox
aligned to slope and relocated clear of fence after native visual review. The
crystal deer candidate was rejected for active placement as too stylized; retained
with provenance as a source candidate. New dragon/deer author/license metadata
independently verified, hashes and credits bundled; fox uses existing credited base.
546 assertions PASS, all 23 map route/floor/approach checks PASS, four active
placement native captures inspected. No real-phone FPS or photoreal claim.
Windows v057 export/manifest/headless boot PASS; Android code12 signature/CRC and
fauna license inclusion PASS; 85 compiled game scripts identical. Play-Latest and
aliases route to v057, old saves/builds retained. Includes v056 villain changes.
Named APK ready; Gofile sharing awaits owner approval for this version under
earlier automatic-review decisions. See docs/testing/mythic-fauna.md for evidence.

## Latest — 0.5.6 villain detail, 2026-11-06

All four ordinary enemy profiles and five bosses have individual fitted regalia,
open cowls / finer folded cloth / armor and weapon detail. Gravedigger lantern,
Maldrek ritual ornaments, Commander heraldry, Warden furnace fittings, villager
cleaver/apron, shade mask and beast brow/back details distinguish the silhouettes.
Static fittings are baked by material and shared by matching actor types; source
armor/fur geometry/credits retained. Gameplay stats, collision, attack authority,
save format and the upgraded maps remain. 542 assertions PASS; native portraits
for all nine types, both lineups and village/crypt windup captures completed;
key portraits and crypt windup inspected. Detached extra beast fangs removed after
visual review. No physical-device FPS or production animation acceptance claimed.
Windows v056 export/manifest/headless boot verified. Android code11 signature/CRC
PASS with same certificate, 83 compiled game scripts identical across platforms.
Play-Latest / Session / Villains route to v056 with existing saves. Named Android
APK ready; Gofile sharing pending owner permission for this new version.
See docs/testing/villain-detail.md for hashes, model changes and limitations.

## Latest — 0.5.5 Blackwood through finale design, 2026-11-06

All eight later maps have regional ground/path materials and additional authored
vegetation/props/architecture. Blackwood trail/scout tower/signs, curved root grove,
Order barracks/courts/windows/banners, sanctum details, Peaks crags/mine rails/cart,
forge tools/pipes, citadel service houses/prison/upper towers and ritual windows /
floor inlays / ceiling structure implemented. New citadel building footprints
have collision and rebuilt navigation. Source startup/village art stays unchanged.
540 assertions PASS; 23 actual navigation/arena-approach/spawn-floor checks PASS;
15 native views captured, key views inspected. Import/test/capture logs clean.
Fixed-view Blackwood primitive count reduced 5.14M -> 1.90M; desktop mobile
profile 568K. These are render counters, not physical-phone FPS measurements.
Windows v055 export/manifest/headless boot verified; Android code10 signed and
CRC verified; 82 game scripts identical across platforms. Play-Latest and
Play-Session point to v055, saves/older builds retained. APK ready locally; new
Gofile payload needs owner permission under prior automatic-review decisions.
See docs/testing/chapter-map-design.md for screenshots, hashes and remaining art
limitations. Full manual campaign and physical-phone review are still open.

## Latest — 0.5.4 sprint-only stamina, 2026-11-06

Owner changed stamina policy: only sprint consumes it. Light/heavy attacks,
walking, jumping, dodge and frontal guard are free; attacks/dodge/guard work with
empty sprint reserve. Regeneration can continue in combat after sprint delay.
538 assertions PASS plus four real movement/consumption/recovery/dodge checks.
Windows v054 export/manifest/headless boot and Android code9 export/signature/CRC
verified. Same signing key, 79 compiled game scripts identical. Play-Latest now
launches windows-v054, preserving saves and older packages. Android local package
ready; Gofile upload blocked by automatic approval review because prior permission
covered 0.5.3 specifically. Ask owner approval for new payload before upload.
See docs/testing/v054-sprint-reserve.md. No physical-phone test claimed.

## Latest — 0.5.3 resource HUD / mobile jump, 2026-11-06

Named/numeric health and stamina meters, low-resource labels, quarter divisions
and loss trail implemented. Mobile retains four primary buttons: tap/release
Dodge to evade, swipe up from Dodge to jump, permanent button hint. Native touch
events physically lifted the actor without dodge; cancellation/release checks
PASS. 537 assertions PASS. Frontend wide/tablet/large-text captures passed.
Windows v053 build/manifest/headless boot verified; Android code8 signed/CRC PASS,
same certificate, 79 compiled game scripts byte-identical across both packages.
Includes all preceding region art/audio/skeletal source increments. Play-Latest
now points to windows-v053, preserving saves and all older builds. Named APK ready
at build/android-releases/LastLight-0.5.3.apk. Physical-phone feel/FPS remain open.
Gofile upload blocked by automatic review pending explicit APK-sharing permission;
no new download URL. See docs/testing/v053-hud-jump.md for hashes and evidence.

## Source checkpoint — citadel / ritual architecture, 2026-11-06

First courtyard/prison/ascent and vaulted ritual hall pass implemented. Native
capture completed, courtyard/hall screenshots inspected. Broad flat walls and
simple wizard geometry remain unfinished. See docs/testing/citadel-art.md.
Campaign/presentation regression: 533 assertions PASS, process exit 0.
Play-Session rebuilt successfully before this pass: contains Order, Peaks, forge,
layered audio and default skeletal knight. Citadel source not yet packaged;
Android/Play-Latest remain stable 0.5.2. Goal tool reports usageLimited; stop further
feature work at this checkpoint and resume from regression/package evidence.

## Source — skeletal knight locomotion, 2026-11-06

Six-bone skinned legs and authored jog/run/stand clips now enabled by default;
legacy presentation remains available with --legacy-locomotion. Corrected missing
leg geometry caused by zero active pose translations. Native render regression
changed from 0 to 63,131 upper/shin pixels. 533 assertions PASS, including skin
weights/UV/bind origins and visual-only sampling. Native jog/sprint/attack captures
inspected; attack/dodge blend to stand. Full-body combat animation and foot IK
remain unfinished. Lowered decorative paving toward collision floor. See
docs/testing/skeletal-locomotion.md. Published Android 0.5.2 is unchanged.

## In progress — Peaks and forge presentation, 2026-11-05

Bridge underside arches/balustrade, actual gorge faces, mine supports/roof,
fortress portal/towers and external rock/ridge setting added. Original bridge gap,
deck/rails/fall recovery/navigation stay. Shared external apron closes terrain/sky
seams; outside-bounds assertions still pass. Forge vault/frame/chains/furnace faces
reuse six amber lights plus cool fill; faceted seals replace selected cubes.
529 assertions PASS; native gorge/mine/forge/furnace captures inspected. Boss
material-readability tuning underway. Not in published 0.5.2 yet. Details:
docs/testing/peaks-forge-art.md. No manual/FPS/phone quality claim.

## In progress after 0.5.2 — Order architecture and layered audio, 2026-11-05

Order barracks/arcade/memorial/sanctum facade and vaulted Commander hall added;
burial chamber now uses shared stone-vault geometry. Native regional captures
inspected, existing combat/progression rules preserved. Kenney CC0 official source
footfalls and original varied weapon noise replace selected tone cues. Independent
footfall emitter cannot cut active weapon audio; death clears it. 529 assertions
PASS. Subjective audio/camera/FPS/phone review still open. These changes are not in
the already published 0.5.2 APK. docs/testing/order-architecture.md and combat-audio.md.

## Latest — cumulative 0.5.2 packaging, 2026-11-05

Blackwood visual route/landmarks complete as an increment. Discovery-aware journal
replaces full-campaign spoiler text; controls separated, met allies/victories shown.
Original friendly silhouettes replace boxes; Cael uses the credited knight adapter.
Same visuals used by active followers with presentation-only walk cycles.
526 assertions PASS. Native fresh journal, friendly lineup and frontend badge
captures inspected; civilian anatomy remains prototype/stylized. Windows v0.5.2
manifest and packaged headless boot PASS. Play-Latest and owner's village launcher
point to build/windows-v052; Play-v05 retains old version. Android cumulative
versionCode 7 export complete; matching signing certificate, APK CRC and all 69
compiled scripts identical to Windows verified. New APK SHA256:
F15F2C5034983645FBE755832A9C571ADBCC0794CA9A560194A06EE1DB4425FA.
docs/testing/v052-shared.md tracks package evidence. Named APK uploaded to
https://gofile.io/d/tEm97VBu; remote size/MD5 match local. This package precedes
the subsequent Order art work in source.

## Latest — Blackwood trails and landmarks, 2026-11-05

Cubic foliage presentation replaced by existing bounded pine meshes, preserving
trunk collision/navigation. Broken stone route, braced watchtower with torn roof,
arched/rooted shrine and batched root-bar visuals added. Existing shortcut body
controls root visibility. External ridge backdrop hides rectangular boundary art.
520 assertions PASS; bounded native trail/tower/shrine captures inspected. No
manual companion or FPS claim. Preview: Play-Blackwood-Art.cmd. Android remains
0.5.1 forest package. Details: docs/testing/blackwood-art.md.

## Latest — burial ambience, 2026-11-05

Five original PCM assets: filtered chamber air bed, three spatial drip variants and
seal resonance. Region-owned three-player soundscape uses SFX volume, inherits
gameplay pause and stops on region disposal. Seal visibility signal stops resonance
immediately, including while paused. 520 assertions PASS with actual startup,
seal-break and unload integration. Sample analysis confirms nonzero RMS/no clipping.
No subjective listening/device mix acceptance claimed; this is synthesized ambience.
Separate Windows preview: Play-Burial-Sound.cmd. Android remains 0.5.1 forest
content. Evidence/limits: docs/testing/burial-audio.md. Saves/old builds retained.

## Latest — burial chamber architecture, 2026-11-05

Closed stone barrel vault/ribs, wall bays, six perimeter sarcophagi/effigies and
rear pointed recesses replace the open-sky chamber/old coffin blocks. Warm torches,
cool fill and crypt-specific lighting preserve a readable central arena. Existing
floor/walls, boss rules, seal/barrier and saves unchanged. 517 assertions PASS,
including three clear combat corridors and boss/seal integration. Native vault,
tomb and actual third-person camera/HUD captures inspected, clean bounded exit.
Separate Windows preview: Play-Burial-Chamber.cmd. Android remains 0.5.1 forest
package pending refresh. No manual fight/FPS/phone acceptance. Full evidence and
cosmetic collision limitations: docs/testing/burial-architecture.md.

## Latest — mausoleum and graveyard exterior, 2026-11-05

Original crypt box/prism appearance replaced by tiered stone mausoleum with twin
towers, steep roof, buttresses, layered portal, iron door and rose-window tracery.
Six grave blockers retain their footprint with rounded tablets/carvings/slabs.
Original crypt interaction/transition retained; roof and buttress proxies added.
516 assertions PASS, including routes/boss progression and high roof collision.
Native entrance/graveyard images inspected, clean bounded capture exit. Separate
Windows preview: Play-Mausoleum.cmd. Manifest hashes PASS; packaged headless boot
exit 0 with clean log. Android remains 0.5.1 forest content. Interior/animation/audio,
manual campaign and phone/performance acceptance remain open. docs/testing/mausoleum.md.

## Latest — village terrain and horizon, 2026-11-05

Blended street cobbles/yard soil material with burial-seal tint preserved. Ten
authored low-grass pockets, 18 outer trees and external ridge skirt frame the
village, without changing physical ground/navigation or story state. 515 assertions
PASS including routes, seal-driven terrain tint and outside-bounds backdrop.
Native market and square views inspected, clean bounded capture exit. Separate
Windows preview: Play-Village-Landscape.cmd; manifest hashes and headless exported
boot PASS (exit 0). No manual full campaign/FPS/phone claim. Android APK remains
0.5.1 forest content pending the next packaging pass. docs/testing/village-landscape.md.

## Latest — village trades and yard composition, 2026-11-05

Two abandoned market stalls, banded crates/barrels, woodpiles, water troughs,
interrupted yard fences, laundry line and weathered canvas added. Simple physical
proxies enter final village navigation; campaign/save/encounter rules unchanged.
513 assertions PASS including story route connectivity, canopy/storage collision.
Native east market and west yard images inspected. Separate Windows preview:
Play-Village-Life.cmd. Android 0.5.1 remains the prior forest package. Full manual
playthrough, phone/performance and village horizon/interiors remain open.
Evidence: docs/testing/village-life.md.

## Latest — Android Forest Road package, 2026-11-05

Android 0.5.1-forest-road (versionCode 6) includes both King's Road and woodland
canopy/horizon/lighting increments. Same org.lastlight.knight package and signing
certificate as v0.5; update-in-place expected, actual phone acceptance pending.
APK CRC, embedded kings_road/forest_horizon scripts and no player-save payload
verified. Signature verification and matching certificate checked.
373445337 bytes; SHA256 4B97A5B025130DC19264A7BD1CE827E0BF61D2F21D3B05B2B55FFCC31C0A41A2.
Previous APK retained as build/android/LastLight-v05-before-forest.apk.
Build evidence: .tools/android/forest-export.log. No physical phone FPS claim.

## Latest — woodland horizon and lighting increment, 2026-11-05

Wider bounded pine canopies with copied alpha-scissor needle materials; decorative
576-triangle ridge skirt outside the playable rectangle with citadel valley view.
Adjusted refuge fog/fill/key angle and three warm roadside structure torches.
511 assertions PASS, including outside-bounds horizon geometry, road corridor and
navigation/travel regressions. Bounded native capture exits 0; final watchtower and
chapel views inspected. Separate preview: Play-Forest-Light.cmd. Existing saves and
builds retained. Android APK not refreshed; no phone performance or full campaign
claim. Further foliage/terrain/sky/castle polish remains. docs/testing/forest-light.md.

## Latest — King's Road first composition increment, 2026-11-05

Authored broken stone carriageway, boundary stones/signs, estate fence runs,
roadside shelter, abandoned wheeled cart, ruined watchtower and small graveyard
added to the refuge woodland. Reserved vegetation clearings around new structures.
Batched timber/stone detail; simple tower/cart collision; decorative thin fences.
No campaign/save/encounter changes. 510 assertions PASS, including a 2.4m road
corridor, tower collision and actual forest/village transition regression.
Native rendered camp/watchtower/graveyard images inspected. Existing canopy,
horizon and lighting remain below the desired quality; not an AAA-quality claim.
Separate Windows preview: Play-Kings-Road.cmd. Android APK not updated yet.
See docs/testing/kings-road.md for evidence and remaining work.

## Latest — shared Windows/Android v0.5, 2026-11-05

Owner's laptop entrypoint identified as Play-Village-Detail.cmd, a native Windows
village build. Updated that launcher to build/windows-v05 with unchanged workspace
APPDATA and added Play-Latest.cmd. Prior windows-village export retained. Both
platforms now instantiate the same current frontend; named menu actions work on
desktop without a touch overlay. Input/render profiles remain platform-appropriate.
Saved journey/schema-v8 behavior and current content are shared. No cloud save sync.

508 assertions PASS; separate desktop/touch menu action probes PASS. Native laptop
wide/tablet/large-text captures inspected. Windows EXE smoke exit 0, folder/ZIP
hashes and Android signing continuity verified. All 59 compiled game scripts are
byte-identical across the PCK/APK. See docs/testing/v05-platform-parity.md for hashes
and limits. No new full campaign/hardware phone/performance acceptance claimed.

## Latest — saved journey library and progress, 2026-11-05

New Journey UI allocates a new independent ID; the three-slot campaign limit is
removed. Existing saves remain discoverable. Saved journeys / World progress show
bosses, quests, world unlocks, allies/items, character progress and ordinary-enemy
victory history. Schema v8 migrates old saves without inventing historical kills;
existing campaign facts/rewards remain authoritative. Atomic snapshots/backups and
failed-write recovery retained; single enemy life cannot grant duplicate history.
506 assertions PASS, including actual disk restart and runtime New Journey flow.
Native captures inspected with six seeded QA journeys. Same safe-checkpoint and
ordinary-enemy respawn rules; history persists. Local storage, no cloud sync.
Decision: docs/adr/0009-journey-library-and-victory-history.md. Device acceptance
still pending; no new Android performance claim.
Android v0.5 export/signature continuity/payload hashes/APK CRC verified; package
contains no player saves or QA fixture campaigns. APK SHA256:
17EF2B45A322F27417E3162B404D5C64A3106711D662B173F875320B71EC28E3.

## Latest — mobile v0.4 button and frontend pass, 2026-11-05

Reproduced context-hold returning to the in-game full-screen menu; removed its
pause shortcut. Explicit HUD pause tap replaces it while four gameplay buttons
remain. All four held controls now stay in gameplay in the targeted regression.
Barlow Semibold button face, shared rounded states, original action symbols and
press feedback added. Ambient menu art/embers/page fades, reduced-motion toggle
and a distinct current-world pause screen improve startup/in-session separation.
Save schema/combat authority unchanged. Reference comparison and device/crash
verification limits: docs/testing/mobile-ui-v04.md. No Android launcher-crash fix
or phone FPS claim without device evidence.
485 assertions PASS; native wide/tablet/150%-text captures and disabled-atmosphere
check PASS. Dedicated pause/cancel/secondary-heal input replay is recorded separately.
Android version code 4 exported without engine/script errors; APK CRC, embedded
Barlow license, payload hashes and signing-certificate continuity verified.
SHA256: 21E55B169638C29CCD665862EB9699C63345D54670CA333BF269A793A40B96D9.

## Latest — mobile fullscreen, frontend and fonts, 2026-11-05

Mobile v0.3 expands aspect ratio, enables edge-to-edge/immersive Android mode and
avoids applying desktop window mode settings on mobile. New artwork-backed
full-screen frontend separates startup and pause utilities, preserves campaign
slots/overwrite checks, and supports font scaling. Source Sans 3/Cinzel fonts and
OFL notices bundled. Settings/dialogs respect safe areas; keyboard rebind/fullscreen
switch hidden on mobile. Duplicate fingers cannot start duplicate attack gestures.
482 assertions PASS, targeted failing-before/passing-after layout probe and native
wide/tablet/large-text/menu/settings/gameplay captures PASS. Touch replay verifies
menu and secondary healing. Engine remains pinned at Godot 4.7.2.
Phone-specific bugs remain unverified without a reproduction; no device FPS claim.
See docs/MOBILE.md for behavior, references and verification limits.
Android v0.3 export, signature continuity, payload manifest and APK CRC verified.
Both font licenses are embedded in the APK. SHA256:
1AA4060D464C2853A8026B8BD91D5E796A213C9364569A752E8179EBC76653DD.

## Latest — four-button mobile controls, 2026-11-05

Thirteen touch targets reduced to exactly four: Attack (tap light/hold heavy),
Dodge, Guard and contextual Use/Flask (hold for pause menu). Full joystick tilt
runs; attacking selects a visible nearby target when unlocked. Journal, manual
flask, Jump, targeting and companion order actions moved into the pause menu.
Combat rules and desktop bindings retained. Version code 2 can update the prior
Android package using the existing debug key; prior APK retained separately.
479 assertions PASS; native touch preview verifies movement, hold-to-menu and
one-flask healing after resuming from the secondary menu.
See docs/MOBILE.md for the updated scheme, build evidence and device-test limits.
Final APK SHA256: 9E083235B9F4DE34E975A2A37E80BE5664561F4ED8BFE36D0DB6E24357F334A4.
Export completed without engine/script errors; archive CRC, six payload hashes
and matching signing certificate with the previous APK verified.

## Latest — Android mobile preview, 2026-11-05

Added multitouch movement, camera and thirteen action targets; named InputMap
adapter retains existing combat authority. Held actions release on pause/focus
loss. Android Back pauses. Larger scrollable menu targets, touch hints, display
insets, landscape and a lighter mobile rendering profile are implemented.
Separate debug-signed ARM64 Android APK is exported under build/android/.
471 automated assertions PASS; native Windows touch-preview captures inspected.
Details, installation and remaining physical-device acceptance: docs/MOBILE.md.
No actual Android FPS/device-playthrough claim and no iOS package. Existing
Windows packages and saves retained; Android saves are local to that installation.

## Latest — villain models, 2026-11-05

Four ordinary enemy profiles and all five bosses now use detailed hostile models.
Licensed CC BY 4.0 Strong Knight (DJMaesen) and Fox (Alexei Ostapenko) sources
provide armor and canine anatomy; authored robes, skulls, antlers and weapons
differentiate the remaining enemies. Source and modification credits accompany
the package and appear in game. Presentation poses are procedural, not imported
skeletal animation clips. Combat, collision authority and save schema retained.

465 assertions PASS. Native lineup, closeup and actual village/crypt captures
inspected; final export has no engine/script errors. Six payload hashes verified
in folder and ZIP. Play-Villains.cmd / build/windows-hostiles/ contains the update.
PCK SHA256 F8E95E54752F69F6DEB9DD6C2B28938B7DCC8B42560A366CDFC23BD20802FAD7.
Details: docs/testing/hostile-models.md. Earlier builds and player saves retained.
No current-build FPS claim: the user's older village game remained open, so no
competing benchmark was run. Human combat/camera acceptance remains pending.

## Latest — detailed village pass, 2026-11-05

Owner supplied a moonlit half-timber village reference. Play-Village-Detail.cmd /
build/windows-village/ now has eleven timber/plaster buildings with bracing,
shutters, canopies, gables, curved slate roofs and chimneys; cobbled streets, square
well, radial mill wheel, slatted shortcut gate, warm torches and full-moon lighting.
PBR maps are licensed CC0, provider-hash verified and credited. Existing quests,
enemy placements, interaction points and save schema retained. Exteriors only.

Clean import and 460 assertions PASS. Added connected story-route, canopy-camera
collision and timber-transform regression checks. Native street/square/mill/HUD
captures inspected and completed cleanly. Separate Windows export/manifest PASS.
PCK SHA256 2090BBC807FA6F740B395CDDA60070AFE03C98696AED523CA118E6E25610228E.
Details and performance evidence: docs/testing/village-detail.md. Earlier packages
and saves retained; actual opening film included. Full human map/combat/camera
acceptance and final visual quality remain open; this is a reviewable art increment.
Native exported route completed twice, cold and same-cache: village combat about
119–120 mean interval-derived FPS at actual 2880x1620. Transition stalls persist:
2.654 seconds first run, 1.445 seconds repeat. Stable-play percentiles do not erase
the load hitch; loading still needs a targeted profile. Raw data retained separately.
Folder and ZIP manifests verified. No broad FPS or hitch-free claim.

Opening film follow-up: native source playback passed. External-script export probe
was inconclusive (80-second timeout); normal app menu verified, new-journey movie
UI acceptance interrupted by the owner's village request. No export movie-handoff
pass is claimed. See docs/testing/opening-film.md for exact evidence.

## Latest — actual opening film, 2026-11-05

Owner requested an actual video instead of the single-painting/text opening.
Play-Film.cmd / build/windows-film/ now plays a 30-second 720p/24-fps prerendered
3D movie: citadel curse, expedition march, defeat and survivor at camp. Includes
original atmospheric audio and burned-in subtitles. Skip/Escape and normal end
return through the existing safe camp handoff; Continue bypasses the film. No
static image is used by the active opener. Character animation remains procedural
and prototype quality; this is not a finished high-end cinematic.

Clean import and 457 assertions PASS. Native source playback verified decoded
moving frames, advancing time, normal movie completion and memory-only camp handoff,
exit 0. Full-media decode and audio signal checks pass. Separate Windows export
includes the movie, credits and player script; manifest hashes verified. PCK SHA256
4E1B6A13E4E6D36B749DF2427FB827E6AC6D9C05927D31A8E89C9EF854290EC6.
Evidence/provenance/limits: docs/testing/opening-film.md and assets/cinematics/README.md.
Earlier forest build and saves retained. No unrelated gameplay/balance changes or
new full-game performance claim. Export playback check: .tools/movie-export-check/.

## Latest — forest opening increment, 2026-11-05

Owner selected an animated backstory and a primarily forested connected world,
using the generated painting as the visual target with more complex forms. First
increment: Play-Forest.cmd / build/windows-forest/ (previous builds retained).
New Journey plays a skippable 27-second animated 2D painting with three subtitle
beats, then starts at the expedition camp. Continue skips the intro. No narration
or soundtrack yet. Starting refuge geography now includes a 136 x 224 m woodland
road, chapel, shrine, rocks, pines/ferns and distant citadel. Existing persistent IDs,
quest rules and save slots retained; village return arrives at the north road.
Later regions still retain their earlier layouts. This is not yet a giant seamless
map or visual parity with the painting. Direction: docs/forest-world-direction.md.

Clean import and 457 assertions PASS; new tests cover intro Next/Skip/load bypass,
spawn support, unobstructed road, actual navigation/travel/return and bounded canopy
geometry. Native images inspected. Export/manifest checks pass. PCK SHA256
CEC3A6E9280F18079EBF92992D0D78AB6CA1EC064F91DACA38D0A8B87BC8D07A.
Native final build was observed in camp gameplay; user took input, so further UI
control stopped. Manual intro click sequence and full route/quit/relaunch remain.
Early capture sessions generated frames but required stopping, not clean exit.

Measured geometry regression and correction: woodland stage improved from 33.91
to 112.28 mean callback-derived FPS at actual 2880x1620 with shadows/VSync on.
Final scripted exported route completed cleanly: p95 9.328 ms, p99 9.976 ms,
worst 325.242 ms including transition; RAM peak 1.09 GiB, draw-call peak 1232.
No blanket FPS claim: power/background activity uncontrolled, assisted scripted
route and full later-region coverage pending. docs/testing/forest-opening.md has
hashes/data/limits. No old performance measurement substituted for this build.

Next: owner composition feedback; camp tent camera obstruction/collision, denser
natural root/canopy forms and detailed story buildings; village/region connections,
audio/narration, production character animation and full manual campaign acceptance.
Controller remains unsupported. No purchase or public distribution performed.

## Seven-area acceptance audit — 2026-11-04

Audited the realistic candidate before broad improvements; no gameplay/art changes
in this audit. Full findings: docs/testing/acceptance-baseline-2026-11-04.md.
Clean import and 445 assertions PASS again. A single native exported workload
completed: 118.93 mean interval-derived FPS, p95 9.387 ms, p99 10.380 ms, worst
266.475 ms, peak working set 1.05 GiB. Actual rendering was 2880x1620, not 1080p.
Earlier 8.7-second hitch did not repeat; cause remains unproven. Raw report and
process data preserved under docs/testing/data/acceptance-baseline-*.json.

Direct app launch, new Journey 3 in an empty normal-APPDATA slot, Refuge rendering,
focus-loss pause, settings scrolling/return and journal scrolling/return observed
through Computer Use. Existing saves not overwritten. Folder and ZIP payload
hashes match the manifest. Ordinary CMD launcher reliability, save-and-quit/relaunch,
full clean-start campaign and clean-machine delivery remain unverified. UI input
was detected during review; no further app input issued. This is a development
candidate, not an accepted release.

Confirmed improvement priorities: journal reveals all chapters/finale immediately;
essential Back actions are below long scroll content; hero has rigid procedural
motion and bosses remain primitive; no actual music/region ambience; investigate
transition hitch and render-resolution controls. Preserve medium combat pace and
measure actual fight attempts before global HP/damage tuning. Manual camera,
companion, audio and whole-campaign acceptance still open. Controller unsupported.

## Latest candidate — realistic assets, 2026-11-04

Launch Play-Realism.cmd; separate export build/windows-realism/ and archive
build/Last-Light-windows-realism.zip. Previous builds and player saves preserved.
This section supersedes older art/build statements below; historical milestone
evidence is retained.

Installed licensed free Poly Haven fortress modules, six mossy rocks, fallen trunk,
castle door, ground and metal PBR maps. Active player now uses Andy Woodhead's
credited CC BY 4.0 knight from the public AFK sample; adapted static mesh with
procedural limbs, not production skeletal animation. Added textured stone surfaces,
smooth pointed stone arches and region-specific environmental placements. Full
provenance and modifications are in assets/vendor/ and docs/ASSET_CREDITS.txt;
credits ship beside the executable. No paid assets purchased. Research and engine
compatibility distinctions: docs/realistic-asset-research.md.

Checks: clean import and 445 assertions PASS; final native Vulkan captures inspected
(.tools/review/realistic_*.png), clean capture exit. Separate Windows export succeeded
and every manifest hash verified. Native exported scripted workload completed, but
contains an 8.7-second refuge hitch and concurrent second-process startup; performance
acceptance remains open. See docs/testing/realistic-performance.md for raw data,
exact build hashes and inconclusive attempts. This is not a stable-FPS certification.
Independent offscreen 120-frame boot exceeded 60 seconds with no engine error;
ordinary launcher startup is not verified and needs visible review/diagnosis.

Remaining: clean single-instance startup/transition profiling, detailed NPC/boss models,
skeletal combat animation, richer terrain/lighting/composition, and human campaign,
camera and combat acceptance. Refuge has the fullest asset pass; later regions are
partially dressed. This remains a playable work in progress, not a finished photoreal
environment. Implementation evidence: docs/testing/realistic-assets.md.

Stage: M0–M10 implemented locally as graybox milestones. Ashen Peaks, Iron Warden and Forge Seal lead into a playable Eclipse Citadel forecourt. Human slice/companion/chapter review remains pending. Medium combat pace retained.

Engine: Godot 4.7.2.stable.official.ed1daf0bf standard Windows x86_64, verified 2026-11-03. Mobile renderer graphically launched on NVIDIA RTX 3050 Ti Laptop (Vulkan 1.3.242). Portable engine is excluded under .tools/. No Git repository existed; no commits or pushes made.

Implemented: real boot scene, start/pause/resume/reset/quit/death-retry UI, primitive knight, hand-authored training courtyard with ramp/jump blocks/camera corner/open ledge, camera-relative movement, sprint/stamina, jump, grounded dodge and timed invulnerability, sphere collision camera, focus-loss pause and fall reset. M2 adds light/heavy sword attacks with continuous angular sweeps and per-swing claims, frontal blocking/guard break, stagger, healing/interruption, visible-target lock/cycle and target cleanup, one telegraphed soldier, lantern rest/reset, resource HUD and original synthesized short audio cues. Menus clear buffers and suppress initial gameplay ticks. The courtyard is a developer training area, not the campaign refuge.

Checks: Test.ps1 clean headless import and real M0/M1/M2 rule/runtime assertions PASS. Includes real hostile sword damage, one-hit uniqueness, attack costs, block/guard break and following hit, dodge windows, heal completion/interruption, enemy telegraph/strike/recovery, target lock/death removal, checkpoint rejection during combat, death cleanup and full retry. Native graphical launch PASS on Mobile/Vulkan. Computer-use visual smoke verified menu/start, camera distance while paused, HUD spacing, relocated lantern text and mouse-triggered sword animation with stamina 100→85 and ATTACK status. Keyboard injection was inconclusive; human combat/keyboard/lock/block/audio review still required. Details: docs/testing/m2-combat.md. No measured performance, gamepad, Windows standalone export or campaign verification.

Run: Play-Build.cmd for exported campaign with existing local saves; Play-Village.cmd for source campaign; Play.cmd for preserved training. Standalone folder build/windows/; ZIP build/Last-Light-Windows-Slice.zip. Verification: Test.ps1; rebuild: Build-Windows.ps1. Launchers redirect APPDATA into .tools/userdata for their own processes only.

Current limitations: primitive art/procedural motion/synthesized cues; no rig animations, hit-stop, gamepad or deeper Blackwood chapter. Lyra now exists as a working companion after her introductory scout quest. Full human exported playthrough, sound/camera/navigation comfort and art-direction review remain pending. No complete campaign or public release claimed.

M3 additions: three save slots, load/new with overwrite confirmation, save-and-quit/window-close handling, validated version-1 JSON, previous known-good backup and corrupt-primary recovery, dirty-session retry, rank/XP/shards, first-training-victory reward exactly once, small repeatable respawn rewards, rank maximum-HP gain, sword tier upgrades at anvil, equipment screen, separate training-seal interaction and physical passage into a walled training alcove. All training IDs are separate from campaign geography/bosses. Runtime stats and passage derive from campaign state. Unsupported future versions remain intact; campaign-region saves are rejected by the training scene instead of silently loaded into the wrong world.

M3 evidence: Test.ps1 clean headless import and rule/runtime/Windows-file checks pass; see docs/testing/m3-progression.md for exact coverage and latest assertion count. File tests write unique .tools/test-saves subdirectories; runtime tests use in-memory slots. Actual graphical M3 launch and saved reward HUD observed. Computer-use stopped on user input/physical Escape; no further UI input issued, and isolated review process stopped. Three-slot UI, overwrite dialog, equipment layout and full human quit/relaunch route are not visually certified.

M4 additions: separate authored refuge and village region instances; safe transitions preserving old area until target/navigation readiness; village lantern/recovery; east/west routes, square, mill and graveyard; three Resource-based enemy profiles in five encounters with NavigationAgent3D movement, LOS/memory/leash; Oren rescue/conditional dialogue/refuge forge upgrade; optional family token/memorial quest; north-side shortcut. Campaign saves are separate from training. Per-actor health never mutates shared Resource definitions.

M4 evidence: clean Test.ps1 import and 129 assertions PASS. Checks cover full controller route through rescue/dialogue choice, duplicate-reward rejection, token return, forge, checkpoint/reload/death, absent captive/present resident, actual NavigationAgent-driven movement, path detour and shared-data isolation. Native Vulkan launch and four actual rendered images inspected: refuge, village, campaign menu, journal. No interactive human playthrough or performance certification claimed. Details: docs/testing/m4-village.md.

M5 additions: crypt arena; dormant/triggered encounter and physical barrier; 420-HP Gravedigger with sweep/slam/advancing grab; single half-health phase change and localized delayed ground burst; boss health HUD; complete loss/reset and victory/reload path; atomic 180-XP/80-shard reward once; explicit Burial Seal action; derived village ward/floor change; separately loaded Blackwood entrance and return with chapter-one completion. Existing M4 campaign saves remain compatible.

M5 evidence: clean import and 164 assertions PASS, including M0–M4 regression plus full boss/seal/forest integration, phase/telegraph/dodge behavior and persistence boundary between victory/seal. Native Mobile/Vulkan capture exited 0 without errors; actual slam, burst and forest renders inspected. Automated renders/tests do not establish a human-played boss victory, camera comfort, audio quality or performance. Details: docs/testing/m5-gravedigger.md.

M6 additions: validated independent settings.cfg, remapping/conflict/default controls, current-key hints, camera sensitivity/invert, scalable text and scrolling panels, backed resource/objective HUD, four volume buses, bounded damage/tempo assists, low shadows/fullscreen, credits and original icon/cues. Real Windows x86_64 release EXE/PCK exported with matching templates, bundled engine/font/library notices, player README, SHA-256 manifest and 38 MB ZIP. Play-Build.cmd uses existing local saves; no files migrated/reset/published.

M6 checks: clean import and 186 assertions PASS. Native settings/menu/HUD renders inspected at 100/150% text after correcting anchored panel offsets. Export completed; independent release boot and native 60.13-second scripted workload executed. P95 wall interval 9.519 ms, p99 10.430 ms, worst startup frame 255.219 ms; observed process working-set peak 564.3 MiB. Actual texture 2880×1620 despite 1920×1080 logical window, VSync enabled. This is a scripted/offscreen workload with HP assistance, not a human acceptance run. Exact limitations/hash/data: docs/testing/m6-performance.md; build/settings evidence: docs/testing/m6-presentation-build.md.

M7 additions: speak/secure trail/recover satchel/explicit Join quest; one-time 40-XP/20-shard recruitment and active selection; rebindable follow/hold; one NavigationAgent-based Lyra, limited ordinary-enemy assistance, no friendly fire or boss targets; hostile companion damage/downed/checkpoint recovery; safe stuck/out-of-bounds suspension; crypt waiting and allowed-region reconstruction. NPC/follower representations derive from campaign state. Legacy controls keep C remaps with an unused fallback for the new command.

M7 save contract: v1 reads unchanged; first new companion mutation copies state to schema two, backed by the existing known-good save protocol. Version-two recruitment/satchel/quest/reward consistency validates; older readers reject new schema rather than overwrite it. No player slots reset or copied by automated testing. See docs/adr/0003-companion-state-and-save-v2.md.

M7 checks: Test.ps1 clean import and 230 assertions PASS. Native actual quest/follower/downed renders inspected. Tests exercise actual movement, hold/resume, combat, duplicate rejection, safe recovery, crypt exclusion/return, save reconstruction/version promotion/backup and legacy control fallback. Windows EXE/PCK/ZIP refreshed; manifest PASS and isolated native 120-frame boot exit 0 with empty error log. An external-script route probe was inconclusive/stopped; full exported companion playthrough remains pending. M6 performance report identifies the older PCK; it is not a measurement of the new companion workload. Details: docs/testing/m7-companion.md.

M8 additions: expanded authored forest, watchtower detour/hollow/root shrine, forest lantern and north-side shortcut; 500-HP Thorn Beast with telegraphed lunge/sweep and punish windows; durable one-time 240-XP/110-shard reward, separate Root Seal, forest/refuge feedback and unlocked Order forecourt/return. Lyra waits outside the grove. Schema three retains v1/v2 reads and known-good backups. Old navigation is parked during transitions so overlapping previous-region geometry cannot satisfy readiness.

M8 checks: Test.ps1 clean import and 271 assertions PASS. Actual native forest/boss/forecourt renders inspected. Windows EXE/PCK/ZIP refreshed, manifest verified and isolated 120-frame native boot exited 0 with empty error log. No M8 FPS claim; M6 benchmark remains tied to its older PCK. See docs/testing/m8-blackwood.md and docs/adr/0004-blackwood-save-v3.md.

M9a additions: expanded Order barracks/collapsed courtyard/memorial hall with three sentries, expedition record and explicit Cael recruitment; 50-XP/25-shard reward once; actual Order checkpoint/recovery; one selected companion with identity-specific appearance/stats, switching through journal/dialogue and waiting refuge NPCs. Cael follows/holds, assists ordinary combat and recovers from downed state. Schema four validates new progress while retaining v1/v2/v3 reads and backups.

M9a checks: Test.ps1 clean import and 303 assertions PASS; native quest/record/companion renders inspected. Windows EXE/PCK/ZIP refreshed; manifest verified and isolated native 120-frame boot exited 0 with empty error log. No new performance or human route certification. Details: docs/testing/m9a-cael.md and docs/adr/0005-order-companions-save-v4.md.

M9b additions: separate Commander sanctum with 600-HP mentor boss, alternating two-cut combo/thrust/overhead and explicit recovery windows; actual ward, companion waiting and loss/reset; 300-XP/140-shard reward once; separate Oath Seal, derived Order/refuge/Cael changes, northeast mountain ward and playable Peaks approach/return. Schema five validates this new progress, preserves v1–v4 playable saves and protects known-good backups.

M9b checks: Test.ps1 clean import and 339 assertions PASS. Native overhead/second-cut/mountain renders inspected. Windows EXE/PCK/ZIP refreshed; manifest verified and isolated native 120-frame boot exited 0 with empty error log. No new performance measurement or human route certification. See docs/testing/m9b-commander.md and docs/adr/0006-commander-oath-save-v5.md.

M10 additions: authored western mine/two plateaus/railed gorge bridge, three ordinary encounters, service bar/return path and Peaks lantern; 720-HP Iron Warden with telegraphed sweep/local slam and recovery windows; 360-XP/160-shard reward once, separate Forge Seal and four-seal citadel ward; playable citadel forecourt/return and chapter-four completion. Companion bridge traversal, guardian waiting and checkpoint fall recovery are exercised. Schema six validates new facts/recovery while retaining earlier playable saves and backups.

M10 checks: Test.ps1 clean import and 375 assertions PASS. Actual native bridge/mine/slam/citadel renders inspected. Windows EXE/PCK/ZIP refreshed; manifest verified and isolated native 120-frame boot exited 0 with empty error log. No new FPS claim or human route certification. Details: docs/testing/m10-peaks.md and docs/adr/0007-peaks-save-v6.md.

M11 additions: citadel gatehouse/prison/ritual approach and lantern; optional jailer/rescue/reward with refuge survivors; 780-HP Maldrek with swept orb, marked ground and close burst, one half-health phase change and at most two shades/three spells; victory cleanup and finite 500-XP/250-shard reward; explicit artifact confirmation, save-failure retry before ending/credits, restored refuge and continued peaceful exploration. All ordinary campaign encounters stop respawning, while optional quests remain completable. Schema seven validates completion and refuge recovery with earlier playable saves/backup protection.

M11 checks: Test.ps1 clean import and 417 assertions PASS. Actual native wizard phase-two, ending and restored-refuge renders inspected. Windows EXE/PCK/ZIP refreshed; manifest verified and isolated native 120-frame boot exited 0 with empty error log. Real-file ritual failure/retry is covered. No current performance or human campaign certification. Details: docs/testing/m11-finale.md and docs/adr/0008-final-ritual-save-v7.md.

M12a additions: journal map for travel only between activated, unwarded campaign lanterns; source proximity/combat/action guards; actual safe arrival/resource/follower recovery and destination persistence, with completed journeys retaining refuge reload. Campaign menu/window names and dialogue scroll reset polished. Export supports a checked build subdirectory and generates notices/manifest/ZIP there, preserving the primary M11 build while it is open.

M12a checks: Test.ps1 clean import and 433 assertions PASS. Native map render at 150% text inspected. Separate windows-preview EXE/PCK/ZIP exported; preview boot and manifest verified. Existing player slots unchanged. See docs/testing/m12a-lantern-travel.md. Primary M11 export remains available through Play-Build.cmd; current preview uses Play-Preview.cmd.

Owner-directed art/UI pass: generated limestone base color (built-in imagegen, prompt/provenance recorded), original articulated knight mesh and armor/shield/sword/cape; reusable pointed arches/columns/spires/lanterns/bare trees plus instanced paving/grass/rubble. Refuge receives the first full dressing and other regions selected kit props. Cyan lights, non-volumetric fog and original storm sky; compact HUD, separate objectives/prompts/notices and framed serif menus preserve controls/text scaling. Four static GLB model exports were read back successfully under art_exports/. Earlier NPC/boss models still need individual passes.

Art evidence: clean Test.ps1 import and 441 assertions PASS. Native refuge/menu/knight/150% HUD/journal renders inspected. Separate windows-art package exported, independent EXE/PCK boot exit 0 and manifests verified. Final 60.184-second exported workload on RTX 3050 Ti: p95/p99 wall interval 9.076/9.869 ms; worst startup 215.901 ms, sampled working-set peak 811 MiB. Actual render texture 2880x1620, offscreen scripted workload with restored HP; not human/FPS certification. See docs/testing/dark-fantasy-art.md and dark-fantasy-performance.md for raw data, hashes and limitations. Existing saves untouched.

Next: owner review of refuge/knight/UI direction before extending full art to every region/actor; profile load hitches and architecture batching; full human clean-start campaign acceptance remains open. This is an improved art preview, not a finished production release.


0.5.3 delivery update: owner explicitly approved Gofile upload; completed at https://gofile.io/d/h78Ov8TR . Remote file name, size and MD5 match the local APK. Earlier upload block resolved.

0.5.4 delivery update: owner authorized upload; completed at https://gofile.io/d/3g11f8Wj . Remote name, size and MD5 match local APK. Earlier upload block resolved.

0.5.5 delivery update: owner requested the APK; authorized Gofile upload complete at https://gofile.io/d/TzVqXwSO . Remote file name, size and MD5 match local release. Earlier pending-upload status is resolved.

0.5.24 delivery verification: 589 assertions PASS; 93 compiled scripts / 162 character resources identical across platforms; packaged film selection/bytes, Android signatures and both package CRCs PASS. Isolated desktop playback median/p95 8.323/15.239 ms, completes in 29.987 s. Windows-v0524 and LastLight-0.5.24.apk are local; Play-Latest selects v0524. No 0.5.24 third-party upload performed. Owner-approved 0.5.22 phone link remains https://gofile.io/d/guaaJRVE .

0.5.25 delivery: 589 assertions PASS, native packaged film/boot PASS, platform script/model parity and film selection PASS, APK signatures and APK/Windows ZIP CRC PASS. Latest launchers select windows-v0525; named APK LastLight-0.5.25.apk ready locally. Caption layout now runs on resize rather than every frame, with natural completion rechecked. Evidence: docs/testing/v0525-cinzel.md.
