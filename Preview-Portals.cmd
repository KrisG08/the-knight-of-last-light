@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\portal-preview-userdata"
start "" ".tools\godot\Godot_v4.7.2-stable_win64.exe" --path . --script res://tools/debug/preview_portals.gd
