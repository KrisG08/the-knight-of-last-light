"""Keep original Theora pages byte-for-byte while separating the score stream."""
from pathlib import Path
import hashlib
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v6'
def extract(platform):
    source=OUT/('opening-'+platform+'-48k.ogv')
    target=OUT/('opening-'+platform+'-isolated.ogv')
    serial=None; pages=0
    with source.open('rb') as src,target.open('wb') as dst:
        while True:
            header=src.read(27)
            if not header: break
            assert header[:4]==b'OggS'
            laces=src.read(header[26]); body=src.read(sum(laces))
            if body.startswith(b'\x80theora'): serial=header[14:18]
            if header[14:18]==serial:
                dst.write(header+laces+body); pages+=1
    return {'file':target.name,'pages':pages,'bytes':target.stat().st_size,
      'sha256':hashlib.sha256(target.read_bytes()).hexdigest()}
if __name__=='__main__':
    receipt={'type':'Authored Godot 3D film; original Theora pages preserved, independent score and localized speech',
      'duration_seconds':80,'fps':60,'frames':4800,'engine':'4.7.2.stable.official.ed1daf0bf',
      'files':[extract(p) for p in ['desktop','mobile']]}
    (OUT/'isolated-receipt.json').write_text(json.dumps(receipt,indent=2))
    print(json.dumps(receipt,indent=2))
