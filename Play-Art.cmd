@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-art\LastLight.exe" (
  echo Art preview missing.
  pause
  exit /b 1
)
start "" "build\windows-art\LastLight.exe"
