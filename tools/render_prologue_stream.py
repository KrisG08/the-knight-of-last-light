"""Render real Godot animation directly into an encoder, without AVI/frame dumps."""
import os
import base64
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / '.tools/movie-render/prologue-v6'
OUT.mkdir(parents=True, exist_ok=True)
FFMPEG = ROOT / '.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
ENGINE = ROOT / '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'

def main():
    env = dict(os.environ, APPDATA=str(ROOT / '.tools/qa-prologue-v6'))
    with (OUT/'render.log').open('w', encoding='utf-8') as log, (OUT/'encoder.log').open('w', encoding='utf-8') as encoder_log:
        engine = subprocess.Popen([str(ENGINE), '--path', str(ROOT), '--resolution', '1920x1080',
            '--fixed-fps', '60', '--script', 'res://tools/render_prologue_v6.gd'], cwd=str(ROOT), env=env,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        encoder = subprocess.Popen([str(FFMPEG), '-hide_banner', '-y', '-f', 'image2pipe',
            '-framerate', '60', '-vcodec', 'mjpeg', '-i', 'pipe:0', '-an', '-c:v', 'libx264',
            '-preset', 'fast', '-crf', '16', '-pix_fmt', 'yuv420p', '-movflags', '+faststart',
            str(OUT/'picture-master.mp4')], stdin=subprocess.PIPE, stdout=encoder_log, stderr=subprocess.STDOUT)
        received = 0
        try:
            try:
                for line in engine.stdout:
                    if line.startswith(b'PROLOGUE_IMAGE '):
                        encoder.stdin.write(base64.b64decode(line[len(b'PROLOGUE_IMAGE '):].strip(),validate=True))
                        received += 1
                    else:
                        message=line.decode('utf-8',errors='replace')
                        log.write(message); log.flush()
                        if 'PROLOGUE_V6_FRAME' in message: print(message.strip(),flush=True)
            finally:
                encoder.stdin.close()
            if encoder.wait() != 0: raise RuntimeError('Encoder failed; see encoder.log')
            if engine.wait(timeout=60) != 0: raise RuntimeError('Godot render failed; see render.log')
            if received != 4800 or 'PROLOGUE_V6_COMPLETE 4800' not in (OUT/'render.log').read_text(encoding='utf-8'):
                raise RuntimeError('Incomplete frame sequence')
            print('Rendered all 4800 authored frames: 1920x1080, 60 fps, 80 seconds', flush=True)
        finally:
            if engine.poll() is None: engine.terminate()
            if encoder.poll() is None: encoder.terminate()

if __name__ == '__main__':
    main()
