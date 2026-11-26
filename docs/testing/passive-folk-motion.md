# Passive folk movement — 0.5.11

Owner requested movement without interactions. Goblins, troll and dwarves now
walk out and back along short authored corridors with two-second endpoint rests.
Speeds: 0.4 m/s goblins/dwarves, 0.28 m/s troll. Maximum route length: 0.8 m folk,
1.2 m troll; route setup samples the segment against expanded authored obstacle
footprints, shrinking or rejecting blocked corridors. Current placements stay on
their original flat floor plateaus. This is authored ambient motion, not roaming
AI or navigation around dynamic actors. Folk do not collide with the player.

Four articulated limb pivots replace single static mesh batches. Torso and each
limb retain shared cached mesh/material batches, including on region revisits.
Arms/legs swing during steps; subtle arm idle continues during rests; dwarf hammer
is attached to the hand. Root turning follows the route. Game pause stops all
motion. No interactions, damage receivers, hostile membership, quest facts,
rewards or save schema changes. Animals and stone figures retain their old idles.

551 assertions PASS, no script errors: movement with articulated legs and bounds,
blocked corridor fallback, shared limb cache, pause, passive geometry, original
source materials and full regression suite. `.tools/folk-motion-tests.log`.
Native Forward Mobile capture verifies root movement across real rendered frames
for all five placed folk; all twelve scenery placements captured, plus five
walking follow-up images. `.tools/folk-motion-capture.log`. Goblin, troll and
dwarf walking images inspected. No production animation quality, full campaign,
phone playtest or frame-rate acceptance claimed.

Windows v0511 export and ZIP complete; native executable headless boot exit 0
and manifest verified. Android code 16 / 0.5.11-living-folk export, signature,
ZIP CRC and license inclusion verified. All 87 compiled game scripts match
across platforms. Logs: `.tools/v0511-windows-build.log`,
`.tools/android/v0511-export.log`, `.tools/v0511-pack-parity.log`.
APK: `build/android-releases/LastLight-0.5.11.apk` (384514837 bytes).
SHA256: `9A774715AE61FAA00DD71466D98783400AA5D0D3946CD665D3F3A416F925719F`.
Play-Latest now targets v0511, preserving old builds and saves. No external upload.
