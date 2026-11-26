"""Render the revised, time-addressable 3D film without large raw frame dumps."""
from pathlib import Path
import os
import subprocess
import base64
import json
import sys
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.tools/movie-render/prologue-v7'
OUT.mkdir(parents=True,exist_ok=True)
ENGINE=ROOT/'.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
FF=ROOT/'.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe'
if __name__=='__main__':
    patch='--patch' in sys.argv
    ground='--ground-only' in sys.argv
    expected=336 if ground else (906 if patch else 2400)
    name='patch-ground-depth' if ground else ('patch-violet' if patch else 'picture-master')
    log_name=name+'-render.log' if patch or ground else 'render.log'
    env=dict(os.environ,APPDATA=str(ROOT/'.tools/qa-prologue-v7'))
    with (OUT/log_name).open('w',encoding='utf-8') as log,(OUT/(name+'-encoder.log')).open('w',encoding='utf-8') as encoded:
        command=[str(ENGINE),'--path',str(ROOT),'--resolution','1920x1080','--fixed-fps','30','--script','res://tools/render_prologue_v7.gd']
        if ground: command+=['--','--patch-soft-depth']
        elif patch: command+=['--','--patch-violet']
        engine=subprocess.Popen(command,cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        encoder=subprocess.Popen([str(FF),'-nostdin','-hide_banner','-y','-f','image2pipe','-framerate','30',
          '-vcodec','mjpeg','-i','pipe:0','-an','-c:v','libx264','-preset','fast','-crf','16',
          '-pix_fmt','yuv420p','-movflags','+faststart',str(OUT/(name+'-rendering.mp4'))],
          stdin=subprocess.PIPE,stdout=encoded,stderr=subprocess.STDOUT)
        received=0
        completed=False
        try:
            for line in engine.stdout:
                if line.startswith(b'PROLOGUE_IMAGE '):
                    encoder.stdin.write(base64.b64decode(line[len(b'PROLOGUE_IMAGE '):].strip(),validate=True))
                    received+=1
                else:
                    text=line.decode('utf-8',errors='replace'); log.write(text); log.flush()
                    if 'PROLOGUE_V7_FRAME' in text: print(text.strip(),flush=True)
                    if ('PROLOGUE_V7_COMPLETE '+str(expected)) in text:
                        completed=True
                        break
            encoder.stdin.close()
            assert encoder.wait()==0
            assert received==expected and completed
            (OUT/(name+'-rendering.mp4')).replace(OUT/(name+'.mp4'))
            normal_shutdown=True
            try:
                assert engine.wait(timeout=45)==0
            except subprocess.TimeoutExpired:
                # Some Vulkan drivers stall during teardown after the last frame.
                # All 2,400 frames and the encoder must finish before this is allowed.
                normal_shutdown=False
                engine.terminate(); engine.wait(timeout=30)
            receipt_name=name+'-render-receipt.json' if patch or ground else 'render-receipt.json'
            (OUT/receipt_name).write_text(json.dumps({'frames':received,'fps':30,'seconds':expected/30,
              'all_frames_received':completed,'normal_engine_shutdown':normal_shutdown},indent=2))
            print('Complete: '+str(expected)+' authored 1080p frames, 30 fps',flush=True)
        finally:
            if engine.poll() is None: engine.terminate()
            if encoder.poll() is None: encoder.terminate()
