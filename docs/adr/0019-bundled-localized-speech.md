# ADR 0019: Bundled, localized narrative speech

2026-11-21. Accepted. The owner explicitly approved sending only authored game
dialogue to Microsoft Edge through edge-tts for five-language audio production.

## Context

The owner requests speech for conversations and cinematic captions in all five
supported languages. Native system TTS depends on installed language voices;
availability differs across Windows and Android. A language picker must not
silently substitute English speech when another language is selected.

## Decision

Use bundled per-language audio for authored NPC prose, inscriptions, the opening,
wizard defeat and final narrative. `NarrativeVoice` owns one audio player and a
bounded queue. Its small interface is `say`, `dialogue`, `stop_for`, `speaking`.
An owner reference makes cancellation local to the conversation or cinematic;
closing one view cannot stop a later view's speech. Gameplay rewards, saves,
dialogue actions and combat never depend on audio completion.

English authored dialogue remains the source. The development exporter derives
spoken paragraphs and translates them with the same localization adapter as UI.
Hash keys include speaker and source text. Five-language clips and metadata are
validated before release. Shop statistics, account data, journals and legal
credits are not sent to the voice builder and are not screen-reader content.

The offline development tool uses edge-tts 7.3.1 to request synthesis from
Microsoft Edge's online speech service. This is a community client, not an
official Azure SDK or a service-level guarantee. The game bundles results and
contains no service token, Python library, synthesis endpoint, microphone or
runtime request. Original synthesis masters remain outside runtime assets.
The automatic review rejected the initial sample before it ran. After a separate
owner approval, the Bulgarian sample succeeded and production began. No text was
sent by the rejected command; account data and player saves remain excluded.

Speech has a separate Voice bus, volume and opt-out. Subtitles remain visible.
Music/film score is reduced while speech is playing. Changing language cancels
the previous language and displayed conversations restart in the new language.
Skipping a film or closing a conversation stops its speech immediately. Missing
clips stay silent and are exposed to checks; there is no wrong-language fallback.

## Consequences and limits

Bundled clips increase package size but keep runtime playback deterministic and
offline. Translation/source edits require regenerating affected clips. Voices
are synthesized narration, not actor performances or facial lip synchronization.
Generation service availability and output distribution terms are separate from
the client library's license; no external publication or commercial clearance is
claimed by installing the tool. Local prototype production is the current scope.

References: Godot TTS documentation,
https://docs.godotengine.org/en/stable/tutorials/audio/text_to_speech.html ;
edge-tts project, https://github.com/rany2/edge-tts .
