extends Node
## Supabase HTTPS adapter. Passwords and session tokens are never written to disk.
signal changed
signal status_changed
var endpoint := ""
var public_key := ""
var user: Dictionary = {}
var access_token := ""
var refresh_token := ""
var expires_at := 0.0
var notice := "Play offline"
var busy := false
var refreshing := false
var enabled := true
var email_codes_ready := false
var session_epoch := 0
var resend_ready_at := 0

func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	var config = JSON.parse_string(FileAccess.get_file_as_string("res://game/cloud/cloud_config.json"))
	if config is Dictionary:
		endpoint=str(config.get("url","")).trim_suffix("/")
		public_key=str(config.get("publishable_key",""))
		email_codes_ready=bool(config.get("email_codes_ready",false))
	if not configured(): notice="Online service is not configured yet."

func configured() -> bool:
	if not endpoint.begins_with("https://") or public_key.is_empty(): return false
	if public_key.begins_with("sb_publishable_"): return true
	var parts := public_key.split(".")
	if parts.size()!=3: return false
	var encoded := parts[1].replace("-","+").replace("_","/")
	while encoded.length()%4: encoded+="="
	var payload = JSON.parse_string(Marshalls.base64_to_utf8(encoded))
	return payload is Dictionary and payload.get("role","")=="anon"

func authenticated() -> bool:
	return not access_token.is_empty() and not user.is_empty()

func _process(_delta: float) -> void:
	if enabled and authenticated() and not busy and not refreshing and Time.get_unix_time_from_system()>expires_at-45:
		refresh()

func request(path: String, method: int, body: Variant=null, authorized: bool=false) -> Dictionary:
	if not enabled or not configured(): return {"ok":false,"status":0,"data":{},"message":"Online service is not configured yet."}
	var headers := PackedStringArray(["apikey: "+public_key,"Content-Type: application/json"])
	if authorized:
		if not authenticated(): return {"ok":false,"status":401,"data":{},"message":"Sign in to synchronize your journeys."}
		headers.append("Authorization: Bearer "+access_token)
	var http := HTTPRequest.new(); http.timeout=18; http.body_size_limit=8388608
	add_child(http)
	var error := http.request(endpoint+path,headers,method,"" if body==null else JSON.stringify(body))
	if error!=OK:
		http.queue_free()
		return {"ok":false,"status":0,"data":{},"message":"Connection unavailable. Progress remains saved locally."}
	var response: Array=await http.request_completed
	http.queue_free()
	var status: int=response[1]
	var data=JSON.parse_string(response[3].get_string_from_utf8())
	if data==null: data={}
	var code: String=str(data.get("error_code",data.get("code",""))) if data is Dictionary else ""
	var message:=failure_message(status,code)
	return {"ok":response[0]==HTTPRequest.RESULT_SUCCESS and status>=200 and status<300,"status":status,"data":data,"message":message}

static func failure_message(status: int, code: String="") -> String:
	if status==429: return "Too many attempts. Please wait before trying again."
	if code=="email_not_confirmed": return "Confirm your email before signing in."
	if code=="otp_expired": return "The verification link or code has expired. Request a new confirmation email."
	if status in [400,401,403,422]: return "Check your email, password or verification code."
	return "Connection unavailable. Progress remains saved locally."

func accept_session(data: Dictionary) -> bool:
	if not data.get("user") is Dictionary or str(data.get("access_token","")).is_empty(): return false
	var id: String=data.user.get("id","")
	var pattern := RegEx.new(); pattern.compile("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$")
	if pattern.search(id)==null: return false
	user=data.user; access_token=data.access_token; refresh_token=data.get("refresh_token","")
	expires_at=Time.get_unix_time_from_system()+float(data.get("expires_in",3600))
	changed.emit()
	return true

