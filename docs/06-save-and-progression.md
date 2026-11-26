# Persistence, world progression and recovery

## Single source of truth

CampaignState holds character rank/experience, shards, owned equipment and upgrades, quest facts, recruited allies, active companion selection, activated checkpoints, boss defeats, broken seals, claimed finite rewards, claimed pickups, chapter and ending flags. Region access is derived from these facts. Session health/position is transient except safe checkpoint recovery data.

Each new campaign journey receives an independent save ID; the former three-slot limit is removed by the owner's request. Settings remain separate. Automatic save on ordinary victory, checkpoint activation/rest, recruitment, finite reward commit, boss defeat, seal break, successful equipment upgrade, region transition commit and campaign completion. Quit/background saves or retries durable changes and safe recovery location, not arbitrary active-combat transforms. On load, restore full health/stamina/healing at the checkpoint and reset ordinary enemies; their cumulative victory history persists. See ADR 0009 for schema-v8 history and library behavior.

No database, cloud or account required. Use validated JSON or equivalent explicit format under user://saves/slot_01.json etc. Settings under user://settings.cfg. Never serialize Node references, instance IDs, runtime hit sets or global scene paths.

## Snapshot schema

schema_version, content_version, slot_id, saved_at, campaign, character and recovery. Collections use stable IDs, sorted where useful. Character has rank, xp_into_rank, shards, weapon_id, weapon_tier, owned_item_ids and equipped_relic_ids. Campaign has fact sets, boss_defeated_ids, broken_seal_ids, recruited_ally_ids, reward_claim_ids, pickup_claim_ids, checkpoint_ids and quest_states. Recovery has region_id/checkpoint_id/spawn_id. Positions are optional bounded plain coordinates only for future migrations; initial load uses named safe spawn.

Treat a save as untrusted local input. Check types, limits, IDs, duplicate entries, enum values, finite numbers and internal consistency. Bound file size (initial 2 MB), collection lengths and string lengths. Unknown optional cosmetic IDs may be skipped with warning; missing required checkpoint IDs require an explicit safe fallback. Unsupported future schema never overwrites the original file. New Journey allocates a fresh ID and never resets the selected existing campaign.

## Crash-safe save protocol

One writer and monotonically increasing in-memory revision. Capture immutable snapshot → validate → write temp in the same directory → flush/close → validate temp → preserve last known-good backup → promote temp to primary using platform-supported replacement → verify/report outcome. Do not assume a cross-platform rename overwrites an existing file identically. Implement and test replacement behavior on Windows. Preserve primary/backup on errors. Recovery: valid primary, else valid backup with message; do not silently reset the campaign. Checksum can detect accidental corruption, not prevent tampering.

Persistent mutation and finite rewards are one logical transaction: DefeatBoss adds defeat fact, reward claim and items/XP together. The snapshot includes all of them. If writing fails, keep current session dirty, notify the player, retry safely; never apply the reward again when retrying. Do not leave an unearned gate unlock in a separate unrelated file. Resume from older backup may lose the last uncommitted action; explain honestly.

## Gate progression

gate.village_to_blackwood requires seal.burial.broken.
gate.blackwood_to_order requires seal.root.broken.
gate.order_to_peaks requires seal.oath.broken.
gate.peaks_to_citadel requires all four seal facts.
seal break requires its guardian defeated plus interaction eligibility. BossDefeated and SealBroken are distinct. All previous routes remain unlocked. chapter advancement is derived or updated atomically from these same facts; do not maintain contradictory chapter/gate copies.

Final artifact interaction requires boss.maldrek.defeated and four seals broken. CompleteCampaign sets campaign.completed and curse.cleansed, moves recovery to the refuge ending spawn and persists before credits. If saving fails, keep the player at the completed ritual with a retry path; never permanently lock progression behind credits.

## Migration and reset

Start at schema_version=1 and content_version=prototype. Future migrations transform a copied document sequentially, validate, then save with the original backed up. No imaginary migrations to versions that do not exist. Provide fixtures for valid, truncated, wrong-type, unknown-version, duplicate-claim and obsolete-ID data. Campaign reset is separate from resetting settings. Tests must use temporary save directories.
