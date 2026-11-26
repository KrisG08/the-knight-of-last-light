"""Run a Godot acceptance check with isolated settings and an exact log/exit code."""
from pathlib import Path
import subprocess
import os
import sys
ROOT=Path(__file__).resolve().parents[1]
if __name__=='__main__':
    label=sys.argv[1]
    script=sys.argv[2]
    arguments=sys.argv[3:]
    headless='--headless' in arguments
    if headless: arguments.remove('--headless')
    env=dict(os.environ,APPDATA=str(ROOT/'.tools/prologue-v6-test-userdata'))
    command=[str(ROOT/'.tools/godot/Godot_v4.7.2-stable_win64_console.exe'),'--path',str(ROOT)]
    command+=['--headless'] if headless else ['--resolution','1280x720']
    if '--gl' in arguments:
        arguments.remove('--gl')
        command+=['--rendering-method','gl_compatibility']
    command+=['--script',script,'--',*arguments]
    target=ROOT/'.tools/review'/('prologue-v6-'+label+'.log')
    with target.open('w',encoding='utf-8') as log:
        result=subprocess.run(command,cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=190)
    print(target.read_text(encoding='utf-8',errors='replace')[-8000:],flush=True)
    sys.exit(result.returncode)
