# Development setup

## Requirements

- Git and [Git LFS](https://git-lfs.com/).
- Godot **4.7.2 standard** (GDScript, not .NET), matching `ENGINE_VERSION.txt`.
  Get the editor and matching export templates from the official Godot release.
- Python **3.8+** for repository checks and the portable project runner.
- Windows desktop and Android ARM64 are the current preview targets.

## Clone and run

```sh
git lfs install
git clone https://github.com/KrisG08/the-knight-of-last-light.git
cd the-knight-of-last-light
git lfs pull
python tools/check_repository.py
```

Open `project.godot` in Godot, wait for import, then press **F5** to run the
configured game entry point. Alternatively, with Godot on PATH:

```sh
python tools/project.py import
python tools/project.py run
```

For an editor installed elsewhere, pass the executable explicitly:

```sh
python tools/project.py --godot "C:/Tools/Godot/Godot.exe" run
```

`GODOT_BIN` is another supported override. The runner also recognizes the
existing local `.tools/godot/Godot_v4.7.2-stable_win64_console.exe`; that portable
editor is intentionally not uploaded. First import can take time for textures
and native model resources. Git LFS pointer files are not usable art assets.

## Controls

Default bindings are defined in `game/core/input_bindings.gd` and can be remapped
in settings. W/A/S/D move, Shift sprints, F jumps, Space dashes/dodges, left mouse
attacks, Q uses heavy attack, right mouse guards, R heals, E interacts, J opens
the journal, Tab opens equipment and C orders the companion. Middle mouse locks
a target; the wheel cycles targets. Escape pauses. Android uses a virtual stick,
four primary action buttons and context/gesture alternatives.

## Verification

```sh
python tools/check_repository.py
python tools/project.py test
```

`test` imports first and runs `tests/run_tests.gd` with isolated local test data.
Specialized scripts in `tests/` and `tools/` have their own evidence/limitations;
they are not all invoked by the general runner. For example:

```sh
godot --headless --path . --script tools/check_prologue_v7_motion.gd
godot --path . --script tests/prologue_playback.gd
```

The template at `tools/ci/repository-checks.yml` checks repository hygiene and
required resources using Python; it does **not** claim to run Godot, certify
graphics, or measure phone FPS. The initial upload credential lacks GitHub's
`workflow` permission, so the template is not activated. A repository owner can
later put it at `.github/workflows/repository-checks.yml` using GitHub's editor or
a credential authorized for workflows. No broader account permission is granted
by this project, and local verification remains available immediately.

## Exporting

Install matching templates, then open Export in the Godot editor. The checked-in
presets reference the original workstation's `.tools/templates/` paths. On a new
machine, clear those custom template fields to use installed official templates,
or supply your own matching paths. Keep local signing credentials in Godot's
ignored credentials file, never in `export_presets.cfg`.

Windows output requires `LastLight.exe` and `LastLight.pck` together. On the
original workstation `Build-Windows.ps1`, `Build-Android.ps1` and
`tools/export_prologue_release.py` retain the verified portable-tool layout.
After a local v0.5.66 export, `Play-Latest.cmd` opens `build/windows-v0566`.
Those launchers cannot open a build that has not been exported after cloning.

Android needs the SDK/JDK/tool versions described in [MOBILE.md](MOBILE.md).
Existing installations can only be updated using the **same signing identity**;
the private key is not in this repository. Configure your own development key
for independent testing. Do not uninstall an existing game just to solve a
signing mismatch without backing up its saves.

## Optional cloud accounts

Offline play does not require Supabase. The existing client configuration
contains a publishable key, never an administrative key. To run an independent
service, apply `backend/supabase/schema.sql` and its migrations to your own
project, configure the email templates/redirects and update
`game/cloud/cloud_config.json` with your own URL and publishable key. See
[ADR 0016](adr/0016-optional-cloud-and-localization.md).

Keep SMTP credentials, service-role keys and refresh tokens outside Git. No
production cloud changes are performed by cloning or running repository checks.

## Asset production and historical notes

Bundled runtime art is ready for import; optional regeneration tools can require
additional explicitly documented local dependencies (FFmpeg, NumPy or TTS).
See [opening production](art/opening-v7.md),
[asset credits](ASSET_CREDITS.txt) and [repository layout](repository.md).
`SETUP.md` retains historical milestone notes; use this page and `STATUS.md`
for current setup and acceptance rather than assuming an old launcher is latest.
