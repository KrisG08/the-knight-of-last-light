"""Verify the new release can update the specified previous signed APK."""
from pathlib import Path
import sys
import subprocess
import re
import json
from verify_android_v0565 import certificate,SDK
ROOT=Path(__file__).resolve().parents[1]
if __name__=='__main__':
    version=sys.argv[1]; previous=sys.argv[2]; code=sys.argv[3]
    folder=ROOT/'build/android-releases'
    apk=folder/('LastLight-'+version+'.apk')
    digest=certificate(apk)
    assert digest==certificate(folder/('LastLight-'+previous+'.apk')),'Update signing identity changed'
    output=subprocess.check_output([str(SDK/'aapt2.exe'),'dump','badging',str(apk)]).decode('utf-8',errors='replace').splitlines()[0]
    assert "name='org.lastlight.knight'" in output and ("versionName='"+version+"'") in output and ("versionCode='"+code+"'") in output,output
    report={'version':version,'package':output,'certificate_sha256':digest,'same_signer_as':previous,'update_identity':'PASS'}
    (ROOT/'.tools/review'/('android-'+version+'-update.json')).write_text(json.dumps(report,indent=2))
    print(json.dumps(report,indent=2))
