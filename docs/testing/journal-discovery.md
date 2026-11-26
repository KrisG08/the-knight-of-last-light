# Discovery-aware journal — 2026-11-05

Journal text now derives from actual current/visited regions, persistent discovery
facts or legacy activated checkpoints. It shows the current lead, known region
routes, met/recruited allies and actual boss victories. Removes the old complete
campaign walkthrough and unconditional future Lyra/Cael notes. Controls are a
separate action; companion selection, recovered record and lantern travel remain.
No save/schema changes; rendering is read-only.

Six new pure assertions cover a spoiler-free fresh journey, read-only rendering,
notes after returning to refuge, met ally, recorded victory and legacy checkpoint
fallback. Updated actual Order journal integration checks for both companion
actions and recovered record. 526 assertions PASS (.tools/journal-tests-final.log).
Native fresh journal capture inspected (.tools/journal-capture.log), clean exit;
Back/travel/Controls visible without scrolling in the fresh 1280x720 layout.
Later-region and large-text long-dialogue scrolling still need further UI review.
Included in cumulative 0.5.2 packaging, not earlier Blackwood preview.
