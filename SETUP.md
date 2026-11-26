# Current setup

For v0.5.66 and a clean GitHub clone, use [docs/development.md](docs/development.md)
and [README.md](README.md). The sections below are retained historical milestone
notes; their versioned paths and older feature statements are not current setup.
Latest local packaged launcher: `Play-Latest.cmd`.

# Historical version — v0.5 on laptop and Android

Use **Play-Village-Detail.cmd** (the existing village launcher) or **Play-Latest.cmd**.
They open `build/windows-v05/LastLight.exe`, with the same campaign/frontend/save
features as Android v0.5. The old windows-village package remains available.
The launcher retains `.tools/userdata` APPDATA so existing laptop journeys remain
visible; close an older running game first. Device saves are local, not cloud-synced.

# Realistic asset preview

**Play-Realism.cmd** runs the latest compatible external-model candidate in
`build/windows-realism/`. It shares existing workspace saves. Earlier launchers
remain separate. Start in the refuge for the full visual comparison.
[Installed assets and alternatives](docs/realistic-asset-research.md).

# Dark fantasy art preview

Use **Play-Art.cmd** for the latest visual candidate in `build/windows-art/`.
It retains the same workspace saves and controls. Earlier launchers stay available.
The refuge is the first fully dressed visual review scene. [Art notes](docs/testing/dark-fantasy-art.md).

# Running the campaign development preview (M12a)

Double-click **Play-Preview.cmd** for the latest M12a candidate in build/windows-preview.
**Play-Build.cmd** retains the M11 export. Both use the same local saves/settings.

The retained M11 Windows game keeps the
same local saves/settings as the source launchers. No editor runs in this mode.
The standalone folder is `build/windows/`; keep LastLight.exe and LastLight.pck together.
`build/Last-Light-Windows-Slice.zip` contains that folder's executable, pack, README,
engine/font/library notices and SHA-256 build manifest. No upload/public release occurred.

Launching LastLight.exe directly uses normal Windows APPDATA. Play-Build.cmd keeps
the workspace APPDATA redirection, so existing local campaign progress remains visible.
No save files are copied or reset by building or packaging.

Settings / controls in the menu provides sensitivity, inverted Y, 100/125/150% text,
Master/SFX/UI volume plus a reserved Music bus, fullscreen and a shadow-free low preset.
Optional incoming damage 25–100% and enemy attack tempo 60–100% keep rewards identical.
Enemy pose and hit timing use the same scaled clock. Motion blur, shake and flashes
remain absent; textual cues/subtitles are always present. Keyboard/mouse only.

Scroll within settings to remap an action. Press Rebind, then a key or mouse button;
Escape cancels capture. Conflicts, including the secondary mouse-wheel cycle binding,
are rejected without replacing the original action. Restore defaults is available.
Save settings and back commits `settings.cfg` separately from campaign slots.

## Lyra and companion route

After breaking the Burial Seal, enter Blackwood and talk to Lyra west of the path.
Clear both trail hounds and recover her satchel southeast, behind the fallen wall
by the watchtower post. Return and choose **Return satchel · ask Lyra to join**.
Recruitment gives 40 XP / 20 shards once and explicitly selects her as companion.

**C** toggles follow/hold by default. If an older remap already used C, the new command
gets a free fallback (V, B or F6); HUD/settings show the actual binding. E near an active
Lyra offers orders or waiting at the refuge. Journal provides selection/dismissal too.
She follows around obstacles using navigation, holds without drifting and contributes
small melee damage only against nearby ordinary enemies engaged with the knight.
She never selects bosses or creates distant aggro. Friendly bodies do not block the player.

At 0/70 HP Lyra is downed, never permanently killed. Rest at an activated lantern or
cross an allowed safe passage to recover her. In restricted crypt she waits outside;
returning restores her while keeping the saved active selection. Unsafe/stuck routes
can suspend her until a lantern instead of repeated teleporting or crossing a locked gate.
Follow/hold is transient; recruited/active state persists. Existing v1 campaign saves
remain valid; new companion mutations produce version-2 saves using the same backup
protocol. Neither training nor campaign slots are reset by this update.

