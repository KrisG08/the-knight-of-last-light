# M10: Ashen Peaks, Iron Warden and Forge Seal

Implemented locally 2026-11-04, Godot 4.7.2.stable.official.ed1daf0bf.

Ashen Peaks now has two authored plateaus, western abandoned mine with an inscription
and hound, a railed bridge over a real eight-metre gap, northern soldier encounters,
forge fortress, eastern service return and southern lantern. Navigation excludes the
void and the rails' clearance; it is authored once, not rebaked each frame. The
service bar opens only from the fortress side. Conservative navigation retains its
blocked cells after opening; companions can use the main bridge route.

The forge is a separate 24 m arena. Its 720-HP Iron Warden alternates a 1.0-second
hammer sweep and 1.4-second raised-hammer local slam. Active windows are 0.3/0.2 s;
recovery is 1.9/2.4 s. Sweep damage/guard cost is 30/45, slam 34/60 before defense.
Slam reaches 4.3 m around the Warden and can be avoided by moving clear, blocking
with sufficient stamina or the normal dodge window. No instant-death attack,
mandatory upgrade or compulsory jump. The same assist clock controls poses/hits.
Companions wait outside and safely rejoin on return.

Victory grants 360 XP and 160 shards once. Forge Seal requires a separate explicit
interaction. The citadel gate requires all four broken regional seals, opens into
a playable gatehouse forecourt and permits return. Discovery completes chapter IV;
the deeper citadel, Maldrek, artifact ritual and ending remain M11. Four-seal refuge
feedback derives from saved facts. New checkpoint/recovery is checkpoint.peaks.

## Evidence

- Test.ps1 clean import and **375 assertions PASS**, M0–M10 regression included.
  New checks cover discovery and four-seal guards, finite rewards/XP thresholds,
  version-six save/backup/round-trip, path confinement to bridge, actual physics
  crossing by knight and follower, fall recovery, service bar, guardian restriction,
  slam telegraph/escape/hit uniqueness, blocking/guard cost, death/reset, real victory,
  menu reload before seal, explicit seal, restored follower/routes, citadel transition,
  backtracking spawn and refuge feedback.
- Native Mobile/Vulkan script capture exited 0 with no engine errors on NVIDIA RTX
  3050 Ti Laptop. Actual bridge, mine, Warden slam and citadel forecourt renders were
  inspected under .tools/review/{peaks_bridge,peaks_mine,iron_warden_slam,citadel_entrance}.png.
- Windows EXE/PCK/ZIP refresh, isolated 120-frame native boot and manifest checks
  are recorded in STATUS.md. Tests use memory slots or unique .tools/test-peaks
  directories. Existing player slots are not copied, reset or silently migrated.

## Player route and limits

After Oath Seal, enter Peaks and activate the lantern west of the entrance. Explore
the western mine, cross inside the bridge rails, then follow the north road to the
forge. The east service bar opens from north for an alternate return. Defeat Warden,
break Forge Seal behind him, leave and take the northeast citadel ward. Reloading
uses the last activated lantern; falling restores that checkpoint as well.

Primitive geometry/animation and synthesized cues remain development assets. Human
combat feel, audio/camera, clean-start/backtracking acceptance and current workload
performance remain pending. M6 benchmark data identifies its older PCK and does not
certify the expanded Peaks. No full campaign or ending is claimed.
