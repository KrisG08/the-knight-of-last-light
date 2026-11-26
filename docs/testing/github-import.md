# Initial private GitHub import

Date: 2026-11-26. Source snapshot: v0.5.66. Engine:
4.7.2.stable.official.ed1daf0bf. Account: KrisG08.

Repository: https://github.com/KrisG08/the-knight-of-last-light

## Local preparation evidence

- No Git repository existed at task start. Initialized `main` in the game
  workspace without changing any other project.
- Checked-in `.gitignore` excludes local tools, exports, sessions, credentials,
  signing keys, player data and private chat attachments.
- Original runtime `res://` paths and Godot UID/import metadata are retained.
- Source art and unpacked model exchange packs are included with their credits.
  Only duplicate ZIP packaging is excluded; nothing was deleted locally.
- `python tools/check_repository.py`: required files/folders, JSON validity,
  current documentation links and known private credential patterns PASS.
  This is a pattern-based review, not a guarantee against every possible secret.
- `python tools/project.py test`: clean import and **646 assertions PASS**.
  The helper checked the pinned engine version and used isolated local user data.
- Existing upstream font-license whitespace and historical source whitespace
  were preserved; they are not new game behavior defects from this import.

## Remote verification

Verified after the initial upload:

- GitHub repository visibility is **private** and its default branch is `main`.
- Remote `main` matches source commit `2e0ab001d062b0df53516a79da0187182efd18a2`; the complete GitHub tree
  matches the local tree and all **2992 tracked paths** exactly.
- Git LFS object and pointer integrity checks PASS locally. The initial import
  uploads **844 unique binary objects**, totaling **1,410,363,249 bytes**;
  duplicate resource contents share the same object.
- A fresh, shallow clone from GitHub passes repository checks with LFS pointers.
- A direct LFS pull into that independent clone retrieves the mobile opening
  movie and a native model resource; file lengths and SHA-256 match the source
  LFS object identifiers. This proves remote media retrieval for those samples,
  not a second complete download or a fresh-clone gameplay playthrough.
- CI is included as `tools/ci/repository-checks.yml`, ready for later owner
  activation. The current OAuth access lacks `workflow` permission; the first
  ref push was rejected for that reason after LFS upload succeeded. No live
  GitHub Actions run is claimed, and no permissions were expanded. The initial
  local commit remains on `local-import-with-workflow`; remote `main` has the
  CI source under the unrestricted template path.

The follow-up documentation commit records these observations. Full binary
upload success plus exact pointer/tree verification is distinct from the sampled
fresh-clone downloads. No excluded credentials, tools, builds or private chat
attachments occur in the remote file inventory.

## Scope boundaries

No new full campaign playthrough, phone installation or FPS measurement was
performed for this repository organization task. Existing v0.5.66 game packages
and player saves remain unchanged. No open-source license or public visibility
was granted. The repository-hygiene CI template does not run Godot integration
tests or download the full LFS asset library.
