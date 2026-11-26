# The Knight of Last Light — Codex development pack

This is a planning and implementation-instruction package, not a playable game or a prebuilt Godot project. All documents are English. The working title, names, narrative details and balance numbers are editable proposals. The owner's approved pillars are binding.

## What the owner approved

A single-player 3D dark fantasy adventure. The player is a knight. An evil wizard has cursed the kingdom. Exploration, combat, bosses and character progression gradually unlock new connected regions and story chapters. Friendly NPCs are met over time; some join the refuge, some accompany the knight. The final confrontation defeats the wizard and enables the curse to be broken. The story will grow incrementally with the owner.

## How to use this pack

1. Create a NEW, empty game repository. Do not reuse or erase CarPartAI. Its earlier reset discussion does not authorize game files to replace that project.
2. Copy this pack into the repository root. Keep AGENTS.md, CONTEXT.md, docs/, examples/ and planning/ together.
3. Open that repository in Codex. Paste START_HERE.txt for file-based operation, or paste MASTER_PROMPT.md when transferring one document to another chat.
4. Codex implements milestone M0, then M1, and continues according to the milestone gates. A headless import is not evidence of a playable game.
5. Review the first playable movement/combat prototype before increasing content scope. Use the provided review questions; avoid an endless questionnaire before starting.

## Recommended baseline

Godot 4.7.2 standard Windows x86_64 release with typed GDScript, proposed from the official download page checked on 2026-11-03. Verify the actual executable version and pin it in ENGINE_VERSION.txt before implementation. If that release cannot be obtained, choose a supported stable Godot 4 release explicitly and verify all APIs against its matching docs. Do not silently mix engine versions or use preview releases.

Use the Mobile renderer initially for a modest 3D project; this renderer can target desktop. Benchmark the game before changing renderer or adding expensive effects. Godot engine minimum requirements do not guarantee this game's frame rate.

Known development laptop: i5-12450H, RTX 3050 Ti Laptop GPU with 4 GB VRAM, about 16 GB RAM. Previous inspection found about 59 GB free on C: and little available RAM; recheck before large downloads. Target Windows keyboard/mouse first. Gamepad is a later gate.

## Reading order

AGENTS.md → CONTEXT.md → docs/01-product-and-scope.md → docs/02-game-design.md → docs/03-world-and-narrative.md → docs/04-architecture.md → docs/05-implementation-contracts.md → docs/06-save-and-progression.md → docs/07-ui-controls-accessibility.md → docs/08-art-audio-assets.md → docs/09-performance-and-tooling.md → docs/10-roadmap.md → docs/11-testing-and-acceptance.md → docs/12-risks-and-owner-review.md.

MASTER_PROMPT.md embeds all authoritative documents and example data. It is generated from these files; edit the source files first and regenerate the master if the design changes. README.md and docs/04-architecture.md explain ownership.

## Deliverables expected from implementation

A runnable Godot project; honest prototype art; meaningful tests; Windows development build; setup and controls instructions; asset licensing register; save fixtures; test evidence; and a documented list of limitations. Final game completion requires all campaign gates, not merely the first boss.
