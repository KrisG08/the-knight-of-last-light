"""Install verified authored film and staged translations/speech, retaining old film."""
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[1]
PACK=ROOT/'art/cinematics/opening-v6'
OUT=ROOT/'.tools/movie-render/prologue-v6'
FFMPEG=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'

def verify(path,width):
    command=[str(FFMPEG),'-hide_banner','-threads','1','-i',str(path),'-map','0:v','-progress','pipe:1',
             '-nostats','-r','30','-fps_mode','cfr','-f','null','NUL']
    result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True)
    progress=result.stdout.decode('utf-8')
    description=result.stderr.decode('utf-8',errors='replace')
    (ROOT/'.tools/review'/('decode-'+path.name+'.txt')).write_text(description+'\n'+progress,encoding='utf-8')
    frames=re.findall(r'^frame=(\d+)$',progress,re.M)
    assert frames and int(frames[-1])==2400,(path,'Unexpected decoded frame count',frames[-1:])
    assert '{}x{}'.format(width,width*9//16) in description and '30 tbr' in description
    duplicates=re.findall(r'^dup_frames=(\d+)$',progress,re.M)
    assert duplicates and int(duplicates[-1])<=24, 'Unexpected held frame count: '+str(duplicates[-1:])
    assert 'Coefficient index overflow' not in description and 'Broken file' not in description, 'Corrupt decoded video'
    assert 'Duration: 00:01:20.' in description,description[:600]
    print('Verified full video decode',path.name,frames[-1],flush=True)

def main():
    plan=json.loads((PACK/'production.json').read_text(encoding='utf-8'))
    voices=json.loads((PACK/'narration/manifest.json').read_text(encoding='utf-8'))
    assert sum(s['duration'] for s in plan['shots'])==80 and len(plan['shots'])==8
    for name,width in [('desktop',1920),('mobile',1280)]:
        verify(OUT/('opening-'+name+'-picture30.ogv'),width)
    for key,entry in voices['lines'].items():
        assert key==hashlib.sha256(('narrator\n'+entry['source']).encode('utf-8')).hexdigest()[:20]
        for language,path in entry['clips'].items():
            assert language in plan['languages'] and (ROOT/path[6:]).is_file()
            assert hashlib.sha256((ROOT/path[6:]).read_bytes()).hexdigest()==entry['metadata'][language]['sha256']
            assert entry['metadata'][language]['seconds']<=9.01
    archive=ROOT/'art/cinematics/opening-v5-archive'
    archive.mkdir(parents=True,exist_ok=True)
    for name in ['opening_film.ogv','opening_mobile.ogv']:
        if not (archive/name).exists(): shutil.copy2(ROOT/'assets/cinematics'/name,archive/name)
    source=ROOT/'game/presentation/film_script.gd'
    if not (archive/'film_script.gd').exists(): shutil.copy2(source,archive/'film_script.gd')
    legacy=ROOT/'tools/legacy_opening_timeline.gd'
    if not legacy.exists(): shutil.copy2(archive/'film_script.gd',legacy)
    renderer=ROOT/'tools/render_opening_film.gd'
    renderer.write_text(renderer.read_text(encoding='utf-8').replace(
        'res://game/presentation/film_script.gd','res://tools/legacy_opening_timeline.gd'),encoding='utf-8')
    runtime_manifest_path=ROOT/'assets/audio/voice/manifest.json'
    runtime=json.loads(runtime_manifest_path.read_text(encoding='utf-8'))
    if not (archive/'voice-manifest.json').exists(): shutil.copy2(runtime_manifest_path,archive/'voice-manifest.json')
    for key,entry in voices['lines'].items():
        updated=json.loads(json.dumps(entry))
        for language,path in entry['clips'].items():
            target=ROOT/'assets/audio/voice'/language/(key+'.ogg')
            target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(ROOT/path[6:],target)
            updated['clips'][language]='res://'+target.relative_to(ROOT).as_posix()
        runtime['lines'][key]=updated
    runtime_manifest_path.write_text(json.dumps(runtime,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    translations={s['narration']['en']:[s['narration'][code] for code in ['bg','ru','fr','ar']] for s in plan['shots']}
    (ROOT/'assets/localization/prologue_v6.json').write_text(json.dumps(translations,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    old=(archive/'film_script.gd').read_text(encoding='utf-8')
    victory=re.search(r'^const VICTORY = (.+)$',old,re.M).group(1)
    script='extends RefCounted\n## Authored 80-second film; timing is shared with captions and localized speech.\n'
    script+='const STARTS = '+str([s['start']*1.0 for s in plan['shots']])+'\n'
    script+='const DURATIONS = '+str([s['duration']*1.0 for s in plan['shots']])+'\nconst LENGTH = 80.0\n'
    script+='const CAPTIONS = '+json.dumps([s['narration']['en'] for s in plan['shots']],ensure_ascii=False,indent=2)+'\n'
    script+='const VICTORY = '+victory+'\n'
    script+='static func shot(time: float) -> int:\n\tfor index in range(STARTS.size()-1,-1,-1):\n\t\tif time>=STARTS[index]: return index\n\treturn 0\n'
    source.write_text(script,encoding='utf-8')
    for platform,name in [('desktop','opening_film.ogv'),('mobile','opening_mobile.ogv')]:
        shutil.copy2(OUT/('opening-'+platform+'-picture30.ogv'),ROOT/'assets/cinematics'/name)
    shutil.copy2(OUT/'opening-score.ogg',ROOT/'assets/cinematics/opening_score.ogg')
    receipt_path=OUT/'picture30-receipt.json'
    receipt=json.loads(receipt_path.read_text(encoding='utf-8'))
    receipt['installed']=True
    receipt['localized_narration_clips']=40
    receipt['legacy_preserved_at']=archive.relative_to(ROOT).as_posix()
    (PACK/'authored-production.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
    print('Installed authored 80-second film, 40 localized speech clips, four translated caption catalogs',flush=True)

if __name__=='__main__': main()
