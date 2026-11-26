# Product, pillars and scope

Owner revision, 2026-11-21: authored NPC conversations, narrative inscriptions,
opening captions, wizard victory captions and the ending receive localized speech
in English, Bulgarian, Russian, French and Arabic. Deliver bundled clips for
offline playback, with independent volume and an opt-out. This authorizes spoken
narration despite the original exclusion below; it does not add a voiced player,
microphone, runtime generation or compulsory network dependency.

Owner revision, 2026-11-07: Android is a supported preview target alongside
Windows. Optional online accounts and cross-device journey synchronization use
Supabase; offline single-player play remains available without an account.
Presentation supports English, Bulgarian, Russian, French and Arabic. See
ADR 0016 for boundaries and pending email-service acceptance.

## Binding pillars

- Single-player 3D third-person dark fantasy adventure.
- One knight protagonist; one evil wizard responsible for the central curse.
- Melee combat, exploration, equipment improvement and meaningful bosses.
- Connected world with sequentially unlocked regions, optional routes and backtracking.
- Gradual story discovery and growing friendships; useful NPC allies and companions.
- A final boss and an explicit curse-breaking conclusion.
- Owner-led incremental expansion of the story.

## Proposed creative direction

Working title: The Knight of Last Light. Kingdom: Veyr. Wizard: Maldrek. Names and lore are proposals. The knight is the survivor of a failed expedition. No character creator, class selection or voiced protagonist in the first release. Equipment offers playstyle differences.

The world is open inside linked handcrafted regions. This is not a seamless continent. Load one region and the refuge as needed, using diegetic passages and brief loading screens. Distant landmarks imply a larger world. Never market the prototype as an unlimited open world.

## Scope tiers

Technical prototype: boot/menu, third-person movement, camera, one sword attack, dodge, one enemy, health, death and restart in a test room.

Vertical slice: refuge plus Ashen Village region, checkpoint, three enemy archetypes, the Gravedigger boss, blacksmith rescue, one optional quest, inventory/equipment, durable boss reward, forest gate, return to changed refuge. Include a small playable forest entrance to prove the gate actually opens into a new area. A locked menu entry is not an implemented second region. Target 20–40 minutes of first-time play as a design aspiration; playtest it.

Full small campaign, only after slice approval: five regions including the citadel, four seal guardians and Maldrek, three recruitable allies, one active companion, curated equipment, ending and post-ending exploration. Target 3–5 hours if content capacity supports it; never inflate scope merely to meet duration.

## Explicit exclusions

Multiplayer, MMO systems, multiplayer networking, procedural continents, base construction, vehicles, mounted combat, underwater traversal, photorealistic character creation, fully simulated NPC schedules, branching campaign endings, extensive crafting, randomized loot affixes, full voice acting and mobile/console release.

Allow future design changes through small documented proposals; do not build speculative support in advance. Story and final production assets do not have to be authored before movement is playable.

## Product success

The player understands where to explore, can read enemy attacks, earns a satisfying first victory, sees a region change, recruits a memorable ally and can reload without losing progress. The final campaign succeeds only when the final battle, curse-breaking action and ending are actually reachable from a clean start.
