"""Original score, localized review copies and platform encodes for the authored film."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import random
import struct
import subprocess
import wave

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT/'art/cinematics/opening-v6'
OUT = ROOT/'.tools/movie-render/prologue-v6'
FFMPEG = ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'

def run(arguments):
    subprocess.run([str(FFMPEG), '-hide_banner', '-loglevel', 'error', '-y']+arguments, check=True)

def voiced_review(language, suffix='voiced'):
    plan=json.loads((PACK/'production.json').read_text(encoding='utf-8'))
    voices=json.loads((PACK/'narration/manifest.json').read_text(encoding='utf-8'))
    command=['-i',str(OUT/'opening-master.mp4')]
    filters=['[0:a]volume=0.40[music]']
    inputs=['[music]']
    for index,shot in enumerate(plan['shots']):
        key=hashlib.sha256(('narrator\n'+shot['narration']['en']).encode('utf-8')).hexdigest()[:20]
        clip=ROOT/voices['lines'][key]['clips'][language][6:]
        command+=['-i',str(clip)]
        filters.append('[{}:a]adelay={}:all=1[v{}]'.format(index+1,shot['start']*1000,index))
        inputs.append('[v{}]'.format(index))
    filters.append(''.join(inputs)+'amix=inputs=9:normalize=0,alimiter=limit=0.95[a]')
    target=OUT/('opening-'+language+'-'+suffix+'.mp4')
    command+=['-filter_complex',';'.join(filters),'-map','0:v','-map','[a]','-c:v','copy',
              '-c:a','aac','-ar','48000','-b:a','192k','-t','80','-movflags','+faststart',str(target)]
    run(command)
    print(target,flush=True)

def score():
    rate = 24000
    rng = random.Random(65080)
    wind = 0.0
    notes = [(55,82.41,110), (51.91,77.78,103.83), (49,73.42,98), (55,82.41,110),
             (46.25,69.3,92.5), (43.65,65.41,87.31), (55,82.41,130.81), (55,82.41,110)]
    target = OUT/'score.wav'
    with wave.open(str(target), 'wb') as stream:
        stream.setparams((2,2,rate,0,'NONE','not compressed'))
        data = bytearray()
        for index in range(80*rate):
            t = index/rate
            beat = min(7,int(t//10))
            local = t-beat*10
            wind = wind*.986+rng.uniform(-1,1)*.014
            fade = max(0,min(1,t/1.3,(80-t)/2))
            envelope = .65+.18*math.sin(t*.27)
            if beat == 5: envelope *= .38 if local>4 else 1.2
            if beat == 6: envelope *= .45
            chord = sum(math.sin(2*math.pi*f*t+math.sin(t*.7)*.014)*(gain)
                        for f,gain in zip(notes[beat],[.085,.045,.025]))
            air = wind*(.28 if beat!=4 else .35+local*.04)
            metallic = 0.0
            for hit in [1.2,11.0,14.0,17.0,26.3,45.1,50.5,51.8,52.6,60.6,71.1]:
                age=t-hit
                if 0<age<3:
                    metallic += (math.sin(2*math.pi*220*age)+.24*math.sin(2*math.pi*589*age))*.038*math.exp(-age*1.6)
            if beat in [3,7]:
                step=local%.41
                metallic += math.sin(2*math.pi*72*step)*.10*math.exp(-step*55)
            if 45<t<50:
                age=t-45
                air += math.sin(2*math.pi*(47+age*3)*age)*.045*age/5
            if 50<t<54:
                age=t-50
                air += (math.sin(2*math.pi*(42-age*2)*age)*.18+wind*.8)*math.exp(-age*1.2)
            signal = (chord*envelope+air+metallic)*fade
            left=max(-.86,min(.86,signal+wind*.035))
            right=max(-.86,min(.86,signal-wind*.035))
            data.extend(struct.pack('<hh',int(left*32767),int(right*32767)))
            if len(data)>=65536:
                stream.writeframes(data); data.clear()
        stream.writeframes(data)
    return target

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--score-only',action='store_true')
    parser.add_argument('--normalize-only',action='store_true',help='Prepare 48 kHz runtime audio without re-encoding video')
    parser.add_argument('--review-only',action='store_true',help='Create a narrated review from the finished H.264 master')
    args=parser.parse_args()
    OUT.mkdir(parents=True,exist_ok=True)
    if args.review_only:
        voiced_review('bg','preview')
        return
    if args.normalize_only:
        for label in ['desktop','mobile']:
            run(['-i',str(OUT/('opening-'+label+'.ogv')),'-c:v','copy',
                 '-c:a','libvorbis','-ar','48000','-q:a','5','-t','80',str(OUT/('opening-'+label+'-48k.ogv'))])
        report=json.loads((OUT/'receipt.json').read_text(encoding='utf-8'))
        report['runtime_audio_sample_rate']=48000
        for path in OUT.glob('*-48k.ogv'):
            report['files'][path.name]={'bytes':path.stat().st_size,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        (OUT/'receipt.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
        print('Prepared 48 kHz runtime score, preserving the exact encoded video frames',flush=True)
        return
    music=OUT/'score.wav'
    if not music.exists(): music=score()
    if args.score_only:
        print(music); return
    picture=OUT/'picture-master.mp4'
    assert picture.is_file(), 'Actual 4800-frame animation must finish first'
    master=OUT/'opening-master.mp4'
    run(['-i',str(picture),'-i',str(music),'-map','0:v','-map','1:a','-c:v','copy',
         '-af','loudnorm=I=-24:TP=-3:LRA=10','-ar','48000','-c:a','aac','-b:a','192k','-t','80','-movflags','+faststart',str(master)])
    for label,width,quality in [('desktop',1920,'9'),('mobile',1280,'8')]:
        run(['-i',str(master),'-vf','scale={}:-2:flags=lanczos'.format(width),'-c:v','libtheora',
             '-q:v',quality,'-pix_fmt','yuv420p','-c:a','libvorbis','-ar','48000','-q:a','5','-t','80',
             str(OUT/('opening-'+label+'.ogv'))])
    for language in ['bg','en']:
        voiced_review(language)
    report={'type':'authored Godot 3D animation, not generative AI video', 'duration_seconds':80,
            'fps':60,'frames':4800,'dimensions':[1920,1080], 'engine':'4.7.2.stable.official.ed1daf0bf',
            'files':{p.name:{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
                     for p in OUT.iterdir() if p.suffix in ['.mp4','.ogv','.wav']}}
    (OUT/'receipt.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(json.dumps(report,indent=2))

if __name__=='__main__': main()
