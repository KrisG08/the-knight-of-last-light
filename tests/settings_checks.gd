extends RefCounted

const Settings = preload("res://game/settings/game_settings.gd")

static func rules(check: Callable) -> void:
	var directory := "res://.tools/test-settings/" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(directory)
	var path := directory.path_join("settings.cfg")
	var settings := Settings.new(path)
	settings.restore_defaults()
	check.call(not settings.set_value("sensitivity", NAN), "Nonfinite sensitivity rejected")
	check.call(not settings.set_value("invert_y", "yes"), "Wrong-type settings rejected")
	check.call(settings.set_value("incoming_damage", -1) and settings.values.incoming_damage == 0.25, "Incoming damage assist is bounded")
	check.call(settings.set_value("enemy_tempo", 0.01) and settings.values.enemy_tempo == 0.6, "Enemy tempo cannot fall below safe minimum")
	check.call(not settings.rebind("jump", KEY_SPACE) and settings.bindings.jump == KEY_F, "Duplicate jump/dodge binding is rejected without mutation")
	check.call(not settings.rebind("light_attack", -MOUSE_BUTTON_WHEEL_DOWN), "Secondary cycle wheel binding also prevents conflicts")
	check.call(settings.rebind("interact", KEY_G) and settings.hint("interact") == "G", "Rebinding updates InputMap and readable hint")
	check.call(settings.save_settings(), "Settings file writes independently of saves")
	settings.restore_defaults()
	var loaded := Settings.new(path)
	loaded.load_settings()
	check.call(loaded.bindings.interact == KEY_G and loaded.values.incoming_damage == 0.25 and loaded.values.enemy_tempo == 0.6, "Settings and controls persist across reconstruction")
	loaded.set_value("sensitivity", 2.0)
	check.call(loaded.save_settings(), "Existing settings file can be safely replaced on Windows")
	loaded.set_value("effects", 0)
	loaded.apply_audio()
	check.call(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "Effects zero mutes SFX bus")
	loaded.restore_defaults()
	loaded.apply_audio()
	check.call(loaded.bindings.interact == KEY_E and loaded.values.incoming_damage == 1 and loaded.values.enemy_tempo == 1, "Restore defaults resets controls and assists")

static func runtime(game: Node, check: Callable) -> void:
	game.settings.set_value("sensitivity", 2)
	game.settings.set_value("invert_y", true)
	game.settings.set_value("incoming_damage", 0.5)
	game.settings.set_value("enemy_tempo", 0.6)
	game.settings.set_value("ui_scale", 1.5)
	game.apply_settings()
	check.call(game.player.incoming_damage == 0.5 and game.burial.actor.attack_tempo == 0.6, "Assists apply to actual knight and boss without changing rewards")
	game.burial.actor.begin_attack("slam")
	game.burial.actor._physics_process(0.9)
	check.call(game.burial.actor.state == "windup" and game.burial.actor.shovel.rotation.x > 0 and game.burial.actor.shovel.rotation.x < 0.5, "Slower enemy tempo keeps telegraph timing and shovel pose coherent")
	game.player.enabled = true
	game.player.discard_mouse_events = 0
	game.player.target = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var yaw: float = game.player.yaw
	var pitch: float = game.player.pitch
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(10, 10)
	game.player.apply_look(motion.relative)
	check.call(is_equal_approx(game.player.yaw, yaw - 0.06) and is_equal_approx(game.player.pitch, pitch + 0.06), "Camera sensitivity and inverted Y affect actual mouse look")
	game.player.health = 100
	game.player.combat.state = "locomotion"
	game.player.dodge_left = 0
	game.player.receive_hit(game.player.position + Vector3.FORWARD, 24, 1, 35)
	check.call(game.player.health == 89, "Incoming assist reduces actual applied damage")
	check.call(game.hud_panel.theme.default_font_size == 24, "150 percent text size applies to real HUD theme")
	game.show_settings()
	check.call(game.settings_panel.visible and game.get_tree().paused and not game.player.enabled, "Settings pauses gameplay and releases player input")
	check.call(game.settings_panel.get_global_rect().position.x >= 0 and game.settings_panel.get_global_rect().position.y >= 0, "Settings panel stays inside viewport at 150 percent text")
	game.settings_panel.capturing = "interact"
	var key := InputEventKey.new()
	key.physical_keycode = KEY_G
	key.pressed = true
	game.settings_panel.capture_input(key)
	check.call(game.settings.hint("interact") == "G" and game.settings_panel.capturing == "", "Settings capture binds a real key and ends capture")
	game.settings_panel.capturing = "jump"
	key.physical_keycode = KEY_SPACE
	game.settings_panel.capture_input(key)
	check.call(game.settings.bindings.jump == KEY_F and game.settings_panel.capturing == "jump", "Capture warns and retains original binding on conflict")
	key.physical_keycode = KEY_ESCAPE
	game.settings_panel.capture_input(key)
	check.call(game.settings_panel.capturing == "", "Escape cancels capture without rebinding pause")
	game.settings.restore_defaults()
	game.apply_settings()
	game.pause(false)