Native companion review images: `.tools/review/lyra_quest.png`,
`lyra_companion.png`, `lyra_downed.png`. These are scripted native renders, not a
human playthrough. Current full test suite also exercises actual follower physics.
HUD interaction/journal hints and world interaction labels follow the current binding.

Rebuild with `powershell -ExecutionPolicy Bypass -File .\Build-Windows.ps1`.
It needs the pinned portable editor and matching extracted x86_64 debug/release
templates under `.tools/templates/` (version.txt is 4.7.2.stable). Templates came
from the official Godot 4.7.2 standard export-template archive. Binary downloads
and exports are ignored by Git. No export templates are required to play the build.

## Source launchers and route

Double-click **Play-Village.cmd**, then **New campaign in selected slot**.
Alternatively, open Play.cmd and choose **Ashen Village campaign**.
Training slots remain under `saves/`; campaign slots use separate `campaign_saves/`
under the same `.tools/userdata/Godot/app_userdata/The Knight of Last Light/` directory.
Nothing automatically imports, overwrites or resets a training journey.

First route:

1. Start at Lantern Refuge. No hostiles spawn here. Walk north along the chapel path;
   press E near the **Ashen Village** passage.
2. Activate the village lantern with E. The barred central street requires a detour
   via the east or west road. Explore the houses and village square.
3. Follow the east road around the buildings to the mill. Defeat its Fallen Soldier,
   talk to captive Oren with E and choose **Free Oren**. He leaves the village.
4. From the north side of the central barrier, use E to open the permanent shortcut.
5. Optional: explore the western burial yard and collect the family token with E.
6. Return south to the refuge passage and use E. Oren now stands only at the refuge
   forge. Talk and upgrade the equipped sword. Return the token at the memorial.
7. Save and quit, then load the same campaign slot. The last activated lantern is
   your recovery point; ordinary enemies respawn while rescue, rewards, shortcut,
   token quest and sword upgrade persist.
8. Follow the square's north road to **Gravedigger's Crypt**. Press E at the entrance.
   Walk into the arena to start the battle. The exit ward closes when the fight starts.
9. Defeat the Gravedigger, then walk to the purple **Burial Seal** at the far end and
   press E. Boss victory grants 180 XP / 80 shards once; the seal separately unlocks
   Blackwood. Quitting between these actions preserves victory and leaves the seal available.
10. Leave the crypt with E by the southern entrance. Go to the northeastern forest ward,
    press E to enter the playable Blackwood entrance, explore and use E at its southern
    passage to return. This completes the first chapter objective. Recovery still uses
    your last activated village/refuge lantern; the forest entrance has no new checkpoint.

Boss guide: sweep winds up 0.8 seconds, overhead slam 1.2, advancing grab 1.0.
Move aside or time a dodge, then attack during recovery. Frontal block spends guard
stamina; the grab causes a strong guard break. At 50% HP a one-time phase change adds
a separate 1.4-second marked ground burst. Leave its marked location or time the dodge.
No boss attack overlaps another. After death, return to the checkpoint; an unfinished
boss resets to full health/phase one. Defeated bosses remain dead after rest/reload.
Oren and the optional token are helpful but not required to fight the boss.

**J** opens the journal and regional route notes. **Tab** opens the same notes for
now; campaign equipment upgrades are handled by Oren. Existing combat/movement
controls below apply. Death or Backspace returns to the last activated lantern.
Talking, resting and travel reject active pursuit; defeat enemies or lose them first.

