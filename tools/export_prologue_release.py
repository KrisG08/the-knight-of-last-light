"""Portable export equivalent of the platform scripts, usable without PowerShell."""
from pathlib import Path
import subprocess
import os
import shutil
import hashlib
import json
import re
ROOT=Path(__file__).resolve().parents[1]
VERSION=re.search(r'config/version="([^"]+)"',(ROOT/'project.godot').read_text(encoding='utf-8')).group(1)
ENGINE=ROOT/'.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
JAVA=Path('C:/Program Files/Microsoft/jdk-17.0.19.10-hotspot')
SDK=ROOT/'.tools/android/sdk'
ENV=dict(os.environ,APPDATA=str(ROOT/'.tools/userdata'),JAVA_HOME=str(JAVA))
def run(args,label):
    with (ROOT/'.tools/review'/('release-'+VERSION+'-'+label+'.log')).open('w',encoding='utf-8') as log:
        subprocess.run([str(v) for v in args],cwd=ROOT,env=ENV,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=900)
    print(label+' PASS',flush=True)
def engine(args,label):
    run([ENGINE,'--headless','--path',ROOT,*args],label)
def manifest(folder):
    entries=[{'name':p.name,'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
             for p in folder.iterdir() if p.is_file() and p.name!='build_manifest.json']
    (folder/'build_manifest.json').write_text(json.dumps(entries,indent=2))
if __name__=='__main__':
    desktop=ROOT/('build/windows-v'+VERSION.replace('.','')); desktop.mkdir(parents=True,exist_ok=True)
    android=ROOT/'build/android'; android.mkdir(parents=True,exist_ok=True)
    engine(['--editor','--import','--quit'],'export-import')
    engine(['--export-release','Windows Desktop',desktop/'LastLight.exe'],'windows-export')
    engine(['--script','res://tools/write_licenses.gd','--',desktop],'windows-licenses')
    shutil.copy2(ROOT/'docs/BUILD_README.txt',desktop/'README.txt')
    shutil.copy2(ROOT/'docs/ASSET_CREDITS.txt',desktop/'ASSET_CREDITS.txt')
    manifest(desktop)
    engine(['--export-debug','Android',android/'LastLight.apk'],'android-export')
    run([JAVA/'bin/java.exe','-jar',SDK/'build-tools/35.0.1/lib/apksigner.jar','verify','--verbose',android/'LastLight.apk'],'android-signature')
    run([SDK/'build-tools/35.0.1/zipalign.exe','-c','-P','16','-v','4',android/'LastLight.apk'],'android-alignment')
    shutil.copy2(ROOT/'docs/MOBILE.md',android/'README.md')
    shutil.copy2(ROOT/'docs/ASSET_CREDITS.txt',android/'ASSET_CREDITS.txt')
    engine(['--script','res://tools/write_licenses.gd','--',android],'android-licenses')
    manifest(android)
    release=ROOT/('build/android-releases/LastLight-'+VERSION+'.apk')
    release.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(android/'LastLight.apk',release)
    print('Release ready: '+str(release)+' '+str(release.stat().st_size)+' bytes',flush=True)
