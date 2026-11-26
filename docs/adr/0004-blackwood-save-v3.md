# Blackwood progression and save version three

Status: implemented, 2026-11-04.

Forest checkpoint/shortcut, Thorn Beast victory, Root Seal and Order discovery
require schema three. Accepted new actions copy/upgrade the state; older companion
actions preserve the newer version. Readers continue accepting versions one/two
with their original invariants. Existing save promotion/backup protocol is reused.

Validation requires forest discovery for chapter-two progress, the guardian before
Root Seal, Root Seal before Order discovery, and chapter-two completion matching
that discovery. Blackwood recovery uses checkpoint.blackwood / region.blackwood /
spawn.blackwood.safe. Older schemas cannot carry these new facts. Future schemas
remain unsupported and protected from overwrite. Recruitment remains optional.

Runtime derives guardian death, barriers, seal, ward and refuge feedback from the
campaign state. Victory and explicit seal interaction remain separate transactions.
Ordinary enemies reset on rest/load; boss rewards never reset.
