"""Validate and package selected image references without modifying their pixels."""
import hashlib
import html
import json
from pathlib import Path
import zipfile
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / 'art' / 'reference-pack'
manifest = json.loads((PACK / 'manifest.json').read_text(encoding='utf-8'))
entries = [e for e in manifest['entries'] if e['id'] not in ('goblin', 'roadside-shrine')]
entries.insert(13, {'id': 'goblin', 'category': 'characters', 'prompt_source': 'initial-prompts.md'})
entries.insert(21, {'id': 'roadside-shrine', 'category': 'architecture', 'prompt_source': 'initial-prompts.md'})
names = {
    'knight': 'Рицарят', 'oren': 'Oren — ковач', 'lyra': 'Lyra — разузнавач', 'cael': 'Sir Cael',
    'fallen-soldier': 'Паднал войник', 'hollow-villager': 'Прокълнат селянин', 'grave-hound': 'Гробищно куче',
    'bound-shade': 'Враждебна сянка', 'gravedigger': 'Gravedigger', 'thorn-beast': 'Thorn Beast',
    'fallen-commander': 'Fallen Commander', 'iron-warden': 'Iron Warden', 'maldrek': 'Maldrek',
    'goblin': 'Гоблин', 'troll': 'Трол', 'dwarf': 'Джудже', 'wraith': 'Призрак',
    'stone-sentinel': 'Каменен пазител', 'gargoyle': 'Гаргойла', 'ash-dragon': 'Пепелен дракон', 'barghest': 'Тъмен хръток',
    'roadside-shrine': 'Крайпътно светилище', 'expedition-tent': 'Експедиционна палатка',
    'ruined-chapel': 'Разрушен параклис', 'village-house': 'Селска къща', 'village-mill': 'Мелница',
    'crypt-entrance': 'Вход на криптата', 'watchtower': 'Наблюдателна кула', 'root-shrine': 'Коренно светилище',
    'order-memorial': 'Мемориална зала', 'forge-fortress': 'Ковачница крепост', 'citadel-tower': 'Кула на цитаделата',
    'ritual-dais': 'Ритуален подиум', 'broken-cart': 'Повредена количка', 'village-well': 'Кладенец',
    'lantern': 'Готически фенер', 'crate': 'Сандък', 'barrel': 'Бъчва', 'fence': 'Ограда',
    'smith-workbench': 'Ковашка работна маса', 'memorial': 'Мемориален камък', 'burial-seal': 'Burial Seal',
    'root-seal': 'Root Seal', 'oath-seal': 'Oath Seal', 'forge-seal': 'Forge Seal',
    'central-artifact': 'Централен артефакт', 'knight-sword': 'Меч на рицаря', 'knight-shield': 'Щит на рицаря',
    'ancient-tree': 'Древно мъртво дърво', 'forest-pine': 'Горски бор', 'mossy-rock': 'Мъхеста скала', 'fern': 'Папрат'
}
categories = {'characters': 'Персонажи и същества', 'architecture': 'Постройки', 'props': 'Предмети', 'nature': 'Природа'}
counts = {}
for entry in entries:
    filename = 'ash-dragon-v2.png' if entry['id'] == 'ash-dragon' else entry['id'] + '.png'
    entry['file'] = entry['category'] + '/' + filename
    path = PACK / entry['file']
    with Image.open(str(path)) as image:
        entry['width'], entry['height'] = image.size
        assert min(image.size) >= 1000, str(path)
        image.verify()
    entry['sha256'] = hashlib.sha256(path.read_bytes()).hexdigest().upper()
    entry['name_bg'] = names[entry['id']]
    counts[entry['category']] = counts.get(entry['category'], 0) + 1
assert len(entries) == 52 and len(set(e['id'] for e in entries)) == 52
manifest.update(status='images_ready_not_converted', created='2026-11-06', generator='built-in imagegen',
                counts=counts, entries=entries, game_integration=False,
                note='52 distinct primary asset references; not every map instance or modular variant. No Hyper3D generation or model integration claimed.')
