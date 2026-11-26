"""Fetch a pinned binary music-authoring dependency using Windows certificate trust."""
from pathlib import Path
import subprocess
import json
import hashlib
import zipfile
ROOT=Path(__file__).resolve().parents[1]
TARGET=ROOT/'.tools/music-python'
def fetch(url,path):
    subprocess.run(['curl.exe','--fail','--location','--silent','--show-error',url,'-o',str(path)],check=True)
if __name__=='__main__':
    TARGET.mkdir(parents=True,exist_ok=True)
    metadata=TARGET/'numpy-source.json'
    fetch('https://pypi.org/pypi/numpy/1.24.4/json',metadata)
    data=json.loads(metadata.read_text())
    entry=next(e for e in data['urls'] if e['filename'].endswith('cp38-cp38-win_amd64.whl'))
    assert entry['url'].startswith('https://files.pythonhosted.org/')
    wheel=TARGET/entry['filename']; fetch(entry['url'],wheel)
    assert hashlib.sha256(wheel.read_bytes()).hexdigest()==entry['digests']['sha256']
    with zipfile.ZipFile(wheel) as archive:
        for name in archive.namelist():
            destination=(TARGET/name).resolve()
            assert TARGET.resolve() in destination.parents
        archive.extractall(TARGET)
    (TARGET/'provenance.json').write_text(json.dumps({'version':'1.24.4','source':entry['url'],'sha256':entry['digests']['sha256']},indent=2))
    print('Verified NumPy 1.24.4 binary dependency, local offline music authoring only')
