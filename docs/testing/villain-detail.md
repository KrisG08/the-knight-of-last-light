# Villain appearance detail — 0.5.6, 2026-11-06

Central hostile model builders now apply the pass to every actual profile and
boss, including regional guards/jailer and summoned Bound Shades.

| Type | Visual change |
| --- | --- |
| Hollow Villager | Woven work apron, rope straps, stitching, open cowl and broad improvised cleaver. |
| Fallen Soldier | Field tabard, crossing leather strap/buckle, collar fittings and plated attacking arm. |
| Grave Hound | Reinforced collar and fitted brow plates; original textured muzzle/dentition retained. |
| Bound Shade | Blue-gray cloth, narrow hanging panel and a glyph-marked dark face mask. |
| Gravedigger | Open cowl, brighter sculpted brow/nasal details, folded burial cloth, bone collar, belt pouches and hanging lantern. |
| Thorn Beast | Existing antlers/spines complemented by fitted back armor and brow details, adjusted after native inspection to avoid detached ribs/extra fangs. |
| Fallen Commander | Heraldic hanging cloth, gold crest/inlay, strap/buckle and plated attacking arm. |
| Iron Warden | Layered tassets, furnace backpack/vent collars, heavy arm plates and chamfered striking faces on the hammer. |
| Maldrek | Open ritual cowl, layered purple vestments, shoulder fittings, crown/halo, ornaments and staff collars. |

Cloth geometry has finer folds and cached reusable meshes. The original woven
material uses filtered thread detail and smooth stain variation, with no animation
clock running independently of game pause. Static fittings are baked into a small
number of meshes per material and shared by matching actor types. Normals use
inverse-transpose transforms, and texture UVs are retained. Existing imported
armor/fur source UVs and material provenance are preserved.

No new external assets or dependencies. Existing credited DJMaesen and Alexei
Ostapenko bases remain; new fittings/cloth/shader are original code-authored work.
This is a presentation pass, not a new fully rigged production character pack.
Procedural movement and partition seams still require animation refinement.

## Verification

Godot 4.7.2, Mobile renderer. Campaign/presentation suite: 542 assertions PASS.
New checks instantiate all nine real actor types and verify fitted appearances,
batched geometry normals/UVs; existing checks retain one collision shape and the
same actor collision layers, valid imported indices, state telegraph and pause.
Native presentation captures include both lineups and individual portraits for all
nine types. Village guard and crypt Gravedigger windup were captured in actual
regions; key portraits/crypt view inspected and floating/hidden fitting positions
corrected. No human combat playthrough or physical-phone FPS acceptance claimed.

Evidence: .tools/villains-detail-{import,tests,capture}.log and
.tools/villains-encounter-capture.log; .tools/review/hostile_*.png and
hostiles_{ordinary,bosses}.png. The lineup is a separate presentation stage and
must not be described as a gameplay screenshot.

## Delivery evidence

Windows build/windows-v056 exported, manifest hashes match and packaged headless
boot exited 0. Play-Latest, Play-Session and Play-Villains now route to v056 with
the same .tools/userdata path. Older packages are retained.
Android package org.lastlight.knight code11 / 0.5.6-villain-detail exported,
signature and ZIP CRC PASS. Certificate SHA256 remains
03bb1a985f9e91df8278d88bfe1139c37fbb039621b2e8520a53d5e3450b72d8.
All 83 compiled game scripts are byte-identical between Windows and Android.
Named APK: build/android-releases/LastLight-0.5.6.apk, 373860823 bytes.
SHA256: 782F209ED687E1C3180CDBD0C77512FC9E4B86A8173F8F74AE7DA7054F9E5F94.
MD5: FB436E0A757FAE5DC176E2355931FBBB.
No 0.5.6 Gofile upload yet. Prior automatic-review decisions required approval
for each new APK payload; ask owner before sharing this version externally.