This is a playable graybox, with primitive houses, NPCs and three enemy profiles.
The authored village is roughly 80×90 meters, pending traversal review rather than
being inflated to the planning aspiration. Enemies follow a navigation mesh around
buildings with sight/memory/leash limits. The opened shortcut remains conservatively
excluded from AI navigation; the player can use it immediately.
The boss, Burial Seal, scout trail and Lyra recruitment are implemented. Deeper Blackwood
and the remaining campaign are future milestones. Art and animation remain
primitive; the complete slice presentation/export milestone is still ahead.

Native render review: `.tools/review/refuge.png`, `village.png`, `village_menu.png`
and `village_journal.png`. These are actual engine renders, not a human playthrough.
Boss/forest render review adds `crypt_slam.png`, `crypt_burst.png`, `blackwood_entrance.png`.

# Training playground (M3, preserved)

Double-click `Play.cmd` in this folder. Choose **Enter the courtyard**.
The local portable Godot engine is in `.tools/godot/`; it is deliberately excluded from Git.
Its official source is https://github.com/godotengine/godot/releases/tag/4.7.2-stable.
If missing, obtain the standard Windows x86_64 archive for this pinned version and extract it there.

WASD: camera-relative movement. Mouse: orbit. Shift: sprint. F: jump.
Space: dodge (25 stamina). Escape: pause/resume. Backspace: reset position/camera.
Left mouse: light sword attack (15 stamina). Q: heavy attack (30 stamina).
Right mouse: hold frontal block. R: heal (3 charges, 1 second; damage interrupts).
Middle mouse: lock/unlock a visible enemy. Mouse wheel: cycle eligible targets.
E: interact with the focused nearby lantern, anvil or training seal.
Tab: equipment and upgrade screen. Escape returns to the pause menu.
Rest is rejected while the soldier is engaged.

Three slots are available in the menu. Start creates a journey in an empty selected
slot; Continue/Load reloads the selected journey. New journey asks for confirmation
when the selected slot already exists. Save and quit also handles the window close
button. If writing fails, the game stays open with an unsaved warning and Retry saving.
Loading restores full resources at the training checkpoint and respawns the soldier;
it never restores a partially completed fight. Unknown future save versions are preserved.

First victory grants 100 XP and 60 shards once, raises rank to 2 and maximum HP to 105.
Each actual respawn defeat thereafter grants 10 XP and 5 shards. Death loses no XP.
At the training anvil on the right of spawn, use E and Upgrade sword: tiers 1/2
cost 60/120 shards and deal 26/31 base damage (starting sword: 22).
After the first victory, interact with the purple seal before the northern arch.
The seal break opens a small walled training alcove. Return through the arch.
Reward claims, rank, XP, shards, sword tier and the opened passage survive reload.
This alcove is a persistence proof, not the Blackwood chapter or a defeated story boss.

Local saves from Play.cmd are under
`.tools/userdata/Godot/app_userdata/The Knight of Last Light/saves/`.
Each `slot_01.json` (or 02/03) has a previous known-good `.json.bak` backup after
subsequent saves. Do not edit the only copy of a save when testing corruption.
Falling off the open northern edge returns the knight to the starting point.
Try the western ramp, eastern jump blocks and central camera obstruction corner.
Small ledges require jumping; automatic stair climbing is not implemented.

Run `powershell -ExecutionPolicy Bypass -File .\Test.ps1` for import and rule/runtime checks.
The launcher and tests redirect APPDATA only for their child process to `.tools/userdata`
so Godot can operate inside this workspace. No Windows settings are changed.
To edit, open `project.godot` in Godot 4.7.2. The scene entrypoint is
`game/bootstrap/game_root.tscn`. Input actions are configured by the boot script.

Approach the Fallen Soldier on the left of the central wall. His 0.8-second windup
raises the weapon, changes his silhouette color, displays WINDUP and plays a short cue.
Block while facing him, dodge through the strike or attack during recovery.
Defeat him, return to the lantern and press E for another round.
Death pauses the encounter; choose Return to checkpoint to restore both actors.
The courtyard is a developer training location, not the future hostile-free refuge.