func sign_in(email: String, password: String) -> bool:
	if busy: return false
	busy=true; notice="Connecting…"; status_changed.emit()
	var response := await request("/auth/v1/token?grant_type=password",HTTPClient.METHOD_POST,{"email":email.strip_edges(),"password":password})
	var ok: bool=response.ok and response.data is Dictionary and accept_session(response.data)
	busy=false; notice="Signed in" if ok else response.message; status_changed.emit()
	return ok

func sign_up(email: String, password: String, display_name: String) -> bool:
	if busy: return false
	if password.length()<10:
		notice="Use a password of at least 10 characters."; status_changed.emit(); return false
	busy=true; notice="Connecting…"; status_changed.emit()
	var response := await request("/auth/v1/signup",HTTPClient.METHOD_POST,{"email":email.strip_edges(),"password":password,"data":{"display_name":display_name.strip_edges().left(32)}})
	if response.ok and response.data is Dictionary: accept_session(response.data)
	busy=false
	if authenticated(): notice="Signed in"
	elif response.ok:
		notice="Check your email for a confirmation code." if email_codes_ready else "Open the confirmation link in your email, then sign in here."
	else: notice=response.message
	status_changed.emit(); return response.ok

func resend_confirmation(email: String) -> bool:
	if busy: return false
	var address:=email.strip_edges()
	if not address.contains("@") or "\n" in address or "\r" in address:
		notice="Enter a valid email address."; status_changed.emit(); return false
	if Time.get_ticks_msec()<resend_ready_at:
		notice="Too many attempts. Please wait before trying again."; status_changed.emit(); return false
	busy=true; notice="Connecting…"; status_changed.emit()
	var response:=await request("/auth/v1/resend",HTTPClient.METHOD_POST,{"type":"signup","email":address})
	if response.ok or response.status==429: resend_ready_at=Time.get_ticks_msec()+60000
	busy=false
	notice="If this address is awaiting confirmation, a new email has been requested." if response.ok else response.message
	status_changed.emit(); return response.ok

func verify(email: String, code: String, recovery: bool=false) -> bool:
	if busy: return false
	busy=true
	var response := await request("/auth/v1/verify",HTTPClient.METHOD_POST,{"email":email.strip_edges(),"token":code.strip_edges(),"type":"recovery" if recovery else "signup"})
	var ok: bool=response.ok and response.data is Dictionary and accept_session(response.data)
	busy=false; notice="Signed in" if ok else response.message; status_changed.emit(); return ok

func recover(email: String) -> bool:
	if busy: return false
	busy=true
	var response := await request("/auth/v1/recover",HTTPClient.METHOD_POST,{"email":email.strip_edges()})
	busy=false; notice="Check your email for a recovery code." if response.ok else response.message
	status_changed.emit(); return response.ok

func set_password(password: String) -> bool:
	if busy or password.length()<10: return false
	busy=true
	var response := await request("/auth/v1/user",HTTPClient.METHOD_PUT,{"password":password},true)
	busy=false; notice="Password updated" if response.ok else response.message
	status_changed.emit(); return response.ok

func refresh() -> void:
	if refreshing or refresh_token.is_empty(): return
	refreshing=true
	var ticket:=session_epoch
	var response := await request("/auth/v1/token?grant_type=refresh_token",HTTPClient.METHOD_POST,{"refresh_token":refresh_token})
	if ticket!=session_epoch:
		refreshing=false; return
	if response.ok and response.data is Dictionary: accept_session(response.data)
	elif response.status in [400,401,403]:
		access_token=""; refresh_token=""; notice="Sign in again to synchronize. Local progress is safe."
		status_changed.emit()
	else: expires_at=Time.get_unix_time_from_system()+90
	refreshing=false

func sign_out() -> void:
	if busy: return
	busy=true
	session_epoch+=1
	if authenticated(): await request("/auth/v1/logout?scope=local",HTTPClient.METHOD_POST,null,true)
	user={}; access_token=""; refresh_token=""; expires_at=0
	busy=false; notice="Play offline"; changed.emit(); status_changed.emit()
