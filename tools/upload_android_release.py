"""Publish one specifically owner-authorized continuation release, no other files."""
from pathlib import Path
import sys
import subprocess
import json
import hashlib
ROOT=Path(__file__).resolve().parents[1]
if __name__=='__main__':
    version=sys.argv[1]
    assert version=='0.5.66', 'This upload is scoped to the current authorized feedback revision'
    apk=ROOT/'build/android-releases'/('LastLight-'+version+'.apk')
    assert apk.is_file()
    receipt=ROOT/'.tools/android'/('gofile-upload-v'+version.replace('.','')+'.json')
    subprocess.run(['curl.exe','--fail-with-body','--silent','--show-error','--connect-timeout','30','--max-time','1800',
      '-F','file=@'+str(apk)+';type=application/vnd.android.package-archive','-o',str(receipt),
      'https://upload.gofile.io/uploadfile'],check=True)
    response=json.loads(receipt.read_text(encoding='utf-8'))
    assert response['status']=='ok',response.get('status')
    data=response['data']
    assert data['name']==apk.name and data['size']==apk.stat().st_size
    content=apk.read_bytes()
    assert data['md5']==hashlib.md5(content).hexdigest()
    public={'version':version,'name':apk.name,'bytes':data['size'],'sha256':hashlib.sha256(content).hexdigest(),
      'downloadPage':data['downloadPage'],'owner_authorized_public_delivery':True}
    (ROOT/'build/android-releases'/('LastLight-'+version+'-delivery.json')).write_text(json.dumps(public,indent=2))
    print(json.dumps(public,indent=2),flush=True)
