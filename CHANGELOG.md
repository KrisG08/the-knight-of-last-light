# Changelog

This log describes the initial versioned repository snapshot. Earlier iteration
and acceptance history remains in [docs/STATUS.md](docs/STATUS.md).

## 0.5.66 — 2026-11-26

### Cinematic and audio revision

- Continuous film skins for attached caster arms and less stretched sleeves.
- Visible occupied-cell staging, separate knight fall lanes, grounded landing
  poses and dropped equipment.
- Curved violet casting streams and softer depth-aware haze.
- Varied scene lengths and camera cuts within the 80-second prologue.
- Original dramatic opening score and four slowed dark-fantasy phonk gameplay
  loops; existing menu music and five-language offline narration retained.
- Desktop 1080p30 and Android 720p30 film delivery, with platform package parity.

### Repository preparation

- Source, art references, unpacked model packs, runtime resources, backend
  schema, tests, tools and project documentation are versioned together.
- Git LFS handles binary media and model resources.
- Current setup instructions, repository map, contribution guide, issue/PR
  templates and a ready-to-activate repository CI template are included.
- Local toolchains, caches, builds, duplicate ZIPs, private credentials,
  signing identities, chat attachments and real player saves remain excluded.

### Validation and limitations

Import and 646 general campaign/presentation assertions passed on the local
pinned Godot 4.7.2 installation. Cinematic-specific acceptance and package checks
are documented in STATUS. Remaining visual polish and physical Nothing Phone 3a
performance review are not declared complete.
