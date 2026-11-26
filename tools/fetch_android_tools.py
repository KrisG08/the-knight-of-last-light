"""Fetch official tools using bounded HTTP ranges; extract only Android template.
All writes stay under .tools/android or .tools/templates in this workspace.
"""
import concurrent.futures
import io
import pathlib
import struct
import urllib.request
import zipfile
import zlib
import hashlib
import sys
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
DEST = ROOT / '.tools/android'
DEST.mkdir(parents=True, exist_ok=True)

def part(url, start, end):
    for attempt in range(3):
        try:
            request = urllib.request.Request(url, headers={'Range': 'bytes=%d-%d' % (start, end)})
            with urllib.request.urlopen(request, timeout=25) as response:
                data = response.read()
                if len(data) != end - start + 1:
                    raise ValueError('Server ignored bounded range')
                return data
        except Exception:
            if attempt == 2:
                raise

def span(url, start, length):
    ranges = [(offset, min(start+length-1, offset+1048575)) for offset in range(start, start+length, 1048576)]
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        return b''.join(pool.map(lambda bounds: part(url, *bounds), ranges))

def template():
    url = 'https://godot-releases.nbg1.your-objectstorage.com/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz'
    size = 1281349702
    tail = part(url, size-65536, size-1)
    position = tail.rfind(b'PK\x05\x06')
    end = struct.unpack_from('<4s4H2LH', tail, position)
    central = span(url, end[6], end[5])
    offset = 0
    while central[offset:offset+4] == b'PK\x01\x02':
        fields = struct.unpack_from('<4s6H3L5H2L', central, offset)
        name_len, extra_len, comment_len = fields[10:13]
        name = central[offset+46:offset+46+name_len].decode()
        if name == 'templates/android_debug.apk':
            crc, compressed, original = fields[7:10]
            local_at = fields[16]
            header = part(url, local_at, local_at+29)
            local = struct.unpack('<4s5H3L2H', header)
            data = span(url, local_at+30+local[9]+local[10], compressed)
            decoded = zlib.decompress(data, -15) if fields[4] == 8 else data
            if len(decoded) != original or zlib.crc32(decoded) & 0xffffffff != crc:
                raise ValueError('Android template CRC mismatch')
            (ROOT / '.tools/templates/android_debug.apk').write_bytes(decoded)
            print('Android template extracted and CRC verified', flush=True)
            return
        offset += 46+name_len+extra_len+comment_len
    raise ValueError('Matching Android template missing')

def sdk():
    url = 'https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip'
    data = span(url, 0, 155655386)
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        if archive.testzip() is not None:
            raise ValueError('SDK archive CRC mismatch')
        target = DEST / 'sdk/cmdline-tools/latest'
        for entry in archive.infolist():
            path = pathlib.PurePosixPath(entry.filename)
            if path.parts[0] != 'cmdline-tools' or '..' in path.parts:
                raise ValueError('Unexpected SDK archive path')
            output = target.joinpath(*path.parts[1:])
            if entry.is_dir():
                output.mkdir(parents=True, exist_ok=True)
            else:
                output.parent.mkdir(parents=True, exist_ok=True)
                output.write_bytes(archive.read(entry))
    print('Official SDK command line tools extracted and CRC verified', flush=True)

def packages():
    root = ET.parse(DEST / 'repository.xml').getroot()
    needed = {'platform-tools': 'platform-tools', 'build-tools;35.0.1': 'build-tools/35.0.1', 'platforms;android-35': 'platforms/android-35'}
    for package in root.findall('remotePackage'):
        name = package.attrib['path']
        if name not in needed:
            continue
        for archive in package.findall('archives/archive'):
            host = archive.findtext('host-os')
            if host not in (None, 'windows'):
                continue
            full = archive.find('complete')
            data = span('https://dl.google.com/android/repository/' + full.findtext('url'), 0, int(full.findtext('size')))
            if hashlib.sha1(data).hexdigest() != full.findtext('checksum'):
                raise ValueError('Official SDK checksum mismatch: '+name)
            target = DEST / 'sdk' / needed[name]
            with zipfile.ZipFile(io.BytesIO(data)) as zipped:
                for entry in zipped.infolist():
                    path = pathlib.PurePosixPath(entry.filename)
                    if '..' in path.parts or path.is_absolute():
                        raise ValueError('Unexpected SDK package path')
                    output = target.joinpath(*path.parts[1:])
                    if entry.is_dir():
                        output.mkdir(parents=True, exist_ok=True)
                    else:
                        output.parent.mkdir(parents=True, exist_ok=True)
                        output.write_bytes(zipped.read(entry))
            print('Installed verified '+name, flush=True)
    for license in root.findall('license'):
        license_dir = DEST / 'sdk/licenses'
        license_dir.mkdir(exist_ok=True)
        (license_dir / license.attrib['id']).write_text(hashlib.sha1(license.text.encode()).hexdigest()+'\n')

if __name__ == '__main__' and 'packages' in sys.argv:
    packages()
elif __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        for result in pool.map(lambda task: task(), [template, sdk]):
            pass
