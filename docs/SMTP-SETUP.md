# Complete account email delivery

The project's private journey table and revision-checked commit function have
been installed in Supabase project `vtvvevevkhqwyemrpawy`. The shipped game has
only the public publishable key. No service key or database password belongs in
the game. Email confirmation remains enabled.

Account registration is a preview until the owner configures email delivery.
The production confirmation return URL was repaired on 2026-11-08; localhost
is no longer used. The public information route is
`https://vtvvevevkhqwyemrpawy.supabase.co/functions/v1/account-confirmation`.
Return to the game and sign in after opening the email. Version 0.5.31 also
offers Resend confirmation email for an unused/expired confirmation. This
redirect repair does not lift default-sender restrictions or enable recovery.

Supabase's default sender delivers only to organization members and does not
allow custom confirmation/recovery templates. The current game supports the
default confirmation link, followed by signing in. In-app recovery is visibly
unavailable until code delivery is configured.

## Owner steps

For a small private test without buying a domain, a personal Gmail account can
provide SMTP if Google allows App Passwords for that account. School/workspace
administrators may prohibit this. Use a dedicated sender account when possible.

1. In that Google account, enable two-step verification if needed. Open
   [App passwords](https://myaccount.google.com/apppasswords) and create one for
   Last Light. Complete these credential steps yourself. Do not paste the
   password into chat or commit it to the project.
2. Open [Supabase Authentication Emails](https://supabase.com/dashboard/project/vtvvevevkhqwyemrpawy/auth/templates),
   then **SMTP Settings / Set up SMTP**.
3. Enter the following directly in Supabase:

   | Field | Value |
   |---|---|
   | Sender email | Your Gmail sender address |
   | Sender name | The Knight of Last Light |
   | Host | smtp.gmail.com |
   | Port | 587 with TLS/STARTTLS |
   | Username | The same complete Gmail address |
   | Password | The Google App Password, not your normal Google password |

4. Save. In **Confirm sign up**, paste the contents of
   `backend/supabase/mail/signup.html`. In **Reset password**, paste
   `backend/supabase/mail/recovery.html`. Save each template. Keep confirmation,
   TLS and rate limiting enabled.
5. Tell Codex the email service is configured, without sending its password.
   We will test delivery to an address you control, enter the code manually,
   and verify password recovery. Only then set `email_codes_ready` to `true`
   in `game/cloud/cloud_config.json` and rebuild both platforms.

Gmail is a limited test sender, not a recommendation for a public launch at
scale. A production sender such as Resend with a verified domain can be
connected through the same Supabase SMTP form later.

## Real-device acceptance still required

Create an account on Android, verify email, import a local journey explicitly,
defeat an enemy/boss, save and return to menu. Sign in on Windows and sync; check
that the progress and defeated bosses appear. Make different offline edits on
both devices; sync and verify that two branches are retained. Test sign-out,
re-login, rate limiting and recovery. Automated replica tests are not proof of
real email delivery or a two-device test.

Sessions currently last until the application closes; tokens/passwords are
kept in memory only. Offline guest journeys remain available independently.
Signed-in local progress is stored under `user://accounts/<user-id>/saves` and
never overwrites the guest library. After restarting, sign in to reopen that
account's library. Persistent secure sign-in is not implemented.

Sources checked 2026-11-08:
- https://supabase.com/docs/guides/auth/auth-smtp
- https://supabase.com/docs/guides/auth/auth-email-templates
- https://support.google.com/mail/answer/185833
- https://developers.google.com/workspace/gmail/imap/imap-smtp
