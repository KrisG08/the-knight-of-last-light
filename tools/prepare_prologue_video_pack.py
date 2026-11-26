"""Validate the pending cinematic and export per-shot video prompts/subtitles.

This tool never fabricates video from still images. Missing AI clips remain
explicitly missing; the current runtime film and its timing are not modified.
"""
import json
import hashlib
import struct
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / 'art/cinematics/opening-v6'
LANGUAGES = {'en', 'bg', 'ru', 'fr', 'ar'}


def timestamp(seconds):
    milliseconds = round(seconds * 1000)
    hours, milliseconds = divmod(milliseconds, 3600000)
    minutes, milliseconds = divmod(milliseconds, 60000)
    secs, milliseconds = divmod(milliseconds, 1000)
    return '%02d:%02d:%02d,%03d' % (hours, minutes, secs, milliseconds)


def narration_audio(plan):
    manifest = json.loads((PACK / 'narration/manifest.json').read_text(encoding='utf-8'))
    ffmpeg = ROOT / '.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
    count = 0
    for shot in plan['shots']:
        key = hashlib.sha256(('narrator\n' + shot['narration']['en'].strip()).encode('utf-8')).hexdigest()[:20]
        line = manifest['lines'][key]
        assert line['source'] == shot['narration']['en'] and line['speaker'] == 'narrator'
        assert set(line['clips']) == LANGUAGES
        shot['audio'] = {}
        for language in sorted(LANGUAGES):
            metadata = line['metadata'][language]
            assert line['clips'][language].startswith('res://')
            path = ROOT / line['clips'][language][6:]
            relative = path.resolve().relative_to(PACK.resolve())
            assert metadata['text'] == shot['narration'][language]
            assert 0 < metadata['seconds'] <= shot['duration'] - 0.8
            assert 1 <= metadata['tempo'] <= 1.25
            assert hashlib.sha256(path.read_bytes()).hexdigest() == metadata['sha256']
            subprocess.run([str(ffmpeg), '-v', 'error', '-i', str(path), '-f', 'null', '-'], check=True)
            shot['audio'][language] = relative.as_posix()
            count += 1
    return count


def review_page(plan, report):
    data = json.dumps(plan, ensure_ascii=False).replace('</', '<\\/')
    template = '''<!doctype html>
<html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>The Last Lantern — opening storyboard</title>
<style>
*{box-sizing:border-box}body{margin:0;background:#0c0b13;color:#e7e1ef;font:16px/1.55 system-ui,sans-serif}header,main,footer{max-width:1300px;margin:auto;padding:24px}header{display:flex;justify-content:space-between;gap:24px;align-items:center}h1{font:600 36px Georgia,serif;margin:2px 0}p{margin:8px 0;color:#c5bdd1}.status{color:#b99ce5;font-size:13px;letter-spacing:1px;text-transform:uppercase}select,button{font:inherit;background:#211a30;color:#eee5fc;border:1px solid #645076;border-radius:8px;padding:10px;cursor:pointer}select:focus,button:focus-visible{outline:2px solid #c5a0ff}.notice{border-left:3px solid #a47ad4;padding:12px 18px;background:#1b1626}.viewer{position:relative;margin-top:24px}.viewer img{display:block;width:100%;aspect-ratio:16/9;object-fit:contain;background:#050507;border-radius:12px}.caption{font-size:21px;min-height:80px;margin:20px 0}.transport{display:flex;align-items:center;gap:16px;flex-wrap:wrap}audio{flex:1;min-width:220px;height:40px}nav{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin:24px 0}nav button{padding:0;overflow:hidden;text-align:left}nav button.active{border:2px solid #d5acff;background:#3c2c50}nav img{display:block;width:100%;aspect-ratio:16/9;object-fit:cover}nav span{display:block;padding:8px 12px;font-size:14px}.direction{border-top:1px solid #393041;padding-top:16px}footer{font-size:13px;color:#9d92ab}@media(max-width:600px){header{display:block}nav{grid-template-columns:repeat(2,1fr)}.caption{font-size:18px}h1{font-size:30px}}
</style>
<header><div><div class="status">Opening v6 • Production review</div><h1>The Last Lantern</h1></div><label>Narration language <select id="language"><option value="bg">Български</option><option value="en">English</option><option value="ru">Русский</option><option value="fr">Français</option><option value="ar">العربية</option></select></label></header>
<main><div class="notice">Storyboard only: these are eight still keyframes and localized narration, not the finished AI video. The playable game's current opening remains unchanged.</div><section class="viewer"><img id="frame" alt="Selected opening keyframe"></section><div class="caption" id="caption"></div><div class="transport"><button id="previous">← Previous</button><strong id="shotLabel"></strong><button id="next">Next →</button><audio id="voice" controls preload="none"></audio></div><nav id="shots" aria-label="Opening scenes"></nav><section class="direction"><h2>Motion and camera direction</h2><p id="action"></p><p id="camera"></p></section></main>
<footer>Eight keyframes • __VOICE_COUNT__ verified narration clips • __VIDEO_COUNT__ supplied video clips. Review appearance and story before producing video; this page is not a game build.</footer>
<script>
const plan=__PLAN__;let index=0;const byId=id=>document.getElementById(id);const voice=byId('voice');
function show(next){index=(next+plan.shots.length)%plan.shots.length;const shot=plan.shots[index],language=byId('language').value;voice.pause();voice.src=shot.audio[language];byId('frame').src=shot.keyframe;byId('frame').alt=shot.id;byId('caption').textContent=shot.narration[language];byId('caption').lang=language;byId('caption').dir=language==='ar'?'rtl':'ltr';byId('shotLabel').textContent=`${index+1} / ${plan.shots.length} · ${shot.start}–${shot.start+shot.duration}s`;byId('action').textContent=shot.action;byId('camera').textContent=shot.camera;document.querySelectorAll('nav button').forEach((button,i)=>button.classList.toggle('active',i===index));}
plan.shots.forEach((shot,i)=>{const button=document.createElement('button'),image=document.createElement('img'),label=document.createElement('span');image.src=shot.keyframe;image.alt='';image.loading='lazy';label.textContent=shot.id;button.append(image,label);button.addEventListener('click',()=>show(i));byId('shots').append(button);});
byId('previous').onclick=()=>show(index-1);byId('next').onclick=()=>show(index+1);byId('language').onchange=()=>show(index);document.addEventListener('keydown',event=>{if(event.target.tagName==='SELECT'||event.target.tagName==='AUDIO')return;if(event.key==='ArrowLeft')show(index-1);if(event.key==='ArrowRight')show(index+1);});show(0);
</script></html>'''
    output = template.replace('__PLAN__', data).replace('__VOICE_COUNT__', str(report['narration_clips_verified'])).replace('__VIDEO_COUNT__', str(report['video_clips_present']))
    (PACK / 'Review.html').write_text(output, encoding='utf-8')


