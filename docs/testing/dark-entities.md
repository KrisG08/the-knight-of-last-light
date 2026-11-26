# Passive non-animal entities — 0.5.9

Owner requested mythical entities beyond animals. Added a robed hovering wraith
at Blackwood (-28,0,-42), crowned stone sentinel at citadel (-15,0,-40), and
gargoyle on a four-meter decorative plinth at citadel (15,4,-40).

Wraith robe is a corrugated/torn curved mesh, with hood, recessed dark face and
fingers. Gargoyle has sculpted ellipsoid masses, horns and ribbed wing membranes.
Sentinel derives from DJMaesen's already credited CC BY 4.0 Strong Knight mesh,
with stone material override, original radial crown and staff. Original source
materials remain intact. Existing Poly Haven stone material remains credited.
This is procedural authored art, not a claim of photoreal asset quality.

All are Node3D visuals only, without health, damage receiver, collision,
interaction, rewards, quest state or AI. Wraith has a small local vertical idle;
entity roots stay fixed, and processing pauses with the game.

Validation: 548 assertions PASS, with all five creature/entity types covered by
the passive geometry checks. Seven native Forward Mobile captures completed
without script errors; final new entity images manually inspected after moving
citadel placements away from perimeter walls. Evidence:
`.tools/entities-tests.log`, `.tools/entities-capture.log`,
`.tools/review/fauna-blackwood-wraith.png`,
`.tools/review/fauna-citadel-sentinel.png`,
`.tools/review/fauna-citadel-gargoyle.png`.

No full campaign replay, phone playtest or performance acceptance claimed.

Windows v059 manifest verified and native executable headless boot exited 0.
Android code 14 / 0.5.9-dark-entities exported and signature verified. Platform
comparison: all 86 compiled game scripts identical. Build logs:
`.tools/v059-windows-build.log`, `.tools/android/v059-export.log`,
`.tools/v059-pack-parity.log`.
APK SHA256: `37D73B78DF633A44DC74E2369AF551071664C4C5E8136C2ACBF673152A7A1EEC`.
Named copy: `build/android-releases/LastLight-0.5.9.apk`. Not uploaded externally.
