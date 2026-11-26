"""Repair Theora page timing from preserved frame packets and recompute Ogg CRCs."""
from pathlib import Path
import hashlib
import json
import zlib

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / '.tools/movie-render/prologue-v6'

def crc(data):
    # Reflect input/output around zlib's native reflected implementation.
    reflected = zlib.crc32(bytes(data).translate(REVERSED), 0xffffffff) ^ 0xffffffff
    return int.from_bytes(reflected.to_bytes(4, 'little').translate(REVERSED), 'big')

TABLE = []
REVERSED = bytes(int(f'{value:08b}'[::-1], 2) for value in range(256))
for index in range(256):
    value = index << 24
    for _ in range(8):
        value = ((value << 1) ^ (0x04c11db7 if value & 0x80000000 else 0)) & 0xffffffff
    TABLE.append(value)

def normalize(platform):
    source = OUT / ('opening-' + platform + '-direct32.ogv')
    target = OUT / ('opening-' + platform + '-timed.ogv')
    serial = None
    packet = bytearray()
    count = frame = key = changed = 0
    payload_hash = hashlib.sha256()
    shift = 8
    with source.open('rb') as src, target.open('wb') as dst:
        while True:
            header = bytearray(src.read(27))
            if not header:
                break
            assert header[:4] == b'OggS'
            laces = src.read(header[26])
            body = bytearray(src.read(sum(laces)))
            original_crc = int.from_bytes(header[22:26], 'little')
            header[22:26] = bytes(4)
            assert crc(header + laces + body) == original_crc, 'Invalid source CRC'
            if serial is None and body.startswith(b'\x80theora'):
                serial = header[14:18]
                packed = int.from_bytes(body[40:42], 'big')
                body[40:42] = ((packed & ~(31 << 5)) | (shift << 5)).to_bytes(2, 'big')
            if header[14:18] == serial:
                at = 0
                expected = -1
                for size in laces:
                    packet.extend(body[at:at+size])
                    at += size
                    if size < 255:
                        if count >= 3:
                            frame += 1
                            payload_hash.update(packet)
                            if packet and not packet[0] & 64:
                                key = frame
                            assert 0 <= frame-key < 1 << shift
                            expected = (key << shift) + frame-key
                        else:
                            expected = 0
                        count += 1
                        packet.clear()
                if int.from_bytes(header[6:14], 'little', signed=True) != expected:
                    changed += 1
                header[6:14] = expected.to_bytes(8, 'little', signed=True)
            header[22:26] = crc(header + laces + body).to_bytes(4, 'little')
            dst.write(header + laces + body)
    assert frame == 4800 and not packet
    return {'file': target.name, 'frames': frame, 'changed_pages': changed,
            'frame_payload_sha256': payload_hash.hexdigest(), 'bytes': target.stat().st_size,
            'sha256': hashlib.sha256(target.read_bytes()).hexdigest(), 'granule_shift': shift}

if __name__ == '__main__':
    receipt = [normalize(platform) for platform in ['desktop', 'mobile']]
    (OUT / 'timing-receipt.json').write_text(json.dumps(receipt, indent=2), encoding='utf-8')
    print(json.dumps(receipt, indent=2))
