"""Encode video-only Theora to avoid coupled audio/video buffering in the game."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
import json
import hashlib
import sys
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v6'
FF=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
def encode(platform,width,quality):
    fps=30 if '--30fps' in sys.argv else 60
    suffix='picture30' if fps==30 else 'picture'
    target=OUT/('opening-'+platform+'-'+suffix+'.ogv')
    with (OUT/(platform+'-'+suffix+'.log')).open('w') as log:
        subprocess.run([str(FF),'-nostdin','-y','-i',str(OUT/'picture-master.mp4'),'-an',
          '-vf',f'fps={fps},scale={width}:-2:flags=lanczos','-r',str(fps),'-fps_mode','cfr',
          '-c:v','libtheora','-q:v',str(quality),'-g',str(fps),'-pix_fmt','yuv420p',
          '-t','80',str(target)],stdout=log,stderr=subprocess.STDOUT,check=True)
    print(platform+' video-only encode complete',flush=True)
    return target
if __name__=='__main__':
    with ThreadPoolExecutor(max_workers=2) as pool:
        jobs=[pool.submit(encode,'desktop',1920,8),pool.submit(encode,'mobile',1280,7)] if '--30fps' in sys.argv else [pool.submit(encode,'desktop',1920,9),pool.submit(encode,'mobile',1280,8)]
        files=[j.result() for j in jobs]
    subprocess.run([str(FF),'-nostdin','-y','-i',str(OUT/'score.wav'),'-af',
       'loudnorm=I=-24:TP=-3:LRA=10','-ar','48000','-c:a','libvorbis','-q:a','5',
       str(OUT/'opening-score.ogg')],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True)
    fps=30 if '--30fps' in sys.argv else 60
    (OUT/('picture30-receipt.json' if fps==30 else 'picture-receipt.json')).write_text(json.dumps({
      'type':'Authored Godot 3D animation; independent video, score and localized narration',
      'duration_seconds':80,'fps':fps,'frames':80*fps,'source_rendered_frames':4800,'engine':'4.7.2.stable.official.ed1daf0bf',
      'files':{f.name:{'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in files}
    },indent=2))
