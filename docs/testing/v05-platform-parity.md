# v0.5 Windows / Android parity

The owner clarified that their laptop "web version" is the native executable
launched by Play-Village-Detail.cmd from build/windows-village. No website is in
scope. Export the current shared campaign to build/windows-v05, then update that
existing launcher while retaining its exact APPDATA redirection. Older exported
folders remain intact; no player saves are copied, reset or uploaded.

The previous desktop-only menu path is removed: both platforms use the same
frontend, saved-journey library, world progress view, fonts, atmosphere and pause
navigation. Input and graphics adapt by platform. An independent named-action
pulse node makes More actions work without requiring a touch overlay on Windows;
pause cancels pending menu input on both platforms.

Source tests: 508 assertions PASS. Independent headless desktop/touch startup and
menu-flask flows PASS via tests/check_platform_parity.gd. Native laptop capture
uses tests/capture_mobile_frontend.gd -- --desktop and does not enable touch mode.
This does not claim a full human campaign playthrough or hardware phone test.

Both packages carry version 0.5.0. Existing Windows/Android journeys remain private
to their installation. Feature/version parity does not imply cross-device save
synchronization. The Windows launcher uses .tools/userdata; directly launching an
EXE uses normal Windows APPDATA, as before.

Final evidence: 59 exported game .gdc files are byte-identical between the Windows
PCK and Android APK (tools/verify_platform_packs.gd). Windows folder and ZIP payload
hashes match; exported EXE review-mode smoke exits 0 with native Vulkan startup
and no engine/script errors. Android signature continuity and manifest verified.
PCK SHA256 E2090F0B639EC2802B05F92166533BF2B656F049C350782982EE9188BBFF0001.
APK SHA256 E40107CA9F04739CBC298BFCE286D5C6BB3AB6D6EA314C9C798AC084902C7C5F.
Smoke mode uses memory-only campaign/settings, preserving real player files.