The preserved training route is an M3 graybox, with original primitive geometry, a block knight,
procedural sword swings and short original synthesized audio cues. Story chapters,
polished animation remains future work. Campaign settings/rebinding and the Windows
export now exist. Audio balance and combat feel need human playtesting.
The design pack's README describes the intended campaign, not current implementation.

Developer-only `-- --review` launches with in-memory slots for UI inspection. Rule,
runtime and file-save tests never touch player slots; file tests use unique subfolders
under `.tools/test-saves/`. Full campaign acceptance remains pending.

M8: Blackwood now has a western lantern, east watchtower detour, north root shrine,
Thorn Beast, explicit Root Seal and northeast Order forecourt. Open the forest
shortcut from its northern side. Lyra waits outside the grove. See
[Blackwood checks](docs/testing/m8-blackwood.md) for the route and limitations.


M9a: Order barracks/courtyard/memorial hall, Sir Cael quest and companion selection
are playable. Activate the Order lantern, meet Cael, clear three sentries, read
the northwest memorial record and return to recruit him. J switches companions
outside combat; C toggles follow/hold. The Commander sanctum, Oath Seal and mountain approach are now playable.
See [Cael checks](docs/testing/m9a-cael.md).

M9b: enter the northern Order sanctum, defeat Fallen Commander, break Oath Seal,
then take the northeast ward into the Peaks approach. Crosscut warns twice before
its two strikes; attack during recovery. Companions wait outside and rejoin after.
See [Commander checks](docs/testing/m9b-commander.md). Deeper Peaks remains M10.

M10: Peaks now has its own lantern, western mine, real railed gorge bridge,
fortress, Iron Warden and Forge Seal. Cross north, defeat Warden and break the
seal, then take the northeast ward to the citadel forecourt. Four seals are
required. Open the service bar from north. [Peaks checks](docs/testing/m10-peaks.md).
The citadel finale remains M11; old M9 approach-only notes above are historical.

M11: the citadel now has a lantern, optional prison rescue, ritual inscription and
Maldrek's two-phase encounter. After victory, explicitly confirm shattering the
artifact. The saved ending/credits lead to peaceful postgame exploration; reload
returns to restored refuge. [Finale checks](docs/testing/m11-finale.md). Older
forecourt-only notes above are historical. M12 human campaign acceptance is pending.

M12a: J / Lantern travel links activated lanterns outside combat when standing
near a lit checkpoint. The preview is separate from the primary build so the old
game can stay open. Rebuild with `powershell -ExecutionPolicy Bypass -File
.\Build-Windows.ps1 -OutputDirectory build/windows-preview`. Preview archive:
build/Last-Light-windows-preview.zip. [Checks](docs/testing/m12a-lantern-travel.md).
# Forest opening preview

Run `Play-Forest.cmd` for the new 2D opening and wooded camp-to-village approach.
Choose New Journey to see the opening; Continue bypasses it. Next advances a beat;
Skip introduction or Escape enters play. Follow the forest road north past the
chapel to the village. This is the first forest increment; later regions retain
their earlier layouts. See docs/forest-world-direction.md.

# Opening film preview

Run `Play-Film.cmd` for the latest build with the actual 30-second opening movie.
New Journey plays it; Continue bypasses it. Use Skip film / Escape, or let playback
finish to enter the camp. Movie has animated 3D scenes, original audio and subtitles.
The earlier forest build remains available separately.

# Village detail preview

Run `Play-Village-Detail.cmd` for the latest village pass and opening film. Continue
retains your campaign checkpoint; the woodland road north of the refuge leads to
Ashen Village. All earlier preview builds are retained separately.

# Villain model preview

Run `Play-Villains.cmd` for the latest enemy/boss models, retaining the village pass,
woodland route and opening film. Continue keeps your campaign checkpoint. Previous
packages remain available separately. Licensed source credits are bundled beside EXE.

