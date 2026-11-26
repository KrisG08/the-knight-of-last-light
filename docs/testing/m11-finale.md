# M11: Citadel, Maldrek and explicit ending

Implemented locally 2026-11-04 with Godot 4.7.2.stable.official.ed1daf0bf.

The citadel now contains a gatehouse, real lantern, optional two-prisoner rescue,
ritual inscription and authored colonnade approach to the separate final chamber.
The graybox approach uses a flat floor; it does not claim finished vertical ascent
art. The jailer must fall before the bars open. Rescue grants 30 XP / 20 shards once
and moves the survivors' representation to the refuge. The inscription explains
that killing Maldrek is distinct from breaking the curse.

Maldrek has 780 HP / 10 defense. His deterministic sequence uses a straight orb
(0.9 s casting warning, swept movement at 7 m/s), marked ground (0.9 s cast followed
by a 1.1 s escape window, 2.3 m visible disc plus actor clearance), and a close 3.5 m
burst (1.1 s warning). Long-range burst selections become orbs. Damage is 22/28/26
before knight defense; normal guard/dodge rules apply. Each cast recovers for 1.6 s.
One half-health phase change adds up to two 45-HP shades, with no shade XP farming.
Simultaneous spell count is capped at three; assistance scales casting/projectile/
hazard timing. Victory immediately cancels spells/shades and awards 500 XP / 250
shards once. Companions explicitly wait outside the final chamber.

Victory does not complete the campaign. Interact with the central artifact, confirm
the ending, and save completion before the restored-refuge ending/credits panel.
Declining leaves the artifact intact. A failed write shows Retry saving ritual and
preserves the earlier victorious snapshot; retry does not grant the reward again.
Completion sets chapter V, curse.cleansed and spawn.refuge.ending. The ending offers
continued exploration. All main ordinary campaign encounters stop respawning;
boss defeats/gates persist and optional rescue/recruitment can still finish on the
peaceful roads. Postgame resting does not replace refuge recovery on future loads.

## Executed checks

- Test.ps1 clean import and **417 assertions PASS**, M0–M11 regression included.
  New rules/file/runtime checks cover final prerequisites, finite rescue/rewards,
  completed schema/recovery, JSON promotion/backup, actual prison interaction,
  ritual lore, selected companion restriction, swept orb hit, hazard telegraph and
  escape, close burst hit uniqueness/dodge, spell/summon caps, phase change,
  death/reset, victory cleanup, reload before artifact, confirmation decline,
  injected real-file save failure and successful retry before ending, continued
  exploration, every ordinary campaign region peaceful and postgame load at refuge.
- Native Mobile/Vulkan capture exited 0 with no engine errors on NVIDIA RTX 3050 Ti
  Laptop. Actual phase-two, ending/credits and restored-refuge renders inspected:
  .tools/review/{maldrek_phase_two,campaign_ending,cleansed_refuge}.png. Prison capture
  is also available as citadel_prison.png. These are scripted memory-slot renders.
- Windows export refresh, independent 120-frame native boot and SHA-256 manifest
  verification are recorded in STATUS.md. Tests use memory slots or unique .tools
  directories, never player slots. A guarded map-iteration check also prevents
  querying new navigation before its first map synchronization.

## Player route and remaining acceptance

After four seals, enter the citadel and activate its western lantern. Free prisoners
west if desired, read the eastern inscription, and enter the north ritual chamber.
Sidestep orbs, leave marked ground, manage the two shades and counter between casts.
After winning, approach the artifact behind Maldrek and confirm breaking it.
Continue exploring or reload into the restored refuge.

This is a complete implemented graybox story route with an explicit ending, not an
M12 release candidate. Art/animation/audio remain provisional. Full human clean-start
campaign/slice acceptance, combat balance, current workload performance, gamepad and
production polish remain open. M6 benchmark results refer to an older PCK.
