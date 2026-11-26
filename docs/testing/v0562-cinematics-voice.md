# Cinematics and five-language narration — v0.5.62

2026-11-21. Pinned Godot 4.7.2.stable.official.ed1daf0bf, Mobile renderer.
Native visual checks on the RTX 3050 Ti laptop. No Git repository/commit.

## Delivered behavior

- 37 authored narrative units, 185 localized clips: English, Bulgarian, Russian,
  French and Arabic. NPC prose, inscriptions, opening, wizard defeat and ending.
  Bundled Ogg playback, no microphone or runtime speech request.
- Independent Voice volume and opt-out, translated settings labels, score ducking,
  paragraph queue, close/skip/locale cancellation and explicit view ownership.
  Shop statistics, account fields, journals and legal credits are not screen-read.
- Forty-second opening from a new QHD/60 native render of current camp/castle art.
  Four longer story beats, moving cameras, casting, march, staggered falls and
  recovery. English subtitles are no longer baked into the video.
- Selected runtime opening: 1920x1080 / 60 FPS on both platforms, Theora q8.
  Menu: twelve seconds / 720 original frames, QHD desktop / Full HD phone, q10.
  4K menu layers stream raw RGB to avoid an extra lossy JPEG intermediate.
- Live wizard defeat: sixteen seconds, two voice cues, safe camera/control
  restoration. Defeat remains durable; the artifact still requires interaction.

Synthetic reading, not actor performance or facial lip sync. Russian uses the
working Svetlana voice for all speakers after Dmitry repeatedly returned no audio
for the same text. Owner explicitly approved sending only game narrative to the
Microsoft Edge synthesis destination. No account data or saves were included.
Client/tool dependencies remain outside exports. ADR 0019 records the boundary.

## Actual verification

| Check | Result / evidence |
|---|---|
| Import/parse and exports | Complete, no script errors in final export logs |
| Campaign, runtime, settings and presentation | **645 PASS**, v062-campaign.log |
| Source speech acceptance | **445 PASS**, v062-voice-source.log, before additional UI-route checks |
| Final native Windows PCK speech/UI | **461 PASS**, v062-voice-package-final.log |
| Native final wizard victory | **22 PASS**, v062-victory-package.log |
| Final native menu loop | **14 PASS**, menu-hfr-v062-native-desktop-final.log |
| Actual new-game opening in final Windows PCK | PASS, v062-opening-package.log |
| Source audio SHA-256 vs manifest | All **185 PASS**, 8,845,747 total Ogg bytes |
| Windows file manifest | All listed file sizes and hashes PASS |
| Android signature / alignment | v2/v3, established certificate and 16 KiB alignment PASS |
| Windows/Android parity | **128** scripts, **185** voice clips, **162** character resources, **12** locale/cloud files and shared media/shaders/catalogs PASS |

Logs and raw captures are in `.tools/review/`. Native voice tests actually open
Settings in every locale, operate the toggle/slider, open the NPC panel, verify
queue ownership and cancellation, and seek a real Ogg stream near its end to
check that completion starts the next paragraph while gameplay is paused.
Bulgarian and Arabic NPC captures were visually inspected. Final victory uses an
actual lethal knight sweep; both spoken cues and cancellation on finish pass.
The full opening check decodes moving frames, waits for automatic completion and
verifies a memory-only return to the authored camp. No owner save is loaded.

## Performance evidence and discarded takes

The QHD opening encode was too heavy for native real-time playback: only about
7.78 seconds advanced in 50.15 seconds. A repeat after closing two old QA sessions
still advanced only about 8.09 seconds in 63.38 seconds. This encode is excluded
from runtime and preserved in `.tools/movie-render/` with its source master.

The selected Full HD encode completed in **40.10 s** in the desktop touch-layout
test (median/p95 callback intervals **16.665 / 22.045 ms**, 2325 samples), and
**42.40 s** in the desktop test while other headless checks were running
(**16.665 / 27.216 ms**, 2172 samples). These are video checks, not game FPS or
physical-phone measurements; they do not establish zero stutter. The final PCK
new-game flow separately passed natural completion and camp handoff.

The JPEG menu intermediary softened detail and was discarded. Selected raw-RGB
menu first-frame SSIM against its raw target: **0.991843**, identical to the old
30 FPS encode's first-frame comparison. Exact-loop endpoint RMS: **0.0032153**.
These are narrow frame comparisons, not a whole-video quality score. Raw-RGB
delivery preserves the original layer detail; it does not invent photographic 4K
detail beyond the source art. Menu loop/pause/resume/resizing pass natively.

An early campaign test launched while movie files were being written was
interrupted and excluded; the final 645 PASS run used stable media. An initial
direct Movie Maker launch initialized at 720p and was interrupted/excluded. The
selected opening master initialized at 2560x1440, rendered 2402 frames at 60 FPS
in 4:59, and uses only the first 2400 frames. The render wrapper restored the
original viewport configuration. No temporary-frame or old-package deletion.

## Local deliverables and limits

- `build/windows-v0562/LastLight.exe` plus PCK; `Play-Latest.cmd` selects it.
- `build/android-releases/LastLight-0.5.62.apk`: **642320890 bytes**, versionCode
  **67**, same package ID and established signer as prior installs.
- APK SHA-256:
  `1E8D2E915F3976F47FD931FD48CFC574955CE7CC4E7627C7DE4B6D652C41DE59`.
- `.tools/review/opening-v5-bg-voiced.mp4`: local Bulgarian audio review copy.
  Gameplay captions remain native and selectable; this review is not an export.

Known pre-existing Android badging warning: unused adaptive themed-icon file
reference. Signing/alignment pass. No physical Nothing Phone 3a run, native-speaker
pronunciation acceptance, full human campaign or guaranteed sustained FPS claim.
No public upload, paid asset purchase, deletion or owner-save mutation. Next:
owner listening/volume review and real-phone playback/thermal checks.
