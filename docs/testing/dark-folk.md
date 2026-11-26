# Dark folk — 0.5.10

Original procedural scenery models for goblins, troll and dwarves. No downloaded
assets or new external licensing requirements. Existing credited Art/Regalia PBR
materials reused; shared cached material batches reduce per-instance draw calls.
Skin normal maps generated locally from fixed-seed noise.

Placements: Blackwood goblins (12,0,-15), (14,0,-16); Peaks troll (25,0,-44),
scale 1.65; mine dwarves (-15,0,-10), (-15,0,-19). Existing dragon rock placement
retains its original mesh lookup order. No new collision, AI, interaction,
campaign facts, combat or rewards. Existing passive idle pauses with game.

Native Forward Mobile captures include all twelve placements, all five new
placements visually inspected. Capture script checks new folk root positions
against authored obstacle footprints expanded by 0.75 m. Logs:
`.tools/folk-import.log`, `.tools/folk-capture.log`, `.tools/folk-tests.log`.
Final images: `.tools/review/fauna-blackwood-goblin-0.png`,
`fauna-blackwood-goblin-1.png`, `fauna-peaks-troll.png`,
`fauna-peaks-dwarf-3.png`, `fauna-peaks-dwarf-4.png` in the same directory.

Art is visibly stylized/procedural. It does not meet photoreal character quality;
authored sculpted meshes, textures and full-body idle animation remain art work.
No phone playtest, full campaign replay or performance acceptance claimed.

548 regression assertions PASS, no script errors in final capture/tests.
Windows v0510 export/ZIP complete, manifest verified and native executable
headless boot exit 0. Android code 15 / 0.5.10-dark-folk signature verified,
ZIP CRC and attribution inclusion PASS. All 87 compiled game scripts identical
between Windows and Android. Logs: `.tools/v0510-windows-build.log`,
`.tools/android/v0510-export.log`, `.tools/v0510-pack-parity.log`.
APK: `build/android-releases/LastLight-0.5.10.apk`, 384510741 bytes.
SHA256: `C1CDF78C8B4F59F8FE09E194DF6A5BE862064D361C7A405AAF68EA02D6B797B2`.
Play-Latest now points at v0510; prior builds and player saves preserved.
No external upload performed for this APK payload.
