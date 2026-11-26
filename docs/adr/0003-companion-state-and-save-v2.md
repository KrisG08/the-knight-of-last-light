# Companion state and additive save version two

Status: implemented, 2026-11-04.

Recruitment, its finite reward, quest completion and selected active companion commit
as one campaign action. Follow/hold, attack timing, follower HP and downed/suspended
state remain transient runtime state. Safe checkpoints/transitions can recover Lyra;
an active selection is retained when a region such as the crypt suspends her.

Companion facts are new required semantics, so first accepted scout/companion action
writes schema_version=2 on a copied state. Reading version-one saves remains supported;
they are not rewritten merely to add empty fields. Initial new/training fixtures remain
version one until companion progress exists. Version-one documents cannot contain v2
companion facts. Existing backup promotion retains the previous known-good primary.
Older M6 readers reject schema two as unsupported instead of treating unfamiliar quest
facts as corrupt input eligible for fallback/overwrite. No future migrations are invented.

Runtime Lyra owns a small follow/hold/downed interface and NavigationAgent-based
movement. A journey controller owns quest interactions, authored guard completion,
region eligibility and reconstruction from selected campaign state. Region geometry
does not own permanent recruitment booleans. Friendly attack queries target hostiles
only; hostile swings may hit the knight and companion with per-target swing claims.
Bosses are excluded from companion target selection and crypt spawns are prohibited.
