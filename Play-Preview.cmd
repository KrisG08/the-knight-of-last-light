@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0.tools\userdata"
if not exist "build\windows-preview\LastLight.exe" (
  echo Preview build missing.
  pause
  exit /b 1
)
start "" "build\windows-preview\LastLight.exe"
