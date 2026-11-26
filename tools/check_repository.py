"""Lightweight source/layout/credential checks; does not certify gameplay."""
from pathlib import Path, PurePosixPath
import argparse
import base64
import json
import os
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
EXCLUDED = {'.git', '.godot', '.tools', 'build', '.codex', '.agents',
            '.codex-remote-attachments', '__pycache__'}
TEXT = {'.gd', '.gdshader', '.tscn', '.tres', '.json', '.py', '.ps1', '.cmd',
        '.md', '.txt', '.sql', '.toml', '.cfg', '.godot', '.yml', '.yaml', '.html', '.ts'}
SECRET = re.compile(
    r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|'
    r'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b|'
    r'\bAKIA[A-Z0-9]{16}\b|\bsb_secret_[A-Za-z0-9_-]{12,}\b')


def source_paths():
    result = subprocess.run(['git', 'ls-files', '-z', '--cached'], cwd=ROOT,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode == 0 and result.stdout:
        return [p for p in result.stdout.decode('utf-8').split('\0') if p]
    paths = []
    for folder, dirs, names in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in EXCLUDED]
        for name in names:
            path = Path(folder) / name
            rel = path.relative_to(ROOT).as_posix()
            if rel.startswith('art_exports/') and path.suffix == '.zip':
                continue
            paths.append(rel)
    return paths


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--allow-lfs-pointers', action='store_true',
                        help='Metadata-only CI checkout; do not claim usable media.')
    args = parser.parse_args()
    failures = []
    paths = source_paths()
    for folder in ('game', 'assets', 'content', 'art', 'art_exports', 'backend',
                   'tests', 'tools', 'docs', 'planning', 'examples', 'outputs', '.github'):
        if not (ROOT / folder).is_dir():
            failures.append('Missing source folder: ' + folder)
    required = ('README.md', 'LICENSE', 'CONTRIBUTING.md', '.gitignore', '.gitattributes',
                'ENGINE_VERSION.txt', 'project.godot', 'export_presets.cfg',
                'game/world/runtime/village_game.tscn', 'game/cloud/cloud_config.json',
                'assets/cinematics/opening_film.ogv', 'assets/cinematics/opening_mobile.ogv',
                'assets/cinematics/opening_score.ogg', 'assets/audio/voice/manifest.json',
                'backend/supabase/schema.sql', 'tests/run_tests.gd', 'docs/ASSET_CREDITS.txt')
    for name in required:
        if not (ROOT / name).is_file():
            failures.append('Missing required file: ' + name)
    pointers = 0
    json_count = 0
    for rel in paths:
        path = ROOT / rel
        parts = PurePosixPath(rel).parts
        if any(part in EXCLUDED for part in parts):
            failures.append('Tracked local-only path: ' + rel)
        if path.suffix.lower() in {'.keystore', '.jks', '.pem', '.key', '.p12', '.pfx'}:
            failures.append('Tracked signing/private-key file: ' + rel)
        if path.name.startswith('.env') and path.name != '.env.example':
            failures.append('Tracked environment file: ' + rel)
        if path.name == 'export_credentials.cfg':
            failures.append('Tracked export credentials: ' + rel)
        if not path.is_file():
            failures.append('Tracked file missing locally: ' + rel)
            continue
        with path.open('rb') as stream:
            prefix = stream.read(128)
        if prefix.startswith(b'version https://git-lfs.github.com/spec/v1\n'):
            pointers += 1
            if not args.allow_lfs_pointers:
                failures.append('Missing binary data; run git lfs pull: ' + rel)
            continue
        if path.stat().st_size > 100 * 1024 * 1024:
            attr = subprocess.check_output(['git', 'check-attr', 'filter', '--', rel], cwd=ROOT)
            if not attr.rstrip().endswith(b': lfs'):
                failures.append('Large file not managed by LFS: ' + rel)
        if path.suffix.lower() not in TEXT or path.stat().st_size > 3_000_000:
            continue
        try:
            content = path.read_text(encoding='utf-8-sig')
        except UnicodeError:
            continue
        if SECRET.search(content):
            failures.append('Possible private credential (value redacted): ' + rel)
        if path.suffix.lower() == '.json':
            try:
                json.loads(content)
                json_count += 1
            except ValueError:
                failures.append('Invalid JSON: ' + rel)
        # Public anon/publishable keys are expected; administrative JWTs are not.
        for token in re.findall(r'eyJ[A-Za-z0-9_-]+\.([A-Za-z0-9_-]+)\.[A-Za-z0-9_-]+', content):
            try:
                claims = json.loads(base64.urlsafe_b64decode(token + '=' * (-len(token) % 4)))
                if claims.get('role') == 'service_role':
                    failures.append('Administrative JWT (value redacted): ' + rel)
            except (ValueError, UnicodeError):
                pass
    for name in ('README.md', 'CONTRIBUTING.md', 'docs/development.md', 'docs/repository.md'):
        for target in re.findall(r'\]\(([^)]+)\)', (ROOT / name).read_text(encoding='utf-8')):
            if '://' in target or target.startswith('#'):
                continue
            destination = target.split('#', 1)[0]
            if not (ROOT / name).parent.joinpath(destination).exists():
                failures.append('Broken documentation link: ' + name + ' -> ' + target)
    for failure in failures:
        print('FAIL: ' + failure)
    print('Repository checks: {} files, {} JSON documents, {} LFS pointers; {}'.format(
        len(paths), json_count, pointers, 'FAIL' if failures else 'PASS'))
    print('Scope: source hygiene and layout only; no visual, engine or phone certification.')
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
