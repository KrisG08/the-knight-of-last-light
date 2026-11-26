# Godot and connected region scenes

Status: proposed implementation baseline.

Use standard Godot 4 with typed GDScript and load connected handcrafted regions separately. This trades seamless-continent scale and high-end rendering ambitions for a smaller toolchain, text-editable scenes, controlled memory use and an achievable solo project on the owner's laptop. Engine choice carries meaningful rework cost; record the actual pinned release when accepted through implementation. Keep region progression and durable state independent of scene node paths so later art expansion does not rewrite saves.
