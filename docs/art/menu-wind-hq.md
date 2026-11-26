# Higher-resolution menu films

The existing registered landscape, knight and foliage PNG layers are rendered
again with the original wind/cloud shaders at 3840 × 2160. No downloaded artwork
or new third-party assets are introduced. Source art provenance remains in
`menu-wind-v2.md` and `assets/ui/menu-wind/provenance.json`.

`tools/render_menu_hq.gd` streams 360 lossless PNG frames directly into FFmpeg,
avoiding a large temporary frame archive. Lanczos downsampling produces:

| Platform | Encoded resolution | Frame rate | Duration | Theora quality |
| --- | --- | --- | --- | --- |
| Windows | 2560 × 1440 | 30 fps | 12 seconds | 10 |
| Android | 1920 × 1080 | 30 fps | 12 seconds | 10 |

The platform exports contain only their respective menu video. The old 720p
movie remains in the source workspace as a fallback/reference and is excluded
from both new exports. Framing, grading, native moon/cloud animation and title
effects remain independent of the video resolution.

The original landscape is 1672 × 941; foreground assets are 1024 × 1536 and
1536 × 1024. Supersampling improves shader edges, compositing and compression
retention; it does not invent native 4K photographic detail. The Android encode
is deliberately Full HD rather than 4K to limit software video decoding work.
Physical-phone performance remains an owner-device check.

File sizes and SHA256 hashes are recorded in the movie manifest. Render evidence
and loop endpoint metrics are in `.tools/review/menu-hq-source/render.json`.
