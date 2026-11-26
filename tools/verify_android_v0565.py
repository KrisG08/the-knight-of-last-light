"""Check install/update identity and APK version independently of export success."""
from pathlib import Path
import subprocess
import re
import json
ROOT=Path(__file__).resolve().parents[1]
SDK=ROOT/'.tools/android/sdk/build-tools/35.0.1'
JAVA=Path('C:/Program Files/Microsoft/jdk-17.0.19.10-hotspot/bin/java.exe')
APK=ROOT/'build/android-releases/LastLight-0.5.65.apk'
PREVIOUS=ROOT/'build/android-releases/LastLight-0.5.64.apk'
def certificate(path):
    result=subprocess.run([str(JAVA),'-jar',str(SDK/'lib/apksigner.jar'),'verify','--print-certs',str(path)],capture_output=True,check=True)
    text=result.stdout.decode('utf-8',errors='replace')
    return re.search(r'Signer #1 certificate SHA-256 digest: ([0-9a-f]+)',text).group(1)
if __name__=='__main__':
    current=certificate(APK); previous=certificate(PREVIOUS)
    assert current==previous,'APK cannot update the preceding version: signer changed'
    result=subprocess.run([str(SDK/'aapt2.exe'),'dump','badging',str(APK)],capture_output=True,check=True)
    package=result.stdout.decode('utf-8',errors='replace').splitlines()[0]
    assert "name='org.lastlight.knight'" in package and "versionCode='70'" in package and "versionName='0.5.65'" in package,package
    report={'package':package,'certificate_sha256':current,'same_signer_as':'0.5.64','update_identity':'PASS'}
    (ROOT/'.tools/review/prologue-v6-android-update.json').write_text(json.dumps(report,indent=2))
    print(json.dumps(report,indent=2))
