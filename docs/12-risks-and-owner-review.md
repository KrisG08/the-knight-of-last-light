# Assumptions, risks and review points

## Confirmed versus proposed

Confirmed: 3D, knight protagonist, evil wizard, dark fantasy adventure, exploration/combat/bosses, progressively unlocked map/story, friends and useful NPC allies, final curse breaking, incremental story development.

Proposed implementation choices: Godot/GDScript, stylized art, separate connected region scenes, Windows target, single active companion, four regional seals, five campaign regions, working names, initial balance and controls. These choices enable a prototype without claiming the owner approved every detail. Present meaningful changes when evidence requires them.

## Main risks and responses

Scope: five polished regions are substantial for one developer. Ship a coherent slice first; if time is constrained, propose a shorter complete campaign with owner approval rather than silently removing the ending.

Animation/content: code does not generate a finished world automatically. Use readable placeholders, a small reusable asset kit and explicit art tasks. Missing art is visible in status.

Combat feel: architecture cannot prove fun. Playtest attack timing, camera, input buffering and hit feedback before more weapons.

Companion navigation: doors, slopes and moving actors cause failures. Test constrained routes, reserve safe spawn/recovery and permit authored restrictions.

Performance: 4 GB VRAM requires controlled art/light budgets. Benchmark early with exported build and representative encounters.

Persistence: boss/gate/quest facts can diverge. One campaign state and atomic semantic actions; failure/backup tests early.

Narrative: owner wants gradual development. Expand dialogue and chapters after short approvals; do not lock dozens of pages of mandatory lore up front.

## Questions that do not block initial graybox

Final title, knight name, wizard name, armor style, exact number of side quests, regional ordering details, difficulty target, final art pack and controller platform. Use labeled proposals and ask at the relevant milestone.

## Questions that require a decision before dependent work

Any engine/language switch after implementation begins; paid assets or services; public release; deleting/replacing repositories; major scope expansion; replacing the approved knight/wizard premise; transferring project ownership. Prepare concrete options rather than requesting vague permission.

## Handoff contract

At the end of a work session, leave runnable state where possible and update STATUS.md with exact current milestone, implemented scenes, tests executed, blockers, current engine version and next actionable task. Include reproducible commands. Do not say 'finished' when only planning files or placeholder menus exist.
