"""Package unchanged Theora/Vorbis streams with the native-tested Ogg layout."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v6'
ENCODER=ROOT/'.tools/video-encoder32/imageio_ffmpeg/binaries/ffmpeg-win32-v4.2.2.exe'

def main():
    assert ENCODER.is_file(), 'Use the SHA-256-verified imageio-ffmpeg 0.4.3 win32 wheel recorded in .tools/video-encoder32/source.json'
    report={'encoder':'FFmpeg 4.2.2 Windows 32-bit from imageio-ffmpeg 0.4.3',
            'wheel_sha256':'3b00bb04e8649f60d5ede91aa47b754283d1fa9fd8d40803d9871c8afd72cd50',
            'page_duration_microseconds':20000,'max_interleave_delta_microseconds':100000,
            'video_reencoded':False,'audio_reencoded':False,'files':{}}
    for platform in ['desktop','mobile']:
        source=OUT/('opening-'+platform+'-48k.ogv')
        target=OUT/('opening-'+platform+'-remux32.ogv')
        subprocess.run([str(ENCODER),'-nostdin','-hide_banner','-loglevel','error','-y','-i',str(source),
            '-map','0','-c','copy','-max_interleave_delta','100000','-page_duration','20000',str(target)],check=True)
        report['files'][target.name]={'bytes':target.stat().st_size,'sha256':hashlib.sha256(target.read_bytes()).hexdigest()}
    (OUT/'compatibility-receipt.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print('Native-tested short-page Ogg layout; original encoded picture and score retained')

if __name__=='__main__': main()
