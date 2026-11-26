"""Local review MP4; the game itself keeps selectable speech outside the video."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--language', default='bg', choices=['en', 'bg', 'ru', 'fr', 'ar'])
args = parser.parse_args()
manifest = json.loads((ROOT/'assets/audio/voice/manifest.json').read_text(encoding='utf-8'))
script = json.loads((ROOT/'.tools/voice-build/script.json').read_text(encoding='utf-8'))
ffmpeg = ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
command = [str(ffmpeg), '-hide_banner', '-y', '-i', str(ROOT/'.tools/review/opening-v5-review.mp4')]
filters = ['[0:a]volume=0.35[music]']
for index, caption in enumerate(script['opening']['captions']):
    key = hashlib.sha256(('narrator\n'+caption).encode('utf-8')).hexdigest()[:20]
    clip = ROOT/manifest['lines'][key]['clips'][args.language].removeprefix('res://') if hasattr(str,'removeprefix') else ROOT/manifest['lines'][key]['clips'][args.language][6:]
    command += ['-i', str(clip)]
    delay = int(script['opening']['starts'][index]*1000)
    filters.append('[{}:a]adelay={}:all=1[v{}]'.format(index+1,delay,index))
filters.append('[music][v0][v1][v2][v3]amix=inputs=5:normalize=0,alimiter=limit=0.95[a]')
output = ROOT/('.tools/review/opening-v5-'+args.language+'-voiced.mp4')
command += ['-filter_complex', ';'.join(filters), '-map', '0:v:0', '-map', '[a]', '-c:v', 'copy',
    '-c:a', 'aac', '-b:a', '160k', '-t', '40', '-movflags', '+faststart', str(output)]
subprocess.run(command, check=True)
print(output)
