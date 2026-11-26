extends RefCounted
## Shared timings and arcs for physics and visible sword movement.
const LIGHT = [
	{"windup":0.20,"active":0.12,"duration":0.62,"from":-1.1,"to":1.1,"multiplier":1.0,"reach":2.3},
	{"windup":0.18,"active":0.12,"duration":0.58,"from":1.1,"to":-1.1,"multiplier":1.0,"reach":2.3},
	{"windup":0.28,"active":0.16,"duration":0.82,"from":-0.65,"to":0.65,"multiplier":1.35,"reach":2.5}
]
const HEAVY = {"windup":0.55,"active":0.18,"duration":1.28,"from":-0.8,"to":0.8,"multiplier":1.8,"reach":2.5}
static func resolve(heavy: bool, step: int) -> Dictionary:
	return HEAVY if heavy else LIGHT[clampi(step,0,2)]
