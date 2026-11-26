# Verification plan

## Automated rules

Damage: finite/nonnegative validation; defense formula; valid/invalid guard cone; invulnerability; guard break; no negative stamina; one hit per attack-target; death clears action. Rank: threshold boundary, multi-rank reward, no duplicate boss XP. Inventory: missing item, incompatible equip, insufficient shards, upgrade cap. Campaign: unknown IDs, repeat action, boss/seal distinction, all four seal conditions, reward idempotency, full ending prerequisites. Dialogue: no repeated choice effect/reward. Gate access uses the same interface in tests and world scenes.

## Integration

File saves round-trip and maintain stable IDs. Corrupt primary restores backup with warning. Unsupported future version is preserved and rejected. Simulated write failure does not duplicate rewards or falsely report success. Region transition valid/locked/missing-target/missing-spawn cases recover. Loading defeated boss leaves seal available if unbroken. Load recruited Oren at refuge only, not captive and resident simultaneously. Unequipping/changing regions does not mutate global item Resources. Test directories must not touch user save slots.

Headless runtime tests can check node construction, signal wiring, target removal, action cleanup and content references where supported. They cannot certify visuals or interaction feel. Mark unexecuted checks as unexecuted.

## Manual slice route

1. Launch a fresh Windows build, use settings, start slot 1.
2. Move, orbit near walls, climb supported slope, fall out of bounds and recover.
3. Attack one enemy; verify a swing does not damage it repeatedly. Block front/rear attacks and exhaust stamina.
4. Dodge telegraphed attack, heal, get interrupted, die and respawn.
5. Activate checkpoint and confirm ordinary enemies reset.
6. Rescue Oren; visit refuge; converse and upgrade once; reload and verify one resident Oren.
7. Enter boss arena, lose, re-enter with full reset, then win.
8. Exit/reload before breaking seal; boss stays dead, reward not duplicated, seal available.
9. Break seal; forest gate opens; transition into playable entrance and return.
10. Quit/relaunch; check gate, equipment, quest and checkpoint persistence.
11. Exercise invalid slot/backup flow using a copy, not the sole player save.
12. Run performance route and inspect visual/audio readability.

## Companion manual route

Recruit Lyra, follow around obstacles and doorways, hold, resume, enter combat, down her, reset/recover, cross allowed gate, enter restricted arena, return, reload active selection. Confirm no companion can cross locked gates, trigger boss death alone or block the only exit. In developer test room deliberately remove a path and verify safe stuck handling.

## Campaign acceptance

From clean slot, defeat every required boss, break each seal, recruit available allies, revisit earlier regions, complete finale, interact with artifact, see credits and load into cleansed refuge. No debug flags, console commands or editor scene switching. Optional side quests cannot permanently lock required progress. Check ending music/lighting/encounters are consistent with cleansing.

## Reporting template

Date/build/engine/hardware; test command or manual steps; expected and observed result; pass/fail/not run; evidence path; limitations. Record initial tuning separately from measured balance. Track failures by severity: crash/data loss, progression blocker, combat defect, usability, polish. Block distribution on known save corruption, reproducible softlocks or missing asset licenses.

## Diploma evidence

Keep architecture diagram, original requirements, iteration screenshots, state diagrams, test reports, measured performance and an honest account of external assets. Explain implemented patterns with actual code examples. Never claim authorship of downloaded art or a complete engine. Optional documentation export can be produced later from verified implementation.
