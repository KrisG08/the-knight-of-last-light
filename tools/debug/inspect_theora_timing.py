"""Audit Ogg page timestamps against the actual Theora frame/keyframe packets."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'.tools/movie-render/prologue-v6'

def audit(name):
    serial=None
    packet=bytearray()
    count=frame=key=mismatched=max_distance=0
    examples=[]
    with (OUT/name).open('rb') as stream:
        while True:
            header=stream.read(27)
            if not header: break
            assert header[:4]==b'OggS' and len(header)==27
            laces=stream.read(header[26])
            body=stream.read(sum(laces))
            if serial is None and body.startswith(b'\x80theora'):
                serial=header[14:18]
                shift=(int.from_bytes(body[40:42],'big')>>5)&31
            if header[14:18]!=serial: continue
            at=0
            expected=None
            for size in laces:
                packet.extend(body[at:at+size]); at+=size
                if size<255:
                    if count>=3:
                        frame+=1
                        if packet and not packet[0]&64: key=frame
                        max_distance=max(max_distance,frame-key)
                        expected=(key<<shift)+(frame-key)
                    else:
                        expected=0
                    count+=1
                    packet.clear()
            actual=int.from_bytes(header[6:14],'little',signed=True)
            if expected is not None and actual!=expected:
                mismatched+=1
                if len(examples)<12: examples.append({'frame':frame,'actual':actual,'expected':expected})
    return {'file':name,'frames':frame,'max_keyframe_distance':max_distance,'mismatched_pages':mismatched,'examples':examples}

if __name__=='__main__':
    report=[audit(name) for name in ['opening-desktop-direct32.ogv','opening-mobile-direct32.ogv']]
    (ROOT/'.tools/review/prologue-v6-granule-audit.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(json.dumps(report,indent=2))
