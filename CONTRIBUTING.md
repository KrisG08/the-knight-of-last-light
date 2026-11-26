# Contributing

This is the private development repository for The Knight of Last Light.
Read [AGENTS.md](AGENTS.md), [CONTEXT.md](CONTEXT.md) and the numbered design
specifications before changing game behavior. The owner's later approved
revisions take precedence over early planning proposals.

## Working process

1. Branch from `main` for one coherent task.
2. Keep gameplay rules in the existing domain/application modules; keep physics,
   cameras and actor lifecycle in Godot runtime scripts.
3. Preserve resource paths, `.uid` files, save compatibility and asset credits.
4. Run `python tools/check_repository.py`, import the project and run the relevant
   Godot tests. Visually test camera, animation, audio and interface changes.
5. Record actual evidence and limitations in [docs/STATUS.md](docs/STATUS.md).
6. Open a pull request with the problem, resulting behavior and checks performed.

Use English for code and documentation. Do not commit credentials, signing keys,
player saves, local tools, build outputs or chat attachments. Install Git LFS
before adding binary assets. Keep source images/models and their provenance.

See [development setup](docs/development.md) and
[repository organization](docs/repository.md). Publishing builds, buying services
and changing distribution rights require the owner's authorization.
