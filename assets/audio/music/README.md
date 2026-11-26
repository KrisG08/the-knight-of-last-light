# Last Light original score

## Current gameplay score — v0.5.66

Exploration, combat, boss and dawn loops are original slowed dark-fantasy phonk
compositions from `tools/compose_dark_fantasy_score.py`: 62 / 70 / 76 / 58 BPM,
48 kHz stereo, Vorbis quality 6. They combine synthesized sub/bass harmonics,
bell/FM motifs, swung hats and half-time drums with restrained harmonic pads.
No external recordings, commercial melodies or sampled vocals are included.
The existing menu.ogg is preserved; former gameplay files remain in ignored
`art/audio/music-v0558`. The opening has its own separately event-scored cue.

Decoded peaks, RMS levels and circular seam checks are recorded in
`.tools/review/v0566-music-quality.json`. Listening preference and real-phone
speaker balance require owner review. Track switches, independent volume,
voice ducking and crossfades use the existing journey-music controller.

## Earlier source generation

Five original instrumental loops, authored for this repository with
`tools/render_score.py`. No external melodies, recordings or samples are used.
Python masters: 44.1 kHz stereo PCM; delivery: Ogg Vorbis quality 6.

Menu / exploration: slow minor-key pads and bell motif; combat / boss:
plucked ostinato and synthesized low percussion; dawn: warmer harmonic ending.
Wrapped note tails and circular early reflections avoid hard loop cuts.
These are synthesized score assets, not recorded orchestral performances.

The persistent journey music node selects and crossfades two streaming decks on
the Music bus. Regional environmental emitters remain independently on SFX.
