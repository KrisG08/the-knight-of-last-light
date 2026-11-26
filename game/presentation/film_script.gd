extends RefCounted
## Authored 80-second film; timing is shared with captions and localized speech.
const STARTS = [0, 10, 20, 29.6, 38.8, 47.8, 59, 69.5]
const DURATIONS = [10, 10, 9.6, 9.2, 9, 11.2, 10.5, 10.5]
const LENGTH = 80.0
const CAPTIONS = [
  "Four ancient seals once guarded the kingdom. Above them stood the citadel, watched over by the Order.",
  "Maldrek seized it and bound the seals to an artifact. He drained the kingdom's life to prolong his reign.",
  "Crops withered. The dead rose. Those who survived were dragged behind iron doors.",
  "Your master led the Order down the old forest road. You believed you could still reach the citadel.",
  "Maldrek saw you coming. He raised his staff, and the curse tore open the sky.",
  "Shields shattered. Your companions fell. You reached for a fallen knight, but the darkness took him.",
  "You woke among broken banners. Beyond the silent trees, one lantern was still burning.",
  "A ruined chapel waits beyond the trees. Find the other survivors. You cannot reclaim this kingdom alone."
]
const VICTORY = ["Maldrek has fallen. The curse still clings to the artifact.", "Shatter the central artifact to end the curse"]
static func shot(time: float) -> int:
	for index in range(STARTS.size()-1,-1,-1):
		if time>=STARTS[index]: return index
	return 0
