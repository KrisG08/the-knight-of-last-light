"""Install the validated film revision and four original gameplay score loops."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v7'
FF=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
def verify(path,width):
    result=subprocess.run([str(FF),'-hide_banner','-threads','1','-i',str(path),'-map','0:v',
       '-progress','pipe:1','-nostats','-r','30','-fps_mode','cfr','-f','null','NUL'],capture_output=True,check=True)
    progress=result.stdout.decode(); description=result.stderr.decode(errors='replace')
    (ROOT/'.tools/review'/('v7-decode-'+path.name+'.log')).write_text(description+'\n'+progress)
    frames=re.findall(r'^frame=(\d+)$',progress,re.M)
    duplicated=re.findall(r'^dup_frames=(\d+)$',progress,re.M)
    dropped=re.findall(r'^drop_frames=(\d+)$',progress,re.M)
    assert frames and int(frames[-1])==2400
    assert f'{width}x{width*9//16}' in description and '30 tbr' in description and 'Duration: 00:01:20.' in description
    assert 'Coefficient index overflow' not in description and 'Broken file' not in description
    assert duplicated and int(duplicated[-1])<=12
    assert dropped and int(dropped[-1])==0
    print('Full decode PASS: '+path.name,flush=True)
if __name__=='__main__':
    for platform,width in [('desktop',1920),('mobile',1280)]: verify(OUT/('opening-'+platform+'.ogv'),width)
    plan=json.loads((ROOT/'art/cinematics/opening-v7/production.json').read_text(encoding='utf-8'))
    assert len(plan['shots'])==8 and abs(sum(s['duration'] for s in plan['shots'])-80)<.0001
    film=ROOT/'game/presentation/film_script.gd'
    backup=ROOT/'art/cinematics/opening-v6/film_script.gd'
    if not backup.exists(): shutil.copy2(film,backup)
    text=film.read_text(encoding='utf-8')
    text=re.sub(r'^const STARTS = .*$', 'const STARTS = '+str([s['start'] for s in plan['shots']]),text,flags=re.M)
    text=re.sub(r'^const DURATIONS = .*$', 'const DURATIONS = '+str([s['duration'] for s in plan['shots']]),text,flags=re.M)
    film.write_text(text,encoding='utf-8')
    for platform,name in [('desktop','opening_film.ogv'),('mobile','opening_mobile.ogv')]: shutil.copy2(OUT/('opening-'+platform+'.ogv'),ROOT/'assets/cinematics'/name)
    shutil.copy2(ROOT/'.tools/music-masters/v0566/opening-cinematic.ogg',ROOT/'assets/cinematics/opening_score.ogg')
    preserved=ROOT/'art/audio/music-v0558'; preserved.mkdir(parents=True,exist_ok=True)
    menu=ROOT/'assets/audio/music/menu.ogg'; menu_hash=hashlib.sha256(menu.read_bytes()).hexdigest()
    for name in ['exploration','combat','boss','dawn']:
        target=ROOT/'assets/audio/music'/(name+'.ogg')
        if not (preserved/target.name).exists(): shutil.copy2(target,preserved/target.name)
        shutil.copy2(ROOT/'.tools/music-masters/v0566'/(name+'.ogg'),target)
    assert hashlib.sha256(menu.read_bytes()).hexdigest()==menu_hash
    source=ROOT/'project.godot'; source.write_text(re.sub(r'config/version="[^"]+"','config/version="0.5.66"',source.read_text(encoding='utf-8')),encoding='utf-8')
    presets=ROOT/'export_presets.cfg'; text=presets.read_text(encoding='utf-8')
    text=re.sub(r'version/name="[^"]+"','version/name="0.5.66"',text)
    text=re.sub(r'version/code=\d+','version/code=71',text); presets.write_text(text,encoding='utf-8')
    receipt=json.loads((OUT/'production-receipt.json').read_text())
    receipt.update(installed_version='0.5.66',preserved_menu_sha256=menu_hash,
      music=json.loads((ROOT/'.tools/music-masters/v0566/production.json').read_text()))
    (ROOT/'art/cinematics/opening-v7/authored-production.json').write_text(json.dumps(receipt,indent=2))
    print('Installed v0.5.66: new film, event score, four gameplay loops; menu and old sources preserved')
