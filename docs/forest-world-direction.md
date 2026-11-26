# Forest-world direction — owner decision, 2026-11-04

2026-11-05 update: the owner rejected the single painting with changing text.
Current opening is a real 30-second prerecorded 3D film with four animated shots,
original atmospheric audio and subtitles. Play-Film.cmd supersedes Play-Forest.cmd
as the latest preview. The forest/world direction below is retained; the original
painting remains the visual target. See docs/testing/opening-film.md.

Owner requested an animated backstory before control begins, a meaningful spawn,
a large primarily forested world whose paths connect the story locations, and
replacement of the current simple buildings with detailed, story-appropriate forms.
The owner selected the generated opening painting as the desired visual direction:
complex natural silhouettes, roots, layered forest, ruins and majestic gothic distance.
This is a visual target, not a claim that the current renderer matches the painting.

First implemented increment:

- Three-beat animated 2D opening using a project-generated painting, pan/zoom,
  fades and subtitles; Next/Skip and Escape. No voice narration or music yet.
- New journeys begin at the expedition's last roadside camp. The existing refuge
  ID is retained for save compatibility; its safe geography now includes the wooded
  approach and ruined chapel. Existing saves resume at their checkpoint without intro.
- Authored 136 x 224 metre approach, nine road waypoints, rolling side terrain,
  detailed pine/fern meshes, mossy rocks, fallen trunks, shrine, chapel and a distant
  citadel silhouette. The main path stays walkable. Geometry has real collision and
  navigation; cosmetic imports use separate trunk proxies near the road.
- Village passage and return remain actual campaign interactions. Returning arrives
  at the north road, not back at the distant starting camp. Current boss/quest/save
  rules are preserved.

Main route with short exploratory space is the working layout assumption. The owner
has not yet specified branching density. There is no new giant seamless map yet:
the village and subsequent regions retain their earlier layouts and transitions.
Next approved increments should connect/rebuild those locations in this forest-world
language, replace simple character motion, and deepen natural/architectural shapes.
Do not expand all five regions before the first playable composition is reviewed.

Actual opening asset/prompt: assets/cinematics/README.md. Licensed forest sources,
hashes and changes: assets/vendor/polyhaven/manifest.json and docs/ASSET_CREDITS.txt.
Launcher: Play-Forest.cmd. Separate package: build/windows-forest/.
