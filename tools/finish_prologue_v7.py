"""Fresh video-only delivery encodes and a localized review of the revised film."""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import subprocess
import hashlib
import json
import shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v7'
FF=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
def run(args,log):
    with (OUT/log).open('w',encoding='utf-8') as stream:
        subprocess.run([str(FF),'-nostdin','-hide_banner','-y',*map(str,args)],stdout=stream,stderr=subprocess.STDOUT,check=True)
def encode(platform,width,quality):
    target=OUT/('opening-'+platform+'.ogv')
    run(['-i',OUT/'picture-master.mp4','-an','-vf',f'scale={width}:-2:flags=lanczos','-r','30','-fps_mode','cfr',
         '-c:v','libtheora','-q:v',quality,'-g','30','-pix_fmt','yuv420p','-t','80',target],platform+'-encode.log')
    print(platform+' fresh encode complete',flush=True)
    return target
def review(language='bg'):
    plan=json.loads((ROOT/'art/cinematics/opening-v7/production.json').read_text(encoding='utf-8'))
    voices=json.loads((ROOT/'assets/audio/voice/manifest.json').read_text(encoding='utf-8'))
    args=['-i',OUT/'picture-master.mp4','-i',ROOT/'.tools/music-masters/v0566/opening-cinematic.ogg']
    filters=['[1:a]volume=0.35[music]']; inputs=['[music]']
    for i,shot in enumerate(plan['shots']):
        key=hashlib.sha256(('narrator\n'+shot['narration']['en']).encode()).hexdigest()[:20]
        args+=['-i',ROOT/voices['lines'][key]['clips'][language][6:]]
        filters.append(f'[{i+2}:a]adelay={round(shot["start"]*1000)}:all=1[v{i}]'); inputs.append(f'[v{i}]')
    filters.append(''.join(inputs)+'amix=inputs=9:normalize=0,alimiter=limit=0.95[a]')
    target=OUT/('opening-'+language+'-preview.mp4')
    run(args+['-filter_complex',';'.join(filters),'-map','0:v','-map','[a]','-c:v','copy',
       '-c:a','aac','-ar','48000','-b:a','192k','-t','80','-movflags','+faststart',target],'review-encode.log')
    return target
if __name__=='__main__':
    source=json.loads((OUT/'render-receipt.json').read_text())
    assert source['frames']==2400 and source['all_frames_received']
    with ThreadPoolExecutor(max_workers=2) as pool:
        jobs=[pool.submit(encode,'desktop',1920,'8'),pool.submit(encode,'mobile',1280,'7')]
        files=[job.result() for job in jobs]
    files.append(review())
    receipt={'type':'Authored Godot 3D cinematic, continuous skins, grounded choreography',
      'fps':30,'frames':2400,'duration_seconds':80,'render':source,
      'files':{f.name:{'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in files}}
    (OUT/'production-receipt.json').write_text(json.dumps(receipt,indent=2))
    print('Complete platform encodes and narrated review',flush=True)
