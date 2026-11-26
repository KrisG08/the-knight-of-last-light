# Repository organization

The initial GitHub import preserves the working Godot resource layout. Moving
runtime assets just to shorten the root directory would break `res://` paths.

| Folder / entry | Responsibility |
| --- | --- |
| `game/` | GDScript gameplay, domain rules, actors, presentation, UI and persistence |
| `assets/` | Runtime models, native mesh catalogs, textures, shaders, films, speech, music and fonts |
| `content/` | Authored game definitions |
| `art/` | Source references, original models, production plans and retained art iterations |
| `art_exports/` | Unpacked image/model exchange packs and standalone GLB region exports |
| `backend/supabase/` | Optional cloud schema, migrations, confirmation endpoint and email templates |
| `tests/` | Rule/integration checks, regression scripts and native visual capture routes |
| `tools/` | Asset preparation, film production, validation, export and diagnostic utilities |
| `docs/` | Design specifications, architecture decisions, evidence, setup and credits |
| `planning/` | Milestones and asset register |
| `examples/` | Example content and save fixtures |
| `outputs/` | Authored project/diploma documents |
| `.github/` | Issue and pull-request templates |
| `project.godot` | Godot entry point; open this file in the pinned editor |
| `export_presets.cfg` | Shared Windows/Android export options; no signing credentials |
| `Play*.cmd`, `Preview*.cmd`, `Build*.ps1`, `Test.ps1` | Retained Windows compatibility entry points |

`art/`, `art_exports/` and `planning/` retain their existing `.gdignore` files.
The editor must not import duplicate exchange-pack scripts as game classes.

## Files deliberately kept local

- `.godot/`: reimportable editor cache.
- `.tools/`: portable executables, SDK/JDK helpers, temporary renders, local
  account sessions, review logs, upload receipts and redirected player data.
- `build/`: historical exported games and installers; these are not source.
- `.codex-remote-attachments/`: private chat attachments.
- Signing keys, environment secrets, session files and real player saves.
- `art_exports/*.zip`: duplicate archives; their unpacked contents are included.

These exclusions do not delete any local files. Runtime `.import` metadata and
`.uid` identities are included; the generated `.godot` data they point to is
rebuilt by the editor. The client Supabase publishable key is intentionally part
of the game configuration; service-role, SMTP and signing secrets are not.

## Continuous integration template

`tools/ci/repository-checks.yml` is ready for activation at
`.github/workflows/repository-checks.yml`. The initial GitHub credential cannot
write workflow files; uploading that path was rejected even though the LFS media
upload succeeded. The CI source is included as a template without expanding
OAuth permissions. Run `python tools/check_repository.py` locally in the meantime.

## Binary assets

Images, audio, fonts, binary native meshes, GLBs and films use Git LFS. Their
GitHub code view contains a pointer; `git lfs pull` retrieves the actual file.
Use a Git clone with LFS for development rather than relying on Download ZIP.
The two identical archived film files are stored only once by LFS's content hash.
Do not purchase additional GitHub storage automatically if an account quota is hit.

## Version and rights

Initial source import: **v0.5.66**, Android version code **71**, Godot **4.7.2**.
See [STATUS](STATUS.md) for actual acceptance evidence and pending physical-device
checks. This repository is a development snapshot, not a claim of a finished
commercial release. Original work remains all rights reserved; third-party
licenses and provenance are retained separately.
