"""Original offline music: slowed dark-fantasy phonk and an event-scored prologue.

No downloaded samples, copied melodies, recorded voices or external generation.
NumPy is an offline authoring dependency, never a game dependency.
"""
from pathlib import Path
import sys
import json
import hashlib
import wave
import subprocess
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/music-python'))
import numpy as np
RATE=48000
FF=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
OUT=ROOT/'.tools/music-masters/v0566'
OUT.mkdir(parents=True,exist_ok=True)
TAU=2*np.pi

class Score:
    def __init__(self,seconds,seed,loop=False):
        self.audio=np.zeros((round(seconds*RATE),2),dtype=np.float32)
        self.rng=np.random.default_rng(seed); self.loop=loop
    def add(self,sound,at,gain=1.,pan=0.):
        start=round(at*RATE); signal=np.asarray(sound,dtype=np.float32)*gain
        stereo=signal[:,None]*np.array([(1-pan*.6),(1+pan*.6)],dtype=np.float32)[None,:]
        if self.loop:
            indices=(np.arange(len(stereo))+start)%len(self.audio)
            np.add.at(self.audio,indices,stereo)
        else:
            stop=min(len(self.audio),start+len(stereo))
            if stop>start>=0: self.audio[start:stop]+=stereo[:stop-start]
    def note(self,midi,at,length,gain,voice='pad',pan=0.):
        t=np.arange(round(length*RATE),dtype=np.float64)/RATE
        f=440*2**((midi-69)/12)
        if voice=='bell':
            phase=TAU*f*t
            sound=(np.sin(phase+1.1*np.sin(phase*1.47))+.24*np.sin(phase*2.03))*np.exp(-t*4.3)
            env=np.minimum(t/.004,1)*np.minimum((length-t)/.09,1)
        elif voice=='bass':
            # Sub, saturated octave and a restrained descending 808 onset.
            phase=TAU*f*(t+.012*(1-np.exp(-t*35)))
            sound=np.tanh((np.sin(phase)+.26*np.sin(2*phase)) *1.5)*np.exp(-t*.85)
            env=np.minimum(t/.008,1)*np.minimum((length-t)/.12,1)
        elif voice=='pluck':
            phase=TAU*f*t
            sound=(np.sin(phase)+.28*np.sin(phase*2)+.12*np.sin(phase*3))*np.exp(-t*3.1)
            env=np.minimum(t/.006,1)*np.minimum((length-t)/.10,1)
        else:
            # Bow/choir-like harmonic layer with independent drift, no speech samples.
            sound=sum(np.sin(TAU*f*(1+detune)*t+phase)*gain
                      for detune,phase,gain in [(-.0018,.1,.50),(.0015,.8,.42),(0,0,.40)])
            sound+=.13*np.sin(TAU*f*2*t)+.055*np.sin(TAU*f*3*t)
            env=np.minimum(t/.45,1)*np.minimum((length-t)/.8,1)
        self.add(sound*np.maximum(env,0),at,gain,pan)
    def drum(self,kind,at,gain=1.,pan=0.):
        length={'kick':.64,'snare':.32,'hat':.10,'boom':2.8,'clank':.9,'swell':2.0}[kind]
        t=np.arange(round(length*RATE))/RATE
        noise=self.rng.standard_normal(len(t))
        high=np.diff(noise,prepend=noise[0])*.45
        if kind=='kick': sound=np.sin(TAU*(43*t+2.4*(1-np.exp(-t*29))))*np.exp(-t*9)+high*np.exp(-t*120)*.12
        elif kind=='snare': sound=high*np.exp(-t*19)*.55+np.sin(TAU*176*t)*np.exp(-t*30)*.2
        elif kind=='hat': sound=high*np.exp(-t*65)*.24
        elif kind=='boom': sound=(np.sin(TAU*(30*t+1.6*(1-np.exp(-t*9))))*.8+noise*.11)*np.exp(-t*2.1)
        elif kind=='clank': sound=(np.sin(TAU*223*t)+.38*np.sin(TAU*591*t)+.12*high)*np.exp(-t*7)
        else: sound=(high*.20+np.sin(TAU*(45*t+12*t*t))*.22)*np.sin(np.pi*t/length)**2
        sound*=np.minimum(t/.003,1)
        self.add(sound,at,gain,pan)
    def finish(self,name,loudness=-19):
        wet=self.audio.copy()
        for delay,gain in [(.133,.11),(.287,.08),(.619,.045)]:
            shift=round(delay*RATE)
            if self.loop: reflected=np.roll(self.audio,shift,axis=0)
            else:
                reflected=np.zeros_like(self.audio); reflected[shift:]=self.audio[:-shift]
            wet[:,0]+=reflected[:,1]*gain; wet[:,1]+=reflected[:,0]*gain
        wet=np.tanh(wet*.9)
        if not self.loop:
            fade=round(RATE*.9); wet[:fade]*=np.linspace(0,1,fade)[:,None]; wet[-fade:]*=np.linspace(1,0,fade)[:,None]
        peak=float(np.max(np.abs(wet)))
        wet*=.82/max(peak,.001)
        wav=OUT/(name+'.wav')
        with wave.open(str(wav),'wb') as out:
            out.setparams((2,2,RATE,0,'NONE','not compressed'))
            out.writeframes((wet*32767).astype('<i2').tobytes())
        ogg=OUT/(name+'.ogg')
        subprocess.run([str(FF),'-nostdin','-hide_banner','-loglevel','error','-y','-i',str(wav),
          '-af',f'loudnorm=I={loudness}:TP=-2:LRA=9','-ar',str(RATE),'-c:a','libvorbis','-q:a','6',str(ogg)],check=True)
        return {'name':name,'seconds':len(wet)/RATE,'wav':str(wav.relative_to(ROOT)),
                'ogg':str(ogg.relative_to(ROOT)),'peak_before_encode':float(np.max(np.abs(wet))),
                'sha256':hashlib.sha256(ogg.read_bytes()).hexdigest()}

