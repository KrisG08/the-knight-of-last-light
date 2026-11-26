extends RefCounted
const STARTS=[0.0,10.0,20.0,29.6,38.8,47.8,59.0,69.5]
const DURATIONS=[10.0,10.0,9.6,9.2,9.0,11.2,10.5,10.5]
const LENGTH=80.0
static func shot(time: float) -> int:
	for index in range(STARTS.size()-1,-1,-1):
		if time>=STARTS[index]: return index
	return 0
