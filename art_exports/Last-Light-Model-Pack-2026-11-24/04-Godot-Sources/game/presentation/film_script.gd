extends RefCounted
## One timing/source authority for offline animation, subtitles and localized voice.
const STARTS = [0.0,11.0,21.0,30.0]
const DURATIONS = [11.0,10.0,9.0,10.0]
const LENGTH = 40.0
const CAPTIONS = [
	"Maldrek seized the citadel. Through four ancient seals, his curse reached the kingdom.",
	"The Order marched along the old forest road. You went with them.",
	"The curse broke the expedition. Beneath the eclipse, the road fell silent.",
	"You survived. One lantern still burns. Find the others."
]
const VICTORY = ["Maldrek has fallen. The curse still clings to the artifact.", "Shatter the central artifact to end the curse"]
static func shot(time: float) -> int:
	return 0 if time<STARTS[1] else (1 if time<STARTS[2] else (2 if time<STARTS[3] else 3))
