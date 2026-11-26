# Hostile character source assets

Downloaded 2026-11-05 from the public sample files linked by https://afk.ai/samples.
That page identifies the authors/licenses and states these are simplified source
copies. Both selected samples are **CC BY 4.0**, not the noncommercial mech sample.
License: https://creativecommons.org/licenses/by/4.0/ . No author endorsement implied.
Original source files and SHA256/byte counts retained in manifest.json.
Original-author license metadata was also checked through Sketchfab's public model
API and retained in original-license-metadata.json; both records explicitly allow
commercial use with author credit.

## Strong Knight — DJMaesen

Original: https://sketchfab.com/3d-models/strong-knight-9d912e0fedb44b619fbd2a083bbf174f
Download: https://afk.ai/rig/samples/strong-knight.glb
Used as the armor/body base for Fallen Soldier, Fallen Commander and Iron Warden.
Changes: orientation, static limb partition, material tint/roughness, procedural
limb motion and additional crown, cape/armor details and authored combat weapons.
Source accessory dagger/maul meshes are omitted in favor of actual attack pivots.

## Fox — Alexei Ostapenko

Original: https://sketchfab.com/3d-models/fox-4e37c303f8a241aaa2511bd9f3019273
Download: https://afk.ai/rig/samples/red-fox.glb
Used as canine anatomy/fur base for Grave Hound and Thorn Beast, not represented
as a separately downloaded wolf. Changes: scale/proportions, static head/leg/tail
partition, desaturated fur shader and authored thorns, antlers and collar.

Both inspected files are static, with **no skeleton or animation clips**. The
adapter game/presentation/hostile_source_parts.gd keeps UV/UV2, normals and valid
compacted indices. Unused third UV/custom channels are removed. This is procedural
presentation of static parts, not production skeletal animation or retargeting.
No original source file is overwritten. NPCs and the player's model are unchanged.
