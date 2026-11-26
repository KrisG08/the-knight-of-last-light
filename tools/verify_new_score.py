"""Decode delivery music independently: peak, loop seam and preserved menu."""
from pathlib import Path
import sys
import subprocess
import json
import hashlib
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/music-python'))
import numpy as np
FF=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
OUT=ROOT/'.tools/music-masters/v0566'
if __name__=='__main__':
    report={}
    for name in ['opening-cinematic','exploration','combat','boss','dawn']:
        path=OUT/(name+'.ogg')
        result=subprocess.run([str(FF),'-v','error','-i',str(path),'-f','f32le','-ar','48000','-ac','2','pipe:1'],capture_output=True,check=True)
        assert not result.stderr,result.stderr[:200]
        values=np.frombuffer(result.stdout,dtype='<f4').reshape(-1,2)
        peak=float(np.max(np.abs(values))); rms=float(np.sqrt(np.mean(values**2)))
        seam=float(np.max(np.abs(values[0]-values[-1])))
        assert np.isfinite(values).all() and .005<rms<.5 and peak<.95,(name,peak,rms)
        assert name=='opening-cinematic' or seam<.035,(name,seam)
        report[name]={'seconds':len(values)/48000,'peak':peak,'rms':rms,'loop_step':seam}
    menu=ROOT/'assets/audio/music/menu.ogg'
    report['preserved_menu_sha256']=hashlib.sha256(menu.read_bytes()).hexdigest()
    (ROOT/'.tools/review/v0566-music-quality.json').write_text(json.dumps(report,indent=2))
    print(json.dumps(report,indent=2))
