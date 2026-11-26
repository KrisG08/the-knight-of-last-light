# Explicit final ritual and save version seven

Status: implemented, 2026-11-04.

Citadel checkpoint, ritual knowledge, prison rescue, Maldrek victory and campaign
completion promote copied state to version seven. Earlier playable versions one
through six remain readable. Older actions preserve the current higher schema;
reserved wizard/ending IDs now enforce discovered citadel and the final schema.

Wizard reward remains atomic with defeat. Artifact confirmation calls completion
separately. Completion adds curse.cleansed and completed quest.main.ch05, and moves
recovery to checkpoint.refuge / spawn.refuge.ending. Validation enforces four seals,
wizard defeat, chapter/completed agreement and restored-refuge recovery. Postgame
checkpoint activation can add discovery but preserves that completed-load recovery.

Session.act may accept a mutation while its disk write fails. The ritual therefore
checks dirty state and retries saving before travel/ending. Its persistent controller
owns the asynchronous ending transition so deleting the chamber cannot abort it.
A real before_promote failure test verifies the prior victorious primary remains
readable and retry finishes without duplicate reward. No uncommitted credits.

Completed world reconstruction omits ordinary hostiles in every campaign region.
Peaceful routes satisfy former guard-clear prerequisites for optional unfinished
rescues/recruitments; there is no requirement to resurrect enemies to finish them.
Summons/spells are transient and never serialized. The final encounter caps them
and clears them on victory or region loss. NPC prison/refuge visuals derive from the
same saved rescue fact to avoid duplicate survivors after return.