(PACK / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
(PACK / 'initial-prompts.md').write_text((ROOT / 'assets/concepts/hyper3d/prompts.md').read_text(encoding='utf-8'), encoding='utf-8')
prompts = ['# Reference prompts\n\nGenerated with the built-in imagegen tool. Initial goblin/shrine prompts are in initial-prompts.md.\n']
for entry in entries:
    if 'prompt' in entry:
        prompts.append('## ' + entry['id'] + '\n\n' + entry['prompt'] + '\n')
(PACK / 'prompts.md').write_text('\n'.join(prompts), encoding='utf-8')
parts = ['''<!doctype html><html lang="bg"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Last Light — 52 референции</title><style>
*{box-sizing:border-box}body{margin:0;background:#111619;color:#ece5d8;font:16px system-ui,sans-serif}
header,main{max-width:1500px;margin:auto;padding:28px}h1{font-family:Georgia,serif;font-size:36px;margin:0 0 12px}
p{color:#bcc9c7;line-height:1.6}nav{display:flex;gap:20px;flex-wrap:wrap}a{color:#d4bb8d}input{margin:20px 0 0;padding:14px;width:min(100%,520px);background:#202a2e;color:white;border:1px solid #58666b;border-radius:6px}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:18px}article{border:1px solid #39474b;border-radius:8px;overflow:hidden;background:#1c2528}
article img{width:100%;height:300px;object-fit:contain;background:#d1d1cf;display:block}article div{padding:14px}small{display:block;color:#a4b6b9;margin-top:7px}article[hidden]{display:none}
</style><header><h1>The Knight of Last Light</h1><p>52 отделни референции за обновяване на основните 3D обекти. Натисни изображение за оригинала. Това са изображения, не готови 3D модели. Качвай по един обект в Hyper3D.</p><nav>''']
for key, title in categories.items():
    parts.append('<a href="#' + key + '">' + title + ' · ' + str(counts[key]) + '</a>')
parts.append('</nav><input id="search" placeholder="Търси по име…" aria-label="Търсене"></header><main>')
for category, title in categories.items():
    parts.append('<section id="' + category + '"><h2>' + title + '</h2><div class="grid">')
    for entry in entries:
        if entry['category'] != category:
            continue
        file = html.escape(entry['file'])
        title_text = html.escape(entry['name_bg'])
        parts.append('<article data-name="' + html.escape(entry['name_bg'] + ' ' + entry['id']) + '"><a href="' + file + '"><img loading="lazy" src="' + file + '" alt="' + title_text + '"></a><div>' + title_text + '<small>' + html.escape(entry['id']) + ' · ' + str(entry['width']) + ' × ' + str(entry['height']) + '</small></div></article>')
    parts.append('</div></section>')
parts.append('''</main><script>document.getElementById('search').addEventListener('input',e=>{const q=e.target.value.toLocaleLowerCase();document.querySelectorAll('article').forEach(a=>a.hidden=!a.dataset.name.toLocaleLowerCase().includes(q))})</script></html>''')
(PACK / 'index.html').write_text(''.join(parts), encoding='utf-8')
readme = '''# Last Light reference pack

52 selected original image references, generated with the built-in imagegen tool.
Open index.html in a browser after extracting the archive. Click a card for its
full-resolution PNG. Categories: 21 characters/creatures, 12 architecture assets,
15 props and 4 nature assets. The manifest records exact prompts, selected paths,
dimensions and SHA256 hashes. The selected dragon uses the wider-framed v2.

These cover the principal asset types, not every placed instance or modular
variant. They are raster references, not GLB files, rigs, animations or changes
already integrated into the playable game. Fine hair, foliage, cloth fringes,
thin wings and enclosed architectural spaces need particular review after 3D
conversion. One view cannot define unseen geometry exactly.

For Hyper3D: upload one selected PNG per object/job. Keep weapons separate from
characters. Inspect the resulting mesh, topology, PBR materials, scale and export
rights before integration; rigging/animation and mobile optimization remain
separate steps. This pack creation did not submit a Hyper3D job or purchase credits.

Prompts: prompts.md, initial-prompts.md, edit-prompts.md.
'''
(PACK / 'README.md').write_text(readme, encoding='utf-8')
archive = ROOT / 'build/Last-Light-Reference-Images-52.zip'
paths = [PACK / e['file'] for e in entries] + [PACK / n for n in ('manifest.json','index.html','README.md','prompts.md','initial-prompts.md','edit-prompts.md')]
with zipfile.ZipFile(str(archive), 'w', zipfile.ZIP_DEFLATED) as z:
    for path in paths:
        z.write(str(path), str(path.relative_to(PACK)).replace('\\', '/'))
with zipfile.ZipFile(str(archive)) as z:
    assert z.testzip() is None
    assert len([n for n in z.namelist() if n.endswith('.png')]) == 52
    for entry in entries:
        assert hashlib.sha256(z.read(entry['file'])).hexdigest().upper() == entry['sha256']
print(json.dumps({'images': len(entries), 'counts': counts, 'zip_bytes': archive.stat().st_size, 'all_images_and_archive_hashes_verified': True}))
