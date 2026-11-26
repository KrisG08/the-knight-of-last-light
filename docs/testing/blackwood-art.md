# Blackwood trail and landmarks — 2026-11-05

Godot 4.7.2 Mobile renderer. Original architecture plus existing credited pine kit.
Old cubic foliage presentation replaced with bounded pine meshes at the original
trunk locations. Original trunk collisions/navigation stay. Broken stone trail
marks the watchtower/shrine/Order/shortcut routes. Watchtower gets timber braces,
railing and surviving roof strips. Root shrine gets nested pointed arches, climbing
roots and two warm torches; the old visible crossbar is hidden. Physical portal
and interaction stay. Three root-bar obstacle visuals become batched tapered roots,
parented to their original bodies so opening still hides the actual shortcut.
Outer boundary visuals are hidden behind a scaled external ridge skirt.

520 assertions PASS: .tools/blackwood-art-tests-final.log. Existing Blackwood/Lyra
navigation, shortcut, guardian/reward/seal and travel checks remain passing.
Native bounded capture exits 0 (.tools/blackwood-art-capture-final.log), trail,
watchtower and shrine views inspected. No manual companion traversal or FPS claim.
Original primitives still serve several interaction/character representations.

Separate Windows preview: Play-Blackwood-Art.cmd / build/windows-blackwood-art.
Manifest hashes match; exported headless boot exits 0 (.tools/blackwood-art-export.log).
Older builds/player saves kept. Android 0.5.1 remains earlier forest-only additions;
later village/chamber/Blackwood changes need an APK refresh. This is an art
increment, not a full seamless-world or final forest-quality claim.
