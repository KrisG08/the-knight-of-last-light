"""Generate nearby covered UV coordinate data, never modify color images.

Only Python's standard library is required. Multi-source breadth-first
propagation assigns the nearest covered grid cell under Manhattan distance.
"""
from array import array
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SIZE = 512
DIRECTORY = ROOT / '.tools/review/front-uv-coverage'


def build(path):
    mask = path.read_bytes()
    assert len(mask) == SIZE * SIZE
    nearest = array('i', [-1]) * len(mask)
    queue = deque()
    for i, valid in enumerate(mask):
        if valid:
            nearest[i] = i
            queue.append(i)
    assert queue, path
    while queue:
        i = queue.popleft()
        x = i % SIZE
        candidates = []
        if x:
            candidates.append(i - 1)
        if x < SIZE - 1:
            candidates.append(i + 1)
        if i >= SIZE:
            candidates.append(i - SIZE)
        if i < len(mask) - SIZE:
            candidates.append(i + SIZE)
        for other in candidates:
            if nearest[other] < 0:
                nearest[other] = nearest[i]
                queue.append(other)
    data = bytearray(len(mask) * 4)
    for i, covered in enumerate(nearest):
        assert covered >= 0 and mask[covered]
        u = ((2 * (covered % SIZE) + 1) * 65535 + SIZE) // (2 * SIZE)
        v = ((2 * (covered // SIZE) + 1) * 65535 + SIZE) // (2 * SIZE)
        data[i * 4:i * 4 + 4] = bytes((u >> 8, u & 255, v >> 8, v & 255))
    path.with_suffix('.bin').write_bytes(data)
    print('FRONT UV COVERAGE', path.stem, len(data))


if __name__ == '__main__':
    masks = sorted(DIRECTORY.glob('*.mask'))
    assert len(masks) == 10, 'Run Godot front fitter --masks-only first'
    for source in masks:
        build(source)
