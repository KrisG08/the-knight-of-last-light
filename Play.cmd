@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist ".tools\godot\Godot_v4.7.2-stable_win64.exe" (
  echo Portable Godot is missing. See SETUP.md.
  pause
  exit /b 1
)
".tools\godot\Godot_v4.7.2-stable_win64.exe" --path "%~dp0." res://game/bootstrap/game_root.tscn
