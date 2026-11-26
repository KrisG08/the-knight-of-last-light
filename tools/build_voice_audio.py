"""Offline development tool: render authored, localized lines into bundled speech.

No requests are made by the game. Only project dialogue is sent for synthesis.
Requires edge-tts in .tools/voice-build/python and the Windows trust-store PEM.
"""
import argparse
import asyncio
import json
import os
import hashlib
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools/voice-build/python'))
import edge_tts
import edge_tts.communicate
import edge_tts.voices

TRUST = ROOT / '.tools/voice-build/windows-ca.pem'
if TRUST.exists():
    edge_tts.communicate._SSL_CTX.load_verify_locations(str(TRUST))
    edge_tts.voices._SSL_CTX.load_verify_locations(str(TRUST))

VOICES = {
    'en': ('en-GB-RyanNeural', 'en-GB-SoniaNeural'),
    'bg': ('bg-BG-BorislavNeural', 'bg-BG-KalinaNeural'),
    'ru': ('ru-RU-SvetlanaNeural', 'ru-RU-SvetlanaNeural'),
    'fr': ('fr-FR-HenriNeural', 'fr-FR-DeniseNeural'),
    'ar': ('ar-EG-ShakirNeural', 'ar-EG-SalmaNeural'),
}

async def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sample', action='store_true')
    parser.add_argument('--language', choices=list(VOICES))
    parser.add_argument('--list-voices', action='store_true')
    parser.add_argument('--voice-name')
    parser.add_argument('--prologue-plan', type=Path, help='Stage a new opening outside runtime; preserve the current voice manifest')
    args = parser.parse_args()
    if args.list_voices:
        voices = await edge_tts.list_voices()
        (ROOT / '.tools/voice-build/available-voices.json').write_text(json.dumps(voices,ensure_ascii=False,indent=2),encoding='utf-8')
        for voice in voices:
            if voice['Locale'].split('-')[0] in VOICES:
                print(voice['ShortName'],voice['Gender'],flush=True)
        return
    output = ROOT / '.tools/voice-build/sample.mp3'
    if args.sample:
        language = args.language or 'bg'
        sample_text = 'Мракът покри кралството. Една светлина все още гори.'
        if args.language:
            sample_script = json.loads((ROOT / '.tools/voice-build/script.json').read_text(encoding='utf-8'))
            sample_text = next(iter(sample_script['lines'].values()))['text'][language]
            output = ROOT / ('.tools/voice-build/probe-'+language+'-'+(args.voice_name or VOICES[language][0])+'.mp3')
        await edge_tts.Communicate(
            sample_text, args.voice_name or VOICES[language][0], rate='-8%', pitch='-6Hz',
            connect_timeout=20, receive_timeout=30,
        ).save(str(output))
        print('VOICE SAMPLE', output.stat().st_size, flush=True)
        return

    if args.prologue_plan:
        plan_path = args.prologue_plan.resolve()
        plan_path.relative_to(ROOT)
        plan = json.loads(plan_path.read_text(encoding='utf-8-sig'))
        lines = {}
        for shot in plan['shots']:
            source = shot['narration']['en']
            key = hashlib.sha256(('narrator\n'+source.strip()).encode('utf-8')).hexdigest()[:20]
            lines[key] = {'source': source, 'speaker': 'narrator', 'text': shot['narration']}
        script = {'lines': lines,
                  'opening': {'captions': [s['narration']['en'] for s in plan['shots']],
                              'durations': [s['duration'] for s in plan['shots']]},
                  'victory': {'captions': [], 'durations': []}}
    else:
        script_path = ROOT / '.tools/voice-build/script.json'
        script = json.loads(script_path.read_text(encoding='utf-8'))
    ffmpeg = ROOT / '.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
    masters = plan_path.parent / 'voice-masters' if args.prologue_plan else ROOT / '.tools/voice-build/masters'
    masters.mkdir(parents=True, exist_ok=True)
    destination = plan_path.parent / 'narration' if args.prologue_plan else ROOT / 'assets/audio/voice'
    destination.mkdir(parents=True, exist_ok=True)
    manifest_path = destination / 'manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8')) if manifest_path.exists() else {'version': 1, 'languages': list(VOICES), 'lines': {}}
    limiter = asyncio.Semaphore(2)
    async def render_one(key, entry, language, names):
        async with limiter:
            target = manifest['lines'].setdefault(key, {'source': entry['source'], 'speaker': entry['speaker'], 'clips': {}, 'metadata': {}})
            localized = entry['text'][language]
            if language != 'en' and localized == entry['source']:
                raise ValueError('Missing localized speech: '+language+' '+key)
            voice = names[1 if entry['speaker'] == 'lyra' else 0]
            rate = '-6%' if entry['speaker'] == 'lyra' else '-8%'
            pitch = '-3Hz' if entry['speaker'] == 'lyra' else '-6Hz'
            # Reuse only exact-input masters. Never overwrite a different take.
            fingerprint = hashlib.sha256((localized+voice+rate+pitch).encode('utf-8')).hexdigest()[:12]
            master = masters / (language+'-'+key+'-'+fingerprint+'.mp3')
            receipt = master.with_suffix('.complete.json')
            existing = destination / language / (key+'.ogg')
            metadata = target['metadata'].get(language,{})
            if (existing.exists() and metadata.get('text') == localized and metadata.get('voice') == voice
                    and hashlib.sha256(existing.read_bytes()).hexdigest() == metadata.get('sha256')):
                print('VOICE CACHED', language, key, flush=True)
                return
            complete_master = (master.exists() and receipt.exists()
                and json.loads(receipt.read_text(encoding='utf-8')).get('sha256') == hashlib.sha256(master.read_bytes()).hexdigest())
            if not complete_master:
                last_error = None
                for attempt in range(3):
                    try:
                        partial = master.with_suffix('.partial.mp3')
                        await edge_tts.Communicate(localized, voice, rate=rate, pitch=pitch,
                            connect_timeout=20, receive_timeout=40).save(str(partial))
                        os.replace(str(partial),str(master))
                        receipt.write_text(json.dumps({'sha256': hashlib.sha256(master.read_bytes()).hexdigest()}),encoding='utf-8')
                        last_error = None
                        break
                    except Exception as error:
                        last_error = error
                        await asyncio.sleep(2+attempt*2)
                if last_error:
                    raise last_error
            raw = subprocess.run([str(ffmpeg), '-hide_banner', '-i', str(master)], capture_output=True, text=True).stderr
            match = re.search(r'Duration: (\d+):(\d+):(\d+(?:\.\d+)?)', raw)
            if not match:
                raise ValueError('Cannot decode speech master: '+str(master))
            duration = int(match[1])*3600+int(match[2])*60+float(match[3])
            budget = None
            for film in ('opening', 'victory'):
                if entry['source'] in script[film]['captions']:
                    budget = script[film]['durations'][script[film]['captions'].index(entry['source'])] - 1.0
            tempo = max(1.0, duration/budget) if budget else 1.0
            if tempo > 1.25:
                raise ValueError('Narration needs a longer shot: '+language+' '+entry['source'])
            folder = destination / language
            folder.mkdir(exist_ok=True)
            clip = folder / (key+'.ogg')
            filters = 'loudnorm=I=-18:TP=-2:LRA=7'
            if tempo > 1.001:
                filters += ',atempo={:.6f}'.format(tempo)
            subprocess.run([str(ffmpeg), '-hide_banner', '-loglevel', 'error', '-y', '-i', str(master),
                '-af', filters, '-ar', '24000', '-ac', '1', '-c:a', 'libvorbis', '-q:a', '4', str(clip)], check=True)
            target['clips'][language] = 'res://'+clip.relative_to(ROOT).as_posix()
            target['metadata'][language] = {'voice': voice, 'text': localized, 'seconds': round(duration/tempo,3),
                'tempo': round(tempo,6), 'sha256': hashlib.sha256(clip.read_bytes()).hexdigest()}
            manifest_pending = manifest_path.with_suffix('.json.tmp')
            manifest_pending.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
            os.replace(str(manifest_pending),str(manifest_path))
            print('VOICE', language, key, round(duration/tempo,2), flush=True)
    jobs = [render_one(key, entry, language, names)
        for key, entry in script['lines'].items()
        for language, names in VOICES.items()
        if not args.language or language == args.language]
    await asyncio.gather(*jobs)
    expected = len(script['lines'])*5
    actual = sum(len(line['clips']) for line in manifest['lines'].values())
    print('BUNDLED VOICE COVERAGE', actual, '/', expected, flush=True)

if __name__ == '__main__':
    asyncio.run(main())
