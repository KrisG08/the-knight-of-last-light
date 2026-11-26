from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
if __name__=='__main__':
    data=json.loads((ROOT/'art/cinematics/opening-v6/production.json').read_text(encoding='utf-8'))
    starts=[0,10,20,29.6,38.8,47.8,59,69.5]
    durations=[10,10,9.6,9.2,9,11.2,10.5,10.5]
    for i,shot in enumerate(data['shots']): shot.update(start=starts[i],duration=durations[i])
    data['revision']='v7: continuous skins, grounded distinct falls, visible captive, motivated cuts'
    data['source_fps']=30
    folder=ROOT/'art/cinematics/opening-v7'; folder.mkdir(parents=True,exist_ok=True)
    (folder/'production.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