def main():
    plan = json.loads((PACK / 'production.json').read_text(encoding='utf-8-sig'))
    assert set(plan['languages']) == LANGUAGES
    assert plan['aspect_ratio'] == '16:9'
    assert len(plan['shots']) == 8
    clock = 0
    seen = set()
    keyframes = 0
    clips = 0
    (PACK / 'video-prompts').mkdir(exist_ok=True)
    (PACK / 'subtitles-draft').mkdir(exist_ok=True)
    subtitle_entries = {language: [] for language in sorted(LANGUAGES)}
    for i, shot in enumerate(plan['shots'], 1):
        assert shot['id'] not in seen
        seen.add(shot['id'])
        assert shot['start'] == clock and shot['duration'] > 0
        assert set(shot['narration']) == LANGUAGES
        assert all(text.strip() for text in shot['narration'].values())
        for field in ('keyframe', 'clip'):
            path = (PACK / shot[field]).resolve()
            assert PACK.resolve() in path.parents, 'Media path escapes production pack'
        keyframe_path = PACK / shot['keyframe']
        if keyframe_path.is_file():
            pixels = keyframe_path.read_bytes()
            assert pixels[:8] == b'\x89PNG\r\n\x1a\n'
            width, height = struct.unpack('>II', pixels[16:24])
            assert width >= 1280 and height >= 720 and abs(width / height - 16 / 9) < 0.01
            keyframes += 1
        clips += (PACK / shot['clip']).is_file()
        prompt = '\n'.join([
            'SHOT ' + shot['id'],
            'Input: ' + shot['keyframe'],
            'Target: %s seconds, 16:9. Generate actual temporal motion.' % shot['duration'],
            'Maintain the provided character identity, equipment, costume and architecture.',
            'Subject and environment action: ' + shot['action'],
            'Camera: ' + shot['camera'],
            'Natural weight, grounded feet, coherent hands, stable faces and heraldry.',
            'Real wind response in cloth, hair, foliage and clouds; consistent physical light.',
            'No new characters, costume changes, body morphing, teleporting props or camera-only still pan.',
            'No baked narration, dialogue, captions, logo or text. Keep output private.',
            'Sound direction for later mix: ' + shot['sound'],
            'Do not purchase credits or submit a paid upgrade.',
        ])
        (PACK / 'video-prompts' / (shot['id'] + '.txt')).write_text(prompt + '\n', encoding='utf-8')
        for language in sorted(LANGUAGES):
            subtitle_entries[language].append('%d\n%s --> %s\n%s\n' % (
                i, timestamp(clock + 0.4), timestamp(clock + shot['duration'] - 0.4),
                shot['narration'][language],
            ))
        clock += shot['duration']
    assert clock == plan['target_duration_seconds']
    for language, entries in subtitle_entries.items():
        (PACK / 'subtitles-draft' / (language + '.srt')).write_text('\n'.join(entries), encoding='utf-8')
    voice_count = narration_audio(plan)
    result = {
        'timeline_valid': True, 'duration_seconds': clock,
        'localized_narrative_units': len(plan['shots']) * len(LANGUAGES),
        'keyframes_present': keyframes, 'video_clips_present': clips,
        'narration_clips_verified': voice_count,
        'ready_for_runtime_integration': False,
        'note': 'Draft timing only; actual video, voice duration and motion review are still required.'
    }
    (PACK / 'preflight.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    if keyframes == len(plan['shots']):
        review_page(plan, result)
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
