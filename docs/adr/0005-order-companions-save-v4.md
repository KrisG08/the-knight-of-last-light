# Order quest and single companion identity

Status: implemented, 2026-11-04.

Cael's quest, expedition record and Order checkpoint promote a copied snapshot to
schema four. Versions one through three still read under their earlier invariants.
Older actions preserve the highest version already present. Promotion uses the
existing validated temp/backup protocol and does not rewrite player slots on boot.

New persistent IDs: ally.cael.met, order.courtyard_safe,
document.order.expedition, quest.cael, reward.quest.cael, checkpoint.order,
spawn.order.safe. Their prerequisites and reward consistency validate together.
Order quest progress requires region.order.visited and version four. Recruitment
requires meeting Cael, securing the sentries and recovering the record. It atomically
records recruitment, completed quest, reward claim and active selection.

The existing follower runtime is shared by both identities; its historical filename
lyra_companion.gd is retained to preserve references. Configure before adding it to
the scene. Identity supplies name, primitive appearance, HP, defense and damage;
movement/target restrictions remain shared. CompanionJourney replaces an actor when
the selected ID changes, and derives waiting refuge NPCs from the same state.
Runtime refuses selection changes in combat. No second follower service or new
behavior framework is introduced. The Commander/seal/mountain are future M9 work.
