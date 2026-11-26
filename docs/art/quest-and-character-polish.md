# Quest props and character polish — 2026-11-08

Original code-authored geometry in `game/presentation/quest_props.gd`: curved
leather scout satchel with flap, strap, buckle, stitches and parchment; hinged
family locket with tree relief and chain; carved memorial; metal crystal cradle.
Leather grain is an original spatial shader. Existing credited Poly Haven stone,
wood and metal normal maps are reused. No new external assets or paid services.
Static details merge by material and share cached meshes between regions.

The satchel and locket retain their existing stateful owner nodes and pickup IDs.
The memorial retains its interaction/collision node. Seal crystals remain intact;
their original hidden cube stays hidden. Presentation never grants quest progress.

Hollow Villager reuses the existing credited Oren artisan mesh as a corrupted
butcher; the survivor uses a separately tinted artisan variant. Bound Shade uses
the existing Maldrek robe mesh at 70% height with a violet material variant.
These are adaptations, not newly sculpted unique characters. Materials are
duplicated before tinting so named NPCs and the final boss retain their colors.
The passive troll adapts the detailed goblin at a larger, broader proportion;
the dwarf adapts the artisan with shorter, broader proportions and a fitted work tool.
Their existing named arm/leg pivots retain stroll and repair animation behavior.

Imported hostile right arms use render-only two-bone deformation and separate
weapon appearance nodes. Rest weapons meet the palm; attack appearance returns
to the existing authoritative combat pivot. Death disables live deformation for
the cinematic. Health, damage, timings, collision and progression are unchanged.
Weapons have beveled blades, smaller hammer/cleaver silhouettes, wood grain and
a cut crystal on the wizard staff. Lyra and Cael no longer use rectangular blades.
Reduced metal glare and bark detail improve existing imported enemy materials.

All eleven region inventories include visible individual meshes and batched
instances. Remaining untextured box candidates are inspected as fixture glass,
window/void backings, inscriptions or architectural trim; a BoxMesh alone does
not indicate an unfinished object. The inventory is not a claim that every model
has final production art. Source scans still have soft projection and some faceting;
animation remains the existing lightweight segmented rig, not motion capture.
