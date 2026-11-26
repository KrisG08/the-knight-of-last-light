# The Knight of Last Light

**A single-player 3D dark fantasy adventure for Windows and Android.**

Explore a cursed kingdom as its surviving knight, rescue allies, defeat the
guardians of four seals and ascend Eclipse Citadel to confront Maldrek.
The campaign connects handcrafted regions with violet waygates, checkpoints
and persistent world progression.

**Development snapshot:** v0.5.66 · Godot 4.7.2 · typed GDScript · Mobile renderer

[Get started](docs/development.md) · [Repository layout](docs/repository.md) ·
[Current status](docs/STATUS.md) · [Design](docs/02-game-design.md) ·
[Asset credits](docs/ASSET_CREDITS.txt)

## Game features

- Third-person exploration with a collision-aware orbit camera, sprinting,
  jumping, dash/dodge and target lock.
- Sword combos, heavy attacks, guarding, healing, enemy telegraphs and bosses.
  Attacks do not consume the sprint stamina reserve.
- Connected handcrafted regions: Lantern Refuge, Ashen Village, Blackwood,
  the Order's Ruins, Ashen Peaks and Eclipse Citadel, with dedicated arenas,
  optional routes, elevation and a final castle ascent.
- NPC conversations, rescue quests, a refuge blacksmith, recruitable companions
  and follow/hold orders for one selected companion.
- Multiple saved journeys, durable boss defeats, seal/quest progression,
  equipment upgrades, relics, checkpoints and backup-aware save recovery.
- Optional Supabase accounts and cross-device save synchronization; offline
  single-player play remains available without an account.
- English, Bulgarian, Russian, French and Arabic UI/narrative localization,
  bundled offline narration and separate audio controls.
- A living menu backdrop, authored opening and victory cinematics, dark violet
  atmosphere, environmental creatures and original music.
- Windows keyboard/mouse and Android touch controls with device-aware rendering.

Further animation/visual polish, clean-start campaign acceptance and sustained
performance testing on the physical Nothing Phone 3a remain open. Video frame
rates and laptop measurements are not guarantees of phone frame rate.
See [STATUS](docs/STATUS.md) for actual evidence and limitations.

## Run from source

Install Git, Git LFS and the standard **Godot 4.7.2** editor.

```sh
git lfs install
git clone https://github.com/KrisG08/the-knight-of-last-light.git
cd the-knight-of-last-light
git lfs pull
```

Open `project.godot` in Godot, let the resources import and press **F5**.
Alternatively, with Python 3.8+ and Godot on PATH:

```sh
python tools/check_repository.py
python tools/project.py run
```

The repository includes game resources, not the editor or Android SDK. Binary
resources use Git LFS; pointer-only downloads cannot run the game. Follow
[development setup](docs/development.md) for editor paths, tests and exports.

## Project structure

```text
game/                 Gameplay, actors, domain rules, UI and persistence
assets/               Runtime models, textures, shaders, video, audio and fonts
content/              Authored content definitions
art/                  Art references, source models and production history
art_exports/          Unpacked model/image exchange packs and region GLBs
backend/supabase/     Optional cloud schema, migrations and email/confirmation setup
tests/                Automated checks, regressions and native capture routes
tools/                Development, validation, asset production and export tools
docs/                 Design, architecture, evidence, setup and credits
planning/             Milestones and asset register
examples/             Save/content examples
outputs/              Authored project documents
.github/              Issue and pull-request templates
```

Root-level Windows launchers are retained for compatibility with the owner's
workstation. `Play-Latest.cmd` opens a locally exported v0.5.66 build; it requires
that export to exist. Historical installers, tools, caches, signing identities,
chat attachments and player saves are excluded from Git. Duplicate ZIPs are
excluded while their unpacked image/model packs are included.

## Checks and development

```sh
python tools/check_repository.py
python tools/project.py test
```

The [CI template](tools/ci/repository-checks.yml) validates repository structure
and tracked-file hygiene. It is not activated: the current GitHub OAuth access
does not have `workflow` permission. Local checks work without it; Godot
integration checks and visual/audio review remain separate. See
[CONTRIBUTING](CONTRIBUTING.md), [architecture](docs/04-architecture.md),
[ADRs](docs/adr/) and [milestones](planning/milestones.csv).

## Credits and rights

Original project work is **all rights reserved**. This repository does not
grant an open-source license. Credited third-party assets retain their own
licenses, including CC0, CC BY and SIL OFL. See [LICENSE](LICENSE),
[complete credits](docs/ASSET_CREDITS.txt) and the source manifests/licenses
alongside the assets.

The initial planning-pack introduction is preserved in
[docs/archive/development-pack-readme.md](docs/archive/development-pack-readme.md).
Numbered specifications and approved owner revisions remain authoritative.
