# Save and main menu — 0.5.19

The pause footer now says "Save and main menu". A successful save deactivates the
live journey, clears the target/input, pauses simulation and restores the title
page, saved-journey selector and Continue button. Continue reloads the same save.
Save failure preserves the active session and dirty state for retry. Explicit
title-screen Quit and the window close action keep their application-exit role.
Shared frontend callback applies to Windows and Android. Inactive title-screen
journal hotkeys cannot reopen gameplay UI.

Actual Godot 4.7.2 checks:

- Native desktop and desktop touch-preview: pause footer activated, title screen
  remains open, art/Continue shown, player disabled. Logs:
  `.tools/save-menu-native-desktop.log`, `.tools/save-menu-native-mobile.log`;
  captures `.tools/review/save-menu-desktop.png` and `save-menu-mobile.png`.
- Campaign runner tests the actual footer/Continue signals, disk save failure at
  promotion in a temporary store, retry, title state and same-slot reload.
  `.tools/save-menu-tests-final.log`.

Touch preview is not a real-phone acceptance test. Save semantics remain the
existing checkpoint/world-progress model; no new exact-position save contract.
