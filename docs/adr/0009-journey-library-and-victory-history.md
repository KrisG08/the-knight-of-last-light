# Journey library and save schema v8

User requested every new journey be preserved and listed, with world progress and
defeated bosses/enemies visible. Extend the existing validated JSON snapshot store;
no SQL plugin, account, network service or cloud database is needed for local play.

Campaign UI New Journey allocates a fresh monotonically increasing numeric ID.
The old three-slot UI limit is removed. Existing slot filenames stay unchanged,
including slot_01.json through slot_03.json. IDs range 1..999999; corrupt, backup,
temporary and unsupported-future files reserve their IDs. The library is rebuilt
from files, so an independently committed index cannot diverge from save truth.
The existing single-writer, verified-temp/backup/promotion protocol remains.

Schema v8 adds journey creation metadata, visited region IDs and an ordinary-enemy
victory ledger keyed by authored region/profile/home coordinates. Counts survive
respawn and reload. Boss, quest, item, ally, shortcut, reward and ending truth stays
in the campaign object; presentation derives its progress from that same state.
No duplicated boss-state table or invented completion percentage is introduced.

Versions 1..7 remain readable. Session load adds history in memory; the next
successful commit preserves the legacy primary as backup. Existing facts/rewards
and characters are retained. Older ordinary-enemy victories cannot be inferred
reliably, so old records are marked legacy and counts start with new events.
Campaign version promotions never downgrade v8, including the final chapter.

Runtime normal-enemy deaths record history in the same final snapshot as their
existing XP/shard payout; a per-life guard rejects duplicate death signals. Real
respawn increments the life number and permits the next victory. Wizard summons
are logged but retain the previous zero-XP policy. Boss rewards remain their
existing validated transaction. Region commits add visited history; app background
and focus loss retry a dirty durable snapshot. Failed writes remain visibly dirty.

Ordinary enemies still return at rest/death/load, as in the existing recovery
design; their historical victories remain. Loading uses a safe checkpoint with
restored resources, not an arbitrary combat position. Storage is private to the
installation; Android updates with the same package/signing key retain it, but
uninstall/clear-data and cross-device sync are outside this local mechanism.
