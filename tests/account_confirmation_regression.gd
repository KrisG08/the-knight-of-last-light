extends SceneTree
const Account=preload("res://game/cloud/cloud_account.gd")
var assertions:=0
var failures:=0
class MockAccount extends Account:
	var calls: Array=[]
	var answer:={"ok":true,"status":200,"data":{},"message":""}
	func request(path: String, method: int, body: Variant=null, authorized: bool=false) -> Dictionary:
		calls.append({"path":path,"method":method,"body":body,"authorized":authorized})
		await get_tree().process_frame
		return answer
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var auth: Variant=MockAccount.new(); root.add_child(auth)
	check(auth.has_method("resend_confirmation"),"Players can request a replacement after an expired confirmation link")
	if not auth.has_method("resend_confirmation"):
		auth.queue_free(); await process_frame; quit(1); return
	auth.email_codes_ready=false
	await auth.sign_up("fixture@example.invalid","fixture-password","Fixture")
	check(auth.notice=="Open the confirmation link in your email, then sign in here.","Link delivery never misleadingly asks for an unavailable code")
	auth.email_codes_ready=true
	await auth.sign_up("fixture@example.invalid","fixture-password","Fixture")
	check(auth.notice=="Check your email for a confirmation code.","Configured OTP delivery still explains code verification")
	check(await auth.resend_confirmation(" fixture@example.invalid "),"Replacement confirmation accepted")
	var call: Dictionary=auth.calls[-1]
	check(call.path=="/auth/v1/resend" and call.body=={"type":"signup","email":"fixture@example.invalid"},"Resend uses official endpoint and only email/type")
	check(not call.authorized and not auth.authenticated(),"Resending never signs in or grants access before verification")
	var count: int=auth.calls.size()
	check(not await auth.resend_confirmation("fixture@example.invalid") and auth.calls.size()==count,"Repeated taps respect local resend cooldown")
	check(auth.notice=="Too many attempts. Please wait before trying again.","Cooldown gives actionable feedback")
	auth.resend_ready_at=0
	auth.answer={"ok":false,"status":429,"data":{},"message":"Too many attempts. Please wait before trying again."}
	check(not await auth.resend_confirmation("fixture@example.invalid") and auth.resend_ready_at>Time.get_ticks_msec(),"Server rate limiting also starts cooldown")
	auth.resend_ready_at=0
	auth.answer={"ok":false,"status":0,"data":{},"message":"Connection unavailable. Progress remains saved locally."}
	check(not await auth.resend_confirmation("fixture@example.invalid") and auth.notice.contains("Connection unavailable"),"Network failure never claims an email was sent")
	count=auth.calls.size()
	check(not await auth.resend_confirmation("invalid") and auth.calls.size()==count,"Invalid email is rejected before a network request")
	var mapper: Callable=Account.failure_message
	check(mapper.call(403,"otp_expired")=="The verification link or code has expired. Request a new confirmation email.","Expired verification has a specific recovery message")
	check(mapper.call(400,"email_not_confirmed")=="Confirm your email before signing in.","Unconfirmed account differs from incorrect password")
	auth.queue_free(); await process_frame
	print("Account confirmation regression: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
