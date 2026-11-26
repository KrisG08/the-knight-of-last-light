# Peaks traversal and save version six

Status: implemented, 2026-11-04.

Peaks checkpoint/service bar, Warden defeat, Forge Seal and citadel discovery promote
a copied state to schema six. Prior actions preserve newer schemas. Versions one
through five remain readable for previously implemented progression. Reserved Warden
IDs now require discovered Peaks and version six; no earlier playable encounter
could create them. Existing crash-safe promotion and known-good backups are reused.

Recovery adds checkpoint.peaks / region.peaks / spawn.peaks.safe. New facts are
gate.peaks.shortcut.open and region.citadel.visited; the latter requires all four
seals and completed quest.main.ch04. Validation enforces their agreement. Victory
and reward remain atomic; explicit seal interaction is separate. Oren upgrades and
both recruitable companions remain optional for the main gate.

The bridge has real collision surfaces over a floor gap. Navigation excludes void
footprints and inflated rail colliders so AI cannot path over missing ground.
Existing fall recovery uses the activated checkpoint, never arbitrary bridge
coordinates. Forge arena excludes companions; Peaks and citadel forecourt permit
them. No new recovery checkpoint is implied inside either arena or forecourt.
