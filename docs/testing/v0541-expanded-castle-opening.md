# Expanded-castle opening — v0.5.41, completed 2026-11-09

## Implemented

The new-journey opening is re-rendered from the current actual citadel, including
the enlarged forecourt, keep, towers and terraced ascent. A moving 2.6-second
exterior establishes the castle, then cuts into Maldrek's casting performance on
the real upper terrace. The staff uses the current cut-crystal geometry and moves
with the casting hand. Spell veins, sparks and local light use violet rather
than the previous green. The camera approaches during charge and withdraws on
release. The remaining expedition, collapse and survival shots retain their
30-second timeline and localized caption boundaries.

Art/provenance and reproduction: [source notes](../art/opening-expanded-castle.md),
`assets/cinematics/README.md`. No new external art, footage or soundtrack.

## Actual verification

- Godot **4.7.2.stable.official.ed1daf0bf**, Forward Mobile, RTX 3050 Ti.
  Native Movie Maker produced 1802 frames / 1920x1080 at 60 fps. The first
  30 seconds were encoded, matching the existing score and caption timing.
- Preview stills reviewed for exterior, casting and release. Actual encoded
  exterior extracted and inspected: `.tools/review/opening-v4/encoded-castle.png`.
- Desktop **1920x1080 / 60 fps**, phone **1280x720 / 60 fps**, both 30.00 s,
  Theora/Vorbis. Both streams completely decode without corruption errors.
  Encoder/decode logs: `.tools/movie-render/{encode,decode}-v4-*.log`.
- Native full new-journey flow **PASS** with the desktop source, touch/mobile
  source and final Windows PCK. Tests verify changing decoded frames and elapsed
  playback, automatic completion, restoration to camp and memory-only persistence.
  `.tools/movie-render/playback-v4-{desktop-source,mobile-source,desktop-package}.log`.
- Final package screenshot, including actual playback controls and enlarged
  castle: `.tools/review/opening-v0541-package/movie_playback_castle.png`.
- The review harness initially attempted to write into packed `res://.tools`.
  It now accepts an absolute capture directory and checks screenshot-write errors;
  final packaged playback completed with no such errors. Game runtime unchanged.
- Platform parity **PASS**: each platform contains the exact current appropriate
  opening encode, with the desktop encode excluded from Android; 112 compiled
  game scripts, 162 character resources, seven catalogs/config files and retained
  material/menu effects match. `.tools/platform-parity-v0541.log`.
- Android code **46**, name **0.5.41-expanded-castle-opening**. Signature retains
  the existing certificate; APK CRC, 16 KB alignment and Windows manifest **PASS**.
  Receipt: `.tools/opening-v0541-release-hashes.json`.
- Temporary desktop viewport overrides used only during offline rendering were
  restored byte-for-byte before the version bump. Owner saves were not loaded.
- Owner specifically authorized removal of duplicate ZIPs v0518, v0519 and v0520
  for working space. Their extracted versions and all existing APK releases remain.

## Deliverables and limits

`Play-Latest.cmd` selects `build/windows-v0541/LastLight.exe` with the existing
owner userdata path. Android: `build/android-releases/LastLight-0.5.41.apk`
(424,338,391 bytes). Desktop video: 96,731,720 bytes; mobile: 24,118,421 bytes.
MP4 review: `.tools/review/opening-v0541.mp4` (19,910,923 bytes).

Offline Movie Maker retained its earlier exit-only diagnostic (two ObjectDB
instances and one resource still in use). Rendering completed successfully;
encodes decode and final runtime playback logs are clean. Do not describe that
offline diagnostic as a clean render shutdown. The full unrelated campaign suite
was not repeated for a media-only change. No real Nothing Phone 3a performance,
frame-pacing/thermal acceptance or human full campaign playthrough is claimed.
The animation remains authored segmented motion rather than motion capture.
Owner subsequently explicitly authorized Android v0.5.41 upload to Gofile on
2026-11-09: https://gofile.io/d/1QmaRGax. Returned filename, 424,338,391-byte
size and MD5 `7f00bda42b57591bcd5a00adb206976c` match the local signed APK.
Private receipt: `.tools/android/gofile-upload-v0541.json`.
