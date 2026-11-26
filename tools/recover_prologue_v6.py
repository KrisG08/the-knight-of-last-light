"""Resume the interrupted platform encode; retain the completed 77.2-second prefix."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v6'
FFMPEG=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'

def encode(label,arguments):
    with (OUT/(label+'.log')).open('w',encoding='utf-8') as log:
        subprocess.run([str(FFMPEG),'-nostdin','-hide_banner','-y','-progress',str(OUT/(label+'.progress'))]+arguments,
                       stdout=log,stderr=subprocess.STDOUT,check=True)
    print(label+' complete',flush=True)

def main():
    # The recovered Ogg's presentation endpoint is 77.2 s (4,632 source frames).
    # It has fewer coded packets because Theora omits identical black fade frames.
    # Resume by presentation time, not by the number of nonempty coded packets.
    prefix=OUT/'desktop-prefix.ogv'
    assert prefix.is_file()
    def desktop_tail():
        encode('desktop-tail',['-ss','77.2','-i',str(OUT/'opening-master.mp4'),'-vf',
            'scale=1920:-2:flags=lanczos','-r','60','-fps_mode','cfr',
            '-an','-frames:v','168','-c:v','libtheora','-q:v','9','-pix_fmt','yuv420p',str(OUT/'desktop-tail.ogv')])
    def mobile():
        encode('mobile-recovered',['-i',str(OUT/'opening-master.mp4'),'-vf','scale=1280:-2:flags=lanczos',
            '-c:v','libtheora','-q:v','8','-pix_fmt','yuv420p','-c:a','libvorbis','-ar','48000',
            '-q:a','5','-t','80',str(OUT/'opening-mobile-48k.ogv')])
    with ThreadPoolExecutor(max_workers=2) as pool:
        futures=[pool.submit(desktop_tail),pool.submit(mobile)]
        for future in futures: future.result()
    playlist=OUT/'desktop-concat.txt'
    playlist.write_text("file 'desktop-prefix.ogv'\nduration 77.2\nfile 'desktop-tail.ogv'\nduration 2.8\n",encoding='utf-8')
    encode('desktop-recovered',['-f','concat','-safe','0','-i',str(playlist),'-i',str(OUT/'score.wav'),
        '-map','0:v:0','-map','1:a:0','-c:v','copy','-af','loudnorm=I=-24:TP=-3:LRA=10',
        '-ar','48000','-c:a','libvorbis','-q:a','5','-t','80',str(OUT/'opening-desktop-48k.ogv')])
    report={'type':'authored Godot 3D animation, not generative AI video','duration_seconds':80,
            'fps':60,'frames':4800,'dimensions':[1920,1080],'runtime_audio_sample_rate':48000,
            'engine':'4.7.2.stable.official.ed1daf0bf',
            'recovery':'Retained complete Ogg presentation through 77.2 s; encoded source frames 4632–4799 and remuxed with original 48 kHz score. Mobile freshly encoded.',
            'files':{p.name:{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
                     for p in OUT.glob('*-48k.ogv')}}
    (OUT/'recovery-receipt.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print('Both recovered platform files ready for full decode and native acceptance',flush=True)

if __name__=='__main__': main()
