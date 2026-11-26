# Knight natural gait — 0.5.14

Presentation changes only. Shoulder/elbow/wrist skins are prepared once from the
existing Meshy arm meshes and shared between knight instances. Each arm uses
three bind bones with normalized weights. Equipment follows the wrist's skin
deformation; the combat-owned sword pivot remains the parent and is never written
by locomotion. The original detailed sword and shield meshes are retained.

Leg clips use sampled continuous cubic pose curves, opposite half-cycle phases,
and speed-dependent cadence. Shoulders counter the corresponding leg; the shield
arm has a smaller swing. Running increases elbow bend and torso lean. The sword
has a restrained downward carry angle through its wrist. Movement weight eases
out when stopping. Guard uses a raised shield pose; attack/heal/stagger
release arm secondary motion. Torso rotation/breathing are local cosmetic offsets.
No hit timing, damage, stamina, collision, movement speed or camera changes.

## Checks

- Headless campaign regression and upper-body checks: 574 assertions PASS in
  `.tools/natural-gait-tests.log`; release confirmation: 574 PASS in
  `.tools/natural-gait-tests-final.log`.
- Checks cover counterphase shoulders, skin weights, stronger running elbows,
  equipment following wrists, shield guard, attack-pivot ownership, unchanged
  physics/stamina and continuous leg loop endpoints.
- Native actual-game capture scripts sample walking, attack, dodge, sprint,
  guard and return to idle, including physical movement of 3.83 m over the
  scripted walking segment. See `.tools/natural-gait-release-capture.log` and
  `.tools/review/skeletal-*.png`, `natural-guard.png`, `natural-idle.png`.
- Source retains a procedural adapter rather than authored mocap/full-body
  animation. Small material/partition seams and further animation polish remain.
  These checks do not verify phone FPS, foot IK on every terrain or human feel.

Both platform packages verified: 90 matching compiled game scripts, 62 matching character resources. Packaged Windows headless boot exit 0; APK signatures v2/v3 verified; archive CRC and manifest hashes checked. Play-Latest.cmd points to 0.5.14. Real phone gameplay/performance has not been checked.

0.5.15 dash correction: Space keeps jog at 2.162x cadence at 8 m/s; arm motion and footfalls continue. Grounded runtime baseline fails with stand/1.0; corrected runtime passes with jog/2.162. 575 regression assertions PASS. Native actual-input dash capture passed. Dash physics/invulnerability/stamina are unchanged.
