"""Fresh platform encodes from the canonical picture/score with the recommended Win32 encoder."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v6'
FFMPEG=ROOT/'.tools/video-encoder32/imageio_ffmpeg/binaries/ffmpeg-win32-v4.2.2.exe'

def encode(platform,width,quality):
    destination=OUT/('opening-'+platform+'-direct32.ogv')
    with (OUT/(platform+'-direct32.log')).open('w',encoding='utf-8') as log:
        subprocess.run([str(FFMPEG),'-nostdin','-hide_banner','-y','-progress',str(OUT/(platform+'-direct32.progress')),
            '-i',str(OUT/'picture-master.mp4'),'-i',str(OUT/'score.wav'),'-map','0:v:0','-map','1:a:0',
            '-vf','scale={}:-2:flags=lanczos'.format(width),'-r','60','-vsync','cfr','-c:v','libtheora','-q:v',str(quality),
            '-g','60','-pix_fmt','yuv420p','-af','loudnorm=I=-24:TP=-3:LRA=10','-ar','48000','-c:a','libvorbis','-q:a','5',
            '-max_interleave_delta','100000','-page_duration','20000','-t','80',str(destination)],
            stdout=log,stderr=subprocess.STDOUT,check=True)
    print(platform+' direct Win32 encode complete',flush=True)
    return destination

def main():
    assert FFMPEG.is_file()
    with ThreadPoolExecutor(max_workers=2) as pool:
        futures=[pool.submit(encode,'desktop',1920,9),pool.submit(encode,'mobile',1280,8)]
        files=[f.result() for f in futures]
    receipt={'type':'authored Godot 3D animation; fresh direct Win32 Theora encodes',
        'engine':'4.7.2.stable.official.ed1daf0bf','duration_seconds':80,'fps':60,'frames':4800,
        'encoder':'FFmpeg 4.2.2 Windows 32-bit from verified imageio-ffmpeg 0.4.3 wheel',
        'page_duration_microseconds':20000,'runtime_audio_sample_rate':48000,'gop':60,
        'files':{f.name:{'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in files}}
    (OUT/'direct32-receipt.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
    print('Fresh encodes complete; native cadence acceptance still required',flush=True)

if __name__=='__main__': main()
