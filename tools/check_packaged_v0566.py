"""Isolated, non-visual startup smoke check of the accepted Windows package."""
from pathlib import Path
import os
import subprocess

ROOT = Path(__file__).resolve().parents[1]
userdata = ROOT / '.tools/review/v0566-packaged-userdata'
userdata.mkdir(parents=True, exist_ok=True)
log = ROOT / '.tools/review/v0566-packaged-boot.log'
result = subprocess.run(
    [str(ROOT / 'build/windows-v0566/LastLight.exe'), '--headless',
     '--log-file', str(log), '--quit-after', '3'],
    cwd=ROOT, env=dict(os.environ, APPDATA=str(userdata)),
    capture_output=True, timeout=150, check=True)
assert log.is_file(), 'Packaged engine did not produce a startup log'
content = log.read_text(encoding='utf-8', errors='replace')
assert 'SCRIPT ERROR' not in content and 'ERROR:' not in content, content
print('Packaged headless startup PASS; no visual or phone claim')
