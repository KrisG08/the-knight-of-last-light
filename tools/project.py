"""Run the existing Godot project/checks without requiring workstation paths."""
from pathlib import Path
import argparse
import os
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default=os.environ.get('GODOT_BIN'))
    parser.add_argument('command', choices=('import', 'run', 'test'))
    args = parser.parse_args()
    portable = ROOT / '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
    engine = args.godot or shutil.which('godot') or shutil.which('godot4')
    if not engine and portable.is_file():
        engine = str(portable)
    if not engine:
        parser.error('Godot 4.7.2 is required: use --godot, GODOT_BIN or PATH.')
    version = subprocess.check_output([engine, '--version'], timeout=30).decode().strip()
    if not version.startswith('4.7.2.stable.'):
        parser.error('Expected pinned Godot 4.7.2 stable; found ' + version)
    env = dict(os.environ)
    data = ROOT / ('.tools/userdata' if args.command == 'run' else '.tools/repository-test-userdata')
    data.mkdir(parents=True, exist_ok=True)
    env['APPDATA' if os.name == 'nt' else 'XDG_DATA_HOME'] = str(data)

    def run(options, label, timeout):
        result = subprocess.run([engine, '--path', str(ROOT), *options],
                                cwd=ROOT, env=env, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=timeout)
        output = result.stdout.decode('utf-8', errors='replace')
        print(output, end='', flush=True)
        if result.returncode or 'SCRIPT ERROR:' in output or '\nERROR:' in output:
            raise RuntimeError(label + ' failed; see the engine output above.')

    if args.command in ('import', 'test'):
        run(['--headless', '--editor', '--import', '--quit'], 'Import', 600)
    if args.command == 'test':
        run(['--headless', '--script', 'res://tests/run_tests.gd'], 'Godot checks', 180)
    if args.command == 'run':
        return subprocess.call([engine, '--path', str(ROOT)], cwd=ROOT, env=env)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, subprocess.SubprocessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