def phonk(name,bpm,intensity,seed):
    beat=60/bpm; music=Score(beat*64,seed,True)
    progression=[38,34,31,33,38,36,34,33]*2 # D minor, with the unsettled dominant.
    motif=[0,7,10,7,3,2,-1,2]
    for bar,root in enumerate(progression):
        at=bar*4*beat
        for degree in [0,7,15]: music.note(root+degree,at,4*beat+.6,.027 if intensity else .035,'pad',(-.4 if degree==7 else .4))
        for position in [0,1.75,3.0]: music.note(root-12,at+position*beat,beat*(1.45 if position==0 else .85),.22 if intensity else .13,'bass')
        if name!='dawn' or bar%4<2:
            for step in range(8):
                if step in [2,5] and intensity<2: continue
                swing=.10*beat if step%2 else 0
                music.note(root+24+motif[(step+bar%4)%8],at+step*.5*beat+swing,.60*beat,
                  .036 if intensity<2 else .052,'bell',(-1 if step%2 else 1)*.28)
        for position in ([0,2.75] if intensity==0 else [0,1.5,2.75,3.5]): music.drum('kick',at+position*beat,.15+.05*intensity)
        music.drum('snare',at+2*beat,.12+.035*intensity)
        for step in range(8 if intensity<2 else 16):
            subdivision=2 if intensity<2 else 4
            music.drum('hat',at+(step/subdivision+.08*(step%2))*beat,.08+.015*(step%3),(-.5 if step%2 else .5))
        if bar%4==3:
            music.note(root+23,at+3.75*beat,.55*beat,.043,'pluck',.35)
            if intensity: music.drum('snare',at+3.75*beat,.06)
    return music.finish(name,-22 if name=='dawn' else (-19 if intensity==0 else -17))

def cinematic():
    plan=json.loads((ROOT/'art/cinematics/opening-v7/production.json').read_text(encoding='utf-8'))
    score=Score(80,66780)
    roots=[38,34,31,33,30,26,38,38]
    for i,shot in enumerate(plan['shots']):
        at=shot['start']; length=shot['duration']; root=roots[i]
        for interval,gain in [(0,.07),(7,.04),(15,.024),(24,.012)]:
            score.note(root+interval,at,max(1,length-.1),gain,'pad',-.3 if interval==7 else .3)
        if i in [0,1,2,6,7]:
            for j,note in enumerate([root+24,root+27,root+31]):
                score.note(note,at+1.2+j*1.4,2.8,.035 if i!=6 else .017,'bell',(-1 if j%2 else 1)*.35)
    # Cinematic cues follow the actual gate, hand release and staggered impacts.
    for at in [3.2,14.6,24.55]: score.drum('clank',at,.14)
    for at in [30.2,32.0,34.1,36.7]: score.drum('kick',at,.09)
    for at in [40.6,42.0,43.2]: score.drum('swell',at,.30)
    # A brief pre-release vacuum makes the spell hit surprising, not constant noise.
    begin,end=round(42.95*RATE),round(43.30*RATE)
    score.audio[begin:end]*=.10
    score.drum('boom',43.32,.42); score.drum('clank',43.40,.12)
    for at,gain in [(50.79,.18),(51.27,.22),(51.75,.20),(53.31,.27)]:
        score.drum('boom',at,gain); score.drum('clank',at+.04,.06)
    # The exhausted survivor has room to breathe before the lantern motif returns.
    score.audio[round(58.8*RATE):round(62.0*RATE)]*=.42
    for at in [61.2,63.5]: score.drum('kick',at,.055)
    for offset,note in [(0,62),(1.6,65),(3.2,69),(5.6,74)]: score.note(note,70+offset,3.0,.055,'pad',.15)
    return score.finish('opening-cinematic',-21)

if __name__=='__main__':
    reports=[]
    if '--cinematic' in sys.argv or len(sys.argv)==1: reports.append(cinematic())
    if '--gameplay' in sys.argv or len(sys.argv)==1:
        for args in [('exploration',62,0,661),('combat',70,1,662),('boss',76,2,663),('dawn',58,0,664)]:
            reports.append(phonk(*args)); print('Composed '+args[0],flush=True)
    merged={entry['name']:entry for entry in reports}
    for name in ['opening-cinematic','exploration','combat','boss','dawn']:
        if name in merged or not (OUT/(name+'.ogg')).exists(): continue
        with wave.open(str(OUT/(name+'.wav')),'rb') as audio: seconds=audio.getnframes()/audio.getframerate()
        merged[name]={'name':name,'seconds':seconds,'wav':str((OUT/(name+'.wav')).relative_to(ROOT)),
          'ogg':str((OUT/(name+'.ogg')).relative_to(ROOT)),'sha256':hashlib.sha256((OUT/(name+'.ogg')).read_bytes()).hexdigest()}
    (OUT/'production.json').write_text(json.dumps({'original_music':True,'external_samples':False,
      'style':'Slowed dark fantasy phonk for play; dedicated event-scored cinematic opening; menu unchanged',
      'tracks':list(merged.values())},indent=2))
    print(json.dumps(reports,indent=2))
