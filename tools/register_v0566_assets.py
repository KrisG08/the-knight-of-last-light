from pathlib import Path
import csv
ROOT=Path(__file__).resolve().parents[1]
if __name__=='__main__':
    path=ROOT/'planning/asset-register.csv'
    with path.open(encoding='utf-8',newline='') as stream:
        existing=list(csv.DictReader(stream)); fields=list(existing[0])
    known={r['asset_id'] for r in existing}
    rows=[('film.opening_v7','assets/cinematics/opening_film.ogv','Authored film; current credited models; continuous skin and grounded motion'),
          ('audio.opening_v7','assets/cinematics/opening_score.ogg','Original event-scored synthesized cinematic cue')]
    rows += [('audio.phonk.'+name,'assets/audio/music/'+name+'.ogg','Original slowed dark-fantasy phonk loop; no external samples') for name in ['exploration','combat','boss','dawn']]
    with path.open('a',encoding='utf-8',newline='') as stream:
        writer=csv.DictWriter(stream,fieldnames=fields)
        for key,resource,credit in rows:
            if key in known: continue
            writer.writerow(dict(zip(fields,[key,resource,'Project original; source model credits retained','workspace',
              'Project-owned composition; underlying assets retain listed licenses',credit,'true',
              'Keep source geometry/texture credits; prior versions preserved','authored_and_inspected'])))
