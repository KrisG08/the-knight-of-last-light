extends SceneTree
const L=preload("res://game/localization/localizer.gd")
var assertions:=0
var failures:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size=Vector2i(1600,900)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true
	game.show_account()
	var panel=game.account_panel
	for language in ["en","bg","ru","fr","ar"]:
		game.set_language(language); panel.mode="login"; panel.refresh()
		for frame in range(5): await process_frame
		check(panel.resend.is_visible_in_tree(),"Replacement email action reachable from sign-in: "+language)
		check(panel.resend.text==L.text("Resend confirmation email"),"Replacement email action localized: "+language)
		if language!="en":
			for source in ["Resend confirmation email","If this address is awaiting confirmation, a new email has been requested.","The verification link or code has expired. Request a new confirmation email."]:
				check(L.text(source)!=source,"Confirmation feedback localized: "+language)
		if DisplayServer.get_name()!="headless":
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png("res://.tools/review/account-confirmation-"+language+".png")
	panel.mode="signup"; panel.refresh()
	check(not panel.resend.visible,"Resend action does not confuse fresh registration")
	panel.mode="verify"; panel.refresh()
	check(panel.resend.visible,"Expired OTP has the same replacement action")
	panel.mode="reset"; panel.refresh()
	check(not panel.resend.visible,"Signup replacement cannot replace a password recovery request")
	game.cloud_account.accept_session({"access_token":"memory-only-fixture","user":{"id":"00000000-0000-4000-8000-000000000003"}})
	panel.refresh()
	check(L.source(panel.session_note)=="Local progress is safe while offline.","Signed-in profile does not show the registration-preview warning")
	check(panel.profile.visible and not panel.resend.is_visible_in_tree(),"Resend is hidden after successful sign-in")
	game.queue_free(); await process_frame; L.set_locale("en")
	print("Account confirmation UI: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
