"""Replace only binding/casting/curse shots, decoding all segments into one master."""
from pathlib import Path
import subprocess
import json
import shutil
import hashlib
import re
import sys
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v7'
FF=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
if __name__=='__main__':
    receipt=json.loads((OUT/'patch-violet-render-receipt.json').read_text())
    assert receipt['frames']==906 and receipt['all_frames_received']
    backup=OUT/'picture-master-before-violet.mp4'
    if not backup.exists(): shutil.copy2(OUT/'picture-master.mp4',backup)
    ground='--ground-only' in sys.argv
    if ground:
        ground_receipt=json.loads((OUT/'patch-ground-depth-render-receipt.json').read_text())
        assert ground_receipt['frames']==336 and ground_receipt['all_frames_received']
        parts=[(0,0,300),(1,0,300),(0,600,1164),(1,300,570),(2,0,336),(0,1770,2400)]
    else: parts=[(0,0,300),(1,0,300),(0,600,1164),(1,300,906),(0,1770,2400)]
    filters=[f'[{stream}:v]trim=start_frame={start}:end_frame={end},setpts=PTS-STARTPTS[p{i}]'
             for i,(stream,start,end) in enumerate(parts)]
    filters.append(''.join(f'[p{i}]' for i in range(len(parts)))+f'concat=n={len(parts)}:v=1:a=0,fps=30[v]')
    target=OUT/'picture-master-revised.mp4'
    with (OUT/'patch-composite.log').open('w') as log:
        inputs=['-i',str(backup),'-i',str(OUT/'patch-violet.mp4')]
        if ground: inputs+=['-i',str(OUT/'patch-ground-depth.mp4')]
        subprocess.run([str(FF),'-nostdin','-hide_banner','-y',*inputs,
          '-filter_complex',';'.join(filters),'-map','[v]','-an','-c:v','libx264','-crf','16','-preset','fast',
          '-pix_fmt','yuv420p','-movflags','+faststart',str(target)],stdout=log,stderr=subprocess.STDOUT,check=True)
    result=subprocess.run([str(FF),'-v','error','-i',str(target),'-map','0:v','-progress','pipe:1','-f','null','NUL'],capture_output=True,check=True)
    frames=re.findall(rb'^frame=(\d+)$',result.stdout,re.M)
    assert frames and int(frames[-1])==2400 and not result.stderr
    target.replace(OUT/'picture-master.mp4')
    original=json.loads((OUT/'render-receipt.json').read_text())
    original['violet_revision']=receipt
    original['replaced_frame_ranges']=[[300,600],[1164,1770]]
    if ground: original['soft_particle_revision']=ground_receipt
    original['master_sha256']=hashlib.sha256((OUT/'picture-master.mp4').read_bytes()).hexdigest()
    (OUT/'render-receipt.json').write_text(json.dumps(original,indent=2))
    print('Revised complete master verified: 2400 frames; original base retained')
