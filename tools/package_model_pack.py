"""Copy explicit art-only inputs and package a validated static 3D collection."""
import argparse
import hashlib
import json
import shutil
import struct
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT/'art_exports/Last-Light-Model-Pack-2026-11-24'
PACK.mkdir(parents=True, exist_ok=True)
(PACK/'.gdignore').write_text('', encoding='utf-8')
parser = argparse.ArgumentParser()
parser.add_argument('--prepare', action='store_true')
args = parser.parse_args()

references = json.loads((ROOT/'art/reference-pack/manifest.json').read_text(encoding='utf-8'))
for entry in references['entries']:
    source = ROOT/'art/reference-pack'/entry['file']
    target = PACK/'01-Images-For-3D'/entry['file']
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(str(source), str(target))
    assert hashlib.sha256(target.read_bytes()).hexdigest().upper() == entry['sha256'].upper()
for filename in ('index.html', 'manifest.json', 'prompts.md', 'README.md'):
    shutil.copy2(str(ROOT/'art/reference-pack'/filename), str(PACK/'01-Images-For-3D'/filename))

allowed = [ROOT/'assets/models', ROOT/'assets/materials']
allowed += [ROOT/'assets/vendor'/name for name in ('polyhaven','andy_woodhead','hostile_sources','mythic_fauna')]
for folder in allowed:
    for source in folder.rglob('*'):
        if not source.is_file() or source.suffix in ('.import','.uid'):
            continue
        target = PACK/'04-Godot-Sources'/source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(str(source), str(target))
for folder in (ROOT/'game/presentation', ROOT/'game/world/regions'):
    for source in folder.glob('*.gd'):
        target = PACK/'04-Godot-Sources'/source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(str(source), str(target))
shutil.copy2(str(ROOT/'docs/ASSET_CREDITS.txt'), str(PACK/'ASSET_CREDITS.txt'))

readme = '''LAST LIGHT - MODEL COLLECTION - 2026-11-24

01-Images-For-3D: 52 selected PNG design references. Use individual images if
your chosen image-to-3D tool accepts pictures. These are original concept
references, not screenshots or proof of the resulting mesh quality. Open the
index.html gallery after extracting. No upload to Canva has been performed.

02-GLB: static, self-contained 3D files: assembled character variants, player,
villains with equipment, passive creatures, quest props and imported source art.
03-Worlds: all eleven authored region scenes as static GLB geometry. Buildings,
landmarks, placed props and vegetation are included here, even when they are
normally constructed by code rather than stored as separate model files.
Whole-world exports use simple untextured colors to keep these large geometry
snapshots portable; use the native sources for the original world materials.
04-Godot-Sources: native RES geometry, source GLB/GLTF files, textures, shader
definitions and presentation/region builders. Original paths are preserved.
This is an art-source collection, not a standalone runnable game project.

The GLBs are static geometry snapshots, not complete Godot scenes, game logic,
collision/navigation data, animations or ready-made character rigs. Instanced
geometry is expanded into scene nodes. Native shaders are approximated by
standard materials; Meshy front/rear coloring is baked to vertex colors to avoid
white exports. Portable albedo textures are limited to 1024 pixels; separate
normal/roughness/metallic/AO maps are omitted in favor of scalar materials.
The original full-resolution texture files remain in 04-Godot-Sources.
Animated curse/portal effects, wind, triplanar shading, microscopic
surface wear and lighting will differ from the game. Original sources are kept
alongside for work requiring full fidelity. Do not treat a world scene as one
small image-to-3D object: use individual references for object conversion.

GLB does not imply compatibility with every Canva app. The selected app's input
requirements determine whether to use a PNG reference or a 3D file. These assets
are already 3D; generating a new mesh from one picture is a separate operation.

models.json lists exports, source roles and instance counts. files.json records
file sizes and SHA-256 values. The 47 individual GLBs were read back by Godot;
all 58 files, including the large worlds, pass structural container/mesh/buffer
checks in the packager. Third-party source attribution remains applicable;
Godot's direct GLTFDocument preview may require explicitly enabling vertex
colors on imported character materials; the GLB COLOR_0 data is present.
read ASSET_CREDITS.txt and the original vendor licenses. No author endorsement.
No account configuration, API credentials, user saves or private attachments.
The playable game and its assets have not been modified by this collection.
'''
(PACK/'README.txt').write_text(readme, encoding='utf-8')
if args.prepare:
    print('Art-only sources and 52 image references copied. Awaiting GLB export.')
    raise SystemExit(0)

models = json.loads((PACK/'models.json').read_text(encoding='utf-8'))
assert models['failures'] == 0
assert len(models['models']) == 58, len(models['models'])
for entry in models['models']:
    path = PACK/entry['file']
    data = path.read_bytes()
    magic, version, length = struct.unpack_from('<III', data)
    assert magic == 0x46546c67 and version == 2 and length == len(data), path
    json_length, json_type = struct.unpack_from('<II', data, 12)
    assert json_type == 0x4e4f534a, path
    content = json.loads(data[20:20+json_length].decode('utf-8'))
    assert content.get('meshes') and content.get('nodes'), path
    binary_length, binary_type = struct.unpack_from('<II', data, 20+json_length)
    assert binary_type == 0x004e4942 and 28+json_length+binary_length == len(data), path
    for view in content.get('bufferViews',[]):
        assert view.get('buffer',0) == 0, path
        assert 0 <= view.get('byteOffset',0) <= binary_length, path
        assert view.get('byteOffset',0)+view['byteLength'] <= binary_length, path
    for mesh in content['meshes']:
        assert mesh.get('primitives'), path
        for primitive in mesh['primitives']:
            position = primitive['attributes']['POSITION']
            assert content['accessors'][position]['count'] > 0, path
            for index in primitive['attributes'].values():
                assert 0 <= index < len(content['accessors']), path
    assert sum('mesh' in node for node in content['nodes']) == entry['mesh_instances'], path
    for image in content.get('images',[]):
        assert 'bufferView' in image or image.get('uri','').startswith('data:'), path
    for buffer in content.get('buffers',[]):
        assert 'uri' not in buffer or buffer['uri'].startswith('data:'), path
    assert not content.get('animations') and not content.get('skins'), path

manifest = [{'file':p.relative_to(PACK).as_posix(), 'bytes':p.stat().st_size,
    'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
    for p in sorted(PACK.rglob('*')) if p.is_file() and p.name not in ('files.json','.gdignore')]
(PACK/'files.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
archives = [(ROOT/'art_exports/Last-Light-Model-Pack-2026-11-24.zip', PACK),
    (ROOT/'art_exports/Last-Light-Images-For-3D-2026-11-24.zip', PACK/'01-Images-For-3D')]
for archive, folder in archives:
    with zipfile.ZipFile(str(archive),'w',zipfile.ZIP_DEFLATED,compresslevel=6) as output:
        for path in sorted(folder.rglob('*')):
            if path.is_file() and path.name != '.gdignore':
                output.write(str(path),path.relative_to(folder).as_posix())
        if folder.name == '01-Images-For-3D':
            output.write(str(PACK/'ASSET_CREDITS.txt'),'ASSET_CREDITS.txt')
    with zipfile.ZipFile(str(archive)) as checked:
        assert checked.testzip() is None
    print(archive.name, archive.stat().st_size)
print('MODEL PACK VERIFIED:',len(models['models']),'GLBs; 52 selected images;',len(manifest),'files')
