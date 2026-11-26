# Optional account replicas and presentation localization

Owner-approved scope revision, 2026-11-07: optional online accounts synchronize
journeys across Android and Windows, using Supabase; the game has five UI/story
languages. This supersedes the earlier exclusion of backend/account work.
Accounts remain optional and the local single-player campaign stays playable.

The campaign model and save-v8 invariants remain authoritative. A separate cloud
adapter uploads only validated durable snapshots. Per-account local stores keep
guest journeys separate. A UUID sidecar associates local slots with remote
journeys. A content hash ignores device slot IDs and timestamps; revisions use
compare-and-swap. Divergent edits fork into two journeys rather than dropping
either branch. Server RLS restricts reads to the authenticated owner; writes go
through an owner-checked function. Clients never contain privileged keys.

Passwords and session tokens are memory-only. This deliberately requires login
after restart until a platform secure-storage adapter is implemented. Email
verification is retained. SMTP configuration is owner-controlled and currently
pending; do not advertise public registration or recovery as completed.

Localization is a presentation adapter with English source text, weak UI
bindings, dynamic templates and persistent language settings. Save IDs, actions,
history keys and user input remain unchanged. Cinzel is used where supported;
Noto Serif covers Cyrillic and Noto Naskh Arabic covers Arabic shaping. Controls
follow locale direction, including mirrored navigation decoration. Google
machine translation bootstraps gameplay text; core UI and selected terminology
are manually edited. Native-language narrative proofreading remains necessary.
