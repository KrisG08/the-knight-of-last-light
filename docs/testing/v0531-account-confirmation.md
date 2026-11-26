# Confirmation return and cloud sync — v0.5.31, 2026-11-08

Engine: Godot 4.7.2.stable.official.ed1daf0bf. No Git repository available.

Two independently reproduced failures:

1. Public `/auth/v1/verify` with an intentionally invalid fixture token returned
   HTTP 303 to `http://localhost:3000`. The production Site URL was unchanged
   from the development default. `tools/check_auth_redirect.py` failed before
   the correction and passed afterwards. No personal email link/token inspected.
2. Owner then signed in successfully but saw unavailable-cloud feedback.
   Loaded Godot save JSON sends `schema_version: 8.0`; deployed RPC text regex
   accepted only `8`. Schema usage, table SELECT and RPC EXECUTE grants were all
   present. The actual RPC regression before the fix rejected valid 1.0/8.0
   and accepted the invalid string `"8"`. After the numeric type/value fix all
   12 cases passed. The regression is read-only and writes zero journeys.

Applied to the existing Supabase project through its dashboard:

- Deployed `account-confirmation`, fixed public instructions in five languages.
  No database access, auth SDK, secrets, logging, credential exchange or user
  input reflection. Free Supabase functions do not serve HTML, so this is an
  honest text page. It never reports successful confirmation for an expired link.
- A fixed same-origin 303 with explicit `#last-light` replaces any incoming
  session/error fragment. Native browser fixture check confirmed the cleaned URL.
  No cache and no-referrer headers; the game signs in with its own password flow.
- Public access applies only to this information-only function. Supabase email
  confirmation and private journey policies remain enabled.
- Site URL now points to the deployed return route. No wildcard redirect added.
- Applied `backend/supabase/migrations/20261108_accept_integral_schema_numbers.sql`.
  CREATE OR REPLACE only; no table data, RLS or grants reset. Existing snapshots
  and content hashes are retained.

Actual checks:

- `tests/account_confirmation_page.mjs`: fixed-origin fragment replacement,
  five languages, no echo/cache, HEAD and method rejection PASS.
- `tests/account_confirmation_regression.gd`: 13 assertions PASS (after a real
  missing-resend failure), including correct link/code notice, resend payload,
  cooldown, invalid input, server rate limit and no false email-send success.
- `tests/account_confirmation_ui.gd`: 25 assertions PASS with native five-language
  captures. Bulgarian login/resend layout reviewed.
- `tests/run_cloud_checks.gd`: 21 replica/conflict/isolation assertions PASS.
- `tests/menu_sections_translation.gd`: 211 assertions PASS.
- `backend/supabase/tests/schema_numbers.sql`: real RPC 12 cases FAIL before,
  PASS after. Screenshots `.tools/review/cloud-schema-before.png` and `-after.png`.
- Public redirect/return probe PASS after deployment and Site URL correction.
  `.tools/auth-redirect-fixed.log`; saved settings `.tools/review/auth-url-fixed.png`.
- Owner screenshot confirmed real sign-in. Read-only observation of the running
  game's sync metadata after the server fix: 9 journeys, 9 acknowledged cloud
  revisions, 0 pending. Aggregate evidence `.tools/account-live-sync-evidence.json`.
  No session token/password read, no real email sent by the agent, no journey
  imported or removed manually. The running v0.5.30 client retried its own sync.

Client improvements: replacement-confirmation button, truthful link-versus-code
notice, specific expired-link message, localized new feedback and appropriate
signed-in help text. No automatic browser-to-game session handoff or persistent
login added. Local journeys remain authoritative and guest/account stores separate.

Limitations: no new real Gmail confirmation/recovery round trip or Android live
sign-in tested by the agent; no new two-device/conflict acceptance. Default email
sender restrictions remain; custom SMTP/OTP templates still require owner setup.
The server fixes already apply to existing clients. New resend UI needs v0.5.31.

Primary references checked:
https://supabase.com/docs/guides/auth/redirect-urls
https://supabase.com/docs/guides/functions/development-tips
https://supabase.com/docs/reference/javascript/auth-resend

Release evidence:

- Isolated Windows PCK: 39 localization assertions, 13 auth assertions and
  27 account UI assertions PASS, including translated resend feedback and
  correct signed-in help text. No source-folder fallback.
- Windows/Android: all 100 compiled scripts, 162 character resources, five
  locale/cloud data files and the existing menu film match. Android v2/v3
  signatures verified; both delivery archives passed ZIP CRC checks.
- Windows `build/windows-v0531`; Android code 36/version
  `0.5.31-account-confirmation`, `build/android-releases/LastLight-0.5.31.apk`.
  APK 424,039,387 bytes, SHA-256
  `e3d8a2145b479c1b6da3a5b16ced107988541adcc2f3da11a7640b95751eeaaf`.
  Windows ZIP 502,733,330 bytes, SHA-256
  `b514934e138c1156c8a1ae1fa2d0ea2611e6ea060a0a00ee98e9f61543729da4`.
- Anonymous real journey read still rejected with HTTP 401 after the migration.
  Public information-page access does not grant access to private snapshots.
- Latest launcher points to v0.5.31. No public upload of this APK performed;
  previous Gofile link still serves v0.5.30. Existing running owner app was
  left open and signed in, with its nine acknowledged cloud journeys.
