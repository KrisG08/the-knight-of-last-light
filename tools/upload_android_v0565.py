"""Publish only the explicitly owner-authorized Android release to Gofile."""
from pathlib import Path
import subprocess
import json
import hashlib
import urllib.request
ROOT=Path(__file__).resolve().parents[1]
APK=ROOT/'build/android-releases/LastLight-0.5.65.apk'
RECEIPT=ROOT/'.tools/android/gofile-upload-v0565.json'
if __name__=='__main__':
    assert APK.is_file()
    subprocess.run(['curl.exe','--fail-with-body','--connect-timeout','30','--max-time','1800',
      '-F','file=@'+str(APK)+';type=application/vnd.android.package-archive',
      '-o',str(RECEIPT),'https://upload.gofile.io/uploadfile'],check=True)
    result=json.loads(RECEIPT.read_text(encoding='utf-8'))
    assert result['status']=='ok',result.get('status')
    data=result['data']
    assert data['name']==APK.name and data['size']==APK.stat().st_size
    digest=hashlib.md5(APK.read_bytes()).hexdigest()
    assert data['md5']==digest
    public={'version':'0.5.65','name':data['name'],'bytes':data['size'],
      'sha256':hashlib.sha256(APK.read_bytes()).hexdigest(),'downloadPage':data['downloadPage'],
      'owner_authorized_public_upload':True}
    (ROOT/'build/android-releases/LastLight-0.5.65-delivery.json').write_text(json.dumps(public,indent=2))
    print(json.dumps(public,indent=2),flush=True)
