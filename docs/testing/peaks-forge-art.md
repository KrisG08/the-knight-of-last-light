# Ashen Peaks and forge art — 2026-11-05

Post-0.5.2 source work, Godot 4.7.2 Mobile renderer. Original architecture and
existing credited stone/timber/rock materials/models.

Bridge gains carved stone balustrade presentation over the original solid rails,
pointed support arches under the deck and rock faces down the actual gorge gap.
External ridge/rock dressing replaces visible rectangular perimeter walls. Mine
gets nested support frames, surviving roof strips and two warm torches; fortress
gets capped towers and a deep entry portal. Original gap, deck/rail collision,
fall recovery, mine/fortress/shortcut/ward interactions and navigation are unchanged.

Shared horizon adds a narrow external apron to close the terrain/sky seam; all
vertices remain outside the authored play rectangle. Gorge end faces close the
visible end gap. Scene dressing is cosmetic and does not add traversable ground.

Forge hall receives a closed vault, iron frame/chain details, four wall furnace
facades and warm coals. Reuses original six lights with amber color plus one cool
fill, rather than adding furnace lights. Seal is a faceted crystal parented to its
existing authoritative node. Shared crystal also presents burial/oath seals.

529 assertions PASS (.tools/forge-art-tests.log), including actual bridge/gap/rail,
shortcut, Iron Warden attacks/rewards/seal and all campaign persistence checks.
Native bounded captures inspected: .tools/forge-art-capture.log and images under
.tools/review/peaks-art-*. Scripted captures are not manual platform traversal,
combat-balance, phone or FPS certification. Minor distant seams/landscape shape
and final material quality still need art review. Not in the 0.5.2 phone download.
